--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_APP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_APP_PVT" AS
  /* $Header: OKLRLAPB.pls 120.93.12010000.10 2010/02/10 08:31:01 smadhava ship $*/
  -- Bug#4741121 - smadhava  - Modified - Start
  G_WF_EVT_LEASE_APP_WDW_PENDING    CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.sales.leaseapplication.withdrawn';
  G_WF_LEASE_APP_ID     CONSTANT  VARCHAR2(50)       := 'LA_ID';
  -- Bug#4741121 - smadhava  - Modified - Start

  L_MODULE                   FND_LOG_MESSAGES.MODULE%TYPE;
  L_DEBUG_ENABLED            VARCHAR2(10);
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  IS_DEBUG_STATEMENT_ON      BOOLEAN;

  -- Record type for the credit Application
  TYPE crr_rec_type IS RECORD(
    l_commit                    VARCHAR2(15),
    validation_level            VARCHAR2(50),
    application_number          AR_CMGT_CREDIT_REQUESTS.APPLICATION_NUMBER%TYPE,
    application_date            AR_CMGT_CREDIT_REQUESTS.APPLICATION_DATE%TYPE,
    requestor_type              AR_CMGT_CREDIT_REQUESTS.REQUESTOR_TYPE%TYPE,
    requestor_id                AR_CMGT_CREDIT_REQUESTS.REQUESTOR_ID%TYPE,
    review_type                 AR_CMGT_CREDIT_REQUESTS.REVIEW_TYPE%TYPE,
    credit_classification       AR_CMGT_CREDIT_REQUESTS.CREDIT_CLASSIFICATION%TYPE,
    requested_amount            AR_CMGT_CREDIT_REQUESTS.LIMIT_AMOUNT%TYPE,
    requested_currency          AR_CMGT_CREDIT_REQUESTS.LIMIT_CURRENCY%TYPE,
    trx_amount                  AR_CMGT_CREDIT_REQUESTS.TRX_AMOUNT%TYPE,
    trx_currency                AR_CMGT_CREDIT_REQUESTS.TRX_CURRENCY%TYPE,
    credit_type                 AR_CMGT_CREDIT_REQUESTS.CREDIT_TYPE%TYPE,
    term_length                 AR_CMGT_CREDIT_REQUESTS.TERM_LENGTH%TYPE,
    credit_check_rule_id        AR_CMGT_CREDIT_REQUESTS.CREDIT_CHECK_RULE_ID%TYPE,
    credit_request_status       AR_CMGT_CREDIT_REQUESTS.STATUS%TYPE,
    party_id                    AR_CMGT_CREDIT_REQUESTS.PARTY_ID%TYPE,
    cust_account_id             AR_CMGT_CREDIT_REQUESTS.CUST_ACCOUNT_ID%TYPE,
    cust_acct_site_id           AR_CMGT_CREDIT_REQUESTS.CUST_ACCT_SITE_ID%TYPE,
    site_use_id                 AR_CMGT_CREDIT_REQUESTS.SITE_USE_ID%TYPE,
    contact_party_id            AR_CMGT_CREDIT_REQUESTS.CONTACT_PARTY_ID%TYPE,
    notes                       AR_CMGT_CREDIT_REQUESTS.NOTES%TYPE,
    source_org_id               AR_CMGT_CREDIT_REQUESTS.SOURCE_ORG_ID%TYPE,
    source_user_id              AR_CMGT_CREDIT_REQUESTS.SOURCE_USER_ID%TYPE,
    source_resp_id              AR_CMGT_CREDIT_REQUESTS.SOURCE_RESP_ID%TYPE,
    source_appln_id             AR_CMGT_CREDIT_REQUESTS.SOURCE_RESP_APPLN_ID%TYPE,
    source_security_group_id    AR_CMGT_CREDIT_REQUESTS.SOURCE_SECURITY_GROUP_ID%TYPE,
    source_name                 AR_CMGT_CREDIT_REQUESTS.SOURCE_NAME%TYPE,
    source_column1              AR_CMGT_CREDIT_REQUESTS.SOURCE_COLUMN1%TYPE,
    source_column2              AR_CMGT_CREDIT_REQUESTS.SOURCE_COLUMN2%TYPE,
    source_column3              AR_CMGT_CREDIT_REQUESTS.SOURCE_COLUMN3%TYPE,
    credit_request_id           AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE,
    review_cycle                AR_CMGT_CREDIT_REQUESTS.REVIEW_CYCLE%TYPE,
    case_folder_number          AR_CMGT_CREDIT_REQUESTS.CASE_FOLDER_NUMBER%TYPE,
    score_model_id              AR_CMGT_CREDIT_REQUESTS.SCORE_MODEL_ID%TYPE,
    parent_credit_request_id    AR_CMGT_CREDIT_REQUESTS.PARENT_CREDIT_REQUEST_ID%TYPE,
    credit_request_type         AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_TYPE%TYPE
  );
  --Added Bug 5647107 ssdeshpa start
  -----------------------------------
  -- PROCEDURE validate_le_id
  -----------------------------------
  PROCEDURE validate_le_id(p_le_id IN NUMBER ,
                           x_return_status  OUT NOCOPY VARCHAR2) IS

  l_program_name      CONSTANT VARCHAR2(30) := 'validate_le_id';
  l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
  l_ou_tax_upfront_yn VARCHAR2(1);

  CURSOR  l_systemparams_csr IS
    SELECT NVL(tax_upfront_yn,'N')
    FROM   OKL_SYSTEM_PARAMS;

  BEGIN
    OPEN l_systemparams_csr;
    FETCH l_systemparams_csr INTO l_ou_tax_upfront_yn;
    CLOSE l_systemparams_csr;

     IF(l_ou_tax_upfront_yn = 'Y') THEN
        IF(p_le_id IS NULL) THEN
           OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME
           ,p_msg_name     => 'OKL_SO_LSE_APP_LE_ERR');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
     END IF;
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_le_id;
  --Added Bug 5647107 ssdeshpa end
  -------------------------------------------------------------------------------
  -- FUNCTION get_lookup_meaning
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_lookup_meaning
  -- Description     : This function returns the meaning for given lookup type
  --                   and code
  -- Business Rules  : This function returns the meaning for given lookup type
  --                   and code
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 23-Dec-2005 PAGARG created
  -- End of comments
  FUNCTION get_lookup_meaning(
           p_lookup_type     IN VARCHAR2,
           p_lookup_code     IN VARCHAR2)
    RETURN VARCHAR2
  IS
    --Local variables
    l_meaning           VARCHAR2(80);

    --Cursor to check for Approve or Reject recommendation for a
    --given Lease Application
    CURSOR lkup_meaning_csr(p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS
      SELECT MEANING
      FROM FND_LOOKUPS FL
      WHERE FL.LOOKUP_TYPE = p_lookup_type
        AND FL.LOOKUP_CODE = p_lookup_code;

  BEGIN
    IF p_lookup_type IS NOT NULL
       AND p_lookup_code IS NOT NULL
    THEN
      OPEN lkup_meaning_csr(p_lookup_type, p_lookup_code);
      FETCH lkup_meaning_csr INTO l_meaning;
      CLOSE lkup_meaning_csr;
    END IF;

    RETURN l_meaning;
  EXCEPTION
	WHEN OTHERS
	THEN
      --Lookup Meaning Cursor
      IF lkup_meaning_csr%ISOPEN
      THEN
        CLOSE lkup_meaning_csr;
      END IF;
      OKL_API.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
      RETURN NULL;
  END get_lookup_meaning;

   -- Bug# 7140398 - Start
   ------------------------------------------------------------------------------
   -- FUNCTION is_primary_quote_declined
   ------------------------------------------------------------------------------
   -- Start of comments
   --
   -- Function Name  : is_primary_quote_declined
   -- Description     : This procedure checks if the primary quote on the lease app
   --                   is in status Credit Declined
   -- Parameters      :
   -- Version         : 1.0
   -- History         : 24-Apr-2009 nikshah created Bug 7140398
   --
   -- End of comments
   FUNCTION is_primary_quote_declined(p_lap_id IN OKL_LEASE_APPLICATIONS_B.ID%TYPE)
   RETURN BOOLEAN
   IS
    is_primary_declined BOOLEAN := FALSE;
    l_flag NUMBER;
     -- Cursor to check if primary quote on the lease app is credit declined
     CURSOR get_primary_quote_declined IS
           SELECT 1
             FROM OKL_LEASE_APPLICATIONS_B LAP
                    , OKL_LEASE_QUOTES_B LSQ
            WHERE LAP.ID = p_lap_id
              AND LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
                  AND LSQ.PARENT_OBJECT_ID = LAP.ID
              AND LSQ.PRIMARY_QUOTE = 'Y'
              AND LSQ.STATUS = 'CR-DECLINED';
   BEGIN
     OPEN get_primary_quote_declined;
           FETCH get_primary_quote_declined INTO l_flag;
           IF get_primary_quote_declined%FOUND THEN
             is_primary_declined := TRUE;
           END IF;
         CLOSE get_primary_quote_declined;

     return is_primary_declined;
   END is_primary_quote_declined;

   -- Bug# 7140398 - End

--Bug 4872214 PAGARG Added functions to return credit decision
  -------------------------------------------------------------------------------
  -- FUNCTION get_credit_decision
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_credit_decision
  -- Description     : This function returns the Credit Decision on the given
  --                   Lease Application
  -- Business Rules  : This function returns the Credit Decision on the given
  --                   Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 14-Dec-2005 PAGARG created
  --                 : 20 Dec 2005 PAGARG Bug 4897011 returning Credit Approved
  --                   or Credit Rejected instead of Approved or Rejected
  --                   19 Nov 2008 gboomina Bug 6971371 Modified the logic to return
  --                   credit decision based on status of Credit Recommendations
  -- End of comments
  FUNCTION get_credit_decision(
           p_lease_app_id       IN NUMBER)
    RETURN VARCHAR2
  IS
    --Local variables
    l_cr_decision           VARCHAR2(50);
    l_cr_recom              AR_CMGT_CF_RECOMMENDS.CREDIT_RECOMMENDATION%TYPE;
    l_cr_status             AR_CMGT_CF_RECOMMENDS.STATUS%TYPE;

    --Cursor to check for Approve or Reject recommendation for a
    --given Lease Application
    CURSOR credit_recom_csr(cp_lap_id NUMBER) IS
      SELECT RCM.CREDIT_RECOMMENDATION
           , RCM.STATUS
      FROM AR_CMGT_CF_RECOMMENDS RCM
         , AR_CMGT_CREDIT_REQUESTS CCR
      WHERE RCM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND RCM.CREDIT_RECOMMENDATION IN ('REJECT', 'APPROVE')
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCR.SOURCE_COLUMN1 = cp_lap_id;

    --Cursor to check for Approve or Reject recommendation for a
    --given Lease Application
    CURSOR credit_decision_csr(p_decision_code VARCHAR2) IS
      SELECT MEANING
      FROM FND_LOOKUPS FL
      WHERE FL.LOOKUP_TYPE = 'OKL_LEASE_APP_STATUS'
        AND FL.LOOKUP_CODE = p_decision_code;

  BEGIN
    IF ( p_lease_app_id IS NULL )
	THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN credit_recom_csr(p_lease_app_id);
    FETCH credit_recom_csr INTO l_cr_recom, l_cr_status;
    CLOSE credit_recom_csr;

    IF l_cr_recom = 'APPROVE' AND l_cr_status = 'I'
    THEN
      OPEN credit_decision_csr('CR-APPROVED');
      FETCH credit_decision_csr INTO l_cr_decision;
      CLOSE credit_decision_csr;
    ELSIF l_cr_recom = 'REJECT' AND l_cr_status = 'I'
    THEN
      OPEN credit_decision_csr('CR-REJECTED');
      FETCH credit_decision_csr INTO l_cr_decision;
      CLOSE credit_decision_csr;
    ELSIF ((l_cr_recom = 'REJECT' OR l_cr_recom = 'APPROVE') AND
               l_cr_status = 'R')
    THEN
         OPEN credit_decision_csr('RECOM_NOT_APPROVED');
         FETCH credit_decision_csr INTO l_cr_decision;
         CLOSE credit_decision_csr;
    END IF;

    RETURN l_cr_decision;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
	THEN
	  RETURN NULL;
	WHEN OTHERS
	THEN
      --Credit Recommendations Cursor
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Credit Decision Cursor
      IF credit_decision_csr%ISOPEN
      THEN
        CLOSE credit_decision_csr;
      END IF;
      OKL_API.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
      RETURN NULL;
  END get_credit_decision;

--Bug 4872214 PAGARG Added functions to return approval expiration date
  -------------------------------------------------------------------------------
  -- FUNCTION get_approval_exp_date
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_approval_exp_date
  -- Description     : This function returns the Credit Approval Expiration Date
  --                   for the given Lease Application
  -- Business Rules  : This function returns the Credit Approval Expiration Date
  --                   for the given Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 14-Dec-2005 PAGARG created
  --
  -- End of comments
  FUNCTION get_approval_exp_date(
           p_lease_app_id       IN NUMBER)
    RETURN DATE
  IS
    --Local variables
    l_cr_recom_count        NUMBER;
    l_exp_date              DATE;

    --Cursor to check for Approve or Reject recommendation for a
    --given Lease Application
    CURSOR credit_recom_csr(cp_lap_id NUMBER) IS
      SELECT COUNT(*)
      FROM AR_CMGT_CF_RECOMMENDS RCM
         , AR_CMGT_CREDIT_REQUESTS CCR
      WHERE RCM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND RCM.CREDIT_RECOMMENDATION IN ('APPROVE', 'EXPIRATION_DATE')
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCR.SOURCE_COLUMN1 = cp_lap_id;

    --Cursor to check for Approve or Reject recommendation for a
    --given Lease Application
    CURSOR case_folder_csr(p_lap_id NUMBER)
    IS
      SELECT LAP.CR_EXP_DAYS + TRUNC(LAST_UPDATED) APPR_EXP_DATE
      FROM AR_CMGT_CASE_FOLDERS CCF
         , AR_CMGT_CREDIT_REQUESTS CCR
         , OKL_LEASE_APPLICATIONS_B LAP
      WHERE CCR.CREDIT_REQUEST_ID = CCF.CREDIT_REQUEST_ID
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCR.SOURCE_COLUMN1 = LAP.ID
        AND CCF.STATUS = 'CLOSED'
		AND LAP.ID = p_lap_id;
  BEGIN
    IF ( p_lease_app_id IS NULL )
	THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN credit_recom_csr(p_lease_app_id);
    FETCH credit_recom_csr INTO l_cr_recom_count;
    CLOSE credit_recom_csr;

    IF l_cr_recom_count = 2
    THEN
      OPEN case_folder_csr(p_lease_app_id);
      FETCH case_folder_csr INTO l_exp_date;
      CLOSE case_folder_csr;
    END IF;

    RETURN l_exp_date;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
	THEN
	  RETURN NULL;
	WHEN OTHERS
	THEN
      --Credit Recommendations Cursor
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Case Folder Cursor
      IF case_folder_csr%ISOPEN
      THEN
        CLOSE case_folder_csr;
      END IF;
      OKL_API.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
      RETURN NULL;
  END get_approval_exp_date;

  --Bug 4872271 PAGARG Added two functions: one to return Credit Decision Appeal
  --Flag and other to return Expiration Date Appeal Flag
  --Start
  -------------------------------------------------------------------------------
  -- FUNCTION get_cr_dec_appeal_flag
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_cr_dec_appeal_flag
  -- Description     : This function returns the appeal flag for Credit Decision
  --                   on the given Lease Application
  -- Business Rules  : This function returns the appeal flag for Credit Decision
  --                   on the given Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 28-Mar-2006 PAGARG created
  --
  -- End of comments
  FUNCTION get_cr_dec_appeal_flag(
           p_lease_app_id       IN NUMBER)
    RETURN VARCHAR2
  IS
    --Local variables
    l_cr_dec_appeal_flag    VARCHAR2(3);
    l_cr_recom              VARCHAR2(30);

    --Cursor to check for Approve or Reject recommendation for a
    --given Lease Application
    CURSOR credit_recom_csr(cp_lap_id NUMBER) IS
      SELECT RCM.CREDIT_RECOMMENDATION
           , RCM.APPEALED_FLAG
      FROM AR_CMGT_CF_RECOMMENDS RCM
         , AR_CMGT_CREDIT_REQUESTS CCR
      WHERE RCM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND RCM.CREDIT_RECOMMENDATION IN ('REJECT', 'APPROVE')
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCR.SOURCE_COLUMN1 = cp_lap_id;
  BEGIN
    IF ( p_lease_app_id IS NULL )
	THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN credit_recom_csr(p_lease_app_id);
    FETCH credit_recom_csr INTO l_cr_recom, l_cr_dec_appeal_flag;
    CLOSE credit_recom_csr;

    RETURN l_cr_dec_appeal_flag;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
	THEN
	  RETURN NULL;
	WHEN OTHERS
	THEN
      --Credit Recommendations Cursor
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      OKL_API.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
      RETURN NULL;
  END get_cr_dec_appeal_flag;

  -------------------------------------------------------------------------------
  -- FUNCTION get_exp_date_appeal_flag
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_exp_date_appeal_flag
  -- Description     : This function returns the appeal flag for Credit Approval
  --                   Expiration Date for the given Lease Application
  -- Business Rules  : This function returns the appeal flag for Credit Approval
  --                   Expiration Date for the given Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 28-Mar-2006 PAGARG created
  --
  -- End of comments
  FUNCTION get_exp_date_appeal_flag(
           p_lease_app_id       IN NUMBER)
    RETURN VARCHAR2
  IS
    --Local variables
    l_cr_recom_count        NUMBER;
    l_exp_date_appeal_flag  VARCHAR2(3);

    --Cursor to check for Approve or Reject recommendation for a
    --given Lease Application
    CURSOR credit_recom_csr(cp_lap_id NUMBER) IS
      SELECT COUNT(*)
      FROM AR_CMGT_CF_RECOMMENDS RCM
         , AR_CMGT_CREDIT_REQUESTS CCR
      WHERE RCM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND RCM.CREDIT_RECOMMENDATION IN ('APPROVE', 'EXPIRATION_DATE')
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCR.SOURCE_COLUMN1 = cp_lap_id;

    --Cursor to check for Approve or Reject recommendation for a
    --given Lease Application
    CURSOR appeal_flag_csr(p_lap_id NUMBER)
    IS
      SELECT RCM.APPEALED_FLAG
      FROM AR_CMGT_CF_RECOMMENDS RCM
         , AR_CMGT_CREDIT_REQUESTS CCR
      WHERE RCM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND RCM.CREDIT_RECOMMENDATION = 'EXPIRATION_DATE'
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCR.SOURCE_COLUMN1 = p_lap_id;
  BEGIN
    IF ( p_lease_app_id IS NULL )
	THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN credit_recom_csr(p_lease_app_id);
    FETCH credit_recom_csr INTO l_cr_recom_count;
    CLOSE credit_recom_csr;

    IF l_cr_recom_count = 2
    THEN
      OPEN appeal_flag_csr(p_lease_app_id);
      FETCH appeal_flag_csr INTO l_exp_date_appeal_flag;
      CLOSE appeal_flag_csr;
    END IF;

    RETURN l_exp_date_appeal_flag;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
	THEN
	  RETURN NULL;
	WHEN OTHERS
	THEN
      --Credit Recommendations Cursor
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Case Folder Cursor
      IF appeal_flag_csr%ISOPEN
      THEN
        CLOSE appeal_flag_csr;
      END IF;
      OKL_API.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
      RETURN NULL;
  END get_exp_date_appeal_flag;
  --Bug 4872271 PAGARG End

  ------------------------------------------------------------------------------
  -- FUNCTION get_next_seq_num
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_next_seq_num
  -- Description     : This function returns the next unique value from the sequence
  --                   for given column column in the table.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 01-Dec-2005 PAGARG Created Bug 4867953
  --
  -- End of comments
  --Bug 7022258-Modified by kkorrapo
  /*FUNCTION get_next_seq_num(
           p_seq_name           IN VARCHAR2,
           p_table_name         IN VARCHAR2,
           p_col_name           IN VARCHAR2)
  RETURN NUMBER
  IS
    l_next_val          NUMBER;
    l_col_value         VARCHAR2(150);
    l_seq_stmt          VARCHAR2(100);
    l_query_stmt        VARCHAR2(100);
    TYPE l_csr_typ IS REF CURSOR;
    l_ref_csr l_csr_typ;
  BEGIN
    l_next_val   := 0;
    l_seq_stmt   := 'SELECT ' || p_seq_name || '.NEXTVAL FROM DUAL';
    l_query_stmt := 'SELECT ' ||
                    p_col_name ||
                    ' FROM ' ||
                    p_table_name ||
                    ' WHERE '||
                    p_col_name || ' = :1 ';
    LOOP
      --Execute the dynamic sql for obtaining next value of sequence
      OPEN l_ref_csr FOR l_seq_stmt;
      FETCH l_ref_csr INTO l_next_val;
        IF l_ref_csr%NOTFOUND THEN
          EXIT;
        END IF;
      CLOSE l_ref_csr;

      --Execute the dynamic sql for validating uniqueness of the next value from sequence
      OPEN l_ref_csr FOR l_query_stmt USING TO_CHAR(l_next_val);
      FETCH l_ref_csr INTO l_col_value;
        IF l_ref_csr%NOTFOUND THEN
          EXIT;
        END IF;
      CLOSE l_ref_csr;
    END LOOP;
    RETURN l_next_val;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF l_ref_csr%ISOPEN
      THEN
        CLOSE l_ref_csr;
      END IF;
      RETURN 0;
      END get_next_seq_num; */

    FUNCTION get_next_seq_num(
	      p_seq_name           IN VARCHAR2,
	      p_table_name         IN VARCHAR2,
	      p_col_name           IN VARCHAR2)
     RETURN VARCHAR2
     IS
       l_next_val          NUMBER;
       l_col_value         VARCHAR2(150);
       l_seq_stmt          VARCHAR2(100);
       l_query_stmt        VARCHAR2(100);
       TYPE l_csr_typ IS REF CURSOR;
       l_ref_csr l_csr_typ;
       CURSOR c_get_prefix(c_table_name IN VARCHAR2) IS
       SELECT DECODE(c_table_name,'OKL_LEASE_QUOTES_B',LSEQTE_SEQ_PREFIX_TXT,'OKL_QUICK_QUOTES_B',QCKQTE_SEQ_PREFIX_TXT,'OKL_LEASE_OPPORTUNITIES_B',LSEOPP_SEQ_PREFIX_TXT,'OKL_LEASE_APPLICATIONS_B',LSEAPP_SEQ_PREFIX_TXT)
       FROM okl_system_params;
       l_prefix VARCHAR2(30);
       l_value  VARCHAR(250);
     BEGIN
       l_next_val   := 0;
       l_seq_stmt   := 'SELECT ' || p_seq_name || '.NEXTVAL FROM DUAL';
       l_query_stmt := 'SELECT ' ||
		       p_col_name ||
		       ' FROM ' ||
		       p_table_name ||
		       ' WHERE '||
		       p_col_name || ' = :1 ';
       --get prefix
       OPEN c_get_prefix(p_table_name);
       FETCH c_get_prefix INTO l_prefix;
       CLOSE c_get_prefix;

       LOOP
	 --Execute the dynamic sql for obtaining next value of sequence
	 OPEN l_ref_csr FOR l_seq_stmt;
	 FETCH l_ref_csr INTO l_next_val;
	   IF l_ref_csr%NOTFOUND THEN
	     EXIT;
	   END IF;
	 CLOSE l_ref_csr;


	 IF l_prefix IS NOT NULL THEN
	  l_value := l_prefix || TO_CHAR(l_next_val);
	 ELSE
	  l_value := TO_CHAR(l_next_val);
	 END IF;

	 --Execute the dynamic sql for validating uniqueness of the next value from sequence
	 OPEN l_ref_csr FOR l_query_stmt USING l_value;
	 FETCH l_ref_csr INTO l_col_value;
	   IF l_ref_csr%NOTFOUND THEN
	     EXIT;
	   END IF;
	 CLOSE l_ref_csr;
       END LOOP;
       RETURN l_value;
     EXCEPTION
       WHEN OTHERS
       THEN
	 IF l_ref_csr%ISOPEN
	 THEN
	   CLOSE l_ref_csr;
	 END IF;
	 RETURN 0;
  --Bug 7022258--Modification end
  END get_next_seq_num;

  -------------------------------------------------------------------------------
  -- PROCEDURE populate_ec_rec
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : populate_ec_rec
  -- Description     : This procedure populates okl_ec_rec_type
  -- Business Rules  : This procedure populates okl_ec_rec_type
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 27-Oct-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE populate_ec_rec(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            lx_okl_ec_rec     IN OUT NOCOPY OKL_ECC_PUB.okl_ec_rec_type)
  IS
    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'POPULATE_EC_REC';
    l_return_status          VARCHAR2(1);
    l_counter                NUMBER;

    l_item_tbl               okl_ec_evaluate_pvt.okl_number_table_type;

    --Cursor to obtain Lease Application Details
    CURSOR lse_app_dtls_csr(cp_lse_app_id NUMBER) IS
      SELECT VALID_FROM VALID_FROM
           , PROSPECT_ID PROSPECT_ID
           , CUST_ACCT_ID CUST_ACCT_ID
           , CURRENCY_CODE CURRENCY_CODE
        FROM OKL_LEASE_APPLICATIONS_B LAB
       WHERE LAB.ID = cp_lse_app_id;
    lse_app_dtls_rec lse_app_dtls_csr%ROWTYPE;

    --Cursor to obtain the details of lease quote line of Lease App
    CURSOR l_lsq_dtls_csr(p_lap_id NUMBER)
	IS
      SELECT LSQ.ID LSQ_ID
           , LSQ.TERM
      FROM OKL_LEASE_QUOTES_B LSQ
      WHERE LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LSQ.PRIMARY_QUOTE= 'Y'
        AND LSQ.PARENT_OBJECT_ID = p_lap_id;
    l_lsq_dtls_rec l_lsq_dtls_csr%ROWTYPE;

    --Cursor to obtain the inventory items of Lease Quote
    CURSOR l_item_csr(p_lsq_id NUMBER)
	IS
      SELECT INV_ITEM_ID
      FROM OKL_ASSET_COMPONENTS_B ASTC
         , OKL_ASSETS_B AST
      WHERE ASTC.ASSET_ID = AST.ID
        AND AST.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND AST.PARENT_OBJECT_ID = p_lsq_id;
    l_item_rec l_item_csr%ROWTYPE;

    --Cursor to obtain the sum of adjustments of Lease Quote
    CURSOR l_adj_sum_csr(p_lsq_id IN NUMBER, cp_adj_src_type IN VARCHAR2)
	IS
      SELECT SUM(ADJ.VALUE)
        FROM OKL_ASSETS_B AST
           , OKL_COST_ADJUSTMENTS_B ADJ
       WHERE AST.PARENT_OBJECT_CODE = 'LEASEQUOTE'
         AND ADJ.PARENT_OBJECT_ID = AST.ID
         AND AST.PARENT_OBJECT_ID = p_lsq_id
         AND ADJ.ADJUSTMENT_SOURCE_TYPE = cp_adj_src_type;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.POPULATE_EC_REC';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate Eligibility criteria rec
    OPEN lse_app_dtls_csr(p_lap_id);
    FETCH lse_app_dtls_csr INTO lse_app_dtls_rec;
    CLOSE lse_app_dtls_csr;

    --Obtain the details of Lease Quote line of Lease App
    OPEN l_lsq_dtls_csr(p_lap_id);
    FETCH l_lsq_dtls_csr INTO l_lsq_dtls_rec;
    CLOSE l_lsq_dtls_csr;

    lx_okl_ec_rec.target_id := p_lap_id;
    lx_okl_ec_rec.target_type := 'LEASE_APP';
    lx_okl_ec_rec.target_eff_from := lse_app_dtls_rec.valid_from;
    lx_okl_ec_rec.term := l_lsq_dtls_rec.term;
    lx_okl_ec_rec.deal_size := get_financed_Amount(l_lsq_dtls_rec.lsq_id);
    lx_okl_ec_rec.customer_credit_class := get_credit_classfication(lse_app_dtls_rec.prospect_id, lse_app_dtls_rec.cust_acct_id, NULL);
    lx_okl_ec_rec.currency_code := lse_app_dtls_rec.currency_code;

    OPEN l_adj_sum_csr(l_lsq_dtls_rec.lsq_id, 'DOWN_PAYMENT');
    FETCH l_adj_sum_csr INTO lx_okl_ec_rec.down_payment;
    CLOSE l_adj_sum_csr;

    OPEN l_adj_sum_csr(l_lsq_dtls_rec.lsq_id, 'TRADEIN');
    FETCH l_adj_sum_csr INTO lx_okl_ec_rec.trade_in_value;
    CLOSE l_adj_sum_csr;

    l_counter := 1;
    FOR l_item_rec IN l_item_csr(l_lsq_dtls_rec.lsq_id)
    LOOP
      l_item_tbl(l_counter) := l_item_rec.inv_item_id;
    END LOOP;
    lx_okl_ec_rec.item_table := l_item_tbl;

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease Application Details cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      --Lease Quote Details Cursor
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      --Inventory Item Id Cursor
      IF l_item_csr%ISOPEN
      THEN
        CLOSE l_item_csr;
      END IF;
      --Sum of Adjustment Cursor
      IF l_adj_sum_csr%ISOPEN
      THEN
        CLOSE l_adj_sum_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease Application Details cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      --Lease Quote Details Cursor
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      --Inventory Item Id Cursor
      IF l_item_csr%ISOPEN
      THEN
        CLOSE l_item_csr;
      END IF;
      --Sum of Adjustment Cursor
      IF l_adj_sum_csr%ISOPEN
      THEN
        CLOSE l_adj_sum_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Lease Application Details cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      --Lease Quote Details Cursor
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      --Inventory Item Id Cursor
      IF l_item_csr%ISOPEN
      THEN
        CLOSE l_item_csr;
      END IF;
      --Sum of Adjustment Cursor
      IF l_adj_sum_csr%ISOPEN
      THEN
        CLOSE l_adj_sum_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END populate_ec_rec;

  -------------------------------------------------------------------------------
  -- FUNCTION get_financed_amount
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_financed_amount
  -- Description     : This function returns the financed amount for given
  --                   Lease Quote
  -- Business Rules  : This function returns the financed amount for given
  --                   Lease Quote
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 23-SEP-2005 PAGARG created
  --
  -- End of comments
  FUNCTION get_financed_amount(
           p_lease_qte_id       IN NUMBER)
    RETURN NUMBER
  IS
    --cursor to find total capital amount
    CURSOR l_cap_amnt_csr(p_lsq_id NUMBER)
	IS
      SELECT NVL(SUM(ASS.OEC), 0) ASSET_AMOUNT
      FROM OKL_ASSETS_B ASS
      WHERE ASS.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND ASS.PARENT_OBJECT_ID = p_lsq_id;

    -- cursor to find total Rollover Fee Amount for a Lease Application
    CURSOR l_fee_csr(p_lsq_id NUMBER, p_fee_type VARCHAR2)
	IS
      SELECT NVL(SUM(FEE.FEE_AMOUNT), 0) FEE_AMOUNT
      FROM OKL_FEES_B FEE
      WHERE FEE.FEE_TYPE = p_fee_type
        AND FEE.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND FEE.PARENT_OBJECT_ID = p_lsq_id;

    -- added for bug 6596860 --
    CURSOR l_adj_sum_csr(p_lsq_id IN NUMBER)
   	IS
         SELECT NVL(SUM(VALUE), 0 )
           FROM OKL_ASSETS_B AST
              , OKL_COST_ADJUSTMENTS_B ADJ
          WHERE AST.PARENT_OBJECT_CODE = 'LEASEQUOTE'
            AND ADJ.PARENT_OBJECT_ID = AST.ID
            AND ADJ.ADJUSTMENT_SOURCE_TYPE  IN ('DOWN_PAYMENT', 'TRADEIN')
            AND AST.PARENT_OBJECT_ID = p_lsq_id;


    l_rollover_fee     NUMBER;
    l_capital_amount   NUMBER;
    l_financed_fee     NUMBER;
    l_financed_amount  NUMBER;
    l_adj_amount 	   NUMBER;   -- added for bug 6596860 --
    l_capitalized_fee  NUMBER; --added for bug 6697231 --

  BEGIN
    IF ( p_lease_qte_id IS NULL )
	THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_capital_amount := 0;
    l_financed_fee   := 0;
    l_financed_amount := 0;
    l_rollover_fee := 0;
    l_adj_amount :=0;   -- added for bug 6596860 --
    l_capitalized_fee:=0; --added for bug 6697231 --

    OPEN l_cap_amnt_csr(p_lease_qte_id);
    FETCH l_cap_amnt_csr INTO l_capital_amount;
    CLOSE l_cap_amnt_csr;

    OPEN l_fee_csr(p_lease_qte_id, 'ROLLOVER');
    FETCH l_fee_csr INTO l_rollover_fee;
    CLOSE l_fee_csr;

    OPEN l_fee_csr(p_lease_qte_id, 'FINANCED');
    FETCH l_fee_csr INTO l_financed_fee;
    CLOSE l_fee_csr;

    --added for bug 6697231
    OPEN l_fee_csr(p_lease_qte_id, 'CAPITALIZED');
    FETCH l_fee_csr INTO l_capitalized_fee;
    CLOSE l_fee_csr;
    --added for bug 6697231:End

    -- added for bug 6596860 --
    OPEN l_adj_sum_csr(p_lease_qte_id);
    FETCH l_adj_sum_csr INTO l_adj_amount;
    CLOSE l_adj_sum_csr;

    --bug 6697231: added capitalized fee
    l_financed_amount := l_capital_amount + l_financed_fee + l_rollover_fee + l_capitalized_fee - l_adj_amount ; -- Subtract adjusted amount (Bug 6596860)

    RETURN l_financed_amount;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
	THEN
	  RETURN 0;
	WHEN OTHERS
	THEN
      --Capital Amount cursor
      IF l_cap_amnt_csr%ISOPEN
      THEN
        CLOSE l_cap_amnt_csr;
      END IF;
      --Fee Amount cursor
      IF l_fee_csr%ISOPEN
      THEN
        CLOSE l_fee_csr;
      END IF;
      OKL_API.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
      RETURN 0;
  END get_financed_amount;

  -------------------------------------------------------------------------------
  -- PROCEDURE populate_lease_app
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : populate_lease_app
  -- Description     : This procedure populates lapv_rec and lsqv_rec with the
  --                 : database values for a given lease application.
  -- Business Rules  : This procedure populates lapv_rec and lsqv_rec with the
  --                 : database values for a given lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 30-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE populate_lease_app(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type) IS

    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'POPULATE_LEASE_APP';
    l_return_status          VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec      lsqv_rec_type;

    --Cursor to populate Lease Application details from database
    CURSOR lap_db_val_csr(cp_lap_id NUMBER) IS
      SELECT LAB.ID ID
           , LAB.REFERENCE_NUMBER LEASE_APPL_NUMBER
           , LAB.APPLICATION_STATUS LEASE_APPL_STATUS_CODE
           , LAB.VALID_FROM VALID_FROM
           , LAB.VALID_TO VALID_TO
           , LAB.PROSPECT_ID PROSPECT_ID
           , LAB.PROSPECT_ADDRESS_ID PROSPECT_ADDRESS_ID
           , LAB.CUST_ACCT_ID CUST_ACCT_ID
           , LAB.CURRENCY_CODE CURRENCY_CODE
           , LAB.CURRENCY_CONVERSION_TYPE CONVERSION_TYPE
           , LAB.CURRENCY_CONVERSION_RATE CONVERSION_RATE
           , LAB.CURRENCY_CONVERSION_DATE CONVERSION_DATE
           , LAB.LEASEAPP_TEMPLATE_ID LEASEAPP_TEMPLATE_ID
           , LAB.LEASE_OPPORTUNITY_ID LEASE_OPPORTUNITY_ID
           , LAB.CREDIT_LINE_ID CREDIT_LINE_ID
           , LAB.PROGRAM_AGREEMENT_ID PROGRAM_AGREEMENT_ID
           , LAB.MASTER_LEASE_ID MASTER_LEASE_ID
           , LAB.SALES_REP_ID SALES_REP_ID
           , LAB.SALES_TERRITORY_ID SALES_TERRITORY_ID
           , LAB.INDUSTRY_CODE INDUSTRY_CODE
           , LAB.INDUSTRY_CLASS INDUSTRY_CLASS
           , LAT.SHORT_DESCRIPTION DESCRIPTION
           , LAB.ORG_ID ORG_ID
           , LAB.OBJECT_VERSION_NUMBER OBJECT_VERSION_NUMBER
           , LAB.CREATED_BY CREATED_BY
           , LAB.CREATION_DATE CREATION_DATE
           , LAB.PARENT_LEASEAPP_ID PARENT_LEASEAPP_ID
           , LAB.ACTION ACTION
           , LAB.ORIG_STATUS ORIG_STATUS
           , LQ.ID LSE_QTE_ID
           , LQ.REFERENCE_NUMBER QUOTE_NUMBER
           , LQ.STATUS STATUS_CODE
           , LQ.VALID_FROM LQ_VALID_FROM
           , LQ.VALID_TO LQ_VALID_TO
           , LQ.PRICING_METHOD PRICING_METHOD_CODE
           , LQ.TERM TERM
           , LQ.PRODUCT_ID PRODUCT_ID
           , LQ.END_OF_TERM_OPTION_ID END_OF_TERM_OPTION_ID
           , LQ.PROPERTY_TAX_APPLICABLE PROPERTY_TAX_APPLICABLE_CODE
           , LQ.PROPERTY_TAX_BILLING_TYPE PROPERTY_TAX_BILLING_TYPE_CODE
           , LQ.UPFRONT_TAX_TREATMENT UPFRONT_TAX_TREATMENT_CODE
           , LQ.PURCHASE_OF_LEASE PURCHASE_OF_LEASE_CODE
           , LQ.SALE_AND_LEASE_BACK SALE_AND_LEASE_BACK_CODE
           , LQ.INTEREST_DISCLOSED INTEREST_DISCLOSED_CODE
           , LQ.TRANSFER_OF_TITLE TRANSFER_OF_TITLE_CODE
           , LQ.USAGE_CATEGORY USAGE_CATEGORY
           , LQ.AGE_OF_EQUIPMENT AGE_OF_EQUIPMENT
           , LQ.UPFRONT_TAX_STREAM_TYPE UPFRONT_TAX_STY_ID
           , LQ.PARENT_OBJECT_CODE PARENT_OBJECT_CODE
           , LQ.PARENT_OBJECT_ID PARENT_OBJECT_ID
           , LQ.EXPECTED_START_DATE LQ_EXPECTED_START_DATE
           , LQ.OBJECT_VERSION_NUMBER LQ_OBJECT_VERSION_NUMBER
            --asawanka bug 4721141 start
           , LQ.EXPECTED_FUNDING_DATE LQ_EXPECTED_FUNDING_DATE
           , LQ.EXPECTED_DELIVERY_DATE LQ_EXPECTED_DELIVERY_DATE
            --asawanka bug 4721141 end
	    --Added Bug 5647107 ssdeshpa start
           , LQ.LEGAL_ENTITY_ID LEGAL_ENTITY_ID
           --Added Bug 5647107 ssdeshpa start
      FROM OKL_LEASE_APPLICATIONS_B LAB
         , OKL_LEASE_APPLICATIONS_TL LAT
         , OKL_LEASE_QUOTES_B LQ
      WHERE LAB.ID = LAT.ID
        AND LAT.LANGUAGE = USERENV('LANG')
        AND LQ.PARENT_OBJECT_ID = LAB.ID
        AND LQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LQ.PRIMARY_QUOTE = 'Y'
        AND LAB.ID = cp_lap_id;
    lap_db_val_rec lap_db_val_csr%ROWTYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.POPULATE_LEASE_APP';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate lease application rec with database values
    IF(p_lap_id IS NOT NULL AND
       p_lap_id <> OKL_API.G_MISS_NUM)
    THEN
      OPEN lap_db_val_csr(p_lap_id);
      FETCH lap_db_val_csr INTO lap_db_val_rec;
        IF(lap_db_val_csr%NOTFOUND)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_SO_LSE_APP_INVALID');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
          l_lapv_rec.id := lap_db_val_rec.id;
          l_lapv_rec.reference_number := lap_db_val_rec.lease_appl_number;
          l_lapv_rec.application_status := lap_db_val_rec.lease_appl_status_code;
          l_lapv_rec.valid_from := lap_db_val_rec.valid_from;
          l_lapv_rec.valid_to := lap_db_val_rec.valid_to;
          l_lapv_rec.prospect_id := lap_db_val_rec.prospect_id;
          l_lapv_rec.prospect_address_id := lap_db_val_rec.prospect_address_id;
          l_lapv_rec.cust_acct_id := lap_db_val_rec.cust_acct_id;
          l_lapv_rec.currency_code := lap_db_val_rec.currency_code;
          l_lapv_rec.currency_conversion_type := lap_db_val_rec.conversion_type;
          l_lapv_rec.currency_conversion_rate := lap_db_val_rec.conversion_rate;
          l_lapv_rec.currency_conversion_date := lap_db_val_rec.conversion_date;
          l_lapv_rec.leaseapp_template_id := lap_db_val_rec.leaseapp_template_id;
          l_lapv_rec.lease_opportunity_id := lap_db_val_rec.lease_opportunity_id;
          l_lapv_rec.credit_line_id := lap_db_val_rec.credit_line_id;
          l_lapv_rec.program_agreement_id := lap_db_val_rec.program_agreement_id;
          l_lapv_rec.master_lease_id := lap_db_val_rec.master_lease_id;
          l_lapv_rec.sales_rep_id := lap_db_val_rec.sales_rep_id;
          l_lapv_rec.sales_territory_id := lap_db_val_rec.sales_territory_id;
          l_lapv_rec.industry_code := lap_db_val_rec.industry_code;
          l_lapv_rec.industry_class := lap_db_val_rec.industry_class;
          l_lapv_rec.short_description := lap_db_val_rec.description;
          l_lapv_rec.org_id := lap_db_val_rec.org_id;
          l_lapv_rec.object_version_number := lap_db_val_rec.object_version_number;
          l_lapv_rec.parent_leaseapp_id := lap_db_val_rec.parent_leaseapp_id;
          l_lapv_rec.action := lap_db_val_rec.action;
          l_lapv_rec.orig_status := lap_db_val_rec.orig_status;
          l_lsqv_rec.id := lap_db_val_rec.lse_qte_id;
          l_lsqv_rec.reference_number := lap_db_val_rec.quote_number;
          l_lsqv_rec.status := lap_db_val_rec.status_code;
          l_lsqv_rec.valid_from := lap_db_val_rec.lq_valid_from;
          l_lsqv_rec.valid_to := lap_db_val_rec.lq_valid_to;
          l_lsqv_rec.pricing_method := lap_db_val_rec.pricing_method_code;
          l_lsqv_rec.term := lap_db_val_rec.term;
          l_lsqv_rec.product_id := lap_db_val_rec.product_id;
          l_lsqv_rec.end_of_term_option_id := lap_db_val_rec.end_of_term_option_id;
          l_lsqv_rec.property_tax_applicable := lap_db_val_rec.property_tax_applicable_code;
          l_lsqv_rec.property_tax_billing_type := lap_db_val_rec.property_tax_billing_type_code;
          l_lsqv_rec.upfront_tax_treatment := lap_db_val_rec.upfront_tax_treatment_code;
          l_lsqv_rec.purchase_of_lease := lap_db_val_rec.purchase_of_lease_code;
          l_lsqv_rec.sale_and_lease_back := lap_db_val_rec.sale_and_lease_back_code;
          l_lsqv_rec.interest_disclosed := lap_db_val_rec.interest_disclosed_code;
          l_lsqv_rec.transfer_of_title := lap_db_val_rec.transfer_of_title_code;
          l_lsqv_rec.usage_category := lap_db_val_rec.usage_category;
          l_lsqv_rec.age_of_equipment := lap_db_val_rec.age_of_equipment;
          l_lsqv_rec.upfront_tax_stream_type := lap_db_val_rec.upfront_tax_sty_id;
          l_lsqv_rec.parent_object_code := lap_db_val_rec.parent_object_code;
          l_lsqv_rec.parent_object_id := lap_db_val_rec.parent_object_id;
          l_lsqv_rec.expected_start_date := lap_db_val_rec.lq_expected_start_date;
          l_lsqv_rec.object_version_number := lap_db_val_rec.lq_object_version_number;
          --asawanka bug 4721141 start
          l_lsqv_rec.expected_funding_date := lap_db_val_rec.lq_expected_funding_date;
          l_lsqv_rec.expected_delivery_date := lap_db_val_rec.lq_expected_delivery_date;
          --asawanka bug 4721141 end
	  --Added Bug 5647107 ssdeshpa start
          l_lsqv_rec.legal_entity_id := lap_db_val_rec.legal_entity_id;
          --Added Bug 5647107 ssdeshpa end
        END IF;
      CLOSE lap_db_val_csr;
    ELSE
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_LSE_APP_INVALID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; --Lease Application Id is null or G_MISS_NUM

    x_lapv_rec := l_lapv_rec;
    x_lsqv_rec := l_lsqv_rec;
    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease Application Details cursor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease Application Details cursor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Lease Application Details cursor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END populate_lease_app;

  -------------------------------------------------------------------------------
  -- PROCEDURE pop_checklist_item
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : pop_checklist_item
  -- Description     : This procedure populates cldv_rec with the database values
  --                   for a given Checklist Item Id.
  -- Business Rules  : This procedure populates cldv_rec with the database values
  --                   for a given Checklist Item Id.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 28-MAR-2006 PAGARG created
  --
  -- End of comments
  PROCEDURE pop_checklist_item(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_cld_id             IN  OKL_CHECKLIST_DETAILS.ID%TYPE,
            x_cldv_rec           OUT NOCOPY OKL_CLD_PVT.CLDV_REC_TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'POP_CHECKLIST_ITEM';
    l_return_status          VARCHAR2(1);

    -- Record/Table Type Declarations
    l_cldv_rec      OKL_CLD_PVT.CLDV_REC_TYPE;

    --Cursor to populate Lease Application details from database
    CURSOR cld_db_val_csr(cp_cld_id NUMBER) IS
      SELECT CLD.ID ID
           , CLD.OBJECT_VERSION_NUMBER OBJECT_VERSION_NUMBER
           , CLD.CKL_ID CKL_ID
           , CLD.TODO_ITEM_CODE TODO_ITEM_CODE
           , CLD.ATTRIBUTE_CATEGORY ATTRIBUTE_CATEGORY
           , CLD.ATTRIBUTE1 ATTRIBUTE1
           , CLD.ATTRIBUTE2 ATTRIBUTE2
           , CLD.ATTRIBUTE3 ATTRIBUTE3
           , CLD.ATTRIBUTE4 ATTRIBUTE4
           , CLD.ATTRIBUTE5 ATTRIBUTE5
           , CLD.ATTRIBUTE6 ATTRIBUTE6
           , CLD.ATTRIBUTE7 ATTRIBUTE7
           , CLD.ATTRIBUTE8 ATTRIBUTE8
           , CLD.ATTRIBUTE9 ATTRIBUTE9
           , CLD.ATTRIBUTE10 ATTRIBUTE10
           , CLD.ATTRIBUTE11 ATTRIBUTE11
           , CLD.ATTRIBUTE12 ATTRIBUTE12
           , CLD.ATTRIBUTE13 ATTRIBUTE13
           , CLD.ATTRIBUTE14 ATTRIBUTE14
           , CLD.ATTRIBUTE15 ATTRIBUTE15
           , CLD.ORG_ID ORG_ID
           , CLD.MANDATORY_FLAG MANDATORY_FLAG
           , CLD.USER_COMPLETE_FLAG USER_COMPLETE_FLAG
           , CLD.ADMIN_NOTE ADMIN_NOTE
           , CLD.USER_NOTE USER_NOTE
           , CLD.FUNCTION_VALIDATE_RSTS FUNCTION_VALIDATE_RSTS
           , CLD.FUNCTION_VALIDATE_MSG FUNCTION_VALIDATE_MSG
           , CLD.DNZ_CHECKLIST_OBJ_ID DNZ_CHECKLIST_OBJ_ID
           , CLD.FUNCTION_ID FUNCTION_ID
           , CLD.INST_CHECKLIST_TYPE INST_CHECKLIST_TYPE
           , CLD.APPEAL_FLAG APPEAL_FLAG
      FROM OKL_CHECKLIST_DETAILS CLD
      WHERE CLD.ID = cp_cld_id;
    cld_db_val_rec cld_db_val_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.POP_CHECKLIST_ITEM';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate lease application rec with database values
    IF(p_cld_id IS NOT NULL AND
       p_cld_id <> OKL_API.G_MISS_NUM)
    THEN
      OPEN cld_db_val_csr(p_cld_id);
      FETCH cld_db_val_csr INTO cld_db_val_rec;
        IF(cld_db_val_csr%FOUND)
        THEN
          l_cldv_rec.id := cld_db_val_rec.id;
          l_cldv_rec.object_version_number := cld_db_val_rec.object_version_number;
          l_cldv_rec.ckl_id := cld_db_val_rec.ckl_id;
          l_cldv_rec.todo_item_code := cld_db_val_rec.todo_item_code;
          l_cldv_rec.attribute_category := cld_db_val_rec.attribute_category;
          l_cldv_rec.attribute1 := cld_db_val_rec.attribute1;
          l_cldv_rec.attribute2 := cld_db_val_rec.attribute2;
          l_cldv_rec.attribute3 := cld_db_val_rec.attribute3;
          l_cldv_rec.attribute4 := cld_db_val_rec.attribute4;
          l_cldv_rec.attribute5 := cld_db_val_rec.attribute5;
          l_cldv_rec.attribute6 := cld_db_val_rec.attribute6;
          l_cldv_rec.attribute7 := cld_db_val_rec.attribute7;
          l_cldv_rec.attribute8 := cld_db_val_rec.attribute8;
          l_cldv_rec.attribute9 := cld_db_val_rec.attribute9;
          l_cldv_rec.attribute10 := cld_db_val_rec.attribute10;
          l_cldv_rec.attribute11 := cld_db_val_rec.attribute11;
          l_cldv_rec.attribute12 := cld_db_val_rec.attribute12;
          l_cldv_rec.attribute13 := cld_db_val_rec.attribute13;
          l_cldv_rec.attribute14 := cld_db_val_rec.attribute14;
          l_cldv_rec.attribute15 := cld_db_val_rec.attribute15;
          l_cldv_rec.org_id := cld_db_val_rec.org_id;
          l_cldv_rec.mandatory_flag := cld_db_val_rec.mandatory_flag;
          l_cldv_rec.user_complete_flag := cld_db_val_rec.user_complete_flag;
          l_cldv_rec.admin_note := cld_db_val_rec.admin_note;
          l_cldv_rec.user_note := cld_db_val_rec.user_note;
          l_cldv_rec.function_validate_rsts := cld_db_val_rec.function_validate_rsts;
          l_cldv_rec.function_validate_msg := cld_db_val_rec.function_validate_msg;
          l_cldv_rec.dnz_checklist_obj_id := cld_db_val_rec.dnz_checklist_obj_id;
          l_cldv_rec.function_id := cld_db_val_rec.function_id;
          l_cldv_rec.inst_checklist_type := cld_db_val_rec.inst_checklist_type;
          l_cldv_rec.appeal_flag := cld_db_val_rec.appeal_flag;
        END IF;
      CLOSE cld_db_val_csr;
    END IF;--Checklist Details Id is null or G_MISS_NUM

    x_cldv_rec := l_cldv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Checklist Details cursor
      IF cld_db_val_csr%ISOPEN
      THEN
        CLOSE cld_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Checklist Details cursor
      IF cld_db_val_csr%ISOPEN
      THEN
        CLOSE cld_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Checklist Details cursor
      IF cld_db_val_csr%ISOPEN
      THEN
        CLOSE cld_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END pop_checklist_item;

  ------------------------------------------------------------------------------
  -- PROCEDURE set_in_progress_status
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : set_in_progress_status
  -- Description     : This procedure sets the in progress status for lease
  --                   application based on the type of action
  --                   THIS PROCEDURE IS ONLY FOR OKL INTERNAL DEVELOPMENT PURPOSE
  -- Business Rules  : This procedure sets the in progress status for lease
  --                   application based on the type of action. It will store the
  --                   current status in orig_status
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 28-Feb-2006 PAGARG created Bug 4872271
  --
  -- End of comments
  PROCEDURE set_in_progress_status(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            p_action             IN  VARCHAR2,
			x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'SET_IN_PROGRESS_STATUS';
    l_return_status            VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    x_lapv_rec		lapv_rec_type;
    x_lsqv_rec      lsqv_rec_type;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.SET_IN_PROGRESS_STATUS';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate Lease Application rec with the values from database.
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call POPULATE_LEASE_APP');
    END IF;

    POPULATE_LEASE_APP(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lap_id                => p_lap_id
       ,x_lapv_rec              => x_lapv_rec
       ,x_lsqv_rec              => x_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call POPULATE_LEASE_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of POPULATE_LEASE_APP'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := x_lapv_rec;
    l_lapv_rec.orig_status := l_lapv_rec.application_status;
    IF(p_action = 'APPEAL')
    THEN
      l_lapv_rec.application_status := 'APPEALINPROG';
    ELSIF(p_action = 'RESUBMIT')
    THEN
      l_lapv_rec.application_status := 'RESUBMITINPROG';
    END IF;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_LAP_PVT.UPDATE_ROW');
    END IF;

    OKL_LAP_PVT.UPDATE_ROW(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lapv_rec              => l_lapv_rec
       ,x_lapv_rec              => x_lapv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_LAP_PVT.UPDATE_ROW');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_LAP_PVT.UPDATE_ROW'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END set_in_progress_status;

  ------------------------------------------------------------------------------
  -- PROCEDURE revert_to_orig_status
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : revert_to_orig_status
  -- Description     : This procedure updates the status of parent lease
  --                   application with the status stored in orig_status
  --                   THIS PROCEDURE IS ONLY FOR OKL INTERNAL DEVELOPMENT PURPOSE
  -- Business Rules  : This procedure updates the status of parent lease
  --                   application with the status stored in orig_status. It will
  --                   then clear the value in orig_status
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 28-Feb-2006 PAGARG created Bug 4872271
  --
  -- End of comments
  PROCEDURE revert_to_orig_status(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'REVERT_TO_ORIG_STATUS';
    l_return_status            VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    x_lapv_rec		lapv_rec_type;
    x_lsqv_rec      lsqv_rec_type;

    --Cursor to obtain Parent Lease Application Details
    CURSOR lse_app_dtls_csr(cp_lse_app_id NUMBER) IS
      SELECT PLAB.ID PARENT_LSE_APP_ID
           , PLAB.APPLICATION_STATUS PARENT_LSE_APP_STS
        FROM OKL_LEASE_APPLICATIONS_B LAB
           , OKL_LEASE_APPLICATIONS_B PLAB
       WHERE LAB.ID = cp_lse_app_id
         AND PLAB.ID = LAB.PARENT_LEASEAPP_ID;
    lse_app_dtls_rec lse_app_dtls_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.REVERT_TO_ORIG_STATUS';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN lse_app_dtls_csr(p_lap_id);
    FETCH lse_app_dtls_csr INTO lse_app_dtls_rec;
    CLOSE lse_app_dtls_csr;

    IF(lse_app_dtls_rec.parent_lse_app_id IS NOT NULL
       AND lse_app_dtls_rec.parent_lse_app_sts IN ('APPEALINPROG', 'RESUBMITINPROG') )
    THEN
      --Populate Lease Application rec with the values from database.
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call POPULATE_LEASE_APP');
      END IF;

      POPULATE_LEASE_APP(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_lap_id                => lse_app_dtls_rec.parent_lse_app_id
         ,x_lapv_rec              => x_lapv_rec
         ,x_lsqv_rec              => x_lsqv_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call POPULATE_LEASE_APP');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of POPULATE_LEASE_APP'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_lapv_rec := x_lapv_rec;
      l_lapv_rec.application_status := l_lapv_rec.orig_status;
      l_lapv_rec.orig_status := NULL;

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_LAP_PVT.UPDATE_ROW');
      END IF;

      OKL_LAP_PVT.UPDATE_ROW(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_lapv_rec              => l_lapv_rec
         ,x_lapv_rec              => x_lapv_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_LAP_PVT.UPDATE_ROW');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_LAP_PVT.UPDATE_ROW'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;--if parent lease app id is not null and status is in progress status

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease Application Details cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease Application Details cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Lease Application Details cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END revert_to_orig_status;

  -------------------------------------------------------------------------------
  -- PROCEDURE check_lease_quote_defaults
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_lease_quote_defaults
  -- Description     : This procedure checks the values defaulted in lease
  --                 : application from lease quote.
  -- Business Rules  : If default values from lease quote are not changed then
  --                 : set the status as Pricing Approved else Incomplete
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 30-MAY-2005 PAGARG created
  --                 : 02 Jan 2006 PAGARG Bug 4902717 Fixed the cursor to compare
  --                   default values
  --                 : 18 Jan 2006 PAGARG BUG 4951955 Instead of lapv_rec, take source
  --                   Lease Quote Id as input so that this procedure can be reused
  --                 : 17 Feb 2006 PAGARG BUG 4905261 Included comparison of some
  --                   header level attributes to identify if there are any changes done
  -- End of comments
  PROCEDURE check_lease_quote_defaults(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_source_lsq_id      IN  OKL_LEASE_QUOTES_B.ID%TYPE,
            p_lapv_rec           IN  lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type)
  IS
    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'CHECK_LEASE_QUOTE_DEFAULTS';
    l_return_status          VARCHAR2(1);

    --02 Jan 2006 PAGARG Bug 4902717 Fixed the condition to compare default values
    --as values passed from java layer will not be null but G_MISS
    --BUG 4936112 PAGARG Removed the check for pricing method
    --BUG 4951955 PAGARG Instead of Lease Opp id, Lease Quote id is the input
    --Cursor to query the default values from lease quote
    CURSOR lsq_db_val_csr(cp_lsq_id NUMBER, cp_lsqv_rec lsqv_rec_type) IS
      SELECT LQ.REFERENCE_NUMBER REFERENCE_NUMBER
      FROM OKL_LEASE_QUOTES_B LQ
      WHERE LQ.ID = cp_lsq_id
--        AND NVL(LQ.PRICING_METHOD, OKL_API.G_MISS_CHAR) = NVL(cp_lsqv_rec.PRICING_METHOD, OKL_API.G_MISS_CHAR)
        AND NVL(LQ.EXPECTED_START_DATE, OKL_API.G_MISS_DATE) = NVL(cp_lsqv_rec.EXPECTED_START_DATE, OKL_API.G_MISS_DATE)
        AND NVL(LQ.VALID_FROM, OKL_API.G_MISS_DATE) = NVL(cp_lsqv_rec.VALID_FROM, OKL_API.G_MISS_DATE)
        AND NVL(LQ.VALID_TO, OKL_API.G_MISS_DATE) = NVL(cp_lsqv_rec.VALID_TO, OKL_API.G_MISS_DATE)
        AND NVL(LQ.TERM, OKL_API.G_MISS_NUM) = NVL(cp_lsqv_rec.TERM, OKL_API.G_MISS_NUM)
        AND NVL(LQ.PRODUCT_ID, OKL_API.G_MISS_NUM) = NVL(cp_lsqv_rec.PRODUCT_ID, OKL_API.G_MISS_NUM)
        AND NVL(LQ.END_OF_TERM_OPTION_ID, OKL_API.G_MISS_NUM) = NVL(cp_lsqv_rec.END_OF_TERM_OPTION_ID, OKL_API.G_MISS_NUM)
        AND NVL(LQ.PROPERTY_TAX_APPLICABLE, OKL_API.G_MISS_CHAR) = NVL(cp_lsqv_rec.PROPERTY_TAX_APPLICABLE, OKL_API.G_MISS_CHAR)
        AND NVL(LQ.PROPERTY_TAX_BILLING_TYPE, OKL_API.G_MISS_CHAR) = NVL(cp_lsqv_rec.PROPERTY_TAX_BILLING_TYPE, OKL_API.G_MISS_CHAR)
        AND NVL(LQ.USAGE_CATEGORY, OKL_API.G_MISS_CHAR) = NVL(cp_lsqv_rec.USAGE_CATEGORY, OKL_API.G_MISS_CHAR)
        AND NVL(LQ.UPFRONT_TAX_TREATMENT, OKL_API.G_MISS_CHAR) = NVL(cp_lsqv_rec.UPFRONT_TAX_TREATMENT, OKL_API.G_MISS_CHAR)
        AND NVL(LQ.UPFRONT_TAX_STREAM_TYPE, OKL_API.G_MISS_NUM) = NVL(cp_lsqv_rec.UPFRONT_TAX_STREAM_TYPE, OKL_API.G_MISS_NUM)
        AND NVL(LQ.TRANSFER_OF_TITLE, OKL_API.G_MISS_CHAR) = NVL(cp_lsqv_rec.TRANSFER_OF_TITLE, OKL_API.G_MISS_CHAR)
        AND NVL(LQ.AGE_OF_EQUIPMENT, OKL_API.G_MISS_NUM) = NVL(cp_lsqv_rec.AGE_OF_EQUIPMENT, OKL_API.G_MISS_NUM)
        AND NVL(LQ.PURCHASE_OF_LEASE, OKL_API.G_MISS_CHAR) = NVL(cp_lsqv_rec.PURCHASE_OF_LEASE, OKL_API.G_MISS_CHAR)
        AND NVL(LQ.SALE_AND_LEASE_BACK, OKL_API.G_MISS_CHAR) = NVL(cp_lsqv_rec.SALE_AND_LEASE_BACK, OKL_API.G_MISS_CHAR)
        AND NVL(LQ.INTEREST_DISCLOSED, OKL_API.G_MISS_CHAR) = NVL(cp_lsqv_rec.INTEREST_DISCLOSED, OKL_API.G_MISS_CHAR)
	    --Added Bug # 5647107 start
	    AND NVL(LQ.LEGAL_ENTITY_ID, OKL_API.G_MISS_NUM) = NVL(cp_lsqv_rec.LEGAL_ENTITY_ID, OKL_API.G_MISS_NUM)
        --Added Bug # 5647107 end
        -- Bug 5908845. eBTax Enhancement Project
        AND NVL(LQ.LINE_INTENDED_USE, OKL_API.G_MISS_CHAR) = NVL(cp_lsqv_rec.LINE_INTENDED_USE, OKL_API.G_MISS_CHAR);
        -- End Bug 5908845. eBTax Enhancement Project

    lsq_db_val_rec lsq_db_val_csr%ROWTYPE;

    --Cursor to compare the db values of lease app header with the one in rec
    CURSOR lap_db_val_csr(cp_lap_id NUMBER, cp_lapv_rec lapv_rec_type) IS
      SELECT LAP.REFERENCE_NUMBER REFERENCE_NUMBER
      FROM OKL_LEASE_APPLICATIONS_B LAP
      WHERE LAP.ID = cp_lap_id
        AND NVL(LAP.PROSPECT_ADDRESS_ID, OKL_API.G_MISS_NUM) = NVL(cp_lapv_rec.prospect_address_id, OKL_API.G_MISS_NUM)
        AND NVL(LAP.CUST_ACCT_ID, OKL_API.G_MISS_NUM) = NVL(cp_lapv_rec.cust_acct_id, OKL_API.G_MISS_NUM)
        AND NVL(LAP.MASTER_LEASE_ID, OKL_API.G_MISS_NUM) = NVL(cp_lapv_rec.master_lease_id, OKL_API.G_MISS_NUM)
        AND NVL(LAP.CURRENCY_CODE, OKL_API.G_MISS_CHAR) = NVL(cp_lapv_rec.currency_code, OKL_API.G_MISS_CHAR)
        AND NVL(LAP.CURRENCY_CONVERSION_TYPE, OKL_API.G_MISS_CHAR) = NVL(cp_lapv_rec.currency_conversion_type, OKL_API.G_MISS_CHAR)
        AND NVL(LAP.CURRENCY_CONVERSION_RATE, OKL_API.G_MISS_NUM) = NVL(cp_lapv_rec.currency_conversion_rate, OKL_API.G_MISS_NUM)
        AND NVL(LAP.CURRENCY_CONVERSION_DATE, OKL_API.G_MISS_DATE) = NVL(cp_lapv_rec.currency_conversion_date, OKL_API.G_MISS_DATE);
    lap_db_val_rec lap_db_val_csr%ROWTYPE;

    --Cursor to compare the db values of lease app header with the one in rec
    CURSOR lop_db_val_csr(cp_lop_id NUMBER, cp_lapv_rec lapv_rec_type) IS
      SELECT LOP.REFERENCE_NUMBER REFERENCE_NUMBER
      FROM OKL_LEASE_OPPORTUNITIES_B LOP
      WHERE LOP.ID = cp_lop_id
        AND NVL(LOP.PROSPECT_ADDRESS_ID, OKL_API.G_MISS_NUM) = NVL(cp_lapv_rec.prospect_address_id, OKL_API.G_MISS_NUM)
        AND NVL(LOP.CUST_ACCT_ID, OKL_API.G_MISS_NUM) = NVL(cp_lapv_rec.cust_acct_id, OKL_API.G_MISS_NUM)
        AND NVL(LOP.MASTER_LEASE_ID, OKL_API.G_MISS_NUM) = NVL(cp_lapv_rec.master_lease_id, OKL_API.G_MISS_NUM)
        AND NVL(LOP.CURRENCY_CODE, OKL_API.G_MISS_CHAR) = NVL(cp_lapv_rec.currency_code, OKL_API.G_MISS_CHAR)
        AND NVL(LOP.CURRENCY_CONVERSION_TYPE, OKL_API.G_MISS_CHAR) = NVL(cp_lapv_rec.currency_conversion_type, OKL_API.G_MISS_CHAR)
        AND NVL(LOP.CURRENCY_CONVERSION_RATE, OKL_API.G_MISS_NUM) = NVL(cp_lapv_rec.currency_conversion_rate, OKL_API.G_MISS_NUM)
        AND NVL(LOP.CURRENCY_CONVERSION_DATE, OKL_API.G_MISS_DATE) = NVL(cp_lapv_rec.currency_conversion_date, OKL_API.G_MISS_DATE);
    lop_db_val_rec lop_db_val_csr%ROWTYPE;

    --Cursor to obtain parent object information of lease quote
    CURSOR lsq_parent_csr(cp_lsq_id NUMBER) IS
      SELECT LQ.PARENT_OBJECT_CODE PARENT_OBJECT_CODE
           , LQ.PARENT_OBJECT_ID PARENT_OBJECT_ID
      FROM OKL_LEASE_QUOTES_B LQ
      WHERE LQ.ID = cp_lsq_id;
    lsq_parent_rec lsq_parent_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.CHECK_LEASE_QUOTE_DEFAULTS';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate lease application rec with database values
    IF(p_source_lsq_id IS NOT NULL AND
       p_source_lsq_id <> OKL_API.G_MISS_NUM)
    THEN
      OPEN lsq_parent_csr(p_source_lsq_id);
      FETCH lsq_parent_csr INTO lsq_parent_rec;
        IF(lsq_parent_csr%NOTFOUND)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
      CLOSE lsq_parent_csr;

      IF(l_return_status = OKL_API.G_RET_STS_SUCCESS)
      THEN
        IF(lsq_parent_rec.parent_object_code = 'LEASEAPP')
        THEN
          OPEN lap_db_val_csr(lsq_parent_rec.parent_object_id, p_lapv_rec);
          FETCH lap_db_val_csr INTO lap_db_val_rec;
            IF(lap_db_val_csr%NOTFOUND)
            THEN
              l_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;
          CLOSE lap_db_val_csr;
        ELSIF(lsq_parent_rec.parent_object_code = 'LEASEOPP')
        THEN
          OPEN lop_db_val_csr(lsq_parent_rec.parent_object_id, p_lapv_rec);
          FETCH lop_db_val_csr INTO lop_db_val_rec;
            IF(lop_db_val_csr%NOTFOUND)
            THEN
              l_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;
          CLOSE lop_db_val_csr;
        END IF;
      END IF;

      IF(l_return_status = OKL_API.G_RET_STS_SUCCESS)
      THEN
        OPEN lsq_db_val_csr(p_source_lsq_id, p_lsqv_rec);
        FETCH lsq_db_val_csr INTO lsq_db_val_rec;
          IF(lsq_db_val_csr%NOTFOUND)
          THEN
            l_return_status := OKL_API.G_RET_STS_ERROR;
          END IF;
        CLOSE lsq_db_val_csr;
      END IF;
    ELSE
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;--Source Lease Quote Id is null or G_MISS_NUM

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease Quote Details cursor
      IF lsq_db_val_csr%ISOPEN
      THEN
        CLOSE lsq_db_val_csr;
      END IF;
      --Lease App Details cursor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      --Lease Opp Details cursor
      IF lop_db_val_csr%ISOPEN
      THEN
        CLOSE lop_db_val_csr;
      END IF;
      --Lease Quote parent Details cursor
      IF lsq_parent_csr%ISOPEN
      THEN
        CLOSE lsq_parent_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease Quote Details cursor
      IF lsq_db_val_csr%ISOPEN
      THEN
        CLOSE lsq_db_val_csr;
      END IF;
      --Lease App Details cursor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      --Lease Opp Details cursor
      IF lop_db_val_csr%ISOPEN
      THEN
        CLOSE lop_db_val_csr;
      END IF;
      --Lease Quote parent Details cursor
      IF lsq_parent_csr%ISOPEN
      THEN
        CLOSE lsq_parent_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Lease Quote Details cursor
      IF lsq_db_val_csr%ISOPEN
      THEN
        CLOSE lsq_db_val_csr;
      END IF;
      --Lease App Details cursor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      --Lease Opp Details cursor
      IF lop_db_val_csr%ISOPEN
      THEN
        CLOSE lop_db_val_csr;
      END IF;
      --Lease Quote parent Details cursor
      IF lsq_parent_csr%ISOPEN
      THEN
        CLOSE lsq_parent_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END check_lease_quote_defaults;

  -------------------------------------------------------------------------------
  -- PROCEDURE raise_business_event
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : raise_business_event
  -- Description     : This procedure is a wrapper to raise workflow event
  -- Business Rules  : This procedure is a wrapper to raise workflow event
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 01-June-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE raise_business_event(
              p_transaction_id     IN NUMBER,
              p_event_name         IN VARCHAR2) IS

    -- Variables Declarations
    l_parameter_list        wf_parameter_list_t;
    l_key                   VARCHAR2(240);
    l_seq                   NUMBER;

    -- Selects the nextval from sequence, used later for defining event key
    CURSOR okl_key_csr IS
      SELECT okl_wf_item_s.nextval
        FROM dual;

  BEGIN
    SAVEPOINT raise_event;

    OPEN okl_key_csr;
    FETCH okl_key_csr INTO l_seq;
    CLOSE okl_key_csr;

    l_key := p_event_name || l_seq ;

    wf_event.AddParameterToList('TRANSACTION_ID', p_transaction_id, l_parameter_list);

    -- Raise Event
    wf_event.raise(p_event_name  => p_event_name
                  ,p_event_key   => l_key
                  ,p_parameters  => l_parameter_list);

    l_parameter_list.DELETE;
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      IF okl_key_csr%ISOPEN
      THEN
        CLOSE okl_key_csr;
      END IF;

      ROLLBACK TO raise_event;
  END raise_business_event;

  -------------------------------------------------------------------------------
  -- PROCEDURE create_credit_app
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_credit_app
  -- Description     : This procedure is a wrapper that creates credit application
  -- Business Rules  : This procedure creates credit application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 21-JUNE-2005 PAGARG created
  --                 : 20 Jan 2006 PAGARG BUG 4968010 Passing requestor id and
  --                   type appropriately to create Credit Application
  -- End of comments
  PROCEDURE create_credit_app(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            p_crr_rec            IN  crr_rec_type,
            x_crr_rec            OUT NOCOPY crr_rec_type) IS

    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'CREATE_CREDIT_APP';
    l_return_status          VARCHAR2(1);
    l_cm_installed           BOOLEAN;

    --Variables for create Credit Application call
    l_init_msg_list               VARCHAR2(32767);

    -- Record/Table Type Declarations
    l_crr_rec                crr_rec_type;

    --Cursor to obtain Lease Application Details
    CURSOR lse_app_dtls_csr(cp_lse_app_id NUMBER) IS
      SELECT LAB.REFERENCE_NUMBER REFERENCE_NUMBER
            ,LSQ.EXPECTED_START_DATE EXPECTED_START_DATE
            ,LAT.CREDIT_REVIEW_PURPOSE REVIEW_TYPE
            ,LAT.CUST_CREDIT_CLASSIFICATION CREDIT_CLASSIFICATION
            ,LAB.CURRENCY_CODE CURRENCY_CODE
            ,LSQ.TERM TERM
            ,LAB.PROSPECT_ID PROSPECT_ID
            ,LAB.CUST_ACCT_ID CUST_ACCT_ID
            ,LAB.ORG_ID ORG_ID
            ,LAB.CREDIT_LINE_ID CREDIT_LINE_ID
            ,LSQ.ID LSQ_ID
        FROM OKL_LEASE_APPLICATIONS_B LAB
            ,OKL_LEASEAPP_TEMPLATES LAT
            ,OKL_LEASE_QUOTES_B LSQ
            ,OKL_LEASEAPP_TEMPL_VERSIONS_V LATV
       WHERE LATV.ID = LAB.LEASEAPP_TEMPLATE_ID
         AND LAT.ID = LATV.LEASEAPP_TEMPLATE_ID
         AND LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
         AND LSQ.PARENT_OBJECT_ID = LAB.ID
         AND LSQ.PRIMARY_QUOTE = 'Y'
         AND LAB.ID = cp_lse_app_id;
    lse_app_dtls_rec lse_app_dtls_csr%ROWTYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.CREATE_CREDIT_APP';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_cm_installed := AR_CMGT_CREDIT_REQUEST_API.is_Credit_Management_Installed;
    IF NOT l_cm_installed
    THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_CM_NOTINSTALLED');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_crr_rec := p_crr_rec;

    OPEN lse_app_dtls_csr(p_lapv_rec.id);
    FETCH lse_app_dtls_csr INTO lse_app_dtls_rec;
    CLOSE lse_app_dtls_csr;

    l_crr_rec.application_number := lse_app_dtls_rec.reference_number;
    l_crr_rec.application_date := lse_app_dtls_rec.expected_start_date;
    --BUG 4968010 PAGARG Passing requestor id and type based on the value of
    --employee id
    IF FND_GLOBAL.EMPLOYEE_ID = -1
    THEN
      l_crr_rec.requestor_type := 'FND_USER';
      l_crr_rec.requestor_id := FND_GLOBAL.USER_ID;
    ELSE
      l_crr_rec.requestor_type := 'EMPLOYEE';
      l_crr_rec.requestor_id := FND_GLOBAL.EMPLOYEE_ID;
    END IF;
    l_crr_rec.review_type := lse_app_dtls_rec.review_type;
    l_crr_rec.credit_classification := lse_app_dtls_rec.credit_classification;
    l_crr_rec.requested_amount := get_financed_Amount(lse_app_dtls_rec.lsq_id);
    l_crr_rec.requested_currency := lse_app_dtls_rec.currency_code;
    l_crr_rec.trx_amount := get_financed_Amount(lse_app_dtls_rec.lsq_id); -- Added for bug 6596860
    --l_crr_rec.trx_amount := l_crr_rec.requested_amount; -- Commented for for bug 6596860
    l_crr_rec.trx_currency := l_crr_rec.requested_currency;
    IF(l_crr_rec.credit_type IS NULL)
    THEN
      l_crr_rec.credit_type := 'TERM';
    END IF;
    IF(l_crr_rec.credit_request_status IS NULL)
    THEN
      l_crr_rec.credit_request_status := 'SAVE';
    END IF;
    l_crr_rec.term_length := lse_app_dtls_rec.term;
    l_crr_rec.party_id := lse_app_dtls_rec.prospect_id;
    l_crr_rec.cust_account_id := lse_app_dtls_rec.cust_acct_id;
    l_crr_rec.source_org_id := lse_app_dtls_rec.org_id;
    l_crr_rec.source_user_id := FND_GLOBAL.USER_ID;
    l_crr_rec.source_resp_id := FND_GLOBAL.RESP_ID;
    l_crr_rec.source_appln_id := 540;
    l_crr_rec.source_security_group_id := FND_GLOBAL.SECURITY_GROUP_ID;
    l_crr_rec.source_name := 'OKL';
    l_crr_rec.source_column1 := p_lapv_rec.id;
    --Bug 4728360 Interchanged the values populated for source_column2 and 3
    l_crr_rec.source_column2 := p_lapv_rec.reference_number;
    l_crr_rec.source_column3 := 'LEASEAPP';

    --Call to create Credit Application
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call AR_CMGT_CREDIT_REQUEST_API.CREATE_CREDIT_REQUEST');
    END IF;

    AR_CMGT_CREDIT_REQUEST_API.CREATE_CREDIT_REQUEST(
       p_api_version                =>     l_api_version,
       p_init_msg_list              =>     OKL_API.G_FALSE,
       p_commit                     =>     l_crr_rec.l_commit,
       p_validation_level           =>     l_crr_rec.validation_level,
       x_return_status              =>     l_return_status,
       x_msg_count                  =>     x_msg_count,
       x_msg_data                   =>     x_msg_data,
       p_application_number         =>     l_crr_rec.application_number,
       p_application_date           =>     l_crr_rec.application_date,
       p_requestor_type             =>     l_crr_rec.requestor_type,
       p_requestor_id               =>     l_crr_rec.requestor_id,
       p_review_type                =>     l_crr_rec.review_type,
       p_credit_classification      =>     l_crr_rec.credit_classification,
       p_requested_amount           =>     l_crr_rec.requested_amount,
       p_requested_currency         =>     l_crr_rec.requested_currency,
       p_trx_amount                 =>     l_crr_rec.trx_amount,
       p_trx_currency               =>     l_crr_rec.trx_currency,
       p_credit_type                =>     l_crr_rec.credit_type,
       p_term_length                =>     l_crr_rec.term_length,
       p_credit_check_rule_id       =>     l_crr_rec.credit_check_rule_id,
       p_credit_request_status      =>     l_crr_rec.credit_request_status,
       p_party_id                   =>     l_crr_rec.party_id,
       p_cust_account_id            =>     l_crr_rec.cust_account_id,
       p_cust_acct_site_id          =>     l_crr_rec.cust_acct_site_id,
       p_site_use_id                =>     l_crr_rec.site_use_id,
       p_contact_party_id           =>     l_crr_rec.contact_party_id,
       p_notes                      =>     l_crr_rec.notes,
       p_source_org_id              =>     l_crr_rec.source_org_id,
       p_source_user_id             =>     l_crr_rec.source_user_id,
       p_source_resp_id             =>     l_crr_rec.source_resp_id,
       p_source_appln_id            =>     l_crr_rec.source_appln_id,
       p_source_security_group_id   =>     l_crr_rec.source_security_group_id,
       p_source_name                =>     l_crr_rec.source_name,
       p_source_column1             =>     l_crr_rec.source_column1,
       p_source_column2             =>     l_crr_rec.source_column2,
       p_source_column3             =>     l_crr_rec.source_column3,
       p_credit_request_id          =>     l_crr_rec.credit_request_id,
       p_review_cycle               =>     l_crr_rec.review_cycle,
       p_case_folder_number         =>     l_crr_rec.case_folder_number,
       p_score_model_id             =>     l_crr_rec.score_model_id,
       p_parent_credit_request_id   =>     l_crr_rec.parent_credit_request_id,
       p_credit_request_type        =>     l_crr_rec.credit_request_type,
       p_reco                       =>     'OKL_CR_MGMT_RECOMMENDATION' );

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call AR_CMGT_CREDIT_REQUEST_API.CREATE_CREDIT_REQUEST');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of AR_CMGT_CREDIT_REQUEST_API.CREATE_CREDIT_REQUEST'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_crr_rec := l_crr_rec;
    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease Application Details Cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease Application Details Cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Lease Application Details Cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_credit_app;

  -------------------------------------------------------------------------------
  -- PROCEDURE checklist_inst_cre
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : checklist_inst_cre
  -- Description     : This procedure is a wrapper that creates checklist instance
  -- Business Rules  : This procedure creates checklist instance
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 24-JUNE-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE checklist_inst_cre(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lap_id             IN  NUMBER,
			p_chklst_tmpl_id     IN  NUMBER) IS

    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'CHECKLIST_INST_CRE';
    l_return_status          VARCHAR2(1);
    l_counter                NUMBER;

    -- Record/Table Type Declarations
    l_clhv_rec OKL_CLH_PVT.CLHV_REC_TYPE;
    x_clhv_rec OKL_CLH_PVT.CLHV_REC_TYPE;
    l_cldv_tbl OKL_CLD_PVT.CLDV_TBL_TYPE;
    x_cldv_tbl OKL_CLD_PVT.CLDV_TBL_TYPE;

    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.checklist_associated';
    -- Bug#4741121 - viselvar  - Modified - End


    --Cursor to obtain Lease App details
    CURSOR lse_app_dtls_csr(cp_lap_id NUMBER)
    IS
    SELECT LAP.ORG_ID ORG_ID
         , LAP.VALID_FROM VALID_FROM
         , LAP.VALID_TO VALID_TO
    FROM OKL_LEASE_APPLICATIONS_B LAP
    WHERE LAP.ID = cp_lap_id;
    lse_app_dtls_rec lse_app_dtls_csr%ROWTYPE;

    --Cursor to obtain Checklist Header Id and details
    CURSOR chk_hdr_dtls_csr(cp_chk_id NUMBER)
    IS
    SELECT CHK.ID ID
          ,CHK.START_DATE START_DATE
          ,CHK.END_DATE END_DATE
          ,CHK.DESCRIPTION
          ,CHK.SHORT_DESCRIPTION
    FROM OKL_CHECKLISTS CHK
    WHERE CHK.ID = cp_chk_id;
    chk_hdr_dtls_rec chk_hdr_dtls_csr%ROWTYPE;

    --Bug 4893077 PAGARG Querying checklist type from header while querying
    --data for source checklist items
    --Cursor to obtain Checklist details for given checklist
    CURSOR chk_ln_dtls_csr(cp_chk_id NUMBER)
    IS
    SELECT CHKD.TODO_ITEM_CODE ITEM_CODE
         , CHK.CHECKLIST_TYPE CHECKLIST_TYPE
         , CHKD.FUNCTION_ID FUNCTION_ID
    FROM OKL_CHECKLIST_DETAILS CHKD
       , OKL_CHECKLISTS CHK
    WHERE CHKD.CKL_ID = CHK.ID
     --removing the condition for bug 5167776
     -- AND CHK.CHECKLIST_PURPOSE_CODE <> 'CHECKLIST_INSTANCE'
      AND (CHK.ID = cp_chk_id OR CHK.CKL_ID = cp_chk_id );

    --Curosr to obtain existing checklist instances with given lease application
    CURSOR lap_chk_dtls_csr(cp_lap_id NUMBER)
    IS
      SELECT CHK.ID ID
            ,CHK.START_DATE START_DATE
            ,CHK.END_DATE END_DATE
            ,CHK.DESCRIPTION DESCRIPTION
            ,CHK.SHORT_DESCRIPTION SHORT_DESCRIPTION
            ,CHK.OBJECT_VERSION_NUMBER OBJECT_VERSION_NUMBER
      FROM OKL_CHECKLISTS CHK
      WHERE CHK.CHECKLIST_OBJ_TYPE_CODE = 'LEASE_APPL'
        AND CHK.CHECKLIST_OBJ_ID = cp_lap_id;
    lap_chk_dtls_rec lap_chk_dtls_csr%ROWTYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.CHECKLIST_INST_CRE';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR lap_chk_dtls_rec IN lap_chk_dtls_csr(p_lap_id)
    LOOP
      l_clhv_rec.id := lap_chk_dtls_rec.id;
      l_clhv_rec.CHECKLIST_OBJ_ID := NULL;
      l_clhv_rec.CHECKLIST_OBJ_TYPE_CODE := NULL;

      --Call to update Checklist Instance header to remove already association
      --with lease application
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_CHECKLIST_PVT.UPDATE_CHECKLIST_INST_HDR');
      END IF;

      OKL_CHECKLIST_PVT.UPDATE_CHECKLIST_INST_HDR(
          p_api_version   => p_api_version
         ,p_init_msg_list => OKL_API.G_FALSE
         ,x_return_status => l_return_status
         ,x_msg_count     => x_msg_count
         ,x_msg_data      => x_msg_data
         ,p_clhv_rec      => l_clhv_rec
         ,x_clhv_rec      => x_clhv_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_CHECKLIST_PVT.UPDATE_CHECKLIST_INST_HDR');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_CHECKLIST_PVT.UPDATE_CHECKLIST_INST_HDR'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

    --asawanka Bug 4865418 changes start
    IF p_chklst_tmpl_id IS NOT NULL THEN
      --asawanka Bug 4865418 changes end.
      OPEN chk_hdr_dtls_csr(p_chklst_tmpl_id);
      FETCH chk_hdr_dtls_csr INTO chk_hdr_dtls_rec;
      CLOSE chk_hdr_dtls_csr;

      OPEN lse_app_dtls_csr(p_lap_id);
      FETCH lse_app_dtls_csr INTO lse_app_dtls_rec;
      CLOSE lse_app_dtls_csr;

      l_clhv_rec.description := chk_hdr_dtls_rec.description;
      l_clhv_rec.short_description := chk_hdr_dtls_rec.short_description;
      l_clhv_rec.org_id := lse_app_dtls_rec.org_id;
      l_clhv_rec.start_date := chk_hdr_dtls_rec.start_date;
      IF(chk_hdr_dtls_rec.end_date <= SYSDATE)
      THEN
        l_clhv_rec.end_date := SYSDATE + 30;
      ELSE
        l_clhv_rec.end_date := chk_hdr_dtls_rec.end_date;
      END IF;
      l_clhv_rec.id := NULL;
      --Lease Application Id
      l_clhv_rec.checklist_obj_id := p_lap_id;
      l_clhv_rec.checklist_obj_type_code := 'LEASE_APPL';

      --Call to create Checklist Instance
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_CHECKLIST_PVT.CREATE_CHECKLIST_INST_HDR');
      END IF;

      OKL_CHECKLIST_PVT.CREATE_CHECKLIST_INST_HDR(
          p_api_version   => p_api_version
         ,p_init_msg_list => OKL_API.G_FALSE
         ,x_return_status => l_return_status
         ,x_msg_count     => x_msg_count
         ,x_msg_data      => x_msg_data
         ,p_clhv_rec      => l_clhv_rec
         ,x_clhv_rec      => x_clhv_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_CHECKLIST_PVT.CREATE_CHECKLIST_INST_HDR');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_CHECKLIST_PVT.CREATE_CHECKLIST_INST_HDR'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_counter := 0;
      FOR chk_ln_dtls_rec in chk_ln_dtls_csr(chk_hdr_dtls_rec.id)
      LOOP
        l_counter := l_counter + 1;
        l_cldv_tbl(l_counter).ckl_id := x_clhv_rec.id;
        l_cldv_tbl(l_counter).todo_item_code := chk_ln_dtls_rec.item_code;
        l_cldv_tbl(l_counter).org_id := x_clhv_rec.org_id;
        l_cldv_tbl(l_counter).function_id := chk_ln_dtls_rec.function_id;
        --Bug 4893077 PAGARG Populate instance checklist type with checklist type
        --of checklist header of source checklist
        l_cldv_tbl(l_counter).inst_checklist_type := chk_ln_dtls_rec.checklist_type;
      END LOOP;

      IF(l_cldv_tbl.count > 0)
      THEN
        --Call to create Checklist Instance Details
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call OKL_CHECKLIST_PVT.CREATE_CHECKLIST_INST_DTL');
        END IF;

        OKL_CHECKLIST_PVT.CREATE_CHECKLIST_INST_DTL(
            p_api_version   => p_api_version
           ,p_init_msg_list => OKL_API.G_FALSE
           ,x_return_status => l_return_status
           ,x_msg_count     => x_msg_count
           ,x_msg_data      => x_msg_data
           ,p_cldv_tbl      => l_cldv_tbl
           ,x_cldv_tbl      => x_cldv_tbl);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call OKL_CHECKLIST_PVT.CREATE_CHECKLIST_INST_DTL');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of OKL_CHECKLIST_PVT.CREATE_CHECKLIST_INST_DTL'
             ,'l_return_status ' || l_return_status);
        END IF; -- end of statement level debug

        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;-- l_cldv_tbl.count > 0

      -- Bug#4741121 - viselvar  - Modified - Start
      -- raise the business event passing the Lease Application id added to the parameter list

      wf_event.addparametertolist('LAPP_ID'
                                 ,p_lap_id
                                 ,l_parameter_list);

      okl_wf_pvt.raise_event(  p_api_version   =>            p_api_version
                              ,p_init_msg_list =>            p_init_msg_list
                              ,x_return_status =>            l_return_status
                              ,x_msg_count     =>            x_msg_count
                              ,x_msg_data      =>            x_msg_data
                              ,p_event_name    =>            p_event_name
                              ,p_parameters    =>            l_parameter_list);


      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Bug#4741121 - viselvar  - Modified - End
    --asawanka Bug 4865418 changes start
    END IF;
    --asawanka Bug 4865418 changes end.
    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease App Details Cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Checklist Details Cursor
      IF chk_ln_dtls_csr%ISOPEN
      THEN
        CLOSE chk_ln_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease App Details Cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Checklist Details Cursor
      IF chk_ln_dtls_csr%ISOPEN
      THEN
        CLOSE chk_ln_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Lease App Details Cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Checklist Details Cursor
      IF chk_ln_dtls_csr%ISOPEN
      THEN
        CLOSE chk_ln_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END CHECKLIST_INST_CRE;

  -------------------------------------------------------------------------------
  -- PROCEDURE lease_app_cre
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_cre
  -- Description     : This procedure is a wrapper that creates records for
  --                 : lease application.
  -- Business Rules  : This procedure inserts records into the
  --                   OKL_LEASE_APPLICATIONS_B and _TL table
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --                 : 09 Feb 2006 PAGARG Bug 4960541 Added call to validations
  --                   API while creating Lease App from Lease Quote
  -- End of comments
  PROCEDURE lease_app_cre(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type) IS

    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_CRE';
    l_return_status          VARCHAR2(1);
    l_qa_result              VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec      lsqv_rec_type;
    l_crr_rec       crr_rec_type;
    x_crr_rec       crr_rec_type;

    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.header_created';
    p_event_name1     VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.sales_quote_created';
    -- Bug#4741121 - viselvar  - Modified - End

    --Cursor to obtain Checklist Header Id
    CURSOR chk_hdr_dtls_csr(cp_lap_id NUMBER)
    IS
    SELECT LATV.CHECKLIST_ID
    FROM OKL_LEASE_APPLICATIONS_B LAP
        ,OKL_LEASEAPP_TEMPL_VERSIONS_V LATV
    WHERE LAP.LEASEAPP_TEMPLATE_ID = LATV.ID
      AND LAP.ID = cp_lap_id;
    chk_hdr_dtls_rec chk_hdr_dtls_csr%ROWTYPE;

    --Cursor to obtain Lease App Source details
      --Begin - varangan-3-11-2005- removed lease application reference for bug#4713798
    CURSOR lse_app_src_dtls_csr(cp_lap_id NUMBER)
    IS
      SELECT LSQ.ID LSQ_ID
           , LOP.ID LOP_ID
      FROM OKL_LEASE_OPPORTUNITIES_B LOP
         , OKL_LEASE_QUOTES_B LSQ
      WHERE
      LSQ.PARENT_OBJECT_ID = LOP.ID
        AND LSQ.PARENT_OBJECT_CODE = 'LEASEOPP'
        AND LSQ.STATUS = 'CT-ACCEPTED'
        AND LOP.ID = cp_lap_id;
      --End - varangan-3-11-2005- removed lease application reference for bug#4713798
    lse_app_src_dtls_rec lse_app_src_dtls_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_CRE';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    l_lapv_rec := p_lapv_rec;
    l_lsqv_rec := p_lsqv_rec;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --set the status for lease application
    l_lapv_rec.application_status := G_INIT_APPL_STATUS;

    --Validate Lease Application Template
    --Validate Program Agreement
    --Validate VP and LAT association
    --Validate Lease Quote
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call LEASE_APP_VAL');
    END IF;

    LEASE_APP_VAL(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lapv_rec              => l_lapv_rec
       ,p_lsqv_rec              => l_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call LEASE_APP_VAL');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of LEASE_APP_VAL'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(l_lapv_rec.lease_opportunity_id IS NOT NULL OR
       l_lapv_rec.lease_opportunity_id <> OKL_API.G_MISS_NUM)
    THEN
      --BUG 4951955 PAGARG Instead of Lease Opp id, pass source Lease Quote id
      --as parameter to check default values
      OPEN lse_app_src_dtls_csr(l_lapv_rec.lease_opportunity_id);
      FETCH lse_app_src_dtls_csr INTO lse_app_src_dtls_rec;
      CLOSE lse_app_src_dtls_csr;

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call CHECK_LEASE_QUOTE_DEFAULTS');
      END IF;

      check_lease_quote_defaults(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_source_lsq_id         => lse_app_src_dtls_rec.lsq_id
         ,p_lapv_rec              => l_lapv_rec
         ,p_lsqv_rec              => l_lsqv_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call CHECK_LEASE_QUOTE_DEFAULTS');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON)
	  THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of CHECK_LEASE_QUOTE_DEFAULTS'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      -- Check the status and accordingly set the Lease Application Status
      IF(l_return_status = OKL_API.G_RET_STS_SUCCESS)THEN
        l_lapv_rec.application_status := 'PR-ACCEPTED';
      END IF;
    END IF; -- LEASE_OPPORTUNITY_ID check for null and G_MISS_NUM

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_LAP_PVT.INSERT_ROW');
    END IF;

    -- call the TAPI insert_row to create a lease application
    OKL_LAP_PVT.INSERT_ROW(
        p_api_version                        => p_api_version
       ,p_init_msg_list                      => OKL_API.G_FALSE
       ,x_return_status                      => l_return_status
       ,x_msg_count                          => x_msg_count
       ,x_msg_data                           => x_msg_data
       ,p_lapv_rec                           => l_lapv_rec
       ,x_lapv_rec                           => x_lapv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_LAP_PVT.INSERT_ROW');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_LAP_PVT.INSERT_ROW'
         ,'l_lapv_rec.reference_number ' || to_char(l_lapv_rec.reference_number) ||
          ' l_lapv_rec.id '|| l_lapv_rec.id ||
          ' result status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate lease quote rec values
    l_lsqv_rec.parent_object_code := 'LEASEAPP';
    l_lsqv_rec.parent_object_id := x_lapv_rec.id;
    --Bug 4721142 PAGARG set the lease quote reference number form sequence
    --Bug 4867953 PAGARG instead of using the sequence directly use function
    l_lsqv_rec.reference_number := get_next_seq_num(
                                       'OKL_LSQ_REF_SEQ'
                                      ,'OKL_LEASE_QUOTES_B'
                                      ,'REFERENCE_NUMBER');
    --Bug Fix End
    l_lsqv_rec.status := 'PR-INCOMPLETE';
    l_lsqv_rec.primary_quote := 'Y';

    --if lease application is sourced from Lease Opportunity then duplicate the
    --underline lease quote with the header rec passed to duplicate api
    --This way it will duplicate lease quote with header values from rec and
    --rest of configuration, adjustment, pricing data from the source lease quote id
    IF(l_lapv_rec.lease_opportunity_id IS NOT NULL
       AND l_lapv_rec.lease_opportunity_id <> OKL_API.G_MISS_NUM)
    THEN
      IF(x_lapv_rec.application_status = 'PR-ACCEPTED')
      THEN
        l_lsqv_rec.status := 'CT-ACCEPTED';
      END IF;
      --Begin - varangan-3-11-2005- updated with lease opportunity id for bug#4713798
      OPEN lse_app_src_dtls_csr(l_lapv_rec.lease_opportunity_id);
      --End - varangan-3-11-2005- updated with lease opportunity id for bug#4713798
      FETCH lse_app_src_dtls_csr INTO lse_app_src_dtls_rec;
      CLOSE lse_app_src_dtls_csr;

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE');
      END IF;

      -- call the procedure to create lease quote line
      OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE(
          p_api_version                        => p_api_version
         ,p_init_msg_list                      => OKL_API.G_FALSE
         ,p_transaction_control                => OKL_API.G_TRUE
         ,p_source_quote_id                    => lse_app_src_dtls_rec.lsq_id
         ,p_lease_qte_rec                      => l_lsqv_rec
         ,x_lease_qte_rec                      => x_lsqv_rec
         ,x_return_status                      => l_return_status
         ,x_msg_count                          => x_msg_count
         ,x_msg_data                           => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE'
           ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
            ' l_lsqv_rec.id '|| l_lsqv_rec.id ||
            ' result status ' || l_return_status ||
            ' x_msg_data ' || x_msg_data);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Bug 4960541 PAGARG Added call to validations API while creating Lease
      --App from Lease Quote. Based on qa result Lease App and Lease Quote status
      --are updated
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call LEASE_APP_QA_VAL');
      END IF;

      -- call the procedure to perform QA validations
      LEASE_APP_QA_VAL(
          p_api_version                => p_api_version
         ,p_init_msg_list              => OKL_API.G_FALSE
         ,p_lap_id                     => x_lapv_rec.id
         ,x_return_status              => l_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,x_qa_result                  => l_qa_result);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call LEASE_APP_QA_VAL');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE
           ,' Result of LEASE_APP_QA_VAL' ||
            ' Result Status ' || l_return_status ||
            ' QA Result Status ' || l_qa_result);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF l_qa_result <> OKL_API.G_RET_STS_SUCCESS
      THEN
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call SET_LEASE_APP_STATUS');
        END IF;

        --call the procedure to update a lease application status
        SET_LEASE_APP_STATUS(
            p_api_version     => p_api_version
           ,p_init_msg_list   => OKL_API.G_FALSE
           ,p_lap_id          => x_lapv_rec.id
           ,p_lap_status      => G_INIT_APPL_STATUS
           ,x_return_status   => l_return_status
           ,x_msg_count       => x_msg_count
           ,x_msg_data        => x_msg_data);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call SET_LEASE_APP_STATUS');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of SET_LEASE_APP_STATUS'
             ,'return status ' || l_return_status ||
              ' x_msg_data ' || x_msg_data);
        END IF; -- end of statement level debug

        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_lsqv_rec := x_lsqv_rec;
        l_lsqv_rec.status := 'PR-INCOMPLETE';
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
        END IF;

        -- call the procedure to create lease quote line
        OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE(
            p_api_version                        => p_api_version
           ,p_init_msg_list                      => OKL_API.G_FALSE
           ,p_transaction_control                => OKL_API.G_TRUE
           ,p_lease_qte_rec                      => l_lsqv_rec
           ,x_lease_qte_rec                      => x_lsqv_rec
           ,x_return_status                      => l_return_status
           ,x_msg_count                          => x_msg_count
           ,x_msg_data                           => x_msg_data);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE'
             ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
              ' l_lsqv_rec.id '|| l_lsqv_rec.id ||
              ' result status ' || l_return_status ||
              ' x_msg_data ' || x_msg_data);
        END IF; -- end of statement level debug

        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      -- Bug 7440199: Quote Streams ER: RGOOTY: Start
      ELSE
        --Making the pricing call to generate the streams
        IF(x_lapv_rec.application_status = 'PR-ACCEPTED')
        THEN
           --Start Pricing API call
           IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
           THEN
             OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_PROCEDURE
               ,L_MODULE
               ,'begin debug call OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE');
           END IF;

           OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE(
              p_api_version            => p_api_version
             ,p_init_msg_list          => OKL_API.G_FALSE
             ,p_qte_id                 => x_lsqv_rec.id
             ,x_return_status          => l_return_status
             ,x_msg_count              => x_msg_count
             ,x_msg_data               => x_msg_data);

           IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
           THEN
             OKL_DEBUG_PUB.LOG_DEBUG(
                 FND_LOG.LEVEL_PROCEDURE
                ,L_MODULE
                ,'end debug call OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE');
           END IF;

           -- write to log
           IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                 FND_LOG.LEVEL_STATEMENT
                ,L_MODULE || ' Result of OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE'
                ,'l_return_status ' || l_return_status);
           END IF; -- end of statement level debug

           IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
           --End of Pricing API call
        END IF;
       -- Bug 7440199: Quote Streams ER: RGOOTY: End
      END IF; -- For QA Result Check
    ELSE -- if Lease Opportunity Id is null
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_LEASE_QUOTE_PVT.CREATE_LEASE_QTE');
      END IF;

      -- call the procedure to create lease quote line
      OKL_LEASE_QUOTE_PVT.CREATE_LEASE_QTE(
          p_api_version                        => p_api_version
         ,p_init_msg_list                      => OKL_API.G_FALSE
         ,p_transaction_control                => OKL_API.G_TRUE
         ,p_lease_qte_rec                      => l_lsqv_rec
         ,x_lease_qte_rec                      => x_lsqv_rec
         ,x_return_status                      => l_return_status
         ,x_msg_count                          => x_msg_count
         ,x_msg_data                           => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_LEASE_QUOTE_PVT.CREATE_LEASE_QTE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.CREATE_LEASE_QTE'
           ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
            ' l_lsqv_rec.id '|| l_lsqv_rec.id ||
            ' result status ' || l_return_status ||
            ' x_msg_data ' || x_msg_data);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
    -- Bug#4741121 - viselvar  - Modified - Start
    -- raise the business event passing the Lease Application id added to the parameter list
    wf_event.addparametertolist('LAPP_ID'
                               ,x_lapv_rec.id
                               ,l_parameter_list);
    okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name1
                            ,p_parameters    =>            l_parameter_list);

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Bug#4741121 - viselvar  - Modified - End

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call CREATE_CREDIT_APP');
    END IF;

    --call to create Credit Lease Application
    CREATE_CREDIT_APP(
        p_api_version        => p_api_version
       ,p_init_msg_list      => OKL_API.G_FALSE
       ,x_return_status      => l_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       ,p_lapv_rec           => x_lapv_rec
       ,p_crr_rec            => l_crr_rec
       ,x_crr_rec            => x_crr_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call CREATE_CREDIT_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of CREATE_CREDIT_APP'
         ,' result status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN chk_hdr_dtls_csr(x_lapv_rec.id);
    FETCH chk_hdr_dtls_csr INTO chk_hdr_dtls_rec;
    CLOSE chk_hdr_dtls_csr;

    IF(chk_hdr_dtls_rec.checklist_id IS NOT NULL)
    THEN
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call CHECKLIST_INST_CRE');
      END IF;

      --call to create Checklist Instance
      CHECKLIST_INST_CRE(
          p_api_version        => p_api_version
         ,p_init_msg_list      => OKL_API.G_FALSE
         ,x_return_status      => l_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_lap_id             => x_lapv_rec.id
		 ,p_chklst_tmpl_id     => chk_hdr_dtls_rec.checklist_id);

	  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call CHECKLIST_INST_CRE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of CHECKLIST_INST_CRE'
           ,' result status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- Condition to check for call to create checklist instance

    -- Bug#4741121 - viselvar  - Modified - Start
    -- raise the business event passing the Lease Application id added to the parameter list
    wf_event.addparametertolist('LAPP_ID'
                               ,x_lapv_rec.id
                               ,l_parameter_list);
    okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Bug#4741121 - viselvar  - Modified - End

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Lease Application Source Details Cursor
      IF lse_app_src_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_src_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Lease Application Source Details Cursor
      IF lse_app_src_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_src_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Lease Application Source Details Cursor
      IF lse_app_src_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_src_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_cre;

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_upd
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_upd
  -- Description     : This procedure is a wrapper that updates records for
  --                 : lease application.
  -- Business Rules  : This procedure updates records into the
  --                   OKL_LEASE_APPLICATIONS_B and _TL table
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_upd(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type) IS

    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_UPD';
    l_return_status          VARCHAR2(1);
    l_update_quote           NUMBER;

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec      lsqv_rec_type;

    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.saved';
    -- Bug#4741121 - viselvar  - Modified - Start

    --asawanka Bug 4865418 changes start
    l_credit_request_rec       OCM_CREDIT_REQUEST_UPDATE_PUB.credit_request_rec;
    --asawanka Bug 4865418 changes end
    --Cursor to obtain the details of lease quote line of Lease App
    CURSOR l_lsq_dtls_csr(p_lap_id NUMBER)
        IS
      SELECT LSQ.ID LSQ_ID
           , LSQ.STATUS STATUS
      FROM OKL_LEASE_QUOTES_B LSQ
      WHERE LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LSQ.PRIMARY_QUOTE= 'Y'
        AND LSQ.PARENT_OBJECT_ID = p_lap_id;
    l_lsq_dtls_rec l_lsq_dtls_csr%ROWTYPE;
    --asawanka Bug 4865418 changes start
    --cursor to obtain lease app template id used on lease application
    CURSOR l_lse_app_tmplt_csr(p_lap_id NUMBER)
        IS
      SELECT leaseapp_template_id
      FROM okl_lease_applications_b LSQ
      WHERE ID = p_lap_id;
    l_lse_app_tmplt_csr_rec l_lse_app_tmplt_csr%ROWTYPE;

    --Cursor to obtain Checklist Header Id
    CURSOR chk_hdr_dtls_csr(cp_latv_id NUMBER)
    IS
    SELECT LATV.CHECKLIST_ID
           ,LAT.CREDIT_REVIEW_PURPOSE
           ,LAT.CUST_CREDIT_CLASSIFICATION
    FROM OKL_LEASEAPP_TEMPL_VERSIONS_V LATV
        ,OKL_LEASEAPP_TEMPLATES LAT
    WHERE LATV.LEASEAPP_TEMPLATE_ID = LAT.ID
      AND LATV.ID = cp_latv_id;
    chk_hdr_dtls_rec chk_hdr_dtls_csr%ROWTYPE;

    CURSOR get_crd_app_data(cp_lap_id NUMBER)
    IS
    SELECT CREDIT_REQUEST_ID
          ,APPLICATION_NUMBER
          ,TRX_AMOUNT
          ,TRX_CURRENCY
          ,STATUS
          ,RECOMMENDATION_NAME
          ,SOURCE_COLUMN1
          ,SOURCE_COLUMN2
          ,REVIEW_TYPE
          ,CREDIT_CLASSIFICATION
          ,CUST_ACCOUNT_ID
    FROM AR_CMGT_CREDIT_REQUESTS
    WHERE SOURCE_COLUMN3 = 'LEASEAPP'
    AND   SOURCE_COLUMN1 = cp_lap_id;
    get_crd_app_data_rec get_crd_app_data%ROWTYPE;
    --asawanka Bug 4865418 changes end
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_UPD';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := p_lapv_rec;
    l_lsqv_rec := p_lsqv_rec;
    x_lsqv_rec := p_lsqv_rec;

    --Validate Lease Application Template
    --Validate Program Agreement
    --Validate VP and LAT association
    --Validate Lease Quote
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call LEASE_APP_VAL');
    END IF;

    LEASE_APP_VAL(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lapv_rec              => l_lapv_rec
       ,p_lsqv_rec              => l_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call LEASE_APP_VAL');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of LEASE_APP_VAL'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --asawanka Bug 4865418 changes start

    --collect the existing lease application template before update
    OPEN l_lse_app_tmplt_csr(l_lapv_rec.id);
    FETCH l_lse_app_tmplt_csr INTO l_lse_app_tmplt_csr_rec;
    CLOSE l_lse_app_tmplt_csr;
    --asawanka Bug 4865418 changes end

    --BUG 4951955 PAGARG Call check Lease Quote defaults and accordingly set
    --status of Lease App and Lease Quote
    l_update_quote := 0;
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call CHECK_LEASE_QUOTE_DEFAULTS');
    END IF;

    CHECK_LEASE_QUOTE_DEFAULTS(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_source_lsq_id         => l_lsqv_rec.id
       ,p_lapv_rec              => l_lapv_rec
       ,p_lsqv_rec              => l_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call CHECK_LEASE_QUOTE_DEFAULTS');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON)
	THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of CHECK_LEASE_QUOTE_DEFAULTS'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    -- Check the status and accordingly set the Lease Application Status
    IF(l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      --set the status for lease application
      l_lapv_rec.application_status := G_INIT_APPL_STATUS;
      l_update_quote := 1;
    END IF;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_LAP_PVT.UPDATE_ROW');
    END IF;

    -- call the TAPI update_row to update a lease application
    OKL_LAP_PVT.UPDATE_ROW(
        p_api_version                        => p_api_version
       ,p_init_msg_list                      => OKL_API.G_FALSE
       ,x_return_status                      => l_return_status
       ,x_msg_count                          => x_msg_count
       ,x_msg_data                           => x_msg_data
       ,p_lapv_rec                           => l_lapv_rec
       ,x_lapv_rec                           => x_lapv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_LAP_PVT.UPDATE_ROW');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_LAP_PVT.UPDATE_ROW'
         ,'l_lapv_rec.reference_number ' || to_char(l_lapv_rec.reference_number) ||
          ' expiring lease application with status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(l_update_quote = 1)
    THEN
      l_lsqv_rec.status := 'PR-INCOMPLETE';

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
      END IF;

      -- call the procedure to create lease quote line
      OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE(
          p_api_version                        => p_api_version
         ,p_init_msg_list                      => OKL_API.G_FALSE
         ,p_transaction_control                => OKL_API.G_TRUE
         ,p_lease_qte_rec                      => l_lsqv_rec
         ,x_lease_qte_rec                      => x_lsqv_rec
         ,x_return_status                      => l_return_status
         ,x_msg_count                          => x_msg_count
         ,x_msg_data                           => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE'
           ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
            ' l_lsqv_rec.id '|| l_lsqv_rec.id ||
            ' result status ' || l_return_status ||
            ' x_msg_data ' || x_msg_data);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    --BUG 4951955 PAGARG Removed the call to subsidy pool API as it was redundant
    --It is already called in update_lease_qte

    -- Bug#4741121 - viselvar  - Modified - Start
    -- raise the business event passing the Lease Application id added to the parameter list
    wf_event.addparametertolist('LAPP_ID'
                               ,x_lapv_rec.id
                               ,l_parameter_list);
    okl_wf_pvt.raise_event(p_api_version     =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Bug#4741121 - viselvar  - Modified - End

    --asawanka Bug 4865418 changes start
    --if lease application template selected on the lease application has changed
    --then handle the checklist instance, credit application review purpose and  credit classification
    IF l_lse_app_tmplt_csr_rec.leaseapp_template_id <> l_lapv_rec.LEASEAPP_TEMPLATE_ID
    THEN
      --take the checklist details for the new lease application template
      OPEN chk_hdr_dtls_csr(l_lapv_rec.LEASEAPP_TEMPLATE_ID);
      FETCH chk_hdr_dtls_csr INTO chk_hdr_dtls_rec;
      CLOSE chk_hdr_dtls_csr;

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call CHECKLIST_INST_CRE');
      END IF;

      --call to create Checklist Instance
      CHECKLIST_INST_CRE(
          p_api_version        => p_api_version
         ,p_init_msg_list      => OKL_API.G_FALSE
         ,x_return_status      => l_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_lap_id             => l_lapv_rec.id
         ,p_chklst_tmpl_id     => chk_hdr_dtls_rec.checklist_id);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call CHECKLIST_INST_CRE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of CHECKLIST_INST_CRE'
           ,' result status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;--condition to check change of lease application template

    --check the review purpose, credit classification and Customer Account on the
    --credit application for this lease application. if any of these are
    --changed, call the api to update them in credit application.
    OPEN get_crd_app_data(l_lapv_rec.id);
    FETCH get_crd_app_data INTO get_crd_app_data_rec;
    CLOSE get_crd_app_data;
    IF get_crd_app_data_rec.review_type <> chk_hdr_dtls_rec.credit_review_purpose
       OR get_crd_app_data_rec.credit_classification <> chk_hdr_dtls_rec.cust_credit_classification
       OR get_crd_app_data_rec.cust_account_id <> NVL(x_lapv_rec.cust_acct_id, -99)
       OR get_crd_app_data_rec.application_number <> l_lapv_rec.reference_number
    THEN
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC');
      END IF;
      --get the existing credit request data
      OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC(
          p_credit_request_id  => get_crd_app_data_rec.credit_request_id
         ,p_return_status      => l_return_status
         ,p_error_msg          => x_msg_data
         ,p_credit_request_rec => l_credit_request_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC'
           ,' result status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --assign the new values
      l_credit_request_rec.application_number := l_lapv_rec.reference_number;
      l_credit_request_rec.source_column2 := l_lapv_rec.reference_number;
      l_credit_request_rec.review_type := chk_hdr_dtls_rec.credit_review_purpose;
      l_credit_request_rec.credit_classification := chk_hdr_dtls_rec.cust_credit_classification;
      l_credit_request_rec.cust_account_id := x_lapv_rec.cust_acct_id;

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST');
      END IF;
      --update the credit application data
      OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST(
          p_api_version           => l_api_version,
          p_init_msg_list         => OKL_API.G_FALSE,
          p_commit                => NULL,
          p_validation_level      => NULL,
          x_return_status         => l_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          p_credit_request_rec    => l_credit_request_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST'
           ,' result status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;--condition to check change in credit classification or review purpose
    --asawanka Bug 4865418 changes end

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease Quote Details Cursor
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      --Lease App Template Details Cursor
      IF l_lse_app_tmplt_csr%ISOPEN
      THEN
        CLOSE l_lse_app_tmplt_csr;
      END IF;
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Credit Application Details Cursor
      IF get_crd_app_data%ISOPEN
      THEN
        CLOSE get_crd_app_data;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease Quote Details Cursor
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      --Lease App Template Details Cursor
      IF l_lse_app_tmplt_csr%ISOPEN
      THEN
        CLOSE l_lse_app_tmplt_csr;
      END IF;
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Credit Application Details Cursor
      IF get_crd_app_data%ISOPEN
      THEN
        CLOSE get_crd_app_data;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Lease Quote Details Cursor
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      --Lease App Template Details Cursor
      IF l_lse_app_tmplt_csr%ISOPEN
      THEN
        CLOSE l_lse_app_tmplt_csr;
      END IF;
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Credit Application Details Cursor
      IF get_crd_app_data%ISOPEN
      THEN
        CLOSE get_crd_app_data;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_upd;

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_val
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_val
  -- Description     : This procedure validates lease application.
  -- Business Rules  : This procedure validates lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --                 : 12-Dec-2005 PAGARG Bug 4873205 Added validation for
  --                   Checklist and Contract Template effectivity and also
  --                   fixed the VP-LAT association validation
  -- End of comments
  PROCEDURE lease_app_val(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type) IS

    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_VAL';
    l_return_status            VARCHAR2(1);
    l_dummy                    VARCHAR2(200);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec		lsqv_rec_type;

    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.validated';
    -- Bug#4741121 - viselvar  - Modified - End

    --Cursor for Lease Application Template details
    CURSOR lat_dtls_csr(cp_tmpl_id NUMBER, cp_valid_from DATE) IS
      SELECT LAT.NAME LEASEAPP_TMPL_NAME
        FROM OKL_LEASEAPP_TEMPLATES LAT
            ,OKL_LEASEAPP_TEMPL_VERSIONS_V LATV
       WHERE (LATV.VERSION_STATUS <> 'ACTIVE' OR
              LATV.VALID_FROM > cp_valid_from OR
              NVL(LATV.VALID_TO, TO_DATE('31-12-9999', 'dd-mm-yyyy')) < cp_valid_from)
         AND LATV.ID = cp_tmpl_id
		 AND LATV.LEASEAPP_TEMPLATE_ID = LAT.ID;
    lat_dtls_rec lat_dtls_csr%ROWTYPE;

    --Cursor for Program Agreement details
    CURSOR pgm_agr_dtls_csr(cp_pgm_agr_id NUMBER) IS
      SELECT CHR.ID
           , CHR.CONTRACT_NUMBER
           , CHR.STS_CODE
           , PSTS.STE_CODE
           , CHR.START_DATE START_DATE
           , CHR.END_DATE END_DATE
        FROM OKC_K_HEADERS_B CHR
           , OKC_STATUSES_V PSTS
       WHERE CHR.SCS_CODE = 'PROGRAM'
         AND CHR.STS_CODE = PSTS.CODE
         AND CHR.ID = cp_pgm_agr_id;
    pgm_agr_dtls_rec pgm_agr_dtls_csr%ROWTYPE;

    --Cursor for Lease Quote details
    CURSOR lse_qte_dtls_csr(cp_lop_id NUMBER) IS
      SELECT LSQ.ID
           , LSQ.REFERENCE_NUMBER
           , LSQ.STATUS
        FROM OKL_LEASE_QUOTES_B LSQ
           , OKL_LEASE_OPPORTUNITIES_B LOP
       WHERE LOP.ID = cp_lop_id
	     AND LSQ.PARENT_OBJECT_CODE = 'LEASEOPP'
		 AND LSQ.PARENT_OBJECT_ID = LOP.ID
		 AND LSQ.STATUS = 'CT-ACCEPTED';
    lse_qte_dtls_rec lse_qte_dtls_csr%ROWTYPE;

    --Cursor for Lease Application Template and Vendor Program Association validation
    --Bug abhsaxen 5158188 for validation of VPA is having any LAT
    CURSOR lat_pgm_exist_csr(cp_pgm_agr_id NUMBER) IS
      SELECT 'X'
        FROM OKC_K_HEADERS_B PGM
           , OKL_VP_ASSOCIATIONS_V VPA
           , OKL_LEASEAPP_TEMPLATES LAT
           , OKL_LEASEAPP_TEMPL_VERSIONS_B LATV
       WHERE VPA.CHR_ID = PGM.ID
         AND VPA.CRS_ID IS NULL
         AND VPA.ASSOC_OBJECT_TYPE_CODE = 'LA_TEMPLATE'
         AND PGM.SCS_CODE = 'PROGRAM'
         AND VPA.ASSOC_OBJECT_ID = LAT.ID
         AND VPA.ASSOC_OBJECT_VERSION = LATV.VERSION_NUMBER
         AND LATV.LEASEAPP_TEMPLATE_ID = LAT.ID
         AND PGM.ID = cp_pgm_agr_id;
    lat_pgm_exist_rec lat_pgm_exist_csr%ROWTYPE;
    --Bug 4873205 PAGARG modified the query to validate validation
    CURSOR lat_pgm_val_csr(cp_pgm_agr_id NUMBER, cp_latv_id NUMBER) IS
      SELECT 'X'
        FROM OKC_K_HEADERS_B PGM
           , OKL_VP_ASSOCIATIONS_V VPA
           , OKL_LEASEAPP_TEMPLATES LAT
           , OKL_LEASEAPP_TEMPL_VERSIONS_B LATV
       WHERE VPA.CHR_ID = PGM.ID
         AND VPA.CRS_ID IS NULL
         AND VPA.ASSOC_OBJECT_TYPE_CODE = 'LA_TEMPLATE'
         AND PGM.SCS_CODE = 'PROGRAM'
         AND VPA.ASSOC_OBJECT_ID = LAT.ID
         AND VPA.ASSOC_OBJECT_VERSION = LATV.VERSION_NUMBER
         AND LATV.LEASEAPP_TEMPLATE_ID = LAT.ID
         AND PGM.ID = cp_pgm_agr_id
         AND LATV.ID = cp_latv_id;
    lat_pgm_val_rec lat_pgm_val_csr%ROWTYPE;

    --Cursor to validate if there is any in process lease application sourced from
    --given Lease Quote
    CURSOR lap_lsq_uniq_csr(cp_lop_id NUMBER, p_lap_id NUMBER) IS
      SELECT REFERENCE_NUMBER
      FROM OKL_LEASE_APPLICATIONS_B
      --asawanka bug 4936130 changes start
      WHERE APPLICATION_STATUS NOT IN ('CR-APPROVED'
                                         ,'CR-REJECTED'
                                         ,'RECOM_NOT_APPROVED'
                                         ,'CONV-K'
                                         ,'WITHDRAWN'
                                         ,'CANCELED'
                                         ,'APPEALINPROG'
                                         ,'RESUBMITINPROG')
      --asawanka bug 4936130 changes end
        AND LEASE_OPPORTUNITY_ID = cp_lop_id
        AND ID <> NVL(p_lap_id, -1);

    --Bug 4873205 PAGARG Added cursors to validate Checklist and Contract Template
    --Validate Checklist Cursor
    CURSOR checklist_val_csr(p_latv_id NUMBER, p_valid_from DATE)
    IS
      SELECT CHECKLIST_NUMBER TEMPLATE_NUMBER
      FROM OKL_CHECKLISTS CHK
         , OKL_LEASEAPP_TEMPL_VERSIONS_V LATV
         , OKL_LEASEAPP_TEMPLATES LAT
      WHERE LATV.CHECKLIST_ID = CHK.ID
        AND LATV.LEASEAPP_TEMPLATE_ID = LAT.ID
        AND ( (p_valid_from NOT BETWEEN NVL(CHK.START_DATE, p_valid_from)
               AND NVL(CHK.END_DATE, p_valid_from))
             OR CHK.STATUS_CODE <> 'ACTIVE'
             OR CHK.CHECKLIST_PURPOSE_CODE NOT IN ('CHECKLIST_TEMPLATE', 'CHECKLIST_TEMPLATE_GROUP')
             OR CHK.ORG_ID <> LAT.ORG_ID)
        AND LATV.ID = p_latv_id;

     --Validate Contract Template Cursor
    CURSOR contract_tmpl_val_csr(p_latv_id NUMBER, p_valid_from DATE)
    IS
      SELECT CHR.CONTRACT_NUMBER TEMPLATE_NUMBER
      FROM OKC_K_HEADERS_B CHR
         , OKL_LEASEAPP_TEMPL_VERSIONS_V LATV
         , OKL_LEASEAPP_TEMPLATES LAT
         , OKL_K_HEADERS KHR
         , OKC_STATUSES_V STS
      WHERE LATV.CONTRACT_TEMPLATE_ID = CHR.ID
        AND LATV.LEASEAPP_TEMPLATE_ID = LAT.ID
        AND CHR.ID = KHR.ID
        AND CHR.STS_CODE = STS.CODE
	/* Bug#6850094 : Include contract template with any status
        AND (CHR.TEMPLATE_YN <> 'Y'
             OR STS.STE_CODE <> 'ACTIVE'
             OR NVL(KHR.TEMPLATE_TYPE_CODE, 'X') <> 'LEASEAPP'
             OR CHR.AUTHORING_ORG_ID <> LAT.ORG_ID)
        */
       AND (CHR.TEMPLATE_YN <> 'Y'
                OR (NVL(KHR.TEMPLATE_TYPE_CODE,'X') = 'LEASEAPP' AND STS.STE_CODE <> 'ACTIVE')
                OR NVL(KHR.TEMPLATE_TYPE_CODE, 'X') NOT IN ('LEASEAPP','CONTRACT')
                OR CHR.AUTHORING_ORG_ID <> LAT.ORG_ID)
       --Bug# 6850094 :End
        AND LATV.ID = p_latv_id;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_VAL';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := p_lapv_rec;
    l_lsqv_rec := p_lsqv_rec;

    --Validate Lease Application Template
    IF(l_lapv_rec.leaseapp_template_id IS NOT NULL AND
       l_lapv_rec.leaseapp_template_id <> OKL_API.G_MISS_NUM)
    THEN
      FOR lat_dtls_rec IN lat_dtls_csr(l_lapv_rec.leaseapp_template_id
                                      ,l_lapv_rec.valid_from)
      LOOP
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_VAL_LEASEAPP_TEMPLATE',
            p_token1        => 'TEMPLATE_NUMBER',
            p_token1_value  => lat_dtls_rec.leaseapp_tmpl_name);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END LOOP;

      --Validate Eligibility Criteria for Lease Application Template
      l_return_status := is_valid_leaseapp_template(
                            l_lapv_rec.leaseapp_template_id
                           ,l_lapv_rec.id
                           ,l_lapv_rec.valid_from);
      IF(l_return_status = OKL_API.G_RET_STS_ERROR)
      THEN
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_SO_LSEAPP_TMPL_EC_FAIL',
            p_token1        => 'TEXT',
            p_token1_value  => lat_dtls_rec.leaseapp_tmpl_name);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
      --Lease Application Template is required field.
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_INVALID_LSEAPP_TMPL');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; --Validate Lease Application Template

    --Validate Program Agreement and Associations
    IF(l_lapv_rec.program_agreement_id IS NOT NULL AND
       l_lapv_rec.program_agreement_id <> OKL_API.G_MISS_NUM)
    THEN
      OPEN pgm_agr_dtls_csr(l_lapv_rec.program_agreement_id);
      FETCH pgm_agr_dtls_csr INTO pgm_agr_dtls_rec;
        IF(pgm_agr_dtls_csr%NOTFOUND)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_SO_INVALID_PGM_AGR');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF(pgm_agr_dtls_rec.ste_code <> 'ACTIVE'
              OR pgm_agr_dtls_rec.START_DATE > l_lsqv_rec.expected_start_date
              OR NVL(pgm_agr_dtls_rec.END_DATE, TO_DATE('31-12-9999', 'dd-mm-yyyy')) < l_lsqv_rec.expected_start_date)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_SO_INACTIVE_PGM_AGR',
              p_token1        => 'TEXT',
              p_token1_value  => pgm_agr_dtls_rec.contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      CLOSE pgm_agr_dtls_csr;

      --Validate Eligibility Criteria for Program Agreement
      l_return_status := is_valid_program_agreement(
                            l_lapv_rec.program_agreement_id
                           ,l_lapv_rec.id
                           ,l_lapv_rec.valid_from);

      IF(l_return_status = OKL_API.G_RET_STS_ERROR)
      THEN
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_SO_PGM_AGR_EC_FAIL',
            p_token1        => 'TEXT',
            p_token1_value  => pgm_agr_dtls_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Validate Lease Application Template and Program Agreement Association
      --Bug 4873205 PAGARG Passing Template Version id also to validate association
      --Bug abhsaxen 5158188 modified for VPA is not having LAT
      OPEN lat_pgm_exist_csr(l_lapv_rec.program_agreement_id);
      FETCH lat_pgm_exist_csr INTO lat_pgm_exist_rec;
      IF  lat_pgm_exist_csr%FOUND THEN
        OPEN lat_pgm_val_csr(l_lapv_rec.program_agreement_id, l_lapv_rec.leaseapp_template_id);
        FETCH lat_pgm_val_csr INTO lat_pgm_val_rec;
        IF lat_pgm_val_csr%NOTFOUND
            THEN
            l_return_status := OKL_API.G_RET_STS_ERROR;
            OKL_API.SET_MESSAGE(
                p_app_name      => G_APP_NAME,
                p_msg_name      => 'OKL_SO_NO_ASS_LAT_PAG',
                p_token1        => 'LAP_TMP',
                p_token1_value  => lat_dtls_rec.leaseapp_tmpl_name,
                p_token2        => 'PGM_AGR',
                p_token2_value  => pgm_agr_dtls_rec.contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE lat_pgm_val_csr;
      END IF;
      CLOSE lat_pgm_exist_csr;
    END IF; --Validate Program Agreement and Association

    --Validate Lease Quote
    IF(l_lapv_rec.lease_opportunity_id IS NOT NULL AND
       l_lapv_rec.lease_opportunity_id <> OKL_API.G_MISS_NUM)
    THEN
      OPEN lse_qte_dtls_csr(l_lapv_rec.lease_opportunity_id);
      FETCH lse_qte_dtls_csr INTO lse_qte_dtls_rec;
        IF(lse_qte_dtls_csr%NOTFOUND)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_SO_INVALID_LSE_QTE');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      CLOSE lse_qte_dtls_csr;

      OPEN lap_lsq_uniq_csr(l_lapv_rec.lease_opportunity_id, l_lapv_rec.id);
      FETCH lap_lsq_uniq_csr INTO l_dummy;
        IF(lap_lsq_uniq_csr%FOUND)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_SO_LSE_APP_QTE_UNQ_ERR',
              p_token1        => 'TEXT',
              p_token1_value  => l_dummy,
              p_token2        => 'QUOTE',
              p_token2_value  => lse_qte_dtls_rec.reference_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      CLOSE lap_lsq_uniq_csr;
    END IF; --Validate Lease Quote

    --Bug 4873205 PAGARG Validating Checklist and Contract Template
    --Validate whether Contract Template associated to the
    --Lease Application Template is still Active and effective
    FOR contract_tmpl_val_rec IN contract_tmpl_val_csr(l_lapv_rec.leaseapp_template_id
                                                      ,l_lapv_rec.valid_from)
    LOOP
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_VAL_CONTRACT_TEMPLATE',
          p_token1        => 'TEMPLATE_NUMBER',
          p_token1_value  => contract_tmpl_val_rec.template_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END LOOP;

    --Validate whether Checklist associated to the
    --Lease Application Template is still Active and effective
    FOR checklist_val_rec IN checklist_val_csr(l_lapv_rec.leaseapp_template_id
                                              ,l_lapv_rec.valid_from)
    LOOP
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_VAL_CHECKLIST_TEMPLATE',
          p_token1        => 'TEMPLATE_NUMBER',
          p_token1_value  => checklist_val_rec.template_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END LOOP;

    --Bug 4932155 PAGARG Validate Currency Conversion Attributes
    l_return_status := is_curr_conv_valid(
                          p_curr_code    => l_lapv_rec.currency_code
                         ,p_curr_type    => l_lapv_rec.currency_conversion_type
                         ,p_curr_rate    => l_lapv_rec.currency_conversion_rate
                         ,p_curr_date    => l_lapv_rec.currency_conversion_date);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Validate Expected Start Date against Valid From Date
    IF(TRUNC(l_lsqv_rec.expected_start_Date) < TRUNC(l_lapv_rec.valid_from))
    THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_SO_LSE_APP_EXP_ST_DATE_ERR',
            p_token1        => 'VALID_FROM',
            p_token1_value  => l_lapv_rec.valid_from);
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Bug#4741121 - viselvar  - Modified - Start
    -- raise the business event passing the Lease Application id added to the parameter list
    wf_event.addparametertolist('LAPP_ID'
                               ,l_lapv_rec.id
                               ,l_parameter_list);
    okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Bug#4741121 - viselvar  - Modified - End

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease Application Template Details Cursor
      IF lat_dtls_csr%ISOPEN
      THEN
        CLOSE lat_dtls_csr;
      END IF;
      --Program Agreement Details Cursor
      IF pgm_agr_dtls_csr%ISOPEN
      THEN
        CLOSE pgm_agr_dtls_csr;
      END IF;
      --Lease Quote Details Cursor
      IF lse_qte_dtls_csr%ISOPEN
      THEN
        CLOSE lse_qte_dtls_csr;
      END IF;
      --Lease Application Template and Program Agreement Association Cursor
      IF lat_pgm_val_csr%ISOPEN
      THEN
        CLOSE lat_pgm_val_csr;
      END IF;
      --Unique source for Active Lease Application
      IF lap_lsq_uniq_csr%ISOPEN
      THEN
        CLOSE lap_lsq_uniq_csr;
      END IF;
      --Contract Template Validate Cursor
      IF contract_tmpl_val_csr%ISOPEN
      THEN
        CLOSE contract_tmpl_val_csr;
      END IF;
      --Checklist Template Validate Cursor
      IF checklist_val_csr%ISOPEN
      THEN
        CLOSE checklist_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease Application Template Details Cursor
      IF lat_dtls_csr%ISOPEN
      THEN
        CLOSE lat_dtls_csr;
      END IF;
      --Program Agreement Details Cursor
      IF pgm_agr_dtls_csr%ISOPEN
      THEN
        CLOSE pgm_agr_dtls_csr;
      END IF;
      --Lease Quote Details Cursor
      IF lse_qte_dtls_csr%ISOPEN
      THEN
        CLOSE lse_qte_dtls_csr;
      END IF;
      --Lease Application Template and Program Agreement Association Cursor
      IF lat_pgm_val_csr%ISOPEN
      THEN
        CLOSE lat_pgm_val_csr;
      END IF;
      --Unique source for Active Lease Application
      IF lap_lsq_uniq_csr%ISOPEN
      THEN
        CLOSE lap_lsq_uniq_csr;
      END IF;
      --Contract Template Validate Cursor
      IF contract_tmpl_val_csr%ISOPEN
      THEN
        CLOSE contract_tmpl_val_csr;
      END IF;
      --Checklist Template Validate Cursor
      IF checklist_val_csr%ISOPEN
      THEN
        CLOSE checklist_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Lease Application Template Details Cursor
      IF lat_dtls_csr%ISOPEN
      THEN
        CLOSE lat_dtls_csr;
      END IF;
      --Program Agreement Details Cursor
      IF pgm_agr_dtls_csr%ISOPEN
      THEN
        CLOSE pgm_agr_dtls_csr;
      END IF;
      --Lease Quote Details Cursor
      IF lse_qte_dtls_csr%ISOPEN
      THEN
        CLOSE lse_qte_dtls_csr;
      END IF;
      --Lease Application Template and Program Agreement Association Cursor
      IF lat_pgm_val_csr%ISOPEN
      THEN
        CLOSE lat_pgm_val_csr;
      END IF;
      --Unique source for Active Lease Application
      IF lap_lsq_uniq_csr%ISOPEN
      THEN
        CLOSE lap_lsq_uniq_csr;
      END IF;
      --Contract Template Validate Cursor
      IF contract_tmpl_val_csr%ISOPEN
      THEN
        CLOSE contract_tmpl_val_csr;
      END IF;
      --Checklist Template Validate Cursor
      IF checklist_val_csr%ISOPEN
      THEN
        CLOSE checklist_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_val;

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_accept
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_accept
  -- Description     : This procedure accepts lease application.
  -- Business Rules  : This procedure accepts lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_accept(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type) IS

    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_ACCEPT';
    l_return_status            VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec      lsqv_rec_type;
    x_lsqv_rec      lsqv_rec_type;
    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.submitted_for_acceptance';
    p_event_name1      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.quote_accepted';
    -- Bug#4741121 - viselvar  - Modified - End
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_ACCEPT';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := p_lapv_rec;
    -- Bug#4741121 - viselvar  - Modified - Start
    -- raise the business event passing the Lease Application id added to the parameter list
    wf_event.addparametertolist('LAPP_ID'
                               ,p_lapv_rec.id
                               ,l_parameter_list);

    okl_wf_pvt.raise_event(  p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);


    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Bug#4741121 - viselvar  - Modified - End

    --Populate Lease Application rec with the values from database.
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call POPULATE_LEASE_APP');
    END IF;

    POPULATE_LEASE_APP(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lap_id                => l_lapv_rec.id
       ,x_lapv_rec              => x_lapv_rec
       ,x_lsqv_rec              => x_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call POPULATE_LEASE_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of POPULATE_LEASE_APP'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := x_lapv_rec;
    l_lsqv_rec := x_lsqv_rec;
    IF(l_lapv_rec.application_status = 'PR-APPROVED')
    THEN
      --Validate Lease Application and if valid then update the status to
      --Pricing Accepted
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call LEASE_APP_VAL');
      END IF;

      LEASE_APP_VAL(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_lapv_rec              => l_lapv_rec
         ,p_lsqv_rec              => l_lsqv_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call LEASE_APP_VAL');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of LEASE_APP_VAL'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Fixed added Bug 5647107 ssdeshpa start
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call VALIDATE_LE_ID');
      END IF;

      validate_le_id(l_lsqv_rec.legal_entity_id, l_return_status);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call VALIDATE_LE_ID');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of VALIDATE_LE_ID'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      --Fixed added Bug 5647107 ssdeshpa end

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call SET_LEASE_APP_STATUS');
      END IF;

      SET_LEASE_APP_STATUS(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,p_lap_id                => l_lapv_rec.id
         ,p_lap_status            => 'PR-ACCEPTED'
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call SET_LEASE_APP_STATUS');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of SET_LEASE_APP_STATUS'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Update the lease quote to status pricing accepted
      l_lsqv_rec.status := 'CT-ACCEPTED';

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
      END IF;

      -- call the procedure to update lease quote line
      OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE(
          p_api_version                        => p_api_version
         ,p_init_msg_list                      => OKL_API.G_FALSE
         ,p_transaction_control                => OKL_API.G_TRUE
         ,p_lease_qte_rec                      => l_lsqv_rec
         ,x_lease_qte_rec                      => x_lsqv_rec
         ,x_return_status                      => l_return_status
         ,x_msg_count                          => x_msg_count
         ,x_msg_data                           => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE'
           ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
            ' l_lsqv_rec.id '|| l_lsqv_rec.id ||
            ' result status ' || l_return_status ||
            ' x_msg_data ' || x_msg_data);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Bug#4741121 - viselvar  - Modified - Start
      -- raise the business event passing the Lease Application id added to the parameter list
      -- this event is raised after the quote is accepted ie the quote status is changed
      wf_event.addparametertolist('LAPP_ID'
                               ,p_lapv_rec.id
                               ,l_parameter_list);

      okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name1
                            ,p_parameters    =>            l_parameter_list);

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Bug#4741121 - viselvar  - Modified - End
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_accept;

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_withdraw
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_withdraw
  -- Description     : This procedure withdraws lease application.
  -- Business Rules  : This procedure withdraws lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_withdraw(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type) IS

    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_WITHDRAW';
    l_return_status            VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec      lsqv_rec_type;
    x_lsqv_rec      lsqv_rec_type;

    -- Bug#4741121 - smadhava  - Added - Start
    l_parameter_list WF_PARAMETER_LIST_T;
    l_event_name     wf_events.name%TYPE;
    -- Bug#4741121 - smadhava  - Added - End
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_WITHDRAW';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := p_lapv_rec;

    --Check the status of Lease Application
    --If status not Credit submitted, credit rejected, credit approved, withdrawn
    -- then change the status to withdrawn
    --If status credit submitted then start workflow for withdrawn approval from
    --credit analyst and change the status to Withdraw Approval Pending
    --If approved from credit analyst then change the status to withdrawn
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call POPULATE_LEASE_APP');
    END IF;

    POPULATE_LEASE_APP(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lap_id                => l_lapv_rec.id
       ,x_lapv_rec              => x_lapv_rec
       ,x_lsqv_rec              => x_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call POPULATE_LEASE_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of POPULATE_LEASE_APP'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := x_lapv_rec;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call CHECK_ELIGIBILITY');
    END IF;

    --call the procedure to Validate Withdraw action on lease app
    CHECK_ELIGIBILITY(
        p_api_version     => p_api_version
       ,p_init_msg_list   => OKL_API.G_FALSE
       ,x_return_status   => l_return_status
       ,x_msg_count       => x_msg_count
       ,x_msg_data        => x_msg_data
       ,p_lap_id          => l_lapv_rec.id
       ,p_action          => 'WITHDRAW');

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call CHECK_ELIGIBILITY');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of CHECK_ELIGIBILITY'
         ,'return status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(l_lapv_rec.application_status NOT IN('CR-SUBMITTED'
                                           ,'CONV-K'
                                           ,'WITHDRAWN'))
    THEN
      l_lapv_rec.application_status := 'WITHDRAWN';

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_LAP_PVT.UPDATE_ROW');
      END IF;

      OKL_LAP_PVT.UPDATE_ROW(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_lapv_rec              => l_lapv_rec
         ,x_lapv_rec              => x_lapv_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_LAP_PVT.UPDATE_ROW');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_LAP_PVT.UPDATE_ROW'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Check if lease quote line of Lease App is in status pricing approved or
      --accepted then only call the process subsidy pool api
      IF(x_lsqv_rec.status IN ('PR-APPROVED', 'CT-ACCEPTED'))
      THEN
        --Call the API to process the lease app subsidy pool
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call OKL_LEASE_QUOTE_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL');
        END IF;

        OKL_LEASE_QUOTE_SUBPOOL_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL(
            p_api_version           => p_api_version
           ,p_init_msg_list         => OKL_API.G_FALSE
           ,p_transaction_control   => OKL_API.G_TRUE
           ,p_leaseapp_id           => l_lapv_rec.id
           ,p_transaction_reason    => 'WITHDRAW_LEASE_APP'
           ,p_quote_id              => null
           ,x_return_status         => l_return_status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call OKL_LEASE_QUOTE_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL'
             ,'l_return_status ' || l_return_status);
        END IF; -- end of statement level debug

        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;-- Checking Lease Quote status for call to process subsidy pool api

      --Call the API which will check if there is any Parent to this Lease App
      --and in status Appeal/Resubmit in Progress. If yes then restore the status
      --of parent to original status
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call REVERT_TO_ORIG_STATUS');
      END IF;

      REVERT_TO_ORIG_STATUS(
          p_api_version           => l_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,p_lap_id                => l_lapv_rec.id
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call REVERT_TO_ORIG_STATUS');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of REVERT_TO_ORIG_STATUS'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF(l_lapv_rec.application_status = 'CR-SUBMITTED')
    THEN
      --**** Instead of submitting any Withdraw Approval, need to call OCM API to Withdraw****--
      --Submit workflow for Withdraw approval
      --Bug#4741121 - smadhava  - Added - Start
      --raise workflow submit event
      l_event_name := G_WF_EVT_LEASE_APP_WDW_PENDING;

      -- Add the version id to the wf parameter list
      wf_event.AddParameterToList(G_WF_LEASE_APP_ID
                                 ,l_lapv_rec.ID
                                 ,l_parameter_list);
	--added by akrangan
	wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);


      -- Raise the workflow event for Withdrawal of lease application
      OKL_WF_PVT.raise_event(p_api_version      => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => l_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_event_name     => l_event_name,
                             p_parameters     => l_parameter_list);

      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Bug#4741121 - smadhava  - Added - End
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_withdraw;

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_dup
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_dup
  -- Description     : This procedure duplicates lease application.
  -- Business Rules  : This procedure duplicates lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --                 : 09 Feb 2006 PAGARG Bug 4960541 Added call to validations
  --                   API while creating Lease App from Lease Quote
  -- End of comments
  PROCEDURE lease_app_dup(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_source_lap_id      IN  NUMBER,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type,
            p_origin             IN  VARCHAR2) IS

    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_DUP';
    l_return_status            VARCHAR2(1);
    l_source_quote_id          NUMBER;
    l_qa_result                VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec      lsqv_rec_type;
    l_crr_rec       crr_rec_type;
    x_crr_rec       crr_rec_type;

    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.duplicated';
    -- Bug#4741121 - viselvar  - Modified - End

     --gboomina:bug 7110500 - Start
     CURSOR quote_oth_atrrib_csr(p_source_quote_id NUMBER) IS
     SELECT
      EXPECTED_FUNDING_DATE,
      EXPECTED_DELIVERY_DATE
      FROM okl_lease_quotes_v
      WHERE id = p_source_quote_id;

     quote_oth_atrrib_rec quote_oth_atrrib_csr%ROWTYPE;
     --gboomina:bug 7110500 End

    --Cursor to obtain Checklist Header Id
    CURSOR chk_hdr_dtls_csr(cp_lap_id NUMBER)
    IS
    SELECT LATV.CHECKLIST_ID
    FROM OKL_LEASE_APPLICATIONS_B LAP
        ,OKL_LEASEAPP_TEMPL_VERSIONS_V LATV
    WHERE LAP.LEASEAPP_TEMPLATE_ID = LATV.ID
      AND LAP.ID = cp_lap_id;
    chk_hdr_dtls_rec chk_hdr_dtls_csr%ROWTYPE;

    --Cursor to obtain Source Lease App details
    CURSOR src_lse_app_dtls_csr(cp_lap_id NUMBER)
    IS
      SELECT LSQ.ID LSQ_ID
      FROM OKL_LEASE_QUOTES_B LSQ
         , OKL_LEASE_APPLICATIONS_B LAP
      WHERE LSQ.PARENT_OBJECT_ID = LAP.ID
        AND LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LSQ.PRIMARY_QUOTE = 'Y'
        AND LAP.ID = cp_lap_id;
    src_lse_app_dtls_rec src_lse_app_dtls_csr%ROWTYPE;

    --Begin-bug#4721142 - varangan- cursor to fetch quote details from opportunity id
     --Cursor to obtain Source Lease App details
    CURSOR src_lse_opp_dtls_csr(cp_lap_id NUMBER)
    IS
      SELECT LSQ.ID LSQ_ID
           , LOP.ID LOP_ID
      FROM OKL_LEASE_OPPORTUNITIES_B LOP
         , OKL_LEASE_QUOTES_B LSQ
      WHERE
      LSQ.PARENT_OBJECT_ID = LOP.ID
        AND LSQ.PARENT_OBJECT_CODE = 'LEASEOPP'
        AND LSQ.STATUS = 'CT-ACCEPTED'
        AND LOP.ID = cp_lap_id;
    src_lse_opp_dtls_rec src_lse_opp_dtls_csr%ROWTYPE;
   --End-bug#4721142 - varangan- cursor to fetch quote details from opportunity id
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_DUP';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := p_lapv_rec;
    l_lsqv_rec := p_lsqv_rec;
    IF p_source_lap_id IS NOT NULL
    THEN
      --set the status for lease application
      l_lapv_rec.application_status := G_INIT_APPL_STATUS;
      --Bug 4930634 PAGARG if source for duplicate is not Lease Opp then remove
      --the link with Lease Opp from duplicated Lease App
      IF p_origin <> 'LEASEOPP'
      THEN
        l_lapv_rec.lease_opportunity_id := NULL; --Commented by VARANGAN for bug#4721142 to fetch quote details
      END IF;
    ELSE
      --BUG 4951955 PAGARG Instead of Lease Opp id, pass source Lease Quote id
      --as parameter to check default values
      OPEN src_lse_opp_dtls_csr(l_lapv_rec.lease_opportunity_id);
      FETCH src_lse_opp_dtls_csr INTO src_lse_opp_dtls_rec;
      CLOSE src_lse_opp_dtls_csr;

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call CHECK_LEASE_QUOTE_DEFAULTS');
      END IF;

      CHECK_LEASE_QUOTE_DEFAULTS(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_source_lsq_id         => src_lse_opp_dtls_rec.lsq_id
         ,p_lapv_rec              => l_lapv_rec
         ,p_lsqv_rec              => l_lsqv_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call CHECK_LEASE_QUOTE_DEFAULTS');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON)
	  THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of CHECK_LEASE_QUOTE_DEFAULTS'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      -- Check the status and accordingly set the Lease Application Status
      IF(l_return_status = OKL_API.G_RET_STS_SUCCESS)THEN
        l_lapv_rec.application_status := 'PR-ACCEPTED';
      ELSE
        --set the status for lease application
        l_lapv_rec.application_status := G_INIT_APPL_STATUS;
      END IF;
    END IF;

    --Validate Lease Application Template
    --Validate Program Agreement
    --Validate VP and LAT association
    --Validate Lease Quote
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call LEASE_APP_VAL');
    END IF;

    LEASE_APP_VAL(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lapv_rec              => l_lapv_rec
       ,p_lsqv_rec              => l_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call LEASE_APP_VAL');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of LEASE_APP_VAL'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_LAP_PVT.INSERT_ROW');
    END IF;

    -- call the TAPI insert_row to create a lease application
    OKL_LAP_PVT.INSERT_ROW(
        p_api_version                        => p_api_version
       ,p_init_msg_list                      => OKL_API.G_FALSE
       ,x_return_status                      => l_return_status
       ,x_msg_count                          => x_msg_count
       ,x_msg_data                           => x_msg_data
       ,p_lapv_rec                           => l_lapv_rec
       ,x_lapv_rec                           => x_lapv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_LAP_PVT.INSERT_ROW');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_LAP_PVT.INSERT_ROW'
         ,'l_lapv_rec.reference_number ' || to_char(l_lapv_rec.reference_number) ||
          ' l_lapv_rec.id '|| l_lapv_rec.id ||
          ' result status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate lease quote rec values
    l_lsqv_rec.parent_object_code := 'LEASEAPP';
    l_lsqv_rec.parent_object_id := x_lapv_rec.id;
    --Bug 4721142 PAGARG set the lease quote reference number form sequence
    --Bug 4867953 PAGARG instead of using the sequence directly use function
    l_lsqv_rec.reference_number := get_next_seq_num(
                                       'OKL_LSQ_REF_SEQ'
                                      ,'OKL_LEASE_QUOTES_B'
                                      ,'REFERENCE_NUMBER');
    --Bug Fix End
    l_lsqv_rec.primary_quote := 'Y';
    l_lsqv_rec.status := 'PR-INCOMPLETE';

    IF p_source_lap_id IS NULL
       AND l_lapv_rec.application_status = 'PR-ACCEPTED'
    THEN
      l_lsqv_rec.status := 'CT-ACCEPTED';
    END IF;

    --Obtain the lease quote id attached to lease application and pass it as
    --source to duplicate lease quote.
    --This way it will duplicate lease quote with header values from rec and
    --rest of configuration, adjustment, pricing data from the source lease quote id

--Begin-bug#4721142 - varangan- cursor to fetch quote details from opportunity id
    IF p_source_lap_id IS NULL
    THEN
      IF x_lapv_rec.lease_opportunity_id IS NOT NULL
      THEN
        OPEN src_lse_opp_dtls_csr(x_lapv_rec.lease_opportunity_id);
        FETCH src_lse_opp_dtls_csr INTO src_lse_opp_dtls_rec;
        CLOSE src_lse_opp_dtls_csr;
        l_source_quote_id := src_lse_opp_dtls_rec.lsq_id;

        -- gboomina Bug 7110500: start
        OPEN quote_oth_atrrib_csr(l_source_quote_id);
        FETCH quote_oth_atrrib_csr INTO quote_oth_atrrib_rec;
        CLOSE quote_oth_atrrib_csr;

        l_lsqv_rec.EXPECTED_FUNDING_DATE:=quote_oth_atrrib_rec.EXPECTED_FUNDING_DATE;
        l_lsqv_rec.EXPECTED_DELIVERY_DATE:=quote_oth_atrrib_rec.EXPECTED_DELIVERY_DATE;

        -- gboomina Bug 7110500: End

      END IF;
    ELSE
        OPEN src_lse_app_dtls_csr(p_source_lap_id);
        FETCH src_lse_app_dtls_csr INTO src_lse_app_dtls_rec;
        CLOSE src_lse_app_dtls_csr;
        l_source_quote_id := src_lse_app_dtls_rec.lsq_id;
    END IF;
--End-bug#4721142 - varangan- cursor to fetch quote details from opportunity id

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE');
    END IF;

    -- call the procedure to create lease quote line
    OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE(
        p_api_version                        => p_api_version
       ,p_init_msg_list                      => OKL_API.G_FALSE
       ,p_transaction_control                => OKL_API.G_TRUE
       ,p_source_quote_id                    => l_source_quote_id
       ,p_lease_qte_rec                      => l_lsqv_rec
       ,x_lease_qte_rec                      => x_lsqv_rec
       ,x_return_status                      => l_return_status
       ,x_msg_count                          => x_msg_count
       ,x_msg_data                           => x_msg_data);

	IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE'
         ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
          ' l_lsqv_rec.id '|| l_lsqv_rec.id ||
          ' result status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug 4960541 PAGARG Added call to validations API while creating Lease
    --App from Lease Quote. Based on qa result Lease App and Lease Quote status
    --are updated
    l_lsqv_rec := x_lsqv_rec;
    IF l_lsqv_rec.status = 'CT-ACCEPTED'
    THEN
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call LEASE_APP_QA_VAL');
      END IF;

      -- call the procedure to perform QA validations
      LEASE_APP_QA_VAL(
          p_api_version                => p_api_version
         ,p_init_msg_list              => OKL_API.G_FALSE
         ,p_lap_id                     => x_lapv_rec.id
         ,x_return_status              => l_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,x_qa_result                  => l_qa_result);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call LEASE_APP_QA_VAL');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE
           ,' Result of LEASE_APP_QA_VAL' ||
            ' Result Status ' || l_return_status ||
            ' QA Result Status ' || l_qa_result);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF l_qa_result <> OKL_API.G_RET_STS_SUCCESS
      THEN
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call SET_LEASE_APP_STATUS');
        END IF;

        --call the procedure to update a lease application status
        SET_LEASE_APP_STATUS(
            p_api_version     => p_api_version
           ,p_init_msg_list   => OKL_API.G_FALSE
           ,p_lap_id          => x_lapv_rec.id
           ,p_lap_status      => G_INIT_APPL_STATUS
           ,x_return_status   => l_return_status
           ,x_msg_count       => x_msg_count
           ,x_msg_data        => x_msg_data);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call SET_LEASE_APP_STATUS');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of SET_LEASE_APP_STATUS'
             ,'return status ' || l_return_status ||
              ' x_msg_data ' || x_msg_data);
        END IF; -- end of statement level debug

        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_lsqv_rec.status := 'PR-INCOMPLETE';
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
        END IF;

        -- call the procedure to create lease quote line
        OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE(
            p_api_version               => p_api_version
           ,p_init_msg_list             => OKL_API.G_FALSE
           ,p_transaction_control       => OKL_API.G_TRUE
           ,p_lease_qte_rec             => l_lsqv_rec
           ,x_lease_qte_rec             => x_lsqv_rec
           ,x_return_status             => l_return_status
           ,x_msg_count                 => x_msg_count
           ,x_msg_data                  => x_msg_data);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE'
             ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
              ' l_lsqv_rec.id '|| l_lsqv_rec.id ||
              ' result status ' || l_return_status ||
              ' x_msg_data ' || x_msg_data);
        END IF; -- end of statement level debug

        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      -- Bug 7440199: Quote Streams ER: RGOOTY: Start
      ELSE
        --Making the pricing call to generate the streams
        --Start Pricing API call
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
             FND_LOG.LEVEL_PROCEDURE
            ,L_MODULE
            ,'begin debug call OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE');
        END IF;

        OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE(
           p_api_version            => p_api_version
          ,p_init_msg_list          => OKL_API.G_FALSE
          ,p_qte_id                 => x_lsqv_rec.id
          ,x_return_status          => l_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE'
             ,'l_return_status ' || l_return_status);
        END IF; -- end of statement level debug

        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        --End of Pricing API call
       -- Bug 7440199: Quote Streams ER: RGOOTY: End
      END IF; -- For QA Result Check
    END IF;-- Check for Lease Quote status to call QA validation

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call CREATE_CREDIT_APP');
    END IF;

    --call to duplicate Credit Lease Application
    CREATE_CREDIT_APP(
        p_api_version        => p_api_version
       ,p_init_msg_list      => OKL_API.G_FALSE
       ,x_return_status      => l_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       ,p_lapv_rec           => x_lapv_rec
       ,p_crr_rec            => l_crr_rec
       ,x_crr_rec            => x_crr_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call CREATE_CREDIT_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of CREATE_CREDIT_APP'
         ,' result status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN chk_hdr_dtls_csr(x_lapv_rec.id);
    FETCH chk_hdr_dtls_csr INTO chk_hdr_dtls_rec;
    CLOSE chk_hdr_dtls_csr;

    IF(chk_hdr_dtls_rec.checklist_id IS NOT NULL)
    THEN
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call CHECKLIST_INST_CRE');
      END IF;

      --call to create Checklist Instance
      CHECKLIST_INST_CRE(
          p_api_version        => p_api_version
         ,p_init_msg_list      => OKL_API.G_FALSE
         ,x_return_status      => l_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_lap_id             => x_lapv_rec.id
		 ,p_chklst_tmpl_id     => chk_hdr_dtls_rec.checklist_id);

	  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call CHECKLIST_INST_CRE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of CHECKLIST_INST_CRE'
           ,' result status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- Condition to check for call to create checklist instance

    -- Bug#4741121 - viselvar  - Modified - Start
    -- raise the business event passing the Lease Application id added to the parameter list
    wf_event.addparametertolist('LAPP_ID'
                               ,x_lapv_rec.id
                               ,l_parameter_list);
    okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Bug#4741121 - viselvar  - Modified - End

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Lease Application Source Details Cursor
      IF src_lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE src_lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Lease Application Source Details Cursor
      IF src_lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE src_lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Lease Application Source Details Cursor
      IF src_lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE src_lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_dup;

  ------------------------------------------------------------------------------
  -- PROCEDURE submit_for_pricing
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : submit_for_pricing
  -- Description     : This procedure submits lease application for pricing.
  -- Business Rules  : This procedure submits lease application for pricing.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE submit_for_pricing(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type) IS

    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'SUBMIT_FOR_PRICING';
    l_return_status            VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec      lsqv_rec_type;
    x_lsqv_rec      lsqv_rec_type;
    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list  wf_parameter_list_t;
    p_event_name1      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.sent_for_pricing_approval';
    p_event_name2      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.pricing_approved';
    -- Bug#4741121 - viselvar  - Modified - End

    --Cursor to obtain the details of lease quote line of Lease App
    CURSOR l_lsq_dtls_csr(p_lap_id NUMBER)
	IS
      SELECT LSQ.ID LSQ_ID
           , LSQ.STATUS STATUS
      FROM OKL_LEASE_QUOTES_B LSQ
      WHERE LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LSQ.PRIMARY_QUOTE= 'Y'
        AND LSQ.PARENT_OBJECT_ID = p_lap_id;
    l_lsq_dtls_rec l_lsq_dtls_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.SUBMIT_FOR_PRICING';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := p_lapv_rec;

    -- Bug#4741121 - viselvar  - Modified - Start
    -- raise the business event passing the Lease Application id added to the parameter list
    wf_event.addparametertolist('LAPP_ID'
                               ,p_lapv_rec.id
                               ,l_parameter_list);

    okl_wf_pvt.raise_event(  p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name1
                            ,p_parameters    =>            l_parameter_list);

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Bug#4741121 - viselvar  - Modified - End

    --Populate Lease Application rec with the values from database.
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call POPULATE_LEASE_APP');
    END IF;

    POPULATE_LEASE_APP(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lap_id                => l_lapv_rec.id
       ,x_lapv_rec              => x_lapv_rec
       ,x_lsqv_rec              => x_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call POPULATE_LEASE_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of POPULATE_LEASE_APP'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := x_lapv_rec;
    l_lsqv_rec := x_lsqv_rec;

    IF(l_lapv_rec.application_status = 'PR-COMPLETE')
    THEN
      --Validate Lease Application and if valid then update the status to
      --Pricing Submitted
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call LEASE_APP_VAL');
      END IF;

      LEASE_APP_VAL(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_lapv_rec              => l_lapv_rec
         ,p_lsqv_rec              => l_lsqv_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call LEASE_APP_VAL');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of LEASE_APP_VAL'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --set the status of Lease Application to Pricing Submitted
      l_lapv_rec.application_status := 'PR-SUBMITTED';

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call SET_LEASE_APP_STATUS');
      END IF;

      SET_LEASE_APP_STATUS(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,p_lap_id                => l_lapv_rec.id
         ,p_lap_status            => l_lapv_rec.application_status
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call SET_LEASE_APP_STATUS');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of SET_LEASE_APP_STATUS'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Obtain the details of Lease Quote line of Lease App
      OPEN l_lsq_dtls_csr(l_lapv_rec.id);
      FETCH l_lsq_dtls_csr INTO l_lsq_dtls_rec;
      CLOSE l_lsq_dtls_csr;

      --Call the API to submit the lease quote for Pricing Approval
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_LEASE_QUOTE_PVT.SUBMIT_LEASE_QTE');
      END IF;

      OKL_LEASE_QUOTE_PVT.SUBMIT_LEASE_QTE(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,p_transaction_control   => OKL_API.G_TRUE
         ,p_quote_id		   	  => l_lsq_dtls_rec.lsq_id
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_LEASE_QUOTE_PVT.SUBMIT_LEASE_QTE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.SUBMIT_LEASE_QTE'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Check if lease quote line of Lease App is in status pricing complete
      --then only call the process subsidy pool api
      IF(l_lsq_dtls_rec.status = 'PR-COMPLETE')
      THEN
        --Call the API to process the lease app subsidy pool
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call OKL_LEASE_QUOTE_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL');
        END IF;

        OKL_LEASE_QUOTE_SUBPOOL_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL(
            p_api_version           => p_api_version
           ,p_init_msg_list         => OKL_API.G_FALSE
           ,p_transaction_control   => OKL_API.G_TRUE
           ,p_leaseapp_id		   	=> l_lapv_rec.id
           ,p_transaction_reason    => 'APPROVE_LEASE_APP_PRICING'
           ,p_quote_id              => l_lsq_dtls_rec.lsq_id
           ,x_return_status         => l_return_status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call OKL_LEASE_QUOTE_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL'
             ,'l_return_status ' || l_return_status);
        END IF; -- end of statement level debug

        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;-- Checking Lease Quote status for call to process subsidy pool api
    ELSE
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_LSE_APP_PR_SUB_FAIL',
          p_token1        => 'TEXT',
          p_token1_value  => l_lapv_rec.reference_number);
    END IF;

    -- Bug#4741121 - viselvar  - Modified - Start
    -- raise the business event passing the Lease Application id added to the parameter list

    wf_event.addparametertolist('LAPP_ID'
                               ,p_lapv_rec.id
                               ,l_parameter_list);

    okl_wf_pvt.raise_event(  p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name2
                            ,p_parameters    =>            l_parameter_list);


    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   -- Bug#4741121 - viselvar  - Modified - End

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END submit_for_pricing;

  ------------------------------------------------------------------------------
  -- PROCEDURE submit_for_credit
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : submit_for_credit
  -- Description     : This procedure submits lease application for Credit Approval.
  -- Business Rules  : This procedure submits lease application for Credit Approval.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --                 : 23 Dec 2005 PAGARG Bug 4902717 Update the Requested Amount
  --                   on Credit Application before submitting it for approval
  --                 : 03 Apr 2006 PAGARG Bug 4872271 Added validation to check
  --                   appeal allowed period befor submitting for credit approval
  --                   This validation is needed for Lease App with action APPEAL
  -- End of comments
  PROCEDURE submit_for_credit(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type) IS

    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'SUBMIT_FOR_CREDIT';
    l_return_status            VARCHAR2(1);
    l_req_amt                  NUMBER;
    l_meaning                  VARCHAR2(80);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec      lsqv_rec_type;
    x_lsqv_rec      lsqv_rec_type;
    l_crd_req_rec   OCM_CREDIT_REQUEST_UPDATE_PUB.credit_request_rec;
    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.submitted_for_credit_evaluation';
    -- Bug#4741121 - viselvar  - Modified - End
    l_count         NUMBER;
    l_exp_date      DATE;

    --Cursor to obtain Credit Request Details
    CURSOR acr_dtls_csr(cp_lap_id NUMBER) IS
      SELECT CREDIT_REQUEST_ID CREDIT_REQUEST_ID
        FROM AR_CMGT_CREDIT_REQUESTS ACR
       WHERE ACR.SOURCE_COLUMN3 = 'LEASEAPP' -- Fix for Bug 4749255
         AND ACR.SOURCE_COLUMN1 = cp_lap_id;
    acr_dtls_rec acr_dtls_csr%ROWTYPE;

    --Cursor to obtain the details of lease quote line of Lease App
    CURSOR l_lsq_dtls_csr(p_lap_id NUMBER)
	IS
      SELECT LSQ.ID LSQ_ID
           , LSQ.REFERENCE_NUMBER REFERENCE_NUMBER
      FROM OKL_LEASE_QUOTES_B LSQ
      WHERE LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LSQ.PRIMARY_QUOTE= 'Y'
        AND LSQ.PARENT_OBJECT_ID = p_lap_id;
    l_lsq_dtls_rec l_lsq_dtls_csr%ROWTYPE;

    --Cursor to check whether a given recommendation is added to given Lease App
    CURSOR credit_recom_csr(p_lap_id NUMBER, p_recomm VARCHAR2, p_appeal VARCHAR2) IS
      SELECT COUNT(*)
      FROM AR_CMGT_CF_RECOMMENDS RCM
         , AR_CMGT_CREDIT_REQUESTS CCR
      WHERE RCM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND RCM.CREDIT_RECOMMENDATION = NVL(p_recomm, RCM.CREDIT_RECOMMENDATION)
        AND NVL(RCM.APPEALED_FLAG, 'N') = NVL(p_appeal, NVL(RCM.APPEALED_FLAG, 'N'))
        AND CCR.SOURCE_COLUMN1 = p_lap_id;

    --Cursor to obtain appeal period expiration date for a given Lease App
    CURSOR appeal_exp_date_csr(p_lap_id NUMBER)
    IS
      SELECT RCM.RECOMMENDATION_VALUE1 + TRUNC(LAST_UPDATED) APPEAL_EXP_DATE
      FROM AR_CMGT_CASE_FOLDERS CCF
         , AR_CMGT_CREDIT_REQUESTS CCR
         , AR_CMGT_CF_RECOMMENDS RCM
      WHERE CCR.CREDIT_REQUEST_ID = CCF.CREDIT_REQUEST_ID
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCF.STATUS = 'CLOSED'
        AND RCM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND RCM.CREDIT_RECOMMENDATION = 'AUTHORIZE_APPEAL'
        AND CCR.SOURCE_COLUMN1 = p_lap_id;

    --Cursor to obtain Lease Application Details
    CURSOR lse_app_dtls_csr(p_lap_id NUMBER) IS
      SELECT LAB.REFERENCE_NUMBER
        FROM OKL_LEASE_APPLICATIONS_B LAB
       WHERE LAB.ID = p_lap_id;
    lse_app_dtls_rec lse_app_dtls_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.SUBMIT_FOR_CREDIT';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := p_lapv_rec;

    --Populate Lease Application rec with the values from database.
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call POPULATE_LEASE_APP');
    END IF;

    POPULATE_LEASE_APP(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lap_id                => l_lapv_rec.id
       ,x_lapv_rec              => x_lapv_rec
       ,x_lsqv_rec              => x_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call POPULATE_LEASE_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of POPULATE_LEASE_APP'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := x_lapv_rec;
    l_lsqv_rec := x_lsqv_rec;
    --Validate if Lease App is appealed Lease Application then whether parent
    --Lease App is allowed for appeal and appeal period has not expired
    IF(l_lapv_rec.action = 'APPEAL')
    THEN
      OPEN lse_app_dtls_csr(l_lapv_rec.parent_leaseapp_id);
      FETCH lse_app_dtls_csr INTO lse_app_dtls_rec;
      CLOSE lse_app_dtls_csr;
      --Check if AUTHORIZE_APPEAL recommendation is added for parent lease app
      OPEN credit_recom_csr(l_lapv_rec.parent_leaseapp_id, 'AUTHORIZE_APPEAL', NULL);
      FETCH credit_recom_csr INTO l_count;
      CLOSE credit_recom_csr;
      IF(l_count = 1)
      THEN
        OPEN appeal_exp_date_csr(l_lapv_rec.parent_leaseapp_id);
        FETCH appeal_exp_date_csr INTO l_exp_date;
        CLOSE appeal_exp_date_csr;
        IF(l_exp_Date IS NULL OR l_exp_Date < TRUNC(SYSDATE))
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_SO_LSE_APP_APPEAL_PRD_EXP',
              p_token1       => 'TEXT',
              p_token1_value => lse_app_dtls_rec.reference_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_SO_LSE_APP_APPEAL_AUTH_ERR',
            p_token1       => 'TEXT',
            p_token1_value => lse_app_dtls_rec.reference_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      --Check if atleast one of the recommendations of parent lease app is marked
      --for appeal
      OPEN credit_recom_csr(l_lapv_rec.parent_leaseapp_id, NULL, 'Y');
      FETCH credit_recom_csr INTO l_count;
      CLOSE credit_recom_csr;
      IF(l_count = 0)
      THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_SO_LSE_APP_APL_RECOM_ERR');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;--Check for Appeal validity

    IF(l_lapv_rec.application_status IN ('PR-ACCEPTED'))
    THEN
      --Validate Lease Application and if valid then update the status to
      --Pricing Accepted
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call LEASE_APP_VAL');
      END IF;

      LEASE_APP_VAL(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_lapv_rec              => l_lapv_rec
         ,p_lsqv_rec              => l_lsqv_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call LEASE_APP_VAL');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of LEASE_APP_VAL'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OPEN acr_dtls_csr(l_lapv_rec.id);
      FETCH acr_dtls_csr INTO acr_dtls_rec;
      CLOSE acr_dtls_csr;

      --Obtain the details of Lease Quote line of Lease App
      OPEN l_lsq_dtls_csr(l_lapv_rec.id);
      FETCH l_lsq_dtls_csr INTO l_lsq_dtls_rec;
      CLOSE l_lsq_dtls_csr;

      l_req_amt := get_financed_amount(l_lsq_dtls_rec.lsq_id);
      IF(l_req_amt <= 0)
      THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_AMOUNT_GREATER_THAN_ZERO');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSE
        -- Bug 4902717 PAGARG Update the Requested Amount on Credit Application
	    --before submitting it for approval
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC');
        END IF;
        --get the existing credit request data
        OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC(
            p_credit_request_id  => acr_dtls_rec.credit_request_id
           ,p_return_status      => l_return_status
           ,p_error_msg          => x_msg_data
           ,p_credit_request_rec => l_crd_req_rec);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC'
             ,' result status ' || l_return_status);
        END IF; -- end of statement level debug

        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --assign the new values
        l_crd_req_rec.requested_amount := l_req_amt;
        l_crd_req_rec.trx_amount := l_req_amt; -- added for bug 6596860

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST');
        END IF;
        --update the credit application data
        OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST(
            p_api_version           => l_api_version,
            p_init_msg_list         => OKL_API.G_FALSE,
            p_commit                => NULL,
            p_validation_level      => NULL,
            x_return_status         => l_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_credit_request_rec    => l_crd_req_rec);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST'
             ,' result status ' || l_return_status);
        END IF; -- end of statement level debug

        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      --Trigger the Credit Approval workflow
      --Bug#4741121 - viselvar  - Modified - Start
      --raise the business event passing the Lease Application id added to the parameter list
      wf_event.addparametertolist('LAPP_ID'
                               ,x_lapv_rec.id
                               ,l_parameter_list);
      okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Bug#4741121 - viselvar  - Modified - End

      --11/05/05 SNAMBIAR - we should not update other teams table like this
      --changing the update statement and calling the API.
      --This API will take care of the business event also.
      /*  UPDATE AR_CMGT_CREDIT_REQUESTS
        SET status = 'SUBMIT'
        WHERE credit_request_id= acr_dtls_rec.credit_request_id;

        AR_CMGT_WF_ENGINE.START_WORKFLOW(
           acr_dtls_rec.credit_request_id
          ,'SUBMIT');
      */
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST_STATUS');
      END IF;

      OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST_STATUS(
          p_api_version           => l_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,p_commit                => OKL_API.G_FALSE
         ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_credit_request_id     => acr_dtls_rec.credit_request_id
         ,p_credit_request_status => 'SUBMIT');

	  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST_STATUS');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST_STATUS'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_lapv_rec.application_status := 'CR-SUBMITTED';

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call SET_LEASE_APP_STATUS');
      END IF;

      SET_LEASE_APP_STATUS(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,p_lap_id                => l_lapv_rec.id
         ,p_lap_status            => l_lapv_rec.application_status
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call SET_LEASE_APP_STATUS');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of SET_LEASE_APP_STATUS'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
      l_return_status := OKL_API.G_RET_STS_ERROR;
      l_meaning := get_lookup_meaning('OKL_LEASE_APP_STATUS', 'CR-SUBMITTED');
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_LSE_APP_ACTION_ERR',
          p_token1        => 'TEXT',
          p_token1_value  => l_lapv_rec.reference_number,
          p_token2        => 'STATUS',
          p_token2_value  => l_lapv_rec.application_status,
          p_token3        => 'ACTION',
          p_token3_value  => l_meaning);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Credit Request Details Cursor
      IF acr_dtls_csr%ISOPEN
      THEN
        CLOSE acr_dtls_csr;
      END IF;
      --Lease Quote Details Cursor
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      --Check if Credit Recommendation cursor is open
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Check if Appeal Exp Date cursor is open
      IF appeal_exp_date_csr%ISOPEN
      THEN
        CLOSE appeal_exp_date_csr;
      END IF;
      --Check if Lease App details cursor is open
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Credit Request Details Cursor
      IF acr_dtls_csr%ISOPEN
      THEN
        CLOSE acr_dtls_csr;
      END IF;
      --Lease Quote Details Cursor
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      --Check if Credit Recommendation cursor is open
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Check if Appeal Exp Date cursor is open
      IF appeal_exp_date_csr%ISOPEN
      THEN
        CLOSE appeal_exp_date_csr;
      END IF;
      --Check if Lease App details cursor is open
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Credit Request Details Cursor
      IF acr_dtls_csr%ISOPEN
      THEN
        CLOSE acr_dtls_csr;
      END IF;
      --Lease Quote Details Cursor
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      --Check if Credit Recommendation cursor is open
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Check if Appeal Exp Date cursor is open
      IF appeal_exp_date_csr%ISOPEN
      THEN
        CLOSE appeal_exp_date_csr;
      END IF;
      --Check if Lease App details cursor is open
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END submit_for_credit;

  ------------------------------------------------------------------------------
  -- FUNCTION is_valid_program_agreement
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_valid_program_agreement
  -- Description     : This function returns whether Program Agreement fulfills
  --                   all eligibility criteria on Lease Application
  -- Business Rules  : This function returns whether Program Agreement fulfills
  --                   all eligibility criteria on Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 08-JUNE-2005 PAGARG created
  --
  -- End of comments
  FUNCTION is_valid_program_agreement(
           p_pgm_agr_id          IN NUMBER,
           p_lap_id              IN NUMBER,
           p_eff_from            IN DATE)
    RETURN VARCHAR2
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'IS_VALID_PROGRAM_AGREEMENT';
    l_return_status            VARCHAR2(1);
    l_eligible                 BOOLEAN;
    x_msg_count                NUMBER;
    x_msg_data                 VARCHAR2(32767);

    -- Record/Table Type Declarations
    l_okl_ec_rec		OKL_ECC_PUB.okl_ec_rec_type;

    --Cursor to obtain Program Agreement Details
    CURSOR pgm_agr_dtls_csr(cp_pgm_agr_id NUMBER) IS
      SELECT CONTRACT_NUMBER PROGRAM_AGREEMENT
        FROM OKC_K_HEADERS_B CHR
       WHERE CHR.ID = cp_pgm_agr_id
         AND CHR.SCS_CODE = 'PROGRAM';
    pgm_agr_dtls_rec pgm_agr_dtls_csr%ROWTYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_ERROR;
    l_eligible := false;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.IS_VALID_PROGRAM_AGREEMENT';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    OPEN pgm_agr_dtls_csr(p_pgm_agr_id);
    FETCH pgm_agr_dtls_csr INTO pgm_agr_dtls_rec;
    CLOSE pgm_agr_dtls_csr;

    l_okl_ec_rec.src_id := p_pgm_agr_id;
    l_okl_ec_rec.src_type := 'VENDOR_PROGRAM';
    l_okl_ec_rec.validation_mode := 'LOV';
    l_okl_ec_rec.source_name := pgm_agr_dtls_rec.program_agreement;

    IF(p_lap_id IS NOT NULL AND p_lap_id <> OKL_API.G_MISS_NUM)
    THEN
      --Populate the EC rec
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call POPULATE_EC_REC');
      END IF;

      POPULATE_EC_REC(
          p_api_version           => l_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,p_lap_id                => p_lap_id
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,lx_okl_ec_rec           => l_okl_ec_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call POPULATE_EC_REC');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of POPULATE_EC_REC'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
      l_okl_ec_rec.target_eff_from := p_eff_from;
    END IF;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_ECC_PUB.EVALUATE_ELIGIBILITY_CRITERIA');
    END IF;

    OKL_ECC_PUB.EVALUATE_ELIGIBILITY_CRITERIA(
        p_api_version           => l_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_okl_ec_rec            => l_okl_ec_rec
       ,x_eligible              => l_eligible);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_ECC_PUB.EVALUATE_ELIGIBILITY_CRITERIA');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_ECC_PUB.EVALUATE_ELIGIBILITY_CRITERIA'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(l_return_status = OKL_API.G_RET_STS_SUCCESS AND l_eligible)
    THEN
      l_return_status := OKL_API.G_RET_STS_SUCCESS;
    ELSE
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Program Agreement Details Cursor
      IF pgm_agr_dtls_csr%ISOPEN
      THEN
        CLOSE pgm_agr_dtls_csr;
      END IF;
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Program Agreement Details Cursor
      IF pgm_agr_dtls_csr%ISOPEN
      THEN
        CLOSE pgm_agr_dtls_csr;
      END IF;
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Program Agreement Details Cursor
      IF pgm_agr_dtls_csr%ISOPEN
      THEN
        CLOSE pgm_agr_dtls_csr;
      END IF;
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END is_valid_program_agreement;

  ------------------------------------------------------------------------------
  -- FUNCTION is_valid_leaseapp_template
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_valid_leaseapp_template
  -- Description     : This function returns whether Lease Application Template
  --                   fulfills all eligibility criteria on Lease Application
  -- Business Rules  : This function returns whether Program Agreement fulfills
  --                   all eligibility criteria on Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 08-JUNE-2005 PAGARG created
  --
  -- End of comments
  FUNCTION is_valid_leaseapp_template(
           p_lat_id              IN NUMBER,
           p_lap_id              IN NUMBER,
           p_eff_from            IN DATE)
    RETURN VARCHAR2
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'IS_VALID_LEASEAPP_TEMPLATE';
    l_return_status            VARCHAR2(1);
    l_eligible                 BOOLEAN;
    x_msg_count                NUMBER;
    x_msg_data                 VARCHAR2(32767);

    -- Record/Table Type Declarations
    l_okl_ec_rec		OKL_ECC_PUB.okl_ec_rec_type;

    --Cursor to obtain Lease Application Template Details
    CURSOR lat_dtls_csr(cp_lat_id NUMBER) IS
      SELECT LAT.NAME LAT_NUMBER
        FROM OKL_LEASEAPP_TEMPLATES LAT
            ,OKL_LEASEAPP_TEMPL_VERSIONS_V LATV
       WHERE LATV.LEASEAPP_TEMPLATE_ID = LAT.ID
	     AND LATV.ID = cp_lat_id;
    lat_dtls_rec lat_dtls_csr%ROWTYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_ERROR;
    l_eligible := false;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.IS_VALID_LEASEAPP_TEMPLATE';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    IF(p_lat_id IS NOT NULL
	   AND p_lat_id <> OKL_API.G_MISS_NUM)
    THEN
      OPEN lat_dtls_csr(p_lat_id);
      FETCH lat_dtls_csr INTO lat_dtls_rec;
      CLOSE lat_dtls_csr;
      l_okl_ec_rec.src_id := p_lat_id;
      l_okl_ec_rec.src_type := 'LEASE_APPL_TEMPLATE';
      l_okl_ec_rec.validation_mode := 'LOV';
      l_okl_ec_rec.source_name := lat_dtls_rec.lat_number;
    END IF;

    IF(p_lap_id IS NOT NULL
	   AND p_lap_id <> OKL_API.G_MISS_NUM)
    THEN
      --Populate the EC rec
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call POPULATE_EC_REC');
      END IF;

      POPULATE_EC_REC(
          p_api_version           => l_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,p_lap_id                => p_lap_id
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,lx_okl_ec_rec           => l_okl_ec_rec);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call POPULATE_EC_REC');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of POPULATE_EC_REC'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
      l_okl_ec_rec.target_eff_from := p_eff_from;
    END IF;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_ECC_PUB.EVALUATE_ELIGIBILITY_CRITERIA');
    END IF;

    OKL_ECC_PUB.EVALUATE_ELIGIBILITY_CRITERIA(
        p_api_version           => l_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_okl_ec_rec            => l_okl_ec_rec
       ,x_eligible              => l_eligible);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_ECC_PUB.EVALUATE_ELIGIBILITY_CRITERIA');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_ECC_PUB.EVALUATE_ELIGIBILITY_CRITERIA'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(l_return_status = OKL_API.G_RET_STS_SUCCESS AND l_eligible)
    THEN
      l_return_status := OKL_API.G_RET_STS_SUCCESS;
    ELSE
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease Application Template Details Cursor
      IF lat_dtls_csr%ISOPEN
      THEN
        CLOSE lat_dtls_csr;
      END IF;
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease Application Template Details Cursor
      IF lat_dtls_csr%ISOPEN
      THEN
        CLOSE lat_dtls_csr;
      END IF;
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Lease Application Template Details Cursor
      IF lat_dtls_csr%ISOPEN
      THEN
        CLOSE lat_dtls_csr;
      END IF;
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END is_valid_leaseapp_template;

  ------------------------------------------------------------------------------
  -- FUNCTION get_credit_classfication
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_credit_classfication
  -- Description     : This function returns credit classification for given
  --                   party, customer account or customer account site use.
  -- Business Rules  : This function returns credit classification for given
  --                   party, customer account or customer account site use.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-JUNE-2005 PAGARG created
  --
  -- End of comments
  FUNCTION get_credit_classfication(
           p_party_id            IN NUMBER,
           p_cust_acct_id        IN NUMBER,
           p_site_use_id         IN NUMBER)
    RETURN VARCHAR2
  IS
    -- Variables Declarations
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'GET_CREDIT_CLASSFICATION';
    l_cr_class                 ar_cmgt_credit_requests.credit_classification%type;
    l_party_id                 NUMBER;
    l_cust_acct_id             NUMBER;
    l_site_use_id              NUMBER;

  BEGIN
    l_cr_class := NULL;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.GET_CREDIT_CLASSFICATION';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    l_party_id     := p_party_id;
    l_cust_acct_id := p_cust_acct_id;
    l_site_use_id  := p_site_use_id;

    --Begin viselvar bug#4740946
--Begin-varangan-bug#4723072-getting site level risk
   /*If (p_site_use_id IS NOT NULL AND p_site_use_id  <> OKL_API.G_MISS_NUM) Then
	  Begin
		  select a.site_use_id site_use_id
		  Into l_site_use_id
		   from Hz_cust_site_uses a,
			Hz_cust_acct_sites b
		   Where a.CUST_ACCT_SITE_ID=B.CUST_ACCT_SITE_ID
		   AND A.SITE_USE_CODE='BILL_TO'
		   AND B.PARTY_SITE_ID=p_site_use_id;

	  Exception
		when others then
		l_site_use_id:=NULL;
	  End;
     End If;*/
--End-varangan-bug#4723072-getting site level risk
-- End viselvar Bug#4723072

    IF(l_party_id IS NULL OR l_party_id = OKL_API.G_MISS_NUM)
    THEN
      l_party_id := -99;
    END IF;
    IF(l_cust_acct_id IS NULL OR l_cust_acct_id = OKL_API.G_MISS_NUM)
    THEN
      l_cust_acct_id := -99;
    END IF;
    IF(l_site_use_id IS NULL OR l_site_use_id = OKL_API.G_MISS_NUM)
    THEN
      l_site_use_id := -99;
    END IF;

    l_cr_class := AR_CMGT_UTIL.get_credit_classification(
                       p_party_id         => l_party_id,
                       p_cust_account_id  => l_cust_acct_id,
                       p_site_use_id      => l_site_use_id);
    IF(l_cr_class IS NULL OR l_cr_class = 'NULL')
    THEN
      SELECT DEFAULT_CREDIT_CLASSIFICATION
        INTO l_cr_class
        FROM AR_CMGT_SETUP_OPTIONS;
    END IF;

    RETURN l_cr_class;
  EXCEPTION
    WHEN OTHERS THEN
      l_cr_class := NULL;
  END get_credit_classfication;

  ------------------------------------------------------------------------------
  -- PROCEDURE accept_counter_offer
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : accept_counter_offer
  -- Description     : This procedure accepts counter offers for Lease Application.
  -- Business Rules  : This procedure accepts counter offers for Lease Application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --                 : 04-Jan-2006 PAGARG Bug 4897098 Make accepted offer as
  --                   in-play quote
  -- End of comments
  PROCEDURE accept_counter_offer(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lap_id             IN  NUMBER,
            p_cntr_offr          IN  NUMBER,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'ACCEPT_COUNTER_OFFER';
    l_return_status            VARCHAR2(1);

    l_lapv_rec         lapv_rec_type;
    l_lsqv_rec         lsqv_rec_type;

    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.reco_alt_offers_acpt';
    -- Bug#4741121 - viselvar  - Modified - End

    --Cursor to obtain the in play quote id
    CURSOR in_play_qte_dtls_csr(cp_lap_id NUMBER)
    IS
      SELECT LSQ.ID LSQ_ID
           , LAP.APPLICATION_STATUS LAP_STATUS
           , LAP.REFERENCE_NUMBER LAP_NUMBER
      FROM OKL_LEASE_QUOTES_B LSQ
         , OKL_LEASE_APPLICATIONS_B LAP
      WHERE LSQ.PARENT_OBJECT_ID = LAP.ID
        AND LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LSQ.PRIMARY_QUOTE = 'Y'
        AND LAP.ID = cp_lap_id;
    in_play_qte_dtls_rec in_play_qte_dtls_csr%ROWTYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.ACCEPT_COUNTER_OFFER';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(p_lap_id IS NULL OR
       p_lap_id = OKL_API.G_MISS_NUM)
    THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_LSE_APP_INVALID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN in_play_qte_dtls_csr(p_lap_id);
    FETCH in_play_qte_dtls_csr INTO in_play_qte_dtls_rec;
      IF in_play_qte_dtls_csr%NOTFOUND
      THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_SO_LSE_APP_INVALID');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    CLOSE in_play_qte_dtls_csr;
    IF in_play_qte_dtls_rec.lap_status IN ('CR-REJECTED', 'CR-APPROVED', 'RECOM_NOT_APPROVED')
	THEN --[1]
	  --Update the in play quote
	  l_lsqv_rec.id := in_play_qte_dtls_rec.lsq_id;
	  l_lsqv_rec.primary_quote := 'N';

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
      END IF;

      -- call the procedure to create lease quote line
      OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE(
          p_api_version                        => p_api_version
         ,p_init_msg_list                      => OKL_API.G_FALSE
         ,p_transaction_control                => OKL_API.G_TRUE
         ,p_lease_qte_rec                      => l_lsqv_rec
         ,x_lease_qte_rec                      => x_lsqv_rec
         ,x_return_status                      => l_return_status
         ,x_msg_count                          => x_msg_count
         ,x_msg_data                           => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE'
           ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
            ' l_lsqv_rec.id '|| l_lsqv_rec.id ||
            ' result status ' || l_return_status ||
            ' x_msg_data ' || x_msg_data);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Update counter offer
	  l_lsqv_rec.id := p_cntr_offr;
	  l_lsqv_rec.primary_quote := 'Y';

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
      END IF;

      -- call the procedure to create lease quote line
      OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE(
          p_api_version                        => p_api_version
         ,p_init_msg_list                      => OKL_API.G_FALSE
         ,p_transaction_control                => OKL_API.G_TRUE
         ,p_lease_qte_rec                      => l_lsqv_rec
         ,x_lease_qte_rec                      => x_lsqv_rec
         ,x_return_status                      => l_return_status
         ,x_msg_count                          => x_msg_count
         ,x_msg_data                           => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE'
           ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
            ' l_lsqv_rec.id '|| l_lsqv_rec.id ||
            ' result status ' || l_return_status ||
            ' x_msg_data ' || x_msg_data);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Bug#4741121 - viselvar  - Modified - Start
      -- raise the business event passing the Lease Application id added to the parameter list

      wf_event.addparametertolist('LAPP_ID'
                               ,p_lap_id
                               ,l_parameter_list);

      okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);


      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Bug#4741121 - viselvar  - Modified - End
      x_lapv_rec := l_lapv_rec;
    ELSE
      -- Accept counter offer is applicable only for CR-ACCEPTED or CR-REJECTED
	  -- RECOM_NOT_APPROVED Lease Applications only
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_ALT_OFFER_ACC_ERR',
          p_token1        => 'TEXT',
          p_token1_value  => in_play_qte_dtls_rec.lap_number,
          p_token2        => 'STATUS',
          p_token2_value  => in_play_qte_dtls_rec.lap_status);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; -- [1]

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
	THEN
      IF in_play_qte_dtls_csr%ISOPEN
      THEN
        CLOSE in_play_qte_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
	THEN
      IF in_play_qte_dtls_csr%ISOPEN
      THEN
        CLOSE in_play_qte_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS
	THEN
      IF in_play_qte_dtls_csr%ISOPEN
      THEN
        CLOSE in_play_qte_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END accept_counter_offer;

  -------------------------------------------------------------------------------
  -- PROCEDURE revert_leaseapp
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : revert_leaseapp
  -- Description     : This procedure reverts the status from CONV-K to CR-APPROVED
  --                 : This procedure is called when Contract created from
  --                 : Lease Application is cancelled
  -- Business Rules  : This procedure reverts the status from CONV-K to CR-APPROVED
  --                 : This procedure is called when Contract created from
  --                 : Lease Application is cancelled
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 14-SEP-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE revert_leaseapp (
            p_api_version        IN  NUMBER
           ,p_init_msg_list      IN  VARCHAR2
           ,p_leaseapp_id        IN  NUMBER
           ,x_return_status      OUT NOCOPY VARCHAR2
           ,x_msg_count          OUT NOCOPY NUMBER
           ,x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'REVERT_LEASEAPP';
    l_return_status          VARCHAR2(1);
    l_meaning                VARCHAR2(80);

    --Cursor to populate Lease Application details from database
    CURSOR lap_db_val_csr(cp_lap_id NUMBER) IS
      SELECT LAB.REFERENCE_NUMBER LEASE_APPL_NUMBER
           , LAB.APPLICATION_STATUS APPLICATION_STATUS
           , LAB.OBJECT_VERSION_NUMBER OBJECT_VERSION_NUMBER
      FROM OKL_LEASE_APPLICATIONS_B LAB
      WHERE LAB.ID = cp_lap_id;
    lap_db_val_rec lap_db_val_csr%ROWTYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.REVERT_LEASEAPP';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate lease application rec with database values
    IF(p_leaseapp_id IS NOT NULL OR
       p_leaseapp_id <> OKL_API.G_MISS_NUM)
    THEN
      OPEN lap_db_val_csr(p_leaseapp_id);
      FETCH lap_db_val_csr INTO lap_db_val_rec;
        IF(lap_db_val_csr%NOTFOUND)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_SO_LSE_APP_INVALID');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF(lap_db_val_rec.application_status <> 'CONV-K')
        THEN
          --Lease Application not in status CONV-K, can not be reverted
          l_return_status := OKL_API.G_RET_STS_ERROR;
          l_meaning := get_lookup_meaning('OKL_LEASE_APP_STATUS' ,'CONV-K');
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_SO_LSE_APP_INVALID_STS',
              p_token1        => 'TEXT',
              p_token1_value  => lap_db_val_rec.lease_appl_number,
              p_token2        => 'STATUS',
              p_token2_value  => l_meaning);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      CLOSE lap_db_val_csr;
    ELSE
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_LSE_APP_INVALID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; --Lease Application Id is null or G_MISS_NUM

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call SET_LEASE_APP_STATUS');
    END IF;

    -- call the procedure to update a lease application status
    SET_LEASE_APP_STATUS(
        p_api_version              => p_api_version
       ,p_init_msg_list            => OKL_API.G_FALSE
       ,p_lap_id                   => p_leaseapp_id
       ,p_lap_status               => 'CR-APPROVED'
       ,x_return_status            => l_return_status
       ,x_msg_count                => x_msg_count
       ,x_msg_data                 => x_msg_data);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call SET_LEASE_APP_STATUS');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of SET_LEASE_APP_STATUS'
         ,'return status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease Application Details Cusrsor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease Application Details Cusrsor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Lease Application Details Cusrsor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END revert_leaseapp;

  -------------------------------------------------------------------------------
  -- PROCEDURE validate_credit_results
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_credit_results
  -- Description     : This procedure validates credit results
  -- Business Rules  : This procedure validates credit results
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 22-SEP-2005 PAGARG created
  --                 : 02-Dec-2005 PAGARG Bug 4753078 validate whether either
  --                   approve or reject recommendation is created or not
  --                 : 06 Jan 2006 PAGARG Bug 4931564 Added check for Multiple
  --                   recommendations of Checklist and Expiration Days
  --                 : 02 Feb 2006 PAGARG BUG 4931146 Validate number of Counter
  --                   Offers created as credit recommendations against those
  --                   linked to Lease App, break the link for those for which
  --                   credit recommendations are not commited.
  -- End of comments
  PROCEDURE validate_credit_results (
            p_api_version        IN  NUMBER
           ,p_init_msg_list      IN  VARCHAR2
           ,p_leaseapp_id        IN NUMBER
           ,x_return_status      OUT NOCOPY VARCHAR2
           ,x_msg_count          OUT NOCOPY NUMBER
           ,x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'VALIDATE_CREDIT_RESULTS';
    l_return_status          VARCHAR2(1);

    --Local variables
    l_leaseapp_id           NUMBER;
    l_approve_count         NUMBER;
    l_reject_count          NUMBER;
    l_recom_count           NUMBER;
    l_recom_mean            VARCHAR2(80);

    l_lsqv_rec         lsqv_rec_type;
    x_lsqv_rec         lsqv_rec_type;

    --Bug 4753078 Cursor to check for Approve or Reject recommendation for a
    --given Lease Application
    CURSOR credit_recom_csr(cp_lap_id NUMBER, p_recom VARCHAR2) IS
      SELECT COUNT(*)
      FROM AR_CMGT_CF_RECOMMENDS RCM
         , AR_CMGT_CREDIT_REQUESTS CCR
      WHERE RCM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND RCM.CREDIT_RECOMMENDATION = p_recom
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCR.SOURCE_COLUMN1 = cp_lap_id;

    --BUG 4931146 PAGARG Cursor to query Counter offers for the given Lease App
    CURSOR okl_counter_offer_csr(cp_lap_id NUMBER)
    IS
      SELECT ID
           , REFERENCE_NUMBER
           , STATUS
      FROM OKL_LEASE_QUOTES_B LSQ
      WHERE PARENT_OBJECT_CODE = 'LEASEAPP'
        AND STATUS IN ('CR-RECOMMENDATION', 'CR-INCOMPLETE')
        AND PARENT_OBJECT_ID = cp_lap_id;

    --BUG 4931146 PAGARG Cursor to query Counter offer recommendations for given
    --Lease App
    CURSOR ocm_counter_offer_csr(cp_lap_id NUMBER, cp_co_id NUMBER)
    IS
      SELECT 'X'
      FROM AR_CMGT_CF_RECOMMENDS CCRM
         , AR_CMGT_CREDIT_REQUESTS CCR
      WHERE CCRM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCRM.CREDIT_RECOMMENDATION = 'COUNTER_OFFER'
        AND CCR.SOURCE_COLUMN1 = cp_lap_id
		AND CCRM.RECOMMENDATION_VALUE1 = cp_co_id;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.VALIDATE_CREDIT_RESULTS';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Logic for the procedures goes here
    l_leaseapp_id := p_leaseapp_id;

    --Bug 4753078 Open the cursor and check for number of approve or reject
    --recommendation and accordingly throw error.
    OPEN credit_recom_csr(l_leaseapp_id, 'APPROVE');
    FETCH credit_recom_csr INTO l_approve_count;
    CLOSE credit_recom_csr;
    OPEN credit_recom_csr(l_leaseapp_id, 'REJECT');
    FETCH credit_recom_csr INTO l_reject_count;
    CLOSE credit_recom_csr;
    l_recom_count := l_approve_count + l_reject_count;
    IF(l_recom_count > 1) --changed from <> to > for bug 6945703
    THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_LSE_APP_CRE_REC_ERR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN credit_recom_csr(l_leaseapp_id, 'CHECKLIST');
    FETCH credit_recom_csr INTO l_recom_count;
    CLOSE credit_recom_csr;
    IF(l_recom_count > 1)
    THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      l_recom_mean := get_lookup_meaning('OKL_CR_MGMT_RECOMMENDATION', 'CHECKLIST');
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_LSE_APP_MUL_RECOM',
          p_token1        => 'TEXT',
          p_token1_value  => l_recom_mean);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN credit_recom_csr(l_leaseapp_id, 'EXPIRATION_DATE');
    FETCH credit_recom_csr INTO l_recom_count;
    CLOSE credit_recom_csr;
    IF(l_recom_count > 1)
    THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      l_recom_mean := get_lookup_meaning('OKL_CR_MGMT_RECOMMENDATION', 'EXPIRATION_DATE');
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_LSE_APP_MUL_RECOM',
          p_token1        => 'TEXT',
          p_token1_value  => l_recom_mean);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF(l_recom_count = 0)
    THEN
      --If there is no recommendation for Expiration Days then set the expiration
      --days value as NULL
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call SET_LEASE_APP_EXPDAYS');
      END IF;

      SET_LEASE_APP_EXPDAYS(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,p_lap_id                => l_leaseapp_id
         ,p_lap_expdays           => NULL
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call SET_LEASE_APP_EXPDAYS');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of SET_LEASE_APP_EXPDAYS'
           ,'return status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;--For Expiration Date recommendation check

    --BUG 4931146 PAGARG Loop through the Counter Offers linked to given Lease App
    --if there is no recommendation for the given Counter Offer then remove the link
    --by setting the parent_object_code as -1
    FOR okl_counter_offer_rec IN okl_counter_offer_csr(l_leaseapp_id)
    LOOP
      OPEN ocm_counter_offer_csr(l_leaseapp_id, okl_counter_offer_rec.id);
      FETCH ocm_counter_offer_csr INTO l_recom_mean;
        IF ocm_counter_offer_csr%NOTFOUND
        THEN
          SELECT OBJECT_VERSION_NUMBER INTO l_lsqv_rec.object_version_number
          FROM OKL_LEASE_QUOTES_B
          WHERE ID = okl_counter_offer_rec.id;

          l_lsqv_rec.id := okl_counter_offer_rec.id;
          l_lsqv_rec.parent_object_id := -1;

          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_PROCEDURE
               ,L_MODULE
               ,'begin debug call OKL_LSQ_PVT.UPDATE_ROW');
          END IF;

          -- call the procedure to update lease quote
          OKL_LSQ_PVT.UPDATE_ROW(
              p_api_version        => p_api_version
             ,p_init_msg_list      => OKL_API.G_FALSE
             ,p_lsqv_rec           => l_lsqv_rec
             ,x_lsqv_rec           => x_lsqv_rec
             ,x_return_status      => l_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data);

          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_PROCEDURE
               ,L_MODULE
               ,'end debug call OKL_LSQ_PVT.UPDATE_ROW');
          END IF;

          -- write to log
          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_STATEMENT
               ,L_MODULE || ' Result of OKL_LSQ_PVT.UPDATE_ROW'
               ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
                ' result status ' || l_return_status);
          END IF; -- end of statement level debug

          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        ELSE
          --If Counter offer is found as recommendation in OCM then validate
          --whether pricing is completed for Counter Offer or not
          IF(okl_counter_offer_rec.status = 'CR-INCOMPLETE')
          THEN
            l_return_status := OKL_API.G_RET_STS_ERROR;
            OKL_API.SET_MESSAGE(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_SO_LSE_APP_COUN_OFFER_ERR',
                p_token1       => 'TEXT',
                p_token1_value => okl_counter_offer_rec.reference_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;--For counter offer not found as credit recommendations in OCM
      CLOSE ocm_counter_offer_csr;
    END LOOP;
    --BUG 4931146 PAGARG Fix End

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Credit Recommendations Cursor
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Credit Recommendations Cursor
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Credit Recommendations Cursor
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END validate_credit_results;

  -------------------------------------------------------------------------------
  -- PROCEDURE lease_app_resubmit
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_resubmit
  -- Description     : This procedure resubmits the lease application.
  -- Business Rules  : This procedure resubmits the lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 26-SEP-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_resubmit(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_source_lap_id      IN  NUMBER,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type) IS

    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_RESUBMIT';
    l_return_status          VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec      lsqv_rec_type;
    l_crr_rec       crr_rec_type;
    x_crr_rec       crr_rec_type;
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.resubmitted';

    --Cursor to obtain Checklist Header Id
    CURSOR chk_hdr_dtls_csr(cp_lap_id NUMBER)
    IS
    --changing the query for bug 5167776
    SELECT LATV.CHECKLIST_ID
    FROM OKL_LEASE_APPLICATIONS_B LAP
        ,OKL_LEASEAPP_TEMPL_VERSIONS_V LATV
    WHERE LAP.LEASEAPP_TEMPLATE_ID = LATV.ID
      AND LAP.ID = cp_lap_id;
    chk_hdr_dtls_rec chk_hdr_dtls_csr%ROWTYPE;

    --Cursor to obtain Source Lease App details
    CURSOR src_lse_app_dtls_csr(cp_lap_id NUMBER)
    IS
      SELECT LSQ.ID LSQ_ID
           , CRR.CREDIT_REQUEST_ID
      FROM OKL_LEASE_QUOTES_B LSQ
         , OKL_LEASE_APPLICATIONS_B LAP
         , AR_CMGT_CREDIT_REQUESTS CRR
      WHERE LSQ.PARENT_OBJECT_ID = LAP.ID
        AND LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LSQ.PRIMARY_QUOTE = 'Y'
        AND CRR.SOURCE_COLUMN1 = LAP.ID
        AND CRR.SOURCE_COLUMN3 = 'LEASEAPP'
		AND LAP.ID = cp_lap_id;
    src_lse_app_dtls_rec src_lse_app_dtls_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_RESUBMIT';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := p_lapv_rec;
    l_lsqv_rec := p_lsqv_rec;
    --set the status and parent for lease application
    l_lapv_rec.application_status := G_INIT_APPL_STATUS;
    l_lapv_rec.parent_leaseapp_id := p_source_lap_id;
    l_lapv_rec.action := 'RESUBMIT';

    --Validate Lease Application Template
    --Validate Program Agreement
    --Validate VP and LAT association
    --Validate Lease Quote
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call LEASE_APP_VAL');
    END IF;

    LEASE_APP_VAL(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lapv_rec              => l_lapv_rec
       ,p_lsqv_rec              => l_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call LEASE_APP_VAL');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of LEASE_APP_VAL'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_LAP_PVT.INSERT_ROW');
    END IF;

    -- call the TAPI insert_row to create a lease application
    OKL_LAP_PVT.INSERT_ROW(
        p_api_version                        => p_api_version
       ,p_init_msg_list                      => OKL_API.G_FALSE
       ,x_return_status                      => l_return_status
       ,x_msg_count                          => x_msg_count
       ,x_msg_data                           => x_msg_data
       ,p_lapv_rec                           => l_lapv_rec
       ,x_lapv_rec                           => x_lapv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_LAP_PVT.INSERT_ROW');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_LAP_PVT.INSERT_ROW'
         ,'l_lapv_rec.reference_number ' || to_char(l_lapv_rec.reference_number) ||
          ' l_lapv_rec.id '|| l_lapv_rec.id ||
          ' result status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate lease quote rec values
    l_lsqv_rec.parent_object_code := 'LEASEAPP';
    l_lsqv_rec.parent_object_id := x_lapv_rec.id;
    l_lsqv_rec.reference_number := get_next_seq_num(
                                       'OKL_LSQ_REF_SEQ'
                                      ,'OKL_LEASE_QUOTES_B'
                                      ,'REFERENCE_NUMBER');
    l_lsqv_rec.status := 'PR-INCOMPLETE';
    l_lsqv_rec.primary_quote := 'Y';

    --Obtain the lease quote id attached to lease application and pass it as
    --source to duplicate lease quote.
    --This way it will duplicate lease quote with header values from rec and
    --rest of configuration, adjustment, pricing data from the source lease quote id
    OPEN src_lse_app_dtls_csr(p_source_lap_id);
    FETCH src_lse_app_dtls_csr INTO src_lse_app_dtls_rec;
    CLOSE src_lse_app_dtls_csr;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE');
    END IF;

    -- call the procedure to create lease quote line
    OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE(
        p_api_version                        => p_api_version
       ,p_init_msg_list                      => OKL_API.G_FALSE
       ,p_transaction_control                => OKL_API.G_TRUE
       ,p_source_quote_id                    => src_lse_app_dtls_rec.lsq_id
       ,p_lease_qte_rec                      => l_lsqv_rec
       ,x_lease_qte_rec                      => x_lsqv_rec
       ,x_return_status                      => l_return_status
       ,x_msg_count                          => x_msg_count
       ,x_msg_data                           => x_msg_data);

	IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE'
         ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
          ' l_lsqv_rec.id '|| l_lsqv_rec.id ||
          ' result status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call CREATE_CREDIT_APP');
    END IF;

    l_crr_rec.credit_request_type := 'RESUBMISSION';
    l_crr_rec.parent_credit_request_id := src_lse_app_dtls_rec.credit_request_id;
    --call to duplicate Credit Lease Application
    CREATE_CREDIT_APP(
        p_api_version        => p_api_version
       ,p_init_msg_list      => OKL_API.G_FALSE
       ,x_return_status      => l_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       ,p_lapv_rec           => x_lapv_rec
       ,p_crr_rec            => l_crr_rec
       ,x_crr_rec            => x_crr_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call CREATE_CREDIT_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of CREATE_CREDIT_APP'
         ,' result status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --asawanka. for bug 5169964
    OPEN chk_hdr_dtls_csr(x_lapv_rec.id);
    FETCH chk_hdr_dtls_csr INTO chk_hdr_dtls_rec;
    CLOSE chk_hdr_dtls_csr;

    IF(chk_hdr_dtls_rec.checklist_id IS NOT NULL)
    THEN
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call CHECKLIST_INST_CRE');
      END IF;

      --call to create Checklist Instance
      CHECKLIST_INST_CRE(
          p_api_version        => p_api_version
         ,p_init_msg_list      => OKL_API.G_FALSE
         ,x_return_status      => l_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_lap_id             => x_lapv_rec.id
		 ,p_chklst_tmpl_id     => chk_hdr_dtls_rec.checklist_id);

	  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call CHECKLIST_INST_CRE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of CHECKLIST_INST_CRE'
           ,' result status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- Condition to check for call to create checklist instance

    --Update the status of Parent Lease Application as in Progress
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call SET_IN_PROGRESS_STATUS');
    END IF;

    --call the procedure to update a lease application status
    SET_IN_PROGRESS_STATUS(
        p_api_version              => p_api_version
       ,p_init_msg_list            => OKL_API.G_FALSE
       ,p_lap_id                   => p_source_lap_id
       ,p_action                   => 'RESUBMIT'
       ,x_return_status            => l_return_status
       ,x_msg_count                => x_msg_count
       ,x_msg_data                 => x_msg_data);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call SET_IN_PROGRESS_STATUS');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of SET_IN_PROGRESS_STATUS'
         ,'return status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- raise the business event passing the Lease Application id added to the parameter list
    wf_event.addparametertolist('LAPP_ID'
                               ,x_lapv_rec.id
                               ,l_parameter_list);

    okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Lease Application Source Details Cursor
      IF src_lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE src_lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Lease Application Source Details Cursor
      IF src_lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE src_lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Lease Application Source Details Cursor
      IF src_lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE src_lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_resubmit;

  -------------------------------------------------------------------------------
  -- PROCEDURE lease_app_cancel
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_cancel
  -- Description     : This procedure cancels the lease application.
  -- Business Rules  : This procedure cancels the lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 26-SEP-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_cancel(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lease_app_id       IN  NUMBER,
            x_lapv_rec		     OUT NOCOPY lapv_rec_type)
  IS
    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_CANCEL';
    l_return_status          VARCHAR2(1);
    l_meaning                VARCHAR2(80);

    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.cancelled';
    -- Bug#4741121 - viselvar  - Modified - End

    --Cursor to populate Lease Application details from database
    CURSOR lap_db_val_csr(cp_lap_id NUMBER) IS
      SELECT LAB.REFERENCE_NUMBER LEASE_APPL_NUMBER
           , LAB.APPLICATION_STATUS APPLICATION_STATUS
      FROM OKL_LEASE_APPLICATIONS_B LAB
      WHERE LAB.ID = cp_lap_id;
    lap_db_val_rec lap_db_val_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_CANCEL';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(p_lease_app_id IS NOT NULL OR
       p_lease_app_id <> OKL_API.G_MISS_NUM)
    THEN
      OPEN lap_db_val_csr(p_lease_app_id);
      FETCH lap_db_val_csr INTO lap_db_val_rec;
        IF(lap_db_val_csr%NOTFOUND)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_SO_LSE_APP_INVALID');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      CLOSE lap_db_val_csr;
    ELSE
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_LSE_APP_INVALID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; --Lease Application Id is null or G_MISS_NUM

/*  Due to data integrity concerns, users would not be able to cancel applications
    that are in any of the following statuses:
	Submitted to Credit,Credit Rejected,Credit Approved,Converted to Contract
	Submitted for Pricing Approval, Receommendation Not Approved
*/
    IF(lap_db_val_rec.application_status IN
	   ('CR-SUBMITTED', 'CR-REJECTED', 'CR-APPROVED','CONV-K', 'PR-SUBMITTED', 'RECOM_NOT_APPROVED') )
    THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      l_meaning := get_lookup_meaning('OKL_LEASE_APP_STATUS', 'CANCELED');
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_SO_LSE_APP_ACTION_ERR',
          p_token1        => 'TEXT',
          p_token1_value  => lap_db_val_rec.lease_appl_number,
          p_token2        => 'STATUS',
          p_token2_value  => lap_db_val_rec.application_status,
          p_token3        => 'ACTION',
          p_token3_value  => l_meaning);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSE
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call CHECK_ELIGIBILITY');
      END IF;

      --call the procedure to Validate Cancel action on lease app
      CHECK_ELIGIBILITY(
          p_api_version     => p_api_version
         ,p_init_msg_list   => OKL_API.G_FALSE
         ,x_return_status   => l_return_status
         ,x_msg_count       => x_msg_count
         ,x_msg_data        => x_msg_data
         ,p_lap_id          => p_lease_app_id
         ,p_action          => 'CANCEL');

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call CHECK_ELIGIBILITY');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of CHECK_ELIGIBILITY'
           ,'return status ' || l_return_status ||
            ' x_msg_data ' || x_msg_data);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call SET_LEASE_APP_STATUS');
      END IF;

      --call the procedure to update a lease application status
      SET_LEASE_APP_STATUS(
          p_api_version     => p_api_version
         ,p_init_msg_list   => OKL_API.G_FALSE
         ,p_lap_id          => p_lease_app_id
         ,p_lap_status      => 'CANCELED'
         ,x_return_status   => l_return_status
         ,x_msg_count       => x_msg_count
         ,x_msg_data        => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call SET_LEASE_APP_STATUS');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of SET_LEASE_APP_STATUS'
           ,'return status ' || l_return_status ||
            ' x_msg_data ' || x_msg_data);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

	  -- Added by rravikir for Bug 5001802
      -- Call the API to process the lease app subsidy pool
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_LEASE_QUOTE_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL');
      END IF;

      OKL_LEASE_QUOTE_SUBPOOL_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL(
            p_api_version           => p_api_version
           ,p_init_msg_list         => OKL_API.G_FALSE
           ,p_transaction_control   => OKL_API.G_TRUE
           ,p_leaseapp_id           => p_lease_app_id
           ,p_transaction_reason    => 'CANCEL_LEASE_APP'
           ,p_quote_id              => null
           ,x_return_status         => l_return_status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_LEASE_QUOTE_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.PROCESS_LEASEAPP_SUBSIDY_POOL'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- End changes for Bug 5001802

      --Call the API which will check if there is any Parent to this Lease App
      --and in status Appeal/Resubmit in Progress. If yes then restore the status
      --of parent to original status
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call REVERT_TO_ORIG_STATUS');
      END IF;

      REVERT_TO_ORIG_STATUS(
          p_api_version           => l_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,p_lap_id                => p_lease_app_id
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call REVERT_TO_ORIG_STATUS');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of REVERT_TO_ORIG_STATUS'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Bug#4741121 - viselvar  - Modified - Start
      -- raise the business event passing the Lease Application id added to the parameter list
      wf_event.addparametertolist('LAPP_ID'
                                 ,p_lease_app_id
                                 ,l_parameter_list);

      okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Bug#4741121 - viselvar  - Modified - End
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease App Details Cursor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease App Details Cursor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Lease App Details Cursor
      IF lap_db_val_csr%ISOPEN
      THEN
        CLOSE lap_db_val_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_cancel;

  -------------------------------------------------------------------------------
  -- PROCEDURE lease_app_appeal
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_appeal
  -- Description     : This procedure appeals the lease application.
  -- Business Rules  : This procedure appeals the lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 26-SEP-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_appeal(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_source_lap_id      IN  NUMBER,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type)
  IS
    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_APPEAL';
    l_return_status          VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec      lsqv_rec_type;
    l_crr_rec       crr_rec_type;
    x_crr_rec       crr_rec_type;
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.appeal';

    --Cursor to obtain Checklist Header Id
    CURSOR chk_hdr_dtls_csr(cp_lap_id NUMBER)
    IS
      SELECT CHK.ID CHECKLIST_ID
      FROM OKL_LEASE_APPLICATIONS_B LAP
         , OKL_CHECKLISTS CHK
      WHERE CHK.CHECKLIST_OBJ_TYPE_CODE = 'LEASE_APPL'
        AND CHK.CHECKLIST_OBJ_ID = LAP.ID
        AND LAP.ID = cp_lap_id;
    chk_hdr_dtls_rec chk_hdr_dtls_csr%ROWTYPE;

    --Cursor to obtain Source Lease App details
    CURSOR src_lse_app_dtls_csr(cp_lap_id NUMBER)
    IS
      SELECT LSQ.ID LSQ_ID
           , CRR.CREDIT_REQUEST_ID
           , LAP.APPLICATION_STATUS
           , LAP.APPLICATION_STATUS APPEAL_SCOPE
      FROM OKL_LEASE_QUOTES_B LSQ
         , OKL_LEASE_APPLICATIONS_B LAP
         , AR_CMGT_CREDIT_REQUESTS CRR
      WHERE LSQ.PARENT_OBJECT_ID = LAP.ID
        AND LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LSQ.PRIMARY_QUOTE = 'Y'
        AND CRR.SOURCE_COLUMN1 = LAP.ID
        AND CRR.SOURCE_COLUMN3 = 'LEASEAPP'
		AND LAP.ID = cp_lap_id;
    src_lse_app_dtls_rec src_lse_app_dtls_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_APPEAL';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := p_lapv_rec;
    l_lsqv_rec := p_lsqv_rec;
    l_lapv_rec.application_status := 'PR-ACCEPTED';
    l_lapv_rec.parent_leaseapp_id := p_source_lap_id;
    l_lapv_rec.action := 'APPEAL';

    --Validate Lease Application Template
    --Validate Program Agreement
    --Validate VP and LAT association
    --Validate Lease Quote
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call LEASE_APP_VAL');
    END IF;

    LEASE_APP_VAL(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lapv_rec              => l_lapv_rec
       ,p_lsqv_rec              => l_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call LEASE_APP_VAL');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of LEASE_APP_VAL'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_LAP_PVT.INSERT_ROW');
    END IF;

    -- call the TAPI insert_row to create a lease application
    OKL_LAP_PVT.INSERT_ROW(
        p_api_version                        => p_api_version
       ,p_init_msg_list                      => OKL_API.G_FALSE
       ,x_return_status                      => l_return_status
       ,x_msg_count                          => x_msg_count
       ,x_msg_data                           => x_msg_data
       ,p_lapv_rec                           => l_lapv_rec
       ,x_lapv_rec                           => x_lapv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_LAP_PVT.INSERT_ROW');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_LAP_PVT.INSERT_ROW'
         ,'l_lapv_rec.reference_number ' || to_char(l_lapv_rec.reference_number) ||
          ' l_lapv_rec.id '|| l_lapv_rec.id ||
          ' result status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate lease quote rec values
    l_lsqv_rec.parent_object_code := 'LEASEAPP';
    l_lsqv_rec.parent_object_id := x_lapv_rec.id;
    l_lsqv_rec.reference_number := get_next_seq_num(
                                       'OKL_LSQ_REF_SEQ'
                                      ,'OKL_LEASE_QUOTES_B'
                                      ,'REFERENCE_NUMBER');
    l_lsqv_rec.status := 'CT-ACCEPTED';
    l_lsqv_rec.primary_quote := 'Y';

    --Obtain the details of Source Lease Application
    --Obtain the lease quote id attached to lease application and pass it as
    --source to duplicate lease quote.
    --This way it will duplicate lease quote with header values from rec and
    --rest of configuration, adjustment, pricing data from the source lease quote id
    OPEN src_lse_app_dtls_csr(p_source_lap_id);
    FETCH src_lse_app_dtls_csr INTO src_lse_app_dtls_rec;
    CLOSE src_lse_app_dtls_csr;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE');
    END IF;

    -- call the procedure to create lease quote line
    OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE(
        p_api_version                        => p_api_version
       ,p_init_msg_list                      => OKL_API.G_FALSE
       ,p_transaction_control                => OKL_API.G_TRUE
       ,p_source_quote_id                    => src_lse_app_dtls_rec.lsq_id
       ,p_lease_qte_rec                      => l_lsqv_rec
       ,x_lease_qte_rec                      => x_lsqv_rec
       ,x_return_status                      => l_return_status
       ,x_msg_count                          => x_msg_count
       ,x_msg_data                           => x_msg_data);

	IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.DUPLICATE_LEASE_QTE'
         ,'l_lsqv_rec.reference_number ' || to_char(l_lsqv_rec.reference_number) ||
          ' l_lsqv_rec.id '|| l_lsqv_rec.id ||
          ' result status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call CREATE_CREDIT_APP');
    END IF;

    IF(src_lse_app_dtls_rec.application_status = 'CR-APPROVED')
    THEN
      l_crr_rec.credit_request_type := 'APPEAL';
    ELSIF(src_lse_app_dtls_rec.application_status IN ('CR-REJECTED', 'RECOM_NOT_APPROVED'))
    THEN
      l_crr_rec.credit_request_type := 'APPEAL_REJECTION';
    END IF;
    l_crr_rec.parent_credit_request_id := src_lse_app_dtls_rec.credit_request_id;
    --call to duplicate Credit Lease Application
    CREATE_CREDIT_APP(
        p_api_version        => p_api_version
       ,p_init_msg_list      => OKL_API.G_FALSE
       ,x_return_status      => l_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       ,p_lapv_rec           => x_lapv_rec
       ,p_crr_rec            => l_crr_rec
       ,x_crr_rec            => x_crr_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call CREATE_CREDIT_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of CREATE_CREDIT_APP'
         ,' result status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN chk_hdr_dtls_csr(p_source_lap_id);
    FETCH chk_hdr_dtls_csr INTO chk_hdr_dtls_rec;
    CLOSE chk_hdr_dtls_csr;

    IF(chk_hdr_dtls_rec.checklist_id IS NOT NULL)
    THEN
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call CHECKLIST_INST_CRE');
      END IF;

      --call to create Checklist Instance
      CHECKLIST_INST_CRE(
          p_api_version        => p_api_version
         ,p_init_msg_list      => OKL_API.G_FALSE
         ,x_return_status      => l_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_lap_id             => x_lapv_rec.id
		 ,p_chklst_tmpl_id     => chk_hdr_dtls_rec.checklist_id);

	  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call CHECKLIST_INST_CRE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of CHECKLIST_INST_CRE'
           ,' result status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- Condition to check for call to create checklist instance

    --Update the status of Parent Lease Application as in Progress
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call SET_IN_PROGRESS_STATUS');
    END IF;

    --call the procedure to update a lease application status
    SET_IN_PROGRESS_STATUS(
        p_api_version              => p_api_version
       ,p_init_msg_list            => OKL_API.G_FALSE
       ,p_lap_id                   => p_source_lap_id
       ,p_action                   => 'APPEAL'
       ,x_return_status            => l_return_status
       ,x_msg_count                => x_msg_count
       ,x_msg_data                 => x_msg_data);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call SET_IN_PROGRESS_STATUS');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of SET_IN_PROGRESS_STATUS'
         ,'return status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- raise the business event passing the Lease Application id added to the parameter list
    wf_event.addparametertolist('LAPP_ID'
                               ,x_lapv_rec.id
                               ,l_parameter_list);
    okl_wf_pvt.raise_event(p_api_version       => p_api_version
                          ,p_init_msg_list     => p_init_msg_list
                          ,x_return_status     => l_return_status
                          ,x_msg_count         => x_msg_count
                          ,x_msg_data          => x_msg_data
                          ,p_event_name        => p_event_name
                          ,p_parameters        => l_parameter_list);

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Source Lease Application Details Cursor
      IF src_lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE src_lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Source Lease Application Details Cursor
      IF src_lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE src_lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Checklist Header Details Cursor
      IF chk_hdr_dtls_csr%ISOPEN
      THEN
        CLOSE chk_hdr_dtls_csr;
      END IF;
      --Source Lease Application Details Cursor
      IF src_lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE src_lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_appeal;

  -------------------------------------------------------------------------------
  -- PROCEDURE check_eligibility
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_eligibility
  -- Description     : This procedure checks whether lease app is eligible for
  --                   given action or not.
  -- Business Rules  : This procedure checks whether lease app is eligible for
  --                   given action or not.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 06-OCT-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE check_eligibility(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lap_id             IN  NUMBER,
			p_action             IN  VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'CHECK_ELIGIBILITY';
    l_return_status          VARCHAR2(1);

    -- Record/Table Type Declarations
    flag             BOOLEAN;
    l_count          NUMBER;
    l_exp_date       DATE;
    l_meaning        VARCHAR2(80);

    CURSOR child_lse_app_csr(cp_lap_id IN NUMBER)
    IS
      SELECT ID
           , REFERENCE_NUMBER
           , APPLICATION_STATUS
      FROM OKL_LEASE_APPLICATIONS_B
      WHERE ID <> cp_lap_id
      CONNECT BY PARENT_LEASEAPP_ID = PRIOR ID
      START WITH ID = cp_lap_id;
    child_lse_app_rec child_lse_app_csr%ROWTYPE;

    CURSOR parent_lse_app_csr(cp_lap_id IN NUMBER)
    IS
      SELECT ID
           , REFERENCE_NUMBER
           , APPLICATION_STATUS
      FROM OKL_LEASE_APPLICATIONS_B
      WHERE ID <> cp_lap_id
      CONNECT BY PRIOR PARENT_LEASEAPP_ID = ID
      START WITH ID = cp_lap_id;
    parent_lse_app_rec parent_lse_app_csr%ROWTYPE;

    --Cursor to check whether a given recommendation is added to given Lease App
    CURSOR credit_recom_csr(p_lap_id NUMBER, p_recomm VARCHAR2) IS
      SELECT COUNT(*)
      FROM AR_CMGT_CF_RECOMMENDS RCM
         , AR_CMGT_CREDIT_REQUESTS CCR
      WHERE RCM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND RCM.CREDIT_RECOMMENDATION = p_recomm
        AND CCR.SOURCE_COLUMN1 = p_lap_id;

    --Cursor to obtain appeal period expiration date for a given Lease App
    CURSOR appeal_exp_date_csr(p_lap_id NUMBER)
    IS
      SELECT RCM.RECOMMENDATION_VALUE1 + TRUNC(LAST_UPDATED) APPEAL_EXP_DATE
      FROM AR_CMGT_CASE_FOLDERS CCF
         , AR_CMGT_CREDIT_REQUESTS CCR
         , AR_CMGT_CF_RECOMMENDS RCM
      WHERE CCR.CREDIT_REQUEST_ID = CCF.CREDIT_REQUEST_ID
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCF.STATUS = 'CLOSED'
        AND RCM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND RCM.CREDIT_RECOMMENDATION = 'AUTHORIZE_APPEAL'
        AND CCR.SOURCE_COLUMN1 = p_lap_id;

    --Cursor to Obtain Contract Number created from given lease app
    CURSOR contract_dtls_csr(p_lap_id NUMBER)
	IS
      SELECT CHR.CONTRACT_NUMBER CONTRACT_NUMBER
      FROM OKC_K_HEADERS_B CHR
         , OKC_STATUSES_V CSTS
      WHERE CHR.ORIG_SYSTEM_SOURCE_CODE = 'OKL_LEASE_APP'
        AND CHR.STS_CODE = CSTS.CODE
        AND CSTS.STE_CODE <> 'CANCELLED'
        AND CHR.ORIG_SYSTEM_ID1 = p_lap_id;
    contract_dtls_rec contract_dtls_csr%ROWTYPE;

    --Cursor to obtain Lease Application Details
    CURSOR lse_app_dtls_csr(p_lap_id NUMBER) IS
      SELECT LAB.REFERENCE_NUMBER
        FROM OKL_LEASE_APPLICATIONS_B LAB
       WHERE LAB.ID = p_lap_id;
    lse_app_dtls_rec lse_app_dtls_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.CHECK_ELIGIBILITY';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN lse_app_dtls_csr(p_lap_id);
    FETCH lse_app_dtls_csr INTO lse_app_dtls_rec;
    CLOSE lse_app_dtls_csr;

    IF(p_action = 'APPEAL')
    THEN
      FOR child_lse_app_rec IN child_lse_app_csr(p_lap_id)
      LOOP
        IF child_lse_app_rec.application_status NOT IN ('CANCELED', 'WITHDRAWN')
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          l_meaning := get_lookup_meaning('OKL_LEASE_APP_ACTION', 'APPEAL');
          OKL_API.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_SO_LSE_APP_APP_RESUB_ERR',
              p_token1       => 'ACTION',
              p_token1_value => l_meaning,
              p_token2       => 'TEXT',
              p_token2_value => lse_app_dtls_rec.reference_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
      OPEN credit_recom_csr(p_lap_id, 'AUTHORIZE_APPEAL');
      FETCH credit_recom_csr INTO l_count;
      CLOSE credit_recom_csr;
      IF(l_count = 1)
      THEN
        OPEN appeal_exp_date_csr(p_lap_id);
        FETCH appeal_exp_date_csr INTO l_exp_date;
        CLOSE appeal_exp_date_csr;
        IF(l_exp_Date < TRUNC(SYSDATE))
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_SO_LSE_APP_APPEAL_PRD_EXP',
              p_token1       => 'TEXT',
              p_token1_value => lse_app_dtls_rec.reference_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_SO_LSE_APP_APPEAL_AUTH_ERR',
            p_token1       => 'TEXT',
            p_token1_value => lse_app_dtls_rec.reference_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    IF(p_action = 'RESUBMIT' )
    THEN
           -- Bug# 7140398 - Start
           -- Donot allow resubmit in case the primary quote is Credit Declined.
       IF (is_primary_quote_declined(p_lap_id)) THEN
         l_return_status := OKL_API.G_RET_STS_ERROR;
         OKL_API.SET_MESSAGE(
             p_app_name      => G_APP_NAME,
             p_msg_name      => 'OKL_SO_DEC_OFFER_RESUBM_ERR');
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
           -- Bug# 7140398 - End
      FOR child_lse_app_rec IN child_lse_app_csr(p_lap_id)
      LOOP
        IF child_lse_app_rec.application_status NOT IN ('CANCELED', 'WITHDRAWN')
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          l_meaning := get_lookup_meaning('OKL_LEASE_APP_ACTION', 'RESUBMIT');
          OKL_API.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_SO_LSE_APP_APP_RESUB_ERR',
              p_token1       => 'ACTION',
              p_token1_value => l_meaning,
              p_token2       => 'TEXT',
              p_token2_value => lse_app_dtls_rec.reference_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
    END IF;

    IF(p_action = 'CANCEL')
    THEN
      FOR child_lse_app_rec IN child_lse_app_csr(p_lap_id)
      LOOP
        IF child_lse_app_rec.application_status <> 'CANCELED'
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_SO_LSE_APP_CANCEL_ERR',
              p_token1       => 'TEXT',
              p_token1_value => lse_app_dtls_rec.reference_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
    END IF;

    IF(p_action = 'WITHDRAW')
    THEN
      FOR child_lse_app_rec IN child_lse_app_csr(p_lap_id)
      LOOP
        IF child_lse_app_rec.application_status IN ('APPEALINPROG', 'RESUBMITINPROG')
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          l_meaning := get_lookup_meaning('OKL_LEASE_APP_ACTION', 'WITHDRAW');
          OKL_API.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_SO_LSE_APP_IN_PROG_ERR',
              p_token1       => 'ACTION',
              p_token1_value => l_meaning,
              p_token2       => 'TEXT',
              p_token2_value => lse_app_dtls_rec.reference_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
    END IF;

    IF(p_action = 'CRECON')
    THEN
           -- Bug# 7140398 - Start
           -- Donot allow convertion to contract in case the primary quote is Credit Declined.
           IF (is_primary_quote_declined(p_lap_id)) THEN
         l_return_status := OKL_API.G_RET_STS_ERROR;
         OKL_API.SET_MESSAGE(
             p_app_name      => G_APP_NAME,
             p_msg_name      => 'OKL_SO_DEC_OFFER_TO_CHR_ERR');
         RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
           -- Bug# 7140398 - End

      FOR child_lse_app_rec IN child_lse_app_csr(p_lap_id)
      LOOP
        IF child_lse_app_rec.application_status IN ('APPEALINPROG', 'RESUBMITINPROG')
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          l_meaning := get_lookup_meaning('OKL_LEASE_APP_ACTION', 'CRECON');
          OKL_API.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_SO_LSE_APP_IN_PROG_ERR',
              p_token1       => 'ACTION',
              p_token1_value => l_meaning,
              p_token2       => 'TEXT',
              p_token2_value => lse_app_dtls_rec.reference_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF child_lse_app_rec.application_status = 'CONV-K'
        THEN
          OPEN contract_dtls_csr(child_lse_app_rec.id);
          FETCH contract_dtls_csr INTO contract_dtls_rec;
          CLOSE contract_dtls_csr;
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_SO_LSE_APP_CRE_CON_ERR',
              p_token1       => 'CONTRACT_NUM',
              p_token1_value => contract_dtls_rec.contract_number,
              p_token2       => 'TEXT',
              p_token2_value => child_lse_app_rec.reference_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
      FOR parent_lse_app_rec IN parent_lse_app_csr(p_lap_id)
      LOOP
        IF parent_lse_app_rec.application_status = 'CONV-K'
        THEN
          OPEN contract_dtls_csr(parent_lse_app_rec.id);
          FETCH contract_dtls_csr INTO contract_dtls_rec;
          CLOSE contract_dtls_csr;
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_SO_LSE_APP_CRE_CON_ERR',
              p_token1       => 'CONTRACT_NUM',
              p_token1_value => contract_dtls_rec.contract_number,
              p_token2       => 'TEXT',
              p_token2_value => parent_lse_app_rec.reference_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Check if Child Lease App cursor is open
      IF child_lse_app_csr%ISOPEN
      THEN
        CLOSE child_lse_app_csr;
      END IF;
      --Check if Parent Lease App cursor is open
      IF parent_lse_app_csr%ISOPEN
      THEN
        CLOSE parent_lse_app_csr;
      END IF;
      --Check if Credit Recommendation cursor is open
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Check if Appeal Exp Date cursor is open
      IF appeal_exp_date_csr%ISOPEN
      THEN
        CLOSE appeal_exp_date_csr;
      END IF;
      --Check if Contract Details cursor is open
      IF contract_dtls_csr%ISOPEN
      THEN
        CLOSE contract_dtls_csr;
      END IF;
      --Check if Lease App details cursor is open
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Check if Child Lease App cursor is open
      IF child_lse_app_csr%ISOPEN
      THEN
        CLOSE child_lse_app_csr;
      END IF;
      --Check if Parent Lease App cursor is open
      IF parent_lse_app_csr%ISOPEN
      THEN
        CLOSE parent_lse_app_csr;
      END IF;
      --Check if Credit Recommendation cursor is open
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Check if Appeal Exp Date cursor is open
      IF appeal_exp_date_csr%ISOPEN
      THEN
        CLOSE appeal_exp_date_csr;
      END IF;
      --Check if Contract Details cursor is open
      IF contract_dtls_csr%ISOPEN
      THEN
        CLOSE contract_dtls_csr;
      END IF;
      --Check if Lease App details cursor is open
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Check if Child Lease App cursor is open
      IF child_lse_app_csr%ISOPEN
      THEN
        CLOSE child_lse_app_csr;
      END IF;
      --Check if Parent Lease App cursor is open
      IF parent_lse_app_csr%ISOPEN
      THEN
        CLOSE parent_lse_app_csr;
      END IF;
      --Check if Credit Recommendation cursor is open
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Check if Appeal Exp Date cursor is open
      IF appeal_exp_date_csr%ISOPEN
      THEN
        CLOSE appeal_exp_date_csr;
      END IF;
      --Check if Contract Details cursor is open
      IF contract_dtls_csr%ISOPEN
      THEN
        CLOSE contract_dtls_csr;
      END IF;
      --Check if Lease App details cursor is open
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END check_eligibility;

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_qa_val
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_qa_val
  -- Description     : This procedure calls qa validation for lease application.
  -- Business Rules  : This procedure calls qa validation for lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 26-Oct-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_qa_val(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
			x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            x_qa_result          OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_QA_VAL';
    l_return_status            VARCHAR2(1);
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_QA_VAL';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --QA Checker integration
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_SALES_QUOTE_QA_PVT.RUN_QA_CHECKER');
    END IF;

    OKL_SALES_QUOTE_QA_PVT.RUN_QA_CHECKER(
        p_api_version            => p_api_version
       ,p_init_msg_list          => OKL_API.G_FALSE
       ,p_object_type            => 'LEASEAPP'
       ,p_object_id              => p_lap_id
       ,x_qa_result              => x_qa_result
       ,x_return_status          => l_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_SALES_QUOTE_QA_PVT.RUN_QA_CHECKER');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_SALES_QUOTE_QA_PVT.RUN_QA_CHECKER'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --End of Validatation API call

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_qa_val;

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_price
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_price
  -- Description     : This procedure calls api to price lease application.
  -- Business Rules  : This procedure calls api to price lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 26-Oct-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_price(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
			x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_PRICE';
    l_return_status            VARCHAR2(1);

    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list  wf_parameter_list_t;
    p_event_name      VARCHAR2(240) :='oracle.apps.okl.sales.leaseapplication.priced';
    -- Bug#4741121 - viselvar  - Modified - End

    --Cursor to obtain the details of lease quote line of Lease App
    CURSOR l_lsq_dtls_csr(p_lap_id NUMBER)
	IS
      SELECT LSQ.ID LSQ_ID
           , LSQ.STATUS STATUS
      FROM OKL_LEASE_QUOTES_B LSQ
      WHERE LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LSQ.PRIMARY_QUOTE= 'Y'
        AND LSQ.PARENT_OBJECT_ID = p_lap_id;
    l_lsq_dtls_rec l_lsq_dtls_csr%ROWTYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_PRICE';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Obtain the details of Lease Quote line of Lease App
    OPEN l_lsq_dtls_csr(p_lap_id);
    FETCH l_lsq_dtls_csr INTO l_lsq_dtls_rec;
    CLOSE l_lsq_dtls_csr;

    --Pricing Validation
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE');
    END IF;

    OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE(
        p_api_version            => p_api_version
       ,p_init_msg_list          => OKL_API.G_FALSE
       ,p_qte_id                 => l_lsq_dtls_rec.lsq_id
       ,x_return_status          => l_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_PRICING_UTILS_PVT.PRICE_STANDARD_QUOTE'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --End of Pricing API call

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call SET_LEASE_APP_STATUS');
    END IF;

    SET_LEASE_APP_STATUS(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,p_lap_id                => p_lap_id
       ,p_lap_status            => 'PR-COMPLETE'
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call SET_LEASE_APP_STATUS');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of SET_LEASE_APP_STATUS'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Bug#4741121 - viselvar  - Modified - Start
    -- raise the business event passing the Lease Application id added to the parameter list
    wf_event.addparametertolist('LAPP_ID'
                               ,p_lap_id
                               ,l_parameter_list);

    okl_wf_pvt.raise_event(  p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);


    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Bug#4741121 - viselvar  - Modified - End
    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Check if Lease Quote cursor is open
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Check if Lease Quote cursor is open
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Check if Lease Quote cursor is open
      IF l_lsq_dtls_csr%ISOPEN
      THEN
        CLOSE l_lsq_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_price;

  ------------------------------------------------------------------------------
  -- PROCEDURE set_lease_app_status
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : set_lease_app_status
  -- Description     : This procedure sets the required lease application status.
  --                   THIS PROCEDURE IS ONLY FOR OKL INTERNAL DEVELOPMENT PURPOSE
  -- Business Rules  : This procedure sets the required lease application status.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-Nov-2005 PAGARG created Bug 4721142
  --
  -- End of comments
  PROCEDURE set_lease_app_status(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            p_lap_status         IN  VARCHAR2,
			x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'SET_LEASE_APP_STATUS';
    l_return_status            VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    x_lapv_rec		lapv_rec_type;
    x_lsqv_rec      lsqv_rec_type;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.SET_LEASE_APP_STATUS';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate Lease Application rec with the values from database.
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call POPULATE_LEASE_APP');
    END IF;

    POPULATE_LEASE_APP(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lap_id                => p_lap_id
       ,x_lapv_rec              => x_lapv_rec
       ,x_lsqv_rec              => x_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call POPULATE_LEASE_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of POPULATE_LEASE_APP'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := x_lapv_rec;
    l_lapv_rec.application_status := p_lap_status;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_LAP_PVT.UPDATE_ROW');
    END IF;

    OKL_LAP_PVT.UPDATE_ROW(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lapv_rec              => l_lapv_rec
       ,x_lapv_rec              => x_lapv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_LAP_PVT.UPDATE_ROW');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_LAP_PVT.UPDATE_ROW'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END set_lease_app_status;

  --BEGIN-VARANGAN-for bug4747179
  ------------------------------------------------------------------------------
  -- PROCEDURE set_lease_app_expdays
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : set_lease_app_expdays
  -- Description     : This procedure sets the required lease application expiration status
  --                   THIS PROCEDURE IS ONLY FOR OKL INTERNAL DEVELOPMENT PURPOSE
  -- Business Rules  : This procedure sets the required credit expiration date.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 18-Nov-2005 VARANGAN created Bug#4747179
  --
  -- End of comments
  PROCEDURE set_lease_app_expdays(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            p_lap_expdays        IN  NUMBER,
			x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'SET_LEASE_APP_EXPDAYS';
    l_return_status            VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    x_lapv_rec		lapv_rec_type;
    x_lsqv_rec      lsqv_rec_type;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.SET_LEASE_APP_EXPDAYS';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate Lease Application rec with the values from database.
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call POPULATE_LEASE_APP');
    END IF;

    POPULATE_LEASE_APP(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lap_id                => p_lap_id
       ,x_lapv_rec              => x_lapv_rec
       ,x_lsqv_rec              => x_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call POPULATE_LEASE_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of POPULATE_LEASE_APP'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lapv_rec := x_lapv_rec;
    l_lapv_rec.cr_exp_days := p_lap_expdays;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_LAP_PVT.UPDATE_ROW');
    END IF;

    OKL_LAP_PVT.UPDATE_ROW(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lapv_rec              => l_lapv_rec
       ,x_lapv_rec              => x_lapv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_LAP_PVT.UPDATE_ROW');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_LAP_PVT.UPDATE_ROW'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END set_lease_app_expdays;
  --END-VARANGAN-for bug4747179

  ------------------------------------------------------------------------------
  -- FUNCTION is_curr_conv_valid
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_curr_conv_valid
  -- Description     : This function validates Currency Conversion values and
  --                   returns Success or Error
  -- Business Rules  : This function validates Currency Conversion values and
  --                   returns Success or Error
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 02-Feb-2006 PAGARG created Bug 4932155
  --
  -- End of comments
  FUNCTION is_curr_conv_valid(
           p_curr_code           IN VARCHAR2,
           p_curr_type           IN VARCHAR2,
           p_curr_rate           IN NUMBER,
           p_curr_date           IN DATE)
    RETURN VARCHAR2
  IS
    -- Variables Declarations
    l_func_curr_code        VARCHAR2(15);
    l_return_status         VARCHAR2(1);
    l_meaning               VARCHAR2(80);
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    SELECT OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE INTO l_func_curr_code
    FROM DUAL;

    IF(p_curr_code IS NULL
       OR p_curr_code = OKL_API.G_MISS_CHAR)
    THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_INVALID_CURRENCY');
      RETURN l_return_status;
    END IF;

    IF(l_func_curr_code IS NULL
       OR l_func_curr_code = OKL_API.G_MISS_CHAR)
    THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_FUNC_CURR_NOT_FOUND');
      RETURN l_return_status;
    END IF;

    IF(p_curr_code <> l_func_curr_code)
    THEN
      IF(p_curr_type IS NULL
         OR p_curr_type = OKL_API.G_MISS_CHAR
		 OR p_curr_type = 'NONE')
      THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_BPD_PLS_ENT_CUR_TYPE');
        RETURN l_return_status;
      ELSE
        SELECT  USER_CONVERSION_TYPE
        INTO l_meaning
        FROM GL_DAILY_CONVERSION_TYPES
        WHERE CONVERSION_TYPE = p_curr_type;

        IF(l_meaning IS NULL)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_INVALID_CURR_CONV');
          RETURN l_return_status;
        END IF;
      END IF;-- Currency Conversion type check
      IF(p_curr_type IS  NOT NULL AND UPPER(p_curr_type) <> 'USER' )
      THEN
      -- bug 5148581 abhsaxen modify checking condition
      --replace or with and
        IF(p_curr_rate IS NOT NULL
           AND p_curr_rate <> OKL_API.G_MISS_NUM)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_LA_CONV_RATE_CHK');
          RETURN l_return_status;
        END IF;
        IF(p_curr_date IS NULL
           OR p_curr_date = OKL_API.G_MISS_DATE)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_CONVERSION_DATE_INVALID');
          RETURN l_return_status;
        END IF;
      ELSIF(UPPER(p_curr_type) = 'USER')
      THEN
        IF(p_curr_rate IS NULL
           OR p_curr_rate = OKL_API.G_MISS_NUM)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_BPD_USR_RTE_SUPPLIED');
          RETURN l_return_status;
        END IF;
        IF(p_curr_date IS NULL
           OR p_curr_date = OKL_API.G_MISS_DATE)
        THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_CONVERSION_DATE_INVALID');
          RETURN l_return_status;
        END IF;
      END IF;--Check for different values for Conversion Type
    ELSE
      --Currency Conversion columns must not be populated
      IF((p_curr_type IS NOT NULL AND p_curr_type <> OKL_API.G_MISS_CHAR AND p_curr_type <> 'NONE') OR
         (p_curr_rate IS NOT NULL AND p_curr_rate <> OKL_API.G_MISS_NUM) OR
         (p_curr_date IS NOT NULL AND p_curr_date <> OKL_API.G_MISS_DATE))
      THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_CURR_FUNC_CURR_SAME');
        RETURN l_return_status;
      END IF;
    END IF;--Functional Currency and Currency is same or not

    RETURN l_return_status;
  EXCEPTION
    WHEN OTHERS
    THEN
      OKL_API.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
      RETURN OKL_API.G_RET_STS_ERROR;
  END is_curr_conv_valid;

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_unaccept
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_unaccept
  -- Description     : This procedure unaccepts lease application.
  -- Business Rules  : This procedure unaccepts lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 07-Feb-2006 PAGARG created Bug 4905274
  --
  -- End of comments
  PROCEDURE lease_app_unaccept(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APP_UNACCEPT';
    l_return_status            VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lapv_rec		lapv_rec_type;
    l_lsqv_rec      lsqv_rec_type;

    --Cursor to obtain Lease Application Details
    CURSOR lse_app_dtls_csr(p_lse_app_id NUMBER)
    IS
      SELECT REFERENCE_NUMBER
        FROM OKL_LEASE_APPLICATIONS_B LAB
       WHERE LAB.ID = p_lse_app_id;
    lse_app_dtls_rec lse_app_dtls_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.LEASE_APP_UNACCEPT';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate Lease Application rec with the values from database.
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call POPULATE_LEASE_APP');
    END IF;

    POPULATE_LEASE_APP(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_lap_id                => p_lap_id
       ,x_lapv_rec              => l_lapv_rec
       ,x_lsqv_rec              => l_lsqv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call POPULATE_LEASE_APP');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of POPULATE_LEASE_APP'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Validate if Lease App is appealed lease app then unaccept is not allowed
    IF(l_lapv_rec.action = 'APPEAL')
    THEN
      OPEN lse_app_dtls_csr(l_lapv_rec.parent_leaseapp_id);
      FETCH lse_app_dtls_csr INTO lse_app_dtls_rec;
      CLOSE lse_app_dtls_csr;

      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKL_SO_LSE_APP_UNACCEPT_ERR',
          p_token1       => 'LEASE_APP',
          p_token1_value => l_lapv_rec.reference_number,
          p_token2       => 'APL_LEASE_APP',
          p_token2_value => lse_app_dtls_rec.reference_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(l_lapv_rec.application_status = 'PR-ACCEPTED')
    THEN
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call SET_LEASE_APP_STATUS');
      END IF;

      SET_LEASE_APP_STATUS(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,p_lap_id                => p_lap_id
         ,p_lap_status            => 'PR-APPROVED'
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call SET_LEASE_APP_STATUS');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of SET_LEASE_APP_STATUS'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_LEASE_QUOTE_PVT.UNACCEPT_LEASE_QTE');
      END IF;

      -- call the procedure to unaccept lease quote
      OKL_LEASE_QUOTE_PVT.UNACCEPT_LEASE_QTE(
          p_api_version                => p_api_version
         ,p_init_msg_list              => OKL_API.G_FALSE
         ,p_transaction_control        => OKL_API.G_TRUE
         ,p_quote_id                   => l_lsqv_rec.id
         ,x_return_status              => l_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data);

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_LEASE_QUOTE_PVT.UNACCEPT_LEASE_QTE');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_LEASE_QUOTE_PVT.UNACCEPT_LEASE_QTE'
           ,' result status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease Application Details cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease Application Details cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Lease Application Details cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lease_app_unaccept;

  ------------------------------------------------------------------------------
  -- PROCEDURE create_contract
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_contract
  -- Description     : This procedure calls api to create contract from lease app.
  -- Business Rules  : This procedure calls api to create contract from lease app.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-Feb-2006 PAGARG created Bug 4930634
  --                 : This wrapper is created to perform validations before
  --                   converting Lease App to Contract
  -- End of comments
  PROCEDURE create_contract(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            x_chr_id             OUT NOCOPY NUMBER,
            x_chr_number         OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'CREATE_CONTRACT';
    l_return_status            VARCHAR2(1);

    --Cursor to obtain the details of lease quote line of Lease App
    CURSOR l_lap_dtls_csr(p_lap_id NUMBER)
	IS
      SELECT LAB.REFERENCE_NUMBER REFERENCE_NUMBER
           , LAB.LEASE_OPPORTUNITY_ID LEASE_OPPORTUNITY_ID
      FROM OKL_LEASE_APPLICATIONS_B LAB
      WHERE LAB.ID  = p_lap_id;
    l_lap_dtls_rec l_lap_dtls_csr%ROWTYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.CREATE_CONTRACT';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Obtain the details of Lease App
    OPEN l_lap_dtls_csr(p_lap_id);
    FETCH l_lap_dtls_csr INTO l_lap_dtls_rec;
    CLOSE l_lap_dtls_csr;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_QUOTE_TO_CONTRACT_PVT.CREATE_CONTRACT');
    END IF;

    OKL_QUOTE_TO_CONTRACT_PVT.CREATE_CONTRACT(
        p_api_version            => p_api_version
       ,p_init_msg_list          => OKL_API.G_FALSE
       ,x_return_status          => l_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data
       ,p_contract_number        => NULL -- Bug#9356216 - null passed so that OKC Autonumbering would be used
       ,p_parent_object_code     => 'LEASEAPP'
       ,p_parent_object_id       => p_lap_id
       ,x_chr_id                 => x_chr_id
       ,x_contract_number	     => x_chr_number);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_QUOTE_TO_CONTRACT_PVT.CREATE_CONTRACT');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_QUOTE_TO_CONTRACT_PVT.CREATE_CONTRACT'
         ,' return status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --End of create contract API call

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Check if Lease App cursor is open
      IF l_lap_dtls_csr%ISOPEN
      THEN
        CLOSE l_lap_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Check if Lease App cursor is open
      IF l_lap_dtls_csr%ISOPEN
      THEN
        CLOSE l_lap_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Check if Lease App cursor is open
      IF l_lap_dtls_csr%ISOPEN
      THEN
        CLOSE l_lap_dtls_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_contract;

  --Bug 4872271 PAGARG Added function to set Appeal Flag for recommendations
  ------------------------------------------------------------------------------
  -- PROCEDURE appeal_recommendations
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : appeal_recommendations
  -- Description     : This procedure sets the appeal flag for credit recommendations
  --                   of parent lease app of given lease application
  -- Business Rules  : This procedure sets the appeal flag for credit recommendations
  --                   of parent lease app of given lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 28-Mar-2006 PAGARG created Bug 4872271
  --
  -- End of comments
  PROCEDURE appeal_recommendations(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            p_cr_dec_apl_flag    IN  VARCHAR2,
            p_exp_date_apl_flag  IN  VARCHAR2,
            p_cr_conds           IN  NAME_VAL_TBL_TYPE,
            p_addl_rcmnds        IN  NAME_VAL_TBL_TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'APPEAL_RECOMMENDATIONS';
    l_return_status            VARCHAR2(1);
    i                          NUMBER;
    recom_count                NUMBER;
    process_chklst             BOOLEAN;
    approve                    BOOLEAN;

    -- Record/Table Type Declarations
    l_cldv_tbl OKL_CLD_PVT.CLDV_TBL_TYPE;
    x_cldv_tbl OKL_CLD_PVT.CLDV_TBL_TYPE;
    l_appealing_reco_tbl OCM_RECOMMENDATIONS_PUB.APPEALING_RECO_TBL;

    --Cursor to obtain Credit Recommendation details
    CURSOR credit_recom_csr(cp_lap_id NUMBER, cp_recom_id NUMBER, cp_cr_recom VARCHAR2)
    IS
      SELECT RCM.RECOMMENDATION_ID
           , RCM.CASE_FOLDER_ID
           , RCM.CREDIT_REQUEST_ID
           , RCM.CREDIT_RECOMMENDATION
           , RCM.RECOMMENDATION_NAME
           , RCM.APPEALED_FLAG
      FROM AR_CMGT_CF_RECOMMENDS RCM
         , AR_CMGT_CREDIT_REQUESTS CCR
      WHERE RCM.CREDIT_REQUEST_ID = CCR.CREDIT_REQUEST_ID
        AND RCM.CREDIT_RECOMMENDATION = NVL(cp_cr_recom, RCM.CREDIT_RECOMMENDATION)
        AND RCM.RECOMMENDATION_ID = NVL(cp_recom_id, RCM.RECOMMENDATION_ID)
        AND CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCR.SOURCE_COLUMN1 = cp_lap_id;
    credit_recom_rec credit_recom_csr%ROWTYPE;

    --Cursor to obtain Credit Request details of Parent Lease Application
    CURSOR crd_app_data_csr(cp_lap_id NUMBER)
    IS
      SELECT CCR.CREDIT_REQUEST_ID
           , CCR.APPLICATION_NUMBER
           , CCR.TRX_AMOUNT
           , CCR.TRX_CURRENCY
           , CCR.STATUS
           , CCR.RECOMMENDATION_NAME
           , CCR.SOURCE_COLUMN1
           , CCR.SOURCE_COLUMN2
           , CCR.REVIEW_TYPE
           , CCR.CREDIT_CLASSIFICATION
           , CCR.CUST_ACCOUNT_ID
           , LAB.PARENT_LEASEAPP_ID PARENT_LEASEAPP_ID
      FROM AR_CMGT_CREDIT_REQUESTS CCR
         , OKL_LEASE_APPLICATIONS_B LAB
      WHERE SOURCE_COLUMN3 = 'LEASEAPP'
        AND SOURCE_COLUMN1 = LAB.PARENT_LEASEAPP_ID
        AND LAB.ID = cp_lap_id;
    crd_app_data_rec crd_app_data_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.APPEAL_RECOMMENDATIONS';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN crd_app_data_csr(p_lap_id);
    FETCH crd_app_data_csr INTO crd_app_data_rec;
    CLOSE crd_app_data_csr;

    process_chklst := FALSE;
    IF(p_cr_conds.COUNT > 0)
    THEN
      i := p_cr_conds.FIRST;
      LOOP
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call POP_CHECKLIST_ITEM');
        END IF;

        POP_CHECKLIST_ITEM(
            p_api_version           => p_api_version
           ,p_init_msg_list         => OKL_API.G_FALSE
           ,p_cld_id                => p_cr_conds(i).itm_name
           ,x_cldv_rec              => l_cldv_tbl(i)
           ,x_return_status         => l_return_status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call POP_CHECKLIST_ITEM');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of POP_CHECKLIST_ITEM'
             ,'l_return_status ' || l_return_status);
        END IF; -- end of statement level debug

        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_cldv_tbl(i).appeal_flag := p_cr_conds(i).itm_value;
        IF(l_cldv_tbl(i).appeal_flag = 'Y')
        THEN
          process_chklst := TRUE;
        END IF;

        EXIT WHEN (i = p_cr_conds.LAST);
        i := p_cr_conds.NEXT(i);
      END LOOP;

      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'begin debug call OKL_CHECKLIST_PVT.UPD_CHKLST_DTL_APL_FLAG');
      END IF;

      OKL_CHECKLIST_PVT.UPD_CHKLST_DTL_APL_FLAG(
          p_api_version           => p_api_version
         ,p_init_msg_list         => OKL_API.G_FALSE
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_cldv_tbl              => l_cldv_tbl
         ,x_cldv_tbl              => x_cldv_tbl);

   	  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_PROCEDURE
           ,L_MODULE
           ,'end debug call OKL_CHECKLIST_PVT.UPD_CHKLST_DTL_APL_FLAG');
      END IF;

      -- write to log
      IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(
            FND_LOG.LEVEL_STATEMENT
           ,L_MODULE || ' Result of OKL_CHECKLIST_PVT.UPD_CHKLST_DTL_APL_FLAG'
           ,'l_return_status ' || l_return_status);
      END IF; -- end of statement level debug

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;--If check for credit conditions table count check

    recom_count := 1;
    --Process Credit Decision Recommendation
    IF(p_cr_dec_apl_flag = 'Y')
    THEN
      approve := TRUE;
      --Fetch the details for the given recommendation id and populate
      --appealing recommendation table
      OPEN credit_recom_csr(crd_app_data_rec.parent_leaseapp_id, NULL, 'APPROVE');
      FETCH credit_recom_csr INTO credit_recom_rec;
        IF(credit_recom_csr%NOTFOUND)
        THEN
          approve := FALSE;
        END IF;
      CLOSE credit_recom_csr;
      IF(NOT approve)
      THEN
        OPEN credit_recom_csr(crd_app_data_rec.parent_leaseapp_id, NULL, 'REJECT');
        FETCH credit_recom_csr INTO credit_recom_rec;
        CLOSE credit_recom_csr;
      END IF;
      l_appealing_reco_tbl(recom_count).recommendation_id := credit_recom_rec.recommendation_id;
      l_appealing_reco_tbl(recom_count).credit_recommendation := credit_recom_rec.credit_recommendation;
      l_appealing_reco_tbl(recom_count).recommendation_name := credit_recom_rec.recommendation_name;
      recom_count := recom_count + 1;
    END IF;
    --Process Expiration Days Recommendation
    IF(p_exp_date_apl_flag = 'Y')
    THEN
      --Fetch the details for the given recommendation id and populate
      --appealing recommendation table
      OPEN credit_recom_csr(crd_app_data_rec.parent_leaseapp_id, NULL, 'EXPIRATION_DATE');
      FETCH credit_recom_csr INTO credit_recom_rec;
        IF(credit_recom_csr%FOUND)
        THEN
          l_appealing_reco_tbl(recom_count).recommendation_id := credit_recom_rec.recommendation_id;
          l_appealing_reco_tbl(recom_count).credit_recommendation := credit_recom_rec.credit_recommendation;
          l_appealing_reco_tbl(recom_count).recommendation_name := credit_recom_rec.recommendation_name;
          recom_count := recom_count + 1;
        END IF;
      CLOSE credit_recom_csr;
    END IF;
    --Process Checklist Recommendation
    IF(process_chklst)
    THEN
      --Fetch the details for the given recommendation id and populate
      --appealing recommendation table
      OPEN credit_recom_csr(crd_app_data_rec.parent_leaseapp_id, NULL, 'CHECKLIST');
      FETCH credit_recom_csr INTO credit_recom_rec;
        IF(credit_recom_csr%FOUND)
        THEN
          l_appealing_reco_tbl(recom_count).recommendation_id := credit_recom_rec.recommendation_id;
          l_appealing_reco_tbl(recom_count).credit_recommendation := credit_recom_rec.credit_recommendation;
          l_appealing_reco_tbl(recom_count).recommendation_name := credit_recom_rec.recommendation_name;
          recom_count := recom_count + 1;
        END IF;
      CLOSE credit_recom_csr;
    END IF;

    --Loop through the additional recommends flag and populate the recommendations
    --table to be passed to OCM
    IF(p_addl_rcmnds.COUNT > 0)
    THEN
      i := p_addl_rcmnds.FIRST;
      LOOP
        IF(p_addl_rcmnds(i).itm_value = 'Y')
        THEN
          --Fetch the details for the given recommendation id and populate
          --appealing recommendation table
          OPEN credit_recom_csr(crd_app_data_rec.parent_leaseapp_id, p_addl_rcmnds(i).itm_name, NULL);
          FETCH credit_recom_csr INTO credit_recom_rec;
            IF(credit_recom_csr%FOUND)
            THEN
              l_appealing_reco_tbl(recom_count).recommendation_id := credit_recom_rec.recommendation_id;
              l_appealing_reco_tbl(recom_count).credit_recommendation := credit_recom_rec.credit_recommendation;
              l_appealing_reco_tbl(recom_count).recommendation_name := credit_recom_rec.recommendation_name;
              recom_count := recom_count + 1;
            END IF;
          CLOSE credit_recom_csr;
        END IF;
        EXIT WHEN (i = p_addl_rcmnds.LAST);
        i := p_addl_rcmnds.NEXT(i);
      END LOOP;
    END IF;--If check for additional recommendations table count

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OCM_RECOMMENDATIONS_PUB.MARK_APPEAL');
    END IF;

    OCM_RECOMMENDATIONS_PUB.MARK_APPEAL(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,p_commit                => NULL
       ,p_validation_level      => NULL
       ,p_credit_request_id     => crd_app_data_rec.credit_request_id
       ,p_case_folder_id        => NULL
       ,p_appealing_reco_tbl    => l_appealing_reco_tbl
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data);

   	IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OCM_RECOMMENDATIONS_PUB.MARK_APPEAL');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OCM_RECOMMENDATIONS_PUB.MARK_APPEAL'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Credit Recommendation Details Cursor
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Credit Request Details Cursor
      IF crd_app_data_csr%ISOPEN
      THEN
        CLOSE crd_app_data_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Credit Recommendation Details Cursor
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Credit Request Details Cursor
      IF crd_app_data_csr%ISOPEN
      THEN
        CLOSE crd_app_data_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Credit Recommendation Details Cursor
      IF credit_recom_csr%ISOPEN
      THEN
        CLOSE credit_recom_csr;
      END IF;
      --Credit Request Details Cursor
      IF crd_app_data_csr%ISOPEN
      THEN
        CLOSE crd_app_data_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END appeal_recommendations;

  ------------------------------------------------------------------------------
  -- PROCEDURE create_contract_val
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_contract_val
  -- Description     : This procedure validates the contract creation from given
  --                   lease app.
  -- Business Rules  : This procedure validates the contract creation from given
  --                   lease app.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 06-Apr-2006 PAGARG created Bug 5115741
   --                   24-Apr-2009 nikshah Bug 7140398
  -- End of comments
  PROCEDURE create_contract_val(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'CREATE_CONTRACT_VAL';
    l_return_status            VARCHAR2(1);

    --Cursor to obtain the details of lease quote line of Lease App
    CURSOR l_lap_dtls_csr(p_lap_id NUMBER)
	IS
      SELECT LAB.REFERENCE_NUMBER REFERENCE_NUMBER
           , LAB.LEASE_OPPORTUNITY_ID LEASE_OPPORTUNITY_ID
      FROM OKL_LEASE_APPLICATIONS_B LAB
      WHERE LAB.ID  = p_lap_id;
    l_lap_dtls_rec l_lap_dtls_csr%ROWTYPE;

    --Cursor to check if contract already created from lease opp linked to lease app
    --through another Lease App
    CURSOR l_uniq_contract_csr(p_lap_id NUMBER)
	IS
      SELECT LAB.REFERENCE_NUMBER LSE_APP
           , LOP.REFERENCE_NUMBER LSE_OPP
           , CHR.CONTRACT_NUMBER CONTRACT_NUMBER
      FROM OKL_LEASE_APPLICATIONS_B LAB
         , OKL_LEASE_APPLICATIONS_B CLAB
         , OKL_LEASE_OPPORTUNITIES_B LOP
         , OKC_K_HEADERS_B CHR
         , OKC_STATUSES_V CSTS
      WHERE LAB.LEASE_OPPORTUNITY_ID = CLAB.LEASE_OPPORTUNITY_ID
        AND LOP.ID = LAB.LEASE_OPPORTUNITY_ID
        AND LAB.ID <> CLAB.ID
        AND LAB.APPLICATION_STATUS = 'CONV-K'
        AND LAB.ID = CHR.ORIG_SYSTEM_ID1
        AND CHR.ORIG_SYSTEM_SOURCE_CODE = 'OKL_LEASE_APP'
        AND CHR.STS_CODE = CSTS.CODE
        AND CSTS.STE_CODE <> 'CANCELLED'
        AND CLAB.ID = p_lap_id;
    l_uniq_contract_rec l_uniq_contract_csr%ROWTYPE;

    --Cursor to check if contract already created directly from lease opp which
	--is linked to lease app
    CURSOR l_uniq_qte_contract_csr(p_lap_id NUMBER)
	IS
      SELECT LSQ.REFERENCE_NUMBER LSE_QTE
           , LOP.REFERENCE_NUMBER LSE_OPP
           , CHR.CONTRACT_NUMBER CONTRACT_NUMBER
      FROM OKL_LEASE_QUOTES_B LSQ
         , OKL_LEASE_APPLICATIONS_B CLAB
         , OKL_LEASE_OPPORTUNITIES_B LOP
         , OKC_K_HEADERS_B CHR
         , OKC_STATUSES_V CSTS
      WHERE LOP.ID = CLAB.LEASE_OPPORTUNITY_ID
        AND CHR.ORIG_SYSTEM_ID1 = LOP.ID
        AND CHR.ORIG_SYSTEM_SOURCE_CODE = 'OKL_QUOTE'
        AND CSTS.CODE = CHR.STS_CODE
        AND CSTS.STE_CODE <> 'CANCELLED'
        AND LSQ.PARENT_OBJECT_CODE = 'LEASEOPP'
        AND LSQ.PARENT_OBJECT_ID = LOP.ID
        AND LSQ.STATUS = 'CT-ACCEPTED'
        AND CLAB.ID = p_lap_id;
    l_uniq_qte_contract_rec l_uniq_qte_contract_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_LEASE_APP_PVT.CREATE_CONTRACT_VAL';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

         -- ER# 7140398 - Start
         -- Do not allow conversion to contract in case the primary quote is Credit Declined.
         IF (is_primary_quote_declined(p_lap_id)) THEN
       l_return_status := OKL_API.G_RET_STS_ERROR;
       OKL_API.SET_MESSAGE(
             p_app_name      => G_APP_NAME,
             p_msg_name      => 'OKL_SO_DEC_OFFER_TO_CHR_ERR');
       RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         -- Bug# 7140398 - End

    --Obtain the details of Lease App
    OPEN l_lap_dtls_csr(p_lap_id);
    FETCH l_lap_dtls_csr INTO l_lap_dtls_rec;
    CLOSE l_lap_dtls_csr;

    --Validate that only one contract being created from source Lease Opp through
    --any Lease App
    OPEN l_uniq_contract_csr(p_lap_id);
    FETCH l_uniq_contract_csr INTO l_uniq_contract_rec;
      IF l_uniq_contract_csr%FOUND
      THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_SO_LSE_APP_DUP_CRE_CON_ERR',
            p_token1        => 'LSE_OPP',
            p_token1_value  => l_uniq_contract_rec.lse_opp,
            p_token2        => 'CONTRACT',
            p_token2_value  => l_uniq_contract_rec.contract_number,
            p_token3        => 'LSE_APP',
            p_token3_value  => l_uniq_contract_rec.lse_app);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    CLOSE l_uniq_contract_csr;

    --Validate that only one contract being created from source Lease Opp through
    --accepted Lease Quote
    OPEN l_uniq_qte_contract_csr(p_lap_id);
    FETCH l_uniq_qte_contract_csr INTO l_uniq_qte_contract_rec;
      IF l_uniq_qte_contract_csr%FOUND
      THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_SO_LSE_QTE_DUP_CRE_CON_ERR',
            p_token1        => 'LSE_OPP',
            p_token1_value  => l_uniq_qte_contract_rec.lse_opp,
            p_token2        => 'CONTRACT',
            p_token2_value  => l_uniq_qte_contract_rec.contract_number,
            p_token3        => 'LSE_QTE',
            p_token3_value  => l_uniq_qte_contract_rec.lse_qte);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    CLOSE l_uniq_qte_contract_csr;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call CHECK_ELIGIBILITY');
    END IF;

    --call the procedure to Validate Create Contract action on lease app
    CHECK_ELIGIBILITY(
        p_api_version     => p_api_version
       ,p_init_msg_list   => OKL_API.G_FALSE
       ,x_return_status   => l_return_status
       ,x_msg_count       => x_msg_count
       ,x_msg_data        => x_msg_data
       ,p_lap_id          => p_lap_id
       ,p_action          => 'CRECON');

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call CHECK_ELIGIBILITY');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of CHECK_ELIGIBILITY'
         ,'return status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Check if Lease App cursor is open
      IF l_lap_dtls_csr%ISOPEN
      THEN
        CLOSE l_lap_dtls_csr;
      END IF;
      --Check if Unique Contract cursor is open
      IF l_uniq_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_contract_csr;
      END IF;
      --Check if Unique Contract from quote cursor is open
      IF l_uniq_qte_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_qte_contract_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Check if Lease App cursor is open
      IF l_lap_dtls_csr%ISOPEN
      THEN
        CLOSE l_lap_dtls_csr;
      END IF;
      --Check if Unique Contract cursor is open
      IF l_uniq_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_contract_csr;
      END IF;
      --Check if Unique Contract from quote cursor is open
      IF l_uniq_qte_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_qte_contract_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      --Check if Lease App cursor is open
      IF l_lap_dtls_csr%ISOPEN
      THEN
        CLOSE l_lap_dtls_csr;
      END IF;
      --Check if Unique Contract cursor is open
      IF l_uniq_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_contract_csr;
      END IF;
      --Check if Unique Contract from quote cursor is open
      IF l_uniq_qte_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_qte_contract_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_contract_val;

END OKL_LEASE_APP_PVT;

/
