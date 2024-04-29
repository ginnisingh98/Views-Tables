--------------------------------------------------------
--  DDL for Package IBY_DISBURSEMENT_COMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DISBURSEMENT_COMP_PUB" AUTHID CURRENT_USER AS
/*$Header: ibydiscs.pls 120.9.12010000.2 2010/03/03 06:34:01 vkarlapu ship $*/

--
-- Declaring Global variables
--
G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_DISBURSEMENT_COMP_PUB';

--
-- module name used for the application debugging framework
--
G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_DISBURSEMENT_COMP_PUB';

-- Lookup Types
BANK_CHARGE_BEARER_LOOKUP     CONSTANT VARCHAR2(100) := 'IBY_BANK_CHARGE_BEARER';
SETTLEMENT_PRIORITY_LOOKUP    CONSTANT VARCHAR2(100) := 'IBY_SETTLEMENT_PRIORITY';

-------------------------------------------------------------------------
-- **Defining all Data Structures required by the APIs**
-- The following PL/SQL record/table types are defined
-- to store the objects (entities) necessary for the APIs.
-------------------------------------------------------------------------
--
-- Generic Record Types
--

-- Input Transaction Record
Type Trxn_Attributes_Rec_Type IS Record(
   Application_Id        NUMBER,
   Payer_Legal_Entity_Id XLE_FIRSTPARTY_INFORMATION_V.legal_entity_id%TYPE,
   Payer_Org_Id          IBY_EXTERNAL_PAYEES_ALL.org_id%TYPE,
   Payer_Org_Type        IBY_EXTERNAL_PAYEES_ALL.org_type%TYPE,
   Payee_Party_Id        IBY_EXTERNAL_PAYEES_ALL.payee_party_id%TYPE,
   Payee_Party_Site_Id   IBY_EXTERNAL_PAYEES_ALL.party_site_id%TYPE,
   Supplier_Site_Id      IBY_EXTERNAL_PAYEES_ALL.supplier_site_id%TYPE,
   Pay_Proc_Trxn_Type_Code
                         IBY_TRXN_TYPES_B.pay_proc_trxn_type_code%TYPE,
   Payment_Currency      IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
   Payment_Amount        IBY_DOCS_PAYABLE_ALL.document_amount%TYPE,
   Payment_Function      IBY_EXTERNAL_PAYEES_ALL.payment_function%TYPE
);


-- Payment Method Record
Type Payment_Method_Rec_Type is Record
(
   Payment_Method_Name   IBY_PAYMENT_METHODS_VL.PAYMENT_METHOD_NAME%TYPE,
   Payment_Method_Code   IBY_PAYMENT_METHODS_VL.PAYMENT_METHOD_CODE%TYPE,
   Bill_Payable_Flag     IBY_PAYMENT_METHODS_VL.SUPPORT_BILLS_PAYABLE_FLAG%TYPE,
   Maturity_Date_Offset  IBY_PAYMENT_METHODS_VL.MATURITY_DATE_OFFSET_DAYS%TYPE,
   DESCRIPTION           IBY_PAYMENT_METHODS_VL.DESCRIPTION%TYPE
);

-- Payment Profile Drivers Record
Type PPP_Drivers_Rec_Type IS Record(
   Payment_Method_Code   IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
   Payer_Org_Id          IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
   Payer_Org_Type        IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
   Payment_Currency      IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
   Int_Bank_Account_Id   IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE
);

-- Payment Profile Record
Type Payment_Profile_Rec_Type is Record
(
   Payment_Profile_Id     IBY_PAYMENT_PROFILES.PAYMENT_PROFILE_ID%TYPE,
   Payment_Profile_Name   IBY_PAYMENT_PROFILES.PAYMENT_PROFILE_NAME%TYPE,
   Processing_Type        IBY_PAYMENT_PROFILES.PROCESSING_TYPE%TYPE
);

-- Payment Format Record
Type Payment_Format_Rec_Type is Record
(
   Payment_Format_Name   IBY_FORMATS_VL.FORMAT_NAME%TYPE,
   Payment_Format_Code   IBY_FORMATS_VL.FORMAT_CODE%TYPE
);


-- Payee Bank Account Record
Type Payee_BankAccount_Rec_Type is Record(
   Payee_BankAccount_Name  IBY_EXT_BANK_ACCOUNTS_V.bank_account_name%TYPE,
   Payee_BankAccount_Id    IBY_EXT_BANK_ACCOUNTS_V.ext_bank_account_id%TYPE,
   Payee_BankAccount_Num   IBY_EXT_BANK_ACCOUNTS_V.bank_account_number%TYPE,
   Currency_Code           IBY_EXT_BANK_ACCOUNTS_V.CURRENCY_CODE%TYPE,
   IBAN                    IBY_EXT_BANK_ACCOUNTS_V.IBAN_NUMBER%TYPE,
   Payee_BankName          IBY_EXT_BANK_ACCOUNTS_V.BANK_NAME%TYPE,
   Payee_BankNumber        IBY_EXT_BANK_ACCOUNTS_V.BANK_NUMBER%TYPE,
   Payee_BranchName        IBY_EXT_BANK_ACCOUNTS_V.BANK_BRANCH_NAME%TYPE,
   Payee_BranchNumber      IBY_EXT_BANK_ACCOUNTS_V.BRANCH_NUMBER%TYPE,
   Bank_Country		   IBY_EXT_BANK_ACCOUNTS_V.COUNTRY_CODE%TYPE,
   Alter_BankAccount_Name  IBY_EXT_BANK_ACCOUNTS_V.ALTERNATE_ACCOUNT_NAME%TYPE,
   BankAccount_Type        IBY_EXT_BANK_ACCOUNTS_V.BANK_ACCOUNT_TYPE%TYPE,
   BankAccount_Suffix      IBY_EXT_BANK_ACCOUNTS_V.ACCOUNT_SUFFIX%TYPE,
   BankAccount_Desc        IBY_EXT_BANK_ACCOUNTS_V.DESCRIPTION%TYPE,
   Foreign_PayUse_Flag     IBY_EXT_BANK_ACCOUNTS_V.FOREIGN_PAYMENT_USE_FLAG%TYPE,
   Pay_Factor_Flag         IBY_EXT_BANK_ACCOUNTS_V.PAYMENT_FACTOR_FLAG%TYPE,
   EFT_Swift_Code          IBY_EXT_BANK_ACCOUNTS_V.EFT_SWIFT_CODE%TYPE
);


-- Payment Reason Record
Type Payment_Reason_Rec_Type is Record
(
   Code                  IBY_PAYMENT_REASONS_VL.payment_reason_code%TYPE,
   Meaning               IBY_PAYMENT_REASONS_VL.meaning%TYPE,
   Description           IBY_PAYMENT_REASONS_VL.description%TYPE,
   Country               IBY_PAYMENT_REASONS_VL.territory_code%TYPE
);

-- Bank Charge Bearer Record
Type Bank_Charge_Bearer_Rec_Type is Record(
  Code               VARCHAR2(30),
  Meaning            VARCHAR2(80),
  Description        VARCHAR2(255)
);


-- Settlement Priority Record
Type Settlement_Priority_Rec_Type is Record(
  Code               VARCHAR2(30),
  Meaning            VARCHAR2(80),
  Description        VARCHAR2(255)
);


-- Delivery Channel Record
Type Delivery_Channel_Rec_Type is Record
(
   Code               IBY_DELIVERY_CHANNELS_VL.delivery_channel_code%TYPE,
   Meaning            IBY_DELIVERY_CHANNELS_VL.meaning%TYPE,
   Description        IBY_DELIVERY_CHANNELS_VL.description%TYPE,
   Country            IBY_DELIVERY_CHANNELS_VL.territory_code%TYPE
);


-- Table of Payment Method Records
Type Payment_Method_Tab_Type is Table of Payment_Method_Rec_Type INDEX by BINARY_INTEGER;

-- Table of Payment Profile Records
Type Payment_Profile_Tab_Type is Table of Payment_Profile_Rec_Type
    INDEX by BINARY_INTEGER;

-- Table of Payment Profile Record Tables
-- i.e., Two-dimensional table of payment profiles
Type Payment_Profile_2D_Tab_Type IS TABLE OF Payment_Profile_Tab_Type
    INDEX BY BINARY_INTEGER;

-- Table of Payment Profile Driver Records
Type PPP_Drivers_Tab_Type is Table of PPP_Drivers_Rec_Type
    INDEX by BINARY_INTEGER;

-- Table of Payment Format Records
Type Payment_Format_Tab_Type is Table of Payment_Format_Rec_Type INDEX by BINARY_INTEGER;

-- Table of Payee Bank Account Records
Type Payee_BankAccount_Tab_Type is Table of Payee_BankAccount_Rec_Type INDEX by BINARY_INTEGER;

-- Table of Payment Reason Records
Type Payment_Reason_Tab_Type is Table of Payment_Reason_Rec_Type INDEX by BINARY_INTEGER;

-- Table of Delivery Channels Records
Type Delivery_Channel_Tab_Type is Table of Delivery_Channel_Rec_Type INDEX by BINARY_INTEGER;

-- Default Payment Attributes Record
Type Default_Pmt_Attrs_Rec_Type is Record(
   Payment_Method       Payment_Method_Rec_Type,
   Payment_Format       Payment_Format_Rec_Type,
   Payee_BankAccount    Payee_BankAccount_Rec_Type,
   Payment_Reason       Payment_Reason_Rec_Type,
   Delivery_Channel     Delivery_Channel_Rec_Type,
   Bank_Charge_Bearer   Bank_Charge_Bearer_Rec_Type,
   Settlement_Priority  Settlement_Priority_Rec_Type,
   Pay_Alone            VARCHAR2(1),
   payment_reason_comments VARCHAR2(240)
);

-- Payment Field Properties Record
Type Applicable_Pmt_Attrs_Rec_Type is Record(
   Payment_Reason_Comnt_apl_flag    IBY_PAYMENT_METHODS_VL.payment_reason_comnt_apl_flag%TYPE,
   Remittance_Message1_apl_flag     IBY_PAYMENT_METHODS_VL.remittance_message1_apl_flag%TYPE,
   Remittance_Message2_apl_flag     IBY_PAYMENT_METHODS_VL.remittance_message2_apl_flag%TYPE,
   Remittance_Message3_apl_flag     IBY_PAYMENT_METHODS_VL.remittance_message3_apl_flag%TYPE,

   Unique_Remittance_apl_flag       IBY_PAYMENT_METHODS_VL.unique_remittance_id_apl_flag%TYPE,
   URI_CheckDigit_apl_flag          IBY_PAYMENT_METHODS_VL.uri_check_digit_apl_flag%TYPE,
   Payment_Format_apl_flag          IBY_PAYMENT_METHODS_VL.payment_format_apl_flag%TYPE,
   Delivery_Channel_apl_flag        IBY_PAYMENT_METHODS_VL.delivery_channel_apl_flag%TYPE,

   Bank_Charge_Bearer_apl_flag      IBY_PAYMENT_METHODS_VL.bank_charge_bearer_apl_flag%TYPE,
   Settlement_Priority_apl_flag     IBY_PAYMENT_METHODS_VL.settlement_priority_apl_flag%TYPE,
   Payment_Reason_apl_flag          IBY_PAYMENT_METHODS_VL.payment_reason_apl_flag%TYPE,
   external_bank_acct_apl_flag    IBY_PAYMENT_METHODS_VL.external_bank_acct_apl_flag%TYPE,
   exclusive_pmt_apl_flag	       IBY_PAYMENT_METHODS_VL.exclusive_pmt_apl_flag%TYPE,
   Inactive_Date                    IBY_PAYMENT_METHODS_VL.inactive_date%TYPE

);

  -- Start of comments
  --   API name     : Get_Appl_Delivery_Channels
  --   Type         : Public
  --   Pre-reqs     : None.
  --   Function     : get the list of applicable Delivery Channels.
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type  Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_delivery_channels_tbl    OUT Delivery_Channels_Tab_Type Required
  --
  --   Version   : Current version   1.0
  --                      Previous version   None
  --                      Initial version    1.0
  -- End of comments

PROCEDURE Get_Appl_Delivery_Channels (
     p_api_version           IN   NUMBER,
     p_init_msg_list         IN   VARCHAR2 default FND_API.G_FALSE,
     p_trxn_attributes_rec   IN   Trxn_Attributes_Rec_Type,
     x_return_status         OUT  NOCOPY VARCHAR2,
     x_msg_count             OUT  NOCOPY NUMBER,
     x_msg_data              OUT  NOCOPY VARCHAR2,
     x_delivery_channels_tbl OUT  NOCOPY Delivery_Channel_Tab_Type
);

  -- Start of comments
  --   API name     : Get_Applicable_Payee_BankAccts
  --   Type         : Public
  --   Pre-reqs     : None.
  --   Function     : get the list of applicable Payee Bank Accounts.
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type  Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payee_bankaccounts_tbl   OUT Payee_BankAccount_Tab_Type Required
  --
  --   Version   : Current version   1.0
  --                      Previous version   None
  --                      Initial version    1.0
  -- End of comments

PROCEDURE Get_Applicable_Payee_BankAccts (
     p_api_version               IN   NUMBER,
     p_init_msg_list             IN   VARCHAR2 default FND_API.G_FALSE,
     p_trxn_attributes_rec       IN   Trxn_Attributes_Rec_Type,
     x_return_status             OUT  NOCOPY VARCHAR2,
     x_msg_count                 OUT  NOCOPY NUMBER,
     x_msg_data                  OUT  NOCOPY VARCHAR2,
     x_payee_bankaccounts_tbl    OUT  NOCOPY Payee_BankAccount_Tab_Type
);

  -- Start of comments
  --   API name     : Get_Applicable_Payment_Formats
  --   Type         : Public
  --   Pre-reqs     : None.
  --   Function     : get the list of applicable Delivery Channels.
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type  Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payment_format_tbl       OUT Payment_Format_Tab_Type Required
  --
  --   Version   : Current version   1.0
  --                      Previous version   None
  --                      Initial version    1.0
  -- End of comments

PROCEDURE Get_Applicable_Payment_Formats(
     p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2 default FND_API.G_FALSE    ,
     x_return_status       OUT  NOCOPY VARCHAR2                     ,
     x_msg_count           OUT  NOCOPY NUMBER                       ,
     x_msg_data            OUT  NOCOPY VARCHAR2                     ,
     x_payment_formats_tbl OUT  NOCOPY Payment_Format_Tab_Type
);


-- Start of comments
--   API name     : Get_Applicable_Payment_Methods
--   Type         : Public
--   Pre-reqs     : None.
--   Function     : get the list of applicable Payment Methods.
--   Parameters   :
--   IN           :   p_api_version              IN  NUMBER   Required
--                    p_init_msg_list            IN  VARCHAR2 Optional
--                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type Required
--   OUT          :   x_return_status            OUT VARCHAR2 Required
--                    x_msg_count                OUT NUMBER   Required
--                    x_msg_data                 OUT VARCHAR2 Required
--                    x_payment_methods_tbl      OUT PmtMthd_Tab_Type Required
--
--   Version   : Current version   1.0
--                      Previous version   None
--                      Initial version    1.0
-- End of comments

PROCEDURE Get_Applicable_Payment_Methods (
     p_api_version              IN   NUMBER,
     p_init_msg_list            IN   VARCHAR2 default FND_API.G_FALSE,
     p_ignore_payee_prefer      IN   VARCHAR2,
     p_trxn_attributes_rec      IN   Trxn_Attributes_Rec_Type,
     x_return_status            OUT  NOCOPY VARCHAR2,
     x_msg_count                OUT  NOCOPY NUMBER,
     x_msg_data                 OUT  NOCOPY VARCHAR2,
     x_payment_methods_tbl      OUT  NOCOPY Payment_Method_Tab_Type
);

  --   Start of comments
  --   API name     : Get_Applicable_Pmt_Profiles
  --   Type         : Public
  --   Pre-reqs     : None
  --   Function     : Get the list of applicable payment profiles
  --                  based on the given profile drivers
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_ppp_drivers_rec          IN  PPP_Drivers_Rec_Type
  --                                                       Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payment_profiles_tbl     OUT
  --                                                 Payment_Profiles_Tab_Type
  --                                                     Required
  --   Version      : Current version   1.0
  --                  Previous version  None
  --                  Initial version   1.0
  --   End of comments

  PROCEDURE Get_Applicable_Pmt_Profiles(
                p_api_version          IN         NUMBER,
                p_init_msg_list        IN         VARCHAR2 DEFAULT
                                                      FND_API.G_FALSE,
                p_ppp_drivers_rec      IN         PPP_Drivers_Rec_Type,
                x_return_status        OUT NOCOPY VARCHAR2,
                x_msg_count            OUT NOCOPY NUMBER,
                x_msg_data             OUT NOCOPY VARCHAR2,
                x_payment_profiles_tbl OUT NOCOPY Payment_Profile_Tab_Type
  );

  --   Start of comments
  --   API name     : Get_Pmt_Profiles_Intersect
  --   Type         : Public
  --   Pre-reqs     : None
  --   Function     : Get the list of applicable payment profiles
  --                  that are applicable across the given profile
  --                  drivers list.
  --
  --                  We already have a method to get the payment
  --                  profiles for a single set of profile drivers;
  --                  This method will attempt to get the payment profiles
  --                  for every given set of payment drivers in the list
  --                  and return their intersection.
  --
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_ppp_drivers_tab          IN  PPP_Drivers_Tab_Type
  --                                                       Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payment_profiles_tbl     OUT
  --                                                 Payment_Profiles_Tab_Type
  --                                                     Required
  --   Version      : Current version   1.0
  --                  Previous version  None
  --                  Initial version   1.0
  --   End of comments

  PROCEDURE Get_Pmt_Profiles_Intersect(
                p_api_version          IN         NUMBER,
                p_init_msg_list        IN         VARCHAR2 DEFAULT
                                                      FND_API.G_FALSE,
                p_ppp_drivers_tab      IN         PPP_Drivers_Tab_Type,
                x_return_status        OUT NOCOPY VARCHAR2,
                x_msg_count            OUT NOCOPY NUMBER,
                x_msg_data             OUT NOCOPY VARCHAR2,
                x_payment_profiles_tbl OUT NOCOPY Payment_Profile_Tab_Type
  );

  -- Start of comments
  --   API name     : Get_Applicable_Payment_Reasons
  --   Type         : Public
  --   Pre-reqs     : None.
  --   Function     : get the list of applicable Payment Reasons.
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type  Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payment_reason_tbl       OUT Payment_Reason_Tab_Type Required
  --
  --   Version   : Current version   1.0
  --                      Previous version   None
  --                      Initial version    1.0
  -- End of comments

PROCEDURE Get_Applicable_Payment_Reasons(
     p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2 default FND_API.G_FALSE    ,
     p_trxn_attributes_rec IN   Trxn_Attributes_Rec_Type,
     x_return_status       OUT  NOCOPY VARCHAR2                     ,
     x_msg_count           OUT  NOCOPY NUMBER                       ,
     x_msg_data            OUT  NOCOPY VARCHAR2                     ,
     x_payment_reason_tbl  OUT  NOCOPY Payment_Reason_Tab_Type
);


-- Start of comments
--   API name     : Get_Default_Payment_Attributes
--   Type         : Public
--   Pre-reqs     : None.
--   Function     : get the default values of all Payment attributes.
--   Parameters   :
--   IN           :   p_api_version              IN  NUMBER   Required
--                    p_application_id           IN  NUMBER   Required
--                    p_init_msg_list            IN  VARCHAR2 Optional
--                    p_ignore_payee_pref        IN  VARCHAR2 Required
--                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type Required
--   OUT          :   x_return_status            OUT VARCHAR2 Required
--                    x_msg_count                OUT NUMBER   Required
--                    x_msg_data                 OUT VARCHAR2 Required
--                    x_default_pmt_attrs_rec    OUT Default_Pmt_Attrs_Rec_Type Required
--
--   Version   : Current version   1.0
--                      Previous version   None
--                      Initial version    1.0
-- End of comments

PROCEDURE Get_Default_Payment_Attributes(
    p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2 default FND_API.G_FALSE,
    p_ignore_payee_pref       IN   VARCHAR2,
    p_trxn_attributes_rec     IN   Trxn_Attributes_Rec_Type,
    x_return_status           OUT  NOCOPY VARCHAR2,
    x_msg_count               OUT  NOCOPY NUMBER,
    x_msg_data                OUT  NOCOPY VARCHAR2,
    x_default_pmt_attrs_rec   OUT  NOCOPY Default_Pmt_Attrs_Rec_Type
);

-- Start of comments
--   API name     : Get_Default_Payee_Bank_Acc
--   Type         : Public
--   Pre-reqs     : None.
--   Function     : get the list of applicable Payment attributes.
--   Parameters   :
--   IN           :   p_api_version              IN  NUMBER   Required
--                    p_init_msg_list            IN  VARCHAR2 Optional
--                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type Required
--   OUT          :   x_return_status            OUT VARCHAR2 Required
--                    x_msg_count                OUT NUMBER   Required
--                    x_msg_data                 OUT VARCHAR2 Required
--                    x_payee_bankaccount        OUT Payee_BankAccount_Rec_Type Required
--
--   Version   : Current version   1.0
--                      Previous version   None
--                      Initial version    1.0
-- End of comments
PROCEDURE Get_Default_Payee_Bank_Acc(
    p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2 default FND_API.G_FALSE,
    p_trxn_attributes_rec     IN   Trxn_Attributes_Rec_Type,
    x_return_status           OUT  NOCOPY VARCHAR2,
    x_msg_count               OUT  NOCOPY NUMBER,
    x_msg_data                OUT  NOCOPY VARCHAR2,
    x_payee_bankaccount       OUT  NOCOPY Payee_BankAccount_Rec_Type
);

-- Start of comments
--   API name     : Get_Payment_Field_Properties
--   Type         : Public
--   Pre-reqs     : None.
--   Function     : get the list of applicable Payment attributes.
--   Parameters   :
--   IN           :   p_api_version              IN  NUMBER   Required
--                    p_application_id           IN  NUMBER   Required
--                    p_init_msg_list            IN  VARCHAR2 Optional
--                    p_payment_method_id        IN  BY_PAYMENT_METHODS_VL.payment_method_id%TYPE Required
--   OUT          :   x_return_status            OUT VARCHAR2 Required
--                    x_msg_count                OUT NUMBER   Required
--                    x_msg_data                 OUT VARCHAR2 Required
--                    x_Payment_Field_Properties OUT Payment_Field_Properties_Rec_Type Required
--
--   Version   : Current version   1.0
--                      Previous version   None
--                      Initial version    1.0
-- End of comments

PROCEDURE Get_Payment_Field_Properties (
     p_api_version              IN   NUMBER,
     p_init_msg_list            IN   VARCHAR2 default FND_API.G_FALSE,
     p_payment_method_id        IN
                        IBY_PAYMENT_METHODS_VL.payment_method_code%TYPE,
     x_return_status            OUT  NOCOPY VARCHAR2,
     x_msg_count                OUT  NOCOPY NUMBER,
     x_msg_data                 OUT  NOCOPY VARCHAR2,
     x_Payment_Field_Properties OUT  NOCOPY Applicable_Pmt_Attrs_Rec_Type
);


-- Start of comments
--   API name     : ValidateDocument
--   Type         : Public
--   Pre-reqs     : None.
--   Function     : validates the documents in the global temporary table
--                  IBY_DOCUMENTS_PAYABLE_GT
--   Parameters   :
--   IN           :   p_api_version              IN  NUMBER   Required
--                    p_application_id           IN  NUMBER   Required
--                    p_init_msg_list            IN  VARCHAR2 Optional
--                    p_validation_level         IN  NUMBER   Optional
--
--   OUT          :   x_return_status            OUT VARCHAR2 Required
--                    x_msg_count                OUT NUMBER   Required
--                    x_msg_data                 OUT VARCHAR2 Required
--
--
--   Version   : Current version   1.0
--                      Previous version   None
--                      Initial version    1.0
-- End of comments

PROCEDURE Validate_Documents(
     p_api_version              IN   NUMBER,
     p_init_msg_list            IN   VARCHAR2 default FND_API.G_FALSE,
     p_document_id              IN   IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     x_return_status            OUT  NOCOPY VARCHAR2,
     x_msg_count                OUT  NOCOPY NUMBER,
     x_msg_data                 OUT  NOCOPY VARCHAR2
);


   -- Start of comments
  --   API name     : Get_Applicable_Payee_Acc_list
  --   Type         : Public
  --   Pre-reqs     : None.
  --   Function     : get the list of all applicable Payee Bank Accounts.
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type  Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payee_bankaccounts_tbl   OUT Payee_BankAccount_Tab_Type Required
  --
  --   Version   : Current version   1.0
  --                      Previous version   None
  --                      Initial version    1.0
  -- End of comments

PROCEDURE Get_Applicable_Payee_Acc_list (
     p_api_version               IN   NUMBER,
     p_init_msg_list             IN   VARCHAR2 default FND_API.G_FALSE,
     p_trxn_attributes_rec       IN   Trxn_Attributes_Rec_Type,
     x_return_status             OUT  NOCOPY VARCHAR2,
     x_msg_count                 OUT  NOCOPY NUMBER,
     x_msg_data                  OUT  NOCOPY VARCHAR2,
     x_payee_bankaccounts_tbl    OUT  NOCOPY Payee_BankAccount_Tab_Type
);

END IBY_DISBURSEMENT_COMP_PUB;

/
