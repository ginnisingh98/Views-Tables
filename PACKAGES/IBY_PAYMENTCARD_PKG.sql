--------------------------------------------------------
--  DDL for Package IBY_PAYMENTCARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PAYMENTCARD_PKG" AUTHID CURRENT_USER AS
/*$Header: ibypmtcards.pls 120.0.12010000.5 2009/01/20 13:29:42 lmallick noship $*/

  -- Constant for payment card types
  C_INSTRTYPE_PAYMENTCARD CONSTANT VARCHAR2(20) := 'PAYMENTCARD';

  -- Constant ofr Comcheck card issuer
  C_ISSUER_COMCHECK VARCHAR2(20) := 'COMCHECK';

  -- Number masking options
  G_MASK_CHARACTER CONSTANT VARCHAR2(1) := 'X';
  G_DEF_UNMASK_LENGTH CONSTANT NUMBER := 4;

  -- Card validation errors
  G_RC_INVALID_CARD_NUMBER CONSTANT VARCHAR2(30) := 'INVALID_CARD_NUMBER';
  G_RC_INVALID_CARD_EXPIRY CONSTANT VARCHAR2(30) := 'INVALID_CARD_EXPIRY';
  G_RC_INVALID_INSTR_TYPE CONSTANT VARCHAR2(30) := 'INVALID_INSTRUMENT_TYPE';
  G_RC_INVALID_CARD_ISSUER CONSTANT VARCHAR2(30) := 'INVALID_CARD_ISSUER';
  G_RC_INVALID_CARD_ID CONSTANT VARCHAR2(30) := 'INVALID_INSTRUMENT';
  G_RC_INVALID_PARTY CONSTANT VARCHAR2(30) := 'INVALID_PARTY';
  G_RC_INVALID_ADDRESS CONSTANT VARCHAR2(30) := 'INVALID_ADDRESS';

  G_LKUP_INSTR_TYPE_PC CONSTANT VARCHAR2(30) := 'PAYMENTCARD';

  -- Payment card billing site usage
  G_PC_BILLING_SITE_USE CONSTANT VARCHAR2(30) := 'PAYMENTCARD_BILLING';

  -- Address Type Flags
  G_PARTY_SITE_ID CONSTANT VARCHAR2(1) := 'S';
  G_PARTY_SITE_USE_ID CONSTANT VARCHAR2(1) := 'U';

  TYPE PaymentCard_rec_type IS RECORD
     (
     Card_Id                NUMBER,
     Owner_Id               NUMBER,
     Card_Holder_Name       VARCHAR2(80),
     Billing_Address_Id     NUMBER,
     Billing_Postal_Code    VARCHAR2(50),
     Billing_Address_Territory VARCHAR2(2),
     Card_Number            VARCHAR2(30),
     Expiration_Date        DATE,
     Instrument_Type        VARCHAR2(30),
     Card_Issuer            VARCHAR2(30),
     FI_Name                VARCHAR2(80),
     Single_Use_Flag        VARCHAR2(1),
     Info_Only_Flag         VARCHAR2(1),
     Card_Purpose           VARCHAR2(30),
     Card_Description       VARCHAR2(240),
     Active_Flag            VARCHAR2(1),
     Inactive_Date          DATE,
     Address_Type           VARCHAR2(1), -- Internal to payments, defaulted to 'S'
     Attribute_category    VARCHAR2(150),
     Attribute1 VARCHAR2(150),
     Attribute2 VARCHAR2(150),
     Attribute3 VARCHAR2(150),
     Attribute4 VARCHAR2(150),
     Attribute5 VARCHAR2(150),
     Attribute6 VARCHAR2(150),
     Attribute7 VARCHAR2(150),
     Attribute8 VARCHAR2(150),
     Attribute9 VARCHAR2(150),
     Attribute10 VARCHAR2(150),
     Attribute11 VARCHAR2(150),
     Attribute12 VARCHAR2(150),
     Attribute13 VARCHAR2(150),
     Attribute14 VARCHAR2(150),
     Attribute15 VARCHAR2(150)
     );



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
  --   Generates a masked payment card number based upon system mask
  --   settings
  --
  FUNCTION Mask_Card_Number(p_card_number IN iby_paymentcard.card_number%TYPE)
  RETURN iby_paymentcard.masked_card_number%TYPE;

  FUNCTION Mask_Card_Number
  (p_card_number       IN   iby_paymentcard.card_number%TYPE,
   p_mask_option       IN   iby_paymentcard.card_mask_setting%TYPE,
   p_unmask_len        IN   iby_paymentcard.card_unmask_length%TYPE
  )
  RETURN iby_paymentcard.masked_card_number%TYPE;


  -- 1. Create_Card
  --
  --   API name        : Create_Card
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates a payment card instrument
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
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
            );

  -- 2. Update_Card
  --
  --   API name        : Update_Card
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Modifies a payment card instrument
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
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
            );

  -- 3. Get_Card
  --
  --   API name        : Get_Card
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Queries a payment card instrument
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
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
            );

  -- 15. Card_Exists
  --
  --   API name        : Card_Exists
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Queries if payment card is already registered;
  --                     identity is based on the card number and owning
  --                     party
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
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
            );


  --
  -- USE: Updates instrument masks according to new setting
  --
  -- ARGS:  p_commit => whether to commit the changes
  --
  --
  PROCEDURE Remask_Instruments
  (
    p_commit      IN     VARCHAR2 := FND_API.G_TRUE
  );


END iby_paymentcard_pkg;

/
