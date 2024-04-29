--------------------------------------------------------
--  DDL for Package CSD_HV_WIP_JOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_HV_WIP_JOB_PVT" AUTHID CURRENT_USER as
/* $Header: csdvhvjs.pls 120.10.12010000.9 2010/06/07 23:45:40 swai ship $ */
-- Start of Comments
-- Package name     : CSD_HV_WIP_JOB_PVT
-- Purpose          : This package is used for High Volume Repair Execution flow
--
--
-- History          : 05/01/2005, Created by Shiv Ragunathan
-- History          :
-- History          :
-- NOTE             :
-- End of Comments


-- Record Type for job header information

TYPE JOB_HEADER_REC_TYPE IS RECORD   (
JOB_PREFIX                                         VARCHAR2(80),
ORGANIZATION_ID                                    NUMBER,
STATUS_type                                        NUMBER,
SCHEDULED_START_DATE                               DATE,
SCHEDULED_END_DATE                                 DATE,
INVENTORY_ITEM_ID                                  NUMBER,
CLASS_CODE                                         VARCHAR2(10),
QUANTITY                                           NUMBER,
routing_reference_id                               NUMBER,
bom_reference_id                                   NUMBER,
alternate_routing_designator                       VARCHAR2(10),
alternate_bom_designator                           VARCHAR2(10),
COMPLETION_SUBINVENTORY                            VARCHAR2(10),
COMPLETION_LOCATOR_ID                              NUMBER,
JOB_NAME                                           VARCHAR2(240),
GROUP_ID                                            NUMBER
);


TYPE JOB_DTLS_REC_TYPE IS RECORD   (
WIP_ENTITY_ID                                       NUMBER,
INVENTORY_ITEM_ID                                   NUMBER,
ORGANIZATION_ID                                     NUMBER,
TRANSACTION_QUANTITY                                NUMBER,
COMPLETION_SUBINVENTORY                             VARCHAR2(10),
COMPLETION_LOCATOR_ID                               NUMBER,
TRANSACTION_UOM                                     VARCHAR2(3),
REVISION_QTY_CONTROl_CODE                           NUMBER,
SERIAL_NUMBER_CONTROL_CODE                          NUMBER,
LOT_CONTROL_CODE                                    NUMBER );

TYPE MV_TXN_DTLS_REC_TYPE IS RECORD (
          WIP_ENTITY_NAME           VARCHAR2(240)
         ,ORGANIZATION_ID           NUMBER
         ,FM_OPERATION_SEQ_NUM      NUMBER
         ,TO_OPERATION_SEQ_NUM      NUMBER
         ,TRANSACTION_QUANTITY      NUMBER
         ,TRANSACTION_UOM           VARCHAR2(3)
         ,WIP_ENTITY_ID            NUMBER
);

-- Table Type corresponding to JOB_BILL_ROUTING_REC_TYPE

TYPE  MV_TXN_DTLS_TBL_TYPE IS TABLE OF MV_TXN_DTLS_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE MTL_TXN_DTLS_REC_TYPE IS RECORD (
          WIP_TRANSACTION_DETAIL_ID NUMBER
         ,REQUIRED_QUANTITY        NUMBER
         ,ISSUED_QUANTITY          NUMBER
         ,JOB_QUANTITY             NUMBER
         ,OP_SCHEDULED_QUANTITY    NUMBER
         ,INVENTORY_ITEM_ID         NUMBER
         ,WIP_ENTITY_ID             NUMBER
         ,ORGANIZATION_ID           NUMBER
         ,OPERATION_SEQ_NUM         NUMBER
         ,TRANSACTION_QUANTITY      NUMBER
         ,TRANSACTION_UOM           VARCHAR2(3)
         ,UOM_CODE                  VARCHAR2(3)
         ,SERIAL_NUMBER             VARCHAR2(30)
         ,LOT_NUMBER                VARCHAR2(80) -- fix for bug#4625226
         ,REVISION                  VARCHAR2(3)
         ,revision_qty_control_code NUMBER
         ,SERIAL_NUMBER_CONTROL_CODE NUMBER
         ,lot_control_code          NUMBER
         ,SUPPLY_SUBINVENTORY       VARCHAR2(10)
         ,SUPPLY_LOCATOR_ID         NUMBER
         ,TRANSACTION_INTERFACE_ID  NUMBER
         ,OBJECT_VERSION_NUMBER     NUMBER
         ,NEW_ROW                   VARCHAR2(1)
         ,REASON_ID                 NUMBER  -- swai bug 6841113
);

-- Table Type corresponding to JOB_BILL_ROUTING_REC_TYPE

TYPE  MTL_TXN_DTLS_TBL_TYPE IS TABLE OF MTL_TXN_DTLS_REC_TYPE INDEX BY BINARY_INTEGER;




TYPE RES_TXN_DTLS_REC_TYPE IS RECORD (
          WIP_TRANSACTION_DETAIL_ID NUMBER
         ,required_quantity   NUMBER
         ,applied_quantity    NUMBER
         ,pending_quantity    NUMBER
         ,job_quantity        NUMBER
         ,op_scheduled_quantity NUMBER
         ,basis_type              NUMBER
         ,RESOURCE_ID         NUMBER
         ,RESOURCE_SEQ_NUM         NUMBER
         ,WIP_ENTITY_ID             NUMBER
         ,ORGANIZATION_ID           NUMBER
         ,ORGANIZATION_CODE         VARCHAR2(3)
         ,OPERATION_SEQ_NUM         NUMBER
         ,TRANSACTION_QUANTITY      NUMBER
         ,TRANSACTION_UOM           VARCHAR2(3)
         ,UOM_CODE                  VARCHAR2(3)
         ,WIP_ENTITY_NAME           VARCHAR2(80)
         ,employee_id               NUMBER
         ,EMPLOYEE_NUM              VARCHAR2(30)
         ,OBJECT_VERSION_NUMBER     NUMBER
         ,NEW_ROW                   VARCHAR2(1)
);

-- Table Type corresponding to JOB_BILL_ROUTING_REC_TYPE

TYPE  RES_TXN_DTLS_TBL_TYPE IS TABLE OF RES_TXN_DTLS_REC_TYPE INDEX BY BINARY_INTEGER;



TYPE OP_DTLS_REC_TYPE IS RECORD (
          WIP_TRANSACTION_DETAIL_ID NUMBER
         ,BACKFLUSH_FLAG            NUMBER      -- swai: 4948649
         ,COUNT_POINT_TYPE          NUMBER      -- swai: 4948649
         ,DEPARTMENT_ID             NUMBER
         ,DESCRIPTION               VARCHAR2(240)
         ,FIRST_UNIT_COMPLETION_DATE   DATE     -- swai: 4948649
         ,FIRST_UNIT_START_DATE     DATE        -- swai: 4948649
         ,LAST_UNIT_COMPLETION_DATE DATE
         ,LAST_UNIT_START_DATE      DATE        -- swai: 4948649
         ,MINIMUM_TRANSFER_QUANTITY NUMBER      -- swai: 4948649
         ,OPERATION_SEQ_NUM         NUMBER
         ,STANDARD_OPERATION_ID     NUMBER
         ,WIP_ENTITY_ID             NUMBER
         ,ORGANIZATION_ID           NUMBER
         ,ORGANIZATION_CODE         VARCHAR2(3)
         ,WIP_ENTITY_NAME           VARCHAR2(80)
         ,OBJECT_VERSION_NUMBER     NUMBER
         ,NEW_ROW                   VARCHAR2(1)
);

-- Table Type corresponding to OP_DTLS_REC_TYPE

TYPE  OP_DTLS_TBL_TYPE IS TABLE OF OP_DTLS_REC_TYPE INDEX BY BINARY_INTEGER;


-- Record Type for service code information.

TYPE SERVICE_CODE_REC_TYPE IS RECORD (
ro_service_code_id                                 NUMBER,
inventory_item_id                                  NUMBER,
service_code_id                                    NUMBER,
object_version_number                              NUMBER
);


-- Table Type corresponding to SERVICE_CODE_REC_TYPE

TYPE  SERVICE_CODE_TBL_TYPE IS TABLE OF SERVICE_CODE_REC_TYPE  INDEX BY BINARY_INTEGER;

-- swai: bug 7182047 (FP of 6995498) wrapper function to get the default item
-- revision. Depending on the transaction type, check the corresponding profile
-- option and return null if the profile is No.
-- Transaction types are 'MAT_ISSUE' and 'JOB_COMP'.  Passing null for
-- transaction type will always return a default from bom_revsions API.
FUNCTION get_default_item_revision
(
    p_org_id                                  IN         NUMBER,
    p_inventory_item_id                       IN         NUMBER,
    p_transaction_date                        IN         DATE,
    p_mat_transaction_type                    IN         VARCHAR2 := null
) RETURN VARCHAR2;

FUNCTION get_pending_quantity( p_wip_entity_id NUMBER,
                               p_operation_seq_num NUMBER,
                               p_resource_seq_num NUMBER,
                               p_primary_uom VARCHAR2 )
                                RETURN NUMBER ;

PROCEDURE process_oper_comp_txn
(
    p_api_version_number                        IN          NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                    IN          VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                             OUT   NOCOPY   VARCHAR2,
    x_msg_count                                  OUT  NOCOPY      NUMBER,
    x_msg_data                                OUT      NOCOPY     VARCHAR2,
    p_mv_txn_dtls_tbl                        IN       MV_TXN_DTLS_TBL_TYPE
);

--
-- Inserts the transaction line(s) for job completion and then
-- processes the transaction lines if there are no details needed
-- OUT param:
-- x_transaction_header_id: If details are needed, the transaction
--                          header ID will be populated.  Otherwise
--                          parameter is null.
--
PROCEDURE process_job_comp_txn
(
    p_api_version_number                      IN         NUMBER,
    p_init_msg_list                           IN         VARCHAR2 ,
    p_commit                                  IN         VARCHAR2 ,
    p_validation_level                        IN         NUMBER,
    x_return_status                           OUT NOCOPY VARCHAR2,
    x_msg_count                               OUT NOCOPY NUMBER,
    x_msg_data                                OUT NOCOPY VARCHAR2,
    p_comp_job_dtls_rec                       IN         JOB_DTLS_REC_TYPE,
    --x_need_details_flag                     OUT     NOCOPY  VARCHAR2
    x_transaction_header_id                   OUT NOCOPY NUMBER
);

--
-- Inserts the transaction line(s) for job completion
-- Does NOT process the transaction lines
-- OUT params:
-- x_need_details_flag: set to 'T' if details are neede, otherwise 'F'
-- x_transaction_header_id: Transaction header ID always passed back
--                          regardless of need details param
--
PROCEDURE insert_job_comp_txn
(
    p_api_version_number                      IN         NUMBER,
    p_init_msg_list                           IN         VARCHAR2 ,
    p_commit                                  IN         VARCHAR2 ,
    p_validation_level                        IN         NUMBER,
    x_return_status                           OUT NOCOPY VARCHAR2,
    x_msg_count                               OUT NOCOPY NUMBER,
    x_msg_data                                OUT NOCOPY VARCHAR2,
    p_comp_job_dtls_rec                       IN         JOB_DTLS_REC_TYPE,
    x_need_details_flag                       OUT NOCOPY VARCHAR2,
    x_transaction_header_id                   OUT NOCOPY NUMBER
);

PROCEDURE process_mti_transactions
(
    p_api_version_number                      IN         NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                  IN         VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                           OUT NOCOPY VARCHAR2,
    x_msg_count                               OUT NOCOPY NUMBER,
    x_msg_data                                OUT NOCOPY VARCHAR2,
    p_txn_header_id                           IN         NUMBER
);


PROCEDURE process_issue_mtl_txn
(
    p_api_version_number                        IN          NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                    IN          VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                             OUT   NOCOPY   VARCHAR2,
    x_msg_count                                  OUT  NOCOPY      NUMBER,
    x_msg_data                                OUT      NOCOPY     VARCHAR2,
    p_mtl_txn_dtls_tbl                       IN       MTL_TXN_DTLS_TBL_TYPE,
  --  p_ro_quantity                               IN      NUMBER,
    x_transaction_header_id                     OUT     NOCOPY   NUMBER
);

--
-- Updates the transaction lines with lot and serial numbers
-- and the processes the transaction lines
--
PROCEDURE process_issue_mtl_txns_lot_srl
(
    p_api_version_number                      IN         NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                  IN         VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                           OUT NOCOPY VARCHAR2,
    x_msg_count                               OUT NOCOPY NUMBER,
    x_msg_data                                OUT NOCOPY VARCHAR2,
    p_mtl_txn_dtls_tbl                        IN         MTL_TXN_DTLS_TBL_TYPE,
    p_transaction_header_id                   IN         NUMBER
);

--
-- Updates the material transaction lines with lot and serial numbers only
-- Does NOT process the transaction lines
--
PROCEDURE update_mtl_txns_lot_srl
(
    p_api_version_number                      IN         NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                  IN         VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                           OUT NOCOPY VARCHAR2,
    x_msg_count                               OUT NOCOPY NUMBER,
    x_msg_data                                OUT NOCOPY VARCHAR2,
    p_mtl_txn_dtls_tbl                        IN         MTL_TXN_DTLS_TBL_TYPE,
    p_transaction_header_id                   IN         NUMBER
);

PROCEDURE process_transact_res_txn
(
    p_api_version_number                        IN          NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                    IN          VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                             OUT   NOCOPY   VARCHAR2,
    x_msg_count                                  OUT  NOCOPY      NUMBER,
    x_msg_data                                OUT      NOCOPY     VARCHAR2,
    p_res_txn_dtls_tbl                       IN       RES_TXN_DTLS_TBL_TYPE
 --   p_ro_quantity                               IN      NUMBER
);

PROCEDURE PROCESS_SAVE_MTL_TXN_DTLS
(
    p_api_version_number                      IN           NUMBER,
    p_init_msg_list                           IN           VARCHAR2 ,
    p_commit                                  IN           VARCHAR2 ,
    p_validation_level                        IN           NUMBER ,
    x_return_status                           OUT  NOCOPY  VARCHAR2,
    x_msg_count                               OUT  NOCOPY  NUMBER,
    x_msg_data                                OUT  NOCOPY  VARCHAR2,
    p_mtl_txn_dtls_tbl                        IN           MTL_TXN_DTLS_TBL_TYPE,
    x_op_created                              OUT  NOCOPY  VARCHAR
  --  p_ro_quantity                               IN           NUMBER
);


PROCEDURE PROCESS_SAVE_RES_TXN_DTLS
(
    p_api_version_number                        IN          NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_Commit                                    IN          VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                             OUT   NOCOPY   VARCHAR2,
    x_msg_count                                  OUT  NOCOPY      NUMBER,
    x_msg_data                                OUT      NOCOPY     VARCHAR2,
    p_res_txn_dtls_tbl                       IN       res_TXN_DTLS_TBL_TYPE
 --  p_ro_quantity                               IN              NUMBER
);


/** swai **/
PROCEDURE PROCESS_SAVE_OP_DTLS
(
    p_api_version_number                        IN          NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_Commit                                    IN          VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                             OUT   NOCOPY   VARCHAR2,
    x_msg_count                                  OUT  NOCOPY      NUMBER,
    x_msg_data                                OUT      NOCOPY     VARCHAR2,
    p_op_dtls_tbl                       IN       OP_DTLS_TBL_TYPE
);

PROCEDURE create_wip_job
(
    p_api_version_number                    IN           NUMBER,
    p_init_msg_list                       IN          VARCHAR2 ,
    p_commit                                IN          VARCHAR2 ,
    p_validation_level                    IN          NUMBER,
    x_return_status                         OUT    NOCOPY   VARCHAR2,
    x_msg_count                              OUT   NOCOPY      NUMBER,
    x_msg_data                            OUT       NOCOPY     VARCHAR2,
    x_job_name                              OUT     NOCOPY      VARCHAR2,
    p_repair_line_id                        IN        NUMBER,
    p_repair_quantity                    IN        NUMBER,
    p_inventory_item_Id                   IN       NUMBER
   );

PROCEDURE generate_wip_jobs_from_scs
(
    p_api_version_number                    IN           NUMBER,
    p_init_msg_list                       IN          VARCHAR2 ,
    p_commit                                IN          VARCHAR2 ,
    p_validation_level                    IN          NUMBER,
    x_return_status                         OUT    NOCOPY   VARCHAR2,
    x_msg_count                              OUT   NOCOPY      NUMBER,
    x_msg_data                            OUT       NOCOPY     VARCHAR2,
    p_repair_line_id                        IN        NUMBER,
    p_repair_quantity                    IN        NUMBER,
    p_service_code_tbl                   IN       service_code_tbl_type
   );

--
-- swai: 12.1.2 Time clock functionality
-- Auto-issues all material lines.
-- If WIP entity id and operaion are specified, then only materials for
-- that operation will be issued and repair line will be disregarded.
-- Future functionality:
-- If repair line id is specified without wip entity id and operation,
-- then all materials for all jobs on that repair order will be issued.
--
PROCEDURE process_auto_issue_mtl_txn
(
    p_api_version_number                        IN         NUMBER,
    p_init_msg_list                             IN         VARCHAR2,
    p_commit                                    IN         VARCHAR2,
    p_validation_level                          IN         NUMBER,
    x_return_status                             OUT NOCOPY VARCHAR2,
    x_msg_count                                 OUT NOCOPY NUMBER,
    x_msg_data                                  OUT NOCOPY VARCHAR2,
    p_wip_entity_id                             IN         NUMBER,
    p_operation_seq_num                         IN         NUMBER,
    p_repair_line_id                            IN         NUMBER,
    x_transaction_header_id                     OUT NOCOPY NUMBER
);

--
-- swai: 12.1.2 Time clock functionality
-- Auto-transacts all resource lines.
-- If WIP entity id and operaion are specified, then only resources for
-- that operation will be issued and repair line will be disregarded.
-- Future functionality:
-- If repair line id is specified without wip entity id and operation,
-- then all resources for all jobs on that repair order will be issued.
--
PROCEDURE process_auto_transact_res_txn
(
    p_api_version_number                  IN         NUMBER,
    p_init_msg_list                       IN         VARCHAR2,
    p_commit                              IN         VARCHAR2,
    p_validation_level                    IN         NUMBER,
    x_return_status                       OUT NOCOPY VARCHAR2,
    x_msg_count                           OUT NOCOPY NUMBER,
    x_msg_data                            OUT NOCOPY VARCHAR2,
    p_wip_entity_id                       IN         NUMBER,
    p_operation_seq_num                   IN         NUMBER,
    p_repair_line_id                      IN         NUMBER
);

--
-- swai: 12.1.2 Time clock functionality
-- Auto-completes an operations
-- If WIP entity id and operaion are specified, then only the spcified
-- operation will be completed.
-- Future functionality:
-- If repair line id is specified without wip entity id and operation,
-- then all operations on all jobs on that repair order will be completed.
--
PROCEDURE process_auto_oper_comp_txn
(
    p_api_version_number                  IN         NUMBER,
    p_init_msg_list                       IN         VARCHAR2,
    p_commit                              IN         VARCHAR2,
    p_validation_level                    IN         NUMBER,
    x_return_status                       OUT NOCOPY VARCHAR2,
    x_msg_count                           OUT NOCOPY NUMBER,
    x_msg_data                            OUT NOCOPY VARCHAR2,
    p_wip_entity_id                       IN         NUMBER,
    p_operation_seq_num                   IN         NUMBER,
    p_repair_line_id                      IN         NUMBER

);


--
-- swai: 12.1.2 Time clock functionality
-- Creates a resource or adds to an existing resource on a job/operation
-- for the given time clock entry id.
-- Notes:
-- (1) Resource comes from profile option CSD_DEF_HV_BOM_RESOURCE,
--     if the resource id from time clock entry is null
-- (2) Transaction qty is always specified in DAY UOM
-- (3) Org is always defined by profile CSD_DEF_REP_INV_ORG
--
PROCEDURE process_time_clock_res_txn
(
    p_api_version_number                  IN         NUMBER,
    p_init_msg_list                       IN         VARCHAR2,
    p_commit                              IN         VARCHAR2,
    p_validation_level                    IN         NUMBER,
    x_return_status                       OUT NOCOPY VARCHAR2,
    x_msg_count                           OUT NOCOPY NUMBER,
    x_msg_data                            OUT NOCOPY VARCHAR2,
    p_time_clock_entry_id                 IN         NUMBER
);

--
-- swai: 12.1.2 Time clock functionality
-- Complete work button: change Repair Order Status
-- Changes repair order status for a given repair order to the
-- status specified by profile option 'CSD_COMPLETE_WORK_RO_STATUS'
--
PROCEDURE process_comp_work_ro_status
(
    p_api_version_number                  IN         NUMBER,
    p_init_msg_list                       IN         VARCHAR2,
    p_commit                              IN         VARCHAR2,
    p_validation_level                    IN         NUMBER,
    x_return_status                       OUT NOCOPY VARCHAR2,
    x_msg_count                           OUT NOCOPY NUMBER,
    x_msg_data                            OUT NOCOPY VARCHAR2,
    p_repair_line_id                      IN         NUMBER,
    x_new_flow_status_code                OUT NOCOPY VARCHAR2,
    x_new_ro_status_code                  OUT NOCOPY VARCHAR2

);


/* swai: 12.1.3
 * bug 9640411
 * Include the ability to delete an existing material transaction detail
 * and its requirements, as long as no materials have been transacted.
 * Deletes a saved material requirement that has not been transacted yet.
 * The following fields in p_mtl_txn_dtls are expected to be filled out:
 *    wip_entity_id
 *    organization_id
 *    inventory_item_id
 *    operation_seq_num
 *    wip_transaction_detail_id (optional)
 */
PROCEDURE process_delete_mtl_txn_dtl
(
    p_api_version_number                      IN           NUMBER,
    p_init_msg_list                           IN           VARCHAR2 ,
    p_commit                                  IN           VARCHAR2 ,
    p_validation_level                        IN           NUMBER ,
    x_return_status                           OUT  NOCOPY  VARCHAR2,
    x_msg_count                               OUT  NOCOPY  NUMBER,
    x_msg_data                                OUT  NOCOPY  VARCHAR2,
    p_mtl_txn_dtls                            IN           MTL_TXN_DTLS_REC_TYPE
);

END CSD_HV_WIP_JOB_PVT;

/
