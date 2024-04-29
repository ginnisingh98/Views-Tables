--------------------------------------------------------
--  DDL for Package Body ARI_SELF_REGISTRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARI_SELF_REGISTRATION_PKG" AS
/* $Header: ARISREGB.pls 120.24.12010000.3 2010/04/30 11:13:58 avepati ship $ */

/*=======================================================================+
 |  Global Constants
 +=======================================================================*/

G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'ARI_SELF_REGISTRATION_PKG';
G_CREATED_BY_MODULE CONSTANT VARCHAR2(5)    := 'ARI';

------------------------------------------------------------------------
-- Procedure Result Codes
------------------------------------------------------------------------
G_NO_ROWS                       CONSTANT NUMBER   :=  0;
G_EXACT_MATCH                   CONSTANT NUMBER   :=  1;
G_BOTH_FOUND                    CONSTANT NUMBER   :=  2;
G_PERSON_FOUND                  CONSTANT NUMBER   :=  3;
G_BUSINESS_PERSON_FOUND         CONSTANT NUMBER   :=  4;
G_FUZZY_MATCH                   CONSTANT NUMBER   :=  5;
G_NOT_UNIQUE                    CONSTANT NUMBER   :=  6;
G_COMPANY_DIFF                  CONSTANT NUMBER   := -1;
G_PERSON_DIFF                   CONSTANT NUMBER   := -2;
G_INVALID_PARTY_ID              CONSTANT NUMBER   := -3;
G_PERSON_NO_SIBLING             CONSTANT NUMBER   := -4;
G_BUSINESS_PERSON_NO_SIBLING    CONSTANT NUMBER   := -5;
G_NO_MATCH                      CONSTANT NUMBER   := -6;
G_PERSON_NOT_UNIQUE             CONSTANT NUMBER   := -7;
G_BUSINESS_PERSON_NOT_UNIQUE    CONSTANT NUMBER   := -8;
G_FIRST_DIFF                    CONSTANT NUMBER   := -9;
G_FAMILY_DIFF                   CONSTANT NUMBER   := -10;

--------------------------------------------------------------------------
-- Registration Status Constants
--------------------------------------------------------------------------
G_HOLD                  CONSTANT VARCHAR2(4)   := 'HOLD';
G_REGISTERED            CONSTANT VARCHAR2(10)  := 'REGISTERED';
G_NEW                   CONSTANT VARCHAR2(3)   := 'NEW';
G_NEW_ACCESS            CONSTANT VARCHAR2(10)  := 'NEW_ACCESS';
G_RETRY                 CONSTANT VARCHAR2(5)   := 'RETRY';
G_NEW_ACCESS_RETRY      CONSTANT VARCHAR2(20)  := 'NEW_ACCESS_RETRY';
G_CREATE_USER_REQUESTED CONSTANT VARCHAR2(25)  := 'CREATE_USER_REQUESTED';

--------------------------------------------------------------------------
-- Access Domain Type Constants
--------------------------------------------------------------------------
G_INVOICE_NUM      CONSTANT VARCHAR2(15)  := 'INVOICE_NUM';
G_CUST_ACCT_NUM    CONSTANT VARCHAR2(15)  := 'CUST_ACCT_NUM';

G_CUST_ACCT_HOLD   CONSTANT VARCHAR2(15)  := 'CUST_ACCT_HOLD';
G_USER_HOLD        CONSTANT VARCHAR2(10)  := 'USER_HOLD';
G_USER_REG_COUNT   CONSTANT VARCHAR2(15)  := 'USER_REG_COUNT';
G_CUST_ACCT_N_USER CONSTANT VARCHAR2(20)  := 'CUST_ACCT_N_USER';

G_RECEIPT_DATE     CONSTANT VARCHAR2(15)  := 'RECEIPT_DATE';
G_RECEIPT_AMT      CONSTANT VARCHAR2(15)  := 'RECEIPT_AMT';

G_ORGANIZATION     CONSTANT VARCHAR2(15)  := 'ORGANIZATION';
G_PERSON           CONSTANT VARCHAR2(10)  := 'PERSON';

G_BUSINESS         CONSTANT VARCHAR2(10)  := 'BUSINESS';
G_CONSUMER         CONSTANT VARCHAR2(10)  := 'CONSUMER';

--------------------------------------------------------------------------
-- Local Procedure Signature
--------------------------------------------------------------------------
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE InformSysAdminError(p_procedure_name  IN VARCHAR2,
                              p_debug_info      IN VARCHAR2,
                              p_error           IN VARCHAR2);


/* =======================================================================
 | PROCEDURE ResolveCustomerAccessRequest
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
PROCEDURE ResolveCustomerAccessRequest(p_customer_id                 IN  VARCHAR2,
                                       x_cust_acct_type               OUT NOCOPY  VARCHAR2,
                                       x_result_code                  OUT NOCOPY  NUMBER)
---------------------------------------------------------------------------
IS
  l_cust_acct_cur             GenCursorRef;
  l_cust_acct_id              NUMBER;
  l_cust_acct_number          VARCHAR2(50);
  l_party_id                  NUMBER;
  l_party_type                HZ_PARTIES.party_type%TYPE;
  l_procedure_name 	          VARCHAR2(30) 	:= '.ResolveCustomerAccessRequest';
  l_debug_info                VARCHAR2(200);
BEGIN

  --------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  --------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

  --------------------------------------------------------------------------
  l_debug_info := 'Calling OpenCustAcctCur';
  ---------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;
  OpenCustAcctCur(p_customer_id => p_customer_id,
				  p_cust_acct_cur => l_cust_acct_cur);

  ------------------------------------------------------------------------
  l_debug_info := 'Fetching the results of the cursor';
  ------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;
  ------------------------------------------------------------------------
  LOOP
    FETCH l_cust_acct_cur INTO l_cust_acct_id,
                               l_cust_acct_number,
                               l_party_id,
                               l_party_type;

    EXIT WHEN l_cust_acct_cur%NOTFOUND;
  END LOOP;

  IF (l_cust_acct_cur%ROWCOUNT = 1) THEN
    ----------------------------------------------------------------
    l_debug_info := 'Exact match on customer_id provided';
    ----------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug(l_debug_info);
    END IF;

    x_result_code          := G_EXACT_MATCH;

    IF (l_party_type = G_ORGANIZATION) THEN
      x_cust_acct_type := G_BUSINESS;
    ELSE
      x_cust_acct_type := G_CONSUMER;
    END IF;

  ELSIF (l_cust_acct_cur%ROWCOUNT > 1) THEN
    ----------------------------------------------------------------------
    l_debug_info := 'Non-unique match on customer_id provided';
    ----------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug(l_debug_info);
    END IF;
    x_result_code := G_NOT_UNIQUE;

  ELSE
    -------------------------------------------------------------------------
    l_debug_info := 'No record found based on customer_id provided';
    -------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug(l_debug_info);
    END IF;
    x_result_code := G_NO_ROWS;

  END IF;

  ------------------------------------------------------------------------
  l_debug_info := 'Close Cust Account Cursor';
  ------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;
  CLOSE l_cust_acct_cur;

  --------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have exited this procedure';
  --------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Debug Info: ' || l_debug_info);
         arp_standard.debug(SQLERRM);
      END IF;
	  FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      InformSysAdminError(p_procedure_name  => l_procedure_name,
                          p_debug_info      => l_debug_info,
                          p_error           => SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END ResolveCustomerAccessRequest;

/* =======================================================================
 | PROCEDURE    InitiateHZUserCreation
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
PROCEDURE InitiateHZUserCreation(p_registration_id      IN  NUMBER,
                                   p_user_email_addr      IN  VARCHAR2,
                                   p_cust_acct_type       IN  VARCHAR2,
                                   p_company_id           IN  NUMBER    DEFAULT NULL,
                                   p_access_domain_id     IN  NUMBER,
                                   p_access_domain_number IN  VARCHAR2,
                                   p_person_id            IN  NUMBER    DEFAULT NULL,
                                   p_first_name           IN  VARCHAR2  DEFAULT NULL,
                                   p_family_name          IN  VARCHAR2  DEFAULT NULL,
                                   p_job_title            IN  VARCHAR2  DEFAULT NULL,
                                   p_phone_country_code   IN  VARCHAR2  DEFAULT NULL,
                                   p_area_code            IN  VARCHAR2  DEFAULT NULL,
                                   p_phone_number         IN  VARCHAR2  DEFAULT NULL,
                                   p_extension            IN  VARCHAR2  DEFAULT NULL,
                                   p_init_msg_list        IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
                                   p_reg_service_code     IN  VARCHAR2  DEFAULT 'FND_RESP|AR|ARI_EXTERNAL|STAND',
                                   p_identity_verification_reqd    IN  VARCHAR2  DEFAULT NULL,
                                   p_requested_username   IN  VARCHAR2  DEFAULT NULL,
                                   p_justification        IN  VARCHAR2  DEFAULT NULL,
                                   p_req_start_date       IN  DATE      DEFAULT SYSDATE,
                                   p_req_end_date         IN  DATE      DEFAULT NULL,
                                   p_ame_application_id   IN  VARCHAR2  DEFAULT NULL,
                                   p_ame_trx_type_id      IN  VARCHAR2  DEFAULT NULL,
                                   x_return_status	     OUT NOCOPY  VARCHAR2,
                                   x_msg_count           OUT NOCOPY  NUMBER,
                                   x_msg_data            OUT NOCOPY  VARCHAR2)
  ---------------------------------------------------------------------------
  IS
    l_app_name            FND_NEW_MESSAGES.message_text%TYPE;
    l_umx_reg_data	      UMX_REGISTRATION_PVT.UMX_REGISTRATION_DATA_TBL;
    l_reg_service_type    VARCHAR2(30);
    l_procedure_name      VARCHAR2(30) 	:= '.InitiateHZUserCreation';
    l_debug_info          VARCHAR2(500);
  BEGIN

    --------------------------------------------------------------------
    l_debug_info := 'In debug mode, log we have entered this procedure';
    --------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
    END IF;

    IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      -----------------------------------------------------------------------
      l_debug_info := 'Initialize message list if requested by calling api';
      -----------------------------------------------------------------------
      FND_MSG_PUB.initialize;
    END IF;

    ----------------------------------------------------------------------------
    l_debug_info := 'Retrieve Application Name';
    ----------------------------------------------------------------------------
    FND_MESSAGE.Set_Name('AR', 'ARI_REG_APP_NAME');
    l_app_name := FND_MESSAGE.Get;

    ----------------------------------------------------------------------------
    l_debug_info := 'Check if the registration service code passed in is valid';
    ----------------------------------------------------------------------------
    BEGIN
        SELECT REGSRVC.REG_SERVICE_TYPE
        INTO   l_reg_service_type
        FROM   UMX_REG_SERVICES_VL REGSRVC
        WHERE  REGSRVC.REG_SERVICE_CODE = p_reg_service_code
        AND    REGSRVC.START_DATE <= SYSDATE
        AND    NVL(REGSRVC.END_DATE, SYSDATE+1) > SYSDATE;
    EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME ('AR','ARI_REG_PROCESS_TYPE_ERROR');
            FND_MESSAGE.SET_TOKEN('REG_PROCESS', p_reg_service_code);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    --Reg Service Type should be SELF_SERVICE when calling from Collections
    IF l_reg_service_type <> 'SELF_SERVICE' THEN
        FND_MESSAGE.SET_NAME ('AR','ARI_REG_PROCESS_TYPE_ERROR');
        FND_MESSAGE.SET_TOKEN('REG_PROCESS', p_reg_service_code);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ----------------------------------------------------------------------------
    l_debug_info := 'Set up UMX parameters';
    ----------------------------------------------------------------------------
    l_umx_reg_data(1).ATTR_NAME  := UMX_REGISTRATION_PVT.G_REG_SERVICE_CODE;
    l_umx_reg_data(1).ATTR_VALUE := p_reg_service_code;

    l_umx_reg_data(2).ATTR_NAME  := UMX_REGISTRATION_PVT.G_REG_SERVICE_TYPE;
    l_umx_reg_data(2).ATTR_VALUE := 'SELF_SERVICE';

    l_umx_reg_data(3).ATTR_NAME  := UMX_REGISTRATION_PVT.G_REG_SERVICE_APP_ID;
    l_umx_reg_data(3).ATTR_VALUE := '222';

    l_umx_reg_data(4).ATTR_NAME  := UMX_REGISTRATION_PVT.G_REQUESTED_USERNAME;
    --IF the requested username is not passes, set the user name to email address
    IF p_requested_username IS NOT NULL THEN
        l_umx_reg_data(4).ATTR_VALUE := p_requested_username;
    ELSE
        l_umx_reg_data(4).ATTR_VALUE := p_user_email_addr;
    END IF;

    l_umx_reg_data(5).ATTR_NAME  := UMX_REGISTRATION_PVT.G_IDENTITY_VERIFY_REQD;
    l_umx_reg_data(5).ATTR_VALUE := p_identity_verification_reqd;

    l_umx_reg_data(6).ATTR_NAME  := UMX_REGISTRATION_PVT.G_REQUESTED_FOR_PARTY_ID;
    l_umx_reg_data(6).ATTR_VALUE := p_person_id;

    l_umx_reg_data(7).ATTR_NAME  := 'CUST_ACCT_TYPE';
    l_umx_reg_data(7).ATTR_VALUE := p_cust_acct_type;

    l_umx_reg_data(8).ATTR_NAME  := 'CUSTOMER_ID';
    l_umx_reg_data(8).ATTR_VALUE := p_access_domain_id;

    l_umx_reg_data(9).ATTR_NAME  := UMX_REGISTRATION_PVT.G_JUSTIFICATION;
    l_umx_reg_data(9).ATTR_VALUE := p_justification;

    --NOTE: Date has to be in this format 'YYYY/MM/DD'
    --THis is in sync with FND_DATE.canonical_to_date which is used to retrieve value from WF.
    l_umx_reg_data(10).ATTR_NAME  := UMX_REGISTRATION_PVT.G_REQUESTED_START_DATE;
    l_umx_reg_data(10).ATTR_VALUE := to_char(p_req_start_date,'YYYY/MM/DD');

    l_umx_reg_data(11).ATTR_NAME  := UMX_REGISTRATION_PVT.G_REQUESTED_END_DATE;
    l_umx_reg_data(11).ATTR_VALUE := to_char(p_req_end_date,'YYYY/MM/DD');

    l_umx_reg_data(12).ATTR_NAME  := UMX_REGISTRATION_PVT.G_AME_APPLICATION_ID;
    l_umx_reg_data(12).ATTR_VALUE := p_ame_application_id;

    l_umx_reg_data(13).ATTR_NAME  := UMX_REGISTRATION_PVT.G_AME_TXN_TYPE_ID;
    l_umx_reg_data(13).ATTR_VALUE := p_ame_trx_type_id;

    l_umx_reg_data(14).ATTR_NAME  := 'EMAIL_ADDRESS';
    l_umx_reg_data(14).ATTR_VALUE := p_user_email_addr;

    l_umx_reg_data(15).ATTR_NAME  := 'FIRST_NAME';
    l_umx_reg_data(15).ATTR_VALUE := p_first_name;

    l_umx_reg_data(16).ATTR_NAME  := 'LAST_NAME';
    l_umx_reg_data(16).ATTR_VALUE := p_family_name;

    l_umx_reg_data(17).ATTR_NAME  := 'COUNTRY_CODE';
    l_umx_reg_data(17).ATTR_VALUE := p_phone_country_code;

    l_umx_reg_data(18).ATTR_NAME  := 'AREA_CODE';
    l_umx_reg_data(18).ATTR_VALUE := p_area_code;

    l_umx_reg_data(19).ATTR_NAME  := 'PRIMARY_PHONE';
    l_umx_reg_data(19).ATTR_VALUE := p_phone_number;

    l_umx_reg_data(20).ATTR_NAME  := 'PHONE_EXTENSION';
    l_umx_reg_data(20).ATTR_VALUE := p_extension;

    ----------------------------------------------------------------------------
    l_debug_info := 'Call UMX API to process registration request';
    ----------------------------------------------------------------------------
--    bug 8809700 - commented by avepati
--    UMX_REGISTRATION_PVT.UMX_PROCESS_REG_REQUEST(l_umx_reg_data);

    ----------------------------------------------------------------------------
    l_debug_info := 'In debug mode, log that we have exited this procedure';
    ----------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF (SQLCODE <> -20001) THEN
        IF (PG_DEBUG = 'Y') THEN
           arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
           arp_standard.debug('Debug Info: '  || l_debug_info);
           arp_standard.debug(SQLERRM);
        END IF;
  	  FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
        FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        InformSysAdminError(p_procedure_name  => l_procedure_name,
                            p_debug_info      => l_debug_info,
                            p_error           => SQLERRM);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
  				              p_data	=> x_msg_data);
END InitiateHZUserCreation;

/* =======================================================================
 | PROCEDURE    OpenCustAcctCur
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
--------------------------------------------------------------------------
PROCEDURE OpenCustAcctCur(p_customer_id             IN  VARCHAR2,
				          p_cust_acct_cur           OUT NOCOPY  GenCursorRef)
--------------------------------------------------------------------------
IS
 l_procedure_name 	        VARCHAR2(30) 	:= '.OpenCustAcctCur';
 l_debug_info               VARCHAR2(200);
BEGIN

  --------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  --------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

  --------------------------------------------------------------------
  l_debug_info := 'Open p_cust_acct_cur';
  --------------------------------------------------------------------
  OPEN p_cust_acct_cur FOR
    SELECT      CustAcct.cust_account_id,
                CustAcct.account_number,
                CustAcct.party_id,
                Party.party_type
    FROM        HZ_CUST_ACCOUNTS        CustAcct,
                HZ_PARTIES              Party
    WHERE       CustAcct.cust_account_id     = p_customer_id
    AND         CustAcct.party_id            = Party.party_id;

  --------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have exited this procedure';
  --------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Debug Info: '  || l_debug_info);
         arp_standard.debug(SQLERRM);
      END IF;
	  FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      InformSysAdminError(p_procedure_name  => l_procedure_name,
                          p_debug_info      => l_debug_info,
                          p_error           => SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END OpenCustAcctCur;

/* =======================================================================
 | PROCEDURE    InformSysAdminError
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
--------------------------------------------------------------------------
PROCEDURE InformSysAdminError(p_procedure_name  IN VARCHAR2,
                              p_debug_info      IN VARCHAR2,
                              p_error           IN VARCHAR2)
--------------------------------------------------------------------------
IS
 l_pkg_name			VARCHAR2(30)    := G_PKG_NAME;
 l_procedure_name 	        VARCHAR2(30) 	:= 'InformSysAdminError';
 l_debug_info                   VARCHAR2(200);
BEGIN

  --------------------------------------------------------------------
  l_debug_info := 'Initiate Inform Sysadmin Workflow';
  -------------------------------------------------------------------

EXCEPTION
 WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Debug Info: '  || l_debug_info);
         arp_standard.debug(SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END InformSysAdminError;

/* =======================================================================
 | PROCEDURE    GenerateAccessVerifyQuestion
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
PROCEDURE GenerateAccessVerifyQuestion(
                                   p_registration_id         IN  NUMBER,
                                   p_client_ip_address       IN  VARCHAR2,
                                   p_customer_id             IN  VARCHAR2,
                                   p_customer_site_use_id    IN  VARCHAR2)
---------------------------------------------------------------------------
IS
  l_rowid               VARCHAR2(100);
  l_reg_access_verify_id NUMBER;
  l_verify_access       VerifyAccessTable;
  l_verify_access_rec   VerifyAccessRec;
  l_curr_question       VARCHAR2(2000);
  l_curr_exp_answer     VARCHAR2(2000);
  l_attempts            NUMBER;
  l_customer_site_use_id    VARCHAR2(50);
  l_procedure_name      VARCHAR2(50) 	:= '.GenerateAccessVerifyQuestion';
  l_debug_info          VARCHAR2(300);
BEGIN
  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

  ----------------------------------------------------------------------------
  l_debug_info := 'Insert Row, reg_id = ' || to_char(p_registration_id) || ',ip_addr= ' ||
                  p_client_ip_address || 'customer_id = ' || to_char(p_customer_id) || ',customer_site_id = ' ||
                  to_char(p_customer_site_use_id);
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

  --If customer site id is -1, pass null to ARI_SELF_REG_CONFIG
  IF (p_customer_site_use_id <> -1) THEN
    l_customer_site_use_id := p_customer_site_use_id;
  END IF;

  ARI_SELF_REG_CONFIG.verify_customer_site_access(p_customer_id => p_customer_id,
                                             p_customer_site_use_id => l_customer_site_use_id,
                                    x_verify_access => l_verify_access,
                                    x_attempts => l_attempts);

  IF (l_verify_access.count > 0) THEN
    FOR i IN 1..l_verify_access.count LOOP

    l_reg_access_verify_id := null;

    ARI_REG_VERIFICATIONS_PKG.Insert_Row(
                                 x_rowid                 => l_rowid,
                                 x_client_ip_address     => p_client_ip_address,
                                 x_question              => l_verify_access(i).question,
                                 x_expected_answer       => l_verify_access(i).expected_answer,
                                 x_number_of_attempts    => 0,--l_attempts,
                                 x_customer_id           => p_customer_id,
                                 x_customer_site_use_id  => p_customer_site_use_id,
                                 x_last_update_login  => nvl(FND_GLOBAL.conc_login_id,FND_GLOBAL.login_id),
                                 x_last_update_date   => sysdate,
                                 x_last_updated_by    => nvl(FND_GLOBAL.user_id,-1),
                                 x_creation_date      => sysdate,
                                x_created_by         => nvl(FND_GLOBAL.user_id,-1));



    END LOOP;
  END IF;

  COMMIT;

  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug('after insert row');
  END IF;
  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log that we have exited this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Debug Info: '  || l_debug_info);
         arp_standard.debug(SQLERRM);
      END IF;
	  FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      InformSysAdminError(p_procedure_name  => l_procedure_name,
                          p_debug_info      => l_debug_info,
                          p_error           => SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END GenerateAccessVerifyQuestion;

/* =======================================================================
 | PROCEDURE    ClearRegistrationTable
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
PROCEDURE ClearRegistrationTable IS

   l_procedure_name           VARCHAR2(50);
   l_debug_info	 	          VARCHAR2(200);

BEGIN

    l_procedure_name           := '.ClearRegistrationTable';

    ----------------------------------------------------------------------------------------
    l_debug_info := 'Delete all records in Registration GT';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    DELETE FROM ARI_REG_VERIFICATIONS_GT;

    COMMIT;

    ----------------------------------------------------------------------------------------
    l_debug_info := 'All records in Registration GT deleted';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

EXCEPTION
WHEN OTHERS THEN
      IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
        arp_standard.debug('ERROR =>'|| SQLERRM);
      END IF;

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;


END;

/* =======================================================================
 | PROCEDURE    GenCustDetailAccessQuestion
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
PROCEDURE GenCustDetailAccessQuestion(
                                   p_client_ip_address       IN  VARCHAR2,
                                   p_customer_id             IN  VARCHAR2)
---------------------------------------------------------------------------
IS
  l_rowid               VARCHAR2(100);
  l_reg_access_verify_id NUMBER;
  l_verify_access       VerifyAccessTable;
  l_verify_access_rec   VerifyAccessRec;
  l_curr_question       VARCHAR2(2000);
  l_curr_exp_answer     VARCHAR2(2000);
  l_attempts            NUMBER;
  l_procedure_name      VARCHAR2(50) 	:= '.GenCustDetailAccessQuestion';
  l_debug_info          VARCHAR2(300);
BEGIN
  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;
  ----------------------------------------------------------------------------
  l_debug_info := 'Insert Row,ip_addr= ' || p_client_ip_address || 'customer_id = ' || to_char(p_customer_id);
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

  ARI_SELF_REG_CONFIG.validate_cust_detail_access(p_customer_id => p_customer_id,
                                                  x_verify_access => l_verify_access,
                                                  x_attempts => l_attempts);


  IF (l_verify_access.count > 0) THEN
    FOR i IN 1..l_verify_access.count LOOP

    l_reg_access_verify_id := null;

    ARI_REG_VERIFICATIONS_PKG.Insert_Row(
                                 x_rowid                 => l_rowid,
                                 x_client_ip_address     => p_client_ip_address,
                                 x_question              => l_verify_access(i).question,
                                 x_expected_answer       => l_verify_access(i).expected_answer,
                                 x_number_of_attempts    => 0, --l_attempts,
                                 x_customer_id           => p_customer_id,
                                 x_customer_site_use_id  => null,
                                 x_last_update_login  => nvl(FND_GLOBAL.conc_login_id,FND_GLOBAL.login_id),
                                 x_last_update_date   => sysdate,
                                 x_last_updated_by    => nvl(FND_GLOBAL.user_id,-1),
                                 x_creation_date      => sysdate,
                                 x_created_by         => nvl(FND_GLOBAL.user_id,-1));


    END LOOP;
  END IF;

  COMMIT;

  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug('after insert row');
  END IF;
  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log that we have exited this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Debug Info: '  || l_debug_info);
         arp_standard.debug(SQLERRM);
      END IF;
	  FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      InformSysAdminError(p_procedure_name  => l_procedure_name,
                          p_debug_info      => l_debug_info,
                          p_error           => SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END GenCustDetailAccessQuestion;

/* =======================================================================
 | FUNCTION    ValidateAnswer
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
/*FUNCTION ValidateAnswer( p_answer IN VARCHAR2,
                         p_reg_access_verify_id IN NUMBER)
RETURN VARCHAR2
---------------------------------------------------------------------------
IS
    l_expected_answer   ari_reg_verifications_gt.expected_answer%type;
    l_return            VARCHAR2(5);
BEGIN

    BEGIN
        select expected_answer
        into l_expected_answer
        from ari_reg_verifications_gt
        where reg_access_verify_id = p_reg_access_verify_id;
    END;

    IF l_expected_answer = to_char(p_answer) THEN
        l_return := 'Y';
    ELSE
        l_return := 'N';
    END IF;

    RETURN l_return;

END ValidateAnswer;*/

/* =======================================================================
 | FUNCTION    RemoveRoleAccess
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
PROCEDURE RemoveRoleAccess(p_person_party_id    IN  VARCHAR2,
                           p_customer_id        IN  VARCHAR2,
                           p_cust_acct_site_id  IN  VARCHAR2,
                           x_return_status      OUT  NOCOPY VARCHAR2)
---------------------------------------------------------------------------
IS
    CURSOR cust_acct_role_cur(p_person_party_id    IN  VARCHAR2,
                                p_customer_id        IN  VARCHAR2,
                                p_cust_acct_site_id  IN  VARCHAR2) IS
        select hcar.cust_account_role_id
        from hz_role_responsibility hrr, hz_cust_account_roles hcar
        where hrr.responsibility_type = 'SELF_SERVICE_USER'
        and hrr.cust_account_role_id = hcar.cust_account_role_id
        and hcar.cust_account_id = p_customer_id
       --Bug 4764121 : Fixed the removal of access to all customers
        and DECODE(p_cust_acct_site_id, '-1', -1,p_cust_acct_site_id) =
                    DECODE(p_cust_acct_site_id, '-1', -1, hcar.cust_acct_site_id)
        and hcar.party_id = p_person_party_id;

    CURSOR cu_acct_role_version (p_cust_acct_role_id IN NUMBER) IS
        SELECT OBJECT_VERSION_NUMBER
        FROM HZ_CUST_ACCOUNT_ROLES
        WHERE CUST_ACCOUNT_ROLE_ID = p_cust_acct_role_id;

    l_cust_account_role_id       HZ_CUST_ACCOUNT_ROLES.cust_account_role_id%TYPE;
    p_cust_account_role_rec_type HZ_CUST_ACCOUNT_ROLE_V2PUB.cust_account_role_rec_type;
    l_object_version_number      HZ_CUST_ACCOUNT_ROLES.object_version_number%TYPE;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_return_status              VARCHAR2(10);
    l_procedure_name      VARCHAR2(50) 	:= '.RemoveRoleAccess';
    l_debug_info          VARCHAR2(300);

BEGIN
  	   ----------------------------------------------------------------------------
       l_debug_info := 'In debug mode, log we have entered this procedure';
       ----------------------------------------------------------------------------
       IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
       END IF;

       SAVEPOINT RemoveAccessStart;

       ----------------------------------------------------------------------------
       l_debug_info := 'Update Cust Account Role';
       ----------------------------------------------------------------------------
       IF (PG_DEBUG = 'Y') THEN
          arp_standard.debug(l_debug_info);
       END IF;

       FOR role_record IN cust_acct_role_cur(p_person_party_id,
                                         p_customer_id,
                                         p_cust_acct_site_id)
       LOOP

        OPEN cu_acct_role_version(role_record.cust_account_role_id);
         FETCH cu_acct_role_version  INTO
               l_object_version_number;
         CLOSE cu_acct_role_version;

        p_cust_account_role_rec_type.cust_account_role_id := role_record.cust_account_role_id;
        p_cust_account_role_rec_type.status               := 'I'; --Inactive
        --p_cust_account_role_rec_type.end_date             := sysdate;

        HZ_CUST_ACCOUNT_ROLE_V2PUB.update_cust_account_role (
                                    p_init_msg_list           => FND_API.G_FALSE,
                                    p_cust_account_role_rec   => p_cust_account_role_rec_type,
                                    p_object_version_number   => l_object_version_number,
                                    x_return_status           => l_return_status,
                                    x_msg_count               => l_msg_count,
                                    x_msg_data                => l_msg_data);

         x_return_status := l_return_status;
         --IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         --  RETURN;
         --END IF;

       END LOOP;

       COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        ROLLBACK TO RemoveAccessStart;
END RemoveRoleAccess;

/* =======================================================================
 | FUNCTION    GetPartyRelationshipId
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
FUNCTION GetPartyRelationshipId (p_user_id      IN VARCHAR2,
                                 p_customer_id  IN VARCHAR2)
        RETURN VARCHAR2
---------------------------------------------------------------------------
IS
    l_party_rel_id   VARCHAR2(50);
    l_party_id 	   VARCHAR2(50);
BEGIN

    IF p_customer_id IS NULL THEN

        select to_char(customer_id)
        into l_party_rel_id
        from fnd_user
        where user_id = p_user_id;

    ELSE
	   -- Bug 5219389 - Party Id should be passed instead of cust_account_id.
        SELECT party_id INTO l_party_id FROM hz_cust_accounts WHERE cust_account_id = p_customer_id;

        select party_id into l_party_rel_id
	        from (
	        select hr1.party_id
		 from hz_relationships hr1,
		      hz_relationships hr2,
		      fnd_user         fu
		 where hr1.subject_type = 'PERSON'
		 AND  (hr1.relationship_code = 'CONTACT_OF' OR hr1.relationship_code = 'EMPLOYEE_OF')
		 AND   hr1.status = 'A'
		 and   hr1.object_id = l_party_id
		 and   hr1.subject_id = hr2.subject_id
		 AND  (hr1.end_date is null OR hr1.end_date > sysdate)
		 and   hr2.party_id = fu.customer_id
		 and   fu.user_id  = p_user_id
		UNION ALL
		select hr1.party_id

		 from hz_relationships hr1,
		      fnd_user         fu, hz_parties Party
		 where hr1.subject_type = 'PERSON'
		 AND  (hr1.relationship_code = 'CONTACT_OF' OR hr1.relationship_code = 'EMPLOYEE_OF')
		 AND   hr1.status = 'A'
		 and   hr1.object_id = l_party_id
		 and   hr1.subject_id = fu.customer_id
		 AND  (hr1.end_date is null OR hr1.end_date > sysdate)
		 and   fu.user_id  = p_user_id
		 AND   Party.party_id = fu.customer_id
		 AND   Party.party_type = 'PERSON'
 	 AND   Party.status = 'A');

    END IF;

    RETURN l_party_rel_id;

EXCEPTION
    WHEN OTHERS THEN
        return null;
END GetPartyRelationshipId;

/* =======================================================================
 | FUNCTION    GetCustomerAcctNumber
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
FUNCTION GetCustomerAcctNumber (p_cust_account_id   IN VARCHAR2)
        RETURN VARCHAR2
---------------------------------------------------------------------------
IS
    l_acct_number   varchar2(30);
BEGIN
    select account_number
    into l_acct_number
    from hz_cust_accounts
    where cust_account_id = p_cust_account_id;

    RETURN l_acct_number;

EXCEPTION
    WHEN OTHERS THEN
        return null;
END GetCustomerAcctNumber;

/* =======================================================================
 | FUNCTION    CheckUserIsAdmin
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
FUNCTION CheckUserIsAdmin (p_user_id   IN VARCHAR2)
        RETURN VARCHAR2
---------------------------------------------------------------------------
IS
    l_return  varchar2(5);
BEGIN

    select 'Y'
    into l_return
    from dual
    where p_user_id IN ( select user_id
                         from umx_role_assignments_v
                         where role_name like 'UMX|ARI_CUST_ADMIN');

    RETURN l_return;

EXCEPTION
    WHEN OTHERS THEN
        return 'N';
END CheckUserIsAdmin;

/*=======================================================================
 | FUNCTION    CreatePersonPartyInternal
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
Procedure CreatePersonPartyInternal(p_event in out NOCOPY WF_EVENT_T,
                                    p_person_party_id out NOCOPY varchar2)
---------------------------------------------------------------------------
IS

  l_first_name hz_parties.person_first_name%type;
  l_last_name hz_parties.person_last_name%type;
  l_middle_name hz_parties.person_middle_name%type;
  l_pre_name_adjunct hz_parties.person_pre_name_adjunct%type;
  l_person_name_suffix hz_parties.person_name_suffix%type;

  l_party_number hz_parties.party_number%type;
  l_person_rec HZ_PARTY_V2PUB.PERSON_REC_TYPE;
  l_profile_id                        NUMBER;
  l_reg_type                    VARCHAR2(50);
  l_reg_user_name               fnd_user.user_name%type;
  l_email_address               fnd_user.email_address%type;
  l_procedure_name      VARCHAR2(50) 	:= '.CreatePersonPartyInternal';
  l_debug_info          VARCHAR2(300);

  X_Return_Status               VARCHAR2(20);
  X_Msg_Count                   NUMBER;
  X_Msg_data                    VARCHAR2(300);

BEGIN

  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

  ----------------------------------------------------------------------------
  l_debug_info := 'Read values from the event';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;
  l_first_name := p_event.getvalueforparameter('FIRST_NAME');
  l_last_name := p_event.getvalueforparameter('LAST_NAME');
  l_middle_name := p_event.getvalueforparameter('MIDDLE_NAME');
  l_pre_name_adjunct := p_event.getvalueforparameter('PRE_NAME_ADJUNCT');
  l_person_name_suffix := p_event.getvalueforparameter('PERSON_SUFFIX');

  ----------------------------------------------------------------------------
  l_debug_info := 'Populate person record';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

  l_person_rec.person_first_name := l_first_name;
  l_person_rec.person_middle_name := l_middle_name;
  l_person_rec.person_last_name  := l_last_name;
  l_person_rec.person_pre_name_adjunct := l_pre_name_adjunct;
  l_person_rec.person_name_suffix := l_person_name_suffix;
  l_person_rec.created_by_module := 'ARI';
  l_person_rec.application_id    := 0;

  HZ_PARTY_V2PUB.create_person (
    p_person_rec                 => l_person_rec,
    x_party_id                   => p_person_party_id,
    x_party_number               => l_party_number,
    x_profile_id                 => l_profile_id,
    x_return_status              => X_Return_Status,
    x_msg_count                  => X_Msg_Count,
    x_msg_data                   => X_Msg_Data);

   ----------------------------------------------------------------------------
  l_debug_info := 'Completed Hz_party_v2_pub.createperson: Status'||x_return_status;
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

  if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           ----------------------------------------------------------------------------
           l_debug_info := 'Completed Hz_party_v2_pub.createperson: Message'||X_Msg_Data;
           ----------------------------------------------------------------------------
           IF (PG_DEBUG = 'Y') THEN
             arp_standard.debug(l_debug_info);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   ----------------------------------------------------------------------------
   l_debug_info := 'After creating person party, if this is an Additional Access flow,
   associate the created person party id with the user';
   ----------------------------------------------------------------------------
   IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
   END IF;

   l_reg_type   := p_event.getvalueforparameter('REG_SERVICE_TYPE');

   IF (l_reg_type = 'ADDITIONAL_ACCESS' OR l_reg_type ='ARI_ADD_CUST_ACCESS') THEN
        --Requested User Name is populated with the user name of the user requesting
        --In case of this scenario, admin will not be able to request additional access
        --because this user will not come up in the listing of users under admin.
        -- This is strictly an ART flow scenario.
        l_reg_user_name := p_event.getvalueforparameter('REQUESTED_USERNAME');
        l_email_address := p_event.getvalueforparameter('EMAIL_ADDRESS');

	----------------------------------------------------------------------------
	l_debug_info := 'Call FND_USER_PKG to update user with person party id';
	----------------------------------------------------------------------------
	IF (PG_DEBUG = 'Y') THEN
		arp_standard.debug(l_debug_info);
	END IF;

        FND_USER_PKG.UpdateUser (
  		    x_user_name                  => l_reg_user_name,
  		    x_owner                      => 'CUST',
  		    x_email_address              => l_email_address,
  		    x_customer_id                => p_person_party_id
  		    );

   END IF;

  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log that we have exited this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Debug Info: '  || l_debug_info);
         arp_standard.debug(SQLERRM);
      END IF;
	  FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
	FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
	FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
	FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	FND_MSG_PUB.ADD;
	InformSysAdminError(p_procedure_name  => l_procedure_name,
                          p_debug_info      => l_debug_info,
                          p_error           => SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END CreatePersonPartyInternal;

/*=======================================================================
 | FUNCTION    GetOrgPartyId
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
FUNCTION GetOrgPartyId(p_customer_id IN NUMBER) RETURN NUMBER
IS
    l_org_party_id  NUMBER;
---------------------------------------------------------------------------
BEGIN

    select party_id
    into l_org_party_id
    from hz_cust_accounts
    where cust_account_id = p_customer_id;

    return l_org_party_id;

EXCEPTION
    WHEN OTHERS THEN
        return null;
END GetOrgPartyId;

/*=======================================================================
 | FUNCTION    GetPartySiteId
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
FUNCTION GetPartySiteId(p_cust_site_use_id IN NUMBER) RETURN NUMBER
---------------------------------------------------------------------------
IS
    l_party_site_id  NUMBER;
BEGIN

    select hcas.party_site_id
    into l_party_site_id
    from hz_cust_acct_sites hcas, hz_cust_site_uses hcsu
    where hcas.cust_acct_site_id = hcsu.cust_acct_site_id
    and hcsu.site_use_id = p_cust_site_use_id;

    return l_party_site_id;

EXCEPTION
    WHEN OTHERS THEN
        return null;
END GetPartySiteId;

/*=======================================================================
 | FUNCTION    GetCustAcctSiteId
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
FUNCTION GetCustAcctSiteId(p_cust_site_use_id IN NUMBER) RETURN NUMBER
---------------------------------------------------------------------------
IS
    l_cust_acct_site_id  NUMBER;
BEGIN

    select cust_acct_site_id
    into l_cust_acct_site_id
    from hz_cust_site_uses
    where site_use_id = p_cust_site_use_id;

    return l_cust_acct_site_id;

EXCEPTION
    WHEN OTHERS THEN
        return null;
END GetCustAcctSiteId;

/*=======================================================================
 | FUNCTION    CreateOrgContactInternal
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
Procedure CreateOrgContactInternal(p_event in out NOCOPY WF_EVENT_T,
                                     p_person_party_id in  varchar2,
                                     p_party_id out NOCOPY number)
---------------------------------------------------------------------------
IS
    l_org_contact_id                    NUMBER;
    l_party_rel_id                      NUMBER;
    l_profile_id                        NUMBER;
    l_org_party_id                      NUMBER;
    l_party_site_id                     NUMBER;
    l_customer_id                       NUMBER;
    l_cust_site_use_id                  NUMBER;

    l_org_contact_rec               HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;
    l_party_rel_rec                 HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
    x_org_contact_party_id          NUMBER;
    --l_party_id                      NUMBER;-- to be used for contactpoints
    l_party_number                  VARCHAR2(100);
    l_cust_acct_type                VARCHAR2(20);
    l_already_exists                VARCHAR2(10);
    l_procedure_name		    VARCHAR2(50) 	:= '.CreateOrgContactInternal';
    l_debug_info		    VARCHAR2(300);

    X_Return_Status               VARCHAR2(20);
    X_Msg_Count                   NUMBER;
    X_Msg_data                    VARCHAR2(300);

BEGIN

    ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

    l_customer_id       :=  p_event.getvalueforparameter('CUSTOMER_ID');
    l_cust_site_use_id  :=  p_event.getvalueforparameter('CUSTOMER_SITE_USE_ID');

    l_org_party_id := GetOrgPartyId(p_customer_id => l_customer_id);
    l_party_site_id := GetPartySiteId(p_cust_site_use_id => l_cust_site_use_id);

    l_cust_acct_type := p_event.getvalueforparameter('CUST_ACCT_TYPE');

    ----------------------------------------------------------------------------
    l_debug_info := 'Check if relationship already exists';
    ----------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
      arp_standard.debug(l_debug_info);
    END IF;
    BEGIN
       --Bug 4764121: Storing the value of party_id (even when relationship exists)
        SELECT 'Y',party_id
        INTO l_already_exists,p_party_id
        FROM HZ_RELATIONSHIPS
        WHERE SUBJECT_ID = p_person_party_id
        AND SUBJECT_TYPE = 'PERSON'
        AND SUBJECT_TABLE_NAME = 'HZ_PARTIES'
        AND RELATIONSHIP_TYPE = 'CONTACT'
        AND RELATIONSHIP_CODE = 'CONTACT_OF'
        AND OBJECT_ID   = l_org_party_id
        AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date,SYSDATE))
                           AND TRUNC(NVL(end_date,SYSDATE));
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            --Relationship exists
            RETURN;
        WHEN NO_DATA_FOUND THEN
            l_already_exists := 'N';
    END;

    IF l_already_exists = 'N' THEN

	 ----------------------------------------------------------------------------
	    l_debug_info := 'Create the org contact relationship';
	    ----------------------------------------------------------------------------
	    IF (PG_DEBUG = 'Y') THEN
	      arp_standard.debug(l_debug_info);
	    END IF;

	    l_party_rel_rec.subject_id                    :=  p_person_party_id;
	    l_party_rel_rec.subject_type                  :=  'PERSON';
	    l_party_rel_rec.subject_table_name            :=  'HZ_PARTIES';
	    l_party_rel_rec.relationship_type             :=  'CONTACT';
	    l_party_rel_rec.relationship_code             :=  'CONTACT_OF';
	    l_party_rel_rec.start_date                    :=  sysdate;
	    l_party_rel_rec.object_id                     :=  l_org_party_id;
	    IF l_cust_acct_type = G_BUSINESS THEN
		l_party_rel_rec.object_type               :=  'ORGANIZATION';
	    ELSIF l_cust_acct_type = G_CONSUMER THEN
		l_party_rel_rec.object_type               :=  'PERSON';
	    END IF;
	    l_party_rel_rec.object_table_name             :=  'HZ_PARTIES';
	    l_party_rel_rec.created_by_module             := G_CREATED_BY_MODULE;
	    l_party_rel_rec.application_id                := 0;
	    l_org_contact_rec.party_rel_rec               :=  l_party_rel_rec;
	    l_org_contact_rec.created_by_module           := G_CREATED_BY_MODULE;
	    l_org_contact_rec.application_id              := 0;
	    l_org_contact_rec.party_site_id               := l_party_site_id;

	HZ_PARTY_CONTACT_V2PUB.create_org_contact (
		p_org_contact_rec          =>  l_org_contact_rec,
		x_org_contact_id           =>  x_org_contact_party_id,
		x_party_rel_id              =>  l_party_rel_id,
		x_party_id                  =>  p_party_id,
		x_party_number              =>  l_party_number,
		x_return_status             =>  X_Return_Status,
		x_msg_count                 =>  X_Msg_Count,
		x_msg_data                  =>  X_Msg_data
		);

	if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	end if;

    END IF;

    ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log that we have exited this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Debug Info: '  || l_debug_info);
         arp_standard.debug(SQLERRM);
      END IF;
	  FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      InformSysAdminError(p_procedure_name  => l_procedure_name,
                          p_debug_info      => l_debug_info,
                          p_error           => SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END CreateOrgContactInternal;

/*=======================================================================
 | FUNCTION    CreateContactPointInternal
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
Procedure CreateContactPointInternal(p_event in out NOCOPY WF_EVENT_T,
                                     p_contact_party_id in  varchar2)
---------------------------------------------------------------------------
IS

  l_contact_point_id hz_contact_points.contact_point_id%type;
  l_contact_preference_id hz_contact_preferences.contact_preference_id%type;
  l_email_format HZ_CONTACT_POINTS.email_format%type;
  l_email_address HZ_CONTACT_POINTS.email_address%type;
   l_primary_phone HZ_CONTACT_POINTS.phone_number%type;
  l_area_code HZ_CONTACT_POINTS.phone_area_code%type;
  l_country_code HZ_CONTACT_POINTS.phone_country_code%type;
  l_phone_purpose HZ_CONTACT_POINTS.contact_point_purpose%type;
  l_phone_extension HZ_CONTACT_POINTS.phone_extension%type;
  l_object_version_number HZ_CONTACT_POINTS.object_version_number%type;

  l_profile_id   number;
  l_cust_site_use_id                  NUMBER;

  l_contact_point_rec    HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
  l_email_rec            HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
  l_phone_rec            HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
  l_procedure_name      VARCHAR2(50) 	:= '.CreateContactPointInternal';
  l_debug_info          VARCHAR2(300);

  X_Return_Status               VARCHAR2(20);
  X_Msg_Count                   NUMBER;
  X_Msg_data                    VARCHAR2(300);

BEGIN

  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

  -- get the values from event object
  l_email_address := p_event.getvalueforparameter('EMAIL_ADDRESS');
  l_email_format := p_event.getvalueforparameter('EMAIL_PREFERENCE');
  l_primary_phone := p_event.getvalueforparameter('PRIMARY_PHONE');
  l_area_code     := p_event.getvalueforparameter('AREA_CODE');
  l_country_code  := p_event.getvalueforparameter('COUNTRY_CODE');
  l_phone_purpose := p_event.getvalueforparameter('PHONE_PURPOSE');
  l_phone_extension := p_event.getvalueforparameter('PHONE_EXTENSION');

  --populate the record
  l_contact_point_rec.status :=             'A';
  l_contact_point_rec.owner_table_name :=   'HZ_PARTIES';
  l_contact_point_rec.owner_table_id :=     p_contact_party_id;
  l_contact_point_rec.primary_flag :=       'Y';
  l_contact_point_rec.created_by_module :=  'ARI';
  l_contact_point_rec.application_id    :=  0;

  if l_email_address is not null then
    ----------------------------------------------------------------------------
  l_debug_info := 'Email Address not null - create/update email contact point';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

    l_contact_point_rec.contact_point_type := 'EMAIL';

    l_email_rec.email_address := l_email_address;
    l_email_rec.email_format  := l_email_format;

    ----------------------------------------------------------------------------
  l_debug_info := 'Check if an email record already exists';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;
    BEGIN
        l_contact_point_id := null;

        SELECT contact_point_id
        INTO l_contact_point_id
        FROM hz_contact_points
        WHERE owner_table_id = p_contact_party_id
        AND owner_table_name = 'HZ_PARTIES'
        AND status = 'A'
        AND primary_flag = 'Y'
        AND contact_point_type = 'EMAIL';
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            --Not possible
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        WHEN OTHERS THEN
            NULL;
    END;

    IF (l_contact_point_id IS NULL) THEN

        ----------------------------------------------------------------------------
        l_debug_info := 'Create email contact point';
        ----------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
          arp_standard.debug(l_debug_info);
        END IF;

        HZ_CONTACT_POINT_V2PUB.create_contact_point (
            p_contact_point_rec           => l_contact_point_rec,
            p_email_rec                   => l_email_rec,
            x_contact_point_id            => l_contact_point_id,
            x_return_status              => X_Return_Status,
            x_msg_count                  => X_Msg_Count,
            x_msg_data                   => X_Msg_Data);
    ELSE

        ----------------------------------------------------------------------------
        l_debug_info := 'Update email contact point';
        ----------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
          arp_standard.debug(l_debug_info);
        END IF;

        SELECT object_version_number
        INTO   l_object_version_number
        FROM   HZ_CONTACT_POINTS
        WHERE  contact_point_id = l_contact_point_id;


        HZ_CONTACT_POINT_V2PUB.update_contact_point (
            p_contact_point_rec           => l_contact_point_rec,
            p_email_rec                   => l_email_rec,
            p_object_version_number       => l_object_version_number,
            x_return_status              => X_Return_Status,
            x_msg_count                  => X_Msg_Count,
            x_msg_data                   => X_Msg_Data);
    END IF;

	----------------------------------------------------------------------------
        l_debug_info := 'Contact point done: Status' || X_Return_Status;
        ----------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
          arp_standard.debug(l_debug_info);
        END IF;

    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

  end if; --mail address not null


  if l_primary_phone is not null then

     ----------------------------------------------------------------------------
  l_debug_info := 'Primary Phone not null - create/update phone contact point';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

    l_contact_point_rec.contact_point_type := 'PHONE';
    l_contact_point_rec.contact_point_purpose := l_phone_purpose;
    --bug #3483248
    l_phone_rec.phone_number := l_primary_phone;
    l_phone_rec.phone_area_code := l_area_code;
    l_phone_rec.phone_country_code := l_country_code;
    l_phone_rec.phone_extension := l_phone_extension;
    l_phone_rec.phone_line_type := 'GEN';

    ----------------------------------------------------------------------------
  l_debug_info := 'Check if a phone record already exists';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;
    BEGIN
        l_contact_point_id := null;

        SELECT contact_point_id
        INTO l_contact_point_id
        FROM hz_contact_points
        WHERE owner_table_id = p_contact_party_id
        AND owner_table_name = 'HZ_PARTIES'
        AND status = 'A'
        AND primary_flag = 'Y'
        AND contact_point_type = 'PHONE';
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            --Not possible
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        WHEN OTHERS THEN
            NULL;
    END;

    IF (l_contact_point_id IS NULL) THEN

        ----------------------------------------------------------------------------
        l_debug_info := 'Create phone contact point';
        ----------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
          arp_standard.debug(l_debug_info);
        END IF;

        HZ_CONTACT_POINT_V2PUB.create_contact_point (
            p_contact_point_rec               => l_contact_point_rec,
            p_phone_rec                       => l_phone_rec,
            x_contact_point_id                => l_contact_point_id,
            x_return_status                   => X_Return_Status,
            x_msg_count                       => X_Msg_Count,
            x_msg_data                        => X_Msg_Data );
    ELSE

	----------------------------------------------------------------------------
        l_debug_info := 'Update phone contact point';
        ----------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
          arp_standard.debug(l_debug_info);
        END IF;

        SELECT object_version_number
        INTO   l_object_version_number
        FROM   HZ_CONTACT_POINTS
        WHERE  contact_point_id = l_contact_point_id;

        HZ_CONTACT_POINT_V2PUB.update_contact_point (
            p_contact_point_rec           => l_contact_point_rec,
            p_phone_rec                       => l_phone_rec,
            p_object_version_number       => l_object_version_number,
            x_return_status              => X_Return_Status,
            x_msg_count                  => X_Msg_Count,
            x_msg_data                   => X_Msg_Data);
    END IF;

	----------------------------------------------------------------------------
        l_debug_info := 'Contact point done: Status' || X_Return_Status;
        ----------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
          arp_standard.debug(l_debug_info);
        END IF;

    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

  end if;

   ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log that we have exited this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Debug Info: '  || l_debug_info);
         arp_standard.debug(SQLERRM);
      END IF;
	  FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      InformSysAdminError(p_procedure_name  => l_procedure_name,
                          p_debug_info      => l_debug_info,
                          p_error           => SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END CreateContactPointInternal;

 /* =======================================================================
 | PROCEDURE    CreateCustAcctRoleFor
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
--------------------------------------------------------------------------
PROCEDURE CreateCustAcctRoleFor(p_event in out NOCOPY WF_EVENT_T,
                                p_party_id    IN  NUMBER,
                                p_cust_acct_role_id    OUT NOCOPY  NUMBER)
--------------------------------------------------------------------------
IS
 l_cust_acct_roles_rec      hz_cust_account_role_v2pub.cust_account_role_rec_type;
 l_return_status            VARCHAR2(1);
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(2000);
 l_customer_id              NUMBER;
 l_cust_acct_site_id        NUMBER;
 l_cust_site_use_id              NUMBER;
 l_already_exists                VARCHAR2(10);

 l_cust_acct_role_id        NUMBER;
 l_procedure_name 	        VARCHAR2(30) 	:= '.CreateCustAcctRoleFor';
 l_debug_info               VARCHAR2(200);
 l_status                   VARCHAR2(1);
 l_version_number           NUMBER;
BEGIN

    ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

  l_customer_id       :=  p_event.getvalueforparameter('CUSTOMER_ID');
    l_cust_site_use_id  :=  p_event.getvalueforparameter('CUSTOMER_SITE_USE_ID');

    l_cust_acct_site_id := GetCustAcctSiteId(p_cust_site_use_id => l_cust_site_use_id);

     ----------------------------------------------------------------------------
  l_debug_info := 'Check if role already exists';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

    BEGIN
        l_already_exists := 'N';
        l_status:='A';
       --Bug 4764121: Activating a inactive role
        SELECT 'Y',a.cust_account_role_id,status,a.object_version_number
        INTO l_already_exists,p_cust_acct_role_id,l_status,l_version_number
        FROM hz_cust_account_roles a
        WHERE party_id = p_party_id
        AND cust_account_id = l_customer_id
        AND ((cust_acct_site_id is null and l_cust_acct_site_id is null )
        OR  cust_acct_site_id = l_cust_acct_site_id )
        AND role_type = 'CONTACT'
        AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(begin_date,SYSDATE))
                           AND TRUNC(NVL(end_date,SYSDATE));
        IF l_status='I' THEN
	  ----------------------------------------------------------------------------
	  l_debug_info := 'Role exists but is Inactive.Trying to activate it.Role Id= '||p_cust_acct_role_id;
	  ----------------------------------------------------------------------------
	  IF (PG_DEBUG = 'Y') THEN
	     arp_standard.debug(l_debug_info);
	  END IF;

	  l_cust_acct_roles_rec.party_id            := p_party_id;
	  l_cust_acct_roles_rec.cust_account_id     := l_customer_id;
	  l_cust_acct_roles_rec.cust_acct_site_id   := l_cust_acct_site_id;
	  l_cust_acct_roles_rec.role_type           := 'CONTACT';
	  l_cust_acct_roles_rec.created_by_module   := 'ARI';
	  l_cust_acct_roles_rec.cust_account_role_id := p_cust_acct_role_id;
	  l_cust_acct_roles_rec.status := 'A';

	  HZ_CUST_ACCOUNT_ROLE_V2PUB.update_cust_account_role (
				p_init_msg_list   => FND_API.G_TRUE,
							  p_cust_account_role_rec => l_cust_acct_roles_rec,
							  x_return_status       => l_return_status,
							  x_msg_count           => l_msg_count,
							  x_msg_data            => l_msg_data,
							  p_object_version_number  => l_version_number);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

   	    ----------------------------------------------------------------------
   	    l_debug_info := 'Error Calling HZ Update Cust Acct Roles API:  ' || l_msg_data;
   	    ----------------------------------------------------------------------
   	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          END IF;
       END IF;
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            --Role exists
            RETURN;
        WHEN OTHERS THEN
            NULL;
    END;

    IF l_already_exists = 'N' THEN

       ----------------------------------------------------------------------------
        l_debug_info := 'Create customer account role';
        ----------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
          arp_standard.debug(l_debug_info);
        END IF;

	  l_cust_acct_roles_rec.party_id            := p_party_id;
	  l_cust_acct_roles_rec.cust_account_id     := l_customer_id;
	  l_cust_acct_roles_rec.cust_acct_site_id   := l_cust_acct_site_id;
	  l_cust_acct_roles_rec.role_type           := 'CONTACT';
	  l_cust_acct_roles_rec.created_by_module   := 'ARI';

	  ------------------------------------------------------------------------
	  l_debug_info := 'Call hz_cust_account_v2pub.Create_Cust_Acct_Roles';
	  ------------------------------------------------------------------------
	  HZ_CUST_ACCOUNT_ROLE_V2PUB.Create_Cust_Account_Role(
							  p_init_msg_list   => FND_API.G_TRUE,
							  p_cust_account_role_rec => l_cust_acct_roles_rec,
							  x_return_status       => l_return_status,
							  x_msg_count           => l_msg_count,
							  x_msg_data            => l_msg_data,
							  x_cust_account_role_id  => l_cust_acct_role_id);

	  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	      ----------------------------------------------------------------------
	      l_debug_info := 'Return cust acct role id';
	      ----------------------------------------------------------------------
	      p_cust_acct_role_id := l_cust_acct_role_id;
	  ELSE

	    ----------------------------------------------------------------------
	    l_debug_info := 'Error Calling HZ Create Cust Acct Roles API:  ' || l_msg_data;
	    ----------------------------------------------------------------------
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	  END IF;

  END IF;

   ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log that we have exited this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Debug Info: '  || l_debug_info);
         arp_standard.debug(SQLERRM);
      END IF;
	  FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      InformSysAdminError(p_procedure_name  => l_procedure_name,
                          p_debug_info      => l_debug_info,
                          p_error           => SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END CreateCustAcctRoleFor;


 /* =======================================================================
 | PROCEDURE    CreateRoleRespFor
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
--------------------------------------------------------------------------
PROCEDURE CreateRoleRespFor(p_cust_acct_role_id     IN  NUMBER,
                            p_role_resp_id         OUT NOCOPY  NUMBER)
--------------------------------------------------------------------------
IS
 l_role_resp_rec            HZ_CUST_ACCOUNT_ROLE_V2PUB.role_responsibility_rec_type;
 l_return_status            VARCHAR2(1);
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(2000);
 l_responsibility_id        NUMBER;
 l_procedure_name 	        VARCHAR2(30) 	:= '.CreateRoleRespFor';
 l_debug_info               VARCHAR2(200);
 l_already_exists           VARCHAR2(10);
BEGIN

   ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

     ----------------------------------------------------------------------------
  l_debug_info := 'Check if role responsbility already exists';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

    BEGIN
        l_already_exists := 'N';

        SELECT 'Y'
        INTO l_already_exists
        FROM hz_role_responsibility
        WHERE cust_account_role_id = p_cust_acct_role_id
        AND responsibility_type   = 'SELF_SERVICE_USER';

    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            --Role exists
            RETURN;
        WHEN OTHERS THEN
            NULL;
    END;

    IF l_already_exists = 'N' THEN

  l_role_resp_rec.cust_account_role_id  := p_cust_acct_role_id;
  l_role_resp_rec.responsibility_type   := 'SELF_SERVICE_USER';
  l_role_resp_rec.created_by_module     := 'ARI';

  --------------------------------------------------------------------
  l_debug_info := 'Call HZ_CUST_ACCOUNT_ROLE_V2PUB.create_role_responsibility';
  --------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;
  HZ_CUST_ACCOUNT_ROLE_V2PUB.create_role_responsibility(
                                            p_init_msg_list       => FND_API.G_TRUE,
                                            p_role_responsibility_rec       => l_role_resp_rec,
                                            x_return_status       => l_return_status,
                                            x_msg_count           => l_msg_count,
                                            x_msg_data            => l_msg_data,
                                            x_responsibility_id   => l_responsibility_id);

  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    ----------------------------------------------------------------------
    l_debug_info := 'Return role responsibility id';
    ----------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;
    p_role_resp_id := l_responsibility_id;
  ELSE
    ----------------------------------------------------------------------
    l_debug_info := 'Error Calling HZ Create Role Resp API:  ' || l_msg_data;
    ----------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  END IF;

   ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log that we have exited this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Debug Info: '  || l_debug_info);
         arp_standard.debug(SQLERRM);
      END IF;
	  FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      InformSysAdminError(p_procedure_name  => l_procedure_name,
                          p_debug_info      => l_debug_info,
                          p_error           => SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END CreateRoleRespFor;

/*=======================================================================
 | PROCEDURE    RegisterB2BUser
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
PROCEDURE RegisterB2BUser( p_event IN OUT NOCOPY WF_EVENT_T,
                           p_person_party_id IN OUT NOCOPY VARCHAR2)
---------------------------------------------------------------------------
IS
    l_party_id  NUMBER;
    l_cust_acct_role_id HZ_CUST_ACCOUNT_ROLES.cust_account_role_id%type;
    l_role_resp_id  HZ_ROLE_RESPONSIBILITY.responsibility_id%type;
    l_cust_acct_type   VARCHAR2(20);
    l_procedure_name      VARCHAR2(50) 	:= '.RegisterB2BUser';
    l_debug_info          VARCHAR2(300);

    X_Return_Status               VARCHAR2(20);
    X_Msg_Count                   NUMBER;
    X_Msg_data                    VARCHAR2(300);

BEGIN

    ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

    IF (p_person_party_id IS NULL) THEN
        CreatePersonPartyInternal(p_event,p_person_party_id);
    END IF;
    CreateOrgContactInternal(p_event, p_person_party_id, l_party_id);
    CreateContactPointInternal(p_event,to_char(l_party_id));
    CreateCustAcctRoleFor(p_event, l_party_id, l_cust_acct_role_id);
    CreateRoleRespFor(l_cust_acct_role_id, l_role_resp_id);

     ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log that we have exited this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

END RegisterB2BUser;

/*=======================================================================
 | PROCEDURE    RegisterB2CUser
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
PROCEDURE RegisterB2CUser( p_event IN OUT NOCOPY WF_EVENT_T,
                           p_person_party_id IN OUT NOCOPY varchar2 )
---------------------------------------------------------------------------
IS
    l_contact_preference_rec HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
    l_contact_preference VARCHAR2(5);
    l_contact_preference_id number;
    l_party_id  NUMBER;
    l_cust_acct_role_id HZ_CUST_ACCOUNT_ROLES.cust_account_role_id%type;
    l_role_resp_id  HZ_ROLE_RESPONSIBILITY.responsibility_id%type;
    l_cust_acct_type   VARCHAR2(20);
    l_new_user         VARCHAR2(10);

    l_procedure_name      VARCHAR2(50) 	:= '.RegisterB2CUser';
    l_debug_info          VARCHAR2(300);


    X_Return_Status               VARCHAR2(20);
    X_Msg_Count                   NUMBER;
    X_Msg_data                    VARCHAR2(300);

BEGIN

     ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

    IF (p_person_party_id IS NULL) THEN
	l_new_user := 'Y';
        CreatePersonPartyInternal(p_event,p_person_party_id);
    END IF;
    CreateContactPointInternal(p_event,p_person_party_id);
    CreateOrgContactInternal(p_event, p_person_party_id, l_party_id);
    CreateCustAcctRoleFor(p_event, l_party_id, l_cust_acct_role_id);
    CreateRoleRespFor(l_cust_acct_role_id, l_role_resp_id);

    --populate contact preference if its a new user
    IF (l_new_user = 'Y') THEN
        l_contact_preference := p_event.getvalueforparameter('CONTACT_PREFERENCE');

        IF (l_contact_preference = 'Y') THEN
            l_contact_preference_rec.preference_code := 'DO';
        ELSE
            l_contact_preference_rec.preference_code := 'DO_NOT';
        END IF;

        l_contact_preference_rec.contact_level_table := 'HZ_PARTIES';
        l_contact_preference_rec.contact_level_table_id := p_person_party_id;
        l_contact_preference_rec.contact_type := 'EMAIL';
        l_contact_preference_rec.requested_by := 'INTERNAL';
        l_contact_preference_rec.created_by_module := 'ARI';
        l_contact_preference_rec.application_id := 0;

         ----------------------------------------------------------------------------
	l_debug_info := 'Create contact preference';
	----------------------------------------------------------------------------
	IF (PG_DEBUG = 'Y') THEN
		arp_standard.debug(l_debug_info);
	END IF;

        HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference(
            p_contact_preference_rec          => l_contact_preference_rec,
            x_contact_preference_id           => l_contact_preference_id,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
       END IF;

         ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log that we have exited this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

END RegisterB2CUser;

/*=======================================================================
 | PROCUDURE    RegisterUser
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
PROCEDURE RegisterUser( p_event IN OUT NOCOPY WF_EVENT_T,
                        p_person_party_id IN OUT NOCOPY varchar2 )
---------------------------------------------------------------------------
IS
    l_cust_acct_type   VARCHAR2(20);
    l_procedure_name      VARCHAR2(50) 	:= '.RegisterUser';
    l_debug_info          VARCHAR2(300);
BEGIN

    ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

    ----------------------------------------------------------------------------
  l_debug_info := 'Check if the customer access requested if of BUSINESS or CONSUMER type';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

    l_cust_acct_type := p_event.getvalueforparameter('CUST_ACCT_TYPE');

    IF  (l_cust_acct_type = G_BUSINESS) THEN
        RegisterB2BUser(p_event, p_person_party_id);
    ELSIF (l_cust_acct_type = G_CONSUMER) THEN
        RegisterB2CUser(p_event, p_person_party_id);
    END IF;

     ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

END RegisterUser;

/*=======================================================================
 | FUNCTION    AddCustomerAccess
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
FUNCTION AddCustomerAccess(p_subscription_guid in raw,
	                            p_event in out NOCOPY WF_EVENT_T)
	         RETURN VARCHAR2
---------------------------------------------------------------------------
IS
	  l_success 		VARCHAR2(10);
	  l_reg_service_type 	VARCHAR2(50);
	  l_person_party_id  	VARCHAR2(50);
      l_temp1   VARCHAR2(100);
      l_temp2   VARCHAr2(100);

	l_procedure_name      VARCHAR2(50) 	:= '.AddCustomerAccess';
	l_debug_info          VARCHAR2(300);

	BEGIN

	   ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

	  -- This function is called on the event 'oracle.apps.fnd.umx.requestapproved'
	  -- To ensure that the code to add access gets executed only for Add Access flow
	  -- Check for the REG_SERVICE_TYPE of the registration process.

	  l_reg_service_type := p_event.getvalueforparameter('REG_SERVICE_TYPE');

          IF ((l_reg_service_type = 'ADDITIONAL_ACCESS' AND
               p_event.getValueForParameter('UMX_CUSTOM_EVENT_CONTEXT') = UMX_PUB.ROLE_APPROVED)
       --Bug 4764121
           OR l_reg_service_type = 'ARI_ADD_CUST_ACCESS' ) THEN

		----------------------------------------------------------------------------
  l_debug_info := 'Add access for the user';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;
	  	l_person_party_id  :=  p_event.getvalueforparameter('PERSON_PARTY_ID');

	  	RegisterUser(p_event, l_person_party_id);

	  END IF;

	  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

	  l_success	:= 'success';
	  RETURN l_success;

EXCEPTION
	    WHEN OTHERS THEN
	        WF_CORE.CONTEXT('ARI_SELF_REGISTRATION_PKG', 'AddCustomerAccess',
	                p_event.getEventName( ),p_subscription_guid,
			sqlerrm,sqlcode);
	        WF_EVENT.SetErrorInfo(p_event,'ERROR');
	        raise;
	        return 'ERROR';

END AddCustomerAccess;

/*=======================================================================
 | FUNCTION    CreatePersonParty
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
FUNCTION CreatePersonParty(p_subscription_guid in raw,
                            p_event in out NOCOPY WF_EVENT_T)
         RETURN VARCHAR2
---------------------------------------------------------------------------
IS

  l_first_name hz_parties.person_first_name%type;
  l_last_name hz_parties.person_last_name%type;
  l_middle_name hz_parties.person_middle_name%type;
  l_pre_name_adjunct hz_parties.person_pre_name_adjunct%type;
  l_person_name_suffix hz_parties.person_name_suffix%type;

  l_party_number hz_parties.party_number%type;
  l_person_rec HZ_PARTY_V2PUB.PERSON_REC_TYPE;
  l_profile_id                        NUMBER;
  l_success VARCHAR2(10);
  p_person_party_id varchar2(30);
  l_procedure_name      VARCHAR2(50) 	:= '.CreateContactPointInternal';
  l_debug_info          VARCHAR2(300);

  X_Return_Status               VARCHAR2(20);
  X_Msg_Count                   NUMBER;
  X_Msg_data                    VARCHAR2(300);

BEGIN

  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

----------------------------------------------------------------------------
  l_debug_info := 'Create B2C party and populate the event object back to main workflow';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

  if(p_event.getValueForParameter('UMX_CUSTOM_EVENT_CONTEXT') =
     UMX_PUB.BEFORE_ACT_ACTIVATION) then

    RegisterUser(p_event,p_person_party_id);

    ----------------------------------------------------------------------------
        l_debug_info := 'Person Party Created:' || p_person_party_id;
        ----------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
          arp_standard.debug(l_debug_info);
        END IF;

   l_success := UMX_REGISTRATION_UTIL.set_event_object(p_event,'PERSON_PARTY_ID',p_person_party_id);

  end if;

  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log that we have exited this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

  IF l_success <> 'success' THEN
    WF_CORE.CONTEXT('ARI_SELF_REGISTRATION_PKG', 'CREATE_PERSON_PARTY',
                p_event.getEventName( ),p_subscription_guid,sqlerrm,sqlcode);
    WF_EVENT.SetErrorInfo(p_event,'ERROR');
  END IF;

  return l_success;

EXCEPTION
    WHEN OTHERS THEN
        WF_CORE.CONTEXT('ARI_SELF_REGISTRATION_PKG', 'CREATE_PERSON_PARTY',
                p_event.getEventName( ),p_subscription_guid,
		sqlerrm,sqlcode);
        WF_EVENT.SetErrorInfo(p_event,'ERROR');
        raise;
        return 'ERROR';

END CreatePersonParty;

/*=======================================================================
 | FUNCTION    RaiseAddCustAccessEvent
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
PROCEDURE RaiseAddCustAccessEvent (p_person_party_id    IN VARCHAR2,
                                   p_customer_id        IN VARCHAR2,
                                   p_cust_site_use_id   IN VARCHAR2 DEFAULT NULL,
                                   p_cust_acct_type     IN VARCHAR2,
                                   p_first_name         IN VARCHAR2,
                                   p_last_name          IN VARCHAR2,
                                   p_middle_name        IN VARCHAR2,
                                   p_pre_name_adjunct   IN VARCHAR2,
                                   p_person_suffix      IN VARCHAR2)
---------------------------------------------------------------------------
IS
    l_parameter_list wf_parameter_list_t;
    l_event_name    VARCHAR2(100);
    l_item_key      VARCHAR2(2000);
    l_user_name     VARCHAR2(100);
BEGIN

    wf_event.addParametertoList('PERSON_PARTY_ID', p_person_party_id, l_parameter_list);
    wf_event.addParametertoList('CUSTOMER_ID', p_customer_id, l_parameter_list);
    wf_event.addParametertoList('CUSTOMER_SITE_USE_ID', p_cust_site_use_id, l_parameter_list);
    wf_event.addParametertoList('REG_SERVICE_TYPE', 'ARI_ADD_CUST_ACCESS', l_parameter_list);
    wf_event.addParametertoList('CUST_ACCT_TYPE', p_cust_acct_type, l_parameter_list);
    wf_event.addParametertoList('FIRST_NAME', p_first_name, l_parameter_list);
    wf_event.addParametertoList('LAST_NAME', p_last_name, l_parameter_list);
    wf_event.addParametertoList('MIDDLE_NAME', p_middle_name, l_parameter_list);
    wf_event.addParametertoList('PRE_NAME_ADJUNCT', p_pre_name_adjunct, l_parameter_list);
    wf_event.addParametertoList('PERSON_SUFFIX', p_person_suffix, l_parameter_list);
    IF p_person_party_id IS NULL THEN
      SELECT usr.user_name into l_user_name
          FROM fnd_user usr
          WHERE Usr.user_id = fnd_global.user_id;
      wf_event.addParametertoList('REQUESTED_USERNAME', l_user_name, l_parameter_list);
    END IF;
    l_event_name := 'oracle.apps.ar.irec.addcustaccess';
    SELECT UMX_REG_REQUESTS_S.nextval INTO l_item_key FROM dual;
    wf_event.raise(l_event_name,l_item_key,null,l_parameter_list,sysdate);

END RaiseAddCustAccessEvent;

/*=======================================================================
 | FUNCTION    GetRegSecurityProfile
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
FUNCTION GetRegSecurityProfile(p_user_id IN VARCHAR2 DEFAULT NULL,
                               p_resp_id IN VARCHAR2)
         RETURN VARCHAR2
---------------------------------------------------------------------------
IS
    l_reg_sec_profile   VARCHAR2(15) := 0;
BEGIN

    IF p_user_id IS NOT NULL THEN
        BEGIN
            select fpov.profile_option_value
            into l_reg_sec_profile
            from   fnd_profile_option_values fpov, fnd_profile_options fpo
            where fpov.profile_option_id = fpo.profile_option_id
            and fpo.profile_option_name like 'XLA_MO_SECURITY_PROFILE_LEVEL'
            and fpov.level_id = 10004 -- user level
            and fpov.level_value = p_user_id;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END IF;

    IF l_reg_sec_profile <> 0 THEN
        RETURN l_reg_sec_profile;
    END IF;

    BEGIN
        --Get the security profile value set up for the
        --iReceivables Registration responsibility
        select fpov.profile_option_value
        into l_reg_sec_profile
        from   fnd_profile_option_values fpov, fnd_profile_options fpo
        where fpov.profile_option_id = fpo.profile_option_id
        and fpo.profile_option_name like 'XLA_MO_SECURITY_PROFILE_LEVEL'
        and fpov.level_id = 10003 -- responsibility level
        and fpov.level_value_application_id = 222
        and fpov.level_value = p_resp_id; -- Resp Id of ARI_REGISTER_RESP- iReceivables Registration Responsibility
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            --Get the security profile set up at the site level
            select fpov.profile_option_value
            into l_reg_sec_profile
	        from   fnd_profile_option_values fpov, fnd_profile_options fpo
	        where fpov.profile_option_id = fpo.profile_option_id
	        and fpo.profile_option_name like 'XLA_MO_SECURITY_PROFILE_LEVEL'
	        and fpov.level_id = 10001; -- Site level

            return l_reg_sec_profile;
    END;

    return l_reg_sec_profile;

EXCEPTION
    WHEN OTHERS THEN
        return l_reg_sec_profile;
END  GetRegSecurityProfile;

/*=======================================================================
 | PROCEDURE    ValidateRequestedCustomer
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
PROCEDURE ValidateRequestedCustomer (p_customer_id  IN VARCHAR2,
				                     x_return_status  OUT NOCOPY VARCHAR2)
---------------------------------------------------------------------------
IS
	l_count_sites	NUMBER;
BEGIN
	x_return_status := 'N';

	SELECT count(cust_acct_site_id)
	INTO l_count_sites
	FROM hz_cust_acct_sites hcas
	WHERE hcaS.cust_account_id = p_customer_id;

	IF l_count_sites > 0 THEN
		x_return_status := 'Y';
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'N';
END ValidateRequestedCustomer;

/*=======================================================================
 | PROCEDURE    GetRequestedRespId
 |
 | DESCRIPTION
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
---------------------------------------------------------------------------
FUNCTION GetRequestedRespId (p_role_name  IN VARCHAR2)
        RETURN VARCHAR2
---------------------------------------------------------------------------
IS
	l_resp_id  VARCHAR2(30) := 0;
BEGIN

	SELECT to_char(resp.responsibility_id)
    INTO   l_resp_id
    FROM   fnd_responsibility_vl resp, wf_roles role
    WHERE  role.name = p_role_name
    AND    resp.responsibility_name  = role.display_name;

	RETURN l_resp_id;

EXCEPTION
	WHEN OTHERS THEN
		RETURN l_resp_id;
END GetRequestedRespId;


END ARI_SELF_REGISTRATION_PKG;

/
