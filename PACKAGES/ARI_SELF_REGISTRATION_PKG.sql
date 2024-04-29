--------------------------------------------------------
--  DDL for Package ARI_SELF_REGISTRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARI_SELF_REGISTRATION_PKG" AUTHID CURRENT_USER AS
/* $Header: ARISREGS.pls 120.11.12010000.2 2010/04/30 11:11:53 avepati ship $ */

/*=======================================================================+
 |  Types
 +=======================================================================*/

TYPE GenCursorRef IS REF CURSOR;

TYPE TokenRec IS RECORD (
     token_name   VARCHAR2(30),
     token_value  VARCHAR2(1000));

TYPE TokensTable IS TABLE OF TokenRec
  INDEX BY BINARY_INTEGER;

TYPE VerifyAccessRec is RECORD
(
    question VARCHAR2(2000),
    expected_answer VARCHAR2(2000)
);

TYPE VerifyAccessTable IS TABLE OF VerifyAccessRec
    INDEX BY BINARY_INTEGER;

TYPE QuestionsArray IS TABLE OF VARCHAR2(2000)
    INDEX BY PLS_INTEGER;

TYPE AnswersArray IS TABLE OF VARCHAR2(2000)
    INDEX BY PLS_INTEGER;

/*=======================================================================+
 |  Procedures and Functions
 +=======================================================================*/
---------------------------------------------------------------------------
PROCEDURE ResolveCustomerAccessRequest(p_customer_id                 IN  VARCHAR2,
                                       x_cust_acct_type               OUT NOCOPY  VARCHAR2,
                                       x_result_code                  OUT NOCOPY  NUMBER);
---------------------------------------------------------------------------

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
                                 x_return_status	   OUT NOCOPY  VARCHAR2,
                                 x_msg_count           OUT NOCOPY  NUMBER,
                                 x_msg_data            OUT NOCOPY  VARCHAR2);
---------------------------------------------------------------------------

--------------------------------------------------------------------------
PROCEDURE OpenCustAcctCur(p_customer_id     IN  VARCHAR2,
			  p_cust_acct_cur           OUT NOCOPY  GenCursorRef);
--------------------------------------------------------------------------

--------------------------------------------------------------------------
PROCEDURE GenerateAccessVerifyQuestion(
                                   p_registration_id         IN  NUMBER,
                                   p_client_ip_address       IN  VARCHAR2,
                                   p_customer_id             IN  VARCHAR2,
                                   p_customer_site_use_id    IN  VARCHAR2);

---------------------------------------------------------------------------
PROCEDURE GenCustDetailAccessQuestion(
                                   p_client_ip_address       IN  VARCHAR2,
                                   p_customer_id             IN  VARCHAR2);
---------------------------------------------------------------------------
PROCEDURE ClearRegistrationTable;
--------------------------------------------------------------------------
/*FUNCTION ValidateAnswer( p_answer IN VARCHAR2,
                         p_reg_access_verify_id IN NUMBER)
RETURN VARCHAR2;*/
--------------------------------------------------------------------------
PROCEDURE RemoveRoleAccess(p_person_party_id    IN  VARCHAR2,
                           p_customer_id        IN  VARCHAR2,
                           p_cust_acct_site_id  IN  VARCHAR2,
                           x_return_status      OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------
FUNCTION GetPartyRelationshipId (p_user_id      IN VARCHAR2,
                                 p_customer_id  IN VARCHAR2)
RETURN VARCHAR2;
--------------------------------------------------------------------------
FUNCTION GetCustomerAcctNumber (p_cust_account_id   IN VARCHAR2)
        RETURN VARCHAR2;
--------------------------------------------------------------------------
FUNCTION CheckUserIsAdmin (p_user_id   IN VARCHAR2)
        RETURN VARCHAR2;
--------------------------------------------------------------------------
FUNCTION CreatePersonParty(p_subscription_guid in raw,
                            p_event in out NOCOPY WF_EVENT_T) RETURN VARCHAR2;
--------------------------------------------------------------------------
FUNCTION AddCustomerAccess(p_subscription_guid in raw,
                           p_event in out NOCOPY WF_EVENT_T)
        RETURN VARCHAR2;
--------------------------------------------------------------------------
PROCEDURE RegisterUser( p_event IN OUT NOCOPY WF_EVENT_T,
                                 p_person_party_id IN OUT NOCOPY varchar2 );
--------------------------------------------------------------------------
PROCEDURE RaiseAddCustAccessEvent (p_person_party_id    IN VARCHAR2,
                                   p_customer_id        IN VARCHAR2,
                                   p_cust_site_use_id   IN VARCHAR2 DEFAULT NULL,
                                   p_cust_acct_type     IN VARCHAR2,
                                   p_first_name         IN VARCHAR2,
                                   p_last_name          IN VARCHAR2,
                                   p_middle_name        IN VARCHAR2,
                                   p_pre_name_adjunct   IN VARCHAR2,
                                   p_person_suffix      IN VARCHAR2);
--------------------------------------------------------------------------
FUNCTION GetRegSecurityProfile(p_user_id IN VARCHAR2 DEFAULT NULL,
                               p_resp_id IN VARCHAR2)
         RETURN VARCHAR2;
--------------------------------------------------------------------------
PROCEDURE ValidateRequestedCustomer (p_customer_id  IN VARCHAR2,
				                     x_return_status  OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------
FUNCTION GetRequestedRespId (p_role_name  IN VARCHAR2)
        RETURN VARCHAR2;
--------------------------------------------------------------------------
END ARI_SELF_REGISTRATION_PKG;

/
