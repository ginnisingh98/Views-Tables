--------------------------------------------------------
--  DDL for Package IBY_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_ASSIGN_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyasgns.pls 120.2.12010000.3 2009/06/24 08:43:18 jnallam ship $*/

 --
 --
 TYPE updateDocAttributesRec IS RECORD (
     payment_request_id
         IBY_DOCS_PAYABLE_ALL.payment_service_request_id%TYPE,
     int_bank_acct_id
         IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE,
     pay_profile_id
         IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE,
     bank_acct_flag
         BOOLEAN,
     pay_profile_flag
         BOOLEAN
     );

 --
 -- Used to update of the IBY_DOCS_PAYABLE_ALL table.
 --
 --TYPE updateDocsTabType IS TABLE OF updateDocAttributesRec
 --    INDEX BY BINARY_INTEGER;

 --
 --
 --
 TYPE unassignedDocRec IS RECORD (
     document_id
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     payment_currency_code
         IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     org_id
         IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     payment_method_code
         IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     calling_app_id
         IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE,
     calling_app_doc_id1
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref1%TYPE,
     calling_app_doc_id2
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref2%TYPE,
     calling_app_doc_id3
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref3%TYPE,
     calling_app_doc_id4
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref4%TYPE,
     calling_app_doc_id5
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref5%TYPE,
     pay_proc_ttype_cd
         IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE,
     int_bank_acct_id
         IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE := -1,
     pay_profile_id
         IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE := -1
     );

 TYPE unassignedDocsTabType IS TABLE OF unassignedDocRec
     INDEX BY BINARY_INTEGER;

 --
 --
 TYPE assignCriteriaType IS RECORD (
     document_id
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     calling_app_id
         IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE,
     calling_app_doc_id1
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref1%TYPE,
     calling_app_doc_id2
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref2%TYPE,
     calling_app_doc_id3
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref3%TYPE,
     calling_app_doc_id4
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref4%TYPE,
     calling_app_doc_id5
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref5%TYPE,
     pay_proc_ttype_cd
         IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE,
     int_bank_acct_id
         IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE,
     payment_profile_id
         IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE,
     payment_currency
         IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     payment_method
         IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     payment_format
         IBY_DOCS_PAYABLE_ALL.payment_format_code%TYPE,
     org_id
         IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     org_type
         IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     payment_date
         IBY_DOCS_PAYABLE_ALL.payment_date%TYPE,
     ext_payee_id
         IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE
     );

 --
 -- Table of assignment criteria.
 --
 TYPE assignCriteriaTabType IS TABLE OF assignCriteriaType
     INDEX BY BINARY_INTEGER;

 --
 -- Table of bank accounts. Used by dummy CE API is available
 --
 TYPE bankAccounts IS TABLE OF IBY_DOCS_PAYABLE_ALL.
     internal_bank_account_id%TYPE INDEX BY BINARY_INTEGER;

 --
 --
 --
 TYPE setDocAttributesRec IS RECORD (
     doc_id
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     ca_id
         IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE,
     ca_doc_id1
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref1%TYPE,
     ca_doc_id2
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref2%TYPE,
     ca_doc_id3
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref3%TYPE,
     ca_doc_id4
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref4%TYPE,
     ca_doc_id5
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref5%TYPE,
     pp_tt_cd
         IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE,
     int_bank_acct_id
         IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE,
     pay_profile_id
         IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE,
     status
         IBY_DOCS_PAYABLE_ALL.document_status%TYPE
     );

 --
 -- Used to update of the IBY_DOCS_PAYABLE_ALL table.
 --
 TYPE setDocAttribsTabType IS TABLE OF setDocAttributesRec
     INDEX BY BINARY_INTEGER;


/*--------------------------------------------------------------------
 | NAME:
 |     performAssignments
 |
 | PURPOSE:
 |
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
 PROCEDURE performAssignments(
     p_payment_request_id IN IBY_PAY_SERVICE_REQUESTS.
                                 payment_service_request_id%type,
     x_return_status      IN OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getRequestAttributes
 |
 | PURPOSE:
 |
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
 PROCEDURE getRequestAttributes(
     p_payReqId   IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE,
     x_caPayReqCd IN OUT NOCOPY
         IBY_PAY_SERVICE_REQUESTS.call_app_pay_service_req_code%TYPE,
     x_caId       IN OUT NOCOPY
         IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     x_bankAcctId IN OUT NOCOPY
         IBY_PAY_SERVICE_REQUESTS.internal_bank_account_id%TYPE,
     x_profileId  IN OUT NOCOPY
         IBY_PAY_SERVICE_REQUESTS.payment_profile_id%TYPE
     );

/*--------------------------------------------------------------------
 | NAME:
 |     updateDocumentAssignments
 |
 | PURPOSE:
 |
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
 PROCEDURE updateDocumentAssignments(
     p_updateDocsRec IN IBY_ASSIGN_PUB.updateDocAttributesRec
     );

/*--------------------------------------------------------------------
 | NAME:
 |     dummyCEAPI
 |
 | PURPOSE:
 |
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
 PROCEDURE dummyCEAPI(
     p_payCurrency   IN IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     p_pmtDate       IN IBY_DOCS_PAYABLE_ALL.payment_date%TYPE,
     p_OrgID         IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     x_bankAccounts  IN OUT NOCOPY IBY_ASSIGN_PUB.bankAccounts
     );

/*--------------------------------------------------------------------
 | NAME:
 |     setDocumentAssignments
 |
 | PURPOSE:
 |
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
 PROCEDURE setDocumentAssignments(
     p_setDocAttribsTab IN IBY_ASSIGN_PUB.setDocAttribsTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getProfileFromProfileDrivers
 |
 | PURPOSE:
 |
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
 FUNCTION getProfileFromProfileDrivers(
     p_pmt_method_cd     IN IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     p_org_id            IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     p_org_type          IN IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     p_pmt_currency      IN IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     p_int_bank_acct_id  IN IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE
     ) RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     getProfileFromPayeeFormat
 |
 | PURPOSE:
 |
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
 FUNCTION getProfileFromPayeeFormat(
     p_payee_id            IN IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE
     ) RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     finalizeStatuses
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalizeStatuses(
     p_payReqID IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE,
     x_req_status  IN OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     updateRequestStatus
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE updateRequestStatus(
     p_payReqID    IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE,
     x_req_status  IN OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     dummyAsgnHook
 |
 | PURPOSE:
 |     Dummy hook; To be used for testing purposes.
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE dummyAsgnHook(
     x_unassgnDocsTab IN OUT NOCOPY IBY_ASSIGN_PUB.unassignedDocsTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     populateDocAttributes
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE populateDocAttributes(
     p_hookAsgnDocsTab  IN            IBY_ASSIGN_PUB.unassignedDocsTabType,
     x_setDocAttribsTab IN OUT NOCOPY IBY_ASSIGN_PUB.setDocAttribsTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     raiseBizEvents
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE raiseBizEvents(
     p_payreq_id          IN            VARCHAR2,
     p_cap_payreq_id      IN            VARCHAR2,
     p_cap_id             IN            NUMBER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getXMLClob
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION getXMLClob(
     p_payreq_id     IN VARCHAR2
     )
     RETURN CLOB;

END IBY_ASSIGN_PUB;

/
