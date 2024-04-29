--------------------------------------------------------
--  DDL for Package AHL_COMPLETIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_COMPLETIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPRCS.pls 120.7.12010000.3 2009/01/09 22:31:12 sikumar ship $ */

-- Common :-

TYPE workorder_rec_type IS RECORD
(
  workorder_id               NUMBER,
  object_version_number      NUMBER,
  workorder_name             VARCHAR2(80),
  master_workorder_flag      VARCHAR2(1),
  wip_entity_id              NUMBER,
  organization_id            NUMBER,
  plan_id                    NUMBER,
  collection_id              NUMBER,
  scheduled_start_date       DATE,
  scheduled_end_date         DATE,
  actual_start_date          DATE,
  actual_end_date            DATE,
  status_code                VARCHAR2(30),
  status                     VARCHAR2(80),
  route_id                   NUMBER,
  unit_effectivity_id        NUMBER,
  ue_object_version_number   NUMBER,
  automatic_signoff_flag     VARCHAR2(1),
  item_instance_id           NUMBER,
  completion_subinventory    VARCHAR2(30),
  completion_locator_id      VARCHAR2(30),
  lot_number                 mtl_lot_numbers.lot_number%TYPE,
  serial_number              VARCHAR2(30),
  txn_quantity               NUMBER
);

TYPE workorder_tbl_type IS TABLE OF workorder_rec_type INDEX BY BINARY_INTEGER;

TYPE operation_rec_type IS RECORD
(
  workorder_operation_id     NUMBER,
  object_version_number      NUMBER,
  workorder_id               NUMBER,
  workorder_name             VARCHAR2(80),
  wip_entity_id              NUMBER,
  operation_sequence_num     NUMBER,
  organization_id            NUMBER,
  description                VARCHAR2(2000),
  plan_id                    NUMBER,
  collection_id              NUMBER,
  scheduled_start_date       DATE,
  scheduled_end_date         DATE,
  actual_start_date          DATE,
  actual_end_date            DATE,
  status_code                VARCHAR2(30),
  status                     VARCHAR2(80)
);

TYPE operation_tbl_type IS TABLE OF operation_rec_type INDEX BY BINARY_INTEGER;

-- Complete Operation :-

PROCEDURE complete_operation
(
  p_api_version            IN   NUMBER     := 1.0,
  p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default                IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type            IN   VARCHAR2   := NULL,
  x_return_status          OUT NOCOPY  VARCHAR2,
  x_msg_count              OUT NOCOPY  NUMBER,
  x_msg_data               OUT NOCOPY  VARCHAR2,
  p_workorder_operation_id IN   NUMBER,
  p_object_version_no      IN   NUMBER := NULL
);

-- Complete Workorder :-

PROCEDURE complete_workorder
(
  p_api_version          IN    NUMBER     := 1.0,
  p_init_msg_list        IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit               IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level     IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default              IN    VARCHAR2   := FND_API.G_FALSE,
  p_module_type          IN    VARCHAR2   := NULL,
  x_return_status        OUT NOCOPY   VARCHAR2,
  x_msg_count            OUT NOCOPY   NUMBER,
  x_msg_data             OUT NOCOPY   VARCHAR2,
  p_workorder_id         IN    NUMBER,
  p_object_version_no    IN    NUMBER     := NULL
);

-- Complete MR Instance :-

TYPE mr_rec_type IS RECORD
(
  unit_effectivity_id      NUMBER,
  ue_object_version_no     NUMBER,
  ue_status                VARCHAR2(80),
  ue_status_code           VARCHAR2(30),
  mr_header_id             NUMBER,
  incident_id              NUMBER,
  mr_title                 VARCHAR2(80),
  qa_inspection_type       VARCHAR2(150),
  qa_plan_id               NUMBER,
  qa_collection_id         NUMBER,
  item_instance_id         NUMBER,
  actual_end_date          DATE
);

TYPE mr_tbl_type IS TABLE OF mr_rec_type INDEX BY BINARY_INTEGER;

TYPE counter_rec_type IS RECORD
(
  item_instance_id       NUMBER,
  counter_id             NUMBER,
  counter_group_id       NUMBER,
  counter_value_id       NUMBER,
  counter_reading        NUMBER,
  prev_net_curr_diff     NUMBER,
  counter_type           VARCHAR2(30),
  reset_value            NUMBER
);

TYPE counter_tbl_type IS TABLE OF counter_rec_type INDEX BY BINARY_INTEGER;

TYPE route_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Start of Comments
-- Procedure name              : complete_mr_instance
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      p_api_version               NUMBER   Required
--      p_init_msg_list             VARCHAR2 Default  FND_API.G_FALSE
--      p_commit                    VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level          NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                   VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type               VARCHAR2 Default  NULL
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2 Required
--      x_msg_count                 NUMBER   Required
--      x_msg_data                  VARCHAR2 Required
--
-- complete_mr_instance IN parameters:
--      None.
--
-- complete_mr_instance IN OUT parameters:
--  p_x_mr_rec                 mr_rec_type Required For Recursive call
--
-- complete_mr_instance OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments


PROCEDURE complete_mr_instance
(
  p_api_version          IN   NUMBER      := 1.0,
  p_init_msg_list        IN   VARCHAR2    := FND_API.G_TRUE,
  p_commit               IN   VARCHAR2    := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  p_default              IN   VARCHAR2    := FND_API.G_FALSE,
  p_module_type          IN   VARCHAR2    := NULL,
  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  p_x_mr_rec             IN OUT NOCOPY mr_rec_type
);

-- Defer Workorder :-

PROCEDURE defer_workorder
(
  p_api_version       IN    NUMBER     := 1.0,
  p_init_msg_list     IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit            IN    VARCHAR2  := FND_API.G_FALSE,
  p_validation_level  IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default           IN    VARCHAR2   := FND_API.G_FALSE,
  p_module_type       IN    VARCHAR2   := NULL,
  x_return_status     OUT NOCOPY   VARCHAR2,
  x_msg_count         OUT NOCOPY   NUMBER,
  x_msg_data          OUT NOCOPY   VARCHAR2,
  p_workorder_id      IN    NUMBER,
  p_object_version_no IN    NUMBER := NULL
);

-- Function to get the user-enter value 'Operation Status' or 'Workorder Status' QA Plan Element and to check if this value is 'Complete'.
FUNCTION validate_qa_status
(
  p_plan_id                 IN   NUMBER,
  p_char_id                 IN   NUMBER,
  p_collection_id           IN   NUMBER
) RETURN VARCHAR2;

-- Function to Get the status of a MR instance
FUNCTION get_mr_status
(
  p_unit_effectivity_id    IN NUMBER
) RETURN VARCHAR2;

TYPE signoff_mr_rec_type IS RECORD
(
  unit_effectivity_id        NUMBER,
  object_version_number      NUMBER,
  signoff_child_mrs_flag     VARCHAR2(1),
  complete_job_ops_flag      VARCHAR2(1),
  default_actual_dates_flag  VARCHAR2(1),
  actual_start_date          DATE,
  actual_end_date            DATE,
  transact_resource_flag     VARCHAR2(1),
  employee_number            VARCHAR2(30),
  serial_number              VARCHAR2(30)
);

TYPE close_visit_rec_type IS RECORD
(
  visit_id                   NUMBER,
  object_version_number      NUMBER,
  signoff_mrs_flag           VARCHAR2(1),
  complete_job_ops_flag      VARCHAR2(1),
  default_actual_dates_flag  VARCHAR2(1),
  actual_start_date          DATE,
  actual_end_date            DATE,
  transact_resource_flag     VARCHAR2(1),
  employee_number            VARCHAR2(30),
  serial_number              VARCHAR2(30)
);

TYPE resource_req_rec_type IS RECORD
(
  wip_entity_id        NUMBER,
  workorder_name       VARCHAR2(80),
  workorder_id         NUMBER,
  workorder_operation_id NUMBER,
  operation_seq_num    NUMBER,
  resource_seq_num     NUMBER,
  resource_name        bom_resources.resource_code%TYPE,
  organization_id      NUMBER,
  department_id        NUMBER,
  resource_id          NUMBER,
  resource_type        NUMBER,
  uom_code             VARCHAR2(3),
  usage_rate_or_amount NUMBER,
  transaction_quantity NUMBER := 0
);

TYPE resource_req_tbl_type IS TABLE OF resource_req_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE signoff_mr_instance
(
  p_api_version      IN         NUMBER        := 1.0,
  p_init_msg_list    IN         VARCHAR2      := FND_API.G_TRUE,
  p_commit           IN         VARCHAR2      := FND_API.G_FALSE,
  p_validation_level IN         NUMBER        := FND_API.G_VALID_LEVEL_FULL,
  p_default          IN         VARCHAR2      := FND_API.G_FALSE,
  p_module_type      IN         VARCHAR2      := NULL,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  p_signoff_mr_rec   IN         signoff_mr_rec_type
);

PROCEDURE close_visit
(
  p_api_version      IN         NUMBER        := 1.0,
  p_init_msg_list    IN         VARCHAR2      := FND_API.G_TRUE,
  p_commit           IN         VARCHAR2      := FND_API.G_FALSE,
  p_validation_level IN         NUMBER        := FND_API.G_VALID_LEVEL_FULL,
  p_default          IN         VARCHAR2      := FND_API.G_FALSE,
  p_module_type      IN         VARCHAR2      := NULL,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  p_close_visit_rec  IN         close_visit_rec_type
);

/*
-- NAME
--     PROCEDURE: Get_Default_Op_Actual_Dates
-- PARAMETERS
-- Standard IN Parameters
--  None
--
-- Standard OUT Parameters
--  x_return_status    OUT NOCOPY VARCHAR2
--  x_msg_count        OUT NOCOPY NUMBER
--  x_msg_data         OUT NOCOPY VARCHAR2
--
-- Get_Default_Op_Actual_Dates Parameters
--  P_x_operation_tbl   IN AHL_COMPLETIONS_PVT.operation_tbl_type - Table holding the operation records
--
-- DESCRIPTION
--  This function will be used to default the actual dates before completing operations using the
--  My Workorders or Update Workorders Uis. Calling APIs need to populate only the workorder_id and
--  operation_sequence_num fields of the operations records.
--
-- HISTORY
--   16-Jun-2005   rroy  Created
--*/

PROCEDURE Get_Default_Op_Actual_Dates
(
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  P_x_operation_tbl   IN   OUT NOCOPY       AHL_COMPLETIONS_PVT.operation_tbl_type
);

/*
-- NAME
--     PROCEDURE: Get_Op_Actual_Dates
-- PARAMETERS
-- Standard IN Parameters
--  None
--
-- Standard OUT Parameters
--  x_return_status    OUT NOCOPY VARCHAR2
--
-- Get_Op_Actual_Dates Parameters
--  P_x_operation_tbl   IN AHL_COMPLETIONS_PVT.operation_tbl_type - Table holding the operation records
--
-- DESCRIPTION
--  This function will be used to retrieve the current actual dates of operations. This is API
--  is needed for the defaulting logic of actual dates on the Operations subtab of the
--  Update Workorders page. Calling APIs need to populate only the workorder_id and
--  operation_sequence_num fields of the operations records.
--
-- HISTORY
--   16-Jun-2005   rroy  Created
--*/

PROCEDURE Get_Op_Actual_Dates
(
  x_return_status    OUT NOCOPY VARCHAR2,
  P_x_operation_tbl   IN     OUT NOCOPY     AHL_COMPLETIONS_PVT.operation_tbl_type
);

/*
-- NAME
--     PROCEDURE: Get_Default_Wo_Actual_Dates
-- PARAMETERS
-- Standard IN Parameters
--  None
--
-- Standard OUT Parameters
--  x_return_status    OUT NOCOPY VARCHAR2
--
-- Get_Op_Actual_Dates Parameters
--  p_workorder_id      IN         NUMBER - The workorder id for which the actual dates are retrieved
--  x_actual_start_date OUT NOCOPY DATE   - Actual workorder start date
--  x_actual_end_date   OUT NOCOPY DATE   - Actual workorder end date
--
-- DESCRIPTION
-- 	This function will be used to default the actual dates before completing workorders using
--  the My Workorders or Update Workorders UIs. Calling APIs need to ensure that they call
--  this API after updating the operation actual dates.
--
-- HISTORY
--   16-Jun-2005   rroy  Created
--*/

PROCEDURE Get_Default_Wo_Actual_Dates
(
  x_return_status     OUT NOCOPY VARCHAR2,
  p_workorder_id      IN         NUMBER,
  x_actual_start_date OUT NOCOPY DATE,
  x_actual_end_date   OUT NOCOPY DATE
);

------------------------------------------------------------------------------------------------
-- Function to check if the workorder completion operation can be carried out. Following factors
-- determine the same...
-- 1. Unit is quarantined.
-- 2. Workorder is in a status where it can be completed.
-- 3. Status of child workorders.
-- 4. Status of containing operations.
-- 5. Quality collection has been done for the workorder or not.
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : Is_Complete_Enabled
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : FND_API.G_TRUE or FND_API.G_FALSE.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
-- Is_Complete_Enabled IN parameters:
--		P_operation_seq_num	IN	NUMBER
--		P_workorder_id		IN	NUMBER
--              p_ue_id                 IN      NUMBER
--
-- Is_Complete_Enabled IN OUT parameters:
--      None
--
-- Is_Complete_Enabled OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments

FUNCTION Is_Complete_Enabled(
		p_workorder_id		IN	NUMBER,
		P_operation_seq_num	IN	NUMBER,
		p_ue_id                 IN      NUMBER,
		p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2;


-- Wrapper function to complete the visit master workorder
-- If the visit id is passed, then the visit master workorder id queried and completed
-- If the UE Id is passed, then the UE Master workorder is queried and completed
-- If the workorder id is passed, then the workorder is completed.
-- Bug 4626717 - Issue 6
FUNCTION complete_master_wo
(
 p_visit_id              IN            NUMBER,
 p_workorder_id          IN            NUMBER,
 p_ue_id                 IN            NUMBER
) RETURN VARCHAR2;

-- function to get UE status.
FUNCTION get_ue_mr_status_code(p_unit_effectivity_id IN NUMBER) RETURN VARCHAR2;
------------------------------------------------------------------------------------------------
-- API added for the concurrent program "Close Work Orders".
-- This API is to be used with Concurrent program.
-- Bug # 6991393 (FP for bug # 6500568)
------------------------------------------------------------------------------------------------
PROCEDURE Close_WorkOrders (
    errbuf                  OUT NOCOPY  VARCHAR2,
    retcode                 OUT NOCOPY  NUMBER,
    p_api_version           IN          NUMBER
);

-- Added function for FP ER# 6435803
-- Function to test whether all operations for a WO are complete
FUNCTION are_all_operations_complete
(
  p_workorder_id    IN NUMBER
) RETURN VARCHAR2;


END AHL_COMPLETIONS_PVT;

/
