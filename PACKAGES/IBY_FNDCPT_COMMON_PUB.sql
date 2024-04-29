--------------------------------------------------------
--  DDL for Package IBY_FNDCPT_COMMON_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FNDCPT_COMMON_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyfccms.pls 120.10.12010000.2 2008/11/21 09:50:15 cjain ship $*/


G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_FNDCPT_COMMON';

G_INTERFACE_CODE CONSTANT VARCHAR2(30) := 'FNDCPT_PUB';

------------------------------------------------------------------------
-- I. Constant Declarations
------------------------------------------------------------------------

-- Payer context equivalency contants
--
G_PAYER_EQUIV_IMMEDIATE CONSTANT VARCHAR2(20) := 'IMMEDIATE';
G_PAYER_EQUIV_UPWARD CONSTANT VARCHAR2(20) := 'UPWARD';
G_PAYER_EQUIV_DOWNWARD CONSTANT VARCHAR2(20) := 'DOWNWARD';
G_PAYER_EQUIV_FULL CONSTANT VARCHAR2(20) := 'FULL';

-- Payer context levels
G_PAYER_LEVEL_PARTY CONSTANT VARCHAR2(30) := 'PARTY_LEVEL';
G_PAYER_LEVEL_CUSTOMER_ACCT CONSTANT VARCHAR2(30) := 'CUSTOMER_ACCT_LEVEL';
G_PAYER_LEVEL_CUSTOMER_SITE CONSTANT VARCHAR2(30) := 'CUSTOMER_SITE_LEVEL';


-- Result Categories
--
G_RCAT_SUCCESS CONSTANT VARCHAR2(30) := 'SUCCESS';
G_RCAT_SUCCESS_RISK CONSTANT VARCHAR2(30) := 'SUCCESS_WITH_RISK';
G_RCAT_PENDING CONSTANT VARCHAR2(30) := 'PENDING';
G_RCAT_SYS_ERROR CONSTANT VARCHAR2(30) := 'SYSTEM_ERROR';
G_RCAT_NOOP CONSTANT VARCHAR2(30) := 'OPERATION_UNSUPPORTED';
G_RCAT_INV_PARAM CONSTANT VARCHAR2(30) := 'INVALID_PARAM';
G_RCAT_INV_FLOW CONSTANT VARCHAR2(30) := 'INCORRECT_FLOW';
G_RCAT_FIN_ERROR CONSTANT VARCHAR2(30) := 'FINANCIAL_ERROR';
G_RCAT_DUP_REQ CONSTANT VARCHAR2(30) := 'DUPLICATE_REQUEST';
G_RCAT_DATA_CORRUPT CONSTANT VARCHAR2(30) := 'DATA_CORRUPTION';
G_RCAT_CONFIG_ERR CONSTANT VARCHAR2(30) := 'CONFIG_ERROR';
G_RCAT_CANCELLED CONSTANT VARCHAR2(30) := 'CANCELLED';


-- Result Codes
--
G_RC_SUCCESS CONSTANT VARCHAR2(30) := 'SUCCESS';
G_RC_INVALID_PAYER CONSTANT VARCHAR2(30) := 'INVALID_PARTY_CONTEXT';
G_RC_GENERIC_SYS_ERROR CONSTANT VARCHAR2(30) := 'GENERAL_SYS_ERROR';
G_RC_GENERIC_CONFIG_ERROR CONSTANT VARCHAR2(30) := 'GENERAL_CONFIG_ERROR';
G_RC_GENERIC_INVALID_PARAM CONSTANT VARCHAR2(30) := 'GENERAL_INVALID_PARAM';
G_RC_GENERIC_DATA_CORRUPTION CONSTANT VARCHAR2(30) := 'GENERAL_DATA_CORRUPTION';
G_RC_SETTLE_PENDING CONSTANT VARCHAR2(30) := 'SETTLEMENT_PENDING';


-- Lookups
--
G_LKUP_PMT_FUNCTION CONSTANT VARCHAR2(30) := 'IBY_PAYMENT_FUNCTIONS';

G_PMT_FUNCTION_CUST_PMT CONSTANT VARCHAR2(30) := 'CUSTOMER_PAYMENT';


G_INSTR_TYPE_CREDITCARD CONSTANT VARCHAR2(30) := 'CREDITCARD';
G_INSTR_TYPE_PAYMENTCARD CONSTANT VARCHAR2(30) := 'PAYMENTCARD';
G_INSTR_TYPE_BANKACCT CONSTANT VARCHAR2(30) := 'BANKACCOUNT';
G_INSTR_TYPE_MANUAL CONSTANT VARCHAR2(30) := 'MANUAL';


-------------------------------------------------------------------------
-- II. Common Record Types
-------------------------------------------------------------------------


TYPE PayerContext_rec_type IS RECORD
     (
     Payment_Function    VARCHAR2(30),
     Party_Id            NUMBER,
     Org_Type            VARCHAR2(30),
     Org_Id              NUMBER,
     Cust_Account_Id     NUMBER,
     Account_Site_Id     NUMBER
     );

TYPE TrxnContext_rec_type IS RECORD
     (
     Application_Id      NUMBER,
     Transaction_Type    VARCHAR2(30),
     Org_Type            VARCHAR2(30),
     Org_Id              NUMBER,
     Currency_Code       VARCHAR2(15),
     Payment_Amount      NUMBER,
     Payment_InstrType   VARCHAR2(30)
     );

TYPE ResultLimit_rec_type IS RECORD
     (
     Default_Flag        VARCHAR2(1)
     );

TYPE Result_rec_type IS RECORD
     (
     Result_Code         VARCHAR2(30),
     Result_Category     VARCHAR2(30),
     Result_Message      VARCHAR2(2000)
     );


TYPE Id_tbl_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- III.  Utility Functions
-------------------------------------------------------------------------------

  --
  -- Return: The party context level; if not a valid context then
  --   G_RC_INVALID_PAYER is returned
  --
  FUNCTION Validate_Payer
  (
  p_payer            IN   PayerContext_rec_type,
  p_val_level        IN   VARCHAR2
  )
  RETURN VARCHAR2;

  --
  -- Return: 'T' if the 2 payer contexts have equivalency
  -- Note: Equivalent payers will always share the same party id
  --   and payment function attributes; thus they are not passed in
  --   as arguments and should be used in the condition of the SQL
  --   query to limit the result set (and calls to this function)
  --
  FUNCTION Compare_Payer
  (
  p_payer_org_type  IN    iby_external_payers_all.org_type%TYPE,
  p_payer_org_id    IN    iby_external_payers_all.org_id%TYPE,
  p_payer_cust_acct_id IN iby_external_payers_all.cust_account_id%TYPE,
  p_payer_acct_site_id IN iby_external_payers_all.acct_site_use_id%TYPE,
  p_payer_level     IN    VARCHAR2,
  p_equiv_type      IN    VARCHAR2,
  p_compare_org_type IN   iby_external_payers_all.org_type%TYPE,
  p_compare_org_id  IN    iby_external_payers_all.org_id%TYPE,
  p_compare_cust_acct_id IN iby_external_payers_all.cust_account_id%TYPE,
  p_compare_acct_site_id IN iby_external_payers_all.acct_site_use_id%TYPE
  )
  RETURN VARCHAR2;

  --
  -- Purpose: Prepares various result out parameters based upon an API
  --          result code
  -- Args:    x_result => Field result code must be set to a valid value
  --
  PROCEDURE Prepare_Result
  (
  p_interface_code   IN  VARCHAR2 := G_INTERFACE_CODE,
  p_existing_msg     IN  VARCHAR2,
  p_prev_msg_count   IN  NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_result           IN OUT NOCOPY Result_rec_type
  );

  --
  -- Purpose: Prepares various result out parameters based upon an API
  --          result code
  -- Args:    x_result => Field result code must be set to a valid value
  --
  PROCEDURE Prepare_Result
  (
  p_prev_msg_count   IN  NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_result           IN OUT NOCOPY Result_rec_type
  );

  --
  -- Purpose: Gets the category of a particular interface result
  --
  FUNCTION Get_Result_Category
  (p_result     IN iby_result_codes.result_code%TYPE,
   p_interface  IN iby_result_codes.request_interface_code%TYPE)
  RETURN iby_result_codes.result_category%TYPE;

  PROCEDURE Clear_Msg_Stack( p_prev_msg_count IN  NUMBER );

END IBY_FNDCPT_COMMON_PUB;

/
