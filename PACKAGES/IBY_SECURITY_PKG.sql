--------------------------------------------------------
--  DDL for Package IBY_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_SECURITY_PKG" AUTHID CURRENT_USER AS
/* $Header: ibysecs.pls 120.14.12010000.7 2008/08/30 06:37:30 lmallick ship $ */

 --
 -- module name used for the application debugging framework
 --
 G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_SECURITY_PKG';

  -- Encryption modes
  G_ENCRYPT_MODE_SCHED CONSTANT VARCHAR2(30) := 'SCHEDULED';
  G_ENCRYPT_MODE_NONE CONSTANT VARCHAR2(30) := 'NONE';
  G_ENCRYPT_MODE_INSTANT CONSTANT VARCHAR2(30) := 'IMMEDIATE';

  -- Mask options
  G_MASK_NONE CONSTANT VARCHAR2(30) := 'DISPLAY_ALL';
  G_MASK_ALL CONSTANT VARCHAR2(30) := 'DISPLAY_NONE';
  G_MASK_PREFIX CONSTANT VARCHAR2(30) := 'DISPLAY_LAST';
  G_MASK_POSTFIX CONSTANT VARCHAR2(30) := 'DISPLAY_FIRST';

  -- Clear-text encoding schemes
  G_ENCODING_NUMERIC CONSTANT VARCHAR2(30) := 'NUMERIC';
  G_ENCODING_UTF8_AL32 CONSTANT VARCHAR2(30) := 'AL32UTF8';

  --
  -- Maximum length (in bytes) of a triple DES key.
  --
  G_DES3_MAX_KEY_LEN CONSTANT INTEGER := 24;

  --
  -- shared FND wallet; used for making http callouts from the
  -- database
  --
  C_SHARED_WALLET_LOC_PROP_NAME CONSTANT VARCHAR2(50) := 'FND_DB_WALLET_DIR';

  -- Masking character
  G_MASK_CHARACTER CONSTANT VARCHAR2(1) := 'X';

  -- Expiry date string format to be used before encryption
  -- Do not modify this variable. This might cause existing
  -- data corruption !!
  G_ENCRYPTED_EXPDATE_FORMAT         VARCHAR2(20) := 'MMYYYY';
  G_MASKED_EXPDATE_FORMAT            VARCHAR2(20) := 'MM/YY';


  SUBTYPE DES3_KEY_TYPE IS RAW(24);


  --
  -- USE
  --    Validates the system security key
  --
  -- ARGS
  --    p_sys_sec_key => system security key in plain text form
  --
  -- OUTS
  --    x_err_code => IBY_XXXX type error code if the key failed to validate
  --                  or NULL if validation succeeds
  --
  PROCEDURE Validate_Sys_Key
  (p_sys_sec_key   IN  DES3_KEY_TYPE,
   x_err_code      OUT NOCOPY VARCHAR2
  );

  --
  -- USE
  --    Creates the system security key
  --
  -- ARGS
  --    p_sys_sec_key => the system security key
  --    p_wallet_path => the path of the key wallet
  --
  -- NOTES
  --    note that it may be padded or otherwised changed by the
  --    prepare_des3key() function
  --
  PROCEDURE Create_Sys_Key
  (p_commit      IN VARCHAR2,
   p_sys_sec_key IN DES3_KEY_TYPE,
   p_wallet_path IN VARCHAR2
  );

  --
  -- USE
  --    Changes the system security key
  --
  -- ARGS
  --    p_commit => Whether to commit changes
  --    p_sys_key_old => The system security key
  --    p_sys_key_new => The new security key
  --    p_wallet_path_new => New wallet patch location
  --
  -- NOTES
  --    note that the new key may be padded or otherwised changed by the
  --    prepare_des3key() function
  --
  PROCEDURE Change_Sys_Key
  (p_commit        IN     VARCHAR2 := FND_API.G_FALSE,
   p_sys_key_old   IN     DES3_KEY_TYPE,
   p_sys_key_new   IN     DES3_KEY_TYPE,
   p_wallet_path_new IN   VARCHAR2
  );

  --
  -- USE
  --   Gets the next system subkey, creating a new one if the current
  --   key has exceeded its usage limit
  --
  -- ARGS
  --   p_commit => Whether to commit changes
  --   p_masterkey => The system master key
  --   p_instrument_use_flag => If 'N' then the key is being used on existing
  --                            data; else it is for new data and so increase
  --                            its use count
  --   x_subkey_id => primary key of the sub-key to use
  --   x_subkey => subkey clear text
  --
  PROCEDURE Get_Sys_Subkey
  (p_commit        IN     VARCHAR2 := FND_API.G_FALSE,
   p_masterkey     IN     DES3_KEY_TYPE,
   p_inc_use_flag  IN     VARCHAR2,
   x_subkey_id     OUT NOCOPY iby_sys_security_subkeys.sec_subkey_id%TYPE,
   x_subkey        OUT NOCOPY DES3_KEY_TYPE
  );

  --
  -- USE
  --   Gets the subkey based upon its cipher-text values from the database
  -- ARGS
  --   p_masterkey => The system master key
  --   p_subkey_cipher => The subkey cipher text
  --
  FUNCTION Get_Sys_Subkey
  (p_sys_key       IN     DES3_KEY_TYPE,
   p_subkey_cipher IN     iby_sys_security_subkeys.subkey_cipher_text%TYPE
  )
  RETURN DES3_KEY_TYPE;

   --
  -- USE
  --   Gets the next system subkey, creating a new one if the current
  --   key has exceeded its usage limit
  --   This is similar to the Get_Sys_Subkey API, except for the fact
  --   that it returns the Hex representation of the subkey as a
  --   varchar2 value. This can be used by the java layer encryption.
  --
  -- ARGS
  --   p_commit => Whether to commit changes
  --   p_sys_key => The system master key
  --   p_instrument_use_flag => If 'N' then the key is being used on existing
  --                            data; else it is for new data and so increase
  --                            its use count
  --   x_subkey_id => primary key of the sub-key to use
  --   x_subkey_Hex => Hex value of the subkey clear text
  --
  PROCEDURE Get_Sys_Subkey_Hex
  (p_commit        IN     VARCHAR2 := FND_API.G_FALSE,
   p_sys_key       IN     DES3_KEY_TYPE,
   p_inc_use_flag  IN     VARCHAR2,
   x_subkey_id     OUT  NOCOPY iby_sys_security_subkeys.sec_subkey_id%TYPE,
   x_subkey_Hex    OUT  NOCOPY VARCHAR2
  );

  --
  -- USE
  --   Gets the Hex form of subkey based upon the subkey_id
  --   This API will be called to pass the Hex key to java
  --   layer, which would be in turn used to decrypt the
  --   acknowledgment files.
  -- ARGS
  --   p_sys_key => The system master key
  --   p_subkey_id => The subkey id
  --
  FUNCTION Get_Sys_Subkey_Hex
  (p_subkey_id     IN     iby_sys_security_subkeys.sec_subkey_id%TYPE,
   p_sys_key       IN     DES3_KEY_TYPE
  )
  RETURN VARCHAR2;


  --
  -- USE
  --    Pads or otherwise prepares clear text to be ciphered
  --
  -- ARGS
  --    p_cleartxt => the data (unencrypted) to prepare
  --    p_padchar => padding character to use
  --
  -- RETURN
  --    The data padded and ready to be input to a cipher function
  --
  FUNCTION Prepare_Cleartxt( p_cleartxt IN VARCHAR2, p_padchar IN VARCHAR2 )
  RETURN VARCHAR2;

  --
  -- USE
  --    Unpacks or otherwise unpads clear text that was ciphered
  --
  -- ARGS
  --    p_cleartxt => the clear text in its to-be-packed form
  --    p_padchar => padding character used to pack it
  --
  -- RETURN
  --    The clear text/data as it originally was
  --
  FUNCTION Unpack_Cleartxt( p_cleartxt IN VARCHAR2, p_padchar IN VARCHAR2 )
  RETURN VARCHAR2;

  --
  -- USE
  --   Light-weight ciphering function; does not do any key validation, and
  --   choses strong encryption was encoding based on in input parameter
  --
  -- ARGS
  --   p_data => the data to cipher
  --   p_sec_key => encryption key to use; should be already validated
  --   p_pad => character used to pad the data to appropriate length
  --   p_encrypt => 'Y' if data should be encrypted; otherwise it will be
  --                 encoded and the passed security key ignored
  --
  FUNCTION Cipher_Data
  (p_data IN VARCHAR2,
   p_sec_key IN IBY_SECURITY_PKG.DES3_KEY_TYPE,
   p_pad IN VARCHAR2,
   p_encrypt IN VARCHAR2
  )
  RETURN VARCHAR2;

  --
  -- USE
  --   Gets the hash value of a string
  -- ARGS
  --   p_text => the text
  --   p_salt => if FND_API.G_TRUE, then the text is "salted"
  --
  FUNCTION Get_Hash( p_text IN VARCHAR2, p_salt IN VARCHAR2 )
  RETURN VARCHAR2;

  --
  -- USE
  --   Gets the hash value of a string
  -- ARGS
  --   p_text => the text
  --   p_salt => if FND_API.G_TRUE, then the text is "salted"
  --   p_site_salt => RAWTOHEX(IBY_SECURITY_PKG.get_site_salt())
  --
  --   bug 7228583
  FUNCTION Get_Hash( p_text IN VARCHAR2, p_salt IN VARCHAR2, p_site_salt IN VARCHAR2)
  RETURN VARCHAR2;

  --
  -- USE
  --   Gets raw site salt

  FUNCTION get_site_salt
  RETURN RAW;

  --
  -- USE
  --   Gets the version of the salting scheme
  --
  FUNCTION get_salt_version RETURN NUMBER;

  --
  -- USE
  --   Generates hashes for RAW values
  --
  FUNCTION Get_Raw_Hash( p_data IN RAW ) RETURN RAW;

  --
  -- USE
  --   Generates the (salted) hash for a key
  --
  FUNCTION Get_Key_Hash( p_sys_key IN RAW ) RETURN RAW;

  --
  -- USE
  --   Masks the given data
  -- ARGS
  --   p_data => the text to mask
  --   p_mask_option => on the of the mask option constants; whether to
  --                    mask all, none, from the beginning, or from the end
  --                    of the data
  --   p_unmask_len => number of characters to expose
  --   p_mask_char => masking character
  --
  FUNCTION Mask_Data
  (p_data IN VARCHAR2,
   p_mask_option IN VARCHAR2,
   p_unmask_len IN NUMBER,
   p_mask_char IN VARCHAR2
  )
  RETURN VARCHAR2;

   --
  -- USE
  --   Masks the given date value
  -- ARGS
  --   p_date => the date value to mask
  --   p_return_format => The date format in which the
  --                      the returned mask value needs to
  --                      be in.
  --   p_mask_char => masking character
  --
  FUNCTION Mask_Date_Field
  (p_date IN DATE,
   p_return_format IN VARCHAR2,
   p_mask_char IN VARCHAR2
  )
  RETURN VARCHAR2;

  --
  -- USE
  --   Gets the unmasked portion of the given data
  -- ARGS
  --   p_data => the text to mask
  --   p_mask_option => on the of the mask option constants; whether to
  --                    mask all, none, from the beginning, or from the end
  --                    of the data
  --   p_unmask_len => number of characters to expose
  --
  FUNCTION Get_Unmasked_Data
  ( p_data IN VARCHAR2, p_mask_option IN VARCHAR2, p_unmask_len IN NUMBER )
  RETURN VARCHAR2;

  --
  -- USE
  --   Encodes a number into a compressed binary representation
  -- ARGS
  --   p_number => The number to encode
  --   p_des3mask => Whether to mask the data for DES3 encryption
  -- RETURN
  --   The number encoded in a unit 8 length hex string
  -- NOTES
  --    !!! DO NOT MODIFY THE ESSENTIAL CHARACTERISTICS OF THIS FUNCTION !!!
  --    !!! DOING SO COULD LEAD TO CREDIT CARD DATA CORRUPTION           !!!
  --
  FUNCTION Encode_Number( p_number IN VARCHAR2, p_des3mask IN BOOLEAN )
  RETURN VARCHAR2;

  --
  -- USE
  --   Decodes a number after decryption
  -- ARGS
  --   p_number => The encoded number
  --   p_length => The number length (in base 10 representation)
  --   p_des3mask => Whether to unmask the data from DES3 encryption
  -- NOTES
  --    !!! DO NOT MODIFY THE ESSENTIAL CHARACTERISTICS OF THIS FUNCTION !!!
  --    !!! DOING SO COULD LEAD TO CREDIT CARD DATA CORRUPTION           !!!
  --
  FUNCTION Decode_Number
  ( p_number IN VARCHAR2, p_length IN NUMBER, p_des3mask IN BOOLEAN )
  RETURN VARCHAR2;

 --
  -- USE
  --   Encodes a number into a compressed binary representation
  --   This does exactly the same thing as the Encode_Number API
  --   The only difference is, it pads the input number to
  --   32-Bytes. This is a PABP mandate for cvv values.
  -- ARGS
  --   p_number => The number to encode (CVV)
  --   p_des3mask => Whether to mask the data for DES3 encryption
  -- RETURN
  --   The number encoded in a unit 32 length hex string
  -- NOTES
  --    !!! DO NOT MODIFY THE ESSENTIAL CHARACTERISTICS OF THIS FUNCTION !!!
  --    !!! DOING SO COULD LEAD TO CREDIT CARD DATA CORRUPTION           !!!
  --
  FUNCTION Encode_CVV( p_number IN VARCHAR2, p_des3mask IN BOOLEAN )
  RETURN VARCHAR2;


  -- USE
  --   Creates a secure segment using the next subkey.
  -- ARGS
  --   p_commit => if FND_API.G_TRUE, commit the data
  --   p_segment => raw segment data
  --   p_encoding => binary encoding scheme for the segment data
  --   p_sys_key => The system key
  -- OUTS
  --   x_segment_id => Primary key of the segment created
  --
  PROCEDURE Create_Segment
  (p_commit IN VARCHAR2 := FND_API.G_FALSE,
   p_segment IN RAW,
   p_encoding IN VARCHAR2,
   p_sys_key IN DES3_KEY_TYPE,
   x_segment_id OUT NOCOPY iby_security_segments.sec_segment_id%TYPE
  );

  PROCEDURE Update_Segment
  (p_commit IN VARCHAR2 := FND_API.G_FALSE,
   p_segment_id IN iby_security_segments.sec_segment_id%TYPE,
   p_segment IN RAW,
   p_encoding IN VARCHAR2,
   p_sys_key IN DES3_KEY_TYPE,
   p_subkey_cipher IN DES3_KEY_TYPE
  );

  --
  -- USE
  --   Creates a security credential for the given key
  --
  PROCEDURE Store_Credential( p_key IN VARCHAR2, x_cred OUT NOCOPY NUMBER );

  --
  -- USE
  --   Verifies if the given credential was issued for the given
  --   key.
  --
  PROCEDURE Verify_Credential
  ( p_key IN VARCHAR2, p_cred IN NUMBER, x_verify OUT NOCOPY VARCHAR2 );

  --
  -- USE
  --   Utility function for reciphering subkeys
  --
  FUNCTION Recipher_Key
  ( p_data IN RAW, p_oldkey IN DES3_KEY_TYPE, p_newkey IN DES3_KEY_TYPE )
  RETURN RAW;

  FUNCTION Gen_Des3_Key( p_random_seed IN RAW ) RETURN RAW;

  --
  -- USE
  --   PKCS5 padding function; copied from AFSOCTKB.pls
  FUNCTION PKCS5_Pad(p_data IN RAW) RETURN RAW;

  --
  -- USE
  --   PKCS5 unpadding function; copied from AFSOCTKB.pls
  --
  FUNCTION PKCS5_Unpad(p_data raw) RETURN RAW;

  /* Bug 6018583: Implementation of the sceurity around Account Option Values
 	          and Transmission Values
 	          The entire code written below is added for the above purpose.
  */

  --
  -- encrypt_field_vals
  -- This function returns sec_segment_id.
  --
 FUNCTION encrypt_field_vals
 	  (
 	  p_value                 IN  VARCHAR2,
	  master_key_in           IN  DES3_KEY_TYPE,
 	  p_sec_segment_id        IN  NUMBER,
 	  p_commit                IN  VARCHAR2 DEFAULT 'N'
 	  ) RETURN NUMBER;

 --
 -- encrypt_num_field_vals
 -- This function returns sec_segment_id.
 --
 FUNCTION encrypt_num_field_vals
 	  (
 	  p_value                 IN  NUMBER,
	  master_key_in           IN  DES3_KEY_TYPE,
 	  p_sec_segment_id        IN  NUMBER,
 	  p_commit                IN  VARCHAR2 DEFAULT 'N'
 	  ) RETURN NUMBER;

  --
  -- encrypt_date_field_vals
  -- This function returns sec_segment_id.
  -- This function will truncate the date value to
  -- mmyyyy format and then create the corresponding
  -- cipher text.
  --
 FUNCTION encrypt_date_field
 	  (
 	  p_value                 IN  DATE,
	  master_key_in           IN  DES3_KEY_TYPE,
	  p_sec_segment_id        IN  NUMBER,
 	  p_commit                IN  VARCHAR2 DEFAULT 'N'
 	  ) RETURN NUMBER;

 --
 -- decrypt_field_vals
 -- This function returns decrypted value.
 --
 FUNCTION decrypt_field_vals
 	  (
 	  p_sec_segment_id        IN  NUMBER,
 	  master_key_in           IN  DES3_KEY_TYPE
 	  ) RETURN VARCHAR2;

 --
 -- decrypt_num_field_vals
 -- This function returns decrypted value.
 --
 FUNCTION decrypt_num_field_vals
 	  (
 	  p_sec_segment_id        IN  NUMBER,
 	  master_key_in           IN  DES3_KEY_TYPE
 	  ) RETURN NUMBER;
 --
 -- decrypt_date_field_vals
 -- This function returns decrypted date value that is
 -- truncated to the last day of month.
 --
 FUNCTION decrypt_date_field
 	  (
 	  p_sec_segment_id        IN  NUMBER,
 	  master_key_in           IN  DES3_KEY_TYPE
 	  ) RETURN DATE;

END IBY_SECURITY_PKG;

/

  GRANT EXECUTE ON "APPS"."IBY_SECURITY_PKG" TO "EM_OAM_MONITOR_ROLE";
