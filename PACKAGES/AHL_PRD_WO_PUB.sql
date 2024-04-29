--------------------------------------------------------
--  DDL for Package AHL_PRD_WO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_WO_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPWOSS.pls 120.0.12010000.4 2009/03/04 00:04:34 sikumar noship $ */

TYPE WO_DETAILS_REC_TYPE IS RECORD
(
   WorkorderId NUMBER,
   ObjectVersionNumber NUMBER,
   WorkorderNumber VARCHAR2(80),
   Description VARCHAR2(240),
   StatusCode VARCHAR2(30),
   Status VARCHAR2(80),
   Priority VARCHAR2(80),
   OrganizationId NUMBER,
   OrganizationName VARCHAR2(240),
   DepartmentId NUMBER,
   DepartmentName VARCHAR2(240),
   ScheduledStartDate DATE,
   ScheduledEndDate DATE,
   ActualStartDate DATE,
   ActualEndDate DATE,
   UnitHeaderId NUMBER,
   UnitName VARCHAR2(4000),
   WorkorderItemNumber VARCHAR2(40),
   SerialNumber VARCHAR2(30),
   LotNumber VARCHAR2(80),
   VisitId NUMBER,
   VisitNumber NUMBER,
   VisitTaskId NUMBER,
   VisitTaskNumber NUMBER,
   VisitStatusCode VARCHAR2(30),
   VisitStartDate DATE,
   VisitEndDate DATE,
   EnigmaDocumentID VARCHAR2(240),
   EnigmaDocumentTitle VARCHAR2(240),
   ATACode VARCHAR2(240),
   Model VARCHAR2(240),
   RoutePublishingDate DATE,
   MrHeaderId NUMBER,
   MrTitle VARCHAR2(80),
   MrRouteId NUMBER,
   RouteId NUMBER,
   RouteTitle VARCHAR2(2000),
   RouteNumber VARCHAR2(30),
   ProjectName VARCHAR2(30),
   ProjectTaskName VARCHAR2(20),
   UnitEffectivityId NUMBER,
   NonRoutineId NUMBER,
   NonRoutineNumber VARCHAR2(64),
   HoldReasonCode   VARCHAR2(30),
   HoldReason VARCHAR2(80),
   IsUnitQuarantined VARCHAR2(1),
   IsCompleteEnabled VARCHAR2(1),
   IsPartsChangeEnabled VARCHAR2(1),
   IsNonRoutineCreationEnabled VARCHAR2(1),
   IsUpdateEnabled VARCHAR2(1),
   IsResTxnEnabled VARCHAR2(1),
   IsQualityEnabled VARCHAR2(1)
 );

------------------------
-- Declare Procedures --
------------------------

PROCEDURE get_workorder_details
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_WO_DETAILS_REC        OUT NOCOPY WO_DETAILS_REC_TYPE
);

TYPE OP_DETAILS_REC_TYPE IS RECORD
(
    WorkorderOperationId NUMBER,
    ObjectVersionNumber NUMBER,
    OperationSequenceNumber NUMBER,
    WorkorderId NUMBER,
    OperationCode VARCHAR2(216),
    Description VARCHAR2(4000),
    StatusCode VARCHAR2(30),
    Status VARCHAR2(80),
    OperationTypeCode VARCHAR2(30),
    OperationType VARCHAR2(80),
    DepartmentId NUMBER,
    DepartmentName VARCHAR2(240),
    ScheduledStartDate DATE,
    ScheduledEndDate DATE,
    ActualStartDate DATE,
    ActualEndDate DATE,
    IsUpdateEnabled VARCHAR2(1),
    IsQualityEnabled VARCHAR2(1)
 );

TYPE OP_TBL_TYPE IS TABLE OF OP_DETAILS_REC_TYPE INDEX BY BINARY_INTEGER;


PROCEDURE get_wo_operations_details
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 p_WoOperationId         IN            NUMBER,
 p_OperationSequence     IN            NUMBER,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_Operations            OUT NOCOPY    OP_TBL_TYPE
);

TYPE MTL_REQMTS_REC_TYPE IS RECORD
(
    ScheduledMaterialId NUMBER,
    WorkorderId NUMBER,
    OperationSequenceNumber NUMBER,
    InventoryItemId NUMBER,
    ItemNumber VARCHAR2(40),
    ItemDescription VARCHAR2(240),
    RequiredQuantity NUMBER,
    PartUOM VARCHAR2(25),
    RequiredDate DATE,
    ScheduledQuantity NUMBER,
    ScheduledDate DATE,
    IssuedQuantity NUMBER
 );

TYPE MTL_REQMTS_TBL_TYPE IS TABLE OF MTL_REQMTS_REC_TYPE INDEX BY BINARY_INTEGER;


PROCEDURE get_wo_mtl_reqmts
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 p_WoOperationId         IN            NUMBER,
 p_OperationSequence     IN            NUMBER,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_MaterialRequirementDetails  OUT NOCOPY MTL_REQMTS_TBL_TYPE
);

TYPE ASSOC_DOCS_REC_TYPE IS RECORD
(
    DocumentNumber VARCHAR2(30),
    DocumentTitle VARCHAR2(240),
    AsoObjectTypeDesc VARCHAR2(80),
    RevisionNumber VARCHAR2(30),
    Chapter VARCHAR2(30),
    Section VARCHAR2(30),
    Subject VARCHAR2(240),
    Page VARCHAR2(5),
    Figure VARCHAR2(30),
    Note VARCHAR2(2000)
 );

TYPE ASSOC_DOCS_TBL_TYPE IS TABLE OF ASSOC_DOCS_REC_TYPE INDEX BY BINARY_INTEGER;



PROCEDURE get_wo_assoc_documents
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_AssociatedDocuments   OUT NOCOPY ASSOC_DOCS_TBL_TYPE
);

TYPE TURNOVER_NOTES_REC_TYPE IS RECORD
(
    JtfNoteId NUMBER,
    SourceObjectId NUMBER,
    SourceObjectCode VARCHAR2(255),
    EnteredDate DATE,
    EnteredBy NUMBER,
    EnteredByName VARCHAR2(4000),
    Notes VARCHAR2(2000)
 );

TYPE TURNOVER_NOTES_TBL_TYPE IS TABLE OF TURNOVER_NOTES_REC_TYPE INDEX BY BINARY_INTEGER;


PROCEDURE get_wo_turnover_notes
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_TurnoverNotes         OUT NOCOPY TURNOVER_NOTES_TBL_TYPE
);

TYPE RES_TXNS_REC_TYPE IS RECORD
(
    TransactionId NUMBER,
    WorkorderId NUMBER,
    OperationSequenceNumber NUMBER,
    ResourceSequenceNumber NUMBER,
    ResourceId NUMBER,
    ResourceCode VARCHAR2(10),
    ResourceDescription VARCHAR2(240),
    ResourceType VARCHAR2(30),
    ResourceTypeCode VARCHAR2(255),
    EmployeeId NUMBER,
    EmployeeNumber VARCHAR2(30),
    EmployeeName VARCHAR2(240),
    SerialNumber VARCHAR2(30),
    StartTime DATE,
    EndTime DATE,
    Quantity NUMBER,
    UOMCode VARCHAR2(3),
    UOM VARCHAR2(25),
    UsageRateOrAmount NUMBER,
    ActivityId NUMBER,
    Activity VARCHAR2(10),
    ReasonId NUMBER,
    Reason VARCHAR2(30),
    Reference VARCHAR2(240),
    TransactionDate DATE,
    TransactionStatus VARCHAR2(80)
 );

TYPE RES_TXNS_TBL_TYPE IS TABLE OF RES_TXNS_REC_TYPE INDEX BY BINARY_INTEGER;


PROCEDURE get_wo_res_txns
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 p_WoOperationId         IN            NUMBER,
 p_OperationSequence     IN            NUMBER,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_DefaultResourceTransactions OUT NOCOPY RES_TXNS_TBL_TYPE,
 x_ResourceTransactions        OUT NOCOPY RES_TXNS_TBL_TYPE
);

TYPE QA_PLAN_ATR_REC_TYPE IS RECORD
(
   CharId NUMBER,
   PromptSequence NUMBER,
   Prompt VARCHAR2(240),
   DefaultValue VARCHAR2(240),
   IsListOfValue VARCHAR2(1),
   IsDisplayed VARCHAR2(1),
   IsMandatory VARCHAR2(1),
   IsReadOnly  VARCHAR2(1),
   DisplayLength NUMBER,
   DataType VARCHAR2(30)
 );

TYPE QA_PLAN_ATR_TBL_TYPE IS TABLE OF QA_PLAN_ATR_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE QA_PLAN_REC_TYPE IS RECORD
(
    PlanId NUMBER,
    OrganizationId NUMBER,
    PlanName VARCHAR2(80),
    PlanDescription VARCHAR2(240),
    QA_PLAN_ATR_TBL QA_PLAN_ATR_TBL_TYPE
);

TYPE QA_PLAN_ATRVAL_REC_TYPE IS RECORD
(
   CharId NUMBER,
   AttributeValue VARCHAR2(4000)
 );

TYPE QA_PLAN_ATRVAL_TBL_TYPE IS TABLE OF QA_PLAN_ATRVAL_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE QA_RESULT_REC_TYPE IS RECORD
(
    Occurence NUMBER,
    QA_PLAN_ATRVAL_TBL QA_PLAN_ATRVAL_TBL_TYPE
);

TYPE QA_RESULT_TBL_TYPE IS TABLE OF QA_RESULT_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE QA_RESULTS_REC_TYPE IS RECORD
(
    CollectionId NUMBER,
    PlanId NUMBER,
    QA_RESULT_TBL QA_RESULT_TBL_TYPE
);



PROCEDURE get_qa_plan_results
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 p_WoOperationId         IN            NUMBER,
 p_OperationSequence     IN            NUMBER,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_QaPlan                  OUT NOCOPY QA_PLAN_REC_TYPE,
 x_QaResults               OUT NOCOPY QA_RESULTS_REC_TYPE
);

TYPE OP_ALL_DETAILS_REC_TYPE IS RECORD
(
    WorkorderOperationId NUMBER,
    ObjectVersionNumber NUMBER,
    OperationSequenceNumber NUMBER,
    WorkorderId NUMBER,
    OperationCode VARCHAR2(216),
    Description VARCHAR2(4000),
    StatusCode VARCHAR2(30),
    Status VARCHAR2(80),
    OperationTypeCode VARCHAR2(30),
    OperationType VARCHAR2(80),
    DepartmentId NUMBER,
    DepartmentName VARCHAR2(240),
    ScheduledStartDate DATE,
    ScheduledEndDate DATE,
    ActualStartDate DATE,
    ActualEndDate DATE,
    IsUpdateEnabled VARCHAR2(1),
    IsQualityEnabled VARCHAR2(1),
    QAResults      QA_RESULTS_REC_TYPE
 );

TYPE OP_ALL_DETAILS_TBL IS TABLE OF OP_ALL_DETAILS_REC_TYPE INDEX BY BINARY_INTEGER;



PROCEDURE process_workorder
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WO_DETAILS_REC        IN            WO_DETAILS_REC_TYPE,
 p_Operations            IN            OP_ALL_DETAILS_TBL,
 p_TurnoverNotes         IN            TURNOVER_NOTES_TBL_TYPE,
 p_MaterialRequirementDetails  IN      MTL_REQMTS_TBL_TYPE,
 p_WO_QaResults          IN            QA_RESULTS_REC_TYPE,
 p_ResourceTransactions  IN            RES_TXNS_TBL_TYPE,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2
);

FUNCTION GET_MSG_DATA(p_msg_count IN NUMBER) RETURN VARCHAR2;

FUNCTION init_user_and_role(p_user_id IN VARCHAR2) RETURN VARCHAR2;

END AHL_PRD_WO_PUB;

/
