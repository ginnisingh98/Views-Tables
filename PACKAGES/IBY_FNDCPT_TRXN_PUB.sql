--------------------------------------------------------
--  DDL for Package IBY_FNDCPT_TRXN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FNDCPT_TRXN_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyfctxs.pls 120.18.12010000.8 2010/01/25 06:23:51 sgogula ship $*/


------------------------------------------------------------------------
-- I. Constant Declarations
------------------------------------------------------------------------

-- Result Codes
--
G_RC_INVALID_EXTENSION_ATTRIB CONSTANT VARCHAR2(30) := 'INVALID_EXTENSION_ATTRIB';
G_RC_INVALID_EXTENSION_ID CONSTANT VARCHAR2(30) := 'INVALID_TXN_EXTENSION';
G_RC_EXTENSION_IMMUTABLE CONSTANT VARCHAR2(30) := 'EXTENSION_NOT_UPDATEABLE';
G_RC_INCMP_EXTENSION_GROUP CONSTANT VARCHAR2(30) := 'INCOMPATIBLE_EXTENSION_GROUP';
G_RC_DUP_EXTENSION_COPY CONSTANT VARCHAR2(30) := 'DUPLICATE_EXTENSION_COPY';
G_RC_DUPLICATE_AUTHORIZATION CONSTANT VARCHAR2(30) := 'DUPLICATE_AUTH';
G_RC_INVALID_AUTHORIZATION CONSTANT VARCHAR2(30) := 'INVALID_AUTHORIZATION';
G_RC_AUTH_CANCEL_UNSUPPORTED CONSTANT VARCHAR2(30) := 'AUTH_CANCEL_UNSUPPORTED';
G_RC_AUTH_SUCCESS CONSTANT VARCHAR2(30) := 'AUTH_SUCCESS';
G_RC_AUTH_UNSUPPORTED CONSTANT VARCHAR2(30) := 'AUTH_UNSUPPORTED';
G_RC_AUTH_PENDING CONSTANT VARCHAR2(30) := 'AUTH_PENDING';
G_RC_AUTH_RISK_THRESHOLD CONSTANT VARCHAR2(30) := 'RISK_THRESHOLD_EXCEEDED';
G_RC_AUTH_RISK_SEC_CODE CONSTANT VARCHAR2(30) := 'SECURITY_CODE_WARNING';
G_RC_INVALID_SETTLEMENT CONSTANT VARCHAR2(30) := 'INVALID_SETTLEMENT';
G_RC_DUPLICATE_RETURN CONSTANT VARCHAR2(30) := 'DUPLICATE_RETURN';
G_RC_INVALID_PAYEE CONSTANT VARCHAR2(30) := 'INVALID_PAYEE';

G_RC_DUPLICATE_SETTLEMENT    CONSTANT VARCHAR2(30) := 'DUPLICATE_SETTLEMENT';
G_RC_AUTH_GROUPING_ERROR     CONSTANT VARCHAR2(30) := 'AUTH_GROUPING_ERROR';
G_RC_INVALID_AMOUNT          CONSTANT VARCHAR2(30) := 'INVALID_AMOUNT';




-------------------------------------------------------------------------
-- II. Common Record Types
-------------------------------------------------------------------------

TYPE PayeeContext_rec_type IS RECORD
     (
     Org_Type            VARCHAR2(30),
     Org_Id              NUMBER,
     Int_Bank_Country_Code      VARCHAR2(30)
     );

TYPE TrxnExtension_rec_type IS RECORD
     (
     Originating_Application_Id NUMBER,
     Order_Id               VARCHAR2(75),
     PO_Number              VARCHAR2(100),
     PO_Line_Number         VARCHAR2(25),
     Trxn_Ref_Number1       VARCHAR2(20),
     Trxn_Ref_Number2       VARCHAR2(20),
     Instrument_Security_Code VARCHAR2(30),
     VoiceAuth_Flag         VARCHAR2(1),
     VoiceAuth_Date         DATE,
     VoiceAuth_Code         VARCHAR2(100),
     Additional_Info        VARCHAR2(255),
     Copy_Instr_Assign_Id   NUMBER,
     Seq_Type_Last          VARCHAR2(1)
     );

TYPE Amount_rec_type IS RECORD
     (
     Value                  NUMBER,
     Currency_Code          VARCHAR2(15)
     );

-- Bug# 7707005. Adding the Receipt_Method_Id Qualifier for the routing rules.
TYPE AuthAttribs_rec_type IS RECORD
     (
     Payment_Factor_Flag    VARCHAR2(1),
     Memo                   VARCHAR2(80),
     Order_Medium           VARCHAR2(30),
     Tax_Amount             Amount_rec_type,
     ShipFrom_SiteUse_Id    NUMBER,
     ShipFrom_PostalCode    VARCHAR2(80),
     ShipTo_SiteUse_Id      NUMBER,
     ShipTo_PostalCode      VARCHAR2(80),
     RiskEval_Enable_Flag   VARCHAR2(1),
     Receipt_Method_Id      NUMBER := NULL
     );

TYPE ReceiptAttribs_rec_type IS RECORD
     (
      Settlement_Date        DATE,
      Settlement_Due_Date    DATE  := NULL
     );

TYPE RiskResult_rec_type IS RECORD
     (
     Risk_Score             NUMBER,
     Risk_Threshold_Val     NUMBER,
     Risky_Flag             VARCHAR2(1)
     );

TYPE AuthResult_rec_type IS RECORD
     (
     Auth_Id                NUMBER,
     Auth_Date              DATE,
     Auth_Code              VARCHAR2(80),
     AVS_Code               VARCHAR2(80),
     Instr_SecCode_Check    VARCHAR2(5),
     PaymentSys_Code        VARCHAR2(40),
     PaymentSys_Msg         VARCHAR2(255),
     Risk_Result            RiskResult_rec_type
     );




  TYPE SettlementResult_rec_type IS RECORD (
     Trxn_Extension_Id      iby_fndcpt_tx_extensions.TRXN_EXTENSION_ID%TYPE,
     Result                 IBY_FNDCPT_COMMON_PUB.Result_rec_type
   );


-- II.2 Table Types

  TYPE SettlementResult_tbl_type IS TABLE OF SettlementResult_rec_type
	INDEX BY BINARY_INTEGER;

------------------------------------------------------------------------------
-- III.  API Signatures
------------------------------------------------------------------------------


  -- 1. Create_Transaction_Extension
  --
  --   API name        : Create_Transaction_Extension
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates a transaction extension entity
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Create_Transaction_Extension
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_pmt_channel      IN   VARCHAR2,
            p_instr_assignment IN   NUMBER,
            p_trxn_attribs     IN   TrxnExtension_rec_type,
            x_entity_id        OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 2. Update_Transaction_Extension
  --
  --   API name        : Update_Transaction_Extension
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Update a transaction extension entity's attributes
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Update_Transaction_Extension
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_entity_id        IN   NUMBER,
            p_pmt_channel      IN   VARCHAR2,
            p_instr_assignment IN   NUMBER,
            p_trxn_attribs     IN   TrxnExtension_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 3. Get_Transaction_Extension
  --
  --   API name        : Get_Transaction_Extension
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Queries a transaction extension entity's attributes
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Get_Transaction_Extension
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_entity_id        IN   NUMBER,
            x_trxn_attribs     OUT NOCOPY TrxnExtension_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 4. Copy_Transaction_Extension
  --
  --   API name        : Copy_Transaction_Extension
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Copies a transaction extension, along with all the
  --                     associated operations done to it; merge version of
  --                     the API
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Copy_Transaction_Extension
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_entities         IN   IBY_FNDCPT_COMMON_PUB.Id_tbl_type,
            p_trxn_attribs     IN   TrxnExtension_rec_type,
            x_entity_id        OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 5. Delete_Transaction_Extension
  --
  --   API name        : Delete_Transaction_Extension
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Deletes/purges a transaction extension entity
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Delete_Transaction_Extension
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_entity_id        IN   NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  PROCEDURE Secure_Wipe_Segment
            (
	      p_segment_id IN iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE
	    );

  -- 6. Create_Authorization
  --
  --   API name        : Create_Authorization
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates an authorization
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Create_Authorization
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_payee            IN   PayeeContext_rec_type,
            p_trxn_entity_id   IN   NUMBER,
            p_auth_attribs     IN   AuthAttribs_rec_type,
            p_amount           IN   Amount_rec_type,
            x_auth_result      OUT NOCOPY AuthResult_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 7. Get_Authorization
  --
  --   API name        : Get_Authorization
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Queries an authorization
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Get_Authorization
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_trxn_entity_id   IN   NUMBER,
            x_auth_result      OUT NOCOPY AuthResult_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

  -- 8. Cancel_Authorization
  --
  --   API name        : Cancel_Authorization
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Cancels an authorization
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Cancel_Authorization
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_auth_id          IN   NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );


  -- 9. Create_Settlement
  --
  --   API name        : Create_Settlement
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates a settlement
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Create_Settlement
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_trxn_entity_id   IN   NUMBER,
            p_amount           IN   Amount_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );


   -- 9.5 Create_Settlement (Overloaded)
    --      Accepts ReceiptAttribs_rec_type as an additional
    --      IN parameter
    --
    --   API name        : Create_Settlement
    --   Type            : Public
    --   Pre-reqs        : None
    --   Function        : Creates a settlement
    --   Current version : 1.0
    --   Previous version: 1.0
    --   Initial version : 1.0
    --
    PROCEDURE Create_Settlement
              (
              p_api_version      IN   NUMBER,
              p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
              x_return_status    OUT NOCOPY VARCHAR2,
              x_msg_count        OUT NOCOPY NUMBER,
              x_msg_data         OUT NOCOPY VARCHAR2,
              p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
              p_payer_equivalency IN  VARCHAR2 :=
                IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
              p_trxn_entity_id   IN   NUMBER,
              p_amount           IN   Amount_rec_type,
              p_receipt_attribs  IN   ReceiptAttribs_rec_type,
              x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
              );


  -- 13. Create_Return
  --
  --   API name        : Create_Return
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates a return
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Create_Return
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_trxn_entity_id   IN   NUMBER,
            p_amount           IN   Amount_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            );

    -- 13.5 Create_Return (Overloaded)
    --      Accepts ReceiptAttribs_rec_type as an additional
    --      IN parameter
    --
    --   API name        : Create_Return
    --   Type            : Public
    --   Pre-reqs        : None
    --   Function        : Creates a return
    --   Current version : 1.0
    --   Previous version: 1.0
    --   Initial version : 1.0
    --
    PROCEDURE Create_Return
              (
              p_api_version      IN   NUMBER,
              p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
              x_return_status    OUT NOCOPY VARCHAR2,
              x_msg_count        OUT NOCOPY NUMBER,
              x_msg_data         OUT NOCOPY VARCHAR2,
              p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
              p_payer_equivalency IN  VARCHAR2 :=
                IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
              p_trxn_entity_id   IN   NUMBER,
              p_amount           IN   Amount_rec_type,
              p_receipt_attribs  IN   ReceiptAttribs_rec_type,
              x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
              );

   -- 14. Create_Settlements
   --
   --   API name        : create_settlements
   --   Type            : Public
   --   Pre-reqs        : None
   --   Function        : Pick up bulk settlment data from the the application
   --                     views to insert the settlement record in
   --                     IBY_TRXN_SUMMARIES_ALL
   --   Current version : 1.0
   --   Previous version: 1.0
   --   Initial version : 1.0
   --
     PROCEDURE Create_Settlements (
    p_api_version	            IN NUMBER,
    p_init_msg_list	            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_calling_app_id            IN NUMBER,
    p_calling_app_request_code	IN
IBY_TRXN_SUMMARIES_ALL.CALL_APP_SERVICE_REQ_CODE%TYPE,
    p_order_view_name           IN VARCHAR2,
    x_return_status	            OUT NOCOPY VARCHAR2,
    x_msg_count	                OUT NOCOPY NUMBER,
    x_msg_data	                OUT NOCOPY VARCHAR2,
    x_responses	                OUT NOCOPY SettlementResult_tbl_type
   );


  -- 100. Encrypt_Extensions
  --
  --   Function        : Encrypt_Extensions
  --   Type            : Private
  --   Purpose         : Encrypts transaction extensions
  --
  PROCEDURE Encrypt_Extensions
  (p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
   p_sys_security_key IN   iby_security_pkg.DES3_KEY_TYPE,
   x_err_code         OUT NOCOPY VARCHAR2
  );

  -- 100.5 Encrypt_Security_Code
  --
  --   Function        : Encrypt_Security_Code
  --   Type            : Private
  --   Purpose         : Encrypts the security code passed
  --
  PROCEDURE Encrypt_Security_Code
  (p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
   p_sys_security_key IN   iby_security_pkg.DES3_KEY_TYPE,
   p_security_code    IN   iby_fndcpt_tx_extensions.instrument_security_code%TYPE,
   x_segment_id       OUT NOCOPY NUMBER,
   x_err_code         OUT NOCOPY VARCHAR2
  );

  -- 101. Decrypt_Extensions
  --
  --   Function        : Decrypt_Extensions
  --   Type            : Private
  --   Purpose         : Decrypts transaction extensions
  --
  PROCEDURE Decrypt_Extensions
  (p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
   p_sys_security_key IN   iby_security_pkg.DES3_KEY_TYPE,
   x_err_code         OUT NOCOPY VARCHAR2
  );

  -- 101.5
  --
  --   Function        : Get_Security_Code
  --   Type            : Private
  --   Purpose         : Gets the clear-text instrument security code
  --                     for a given segment_id
  --
  FUNCTION Get_Security_Code
  (
   p_segment_id   IN iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE,
   p_sec_code_len IN iby_fndcpt_tx_extensions.instr_sec_code_length%TYPE,
   p_sys_sec_key  IN iby_security_pkg.DES3_KEY_TYPE
  )
  RETURN iby_fndcpt_tx_extensions.instrument_security_code%TYPE;

  -- 102.
  --
  --   Function        : Get_Security_Code
  --   Type            : Private
  --   Purpose         : Gets the clear-text instrument security code
  --                     for a given extension_id
  --
  FUNCTION Get_Security_Code
  (
   p_trxn_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
   p_sys_sec_key       IN iby_security_pkg.DES3_KEY_TYPE
  )
  RETURN iby_fndcpt_tx_extensions.instrument_security_code%TYPE;

  -- 102.5
  --   Function        : Get_Security_Code
  --   Type            : Private
  --   Purpose         : Gets the clear-text instrument security code
  --
  FUNCTION Get_Security_Code
  (p_sys_sec_key       IN iby_security_pkg.DES3_KEY_TYPE,
   p_subkey_cipher     IN iby_sys_security_subkeys.subkey_cipher_text%TYPE,
   p_sec_code_cipher   IN iby_security_segments.segment_cipher_text%TYPE,
   p_sec_code_len      IN iby_fndcpt_tx_extensions.instr_sec_code_length%TYPE
  )
  RETURN iby_fndcpt_tx_extensions.instrument_security_code%TYPE;

  -- 103.
  --
  --   Function        : Get_Tangible_Id
  --   Type            : Private
  --   Purpose         : Generates the tangible id
  --                     This function has been kept for backward
  --                     data compatibility. The overloaded API would
  --                     be used for new orders.
  --
  FUNCTION Get_Tangible_Id
  (p_app_short_name    IN fnd_application.application_short_name%TYPE,
   p_order_id          IN iby_fndcpt_tx_extensions.order_id%TYPE,
   p_trxn_ref1         IN iby_fndcpt_tx_extensions.trxn_ref_number1%TYPE,
   p_trxn_ref2         IN iby_fndcpt_tx_extensions.trxn_ref_number2%TYPE
  )
  RETURN iby_trxn_summaries_all.tangibleid%TYPE;

  -- 104.
  --
  --   Function        : Get_Tangible_Id
  --   Type            : Private
  --   Purpose         : Generates the tangible id using the application
  --                     short name and the trxn_extension_id.
  --
  --Overloading this function for bug : 7628586
  FUNCTION Get_Tangible_Id
  (p_app_short_name    IN fnd_application.application_short_name%TYPE,
   p_trxn_extn_id      IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE
  )
  RETURN iby_trxn_summaries_all.tangibleid%TYPE;

/*--------------------------------------------------------------------
 | NAME:
 |     print_debuginfo
 |
 | PURPOSE:
 |     This procedure prints the debug message to the concurrent manager
 |     log file.
 |
 | PARAMETERS:
 |     IN
 |      p_debug_text - The debug message to be printed
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_debuginfo(
     p_module     IN VARCHAR2,
     p_debug_text IN VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     get_le_from_bankacct_id
 |
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION get_le_from_bankacct_id(
     l_intbankacct_id IN IBY_TRXN_SUMMARIES_ALL.payeeinstrid%TYPE)
     RETURN NUMBER;


END IBY_FNDCPT_TRXN_PUB;

/
