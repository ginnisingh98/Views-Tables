--------------------------------------------------------
--  DDL for Package FND_CRYPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CRYPTO" AUTHID CURRENT_USER AS
/* $Header: AFSOCTKS.pls 120.2 2005/09/24 00:11:26 jnurthen noship $ */

    -- Hash Functions
    HASH_MD5           CONSTANT PLS_INTEGER      :=     2;

    -- MAC Functions
    HMAC_MD5           CONSTANT PLS_INTEGER      :=     1;
    HMAC_CRC           CONSTANT PLS_INTEGER      :=     4;

    -- Block Ciphers
    DES_CBC_PKCS5      CONSTANT PLS_INTEGER      :=  4353;
    DES3_CBC_PKCS5     CONSTANT PLS_INTEGER      :=  4355;

    -- Encoding Formats
    ENCODE_B64         CONSTANT PLS_INTEGER      :=     1;  -- Base 64
    ENCODE_URL         CONSTANT PLS_INTEGER      :=     2;  -- URL 64
    ENCODE_ORC         CONSTANT PLS_INTEGER      :=     3;  -- URL 64 drop bits

    -- Conversion formats
    CONVERT_ICX_STYLE  CONSTANT PLS_INTEGER      :=     1;  -- icx.CRC style





    ----------------------------- EXCEPTIONS ----------------------------------
    -- Invalid Cipher Suite
    InvalidCipherSuite EXCEPTION;
    PRAGMA EXCEPTION_INIT(InvalidCipherSuite, -28827);


    ---------------------- FUNCTIONS AND PROCEDURES ------------------------

    ------------------------------------------------------------------------
    --
    -- NAME:  Encrypt
    --
    -- DESCRIPTION:
    --
    --   Encrypt plain text data using stream or block cipher with user
    --   supplied key and optional iv.
    --
    -- PARAMETERS
    --
    --   plaintext   - Plaintext data to be encrypted
    --   crypto_type - Stream or block cipher type plus modifiers
    --   key         - Key to be used for encryption
    --   iv          - Optional IV for block ciphers.  Default all zeros.
    --
    ------------------------------------------------------------------------
    FUNCTION Encrypt (plaintext   IN RAW,
                      crypto_type IN PLS_INTEGER  DEFAULT DES3_CBC_PKCS5,
                      key         IN RAW,
                      iv          IN RAW          DEFAULT NULL)
      RETURN RAW;


    ------------------------------------------------------------------------
    --
    -- NAME:  Decrypt
    --
    -- DESCRIPTION:
    --
    --   Decrypt crypt text data using stream or block cipher with user
    --   supplied key and optional iv.
    --
    -- PARAMETERS
    --
    --   cryptext    - Crypt text data to be decrypted
    --   crypto_type - Stream or block cipher type plus modifiers
    --   key         - Key to be used for encryption
    --   iv          - Optional IV for block ciphers.  Default all zeros.
    --
    ------------------------------------------------------------------------
    FUNCTION Decrypt (cryptext    IN RAW,
                      crypto_type IN PLS_INTEGER DEFAULT DES3_CBC_PKCS5,
                      key         IN RAW,
                      iv          IN RAW          DEFAULT NULL)
      RETURN RAW;


    ------------------------------------------------------------------------
    --
    -- NAME:  EncryptNum
    --
    -- DESCRIPTION:
    --
    --   Encrypt number with DES_CBC.  Number is converted to binary form
    --   (hexify then RAW), padded with leading ZEROs, encrypted and
    --   encoded with URL-Safe Base64.
    --
    -- PARAMETERS
    --
    --   num - Number to be encrypted
    --   key - Key to be used for encryption
    --   iv  - Optional IV for block ciphers.  Default all zeros.
    --
    ------------------------------------------------------------------------
    FUNCTION EncryptNum(num       IN NUMBER,
                        key       IN RAW,
                        iv        IN RAW         DEFAULT NULL)
      RETURN VARCHAR2;


    ------------------------------------------------------------------------
    --
    -- NAME:  DecryptNum
    --
    -- DESCRIPTION:
    --
    --   Decrypt Varchar2 to number with DES_CBC.  Varchar2 is decoded,
    --   decrypted, hexified and converted to a number.
    --
    -- PARAMETERS
    --
    --   cryptext - Data to be decrypted into a number.
    --   key      - Key to be used for decryption
    --   iv       - Optional IV for block ciphers.  Default all zeros.
    --
    ------------------------------------------------------------------------
    FUNCTION DecryptNum(cryptext  IN VARCHAR2,
                        key       IN RAW,
                        iv        IN RAW         DEFAULT NULL)
      RETURN NUMBER;


    ------------------------------------------------------------------------
    --
    -- NAME:  Hash
    --
    -- DESCRIPTION:
    --
    --   Hash source data by cryptographic hash type.
    --
    -- PARAMETERS
    --
    --   source    - Source data to be hashed
    --   hash_type - Hash algorithm to be used
    --
    -- USAGE NOTES:
    --   SHA-1 (HASH_SH1) is recommended.  Consider encoding returned
    --   raw value to hex or base64 prior to storage.
    --
    ------------------------------------------------------------------------
    FUNCTION Hash (source    IN RAW,
                   hash_type IN PLS_INTEGER default HASH_MD5)
      RETURN RAW;


    ------------------------------------------------------------------------
    --
    -- NAME:  Mac
    --
    -- DESCRIPTION:
    --
    --   Message Authentication Code algorithms provide keyed message
    --   protection.
    --
    -- PARAMETERS
    --
    --   source   - Source data to be mac-ed
    --   mac_type - Mac algorithm to be used
    --   key      - Key to be used for mac
    --
    -- USAGE NOTES:
    --   Callers should consider encoding returned raw value to hex or
    --   base64 prior to storage.
    --
    ------------------------------------------------------------------------
    FUNCTION Mac (source   IN RAW,
                  mac_type IN PLS_INTEGER default HMAC_MD5,
                  key      IN RAW)
      RETURN RAW;


    ------------------------------------------------------------------------
    --
    -- NAME:  RandomBytes
    --
    -- DESCRIPTION:
    --
    --   Returns a raw value containing a pseudo-random sequence of
    --   bytes.
    --
    -- PARAMETERS
    --
    --   number_bytes - Number of pseudo-random bytes to be generated.
    --
    -- USAGE NOTES:
    --   number_bytes should not exceed maximum RAW length.
    --
    ------------------------------------------------------------------------
    FUNCTION RandomBytes (number_bytes IN POSITIVE)
      RETURN RAW;


    ------------------------------------------------------------------------
    --
    -- NAME:  RandomNumber
    --
    -- DESCRIPTION:
    --
    --   Returns a random NUMBER, 16 bytes.
    --
    -- PARAMETERS
    --
    --  None.
    --
    ------------------------------------------------------------------------
    FUNCTION RandomNumber
      RETURN NUMBER;

    ------------------------------------------------------------------------
    --
    -- NAME:  SmallRandomNumber
    --
    -- DESCRIPTION:
    --
    --   Returns a small random NUMBER, 4 bytes.
    --
    -- PARAMETERS
    --
    --  None.
    --
    ------------------------------------------------------------------------
    FUNCTION SmallRandomNumber
      RETURN NUMBER;

    ------------------------------------------------------------------------
    --
    -- NAME:  Encode
    --
    -- DESCRIPTION:
    --
    --   Encodes a RAW into specified format (ENCODE_*).
    --
    -- PARAMETERS
    --
    --   source   - Source data to be endoded.
    --   fmt_type - Encoding type for raw to varchar2.
    --
    ------------------------------------------------------------------------
    FUNCTION Encode (source   IN RAW,
                     fmt_type IN PLS_INTEGER)
      RETURN VARCHAR2;


    ------------------------------------------------------------------------
    --
    -- NAME:  Decode
    --
    -- DESCRIPTION:
    --
    --   Decodes a VARCHAR2 into RAW using the specified format (ENCODE_*).
    --
    -- PARAMETERS
    --
    --   source   - Source data to be endoded.
    --   fmt_type - Encoding type for varchar2 to raw.
    --
    ------------------------------------------------------------------------
    FUNCTION Decode (source   IN VARCHAR2,
                     fmt_type IN PLS_INTEGER)
      RETURN RAW;

    ------------------------------------------------------------------------
    --
    -- NAME:  RandomString
    --
    -- DESCRIPTION:
    --
    --   Returns a random VARCHAR2, of a length len, made up of
    --   user-secified characters.
    --   If using the output of this function to generate passwords it is the caller's
    --   responsisilbity to ensure that the generated password conforms to any password
    --   rules. This routine merely generates a random fixed length string from an input mask.
    --
    --   If sublen is specified then a second mask sublen_msk is used for the first sublen
    --   characters of len. This is useful when an object has rules such as the 1st character
    --   of the generated string must be non-numeric.
    --
    --   Sublen_msk defaults to A-Z
    --   msk defaults to A-Z,0-9
    --
    -- PARAMETERS
    --
    --  len - Length of the String - up to 1000
    --  msk (optional) - The type of mask (masks can be found in FND_CRYPTO_CONSTANTS).
    --  sublen (optional)   - The number of initial characters to use sublen_msk below.
    --  sublen_msk (optional) - An optional mask for the sublen
    --
    -- ERROR CONDITIONS
    --  Throws VALUE_ERROR if
    --     len is > than 1000
    --     sublen > len
    --     msk is null or sublen_msk is null
    ------------------------------------------------------------------------

function RandomString(len IN INTEGER,
                      msk IN VARCHAR2 default FND_CRYPTO_CONSTANTS.ALPHANUMERIC_UPPER_MASK,
                      sublen IN INTEGER default 0,
                      sublen_msk IN VARCHAR2 default FND_CRYPTO_CONSTANTS.ALPHABETIC_UPPER_MASK)
 return VARCHAR2;


END fnd_crypto;

 

/
