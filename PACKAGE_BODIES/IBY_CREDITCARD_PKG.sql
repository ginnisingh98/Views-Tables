--------------------------------------------------------
--  DDL for Package Body IBY_CREDITCARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_CREDITCARD_PKG" AS
/*$Header: ibyccb.pls 120.23.12010000.48 2010/06/10 18:39:32 lmallick ship $*/

  --Variable to store the supplemental cardholder data encryption flag
  enc_supl_data iby_sys_security_options.encrypt_supplemental_card_data%TYPE;

  --
  -- USE: Gets the credit card encryption mode setting
  --
  FUNCTION Get_CC_Encrypt_Mode
  RETURN iby_sys_security_options.cc_encryption_mode%TYPE
  IS
    l_mode iby_sys_security_options.cc_encryption_mode%TYPE;
    CURSOR c_encrypt_mode
    IS
      SELECT cc_encryption_mode
      FROM iby_sys_security_options;
  BEGIN
    IF (c_encrypt_mode%ISOPEN) THEN CLOSE c_encrypt_mode; END IF;

    OPEN c_encrypt_mode;
    FETCH c_encrypt_mode INTO l_mode;
    CLOSE c_encrypt_mode;

    RETURN l_mode;
  END Get_CC_Encrypt_Mode;

  --
  -- USE: Returns Y or N if the supplemental cardholder data
  --      e.g., chname and expirydate, are encrypted.
  --
 FUNCTION Other_CC_Attribs_Encrypted
 RETURN VARCHAR2
 IS
   l_enc_suppl_data  VARCHAR2(1);

   CURSOR c_sec
    IS
      SELECT nvl(encrypt_supplemental_card_data, 'N')
      FROM iby_sys_security_options;
 BEGIN

  -- No need to cache the value as it may cause synchronization issues.
  -- IF (enc_supl_data IS NOT NULL) THEN
  --   RETURN enc_supl_data;
  -- END IF;

   IF (c_sec%ISOPEN) THEN CLOSE c_sec; END IF;

   OPEN c_sec;
   FETCH c_sec INTO l_enc_suppl_data;
   CLOSE c_sec;

   RETURN l_enc_suppl_data;
 END Other_CC_Attribs_Encrypted;

 FUNCTION isNumber (p_input   varchar2)
 RETURN VARCHAR2
 IS
  l_number NUMBER;
 BEGIN
  l_number := p_input;
     RETURN 'Y';
  EXCEPTION
    WHEN OTHERS THEN
       RETURN 'N';
 END isNumber;

  FUNCTION Get_Billing_Site
  (p_party_site_id IN hz_party_sites.party_site_id%TYPE,
   p_party_id      IN hz_parties.party_id%TYPE
  )
  RETURN hz_party_site_uses.party_site_use_id%TYPE
  IS
    l_site_use_id       hz_party_site_uses.party_site_use_id%TYPE;
    l_site_id           hz_party_sites.party_site_id%TYPE;
    l_site_use_rec      HZ_PARTY_SITE_V2PUB.Party_Site_Use_rec_type;
    lx_return_status    VARCHAR2(1);
    lx_msg_count        NUMBER;
    lx_msg_data         VARCHAR2(2000);

    CURSOR c_site_use
    (ci_party_site IN hz_party_sites.party_site_id%TYPE,
     ci_party_id IN hz_parties.party_id%TYPE
    )
    IS
      SELECT u.party_site_use_id
      FROM hz_party_site_uses u, hz_party_sites s
      WHERE (u.party_site_id = ci_party_site)
-- because of complexities in the payer model
-- do not require the site address to be owned by the card owner
--AND (s.party_id = NVL(ci_party_id,party_id))
        AND (u.party_site_id = s.party_site_id)
        AND (u.site_use_type = G_CC_BILLING_SITE_USE)
        AND ( NVL(u.begin_date,SYSDATE-10) < SYSDATE)
        AND ( NVL(u.end_date,SYSDATE+10) > SYSDATE);

    CURSOR c_site
    (ci_party_site hz_party_sites.party_site_id%TYPE,
     ci_party_id IN hz_parties.party_id%TYPE
    )
    IS
      SELECT party_site_id
      FROM hz_party_sites
      WHERE (party_site_id = ci_party_site)
-- because of complexities in the payer model
-- do not require the site address to be owned by the card owner
--AND (party_id = NVL(ci_party_id,party_id))
        AND ( NVL(start_date_active,SYSDATE-10) < SYSDATE)
        AND ( NVL(end_date_active,SYSDATE+10) > SYSDATE);
  BEGIN
    IF c_site_use%ISOPEN THEN CLOSE c_site_use; END IF;
    IF c_site%ISOPEN THEN CLOSE c_site; END IF;

    OPEN c_site_use(p_party_site_id,NULL);
    FETCH c_site_use INTO l_site_use_id;
    CLOSE c_site_use;

    -- create a site use if it does not exist
    IF (l_site_use_id IS NULL) THEN
      OPEN c_site(p_party_site_id,p_party_id);
      FETCH c_site INTO l_site_id;
      CLOSE c_site;

      IF (NOT l_site_id IS NULL) THEN
        l_site_use_rec.party_site_id := l_site_id;
        l_site_use_rec.application_id := 673;
        l_site_use_rec.site_use_type := G_CC_BILLING_SITE_USE;
        l_site_use_rec.created_by_module := 'TCA_V2_API';

        HZ_PARTY_SITE_V2PUB.Create_Party_Site_Use
        (FND_API.G_FALSE,l_site_use_rec,l_site_use_id,
         lx_return_status,lx_msg_count,lx_msg_data
        );
      END IF;
    END IF;

    RETURN l_site_use_id;
  END Get_Billing_Site;

  --
  -- Validates the given system key; an exception is thrown
  -- if the key is invalid and there is encrypted card
  -- number data in the instruments table
  --
  PROCEDURE check_key( p_sec_key IN VARCHAR2 )
  IS
    l_encrypted_count NUMBER := 0;
    l_keyvalid        VARCHAR2(100) := NULL;
  BEGIN

    iby_security_pkg.validate_sys_key(p_sec_key,l_keyvalid);

    IF (NOT l_keyvalid IS NULL) THEN
      SELECT count(instrid)
      INTO l_encrypted_count
      FROM iby_creditcard
      WHERE (NVL(encrypted,'N')<>'N');

      IF (l_encrypted_count>0) THEN
        raise_application_error(-20000,l_keyvalid, FALSE);
      END IF;
    END IF;

  END check_key;

  PROCEDURE encrypt_chname
  (p_sec_key IN iby_security_pkg.DES3_KEY_TYPE,
   p_chname  IN iby_creditcard.chname%TYPE,
   p_segment_id IN NUMBER,
   x_segment_id OUT NOCOPY NUMBER,
   x_masked_chname OUT NOCOPY iby_creditcard.chname%TYPE,
   x_mask_setting OUT NOCOPY iby_sys_security_options.credit_card_mask_setting%TYPE,
   x_unmask_len   OUT NOCOPY iby_sys_security_options.credit_card_unmask_len%TYPE
   )
   IS
     l_unmask_data     iby_creditcard.chname%TYPE;
     l_mask_data       iby_creditcard.chname%TYPE;
     l_unmask_len      NUMBER;
     l_chname_segment  iby_security_segments.segment_cipher_text%TYPE;
     l_subkey_cipher   iby_sys_security_subkeys.subkey_cipher_text%TYPE;

     l_dbg_mod       VARCHAR2(100) := 'iby.plsql.IBY_CREDITCARD_PKG' || '.' || 'encrypt_chname';
   BEGIN
     IF (p_chname IS NOT NULL) THEN
       Get_Mask_Settings(x_mask_setting, x_unmask_len);
       l_unmask_data
         := IBY_SECURITY_PKG.Get_Unmasked_Data(p_chname, x_mask_setting, x_unmask_len);
	-- test_debug('l_unmask_data: '|| l_unmask_data);
       l_unmask_len := NVL(LENGTH(l_unmask_data),0);
       iby_debug_pub.add('l_unmask_len: '|| l_unmask_len,iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
       IF (l_unmask_len >= LENGTH(p_chname)) THEN
          --segmentid of -1 would denote that the current mask settings do
	  --not keep the scope for encryption
          x_segment_id := -1;
	  x_masked_chname := p_chname;
          RETURN;
       END IF;

       IF(x_mask_setting = iby_security_pkg.G_MASK_POSTFIX) THEN
         l_mask_data := substr(p_chname, l_unmask_len+1, length(p_chname)-l_unmask_len);
       ELSIF(x_mask_setting = iby_security_pkg.G_MASK_PREFIX) THEN
	 l_mask_data := substr(p_chname, 1, length(p_chname)-l_unmask_len);
       ELSE
         l_mask_data := p_chname;
       END IF;

      l_chname_segment :=
            UTL_I18N.STRING_TO_RAW
            (l_mask_data,iby_security_pkg.G_ENCODING_UTF8_AL32);
--	           	 test_debug('l_chname_segment: '|| l_chname_segment);
	  --  UTL_RAW.CAST_TO_RAW(CONVERT(l_unmask_data,'AL32UTF8'));
       l_chname_segment := IBY_SECURITY_PKG.PKCS5_PAD(l_chname_segment);
--       	 test_debug('l_chname_segment: '|| l_chname_segment);
       IF((p_segment_id IS NULL)OR(p_segment_id = -1)) THEN
           IBY_SECURITY_PKG.Create_Segment( FND_API.G_FALSE
                                          , l_chname_segment
                                          , iby_security_pkg.G_ENCODING_UTF8_AL32
                                          , p_sec_key
                                          , x_segment_id
                                          );


       ELSE
           BEGIN
               SELECT sk.subkey_cipher_text
               INTO l_subkey_cipher
               FROM iby_sys_security_subkeys sk
                  , iby_security_segments ss
               WHERE sk.sec_subkey_id = ss.sec_subkey_id
                 AND ss.sec_segment_id = p_segment_id;
           END;
           IBY_SECURITY_PKG.Update_Segment( FND_API.G_FALSE
                         , p_segment_id
                         , l_chname_segment
                         , iby_security_pkg.G_ENCODING_UTF8_AL32
                         , p_sec_key
                         , l_subkey_cipher
                         );

           x_segment_id := p_segment_id;
       END IF;

       IF(x_unmask_len = 0) THEN --If unmask len is 0, l_unmask_data is returned as null
         x_masked_chname := lpad('*',LENGTH(p_chname),'*');
       ELSIF(x_mask_setting = iby_security_pkg.G_MASK_POSTFIX) THEN
         x_masked_chname := rpad(l_unmask_data,LENGTH(p_chname),'*');
       ELSIF(x_mask_setting = iby_security_pkg.G_MASK_PREFIX) THEN
         x_masked_chname := lpad(l_unmask_data,LENGTH(p_chname),'*');
       ELSE --G_MASK_ALL)
         x_masked_chname := lpad('*',LENGTH(p_chname),'*');
       END IF;
     END IF;
   END encrypt_chname;

  FUNCTION decrypt_chname
  (p_sec_key IN iby_security_pkg.DES3_KEY_TYPE,
   p_instrid  IN iby_creditcard.instrid%TYPE
  ) RETURN iby_creditcard.chname%TYPE
  IS
    l_sub_key         iby_sys_security_subkeys.subkey_cipher_text%TYPE;
    l_chname_segment  iby_security_segments.segment_cipher_text%TYPE;
    l_chname          iby_creditcard.chname%TYPE;
    l_masked_chname   iby_creditcard.chname%TYPE;
    l_encrypted       VARCHAR2(1);
    l_segment_id      NUMBER;
    l_segment_cipher  iby_security_segments.segment_cipher_text%TYPE;
    l_sub_key_cipher  iby_sys_security_subkeys.subkey_cipher_text%TYPE;

    l_mask_setting    iby_sys_security_options.credit_card_mask_setting%TYPE;
    l_unmask_len      iby_sys_security_options.credit_card_unmask_len%TYPE;
  BEGIN
    SELECT chname, nvl(encrypted, 'N'), chname_sec_segment_id,
           chname_mask_setting, chname_unmask_length
    INTO l_masked_chname, l_encrypted, l_segment_id,
         l_mask_setting, l_unmask_len
    FROM iby_creditcard
    WHERE instrid = p_instrid;

    IF ((l_encrypted = 'N') OR (l_segment_id IS NULL) OR (l_segment_id = -1)) THEN
      RETURN l_masked_chname;
    END IF;

    SELECT sg.segment_cipher_text, sk.subkey_cipher_text
    INTO  l_segment_cipher, l_sub_key_cipher
    FROM iby_security_segments sg, iby_sys_security_subkeys sk
    WHERE sg.sec_subkey_id = sk.sec_subkey_id
      AND sg.sec_segment_id = l_segment_id;

    -- uncipher the subkey
    l_sub_key := iby_security_pkg.get_sys_subkey(p_sec_key,l_sub_key_cipher);

    -- uncipher the segment
    l_chname_segment :=
        dbms_obfuscation_toolkit.des3decrypt
        ( input =>  l_segment_cipher, key => l_sub_key,
          which => dbms_obfuscation_toolkit.ThreeKeyMode
        );
    l_chname_segment := IBY_SECURITY_PKG.PKCS5_UNPAD(l_chname_segment);
    l_chname := UTL_I18N.RAW_TO_CHAR(l_chname_segment,iby_security_pkg.G_ENCODING_UTF8_AL32);

    IF (l_mask_setting = iby_security_pkg.G_MASK_POSTFIX) THEN
       l_chname := trim(both '*' from l_masked_chname) || l_chname;
    ELSIF (l_mask_setting = iby_security_pkg.G_MASK_PREFIX) THEN
       l_chname := l_chname || trim(both '*' from l_masked_chname);
    END IF;

    RETURN l_chname;

  END decrypt_chname;

  -- USE: Saves card information to the credit card history table
  --
  PROCEDURE Archive_Card
  (p_commit           IN   VARCHAR2,
   p_instr_id         IN   iby_creditcard.instrid%TYPE,
   x_history_id       OUT NOCOPY iby_creditcard_h.card_history_change_id%TYPE
  )
  IS
  BEGIN

    /*
     * Fix for bug 5256903 by rameshsh:
     *
     * The active_flag column is nullable in IBY_CREDITCARD
     * but nor in IBY_CREDITCARD_H.
     *
     * If active_flag is not set for a particular credit card
     * in IBY_CREDITCARD, default the value to 'Y', otherwise
     * this method will throw a 'cannot insert NULL exception ..'
     */
    SELECT iby_creditcard_h_s.NEXTVAL INTO x_history_id FROM dual;
    INSERT INTO iby_creditcard_h
    (card_history_change_id, instrid, expirydate, expiry_sec_segment_id,
     addressid,
     description, chname, chname_sec_segment_id, finame, security_group_id,
     encrypted,
     masked_cc_number, card_owner_id, instrument_type, purchasecard_flag,
     purchasecard_subtype, card_issuer_code, single_use_flag,
     information_only_flag, card_purpose, active_flag, inactive_date,
     attribute_category, attribute1, attribute2, attribute3, attribute4,
     attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
     attribute11, attribute12, attribute13, attribute14, attribute15,
     attribute16, attribute17, attribute18, attribute19, attribute20,
     attribute21, attribute22, attribute23, attribute24, attribute25,
     attribute26, attribute27, attribute28, attribute29, attribute30,
     request_id, program_application_id, program_id, program_update_date,
     created_by, creation_date, last_updated_by, last_update_date,
     last_update_login, object_version_number
    )
    SELECT x_history_id, instrid, expirydate, expiry_sec_segment_id,
      addressid,
      description, chname, chname_sec_segment_id, finame, security_group_id,
      encrypted,
      masked_cc_number, card_owner_id, instrument_type, purchasecard_flag,
      purchasecard_subtype, card_issuer_code, single_use_flag,
      information_only_flag, card_purpose, NVL(active_flag, 'Y'), inactive_date,
      attribute_category, attribute1, attribute2, attribute3, attribute4,
      attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
      attribute11, attribute12, attribute13, attribute14, attribute15,
      attribute16, attribute17, attribute18, attribute19, attribute20,
      attribute21, attribute22, attribute23, attribute24, attribute25,
      attribute26, attribute27, attribute28, attribute29, attribute30,
      request_id, program_application_id, program_id, program_update_date,
      fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
      fnd_global.login_id, 1
    FROM iby_creditcard
    WHERE (instrid = p_instr_id);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;
  END Archive_Card;

  --
  -- USE: Gets credit card mask settings
  --
  PROCEDURE Get_Mask_Settings
  (x_mask_setting  OUT NOCOPY iby_sys_security_options.credit_card_mask_setting%TYPE,
   x_unmask_len    OUT NOCOPY iby_sys_security_options.credit_card_unmask_len%TYPE
  )
  IS

    CURSOR c_mask_setting
    IS
      SELECT credit_card_mask_setting, credit_card_unmask_len
      FROM iby_sys_security_options;

  BEGIN
    x_mask_setting := iby_security_pkg.G_MASK_PREFIX;

    IF (c_mask_setting%ISOPEN) THEN CLOSE c_mask_setting; END IF;

    OPEN c_mask_setting;
    FETCH c_mask_setting INTO x_mask_setting, x_unmask_len;
    CLOSE c_mask_setting;

    IF (x_mask_setting IS NULL) THEN
      x_mask_setting := iby_security_pkg.G_MASK_PREFIX;
    END IF;
    IF (x_unmask_len IS NULL) THEN
      x_unmask_len := G_DEF_UNMASK_LENGTH;
    END IF;
  END Get_Mask_Settings;

  FUNCTION Mask_Card_Number
  (p_cc_number       IN   iby_creditcard.ccnumber%TYPE,
   p_mask_option     IN   iby_creditcard.card_mask_setting%TYPE,
   p_unmask_len      IN   iby_creditcard.card_unmask_length%TYPE
  )
  RETURN iby_creditcard.masked_cc_number%TYPE
  IS
  BEGIN
    RETURN iby_security_pkg.Mask_Data
           (p_cc_number,p_mask_option,p_unmask_len,G_MASK_CHARACTER);
  END Mask_Card_Number;

  --
  -- Return: The masked card number, usable for display purposes
  --
  PROCEDURE Mask_Card_Number
  (p_cc_number     IN iby_creditcard.ccnumber%TYPE,
   x_masked_number OUT NOCOPY iby_creditcard.masked_cc_number%TYPE,
   x_mask_setting  OUT NOCOPY iby_sys_security_options.credit_card_mask_setting%TYPE,
   x_unmask_len    OUT NOCOPY iby_sys_security_options.credit_card_unmask_len%TYPE
  )
  IS
  BEGIN
    Get_Mask_Settings(x_mask_setting,x_unmask_len);
    x_masked_number :=
      Mask_Card_Number(p_cc_number,x_mask_setting,x_unmask_len);
  END Mask_Card_Number;

  FUNCTION Mask_Card_Number(p_cc_number IN iby_creditcard.ccnumber%TYPE)
  RETURN iby_creditcard.masked_cc_number%TYPE
  IS
    lx_mask_option  iby_creditcard.card_mask_setting%TYPE;
    lx_mask_number  iby_creditcard.masked_cc_number%TYPE;
    lx_unmask_len   iby_sys_security_options.credit_card_unmask_len%TYPE;
  BEGIN
    Mask_Card_Number(p_cc_number,lx_mask_number,lx_mask_option,lx_unmask_len);
    RETURN lx_mask_number;
  END Mask_Card_Number;


  PROCEDURE Create_Card
  (p_commit           IN   VARCHAR2,
   p_owner_id         IN   iby_creditcard.card_owner_id%TYPE,
   p_holder_name      IN   iby_creditcard.chname%TYPE,
   p_billing_address_id IN iby_creditcard.addressid%TYPE,
   p_address_type     IN   VARCHAR2,
   p_billing_zip      IN   iby_creditcard.billing_addr_postal_code%TYPE,
   p_billing_country  IN   iby_creditcard.bill_addr_territory_code%TYPE,
   p_card_number      IN   iby_creditcard.ccnumber%TYPE,
   p_expiry_date      IN   iby_creditcard.expirydate%TYPE,
   p_instr_type       IN   iby_creditcard.instrument_type%TYPE,
   p_pcard_flag       IN   iby_creditcard.purchasecard_flag%TYPE,
   p_pcard_type       IN   iby_creditcard.purchasecard_subtype%TYPE,
   p_issuer           IN   iby_creditcard.card_issuer_code%TYPE,
   p_fi_name          IN   iby_creditcard.finame%TYPE,
   p_single_use       IN   iby_creditcard.single_use_flag%TYPE,
   p_info_only        IN   iby_creditcard.information_only_flag%TYPE,
   p_purpose          IN   iby_creditcard.card_purpose%TYPE,
   p_desc             IN   iby_creditcard.description%TYPE,
   p_active_flag      IN   iby_creditcard.active_flag%TYPE,
   p_inactive_date    IN   iby_creditcard.inactive_date%TYPE,
   p_sys_sec_key      IN   iby_security_pkg.DES3_KEY_TYPE,
	   p_attribute_category IN iby_creditcard.attribute_category%TYPE,
	   p_attribute1	IN 	iby_creditcard.attribute1%TYPE,
	   p_attribute2	IN 	iby_creditcard.attribute2%TYPE,
	   p_attribute3	IN 	iby_creditcard.attribute3%TYPE,
	   p_attribute4	IN 	iby_creditcard.attribute4%TYPE,
	   p_attribute5	IN 	iby_creditcard.attribute5%TYPE,
	   p_attribute6	IN 	iby_creditcard.attribute6%TYPE,
	   p_attribute7	IN 	iby_creditcard.attribute7%TYPE,
	   p_attribute8	IN 	iby_creditcard.attribute8%TYPE,
	   p_attribute9	IN 	iby_creditcard.attribute9%TYPE,
	   p_attribute10	IN 	iby_creditcard.attribute10%TYPE,
	   p_attribute11	IN 	iby_creditcard.attribute11%TYPE,
	   p_attribute12	IN 	iby_creditcard.attribute12%TYPE,
	   p_attribute13	IN 	iby_creditcard.attribute13%TYPE,
	   p_attribute14	IN 	iby_creditcard.attribute14%TYPE,
	   p_attribute15	IN 	iby_creditcard.attribute15%TYPE,
	   p_attribute16	IN 	iby_creditcard.attribute16%TYPE,
	   p_attribute17	IN 	iby_creditcard.attribute17%TYPE,
	   p_attribute18	IN 	iby_creditcard.attribute18%TYPE,
	   p_attribute19	IN 	iby_creditcard.attribute19%TYPE,
	   p_attribute20	IN 	iby_creditcard.attribute20%TYPE,
	   p_attribute21	IN 	iby_creditcard.attribute21%TYPE,
	   p_attribute22	IN 	iby_creditcard.attribute22%TYPE,
	   p_attribute23	IN 	iby_creditcard.attribute23%TYPE,
	   p_attribute24	IN 	iby_creditcard.attribute24%TYPE,
	   p_attribute25	IN 	iby_creditcard.attribute25%TYPE,
	   p_attribute26	IN 	iby_creditcard.attribute26%TYPE,
	   p_attribute27	IN 	iby_creditcard.attribute27%TYPE,
	   p_attribute28	IN 	iby_creditcard.attribute28%TYPE,
	   p_attribute29	IN 	iby_creditcard.attribute29%TYPE,
	   p_attribute30	IN 	iby_creditcard.attribute30%TYPE,
   x_result_code      OUT  NOCOPY VARCHAR2,
   x_instr_id         OUT  NOCOPY iby_creditcard.instrid%TYPE,
   p_allow_invalid_card      IN      VARCHAR2,
   p_user_id                 IN      NUMBER,
   p_login_id                IN      NUMBER
  )
  IS

    lx_checksum_valid   BOOLEAN := FALSE;
    lx_return_status    VARCHAR2(1);
    lx_msg_count        NUMBER;
    lx_msg_data         VARCHAR2(200);
    lx_card_issuer      iby_creditcard.card_issuer_code%TYPE;
    lx_issuer_range     iby_creditcard.cc_issuer_range_id%TYPE;
    lx_card_prefix      iby_cc_issuer_ranges.card_number_prefix%TYPE;
    lx_digit_check      iby_creditcard_issuers_b.digit_check_flag%TYPE;
    l_card_len          iby_creditcard.cc_number_length%TYPE;

    lx_cc_number        iby_creditcard.ccnumber%TYPE;
    lx_cc_compressed    iby_creditcard.ccnumber%TYPE;
    lx_unmasked_digits  iby_creditcard.ccnumber%TYPE;
    l_cc_ciphertext     iby_security_segments.segment_cipher_text%TYPE;
    l_encrypted         iby_creditcard.encrypted%TYPE;
    lx_masked_number    iby_creditcard.masked_cc_number%TYPE;
    lx_mask_option      iby_creditcard.card_mask_setting%TYPE;
    lx_unmask_len       iby_creditcard.card_unmask_length%TYPE;
    l_cc_hash1          iby_creditcard.cc_number_hash1%TYPE;
    l_cc_hash2          iby_creditcard.cc_number_hash2%TYPE;
    lx_sec_segment_id   iby_security_segments.sec_segment_id%TYPE;

    l_expiry_date       iby_creditcard.expirydate%TYPE;

    --l_billing_site      hz_party_site_uses.party_site_use_id%TYPE;-- will not use this variable any more

    -- variabled for CHNAME and EXPDATE encryption
    l_chname_sec_segment_id iby_security_segments.sec_segment_id%TYPE;
    l_expdate_sec_segment_id iby_security_segments.sec_segment_id%TYPE;
    l_chname            VARCHAR2(100);
    l_masked_chname     VARCHAR2(100) := NULL;
    l_chname_mask_setting iby_sys_security_options.credit_card_mask_setting%TYPE;
    l_chname_unmask_len   iby_sys_security_options.credit_card_unmask_len%TYPE;
    l_exp_date          DATE;
    l_expired           VARCHAR2(1) := NULL;

    l_subkey            iby_sys_security_subkeys.subkey_cipher_text%TYPE;
    l_subkey_id         iby_sys_security_subkeys.sec_subkey_id%TYPE;
    l_keyvalid    VARCHAR2(100) := NULL;

    -- Variables to be used when an invalid card is registered
    l_invalid_flag         VARCHAR2(1) := NULL;
    l_invalidation_reason  VARCHAR2(100) := NULL;
    l_isAlphaNumericCard   VARCHAR2(1) := 'N';
    l_allow_invalid_card   VARCHAR2(1);

    CURSOR c_card
    (ci_owner_id IN hz_parties.party_id%TYPE,
     ci_hash1    IN iby_creditcard.cc_number_hash1%TYPE,
     ci_hash2    IN iby_creditcard.cc_number_hash1%TYPE
    )
    IS
      SELECT instrid
      FROM iby_creditcard
      WHERE (cc_number_hash1 = ci_hash1)
        AND (cc_number_hash2 = ci_hash2)
        AND ( (NVL(card_owner_id,ci_owner_id) = NVL(ci_owner_id,card_owner_id))
              OR (card_owner_id IS NULL AND ci_owner_id IS NULL)
            )
        AND (NVL(single_use_flag,'N')='N');
  BEGIN

    l_allow_invalid_card := NVL(p_allow_invalid_card, 'N');

    IF (c_card%ISOPEN) THEN CLOSE c_card; END IF;

    IF (p_card_number IS NULL ) THEN
      x_result_code := G_RC_INVALID_CCNUMBER;
      RETURN;
    END IF;

    -- expiration date may be null
    IF (NOT p_expiry_date IS NULL) THEN
      l_expiry_date := LAST_DAY(p_expiry_date);
      IF (TRUNC(l_expiry_date,'DD') < TRUNC(SYSDATE,'DD')) THEN
        x_result_code := G_RC_INVALID_CCEXPIRY;
	--Keeping this assignment as we may allow registration of expired
	--credit cards in future.
	l_expired := 'Y';
	IF (nvl(l_invalid_flag, 'N') = 'N') THEN
	      l_invalid_flag := 'Y';
	      l_invalidation_reason := G_RC_INVALID_CCEXPIRY;
	END IF;
	IF (l_allow_invalid_card <> 'Y') THEN
	   RETURN;
	END IF;
      ELSE
        l_expired := 'N';
      END IF;
    END IF;

    IF (NOT p_pcard_type IS NULL) THEN
      IF (iby_utility_pvt.check_lookup_val(p_pcard_type,G_LKUP_PCARD_TYPE))
      THEN
        x_result_code := G_RC_INVALID_PCARD_TYPE;
        RETURN;
      END IF;
    END IF;

    IF ( (NVL(p_instr_type,' ') <> G_LKUP_INSTR_TYPE_CC)
         AND (NVL(p_instr_type,' ') <> G_LKUP_INSTR_TYPE_DC)
         AND (NVL(p_instr_type,' ') <> G_LKUP_INSTR_TYPE_PC ))
    THEN
      x_result_code := G_RC_INVALID_INSTR_TYPE;
      RETURN;
    END IF;

    iby_cc_validate.StripCC
    (1.0, FND_API.G_FALSE, p_card_number,
     lx_return_status, lx_msg_count, lx_msg_data, lx_cc_number
    );

    IF( (lx_cc_number IS NULL) OR
        (lx_return_status IS NULL OR
	   lx_return_status <> FND_API.G_RET_STS_SUCCESS) )
    THEN
      x_result_code := G_RC_INVALID_CCNUMBER;
      RETURN;
    END IF;

    iby_cc_validate.Get_CC_Issuer_Range
    (lx_cc_number,lx_card_issuer,lx_issuer_range,lx_card_prefix,lx_digit_check);
    --Bug# 8346420
    --When the upstream product passes the information for card issuer then
    --the below block would be executed. In case of "UNKNOWN" card types, the
    --value is coming as empty, in that case we trim and compare. By doing that
    --the below condition wouldn't be satisfied and the card will be registered.
    IF(length(TRIM(p_issuer)) > 0) THEN
      IF ( (NOT p_issuer IS NULL) AND (p_issuer <> lx_card_issuer) ) THEN
        x_result_code := G_RC_INVALID_CARD_ISSUER;
	  IF (nvl(l_invalid_flag, 'N') = 'N') THEN
	     l_invalid_flag := 'Y';
	     l_invalidation_reason := G_RC_INVALID_CARD_ISSUER;
	  END IF;
	  --Since the card issuer is already invalid, no need to
	  --perform digit check
	  lx_digit_check := 'N';
	  lx_card_issuer := p_issuer;

	  IF (l_allow_invalid_card <> 'Y') THEN
           RETURN;
	  END IF;
      END IF;
    END IF;

    IF (lx_digit_check = 'Y') THEN
      IF ( MOD(iby_cc_validate.CheckCCDigits(lx_cc_number),10) <> 0 ) THEN
        x_result_code := G_RC_INVALID_CCNUMBER;
	  IF (nvl(l_invalid_flag, 'N') = 'N') THEN
	     l_invalid_flag := 'Y';
	     l_invalidation_reason := G_RC_INVALID_CCNUMBER;
	  END IF;
	  IF (l_allow_invalid_card <> 'Y') THEN
           RETURN;
	  END IF;
      END IF;
    END IF;

    -- necessary to decompress secured card instruments, but only if
    -- no known issuer range matches
    IF (lx_issuer_range IS NULL) THEN
      l_card_len := LENGTH(lx_cc_number);
    END IF;

    Mask_Card_Number(lx_cc_number,lx_masked_number,lx_mask_option,lx_unmask_len);
    l_cc_hash1 := iby_security_pkg.get_hash(lx_cc_number,'F');
    -- get hash value for a salted version of the card number
    l_cc_hash2 := iby_security_pkg.get_hash(lx_cc_number,'T');

    -- lmallick
    -- do not perform the TCA entity validation here. Instead, trust
    -- the data passed here

    -- Bug 5153265 start
    -- If Site use id is already provied then no need to call get_billing address
    /*IF (p_address_type = G_PARTY_SITE_USE_ID) AND (NOT (p_billing_address_id  IS NULL)) THEN
      l_billing_site := p_billing_address_id;
    ELSE
      IF (p_billing_address_id = FND_API.G_MISS_NUM ) THEN
        l_billing_site := FND_API.G_MISS_NUM;
      ELSIF (NOT (p_billing_address_id IS NULL)) THEN
        l_billing_site := Get_Billing_Site(p_billing_address_id,p_owner_id);
        IF (l_billing_site IS NULL) THEN
          x_result_code := G_RC_INVALID_ADDRESS;
          RETURN;
        END IF;
      END IF;
    END IF;
    -- Bug 5153265 end


    IF (NOT ( (p_billing_country IS NULL)
            OR (p_billing_country = FND_API.G_MISS_CHAR) )
       )
    THEN
      IF (NOT iby_utility_pvt.Validate_Territory(p_billing_country)) THEN
        x_result_code := G_RC_INVALID_ADDRESS;
        RETURN;
      END IF;
    END IF;

    IF (NOT p_owner_id IS NULL) THEN
      IF (NOT iby_utility_pvt.validate_party_id(p_owner_id)) THEN
        x_result_code := G_RC_INVALID_PARTY;
        RETURN;
      END IF;
    END IF;*/

    OPEN c_card(p_owner_id,l_cc_hash1,l_cc_hash2);
    FETCH c_card INTO x_instr_id;
    CLOSE c_card;

    IF (NOT x_instr_id IS NULL) THEN RETURN; END IF;

    IF (NOT p_sys_sec_key IS NULL) THEN
      -- check the system key
      iby_security_pkg.validate_sys_key(p_sys_sec_key,l_keyvalid);

      IF (NOT l_keyvalid IS NULL) THEN
        x_result_code := 'INVALID_SEC_KEY';
        RETURN;
      END IF;
      l_encrypted := 'Y';

      Compress_CC_Number
      (lx_cc_number,lx_card_prefix,lx_digit_check,lx_mask_option,
       lx_unmask_len,lx_cc_compressed,lx_unmasked_digits);

      IF (NOT lx_cc_compressed IS NULL) THEN
        l_cc_ciphertext :=
          HEXTORAW(IBY_SECURITY_PKG.Encode_Number(lx_cc_compressed,TRUE));
        IBY_SECURITY_PKG.Create_Segment
        (FND_API.G_FALSE,l_cc_ciphertext,iby_security_pkg.G_ENCODING_NUMERIC,
         p_sys_sec_key,lx_sec_segment_id);
      END IF;
      lx_cc_number := NVL(lx_unmasked_digits,'0');

      l_chname := p_holder_name;
      -- Do not allow a chname containing a mask character(*)
      IF(INSTR(l_chname, '*') <> 0)THEN
         l_chname := null;
      END IF;

      --now need to encrypt the other card holder data
      --i.e, CHNAME and EXPDATE for now.
      IF(Other_CC_Attribs_Encrypted = 'Y') THEN
     --    l_chname_sec_segment_id :=
     --            IBY_SECURITY_PKG.encrypt_field_vals(p_holder_name,
     --	                                     p_sys_sec_key,
     --						     null,
     --					     'N'
     --						     );
         l_encrypted := 'A';
         l_expdate_sec_segment_id :=
                 IBY_SECURITY_PKG.encrypt_date_field(l_expiry_date,
		                                     p_sys_sec_key,
						     null,
						     'N'
						     );
	Encrypt_Chname
              (p_sys_sec_key,
               l_chname,
               null,
               l_chname_sec_segment_id,
               l_masked_chname,
               l_chname_mask_setting,
               l_chname_unmask_len
              );


         -- The actuall date column will hold a NULL value in this
         -- case.
         l_expiry_date := NULL;
      ELSE
         l_masked_chname := p_holder_name;
      END IF;
    ELSE
      --l_encrypted := 'N';
      -- we use the same CHNAME column for storing the masked value
      -- when encryption is enabled. So, make this value point to
      -- the clear text when encryption is not enabled.
      -- Also the expiry date column will hold the actual exp date
      -- in this case.
      l_masked_chname := p_holder_name;
    END IF;
   -- l_chname_length := NVL(LENGTH(p_holder_name), 0);

    SELECT iby_instr_s.NEXTVAL INTO x_instr_id FROM DUAL;

    INSERT INTO iby_creditcard
    (instrid, ccnumber, masked_cc_number,
     card_mask_setting, card_unmask_length, cc_number_hash1, cc_number_hash2,
     expirydate, expiry_sec_segment_id, expired_flag,
     card_owner_id, chname, chname_sec_segment_id,
     chname_mask_setting, chname_unmask_length,
     addressid, billing_addr_postal_code, bill_addr_territory_code,
     instrument_type, purchasecard_flag, purchasecard_subtype,
     card_issuer_code, cc_issuer_range_id, cc_number_length,
     description, finame, encrypted, cc_num_sec_segment_id,
     single_use_flag, information_only_flag, card_purpose,
     active_flag, inactive_date,
     last_update_date, last_updated_by, creation_date,
     created_by, last_update_login, object_version_number,
     attribute_category,
     attribute1,attribute2, attribute3,attribute4,attribute5,
    attribute6,attribute7, attribute8,attribute9,attribute10,
    attribute11,attribute12, attribute13,attribute14,attribute15,
    attribute16,attribute17, attribute18,attribute19,attribute20,
    attribute21,attribute22, attribute23,attribute24,attribute25,
    attribute26,attribute27, attribute28,attribute29,attribute30,
    invalid_flag, invalidation_reason,
    salt_version
    )
    VALUES
    (x_instr_id, lx_cc_number, lx_masked_number,
     lx_mask_option, lx_unmask_len, l_cc_hash1, l_cc_hash2,
     l_expiry_date, l_expdate_sec_segment_id, l_expired,
     p_owner_id, l_masked_chname, l_chname_sec_segment_id,
     l_chname_mask_setting, l_chname_unmask_len,
     p_billing_address_id, p_billing_zip, p_billing_country,
     p_instr_type, NVL(p_pcard_flag,'N'), p_pcard_type,
     lx_card_issuer, lx_issuer_range, l_card_len,
     p_desc, p_fi_name, l_encrypted, lx_sec_segment_id,
     NVL(p_single_use,'N'), NVL(p_info_only,'N'), p_purpose,
     NVL(p_active_flag,'Y'), p_inactive_date,
     sysdate, nvl(p_user_id, fnd_global.user_id), sysdate,
     decode(p_user_id,-1,fnd_global.user_id,p_user_id),
     decode(p_login_id,-1,fnd_global.login_id,p_login_id), 1,
     p_attribute_category,
     p_attribute1,p_attribute2,p_attribute3,p_attribute4,p_attribute5,
    p_attribute6,p_attribute7,p_attribute8,p_attribute9,p_attribute10,
    p_attribute11,p_attribute12,p_attribute13,p_attribute14,p_attribute15,
    p_attribute16,p_attribute17, p_attribute18,p_attribute19,p_attribute20,
    p_attribute21,p_attribute22, p_attribute23,p_attribute24,p_attribute25,
    p_attribute26,p_attribute27, p_attribute28,p_attribute29,p_attribute30,
    l_invalid_flag, l_invalidation_reason,
    iby_security_pkg.get_salt_version
    );

    -- Reached upto this point implies that the registration has succeeded
    -- clear the error codes that might have got assigned to the x_result_code parameter
    -- during invalid credit card registration
    x_result_code := NULL;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;
  END Create_Card;

  PROCEDURE Update_Card
  (p_commit           IN   VARCHAR2,
   p_instr_id         IN   iby_creditcard.instrid%TYPE,
   p_owner_id         IN   iby_creditcard.card_owner_id%TYPE,
   p_holder_name      IN   iby_creditcard.chname%TYPE,
   p_billing_address_id IN iby_creditcard.addressid%TYPE,
   p_address_type     IN   VARCHAR2,
   p_billing_zip      IN   iby_creditcard.billing_addr_postal_code%TYPE,
   p_billing_country  IN   iby_creditcard.bill_addr_territory_code%TYPE,
   p_expiry_date      IN   iby_creditcard.expirydate%TYPE,
   p_instr_type       IN   iby_creditcard.instrument_type%TYPE,
   p_pcard_flag       IN   iby_creditcard.purchasecard_flag%TYPE,
   p_pcard_type       IN   iby_creditcard.purchasecard_subtype%TYPE,
   p_fi_name          IN   iby_creditcard.finame%TYPE,
   p_single_use       IN   iby_creditcard.single_use_flag%TYPE,
   p_info_only        IN   iby_creditcard.information_only_flag%TYPE,
   p_purpose          IN   iby_creditcard.card_purpose%TYPE,
   p_desc             IN   iby_creditcard.description%TYPE,
   p_active_flag      IN   iby_creditcard.active_flag%TYPE,
   p_inactive_date    IN   iby_creditcard.inactive_date%TYPE,
  p_attribute_category IN iby_creditcard.attribute_category%TYPE,
   p_attribute1	IN 	iby_creditcard.attribute1%TYPE,
  p_attribute2	IN 	iby_creditcard.attribute2%TYPE,
   p_attribute3	IN 	iby_creditcard.attribute3%TYPE,
  p_attribute4	IN 	iby_creditcard.attribute4%TYPE,
   p_attribute5	IN 	iby_creditcard.attribute5%TYPE,
   p_attribute6	IN 	iby_creditcard.attribute6%TYPE,
   p_attribute7	IN 	iby_creditcard.attribute7%TYPE,
   p_attribute8	IN 	iby_creditcard.attribute8%TYPE,
   p_attribute9	IN 	iby_creditcard.attribute9%TYPE,
   p_attribute10	IN 	iby_creditcard.attribute10%TYPE,
   p_attribute11	IN 	iby_creditcard.attribute11%TYPE,
   p_attribute12	IN 	iby_creditcard.attribute12%TYPE,
   p_attribute13	IN 	iby_creditcard.attribute13%TYPE,
   p_attribute14	IN 	iby_creditcard.attribute14%TYPE,
   p_attribute15	IN 	iby_creditcard.attribute15%TYPE,
   p_attribute16	IN 	iby_creditcard.attribute16%TYPE,
   p_attribute17	IN 	iby_creditcard.attribute17%TYPE,
   p_attribute18	IN 	iby_creditcard.attribute18%TYPE,
   p_attribute19	IN 	iby_creditcard.attribute19%TYPE,
   p_attribute20	IN 	iby_creditcard.attribute20%TYPE,
  p_attribute21	IN 	iby_creditcard.attribute21%TYPE,
   p_attribute22	IN 	iby_creditcard.attribute22%TYPE,
   p_attribute23	IN 	iby_creditcard.attribute23%TYPE,
   p_attribute24	IN 	iby_creditcard.attribute24%TYPE,
   p_attribute25	IN 	iby_creditcard.attribute25%TYPE,
   p_attribute26	IN 	iby_creditcard.attribute26%TYPE,
   p_attribute27	IN 	iby_creditcard.attribute27%TYPE,
   p_attribute28	IN 	iby_creditcard.attribute28%TYPE,
   p_attribute29	IN 	iby_creditcard.attribute29%TYPE,
   p_attribute30	IN 	iby_creditcard.attribute30%TYPE,
   x_result_code      OUT NOCOPY VARCHAR2,
   p_allow_invalid_card      IN      VARCHAR2
  )
  IS
    l_history_id      iby_creditcard_h.card_history_change_id%TYPE;
    l_billing_site    NUMBER;
    l_expiry_date       iby_creditcard.expirydate%TYPE;

  -- variabled for CHNAME and EXPDATE encryption
    l_chname_sec_segment_id iby_security_segments.sec_segment_id%TYPE;
    l_expdate_sec_segment_id iby_security_segments.sec_segment_id%TYPE;
    l_chname            VARCHAR2(100);
    l_masked_chname     VARCHAR2(100) := NULL;
    l_expired           VARCHAR2(1) := NULL;
    l_chname_mask_setting   iby_creditcard.chname_mask_setting%TYPE;
    l_chname_unmask_len     iby_creditcard.chname_unmask_length%TYPE;
    l_chname_unmask_data    iby_creditcard.chname%TYPE;

    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(300);
    l_return_status VARCHAR2(1);
    l_resp_rec      IBY_INSTRREG_PUB.SecureCardInfoResp_rec_type;
    l_sec_code      VARCHAR2(10);

  --  l_encrypted_date_format VARCHAR2(20) := NULL;
    l_exp_date          DATE;
    l_encrypted   VARCHAR2(1);
    l_keyvalid    VARCHAR2(100) := NULL;

    -- Variables to be used when an invalid card is registered
    l_invalid_flag         VARCHAR2(1) := NULL;
    l_invalidation_reason  VARCHAR2(100) := NULL;
    l_allow_invalid_card   VARCHAR2(1);

    l_dbg_mod       VARCHAR2(100) := 'iby.plsql.IBY_CREDITCARD_PKG' || '.' || 'Update_Card';

  BEGIN
    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
    l_allow_invalid_card := NVL(p_allow_invalid_card, 'N');
    IF (NOT p_pcard_type IS NULL) THEN
      IF (iby_utility_pvt.check_lookup_val(p_pcard_type,G_LKUP_PCARD_TYPE)) THEN
        x_result_code := G_RC_INVALID_PCARD_TYPE;
        RETURN;
      END IF;
    END IF;

    IF (NOT p_instr_type IS NULL) THEN
      IF ( (p_instr_type <> G_LKUP_INSTR_TYPE_CC)
           AND (p_instr_type <> G_LKUP_INSTR_TYPE_DC) )
      THEN
        x_result_code := G_RC_INVALID_INSTR_TYPE;
        RETURN;
      END IF;
    END IF;
    IF (NOT p_owner_id IS NULL) THEN
      IF (NOT iby_utility_pvt.validate_party_id(p_owner_id)) THEN
        x_result_code := G_RC_INVALID_PARTY;
        RETURN;
      END IF;
    END IF;
    -- Bug 5153265 start
    -- If Site use id is already provied then no need to call get_billing address
    IF (p_address_type = G_PARTY_SITE_USE_ID) AND (NOT (p_billing_address_id  IS NULL)) THEN
      l_billing_site := p_billing_address_id;
    ELSE
      IF (p_billing_address_id = FND_API.G_MISS_NUM ) THEN
        l_billing_site := FND_API.G_MISS_NUM;
      ELSIF (NOT (p_billing_address_id IS NULL)) THEN
        l_billing_site := Get_Billing_Site(p_billing_address_id,p_owner_id);
        IF (l_billing_site IS NULL) THEN
          x_result_code := G_RC_INVALID_ADDRESS;
          RETURN;
        END IF;
      END IF;
    END IF;
    -- Bug 5153265 end

    IF (NOT ( (p_billing_country IS NULL)
            OR (p_billing_country = FND_API.G_MISS_CHAR) )
       )
    THEN
      IF (NOT iby_utility_pvt.Validate_Territory(p_billing_country)) THEN
        x_result_code := G_RC_INVALID_ADDRESS;
        RETURN;
      END IF;
    END IF;

    -- To be removed
   /* iby_debug_pub.add('expiry date passed as:'||p_expiry_date,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    iby_debug_pub.add('holder name:'||p_holder_name,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    IF(p_holder_name = FND_API.G_MISS_CHAR)THEN
      iby_debug_pub.add('holder name is FND_API.G_MISS_CHAR.',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    END IF;*/
    ---------------------

    -- Bug 5479785 (Panaraya)
    -- Added check for expiry date on update
    -- expiration date may be null
    IF (NOT p_expiry_date IS NULL) THEN
      l_expiry_date := LAST_DAY(p_expiry_date);
      IF (TRUNC(l_expiry_date,'DD') < TRUNC(SYSDATE,'DD')) THEN
        x_result_code := G_RC_INVALID_CCEXPIRY;
	l_expired := 'Y';
	IF (nvl(l_invalid_flag, 'N') = 'N') THEN
	     l_invalid_flag := 'Y';
	     l_invalidation_reason := G_RC_INVALID_CCEXPIRY;
	END IF;
	IF (l_allow_invalid_card <> 'Y') THEN
           RETURN;
	END IF;
      ELSE
        l_expired := 'N';
      END IF;
    END IF;

    -- Get the encrypted flag value of the existing record
    SELECT encrypted, expiry_sec_segment_id, chname_sec_segment_id,
           chname_mask_setting, chname_unmask_length
    INTO l_encrypted, l_expdate_sec_segment_id, l_chname_sec_segment_id,
         l_chname_mask_setting, l_chname_unmask_len
    FROM iby_creditcard
    WHERE instrid = p_instr_id;

    IF(iby_debug_pub.G_LEVEL_INFO >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('expiry_sec_segment_id:'||l_expdate_sec_segment_id,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      iby_debug_pub.add('chname_sec_segment_id:'||l_chname_sec_segment_id,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      iby_debug_pub.add('chname_unmask_length:'||l_chname_unmask_len,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    END IF;

    -- If a masked chname is passed then ignore this for update
    l_chname := p_holder_name;
    IF(INSTR(l_chname, '*') <> 0)THEN
      l_chname := null;
    END IF;

    -- Need to encrypt the sensitive data only if the record was
    -- previously encrypted and of course the encryption mode
    -- shouldn't be NONE
    IF (Get_CC_Encrypt_Mode <> IBY_SECURITY_PKG.G_ENCRYPT_MODE_NONE
        AND l_encrypted = 'A'
	--AND Other_CC_Attribs_Encrypted = 'Y'
       ) THEN

      --Get_Mask_Settings(l_chname_mask_setting, l_chname_unmask_len);

      --If p_holder_name is null then do not update the chname
      --(and do not pass unnecessary values in the http request)
      IF (p_holder_name IS NULL) THEN
        l_chname_sec_segment_id := null;
	l_chname_mask_setting := null;
        l_chname_unmask_len := null;
      END IF;

      IF(l_expiry_date IS NULL) THEN
        l_expdate_sec_segment_id := null;
      END IF;

      /*
      IF (p_holder_name = FND_API.G_MISS_CHAR) THEN
         iby_debug_pub.add('chname passed: G_MISS_CHAR',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      END IF;
      iby_debug_pub.add('chname passed:'||p_holder_name,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      */

      -- No need for the http request if the expiry date and chname
      -- are not expected to be updated
      IF((l_expiry_date IS NOT NULL) OR
         ((p_holder_name IS NOT NULL) AND (p_holder_name <> FND_API.G_MISS_CHAR))
	) THEN

        IBY_INSTRREG_PUB.SecureCardInfo(l_expiry_date,
                                      l_expdate_sec_segment_id,
                                      l_chname,
				      l_chname_sec_segment_id,
                                      l_chname_mask_setting,
                                      l_chname_unmask_len,
                                      l_return_status,
                                      l_msg_count,
                                      l_msg_data,
                                      l_resp_rec
				      );
        IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
	  iby_debug_pub.add('Error during http call out',iby_debug_pub.G_LEVEL_ERROR,l_dbg_mod);
	  x_result_code := FND_API.G_RET_STS_ERROR;
	  RETURN;
	END IF;

        l_chname_sec_segment_id  := l_resp_rec.ChnameSegmentId;
        l_expdate_sec_segment_id := l_resp_rec.ExpiryDateSegmentId;
        l_masked_chname := l_resp_rec.MaskedChname;
        l_chname_mask_setting := l_resp_rec.ChnameMaskSetting;
        l_chname_unmask_len := l_resp_rec.ChnameUnmaskLength;

        l_expiry_date := NULL;

      IF(iby_debug_pub.G_LEVEL_INFO >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('l_masked_chname(2):'||l_masked_chname,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
        iby_debug_pub.add('expiry_sec_segment_id(2):'||l_chname_sec_segment_id,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
        iby_debug_pub.add('chname_sec_segment_id(2):'||l_expdate_sec_segment_id,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
        iby_debug_pub.add('chname_unmask_length(2):'||l_chname_unmask_len,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      END IF;

      ELSE
        iby_debug_pub.add('Skipping http callout..',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      END IF;

    ELSE
      --l_encrypted := 'N';
      -- we use the same CHNAME column for storing the masked value
      -- when encryption is enabled. So, make this value point to
      -- the clear text when encryption is not enabled.
      -- Also the expiry date column will hold the actual exp date
      -- in this case.
      l_masked_chname := l_chname;

    END IF;

    Archive_Card(FND_API.G_FALSE,p_instr_id,l_history_id);


    UPDATE iby_creditcard
    SET chname = DECODE(l_chname, FND_API.G_MISS_CHAR,NULL, NULL,chname, l_masked_chname),
      chname_sec_segment_id = DECODE(l_chname, FND_API.G_MISS_CHAR,NULL,
                                     NULL,chname_sec_segment_id,l_chname_sec_segment_id),
      chname_mask_setting = DECODE(l_chname, FND_API.G_MISS_CHAR,NULL,
                                   NULL,chname_mask_setting,l_chname_mask_setting),
      chname_unmask_length = DECODE(l_chname, FND_API.G_MISS_CHAR,NULL,
                                    NULL,chname_unmask_length,l_chname_unmask_len),
      card_owner_id = NVL(card_owner_id,p_owner_id),
      addressid = DECODE(l_billing_site, FND_API.G_MISS_NUM,NULL,
                         NULL,addressid, l_billing_site),
      bill_addr_territory_code =
        DECODE(p_billing_country, FND_API.G_MISS_CHAR,NULL,
               NULL,bill_addr_territory_code, p_billing_country),
      billing_addr_postal_code =
        DECODE(p_billing_zip, FND_API.G_MISS_CHAR,NULL,
               NULL,billing_addr_postal_code, p_billing_zip),
    --  expirydate = NVL(p_expiry_date, expirydate),
      expirydate = DECODE(p_expiry_date, NULL, expirydate, l_expiry_date),
      expiry_sec_segment_id = DECODE(p_expiry_date, NULL, expiry_sec_segment_id,
                                        l_expdate_sec_segment_id),
      expired_flag = nvl(l_expired, expired_flag),
      encrypted = l_encrypted,
      instrument_type = NVL(p_instr_type, instrument_type),
      purchasecard_flag = NVL(p_pcard_flag, purchasecard_flag),
      purchasecard_subtype =
        DECODE(p_pcard_type, FND_API.G_MISS_CHAR,NULL,
               NULL,purchasecard_subtype, p_pcard_type),
      finame = DECODE(p_fi_name, FND_API.G_MISS_CHAR,NULL, NULL,finame, p_fi_name),
      single_use_flag = NVL(p_single_use, single_use_flag),
      information_only_flag = NVL(p_info_only, information_only_flag),
      card_purpose = DECODE(p_purpose, FND_API.G_MISS_CHAR,NULL, NULL,card_purpose, p_purpose),
      description = DECODE(p_desc, FND_API.G_MISS_CHAR,NULL, NULL,description, p_desc),
      active_flag = NVL(p_active_flag, active_flag),
      inactive_date = DECODE(p_inactive_date, FND_API.G_MISS_DATE,NULL,
                             NULL,inactive_date, p_inactive_date),

      invalid_flag = decode(invalid_flag,null,l_invalid_flag,'N',l_invalid_flag,invalid_flag),
      invalidation_reason = nvl(l_invalidation_reason, invalidation_reason),
      object_version_number = object_version_number + 1,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id,
      attribute_category = p_Attribute_category,
      attribute1 = DECODE(p_attribute1,FND_API.G_MISS_CHAR,NULL,NULL,attribute1, p_attribute1),
      attribute2 = DECODE(p_attribute2,FND_API.G_MISS_CHAR,NULL,NULL,attribute2, p_attribute2),
      attribute3 = DECODE(p_attribute3,FND_API.G_MISS_CHAR,NULL,NULL,attribute3, p_attribute3),
      attribute4 = DECODE(p_attribute4,FND_API.G_MISS_CHAR,NULL,NULL,attribute4, p_attribute4),
      attribute5 = DECODE(p_attribute5,FND_API.G_MISS_CHAR,NULL,NULL,attribute5, p_attribute5),
      attribute6 = DECODE(p_attribute6,FND_API.G_MISS_CHAR,NULL,NULL,attribute6, p_attribute6),
      attribute7 = DECODE(p_attribute7,FND_API.G_MISS_CHAR,NULL,NULL,attribute7, p_attribute7),
      attribute8 = DECODE(p_attribute8,FND_API.G_MISS_CHAR,NULL,NULL,attribute8, p_attribute8),
      attribute9 = DECODE(p_attribute9,FND_API.G_MISS_CHAR,NULL,NULL,attribute9, p_attribute9),
      attribute10 = DECODE(p_attribute10,FND_API.G_MISS_CHAR,NULL,NULL,attribute10, p_attribute10),
      attribute11 = DECODE(p_attribute11,FND_API.G_MISS_CHAR,NULL,NULL,attribute11, p_attribute11),
      attribute12 = DECODE(p_attribute12,FND_API.G_MISS_CHAR,NULL,NULL,attribute12, p_attribute12),
      attribute13 = DECODE(p_attribute13,FND_API.G_MISS_CHAR,NULL,NULL,attribute13, p_attribute13),
      attribute14 = DECODE(p_attribute14,FND_API.G_MISS_CHAR,NULL,NULL,attribute14, p_attribute14),
      attribute15 = DECODE(p_attribute15,FND_API.G_MISS_CHAR,NULL,NULL,attribute15, p_attribute15),
      attribute16 = DECODE(p_attribute16,FND_API.G_MISS_CHAR,NULL,NULL,attribute16, p_attribute16),
      attribute17 = DECODE(p_attribute17,FND_API.G_MISS_CHAR,NULL,NULL,attribute17, p_attribute17),
      attribute18 = DECODE(p_attribute18,FND_API.G_MISS_CHAR,NULL,NULL,attribute18, p_attribute18),
      attribute19 = DECODE(p_attribute19,FND_API.G_MISS_CHAR,NULL,NULL,attribute19, p_attribute19),
      attribute20 = DECODE(p_attribute20,FND_API.G_MISS_CHAR,NULL,NULL,attribute20, p_attribute20),
      attribute21 = DECODE(p_attribute21,FND_API.G_MISS_CHAR,NULL,NULL,attribute21, p_attribute21),
      attribute22 = DECODE(p_attribute22,FND_API.G_MISS_CHAR,NULL,NULL,attribute22, p_attribute22),
      attribute23 = DECODE(p_attribute23,FND_API.G_MISS_CHAR,NULL,NULL,attribute23, p_attribute23),
      attribute24 = DECODE(p_attribute24,FND_API.G_MISS_CHAR,NULL,NULL,attribute24, p_attribute24),
      attribute25 = DECODE(p_attribute25,FND_API.G_MISS_CHAR,NULL,NULL,attribute25, p_attribute25),
      attribute26 = DECODE(p_attribute26,FND_API.G_MISS_CHAR,NULL,NULL,attribute26, p_attribute26),
      attribute27 = DECODE(p_attribute27,FND_API.G_MISS_CHAR,NULL,NULL,attribute27, p_attribute27),
      attribute28 = DECODE(p_attribute28,FND_API.G_MISS_CHAR,NULL,NULL,attribute28, p_attribute28),
      attribute29 = DECODE(p_attribute29,FND_API.G_MISS_CHAR,NULL,NULL,attribute29, p_attribute29),
      attribute30 = DECODE(p_attribute30,FND_API.G_MISS_CHAR,NULL,NULL,attribute30, p_attribute30)
    WHERE (instrid = p_instr_id);

    IF (SQL%NOTFOUND) THEN x_result_code := G_RC_INVALID_CARD_ID;
    ELSE x_result_code := null;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;
  END Update_Card;

  FUNCTION uncipher_ccnumber
  (p_instrid        IN iby_creditcard.instrid%TYPE,
   p_sys_sec_key    IN iby_security_pkg.DES3_KEY_TYPE
  )
  RETURN iby_creditcard.ccnumber%TYPE
  IS
    l_cc_number       iby_creditcard.ccnumber%TYPE;
    l_segment_cipher  iby_security_segments.segment_cipher_text%TYPE;
    l_card_len        iby_creditcard.cc_number_length%TYPE;
    l_encrypted       iby_creditcard.encrypted%TYPE;
    l_cc_prefix       iby_cc_issuer_ranges.card_number_prefix%TYPE;
    l_digit_check     iby_creditcard_issuers_b.digit_check_flag%TYPE;
    l_mask_option     iby_creditcard.card_mask_setting%TYPE;
    l_unmask_len      iby_creditcard.card_unmask_length%TYPE;
    l_unmask_digits   iby_creditcard.ccnumber%TYPE;

    l_subkey_cipher   iby_sys_security_subkeys.subkey_cipher_text%TYPE;
    l_keyvalid        VARCHAR2(100) := NULL;

    CURSOR c_instr_num(ci_instrid iby_creditcard.instrid%TYPE)
    IS
      SELECT
        c.ccnumber, seg.segment_cipher_text,
        NVL(c.encrypted,'N'), k.subkey_cipher_text, r.card_number_prefix,
        NVL(i.digit_check_flag,'N'), c.card_mask_setting, c.card_unmask_length,
        DECODE(encrypted, 'Y',c.ccnumber,'A',c.ccnumber, NULL),
        NVL(r.card_number_length,c.cc_number_length)
      FROM iby_creditcard c, iby_security_segments seg,
        iby_sys_security_subkeys k, iby_cc_issuer_ranges r,
        iby_creditcard_issuers_b i
      WHERE (instrid = ci_instrid)
        AND (c.cc_num_sec_segment_id = seg.sec_segment_id(+))
        AND (seg.sec_subkey_id = k.sec_subkey_id(+))
        AND (c.cc_issuer_range_id = r.cc_issuer_range_id(+))
        AND (r.card_issuer_code = i.card_issuer_code(+));
  BEGIN

    IF (c_instr_num%ISOPEN) THEN CLOSE c_instr_num; END IF;

    OPEN c_instr_num(p_instrid);
    FETCH c_instr_num INTO l_cc_number, l_segment_cipher,
      l_encrypted, l_subkey_cipher,
      l_cc_prefix, l_digit_check, l_mask_option, l_unmask_len,
      l_unmask_digits, l_card_len;
    CLOSE c_instr_num;

    IF (l_cc_number IS NULL) THEN
      raise_application_error(-20000, 'IBY_20512#', FALSE);
    END IF;

    IF (l_encrypted = 'Y' OR l_encrypted = 'A') THEN
      iby_security_pkg.validate_sys_key(p_sys_sec_key,l_keyvalid);
      IF (NOT l_keyvalid IS NULL) THEN
        raise_application_error(-20000,'IBY_10008#INSTRID='||p_instrid, FALSE);
      END IF;
    END IF;

    RETURN uncipher_ccnumber(l_cc_number, l_segment_cipher, l_encrypted,
                             p_sys_sec_key, l_subkey_cipher, l_card_len,
                             l_cc_prefix, l_digit_check, l_mask_option,
                             l_unmask_len, l_unmask_digits);
  END uncipher_ccnumber;

  FUNCTION uncipher_ccnumber
  (p_cc_number     IN     iby_creditcard.ccnumber%TYPE,
   p_segment_cipher IN    iby_security_segments.segment_cipher_text%TYPE,
   p_encrypted     IN     iby_creditcard.encrypted%TYPE,
   p_sys_key       IN     iby_security_pkg.DES3_KEY_TYPE,
   p_subkey_cipher IN     iby_sys_security_subkeys.subkey_cipher_text%TYPE,
   p_card_len      IN     iby_cc_issuer_ranges.card_number_length%TYPE,
   p_cc_prefix     IN     iby_cc_issuer_ranges.card_number_prefix%TYPE,
   p_digit_check   IN     iby_creditcard_issuers_b.digit_check_flag%TYPE,
   p_mask_setting  IN     iby_sys_security_options.credit_card_mask_setting%TYPE,
   p_unmask_len    IN     iby_sys_security_options.credit_card_unmask_len%TYPE,
   p_unmask_digits IN     iby_creditcard.masked_cc_number%TYPE
  )
  RETURN iby_creditcard.ccnumber%TYPE
  IS
    l_sub_key         iby_security_pkg.DES3_KEY_TYPE;
    l_segment_raw     iby_security_segments.segment_cipher_text%TYPE;
    l_cc_number       iby_creditcard.ccnumber%TYPE;
    l_compress_len    NUMBER;
  BEGIN
    l_cc_number := '';
    l_compress_len := Get_Compressed_Len
                      (p_card_len,p_cc_prefix,p_digit_check,p_mask_setting,
                       p_unmask_len);

    IF (p_encrypted = 'Y' OR p_encrypted = 'A') THEN
      IF (l_compress_len > 0) THEN
        -- uncipher the subkey
        l_sub_key :=
          iby_security_pkg.get_sys_subkey(p_sys_key,p_subkey_cipher);

        l_segment_raw :=
          dbms_obfuscation_toolkit.des3decrypt
          ( input => p_segment_cipher , key => l_sub_key,
            which => dbms_obfuscation_toolkit.ThreeKeyMode
          );

        l_cc_number := iby_security_pkg.Decode_Number
                       (l_segment_raw,l_compress_len,TRUE);
      END IF;

      -- finally, uncompress the card number
      RETURN Uncompress_CC_Number
      (l_cc_number,p_card_len,p_cc_prefix,p_digit_check,p_mask_setting,
       p_unmask_len,p_unmask_digits);
    ELSE
      RETURN p_cc_number;
    END IF;
  END uncipher_ccnumber;

  FUNCTION uncipher_ccnumber_ui_wrp
  (i_instrid     IN iby_creditcard.instrid%TYPE,
   i_sys_sec_key IN iby_security_pkg.DES3_KEY_TYPE)
  RETURN iby_creditcard.ccnumber%TYPE
  IS
  BEGIN
    RETURN uncipher_ccnumber(i_instrid, i_sys_sec_key);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN null;
  END uncipher_ccnumber_ui_wrp;

  PROCEDURE Decrypt_Instruments
  (p_commit      IN     VARCHAR2,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  )
  IS
    l_cc_number       iby_creditcard.ccnumber%TYPE;

    -- variabled for CHNAME and EXPDATE decryption
    l_chname            VARCHAR2(80);
    l_str_exp_date      VARCHAR2(20);
    l_exp_date          DATE;
   -- l_encrypted_date_format VARCHAR2(20);

    CURSOR c_card
    IS
      SELECT c.instrid, c.ccnumber, seg.segment_cipher_text,
        c.encrypted, k.subkey_cipher_text,
        NVL(r.card_number_length,c.cc_number_length) card_len,
        r.card_number_prefix, i.digit_check_flag, c.card_mask_setting,
        c.card_unmask_length, c.ccnumber unmask_digits, c.cc_num_sec_segment_id,
	c.chname, c.chname_sec_segment_id,
	c.expirydate, c.expiry_sec_segment_id
      FROM iby_creditcard c, iby_creditcard_issuers_b i,
        iby_cc_issuer_ranges r, iby_sys_security_subkeys k,
        iby_security_segments seg
      WHERE (NVL(c.encrypted,'N') <> 'N')
        AND (c.card_issuer_code = i.card_issuer_code(+))
        AND (c.cc_issuer_range_id = r.cc_issuer_range_id(+))
        AND (c.cc_num_sec_segment_id = seg.sec_segment_id(+))
        AND (seg.sec_subkey_id = k.sec_subkey_id(+));
  BEGIN

    FOR c_card_rec IN c_card LOOP

      l_cc_number :=
        uncipher_ccnumber
        (c_card_rec.ccnumber, c_card_rec.segment_cipher_text,
         c_card_rec.encrypted, p_sys_key, c_card_rec.subkey_cipher_text,
         c_card_rec.card_len, c_card_rec.card_number_prefix,
         c_card_rec.digit_check_flag, c_card_rec.card_mask_setting,
         c_card_rec.card_unmask_length, c_card_rec.unmask_digits
        );

      IF (c_card_rec.expiry_sec_segment_id IS NOT NULL) THEN
        l_exp_date := IBY_SECURITY_PKG.decrypt_date_field
	                            (c_card_rec.expiry_sec_segment_id,
				     p_sys_key
				     );
     ELSE
        -- The exp date wasn't encrypted
        l_exp_date := c_card_rec.expirydate;
     END IF;

      IF(c_card_rec.chname_sec_segment_id IS NOT NULL) THEN
           l_chname := decrypt_chname(p_sys_key, c_card_rec.instrid);
      ELSE
        -- CHNAME wasn't encrypted
        l_chname := c_card_rec.chname;
      END IF;


      UPDATE iby_creditcard
      SET
        ccnumber = l_cc_number,
        encrypted = 'N',
        cc_num_sec_segment_id = NULL,
	expirydate = l_exp_date,
        expiry_sec_segment_id = NULL,
	chname = l_chname,
        chname_sec_segment_id = NULL,
	chname_mask_setting   = NULL,
	chname_unmask_length  = NULL,
        object_version_number = object_version_number + 1,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
      WHERE (instrid = c_card_rec.instrid);

      DELETE iby_security_segments
      WHERE (sec_segment_id IN (c_card_rec.cc_num_sec_segment_id,
                                c_card_rec.chname_sec_segment_id,
				c_card_rec.expiry_sec_segment_id)
			       );
    END LOOP;

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
  END Decrypt_Instruments;

  PROCEDURE Encrypt_Instruments
  (p_commit      IN     VARCHAR2,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  )
  IS
    l_mode            iby_sys_security_options.cc_encryption_mode%TYPE;
    lx_compress_cc    iby_creditcard.ccnumber%TYPE;
    lx_mask_digits    iby_creditcard.masked_cc_number%TYPE;

    l_subkey          iby_security_pkg.DES3_KEY_TYPE;
    l_segment_id      iby_security_segments.sec_segment_id%TYPE;
    l_cc_ciphertext     iby_security_segments.segment_cipher_text%TYPE;

    -- variabled for CHNAME and EXPDATE encryption
    l_chname_sec_segment_id iby_security_segments.sec_segment_id%TYPE;
    l_chname_mask_setting    iby_creditcard.chname_mask_setting%TYPE;
    l_chname_unmask_len      iby_creditcard.chname_unmask_length%TYPE;
    l_expdate_sec_segment_id iby_security_segments.sec_segment_id%TYPE;
    l_masked_chname     VARCHAR2(100) := NULL;
    l_exp_date          DATE;

    l_expired_flag      VARCHAR2(1);
    l_encrypted         VARCHAR2(1);
    l_enc_supl_data     VARCHAR2(1);


    CURSOR c_card
    IS
      SELECT c.instrid, c.ccnumber, c.cc_issuer_range_id,
        k.subkey_cipher_text, r.card_number_prefix, i.digit_check_flag,
        c.card_mask_setting, c.card_unmask_length, c.chname, c.expirydate
      FROM iby_creditcard c, iby_creditcard_issuers_b i,
        iby_cc_issuer_ranges r, iby_security_segments seg,
        iby_sys_security_subkeys k
      WHERE (NVL(c.encrypted,'N') = 'N')
        AND (c.card_issuer_code = i.card_issuer_code(+))
        AND (c.cc_issuer_range_id = r.cc_issuer_range_id(+))
        AND (c.cc_num_sec_segment_id = seg.sec_segment_id(+))
        AND (seg.sec_subkey_id = k.sec_subkey_id(+));
  BEGIN

    l_mode := Get_CC_Encrypt_Mode();
    l_enc_supl_data := Other_CC_Attribs_Encrypted;
    IF (l_mode = iby_security_pkg.G_ENCRYPT_MODE_NONE) THEN
      RETURN;
    END IF;

    check_key(p_sys_key);

    FOR c_card_rec IN c_card LOOP
      Compress_CC_Number
      (c_card_rec.ccnumber,
       c_card_rec.card_number_prefix, c_card_rec.digit_check_flag,
       c_card_rec.card_mask_setting, c_card_rec.card_unmask_length,
       lx_compress_cc, lx_mask_digits);

      IF (NVL(LENGTH(lx_compress_cc),0) > 0) THEN
        l_cc_ciphertext :=
          HEXTORAW(IBY_SECURITY_PKG.Encode_Number(lx_compress_cc,TRUE));

        IBY_SECURITY_PKG.Create_Segment
        (FND_API.G_FALSE,l_cc_ciphertext,iby_security_pkg.G_ENCODING_NUMERIC,
         p_sys_key,l_segment_id);
      ELSE
        l_segment_id := -1;
      END IF;


      --now need to encrypt the other card holder data
      --i.e, CHNAME and EXPDATE for now.
      IF(l_enc_supl_data = 'Y') THEN
         l_encrypted := 'A';
         --l_chname_sec_segment_id :=
         --        IBY_SECURITY_PKG.encrypt_field_vals(c_card_rec.chname,
	 --	                                     p_sys_key,
	 --					     null,
	 --					     'N'
	 --					     );
         l_expdate_sec_segment_id :=
                 IBY_SECURITY_PKG.encrypt_date_field(c_card_rec.expirydate,
		                                     p_sys_key,
						     null,
						     'N'
						     );
	 encrypt_chname(p_sys_key,
                        c_card_rec.chname,
                        null,
                        l_chname_sec_segment_id,
                        l_masked_chname,
                        l_chname_mask_setting,
                        l_chname_unmask_len
                       );

      ELSE
         l_encrypted := 'Y';
         l_masked_chname := c_card_rec.chname;
	 l_exp_date := c_card_rec.expirydate;
      END IF;

      -- Since the expiry dates would also be encrypted, update the
      -- expired_flag column for these records.
      IF (c_card_rec.expirydate IS NOT NULL) THEN
         IF (TRUNC(c_card_rec.expirydate,'DD') < TRUNC(SYSDATE,'DD')) THEN
           l_expired_flag := 'Y';
         ELSE
           l_expired_flag := 'N';
         END IF;
      ELSE
         l_expired_flag := null;
      END IF;

      UPDATE iby_creditcard
      SET
        ccnumber = NVL(lx_mask_digits,0),
        cc_num_sec_segment_id = l_segment_id,
        encrypted = l_encrypted,
	chname = l_masked_chname,
	chname_sec_segment_id = l_chname_sec_segment_id,
	chname_mask_setting   = l_chname_mask_setting,
	chname_unmask_length  = l_chname_unmask_len,
	expiry_sec_segment_id = l_expdate_sec_segment_id,
	expirydate = l_exp_date,
	expired_flag = l_expired_flag,
        object_version_number = object_version_number + 1,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
      WHERE (instrid = c_card_rec.instrid);
    END LOOP;

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;

  END Encrypt_Instruments;

  PROCEDURE Remask_Instruments
  (p_commit      IN     VARCHAR2 := FND_API.G_TRUE,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  )
  IS
    l_cc_number       iby_creditcard.ccnumber%TYPE;
    lx_compress_cc    iby_creditcard.ccnumber%TYPE;
    lx_mask_digits    iby_creditcard.ccnumber%TYPE;
    lx_mask_option    iby_creditcard.card_mask_setting%TYPE;
    lx_unmask_len     iby_creditcard.card_unmask_length%TYPE;
    l_cc_ciphertext   iby_security_segments.segment_cipher_text%TYPE;
    lx_segment_id     iby_security_segments.sec_segment_id%TYPE;

    l_chname          iby_creditcard.chname%TYPE;
    l_masked_chname   iby_creditcard.chname%TYPE;
    l_chname_seg_id   iby_creditcard.chname_sec_segment_id%TYPE;
    l_chname_mask_setting  iby_creditcard.chname_mask_setting%TYPE;
    l_chname_unmask_len    iby_creditcard.chname_unmask_length%TYPE;

    CURSOR c_card
    (ci_mask_option   iby_creditcard.card_mask_setting%TYPE,
     ci_unmask_len    iby_creditcard.card_unmask_length%TYPE
    )
    IS
      SELECT c.instrid, c.ccnumber, seg.segment_cipher_text,
        c.encrypted, k.subkey_cipher_text,
        NVL(r.card_number_length,c.cc_number_length) card_len,
        r.card_number_prefix, i.digit_check_flag, c.card_mask_setting,
        c.card_unmask_length, c.ccnumber unmask_digits, seg.sec_segment_id,
        LENGTH(c.ccnumber) len, c.chname, c.chname_sec_segment_id,
	c.chname_mask_setting, c.chname_unmask_length
      FROM iby_creditcard c, iby_creditcard_issuers_b i,
        iby_cc_issuer_ranges r, iby_sys_security_subkeys k,
        iby_security_segments seg
      WHERE (c.card_issuer_code = i.card_issuer_code(+))
        AND (c.cc_issuer_range_id = r.cc_issuer_range_id(+))
        AND (c.cc_num_sec_segment_id = seg.sec_segment_id(+))
        AND (seg.sec_subkey_id = k.sec_subkey_id(+))
        AND ( (NVL(card_unmask_length,-1) <> ci_unmask_len) OR
              (NVL(card_mask_setting,' ') <> ci_mask_option)
            );
  BEGIN

    IF (c_card%ISOPEN) THEN CLOSE c_card; END IF;

    check_key(p_sys_key);

    Get_Mask_Settings(lx_mask_option,lx_unmask_len);

    FOR c_card_rec IN c_card(lx_mask_option,lx_unmask_len) LOOP
      l_cc_number :=
        uncipher_ccnumber
        (c_card_rec.ccnumber, c_card_rec.segment_cipher_text,
         c_card_rec.encrypted, p_sys_key,
         c_card_rec.subkey_cipher_text, c_card_rec.card_len,
         c_card_rec.card_number_prefix, c_card_rec.digit_check_flag,
         c_card_rec.card_mask_setting, c_card_rec.card_unmask_length,
         c_card_rec.unmask_digits
        );

      l_chname := decrypt_chname(p_sys_key, c_card_rec.instrid);

      lx_segment_id := c_card_rec.sec_segment_id;

      IF (nvl(c_card_rec.encrypted,'N') <> 'N') THEN

        Compress_CC_Number
        (l_cc_number,c_card_rec.card_number_prefix,c_card_rec.digit_check_flag,
         lx_mask_option,lx_unmask_len,lx_compress_cc,lx_mask_digits);

        --
        -- masking options may have resulted in no hidden digits; only
        -- update if there still exist card digits that are not exposed through
        -- the mask or card issuer range
        --
        IF (NVL(LENGTH(lx_compress_cc),0) > 0) THEN
          l_cc_ciphertext :=
            HEXTORAW(IBY_SECURITY_PKG.Encode_Number(lx_compress_cc,TRUE));
          IF (lx_segment_id IS NULL) THEN
            IBY_SECURITY_PKG.Create_Segment
            (FND_API.G_FALSE,l_cc_ciphertext,
             iby_security_pkg.G_ENCODING_NUMERIC,
             p_sys_key,lx_segment_id);
          ELSE
            IBY_SECURITY_PKG.Update_Segment
            (FND_API.G_FALSE,lx_segment_id,l_cc_ciphertext,
             iby_security_pkg.G_ENCODING_NUMERIC,
             p_sys_key,c_card_rec.subkey_cipher_text);
          END IF;
        ELSE
          DELETE iby_security_segments WHERE (sec_segment_id = lx_segment_id);
        END IF;

	IF (c_card_rec.encrypted = 'A') THEN
	  -- Re-encryption of the card holder name will result in encryption
	  -- with the modified mask settings
	  Encrypt_Chname
              (p_sys_key,
               l_chname,
               c_card_rec.chname_sec_segment_id,
               l_chname_seg_id,
               l_masked_chname,
               l_chname_mask_setting,
               l_chname_unmask_len
              );
        ELSE -- c_card_rec.encrypted = 'Y'
          -- Unlike ccnumber, the chname is masked only when the record is
	  -- encrypted. When not encrypted, this would store the unmasked value
          l_masked_chname := l_chname;
	  l_chname_seg_id := null;
          l_chname_mask_setting := null;
          l_chname_unmask_len := null;
        END IF;
      ELSE
        l_masked_chname := l_chname;
	l_chname_seg_id := null;
        l_chname_mask_setting := null;
        l_chname_unmask_len := null;
      END IF;

      UPDATE iby_creditcard
      SET
        ccnumber =
	  DECODE(encrypted,'Y',NVL(lx_mask_digits,'0'),'A',NVL(lx_mask_digits,'0'),ccnumber),
        masked_cc_number =
          Mask_Card_Number(l_cc_number,lx_mask_option,lx_unmask_len),
        cc_num_sec_segment_id = lx_segment_id,
        card_mask_setting = lx_mask_option,
        card_unmask_length = lx_unmask_len,
	chname = l_masked_chname,
	chname_sec_segment_id = l_chname_seg_id,
	chname_mask_setting = l_chname_mask_setting,
	chname_unmask_length = l_chname_unmask_len,
        object_version_number = object_version_number + 1,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
      WHERE (instrid = c_card_rec.instrid);
    END LOOP;

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
  END Remask_Instruments;

  PROCEDURE Compress_CC_Number
  (p_card_number IN iby_creditcard.ccnumber%TYPE,
   p_prefix      IN iby_cc_issuer_ranges.card_number_prefix%TYPE,
   p_digit_check IN iby_creditcard_issuers_b.digit_check_flag%TYPE,
   p_mask_setting IN iby_sys_security_options.credit_card_mask_setting%TYPE,
   p_unmask_len  IN iby_sys_security_options.credit_card_unmask_len%TYPE,
   x_compress_num OUT NOCOPY iby_creditcard.ccnumber%TYPE,
   x_unmask_digits OUT NOCOPY iby_creditcard.masked_cc_number%TYPE
  )
  IS
    l_prefix_index    NUMBER;
    l_unmask_len      NUMBER;
    l_substr_start    NUMBER;
    l_substr_stop     NUMBER;
  BEGIN

    x_unmask_digits :=
      iby_security_pkg.Get_Unmasked_Data
      (p_card_number,p_mask_setting,p_unmask_len);
    l_unmask_len := NVL(LENGTH(x_unmask_digits),0);

    -- all digits exposed; compressed number is trivial
    IF (l_unmask_len >= LENGTH(p_card_number)) THEN
      x_compress_num := NULL;
      RETURN;
    END IF;

    IF ( (p_mask_setting = iby_security_pkg.G_MASK_POSTFIX)
         AND (p_unmask_len > NVL(LENGTH(p_prefix),0))
       )
    THEN
      l_substr_start := l_unmask_len + 1;
    ELSE
      l_substr_start := 1 + NVL(LENGTH(p_prefix),0);
    END IF;

    IF (p_mask_setting = iby_security_pkg.G_MASK_PREFIX)
       AND (p_unmask_len>0)
    THEN
      l_substr_stop := GREATEST(LENGTH(p_card_number)-p_unmask_len,0);
    ELSIF (NVL(p_digit_check,'N') = 'Y') THEN
      l_substr_stop := LENGTH(p_card_number) - 1;
    ELSE
      l_substr_stop := LENGTH(p_card_number);
    END IF;

    IF (l_substr_start < (l_substr_stop +1)) THEN
      x_compress_num := SUBSTR(p_card_number,l_substr_start,
                               l_substr_stop - l_substr_start + 1);
    ELSE
      x_compress_num := NULL;
    END IF;
  END Compress_CC_Number;

  FUNCTION Uncompress_CC_Number
  (p_card_number IN iby_creditcard.ccnumber%TYPE,
   p_card_length IN iby_creditcard.cc_number_length%TYPE,
   p_prefix      IN iby_cc_issuer_ranges.card_number_prefix%TYPE,
   p_digit_check IN iby_creditcard_issuers_b.digit_check_flag%TYPE,
   p_mask_setting IN iby_sys_security_options.credit_card_mask_setting%TYPE,
   p_unmask_len  IN iby_sys_security_options.credit_card_unmask_len%TYPE,
   p_unmask_digits IN iby_creditcard.masked_cc_number%TYPE
  )
  RETURN iby_creditcard.ccnumber%TYPE
  IS
    l_cc_num          iby_creditcard.ccnumber%TYPE;
    l_mod_sum         NUMBER;
    l_unmask_digits_len NUMBER;
    l_prefix_len      NUMBER;
    l_prefix_use      NUMBER;
    l_add_check_digit BOOLEAN;
  BEGIN

    l_unmask_digits_len := NVL(LENGTH(p_unmask_digits),0);
    l_prefix_len := NVL(LENGTH(p_prefix),0);

    IF (p_mask_setting = iby_security_pkg.G_MASK_NONE) THEN
      l_cc_num := p_unmask_digits;
      l_add_check_digit := FALSE;
    END IF;

    -- note we assume p_card_number is null if all the digits
    -- are known through a combination of unmasked digits, prefix
    -- and check digit

    IF (p_mask_setting = iby_security_pkg.G_MASK_ALL) THEN
      l_cc_num := NVL(p_prefix,'') || NVL(p_card_number,'');
      l_add_check_digit := (NVL(p_digit_check,'N') = 'Y');
    END IF;

    IF (p_mask_setting = iby_security_pkg.G_MASK_POSTFIX) THEN
      IF (l_unmask_digits_len > l_prefix_len) THEN
        l_cc_num := p_unmask_digits;
      ELSE
        l_cc_num := p_prefix;
      END IF;
      l_cc_num := NVL(l_cc_num,'') || NVL(p_card_number,'');
      l_add_check_digit := (LENGTH(l_cc_num) < p_card_length);
    END IF;

    IF (p_mask_setting = iby_security_pkg.G_MASK_PREFIX) THEN
      l_cc_num := NVL(p_card_number,'') || NVL(p_unmask_digits,'');
      l_add_check_digit := (l_unmask_digits_len < 1);
      l_prefix_use := p_card_length - NVL(LENGTH(l_cc_num),0);
      IF (l_add_check_digit) THEN l_prefix_use := l_prefix_use - 1; END IF;
      l_prefix_use := LEAST(l_prefix_use,l_prefix_len);
      IF (l_prefix_use > 0) THEN
        l_cc_num := NVL(SUBSTR(p_prefix,1,l_prefix_use),'') || l_cc_num;
      END IF;
    END IF;

    IF (l_add_check_digit) THEN
      l_mod_sum := IBY_CC_VALIDATE.CheckCCDigits(l_cc_num||'0');
      l_cc_num := l_cc_num || TO_CHAR(MOD(10-l_mod_sum,10));
    END IF;

    RETURN l_cc_num;

  END Uncompress_CC_Number;

  FUNCTION Get_Compressed_Len
  (p_card_length IN iby_creditcard.cc_number_length%TYPE,
   p_prefix      IN iby_cc_issuer_ranges.card_number_prefix%TYPE,
   p_digit_check IN iby_creditcard_issuers_b.digit_check_flag%TYPE,
   p_mask_setting IN iby_sys_security_options.credit_card_mask_setting%TYPE,
   p_unmask_len  IN iby_sys_security_options.credit_card_unmask_len%TYPE
  )
  RETURN NUMBER
  IS
    l_compress_len    iby_creditcard.ccnumber%TYPE;
    l_prefix_len      NUMBER;
  BEGIN
    l_compress_len := p_card_length;
    l_prefix_len := NVL(LENGTH(p_prefix),0);

    IF (p_mask_setting = iby_security_pkg.G_MASK_PREFIX) THEN

      IF (p_unmask_len>0) THEN
        l_compress_len := GREATEST(l_compress_len - p_unmask_len,0);
      ELSIF (p_digit_check = 'Y') THEN
        l_compress_len := l_compress_len - 1;
      END IF;
      l_compress_len := GREATEST(l_compress_len - l_prefix_len,0);

    ELSIF (p_mask_setting = iby_security_pkg.G_MASK_POSTFIX) THEN

      IF (NVL(p_unmask_len,0) > l_prefix_len) THEN
        l_compress_len := GREATEST(l_compress_len - p_unmask_len,0);
      ELSE
        l_compress_len := l_compress_len - l_prefix_len;
      END IF;

      IF (p_digit_check = 'Y') THEN
        l_compress_len := GREATEST(l_compress_len - 1,0);
      END IF;

    ELSIF (p_mask_setting = iby_security_pkg.G_MASK_NONE) THEN

      l_compress_len := 0;

    ELSIF (p_mask_setting = iby_security_pkg.G_MASK_ALL) THEN

      l_compress_len := l_compress_len - l_prefix_len;
      IF (p_digit_check = 'Y') THEN
        l_compress_len := GREATEST(l_compress_len - 1,0);
      END IF;

    END IF;

    RETURN l_compress_len;
  END Get_Compressed_Len;

  PROCEDURE Query_Card
  (p_card_id          IN   iby_creditcard.instrid%TYPE,
   p_sys_sec_key      IN   iby_security_pkg.DES3_KEY_TYPE,
   x_owner_id         OUT NOCOPY iby_creditcard.card_owner_id%TYPE,
   x_holder_name      OUT NOCOPY iby_creditcard.chname%TYPE,
   x_billing_address_id OUT NOCOPY iby_creditcard.addressid%TYPE,
   x_billing_address1 OUT NOCOPY hz_locations.address1%TYPE,
   x_billing_address2 OUT NOCOPY hz_locations.address2%TYPE,
   x_billing_address3 OUT NOCOPY hz_locations.address3%TYPE,
   x_billing_city     OUT NOCOPY hz_locations.city%TYPE,
   x_billing_county   OUT NOCOPY hz_locations.county%TYPE,
   x_billing_state    OUT NOCOPY hz_locations.state%TYPE,
   x_billing_zip      OUT NOCOPY hz_locations.postal_code%TYPE,
   x_billing_country  OUT NOCOPY hz_locations.country%TYPE,
   x_card_number      OUT NOCOPY iby_creditcard.ccnumber%TYPE,
   x_expiry_date      OUT NOCOPY iby_creditcard.expirydate%TYPE,
   x_instr_type       OUT NOCOPY iby_creditcard.instrument_type%TYPE,
   x_pcard_flag       OUT NOCOPY iby_creditcard.purchasecard_flag%TYPE,
   x_pcard_type       OUT NOCOPY iby_creditcard.purchasecard_subtype%TYPE,
   x_issuer           OUT NOCOPY iby_creditcard.card_issuer_code%TYPE,
   x_fi_name          OUT NOCOPY iby_creditcard.finame%TYPE,
   x_single_use       OUT NOCOPY iby_creditcard.single_use_flag%TYPE,
   x_info_only        OUT NOCOPY iby_creditcard.information_only_flag%TYPE,
   x_purpose          OUT NOCOPY iby_creditcard.card_purpose%TYPE,
   x_desc             OUT NOCOPY iby_creditcard.description%TYPE,
   x_active_flag      OUT NOCOPY iby_creditcard.active_flag%TYPE,
   x_inactive_date    OUT NOCOPY iby_creditcard.inactive_date%TYPE,
   x_result_code      OUT  NOCOPY VARCHAR2
  )
  IS
    l_ccnum_ciphertxt iby_creditcard.ccnumber%TYPE;
    l_encrypted       iby_creditcard.encrypted%TYPE;
    l_err_code        VARCHAR2(200);
    l_instr_found     BOOLEAN;

    -- variabled for CHNAME and EXPDATE decryption
    l_expiry_sec_segment_id  NUMBER;
    l_chname_sec_Segment_id  NUMBER;
    --l_chname            VARCHAR2(80);
    l_str_exp_date      VARCHAR2(20);
    --l_exp_date          DATE;
    --l_encrypted_date_format VARCHAR2(20);

    CURSOR c_creditcard(ci_instr_id iby_creditcard.instrid%TYPE)
    IS
      SELECT
        c.card_owner_id, c.chname, c.addressid,
        l.address1, l.address2, l.address3, l.city, l.county,
        l.state, l.postal_code, l.country,
        c.ccnumber, c.expirydate, c.instrument_type, c.purchasecard_flag,
        c.purchasecard_subtype, c.card_issuer_code, c.finame,
        c.single_use_flag, c.information_only_flag, c.card_purpose,
        c.description, c.active_flag, c.inactive_date,
	c.encrypted, c.expiry_sec_segment_id,
	c.chname_sec_segment_id
      FROM iby_creditcard c, hz_party_site_uses su, hz_party_sites s,
        hz_locations l
      WHERE (instrid = ci_instr_id)
        AND (c.addressid = su.party_site_use_id(+))
        AND (su.party_site_id = s.party_site_id(+))
        AND (s.location_id = l.location_id(+));

  BEGIN

    IF( c_creditcard%ISOPEN ) THEN
      CLOSE c_creditcard;
    END IF;

    IF (NOT p_sys_sec_key IS NULL) THEN
      iby_security_pkg.validate_sys_key(p_sys_sec_key,l_err_code);
      IF (NOT l_err_code IS NULL) THEN
        raise_application_error(-20000, l_err_code, FALSE);
      END IF;
    END IF;

    OPEN c_creditcard(p_card_id);
    FETCH c_creditcard
    INTO x_owner_id, x_holder_name, x_billing_address_id,
      x_billing_address1, x_billing_address2, x_billing_address3,
      x_billing_city, x_billing_county, x_billing_state, x_billing_zip,
      x_billing_country, x_card_number, x_expiry_date, x_instr_type,
      x_pcard_flag, x_pcard_type, x_issuer, x_fi_name, x_single_use,
      x_info_only, x_purpose, x_desc, x_active_flag, x_inactive_date,
      l_encrypted, l_expiry_sec_segment_id,
      l_chname_sec_segment_id;

    l_instr_found := (NOT c_creditcard%NOTFOUND);
    CLOSE c_creditcard;

    IF (NOT l_instr_found) THEN
      raise_application_error(-20000,'IBY_20512', FALSE);
    END IF;

    -- unencrypt/unencode instrument data
    --
    x_card_number := uncipher_ccnumber(p_card_id,p_sys_sec_key);

    -- unencrypt card holder data if its encrypted
    IF (nvl(l_encrypted, 'N') = 'A'
        AND Other_CC_Attribs_Encrypted = 'Y')
    THEN
      IF (l_expiry_sec_segment_id IS NOT NULL) THEN
        x_expiry_date := IBY_SECURITY_PKG.decrypt_date_field
	                            (l_expiry_sec_segment_id,
				     p_sys_sec_key
				     );
     END IF;

      IF(l_chname_sec_segment_id IS NOT NULL) THEN
        x_holder_name := decrypt_chname(p_sys_sec_key, p_card_id);

      END IF;
    END IF;

  END Query_Card;

  PROCEDURE Encrypt_Card_Info
  (p_commit            IN   VARCHAR2  := FND_API.G_TRUE,
   p_sys_security_key  IN   iby_security_pkg.DES3_KEY_TYPE,
   p_expiry_date       IN   DATE,
   p_expSegmentId      IN   NUMBER,
   p_chname            IN   VARCHAR2,
   p_chnameSegmentId   IN   NUMBER,
   p_chnameMaskSetting IN   VARCHAR2,
   p_chnameUnmaskLen   IN   NUMBER,
   x_exp_segment_id    OUT NOCOPY NUMBER,
   x_masked_chname     OUT NOCOPY VARCHAR2,
   x_chname_segment_id OUT NOCOPY NUMBER,
   x_chnameMaskSetting OUT NOCOPY VARCHAR2,
   x_chnameUnmaskLen   OUT NOCOPY NUMBER,
   x_err_code          OUT NOCOPY VARCHAR2
  ) IS

   l_mode       iby_sys_security_options.instr_sec_code_encryption_mode%TYPE;
   l_chnameSegmentId      iby_creditcard.chname_sec_segment_id%type;

  BEGIN
   --  test_debug('Inside Encrypt_Card_Info.. ');
    l_mode := Get_CC_Encrypt_Mode;
    IF (l_mode = iby_security_pkg.G_ENCRYPT_MODE_NONE) THEN
      RETURN;
    END IF;
    iby_security_pkg.validate_sys_key(p_sys_security_key,x_err_code);
    --  test_debug('sysKey valid.. ');
    IF (NOT x_err_code IS NULL) THEN
      RETURN;
    END IF;

    IF (NOT p_expiry_date IS NULL) THEN
    x_exp_segment_id := IBY_SECURITY_PKG.encrypt_date_field(p_expiry_date,
                                                     p_sys_security_key,
                                                     p_expSegmentId,
                                                     'N'
                                                     );
    END IF;

    IF ((NOT p_chname IS NULL) AND (INSTR(p_chname, '*') = 0)) THEN

      -- the chname_sec_segment_id could be -1. In that case, pass null
      -- value for the segment id to the encryption API so that a new segment
      -- is created(if required) for the chname
      IF (p_chnameSegmentId = -1) THEN
        l_chnameSegmentId := null;
      ELSE
        l_chnameSegmentId := p_chnameSegmentId;
      END IF;

      encrypt_chname
       (p_sys_security_key,
        p_chname,
        l_chnameSegmentId,
        x_chname_segment_id,
        x_masked_chname,
        x_chnameMaskSetting,
        x_chnameUnmaskLen
       );
     ELSE
       x_masked_chname := null;
       x_chname_segment_id := p_chnameSegmentId;
       x_chnameMaskSetting := p_chnameMaskSetting;
       x_chnameUnmaskLen := p_chnameUnmaskLen;
    END IF;

  IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
  END IF;


  END Encrypt_Card_Info;

  PROCEDURE Mark_Expired_Cards
  (p_commit       IN   VARCHAR2  := FND_API.G_TRUE,
   p_sys_sec_key  IN   iby_security_pkg.DES3_KEY_TYPE
  )
  IS
    l_expiry_date    DATE;
    l_expired_flag   VARCHAR2(1);

    syskey_checked VARCHAR2(1) := 'N';
    cnt            NUMBER := 0;

    l_api_name       CONSTANT VARCHAR2(30)   := 'Mark_Expired_Cards';
    l_dbg_mod        VARCHAR2(100)  := 'IBY_CREDITCARD_PKG' || '.' ||
                                                     l_api_name;

    CURSOR c_card
    IS
      SELECT instrid, expirydate, expiry_sec_segment_id
      FROM iby_creditcard
      WHERE (NVL(expired_flag,'N') <> 'Y');
  BEGIN
    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
    IF (c_card%ISOPEN) THEN CLOSE c_card; END IF;
    --check_key(p_sys_sec_key);

    FOR c_card_rec IN c_card LOOP
      IF(c_card_rec.expiry_sec_segment_id IS NOT NULL) THEN
         -- Verify the syskey only if there is atleast one
	 -- encrypted record.
	 -- Also we require the syskey to be checked only once
         IF(syskey_checked = 'N') THEN
	   iby_debug_pub.add('At least one encrypted record. Verifying syskey..',
	                                iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
	   check_key(p_sys_sec_key);
           syskey_checked := 'Y';
	 END IF;

	 l_expiry_date := IBY_SECURITY_PKG.decrypt_date_field
                              (c_card_rec.expiry_sec_segment_id,
                               p_sys_sec_key
                              );
     ELSE
         l_expiry_date := c_card_rec.expirydate;
     END IF;

     -- expirydate could be null for some records. Lets keep the
     -- expired_flag as NULL in such cases.
     IF(l_expiry_date IS NULL) THEN
        l_expired_flag := NULL;
     ELSE
       IF (TRUNC(l_expiry_date,'DD') < TRUNC(SYSDATE,'DD')) THEN
         l_expired_flag := 'Y';
       ELSE
         l_expired_flag := 'N';
       END IF;
     END IF;

     UPDATE iby_creditcard
     SET expired_flag = l_expired_flag
     WHERE (instrid = c_card_rec.instrid);

     -- This count variable is only for logging purposes
     cnt := cnt + 1;

    END LOOP;
    iby_debug_pub.add('No. of records updated = '||cnt,
	                                iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;

    iby_debug_pub.add('Exit',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

  END Mark_Expired_Cards;

  PROCEDURE Upgrade_Encrypted_Instruments
  (p_commit       IN   VARCHAR2  := FND_API.G_TRUE,
   p_sys_sec_key  IN   iby_security_pkg.DES3_KEY_TYPE
  )
  IS
    l_api_name       CONSTANT VARCHAR2(30)   := 'Upgrade_Encrypted_Instruments';
    l_dbg_mod        VARCHAR2(100)  := 'IBY_CREDITCARD_PKG' || '.' ||
                                                     l_api_name;

    l_exp_segment_id     NUMBER;
    l_expired_flag       VARCHAR2(1);

    l_chname_segment_id  NUMBER;
    l_masked_chname      VARCHAR2(100);
    l_chname_mask_setting    iby_creditcard.chname_mask_setting%TYPE;
    l_chname_unmask_len      iby_creditcard.chname_unmask_length%TYPE;

    no_cc    NUMBER;

    CURSOR c_card
    IS
      SELECT instrid, expirydate, expiry_sec_segment_id,
             chname , chname_sec_segment_id
      FROM iby_creditcard
      WHERE (NVL(encrypted,'N') = 'Y')
        AND ((expirydate IS NOT NULL)
	      OR
	     ((chname IS NOT NULL) AND (chname_sec_segment_id IS NULL)));
  BEGIN
    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

    --No point in running this program when the system security setup doesn't allow
    -- this.
    IF(Other_CC_Attribs_Encrypted = 'N') THEN
      iby_debug_pub.add('The system security options do not allow data to be upgraded. Aborting..'
                ,iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
      RETURN;
    END IF;
    IF (c_card%ISOPEN) THEN CLOSE c_card; END IF;
    check_key(p_sys_sec_key);
    no_cc := 0;
    FOR c_card_rec IN c_card LOOP
      IF(c_card_rec.expirydate IS NOT NULL) THEN
        l_exp_segment_id := IBY_SECURITY_PKG.encrypt_date_field(c_card_rec.expirydate,
                                                     p_sys_sec_key,
                                                     null,
                                                     'N'
                                                     );
        IF (TRUNC(c_card_rec.expirydate,'DD') < TRUNC(SYSDATE,'DD')) THEN
         l_expired_flag := 'Y';
        ELSE
         l_expired_flag := 'N';
        END IF;
      END IF;

      IF((c_card_rec.chname IS NOT NULL) AND (c_card_rec.chname_sec_segment_id IS NULL)) THEN
        encrypt_chname
         (p_sys_sec_key,
          c_card_rec.chname,
          null,
          l_chname_segment_id,
          l_masked_chname,
          l_chname_mask_setting,
          l_chname_unmask_len
         );

      END IF;

      UPDATE iby_creditcard
        SET
	   encrypted = 'A',
     	   chname = nvl(l_masked_chname, chname),
	   chname_sec_segment_id = l_chname_segment_id,
	   chname_mask_setting   = l_chname_mask_setting,
	   chname_unmask_length  = l_chname_unmask_len,
	   expirydate = null,
	   expiry_sec_segment_id = l_exp_segment_id,
	   expired_flag = l_expired_flag,
	   object_version_number = object_version_number + 1,
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
      WHERE (instrid = c_card_rec.instrid);
      no_cc := no_cc + 1;
      -- flush the variables before iterating into the next record
      l_masked_chname := null;
      l_chname_segment_id := null;
      l_chname_mask_setting := null;
      l_chname_unmask_len := null;
      l_exp_segment_id := null;
      l_expired_flag := null;

     END LOOP;
     iby_debug_pub.add('No. of records updated = '|| no_cc,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
     iby_debug_pub.add('Exit',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
  END Upgrade_Encrypted_Instruments;


  PROCEDURE Check_CC_Expiry
  (p_instrid      IN   IBY_CREDITCARD.instrid%TYPE,
   p_input_date   IN DATE,
   p_sys_sec_key  IN   iby_security_pkg.DES3_KEY_TYPE,
   x_expired      OUT NOCOPY VARCHAR2
  )
  IS
   l_exp_sec_segment_id NUMBER;
   l_expiry_date        DATE;
  BEGIN
    SELECT expirydate, expiry_sec_segment_id
    INTO l_expiry_date, l_exp_sec_segment_id
    FROM iby_creditcard
    WHERE instrid = p_instrid;

    IF ((l_expiry_date IS NULL) AND (l_exp_sec_segment_id IS NULL)) THEN
       RETURN;
    END IF;

    IF (l_exp_sec_segment_id IS NOT NULL) THEN
       check_key(p_sys_sec_key);
       l_expiry_date := IBY_SECURITY_PKG.decrypt_date_field
                              (l_exp_sec_segment_id,
                               p_sys_sec_key
                              );
    END IF;

    IF (TRUNC(l_expiry_date,'DD') < TRUNC(p_input_date,'DD')) THEN
         x_expired := 'Y';
    ELSE
         x_expired := 'N';
    END IF;

  END Check_CC_Expiry;

  PROCEDURE Upgrade_Risky_Instruments
  (
    p_commit       IN   VARCHAR2
  )
  IS

    lx_cc_number iby_creditcard.ccnumber%TYPE;
    lx_return_status VARCHAR2(1);
    lx_msg_count     NUMBER;
    lx_msg_data      VARCHAR2(200);

    --variables to store the creditcard number hash values
    l_cc_hash1  iby_irf_risky_instr.cc_number_hash1%TYPE;
    l_cc_hash2  iby_irf_risky_instr.cc_number_hash2%TYPE;

    --variables to store the account number hash values
    l_acct_no_hash1  iby_irf_risky_instr.acct_number_hash1%TYPE;
    l_acct_no_hash2  iby_irf_risky_instr.acct_number_hash2%TYPE;

    --Variables to store the number of cerditcard numbers
    --or account numbers that are updated
    no_cc    NUMBER;
    no_acct  NUMBER;

    -- Cursor will fetch all the records from IBY_IRF_RISKY_INSTR
    -- and lock them for UPDATE

    CURSOR get_risky_instruments IS
    SELECT payeeid, instrtype,
           account_no, creditcard_no,
           cc_number_hash1, cc_number_hash2,
           acct_number_hash1, acct_number_hash2,
           object_version_number, last_update_date
    FROM iby_irf_risky_instr
    FOR UPDATE;

    l_dbg_mod       VARCHAR2(100) := 'iby.plsql.IBY_CREDITCARD_PKG' || '.' || 'Upgrade_Risky_Instruments';

  BEGIN
    fnd_file.put_line(fnd_file.log,l_dbg_mod||': Enter..');
    no_cc := 0;
    no_acct := 0;
    --Get each risky instrument
    FOR risky_instr_rec IN get_risky_instruments
    LOOP
      --After the PABP fixes, the creditcard column is
      --supposed to be NULL. If this is not null, then
      --select this one for upgrade.
      --
      --NOTE: If later on, we decide to store a masked
      --card number in creditcard_no column, then the
      --script should be modified accordingly.
      IF (risky_instr_rec.creditcard_no IS NOT NULL)
      THEN
        IBY_CC_VALIDATE.StripCC
         (1.0, FND_API.G_FALSE, risky_instr_rec.creditcard_no,
          IBY_CC_VALIDATE.c_FillerChars, lx_return_status,
	  lx_msg_count, lx_msg_data, lx_cc_number
	 );
        -- Get hash values of the credit number
        l_cc_hash1 := iby_security_pkg.get_hash
                      (lx_cc_number,FND_API.G_FALSE);
        l_cc_hash2 := iby_security_pkg.get_hash
                      (lx_cc_number,FND_API.G_TRUE);

        UPDATE iby_irf_risky_instr
          SET creditcard_no = NULL,
  	      cc_number_hash1 = l_cc_hash1,
  	      cc_number_hash2 = l_cc_hash2,
	      object_version_number = risky_instr_rec.object_version_number + 1,
	      last_update_date = SYSDATE
	  WHERE payeeid = risky_instr_rec.payeeid
	    AND instrtype = 'CREDITCARD'
	    AND creditcard_no = risky_instr_rec.creditcard_no;
	  --update the counter by 1
	  no_cc := no_cc + 1;

      ELSIF (risky_instr_rec.account_no IS NOT NULL) THEN
        -- Get the hash values of the account number
        l_acct_no_hash1 := iby_security_pkg.get_hash
                           (risky_instr_rec.account_no,FND_API.G_FALSE);
        l_acct_no_hash2 := iby_security_pkg.get_hash
                           (risky_instr_rec.account_no,FND_API.G_TRUE);

        UPDATE iby_irf_risky_instr
          SET account_no = NULL,
	      acct_number_hash1 = l_acct_no_hash1,
	      acct_number_hash2 = l_acct_no_hash2,
	      object_version_number = risky_instr_rec.object_version_number + 1,
	      last_update_date = SYSDATE
	  WHERE payeeid = risky_instr_rec.payeeid
	  AND instrtype = 'BANKACCOUNT'
	  AND account_no = risky_instr_rec.account_no;
	  --update the counter by 1
	  no_acct := no_acct + 1;

      END IF;

    END LOOP;
  --  DBMS_OUTPUT.PUT_LINE('complete..: ');
  --  DBMS_OUTPUT.PUT_LINE('No. of cards updated: '|| no_cc);
  --  DBMS_OUTPUT.PUT_LINE('No. of accounts updated: '|| no_acct);
    fnd_file.put_line(fnd_file.log,l_dbg_mod||': No. of cards updated: '|| no_cc);
    fnd_file.put_line(fnd_file.log,l_dbg_mod||': No. of accounts updated: '|| no_acct);
    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
    fnd_file.put_line(fnd_file.log,l_dbg_mod||': Exit.');
  EXCEPTION
  WHEN others THEN
  --  DBMS_OUTPUT.PUT_LINE('SQLCODE is: ' || SQLCODE);
  --  DBMS_OUTPUT.PUT_LINE('SQLERRM is: ' || sqlerrm);
    ROLLBACK;
    fnd_file.put_line(fnd_file.log,l_dbg_mod||': Exception thrown: '|| SQLERRM);
  END Upgrade_Risky_Instruments;

  PROCEDURE Purge_Sensitive_Data
  (x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_num_workers IN NUMBER
  )
  IS
   l_dbg_mod       VARCHAR2(100) := 'iby.plsql.IBY_CREDITCARD_PKG' || '.' || 'Purge_Sensitive_Data';
   req_id  VARCHAR2(30);
   plsql_block VARCHAR2(500);
   x_req_id      NUMBER;
   l_call_status BOOLEAN;
   l_phase VARCHAR2(30);
   l_status VARCHAR2(30);
   l_dev_phase VARCHAR2(30);
   l_dev_status VARCHAR2(30);
   l_message VARCHAR2(500);
  BEGIN
    fnd_file.put_line(fnd_file.log,l_dbg_mod||': Enter.');
    req_id := fnd_global.CONC_REQUEST_ID;
    BEGIN
      fnd_file.put_line(fnd_file.log,l_dbg_mod||': Invoking APXCCUPGMGR. Timestamp: '|| TO_CHAR(systimestamp,'SSSSS.FF'));
      BEGIN
        x_req_id := fnd_request.submit_request(
		                                        APPLICATION=>'SQLAP',
		                                        PROGRAM=>'APXCCUPGMGR',
		                                        DESCRIPTION=>null,
		                                        SUB_REQUEST=>FALSE,
		                                        ARGUMENT1=>x_batch_size,
		                                        ARGUMENT2=>x_num_workers,
		                                        ARGUMENT3=>req_id);

        -- OIE has the requirement that the 2nd CP(APXCCUPGMGR) be triggered only after
	-- the 1st CP (APXCCUPGMGR) completes.
	-- Need to commit before waiting for the CP completion
        COMMIT;
      END;
      fnd_file.put_line(fnd_file.log,l_dbg_mod||': Request_id of the APXCCUPGMGR instance = '||x_req_id||'. Timestamp: '|| TO_CHAR(systimestamp,'SSSSS.FF'));
      l_call_status := fnd_concurrent.wait_for_request(x_req_id,60,0,l_phase,l_status,l_dev_phase,l_dev_status,l_message);

      fnd_file.put_line(fnd_file.log,l_dbg_mod||': Invoking APXCCTRXUPG. Timestamp: '|| TO_CHAR(systimestamp,'SSSSS.FF'));
      BEGIN
        x_req_id := fnd_request.submit_request(
		                                        APPLICATION=>'SQLAP',
		                                        PROGRAM=>'APXCCTRXUPGMGR',
		                                        DESCRIPTION=>null,
		                                        SUB_REQUEST=>FALSE,
		                                        ARGUMENT1=>x_batch_size,
		                                        ARGUMENT2=>x_num_workers,
		                                        ARGUMENT3=>req_id);
      END;
      fnd_file.put_line(fnd_file.log,l_dbg_mod||': Request_id of the APXCCTRXUPGMGR instance = '||x_req_id||'. Timestamp: '|| TO_CHAR(systimestamp,'SSSSS.FF'));

    EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,l_dbg_mod||': Exception thrown during OIE module execution! '|| SQLERRM);
    END;

    -- Invoke the AP Upgrade routine
    -- Signature of the AP routine is as follows
    -- AP_CARDS_PKG.UPG_HISTORICAL_TRANSACTIONS
    --        (errbuf    =>  x_errbuf,
    --         retcode   =>  x_retcode
    --        );
    BEGIN
      fnd_file.put_line(fnd_file.log,l_dbg_mod||': Invoking AP_CARDS_PKG.UPG_HISTORICAL_TRANSACTIONS. Timestamp: '||TO_CHAR(systimestamp,'SSSSS.FF'));
      plsql_block := 'CALL AP_CARDS_PKG.UPG_HISTORICAL_TRANSACTIONS(:1,:2)';
      EXECUTE IMMEDIATE plsql_block USING OUT x_errbuf, OUT x_retcode;
      fnd_file.put_line(fnd_file.log,l_dbg_mod||': Return status frm AP_CARDS_PKG.UPG_HISTORICAL_TRANSACTIONS: '||x_retcode||'. Timestamp: '||TO_CHAR(systimestamp,'SSSSS.FF'));
      EXCEPTION
        WHEN OTHERS THEN
         fnd_file.put_line(fnd_file.log,l_dbg_mod||': Exception thrown during AP_CARDS_PKG.UPG_HISTORICAL_TRANSACTIONS invocation. '|| SQLERRM);
    END;

    -- Upgrade the data in IBY_IRF_RISKY_INSTR
    fnd_file.put_line(fnd_file.log,l_dbg_mod||': Upgrading Data in IBY_IRF_RISKY_INSTR. Timestamp: '||TO_CHAR(systimestamp,'SSSSS.FF'));
    Upgrade_Risky_Instruments('T');
    fnd_file.put_line(fnd_file.log,l_dbg_mod||': Finshed Upgrading Data in IBY_IRF_RISKY_INSTR. Timestamp: '||TO_CHAR(systimestamp,'SSSSS.FF'));
    fnd_file.put_line(fnd_file.log,l_dbg_mod||': Exit.');


  END Purge_Sensitive_Data;

END iby_creditcard_pkg;

/

  GRANT EXECUTE ON "APPS"."IBY_CREDITCARD_PKG" TO "EM_OAM_MONITOR_ROLE";
