--------------------------------------------------------
--  DDL for Package Body IBY_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_SECURITY_PKG" AS
/* $Header: ibysecb.pls 120.22.12010000.12 2009/12/24 06:50:58 sgogula ship $ */

G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  -- Number to hex format string
  NUMTOX CONSTANT VARCHAR2(34) := 'FMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  -- Hex to number format string
  XTONUM CONSTANT VARCHAR2(32) := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  -- DES3 mask to avoid "double encryption" errors
  DES3_MASK CONSTANT RAW(8) := '0123456789ABCDEF';
  -- PKCS 5 padding
  PKCS5PAD CONSTANT RAW(36) := HEXTORAW('010202030303040404040505050505060606'
    || '060606070707070707070808080808080808');

-- Forward Declarations

  PROCEDURE print_debuginfo(
    p_message              IN     VARCHAR2,
    p_prefix               IN     VARCHAR2 DEFAULT 'DEBUG',
    p_msg_level            IN     NUMBER   DEFAULT FND_LOG.LEVEL_STATEMENT,
    p_module               IN     VARCHAR2 DEFAULT 'iby.plsql.IBY_SECURITY_PKG'
  );

  FUNCTION get_site_salt RETURN RAW
  IS
  BEGIN
    RETURN fnd_vault.getr('IBY','IBY_SITE_SALT');
  END get_site_salt;

  FUNCTION get_key_hash(p_sys_key IN RAW) RETURN RAW
  IS
    l_site_salt       RAW(128);
    l_key_hash        iby_sys_security_options.sys_key_hash%TYPE;
  BEGIN
    l_site_salt := get_site_salt();
    l_key_hash := DBMS_OBFUSCATION_TOOLKIT.MD5( INPUT => p_sys_key );
    RETURN
      DBMS_OBFUSCATION_TOOLKIT.MD5
      (INPUT => UTL_RAW.concat(l_key_hash,l_site_salt));
  END get_key_hash;

  FUNCTION Recipher_Key
  ( p_data IN RAW, p_oldkey IN DES3_KEY_TYPE, p_newkey IN DES3_KEY_TYPE )
  RETURN RAW
  IS
  BEGIN
    RETURN
      dbms_obfuscation_toolkit.des3encrypt
      ( input =>
          dbms_obfuscation_toolkit.des3decrypt
          ( input => p_data , key =>  p_oldkey,
            which => dbms_obfuscation_toolkit.ThreeKeyMode
          ),
        key => p_newkey,
        which => dbms_obfuscation_toolkit.ThreeKeyMode
      );
  END Recipher_Key;

  --
  -- USE
  --    Gets the hash value of the current system key
  --
  FUNCTION Get_SysKey_Hash
  RETURN iby_sys_security_options.sys_key_hash%TYPE
  IS
    l_syskey_hash     iby_sys_security_options.sys_key_hash%TYPE;

    CURSOR c_sys_key
    IS
      SELECT sys_key_hash
      FROM iby_sys_security_options;
  BEGIN
    IF (c_sys_key%ISOPEN) THEN CLOSE c_sys_key; END IF;

    OPEN c_sys_key;
    FETCH c_sys_key INTO l_syskey_hash;
    CLOSE c_sys_key;

    RETURN l_syskey_hash;
  END Get_SysKey_Hash;

  PROCEDURE Validate_Sys_Key
  (p_sys_sec_key   IN  DES3_KEY_TYPE,
   x_err_code      OUT NOCOPY VARCHAR2
  )
  IS
    l_sys_key_hash    iby_sys_security_options.sys_key_hash%TYPE;
    l_test_hash       iby_sys_security_options.sys_key_hash%TYPE;
  BEGIN
    IF (p_sys_sec_key IS NULL) THEN
      x_err_code := 'IBY_10006';
      RETURN;
    END IF;

    l_sys_key_hash := Get_SysKey_Hash();
    IF (l_sys_key_hash IS NULL) THEN
      x_err_code := 'IBY_10007';
      RETURN;
    END IF;

    IF (get_key_hash(p_sys_sec_key) <> l_sys_key_hash) THEN
      x_err_code := 'IBY_10003';
      RETURN;
    END IF;

    x_err_code := NULL;
  END Validate_Sys_Key;

  PROCEDURE Create_Sys_Key
  (p_commit      IN VARCHAR2,
   p_sys_sec_key IN DES3_KEY_TYPE,
   p_wallet_path IN VARCHAR2
  )
  IS
    l_sys_secure_hash iby_sys_security_options.sys_key_hash%TYPE;
    l_wallet_loc      iby_sys_security_options.sys_key_file_location%TYPE;

    CURSOR c_wallet_loc IS
      SELECT sys_key_file_location FROM iby_sys_security_options;

  BEGIN
    IF (c_wallet_loc%ISOPEN) THEN CLOSE c_wallet_loc; END IF;

    l_sys_secure_hash := Get_SysKey_Hash();
    OPEN c_wallet_loc; FETCH c_wallet_loc INTO l_wallet_loc; CLOSE c_wallet_loc;
    --
    -- hex strings are twice as long as their byte string equivalents
    --
    IF (LENGTH(RAWTOHEX(p_sys_sec_key)) <> (G_DES3_MAX_KEY_LEN*2))
      OR  (iby_utility_pvt.is_trivial(p_wallet_path))
      OR  (p_sys_sec_key IS NULL)
    THEN
      raise_application_error(-20000,'IBY_10006', FALSE);
    --
    -- sys key not NULL or trivial at this point; if the same as the current
    -- key and the wallet location is NULL, then is the first wallet set after
    -- upgrade from 11i
    --
    ELSIF (NOT l_sys_secure_hash IS NULL) AND
       ( (get_key_hash(p_sys_sec_key) <> l_sys_secure_hash) OR
         (NOT l_wallet_loc IS NULL)
       )
    THEN
      raise_application_error(-20000,'IBY_10005', FALSE);
    ELSE
     IF (NOT l_sys_secure_hash IS NULL) AND (l_wallet_loc IS NULL) THEN
       FND_VAULT.DEL('IBY','IBY_SYS_SECURITY_KEY');
     END IF;

     UPDATE iby_sys_security_options
     SET sys_key_hash = get_key_hash(p_sys_sec_key),
       salt_version = get_salt_version,
       sys_key_file_location = p_wallet_path,
       object_version_number = object_version_number + 1,
       last_update_date = sysdate,
       last_updated_by = fnd_global.user_id,
       last_update_login = fnd_global.login_id;
    END IF;

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
  END Create_Sys_Key;

  PROCEDURE Change_Sys_Key
  (p_commit        IN     VARCHAR2,
   p_sys_key_old   IN     DES3_KEY_TYPE,
   p_sys_key_new   IN     DES3_KEY_TYPE,
   p_wallet_path_new IN   VARCHAR2
  )
  IS
    l_err_code VARCHAR2(50) := NULL;
  BEGIN

    -- validate the new key
    IF (iby_utility_pvt.is_trivial(p_sys_key_new)) OR
       (LENGTH(RAWTOHEX(p_sys_key_new)) <> (G_DES3_MAX_KEY_LEN*2))
    THEN
      raise_application_error(-20000,'IBY_10006', FALSE);
    ELSIF (iby_utility_pvt.is_trivial(p_wallet_path_new)) THEN
      raise_application_error(-20000,'INVALID_WALLET', FALSE);
    END IF;

    validate_sys_key(p_sys_key_old,l_err_code);
    IF (NOT l_err_code IS NULL) THEN
      raise_application_error(-20000,l_err_code, FALSE);
    END IF;

    -- recipher all subkeys
    UPDATE iby_sys_security_subkeys
      SET subkey_cipher_text =
        Recipher_Key(subkey_cipher_text,p_sys_key_old,p_sys_key_new),
      object_version_number = object_version_number + 1,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id;

    -- update system key hash
    UPDATE iby_sys_security_options
    SET sys_key_hash = get_key_hash(p_sys_key_new),
      salt_version = get_salt_version,
      sys_key_file_location = p_wallet_path_new,
      object_version_number = object_version_number + 1,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id;

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
  END Change_Sys_Key;


  PROCEDURE Get_Sys_Subkey
  (p_commit        IN     VARCHAR2,
   p_masterkey     IN     DES3_KEY_TYPE,
   p_inc_use_flag  IN     VARCHAR2,
   x_subkey_id     OUT NOCOPY iby_sys_security_subkeys.sec_subkey_id%TYPE,
   x_subkey        OUT NOCOPY DES3_KEY_TYPE
  )
  IS
    l_err_code        VARCHAR2(100);
    l_subkey_ciphertxt iby_sys_security_subkeys.subkey_cipher_text%TYPE;

    CURSOR c_subkey
    IS
      SELECT k.sec_subkey_id, k.subkey_cipher_text
      FROM iby_sys_security_subkeys k, iby_sys_security_options o
      WHERE ( ( k.use_count < o.subkey_use_maximum) )
        AND ( (sysdate - k.creation_date) < NVL(o.subkey_age_maximum,30) )
      ORDER BY sec_subkey_id ASC;
  BEGIN

    IF (c_subkey%ISOPEN) THEN CLOSE c_subkey; END IF;

    validate_sys_key(p_masterkey,l_err_code);
    IF (NOT l_err_code IS NULL) THEN
      raise_application_error(-20000,l_err_code, FALSE);
    END IF;

    OPEN c_subkey;
    FETCH c_subkey INTO x_subkey_id, x_subkey;
    CLOSE c_subkey;

    IF (x_subkey_id IS NULL) THEN
      --
      -- subkey within use limit not found; create new one
      --
      x_subkey :=
        dbms_obfuscation_toolkit.des3getkey
        (seed => Fnd_Crypto.randombytes(G_DES3_MAX_KEY_LEN * 8),
         which => dbms_obfuscation_toolkit.ThreeKeyMode
        );
      l_subkey_ciphertxt :=
        dbms_obfuscation_toolkit.des3encrypt
        ( input => x_subkey, key => p_masterkey,
          which => dbms_obfuscation_toolkit.ThreeKeyMode
        );

      SELECT iby_sys_security_subkeys_s.NEXTVAL INTO x_subkey_id FROM dual;
      INSERT INTO iby_sys_security_subkeys
      (sec_subkey_id, subkey_cipher_text, use_count,
       created_by, creation_date, last_updated_by, last_update_date,
       last_update_login, object_version_number)
      VALUES
      (x_subkey_id, l_subkey_ciphertxt, 1,
       fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
       fnd_global.login_id, 1);
    ELSE
      -- valid subkey existing found
      x_subkey :=
        dbms_obfuscation_toolkit.des3decrypt
        ( input => x_subkey , key => p_masterkey,
          which => dbms_obfuscation_toolkit.ThreeKeyMode
        );
      --
      -- if subkey will be used, increment its use count
      --
      IF (p_inc_use_flag = 'Y') THEN
        UPDATE iby_sys_security_subkeys
        SET use_count = use_count + 1,
          object_version_number = object_version_number + 1,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
        WHERE (sec_subkey_id = x_subkey_id);
      END IF;
    END IF;

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
  END Get_Sys_Subkey;

  FUNCTION Get_Sys_Subkey
  (p_sys_key       IN     DES3_KEY_TYPE,
   p_subkey_cipher IN     iby_sys_security_subkeys.subkey_cipher_text%TYPE
  )
  RETURN DES3_KEY_TYPE
  IS
  BEGIN
    -- no des3 padding required for either key
    RETURN dbms_obfuscation_toolkit.des3decrypt
           ( input => p_subkey_cipher , key => p_sys_key,
             which => dbms_obfuscation_toolkit.ThreeKeyMode
           );
  END Get_Sys_Subkey;

   PROCEDURE Get_Sys_Subkey_Hex
  (p_commit        IN     VARCHAR2 := FND_API.G_FALSE,
   p_sys_key       IN     DES3_KEY_TYPE,
   p_inc_use_flag  IN     VARCHAR2,
   x_subkey_id     OUT  NOCOPY iby_sys_security_subkeys.sec_subkey_id%TYPE,
   x_subkey_Hex    OUT  NOCOPY VARCHAR2
  ) IS
  l_subkey_raw       RAW(24);
  BEGIN
  Get_Sys_Subkey(p_commit, p_sys_key, p_inc_use_flag, x_subkey_id, l_subkey_raw);
  x_subkey_Hex := RAWTOHEX(l_subkey_raw);
  END Get_Sys_Subkey_Hex;

  FUNCTION Get_Sys_Subkey_Hex
  (p_subkey_id     IN     iby_sys_security_subkeys.sec_subkey_id%TYPE,
   p_sys_key       IN     DES3_KEY_TYPE
  )
  RETURN VARCHAR2
  IS
  l_subkey_cipher       RAW(24);
  l_subkey_clear        RAW(24);
  l_subkey_Hex          VARCHAR2(100);

  BEGIN

  SELECT subkey_cipher_text INTO l_subkey_cipher FROM iby_sys_security_subkeys
  WHERE sec_subkey_id = p_subkey_id;

  l_subkey_clear := Get_Sys_Subkey(p_sys_key, l_subkey_cipher);
  l_subkey_Hex := RAWTOHEX(l_subkey_clear);
  RETURN l_subkey_Hex;
  END Get_Sys_Subkey_Hex;




  FUNCTION Prepare_Cleartxt( p_cleartxt IN VARCHAR2, p_padchar IN VARCHAR2 )
  RETURN VARCHAR2
  IS
  l_pad_by        number;
  l_total_padding VARCHAR2(4096) DEFAULT NULL;
  BEGIN
        IF (p_padchar IS NULL) THEN
          RETURN p_cleartxt;
        END IF;

        -- the clear text for DES3 must be a mutliple of 8 bytes
        -- could use the lengthb() function but as almost all
        -- other character set encodings are multiples of 8 bytes
        -- this should work
        --
/* Bug 6313036: The RPAD function does not pad exact number of bytes
                needed in multi-byte environment.
        RETURN RPAD(p_cleartxt,CEIL(LENGTH(p_cleartxt)/8)*8,p_padchar);
*/
        l_pad_by := (8-MOD(LENGTHB(p_cleartxt),8));
        IF l_pad_by = 0 THEN
           RETURN p_cleartxt;
        ELSE
           FOR i in 1 .. l_pad_by
           LOOP
              l_total_padding :=  l_total_padding || p_padchar;
           END LOOP;
           RETURN p_cleartxt || l_total_padding;
        END IF;
  END Prepare_Cleartxt;


  FUNCTION Unpack_Cleartxt( p_cleartxt IN VARCHAR2, p_padchar IN VARCHAR2 )
  RETURN VARCHAR2
  IS
  BEGIN
        RETURN RTRIM(p_cleartxt,p_padchar);
  END Unpack_Cleartxt;

  FUNCTION Cipher_Data
  (p_data IN VARCHAR2,
   p_sec_key IN IBY_SECURITY_PKG.DES3_KEY_TYPE,
   p_pad IN VARCHAR2,
   p_encrypt IN VARCHAR2
  )
  RETURN VARCHAR2
  IS
  BEGIN
    IF ( p_encrypt = 'Y' ) THEN
      RETURN dbms_obfuscation_toolkit.des3encrypt
             ( input_string => prepare_cleartxt(p_data,p_pad),
               key_string =>  p_sec_key,
               which => dbms_obfuscation_toolkit.ThreeKeyMode
             );
    ELSE
      RETURN p_data;
    END IF;
  END Cipher_Data;

  FUNCTION Get_Unmasked_Data
  ( p_data IN VARCHAR2, p_mask_option IN VARCHAR2, p_unmask_len IN NUMBER )
  RETURN VARCHAR2
  IS
    l_mask_option   VARCHAR2(30);
    l_length        NUMBER;
    l_start_index   NUMBER;
    l_end_index     NUMBER;
  BEGIN
    l_mask_option := p_mask_option;
    l_length := LENGTH(p_data);

    IF (l_length <= NVL(p_unmask_len,l_length)) AND
       (l_mask_option <> G_MASK_ALL)
    THEN
      l_mask_option := G_MASK_NONE;
    ELSIF (NVL(p_unmask_len,0) < 1) AND
       (l_mask_option <> G_MASK_NONE)
    THEN
      l_mask_option := G_MASK_ALL;
    END IF;

    IF (l_mask_option = G_MASK_NONE) THEN
      RETURN p_data;
    ELSIF (l_mask_option = G_MASK_ALL) THEN
      RETURN NULL;
    ELSIF (l_mask_option = G_MASK_POSTFIX) THEN
      RETURN SUBSTR(p_data,1,p_unmask_len);
    ELSE
      RETURN SUBSTR(p_data,l_length-(p_unmask_len-1));
    END IF;
  END Get_Unmasked_Data;

  FUNCTION Mask_Data
  (p_data IN VARCHAR2,
   p_mask_option IN VARCHAR2,
   p_unmask_len IN NUMBER,
   p_mask_char IN VARCHAR2
  )
  RETURN VARCHAR2
  IS
    l_masked_number VARCHAR2(2000);
    l_mask_option   VARCHAR2(30);
    l_unmask_len    NUMBER;
    l_mask_char     VARCHAR2(01);
    l_length        NUMBER;
    l_start_index   NUMBER;
    l_end_index     NUMBER;
  BEGIN
    l_mask_option := nvl(p_mask_option, G_MASK_ALL);
    l_unmask_len  := nvl(p_unmask_len , 0);
    l_mask_char   := nvl(p_mask_char  , '*');
    l_length      := LENGTH(p_data);
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

	    print_debuginfo('The value of p_mask_option:' || l_mask_option);
	    print_debuginfo('The value of p_unmask_len :'|| l_unmask_len);
	    print_debuginfo('The value of l_length:' || l_length);
    END IF;
    IF (l_length <= NVL(l_unmask_len,l_length)) AND
       (l_mask_option <> G_MASK_ALL)
    THEN
      l_mask_option := G_MASK_NONE;
    ELSIF (NVL(l_unmask_len,0) < 1) AND
       (l_mask_option <> G_MASK_NONE)
    THEN
      l_mask_option := G_MASK_ALL;
    END IF;

    IF (l_mask_option = G_MASK_NONE) THEN
      l_masked_number := p_data;
    ELSIF (l_mask_option = G_MASK_ALL) THEN
      l_masked_number := RPAD(l_mask_char,l_length,l_mask_char);
    ELSIF (l_mask_option = G_MASK_POSTFIX) THEN
      l_masked_number := RPAD(SUBSTR(p_data,1,l_unmask_len),
                              l_length,l_mask_char);
    ELSE
      l_masked_number:= LPAD(SUBSTR(p_data,l_length-(l_unmask_len-1)),
                             l_length,l_mask_char);
    END IF;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('The values after masking process.. ');

	     print_debuginfo('The value of p_mask_option: '|| l_mask_option);
	     print_debuginfo('The value of p_unmask_len:'||l_unmask_len);
	     print_debuginfo('The value of l_length:'|| l_length);
	     print_debuginfo('The value of l_masked_number after masking process: '||
	l_masked_number);
     END IF;
    RETURN l_masked_number;

  END Mask_Data;

  FUNCTION Mask_Date_Field
  (p_date IN DATE,
   p_return_format IN VARCHAR2,
   p_mask_char IN VARCHAR2
  )
  RETURN VARCHAR2
  IS
    l_date_format          VARCHAR2(20);
    l_mask_char            VARCHAR2(1);
    l_formatted_date       VARCHAR2(20);
    l_masked_date          VARCHAR2(20);
    l_date_len             NUMBER;
  BEGIN
    l_date_format := NVL(p_return_format, 'MM/YY');
    l_mask_char := NVL(p_mask_char, 'X');
    l_formatted_date := TO_CHAR(p_date, l_date_format);
    l_masked_date := regexp_replace(l_formatted_date, '[0-9]{1}', l_mask_char);
    RETURN l_masked_date;
  END Mask_Date_Field;

  --
  -- NOTES
  --    !!! DO NOT MODIFY THE ESSENTIAL CHARACTERISTICS OF THIS FUNCTION !!!
  --    !!! DOING SO COULD LEAD TO CREDIT CARD DATA CORRUPTION           !!!
  --
  FUNCTION Encode_Number( p_number IN VARCHAR2, p_des3mask IN BOOLEAN )
  RETURN VARCHAR2
  IS
    l_num     VARCHAR2(256);  -- number in hex (RAW) format
    l_pad     VARCHAR2(256);  -- random pad
    l_hex_len NUMBER;        -- number hex string length
  BEGIN
    -- max length of the hex representation of the number is:
    --   log(16,10) * (digit_length - 1 + 1) + 1
    -- A length x digit string is < 10^x since the most signficant
    -- digit is a multiple of 10^(x-1); thus the maximum value for a
    -- length x string is 10^x-1 ~= 10^x
    -- 10^x in hex representatin thus has floor(log(16,10)*x) + 1 digits
    -- since the nth digit is a multiple of 16^(n-1)
    --
    l_hex_len := FLOOR(LOG(16,10)*(LENGTH(p_number)+1-1)) + 1;

    -- must be of whole byte length; 1 byte = 2 hex characters
    l_num := LTRIM(TO_CHAR(TO_NUMBER(p_number),NUMTOX));
    l_num := LPAD(l_num,l_hex_len,'0');

    -- must be of unit byte length; 2 hex characters = 1 byte
    IF (MOD(l_hex_len,2) = 1) THEN
      l_num := SUBSTR(fnd_crypto.randombytes(1),-1) || l_num;
      l_hex_len := l_hex_len+1;
    END IF;

    -- data must be a multiple of 8 bytes long
    l_pad := fnd_crypto.randombytes(8-MOD(l_hex_len/2,8));
    l_num := l_pad || l_num;

    IF (p_des3mask) THEN
      l_num := RAWTOHEX(utl_raw.bit_xor(l_num, DES3_MASK));
    END IF;

    RETURN l_num;
  END Encode_Number;

  --
  -- NOTES
  --    !!! DO NOT MODIFY THE ESSENTIAL CHARACTERISTICS OF THIS FUNCTION !!!
  --    !!! DOING SO COULD LEAD TO CREDIT CARD DATA CORRUPTION           !!!
  --
  FUNCTION Decode_Number
  ( p_number IN VARCHAR2, p_length IN NUMBER, p_des3mask IN BOOLEAN )
  RETURN VARCHAR2
  IS
    l_num     VARCHAR2(256);  -- number in hex (RAW) format
    l_hex_len NUMBER;        -- number hex string length
  BEGIN
    IF (p_des3mask) THEN
      l_num := RAWTOHEX(utl_raw.bit_xor(p_number,DES3_MASK));
    ELSE
      l_num := p_number;
    END IF;

    l_hex_len := FLOOR(LOG(16,10)*(p_length+1-1)) + 1;
    -- ok if not of unit btye length; in fact, the filler hex
    -- character to pad to even the length is random
    --
    l_num := TO_CHAR(TO_NUMBER(SUBSTR(l_num,-l_hex_len),XTONUM));
    l_num := LPAD(l_num,p_length,'0');

    RETURN l_num;
  END Decode_Number;

  --
  -- NOTES
  --    !!! DO NOT MODIFY THE ESSENTIAL CHARACTERISTICS OF THIS FUNCTION !!!
  --    !!! DOING SO COULD LEAD TO CREDIT CARD DATA CORRUPTION           !!!
  --
  FUNCTION Encode_CVV( p_number IN VARCHAR2, p_des3mask IN BOOLEAN )
  RETURN VARCHAR2
  IS
    l_num     VARCHAR2(256);  -- number in hex (RAW) format
    l_pad     VARCHAR2(256);  -- random pad
    l_hex_len NUMBER;        -- number hex string length
  BEGIN
    -- max length of the hex representation of the number is:
    --   log(16,10) * (digit_length - 1 + 1) + 1
    -- A length x digit string is < 10^x since the most signficant
    -- digit is a multiple of 10^(x-1); thus the maximum value for a
    -- length x string is 10^x-1 ~= 10^x
    -- 10^x in hex representatin thus has floor(log(16,10)*x) + 1 digits
    -- since the nth digit is a multiple of 16^(n-1)
    --
    l_hex_len := FLOOR(LOG(16,10)*(LENGTH(p_number)+1-1)) + 1;

    -- must be of whole byte length; 1 byte = 2 hex characters
    l_num := LTRIM(TO_CHAR(TO_NUMBER(p_number),NUMTOX));
    l_num := LPAD(l_num,l_hex_len,'0');

    -- must be of unit byte length; 2 hex characters = 1 byte
    IF (MOD(l_hex_len,2) = 1) THEN
      l_num := SUBSTR(fnd_crypto.randombytes(1),-1) || l_num;
      l_hex_len := l_hex_len+1;
    END IF;

    -- data must be a multiple of 32 bytes long
    l_pad := fnd_crypto.randombytes(32-MOD(l_hex_len/2,32));
    l_num := l_pad || l_num;

    IF (p_des3mask) THEN
      l_num := RAWTOHEX(utl_raw.bit_xor(l_num, DES3_MASK));
    END IF;

    RETURN l_num;
  END Encode_CVV;


  PROCEDURE Create_Segment
  (p_commit IN VARCHAR2,
   p_segment IN RAW,
   p_encoding IN VARCHAR2,
   p_sys_key IN DES3_KEY_TYPE,
   x_segment_id OUT NOCOPY iby_security_segments.sec_segment_id%TYPE
  )
  IS
    l_segment_cipher     iby_security_segments.segment_cipher_text%TYPE;
    lx_subkey_id         iby_sys_security_subkeys.sec_subkey_id%TYPE;
    lx_subkey            iby_sys_security_subkeys.subkey_cipher_text%TYPE;
  BEGIN

    IBY_SECURITY_PKG.Get_Sys_Subkey
    (FND_API.G_FALSE,p_sys_key,'Y',lx_subkey_id,lx_subkey);

    l_segment_cipher :=
      DBMS_OBFUSCATION_TOOLKIT.des3encrypt
      (input => p_segment, key => lx_subkey,
       which => dbms_obfuscation_toolkit.ThreeKeyMode
      );

    SELECT iby_security_segments_s.NEXTVAL INTO x_segment_id FROM DUAL;
    INSERT INTO iby_security_segments
    (sec_segment_id, segment_cipher_text, sec_subkey_id, encoding_scheme,
     created_by, creation_date, last_updated_by, last_update_date,
     last_update_login, object_version_number
    )
    VALUES
    (x_segment_id, l_segment_cipher, lx_subkey_id, p_encoding,
     fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
     fnd_global.login_id, 1
    );

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT;
    END IF;
  END Create_Segment;

  PROCEDURE Update_Segment
  (p_commit IN VARCHAR2,
   p_segment_id IN iby_security_segments.sec_segment_id%TYPE,
   p_segment IN RAW,
   p_encoding IN VARCHAR2,
   p_sys_key IN DES3_KEY_TYPE,
   p_subkey_cipher IN DES3_KEY_TYPE
  )
  IS
    l_segment_cipher     iby_security_segments.segment_cipher_text%TYPE;
    l_subkey             DES3_KEY_TYPE;
  BEGIN
    l_subkey :=
      DBMS_OBFUSCATION_TOOLKIT.des3decrypt
      (input => p_subkey_cipher, key => p_sys_key,
       which => dbms_obfuscation_toolkit.ThreeKeyMode
      );
    l_segment_cipher :=
      DBMS_OBFUSCATION_TOOLKIT.des3encrypt
      (input => p_segment, key => l_subkey,
       which => dbms_obfuscation_toolkit.ThreeKeyMode
      );

     UPDATE iby_security_segments
     SET
       segment_cipher_text = l_segment_cipher,
       encoding_scheme = NVL(p_encoding,encoding_scheme),
       last_updated_by = fnd_global.user_id,
       last_update_date = SYSDATE,
       last_update_login = fnd_global.user_id,
       object_version_number = object_version_number + 1
     WHERE sec_segment_id=p_segment_id;
  END Update_Segment;

  PROCEDURE Store_Credential( p_key IN VARCHAR2, x_cred OUT NOCOPY NUMBER )
  IS
  BEGIN
    x_cred := fnd_gfm.one_time_use_store(1);
  END Store_Credential;

  PROCEDURE Verify_Credential
  ( p_key IN VARCHAR2, p_cred IN NUMBER, x_verify OUT NOCOPY VARCHAR2 )
  IS
  BEGIN
    x_verify := FND_API.G_FALSE;
    IF (fnd_gfm.one_time_use_retrieve(p_cred)=1) THEN
      x_verify := FND_API.G_TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       x_verify := FND_API.G_FALSE;
  END Verify_Credential;



  PROCEDURE print_debuginfo(
    p_message                               IN     VARCHAR2,
    p_prefix                                IN     VARCHAR2,
    p_msg_level                             IN     NUMBER,
    p_module                                IN     VARCHAR2
  ) IS

   l_message                               VARCHAR2(4000);
   l_module                                VARCHAR2(255);
BEGIN

--    DBMS_OUTPUT.PUT_LINE(substr(RPAD(p_module,55)||' : '||p_message, 0, 150));
--     insert into ying_debug(log_time, text)  values(sysdate, p_message);

     -- Debug info.
       l_module  :=SUBSTRB(p_module,1,255);
       IF p_prefix IS NOT NULL THEN
          l_message :=SUBSTRB(p_prefix||'-'||p_message,1,4000);
       ELSE
          l_message :=SUBSTRB(p_message,1,4000);
       END IF;
    IF p_msg_level>=fnd_log.g_current_runtime_level THEN

     FND_LOG.STRING(p_msg_level,l_module,l_message);

    END IF;

  END print_debuginfo;

  FUNCTION get_salt_version RETURN NUMBER
  IS
  BEGIN
    RETURN 1;
  END get_salt_version;

  FUNCTION Get_Hash( p_text IN VARCHAR2, p_salt IN VARCHAR2 )
  RETURN VARCHAR2
  IS
    l_site_salt  VARCHAR2(256);
    l_hash       VARCHAR2(1024);
  BEGIN
    l_site_salt := RAWTOHEX(get_site_salt());
    -- !!! WARNING: DO NOT CHANGE THE SALTING FUNCTION !!!
    -- !!! THIS WILL CORRUPT EVERY ENTITY THAT STORES  !!!
    -- !!! A SALTED HASH VALUE (HASH_VALUE_2)          !!!
    --
    IF (FND_API.To_Boolean(p_salt)) THEN
      l_hash := dbms_obfuscation_toolkit.md5
                (input_string => p_text||SUBSTR(p_text,-1));
    ELSE
      l_hash := dbms_obfuscation_toolkit.md5(input_string => p_text);
    END IF;

    RETURN DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT_STRING => (l_hash || l_site_salt));
  END Get_Hash;

  --  bug 7228583
  FUNCTION Get_Hash( p_text IN VARCHAR2, p_salt IN VARCHAR2, p_site_salt IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_hash       VARCHAR2(1024);
  BEGIN
    -- !!! WARNING: DO NOT CHANGE THE SALTING FUNCTION !!!
    -- !!! THIS WILL CORRUPT EVERY ENTITY THAT STORES  !!!
    -- !!! A SALTED HASH VALUE (HASH_VALUE_2)          !!!
    --
    IF (FND_API.To_Boolean(p_salt)) THEN
      l_hash := dbms_obfuscation_toolkit.md5
                (input_string => p_text||SUBSTR(p_text,-1));
    ELSE
      l_hash := dbms_obfuscation_toolkit.md5(input_string => p_text);
    END IF;

    RETURN DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT_STRING => (l_hash || p_site_salt));
  END Get_Hash;

  FUNCTION Get_Raw_Hash( p_data IN RAW ) RETURN RAW
  IS
  BEGIN
    RETURN dbms_obfuscation_toolkit.md5(input => p_data);
  END Get_Raw_Hash;

  FUNCTION Gen_Des3_Key( p_random_seed IN RAW ) RETURN RAW
  IS
  BEGIN
    RETURN
      dbms_obfuscation_toolkit.des3getkey
      (seed => p_random_seed,
       which => dbms_obfuscation_toolkit.ThreeKeyMode
      );
  END;

  FUNCTION PKCS5_Pad(p_data IN RAW) RETURN RAW
  IS
    pad NUMBER;
  BEGIN
    pad := 8 - MOD(utl_raw.LENGTH(p_data),8);
    RETURN utl_raw.concat(p_data,utl_raw.substr(PKCS5PAD,pad*(pad-1)/2+1,pad));
  END PKCS5_Pad;

  FUNCTION PKCS5_Unpad(p_data raw) RETURN RAW
  IS
    pad NUMBER;
  BEGIN
    pad := TO_NUMBER(rawtohex(utl_raw.substr(p_data, -1)), 'XX');
    IF (pad < 1 OR pad > 8) THEN
return null;
    END IF;

    IF (utl_raw.compare(utl_raw.substr(PKCS5PAD, pad*(pad-1)/2+1, pad),
                        utl_raw.substr(p_data, -pad)) <> 0)
    THEN
return null;
    END IF;

    RETURN utl_raw.substr(p_data, 1, utl_raw.length(p_data) - pad);
  END PKCS5_Unpad;

	 /* Bug 6018583: Implementation of the sceurity around Account Option Values
 	                 and Transmission Values
 	                 The entire code written below is added for the above purpose.
 	 */


 FUNCTION masked_value_passed
 	  (p_data IN VARCHAR2
 	  )
 RETURN VARCHAR2
 IS
 BEGIN
   IF translate(p_data,'#*','#') IS NULL THEN
 	   RETURN 'Y';
   ELSE
 	   RETURN 'N';
   END IF;
 END masked_value_passed;



 	 --
 	 -- Compress_Value
 	 --

 	 PROCEDURE Compress_Value
 	   (p_value         IN  VARCHAR2,
 	    p_mask_setting  IN  VARCHAR2,
 	    p_unmask_len    IN  NUMBER,
 	    x_compress_val  OUT NOCOPY VARCHAR2,
 	    x_unmask_digits OUT NOCOPY VARCHAR2
 	   )
 	   IS
 	     l_prefix_index    NUMBER;
 	     l_unmask_len      NUMBER;
 	     l_substr_start    NUMBER;
 	     l_substr_stop     NUMBER;
 	   BEGIN

 	     x_unmask_digits := Get_Unmasked_Data( p_value
 	                                         , p_mask_setting
 	                                         , p_unmask_len
 	                                         );
 	     l_unmask_len := NVL(LENGTH(x_unmask_digits),0);

 	     -- all digits exposed; compressed number is trivial
 	     IF (l_unmask_len >= LENGTH(p_value)) THEN
 	       x_compress_val := NULL;
 	       RETURN;
 	     END IF;

 	     IF ( (p_mask_setting = iby_security_pkg.G_MASK_POSTFIX) )
 	     THEN
 	       l_substr_start := l_unmask_len + 1;
 	     ELSE
 	       l_substr_start := 1;
 	     END IF;

 	     IF (p_mask_setting = iby_security_pkg.G_MASK_PREFIX)
 	        AND (p_unmask_len>0)
 	     THEN
 	       l_substr_stop := GREATEST(LENGTH(p_value)-p_unmask_len,0);
 	     ELSE
 	       l_substr_stop := LENGTH(p_value);
 	     END IF;

 	     IF (l_substr_start < (l_substr_stop +1)) THEN
 	       x_compress_val := SUBSTR(p_value,l_substr_start,
 	                                l_substr_stop - l_substr_start + 1);
 	     ELSE
 	       x_compress_val := NULL;
 	     END IF;
 	 END Compress_Value;

 --
 -- encrypt_field_vals
 --
 FUNCTION encrypt_field_vals
 	  (
 	   p_value                 IN  VARCHAR2,
	   master_key_in           IN  DES3_KEY_TYPE,
 	   p_sec_segment_id        IN  NUMBER,
 	   p_commit                IN  VARCHAR2 DEFAULT 'N'
 	  ) RETURN NUMBER
 	 IS

 	  lx_key_error      VARCHAR2(300);
 	  lx_compress_val   VARCHAR2(2000);
 	  lx_unmask_digits  VARCHAR2(2000);
 	  l_sys_key         RAW(24);
 	  x_sec_segment_id  iby_security_segments.sec_segment_id%TYPE;
 	  l_fv_segment      iby_security_segments.segment_cipher_text%TYPE;
 	  l_subkey_cipher   iby_sys_security_subkeys.subkey_cipher_text%TYPE;

 	  l_dbg_mod      VARCHAR2(100) := G_DEBUG_MODULE || '.encrypt_field_vals';

 	 BEGIN

 	    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

 	    IF masked_value_passed(p_value) = 'Y' THEN
 	       return p_sec_segment_id;
 	    END IF;

	   -- no more used. System key passed from middle-tier
 	   -- l_sys_key := Get_Sys_Key_Raw();

 	    iby_debug_pub.add('encrypting field value',
 	           iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

 	    Compress_Value ( p_value         => p_value
 	                   , p_mask_setting  => iby_security_pkg.G_MASK_ALL
 	                   , p_unmask_len    => 0
 	                   , x_compress_val  => lx_compress_val
 	                   , x_unmask_digits => lx_unmask_digits);

 	    IF (NOT lx_compress_val IS NULL) THEN
 	          l_fv_segment := UTL_RAW.CAST_TO_RAW(CONVERT(lx_compress_val,'AL32UTF8'));
 	          l_fv_segment := PKCS5_PAD(l_fv_segment);

 	          IF (p_sec_segment_id IS NULL) THEN
 	             Create_Segment ( FND_API.G_FALSE
 	                            , l_fv_segment
 	                            , iby_security_pkg.G_ENCODING_UTF8_AL32
				    , master_key_in
 	                            , x_sec_segment_id
 	                            );
 	          ELSE
 	             BEGIN
 	                SELECT sk.subkey_cipher_text
 	                  INTO l_subkey_cipher
 	                  FROM iby_sys_security_subkeys sk
 	                     , iby_security_segments ss
 	                 WHERE sk.sec_subkey_id = ss.sec_subkey_id
 	                   AND ss.sec_segment_id = p_sec_segment_id;
 	             END;
 	             Update_Segment ( FND_API.G_FALSE
 	                            , p_sec_segment_id
 	                            , l_fv_segment
 	                            , iby_security_pkg.G_ENCODING_UTF8_AL32
 	                            , master_key_in
 	                            , l_subkey_cipher
 	                            );

 	             x_sec_segment_id := p_sec_segment_id;
 	          END IF;
 	    ELSE
 	           DELETE FROM iby_security_segments
 	           WHERE sec_segment_id = p_sec_segment_id;
 	    END IF;

 	    IF ( p_commit = 'Y' ) THEN
 	       COMMIT;
 	    END IF;

 	    RETURN x_sec_segment_id;

 	 END encrypt_field_vals;

 	 FUNCTION encrypt_num_field_vals
 	           (
 	           p_value                 IN  NUMBER,
		   master_key_in           IN  DES3_KEY_TYPE,
 	           p_sec_segment_id        IN  NUMBER,
 	           p_commit                IN  VARCHAR2 DEFAULT 'N'
 	           ) RETURN NUMBER
 	 IS
 	   l_number VARCHAR2(4000);
 	 BEGIN
 	    IF p_value = -11111 THEN
 	       return p_sec_segment_id;
 	    END IF;
 	    l_number := to_char(p_value);
 	    return encrypt_field_vals
 	              ( l_number
		      , master_key_in
 	              , p_sec_segment_id
 	              , p_commit
 	              );
 	 END encrypt_num_field_vals;

 --
 -- encrypt_date_field_vals
 --
 FUNCTION encrypt_date_field
 	  (
 	   p_value                 IN  DATE,
	   master_key_in           IN  DES3_KEY_TYPE,
	   p_sec_segment_id        IN  NUMBER,
 	   p_commit                IN  VARCHAR2 DEFAULT 'N'
 	  ) RETURN NUMBER
 	 IS

           l_trunc_date   VARCHAR2(12);
           l_pad          VARCHAR2(4);
           l_padded_data   VARCHAR2(16);
           l_segment_id    NUMBER;

 	   l_dbg_mod      VARCHAR2(100) := G_DEBUG_MODULE || '.encrypt_field_vals';

 	 BEGIN

           IF ( p_value IS NULL ) THEN return null; END IF;

 	   l_trunc_date := TO_CHAR(p_value, G_ENCRYPTED_EXPDATE_FORMAT);

	   -- Get 2 bytes of random data and pad the date value with this
	   -- this will make the total length as 16 hex chars
	   -- (similar to most credit cards). This will be a good camouflage
	   -- and also since the range of date values could be quite small,
	   -- with the random bytes, we would prevent cipher attacks.

	   l_pad := fnd_crypto.randombytes(2);
	   l_padded_data := l_pad || l_trunc_date;
 	   l_segment_id := encrypt_field_vals(l_padded_data, master_key_in,
	                                      p_sec_segment_id, p_commit);

 	    RETURN l_segment_id;

 END encrypt_date_field;

 	 FUNCTION Uncipher_Field_Value
 	   (p_segment_id     IN   iby_security_segments.sec_segment_id%TYPE,
 	    p_sys_key        IN   DES3_KEY_TYPE,
 	    p_sub_key_cipher IN   iby_sys_security_subkeys.subkey_cipher_text%TYPE,
 	    p_segment_cipher IN   iby_security_segments.segment_cipher_text%TYPE,
 	    p_encoding       IN   iby_security_segments.encoding_scheme%TYPE
 	   )
 	   RETURN VARCHAR2
 	   IS
 	     l_sub_key           RAW(24);
 	     l_fv_segment        iby_security_segments.segment_cipher_text%TYPE;
 	     l_decrypted_value   VARCHAR2(2000);
 	     l_db_characterset   VARCHAR2(2000);
 	   BEGIN

 	     -- uncipher the subkey
 	     l_sub_key := get_sys_subkey(p_sys_key,p_sub_key_cipher);

 	     -- uncipher the segment
 	     l_fv_segment :=
 	         dbms_obfuscation_toolkit.des3decrypt
 	         ( input =>  p_segment_cipher, key => l_sub_key,
 	           which => dbms_obfuscation_toolkit.ThreeKeyMode
 	         );
 	     l_fv_segment := IBY_SECURITY_PKG.PKCS5_UNPAD(l_fv_segment);
 	     BEGIN
 	        SELECT value
 	          INTO l_db_characterset
 	          FROM v$nls_parameters
 	         WHERE parameter = 'NLS_CHARACTERSET';
 	     END;
 	     l_decrypted_value := UTL_RAW.CAST_TO_VARCHAR2(CONVERT(l_fv_segment,l_db_characterset));

 	     RETURN l_decrypted_value;

 	   END Uncipher_Field_Value;

 	 --
 	 -- decrypt_field_vals
 	 --
 	 FUNCTION decrypt_field_vals
 	           ( p_sec_segment_id        IN  NUMBER,
 	             master_key_in           IN  DES3_KEY_TYPE
 	           ) RETURN VARCHAR2
 	 IS

 	  lx_key_error        VARCHAR2(300);
 	  l_sys_key           RAW(24);
 	  l_subkey_ciphertxt  iby_sys_security_subkeys.subkey_cipher_text%TYPE;
 	  l_fv_segment        iby_security_segments.segment_cipher_text%TYPE;
 	  l_encoding          iby_security_segments.encoding_scheme%TYPE;

 	  l_dbg_mod           VARCHAR2(100) := G_DEBUG_MODULE || '.decrypt_field_vals';

 	 BEGIN

 	    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

 	    IF (p_sec_segment_id IS NOT NULL) THEN
 	       --l_sys_key :=
 	       --     iby_security_pkg.Pad_Raw_Key( UTL_RAW.CAST_TO_RAW( p_sys_sec_key ) );

 	       iby_debug_pub.add('decrypting field value',
 	              iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

 	       BEGIN
 	          SELECT bak.subkey_cipher_text
 	               , bas.segment_cipher_text
 	               , bas.encoding_scheme
 	            INTO l_subkey_ciphertxt
 	               , l_fv_segment
 	               , l_encoding
 	            FROM iby_sys_security_subkeys bak
 	               , iby_security_segments bas
 	           WHERE bas.sec_subkey_id  = bak.sec_subkey_id
 	             AND bas.sec_segment_id = p_sec_segment_id;
 	       END;

 	       RETURN Uncipher_Field_Value ( p_sec_segment_id
 	                                   , master_key_in
 	                                   , l_subkey_ciphertxt
 	                                   , l_fv_segment
 	                                   , l_encoding
 	                                   );
 	    ELSE
 	       return NULL;
 	    END IF;

 	 END decrypt_field_vals;

 	 FUNCTION decrypt_num_field_vals
 	           (
 	             p_sec_segment_id        IN  NUMBER,
 	             master_key_in           IN  DES3_KEY_TYPE
 	           ) RETURN NUMBER
 	 IS
 	   l_number VARCHAR2(4000);
 	   l_dbg_mod           VARCHAR2(100) := G_DEBUG_MODULE || '.decrypt_num_field_vals';

 	 BEGIN
 	    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

 	    l_number := decrypt_field_vals
 	                   ( p_sec_segment_id,
 	                     master_key_in
 	                   );
	--The decrypted data is sensitive. Don not log it.

 	--    iby_debug_pub.add('l_number : ' || l_number || ':'|| ':',
 	--           iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

 	    return to_number(l_number);
 	 EXCEPTION
 	    WHEN OTHERS THEN
 	       return null;
 	 END decrypt_num_field_vals;

FUNCTION decrypt_date_field
 	  (
 	   p_sec_segment_id        IN  NUMBER,
 	   master_key_in           IN  DES3_KEY_TYPE
 	  ) RETURN DATE
IS
  l_decrypted_val VARCHAR2(16);
  l_field_len     NUMBER;
BEGIN
  l_decrypted_val := decrypt_field_vals(p_sec_segment_id, master_key_in);
  l_field_len := LENGTH(G_ENCRYPTED_EXPDATE_FORMAT);
  l_decrypted_val := SUBSTR(l_decrypted_val, -l_field_len, l_field_len);
  -- Return the last day of the month since the oracle default is first day.
  -- Also, card expiry date is always the last day of month.
  RETURN LAST_DAY(TO_DATE(l_decrypted_val, G_ENCRYPTED_EXPDATE_FORMAT));
END decrypt_date_field;
/*
 * 6018583:FP: END
 */

END IBY_SECURITY_PKG;

/

  GRANT EXECUTE ON "APPS"."IBY_SECURITY_PKG" TO "EM_OAM_MONITOR_ROLE";
