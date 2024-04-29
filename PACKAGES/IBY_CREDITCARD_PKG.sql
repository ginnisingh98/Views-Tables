--------------------------------------------------------
--  DDL for Package IBY_CREDITCARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_CREDITCARD_PKG" AUTHID CURRENT_USER AS
/*$Header: ibyccs.pls 120.14.12010000.17 2009/12/14 08:13:27 lmallick ship $*/

  -- Constant for credit card types
  C_INSTRTYPE_CCARD CONSTANT VARCHAR2(20) := 'CREDITCARD';

  -- Constant for purchase card types
  C_INSTRTYPE_PCARD CONSTANT VARCHAR2(20) := 'PURCHASECARD';

  -- Number masking options
  G_MASK_CHARACTER CONSTANT VARCHAR2(1) := 'X';
  G_DEF_UNMASK_LENGTH CONSTANT NUMBER := 4;


  G_LKUP_PCARD_TYPE CONSTANT VARCHAR2(30) := 'IBY_PURCHASECARD_SUBTYPE';

  -- Card validation errors
  G_RC_INVALID_CCNUMBER CONSTANT VARCHAR2(30) := 'INVALID_CARD_NUMBER';
  G_RC_INVALID_CCEXPIRY CONSTANT VARCHAR2(30) := 'INVALID_CARD_EXPIRY';
  G_RC_INVALID_INSTR_TYPE CONSTANT VARCHAR2(30) := 'INVALID_INSTRUMENT_TYPE';
  G_RC_INVALID_PCARD_TYPE CONSTANT VARCHAR2(30) := 'INVALID_PCARD_TYPE';
  G_RC_INVALID_CARD_ISSUER CONSTANT VARCHAR2(30) := 'INVALID_CARD_ISSUER';
  G_RC_INVALID_CARD_ID CONSTANT VARCHAR2(30) := 'INVALID_INSTRUMENT';
  G_RC_INVALID_PARTY CONSTANT VARCHAR2(30) := 'INVALID_PARTY';
  G_RC_INVALID_ADDRESS CONSTANT VARCHAR2(30) := 'INVALID_ADDRESS';

  G_LKUP_INSTR_TYPE_CC CONSTANT VARCHAR2(30) := 'CREDITCARD';
  G_LKUP_INSTR_TYPE_DC CONSTANT VARCHAR2(30) := 'DEBITCARD';
  G_LKUP_INSTR_TYPE_PC CONSTANT VARCHAR2(30) := 'PAYMENTCARD';

  -- Pad character used when encrypting credit card numbers
  G_CCNUM_PAD CONSTANT VARCHAR2(1) := ' ';

  -- Credit card billing site usage
  G_CC_BILLING_SITE_USE CONSTANT VARCHAR2(30) := 'CC_BILLING';

  -- Address Type Flags
  G_PARTY_SITE_ID CONSTANT VARCHAR2(1) := 'S';
  G_PARTY_SITE_USE_ID CONSTANT VARCHAR2(1) := 'U';



  --
  -- USE
  --   Gets credit card mask settings
  --
  PROCEDURE Get_Mask_Settings
  (x_mask_setting OUT NOCOPY iby_sys_security_options.credit_card_mask_setting%TYPE,
   x_unmask_len OUT NOCOPY iby_sys_security_options.credit_card_unmask_len%TYPE
  );

  --
  -- USE
  --   Generates a masked credit card number based upon system mask
  --   settings
  --
  FUNCTION Mask_Card_Number(p_cc_number IN iby_creditcard.ccnumber%TYPE)
  RETURN iby_creditcard.masked_cc_number%TYPE;

  FUNCTION Mask_Card_Number
  (p_cc_number       IN   iby_creditcard.ccnumber%TYPE,
   p_mask_option     IN   iby_creditcard.card_mask_setting%TYPE,
   p_unmask_len      IN   iby_creditcard.card_unmask_length%TYPE
  )
  RETURN iby_creditcard.masked_cc_number%TYPE;

  --
  -- USE: Gets the credit card encryption mode setting
  --
  FUNCTION Get_CC_Encrypt_Mode
  RETURN iby_sys_security_options.cc_encryption_mode%TYPE;

  --
  -- USE: Returns Y or N if the supplemental cardholder data
  --      e.g., chname and expirydate, are encrypted.
  --
  FUNCTION Other_CC_Attribs_Encrypted
  RETURN VARCHAR2;

  --
  -- USE: returns the site_use_id for the site. Creates
  --      one if one doesn't exist.
  --
  FUNCTION Get_Billing_Site
  (p_party_site_id IN hz_party_sites.party_site_id%TYPE,
   p_party_id      IN hz_parties.party_id%TYPE
  )
  RETURN hz_party_site_uses.party_site_use_id%TYPE;


  PROCEDURE encrypt_chname
  (p_sec_key IN iby_security_pkg.DES3_KEY_TYPE,
   p_chname  IN iby_creditcard.chname%TYPE,
   p_segment_id IN NUMBER,
   x_segment_id OUT NOCOPY NUMBER,
   x_masked_chname OUT NOCOPY iby_creditcard.chname%TYPE,
   x_mask_setting OUT NOCOPY iby_sys_security_options.credit_card_mask_setting%TYPE,
   x_unmask_len   OUT NOCOPY iby_sys_security_options.credit_card_unmask_len%TYPE
   );

  FUNCTION decrypt_chname
  (p_sec_key IN iby_security_pkg.DES3_KEY_TYPE,
   p_instrid  IN iby_creditcard.instrid%TYPE
  ) RETURN iby_creditcard.chname%TYPE;

  PROCEDURE Create_Card
  (p_commit           IN   VARCHAR2,
   p_owner_id         IN   iby_creditcard.card_owner_id%TYPE,
   p_holder_name      IN   iby_creditcard.chname%TYPE,
   p_billing_address_id IN iby_creditcard.addressid%TYPE,
   p_address_type     IN   VARCHAR2 := G_PARTY_SITE_ID,
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
  );

  PROCEDURE Update_Card
  (p_commit           IN   VARCHAR2,
   p_instr_id         IN   iby_creditcard.instrid%TYPE,
   p_owner_id         IN   iby_creditcard.card_owner_id%TYPE,
   p_holder_name      IN   iby_creditcard.chname%TYPE,
   p_billing_address_id IN iby_creditcard.addressid%TYPE,
   p_address_type     IN   VARCHAR2 := G_PARTY_SITE_ID,
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
  );


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
  );

  --
  -- USE: Unciphers a the credit card number of a stored credit card
  --      instrument
  -- ARGS: i_instrid => the instrument id
  --       i_sys_sec_key => the system security key
  --
  FUNCTION uncipher_ccnumber
  (p_instrid        IN iby_creditcard.instrid%TYPE,
   p_sys_sec_key    IN iby_security_pkg.DES3_KEY_TYPE
  )
  RETURN iby_creditcard.ccnumber%TYPE;

  --
  --
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
  RETURN iby_creditcard.ccnumber%TYPE;

  --
  -- USE: Wrapper of the above function for the UI.
  -- In the UI the SQL is executed by the framework.
  -- We can not catch the exception thrown from the function call.
  -- It will cause unacceptable error in the UI.
  -- In case of exceptions this wrapper function will
  -- simply swallow it and return null.
  -- The UI will display empty instrument number
  -- for this case.
  -- ARGS: i_instrid => the instrument id
  --       i_sys_sec_key => the system security key
  --
  FUNCTION uncipher_ccnumber_ui_wrp
  (i_instrid     IN iby_creditcard.instrid%TYPE,
   i_sys_sec_key IN iby_security_pkg.DES3_KEY_TYPE)
  RETURN iby_creditcard.ccnumber%TYPE;

  --
  -- USE: Un-encrypts all registered credit card instruments, storing
  --      data in obfuscated form
  --
  -- ARGS:  p_commit => whether to commit the changes
  --        p_sys_key => system security key; used to decrypt instruments
  --
  PROCEDURE Decrypt_Instruments
  (p_commit      IN     VARCHAR2 := FND_API.G_TRUE,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  );

  --
  -- USE: Encrypts all registered credit cards
  --
  -- ARGS:  p_commit => whether to commit the changes
  --        p_sys_key => system security key; used to encrypt instruments
  --
  PROCEDURE Encrypt_Instruments
  (p_commit      IN     VARCHAR2 := FND_API.G_TRUE,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  );

  --
  -- USE: Updates instrument masks according to new setting
  --
  -- ARGS:  p_commit => whether to commit the changes
  --        p_sys_key => system security key; used to encrypt instruments
  --
  PROCEDURE Remask_Instruments
  (p_commit      IN     VARCHAR2 := FND_API.G_TRUE,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  );

  -- USE: Compresses a card number into the minimum clear text
  --      representation
  --
  PROCEDURE Compress_CC_Number
  (p_card_number IN iby_creditcard.ccnumber%TYPE,
   p_prefix      IN iby_cc_issuer_ranges.card_number_prefix%TYPE,
   p_digit_check IN iby_creditcard_issuers_b.digit_check_flag%TYPE,
   p_mask_setting IN iby_sys_security_options.credit_card_mask_setting%TYPE,
   p_unmask_len  IN iby_sys_security_options.credit_card_unmask_len%TYPE,
   x_compress_num OUT NOCOPY iby_creditcard.ccnumber%TYPE,
   x_unmask_digits OUT NOCOPY iby_creditcard.masked_cc_number%TYPE
  );

  -- USE: Uncompresses the credit card number based upon its known digits
  --      (range prefix, check digits, unmasked digits) and the clear text
  --      of its comprssed digits
  -- ARGS: p_card_number => clear text of the compressed card digits
  --       p_card_length => actual length of the credit card (uncompressed)
  --       p_prefix => issuer range prefix
  --       p_digit_check => 'Y' if the card has a check digit
  --       p_mask_setting => masking option of the card number
  --       p_unmask_len => number of digits exposed in the mask
  --       p_unmask_digits => unmasked digits
  --
  FUNCTION Uncompress_CC_Number
  (p_card_number IN iby_creditcard.ccnumber%TYPE,
   p_card_length IN iby_creditcard.cc_number_length%TYPE,
   p_prefix      IN iby_cc_issuer_ranges.card_number_prefix%TYPE,
   p_digit_check IN iby_creditcard_issuers_b.digit_check_flag%TYPE,
   p_mask_setting IN iby_sys_security_options.credit_card_mask_setting%TYPE,
   p_unmask_len  IN iby_sys_security_options.credit_card_unmask_len%TYPE,
   p_unmask_digits IN iby_creditcard.masked_cc_number%TYPE
  )
  RETURN iby_creditcard.ccnumber%TYPE;

  --
  -- USE: Gets the number of digits in a compressed credit card number
  --
  FUNCTION Get_Compressed_Len
  (p_card_length IN iby_creditcard.cc_number_length%TYPE,
   p_prefix      IN iby_cc_issuer_ranges.card_number_prefix%TYPE,
   p_digit_check IN iby_creditcard_issuers_b.digit_check_flag%TYPE,
   p_mask_setting IN iby_sys_security_options.credit_card_mask_setting%TYPE,
   p_unmask_len  IN iby_sys_security_options.credit_card_unmask_len%TYPE
  )
  RETURN NUMBER;

  --
  -- USE: Encrypts the other sensitive card info and returns the
  --      corresponding security segment_IDs
  --
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
  );

  --
  -- USE: Updates the EXPIRED_FLAG for all the active credit cards
  --
  --
  PROCEDURE Mark_Expired_Cards
  (p_commit       IN   VARCHAR2  := FND_API.G_TRUE,
   p_sys_sec_key  IN   iby_security_pkg.DES3_KEY_TYPE
  );

  --
  -- USE: Upgrades the previously encrypted credit card records, by
  --      encrypting the corresponding chname and expirydate
  --
  --
  PROCEDURE Upgrade_Encrypted_Instruments
  (p_commit       IN   VARCHAR2  := FND_API.G_TRUE,
   p_sys_sec_key  IN   iby_security_pkg.DES3_KEY_TYPE
  );


  PROCEDURE Check_CC_Expiry
  (p_instrid      IN   IBY_CREDITCARD.instrid%TYPE,
   p_input_date   IN DATE,
   p_sys_sec_key  IN   iby_security_pkg.DES3_KEY_TYPE,
   x_expired      OUT NOCOPY VARCHAR2
  );

  PROCEDURE Upgrade_Risky_Instruments
  (
    p_commit       IN   VARCHAR2
  );

  --
  -- Name: Purge_Sensitive_Data
  -- Notes: This is the executable for the PA-DSS Purge Program(CP)
  --        'Purge Redundant PA-DSS Incidental Data'.
  --        Purges the data from across products to make
  --        the application compliant with PADSS.
  --
  PROCEDURE Purge_Sensitive_Data
  (x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_num_workers IN NUMBER
  );

END iby_creditcard_pkg;

/

  GRANT EXECUTE ON "APPS"."IBY_CREDITCARD_PKG" TO "EM_OAM_MONITOR_ROLE";
