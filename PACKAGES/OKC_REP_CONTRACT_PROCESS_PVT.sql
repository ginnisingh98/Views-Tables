--------------------------------------------------------
--  DDL for Package OKC_REP_CONTRACT_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_CONTRACT_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVREPPROCSS.pls 120.2 2006/05/15 20:40:04 vamuru noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_REP_CONTRACT_PROCESS_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKC';
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';
  G_FND_APP                    CONSTANT   VARCHAR2(200) := OKC_API.G_FND_APP;
  G_UNABLE_TO_RESERVE_REC      CONSTANT   VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;
  G_RECORD_DELETED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_DELETED;
  G_RECORD_CHANGED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED   CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;

  -- Contract Statuses
  G_STATUS_PENDING_APPROVAL    CONSTANT   VARCHAR2(30) :=  'PENDING_APPROVAL';
  G_STATUS_SIGNED              CONSTANT   VARCHAR2(30) :=  'SIGNED';
  G_STATUS_TERMINATED          CONSTANT   VARCHAR2(30) :=  'TERMINATED';
  G_STATUS_DRAFT               CONSTANT   VARCHAR2(30) :=  'DRAFT';
  G_ACTION_SUBMITTED           CONSTANT   VARCHAR2(30) :=  'SUBMITTED';
  G_ACTION_ABORTED             CONSTANT   VARCHAR2(30) :=  'ABORTED';

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';

  G_APPROVAL_ITEM_TYPE         CONSTANT   VARCHAR2(200) := 'OKCREPMA';
  G_APPROVAL_PROCESS           CONSTANT   VARCHAR2(200) := 'REP_CONTRACT_APPROVAL';
  G_APPLICATION_ID         CONSTANT   NUMBER := 510;

  -- Required for Contract not found error message
  G_INVALID_CONTRACT_ID_MSG    CONSTANT   VARCHAR2(200) := 'OKC_REP_INVALID_CONTRACT_ID';
  G_CANEL_APPROVAL_ERROR_MSG   CONSTANT   VARCHAR2(200) := 'OKC_REP_CANCEL_APPROVAL_ERROR';

  G_CONTRACT_ID_TOKEN          CONSTANT   VARCHAR2(200) := 'CONTRACT_ID';
  G_CONTRACT_NUM_TOKEN         CONSTANT   VARCHAR2(200) := 'CONTRACT_NUM';

  G_INTERNAL_ORG               CONSTANT   VARCHAR2(200) := 'INTERNAL_ORG';

  G_CONTRACT_BOOKMARK_TYPE     CONSTANT   VARCHAR2(200) := 'CONTRACT';

  -- Contract events - deliverables integration
  G_CONTRACT_EXPIRE_EVENT     CONSTANT   VARCHAR2(200) := 'CONTRACT_EXPIRE';
  G_CONTRACT_EFFECTIVE_EVENT     CONSTANT   VARCHAR2(200) := 'CONTRACT_EFFECTIVE';
  G_CONTRACT_TERMINATED_EVENT CONSTANT   VARCHAR2(200) := 'CONTRACT_TERMINATED';

  -- Current version number for documents and deliverables
  G_CURRENT_VERSION     CONSTANT        NUMBER := -99;

  -- Contracts business events codes TBL Type
  SUBTYPE EVENT_TBL_TYPE IS OKC_MANAGE_DELIVERABLES_GRP.BUSDOCDATES_TBL_TYPE;

  G_INVALID_CONTRACT_NUMBER_MSG   CONSTANT VARCHAR2(200) := 'OKC_REP_INV_CON_NUMBER';
  ------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ------------------------------------------------------------------------------
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

-- Start of comments
--API name      : submit_contract_for_approval
--Type          : Private.
--Function      : Submits contract for approval
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract to be submitted for approval
--              : p_contract_version    IN NUMBER       Required
--                   Contract Version of the contract to be submitted for approval
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE submit_contract_for_approval(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_contract_id                  IN NUMBER,
    p_contract_version             IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    );

-- Start of comments
--API name      : delete_contacts
--Type          : Private.
--Function      : Deletes party contacts of a particular Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose contacts are to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_contacts(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : delete_parties
--Type          : Private.
--Function      : Deletes parties of a particular Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose parties are to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_parties(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);


-- Start of comments
--API name      : delete_risks
--Type          : Private.
--Function      : Deletes risks of a particular Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose risks are to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_risks(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : delete_related_contracts
--Type          : Private.
--Function      : Deletes related contracts of a particular Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose related contracts are to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_related_contracts(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : delete_ACL
--Type          : Private.
--Function      : Deletes parties of a particular Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose ACL is to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_ACL(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);


-- Start of comments
--API name      : delete_status_history
--Type          : Private.
--Function      : Deletes status history records of a contract version
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose status history is to be deleted
--              : p_contract_version    IN NUMBER       Required
--                   Contract version of the contract whose status history is to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_status_history(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_contract_id       IN  NUMBER,
      p_contract_version    IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : delete_approval_history
--Type          : Private.
--Function      : Deletes contract approval history records of a contract version
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose approval history is to be deleted
--              : p_contract_version    IN NUMBER       Required
--                   Contract version of the contract whose approval history is to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_approval_history(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_contract_id       IN  NUMBER,
      p_contract_version    IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : delete_bookmarks
--Type          : Private.
--Function      : Deletes bookmarks for a given contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_type         IN VARCHAR2       Required
--                   Contract Type of the contract whose bookmarks are to be deleted
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose bookmarks are is to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_bookmarks(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit            IN  VARCHAR2,
      p_contract_type     IN  VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : lock_contract_header
--Type          : Private.
--Function      : Locks a row in OKC_REP_CONTRACTS_ALL table
--Pre-reqs      : None.
--Parameters    :
--IN            : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract to be locked.
--              : p_object_version_number    IN NUMBER       Required
--                   Object version number of the contract to be locked
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE lock_contract_header(
    p_contract_id              IN NUMBER,
    p_object_version_number    IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2
  );

-- Start of comments
--API name      : delete_contract
--Type          : Private.
--Function      : Deletes a Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_contract(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);


-- Start of comments
--API name      : copy_contacts
--Type          : Private.
--Function      : Copies party contacts of source contract to target contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_source_contract_id         IN NUMBER       Required
--                   Id of the contract whose contacts are to be copied
--              : p_target_contract_id         IN NUMBER       Required
--                   Id of the contract to which source contacts are to be copied
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE copy_contacts(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_source_contract_id  IN  NUMBER,
      p_target_contract_id  IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : copy_parties
--Type          : Private.
--Function      : Copies parties of source contract to target contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_source_contract_id         IN NUMBER       Required
--                   Id of the contract whose parties are to be copied
--              : p_target_contract_id         IN NUMBER       Required
--                   Id of the contract to which source parties are to be copied
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE copy_parties(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_source_contract_id  IN  NUMBER,
      p_target_contract_id  IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);


-- Start of comments
--API name      : copy_risks
--Type          : Private.
--Function      : Copies risks of source contract to target contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_source_contract_id         IN NUMBER       Required
--                   Id of the contract whose risks are to be copied
--              : p_target_contract_id         IN NUMBER       Required
--                   Id of the contract to which source contract risks are to be copied
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE copy_risks(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_source_contract_id  IN  NUMBER,
      p_target_contract_id  IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : copy_ACL
--Type          : Private.
--Function      : Copies ACL records from source contract to target contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_source_contract_id         IN NUMBER       Required
--                   Id of the contract whose ACLs are to be copied
--              : p_target_contract_id         IN NUMBER       Required
--                   Id of the contract to which source contract ACL are to be copied
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE copy_ACL(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_source_contract_id  IN  NUMBER,
      p_target_contract_id  IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : copy_contract_details
--Type          : Private.
--Function      : Copies contract details for duplication
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_source_contract_id          IN NUMBER       Required
--                   Id of the contract whose details are to be copied
--              : p_target_contract_id          IN NUMBER       Required
--                   Id of the contract to which source contract details are to be copied
--              : p_target_contract_number      IN VARCHAR2     Required
--                   Number of the contract to which source contract details are to be copied
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE copy_contract_details(
      p_api_version            IN  NUMBER,
      p_init_msg_list          IN  VARCHAR2,
      p_commit                   IN  VARCHAR2,
      p_source_contract_id       IN  NUMBER,
      p_target_contract_id       IN  NUMBER,
      p_target_contract_number   IN  VARCHAR2,
      x_msg_data               OUT NOCOPY  VARCHAR2,
      x_msg_count              OUT NOCOPY  NUMBER,
      x_return_status          OUT NOCOPY  VARCHAR2);


-- Start of comments
--API name      : version_contract_details
--Type          : Private.
--Function      : Copies deliverables and documents for versioning
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id          IN NUMBER       Required
--                   Id of the contract whose details are to be versioned
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE version_contract_details(
      p_api_version            IN  NUMBER,
      p_init_msg_list          IN  VARCHAR2,
      p_commit                   IN  VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data               OUT NOCOPY  VARCHAR2,
      x_msg_count              OUT NOCOPY  NUMBER,
      x_return_status          OUT NOCOPY  VARCHAR2);




   -- Start of comments
--API name      : sign_contract
--Type          : Private.
--Function      : Changes contract status to SIGNED and calls delivarables
--                API to activate deliverables of that contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id          IN NUMBER       Required
--                   Id of the contract to be signed
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE sign_contract(
      p_api_version            IN  NUMBER,
      p_init_msg_list          IN  VARCHAR2,
      p_commit                   IN  VARCHAR2,
      p_contract_id              IN  NUMBER,
      x_msg_data               OUT NOCOPY  VARCHAR2,
      x_msg_count              OUT NOCOPY  NUMBER,
      x_return_status          OUT NOCOPY  VARCHAR2);


 -- Start of comments
--API name      : terminate_contract
--Type          : Private.
--Function      : Changes contract status to TERMINATED and calls delivarables
--                API to cancel deliverables of that contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id          IN NUMBER       Required
--                   Id of the contract to be terminated
--              : p_termination_date     IN DATE       Required
--                   Date the contract is terminated
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE terminate_contract(
      p_api_version            IN  NUMBER,
      p_init_msg_list          IN  VARCHAR2,
      p_commit                   IN  VARCHAR2,
      p_contract_id              IN  NUMBER,
      p_termination_date         IN  DATE,
      x_msg_data               OUT NOCOPY  VARCHAR2,
      x_msg_count              OUT NOCOPY  NUMBER,
      x_return_status          OUT NOCOPY  VARCHAR2);

   -- Start of comments
--API name      : repository_notifier
--Type          : Private.
--Function      : Sends notifications to contract's contacts if
--                the contract is about to expire or expired.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Id of the contract to be processed
--              : p_contract_number     IN NUMBER       Required
--                   Number of the contract to be processed
--              : p_contract_version    IN NUMBER       Required
--                   Version of the contract to be processed
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE repository_notifier(
      p_api_version       IN          NUMBER,
      p_init_msg_list     IN          VARCHAR2,
      p_contract_id       IN          NUMBER,
      p_contract_number   IN          VARCHAR2,
      p_contract_version  IN          NUMBER,
      p_expired_flag      IN          VARCHAR2,
      p_notify_contact_role_id IN     NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2);

--API name      : cancel_approval
--Type          : Private.
--Function      : Aborts the contract approval workflow process.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Id of the contract to be processed
--              : p_contract_version    IN NUMBER       Required
--                   Version of the contract to be processed
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE cancel_approval(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      p_contract_id                  IN NUMBER,
      p_contract_version             IN NUMBER,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2);


--API name      : get_next_contract_number
--Type          : Private.
--Function      : Gets next available number to use for a contract number
--                using FND Document Sequencing.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_number     IN VARCHAR2     Optional
--                   Number of the contract
--              : p_org_id              IN NUMBER       Required
--                   Id of the contract organization
--              : p_info_only           IN VARCHAR2     Optional
--                   Default = 'N'
--OUT           : x_contract_number     OUT  NUMBER
--              : x_auto_number_enabled OUT  VARCHAR2(1)
--              : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE get_next_contract_number(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      p_contract_number              IN VARCHAR2 := NULL,
      p_org_id                       IN NUMBER,
      p_info_only                    IN VARCHAR2,
      x_contract_number              OUT NOCOPY NUMBER,
      x_auto_number_enabled          OUT NOCOPY VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2);
END OKC_REP_CONTRACT_PROCESS_PVT;

 

/
