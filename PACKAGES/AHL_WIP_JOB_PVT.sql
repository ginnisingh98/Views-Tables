--------------------------------------------------------
--  DDL for Package AHL_WIP_JOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_WIP_JOB_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVWIPS.pls 120.0 2005/05/26 00:13:56 appldev noship $ */

-- Define Record Type for AHL Work Order Record --
-- when creating a new job, set dml_type to 'I', all the other cases,
-- set dml_type to 'U'
TYPE ahl_wo_rec_type IS RECORD
(
    wo_name             VARCHAR2(240),
    organization_id     NUMBER,
    status              NUMBER,
    scheduled_start     DATE,
    scheduled_end       DATE,
    inventory_item_id   NUMBER,
    item_instance_id    NUMBER,
    completion_subinventory VARCHAR2(10),
    completion_locator_id   NUMBER,
    wip_supply_type	NUMBER,
    firm_planned_flag   NUMBER,
    project_id          NUMBER,
    prj_task_id         NUMBER,
    quantity            NUMBER,
    mrp_quantity        NUMBER,
    class_code          VARCHAR2(10),
    priority            NUMBER,
    department_id       NUMBER,
    allow_explosion     VARCHAR2(1),
    manual_rebuild_flag VARCHAR2(1),
    rebuild_serial_number  VARCHAR2(30),
    scheduling_method   NUMBER,
    description         VARCHAR2(240),
    dml_type            VARCHAR2(1)
);

-- Define Record Type for AHL Job Detail Operation Record --
-- dml_type can only be set to 'I' or 'U' depending on adding or
-- updating an operation
TYPE ahl_wo_op_rec_type IS RECORD
(
    organization_id     NUMBER,
    operation_seq_num   NUMBER,
    department_id       NUMBER,
    description         VARCHAR2(240),
    minimum_transfer_quantity NUMBER,
    count_point_type    NUMBER,
    backflush_flag      NUMBER,
    scheduled_start     DATE,
    scheduled_end       DATE,
    dml_type            VARCHAR2(1)
);

-- Define Table Type for AHL Job Detail Operation --
TYPE ahl_wo_op_tbl_type IS TABLE OF ahl_wo_op_rec_type INDEX BY BINARY_INTEGER;

-- Define Record Type for AHL Job Detail Resource Requirement Record --
-- dml_type can only be set to 'I','U' or 'D' depending on adding, updating
-- or removing a resource requirement. If dml_type='I', then leave resource_id_old
-- NULL and put the resource_id into resource_id_new. If dml_type='U'
-- then put the old resource_id into resource_id_old and the new resource_id
-- into resource_id_new or leave it blank if no change to the resource_id.
TYPE ahl_wo_res_rec_type IS RECORD
(
    operation_seq_num   NUMBER,
    resource_seq_num    NUMBER,
    organization_id     NUMBER,
    department_id       NUMBER,
    scheduled_sequence  NUMBER,
    resource_id_old     NUMBER,
    resource_id_new     NUMBER,
    uom                 VARCHAR2(30),
    cost_basis          NUMBER,
    quantity            NUMBER,
    assigned_units      NUMBER,
    scheduled_flag      NUMBER,
    activity_id         NUMBER,
    autocharge_type     NUMBER,
    standard_rate_flag  NUMBER,
    applied_resource_units NUMBER,
    applied_resource_value NUMBER,
    description         VARCHAR2(240),
    start_date          DATE,
    end_date            DATE,
    setup_id            NUMBER,
    dml_type            VARCHAR2(1)
);

-- Define Table Type for AHL Job Detail Resource Requirement --
TYPE ahl_wo_res_tbl_type IS TABLE OF ahl_wo_res_rec_type INDEX BY BINARY_INTEGER;

-- Define Record Type for AHL Job Detail Material Requirement Record --
-- dml_type can only be set to 'I','U' or 'D' depending on adding, updating
-- or removing a material requirement. If dml_type='I', then leave inventory_item_id_old
-- NULL and put the inventory_item_id into inventory_item_id_new. If dml_type='U'
-- then put the old inventory_item_id into inventory_item_id_old and the new inventory_item_id
-- into inventory_item_id_new or leave it blank if no change to the inventory_item_id.
TYPE ahl_wo_mtl_rec_type IS RECORD
(
    operation_seq_num     NUMBER,
    inventory_item_id_old NUMBER,
    inventory_item_id_new NUMBER,
    organization_id       NUMBER,
    mrp_net               NUMBER,
    quantity_per_assembly NUMBER,
    required_quantity     NUMBER,
    supply_type           NUMBER,
    supply_locator_id     NUMBER,
    supply_subinventory   VARCHAR2(10),
    date_required         DATE,
    dml_type              VARCHAR2(1)
);

-- Define Table Type for AHL Job Detail Material Requirement --
TYPE ahl_wo_mtl_tbl_type IS TABLE OF ahl_wo_mtl_rec_type INDEX BY BINARY_INTEGER;

-- Define Record Type for AHL Workorder Resource Transaction Record --
TYPE ahl_res_txn_rec_type IS RECORD
(
    wip_entity_id       NUMBER,
    operation_seq_num   NUMBER,
    resource_seq_num    NUMBER,
    resource_id         NUMBER,
    transaction_type    NUMBER,
    transaction_date    DATE,
    transaction_quantity NUMBER,
    transaction_uom     VARCHAR2(3),
    department_id       NUMBER,
    employee_id         NUMBER,
    activity_id         NUMBER,
    activity_meaning    VARCHAR2(80),
    reason_id  	        NUMBER,
    reason              VARCHAR2(80),
    serial_number       VARCHAR2(30),
    reference           VARCHAR2(240)
);

-- Define Table Type for AHL Workorder Resource Transaction --
TYPE ahl_res_txn_tbl_type IS TABLE OF ahl_res_txn_rec_type INDEX BY BINARY_INTEGER;

-- Define Record Type for multiple jobs returned from WIP Mass LOAD_WIP_JOB
TYPE ahl_wip_job_rec_type IS RECORD
(
   wip_entity_id        NUMBER,
   wip_entity_name      VARCHAR2(240),
   organization_id      NUMBER,
   error                VARCHAR2(5000)
);

-- Define Table Type for AHL Workorder Resource Transaction --
TYPE ahl_wip_job_tbl_type IS TABLE OF ahl_wip_job_rec_type INDEX BY BINARY_INTEGER;

-- Define Procedure load_wip_job --
-- This API is Autonomous Transaction. And we have to commit or rollback explicitly
-- when it exits, so p_commit flag is not necessary here.
PROCEDURE load_wip_job (
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  --p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_ahl_wo_rec            IN  ahl_wo_rec_type,
  p_ahl_wo_op_tbl         IN  ahl_wo_op_tbl_type,
  p_ahl_wo_res_tbl        IN  ahl_wo_res_tbl_type,
  p_ahl_wo_mtl_tbl        IN  ahl_wo_mtl_tbl_type,
  x_wip_entity_id         OUT NOCOPY NUMBER
);
--  Start of Comments  --
--
--  Procedure name  : load_wip_job
--  Type            : Private
--  Function        : load(either create or update Job header and Job details information
--                    in WIP entities.
--  Pre-reqs        :
--
--  load_wip_job Parameters :
--  p_ahl_wo_rec          IN  NUMBER     Required
--                        Record of job header attributes
--  p_ahl_wo_op_tbl       IN  NUMBER     Required
--                        Table of job detail: operation record
--  p_ahl_wo_res_tbl      IN  VARCHAR2   Required
--                        Table of job detail: resource requirement record
--  p_ahl_wo_mtl_tbl      IN  VARCHAR2   Required
--                        Table of job detail: material requirement record
--  x_wip_entity_id       OUT NOCOPY NUMBER   Required
--                        Stores the returned wip_entity_id.
--  Version :
--  	Initial Version   1.0
--
--  End of Comments  --

-- Define Procedure insert_resource_txn --
PROCEDURE insert_resource_txn (
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_ahl_res_txn_tbl       IN  ahl_res_txn_tbl_type
);
--  Start of Comments  --
--
--  Procedure name  : insert_resource_txn
--  Type            : Private
--  Function        : to accept Job Resource Transaction information from AHL side and
--                    INSERT it in WIP_COST_TXN_INTERFACE table
--  Pre-reqs        :
--
--  create_wip_job Parameters :
--  p_organization_id     IN  VARCHAR2   Required
--                        Organization_id
--  p_wip_entity_id       IN  VARCHAR2   Required
--                        Wip_entity_id
--  p_ahl_res_txn_tbl     IN  VARCHAR2   Required
--                        Table of Workorder Resource Transaction record
--  Version :
--  	Initial Version   1.0
--
--  End of Comments  --

-- Define Function wip_massload_pending --
FUNCTION wip_massload_pending(
  p_wip_entity_id        IN  NUMBER
) RETURN BOOLEAN;
--  Start of Comments  --
--
--  FUNCTION name   : is_wip_massload_pending
--  Type            : Private
--  Function        : to check whether the specified workorder is in WIP Mass Load phase
--  Pre-reqs        :
--
--  create_wip_job Parameters :
--  p_wip_entity_id       IN  NUMBER   Required
--                        Identifier of workorder
--  Version :
--  	Initial Version   1.0
--
--  End of Comments  --

-- Define Procedure load_wip_batch_jobs --
-- This API is Autonomous Transaction. And we have to commit or rollback explicitly
-- when it exits, so p_commit flag is not necessary here.
PROCEDURE load_wip_batch_jobs (
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  --p_commit              IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_group_id              IN  NUMBER,
  p_header_id             IN  NUMBER,
  p_submit_flag           IN  VARCHAR2,
  p_ahl_wo_rec            IN  ahl_wo_rec_type,
  p_ahl_wo_op_tbl         IN  ahl_wo_op_tbl_type,
  p_ahl_wo_res_tbl        IN  ahl_wo_res_tbl_type,
  p_ahl_wo_mtl_tbl        IN  ahl_wo_mtl_tbl_type,
  x_group_id              OUT NOCOPY NUMBER,
  x_header_id             OUT NOCOPY NUMBER,
  x_ahl_wip_job_tbl	  OUT NOCOPY ahl_wip_job_tbl_type
);
--  Start of Comments  --
--
--  Procedure name  : load_wip_batch_jobs
--  Type            : Private
--  Function        : load(either create or update) Job header and Job details information
--                    in WIP entities. And submit WIP Mass Load in a batch mode. This API
--                    is used for creating multiple jobs only.
--  Pre-reqs        :
--
--  load_wip_job Parameters :
--  p_group_id            IN  NUMBER     Required
--                        group_id for the batch of jobs. NULL for the first job.
--  p_header_id           IN  NUMBER     Required
--                        header_id for each job. NULL for the first job.
--  p_submit_flag         IN  NUMBER     Required
--                        Indicator to show whether to call standard submit request.
--  p_ahl_wo_rec          IN  NUMBER     Required
--                        Record of job header attributes
--  p_ahl_wo_op_tbl       IN  NUMBER     Required
--                        Table of job detail: operation record
--  p_ahl_wo_res_tbl      IN  VARCHAR2   Required
--                        Table of job detail: resource requirement record
--  p_ahl_wo_mtl_tbl      IN  VARCHAR2   Required
--                        Table of job detail: material requirement record
--  x_group_id            OUT NOCOPY NUMBER     Required
--                        Keeps the group_id of the batch of jobs
--  x_header_id           OUT NOCOPY NUMBER     Required
--                        Keeps the header_id of each job
--  x_ahl_wip_job_tbl     OUT NOCOPY ahl_wip_job_tbl_type  Required
--                        Stores the returned wip_entity_id if success or error message
--                        if failure
--  Version :
--  	Initial Version   1.0
--
--  End of Comments  --

END AHL_WIP_JOB_PVT; -- Package spec

 

/
