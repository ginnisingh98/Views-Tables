--------------------------------------------------------
--  DDL for Package IBY_DISBURSEMENT_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DISBURSEMENT_SETUP_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyfdsts.pls 120.2.12010000.7 2010/06/17 04:58:58 pschalla ship $*/

--
-- Declaring Global variables
--

-- Package name
G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_DISBURSEMENT_SETUP_PUB';

-- Module name used for the application debugging framework
G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_DISBURSEMENT_SETUP_PUB';

-- Package constants
G_PMT_FLOW_DISBURSE CONSTANT VARCHAR2(80) := 'DISBURSEMENTS';

G_RC_SUCCESS CONSTANT VARCHAR2(80) := 'SUCCESS';
G_RC_INVALID_PAYEE CONSTANT VARCHAR2(80) := 'INVALID_PARTY_CONTEXT';
G_RC_INVALID_INSTRUMENT CONSTANT VARCHAR2(80) := 'INVALID_INSTRUMENT';
G_RC_INVALID_DATE_RANGE CONSTANT VARCHAR2(80) := 'INVALID_BEGIN_END_RANGE';
G_RC_INVALID_LOOKUP CONSTANT VARCHAR2(80) := 'INVALID_LOOKUP_VALUE';

G_PAYEE_LEVEL_PARTY CONSTANT VARCHAR2(80) := 'PARTY_LEVEL';
G_LE_LEVEL_PARTY CONSTANT VARCHAR2(80) := 'LE_LEVEL';
G_PAYEE_LEVEL_SITE CONSTANT VARCHAR2(80) := 'PARTY_SITE_LEVEL';
G_PAYEE_LEVEL_SITE_ORG CONSTANT VARCHAR2(80) := 'PARTY_SITE_ORG_LEVEL';
G_PAYEE_LEVEL_SUPP_SITE CONSTANT VARCHAR2(80) := 'SUPPLIER_SITE_LEVEL';
G_PAYEE_EMP_SITE CONSTANT VARCHAR2(80) := 'EMPLOYEE_SUPPLIER_SITE_LEVEL';
--
-- Data Structures needed by the APIs
--

-- External payee record and table
Type External_Payee_Rec_Type IS Record(
   Payee_Party_Id        IBY_EXTERNAL_PAYEES_ALL.payee_party_id%TYPE,
   Payment_Function      IBY_EXTERNAL_PAYEES_ALL.payment_function%TYPE,
   Exclusive_Pay_Flag    IBY_EXTERNAL_PAYEES_ALL.exclusive_payment_flag%TYPE,
   Payee_Party_Site_Id   IBY_EXTERNAL_PAYEES_ALL.party_site_id%TYPE,
   Supplier_Site_Id      IBY_EXTERNAL_PAYEES_ALL.supplier_site_id%TYPE,
   Payer_Org_Id          IBY_EXTERNAL_PAYEES_ALL.org_id%TYPE,
   Payer_Org_Type        IBY_EXTERNAL_PAYEES_ALL.org_type%TYPE,
   Default_Pmt_method    IBY_PAYMENT_METHODS_B.payment_method_code%TYPE,
   ECE_TP_Loc_Code       IBY_EXTERNAL_PAYEES_ALL.ece_tp_location_code%TYPE,
   Bank_Charge_Bearer    IBY_EXTERNAL_PAYEES_ALL.bank_charge_bearer%TYPE,
   Bank_Instr1_Code      IBY_EXTERNAL_PAYEES_ALL.bank_instruction1_code%TYPE,
   Bank_Instr2_Code      IBY_EXTERNAL_PAYEES_ALL.bank_instruction2_code%TYPE,
   Bank_Instr_Detail     IBY_EXTERNAL_PAYEES_ALL.bank_instruction_details%TYPE,
   Pay_Reason_Code       IBY_EXTERNAL_PAYEES_ALL.payment_reason_code%TYPE,
   Pay_Reason_Com        IBY_EXTERNAL_PAYEES_ALL.payment_reason_comments%TYPE,
   Inactive_Date         IBY_EXTERNAL_PAYEES_ALL.inactive_date%TYPE,
   Pay_Message1          IBY_EXTERNAL_PAYEES_ALL.payment_text_message1%TYPE,
   Pay_Message2          IBY_EXTERNAL_PAYEES_ALL.payment_text_message2%TYPE,
   Pay_Message3          IBY_EXTERNAL_PAYEES_ALL.payment_text_message3%TYPE,
   Delivery_Channel      IBY_EXTERNAL_PAYEES_ALL.delivery_channel_code%TYPE,
   Pmt_Format            IBY_FORMATS_B.format_code%TYPE,
   Settlement_Priority   IBY_EXTERNAL_PAYEES_ALL.settlement_priority%TYPE,
   Remit_advice_delivery_method
                        IBY_EXTERNAL_PAYEES_ALL.remit_advice_delivery_method%TYPE,
   Remit_advice_email   IBY_EXTERNAL_PAYEES_ALL.remit_advice_email%TYPE,
   edi_payment_format      IBY_EXTERNAL_PAYEES_ALL.bank_instruction1_code%TYPE,
   edi_transaction_handling      IBY_EXTERNAL_PAYEES_ALL.bank_instruction2_code%TYPE,
   edi_payment_method    IBY_PAYMENT_METHODS_B.payment_method_code%TYPE,
   edi_remittance_method      IBY_EXTERNAL_PAYEES_ALL.delivery_channel_code%TYPE,
   edi_remittance_instruction   IBY_EXTERNAL_PAYEES_ALL.payment_text_message1%TYPE,
   remit_advice_fax       IBY_EXTERNAL_PAYEES_ALL.REMIT_ADVICE_FAX%TYPE );

TYPE External_Payee_Tab_Type IS TABLE OF External_Payee_Rec_Type
     INDEX BY BINARY_INTEGER;

-- External payee Id record and table
Type Ext_Payee_ID_Rec_Type IS Record(
   Ext_Payee_ID          IBY_EXTERNAL_PAYEES_ALL.ext_payee_id%TYPE
);

TYPE Ext_Payee_ID_Tab_Type IS TABLE OF Ext_Payee_ID_Rec_Type
     INDEX BY BINARY_INTEGER;

-- External payee creation record and table
Type Ext_Payee_Create_Rec_Type IS Record(
   Payee_Creation_Status VARCHAR2(1),
   Payee_Creation_Msg    VARCHAR2(2000)
);

TYPE Ext_Payee_Create_Tab_Type IS TABLE OF Ext_Payee_Create_Rec_Type
     INDEX BY BINARY_INTEGER;

-- Payee context record and table
TYPE PayeeContext_Rec_Type IS RECORD (
   Payment_Function	VARCHAR2(30),
   Party_Id		NUMBER,
   Org_Type		VARCHAR2(30),
   Org_Id		NUMBER,
   Party_Site_id	NUMBER,
   Supplier_Site_id	NUMBER
);

TYPE PayeeContext_Tab_Type IS TABLE OF PayeeContext_Rec_Type
     INDEX BY BINARY_INTEGER;

-- External payee update record and table
Type Ext_Payee_Update_Rec_Type IS Record(
   Payee_Update_Status VARCHAR2(1),
   Payee_Update_Msg    VARCHAR2(2000)
);

TYPE Ext_Payee_Update_Tab_Type IS TABLE OF Ext_Payee_Update_Rec_Type
     INDEX BY BINARY_INTEGER;

--
-- Public API's
--

-- External Payee
PROCEDURE Create_External_Payee (
   p_api_version           IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2 default FND_API.G_FALSE,
   p_ext_payee_tab         IN   External_Payee_Tab_Type,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2,
   x_ext_payee_id_tab      OUT  NOCOPY Ext_Payee_ID_Tab_Type,
   x_ext_payee_status_tab  OUT  NOCOPY Ext_Payee_Create_Tab_Type
);

PROCEDURE Set_Payee_Instr_Assignment (
   p_api_version      IN   NUMBER,
   p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
   p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
   x_return_status    OUT  NOCOPY VARCHAR2,
   x_msg_count        OUT  NOCOPY NUMBER,
   x_msg_data         OUT  NOCOPY VARCHAR2,
   p_payee            IN   PayeeContext_rec_type,
   p_assignment_attribs IN  IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type,
   x_assign_id        OUT  NOCOPY NUMBER,
   x_response         OUT  NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
);

PROCEDURE Get_Payee_Instr_Assignments (
   p_api_version      IN   NUMBER,
   p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
   x_return_status    OUT  NOCOPY VARCHAR2,
   x_msg_count        OUT  NOCOPY NUMBER,
   x_msg_data         OUT  NOCOPY VARCHAR2,
   p_payee            IN   PayeeContext_rec_type,
   x_assignments      OUT  NOCOPY IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_tbl_type,
   x_response         OUT  NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
);

PROCEDURE Get_Payee_All_Instruments (
   p_api_version      IN   NUMBER,
   p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
   x_return_status    OUT  NOCOPY VARCHAR2,
   x_msg_count        OUT  NOCOPY NUMBER,
   x_msg_data         OUT  NOCOPY VARCHAR2,
   p_party_id         IN   NUMBER,
   x_instruments      OUT  NOCOPY IBY_FNDCPT_SETUP_PUB.PmtInstrument_tbl_type,
   x_response         OUT  NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
);

PROCEDURE Validate_External_Payee (
   p_api_version           IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2 default FND_API.G_FALSE,
   p_ext_payee_rec         IN   External_Payee_Rec_Type,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
);

PROCEDURE Create_Temp_Ext_Bank_Acct (
   p_api_version	IN	NUMBER,
   p_init_msg_list	IN	VARCHAR2 default FND_API.G_FALSE,
   x_return_status	OUT	NOCOPY VARCHAR2,
   x_msg_count	        OUT	NOCOPY NUMBER,
   x_msg_data		OUT	NOCOPY VARCHAR2,
   p_temp_ext_acct_id	IN	NUMBER,
   x_bank_acc_id	OUT	NOCOPY Number,
   x_response		OUT	NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
);

PROCEDURE Create_Temp_Ext_Bank_Acct (
     p_api_version	IN	NUMBER,
     p_init_msg_list	IN	VARCHAR2 default FND_API.G_FALSE,
     x_return_status	OUT	NOCOPY VARCHAR2,
     x_msg_count	OUT	NOCOPY NUMBER,
     x_msg_data		OUT	NOCOPY VARCHAR2,
     p_temp_ext_acct_id	IN	NUMBER,
     p_association_level IN VARCHAR2,
     p_supplier_site_id  IN NUMBER,
     p_party_site_id     IN NUMBER,
     p_org_id            IN NUMBER,
     p_org_type          IN VARCHAR2 default NULL,
     x_bank_acc_id	OUT	NOCOPY Number,
     x_response		OUT	NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
);


PROCEDURE Validate_Temp_Ext_Bank_Acct (
   p_api_version	IN	NUMBER,
   p_init_msg_list	IN	VARCHAR2 default FND_API.G_FALSE,
   x_return_status	OUT	NOCOPY VARCHAR2,
   x_msg_count		OUT	NOCOPY NUMBER,
   x_msg_data		OUT	NOCOPY VARCHAR2,
   p_temp_ext_acct_id	IN	NUMBER
);

--
-- Public API's
--

-- Update External Payee
PROCEDURE Update_External_Payee (
   p_api_version           IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2 default FND_API.G_FALSE,
   p_ext_payee_tab         IN   External_Payee_Tab_Type,
   p_ext_payee_id_tab      IN   Ext_Payee_ID_Tab_Type,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2,
   x_ext_payee_status_tab  OUT  NOCOPY Ext_Payee_Update_Tab_Type
);


END IBY_DISBURSEMENT_SETUP_PUB;

/
