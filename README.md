# Supplementary Material for HPKE Proofs

## Preliminaries

The “RFC” we are referring to in this README, is
[the current draft-RFC on Hybrid Public Key Encryption](https://www.ietf.org/id/draft-irtf-cfrg-hpke-05.html).

### Installation of CryptoVerif

You can get CryptoVerif from [its website](https://cryptoverif.inria.fr).
We refer to the README in the downloadable archive for installation
instructions.

### Windows

Under Windows, to be able to execute the Bash script `run.bash`, we
recommend installing [Cygwin](https://cygwin.com/). If you are on
Windows 10, [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
is also an option.

## Running the proofs

The script `run.bash` can be used to run the proofs. It needs a
`CRYPTOVERIF` environment variable set to the directory in which
the CryptoVerif binary is located. You can also edit the script and
set the variable there.

### Outputs

For each proof, two files are generated:
- one file `*.proof`, containing the proof written by CryptoVerif.
  This file contains the bound.
- one file `*.out`, containing CryptoVerif's auxiliary output, which
  is only interesting in case of problems.

## Files in this Directory

### Library Files

The files with filenames starting by `lib.*` contain macro definitions
for CryptoVerif:

- `lib.authkem.ocvl`: assumptions on authenticated KEMs as defined
  in the paper
- `lib.gdh.ocvl`: the GDH assumption as used by the paper. This is a
  simplified version of the GDH assumption available in the standard
  CryptoVerif library, with just the oracles needed for our proofs.
- `lib.aead.ocvl`: defines an AEAD scheme, with multikey security notions.
- `lib.prf.ocvl`: defines a PRF, with a multikey security notion.
- `lib.choice.ocvl`: defines convenience functions to choose between
  plaintexts m0 and m1 based on a bit b.
- `lib.option.ocvl`: defines a macro for option types, which we heavily
  use as return types of functions
- `lib.truncate.ocvl`: defines an equivalence for transforming a
  uniformly distributed random value of one type into a uniformly
  distributed random value of another, shorter, type.
- `lib.ocvl`: this is the concatenation of the CryptoVerif standard
  library and the files just mentioned in this list.

### Common Definitions

The files with filenames starting by `common.*` contain definitions
used in multiple models:

- `common.dhkem.dh.ocv`: definition of the Diffie-Hellman group for
  all DHKEM security notions
- `common.dhkem.ocv`: definition of DHKEM as defined in the RFC
- `common.hpke.ocv`: definition of HPKE (only everything after the KEM)
  as defined in the RFC

These files are included by the `*.m4.ocv` files that generate the model files.

### Model Files

The ”model files” are the files on which we run CryptoVerif. Each model
contains the definition of a security notion, the definition of the
game, and the proof.

We prove three security notions for DHKEM, and three security notions
for HPKE. These three files share a lot of code, which is why we generate
the files from templates. These templates are the `*.m4.ocv` files; m4
makes reference to the preprocessor m4 which we use.

#### Which files to read

If you don't mind jumping around in one big file, you can read the
`*.ocv` files listed below.

If you prefer smaller files, you can read the `*.m4.ocv` files for
an overview, and look at the included files separately.

#### DHKEM

- `dhkem.auth.outsider-cca-lr.ocv`: Prove that DHKEM as defined in the
  RFC is Outsider-CCA-secure.
- `dhkem.auth.outsider-auth-lr.ocv`: Prove that DHKEM as defined in the
  RFC is Outsider-Auth-secure.
- `dhkem.auth.insider-cca-lr.ocv`: Prove that DHKEM as defined in the
  RFC is Insider-CCA-secure.

#### KeySchedule

We do not use a template for this proof, because it is the only one of
its kind.

- `keyschedule.auth.prf.ocv`: Prove that the key schedule `KS_auth()` as
  used by HPKE's mode Auth, is a PRF with `shared_secret` as key.

#### HPKE Composition Proofs

These models treat HPKE as defined in the RFC, assuming
- KeySchedule (without the VerifyPSKInputs call) is a PRF with
  `shared_secret` as key
- the KEM used is an authenticated KEM satisfying the appropriate
  above-mentioned security notions

There is one model for each security notion:

- `hpke.auth.outsider-cca.ocv`: Prove that HPKE is Outsider-CCA-secure.
- `hpke.auth.outsider-auth.ocv`: Prove that HPKE is Outsider-Auth-secure.
- `hpke.auth.insider-cca.ocv`: Prove that HPKE is Insider-CCA-secure.
