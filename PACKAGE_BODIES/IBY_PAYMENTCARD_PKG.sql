--------------------------------------------------------
--  DDL for Package Body IBY_PAYMENTCARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PAYMENTCARD_PKG" AS
/*$Header: ibypmtcardb.pls 120.1.12010000.4 2009/01/20 13:30:44 lmallick noship $*/

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_PAYMENTCARD_PKG';

  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_PAYMENTCARD_PKG';


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
        AND (u.site_use_type = G_PC_BILLING_SITE_USE)
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
        l_site_use_rec.site_use_type := G_PC_BILLING_SITE_USE;
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
  (p_card_number     IN   iby_paymentcard.card_number%TYPE,
   p_mask_option     IN   iby_paymentcard.card_mask_setting%TYPE,
   p_unmask_len      IN   iby_paymentcard.card_unmask_length%TYPE
  )
  RETURN iby_paymentcard.masked_card_number%TYPE
  IS
  BEGIN
    RETURN iby_security_pkg.Mask_Data
           (p_card_number,p_mask_option,p_unmask_len,G_MASK_CHARACTER);
  END Mask_Card_Number;

  --
  -- Return: The masked card number, usable for display purposes
  --
  PROCEDURE Mask_Card_Number
  (p_card_number    IN iby_paymentcard.card_number%TYPE,
   x_masked_number OUT NOCOPY iby_paymentcard.masked_card_number%TYPE,
   x_mask_setting  OUT NOCOPY iby_sys_security_options.credit_card_mask_setting%TYPE,
   x_unmask_len    OUT NOCOPY iby_sys_security_options.credit_card_unmask_len%TYPE
  )
  IS
  BEGIN
    Get_Mask_Settings(x_mask_setting,x_unmask_len);
    x_masked_number :=
      Mask_Card_Number(p_card_number,x_mask_setting,x_unmask_len);
  END Mask_Card_Number;

  FUNCTION Mask_Card_Number(p_card_number IN iby_paymentcard.card_number%TYPE)
  RETURN iby_paymentcard.masked_card_number%TYPE
  IS
    lx_mask_option  iby_paymentcard.card_mask_setting%TYPE;
    lx_mask_number  iby_paymentcard.masked_card_number%TYPE;
    lx_unmask_len   iby_sys_security_options.credit_card_unmask_len%TYPE;
  BEGIN
    Mask_Card_Number(p_card_number,lx_mask_number,lx_mask_option,lx_unmask_len);
    RETURN lx_mask_number;
  END Mask_Card_Number;

    -- Validates the billing address passed for a payment card instrument
  FUNCTION Validate_Card_Billing
  ( p_is_update IN VARCHAR2, p_paymentcard IN PaymentCard_rec_type )
  RETURN BOOLEAN
  IS

    lx_return_status  VARCHAR2(1);
    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(3000);
    lx_result         IBY_FNDCPT_COMMON_PUB.Result_rec_type;

    l_addressid       iby_paymentcard.addressid%TYPE;
    l_billing_zip     iby_paymentcard.billing_addr_postal_code%TYPE;
    l_billing_terr    iby_paymentcard.bill_addr_territory_code%TYPE;

  BEGIN

    IF (p_paymentcard.Info_Only_Flag = 'Y') THEN
      RETURN TRUE;
    END IF;

    l_addressid := p_paymentcard.Billing_Address_Id;
    l_billing_zip := p_paymentcard.Billing_Postal_Code;
    l_billing_terr := p_paymentcard.Billing_Address_Territory;

    IF FND_API.to_Boolean(p_is_update) THEN
      IF (l_addressid = FND_API.G_MISS_NUM) THEN
        l_addressid := NULL;
      ELSIF (l_addressid IS NULL) THEN
        l_addressid := FND_API.G_MISS_NUM;
      END IF;
      IF (l_billing_zip = FND_API.G_MISS_CHAR) THEN
        l_billing_zip := NULL;
      ELSIF (l_billing_zip IS NULL) THEN
        l_billing_zip := FND_API.G_MISS_CHAR;
      END IF;
      IF (l_billing_terr = FND_API.G_MISS_CHAR) THEN
        l_billing_terr := NULL;
      ELSIF (l_billing_terr IS NULL) THEN
        l_billing_terr := FND_API.G_MISS_CHAR;
      END IF;
    END IF;

    IF ( (NOT (l_addressid IS NULL OR l_addressid = FND_API.G_MISS_NUM))
        AND
         (NOT (l_billing_zip IS NULL OR l_billing_zip = FND_API.G_MISS_CHAR))
       )
    THEN
      RETURN FALSE;
    END IF;

    IF ( (NOT (l_billing_zip IS NULL OR l_billing_zip = FND_API.G_MISS_CHAR))
        AND (l_billing_terr IS NULL OR l_billing_terr = FND_API.G_MISS_CHAR)
       )
    THEN
      RETURN FALSE;
    ELSIF ( (NOT (l_billing_terr IS NULL OR l_billing_terr = FND_API.G_MISS_CHAR))

           AND (l_billing_zip IS NULL OR l_billing_zip = FND_API.G_MISS_CHAR)
          )
    THEN
      RETURN FALSE;
    END IF;

    RETURN TRUE;
  END Validate_Card_Billing;



  PROCEDURE Create_Card
  (p_commit           IN   VARCHAR2,
   p_owner_id         IN   iby_paymentcard.card_owner_id%TYPE,
   p_holder_name      IN   iby_paymentcard.chname%TYPE,
   p_billing_address_id IN iby_paymentcard.addressid%TYPE,
   p_address_type     IN   VARCHAR2,
   p_billing_zip      IN   iby_paymentcard.billing_addr_postal_code%TYPE,
   p_billing_country  IN   iby_paymentcard.bill_addr_territory_code%TYPE,
   p_card_number      IN   iby_paymentcard.card_number%TYPE,
   p_expiry_date      IN   iby_paymentcard.expirydate%TYPE,
   p_instr_type       IN   iby_paymentcard.instrument_type%TYPE,
   p_issuer           IN   iby_paymentcard.card_issuer_code%TYPE,
   p_fi_name          IN   iby_paymentcard.finame%TYPE,
   p_single_use       IN   iby_paymentcard.single_use_flag%TYPE,
   p_info_only        IN   iby_paymentcard.information_only_flag%TYPE,
   p_purpose          IN   iby_paymentcard.card_purpose%TYPE,
   p_desc             IN   iby_paymentcard.description%TYPE,
   p_active_flag      IN   iby_paymentcard.active_flag%TYPE,
   p_inactive_date    IN   iby_paymentcard.inactive_date%TYPE,
  	   p_attribute_category IN iby_paymentcard.attribute_category%TYPE,
	   p_attribute1	IN 	iby_paymentcard.attribute1%TYPE,
	   p_attribute2	IN 	iby_paymentcard.attribute2%TYPE,
	   p_attribute3	IN 	iby_paymentcard.attribute3%TYPE,
	   p_attribute4	IN 	iby_paymentcard.attribute4%TYPE,
	   p_attribute5	IN 	iby_paymentcard.attribute5%TYPE,
	   p_attribute6	IN 	iby_paymentcard.attribute6%TYPE,
	   p_attribute7	IN 	iby_paymentcard.attribute7%TYPE,
	   p_attribute8	IN 	iby_paymentcard.attribute8%TYPE,
	   p_attribute9	IN 	iby_paymentcard.attribute9%TYPE,
	   p_attribute10	IN 	iby_paymentcard.attribute10%TYPE,
	   p_attribute11	IN 	iby_paymentcard.attribute11%TYPE,
	   p_attribute12	IN 	iby_paymentcard.attribute12%TYPE,
	   p_attribute13	IN 	iby_paymentcard.attribute13%TYPE,
	   p_attribute14	IN 	iby_paymentcard.attribute14%TYPE,
	   p_attribute15	IN 	iby_paymentcard.attribute15%TYPE,
   x_result_code      OUT  NOCOPY VARCHAR2,
   x_instr_id         OUT  NOCOPY iby_paymentcard.instrid%TYPE
  )
  IS

    lx_return_status    VARCHAR2(1);
    lx_msg_count        NUMBER;
    lx_msg_data         VARCHAR2(200);

    l_card_len          iby_paymentcard.card_number_length%TYPE;

    lx_card_number        iby_paymentcard.card_number%TYPE;
    lx_unmasked_digits  iby_paymentcard.card_number%TYPE;

    lx_masked_number    iby_paymentcard.masked_card_number%TYPE;
    lx_mask_option      iby_paymentcard.card_mask_setting%TYPE;
    lx_unmask_len       iby_paymentcard.card_unmask_length%TYPE;


    l_expiry_date       iby_paymentcard.expirydate%TYPE;
    l_billing_site      hz_party_site_uses.party_site_use_id%TYPE;


    CURSOR c_card
    (ci_owner_id       IN hz_parties.party_id%TYPE,
     ci_card_number    IN iby_paymentcard.card_number%TYPE
    )
    IS
      SELECT instrid
      FROM iby_paymentcard
      WHERE (card_number = ci_card_number)
        AND ( (NVL(card_owner_id,ci_owner_id) = NVL(ci_owner_id,card_owner_id))
              OR (card_owner_id IS NULL AND ci_owner_id IS NULL)
            )
        AND (NVL(single_use_flag,'N')='N');
  BEGIN

    IF (c_card%ISOPEN) THEN CLOSE c_card; END IF;

    IF (p_card_number IS NULL ) THEN
      x_result_code := G_RC_INVALID_CARD_NUMBER;
      RETURN;
    END IF;

    -- expiration date may be null
    IF (NOT p_expiry_date IS NULL) THEN
      l_expiry_date := LAST_DAY(p_expiry_date);
      IF (TRUNC(l_expiry_date,'DD') < TRUNC(SYSDATE,'DD')) THEN
        x_result_code := G_RC_INVALID_CARD_EXPIRY;
        RETURN;
      END IF;
    END IF;

    IF ( (NVL(p_instr_type,' ') <> G_LKUP_INSTR_TYPE_PC))
    THEN
      x_result_code := G_RC_INVALID_INSTR_TYPE;
      RETURN;
    END IF;

    -- Assign p_card_number directly to lx_card_number since there is
    -- validation done on Payment cards. These could be potentially anything
    lx_card_number := p_card_number;
    Mask_Card_Number(lx_card_number,lx_masked_number,lx_mask_option,lx_unmask_len);

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

    IF (NOT p_owner_id IS NULL) THEN
      IF (NOT iby_utility_pvt.validate_party_id(p_owner_id)) THEN
        x_result_code := G_RC_INVALID_PARTY;
        RETURN;
      END IF;
    END IF;

    OPEN c_card(p_owner_id, p_card_number);
    FETCH c_card INTO x_instr_id;
    CLOSE c_card;

    IF (NOT x_instr_id IS NULL) THEN RETURN; END IF;

    SELECT iby_paymentcard_s.NEXTVAL INTO x_instr_id FROM DUAL;

    INSERT INTO iby_paymentcard
    (instrid, card_number, masked_card_number,
     card_mask_setting, card_unmask_length,
     expirydate, card_owner_id, chname,
     addressid, billing_addr_postal_code, bill_addr_territory_code,
     instrument_type, card_issuer_code, card_number_length,
     description, finame,
     single_use_flag, information_only_flag, card_purpose,
     active_flag, inactive_date,
     last_update_date, last_updated_by, creation_date,
     created_by, object_version_number,
     attribute_category,
     attribute1,attribute2, attribute3,attribute4,attribute5,
    attribute6,attribute7, attribute8,attribute9,attribute10,
    attribute11,attribute12, attribute13,attribute14,attribute15
    )
    VALUES
    (x_instr_id, p_card_number, lx_masked_number,
     lx_mask_option, lx_unmask_len,
     l_expiry_date, p_owner_id, p_holder_name,
     l_billing_site, p_billing_zip, p_billing_country,
     p_instr_type, C_ISSUER_COMCHECK, l_card_len,
     p_desc, p_fi_name,
     NVL(p_single_use,'N'), NVL(p_info_only,'N'), p_purpose,
     NVL(p_active_flag,'Y'), p_inactive_date,
     sysdate, fnd_global.user_id, sysdate,
     fnd_global.user_id, 1,
     p_attribute_category,
     p_attribute1,p_attribute2,p_attribute3,p_attribute4,p_attribute5,
    p_attribute6,p_attribute7,p_attribute8,p_attribute9,p_attribute10,
    p_attribute11,p_attribute12,p_attribute13,p_attribute14,p_attribute15
    );

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;
  END Create_Card;

  PROCEDURE Update_Card
  (p_commit           IN   VARCHAR2,
   p_instr_id         IN   iby_paymentcard.instrid%TYPE,
   p_owner_id         IN   iby_paymentcard.card_owner_id%TYPE,
   p_holder_name      IN   iby_paymentcard.chname%TYPE,
   p_billing_address_id IN iby_paymentcard.addressid%TYPE,
   p_address_type     IN   VARCHAR2 := G_PARTY_SITE_ID,
   p_billing_zip      IN   iby_paymentcard.billing_addr_postal_code%TYPE,
   p_billing_country  IN   iby_paymentcard.bill_addr_territory_code%TYPE,
   p_expiry_date      IN   iby_paymentcard.expirydate%TYPE,
   p_instr_type       IN   iby_paymentcard.instrument_type%TYPE,
   p_fi_name          IN   iby_paymentcard.finame%TYPE,
   p_single_use       IN   iby_paymentcard.single_use_flag%TYPE,
   p_info_only        IN   iby_paymentcard.information_only_flag%TYPE,
   p_purpose          IN   iby_paymentcard.card_purpose%TYPE,
   p_desc             IN   iby_paymentcard.description%TYPE,
   p_active_flag      IN   iby_paymentcard.active_flag%TYPE,
   p_inactive_date    IN   iby_paymentcard.inactive_date%TYPE,
   p_attribute_category IN iby_paymentcard.attribute_category%TYPE,
   p_attribute1	IN 	iby_paymentcard.attribute1%TYPE,
   p_attribute2	IN 	iby_paymentcard.attribute2%TYPE,
   p_attribute3	IN 	iby_paymentcard.attribute3%TYPE,
   p_attribute4	IN 	iby_paymentcard.attribute4%TYPE,
   p_attribute5	IN 	iby_paymentcard.attribute5%TYPE,
   p_attribute6	IN 	iby_paymentcard.attribute6%TYPE,
   p_attribute7	IN 	iby_paymentcard.attribute7%TYPE,
   p_attribute8	IN 	iby_paymentcard.attribute8%TYPE,
   p_attribute9	IN 	iby_paymentcard.attribute9%TYPE,
   p_attribute10	IN 	iby_paymentcard.attribute10%TYPE,
   p_attribute11	IN 	iby_paymentcard.attribute11%TYPE,
   p_attribute12	IN 	iby_paymentcard.attribute12%TYPE,
   p_attribute13	IN 	iby_paymentcard.attribute13%TYPE,
   p_attribute14	IN 	iby_paymentcard.attribute14%TYPE,
   p_attribute15	IN 	iby_paymentcard.attribute15%TYPE,
   x_result_code      OUT NOCOPY VARCHAR2
  )
  IS
    l_billing_site    NUMBER;
    l_expiry_date       iby_paymentcard.expirydate%TYPE;


    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(300);
    l_return_status VARCHAR2(1);

    l_sec_code      VARCHAR2(10);

    l_exp_date          DATE;

  BEGIN

    IF (NOT p_instr_type IS NULL) THEN
      IF (p_instr_type <> G_LKUP_INSTR_TYPE_PC)
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


    -- Bug 5479785 (Panaraya)
    -- Added check for expiry date on update
    -- expiration date may be null
    IF (NOT p_expiry_date IS NULL) THEN
      l_expiry_date := LAST_DAY(p_expiry_date);
      IF (TRUNC(l_expiry_date,'DD') < TRUNC(SYSDATE,'DD')) THEN
        x_result_code := G_RC_INVALID_CARD_EXPIRY;
        RETURN;
      END IF;
    END IF;

    UPDATE iby_paymentcard
    SET chname = DECODE(p_holder_name, FND_API.G_MISS_CHAR,NULL, NULL,chname, p_holder_name),

      card_owner_id = NVL(card_owner_id,p_owner_id),
      addressid = DECODE(l_billing_site, FND_API.G_MISS_NUM,NULL,
                         NULL,addressid, l_billing_site),
      bill_addr_territory_code =
        DECODE(p_billing_country, FND_API.G_MISS_CHAR,NULL,
               NULL,bill_addr_territory_code, p_billing_country),
      billing_addr_postal_code =
        DECODE(p_billing_zip, FND_API.G_MISS_CHAR,NULL,
               NULL,billing_addr_postal_code, p_billing_zip),
      expirydate = NVL(p_expiry_date, expirydate),

      instrument_type = NVL(p_instr_type, instrument_type),

      finame = DECODE(p_fi_name, FND_API.G_MISS_CHAR,NULL, NULL,finame, p_fi_name),
      single_use_flag = NVL(p_single_use, single_use_flag),
      information_only_flag = NVL(p_info_only, information_only_flag),
      card_purpose = DECODE(p_purpose, FND_API.G_MISS_CHAR,NULL, NULL,card_purpose, p_purpose),
      description = DECODE(p_desc, FND_API.G_MISS_CHAR,NULL, NULL,description, p_desc),
      active_flag = NVL(p_active_flag, active_flag),
      inactive_date = DECODE(p_inactive_date, FND_API.G_MISS_DATE,NULL,
                             NULL,inactive_date, p_inactive_date),
      object_version_number = object_version_number + 1,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id,
      attribute_category = p_Attribute_category,
      attribute1 = p_attribute1,
      attribute2 = p_attribute2,
      attribute3 = p_attribute3,
      attribute4 = p_attribute4,
      attribute5 = p_attribute5,
      attribute6 = p_attribute6,
      attribute7 = p_attribute7,
      attribute8 = p_attribute8,
      attribute9 = p_attribute9,
      attribute10 = p_attribute10,
      attribute11 = p_attribute11,
      attribute12 = p_attribute12,
      attribute13 = p_attribute13,
      attribute14 = p_attribute14,
      attribute15 = p_attribute15
    WHERE (instrid = p_instr_id);

    IF (SQL%NOTFOUND) THEN x_result_code := G_RC_INVALID_CARD_ID; END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;
  END Update_Card;

   PROCEDURE Create_Card
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_card_instrument  IN   PaymentCard_rec_type,
            x_card_id          OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS

    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Create_Card';
    l_prev_msg_count NUMBER;

    lx_result_code VARCHAR2(30);
    lx_result      IBY_FNDCPT_COMMON_PUB.Result_rec_type;
    lx_card_rec    PaymentCard_rec_type;

    l_info_only    iby_paymentcard.information_only_flag%TYPE := NULL;

    l_dbg_mod      VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;


  BEGIN
    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    --SAVEPOINT Create_Card;

    Card_Exists
    (
    1.0,
    FND_API.G_FALSE,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_card_instrument.Owner_Id,
    p_card_instrument.Card_Number,
    lx_card_rec,
    lx_result,
    NVL(p_card_instrument.Instrument_Type, C_INSTRTYPE_PAYMENTCARD)
    );

    iby_debug_pub.add('fetched card id:='||lx_card_rec.Card_Id,
      iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

    IF (lx_card_rec.Card_Id IS NULL) THEN

      -- validate billing address information
      IF (NOT Validate_Card_Billing(FND_API.G_FALSE,p_card_instrument)) THEN
        x_response.Result_Code := G_RC_INVALID_ADDRESS;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;

        iby_debug_pub.add('creating new card',
          iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

        Create_Card
        (FND_API.G_FALSE,
         p_card_instrument.Owner_Id, p_card_instrument.Card_Holder_Name,
         p_card_instrument.Billing_Address_Id,
         p_card_instrument.Address_Type,
         p_card_instrument.Billing_Postal_Code,
         p_card_instrument.Billing_Address_Territory,
         p_card_instrument.Card_Number, p_card_instrument.Expiration_Date,
         NVL(p_card_instrument.Instrument_Type, C_INSTRTYPE_PAYMENTCARD),
         C_ISSUER_COMCHECK,
         p_card_instrument.FI_Name, p_card_instrument.Single_Use_Flag,
         p_card_instrument.Info_Only_Flag, p_card_instrument.Card_Purpose,
         p_card_instrument.Card_Description, p_card_instrument.Active_Flag,
         p_card_instrument.Inactive_Date,
         p_card_instrument.attribute_category,
         p_card_instrument.attribute1,
         p_card_instrument.attribute2,
         p_card_instrument.attribute3,
         p_card_instrument.attribute4,
         p_card_instrument.attribute5,
         p_card_instrument.attribute6,
         p_card_instrument.attribute7,
         p_card_instrument.attribute8,
         p_card_instrument.attribute9,
         p_card_instrument.attribute10,
         p_card_instrument.attribute11,
         p_card_instrument.attribute12,
         p_card_instrument.attribute13,
         p_card_instrument.attribute14,
         p_card_instrument.attribute15,
         lx_result_code, x_card_id
        );
   ELSE

      -- card cannot become info only once this flag is turned off
      IF (NOT p_card_instrument.Info_Only_Flag = 'Y') THEN
        l_info_only := p_card_instrument.Info_Only_Flag;
      END IF;

      -- validate billing address information
      IF (NOT Validate_Card_Billing(FND_API.G_TRUE,p_card_instrument)) THEN
        x_response.Result_Code := G_RC_INVALID_ADDRESS;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;
      -- validate expiration date
      IF (TRUNC(p_card_instrument.Expiration_Date,'DD') < TRUNC(SYSDATE,'DD'))
      THEN
        x_response.Result_Code := G_RC_INVALID_CARD_EXPIRY;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;

      Update_Card
      (FND_API.G_FALSE, lx_card_rec.Card_Id, p_card_instrument.Owner_Id,
       p_card_instrument.Card_Holder_Name,
       p_card_instrument.Billing_Address_Id,
       p_card_instrument.Address_Type,
       p_card_instrument.Billing_Postal_Code,
       p_card_instrument.Billing_Address_Territory,
       p_card_instrument.Expiration_Date, p_card_instrument.Instrument_Type,
       p_card_instrument.FI_Name, p_card_instrument.Single_Use_Flag,
       l_info_only, p_card_instrument.Card_Purpose,
       p_card_instrument.Card_Description, p_card_instrument.Active_Flag,
       NVL(p_card_instrument.Inactive_Date,FND_API.G_MISS_DATE),
     p_card_instrument.attribute_category,
     p_card_instrument.attribute1,  p_card_instrument.attribute2,
     p_card_instrument.attribute3,  p_card_instrument.attribute4,
     p_card_instrument.attribute5,  p_card_instrument.attribute6,
     p_card_instrument.attribute7,  p_card_instrument.attribute8,
     p_card_instrument.attribute9,  p_card_instrument.attribute10,
     p_card_instrument.attribute11,  p_card_instrument.attribute12,
     p_card_instrument.attribute13,  p_card_instrument.attribute14,
     p_card_instrument.attribute15,  lx_result_code);
     x_card_id := lx_card_rec.Card_Id;
    END IF;

    x_response.Result_Code := NVL(lx_result_code,IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS);
    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        --ROLLBACK TO Create_Card;
        iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO Create_Card;
        iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN
        --ROLLBACK TO Create_Card;
        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
        iby_debug_pub.add(debug_msg => 'Exit Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

  END Create_Card;

 PROCEDURE Update_Card
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_card_instrument  IN   PaymentCard_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
	    )
   IS

    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Update_Card';
    l_prev_msg_count NUMBER;

    lx_result_code VARCHAR2(30);

    l_info_only    iby_paymentcard.information_only_flag%TYPE := NULL;

  BEGIN
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    SAVEPOINT Update_Card;

    -- card cannot become info only once this flag is turned off
    IF (NOT p_card_instrument.Info_Only_Flag = 'Y') THEN
      l_info_only := p_card_instrument.Info_Only_Flag;
    END IF;
    -- validate billing address information
    IF (NOT Validate_Card_Billing(FND_API.G_TRUE,p_card_instrument)) THEN
      x_response.Result_Code := G_RC_INVALID_ADDRESS;
      iby_fndcpt_common_pub.Prepare_Result
      (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
      RETURN;
    END IF;

    Update_Card
    (FND_API.G_FALSE, p_card_instrument.Card_Id, p_card_instrument.Owner_Id,
     p_card_instrument.Card_Holder_Name,
     p_card_instrument.Billing_Address_Id,
     p_card_instrument.Address_Type,
     p_card_instrument.Billing_Postal_Code,
     p_card_instrument.Billing_Address_Territory,
     p_card_instrument.Expiration_Date, p_card_instrument.Instrument_Type,
     p_card_instrument.FI_Name, p_card_instrument.Single_Use_Flag,
     l_info_only, p_card_instrument.Card_Purpose,
     p_card_instrument.Card_Description, p_card_instrument.Active_Flag,
     p_card_instrument.Inactive_Date,
     p_card_instrument.attribute_category,
     p_card_instrument.attribute1,  p_card_instrument.attribute2,
     p_card_instrument.attribute3,  p_card_instrument.attribute4,
     p_card_instrument.attribute5,  p_card_instrument.attribute6,
     p_card_instrument.attribute7,  p_card_instrument.attribute8,
     p_card_instrument.attribute9,  p_card_instrument.attribute10,
     p_card_instrument.attribute11,  p_card_instrument.attribute12,
     p_card_instrument.attribute13,  p_card_instrument.attribute14,
     p_card_instrument.attribute15,
     lx_result_code);


    x_response.Result_Code :=
      NVL(lx_result_code,IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS);
    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Update_Card;
	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Update_Card;
	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN
        ROLLBACK TO Update_Card;
        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
        iby_debug_pub.add(debug_msg => 'Exit Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

  END Update_Card;

  PROCEDURE Remask_Instruments
  (
   p_commit      IN     VARCHAR2 := FND_API.G_TRUE
  )
  IS
    l_card_number     iby_paymentcard.card_number%TYPE;
    lx_mask_digits    iby_paymentcard.card_number%TYPE;
    lx_mask_option    iby_paymentcard.card_mask_setting%TYPE;
    lx_unmask_len     iby_paymentcard.card_unmask_length%TYPE;

    CURSOR c_card
    (ci_mask_option   iby_paymentcard.card_mask_setting%TYPE,
     ci_unmask_len    iby_paymentcard.card_unmask_length%TYPE
    )
    IS
      SELECT c.instrid, c.card_number,
        c.card_number_length card_len
      FROM iby_paymentcard c
      WHERE ( (NVL(card_unmask_length,-1) <> ci_unmask_len) OR
              (NVL(card_mask_setting,' ') <> ci_mask_option)
            );
  BEGIN

    IF (c_card%ISOPEN) THEN CLOSE c_card; END IF;

    Get_Mask_Settings(lx_mask_option,lx_unmask_len);

    FOR c_card_rec IN c_card(lx_mask_option,lx_unmask_len) LOOP
      UPDATE iby_paymentcard
      SET
        masked_card_number =
          Mask_Card_Number(c_card_rec.card_number,lx_mask_option,lx_unmask_len),
        card_mask_setting = lx_mask_option,
        card_unmask_length = lx_unmask_len,
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


  PROCEDURE Query_Card
  (p_card_id          IN   iby_paymentcard.instrid%TYPE,
   x_owner_id         OUT NOCOPY iby_paymentcard.card_owner_id%TYPE,
   x_holder_name      OUT NOCOPY iby_paymentcard.chname%TYPE,
   x_billing_address_id OUT NOCOPY iby_paymentcard.addressid%TYPE,
   x_billing_address1 OUT NOCOPY hz_locations.address1%TYPE,
   x_billing_address2 OUT NOCOPY hz_locations.address2%TYPE,
   x_billing_address3 OUT NOCOPY hz_locations.address3%TYPE,
   x_billing_city     OUT NOCOPY hz_locations.city%TYPE,
   x_billing_county   OUT NOCOPY hz_locations.county%TYPE,
   x_billing_state    OUT NOCOPY hz_locations.state%TYPE,
   x_billing_zip      OUT NOCOPY hz_locations.postal_code%TYPE,
   x_billing_country  OUT NOCOPY hz_locations.country%TYPE,
   x_card_number      OUT NOCOPY iby_paymentcard.card_number%TYPE,
   x_masked_card_number OUT NOCOPY iby_paymentcard.card_number%TYPE,
   x_expiry_date      OUT NOCOPY iby_paymentcard.expirydate%TYPE,
   x_instr_type       OUT NOCOPY iby_paymentcard.instrument_type%TYPE,
   x_issuer           OUT NOCOPY iby_paymentcard.card_issuer_code%TYPE,
   x_fi_name          OUT NOCOPY iby_paymentcard.finame%TYPE,
   x_single_use       OUT NOCOPY iby_paymentcard.single_use_flag%TYPE,
   x_info_only        OUT NOCOPY iby_paymentcard.information_only_flag%TYPE,
   x_purpose          OUT NOCOPY iby_paymentcard.card_purpose%TYPE,
   x_desc             OUT NOCOPY iby_paymentcard.description%TYPE,
   x_active_flag      OUT NOCOPY iby_paymentcard.active_flag%TYPE,
   x_inactive_date    OUT NOCOPY iby_paymentcard.inactive_date%TYPE,
   x_result_code      OUT  NOCOPY VARCHAR2
  )
  IS

    l_err_code        VARCHAR2(200);
    l_instr_found     BOOLEAN;

    CURSOR c_paymentcard(ci_instr_id iby_paymentcard.instrid%TYPE)
    IS
      SELECT
        c.card_owner_id, c.chname, c.addressid,
        l.address1, l.address2, l.address3, l.city, l.county,
        l.state, l.postal_code, l.country,
        c.card_number, c.masked_card_number, c.expirydate, c.instrument_type,
        c.card_issuer_code, c.finame,
        c.single_use_flag, c.information_only_flag, c.card_purpose,
        c.description, c.active_flag, c.inactive_date
      FROM iby_paymentcard c, hz_party_site_uses su, hz_party_sites s,
        hz_locations l
      WHERE (instrid = ci_instr_id)
        AND (c.addressid = su.party_site_use_id(+))
        AND (su.party_site_id = s.party_site_id(+))
        AND (s.location_id = l.location_id(+));

  BEGIN

    IF( c_paymentcard%ISOPEN ) THEN
      CLOSE c_paymentcard;
    END IF;

    OPEN c_paymentcard(p_card_id);
    FETCH c_paymentcard
    INTO x_owner_id, x_holder_name, x_billing_address_id,
      x_billing_address1, x_billing_address2, x_billing_address3,
      x_billing_city, x_billing_county, x_billing_state, x_billing_zip,
      x_billing_country, x_card_number, x_masked_card_number, x_expiry_date, x_instr_type,
      x_issuer, x_fi_name, x_single_use,
      x_info_only, x_purpose, x_desc, x_active_flag, x_inactive_date;

    l_instr_found := (NOT c_paymentcard%NOTFOUND);
    CLOSE c_paymentcard;

    IF (NOT l_instr_found) THEN
      raise_application_error(-20000,'IBY_20512', FALSE);
    END IF;


  END Query_Card;

  PROCEDURE Card_Exists
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_owner_id              NUMBER,
            p_card_number           VARCHAR2,
            x_card_instrument  OUT NOCOPY PaymentCard_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type,
            p_card_instr_type  IN  VARCHAR2 DEFAULT NULL
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Card_Exists';
    l_prev_msg_count NUMBER;

    l_card_id   iby_paymentcard.instrid%TYPE;

    l_char_allowed  VARCHAR2(1) := 'N';
    lx_return_status    VARCHAR2(1);
    lx_msg_count        NUMBER;
    lx_msg_data         VARCHAR2(200);
    lx_card_number        iby_paymentcard.card_number%TYPE;
    lx_result           IBY_FNDCPT_COMMON_PUB.Result_rec_type;

    CURSOR p_card
    (pi_card_owner IN iby_paymentcard.card_owner_id%TYPE
    )
    IS
      SELECT instrid
      FROM iby_paymentcard
      WHERE ( (card_owner_id = NVL(pi_card_owner,card_owner_id))
          OR (card_owner_id IS NULL AND pi_card_owner IS NULL) )
        AND (NVL(single_use_flag,'N')='N');
  BEGIN

    IF (p_card%ISOPEN) THEN
      CLOSE p_card;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    IF (lx_card_number IS NULL) THEN
      x_response.Result_Code := G_RC_INVALID_CARD_NUMBER;
      iby_fndcpt_common_pub.Prepare_Result
      (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
      RETURN;
    END IF;

    OPEN p_card(p_owner_id);
    FETCH p_card INTO l_card_id;
    CLOSE p_card;

    Get_Card
      (
      1.0,
      FND_API.G_FALSE,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_card_id,
      x_card_instrument,
      lx_result
      );
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

        iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
        iby_debug_pub.add(debug_msg => 'Exit Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
  END Card_Exists;

  PROCEDURE Get_Card
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_card_id               NUMBER,
            x_card_instrument  OUT NOCOPY PaymentCard_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Get_Card';
    l_prev_msg_count NUMBER;

    l_card_count NUMBER;

    CURSOR p_card(pi_card_id IN iby_paymentcard.instrid%TYPE)
    IS
      SELECT card_owner_id, chname, addressid, masked_card_number, expirydate,
        instrument_type,
        card_issuer_code, finame, single_use_flag,
        information_only_flag, card_purpose, description, inactive_date
      FROM iby_paymentcard
      WHERE (instrid = pi_card_id);
  BEGIN
    IF (p_card%ISOPEN) THEN
      CLOSE p_card;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    OPEN p_card(p_card_id);
    FETCH p_card INTO x_card_instrument.Owner_Id, x_card_instrument.Card_Holder_Name,
      x_card_instrument.Billing_Address_Id, x_card_instrument.Card_Number,
      x_card_instrument.Expiration_Date, x_card_instrument.Instrument_Type,
      x_card_instrument.Card_Issuer,
      x_card_instrument.FI_Name, x_card_instrument.Single_Use_Flag,
      x_card_instrument.Info_Only_Flag, x_card_instrument.Card_Purpose,
      x_card_instrument.Card_Description, x_card_instrument.Inactive_Date;

    IF (p_card%NOTFOUND) THEN
       x_response.Result_Code := G_RC_INVALID_CARD_ID;
    ELSE
       x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
       x_card_instrument.Card_Id := p_card_id;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
        iby_debug_pub.add(debug_msg => 'Exit Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
  END Get_Card;

END iby_paymentcard_pkg;

/
