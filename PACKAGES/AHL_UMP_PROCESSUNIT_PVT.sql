--------------------------------------------------------
--  DDL for Package AHL_UMP_PROCESSUNIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_PROCESSUNIT_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUMUS.pls 120.1.12010000.2 2008/12/26 23:57:54 sracha ship $ */


------------------------------------------------------------
-- Define record structures used by Process Unit Procedure
-- and procedures in ahl_ump_processunit_extn_pvt.
------------------------------------------------------------
-- To hold the instance relationship details.
TYPE config_node_rec_type IS RECORD (
   CSI_ITEM_INSTANCE_ID  NUMBER,
   OBJECT_ID             NUMBER,
   POSITION_REFERENCE    CSI_II_RELATIONSHIPS.POSITION_REFERENCE%TYPE);

-- To hold the counter values.
TYPE counter_values_rec_type IS RECORD(
   COUNTER_ID     NUMBER,
   COUNTER_NAME   CS_COUNTERS_V.NAME%TYPE,
   UOM_CODE       VARCHAR2(3),
   COUNTER_VALUE  NUMBER );

----------------------------------------------
-- Define Table Types for record structures --
----------------------------------------------
TYPE counter_values_tbl_type IS TABLE OF counter_values_rec_type INDEX BY BINARY_INTEGER;
TYPE config_node_tbl_type IS TABLE OF config_node_rec_type INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Process_Unit
--  Type        : Private
--  Function    : Manages Create/Modify/Delete operations of applicable maintenance
--                requirements on a unit.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--  Standard IN parameters :
--      p_commit                        IN      VARCHAR2 := FND_API.G_FALSE
--
--  Process_Unit Parameters :
--      p_csi_item_instance_id          IN      NUMBER                 Required.
--      Effectivity will be built for the input item instance ID.
--      p_concurrent_flag               IN      VARCHAR2
--      This flag will be 'Y' if called from a concurrent program. Based on this flag, the error
--      and informational messages will be logged into the log file.

PROCEDURE Process_Unit (
    p_commit                 IN            VARCHAR2 := FND_API.G_FALSE,
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    x_msg_count              OUT  NOCOPY   NUMBER,
    x_msg_data               OUT  NOCOPY   VARCHAR2,
    x_return_status          OUT  NOCOPY   VARCHAR2,
    p_csi_item_instance_id   IN            NUMBER,
    p_concurrent_flag        IN            VARCHAR2 := 'N'

);

-- Process units affected by an MR.
-- Start of Comments --
--  Procedure name    : Process_MR_Affected_Units
--  Type        : Private
--  Function    : Processes effectivity on all Units impacted by an MR.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_MR_Affected_Units Parameters :
--  Effectivity will be built for all units having p_mr_id as a maintenance requirement.
--  This procedure will also be called from terminate_MRs; in which case p_old_mr_header_id
--  will also be passed.p_old_mr_header_id is the MR that was terminated. Effectivity will
--  be re-build for all units that had p_old_mr_header_id as applicability.
--
--  p_concurrent_flag                   IN      VARCHAR2
--  This flag will be 'Y' if called from a concurrent program. Based on this flag, the error
--  and informational messages will be logged into the log file.
--

PROCEDURE Process_MRAffected_Units (
    p_commit                 IN            VARCHAR2 := FND_API.G_FALSE,
    x_msg_count              OUT  NOCOPY   NUMBER,
    x_msg_data               OUT  NOCOPY   VARCHAR2,
    x_return_status          OUT  NOCOPY   VARCHAR2,
    p_mr_header_id           IN            NUMBER,
    p_old_mr_header_id       IN            NUMBER    := NULL,
    p_concurrent_flag        IN            VARCHAR2  := 'N',
    -- added to fix performance bug# 6893404
    p_num_of_workers         IN            NUMBER    := 1,
    p_mtl_category_id        IN            NUMBER    := NULL,
    p_process_option         IN            VARCHAR2  := NULL
);


-- Process effectivity for all Units.
-- Start of Comments --
--  Procedure name    : Process_All_Units
--  Type        : Private
--  Function    : Processes effectivity on all Units/instances from Intalled Base for which
--                maintenance requirements have been defined in FMP.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_All_Units Parameters :
--
--  p_concurrent_flag                   IN      VARCHAR2
--  This flag will be 'Y' if called from a concurrent program. Based on this flag, the error
--  and informational messages will be logged into the log file.
--

PROCEDURE Process_All_Units (
    p_commit                 IN            VARCHAR2 := FND_API.G_FALSE,
    x_msg_count              OUT  NOCOPY   NUMBER,
    x_msg_data               OUT  NOCOPY   VARCHAR2,
    x_return_status          OUT  NOCOPY   VARCHAR2,
    p_concurrent_flag        IN            VARCHAR2  := 'N',
    -- added to fix performance bug# 6893404
    p_num_of_workers         IN            NUMBER    := 1,
    p_mtl_category_id        IN            NUMBER    := NULL,
    p_process_option         IN            VARCHAR2  := NULL
);

-- Tamal: Bug #4207212, #4114368: Begin
-- Process units for contract number, modifier.
-- Start of Comments --
--  Procedure name    : Process_PM_Contracts
--  Type        : Private
--  Function    : Retrieves all instances for a contract and calls Process_Unit for each unit.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_PM_Contracts Parameters :
--
--  p_concurrent_flag                   IN      VARCHAR2
--  This flag will be 'Y' if called from a concurrent program. Based on this flag, the error
--  and informational messages will be logged into the log file.
--  p_contract_number			IN	VARCHAR2
--  The contract number for which want to process csi_item_instances entitlement
--  p_contract_number			IN	VARCHAR2
--  The contract number modifier for above contract number
--
PROCEDURE Process_PM_Contracts
(
    p_commit                 IN            VARCHAR2 := FND_API.G_FALSE,
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    x_msg_count              OUT  NOCOPY   NUMBER,
    x_msg_data               OUT  NOCOPY   VARCHAR2,
    x_return_status          OUT  NOCOPY   VARCHAR2,
    p_contract_number        IN            VARCHAR2  := NULL,
    p_contract_modifier      IN            VARCHAR2  := NULL,
    p_concurrent_flag        IN            VARCHAR2  := 'N'
);
-- Tamal: Bug #4207212, #4114368: End

-- Procedure to calculate due date based on deferral details.
PROCEDURE Get_Deferred_Due_Date (p_unit_effectivity_id    IN  NUMBER,
                                 p_deferral_threshold_tbl IN  counter_values_tbl_type,
                                 x_due_date               OUT NOCOPY DATE,
                                 x_return_status          OUT NOCOPY VARCHAR2,
                                 x_msg_data               OUT NOCOPY VARCHAR2,
                                 x_msg_count              OUT NOCOPY NUMBER);

-------------------------------------------------------------
-- Following procedure has been added for R12 Enhancements --
-------------------------------------------------------------
-- Procedure to calculate counter values at a given forecasted date for Reliability Fwk use.
PROCEDURE Get_Forecasted_Counter_Values(
              x_return_status          OUT NOCOPY VARCHAR2,
              x_msg_data               OUT NOCOPY VARCHAR2,
              x_msg_count              OUT NOCOPY NUMBER,
              p_init_msg_list          IN         VARCHAR2 := FND_API.G_FALSE,
              p_csi_item_instance_id   IN         NUMBER,        -- Instance Number
              p_forecasted_date        IN         DATE,
              x_counter_values_tbl    OUT NOCOPY counter_values_tbl_type); -- Forecasted Counter Vals.

-- Added for BUE parallel run(Perf bug# 6893404.
------------------------------------------------
-- worker concurrent programs for Building Unit Effectivities.
-- used for Preventive Maint. processing.
PROCEDURE Process_Unit_Range (
                     errbuf                 OUT NOCOPY  VARCHAR2,
                     retcode                OUT NOCOPY  NUMBER,
                     p_mr_header_id         IN NUMBER,
                     p_start_instance_id    IN NUMBER,
                     p_end_instance_id      IN NUMBER);

-- this proccedure is used when user selects to run BUE for all units.
PROCEDURE Process_Unit_Range (
                     errbuf                 OUT NOCOPY  VARCHAR2,
                     retcode                OUT NOCOPY  NUMBER,
                     p_parent_conc_pgm_id   IN NUMBER);


-- this procedure is launched when the MR is revised from FMP Complete Revision API..
PROCEDURE Process_Unit_Range (errbuf                 OUT NOCOPY  VARCHAR2,
                              retcode                OUT NOCOPY  NUMBER,
                              p_old_mr_header_id     IN NUMBER,
                              p_new_mr_header_id     IN NUMBER);

-- function to get net reading to fix performance issue.
-- for use by procedure get_current_usage in SQL query.
-- Added for performance bug# 6893404.
FUNCTION get_latest_ctr_reading(p_counter_id IN NUMBER) RETURN NUMBER;


END AHL_UMP_ProcessUnit_PVT;

/
