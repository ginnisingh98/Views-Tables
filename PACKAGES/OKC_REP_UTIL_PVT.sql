--------------------------------------------------------
--  DDL for Package OKC_REP_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVREPUTILS.pls 120.10.12010000.3 2012/08/17 09:43:22 harchand ship $ */

  ------------------------------------------------------------------------------
    -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------

  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_REP_UTIL_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKC';
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';

  G_OBJECT_NAME                CONSTANT   VARCHAR2(200) := 'OKC_REP_CONTRACT';

  G_STATUS_PENDING_APPROVAL    CONSTANT   VARCHAR2(30) :=  'PENDING_APPROVAL';
  G_STATUS_APPROVED            CONSTANT   VARCHAR2(30) :=  'APPROVED';
  G_STATUS_REJECTED            CONSTANT   VARCHAR2(30) :=  'REJECTED';
  G_STATUS_DRAFT               CONSTANT   VARCHAR2(30) :=  'DRAFT';

  G_ACTION_SUBMITTED           CONSTANT   VARCHAR2(30) :=  'SUBMITTED';

  -- Contract Type Intents
  G_INTENT_BUY                 CONSTANT   VARCHAR2(30) := 'B';

  -- Party validation modes
  G_P_MODE_IMPORT              CONSTANT   VARCHAR2(30) :=  'IMPORT';
  G_P_MODE_AUTHORING           CONSTANT   VARCHAR2(30) :=  'AUTHORING';

  -- Party Role codes
  G_PARTY_ROLE_INTERNAL        CONSTANT   VARCHAR2(30) :=  'INTERNAL_ORG';
  G_PARTY_ROLE_PARTNER         CONSTANT   VARCHAR2(30) :=  'PARTNER_ORG';
  G_PARTY_ROLE_CUSTOMER        CONSTANT   VARCHAR2(30) :=  'CUSTOMER_ORG';
  G_PARTY_ROLE_SUPPLIER        CONSTANT   VARCHAR2(30) :=  'SUPPLIER_ORG';

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';

  -- Error Types for import errors table
  G_IMP_CONTRACT_ERROR              CONSTANT   VARCHAR2(50) :=  'CONTRACT';
  G_IMP_PARTY_ERROR                 CONSTANT   VARCHAR2(50) :=  'PARTY';
  G_IMP_DOCUMENT_ERROR              CONSTANT   VARCHAR2(50) :=  'DOCUMENT';

  -- Date Format
  G_IMP_DATE_FORMAT                 CONSTANT    VARCHAR2(50) := 'MM/DD/YYYY';

  -- Number Format
  G_IMP_NUMBER_FORMAT               CONSTANT    VARCHAR2(50) := '999999999999.99';

  G_SELECT_ACCESS_LEVEL             CONSTANT   VARCHAR2(17) :=  'OKC_REP_AU_SELECT';
  G_UPDATE_ACCESS_LEVEL             CONSTANT   VARCHAR2(17) :=  'OKC_REP_AU_UPDATE';

  G_FND_GRANTS_VIEW_ACCESS          CONSTANT   VARCHAR2(4) :=  'VIEW';
  G_FND_GRANTS_UPDATE_ACCESS        CONSTANT   VARCHAR2(6) :=  'UPDATE';

  G_FND_GRANTEE_TYPE_USER           CONSTANT   VARCHAR2(4) :=  'USER';
  G_FND_GRANTEE_TYPE_GROUP          CONSTANT   VARCHAR2(5) :=  'GROUP';

  G_FUNC_OKC_REP_ADMINISTRATOR      CONSTANT   VARCHAR2(21) :=  'OKC_REP_ADMINISTRATOR';
  G_FUNC_OKC_REP_USER_FUNC          CONSTANT   VARCHAR2(17) :=  'OKC_REP_USER_FUNC';
  G_FUNC_OKC_REP_SALES_WB_USER      CONSTANT   VARCHAR2(30) :=  'OKC_REP_SALES_WORKBENCH_USER';

  -- Sales quote constants
  G_SALES_QUOTE_SEC_PROFILE         CONSTANT   VARCHAR2(30) := 'ASO_ENABLE_SECURITY_CHECK';
  G_SALES_QUOTE_UPDATE_ACCESS       CONSTANT   VARCHAR2(6) :=  'UPDATE';

-- Acq Plan messages cleanup
  G_REP_CONTRACT_TYPE_PREFIX        CONSTANT   VARCHAR2(4) := 'REP_';

  G_REP_MSG_ENTITY_HDR              CONSTANT   VARCHAR2(30):= 'REP_MSG_ENTITY_HDR';
  G_REP_MSG_ENTITY_DEL              CONSTANT   VARCHAR2(30):= 'REP_MSG_ENTITY_DEL';


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  -- Start of comments
  --API name      : check_contract_access_external
  --Type          : Private.
  --Function      : Checks access to a external contract by the current user.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Required
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contract to be checked
  --              : p_contract_type       IN VARCHAR2       Required
  --                   Type of the contract to be checked
  --OUT           : x_has_access          OUT  VARCHAR2(1)
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE check_contract_access_external(
    p_api_version     IN  NUMBER,
    p_init_msg_list   IN VARCHAR2,
    p_contract_id     IN  NUMBER,
    p_contract_type   IN  VARCHAR2,
    x_has_access      OUT NOCOPY  VARCHAR2,
    x_msg_data        OUT NOCOPY  VARCHAR2,
    x_msg_count       OUT NOCOPY  NUMBER,
    x_return_status   OUT NOCOPY  VARCHAR2);

  -- Start of comments
  --API name      : check_contract_access
  --Type          : Private.
  --Function      : Checks access to a contract by the current user.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contract whose access to be checked
  --              : p_function_name       IN VARCHAR2       Required
  --                   Name of the function whose access to be checked. Possible values OKC_REP_SELECT and OKC_REP_UPDATE
  --OUT           : x_has_access          OUT  VARCHAR2(1)
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE check_contract_access(
      p_api_version     IN  NUMBER,
      p_init_msg_list   IN VARCHAR2,
      p_contract_id     IN  NUMBER,
      p_function_name   IN  VARCHAR2,
      x_has_access      OUT NOCOPY  VARCHAR2,
      x_msg_data        OUT NOCOPY  VARCHAR2,
      x_msg_count       OUT NOCOPY  NUMBER,
      x_return_status   OUT NOCOPY  VARCHAR2);

-- Start of comments
  --API name      : Function has_contract_access_external
  --Type          : Private.
  --Function      : Checks access to a contract by the current user for external contracts.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_contract_id         IN NUMBER       Required
  --                   Id of the contract that is being checked
  --              : p_contract_type       IN VARCHAR2       Required
  --                   Contract type for contract being chacked
  --OUT           : Return Y if the current user has access to the contracts, else returns N
  -- End of comments
  FUNCTION has_contract_access_external(
      p_contract_id     IN  NUMBER,
      p_contract_type   IN  VARCHAR2
    ) RETURN VARCHAR2;

-- Start of comments
  --API name      : has_contract_access
  --Type          : Private.
  --Function      : Checks access to a contract by the current user.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contract whose access to be checked
  --              : p_function_name       IN VARCHAR2       Required
  --                   Name of the function whose access to be checked. Possible values OKC_REP_SELECT and OKC_REP_UPDATE
  --OUT           : Return Y if the current user has access to the contracts, else returns N
  -- End of comments
  FUNCTION has_contract_access(
      p_contract_id     IN  NUMBER,
      p_function_name   IN  VARCHAR2
  ) RETURN VARCHAR2;


  /**
   * This procedure changes status of a contract and logs the user action that
   * caused this into database tables OKC_REP_CON_STATUS_HIST.
   * @param IN p_contract_id  Id of the contract whose status to be changed
   * @param IN p_contract_version Version number of the contract whose status to be changed
   * @param IN p_status_code New status code to be set on the contract
   * @param IN p_user_id Id of the user who caused this change
   * @param IN p_note User entered notes in the notification while approving or rejecting the contract
   */
  PROCEDURE change_contract_status(
      p_api_version         IN NUMBER,
      p_init_msg_list       IN VARCHAR2,
      p_contract_id         IN NUMBER,
      p_contract_version    IN NUMBER,
      p_status_code         IN VARCHAR2,
      p_user_id             IN NUMBER:=NULL,
      p_note                IN VARCHAR2:=NULL,
    x_msg_data              OUT NOCOPY  VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_return_status       OUT NOCOPY  VARCHAR2);

 -- Start of comments
 --API name      : add_approval_hist_record
 --Type          : Private.
 --Function      : Inserts a record into table OKC_REP_CON_APPROVALS.
 --Pre-reqs      : None.
 --Parameters    :
 --IN            : p_api_version         IN NUMBER       Required
 --              : p_init_msg_list       IN VARCHAR2     Optional
 --                   Default = FND_API.G_FALSE
 --              : p_contract_id         IN NUMBER       Required
 --                   Contract ID of the approval history record
 --              : p_contract_version    IN VARCHAR2       Required
 --                   Contract version of the approval history record
 --              : p_action_code    IN OUT VARCHAR2       Optional
 --                   New action code to be set on the contract
 --              : p_user_id    IN VARCHAR2       Optional
 --                   Id of the user who caused this change
 --              : p_note    IN OUT VARCHAR2       Optional
 --                   User entered notes in the notification while approving or rejecting the contract
 --              : p_forward_user_id IN NUMBER Optional
 --		 : ID of the user to whom the notification is forwarded/Delegated
 --OUT           : x_return_status       OUT  VARCHAR2(1)
 --              : x_msg_count           OUT  NUMBER
 --              : x_msg_data            OUT  VARCHAR2(2000)
 -- End of comments
 PROCEDURE add_approval_hist_record(
      p_api_version     IN  NUMBER,
      p_init_msg_list   IN VARCHAR2,
      p_contract_id         IN NUMBER,
      p_contract_version    IN NUMBER,
      p_action_code         IN VARCHAR2,
      p_user_id             IN NUMBER:=NULL,
      p_note                IN VARCHAR2:=NULL,
      x_msg_data        OUT NOCOPY  VARCHAR2,
      x_msg_count       OUT NOCOPY  NUMBER,
      x_return_status   OUT NOCOPY  VARCHAR2,
      p_forward_user_id     IN NUMBER:=NULL);


 -- Start of comments
 --API name      : validate_contract_party
 --Type          : Private.
 --Function      : Validates a contract party
 --Pre-reqs      : None.
 --Parameters    :
 --IN            : p_api_version         IN NUMBER       Required
 --              : p_init_msg_list       IN VARCHAR2     Optional
 --                   Default = FND_API.G_FALSE
 --              : p_contract_id         IN NUMBER       Required
 --                   Contract ID of the party to be validated
 --              : p_intent    IN VARCHAR2       Required
 --                   Intent of the contract
 --              : p_party_role_code    IN OUT VARCHAR2       Optional
 --                   Role code of the contract party to be validated
 --              : p_party_role_txt    IN VARCHAR2       Optional
 --                   Role name of the contract party to be validated
 --              : p_party_id    IN OUT NUMBER       Optional
 --                   Id of the contract party to be validated
 --              : p_party_name    IN VARCHAR2       Required
 --                   Name of the contract party to be validated
 --              : p_location_id    IN NUMBER       Optional
 --                   Id of the location of the contract party to be validated
 --              : p_mode    IN VARCHAR2       Required
 --                   Mode of the validation. Possible values 'IMPORT' or 'AUTHORING'
 --OUT           : x_valid_party_flag       OUT  VARCHAR2(1)
 --              : x_error_code          OUT  VARCHAR2(100)
 --                   Possible error codes are;
 --                     ROLE_NOT_EXIST - Party role doesn't exist (Import module)
 --                     INV_ROLE_INTENT - Party role and Contract intent combination is invalid (Import module)
 --                     PARTY_NOT_EXIST - Party doesn't exist (Import module)
 --                     INV_CUST_ACCT - Customer party doesn't have any customer accounts (Import module)
 --                     PARTY_NOT_UNIQUE - Party in not unique in the Contract (Import and Authoring modules)
 --                     INV_ROLE_PARTY - Role and Party combination is invalid (Authoring module)
 --                     INV_ROLE_LOCATION - Role and Party Location combination is invalid (Authoring module)
 --              : x_return_status       OUT  VARCHAR2(1)
 --              : x_msg_count           OUT  NUMBER
 --              : x_msg_data            OUT  VARCHAR2(2000)
 -- End of comments
 PROCEDURE validate_contract_party(
      p_api_version              IN NUMBER,
      p_init_msg_list            IN VARCHAR2,
      p_contract_id              IN NUMBER,
      p_intent                   IN VARCHAR2 DEFAULT NULL,
      p_party_role_code          IN OUT NOCOPY VARCHAR2,
      p_party_role_txt           IN VARCHAR2 DEFAULT NULL,
      p_party_id                 IN OUT NOCOPY NUMBER,
      p_party_name               IN VARCHAR2,
      p_location_id              IN NUMBER DEFAULT NULL,
      p_mode                     IN VARCHAR2,
      x_valid_party_flag         OUT NOCOPY VARCHAR2,
      x_error_code               OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2);


 -- Start of comments
 --API name      : validate_party_contact
 --Type          : Private.
 --Function      : Validates a party contact
 --Pre-reqs      : None.
 --Parameters    :
 --IN            : p_api_version         IN NUMBER       Required
 --              : p_init_msg_list       IN VARCHAR2     Optional
 --                   Default = FND_API.G_FALSE
 --              : p_contract_id         IN NUMBER       Required
 --                   Contract ID of the party contact to be validated
 --              : p_party_role_code    IN VARCHAR2       Required
 --                   Role code of the party of the contact to be validated
 --              : p_party_id    IN    NUMBER       Required
 --                   Id of the contract party to be validated
 --              : p_contact_id    IN   NUMBER       Required
 --                   Id of the party contact to be validated
 --              : p_contact_name    IN   VARCHAR2       Required
 --                   Name of the party contact to be validated
 --              : p_contact_role_id    IN   NUMBER       Required
 --                   Id of the role of the party contact to be validated
 --OUT           : x_valid_contact_flag       OUT  VARCHAR2(1)
 --              : x_error_code          OUT  VARCHAR2(100)
 --                   Possible error codes are;
 --                     CONTACT_NOT_UNIQUE - Contact is not unique in the party
 --                     CONTACT_NOT_EXIST - Party and contact combination is invalid
 --              : x_return_status       OUT  VARCHAR2(1)
 --              : x_msg_count           OUT  NUMBER
 --              : x_msg_data            OUT  VARCHAR2(2000)
 -- End of comments
 PROCEDURE validate_party_contact(
      p_api_version              IN NUMBER,
      p_init_msg_list            IN VARCHAR2,
      p_contract_id              IN NUMBER,
      p_party_role_code          IN VARCHAR2,
      p_party_id                 IN NUMBER,
      p_contact_id               IN NUMBER,
      p_contact_name             IN VARCHAR2,
      p_contact_role_id          IN NUMBER,
      x_valid_contact_flag       OUT NOCOPY VARCHAR2,
      x_error_code               OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2);


  -- Start of comments
  --API name      : validate_import_parties
  --Type          : Private.
  --Function      : Validates contract parties during import
  --Pre-reqs      : Currently only called from repository import.
  --              : Contracts should be saved to the OKC_REP_IMP_PARTIES_T table
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_request_id         IN NUMBER       Required
  --                    Concurrent Program Request ID
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE validate_import_parties(
       p_api_version              IN NUMBER,
       p_init_msg_list            IN VARCHAR2,
       p_request_id               IN NUMBER,
       x_return_status            OUT NOCOPY VARCHAR2,
       x_msg_count                OUT NOCOPY NUMBER,
       x_msg_data                 OUT NOCOPY VARCHAR2);

  -- Start of comments
  --API name      : validate_import_documents
  --Type          : Private.
  --Function      : Validates the contract documents stored in the interface table
  --                in a concurrent program.
  --Pre-reqs      : Currently only called from repository import.
  --              : Contract documents should be saved to the OKC_REP_IMP_DOCUMENTS_T table
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_request_id         IN NUMBER       Required
  --                    Concurrent program request id
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE validate_import_documents(
       p_api_version              IN NUMBER,
       p_init_msg_list            IN VARCHAR2,
       p_request_id               IN NUMBER,
       x_return_status            OUT NOCOPY VARCHAR2,
       x_msg_count                OUT NOCOPY NUMBER,
       x_msg_data                 OUT NOCOPY VARCHAR2);

  -- Start of comments
  --API name      : validate_import_contracts
  --Type          : Private.
  --Function      : Validates contracts during import
  --Pre-reqs      : Currently only called from repository import.
  --              : Contracts should be saved to the OKC_REP_IMP_CONTRACTS_T table
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_request_id         IN NUMBER       Required
  --                    Concurrent Program Request ID
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE validate_import_contracts(
       p_api_version              IN NUMBER,
       p_init_msg_list            IN VARCHAR2,
       p_request_id               IN NUMBER,
       x_return_status            OUT NOCOPY VARCHAR2,
       x_msg_count                OUT NOCOPY NUMBER,
       x_msg_data                 OUT NOCOPY VARCHAR2);


  -- Start of comments
  --API name      : validate_and_insert_contracts
  --Type          : Private.
  --Function      : Validates contracts in the interface tables, and then insert
  --                the valid ones into production tables:
  --                okc_rep_contracts_all and okc_rep_contract_parties
  --                Note that contract documents are inserted in the Java layer after this
  --Pre-reqs      : Currently only called from repository import.
  --              : Contracts should be saved to the OKC_REP_IMP_CONTRACTS_T table
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_request_id         IN NUMBER       Required
  --                    Concurrent Program Request ID
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  --              : x_number_inserted     OUT NUMBER
  -- End of comments
  PROCEDURE validate_and_insert_contracts(
    p_api_version   IN  NUMBER,
    p_init_msg_list   IN  VARCHAR2,
    p_request_id    IN  NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    x_msg_count   OUT NOCOPY NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_number_inserted   OUT NOCOPY NUMBER);


  -- Start of comments
  --API name      : delete_import_contract
  --Type          : Private.
  --Function      : (1) Delete the imported contract and its parties
  --                by calling okc_rep_contract_process_pvt.delete_contract
  --                (2) Set the contract's valid_flag to 'N' in okc_rep_imp_contracts_t
  --                (3) Insert an error message in okc_rep_imp_errors_t
  --                This procedure does the cleanup due to an error adding attachments
  --                in the Java layer during repository import
  --Pre-reqs      : None
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_commit               IN VARCHAR2    Optional
  --                   Default = FND_API.G_FALSE
  --              : p_contract_id         IN NUMBER       Required
  --                    Contract ID that the error is from
  --              : p_imp_document_id     IN NUMBER       Required
  --                   okc_rep_imp_documents_t.imp_document_id
  --              : p_error_msg_txt  IN VARCHAR2       Required
  --                   Translated error message text
  --              : p_program_id                IN  NUMBER Required
  --                    Concurrent program ID
  --              : p_program_login_id          IN  NUMBER Required
  --                    Concurrent program login ID
  --              : p_program_app_id            IN  NUMBER Required
  --                    Concurrent program application ID
  --              : p_request_id                IN  NUMBER Required
  --                    Concurrent program request ID
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE delete_import_contract(
       p_api_version              IN NUMBER := 1.0,
       p_init_msg_list            IN VARCHAR2,
       p_commit                   IN VARCHAR2,
       p_contract_id              IN NUMBER,
       p_imp_document_id             IN NUMBER,
       p_error_msg_txt            IN VARCHAR2,
       p_program_id               IN NUMBER,
       p_program_login_id         IN NUMBER,
       p_program_app_id           IN NUMBER,
       p_request_id               IN NUMBER,
       x_return_status            OUT NOCOPY VARCHAR2,
       x_msg_count                OUT NOCOPY NUMBER,
       x_msg_data                 OUT NOCOPY VARCHAR2);

  -- Start of comments
  --API name      : Function get_csv_error_string
  --Type          : Private.
  --Function      : Returns one line in the CSV Error Report
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_imp_contract_id         IN NUMBER       Required
  --                   okc_rep_imp_contracts_t.imp_contract_id
  -- End of comments
  FUNCTION get_csv_error_string(
        p_api_version              IN NUMBER := 1.0,
        p_init_msg_list            IN VARCHAR2,
        p_imp_contract_id     IN  NUMBER
  ) RETURN VARCHAR2;


  -- Start of comments
  --API name      : Function get_csv_header_string
  --Type          : Private.
  --Function      : Returns the header in the csv file
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  -- End of comments
  FUNCTION get_csv_header_string(
      p_api_version              IN NUMBER,
       p_init_msg_list           IN VARCHAR2
  ) RETURN VARCHAR2;

  -- Start of comments
  --API name      : get_external_userlist
  --Type          : Private.
  --Function      : Returns the external user email addresses.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_document_id         IN NUMBER       Required
  --                   Id of the contract
  --             : p_document_type        IN VARCHAR2     Required
  --                   Contract type.
  --              : p_external_party_id   IN NUMBER       Required
  --                   External party ID
  --              : p_external_party_role IN VARCHAR2     Required
  --                   External party role.
  --OUT           : x_external_userlist   OUT  VARCHAR2(1)
  --                      external contact email addresses
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE get_external_userlist(
      p_api_version         IN  NUMBER,
      p_init_msg_list       IN VARCHAR2,
      p_document_id         IN  NUMBER,
      p_document_type       IN VARCHAR2,
      p_external_party_id   IN NUMBER,
      p_external_party_role IN VARCHAR2,
      x_msg_data            OUT NOCOPY  VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_return_status       OUT NOCOPY  VARCHAR2,
      x_external_userlist   OUT NOCOPY VARCHAR2);


  -- Start of comments
  --API name      : ok_to_commit
  --Type          : Private.
  --Function      : Returns the external user email addresses.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_doc_id              IN NUMBER       Required
  --                   Id of the contract
  --              : p_validation_string   IN VARCHAR2     Optional
  --                   Validation string
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  FUNCTION ok_to_commit(
      p_api_version       IN  Number,
      p_init_msg_list     IN  Varchar2,
      p_doc_id            IN  Number,
      p_validation_string IN  Varchar2 default NULL,
      x_return_status     OUT NOCOPY Varchar2,
      x_msg_data          OUT NOCOPY Varchar2,
      x_msg_count         OUT NOCOPY Number) RETURN VARCHAR2;

-- Start of comments
--API name      : purge_recent_contracts
--Type          : Private.
--Function      : Called from OKC_PURGE_PVT package to purge
--                contracts that are olner than p_num_days days
--Pre-reqs      : None.
--Parameters    :
--OUT           : errbuf  OUT NOCOPY VARCHAR2
--              : retcode OUT NOCOPY VARCHAR2
--IN            : p_num_days IN NUMBER
--Note          :
-- End of comments

  PROCEDURE purge_recent_contracts(
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_num_days IN NUMBER);

-- Start of comments
--API name      : can_update
--Type          : Private.
--Function      : Checks if user can update a contract
--Pre-reqs      : None.
--Parameters    :
--OUT           : Return Y if user is allowed to update contracts, N if not allowed
--Note          :
-- End of comments

  FUNCTION can_update RETURN VARCHAR2;


-- Start of comments
--API name      : is_sales_workbench
--Type          : Private.
--Function      : Checks if the current application is Sales Contracts Workbench or Contract Repository
--Pre-reqs      : None.
--Parameters    :
--OUT           : Return Y if it is Sales Contracts Workbench, otherwise returns N
--Note          :
-- End of comments

  FUNCTION is_sales_workbench RETURN VARCHAR2;



  -- Start of comments
  --API name      : insert_new_vendor_contact
  --Type          : Private.
  --Function      : Creates a new vendor contact and returns the newly created contact id.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_vendor_site_id         IN NUMBER       Required
  --                   Vendor site id of the contact
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contract for which the new contact being created
  --              : p_first_name       IN VARCHAR2     Required
  --                   First name of the contact
  --              : p_last_name         IN NUMBER       Required
  --                   Last name of the contact
  --              : p_area_code        IN VARCHAR2     Optional
  --                   Area code of the contact phone number.
  --              : p_phone   IN NUMBER       Optional
  --                   Phone number of the contact
  --              : p_email_address IN VARCHAR2     Optional
  --                   Email address of the contact.
  --OUT           : x_vendor_contact_id   OUT  VARCHAR2(1)
  --                   Vendor contact id
  -- End of comments
  PROCEDURE insert_new_vendor_contact(
      p_vendor_site_id                IN NUMBER,
      p_contract_id                   IN NUMBER,
      p_first_name                    IN VARCHAR2,
      p_last_name                     IN VARCHAR2,
      p_area_code                     IN VARCHAR2,
      p_phone                         IN VARCHAR2,
      p_email_address                 IN VARCHAR2,
      x_vendor_contact_id             OUT NOCOPY NUMBER);



  -- Start of comments
  --API name      : sync_con_header_attributes
  --Type          : Public.
  --Function      : Updates the header level attributes of all archived versions when they're modified in the working version
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contact
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE sync_con_header_attributes(
      p_api_version         IN NUMBER,
      p_init_msg_list       IN VARCHAR2,
      p_contract_id         IN NUMBER,
      x_msg_data            OUT NOCOPY  VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_return_status       OUT NOCOPY  VARCHAR2);

  -- Start of comments
  --API name      : check_contract_doc_access
  --Type          : Private.
  --Function      : Checks access to contract docs by the current user.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contract whose access to be checked
  --              : p_function_name       IN VARCHAR2       Required
  --                   Name of the function whose access to be checked. Possible values OKC_REP_SELECT and OKC_REP_UPDATE
  --OUT           : x_has_access          OUT  VARCHAR2(1)
  --              : x_status_code         OUT  VARCHAR2(30)
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE check_contract_doc_access(
      p_api_version     IN  NUMBER,
      p_init_msg_list   IN VARCHAR2,
      p_contract_id     IN  NUMBER,
      p_version_number  IN  NUMBER,
      p_function_name   IN  VARCHAR2,
      x_has_access      OUT NOCOPY  VARCHAR2,
      x_status_code     OUT NOCOPY  VARCHAR2,
      x_archived_yn     OUT NOCOPY  VARCHAR2,
      x_msg_data        OUT NOCOPY  VARCHAR2,
      x_msg_count       OUT NOCOPY  NUMBER,
      x_return_status   OUT NOCOPY  VARCHAR2);

  FUNCTION get_accessible_ous RETURN VARCHAR2;

-- Start of comments
  --API name      : has_contract_access
  --Type          : Private.
  --Function      : Checks access to a quote by the current user. It first checks the profile
  --              : "aso_enable_security_check". If this profile is set to 'No',
  --              : the API returns 'UPDATE'. else it calls ASO_SECURITY_INT.get_quote_access
  --              : to get the current user access.
  --              :
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_resource_id         IN NUMBER       Required
  --              : p_quote_number        IN NUMBER       Required
  --OUT           : Return 'NONE' if the current user does not have access to the quote. Else it
  --              : returns 'READ' or 'UPDATE'.
  -- End of comments
  FUNCTION get_quote_access
  (
    p_resource_id                IN   NUMBER,
    p_quote_number               IN   NUMBER
  ) RETURN VARCHAR2;

--Start of comments
  --API name      : contract_terms_disabled_yn
  --Type          : Private.
  --Function      : Based on the type of the contract selected for update, this function
  --              : will return 'Y' if there exist contracts with this contract type
  --              : which have structured terms.
  --              : Otherwise, it will return 'N'.The Enable_Contract_Terms chkbox
  --              : will be readonly if 'Y' is returned.It will be updateable otherwise.
  --              :
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_contract_type        	IN  VARCHAR      Required
  --OUT           : x_disable_contract_terms_yn OUT VARCHAR2
  -- End of comments

  PROCEDURE contract_terms_disabled_yn
  (
    p_contract_type              IN VARCHAR2,
    x_disable_contract_terms_yn   OUT NOCOPY  VARCHAR2
  );


END OKC_REP_UTIL_PVT;

/
