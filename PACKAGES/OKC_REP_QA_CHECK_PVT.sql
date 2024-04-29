--------------------------------------------------------
--  DDL for Package OKC_REP_QA_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_QA_CHECK_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVREPQACHKS.pls 120.0.12010000.2 2013/04/05 15:27:58 harchand ship $ */

  ---------------------------------------------------------------------------
  -- TYPE Definitions
  ---------------------------------------------------------------------------
  -- Contracts business events codes TBL Type
  SUBTYPE EVENT_TBL_TYPE IS OKC_TERMS_QA_GRP.BUSDOCDATES_TBL_TYPE;
  ---------------------------------------------------------------------------
  -- Global VARIABLES
  ---------------------------------------------------------------------------
    G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_REP_QA_CHECK_PVT';
    G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
    G_MODULE               CONSTANT   VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
 ------------------------------------------------------------------------------
 G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
 G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
 G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
 G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
 G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
 G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
 G_REP_QA_TYPE                CONSTANT   VARCHAR2(30)  := 'REPOSITORY';
 G_QA_LOOKUP                  CONSTANT   VARCHAR2(30)  := 'OKC_TERM_QA_LIST';

 G_QA_STS_SUCCESS             CONSTANT   varchar2(1) := OKC_TERMS_QA_GRP.G_QA_STS_SUCCESS;
 G_QA_STS_ERROR               CONSTANT   varchar2(1) := OKC_TERMS_QA_GRP.G_QA_STS_ERROR;
 G_QA_STS_WARNING             CONSTANT   varchar2(1) := OKC_TERMS_QA_GRP.G_QA_STS_WARNING;


 G_OKC                        CONSTANT VARCHAR2(3)  :=  'OKC';
 G_NORMAL_QA                  CONSTANT VARCHAR2(30) :=  'NORMAL';

                           -- QA Checks --
 -- Check being performed for repository
 G_CHECK_REP_NO_EXT_PARTY      CONSTANT  VARCHAR2(40) := 'CHECK_REP_NO_EXTERNAL_PARTY';
 G_CHECK_REP_NO_EFF_DATE       CONSTANT  VARCHAR2(40) := 'CHECK_REP_NO_EFF_DATE';
 G_CHECK_REP_EXPIRED       CONSTANT  VARCHAR2(40) := 'CHECK_REP_EXPIRED';
 G_CHECK_REP_INV_CONTRACT_TYPE CONSTANT  VARCHAR2(40) := 'CHECK_REP_INV_CONTRACT_TYPE';
 G_CHECK_REP_INV_EXT_PARTY     CONSTANT  VARCHAR2(40) := 'CHECK_REP_INV_EXTERNAL_PARTY';
 G_CHECK_REP_INV_CONTACT       CONSTANT  VARCHAR2(40) := 'CHECK_REP_INV_CONTACT';
 G_CHECK_REP_INV_RISK_EVENT    CONSTANT  VARCHAR2(40) := 'CHECK_REP_INV_RISK_EVENT';
 G_CHECK_REP_INV_CONTACT_ROLE  CONSTANT  VARCHAR2(40) := 'CHECK_REP_INV_CONTACT_ROLE';
                           -- QA Error messages --
 G_OKC_REP_NO_EXT_PARTY        CONSTANT VARCHAR2(30) := 'OKC_REP_NO_EXTERNAL_PARTY';
 G_OKC_REP_NO_EFF_DATE         CONSTANT VARCHAR2(30) := 'OKC_REP_NO_EFF_DATE';
 G_OKC_REP_EXPIRED         CONSTANT VARCHAR2(30) := 'OKC_REP_EXPIRED';
 G_OKC_REP_INV_CONTRACT_TYPE   CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTRACT_TYPE';
 G_OKC_REP_INV_EXT_PARTY       CONSTANT VARCHAR2(30) := 'OKC_REP_INV_EXTERNAL_PARTY';
 G_OKC_REP_INV_CONTACT         CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTACT';
 G_OKC_REP_INV_RISK_EVENT      CONSTANT VARCHAR2(30) := 'OKC_REP_INV_RISK_EVENT';
 G_OKC_REP_INV_CONTACT_ROLE    CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTACT_ROLE';
                            -- QA Suggestion messages --
 G_OKC_REP_NO_EXT_PARTY_S      CONSTANT VARCHAR2(50) := 'OKC_REP_NO_EXTERNAL_PARTY_S';
 G_OKC_REP_NO_EFF_DATE_S       CONSTANT VARCHAR2(50) := 'OKC_REP_NO_EFF_DATE_S';
 G_OKC_REP_EXPIRED_S       CONSTANT VARCHAR2(50) := 'OKC_REP_EXPIRED_S';
 G_OKC_REP_INV_CONTRACT_TYPE_S CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTRACT_TYPE_S';
 G_OKC_REP_INV_EXT_PARTY_S     CONSTANT VARCHAR2(30) := 'OKC_REP_INV_EXTERNAL_PARTY_S';
 G_OKC_REP_INV_CONTACT_S       CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTACT_S';
 G_OKC_REP_INV_RISK_EVENT_S    CONSTANT VARCHAR2(30) := 'OKC_REP_INV_RISK_EVENT_S';
 G_OKC_REP_INV_CONTACT_ROLE_S  CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTACT_ROLE_S';
                           -- QA Error short descriptions --
 G_OKC_REP_NO_EXT_PARTY_SD     CONSTANT VARCHAR2(30) := 'OKC_REP_NO_EXTERNAL_PARTY_SD';
 G_OKC_REP_NO_EFF_DATE_SD      CONSTANT VARCHAR2(30) := 'OKC_REP_NO_EFF_DATE_SD';
 G_OKC_REP_EXPIRED_SD      CONSTANT VARCHAR2(30) := 'OKC_REP_EXPIRED_SD';
 G_OKC_REP_INV_CONTRACT_TYPE_SD CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTRACT_TYPE_SD';
 G_OKC_REP_INV_EXT_PARTY_SD    CONSTANT VARCHAR2(30) := 'OKC_REP_INV_EXTERNAL_PARTY_SD';
 G_OKC_REP_INV_CONTACT_SD      CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTACT_SD';
 G_OKC_REP_INV_RISK_EVENT_SD   CONSTANT VARCHAR2(30) := 'OKC_REP_INV_RISK_EVENT_SD';
 G_OKC_REP_INV_CONTACT_ROLE_SD CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTACT_ROLE_SD';
                            -- QA Title messages --
 G_OKC_REP_NO_EXT_PARTY_T      CONSTANT VARCHAR2(50) := 'OKC_REP_NO_EXTERNAL_PARTY_T';
 G_OKC_REP_NO_EFF_DATE_T       CONSTANT VARCHAR2(50) := 'OKC_REP_NO_EFF_DATE_T';
 G_OKC_REP_EXPIRED_T       CONSTANT VARCHAR2(50) := 'OKC_REP_EXPIRED_T';
 G_OKC_REP_INV_CONTRACT_TYPE_T CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTRACT_TYPE_T';
 G_OKC_REP_INV_EXT_PARTY_T     CONSTANT VARCHAR2(30) := 'OKC_REP_INV_EXTERNAL_PARTY_T';
 G_OKC_REP_INV_CONTACT_T       CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTACT_T';
 G_OKC_REP_INV_RISK_EVENT_T    CONSTANT VARCHAR2(30) := 'OKC_REP_INV_RISK_EVENT_T';
 G_OKC_REP_INV_CONTACT_ROLE_T  CONSTANT VARCHAR2(30) := 'OKC_REP_INV_CONTACT_ROLE_T';

                             -- Contract events - deliverables integration
  G_CONTRACT_EXPIRE_EVENT      CONSTANT   VARCHAR2(200) := 'CONTRACT_EXPIRE';
  G_CONTRACT_EFFECTIVE_EVENT   CONSTANT   VARCHAR2(200) := 'CONTRACT_EFFECTIVE';

                             -- Required for Contract not found error message
  G_INVALID_CONTRACT_ID_MSG    CONSTANT   VARCHAR2(200) := 'OKC_REP_INVALID_CONTRACT_ID';
  G_CONTRACT_ID_TOKEN          CONSTANT   VARCHAR2(200) := 'CONTRACT_ID';
  G_PARTY_NAME_TOKEN           CONSTANT   VARCHAR2(200) := 'PARTY_NAME';
  G_CONTACT_NAME_TOKEN         CONSTANT   VARCHAR2(200) := 'CONTACT_NAME';
  G_CONTRACT_TYPE_TOKEN        CONSTANT   VARCHAR2(200) := 'CONTRACT_TYPE';
  G_CONTACT_ROLE_TOKEN         CONSTANT   VARCHAR2(200) := 'CONTACT_ROLE';
  G_RISK_EVENT_TOKEN           CONSTANT   VARCHAR2(200) := 'RISK_EVENT';

    -- Party Role codes
  G_PARTY_ROLE_INTERNAL        CONSTANT   VARCHAR2(30) :=  'INTERNAL_ORG';
  G_PARTY_ROLE_PARTNER         CONSTANT   VARCHAR2(30) :=  'PARTNER_ORG';
  G_PARTY_ROLE_CUSTOMER        CONSTANT   VARCHAR2(30) :=  'CUSTOMER_ORG';
  G_PARTY_ROLE_SUPPLIER        CONSTANT   VARCHAR2(30) :=  'SUPPLIER_ORG';

  TYPE okc_doc_qa_lists_rec_type IS RECORD (
              qa_code                        OKC_DOC_QA_LISTS.QA_CODE%TYPE,
              severity_flag                  OKC_DOC_QA_LISTS.severity_flag%TYPE,
              enable_qa_yn                   OKC_DOC_QA_LISTS.enable_qa_yn%TYPE);

  TYPE okc_doc_qa_lists_tbl_type IS TABLE OF okc_doc_qa_lists_rec_type
    INDEX BY BINARY_INTEGER;

  -----------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

-- Start of comments
--API name      : perform_contract_qa_check
--Type          : Private.
--Function      : This API performs QA check on a Repository Contract. The API check for:
--                1. Check contract for no external party (Warning)
--                2. Check contract for no effective date (Error)
--                3. Check contract for invalid contract type
--                4. Check contract for invalid external party type
--                5. Check contract for invalid contact
--                6. Check contract for invalid Risk Event
--                7. Check contract for invalid Contact Role
--                8. Calls OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa to qa check the
--                   deliverables.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract to be QA checked
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--              : x_qa_return_status    OUT  VARCHAR2 (1)
--                    QA Check return status. Possible values are S, W, E
--              : x_sequence_id         OUT  NUMBER
--                    Sequence id of the qa check errors in OKC_QA_ERRORS_T table
-- Note         :
-- End of comments

    PROCEDURE perform_contract_qa_check (
           p_api_version           IN NUMBER,
           p_init_msg_list         IN VARCHAR2,
           p_contract_id           IN NUMBER,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_qa_return_status      OUT NOCOPY VARCHAR2,
           x_sequence_id           OUT NOCOPY NUMBER);


-- Start of comments
--API name      : insert_deliverables_qa_checks
--Type          : Private.
--Function      : This API inserts QA check list of Deliverables for the specified
--                Contract Type into the table OKC_DOC_QA_LISTS
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Required
--              : p_contract_type       IN NUMBER       Required
--                   Contract Type for which the QA checkes to be added
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
-- Note         :
-- End of comments

    PROCEDURE insert_deliverables_qa_checks (
           p_api_version           IN NUMBER,
           p_init_msg_list         IN VARCHAR2,
           p_contract_type           IN VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2,
           x_return_status         OUT NOCOPY VARCHAR2);


END OKC_REP_QA_CHECK_PVT;

/
