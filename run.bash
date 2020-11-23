#!/bin/bash

# This is to let the script abort if any command fails.
set -e

# Assumptions of this script:
# - an environment variable CRYPTOVERIF is defined and points to the
#   directory where the CryptoVerif folder is located. This is the
#   folder that contains for example the files build, and after
#   building CryptoVerif, the file default.ocvl
#   If you do not have the environment variable CRYPTOVERIF defined,
#   you can also uncomment the following line and adapt the path
#   accordingly:
#CRYPTOVERIF=~/CryptoVerif

# Define some paths
CV=${CRYPTOVERIF}/cryptoverif
STDLIB=${CRYPTOVERIF}/default.ocvl
LIB=lib.ocvl
OUT=out

# Check presence of standard library
if [[ -f ${STDLIB} ]]; then
  echo "Found the CryptoVerif standard library at ${STDLIB}."
  cat ${STDLIB} lib.truncate.ocvl lib.option.ocvl lib.choice.ocvl lib.gdh.ocvl lib.authkem.ocvl lib.aead.ocvl lib.prf.ocvl > ${LIB}
else
  echo "I don't seem to find the CryptoVerif standard library at"
  echo "${STDLIB}"
  echo "Please set the CRYPTOVERIF environment variable correctly,"
  echo "or set the CRYPTOVERIF variable by editing this script."
  exit 1
fi

# Check presence of CryptoVerif binary.
if [[ -f ${CV} ]]; then
  echo "Found the CryptoVerif binary at ${CV}."
else
  echo "I don't seem to find the CryptoVerif binary at"
  echo "${CV}"
  echo "Please set the CRYPTOVERIF environment variable correctly,"
  echo "or set the CRYPTOVERIF variable by editing this script."
  echo "Please verify that you ran the build script to compile CryptoVerif."
  exit 1
fi

if [[ -d ${OUT} ]]; then
  echo "Intermediate games output will be stored in ${OUT}."
else
  if [[ -f ${OUT} ]]; then
    echo "Expected ${OUT} to be a directory for intermediate games output,"
    echo "but it appears to be a file. Please change the OUT variable in"
    echo "this script or remove the file."
    exit 1
  fi
  mkdir -p ${OUT}
  echo "Intermediate games output will be stored in newly created directory ${OUT}."
fi


function prove() {
  MODEL="$1"
  CVFILE="${MODEL}.ocv"
  if [[ -f ${CVFILE} ]]; then
    echo "Running CryptoVerif on ${CVFILE}"
    set +e # we want to treat failures of CryptoVerif
    eval "${CV} -lib ${LIB} -oproof ${MODEL}.proof -o ${OUT} ${CVFILE} > ${MODEL}.out"
    RESULT=$? # get the return code of CryptoVerif
    if [[ "$RESULT" -eq "0" ]]; then
      tail -n 2 ${MODEL}.out
      # return code 0 does not necessarily mean that the proof
      # succeeded, so the following grep might return 0 lines
      grep "RESULT Proved" ${MODEL}.proof
    else
      echo "CryptoVerif terminated with an error:"
      tail -n 5 ${MODEL}.out
    fi
    set -e # go back to exit-on-error mode
  else
    echo "I don't seem to find ${CVFILE}, skipping this proof."
  fi
}


function generate_and_prove() {
  MODEL="$1"
  M4FILE="${MODEL}.m4.ocv"
  CVFILE="${MODEL}.ocv"
  echo ""
  if [[ -f ${M4FILE} ]]; then
    echo "Generating CryptoVerif model"
    m4 ${M4FILE} > ${CVFILE}
    prove ${MODEL}
  else
    echo "I don't seem to find ${M4FILE}, skipping this proof."
  fi
}

# Run DHKEM proofs.
for NOTION in outsider-cca outsider-auth insider-cca; do
  generate_and_prove "dhkem.auth.${NOTION}-lr"
done

echo ""
# Run KeySchedule proof in standard model for KeySchedule_auth.
prove "keyschedule.auth.prf"

# Run composition proofs.
for NOTION in outsider-cca outsider-auth insider-cca; do
  generate_and_prove "hpke.auth.${NOTION}"
done
