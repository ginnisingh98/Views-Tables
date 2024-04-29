--------------------------------------------------------
--  DDL for Package IBY_FNDCPT_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FNDCPT_SETUP_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyfcsts.pls 120.18.12010000.8 2010/01/25 10:10:16 sugottum ship $*/


------------------------------------------------------------------------
-- I. Constant Declarations
------------------------------------------------------------------------

G_CHNNL_ATTRIB_USE_OPTIONAL CONSTANT VARCHAR2(30) := 'OPTIONAL';
G_CHNNL_ATTRIB_USE_REQUIRED CONSTANT VARCHAR2(30) := 'REQUIRED';
G_CHNNL_ATTRIB_USE_DISABLED CONSTANT VARCHAR2(30) := 'DISABLED';

G_ENC_PATCH_LEVEL_NORMAL CONSTANT VARCHAR2(30) := 'NORMAL';
G_ENC_PATCH_LEVEL_PADSS  CONSTANT VARCHAR2(30) := 'PADSS';

G_PMT_FLOW_FNDCPT CONSTANT VARCHAR2(30) := 'FUNDS_CAPTURE';

-- Channel Types
G_CHANNEL_CREDIT_CARD CONSTANT VARCHAR2(30) := 'CREDIT_CARD';

-- Result Codes
G_RC_INVALID_CHNNL CONSTANT VARCHAR2(30) := 'INVALID_PMT_CHANNEL';
G_RC_INVALID_PMT_FUNCTION CONSTANT VARCHAR2(30) := 'INVALID_PMT_FUNCTION';
G_RC_INVALID_INSTRUMENT CONSTANT VARCHAR2(30) := 'INVALID_INSTRUMENT';
G_RC_INVALID_INSTR_ASSIGN CONSTANT VARCHAR2(30) := 'INVALID_INSTRUMENT_ASSIGNMENT';
G_RC_UNKNOWN_CARD CONSTANT VARCHAR2(30) := 'UNKNOWN_CARD';


-------------------------------------------------------------------------
-- II. Common Record Types
-------------------------------------------------------------------------


TYPE PayerAttributes_rec_type IS RECORD
     (
     Bank_Charge_Bearer  VARCHAR2(30),
     DirectDebit_BankInstruction VARCHAR2(30)
     );

TYPE PmtChannel_rec_type IS RECORD
     (
     Pmt_Channel_Code    VARCHAR2(30),
     Instrument_Type     VARCHAR2(30)
     );

TYPE PmtChannelAssignment_rec_type IS RECORD
     (
     Pmt_Channel_Code    VARCHAR2(30),
     Default_Flag        VARCHAR2(1),
     Inactive_Date       DATE
     );

TYPE PmtChannel_AttribUses_rec_type IS RECORD
     (
     Instr_SecCode_Use       VARCHAR2(30),
     Instr_VoiceAuthFlag_Use VARCHAR2(30),
     Instr_VoiceAuthCode_Use VARCHAR2(30),
     Instr_VoiceAuthDate_Use VARCHAR2(30),
     PO_Number_Use           VARCHAR2(30),
     PO_Line_Number_Use      VARCHAR2(30),
     AddInfo_Use             VARCHAR2(30),
     Instr_Billing_Address   VARCHAR2(30)
     );

TYPE PmtInstrument_rec_type IS RECORD
     (
     Instrument_Type         VARCHAR2(30),
     Instrument_Id           NUMBER
     );

TYPE PmtInstrAssignment_rec_type IS RECORD
     (
     Assignment_Id          NUMBER,
     Instrument             PmtInstrument_rec_type,
     Priority               NUMBER,
     Start_Date             DATE,
     End_Date               DATE
     );


TYPE CreditCard_rec_type IS RECORD
     (
     Card_Id                NUMBER,
     Owner_Id               NUMBER,
     Card_Holder_Name       VARCHAR2(80),
     Billing_Address_Id     NUMBER,
     Billing_Postal_Code    VARCHAR2(50),
     Billing_Address_Territory VARCHAR2(2),
     Card_Number            VARCHAR2(30),
     Expiration_Date        DATE,
     Expired_Flag           VARCHAR2(1),
     Instrument_Type        VARCHAR2(30),
     PurchaseCard_Flag      VARCHAR2(1),
     PurchaseCard_SubType   VARCHAR2(30),
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
     Attribute15 VARCHAR2(150),
     Attribute16 VARCHAR2(150),
     Attribute17 VARCHAR2(150),
     Attribute18 VARCHAR2(150),
     Attribute19 VARCHAR2(150),
     Attribute20 VARCHAR2(150),
     Attribute21 VARCHAR2(150),
     Attribute22 VARCHAR2(150),
     Attribute23 VARCHAR2(150),
     Attribute24 VARCHAR2(150),
     Attribute25 VARCHAR2(150),
     Attribute26 VARCHAR2(150),
     Attribute27 VARCHAR2(150),
     Attribute28 VARCHAR2(150),
     Attribute29 VARCHAR2(150),
     Attribute30 VARCHAR2(150),
     Register_Invalid_Card  VARCHAR2(1)  -- This parameter is used by OIE to register invalid cards
     );

-- II.2 Table Types

TYPE PmtChannel_tbl_type IS TABLE OF PmtChannel_rec_type
INDEX BY BINARY_INTEGER;

TYPE PmtChannelAssignment_tbl_type IS TABLE OF PmtChannelAssignment_rec_type
INDEX BY BINARY_INTEGER;

TYPE PmtInstrument_tbl_type IS TABLE OF PmtInstrument_rec_type
INDEX BY BINARY_INTEGER;

TYPE PmtInstrAssignment_tbl_type IS TABLE OF PmtInstrAssignment_rec_type
INDEX BY BINARY_INTEGER;


------------------------------------------------------------------------------
-- III.  API Signatures
------------------------------------------------------------------------------

  -- 1. Set_Payer_Attributes
  --
  --   API name        : Set_Payer_Attributes
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Sets payment-specific payer attributes
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Set_Payer_Attributes
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_attributes IN   PayerAttributes_rec_type,
            x_payer_attribs_id OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
          );

  -- 2. Get_Payer_Attributes
  --
  --   API name        : Get_Payer_Attributes
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Gets payment-specific payer attributes
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Get_Payer_Attributes
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            x_payer_attributes OUT NOCOPY PayerAttributes_rec_type,
            x_payer_attribs_id OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 3. Get_Payment_Channel_Attribs
  --
  --   API name        : Get_Payment_Channel_Attribs
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Gets payment channel attribute usages
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Get_Payment_Channel_Attribs
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_channel_code     IN   VARCHAR2,
            x_channel_attrib_uses OUT NOCOPY PmtChannel_AttribUses_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 4. Set_Payer_Default_Pmt_Channel
  --
  --   API name        : Set_Payer_Default_Pmt_Channel
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Sets a payer's default payment channel
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Set_Payer_Default_Pmt_Channel
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_channel_assignment IN PmtChannelAssignment_rec_type,
            x_assignment_id    OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 5. Get_Payer_Default_Pmt_Channel
  --
  --   API name        : Get_Payer_Default_Payment_Channel
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Gets the payer's default payment channel
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Get_Payer_Default_Pmt_Channel
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            x_channel_assignment OUT NOCOPY PmtChannelAssignment_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 6. Get_Trxn_Appl_Payment_Channels
  --
  --   API name        : Get_Trxn_Applicable_Payment_Channels
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Gets the payment channels applicable to the trxn
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Get_Trxn_Appl_Pmt_Channels
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2
              := IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_conditions       IN  IBY_FNDCPT_COMMON_PUB.TrxnContext_rec_type,
            p_result_limit     IN  IBY_FNDCPT_COMMON_PUB.ResultLimit_rec_type,
            x_channels         OUT NOCOPY PmtChannel_tbl_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 7. Set_Payer_Instr_Assignment
  --
  --   API name        : Set_Payer_Instr_Assignment
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Assigns instrument to the payer
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Set_Payer_Instr_Assignment
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_assignment_attribs IN PmtInstrAssignment_rec_type,
            x_assign_id        OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 8. Get_Payer_Instr_Assignments
  --
  --   API name        :
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Gets all instrument assignments for the payer
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Get_Payer_Instr_Assignments
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            x_assignments      OUT NOCOPY PmtInstrAssignment_tbl_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 9. Get_Payer_All_Instruments
  --
  --   API name        : Get_Payer_All_Instruments
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Get all instruments owned by the payer
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Get_Payer_All_Instruments
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_party_id         IN   NUMBER,
            x_instruments      OUT NOCOPY PmtInstrument_tbl_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 10. Get_Trxn_Appl_Instr_Assign
  --
  --   API name        : Get_Trxn_Appl_Instr_Assign
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Gets applicable instrument assignments for the trxn
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Get_Trxn_Appl_Instr_Assign
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_conditions       IN  IBY_FNDCPT_COMMON_PUB.TrxnContext_rec_type,
            p_result_limit     IN  IBY_FNDCPT_COMMON_PUB.ResultLimit_rec_type,
            x_assignments      OUT NOCOPY PmtInstrAssignment_tbl_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 11. Create_Card
  --
  --   API name        : Create_Card
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates a credit card instrument
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
            p_card_instrument  IN   CreditCard_rec_type,
            x_card_id          OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 12. Update_Card
  --
  --   API name        : Update_Card
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Modifies a credit card instrument
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
            p_card_instrument  IN   CreditCard_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 13. Get_Card
  --
  --   API name        : Get_Card
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Queries a credit card instrument
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
            x_card_instrument  OUT NOCOPY CreditCard_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 15. Card_Exists
  --
  --   API name        : Card_Exists
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Queries if credit card is already registered;
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
            x_card_instrument  OUT NOCOPY CreditCard_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type,
            p_card_instr_type  IN  VARCHAR2 DEFAULT NULL
            );

  -- 16. Process_Credit_Card
  --
  --   API name        : Process_Credit_Card
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates a credit card and instrument assignment.
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Process_Credit_Card
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_credit_card      IN   CreditCard_rec_type,
            p_assignment_attribs IN PmtInstrAssignment_rec_type,
            x_assign_id        OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );
  -- 17. Update_Card_Wrapper
  --
  --   API name        : Update_Card_Wrapper
  --   Type            : Public Wrapper for Java calls only to be used by Payments
  --   Pre-reqs        : None
  --   Function        : Modifies a credit card instrument
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
PROCEDURE Update_Card_Wrapper
      (
              p_commit           IN   VARCHAR2,
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
              x_return_status    OUT  NOCOPY VARCHAR2
     );

  -- 18. Create_Card_Wrapper
  --
  --   API name        : Create_Card_Wrapper
  --   Type            : Public Wrapper for Java calls only to be used by Payments
  --   Pre-reqs        : None
  --   Function        : Creates a credit card instrument
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0

PROCEDURE Create_Card_Wrapper
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
           x_return_status    OUT  NOCOPY VARCHAR2,
           x_instr_id         OUT  NOCOPY iby_creditcard.instrid%TYPE
          );

------------------------------------------------------------------------------
-- IV.  Utility Functions
------------------------------------------------------------------------------

  PROCEDURE Get_Payer_Id
  (
   p_payer IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
   p_validation_level IN VARCHAR2,
   x_payer_level OUT NOCOPY VARCHAR2,
   x_payer_id    OUT NOCOPY iby_external_payers_all.ext_payer_id%TYPE,
   x_payer_attribs OUT NOCOPY PayerAttributes_rec_type
   );


  FUNCTION Get_Hash(p_number IN VARCHAR2, p_salt IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION Get_Hash(p_number IN VARCHAR2, p_salt IN VARCHAR2, p_site_salt IN VARCHAR2)
  RETURN VARCHAR2;


  PROCEDURE Get_Trxn_Payer_Attributes
  (
   p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
   p_payer_equivalency IN  VARCHAR2
     := IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
   x_payer_attributes OUT NOCOPY PayerAttributes_rec_type
  );

  --
  -- Scope: Public
  -- USE  : Gets the card expiration status w.r.t an input date
  --        (NOTE:Invoking this API would be a performance overhead
  --         and hence done only when very much required)
  --
  --
  PROCEDURE Get_Card_Expiration_Status
  (p_instrid      IN   IBY_CREDITCARD.instrid%TYPE,
   p_input_date   IN DATE,
   x_expired      OUT NOCOPY VARCHAR2,
   x_result_code  OUT NOCOPY VARCHAR2
  );

  --
  -- Scope: Public
  -- USE  : Gets the current encryption patch level
  --        At present, it returns either NORMAL or PADSS
  --
  --
  FUNCTION Get_Encryption_Patch_Level
  RETURN VARCHAR2;

  -- SEPA DD project changes Begin
  -- Procedure to create new Mandate
  PROCEDURE Create_Debit_Authorization
  (p_debit_auth_id IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTHORIZATION_ID%TYPE,
   p_bank_use_id IN IBY_DEBIT_AUTHORIZATIONS.EXTERNAL_BANK_ACCOUNT_USE_ID%TYPE,
   p_auth_ref_number IN IBY_DEBIT_AUTHORIZATIONS.AUTHORIZATION_REFERENCE_NUMBER%TYPE,
   p_initial_debit_auth_id IN IBY_DEBIT_AUTHORIZATIONS.INITIAL_DEBIT_AUTHORIZATION_ID%TYPE,
   p_auth_rev_number IN IBY_DEBIT_AUTHORIZATIONS.AUTHORIZATION_REVISION_NUMBER%TYPE,
   p_payment_code IN IBY_DEBIT_AUTHORIZATIONS.PAYMENT_TYPE_CODE%TYPE,
   p_amend_readon_code IN IBY_DEBIT_AUTHORIZATIONS.AMENDMENT_REASON_CODE%TYPE,
   p_auth_sign_date IN IBY_DEBIT_AUTHORIZATIONS.AUTH_SIGN_DATE%TYPE,
   p_auth_cancel_date IN IBY_DEBIT_AUTHORIZATIONS.AUTH_CANCEL_DATE%TYPE,
   p_debit_auth_method IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_METHOD%TYPE,
   p_pre_notif_flag IN IBY_DEBIT_AUTHORIZATIONS.PRE_NOTIFICATION_REQUIRED_FLAG%TYPE,
   p_creditor_id IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_LEGAL_ENTITY_ID%TYPE,
   p_creditor_name IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_LE_NAME%TYPE,
   p_debit_auth_begin IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_BEGIN%TYPE,
   p_cust_addr_id IN IBY_DEBIT_AUTHORIZATIONS.CUST_ADDR_ID%TYPE,
   p_debit_auth_flag IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_FLAG%TYPE,
   p_debit_auth_ref IN  IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_REFERENCE%TYPE,
   p_cust_id_code IN IBY_DEBIT_AUTHORIZATIONS.CUST_IDENTIFICATION_CODE%TYPE,
   p_creditor_identifer IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_IDENTIFIER%TYPE,
   p_debit_auth_end IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_END%TYPE,
   p_mandate_file IN IBY_DEBIT_AUTHORIZATIONS.MANDATE_FILE%TYPE,
   x_result OUT NOCOPY NUMBER
   );

  -- Procedure to update the existing Mandate
PROCEDURE Update_Debit_Authorization
  (p_debit_auth_id IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTHORIZATION_ID%TYPE,
   p_bank_use_id IN IBY_DEBIT_AUTHORIZATIONS.EXTERNAL_BANK_ACCOUNT_USE_ID%TYPE,
   p_auth_ref_number IN IBY_DEBIT_AUTHORIZATIONS.AUTHORIZATION_REFERENCE_NUMBER%TYPE,
   p_initial_debit_auth_id IN IBY_DEBIT_AUTHORIZATIONS.INITIAL_DEBIT_AUTHORIZATION_ID%TYPE,
   p_auth_rev_number IN IBY_DEBIT_AUTHORIZATIONS.AUTHORIZATION_REVISION_NUMBER%TYPE,
   p_payment_code IN IBY_DEBIT_AUTHORIZATIONS.PAYMENT_TYPE_CODE%TYPE,
   p_amend_readon_code IN IBY_DEBIT_AUTHORIZATIONS.AMENDMENT_REASON_CODE%TYPE,
   p_auth_sign_date IN IBY_DEBIT_AUTHORIZATIONS.AUTH_SIGN_DATE%TYPE,
   p_auth_cancel_date IN IBY_DEBIT_AUTHORIZATIONS.AUTH_CANCEL_DATE%TYPE,
   p_debit_auth_method IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_METHOD%TYPE,
   p_pre_notif_flag IN IBY_DEBIT_AUTHORIZATIONS.PRE_NOTIFICATION_REQUIRED_FLAG%TYPE,
   p_creditor_id IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_LEGAL_ENTITY_ID%TYPE,
   p_creditor_name IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_LE_NAME%TYPE,
   p_debit_auth_begin IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_BEGIN%TYPE,
   p_cust_addr_id IN IBY_DEBIT_AUTHORIZATIONS.CUST_ADDR_ID%TYPE,
   p_debit_auth_flag IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_FLAG%TYPE,
   p_debit_auth_ref IN  IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_REFERENCE%TYPE,
   p_cust_id_code IN IBY_DEBIT_AUTHORIZATIONS.CUST_IDENTIFICATION_CODE%TYPE,
   p_creditor_identifer IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_IDENTIFIER%TYPE,
   p_debit_auth_end IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_END%TYPE,
   p_mandate_file IN IBY_DEBIT_AUTHORIZATIONS.MANDATE_FILE%TYPE,
   x_result OUT NOCOPY NUMBER
   );
  -- SEPA DD project changes End

END IBY_FNDCPT_SETUP_PUB;

/
