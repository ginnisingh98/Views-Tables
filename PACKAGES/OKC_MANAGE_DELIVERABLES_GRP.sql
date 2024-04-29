--------------------------------------------------------
--  DDL for Package OKC_MANAGE_DELIVERABLES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_MANAGE_DELIVERABLES_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGMDLS.pls 120.0.12010000.3 2008/11/14 13:14:29 strivedi ship $ */

  ---------------------------------------------------------------------------
  -- TYPE Definitions
  ---------------------------------------------------------------------------
    -- declaring record type for deliverable due date events
    TYPE BUSDOCDATES_REC_TYPE IS RECORD (
        event_code      VARCHAR2(30),
        event_date      DATE
                  );
    -- declaring table of records
    TYPE BUSDOCDATES_TBL_TYPE IS TABLE OF BUSDOCDATES_REC_TYPE
    INDEX BY BINARY_INTEGER;

    -- declaring record type for business docs
    TYPE BUSDOCS_REC_TYPE IS RECORD (
        bus_doc_id      NUMBER,
        bus_doc_version NUMBER,
        bus_doc_type    VARCHAR2(30)
                  );
    -- declaring table of records
    TYPE BUSDOCS_TBL_TYPE IS TABLE OF BUSDOCS_REC_TYPE
    INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

    /**
     * This procedure resolves and activates deliverables for a given business
     * document version.
     * @param IN p_bus_doc_id target business document id
     * @param IN p_bus_doc_type target business document type
     * @param IN p_bus_doc_version target business document version, documents with no valid version number
     * should pass -99
     * @param IN p_event_code action based business document event (e.g. PO Signed, PO Cancelled, Bid Received etc.)
     * @param IN p_event_date action based business document event date
     * @param IN p_sync_flag if this flag is true, syncing of target deliverables with the previously managed deliverables takes place.
     * @param IN p_bus_doc_date_events_tbl table type for business document date based events
     */
    PROCEDURE activateDeliverables (
    p_api_version                 IN NUMBER,
    p_init_msg_list               IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	      IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bus_doc_id                  IN NUMBER,
    p_bus_doc_type                IN VARCHAR2,
    p_bus_doc_version             IN NUMBER,
    p_event_code                  IN VARCHAR2,
    p_event_date                  IN DATE,
    p_sync_flag	              	  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bus_doc_date_events_tbl     IN BUSDOCDATES_TBL_TYPE,
    x_msg_data                    OUT NOCOPY  VARCHAR2,
    x_msg_count                   OUT NOCOPY  NUMBER,
    x_return_status               OUT NOCOPY  VARCHAR2);

    /**
     * This procedure cancel deliverables on a given business document version and
     * implicitly activate deliverables that are based on Cancel Event, passed as
     * input parameter 'p_event_code'.
     * @param IN p_bus_doc_id target business document id
     * @param IN p_bus_doc_type target business document type
     * @param IN p_bus_doc_version target business document version, documents with no valid version number
     * should pass -99
     * @param IN p_event_code action based business document event (e.g. PO Cancelled)
     * @param IN p_event_date action based business document event date
     * @param IN p_bus_doc_date_events_tbl table type for business document date based events
     */
    PROCEDURE  cancelDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    p_event_code                IN VARCHAR2,
    p_event_date                IN DATE,
    p_bus_doc_date_events_tbl IN BUSDOCDATES_TBL_TYPE,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2);

    /**
     * This is the simple cancel deliverables procedure where deliverables are simply cancelled
     * on the given business document version.
     * @param IN p_bus_doc_id target business document id
     * @param IN p_bus_doc_type target business document type
     * @param IN p_bus_doc_version target business document version, documents with no valid version number
     * should pass -99
     */
    PROCEDURE  cancelDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2);

    /**
     * This procedure update deliverables for given business document version. The update
     * in real sense implies, re-resolving deliverables due dates which are based
     * on business document dates, if any of the dates are changed and keep the status
     * of deliverables as is.
     * @param IN p_bus_doc_id target business document id
     * @param IN p_bus_doc_type target business document type
     * @param IN p_bus_doc_version target business document version, documents with no valid version number
     * should pass -99
     * @param IN p_bus_doc_date_events_tbl table type for business document date based events, should contain only those date based events where corresponding dates are changed
     */
    PROCEDURE updateDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    p_bus_doc_date_events_tbl IN BUSDOCDATES_TBL_TYPE,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2);

    /**
     * This procedure updates old buyer contact on deliverables for given business document version
     * with the new buyer contact
     * @param IN p_bus_doc_id target business document id
     * @param IN p_bus_doc_type target business document type
     * @param IN p_bus_doc_version target business document version, documents with no valid version number
     * should pass -99
     * @param IN p_original_buyer_id old buyer id
     * @param IN p_new_buyer_id new buyer id
     * @deprecated this API is deprecated. Use updateIntContactOnDeliverables()
     */
    PROCEDURE updateBuyerOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    p_original_buyer_id         IN NUMBER,
    p_new_buyer_id              IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2);

    /**
     * This procedure updates buyer contact on deliverables with new buyer contact, for bulk
     * business documents passed as table of records.
     * @param IN p_bus_docs_tbl table type for business documents to be updated for buyer contact on deliverables
     * @param IN p_original_buyer_id old buyer id
     * @param IN p_new_buyer_id new buyer id
     * @deprecated this API is deprecated. Use updateIntContactOnDeliverables()
     */
    PROCEDURE updateBuyerOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bus_docs_tbl              IN BUSDOCS_TBL_TYPE,
    p_original_buyer_id         IN NUMBER,
    p_new_buyer_id              IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2);

    /**
     * This procedure resolve deliverables due dates.
     * @param IN p_bus_doc_id target business document id
     * @param IN p_bus_doc_type target business document type
     * @param IN p_bus_doc_version target business document version, documents with no valid version number
     * should pass -99
     * @param IN p_event_code action based business document event (e.g. PO Signed, PO Cancelled, Bid Received etc.)
     * @param IN p_event_date action based business document event date
     * @param IN p_bus_doc_date_events_tbl table type for business document date based events
     * @param IN p_sync_flag if this flag is true, syncing of target deliverables with the previously managed deliverables takes place.
     * @param IN p_sync_recurr_instances_flag if this flag i true, recurring instances are re-resolved based on new end date and previous instances are syned up as is.
     * if this flag is false, recurring instances are generated from the scratch (this happens when the API is called directly). If this API is called from activateDeliverables() the value is defaulted to TRUE.
     */
    PROCEDURE resolveDeliverables (
        p_api_version                 IN NUMBER,
        p_init_msg_list               IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    	p_commit	              IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_bus_doc_id                  IN NUMBER,
        p_bus_doc_type                IN VARCHAR2,
        p_bus_doc_version             IN NUMBER,
        p_event_code                  IN VARCHAR2,
        p_event_date                  IN DATE,
        p_bus_doc_date_events_tbl   IN BUSDOCDATES_TBL_TYPE,
        x_msg_data                    OUT NOCOPY  VARCHAR2,
        x_msg_count                   OUT NOCOPY  NUMBER,
        x_return_status               OUT NOCOPY  VARCHAR2,
        p_sync_flag	              	  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_sync_recurr_instances_flag  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_cancel_flag                 IN VARCHAR2 DEFAULT FND_API.G_FALSE);

    /**
     * This procedure enable notifications on deliverables for given business document
     * version.
     * @param IN p_bus_doc_id target business document id
     * @param IN p_bus_doc_type target business document type
     * @param IN p_bus_doc_version target business document version, documents with no valid version number
     * should pass -99
     */
    PROCEDURE enableNotifications (
        p_api_version  IN NUMBER,
        p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_bus_doc_id IN NUMBER,
        p_bus_doc_type IN VARCHAR2,
        p_bus_doc_version IN NUMBER,
        x_msg_data  OUT NOCOPY  VARCHAR2,
        x_msg_count OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2);


    /**
     * This procedure disables execution of deliverables for a given business document
     * version.
     * @param IN p_bus_doc_id target business document id
     * @param IN p_bus_doc_type target business document type
     * @param IN p_bus_doc_version target business document version, documents with no valid version number
     * should pass -99
     */
    PROCEDURE disableDeliverables (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit	        IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_bus_doc_id    IN  NUMBER,
        p_bus_doc_type      IN VARCHAR2,
        p_bus_doc_version   IN  NUMBER,   -- -99 for Sourcing.
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2);

    /**
     * This procedure updates internal contact on deliverables for
     * given business document version with new internal contact id.
     * @param IN p_bus_doc_id target business document id
     * @param IN p_bus_doc_type target business document type
     * @param IN p_bus_doc_version target business document version, documents with no valid version number
     * should pass -99
     * @param p_original_internal_contact_id old internal contact
     * @param p_new_internal_contact_id new internal contact
     */
    PROCEDURE updateIntContactOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    p_original_internal_contact_id         IN NUMBER,
    p_new_internal_contact_id              IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2);

    /**
     * This procedure updates internal contact on deliverables for given set of
     * business documents.
     * @param IN p_bus_docs_tbl table type for business documents to be updated for internal contact on deliverables
     * @param p_original_internal_contact_id old internal contact
     * @param p_new_internal_contact_id new internal contact
     */
    PROCEDURE updateIntContactOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bus_docs_tbl              IN BUSDOCS_TBL_TYPE,
    p_original_internal_contact_id         IN NUMBER,
    p_new_internal_contact_id              IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2);

    /**
     * This procedure updates external party id and site id
     * on deliverables for given draft version of business document.
     */
    PROCEDURE updateExtPartyOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_external_party_id         IN NUMBER,
    p_external_party_site_id    IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2);

    /**
     * This procedure updates external party id and site id
     * on deliverables for given class of business document.
     */
    PROCEDURE updateExtPartyOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_document_class            IN VARCHAR2,
    p_from_external_party_id         IN NUMBER,
    p_from_external_party_site_id    IN NUMBER,
    p_to_external_party_id         IN NUMBER,
    p_to_external_party_site_id    IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2);

	/**
	 * This API performs post actions when deliverables status change
	 * happens in the middle-tier
	 */
    PROCEDURE postDelStatusChanges (
        p_api_version  IN NUMBER,
        p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_bus_doc_id IN NUMBER,
        p_bus_doc_type IN VARCHAR2,
        p_bus_doc_version IN NUMBER,
        x_msg_data  OUT NOCOPY  VARCHAR2,
        x_msg_count OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2);

    /** 11.5.10+ code
    Function to check if any deliverables exist for a given external
    party for a given contract. Invoked by Repository ContractDetailsAMImpl.java    API.
    Parameter Details:
    p_busdoc_id :           Business document Id
    p_busdoc_type :         Business document type
    p_external_party_id              ID of internal or external party
    p_external_party_role            Role of internal or external party
                            (valid values INTERNAL,SUPPLIER, CUSTOMER, PARTNER)
    Returns N or Y, if there is unexpected error then it returns NULL.
    **/
    FUNCTION deliverablesForExtPartyExist(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_busdoc_id          IN  NUMBER,
    p_busdoc_type        IN  VARCHAR2,
    p_external_party_id           IN  NUMBER,
    p_external_party_role         IN  VARCHAR2)
    RETURN VARCHAR2;

    /** 11.5.10+ code
    Function to check if any maneagable deliverables exist for a given contract.    Invoked by Repository ContractDetailsAMImpl.java.
    Parameter Details:
    p_busdoc_id :           Business document Id
    p_busdoc_type :         Business document type
    p_busdoc_version :      Business document version
    Returns N or Y, if there is unexpected error then it returns NULL.
    **/
    FUNCTION check_manageable_deliverables(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_busdoc_id          IN  NUMBER,
    p_busdoc_type        IN  VARCHAR2,
    p_busdoc_version          IN  NUMBER)
    RETURN VARCHAR2;

    /**
     * This procedure updates external party id and site id
     * on deliverables based on external party role for given class of business document.
     * This API is for HZ party Merge process
     **/
    PROCEDURE mergeExtPartyOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_document_class            IN VARCHAR2,
    p_from_external_party_id         IN NUMBER,
    p_from_external_party_site_id    IN NUMBER,
    p_to_external_party_id         IN NUMBER,
    p_to_external_party_site_id    IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2);

   /**
     * This procedure resolves activates deliverables based on Cancel/Close/Termination Event
     * for a given business document version
     * @param IN p_bus_doc_id target business document id
     * @param IN p_bus_doc_type target business document type
     * @param IN p_bus_doc_version target business document version, documents with no valid version number
     * should pass -99
     * @param IN p_event_code action based business document event (e.g. PO Cancelled)
     * @param IN p_event_date action based business document event date
     * @param IN p_bus_doc_date_events_tbl table type for business document date based events
     */
    PROCEDURE  activateCloseoutDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit	          	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    p_event_code                IN VARCHAR2,
    p_event_date                IN DATE,
    p_bus_doc_date_events_tbl IN BUSDOCDATES_TBL_TYPE,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2);

/*-- Start of comments
--API name      : applyPaymentHolds
--Type          : Public.
--Function      : 1.  This API returns TRUE if the Invoices for the concerned PO need to be held.False otherwise
--              : 2.  It runs through the pay_when_paid deliverables associated with the concerned PO.
--              :     It returns true based on which checkbox is checked and by comparing the sysdate with the actual due date.
--Usage         : This public API will be used only by the PO team to determine if invoices need to be held
--		:for the PO because of any deliverable.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_bus_doc_id          IN NUMBER       Required
--                   Header ID of the Standard Purchase Order
--              : p_bus_doc_version     IN NUMBER       Required
--                   Version number of the Standard Purchase Order
--OUT           : x_return_status       OUT  VARCHAR2
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments */

PROCEDURE applyPaymentHolds(
        p_api_version           IN NUMBER,
        p_bus_doc_id            IN NUMBER,
        p_bus_doc_version       IN NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2);

/*-- Start of comments
--Function name : checkDeliverablePayHold
--Type          : Public.
--Function      : This Function returns TRUE if the deliverable is holding invoices.False otherwise.
--Usage         : This public API will be used only by the Projects team to determine if a
--                particular deliverable is holding invoices or not.
--Pre-reqs      : None.
--Returns       :TRUE or FALSE, if there is unexpected error then it returns NULL.
-- End of comments */

FUNCTION checkDeliverablePayHold (
        p_deliverable_id        IN NUMBER)
RETURN VARCHAR2;


END OKC_MANAGE_DELIVERABLES_GRP;

/
