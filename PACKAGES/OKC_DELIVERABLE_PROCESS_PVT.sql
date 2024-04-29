--------------------------------------------------------
--  DDL for Package OKC_DELIVERABLE_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DELIVERABLE_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVDPRS.pls 120.3.12010000.2 2011/12/09 13:47:19 serukull ship $ */

  ---------------------------------------------------------------------------
  -- TYPE Definitions
  ---------------------------------------------------------------------------
    TYPE delRecTabType IS TABLE OF okc_deliverables%ROWTYPE
    INDEX BY BINARY_INTEGER;

    TYPE  delHistTabType IS TABLE OF okc_del_status_history%ROWTYPE
    INDEX BY BINARY_INTEGER;

    TYPE delIdTabType IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

    TYPE recurring_dates_tab_type IS TABLE OF DATE
    INDEX BY BINARY_INTEGER;


    TYPE   del_cur_type IS REF CURSOR RETURN okc_deliverables%ROWTYPE;

    --declaring record type for Bus Doc Type Info
    TYPE BUSDOCTYPE_REC_TYPE IS RECORD(
	  document_type_class   OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE_CLASS%TYPE
	 ,document_type_intent  OKC_BUS_DOC_TYPES_B.INTENT%TYPE);


    -- declaring record type for deliverable due date events
    TYPE BUSDOCDATES_REC_TYPE IS RECORD (
        event_code      VARCHAR2(30),
        event_date      DATE
                  );
    -- declaring table of records
    TYPE BUSDOCDATES_TBL_TYPE IS TABLE OF BUSDOCDATES_REC_TYPE
    INDEX BY BINARY_INTEGER;
    l_doc_dates_tbl BUSDOCDATES_TBL_TYPE;
  ---------------------------------------------------------------------------
  -- Global VARIABLES
  ---------------------------------------------------------------------------
    G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_DELIVERABLE_PROCESS_PVT';
    G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
    G_ENTITY_NAME             CONSTANT VARCHAR2(40)   :=  'OKC_DELIVERABLES';

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
 ------------------------------------------------------------------------------
 G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
 G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
 G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
 G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
 G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
 G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
G_DLV_QA_TYPE                CONSTANT   VARCHAR2(30)  := 'DELIVERABLE';

 G_QA_STS_SUCCESS             CONSTANT   varchar2(1) := 'S';
 G_QA_STS_ERROR               CONSTANT   varchar2(1) := 'E';
 G_QA_STS_WARNING             CONSTANT   varchar2(1) := 'W';

 G_NORMAL_QA             CONSTANT VARCHAR2(30) :=  'NORMAL';
 G_AMEND_QA              CONSTANT VARCHAR2(30) :=  'AMEND';
 G_OKC                   CONSTANT VARCHAR2(3)  :=  'OKC';

  -----------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
   /*** This API is invoked from OKC_TERMS_PVT.COPY_TC.
   This API copies deliverables from one busdoc to another
   of same type. Used in Sourcing amendment process.
   1.  Verify if the source and target business documents
   are of same Class. If Not, raise error.
   2.  The procedure will query deliverables from source
   business document WHERE amendment_operation is NOT 'DELETE'.
   (The reson of this check: In case of RFQ, amendments operation
   and descriptions are maintained in the current copy,
   hence all deletes are just soft deletes.
   So the copy procedure should not copy deliverables which
   were deleted from the RFQ during amendment).
   3.  Create instances of deliverables for p_target_doc_id
   and p_target_doc_type, definition  copied from
   p_source_doc_id and p_source_doc_type.
   Carry forward original deliverable id. Copy attachments.
    Parameter Details:
    p_source_doc_id :       Source document Id
    p_source_doc_type :     Source document type
    p_target_doc_id   :     Target document Id
    p_target_doc_type :     Target document Type
    p_resetFixedDate_yn :   This flag will be used to set null values
    to deliverables having fixed dates or toset null values
    (start date, end date) to deliverables with recurring dates
   ***/

 PROCEDURE copy_del_for_amendment (
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
    p_source_doc_id         IN NUMBER,
    p_source_doc_type       IN VARCHAR2,
    p_target_doc_id         IN NUMBER,
    p_target_doc_type       IN VARCHAR2,
    p_target_doc_number     IN VARCHAR2,
    p_reset_fixed_date_yn   IN VARCHAR2,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    p_copy_del_attachments_yn   IN VARCHAR2 default 'Y',
    p_target_contractual_doctype  IN  Varchar2 default null);


    -- Creates deliverable status history
    PROCEDURE create_del_status_history (
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2,
    p_del_id            IN NUMBER,
    p_deliverable_status    IN VARCHAR2,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_return_status OUT NOCOPY  VARCHAR2);


    /*** This API is invoked from OKC_TERMS_COPY_GRP.COPY_DOC.
    Copies deliverables from source to target documents
    Template to template, Template to Business document
    Busdoc to busdoc of same or different types.
    The procedure will query deliverables from source
    business document WHERE amendment_operation is NOT 'DELETE'.
    (The reason of this check: In case of RFQ, amendments operation
    and descriptions are maintained in the current copy,
    hence all deletes are just soft deletes.
    So the copy procedure should not copy deliverables which
    were deleted from the RFQ during amendment).
    Parameter Details:
    p_source_doc_id :       Source document Id
    p_source_doc_type :     Source document type
    p_target_doc_id   :     Target document Id
    p_target_doc_type :     Target document Type
    p_target_doc_number :   Target document Number
    p_resetFixedDate_yn :   This flag will be used to set null values
    to deliverables having fixed dates or toset null values
    (start date, end date) to deliverables with recurring dates
    p_initializeStatus_yn : Flag indicating status to be reset to INACTIVE.
                            Valid vakues Y and N.
    p_copy_del_attachments_yn : Flag indicates if attachments should be copied or not.
    p_target_contractual_doctype : Specifies the target document for the
    target business document. For example if RFQ is the target busdoc,
    then the p_target_contractual_doctype could be PO_STANDARD or BPA etc.
    p_target_response_doctype : Specifies the target response document for the
    target business document. For example if RFQ is the target busdoc,
    then the p_target_response_doctype could be RESPONSE etc.
    p_internal_party_id  : Internal party id on the target document
    p_internal_contact_id: Internal party contact id on the target document
    p_external_party_id  : External party id on the target document
    p_external_contact_id: External party contact id on the target document
    Bug#4126344
    p_carry_forward_ext_party_yn: If set to Y carry forward following attributes
    from source doc
     external_party_contact_id,
     external_party_id,
     external_party_site_id,
     external_party_role
    Else reset from parameters
    p_carry_forward_int_contact_yn: If set to Y carry forward following attributes from source doc
     internal_party_contact_id,
    ***/
    PROCEDURE copy_deliverables (
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
        p_source_doc_id             IN NUMBER,
        p_source_doc_type           IN VARCHAR2,
        p_target_doc_id             IN NUMBER,
        p_target_doc_type           IN VARCHAR2,
        p_target_doc_number         IN VARCHAR2,
        p_target_contractual_doctype IN VARCHAR2 default null,
        p_target_response_doctype   IN VARCHAR2 default null,
        p_initialize_status_yn      IN VARCHAR2 default 'Y',
        p_copy_del_attachments_yn   IN VARCHAR2 default 'Y',
        p_internal_party_id         IN NUMBER default null,
        p_reset_fixed_date_yn       IN VARCHAR2 default 'N',
        p_internal_contact_id       IN NUMBER default null,
        p_external_party_id         IN NUMBER default null,
        p_external_party_site_id         IN NUMBER default null,
        p_external_contact_id       IN NUMBER default null,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count                 OUT NOCOPY NUMBER,
        x_return_status             OUT NOCOPY VARCHAR2,
        p_carry_forward_ext_party_yn  IN  VARCHAR2 default 'N',
        p_carry_forward_int_contact_yn IN  VARCHAR2 default 'Y'
       ,p_add_only_amend_deliverables IN VARCHAR2 := 'N'
       );



    /***This API is invoked from OKC_TERMS_PVT.VERSION_DOC.
        This API creates new set of deliverables for a given
        version of document.
    Parameter Details:
    p_doc_id :       Business document Id
    p_doc_type :     Business document type
    p_doc_version :  Business document version
    ***/
    PROCEDURE version_deliverables (
        p_api_version   IN NUMBER,
        p_init_msg_list IN VARCHAR2,
        p_doc_id        IN NUMBER,
        p_doc_version   IN NUMBER,
        p_doc_type      IN  VARCHAR2,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2);

    /** This API is called by OKC_MANAGE_DELIVERABLES_GRP.activate_deliverables
    to sync status of the current signed document deliverables with the previous
    signed document deliverables. Copy status history.
    Parameter Details:
    p_current_docid :       Current signed Business document Id
    p_current_doctype :     Business document type
    p_current_doc_version :  Business document version
    ***/
    PROCEDURE sync_deliverables (
        p_api_version   IN NUMBER,
        p_init_msg_list IN VARCHAR2,
        p_current_docid        IN NUMBER,
        p_current_doctype      IN  VARCHAR2,
        p_current_doc_version        IN NUMBER,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2);




    /***Invoked From: OKC_TERMS_PVT.VERSION_DOC
    This API is invoked to clear amendment operation,
    summary amend operation code and amendment notes
    on deliverables for a given busdoc.
    Parameter Details:
    p_doc_id :       Business document Id
    p_doc_type :     Business document type
    bug#3618448 new param added
    p_keep_summary:  If set to 'N' all amendment attributes should be cleared.
    If 'Y' then only amendment_operation will be cleared, default is 'N'.
    ***/
    PROCEDURE clear_amendment_operation (
        p_api_version   IN NUMBER,
        p_init_msg_list IN VARCHAR2,
        p_doc_id        IN NUMBER,
        p_doc_type      IN  VARCHAR2,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2,
        p_keep_summary  IN  VARCHAR2 DEFAULT 'N');

    /***
    This API is invoked from OKC_MANAGE_DELIVERABLES_GRP.activate_deliverables
    and close_deliverables. It changes the status to a given status for a busdoc.
    Creates status history for deliverable.
    Parameter Details:
    p_doc_id :       Business document Id
    p_doc_type :     Business document type
    p_doc_version :  Business document version
    p_cancel_yn : Indicates if the deliverables is updated because of
    cancellation. Valid values Y/N
    p_cancel_event_code : If the call is for cancellation then the cancellation
    event code should be passed.
    p_current_status : Current status of deliverable
    p_new_status : New status of deliverable
    p_manage_yn : Indicates if Manage flag should be turned on or not
    ***/
    PROCEDURE change_deliverable_status (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN VARCHAR2,
        p_doc_id            IN  NUMBER,
        p_doc_version       IN  NUMBER,
        p_doc_type          IN VARCHAR2,
        p_cancel_yn         IN VARCHAR2,
        p_cancel_event_code IN VARCHAR2 default null,
        p_current_status    IN VARCHAR2,
        p_new_status        IN VARCHAR2,
        p_manage_yn         IN VARCHAR2,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2);


    /***
    This is the Concurrent Program scheduled to run every day
    to send out notifications about overdue deliverables.
    It internally calls API overdue_del_notifier
    to check for overdue deliverabls and send out notifications
    ***/
    PROCEDURE overdue_deliverable_manager (
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2);


    /***
    Invoked by Concurrent Program "overdue_deliverable_manager"
    Picks all deliverables that are overdue
    Invokes Deliverable Notifier to send out notifications
    Update deliverables with overdue_notification_id
    ***/
    PROCEDURE overdue_del_notifier(
        p_api_version                  IN NUMBER ,
        p_init_msg_list                IN VARCHAR2 ,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2);

    /***
    This is the Concurrent Program scheduled to run every day
    to send out notifications about beforedue deliverables.
    It internally calls API beforedue_del_notifier.
    ***/
    PROCEDURE beforedue_deliverable_manager (
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2);

    /***
    Invoked by Concurrent Program "beforedue_deliverable_manager"
    Picks all deliverables eligible for before due date notifications
    Invokes Deliverable Notifier to send out notifications
    Update deliverables with prior_notification_id
    ***/
    PROCEDURE beforedue_del_notifier(
        p_api_version                  IN NUMBER ,
        p_init_msg_list                IN VARCHAR2 ,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2);

    /***
    This is the Concurrent Program scheduled to run every day
    to send out escalated notifications about deliverables.
    It internally calls API escalation_deliverable_notifier
    ***/
    PROCEDURE escalation_deliverable_manager (
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2);

    /***
    Invoked by Concurrent Program "escalation_deliverable_manager"
    Picks all deliverables eligible for escalation
    Invokes Deliverable Notifier to send out notifications only to escalation assignee
    Update deliverables with escalation_notification_id
    ***/
    PROCEDURE esc_del_notifier(
        p_api_version                  IN NUMBER ,
        p_init_msg_list                IN VARCHAR2 ,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2);

    /***
    1.  This API performs bulk delete of deliverables for business documents.
    Invoked by OKC_TERMS_UTIL_GRP.purge_documents
    2.  For each doc_type and doc_id in p_doc_table,
    find the deliverables that belong to the business document,
    delete the deliverable, status history and attachments.
    ***/
    PROCEDURE purge_doc_deliverables (
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2:=FND_API.G_FALSE,
    p_doc_table IN OKC_TERMS_UTIL_GRP.doc_tbl_type,
    x_msg_data  OUT NOCOPY  VARCHAR2,
    x_msg_count OUT NOCOPY  NUMBER,
    x_return_status OUT NOCOPY  VARCHAR2);

    /***
    1.  This API is invoked by OKC_TERMS_UTIL_PVT.merge_template_working_copy
    2.  This API will select all deliverables for a given
    business document type and version
    3.  Delete all deliverables along with the attachments and status history
    Parameter Details:
    4. If p_retain_lock_deliverables_yn IN VARCHAR2 := 'N' then all the deliverbales
    with amendment_operation_code not null will not be deleted.
    p_doc_id :       Business document Id
    p_doc_type :     Business document type
    p_doc_version :  Business document version
    p_retain_lock_deliverables_yn : Delete delvierabels based on amendment_operaion_code
    ***/
    PROCEDURE delete_deliverables (
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_doc_id    IN NUMBER,
    p_doc_type  IN  VARCHAR2,
    p_doc_version IN NUMBER DEFAULT NULL,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2
    ,p_retain_lock_deliverables_yn IN VARCHAR2 := 'N');

    /***
    1.  This API is invoked by OKC_TERMS_UTIL_PVT.merge_template_working_copy
    2.  This API will select all deliverables for a given source template id
    3.  Update all deliverables on the target template Id
    set the business_document_id = source template id
    ***/
    PROCEDURE update_del_for_template_merge (
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_base_template_id  IN NUMBER,
    p_working_template_id   IN NUMBER,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2);

    /**Returns the max date of the last_amendment_date for a busdoc
    if the deliverables did not get amended then returns the
    max last update date
    Parameter Details:
    p_busdoc_id :       Business document Id
    p_busdoc_type :     Business document type
    p_busdoc_version :  Business document version
    **/

    FUNCTION get_last_amendment_date (
    p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE

    ,x_return_status    OUT NOCOPY VARCHAR2
    ,x_msg_data         OUT NOCOPY VARCHAR2
    ,x_msg_count        OUT NOCOPY NUMBER

    ,p_busdoc_id        IN    NUMBER
    ,p_busdoc_type     IN    VARCHAR2
    ,p_busdoc_version  IN    NUMBER)
    RETURN DATE;




  /**
  * This function Returns end date as actual date for given Start date,
  * time unit(DAYS, WEEKS, MONTHS), duration and (B)efore/(A)fter.
  */
  FUNCTION get_actual_date(
    p_start_date in date,
    p_timeunit varchar2,
    p_duration number,
    p_before_after varchar2)
  return date;

 /**
  * This API is called from Terms validate API to validate deliverables
  * on a given business document.
  * It will take in a table of records and populate the table if
  * any error or warning is found on the deliverables on the bus doc.
  */
   PROCEDURE validate_deliverable_for_qa (
    p_api_version 	IN    NUMBER,
    p_init_msg_list	IN   VARCHAR2 := FND_API.G_FALSE,
    p_doc_type 		IN   VARCHAR2,
    p_doc_id		IN    NUMBER,
    p_mode		IN     VARCHAR2,
    p_bus_doc_date_events_tbl   IN OKC_TERMS_QA_GRP.BUSDOCDATES_TBL_TYPE,
    p_qa_result_tbl	IN OUT NOCOPY    OKC_TERMS_QA_PVT.qa_result_tbl_type,
    x_msg_data 	OUT NOCOPY VARCHAR2,
    x_msg_count 	OUT NOCOPY NUMBER,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_qa_return_status  IN OUT NOCOPY VARCHAR2);




  /**
  * Resolve recurring dates for given start date, end date and repeat
  * frequency, day of month, day of week. Returns Table of dates resolved.
  */
  PROCEDURE get_recurring_dates (
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_start_date in date,
    p_end_date in date,
    p_frequency in number,
    p_recurr_day_of_month number,
    p_recurr_day_of_week number,
    x_recurr_dates   OUT NOCOPY recurring_dates_tab_type ,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2);

  PROCEDURE delete_del_status_hist_attach(
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    p_deliverable_id IN NUMBER,
    p_bus_doc_id IN NUMBER,
    p_bus_doc_version IN NUMBER,
    p_bus_doc_type IN VARCHAR2,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2);

FUNCTION get_ui_bus_doc_event_text(p_event_name IN VARCHAR2,
                                    p_before_after IN VARCHAR2) RETURN VARCHAR2;

    /**
    Parameter Details:
    p_doc_id :       Business document Id
    p_doc_type :     Business document type
    p_doc_version :  Business document version
    p_Conditional_Delete_Flag : Valid values are 'Y' and 'N'.
                                Pass 'N' if all Deliverable instances for a given Deliverable ID
						  should be deleted unconditionally.
						  Pass 'Y' to delete only those Deliverable instances of a given Deliverable
						  whose Status hasn't been updated by User as part of Manage Deliverables
    p_delid_tab   :  Table of deliverable ids
    **/
    PROCEDURE delete_del_instances(
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_doc_id    IN NUMBER,
    p_doc_type  IN  VARCHAR2,
    p_doc_version IN NUMBER DEFAULT NULL,
    p_Conditional_Delete_Flag IN VARCHAR2 DEFAULT 'N',
    p_delid_tab    IN OKC_DELIVERABLE_PROCESS_PVT.delIdTabType,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2);

    /*** This procedure will disable or turn manage_yn to 'N'
    for a given document type and version
    Parameter Details:
    p_doc_id :       Business document Id
    p_doc_type :     Business document type
    p_doc_version :  Business document version
    ***/
    PROCEDURE disable_deliverables (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN VARCHAR2,
        p_doc_id            IN  NUMBER,
        p_doc_version       IN  NUMBER,
        p_doc_type          IN VARCHAR2,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2);

    /**Invoked From: OKC_TERMS_UTIL_GRP.get_document_deviations
        1.  This function returns type of deliverables existing on a Business Document
            for a given version. Invoked by OKC_TERMS_UTIL_GRP.get_document_deviations.
        2.  Select all deliverables for the Business Document. If deliverables exist then
            a.  Check each deliverable type
                i.  If only contractual deliverables exist then return CONTRACTUAL
                ii. If only internal deliverables exist then return INTERNAL
                iii.If both contractual and internal deliverables exist then return
                    CONTRACTUAL_AND_INTERNAL
        3.  If no deliverables exist then return NONE
    Parameter Details:
    p_docid :       Business document Id
    p_doctype :     Business document type
    **/


    FUNCTION deliverables_exist
        (
         p_api_version      IN  NUMBER,
         p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
         x_return_status    OUT NOCOPY VARCHAR2,
         x_msg_data         OUT NOCOPY VARCHAR2,
         x_msg_count        OUT NOCOPY NUMBER,
         p_doctype         IN  VARCHAR2,
         p_docid           IN  NUMBER
         ) RETURN VARCHAR2;



    /** This procedure deletes the deliverable,
    status history and attachments **/
    PROCEDURE delete_deliverable (
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_del_id    IN NUMBER,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2);



    /*** This procedure will delete all deliverables that have been
    created by applying a particular template on a busdoc.
    It selects all deliverables which have original_deliverable_id
    belonging to TEMPLATE and deletes them from the busdoc.
    Parameter Details:
    p_doc_id :       Business document Id
    p_doc_type :     Business document type
    ***/
    PROCEDURE delete_template_deliverables (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN VARCHAR2,
        p_doc_id            IN  NUMBER,
        p_doc_type          IN VARCHAR2,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2);

    -- This function checks if the given deliverable has an attachment
    FUNCTION attachment_exists(
    p_entity_name IN VARCHAR2
    ,p_pk1_value    IN VARCHAR2
    ) RETURN BOOLEAN;

    /**Invoked From: OKC_TERMS_UTIL_GRP.is_deliverable_amended
    1.  This function returns type of deliverables amended on a Business Document
    2.  Select all deliverables definitions (-99 version) for the Business Document.
    If deliverables exist then
        a.  Check each deliverable type
           i.  If only contractual deliverables amended then return CONTRACTUAL
           ii. If only internal deliverables amended then return INTERNAL
           iii.If both contractual and internal deliverables amended then return
           CONTRACTUAL_AND_INTERNAL
           iv.If both contractual and sourcing deliverables amended then return
           CONTRACTUAL_AND_SOURCING
           v.If both sourcing and internal deliverables amended then return
           SOURCING_AND_INTERNAL
           vi.  If sourcing deliverables are amended then return SOURCING
           vii.  If all deliverables are amended then return ALL
     3.  If no deliverables amended then return NONE
     **/


    FUNCTION deliverables_amended (
        p_api_version      IN  NUMBER,
        p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_data         OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,

        p_doctype         IN  VARCHAR2,
        p_docid           IN  NUMBER
    ) RETURN VARCHAR2;


-- Bug#3272824 New API to get due date message text from newly seeded messages
FUNCTION getDueDateMsgText(
p_relative_st_date_event_id     IN   NUMBER     default null
,p_relative_end_date_event_id   IN   NUMBER     default null
,p_relative_st_date_duration    IN   NUMBER     default null
,p_relative_end_date_duration   IN   NUMBER     default null
,p_repeating_day_of_week        IN   VARCHAR2   default null
,p_repeating_day_of_month       IN   VARCHAR2   default null
,p_repeating_duration           IN   NUMBER     default null
,p_print_due_date_msg_name      IN   VARCHAR2   default null
,p_fixed_start_date             IN   DATE       default null
,p_fixed_end_date               IN   DATE       default null
)
RETURN VARCHAR2;


/***
07-APR-2004 pnayani -- bug#3524864 added copy_response_deliverables API
This API is invoked from OKC_TERMS_COPY_GRP.COPY_RESPONSE_DOC.
Initially coded to support proxy bidding functionality in Sourcing.
Copies deliverables from source response doc to target response documents (bid to bid)
The procedure will query deliverables from source response
business document.
Parameter Details:
p_source_doc_id :       Source document Id
p_source_doc_type :     Source document type
p_target_doc_id   :     Target document Id
p_target_doc_type :     Target document Type
p_target_doc_number :   Target document Number
***/

PROCEDURE copy_response_deliverables (
p_api_version           IN NUMBER,
p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
p_source_doc_id             IN NUMBER,
p_source_doc_type           IN VARCHAR2,
p_target_doc_id             IN NUMBER,
p_target_doc_type           IN VARCHAR2,
p_target_doc_number         IN VARCHAR2,
x_msg_data              OUT NOCOPY VARCHAR2,
x_msg_count                 OUT NOCOPY NUMBER,
x_return_status             OUT NOCOPY VARCHAR2) ;


-- Creates status history for a given deliverable status history table
PROCEDURE create_del_status_history(
	p_api_version       IN NUMBER,
	p_init_msg_list     IN VARCHAR2,
	p_del_st_hist_tab   IN delHistTabType,
	x_msg_data      OUT NOCOPY  VARCHAR2,
	x_msg_count     OUT NOCOPY  NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2);


/**
3635916 MODIFYING DELIVERABLE DOES NOT REMOVE RELATED CLAUSE
FROM AMENDMENT SUMMARY
This API will be invoked by
OKC_TERMS_UTIL_PVT.deliverable_amendment_exists()
Parameter Details:
p_bus_doc_id :       document Id
p_bus_doc_type :     document type
p_variable_code:     deliverable variable code
return value is Y or N based on the matching of deliverable
to the variable.
***/
FUNCTION deliverable_amendment_exists (
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
    p_bus_doc_type          IN VARCHAR2,
    p_bus_doc_id            IN NUMBER,
    p_variable_code         IN VARCHAR2,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;


/***
Function get_party_name
This API will be invoked by the Create/Update/ViewOnly Deliverable pages to display the
name for an External Party. The External Party could be VENDOR_ID from PO_VENDORS or
PARTY_ID from HZ_PARTIES
Parameter Details:
p_external_party_id: Unique Identifier from PO_VENDORS or HZ_PARTIES
p_external_party_role: Resp_Party_Code from OKC_RESP_PARTIES
***/
FUNCTION get_party_name(
p_external_party_id          IN  NUMBER,
p_external_party_role        IN  VARCHAR2)
RETURN VARCHAR2;


    -- bug#4075168 New API for Template Revision
    PROCEDURE CopyDelForTemplateRevision(
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
        p_source_doc_id             IN NUMBER,
        p_source_doc_type           IN VARCHAR2,
        p_target_doc_id             IN NUMBER,
        p_target_doc_type           IN VARCHAR2,
        p_target_doc_number         IN VARCHAR2,
        p_copy_del_attachments_yn   IN VARCHAR2 default 'Y',
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count                 OUT NOCOPY NUMBER,
        x_return_status             OUT NOCOPY VARCHAR2);


-- Start of comments
--API name      : deleteDeliverables
--Type          : Private.
--Function      : 1.  Deletes deliverables of the current version of the bus doc (-99).
--              : 2.  If p_revert_dels = 'Y",  re-creating deliverables with -99 version
--              :     from the deliverable definitions of the previous bus doc version.
--Usage         : This API is called from Repository while deleting a contract.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_bus_doc_id          IN NUMBER       Required
--                   Contract ID of the contract to be deleted
--              : p_bus_doc_type        IN VARCHAR2     Required
--                   Type of the contract to be deleted
--              : p_bus_doc_version     IN NUMBER       Required
--                   Version number of the contract to be deleted
--              : p_prev_del_active     IN VARCHAR2     Optional
--                   Flag which tells whether deliverables of the previous business
--                   document version are activated or not
--                   Default = 'N'
--              : p_revert_dels         IN VARCHAR2     Optional
--                   Flag which tells whether to recreate the -99 deliverables from
--                   the previous document version's deliverables. This will be "N" if
--                   the first version of the business document is being deleted
--                   Default = 'N'
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
PROCEDURE deleteDeliverables(
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
        p_commit                IN VARCHAR2:=FND_API.G_FALSE,
        p_bus_doc_id            IN NUMBER,
        p_bus_doc_type          IN VARCHAR2,
        p_bus_doc_version       IN NUMBER,
        p_prev_del_active       IN VARCHAR2 := 'N',
        p_revert_dels           IN VARCHAR2 := 'N',
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2);



END OKC_DELIVERABLE_PROCESS_PVT;

/
