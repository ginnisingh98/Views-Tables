--------------------------------------------------------
--  DDL for Package WSM_WIP_LOT_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_WIP_LOT_TXN_PVT" AUTHID CURRENT_USER as
/* $Header: WSMVWIPS.pls 120.4 2006/06/14 22:07:40 skaradib noship $ */

    /* Record type for the transaction header */

    type WLTX_TRANSACTIONS_REC_TYPE is record
    (
        /* Transaction info */
        TRANSACTION_TYPE_ID             WSM_SPLIT_MERGE_TRANSACTIONS.TRANSACTION_TYPE_ID%TYPE,
        TRANSACTION_DATE                WSM_SPLIT_MERGE_TRANSACTIONS.TRANSACTION_DATE%TYPE,
        TRANSACTION_REFERENCE           WSM_SPLIT_MERGE_TRANSACTIONS.TRANSACTION_REFERENCE%TYPE,
        REASON_ID                       WSM_SPLIT_MERGE_TRANSACTIONS.REASON_ID%TYPE,
        TRANSACTION_ID                  WSM_SPLIT_MERGE_TRANSACTIONS.TRANSACTION_ID%TYPE,

        /*Added for MES*/
        EMPLOYEE_ID                     WSM_SPLIT_MERGE_TRANSACTIONS.EMPLOYEE_ID%TYPE,

        /* Org info */
        ORGANIZATION_CODE               org_organization_definitions.ORGANIZATION_CODE%TYPE,
        ORGANIZATION_ID                 WSM_SPLIT_MERGE_TRANSACTIONS.ORGANIZATION_ID%TYPE,

        ERROR_MESSAGE                   WSM_SPLIT_MERGE_TRANSACTIONS.ERROR_MESSAGE%TYPE,

        ATTRIBUTE_CATEGORY              WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE_CATEGORY%TYPE,
        ATTRIBUTE1                      WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE1%TYPE,
        ATTRIBUTE2                      WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE2%TYPE,
        ATTRIBUTE3                      WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE3%TYPE,
        ATTRIBUTE4                      WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE4%TYPE,
        ATTRIBUTE5                      WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE5%TYPE,
        ATTRIBUTE6                      WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE6%TYPE,
        ATTRIBUTE7                      WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE7%TYPE,
        ATTRIBUTE8                      WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE8%TYPE,
        ATTRIBUTE9                      WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE9%TYPE,
        ATTRIBUTE10                     WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE10%TYPE,
        ATTRIBUTE11                     WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE11%TYPE,
        ATTRIBUTE12                     WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE12%TYPE,
        ATTRIBUTE13                     WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE13%TYPE,
        ATTRIBUTE14                     WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE14%TYPE,
        ATTRIBUTE15                     WSM_SPLIT_MERGE_TRANSACTIONS.ATTRIBUTE15%TYPE

    );

    type WLTX_STARTING_JOBS_REC_TYPE is record
    (
        /* Job header kinda.....*/
        WIP_ENTITY_ID                           WSM_SM_STARTING_JOBS.WIP_ENTITY_ID%TYPE,
        WIP_ENTITY_NAME                         WSM_SM_STARTING_JOBS.WIP_ENTITY_NAME%TYPE,
        JOB_TYPE                                NUMBER,
        STATUS_TYPE                             WIP_DISCRETE_JOBS.status_type%type,
        DESCRIPTION                             WIP_ENTITIES.DESCRIPTION%type,
        REPRESENTATIVE_FLAG                     WSM_SM_STARTING_JOBS.REPRESENTATIVE_FLAG%TYPE,
        SERIAL_TRACK_FLAG                       NUMBER, -- ST : Serial Support Project --

        /* Primary info....*/
        CLASS_CODE                              WIP_DISCRETE_JOBS.CLASS_CODE%type,
        DEMAND_CLASS                            WIP_DISCRETE_JOBS.DEMAND_CLASS%type,
        ORGANIZATION_CODE                       org_organization_definitions.ORGANIZATION_CODE%TYPE,        /* Entry not in the base table */
        PRIMARY_ITEM_ID                         WSM_SM_STARTING_JOBS.PRIMARY_ITEM_ID%TYPE,
        ITEM_NAME                               mtl_system_items_b_kfv.concatenated_segments%type,
        ORGANIZATION_ID                         WSM_SM_STARTING_JOBS.ORGANIZATION_ID%TYPE,

        /* Current operation infor....*/
        INTRAOPERATION_STEP                     WSM_SM_STARTING_JOBS.INTRAOPERATION_STEP%TYPE,
        OPERATION_SEQ_NUM                       WIP_OPERATIONS.OPERATION_SEQ_NUM%TYPE,
        OPERATION_CODE                          BOM_STANDARD_OPERATIONS.OPERATION_CODE%TYPE,
        OPERATION_DESCRIPTION                   BOM_OPERATION_SEQUENCES.OPERATION_DESCRIPTION%TYPE,
        OPERATION_SEQ_ID                        WIP_OPERATIONS.OPERATION_SEQUENCE_ID%TYPE,
        STANDARD_OPERATION_ID                   WIP_OPERATIONS.STANDARD_OPERATION_ID%TYPE,
        DEPARTMENT_ID                           WSM_SM_STARTING_JOBS.DEPARTMENT_ID%TYPE,
        DEPARTMENT_CODE                         BOM_DEPARTMENTS.DEPARTMENT_CODE%TYPE,

        /* Quantity info */
        START_QUANTITY                          WSM_SM_STARTING_JOBS.job_START_QUANTITY%TYPE,
        QUANTITY_AVAILABLE                      WSM_SM_STARTING_JOBS.AVAILABLE_QUANTITY%TYPE,
        NET_QUANTITY                            WSM_SM_STARTING_JOBS.NET_QUANTITY%TYPE,

        /* BOM and routing */
        ROUTING_REFERENCE_ID                    WSM_SM_STARTING_JOBS.ROUTING_REFERENCE_ID%TYPE,
        BOM_REFERENCE_ID                        WSM_SM_STARTING_JOBS.BOM_REFERENCE_ID%TYPE,
        COMMON_BILL_SEQUENCE_ID                 WSM_SM_STARTING_JOBS.BILL_SEQUENCE_ID%TYPE,
        BOM_REVISION                            WSM_SM_STARTING_JOBS.BOM_REVISION%TYPE,
        BOM_REVISION_DATE                       WSM_SM_STARTING_JOBS.BOM_REVISION_DATE%TYPE,
        ALTERNATE_BOM_DESIGNATOR                WIP_DISCRETE_JOBS.ALTERNATE_BOM_DESIGNATOR%TYPE,
        ALTERNATE_ROUTING_DESIGNATOR            WIP_DISCRETE_JOBS.ALTERNATE_ROUTING_DESIGNATOR%TYPE,
        COMMON_ROUTING_SEQUENCE_ID              WSM_SM_STARTING_JOBS.ROUTING_SEQ_ID%TYPE,
        ROUTING_REVISION                        WSM_SM_STARTING_JOBS.ROUTING_REVISION%TYPE,
        ROUTING_REVISION_DATE                   WSM_SM_STARTING_JOBS.ROUTING_REVISION_DATE%TYPE,

        /* Completion subinv info.... */
        COMPLETION_SUBINVENTORY                 WSM_SM_STARTING_JOBS.COMPLETION_SUBINVENTORY%TYPE,
        COMPLETION_LOCATOR_ID                   WSM_SM_STARTING_JOBS.COMPLETION_LOCATOR_ID%TYPE,
        COMPLETION_LOCATOR                      mtl_item_locations_kfv.concatenated_segments%TYPE,

        /* Dates info... */
        DATE_RELEASED                           WIP_DISCRETE_JOBS.DATE_RELEASED%TYPE,
        SCHEDULED_START_DATE                    WSM_SM_STARTING_JOBS.SCHEDULED_START_DATE%TYPE,
        SCHEDULED_COMPLETION_DATE               WSM_SM_STARTING_JOBS.SCHEDULED_COMPLETION_DATE%TYPE,

        /* Parameters.... */
        COPRODUCTS_SUPPLY                       WSM_SM_STARTING_JOBS.COPRODUCTS_SUPPLY%TYPE,
        KANBAN_CARD_ID                          WIP_DISCRETE_JOBS.KANBAN_CARD_ID%TYPE,
        WIP_SUPPLY_TYPE                         WIP_DISCRETE_JOBS.WIP_SUPPLY_TYPE%TYPE,
        /* add wip_supply type..... */

        ATTRIBUTE_CATEGORY                      WSM_SM_STARTING_JOBS.ATTRIBUTE_CATEGORY%TYPE,
        ATTRIBUTE1                              WSM_SM_STARTING_JOBS.ATTRIBUTE1%TYPE,
        ATTRIBUTE2                              WSM_SM_STARTING_JOBS.ATTRIBUTE2%TYPE,
        ATTRIBUTE3                              WSM_SM_STARTING_JOBS.ATTRIBUTE3%TYPE,
        ATTRIBUTE4                              WSM_SM_STARTING_JOBS.ATTRIBUTE4%TYPE,
        ATTRIBUTE5                              WSM_SM_STARTING_JOBS.ATTRIBUTE5%TYPE,
        ATTRIBUTE6                              WSM_SM_STARTING_JOBS.ATTRIBUTE6%TYPE,
        ATTRIBUTE7                              WSM_SM_STARTING_JOBS.ATTRIBUTE7%TYPE,
        ATTRIBUTE8                              WSM_SM_STARTING_JOBS.ATTRIBUTE8%TYPE,
        ATTRIBUTE9                              WSM_SM_STARTING_JOBS.ATTRIBUTE9%TYPE,
        ATTRIBUTE10                             WSM_SM_STARTING_JOBS.ATTRIBUTE10%TYPE,
        ATTRIBUTE11                             WSM_SM_STARTING_JOBS.ATTRIBUTE11%TYPE,
        ATTRIBUTE12                             WSM_SM_STARTING_JOBS.ATTRIBUTE12%TYPE,
        ATTRIBUTE13                             WSM_SM_STARTING_JOBS.ATTRIBUTE13%TYPE,
        ATTRIBUTE14                             WSM_SM_STARTING_JOBS.ATTRIBUTE14%TYPE,
        ATTRIBUTE15                             WSM_SM_STARTING_JOBS.ATTRIBUTE15%TYPE

    );


    type WLTX_RESULTING_JOBS_REC_TYPE is record
    (
        /* jOB HEADER */
        WIP_ENTITY_NAME                        WSM_SM_RESULTING_JOBS.WIP_ENTITY_NAME%TYPE,
        WIP_ENTITY_ID                          WSM_SM_RESULTING_JOBS.WIP_ENTITY_ID%TYPE,
        DESCRIPTION                            WSM_SM_RESULTING_JOBS.DESCRIPTION%TYPE,
        JOB_TYPE                               WSM_SM_RESULTING_JOBS.JOB_TYPE%TYPE,
        STATUS_TYPE                            WIP_DISCRETE_JOBS.STATUS_TYPE%TYPE,
        wip_supply_type                        WIP_DISCRETE_JOBS.wip_supply_type%TYPE,

        /* Primary details */
        ORGANIZATION_ID                        WSM_SM_RESULTING_JOBS.ORGANIZATION_ID%TYPE,
        ORGANIZATION_CODE                       org_organization_definitions.ORGANIZATION_CODE%TYPE,        /* Entry not in the base table */
        ITEM_NAME                              MTL_SYSTEM_ITEMS_B_KFV.CONCATENATED_SEGMENTS%TYPE,
        PRIMARY_ITEM_ID                        WSM_SM_RESULTING_JOBS.PRIMARY_ITEM_ID%TYPE,
        CLASS_CODE                             WSM_SM_RESULTING_JOBS.CLASS_CODE%TYPE,

        /* Bom and Routing */
        BOM_REFERENCE_ITEM                     MTL_SYSTEM_ITEMS_B_KFV.CONCATENATED_SEGMENTS%TYPE,
        BOM_REFERENCE_ID                       WSM_SM_RESULTING_JOBS.BOM_REFERENCE_ID%TYPE,

        ROUTING_REFERENCE_ITEM                 MTL_SYSTEM_ITEMS_B_KFV.CONCATENATED_SEGMENTS%TYPE,
        ROUTING_REFERENCE_ID                   WSM_SM_RESULTING_JOBS.ROUTING_REFERENCE_ID%TYPE,
        COMMON_BOM_SEQUENCE_ID                 WSM_SM_RESULTING_JOBS.COMMON_BOM_SEQUENCE_ID%TYPE,
        COMMON_ROUTING_SEQUENCE_ID             WSM_SM_RESULTING_JOBS.COMMON_ROUTING_SEQUENCE_ID%TYPE,
        BOM_REVISION                           WSM_SM_RESULTING_JOBS.BOM_REVISION%TYPE,
        ROUTING_REVISION                       WSM_SM_RESULTING_JOBS.ROUTING_REVISION%TYPE,
        BOM_REVISION_DATE                      WSM_SM_RESULTING_JOBS.BOM_REVISION_DATE%TYPE,
        ROUTING_REVISION_DATE                  WSM_SM_RESULTING_JOBS.ROUTING_REVISION_DATE%TYPE,
        ALTERNATE_BOM_DESIGNATOR               WSM_SM_RESULTING_JOBS.ALTERNATE_BOM_DESIGNATOR%TYPE,
        ALTERNATE_ROUTING_DESIGNATOR           WSM_SM_RESULTING_JOBS.ALTERNATE_ROUTING_DESIGNATOR%TYPE,

        /* Quantity */
        START_QUANTITY                         WSM_SM_RESULTING_JOBS.START_QUANTITY%TYPE,
        NET_QUANTITY                           WSM_SM_RESULTING_JOBS.NET_QUANTITY%TYPE,

        /* Starting operation */
        STARTING_OPERATION_SEQ_NUM             WSM_SM_RESULTING_JOBS.STARTING_OPERATION_SEQ_NUM%TYPE,
        STARTING_INTRAOPERATION_STEP           WSM_SM_RESULTING_JOBS.STARTING_INTRAOPERATION_STEP%TYPE,
        STARTING_OPERATION_CODE                WSM_SM_RESULTING_JOBS.STARTING_OPERATION_CODE%TYPE,
        STARTING_OPERATION_SEQ_ID              BOM_OPERATION_SEQUENCES.OPERATION_SEQUENCE_ID%TYPE,
        STARTING_STD_OP_ID                     WSM_SM_RESULTING_JOBS.STARTING_STD_OP_ID%TYPE,
        DEPARTMENT_ID                          BOM_DEPARTMENTS.DEPARTMENT_ID%TYPE,
        DEPARTMENT_CODE                        BOM_DEPARTMENTS.DEPARTMENT_CODE%TYPE,
        OPERATION_DESCRIPTION                  BOM_OPERATION_SEQUENCES.OPERATION_DESCRIPTION%TYPE,

        JOB_OPERATION_SEQ_NUM                  WSM_SM_RESULTING_JOBS.JOB_OPERATION_SEQ_NUM%TYPE,

        /* Specifi to split txn...*/
        SPLIT_HAS_UPDATE_ASSY                  WSM_SM_RESULTING_JOBS.SPLIT_HAS_UPDATE_ASSY%TYPE,

        /* Completion sub inv details...*/
        COMPLETION_SUBINVENTORY                WSM_SM_RESULTING_JOBS.COMPLETION_SUBINVENTORY%TYPE,
        COMPLETION_LOCATOR_ID                  WSM_SM_RESULTING_JOBS.COMPLETION_LOCATOR_ID%TYPE,
        COMPLETION_LOCATOR                      mtl_item_locations_kfv.concatenated_segments%TYPE,

        /* Dates */
        SCHEDULED_START_DATE                   WSM_SM_RESULTING_JOBS.SCHEDULED_START_DATE%TYPE,
        SCHEDULED_COMPLETION_DATE              WSM_SM_RESULTING_JOBS.SCHEDULED_COMPLETION_DATE%TYPE,

        /* Other parameters */
        BONUS_ACCT_ID                          WSM_SM_RESULTING_JOBS.BONUS_ACCT_ID%TYPE,
        COPRODUCTS_SUPPLY                      WSM_SM_RESULTING_JOBS.COPRODUCTS_SUPPLY%TYPE,
        KANBAN_CARD_ID                         WIP_DISCRETE_JOBS.KANBAN_CARD_ID%TYPE,

        ATTRIBUTE_CATEGORY                     WSM_SM_RESULTING_JOBS.ATTRIBUTE_CATEGORY%TYPE,
        ATTRIBUTE1                             WSM_SM_RESULTING_JOBS.ATTRIBUTE1%TYPE,
        ATTRIBUTE2                             WSM_SM_RESULTING_JOBS.ATTRIBUTE2%TYPE,
        ATTRIBUTE3                             WSM_SM_RESULTING_JOBS.ATTRIBUTE3%TYPE,
        ATTRIBUTE4                             WSM_SM_RESULTING_JOBS.ATTRIBUTE4%TYPE,
        ATTRIBUTE5                             WSM_SM_RESULTING_JOBS.ATTRIBUTE5%TYPE,
        ATTRIBUTE6                             WSM_SM_RESULTING_JOBS.ATTRIBUTE6%TYPE,
        ATTRIBUTE7                             WSM_SM_RESULTING_JOBS.ATTRIBUTE7%TYPE,
        ATTRIBUTE8                             WSM_SM_RESULTING_JOBS.ATTRIBUTE8%TYPE,
        ATTRIBUTE9                             WSM_SM_RESULTING_JOBS.ATTRIBUTE9%TYPE,
        ATTRIBUTE10                            WSM_SM_RESULTING_JOBS.ATTRIBUTE10%TYPE,
        ATTRIBUTE11                            WSM_SM_RESULTING_JOBS.ATTRIBUTE11%TYPE,
        ATTRIBUTE12                            WSM_SM_RESULTING_JOBS.ATTRIBUTE12%TYPE,
        ATTRIBUTE13                            WSM_SM_RESULTING_JOBS.ATTRIBUTE13%TYPE,
        ATTRIBUTE14                            WSM_SM_RESULTING_JOBS.ATTRIBUTE14%TYPE,
        ATTRIBUTE15                            WSM_SM_RESULTING_JOBS.ATTRIBUTE15%TYPE --,

        /* Request ID and other WHO columns will be obtained from the header record for every txn

        REQUEST_ID                              WSM_SM_STARTING_JOBS.REQUEST_ID%TYPE,
        PROGRAM_APPLICATION_ID                  WSM_SM_STARTING_JOBS.PROGRAM_APPLICATION_ID%TYPE,
        PROGRAM_ID                              WSM_SM_STARTING_JOBS.PROGRAM_ID%TYPE,
        PROGRAM_UPDATE_DATE                     WSM_SM_STARTING_JOBS.PROGRAM_UPDATE_DATE%TYPE,


        LAST_UPDATE_DATE                        WSM_SM_STARTING_JOBS.LAST_UPDATE_DATE%TYPE,
        LAST_UPDATED_BY                         WSM_SM_STARTING_JOBS.LAST_UPDATED_BY%TYPE,
        CREATION_DATE                           WSM_SM_STARTING_JOBS.CREATION_DATE%TYPE,
        CREATED_BY                              WSM_SM_STARTING_JOBS.CREATED_BY%TYPE,
        LAST_UPDATE_LOGIN                       WSM_SM_STARTING_JOBS.LAST_UPDATE_LOGIN%TYPE */

   );


   TYPE WSM_JOB_SECONDARY_QTY_REC_TYPE IS RECORD
   (
     wip_entity_id         wip_entities.wip_entity_id%type,
     wip_entity_name       wip_entities.wip_entity_name%type,
     organization_id       wsm_job_secondary_quantities.organization_id%type,
     uom_code              wsm_job_secondary_quantities.uom_code%type,
     current_quantity      wsm_job_secondary_quantities.current_quantity%type,
     currently_active      wsm_job_secondary_quantities.currently_active%type
   );

   type WSM_JOB_SECONDARY_QTY_TBL_TYPE is table of WSM_JOB_SECONDARY_QTY_REC_TYPE index by BINARY_INTEGER;

   type WLTX_STARTING_JOBS_TBL_TYPE is table of WLTX_STARTING_JOBS_REC_TYPE index by BINARY_INTEGER;
   type WLTX_RESULTING_JOBS_TBL_TYPE is table of WLTX_RESULTING_JOBS_REC_TYPE index by BINARY_INTEGER;

   -- Public APIs
   -- ST : Added for bug 5263262
   -- OverLoaded procedure created for the bug...
   PROCEDURE invoke_txn_API ( p_api_version          IN                 NUMBER                                          ,
                              p_commit               IN                 VARCHAR2                                        ,
                              p_validation_level     IN                 NUMBER                                          ,
                              p_init_msg_list        IN                 VARCHAR2        DEFAULT NULL                    ,
                              p_calling_mode         IN                 NUMBER                                          ,
                              p_txn_header_rec       IN                 WLTX_TRANSACTIONS_REC_TYPE                      ,
                              p_starting_jobs_tbl    IN                 WLTX_STARTING_JOBS_TBL_TYPE                     ,
                              p_resulting_jobs_tbl   IN                 WLTX_RESULTING_JOBS_TBL_TYPE                    ,
                              P_wsm_serial_num_tbl   IN                 WSM_SERIAL_SUPPORT_GRP.WSM_SERIAL_NUM_TBL       ,
                              p_secondary_qty_tbl    IN                 WSM_JOB_SECONDARY_QTY_TBL_TYPE                  ,
                              -- ST : Added for bug 5263262 (Will have value 0 from interface and NULL from forms and MES) --
                              --bugs 5334285, 5334279 addition of the new optional parameter p_invoke_req_worker to procedure
                              --invoke_txn_API in package WSM_WIP_LOT_TXN_PVT caused WSMPLBMI to become invalid. Since notational
                              --parameters are used in WSMPLBMI and the new parameter is optional effectively there are signatures
                              --of invoke_txn_API matching this call. Hence making p_invoke_req_worker required without the default
                              --p_invoke_req_worker    IN                 NUMBER          DEFAULT NULL                    ,
                              p_invoke_req_worker    IN                 NUMBER                                          ,
                              x_return_status        OUT    NOCOPY      VARCHAR2                                        ,
                              x_msg_count            OUT    NOCOPY      NUMBER                                          ,
                              x_error_msg            OUT    NOCOPY      VARCHAR2
                            );


   PROCEDURE invoke_txn_API ( p_api_version          IN                 NUMBER                                          ,
                              p_commit               IN                 VARCHAR2                                        ,
                              p_validation_level     IN                 NUMBER                                          ,
                              p_init_msg_list        IN                 VARCHAR2        DEFAULT NULL                    ,
                              p_calling_mode         IN                 NUMBER                                          ,
                              p_txn_header_rec       IN                 WLTX_TRANSACTIONS_REC_TYPE                      ,
                              p_starting_jobs_tbl    IN                 WLTX_STARTING_JOBS_TBL_TYPE                     ,
                              p_resulting_jobs_tbl   IN                 WLTX_RESULTING_JOBS_TBL_TYPE                    ,
                              P_wsm_serial_num_tbl   IN                 WSM_SERIAL_SUPPORT_GRP.WSM_SERIAL_NUM_TBL       ,
                              p_secondary_qty_tbl    IN                 WSM_JOB_SECONDARY_QTY_TBL_TYPE                  ,
                              x_return_status        OUT    NOCOPY      VARCHAR2                                        ,
                              x_msg_count            OUT    NOCOPY      NUMBER                                          ,
                              x_error_msg            OUT    NOCOPY      VARCHAR2
                            );

   -- API for Split transaction....
   PROCEDURE SPLIT_TXN        ( p_api_version                           IN              NUMBER                          ,
                                p_commit                                IN              VARCHAR2        DEFAULT NULL    ,
                                p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL    ,
                                p_validation_level                      IN              NUMBER          DEFAULT NULL    ,
                                p_calling_mode                          IN              NUMBER                          ,
                                p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE      ,
                                p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE     ,
                                p_wltx_resulting_jobs_tbl               IN OUT  NOCOPY  WLTX_RESULTING_JOBS_TBL_TYPE    ,
                                p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE  ,
                                x_return_status                         OUT     NOCOPY  VARCHAR2                        ,
                                x_msg_count                             OUT     NOCOPY  NUMBER                          ,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                                );

    /* API for Merge transaction.... */
    PROCEDURE MERGE_TXN  (      p_api_version                           IN              NUMBER                          ,
                                p_commit                                IN              VARCHAR2        DEFAULT NULL    ,
                                p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL    ,
                                p_validation_level                      IN              NUMBER          DEFAULT NULL    ,
                                p_calling_mode                          IN              NUMBER                          ,
                                p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE      ,
                                p_wltx_starting_jobs_tbl                IN OUT  NOCOPY  WLTX_STARTING_JOBS_TBL_TYPE     ,
                                p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE    ,
                                p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE  ,
                                x_return_status                         OUT     NOCOPY  VARCHAR2                        ,
                                x_msg_count                             OUT     NOCOPY  NUMBER                          ,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                        );


    /* API for Update Assembly transaction.... */
    PROCEDURE UPDATE_ASSEMBLY_TXN (     p_api_version                           IN              NUMBER,
                                        p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                        p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                        p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                        p_calling_mode                          IN              NUMBER,
                                        p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                        p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE,
                                        p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                        p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                                        x_return_status                         OUT     NOCOPY  VARCHAR2,
                                        x_msg_count                             OUT     NOCOPY  NUMBER,
                                        x_msg_data                              OUT     NOCOPY  VARCHAR2
                                     );

   /* API for Update Routing transaction.... */
   PROCEDURE UPDATE_ROUTING_TXN (       p_api_version                           IN              NUMBER,
                                        p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                        p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                        p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                        p_calling_mode                          IN              NUMBER,
                                        p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                        p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE,
                                        p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                        p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                                        x_return_status                         OUT     NOCOPY  VARCHAR2,
                                        x_msg_count                             OUT     NOCOPY  NUMBER,
                                        x_msg_data                              OUT     NOCOPY  VARCHAR2
                                );

   /* API for Update Quantity transaction.... */
   PROCEDURE UPDATE_QUANTITY_TXN (      p_api_version                           IN              NUMBER,
                                        p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                        p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                        p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                        p_calling_mode                          IN              NUMBER,
                                        p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                        p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE,
                                        p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                        p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                                        x_return_status                         OUT     NOCOPY  VARCHAR2,
                                        x_msg_count                             OUT     NOCOPY  NUMBER,
                                        x_msg_data                              OUT     NOCOPY  VARCHAR2
                                );

   /* API for Update Lot name transaction.... */
   PROCEDURE UPDATE_LOTNAME_TXN (       p_api_version                           IN              NUMBER                          ,
                                        p_commit                                IN              VARCHAR2        DEFAULT NULL    ,
                                        p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL    ,
                                        p_validation_level                      IN              NUMBER          DEFAULT NULL    ,
                                        p_calling_mode                          IN              NUMBER                          ,
                                        p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE      ,
                                        p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE     ,
                                        p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE    ,
                                        p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE  ,
                                        x_return_status                         OUT     NOCOPY  VARCHAR2                        ,
                                        x_msg_count                             OUT     NOCOPY  NUMBER                          ,
                                        x_msg_data                              OUT     NOCOPY  VARCHAR2
                                    );

     Procedure BONUS_TXN        (       p_api_version                           IN              NUMBER                          ,
                                        p_commit                                IN              VARCHAR2        DEFAULT NULL    ,
                                        p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL    ,
                                        p_validation_level                      IN              NUMBER          DEFAULT NULL    ,
                                        p_calling_mode                          IN              NUMBER                          ,
                                        p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE      ,
                                        p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE    ,
                                        p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE  ,
                                        x_return_status                         OUT     NOCOPY  VARCHAR2                        ,
                                        x_msg_count                             OUT     NOCOPY  NUMBER                          ,
                                        x_msg_data                              OUT     NOCOPY  VARCHAR2
                                );

  /* APIs not coded.... start */
  PROCEDURE UPDATE_BOM     (    p_api_version                           IN              VARCHAR2                        ,
                                p_commit                                IN              VARCHAR2        DEFAULT NULL    ,
                                p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL    ,
                                p_validation_level                      IN              NUMBER          DEFAULT NULL    ,
                                p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE      ,
                                p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE     ,
                                p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE    ,
                                x_return_status                         OUT     NOCOPY  VARCHAR2                        ,
                                x_msg_count                             OUT     NOCOPY  NUMBER                          ,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                               );

  PROCEDURE UPDATE_STATUS     ( p_api_version                           IN              VARCHAR2                        ,
                                p_commit                                IN              VARCHAR2        DEFAULT NULL    ,
                                p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL    ,
                                p_validation_level                      IN              NUMBER          DEFAULT NULL    ,
                                p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE      ,
                                p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE     ,
                                p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE    ,
                                x_return_status                         OUT     NOCOPY  VARCHAR2                        ,
                                x_msg_count                             OUT     NOCOPY  NUMBER                          ,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                               );


  PROCEDURE UPDATE_COMP_SUBINV_LOC(     p_api_version                           IN              VARCHAR2                        ,
                                        p_commit                                IN              VARCHAR2        DEFAULT NULL    ,
                                        p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL    ,
                                        p_validation_level                      IN              NUMBER          DEFAULT NULL    ,
                                        p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE      ,
                                        p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE     ,
                                        p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE    ,
                                        x_return_status                         OUT     NOCOPY  VARCHAR2                        ,
                                        x_msg_count                             OUT     NOCOPY  NUMBER                          ,
                                        x_msg_data                              OUT     NOCOPY  VARCHAR2
                               );

  -- This procedure is added to log the transaction related data..
  Procedure Log_transaction_data ( p_txn_header_rec       IN            WLTX_TRANSACTIONS_REC_TYPE                      ,
                                   p_starting_jobs_tbl    IN            WLTX_STARTING_JOBS_TBL_TYPE                     ,
                                   p_resulting_jobs_tbl   IN            WLTX_RESULTING_JOBS_TBL_TYPE                    ,
                                   p_secondary_qty_tbl    IN            WSM_JOB_SECONDARY_QTY_TBL_TYPE                  ,
                                   x_return_status        OUT    NOCOPY VARCHAR2                                        ,
                                   x_msg_count            OUT    NOCOPY NUMBER                                          ,
                                   x_error_msg            OUT    NOCOPY VARCHAR2
                                 );
  /* APIs not coded.... end */
end WSM_WIP_LOT_TXN_PVT;

 

/
