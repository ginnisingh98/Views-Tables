--------------------------------------------------------
--  DDL for Package Body AHL_UMP_PROCESSUNIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_PROCESSUNIT_PVT" AS
/* $Header: AHLVUMUB.pls 120.26.12010000.6 2009/12/12 05:02:55 sracha ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_UMP_ProcessUnit_PVT';
G_DEBUG             VARCHAR2(1) := AHL_DEBUG_PUB.is_log_enabled;
G_IS_PM_INSTALLED   CONSTANT VARCHAR2(1) := AHL_UTIL_PKG.IS_PM_INSTALLED;

G_CONCURRENT_FLAG   VARCHAR2(1);

-- added to debug concurrent worker pgms failure.
G_DEBUG_LINE_NUM    NUMBER;

----------------------------------------------------------------
-- Define local record structures used by Process Unit Procedure.
----------------------------------------------------------------
-- To hold the counter rules.
TYPE counter_rules_rec_type IS RECORD(
   UOM_CODE  VARCHAR2(3),
   RATIO     NUMBER);

-- To hold the applicable MRs table record.
TYPE applicable_mrs_rec_type IS RECORD(
   CSI_ITEM_INSTANCE_ID      NUMBER,
   MR_HEADER_ID              NUMBER,
   TITLE                     AHL_MR_HEADERS_VL.TITLE%TYPE,
   VERSION_NUMBER            NUMBER,
   REPETITIVE_FLAG           VARCHAR2(1),
   SHOW_REPETITIVE_CODE      VARCHAR2(30),
   IMPLEMENT_STATUS_CODE     VARCHAR2(30),
   COPY_ACCOMPLISHMENT_CODE  VARCHAR2(30),
   PRECEDING_MR_HEADER_ID    NUMBER,
   DESCENDENT_COUNT          NUMBER,
   WHICHEVER_FIRST_CODE      VARCHAR2(30),
   PROGRAM_MR_HEADER_ID      NUMBER,
   SERVICE_LINE_ID           NUMBER,      -- from service contracts for PM installation.
   PM_SCHEDULE_EXISTS        VARCHAR2(1), -- used only for PM installation.
   CONTRACT_START_DATE       DATE,        -- used only for PM installation.
   CONTRACT_END_DATE         DATE,        -- used only for PM installation.
   PROGRAM_END_DATE          DATE,        -- used only for PM installation.
   COVERAGE_IMP_LEVEL        NUMBER,      -- used only for PM installation.
   EFFECTIVE_TO              DATE,
   EFFECTIVE_FROM            DATE
   );

-- To hold the forecast details.
TYPE forecast_details_rec_type IS RECORD(
   START_DATE     DATE,
   END_DATE       DATE,
   UOM_CODE       VARCHAR2(3),
   USAGE_PER_DAY  NUMBER);

-- To hold the ahl unit effectivity record details.
TYPE unit_effectivity_rec_type IS RECORD(
   UNIT_EFFECTIVITY_ID  NUMBER,
   STATUS_CODE          VARCHAR2(30),
   DUE_DATE             DATE,
   FORECAST_SEQUENCE    NUMBER,
   RELATED_UE_ID        NUMBER,
   ORIGINATOR_UE_ID     NUMBER,
   VISIT_ASSIGN_FLAG    VARCHAR2(1),
   VISIT_END_DATE       DATE);

-- To hold the calculated next due details.
TYPE next_due_date_rec_type IS RECORD(
   MR_EFFECTIVITY_ID     NUMBER,
   MR_INTERVAL_ID        NUMBER,
   DUE_DATE              DATE,
   DUE_AT_COUNTER_VALUE  NUMBER,
   CURRENT_CTR_VALUE     NUMBER,
   LAST_CTR_VALUE        NUMBER,
   MESSAGE_CODE          VARCHAR2(30),
   TOLERANCE_AFTER       NUMBER,
   TOLERANCE_BEFORE      NUMBER,
   TOLERANCE_FLAG        VARCHAR2(1),
   CTR_UOM_CODE          VARCHAR2(3),
   EARLIEST_DUE_DATE     DATE,
   LATEST_DUE_DATE       DATE,
   COUNTER_ID            NUMBER,
   -- Added to fix bug# 4224867.
   COUNTER_REMAIN        NUMBER);

/*TYPE MR_RELATIONSHIP_REC IS RECORD (
   MR_HEADER_ID          NUMBER,
   RELATED_MR_HEADER_ID  NUMBER,
   RELATIONSHIP_CODE     VARCHAR2(30)); */

-- To hold the PM program details.
TYPE PMprogram_rec_type IS RECORD(
   PROGRAM_MR_HEADER_ID   NUMBER,
   MR_EFFECTIVITY_ID      NUMBER);

-- Begin -- Added for performance fix bug# 6893404.
-- number table.
TYPE nbr_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- varchar2 table.
TYPE vchar_tbl_type IS TABLE OF VARCHAR2(400) INDEX BY BINARY_INTEGER;
-- End -- Added for performance fix bug# 6893404.

----------------------------------------------
-- Define Table Types for record structures --
----------------------------------------------
TYPE unit_effectivity_tbl_type IS TABLE OF unit_effectivity_rec_type INDEX BY BINARY_INTEGER;
TYPE counter_rules_tbl_type IS TABLE OF counter_rules_rec_type INDEX BY BINARY_INTEGER;
TYPE forecast_details_tbl_type IS TABLE OF forecast_details_rec_type INDEX BY BINARY_INTEGER;

--TYPE MR_RELATIONSHIP_TBL IS TABLE OF MR_RELATIONSHIP_REC INDEX BY BINARY_INTEGER;

TYPE PMprogram_tbl_type IS TABLE OF PMprogram_rec_type INDEX BY BINARY_INTEGER;

------------------------------
-- Declare Local Procedures --
------------------------------
-- To get the unit and master configurations IDs for the input item instance.
PROCEDURE Get_Unit_Master_ConfigIDs (p_csi_item_instance_id IN NUMBER,
                                     x_uc_header_id OUT NOCOPY NUMBER,
                                     x_master_config_id OUT NOCOPY NUMBER);

-- To get the root item instance for the input item instance if exists.
FUNCTION Get_RootInstanceID(p_csi_item_instance_id IN NUMBER)
RETURN NUMBER;

-- Validate the input item instance.
PROCEDURE Validate_Item_Instance (p_csi_item_instance_id       IN NUMBER,
                                  x_inventory_item_id          OUT NOCOPY NUMBER,
                                  x_inv_master_organization_id OUT NOCOPY NUMBER);

-- Build the item instance tree containing root nodes and its components.
PROCEDURE Build_Config_Tree(p_csi_root_instance_id  IN         NUMBER,
                            p_master_config_id      IN         NUMBER,
                            x_config_node_tbl       OUT NOCOPY AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type);


-- To get the last day of the rolling window from profile values.
FUNCTION Get_Rolling_Window_Date RETURN DATE;

-- Procedure to build unit effectivity for ASO Installation.
-- Called from Process_Unit API. This procedure uses the global variables
-- set in 'Process Unit' API for processing.
PROCEDURE Process_ASO_Unit;

-- Get the utilization forecast applicable to the input item instance/unit.
PROCEDURE Get_Utilization_Forecast (p_csi_item_instance_id IN         NUMBER,
                                    p_uc_header_id         IN         NUMBER,
                                    p_inventory_item_id    IN         NUMBER,
                                    p_inventory_org_id     IN         NUMBER,
                                    x_forecast_details_tbl OUT NOCOPY forecast_details_tbl_type);

-- Lock all existing unit effectivity records.
PROCEDURE Lock_UnitEffectivity_Records(x_ret_code  OUT NOCOPY VARCHAR2);

-- Build the counter ratio that needs to be applied to the item instance based
-- on its master configuration position. Input is the item instance.
PROCEDURE build_Counter_Ratio(p_position_reference   IN         VARCHAR2,
                              p_csi_item_instance_id IN         NUMBER,
                              p_master_config_id     IN         NUMBER,
                              x_counter_rules_tbl    OUT NOCOPY counter_rules_tbl_type);

-- Build the current usage on the item instance's counters based on counters attached
-- to the item instance.
PROCEDURE get_Current_Usage ( p_csi_item_instance_id IN         NUMBER,
                              x_current_usage_tbl    OUT NOCOPY counter_values_tbl_type );

-- Get accomplishment details for an MR.
-- Added parameter x_no_forecast to fix bug# 6711228
PROCEDURE get_accomplishment_details (p_applicable_mrs_rec       IN         applicable_mrs_rec_type,
                                      p_current_usage_tbl        IN         counter_values_tbl_type,
                                      p_counter_rules_tbl        IN         counter_rules_tbl_type,
                                      x_accomplishment_date      OUT NOCOPY DATE,
                                      x_last_acc_counter_val_tbl OUT NOCOPY counter_values_tbl_type,
                                      x_one_time_mr_flag         OUT NOCOPY BOOLEAN,
                                      x_dependent_mr_flag        OUT NOCOPY BOOLEAN,
                                      x_get_preceding_next_due   OUT NOCOPY BOOLEAN,
                                      x_mr_accomplish_exists     OUT NOCOPY BOOLEAN,
                                      x_no_forecast_flag         OUT NOCOPY BOOLEAN);


-- Build unit effectivity for a given item instance and a maintenance requirement.
-- The unit effectivities created here will be written into a temporary table.
PROCEDURE Build_Effectivity ( p_applicable_mrs_rec IN applicable_mrs_rec_type,
                              p_current_usage_tbl  IN counter_values_tbl_type,
                              p_counter_rules_tbl  IN counter_rules_tbl_type );

-- Calculate due date for the item instance and mr using current usage, counter rules,
-- last accomplishment counters and forecast (defined in global variable).
-- Added parameter p_dependent_mr_flag to fix bug# 6711228.
-- Added parameters p_mr_accomplish_exists and p_last_due_mr_interval_id to fix bug# 6858788.
PROCEDURE Calculate_Due_Date ( p_repetivity_flag    IN VARCHAR2 := 'Y',
                               p_applicable_mrs_rec IN applicable_mrs_rec_type,
                               p_current_usage_tbl  IN counter_values_tbl_type,
                               p_counter_rules_tbl  IN counter_rules_tbl_type,
                               p_last_due_date      IN DATE,
                               p_last_due_counter_val_tbl IN counter_values_tbl_type,
                               p_dependent_mr_flag  IN BOOLEAN := FALSE,
                               p_mr_accomplish_exists IN BOOLEAN,
                               p_last_due_mr_interval_id IN NUMBER := NULL,
                               x_next_due_date_rec  OUT NOCOPY next_due_date_rec_type);


-- Calculate due at counter values for a given due due from last due date and last due counters using
-- counter rules and forecast (defined in global variable).
PROCEDURE Get_Due_At_Counter_Values ( p_last_due_date IN DATE,
                                      p_last_due_counter_val_tbl IN counter_values_tbl_type,
                                      p_due_date IN DATE,
                                      p_counter_rules_tbl IN counter_rules_tbl_type,
                                      x_due_at_counter_val_tbl OUT NOCOPY counter_values_tbl_type,
                                      x_return_value      OUT NOCOPY BOOLEAN);

-- Calculates the due date for the counter_remain from a given start date using forecast, counter rules
-- and counter uom.
PROCEDURE Get_Date_from_UF ( p_counter_remain IN NUMBER,
                             p_counter_uom_code IN VARCHAR2,
                             p_counter_rules_tbl IN counter_rules_tbl_type,
                             p_start_date IN DATE := NULL,
                             x_due_date         OUT NOCOPY DATE);

-- Apply the counter ratio factor to convert a given counter value at a component level to the
-- root instance. This is needed as forecast is only defined at root instance.
FUNCTION Apply_Counter_Ratio ( p_counter_remain IN NUMBER,
                               p_counter_uom_code IN VARCHAR2,
                               p_counter_rules_tbl IN counter_rules_tbl_type)
RETURN NUMBER;

-- Apply the counter ratio factor to convert a given counter value at a root instance level to the
-- component. This is needed as forecast is only defined at root instance.
FUNCTION Apply_ReverseCounter_Ratio ( p_counter_remain IN NUMBER,
                                      p_counter_uom_code IN VARCHAR2,
                                      p_counter_rules_tbl IN counter_rules_tbl_type)
RETURN NUMBER;

-- This will return the adjusted interval value if the next due counter value overlaps two intervals.
-- It will be used where the overflow condition occurs based on the interval's start value and stop value.
PROCEDURE Adjust_Interval_Value ( p_mr_effectivity_id IN NUMBER,
                                  p_counter_id IN NUMBER,
                                  p_counter_value IN NUMBER,
                                  p_interval_value IN NUMBER,
                                  p_stop_value IN NUMBER,
                                  x_adjusted_int_value OUT NOCOPY NUMBER,
                                  x_nxt_interval_found OUT NOCOPY BOOLEAN);

-- This will return the adjusted due date if the next due date overlaps two intervals.
-- It will be used where the overflow condition occurs based on the interval's start date and stop date.
PROCEDURE Adjust_Due_Date ( p_mr_effectivity_id IN NUMBER,
                            p_start_counter_rec IN counter_values_rec_type,
                            p_start_due_date    IN DATE,
                            p_counter_rules_tbl IN counter_rules_tbl_type,
                            p_interval_value IN NUMBER,
                            p_stop_date IN DATE,
                            p_due_date IN DATE,
                            x_adjusted_due_date OUT NOCOPY DATE,
                            x_adjusted_due_ctr  OUT NOCOPY NUMBER,
                            x_nxt_interval_found OUT NOCOPY BOOLEAN);

-- This procedure will return due date based on the next interval(if exists), whenever an interval
-- is not found for the current start/stop values or dates.
-- Added parameter p_dependent_mr_flag to fix bug# 6711228.
-- Added parameter p_mr_accomplish_exists and p_last_due_mr_interval_id to fix bug# 6858788. Commented
-- p_last_accomplishment_date and will instead use p_mr_accomplish_exists.
PROCEDURE Get_DueDate_from_NxtInterval(p_applicable_mrs_rec      IN  applicable_mrs_rec_type,
                                       p_repetivity_flag         IN  VARCHAR2,
                                       p_mr_effectivity_id       IN  NUMBER,
                                       p_current_ctr_rec         IN  Counter_values_rec_type,
                                       p_current_ctr_at_date     IN  DATE,
                                       p_counter_rules_tbl       IN  Counter_rules_tbl_type,
                                       p_start_int_match_at_ctr  IN  NUMBER,
                                       p_last_accomplish_ctr_val IN  NUMBER,
                                       --p_last_accomplishment_date IN DATE,
                                       p_dependent_mr_flag       IN  BOOLEAN,
                                       p_mr_accomplish_exists    IN  BOOLEAN,
                                       p_last_due_mr_interval_id IN  NUMBER,
                                       x_next_due_date_rec       OUT NOCOPY next_due_date_rec_type,
                                       x_mr_interval_found       OUT NOCOPY BOOLEAN,
                                       x_return_val              OUT NOCOPY BOOLEAN);

-- To write a record into ahl_temp_unit_effectivities.
PROCEDURE Create_temp_unit_effectivity (X_unit_effectivity_rec IN ahl_temp_unit_effectivities%ROWTYPE);

-- To process the decendents in case the mr is a group MR.
PROCEDURE Process_GroupMR (p_applicable_mrs_rec  IN applicable_mrs_rec_type,
                           p_new_unit_effectivity_rec IN ahl_temp_unit_effectivities%ROWTYPE,
                           p_unit_effectivity_tbl IN unit_effectivity_tbl_type,
                           p_old_UE_forecast_sequence IN NUMBER := -1);

-- To process the dependent MRs based on the value of preceding MR.
PROCEDURE Process_PrecedingMR (p_applicable_mrs_rec IN applicable_mrs_rec_type,
                               p_counter_rules_tbl  IN counter_rules_tbl_type,
                               p_current_usage_tbl  IN counter_values_tbl_type);


-- To update the preceding_check_flag in the temporary unit effectivities table.
PROCEDURE Update_check_flag (p_applicable_mrs_rec IN applicable_mrs_rec_type,
                             p_dependent_mr_flag IN BOOLEAN,
                             p_next_due_date_rec IN next_due_date_rec_type);

-- To log error messages into a log file if called from concurrent process.
PROCEDURE log_error_messages;


-------------------------------------------------
-- Procedures for Preventive Maintenance Logic --
-------------------------------------------------
-- Populate applicable MRs temporary table from the output of FMP API.
PROCEDURE PopulatePM_Appl_MRs (p_csi_ii_id      IN  NUMBER,
                               x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count      OUT NOCOPY NUMBER,
                               x_msg_data       OUT NOCOPY VARCHAR2,
                               x_UnSch_programs_tbl OUT NOCOPY PMprogram_tbl_type);

-- Procedure to build instance level effectivity for PM installation
-- using service contracts.
-- Called from Process_Unit API.
PROCEDURE Process_PM_Unit(p_csi_item_instance_id IN    NUMBER,
                          p_UnSch_programs_tbl   IN    PMprogram_tbl_type);


-- Calculate program end date for all MR's where contract is not scheduled.
PROCEDURE Calc_program_end_dates (p_UnSch_programs_tbl IN PMprogram_tbl_type,
                                  p_current_usage_tbl  IN counter_values_tbl_type);

-- Process records with contract dates scheduled.
PROCEDURE Process_PMSch_Activities;

-- Process records with no contract dates.
PROCEDURE Process_PMUnSch_Activities(p_current_usage_tbl IN counter_values_tbl_type);

-- Procedure to find the service_line_id and program for a calculated due_date.
-- The calculated due_date may be overridden by the contract/program dates.
-- Also the earliest due and latest due date will get adjusted if they are not
-- within the contract and program start/end dates.
PROCEDURE Get_PMprogram(p_csi_item_instance_id       IN  NUMBER,
                        p_mr_header_id               IN  NUMBER,
                        p_last_due_date              IN  DATE,
                        p_due_date                   IN  DATE,
                        p_earliest_due               IN  DATE,
                        p_latest_due                 IN  DATE,
                        x_program_mr_header_id       OUT NOCOPY NUMBER,
                        x_service_line_id            OUT NOCOPY NUMBER,
                        x_contract_override_due_date OUT NOCOPY DATE,
                        x_cont_override_earliest_due OUT NOCOPY DATE,
                        x_cont_override_latest_due   OUT NOCOPY DATE,
                        x_contract_found_flag        OUT NOCOPY BOOLEAN);

-- After creation of all maintenance requirements for the instance in the temporary table,
-- assign unit effectivity IDs from existing un-accomplished maintenance requirements
-- from ahl_unit_effectivities_b.
PROCEDURE Assign_Unit_effectivity_IDs;

-- Fix for Prev. Maint. performance bug# 5093064.
-- instead of calling procedure AHL_FMP_PVT.GET_MR_AFFECTED_ITEMS,
-- write PM effectivity logic in this procedure.
PROCEDURE Process_PM_MR_Affected_Items(p_commit           IN            VARCHAR2 := FND_API.G_FALSE,
                                       x_msg_count           OUT NOCOPY NUMBER,
                                       x_msg_data            OUT NOCOPY VARCHAR2,
                                       x_return_status       OUT NOCOPY VARCHAR2,
                                       p_mr_header_id     IN            NUMBER,
                                       p_old_mr_header_id IN            NUMBER := NULL,
                                       p_concurrent_flag  IN            VARCHAR2 := 'N',
                                       p_num_of_workers   IN            NUMBER := 10);

--------------------------------------------------------------------
-- Following procedures have been added for 11.5.10 Enhancements. --
--------------------------------------------------------------------
-- Get the latest recorded counter reading for a given date.
PROCEDURE get_ctr_reading_for_date (p_csi_item_instance_id IN NUMBER,
                                    p_counter_id           IN NUMBER,
                                    p_reading_date         IN DATE,
                                    x_net_reading        OUT NOCOPY NUMBER);

-- Get the earliest date on which a given reading was recorded.
PROCEDURE get_ctr_date_for_reading (p_csi_item_instance_id IN NUMBER,
                                    p_counter_id           IN NUMBER,
                                    p_counter_value        IN NUMBER,
                                    x_ctr_record_date    OUT NOCOPY DATE,
                                    x_return_val         OUT NOCOPY BOOLEAN);

-- Calculate due date all deferred unit effectivities.
PROCEDURE Process_Deferred_UE (p_csi_item_instance_id IN NUMBER,
                               p_current_usage_tbl  IN counter_values_tbl_type,
                               p_counter_rules_tbl  IN counter_rules_tbl_type);

-- Explode SR's having MRs for calculating MR due dates.
PROCEDURE Process_SR_UE (p_csi_item_instance_id IN NUMBER);

-- Match if current UE group MR matches the applicable group MR.
PROCEDURE Match_Group_MR (p_orig_csi_item_instance_id  IN  NUMBER,
                          p_orig_mr_header_id          IN  NUMBER,
                          p_unit_effectivity_id        IN  NUMBER,
                          x_group_match_flag           OUT NOCOPY VARCHAR2);

-----------------------------------------------------------------------------------
-- Following procedures have been added for 11.5.10+ Transit Check Enhancements. --
-----------------------------------------------------------------------------------

-- Validate applicability for Unplanned MRs (MRs directly planned into a Visit from FMP).
PROCEDURE Process_Unplanned_UE(p_csi_item_instance_id IN NUMBER);

---------------------------------------
-- added to fix performance bug 5093064.
---------------------------------------
-- Split instances based on instance count.
PROCEDURE Instance_Split_BTree(p_csi_max_id  in NUMBER,
                               p_csi_min_id  IN NUMBER,
                               p_num_workers IN NUMBER,
                               p_mr_header_id IN NUMBER,
                               p_total_inst_count  IN NUMBER);


-- Split instance range into blocks based on instance IDs.
PROCEDURE Instance_Split_Sequential(p_csi_max_id  in NUMBER,
                                    p_csi_min_id  IN NUMBER,
                                    p_num_workers IN NUMBER,
                                    p_mr_header_id IN NUMBER);

----------------------------------------------
-- Following procedures have been added R12 --
----------------------------------------------
-- Added to fix bug# 4224867.
-- find usage forecast for a given date.
PROCEDURE get_usage_for_date(p_due_date          IN DATE,
                             p_counter_uom_code  IN VARCHAR2,
                             p_counter_rules_tbl IN Counter_rules_tbl_type,
                             x_usage_per_day     OUT NOCOPY NUMBER);

-- Added to fix bug# 6875650.
-- Get the latest recorded counter reading for a given date-time.
PROCEDURE get_ctr_reading_for_datetime (p_csi_item_instance_id IN NUMBER,
                                        p_counter_id           IN NUMBER,
                                        p_reading_date         IN DATE,
                                        x_net_reading          OUT NOCOPY NUMBER);


-- Added for performance bug# 6893404.
-- Identify affected units and process or launch concurrent workers for AHL processing.
PROCEDURE Split_Process_All_Instances(p_concurrent_flag  IN  VARCHAR2,
                                      p_commit_flag      IN  VARCHAR2,
                                      p_num_of_workers   IN  NUMBER,
                                      p_mr_header_id     IN  NUMBER,
                                      p_mtl_category_id  IN  NUMBER,
                                      p_process_option   IN  VARCHAR2,
                                      x_msg_count        OUT NOCOPY  NUMBER,
                                      x_msg_data         OUT NOCOPY  NUMBER,
                                      x_return_status    OUT NOCOPY  VARCHAR2);

-- Added for performance bug# 6893404.
-- Write into BUW worker table when processing all units.
PROCEDURE Populate_BUE_Worker(p_conc_request_id IN  NUMBER,
                              p_concurrent_flag IN  VARCHAR2,
                              p_mtl_category_id IN  NUMBER,
                              p_process_option  IN  VARCHAR2,
                              errbuf            OUT NOCOPY VARCHAR2,
                              x_return_status   OUT NOCOPY VARCHAR2);


-- Write into BUW worker table when processing for a MR.
PROCEDURE Populate_BUE_Worker_for_MR(p_conc_request_id IN  NUMBER,
                                     p_mr_header_id    IN  NUMBER,
                                     p_concurrent_flag IN  VARCHAR2,
                                     p_mtl_category_id IN  NUMBER,
                                     p_process_option  IN  VARCHAR2,
                                     x_return_status   OUT NOCOPY VARCHAR2);

-- Added for performance bug# 6893404.
-- get next instance from BUE worker table to process.
PROCEDURE Get_Next_BUE_Row(p_parent_conc_pgm_id    IN  NUMBER,
                           p_conc_child_req_id     IN  NUMBER,
                           x_return_status         OUT NOCOPY VARCHAR2,
                           errbuf                  OUT NOCOPY VARCHAR2,
                           x_item_instance_id      OUT NOCOPY NUMBER);


-- Added for performance bug# 6893404.
-- cleanup worker table
PROCEDURE Cleanup_BUE_Worker(p_parent_conc_request_id IN  NUMBER,
                             p_child_conc_request_id  IN  NUMBER);


-- added to fix bug# 6907562.
-- function that compares previous due date and uom remain with current values
-- and return Y is the current due date replaces the prev one.
FUNCTION validate_for_duedate_reset(p_due_date        IN DATE,
                                    p_uom_remain      IN NUMBER,
                                    p_prev_due_date   IN DATE,
                                    p_prev_counter_id IN NUMBER,
                                    p_prev_uom_remain IN NUMBER) RETURN VARCHAR2;

-- procedure checks forecast and adds zero forecast row if missing forecast.
PROCEDURE validate_uf_for_ctr(p_current_usage_tbl       IN counter_values_tbl_type,
                              p_x_forecast_details_tbl IN OUT NOCOPY forecast_details_tbl_type);

------------------------------
-- Declare global variables --
------------------------------
G_config_node_tbl      AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type;
-- This variable holds all the item instances that are contained in a configuration.
-- For AHL installation, this will hold the top node and all of its components.
-- For PM installation, this will contain only one item instance, because each
-- component of a configuration is processed as a unit for this case.

G_forecast_details_tbl forecast_details_tbl_type;
-- This variable holds the forecast information for the unit that is being
-- processed. This variable is set in procedure Process_Unit.

G_last_day_of_window   DATE;
-- This variable holds the last day of the rolling window, calculated based on
-- the profile values set. This is set in procedure Process_Unit.

G_master_config_id  NUMBER;
-- This variable holds the Master config ID if configuration has a master Configuration.
-- Not Applicable for PM installation.

G_application_usg_code VARCHAR2(30);
-- This variable is populated based on the AHL_APPLN_USAGE profile value.
-- 11.5.10 enhancement.

-----------------------
-- Define Procedures --
-----------------------

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
--
--  Process_Unit Parameters :
--      Unit's Effectivity will be built for the input item instance.
--

PROCEDURE Process_Unit (
    p_commit                 IN            VARCHAR2 := FND_API.G_FALSE,
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    x_msg_count              OUT  NOCOPY   NUMBER,
    x_msg_data               OUT  NOCOPY   VARCHAR2,
    x_return_status          OUT  NOCOPY   VARCHAR2,
    p_csi_item_instance_id   IN            NUMBER,
    p_concurrent_flag        IN            VARCHAR2 := 'N')
IS

  l_inventory_item_id  NUMBER;
  l_inv_master_organization_id NUMBER;

  l_uc_header_id    NUMBER;
  -- This variable holds the Unit config ID if configuration is a Unit Configuration.
  -- Not Applicable for PM installation.

  l_csi_item_instance_id  NUMBER;
  -- This variable holds the Root item instance id.
  -- For AHL installation, this is the root item instance of the input parameter p_csi_item_instance_id
  -- For PM installation, this is the item instance input to this procedure(i.e p_csi_item_instance_id).

  l_config_node_tbl      AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type;
  l_forecast_details_tbl forecast_details_tbl_type;

  l_UnSch_programs_tbl   PMprogram_tbl_type;
  -- contains programs and their effectivities.

  l_ret_code             VARCHAR2(30);

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Process_Unit_PVT;

 -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Enable Debug.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Add debug mesg.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Begin private API:' ||  G_PKG_NAME || '.' || 'ProcessUnit');

    -- Dump input parameters.
    AHL_DEBUG_PUB.debug(' Csi Item instance ID:' || p_csi_item_instance_id);
    AHL_DEBUG_PUB.debug(' p_concurrent_flag:' || p_concurrent_flag );
    AHL_DEBUG_PUB.debug(' p_commit:' || p_commit);

  END IF;

  G_concurrent_flag := p_concurrent_flag;

  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Starting Process Unit for item instance: '|| p_csi_item_instance_id);
     --fnd_file.put_line(fnd_file.log, 'G_IS_PM_INSTALLED: '|| G_IS_PM_INSTALLED);
  END IF;

  -- Initialize temporary tables.

  DELETE FROM AHL_TEMP_UNIT_EFFECTIVITIES;
  DELETE FROM AHL_TEMP_UNIT_SR_DEFERRALS;

  -- validate item instance.
  Validate_item_instance(p_csi_item_instance_id, l_inventory_item_id,
                         l_inv_master_organization_id);

  IF FND_MSG_PUB.Count_msg > 0 THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Log success message if called by concurrent program.
  IF (p_concurrent_flag = 'Y') THEN
    fnd_file.put_line (FND_FILE.LOG, 'Validated Instance:'||p_csi_item_instance_id);
  END IF;

  -- set instance variable.
  l_csi_item_instance_id := p_csi_item_instance_id;


  -- Set configuration variables based on installation type.
  IF (G_IS_PM_INSTALLED = 'N') THEN
  -- Only for AHL installation.

      -- If item instance is not top node, find the root item instance.
      l_csi_item_instance_id := Get_RootInstanceID(l_csi_item_instance_id);

      -- Get master and unit configuration IDs if they exist for this item instance.
      Get_Unit_Master_ConfigIDs (l_csi_item_instance_id,
                                 l_uc_header_id, G_master_config_id);

      -- Check for errors.
      IF FND_MSG_PUB.Count_msg > 0 THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Build the Configuration tree structure.(G_config_node_tbl).
      Build_Config_Tree(l_csi_item_instance_id, G_master_config_id, G_CONFIG_NODE_TBL);

  ELSE
  -- For PM installation.

      -- Intialize config node table consisting of the input item instance.
      G_config_node_tbl(1).csi_item_instance_id := p_csi_item_instance_id;

  END IF;  -- pm_install check

  -- Add debug mesg.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug(' Count on Config Node Tbl:' || G_config_node_tbl.COUNT);
    AHL_DEBUG_PUB.debug(' Root Node:' || l_csi_item_instance_id );
    AHL_DEBUG_PUB.debug(' Unit Config ID:' || l_uc_header_id);
    AHL_DEBUG_PUB.debug(' Master Config ID:' || G_master_config_id);
  END IF;

  -- Get rolling window end date.
  G_last_day_of_window := Get_Rolling_Window_Date;

  -- Call FMP to get applicable MRs.
  IF (G_IS_PM_INSTALLED = 'N') THEN
   -- Only for AHL installation.

      IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('AHL Installation processing');
      END IF;

       -- Call FMP api to build applicable MRs for the unit.
       AHL_UMP_UTIL_PKG.Populate_Appl_MRs ( p_csi_ii_id => l_csi_item_instance_id,
                                            --p_include_doNotImplmt => 'N',
                                            p_include_doNotImplmt => 'Y',
                                            x_return_status => x_return_status,
                                            x_msg_count => x_msg_count,
                                            x_msg_data => x_msg_data );

       IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Build applicability for group MRs.
       AHL_UMP_UTIL_PKG.Process_Group_MRs;

  ELSE  -- for PM installation.
       IF G_DEBUG = 'Y' THEN
         AHL_DEBUG_PUB.debug('PM Installation processing');
       END IF;

       -- Call FMP-PM api to build applicable MRs for an instance.
       PopulatePM_Appl_MRs (p_csi_ii_id => l_csi_item_instance_id,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data,
                            x_UnSch_programs_tbl => l_UnSch_programs_tbl);

       IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

  END IF; -- pm_install check.

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('After calling FMP API and process group MRs');
  END IF;

  -- Read applicable utilization forecast for the configuration.
  Get_Utilization_Forecast (l_csi_item_instance_id,
                            l_uc_header_id,
                            l_inventory_item_id,
                            l_inv_master_organization_id,
                            G_forecast_details_tbl);


  -- Lock records.
  FOR i IN 1..4 LOOP
    Lock_UnitEffectivity_Records(x_ret_code => l_ret_code);
    EXIT WHEN (l_ret_code <> '-54');
    DBMS_LOCK.SLEEP(30);
  END LOOP;

  IF (l_ret_code = -54) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_ALREADY_RUNNING');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  /*
  -- Log success message if called by concurrent program.
  IF (p_concurrent_flag = 'Y') THEN
    fnd_file.put_line (FND_FILE.LOG, 'G Config Tbl:' || G_config_node_tbl.COUNT);
    fnd_file.put_line (FND_FILE.LOG, 'G_forecast_details_tbl:' || G_forecast_details_tbl.count);
    fnd_file.put_line (FND_FILE.LOG, 'Last Day window:' || G_last_day_of_window);
    fnd_file.put_line (FND_FILE.LOG, 'UC Header ID:' || l_uc_header_id);
  END IF;
  */

  -- Note: Both of the procedures Process_ASO_Unit and Process_PM_Unit use global variables
  -- set by this procedure in addition to any input parameters.
  IF (G_IS_PM_INSTALLED = 'N') THEN
     Process_ASO_Unit;
  ELSE
     Process_PM_Unit(p_csi_item_instance_id  => l_csi_item_instance_id,
                     p_UnSch_programs_tbl    => l_UnSch_programs_tbl);
  END IF;

  -- Flush from temporary table to ahl_unit_effectivities.
  AHL_UMP_PROCESSUNIT_EXTN_PVT.Flush_From_Temp_Table(G_config_node_tbl);

  -- Check for errors.
  IF FND_MSG_PUB.Count_msg > 0 THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* -- commented for performance fix - bug# 6893404
  IF (G_IS_PM_INSTALLED = 'N') THEN
   -- Only for AHL installation.

    --call for material requirement forecst
    AHL_UMP_FORECAST_REQ_PVT.process_mrl_req_forecast
    (
     p_api_version                => 1.0,
     p_init_msg_list              => FND_API.G_TRUE,
     p_commit                     => FND_API.G_FALSE,
     p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_applicable_instances_tbl   => G_config_node_tbl
    );

    -- Check for errors.
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;
  */

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  -- Log success message if called by concurrent program.
  IF (p_concurrent_flag = 'Y') THEN
    fnd_file.put_line (FND_FILE.LOG, 'Message-Successfully processed:'||p_csi_item_instance_id);
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Process_Unit_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   IF (p_concurrent_flag = 'Y') THEN

     fnd_file.put_line(fnd_file.log, 'Process Unit failed for item instance: '|| p_csi_item_instance_id);
     log_error_messages;
   END IF;

   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Process_Unit_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Process Unit failed for item instance: '|| p_csi_item_instance_id);
     log_error_messages;
   END IF;

   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;

 WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Process_Unit_PVT;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_Unit_PVT',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


    IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Process Unit failed for item instance: '|| p_csi_item_instance_id);
     log_error_messages;
    END IF;

    -- Disable debug
    AHL_DEBUG_PUB.disable_debug;

END Process_Unit;

-------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Process_MRAffected_Units
--  Type        : Private
--  Function    : Processes all units that are affected for a Maintenance requirement.
--  Pre-reqs    :
--  Parameters  :
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
    x_msg_count              OUT NOCOPY    NUMBER,
    x_msg_data               OUT NOCOPY    VARCHAR2,
    x_return_status          OUT NOCOPY    VARCHAR2,
    p_mr_header_id           IN            NUMBER,
    p_old_mr_header_id       IN            NUMBER    := NULL,
    p_concurrent_flag        IN            VARCHAR2  := 'N',
    p_num_of_workers         IN            NUMBER    := 1,
    p_mtl_category_id        IN            NUMBER    := NULL,
    p_process_option         IN            VARCHAR2  := NULL)


IS

  l_commit VARCHAR2(1) := p_commit;

  l_conc_request_id        NUMBER;
  l_req_id                 NUMBER;
  l_instance_id            NUMBER;
  l_num_of_workers         NUMBER;

BEGIN

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Enable Debug.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Add debug mesg.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Begin private API:' ||  G_PKG_NAME || '.' || 'Process_MRAffected_Units');
    AHL_DEBUG_PUB.debug('Application Usage Profile:' || fnd_profile.value('AHL_APPLN_USAGE'));
  END IF;

  IF (p_concurrent_flag = 'Y') THEN
     l_commit := FND_API.G_TRUE;
     l_conc_request_id := fnd_global.conc_request_id;
     IF (l_conc_request_id = -1) OR (l_conc_request_id IS NULL) OR (l_conc_request_id <= 0) THEN
        -- this will happen only when called from UMP Terminate_MR_Instances api.
        l_conc_request_id := fnd_global.login_id;
     END IF;
  ELSE
     l_conc_request_id := fnd_global.session_id;
  END IF;

  -- validate p_num_of_workers.
  l_num_of_workers := trunc(p_num_of_workers);

  IF (l_num_of_workers IS NULL OR l_num_of_workers <= 0) THEN
    l_num_of_workers := 1;
  ELSIF l_num_of_workers > 30 THEN
    l_num_of_workers := 30;
  END IF;

  -- Set FMP parameter based on PM installation.
  IF (G_IS_PM_INSTALLED = 'Y') THEN
     -- PM processing(fix for performance bug# 5093064).
     Process_PM_MR_Affected_Items(
                   p_commit       => l_commit,
 	           x_msg_count    => x_msg_count,
 	           x_msg_data       => x_msg_data,
 	           x_return_status  => x_return_status,
 	           p_mr_header_id    => p_mr_header_id,
 	           p_old_mr_header_id  => p_old_mr_header_id,
                   p_concurrent_flag   => p_concurrent_flag,
                   p_num_of_workers   => l_num_of_workers);
  ELSE

     Populate_BUE_Worker_for_MR(p_conc_request_id => l_conc_request_id,
                                p_mr_header_id    => p_mr_header_id,
                                p_concurrent_flag => p_concurrent_flag,
                                p_mtl_category_id => p_mtl_category_id,
                                p_process_option  => p_process_option,
                                x_return_status   => x_return_status);

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RETURN;
     END IF;

     IF (p_old_mr_header_id IS NOT NULL AND p_old_mr_header_id <> FND_API.G_MISS_NUM) THEN
         -- Call FMP API to get all items instances which have old mr_id in its applicability.
         Populate_BUE_Worker_for_MR(p_conc_request_id => l_conc_request_id,
                                    p_mr_header_id    => p_old_mr_header_id,
                                    p_concurrent_flag => p_concurrent_flag,
                                    p_mtl_category_id => p_mtl_category_id,
                                    p_process_option  => p_process_option,
                                    x_return_status   => x_return_status);
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RETURN;
         END IF;
     END IF; -- p_old_mr_header_id I

     IF (p_concurrent_flag = 'Y') THEN
       -- submit worker programs to process units.
       FOR i IN 1..l_num_of_workers LOOP
         l_req_id := fnd_request.submit_request('AHL','AHLWUEFF',NULL,NULL,FALSE, l_conc_request_id);
         IF (l_req_id = 0 OR l_req_id IS NULL) THEN
            IF G_debug = 'Y' THEN
               AHL_DEBUG_PUB.debug('Tried to submit concurrent request but failed');
            END IF;
            fnd_file.put_line(FND_FILE.LOG, 'Failed submit concurrent request');
            fnd_file.new_line(FND_FILE.LOG,1);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            EXIT; -- abort and return to calling pgm.

         ELSE
            fnd_file.put_line(FND_FILE.LOG, 'Concurrent request ID:' || l_req_id);
            IF G_debug = 'Y' THEN
               AHL_DEBUG_PUB.debug('Concurrent request ID:' || l_req_id );
            END IF;
         END IF; -- l_req_id = 0 OR ..

       END LOOP;

       -- call cleanup BUE for previously failed deletes.
       Cleanup_BUE_Worker(p_parent_conc_request_id => l_conc_request_id,
                          p_child_conc_request_id  => NULL);

     ELSE
         LOOP
            -- initialize return status.
            x_return_status := FND_API.G_RET_STS_SUCCESS;

            -- process each unit from worker table.
            Get_Next_BUE_Row(p_parent_conc_pgm_id  => l_conc_request_id,
                             p_conc_child_req_id   => l_conc_request_id,
                             errbuf                => x_msg_data,
                             x_return_status       => x_return_status,
                             x_item_instance_id    => l_instance_id);

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              EXIT; -- abort and return to calling pgm.
            END IF;

            EXIT WHEN (l_instance_id IS NULL);

            IF G_DEBUG = 'Y' THEN
               AHL_DEBUG_PUB.debug('Now processing..:' || l_instance_id);
            END IF;

            -- Call Process Unit for the item instance.
            Process_Unit (
                  p_commit               => l_commit,
                  p_init_msg_list        => FND_API.G_TRUE,
                  x_msg_count            => x_msg_count,
                  x_msg_data             => x_msg_data,
                  x_return_status        => x_return_status,
                  p_csi_item_instance_id => l_instance_id,
                  p_concurrent_flag      => p_concurrent_flag);

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              EXIT; -- abort and return to calling pgm.
            END IF;

         END LOOP;

         -- cleanup worker table after processing.
         Cleanup_BUE_Worker(p_parent_conc_request_id => l_conc_request_id,
                            p_child_conc_request_id  => l_conc_request_id);

     END IF; -- p_concurrent_flag

  END IF; -- G_IS_PM_INSTALLED.

END Process_MRAffected_Units;

-- Tamal: Bug #4207212, #4114368: Begin
------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Process_PM_Contracts
--  Type        : Private
--  Function    : Retrieves all instances for a contract and calls Process_Unit for each unit.
--  Pre-reqs    :
--  Parameters  :
--
--  p_concurrent_flag                   IN      VARCHAR2
--  This flag will be 'Y' if called from a concurrent program. Based on this flag, the error
--  and informational messages will be logged into the log file.
--  p_contract_number			IN	VARCHAR2
--  The contract number for which want to process csi_item_instances entitlement
--  p_contract_number			IN	VARCHAR2
--  The contract number modifier for above contract number

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
)
IS
    l_msg_count		number;
    l_commit		varchar2(1) := p_commit;

    l_inp_cont_rec           OKS_ENTITLEMENTS_PUB.inp_cont_rec;
    l_ent_cont_tbl           OKS_ENTITLEMENTS_PUB.ent_cont_tbl;

    -- Fix for bug# 5639852.
    CURSOR get_oks_line_end_dt1(p_contract_number IN VARCHAR2,
                                p_contract_modifier IN VARCHAR2)
    IS
      SELECT trunc(min(okl.end_date)), trunc(okh.start_date)
      FROM okc_k_headers_b okh, okc_k_lines_b okl
      WHERE OKL.DNZ_CHR_ID = OKH.ID
        AND OKH.CONTRACT_NUMBER = p_contract_number
        AND OKH.CONTRACT_NUMBER_MODIFIER = p_contract_modifier
        GROUP BY OKH.ID, OKH.start_date;

    CURSOR get_oks_line_end_dt2(p_contract_number IN VARCHAR2)
    IS
      SELECT trunc(min(okl.end_date)), trunc(okh.start_date)
      FROM okc_k_headers_b okh, okc_k_lines_b okl
      WHERE OKL.DNZ_CHR_ID = OKH.ID
        AND OKH.CONTRACT_NUMBER = p_contract_number
        GROUP BY OKH.ID, OKH.start_date;

    l_end_date  DATE;
    l_start_date  DATE;

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Process_PM_Contracts_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize Procedure return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Enable Debug.
    IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.enable_debug;
    END IF;

    -- Add debug mesg.
    IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('Begin private API:' ||  G_PKG_NAME || '.' || 'Process_PM_Contracts');
        -- Dump input parameters.
        AHL_DEBUG_PUB.debug('Contract Number:' || p_contract_number );
        AHL_DEBUG_PUB.debug('Contract Modifier:' || p_contract_modifier );
        AHL_DEBUG_PUB.debug('p_concurrent_flag:' || p_concurrent_flag );
        AHL_DEBUG_PUB.debug('p_commit:' || p_commit );
    END IF;

    IF (p_concurrent_flag = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'Starting processing for contract Number '|| p_contract_number || ' and contract modifier' || p_contract_modifier);
    	-- If the call is from concurrent program, then commit should default to TRUE
    	l_commit := FND_API.G_TRUE;
    END IF;

    l_inp_cont_rec.contract_number := p_contract_number;
    l_inp_cont_rec.contract_number_modifier := p_contract_modifier;
    l_inp_cont_rec.validate_flag := 'Y';

    -- Fix for bug# 5639852 -- Begin.
    l_inp_cont_rec.request_date := NULL;  -- defaults to sysdate.

    -- For signed contracts we need to send a future date.
    -- find out the minimum end date for the contract lines to ensure date
    -- coverage for all service lines.
    IF (p_contract_modifier IS NULL) THEN
       OPEN get_oks_line_end_dt2(p_contract_number);
       FETCH get_oks_line_end_dt2 INTO l_end_date, l_start_date;
       CLOSE get_oks_line_end_dt2;
    ELSE
       OPEN get_oks_line_end_dt1(p_contract_number, p_contract_modifier);
       FETCH get_oks_line_end_dt1 INTO l_end_date, l_start_date;
       CLOSE get_oks_line_end_dt1;
    END IF;

    IF (l_start_date > trunc(sysdate)) THEN
      IF (l_end_date IS NOT NULL) THEN
         l_inp_cont_rec.request_date := l_end_date;
      END IF;
    END IF;
    -- Fix for bug# 5639852 -- End.

    OKS_ENTITLEMENTS_PUB.get_contracts
    (
        p_api_version   => 1.0,
        p_init_msg_list => FND_API.G_FALSE,
        p_inp_rec       => l_inp_cont_rec,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        x_ent_contracts => l_ent_cont_tbl
    );

    -- Check Error Message stack.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF (l_msg_count > 0 or x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_ent_cont_tbl.count > 0)
    THEN
        FOR i IN l_ent_cont_tbl.FIRST..l_ent_cont_tbl.LAST
        LOOP
            IF (l_ent_cont_tbl(i).coverage_level_code = 'COVER_PROD')
            THEN
                IF (p_concurrent_flag = 'Y') THEN
                    fnd_file.put_line(fnd_file.log, 'Calling Process_Unit for instance: ' || l_ent_cont_tbl(i).coverage_level_id);
                END IF;
                AHL_UMP_ProcessUnit_PVT.Process_Unit
                (
                    p_commit               => l_commit,
                    x_msg_count            => x_msg_count,
                    x_msg_data             => x_msg_data,
                    x_return_status        => x_return_status,
                    p_csi_item_instance_id => l_ent_cont_tbl(i).coverage_level_id,
                    p_concurrent_flag      => p_concurrent_flag
                );
                IF (p_concurrent_flag = 'Y' and (FND_MSG_PUB.count_msg > 0 or x_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
                    fnd_file.put_line(fnd_file.log, 'Process_Unit failed for instance: ' || l_ent_cont_tbl(i).coverage_level_id);
                END IF;
            END IF;
        END LOOP;
    END IF;

    -- Check Error Message stack.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF (l_msg_count > 0 or x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Log success message if called by concurrent program.
    IF (p_concurrent_flag = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'Message-Successfully processed: contract Number '|| p_contract_number || ' and contract modifier' || p_contract_modifier);
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get
    (
        p_count => x_msg_count,
        p_data  => x_msg_data,
        p_encoded => fnd_api.g_false
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Rollback to Process_PM_Contracts_PVT;
        FND_MSG_PUB.count_and_get
        (
            p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false
        );
        IF (p_concurrent_flag = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'Process_PM_Contracts failed for: contract Number '|| p_contract_number || ' and contract modifier' || p_contract_modifier);
            log_error_messages;
        END IF;
        AHL_DEBUG_PUB.disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_PM_Contracts_PVT;
        FND_MSG_PUB.count_and_get
        (
            p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false
        );
        IF (p_concurrent_flag = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'Process_PM_Contracts failed for: contract Number '|| p_contract_number || ' and contract modifier' || p_contract_modifier);
            log_error_messages;
        END IF;
        AHL_DEBUG_PUB.disable_debug;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_PM_Contracts_PVT;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            fnd_msg_pub.add_exc_msg
            (
                p_pkg_name       => G_PKG_NAME,
                p_procedure_name => 'Process_PM_Contracts',
                p_error_text     => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false
        );
        IF (p_concurrent_flag = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'Process_PM_Contracts failed for: contract Number '|| p_contract_number || ' and contract modifier' || p_contract_modifier);
            log_error_messages;
        END IF;
        AHL_DEBUG_PUB.disable_debug;
END Process_PM_Contracts;
-- Tamal: Bug #4207212, #4114368: End

------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Process_All_Units
--  Type        : Private
--  Function    : Loops through all units and calls Process_Unit for each unit.
--  Pre-reqs    :
--  Parameters  :
--
--  p_concurrent_flag                   IN      VARCHAR2
--  This flag will be 'Y' if called from a concurrent program. Based on this flag, the error
--  and informational messages will be logged into the log file by Process_Unit.

PROCEDURE Process_All_Units (
    p_commit                 IN            VARCHAR2 := FND_API.G_FALSE,
    x_msg_count              OUT  NOCOPY   NUMBER,
    x_msg_data               OUT  NOCOPY   VARCHAR2,
    x_return_status          OUT  NOCOPY   VARCHAR2,
    p_concurrent_flag        IN            VARCHAR2  := 'N',
    p_num_of_workers         IN            NUMBER    := 1,
    p_mtl_category_id        IN            NUMBER    := NULL,
    p_process_option         IN            VARCHAR2  := NULL)

IS

  -- uncommented query to fix performance issue 6893404
  -- declare cursor to retrieve min/max instances from Installed Base for PM installation.
  CURSOR csi_pm_instance_csr IS
     SELECT min(instance_id), max(instance_id)
     FROM csi_item_instances csi,
     (select me.inventory_item_id
      from ahl_mr_effectivities me, ahl_mr_headers_app_v mr
      where mr.mr_header_id = me.mr_header_id
        and mr.type_code = 'PROGRAM') mre
     WHERE trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate) AND
           trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
     AND mre.inventory_item_id = csi.inventory_item_id;


  l_commit VARCHAR2(1) := p_commit;

  l_min_csi_id             NUMBER;
  l_max_csi_id             NUMBER;

BEGIN

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Enable Debug.
  -- Add api start debug mesg.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug('Begin private API:' ||  G_PKG_NAME || '.' || 'Process_All_Units');
  END IF;

  -- For concurrent program.
  IF (p_concurrent_flag = 'Y') THEN
     l_commit := FND_API.G_TRUE;
  END IF;

  IF (G_IS_PM_INSTALLED = 'N') THEN
     -- AHL processing.
     Split_Process_All_Instances(p_concurrent_flag => p_concurrent_flag,
                                 p_commit_flag     => l_commit,
                                 p_num_of_workers  => p_num_of_workers,
                                 p_mr_header_id    => null,
                                 p_mtl_category_id => p_mtl_category_id,
                                 p_process_option  => p_process_option,
                                 x_msg_count       => x_msg_count,
                                 x_msg_data        => x_msg_data,
                                 x_return_status   => x_return_status);

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RETURN;
     END IF;

  ELSE
     -- PM processing.
     OPEN csi_pm_instance_csr;
     FETCH csi_pm_instance_csr INTO l_min_csi_id, l_max_csi_id;
     CLOSE csi_pm_instance_csr;

     Instance_Split_Sequential(p_csi_max_id  => l_max_csi_id,
                               p_csi_min_id  => l_min_csi_id,
                               p_num_workers => p_num_of_workers,
                               p_mr_header_id => null);
  END IF; -- pm installation check.

END Process_All_Units;

--------------------------------------------------------------------------
PROCEDURE Validate_Item_Instance (p_csi_item_instance_id IN NUMBER,
                                  x_inventory_item_id    OUT NOCOPY NUMBER,
                                  x_inv_master_organization_id OUT NOCOPY NUMBER)
IS

-- To validate instance.
  CURSOR csi_item_instances_csr(p_csi_item_instance_id IN  NUMBER) IS
    SELECT instance_number, active_end_date, inventory_item_id,
           inv_master_organization_id
    FROM csi_item_instances
    WHERE instance_id = p_csi_item_instance_id;

l_inventory_item_id           NUMBER;
l_inv_master_organization_id  NUMBER;
l_instance_number             csi_item_instances.instance_number%TYPE;
l_active_end_date             DATE;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug('Start Validate Item Instance');
  END IF;

  -- Validate csi_item_instance_id.
  IF (p_csi_item_instance_id IS NOT NULL) THEN
    OPEN csi_item_instances_csr (p_csi_item_instance_id);
    FETCH csi_item_instances_csr INTO l_instance_number, l_active_end_date,
                                     l_inventory_item_id, l_inv_master_organization_id;
    IF (csi_item_instances_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_INSTID_NOTFOUND');
      FND_MESSAGE.Set_Token('INST_ID', p_csi_item_instance_id);
      FND_MSG_PUB.ADD;
      CLOSE csi_item_instances_csr;
      --dbms_output.put_line('Instance not found');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (trunc(l_active_end_date) < trunc(sysdate)) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_INST_EXPIRED');
      FND_MESSAGE.Set_Token('NUMBER', l_instance_number);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Instance has expired');
    END IF;

    CLOSE csi_item_instances_csr;
  END IF;

  x_inventory_item_id := l_inventory_item_id;
  x_inv_master_organization_id := l_inv_master_organization_id;

  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('End Validate Item Instance');
  END IF;

END Validate_Item_Instance;

-----------------------------------------------------------------------------
-- To get the unit and master configurations IDs for the input item instance.

PROCEDURE Get_Unit_Master_ConfigIDs (p_csi_item_instance_id IN NUMBER,
                                     x_uc_header_id OUT NOCOPY NUMBER,
                                     x_master_config_id OUT NOCOPY NUMBER)
IS

  -- To get unit config id.
  CURSOR ahl_unit_config_header_csr (p_item_instance_id IN NUMBER) IS
    SELECT name, active_start_date, active_end_date, master_config_id, unit_config_header_id,
           unit_config_status_code
    FROM  ahl_unit_config_headers
    WHERE csi_item_instance_id = p_item_instance_id
      --AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate) AND
      --    trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
      AND parent_uc_header_id IS NULL;

  l_name              ahl_unit_config_headers.name%TYPE;
  l_active_start_date DATE;
  l_active_end_date   DATE;
  l_master_config_id  NUMBER;
  l_unit_config_header_id NUMBER;
  l_config_status_code    fnd_lookup_values_vl.lookup_code%TYPE;

BEGIN

    IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('Start Get_Unit_Master_ConfigIDs');
    END IF;

     x_uc_header_id := null;
     x_master_config_id := null;

    IF (p_csi_item_instance_id IS NOT NULL) THEN
      OPEN ahl_unit_config_header_csr (p_csi_item_instance_id);
      FETCH ahl_unit_config_header_csr INTO l_name, l_active_start_date,
                                            l_active_end_date, l_master_config_id,
                                            l_unit_config_header_id,
                                            l_config_status_code;
      IF (ahl_unit_config_header_csr%FOUND) THEN
        --IF (l_config_status_code <> 'COMPLETE' AND l_config_status_code <> 'INCOMPLETE') THEN
        --modified for quaratine statuses.
        IF (l_config_status_code = 'DRAFT') THEN
           FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_STATUS_INVALID');
           FND_MESSAGE.Set_Token('NAME',l_name);
           FND_MSG_PUB.ADD;
           --dbms_output.put_line('UC is in draft status');
        ELSE
           x_uc_header_id := l_unit_config_header_id;
           x_master_config_id := l_master_config_id;
        END IF;
      END IF;
      CLOSE ahl_unit_config_header_csr;
    END IF;

    IF (G_concurrent_flag = 'Y') THEN
      fnd_file.put_line (FND_FILE.LOG, 'Unit Config Name:' || l_name);
    END IF;

    IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('Unit Config ID:' || x_uc_header_id);
        AHL_DEBUG_PUB.debug('Master Config ID:' || x_master_config_id);
        AHL_DEBUG_PUB.debug('End Get_Unit_Master_ConfigIDs');
    END IF;

END Get_Unit_Master_ConfigIDs;

-----------------------------------------------------------------------
-- To get the root item instance for the input item instance if exists.

FUNCTION Get_RootInstanceID(p_csi_item_instance_id IN NUMBER)
RETURN NUMBER
IS

  CURSOR csi_root_instance_csr (p_instance_id IN NUMBER) IS
    SELECT root.object_id
    FROM csi_ii_relationships root
    WHERE NOT EXISTS (SELECT 'x'
                      FROM csi_ii_relationships
                      WHERE subject_id = root.object_id
                        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                      )
    START WITH root.subject_id = p_instance_id
               AND root.relationship_type_code = 'COMPONENT-OF'
               AND trunc(nvl(root.active_start_date,sysdate)) <= trunc(sysdate)
               AND trunc(sysdate) < trunc(nvl(root.active_end_date, sysdate+1))
    CONNECT BY PRIOR root.object_id = root.subject_id
                     AND root.relationship_type_code = 'COMPONENT-OF'
                     AND trunc(nvl(root.active_start_date,sysdate)) <= trunc(sysdate)
                     AND trunc(sysdate) < trunc(nvl(root.active_end_date, sysdate+1));

  l_csi_instance_id  NUMBER;

BEGIN

  -- get root instance given an item instance_id.
  OPEN csi_root_instance_csr (p_csi_item_instance_id);
  FETCH csi_root_instance_csr INTO l_csi_instance_id;
  IF (csi_root_instance_csr%NOTFOUND) THEN
     -- input id is root instance.
     l_csi_instance_id := p_csi_item_instance_id;
  END IF;
  CLOSE csi_root_instance_csr;
  --dbms_output.put_line ('root instance' || l_csi_instance_id);

  RETURN  l_csi_instance_id;

END Get_RootInstanceID;

-------------------------------------------------------------
-- Validate the input item instance.

PROCEDURE Build_Config_Tree(p_csi_root_instance_id IN         NUMBER,
                            p_master_config_id     IN         NUMBER,
                            x_config_node_tbl      OUT NOCOPY AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type)

IS

  CURSOR csi_config_tree_csr ( p_csi_root_instance_id IN NUMBER) IS
    SELECT subject_id , object_id, position_reference
    FROM csi_ii_relationships
    START WITH object_id = p_csi_root_instance_id
               AND relationship_type_code = 'COMPONENT-OF'
               AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
               AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    CONNECT BY PRIOR subject_id = object_id
                     AND relationship_type_code = 'COMPONENT-OF'
                     AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                     AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    ORDER BY level;

  i  NUMBER;
  l_config_node_tbl   AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type := x_config_node_tbl;

  -- added for perf fix for bug# 6893404.
  l_buffer_limit      number := 1000;

  l_subj_id_tbl       nbr_tbl_type;
  l_obj_id_tbl        nbr_tbl_type;
  l_posn_ref_tbl      vchar_tbl_type;

BEGIN

  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('Start Build_Config_Tree');
  END IF;

   -- For top node.
  l_config_node_tbl(1).csi_item_instance_id := p_csi_root_instance_id;

  -- For position reference.
  IF (p_master_config_id IS NOT NULL) THEN
    l_config_node_tbl(1).position_reference := to_char(p_master_config_id);
  END IF;

  i := 1;

  -- add child nodes.
  -- added for perf fix for bug# 6893404.
  OPEN csi_config_tree_csr(p_csi_root_instance_id);
  LOOP
    FETCH csi_config_tree_csr BULK COLLECT INTO l_subj_id_tbl, l_obj_id_tbl, l_posn_ref_tbl
                              LIMIT l_buffer_limit;

    EXIT WHEN (l_subj_id_tbl.count = 0);

    FOR j IN l_subj_id_tbl.FIRST..l_subj_id_tbl.LAST LOOP

      -- Loop through to get all components of the configuration.
      -- FOR node_rec IN csi_config_tree_csr(p_csi_root_instance_id) LOOP
      i := i + 1;

      --l_config_node_tbl(i).csi_item_instance_id := node_rec.subject_id;
      --l_config_node_tbl(i).object_id := node_rec.object_id;
      --l_config_node_tbl(i).position_reference := node_rec.position_reference;

      l_config_node_tbl(i).csi_item_instance_id := l_subj_id_tbl(j);
      l_config_node_tbl(i).object_id            := l_obj_id_tbl(j);
      l_config_node_tbl(i).position_reference   := l_posn_ref_tbl(j);

    END LOOP; -- l_subj_id_tbl.FIRST

    -- reset tables and get the next batch of nodes.
    l_subj_id_tbl.DELETE;
    l_obj_id_tbl.DELETE;
    l_posn_ref_tbl.DELETE;

  END LOOP; -- FETCH csi_config_tree_csr
  CLOSE csi_config_tree_csr;

  X_CONFIG_NODE_TBL := l_config_node_tbl;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug('End Build_Config_Tree');
     AHL_DEBUG_PUB.debug('Count on config' || x_config_node_tbl.COUNT);
  END IF;

END Build_Config_Tree;

-----------------------------------------------------------------------
-- This function calculates the last day of the rolling window based on
-- profile values.

FUNCTION Get_Rolling_Window_Date RETURN DATE  IS

  l_date_uom            VARCHAR2(30);
  l_value               NUMBER;
  l_last_day_of_window  DATE;

BEGIN

   BEGIN
     l_date_uom := FND_PROFILE.VALUE('AHL_UMP_MAX_PLANNING_UOM');
     l_value    := to_number(FND_PROFILE.VALUE('AHL_UMP_MAX_PLANNING_VALUE'));

     IF (l_date_uom IS NULL) THEN
        l_last_day_of_window := SYSDATE;
     ELSIF (l_value <= 0 OR l_value IS NULL) THEN
        l_last_day_of_window := SYSDATE;
     ELSIF (l_date_uom = 'YR') THEN
        l_last_day_of_window := ADD_MONTHS(SYSDATE, 12 * l_value);
     ELSIF (l_date_uom = 'MTH') THEN
        l_last_day_of_window := ADD_MONTHS(SYSDATE, l_value);
     ELSIF (l_date_uom = 'WK') THEN
        l_last_day_of_window := SYSDATE + (7 * l_value);
     ELSIF (l_date_uom = 'DAY') THEN
        l_last_day_of_window := SYSDATE + l_value;
     END IF;

     -- Add debug mesg.
     IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.debug('last day of window' || l_last_day_of_window);
       AHL_DEBUG_PUB.debug('profile uom:' || l_date_uom);
       AHL_DEBUG_PUB.debug('profile value:' || l_value);
     END IF;

   EXCEPTION
     WHEN VALUE_ERROR THEN
        l_last_day_of_window := SYSDATE;

     WHEN INVALID_NUMBER THEN
        l_last_day_of_window := SYSDATE;

   END;

   -- return date.
   RETURN l_last_day_of_window;

END Get_Rolling_Window_Date;

--------------------------------------------------------------------
-- Get the utilization forecast applicable to the input item instance/unit.
-- For preventive maintenance, forecast definition is at either instance level
-- or item level.
PROCEDURE Get_Utilization_Forecast (p_csi_item_instance_id IN NUMBER,
                                    p_uc_header_id         IN NUMBER,
                                    p_inventory_item_id    IN NUMBER,
                                    p_inventory_org_id     IN NUMBER,
                                    x_forecast_details_tbl OUT NOCOPY forecast_details_tbl_type)
IS

  CURSOR ahl_uf_headers_csr(p_uc_header_id IN NUMBER) IS
    SELECT uf_header_id, use_unit_flag
    FROM ahl_uf_headers
    WHERE unit_config_header_id = p_uc_header_id;

  CURSOR ahl_uf_details_csr(p_uf_header_id IN NUMBER) IS
    SELECT uom_code, start_date, end_date, usage_per_day
    FROM   ahl_uf_details
    WHERE uf_header_id = p_uf_header_id
    AND trunc(nvl(end_date, sysdate)) >= trunc(sysdate)
    order by uom_code, start_date;

  CURSOR ahl_pm_uf_headers_csr(p_csi_item_instance_id IN NUMBER) IS
    SELECT uf_header_id, use_unit_flag
    FROM ahl_uf_headers
    WHERE csi_item_instance_id = p_csi_item_instance_id;

  CURSOR ahl_pm_item_uf_csr (p_csi_item_instance_id  IN  NUMBER) IS
    SELECT uom_code, start_date, end_date, usage_per_day
    FROM ahl_uf_headers uh, ahl_uf_details ud, csi_item_instances csi
    WHERE uh.uf_header_id = ud.uf_header_id
    AND csi.instance_id = p_csi_item_instance_id
    AND csi.inventory_item_id = uh.inventory_item_id
    AND trunc(nvl(end_date, sysdate)) >= trunc(sysdate)
    order by uom_code, start_date;

  l_uf_header_id  NUMBER;
  l_use_unit_flag   AHL_UF_HEADERS.USE_UNIT_FLAG%TYPE;
  l_uf_details_tbl  AHL_UMP_UF_PVT.uf_details_tbl_type;

  l_index  NUMBER := 1;
  l_forecast_details_tbl  forecast_details_tbl_type;
  l_return_status   VARCHAR2(1);

  -- Added to fix bug# 6326056.
  l_duplicate_flag  VARCHAR2(1);

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug('Start Get_Utilization_Forecast');
     AHL_DEBUG_PUB.debug ('Input csi'|| p_csi_item_instance_id);
     AHL_DEBUG_PUB.debug ('Input uc'|| p_uc_header_id);
     AHL_DEBUG_PUB.debug ('Input invID' || p_inventory_item_id);
     AHL_DEBUG_PUB.debug ('Input invORGID' || p_inventory_org_id);
  END IF;

  -- Check installation to get appropriate forecast.
  IF (G_IS_PM_INSTALLED = 'Y') THEN
    -- pm is installed.

    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.debug('PM forecast');
    END IF;

    -- Check if forecast available at instance level.
    OPEN ahl_pm_uf_headers_csr(p_csi_item_instance_id);
    FETCH ahl_pm_uf_headers_csr INTO l_uf_header_id, l_use_unit_flag;
    IF (ahl_pm_uf_headers_csr%FOUND) AND (l_use_unit_flag = 'Y') THEN
       --dbms_output.put_line('Found uf header and use_unit_flag' || l_uf_header_id);

       -- initialize.
       l_index := 1;
       FOR l_forecast_detail_rec IN ahl_uf_details_csr(l_uf_header_id) LOOP
           l_forecast_details_tbl(l_index).uom_code := l_forecast_detail_rec.uom_code;
           l_forecast_details_tbl(l_index).start_date := trunc(l_forecast_detail_rec.start_date);
           l_forecast_details_tbl(l_index).end_date   := trunc(l_forecast_detail_rec.end_date);
           l_forecast_details_tbl(l_index).usage_per_day := l_forecast_detail_rec.usage_per_day;

           l_index := l_index + 1;

       END LOOP;
    ELSE  -- use item forecast.
       --dbms_output.put_line ('item forecast');

       -- initialize.
       l_index := 1;
       FOR l_forecast_detail_rec IN ahl_pm_item_uf_csr(p_csi_item_instance_id) LOOP
           l_forecast_details_tbl(l_index).uom_code := l_forecast_detail_rec.uom_code;
           l_forecast_details_tbl(l_index).start_date := trunc(l_forecast_detail_rec.start_date);
           l_forecast_details_tbl(l_index).end_date   := trunc(l_forecast_detail_rec.end_date);
           l_forecast_details_tbl(l_index).usage_per_day := l_forecast_detail_rec.usage_per_day;

           l_index := l_index + 1;

       END LOOP;
    END IF;
    CLOSE ahl_pm_uf_headers_csr;
  ELSE -- is_pm_installed.
  -- forecast for AHL installation.
    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.debug('AHL Installation forecast');
    END IF;

    -- If Utlization forecast defined at unit level
    IF (p_uc_header_id IS NOT NULL) THEN
       --dbms_output.put_line ('uc header not null');
       -- check if forecast defined.
       OPEN ahl_uf_headers_csr (p_uc_header_id);
       FETCH ahl_uf_headers_csr INTO l_uf_header_id, l_use_unit_flag;
       IF (ahl_uf_headers_csr%FOUND) AND (l_use_unit_flag = 'Y') THEN
          FOR l_forecast_detail_rec IN ahl_uf_details_csr(l_uf_header_id) LOOP
            l_forecast_details_tbl(l_index).uom_code := l_forecast_detail_rec.uom_code;
            l_forecast_details_tbl(l_index).start_date := trunc(l_forecast_detail_rec.start_date);
            l_forecast_details_tbl(l_index).end_date   := trunc(l_forecast_detail_rec.end_date);
            l_forecast_details_tbl(l_index).usage_per_day := l_forecast_detail_rec.usage_per_day;

            l_index := l_index + 1;

          END LOOP;
       ELSE /* forecast not defined at UC */
          --dbms_output.put_line ('use_unit_flag not Y');
          IF G_DEBUG = 'Y' THEN
             AHL_DEBUG_PUB.debug('AHL PC forecast for UNIT');
          END IF;

          -- added parameter p_add_unit_item_forecast to fix bug# 6749351.
          AHL_UMP_UF_PVT.Get_UF_FROM_PC (p_unit_config_header_id => p_uc_header_id,
                                         p_add_unit_item_forecast => 'Y',
                                         p_onward_end_date => trunc(sysdate),
                                         x_uf_details_tbl => l_uf_details_tbl,
                                         x_return_status => l_return_status);
          /* This will give forecast defined item/pc_node level. */

          IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- populate l_forecast_details_tbl based on l_uf_details_tbl.
          IF (l_uf_details_tbl.COUNT) > 0 THEN
            l_index := 1;

            FOR i IN l_uf_details_tbl.FIRST..l_uf_details_tbl.LAST LOOP
              l_forecast_details_tbl(l_index).uom_code := l_uf_details_tbl(i).uom_code;
              l_forecast_details_tbl(l_index).start_date := trunc(l_uf_details_tbl(i).start_date);
              l_forecast_details_tbl(l_index).end_date   := trunc(l_uf_details_tbl(i).end_date);
              l_forecast_details_tbl(l_index).usage_per_day := l_uf_details_tbl(i).usage_per_day;

              l_index := l_index + 1;

            END LOOP;

          END IF; /* count > 0 */

       END IF; -- %found.
       CLOSE ahl_uf_headers_csr;
    ELSE
       IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('AHL PC forecast for ITEM');
       END IF;
       --dbms_output.put_line ('inv case');

       /* following taken care by get_uf_from_pc as part fix for bug# 6749351.
       -- first get forecast at item level (fix for bug# 6002569).
       -- initialize.
       l_index := 1;
       FOR l_forecast_detail_rec IN ahl_pm_item_uf_csr(p_csi_item_instance_id)
       LOOP
           l_forecast_details_tbl(l_index).uom_code := l_forecast_detail_rec.uom_code;
           l_forecast_details_tbl(l_index).start_date := trunc(l_forecast_detail_rec.start_date);
           l_forecast_details_tbl(l_index).end_date   := trunc(l_forecast_detail_rec.end_date);
           l_forecast_details_tbl(l_index).usage_per_day := l_forecast_detail_rec.usage_per_day;

           l_index := l_index + 1;

       END LOOP;
       */
       /* Next, get forecast defined at instance's item/pc node level. */
       -- set parameter to get forecast at item level as well.
       AHL_UMP_UF_PVT.Get_UF_FROM_PC (p_inventory_item_id => p_inventory_item_id,
                                      p_inventory_org_id => p_inventory_org_id,
                                      p_add_unit_item_forecast => 'Y',
                                      p_onward_end_date => trunc(sysdate),
                                      x_uf_details_tbl => l_uf_details_tbl,
                                      x_return_status => l_return_status);

       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Bug# 6749351:Removed duplicate check which is now taken care by get_uf_from_pc.
       IF (l_uf_details_tbl.count > 0) THEN
           l_index := 1;

           FOR i IN l_uf_details_tbl.FIRST..l_uf_details_tbl.LAST LOOP

              l_forecast_details_tbl(l_index).uom_code := l_uf_details_tbl(i).uom_code;
              l_forecast_details_tbl(l_index).start_date := trunc(l_uf_details_tbl(i).start_date);
              l_forecast_details_tbl(l_index).end_date   := trunc(l_uf_details_tbl(i).end_date);
              l_forecast_details_tbl(l_index).usage_per_day := l_uf_details_tbl(i).usage_per_day;
              l_index := l_index + 1;

           END LOOP; -- l_uf_details_tbl
       END IF; -- l_uf_details_tbl.count

    END IF; -- p_uc_header_id is not null.

  END IF; -- end pm installed check.

  -- Set output variable for forecast.
  x_forecast_details_tbl := l_forecast_details_tbl;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('Count on forecast_details' || x_forecast_details_tbl.COUNT);

     IF (x_forecast_details_tbl.COUNT > 0) THEN
       FOR i IN x_forecast_details_tbl.FIRST..x_forecast_details_tbl.LAST LOOP
             AHL_DEBUG_PUB.debug('Forecast Record ('|| i || ') Uom_Code' || x_forecast_details_tbl(i).uom_code);
             AHL_DEBUG_PUB.debug('Forecast Record ('|| i || ') Start Date' || x_forecast_details_tbl(i).start_date);
             AHL_DEBUG_PUB.debug('Forecast Record ('|| i || ') End Date' || x_forecast_details_tbl(i).end_date);
             AHL_DEBUG_PUB.debug('Forecast Record ('|| i || ') Usage' || x_forecast_details_tbl(i).usage_per_day);
       END LOOP;
     END IF;

     AHL_DEBUG_PUB.debug ('End Get_Utilization_Forecast');

  END IF;

END Get_Utilization_Forecast;

-----------------------------------------
-- Lock all existing unit effectivity records.
-- Modified for perf. bug# 6893404.
PROCEDURE Lock_UnitEffectivity_Records(x_ret_code  OUT NOCOPY VARCHAR2) IS

  /*
  CURSOR ahl_unit_effectivities_csr (p_csi_item_instance_id IN NUMBER) IS
    SELECT UNIT_EFFECTIVITY_ID
    FROM AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE csi_item_instance_id = p_csi_item_instance_id
    AND (status_code IS NULL OR status_code = 'INIT-DUE')
    FOR UPDATE OF object_version_number NOWAIT;
  */

  /* 13 Jul 08: Modified query for performance. Instead of looping for every
   * instance, we loop for the configuration.
  -- 13 Jul 08: Modified query to use status_code instead of object_version_number
  CURSOR ahl_unit_effectivities_csr (p_csi_item_instance_id IN NUMBER) IS
    --SELECT UNIT_EFFECTIVITY_ID
    SELECT 1
    FROM AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE csi_item_instance_id = p_csi_item_instance_id
    AND (status_code IS NULL OR status_code IN ('INIT-DUE','EXCEPTION'))
    FOR UPDATE OF status_code NOWAIT;
  */

  CURSOR ahl_unit_effectivities_csr (p_csi_item_instance_id IN NUMBER) IS
    WITH II AS (SELECT p_csi_item_instance_id instance_id
                FROM DUAL
                UNION ALL
                SELECT A.SUBJECT_ID INSTANCE_ID
                FROM CSI_II_RELATIONSHIPS A
                START WITH OBJECT_ID = p_csi_item_instance_id
                  AND RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                  AND SYSDATE BETWEEN TRUNC(NVL(ACTIVE_START_DATE,SYSDATE))
                  AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1))
                CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID
                  AND RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                  AND SYSDATE BETWEEN TRUNC(NVL(ACTIVE_START_DATE,SYSDATE))
                  AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1))
               )
    SELECT 1
    FROM AHL_UNIT_EFFECTIVITIES_APP_V UE, II
    WHERE UE.csi_item_instance_id = II.INSTANCE_ID
    AND (status_code IS NULL OR status_code IN ('INIT-DUE','EXCEPTION'))
    FOR UPDATE OF status_code NOWAIT;

  --l_next_rec_flag  BOOLEAN;
  --l_unit_effectivity_id NUMBER;

  l_ue_id_tbl      nbr_tbl_type;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('Start Lock Effectivity records');
  END IF;

  x_ret_code := '0';

  /*
  -- Lock all records for all item instances in G_config_node_tbl.
  IF G_config_node_tbl.COUNT > 0 THEN
     FOR i IN G_config_node_tbl.FIRST..G_config_node_tbl.LAST LOOP
        OPEN ahl_unit_effectivities_csr(G_config_node_tbl(i).csi_item_instance_id);
        IF ahl_unit_effectivities_csr%NOTFOUND THEN
          --dbms_output.put_line (' in lock effecti - no record found');
          CLOSE ahl_unit_effectivities_csr;
          EXIT;
        END IF;
        l_next_rec_flag := TRUE;  -- there is at least one record
        WHILE (l_next_rec_flag) LOOP
           FETCH ahl_unit_effectivities_csr INTO l_unit_effectivity_id;
           IF ahl_unit_effectivities_csr%NOTFOUND THEN
              l_next_rec_flag := FALSE;
           END IF;
        END LOOP;
        CLOSE ahl_unit_effectivities_csr;
     END LOOP;
  END IF;
  */

  /* 13 Jul 08: Modified query for performance. Instead of looping for every
   * instance, we loop for the configuration.
  -- Lock all records for all item instances in G_config_node_tbl.
  IF G_config_node_tbl.COUNT > 0 THEN
    FOR i IN G_config_node_tbl.FIRST..G_config_node_tbl.LAST LOOP
       OPEN ahl_unit_effectivities_csr(G_config_node_tbl(i).csi_item_instance_id);
       LOOP
         FETCH ahl_unit_effectivities_csr BULK COLLECT INTO l_ue_id_tbl LIMIT 5000;
         IF G_DEBUG = 'Y' THEN
           AHL_DEBUG_PUB.debug ('Rows processed for instance: ' || G_config_node_tbl(i).csi_item_instance_id
                                  || 'is: ' || ahl_unit_effectivities_csr%ROWCOUNT);
         END IF;
         --EXIT WHEN ahl_unit_effectivities_csr%NOTFOUND;
         EXIT WHEN (l_ue_id_tbl.count = 0);

         -- delete tbl
         l_ue_id_tbl.delete;

       END LOOP;
       CLOSE ahl_unit_effectivities_csr;
    END LOOP;
  END IF;
  */

  IF (G_config_node_tbl.COUNT <= 0) THEN
    -- this should never happen.
    RETURN;
  END IF;

  -- G_config_node_tbl(1).csi_item_instance_id contains root node.
  -- Lock all records for all item instances in G_config_node_tbl.
  OPEN ahl_unit_effectivities_csr(G_config_node_tbl(1).csi_item_instance_id);
  LOOP
       FETCH ahl_unit_effectivities_csr BULK COLLECT INTO l_ue_id_tbl LIMIT 5000;
       IF G_DEBUG = 'Y' THEN
         AHL_DEBUG_PUB.debug ('Rows processed are: ' || ahl_unit_effectivities_csr%ROWCOUNT);
       END IF;
       --EXIT WHEN ahl_unit_effectivities_csr%NOTFOUND;
       EXIT WHEN (l_ue_id_tbl.count = 0);

       -- delete tbl
       l_ue_id_tbl.delete;
  END LOOP;

  CLOSE ahl_unit_effectivities_csr;


  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('End Lock Effectivity records');
  END IF;

EXCEPTION

WHEN OTHERS THEN
  IF (SQLCODE = -54) THEN
     --FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_ALREADY_RUNNING');
     --FND_MSG_PUB.ADD;
     --RAISE  FND_API.G_EXC_ERROR;
     x_ret_code := '-54';
  ELSE
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Lock_UnitEffectivity_Records',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

END Lock_UnitEffectivity_Records;

--------------------------------------------------------------------------------
-- Process Unit for ASO installation.
PROCEDURE Process_ASO_Unit IS

  CURSOR ahl_applicable_MRs (p_csi_item_instance_id IN NUMBER) IS
    SELECT DISTINCT appl.csi_item_instance_id,
                    appl.MR_header_id,
                    mr.Title,
                    mr.version_number,
                    appl.Implement_status_code,
                    appl.copy_accomplishment_code,
                    appl.repetitive_flag,
                    appl.show_repetitive_code,
                    appl.preceding_mr_header_id,
                    appl.descendent_count,
                    mr.whichever_first_code,
                    mr.effective_to,
                    mr.effective_from
    --FROM ahl_applicable_MRs appl, ahl_mr_headers_vl mr
    FROM ahl_applicable_MRs appl, ahl_mr_headers_b mr
    WHERE appl.csi_item_instance_id = p_csi_item_instance_id
       AND (appl.implement_status_code <> 'OPTIONAL_DO_NOT_IMPLEMENT')
       AND appl.preceding_mr_header_id IS NULL
       AND appl.mr_header_id = mr.mr_header_id
       AND trunc(nvl(mr.effective_from,sysdate)) <= trunc(sysdate)
       AND trunc(sysdate) <= trunc(nvl(mr.effective_to,sysdate+1))
    ORDER BY descendent_count DESC;

  l_applicable_mr_rec applicable_mrs_rec_type;

  l_current_usage_tbl    counter_values_tbl_type;
  /* contains current counter usage */

  l_counter_rules_tbl    counter_rules_tbl_type;
  /* contains current counter rules for the position */

BEGIN

  -- Process Unit beginning with top node.
  IF G_config_node_tbl.COUNT > 0 THEN
    FOR i IN G_config_node_tbl.FIRST..G_config_node_tbl.LAST LOOP
       IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('Processing for..:' || G_config_node_tbl(i).csi_item_instance_id );
       END IF;

       -- Build counter rules ratio if node is not root node.
       IF (G_master_config_id IS NOT NULL AND G_config_node_tbl(i).object_id IS NOT NULL) THEN
           build_Counter_Ratio(G_config_node_tbl(i).position_reference,
                               G_config_node_tbl(i).csi_item_instance_id,
                               G_master_config_id,
                               l_counter_rules_tbl);
       END IF;

       -- Get current usage for all the counters defined for the item instance.
       get_Current_Usage (G_config_node_tbl(i).csi_item_instance_id,
                          l_current_usage_tbl);

       -- Add zero forecast row to G_forecast_details_tbl if forecast missing for a UOM.
       validate_uf_for_ctr(p_current_usage_tbl => l_current_usage_tbl,
                           p_x_forecast_details_tbl => G_forecast_details_tbl);

       -- Calculate due dates for all deferred MRs.
       Process_Deferred_UE (p_csi_item_instance_id => G_config_node_tbl(i).csi_item_instance_id,
                            p_current_usage_tbl    => l_current_usage_tbl,
                            p_counter_rules_tbl    => l_counter_rules_tbl);

       -- For UE's of type SR, re-validate MR applicability and explode group MR for next due
       -- date calculation.
       Process_SR_UE (p_csi_item_instance_id => G_config_node_tbl(i).csi_item_instance_id);

       -- For Unplanned MRs (MRs directly planned into a Visit from FMP), validate applicability.
       Process_Unplanned_UE(p_csi_item_instance_id => G_config_node_tbl(i).csi_item_instance_id);

       -- Read ahl_applicable_mrs for all MRs applicable to the item instance.
       FOR l_appl_rec IN ahl_applicable_MRs(G_config_node_tbl(i).csi_item_instance_id) LOOP

         IF G_DEBUG = 'Y' THEN
            AHL_DEBUG_PUB.debug('Found applicable MR-ID:Title' || l_appl_rec.mr_header_id || '[' || l_appl_rec.title || ']');
         END IF;

         /*
         IF (G_concurrent_flag = 'Y') THEN
           fnd_file.put_line (FND_FILE.LOG, 'Found applicable MR-ID:title:' || l_appl_rec.mr_header_id || ':'
                              || l_appl_rec.title);
         END IF;
         */

         l_applicable_mr_rec.csi_item_instance_id := l_appl_rec.csi_item_instance_id;
         l_applicable_mr_rec.MR_header_id := l_appl_rec.MR_header_id;
         l_applicable_mr_rec.title := l_appl_rec.title;
         l_applicable_mr_rec.version_number := l_appl_rec.version_number;
         l_applicable_mr_rec.Implement_status_code := l_appl_rec.Implement_status_code;
         l_applicable_mr_rec.copy_accomplishment_code := l_appl_rec.copy_accomplishment_code;
         l_applicable_mr_rec.repetitive_flag := l_appl_rec.repetitive_flag;
         l_applicable_mr_rec.show_repetitive_code := l_appl_rec.show_repetitive_code;
         l_applicable_mr_rec.preceding_mr_header_id := l_appl_rec.preceding_mr_header_id;
         l_applicable_mr_rec.descendent_count := l_appl_rec.descendent_count;
         l_applicable_mr_rec.whichever_first_code := l_appl_rec.whichever_first_code;
         l_applicable_mr_rec.effective_to := l_appl_rec.effective_to;
         l_applicable_mr_rec.effective_from := l_appl_rec.effective_from;

         -- call procedure to build effectivity.
         Build_Effectivity ( p_applicable_mrs_rec => l_applicable_mr_rec,
                             p_current_usage_tbl  => l_current_usage_tbl,
                             p_counter_rules_tbl  => l_counter_rules_tbl );

         IF G_DEBUG = 'Y' THEN
            AHL_DEBUG_PUB.debug('Process Unit:LOOP to next MR-ID');
         END IF;

       END LOOP; /* loop through next mr */

       IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('Process Unit:LOOP to next NODE');
       END IF;

    END LOOP; /* loop to process next node. */
  END IF; /* for count > 0 */

END Process_ASO_Unit;

--------------------------------------------------------------------------------
-- Build the counter ratio that needs to be applied to the item instance based
-- on its master configuration position. Input is the item instance.
-- Modified per 11.5.10 UC enhancements.

PROCEDURE build_Counter_Ratio(p_position_reference   IN VARCHAR2,
                              p_csi_item_instance_id IN NUMBER,
                              p_master_config_id     IN NUMBER,
                              x_counter_rules_tbl    OUT NOCOPY counter_rules_tbl_type)
IS

  -- for counter rules given a relationship_id.
  CURSOR ahl_ctr_rule_csr ( p_relationship_id IN NUMBER) IS
    SELECT uom_code, ratio
    FROM ahl_ctr_update_rules
    WHERE relationship_id = p_relationship_id
        AND rule_code = 'STANDARD';

  -- traverse up the master configuration to top node.
/*  CURSOR ahl_master_config_csr (p_start_node_id IN NUMBER) IS
    SELECT relationship_id
    FROM   ahl_relationships_b
    START WITH relationship_id = p_start_node_id
    CONNECT BY PRIOR parent_relationship_id = relationship_id
       AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
       AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate + 1));
*/

  -- Per UC 11.5.10 enhancements, instead of traversing MC; we traverse UC and get the position
  -- reference.
  CURSOR ahl_unit_config_csr (p_csi_item_instance_id IN NUMBER) IS
    SELECT to_number(position_reference) position_reference
    FROM csi_ii_relationships
    START WITH subject_id = p_csi_item_instance_id
               AND relationship_type_code = 'COMPONENT-OF'
               AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
               AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    CONNECT BY PRIOR subject_id = object_id
               AND relationship_type_code = 'COMPONENT-OF'
               AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
               AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

  -- get root master configuration for the item's position reference.
  CURSOR ahl_posn_master_config_csr (p_start_node_id IN NUMBER) IS
    SELECT relationship_id
    FROM   ahl_mc_relationships
    WHERE parent_relationship_id IS NULL
    START WITH relationship_id = p_start_node_id
    CONNECT BY PRIOR parent_relationship_id = relationship_id
       AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
       AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate + 1));


  l_position_ref           NUMBER;
  l_uom_code               ahl_ctr_update_rules.uom_code%TYPE;
  l_ratio                  NUMBER;
  l_match_found_flag       BOOLEAN;
  l_table_count            NUMBER;
  l_posn_master_config_id  NUMBER;

  l_counter_rules_tbl  counter_rules_tbl_type;


BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('Start Build Counter Ratio');
  END IF;

  -- If there is no master configuration
  IF (p_master_config_id IS NOT NULL) THEN

      l_position_ref := to_number(p_position_reference);
      x_counter_rules_tbl := l_counter_rules_tbl;

      -- Check if position reference belongs to master configuration.
      OPEN ahl_posn_master_config_csr(l_position_ref);
      FETCH ahl_posn_master_config_csr INTO l_posn_master_config_id;
      IF (ahl_posn_master_config_csr%FOUND) THEN
        IF (l_posn_master_config_id = p_master_config_id) THEN

           l_table_count := 0;
           -- Build counter rules table.
           FOR l_relationship_id IN ahl_unit_config_csr(p_csi_item_instance_id) LOOP
             FOR l_ratio_rec IN ahl_ctr_rule_csr (l_relationship_id.position_reference) LOOP
               l_uom_code := l_ratio_rec.uom_code;
               l_ratio    := l_ratio_rec.ratio;

               -- Check if uom_code already exists in x_counter_rules_tbl.
               l_match_found_flag := FALSE;

               IF (l_table_count > 0) THEN
                 FOR i IN x_counter_rules_tbl.FIRST..x_counter_rules_tbl.LAST LOOP
                   IF (x_counter_rules_tbl(i).uom_code = l_uom_code) THEN
                      x_counter_rules_tbl(i).ratio := x_counter_rules_tbl(i).ratio * l_ratio;
                      l_match_found_flag := TRUE;
                   END IF;
                 END LOOP; /* counter_rules_tbl */
               END IF; /* count > 0 */

               -- Add new row if match not found.
               IF NOT (l_match_found_flag) THEN
                 l_table_count := l_table_count + 1;
                 x_counter_rules_tbl(l_table_count).uom_code := l_uom_code;
                 x_counter_rules_tbl(l_table_count).ratio    := l_ratio;
               END IF;
             END LOOP; /* for ahl_ctr_rule_csr */

           END LOOP; /* for ahl_master-config_csr */
        END IF; /* master config id matches */
      END IF; /* found */
      CLOSE ahl_posn_master_config_csr;
  END IF; /* master config not null */

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('End Build Counter Ratio');
     AHL_DEBUG_PUB.debug ('Counter Rules tbl count' || x_counter_rules_tbl.COUNT);
  END IF;

EXCEPTION

  WHEN INVALID_NUMBER THEN
    x_counter_rules_tbl := l_counter_rules_tbl;

END build_Counter_Ratio;

----------------------------------------------------------------------------------
-- Build the current usage on the item instance's counters based on counters attached
-- to the item instance.

PROCEDURE get_Current_Usage ( p_csi_item_instance_id IN NUMBER,
                              x_current_usage_tbl    OUT NOCOPY counter_values_tbl_type )
IS

  CURSOR csi_cp_counters_csr (p_csi_instance_id IN NUMBER) IS
     /*
     SELECT counter_id, uom_code, net_reading, counter_name
     FROM   csi_cp_counters_v
     WHERE  customer_product_id = p_csi_item_instance_id
     ORDER BY uom_code;

     SELECT cc.counter_id, cc.uom_code,
            cc.counter_template_name counter_name
     from   csi_counter_associations cca, csi_counters_vl cc
     where  cca.counter_id = cc.counter_id
     AND    source_object_code = 'CP'
     AND    source_object_id = p_csi_instance_id;
     */

     /* reverted to old code - see bug# 7355947
     SELECT cc.counter_id, cc.uom_code,
            cc.counter_template_name counter_name,
            (select ccr.net_reading
            from csi_counter_readings ccr
            where ccr.counter_id = cc.counter_id
            and value_timestamp = (select max(value_timestamp) from csi_counter_readings rd
                                   where counter_id = cc.counter_id
                                   and nvl(disabled_flag,'N') = 'N')) net_reading
     FROM   csi_counter_associations cca, csi_counters_vl cc
     WHERE  cca.counter_id = cc.counter_id
     AND    source_object_code = 'CP'
     AND    source_object_id = p_csi_item_instance_id;
     */

     -- 15 Sept 08: Modified based on IB changes - refer bug# 7374316
     SELECT cc.counter_id, cc.uom_code,
            cc.counter_template_name counter_name,
            (select ccr.net_reading
             from csi_counter_readings ccr
             where ccr.counter_value_id = cc.CTR_VAL_MAX_SEQ_NO
               and nvl(ccr.disabled_flag,'N') = 'N')
     FROM   csi_counter_associations cca, csi_counters_vl cc
     WHERE  cca.counter_id = cc.counter_id
     AND    source_object_code = 'CP'
     AND    source_object_id = p_csi_instance_id;

  /*
  -- get net reading.
  CURSOR csi_cp_counters_val_csr (p_counter_id IN NUMBER) IS
     SELECT nvl(cv.net_reading,0) net_reading
     FROM csi_counter_values_v cv
     WHERE cv.counter_id = p_counter_id
       AND rownum < 2;

  -- get net reading.
  CURSOR csi_cp_counters_val_csr (p_counter_id IN NUMBER) IS
     SELECT * FROM
        (SELECT net_reading
         FROM csi_counter_readings
         WHERE counter_id = p_counter_id
           AND nvl(disabled_flag,'N') = 'N'
         ORDER BY value_timestamp desc)
     WHERE rownum < 2;
  */

  i  NUMBER;

  l_current_usage_tbl  counter_values_tbl_type;

  -- added for perf fix.
  l_ctr_id_tbl       nbr_tbl_type;
  l_ctr_uom_tbl      vchar_tbl_type;
  l_ctr_name_tbl     vchar_tbl_type;
  l_ctr_net_read_tbl nbr_tbl_type;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('Start Get Current Usage');
  END IF;

  -- Build current usage counters.
  OPEN csi_cp_counters_csr(p_csi_item_instance_id);
  FETCH csi_cp_counters_csr BULK COLLECT INTO l_ctr_id_tbl, l_ctr_uom_tbl, l_ctr_name_tbl,
                                              l_ctr_net_read_tbl;
  CLOSE csi_cp_counters_csr;

  /*
  LOOP
    FETCH csi_cp_counters_csr INTO l_current_usage_tbl(i).counter_id,
                                   l_current_usage_tbl(i).uom_code,
                                   l_current_usage_tbl(i).counter_name;
    EXIT WHEN csi_cp_counters_csr%NOTFOUND;

    -- get latest net reading.
    OPEN csi_cp_counters_val_csr(l_current_usage_tbl(i).counter_id);
    FETCH csi_cp_counters_val_csr INTO l_current_usage_tbl(i).counter_value;
    CLOSE csi_cp_counters_val_csr;

    IF (l_current_usage_tbl(i).counter_value IS NULL) THEN
       l_current_usage_tbl(i).counter_value := 0;
    END IF;

    i := i + 1;
  END LOOP;
  */

  IF (l_ctr_id_tbl.COUNT > 0) THEN

    i := 1;
    FOR j IN l_ctr_id_tbl.FIRST..l_ctr_id_tbl.LAST LOOP
      l_current_usage_tbl(i).counter_id := l_ctr_id_tbl(j);
      l_current_usage_tbl(i).uom_code   := l_ctr_uom_tbl(j);
      l_current_usage_tbl(i).counter_name := l_ctr_name_tbl(j);

      /* 15 Sept 08: commented to incorporate IB changes - see bug# 7374316
      -- get latest net reading.
      OPEN csi_cp_counters_val_csr(l_current_usage_tbl(i).counter_id);
      FETCH csi_cp_counters_val_csr INTO l_current_usage_tbl(i).counter_value;
      CLOSE csi_cp_counters_val_csr;

      IF (l_current_usage_tbl(i).counter_value IS NULL) THEN
        l_current_usage_tbl(i).counter_value := 0;
      END IF;
      */

      IF (l_ctr_net_read_tbl(j) IS NULL) THEN
         l_current_usage_tbl(i).counter_value := 0;
      ELSE
         l_current_usage_tbl(i).counter_value := l_ctr_net_read_tbl(j);
      END IF;

      i := i + 1;
    END LOOP;
  END IF; -- l_ctr_id_tbl.COUNT

  -- Set return value.
  x_current_usage_tbl := l_current_usage_tbl;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('Counter Usage tbl count' || x_current_usage_tbl.COUNT);
     AHL_DEBUG_PUB.debug ('End Get Current Usage');
  END IF;

END get_Current_Usage;

--------------------------------------------------------------------------------------------
-- Get accomplishment details for an MR.
-- Added parameter x_no_forecast_flag to fix bug# 6711228.
PROCEDURE get_accomplishment_details (p_applicable_mrs_rec IN applicable_mrs_rec_type,
                                      p_current_usage_tbl  IN counter_values_tbl_type,
                                      p_counter_rules_tbl  IN counter_rules_tbl_type,
                                      x_accomplishment_date OUT NOCOPY DATE,
                                      x_last_acc_counter_val_tbl OUT NOCOPY counter_values_tbl_type,
                                      x_one_time_mr_flag     OUT NOCOPY BOOLEAN,
                                      -- x_update_check_flag OUT NOCOPY BOOLEAN,
                                      x_dependent_mr_flag  OUT NOCOPY BOOLEAN,
                                      x_get_preceding_next_due OUT NOCOPY BOOLEAN,
                                      x_mr_accomplish_exists   OUT NOCOPY BOOLEAN,
                                      x_no_forecast_flag       OUT NOCOPY BOOLEAN)
IS

  -- Get last accomplishment counter values.
  CURSOR ahl_unit_accomplish_csr (p_unit_effectivity_id IN NUMBER) IS

  /*
  SELECT ua.counter_id, ua.counter_value, cs.uom_code, cs.name counter_name
   FROM   ahl_unit_accomplishmnts ua, cs_counters_v cs
   WHERE  ua.counter_id = cs.counter_id AND
          ua.unit_effectivity_id = p_unit_effectivity_id
   ORDER BY cs.uom_code;
*/

	 --Priyan
	 --Query being changed due to performance related fixes
	 --Refer Bug # 4918744
	 --Changed the usage of CS_COUNTERS_V to CSI_COUNTERS_VL

	SELECT
		UA.COUNTER_ID,
		UA.COUNTER_VALUE,
		CS.UOM_CODE,
		--CS.NAME COUNTER_NAME
                CS.COUNTER_TEMPLATE_NAME COUNTER_NAME
	FROM
		AHL_UNIT_ACCOMPLISHMNTS UA,
		CSI_COUNTERS_VL CS
	WHERE
		UA.COUNTER_ID = CS.COUNTER_ID AND
		UA.UNIT_EFFECTIVITY_ID = P_UNIT_EFFECTIVITY_ID
	ORDER BY
		CS.UOM_CODE ;

  -- Get instance counter details.
  CURSOR csi_cp_counters_csr (p_csi_instance_id IN NUMBER) IS
     /*
     SELECT counter_id, uom_code, counter_name
     FROM   csi_cp_counters_v
     WHERE  customer_product_id = p_csi_instance_id
     ORDER BY uom_code;
     */
     SELECT cc.counter_id, cc.uom_code,
            cc.counter_template_name counter_name
     from   csi_counter_associations cca, csi_counters_vl cc
     where  cca.counter_id = cc.counter_id
     AND    source_object_code = 'CP'
     AND    source_object_id = p_csi_instance_id;

  -- Get deferred MRs.
  -- consider deferral_effective_on instead of due date, only if l_affect_calc_due_date is 'N'.
  CURSOR ahl_def_csr (p_csi_instance_id IN NUMBER,
                      p_mr_header_id    IN NUMBER) IS
    SELECT
    -- fix for bug# 6875650. Deferral date includes timestamp.
    --decode (affect_due_calc_flag, 'N', trunc(nvl(visit_end_date, deferral_effective_on)), trunc(nvl(visit_end_date, due_date)))

    decode (affect_due_calc_flag, 'N', deferral_effective_on, nvl(visit_end_date, due_date))
    FROM ahl_temp_unit_SR_deferrals
    WHERE csi_item_instance_id = p_csi_instance_id
          AND mr_header_id = p_mr_header_id
          AND object_type = 'MR'
          AND deferral_effective_on IS NOT NULL
    ORDER BY deferral_effective_on DESC;
    -- get the latest deferral.
    -- pick only deferrals and not SR related MRs.

  l_acc_unit_effectivity_id   NUMBER;
  l_acc_status_code           ahl_unit_effectivities_app_v.status_code%TYPE;

  l_last_accomplishment_date  DATE;
  l_last_acc_counter_val_tbl  counter_values_tbl_type;
  l_due_counter_val_tbl       counter_values_tbl_type;
  l_due_date      DATE;

  l_return_val   BOOLEAN;
  i NUMBER;
  l_acc_deferral_flag  BOOLEAN;

  l_dependent_mr_flag  BOOLEAN;
  /* set based on preceding mr and accomplishment */

  --l_update_check_flag  BOOLEAN := FALSE;
  l_get_preceding_next_due BOOLEAN := FALSE;

  l_one_time_mr_flag  BOOLEAN := FALSE;
  /* set to true if the MR is a one time MR and already has an accomplishment */
  /* or there exists a deferral with it's due date = null. */

  l_net_reading  NUMBER;

  l_no_forecast_flag  BOOLEAN := FALSE;
  -- set this flag to true if no forecast available when calculating deferral due date.

  l_mr_accomplish_exists BOOLEAN := FALSE;
  -- set this flag if a mr accomplishment exists.

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('Start Get Accomplishment Details');
  END IF;

  -- Check if any deferrals exist.
  OPEN ahl_def_csr (p_applicable_mrs_rec.csi_item_instance_id,
                    p_applicable_mrs_rec.mr_header_id);
  FETCH ahl_def_csr INTO l_last_accomplishment_date;
  IF (ahl_def_csr%FOUND) THEN
    l_acc_deferral_flag := TRUE;
    l_mr_accomplish_exists := TRUE; -- deferral record.
  ELSE
    -- Lookup if any accomplishments exist.

    -- Get last accomplishment for the MR..
    AHL_UMP_UTIL_PKG.get_last_accomplishment(p_applicable_mrs_rec.csi_item_instance_id,
                                             p_applicable_mrs_rec.mr_header_id,
                                             l_last_accomplishment_date,
                                             l_acc_unit_effectivity_id,
                                             l_acc_deferral_flag,
                                             l_acc_status_code,
                                             l_return_val);
    IF (l_acc_unit_effectivity_id IS NOT NULL) THEN
      l_mr_accomplish_exists := TRUE;
    END IF;

  END IF;

  -- Check for one time MR.
  IF (l_acc_unit_effectivity_id IS NOT NULL AND p_applicable_mrs_rec.repetitive_flag = 'N') OR
     (l_acc_deferral_flag = TRUE AND p_applicable_mrs_rec.repetitive_flag = 'N') THEN
     --dbms_output.put_line('one time true');
     l_one_time_mr_flag := TRUE;
  END IF;

  l_dependent_mr_flag := FALSE;
  -- Set this flag only if there are no accomplishments for the MR and this MR has
  -- a preceding MR.

  IF (p_applicable_mrs_rec.preceding_mr_header_id IS NOT NULL AND
     l_acc_unit_effectivity_id IS NULL)
  THEN
     l_dependent_mr_flag := TRUE;
     --dbms_output.put_line ('dependent flag true');
     -- Modified to get first accomplishment to fix bug#6711228
     AHL_UMP_UTIL_PKG.get_first_accomplishment(p_applicable_mrs_rec.csi_item_instance_id,
                                               p_applicable_mrs_rec.preceding_mr_header_id,
                                               l_last_accomplishment_date,
                                               l_acc_unit_effectivity_id,
                                               l_acc_deferral_flag,
                                               l_acc_status_code,
                                               l_return_val);
  END IF;

  IF (l_acc_deferral_flag) THEN
    IF (l_last_accomplishment_date IS NULL) THEN
       --l_one_time_mr_flag := TRUE;  -- no forecast and cannot calculate deferral due date.
       l_no_forecast_flag := TRUE;  -- no forecast and cannot calculate deferral due date.
    -- fix for bug# 6875650.
    -- ELSIF (trunc(l_last_accomplishment_date) <= trunc(sysdate)) THEN
    ELSIF (l_last_accomplishment_date <= sysdate) THEN
      -- get counter values from counter values tables.
      i := 1;
      FOR instance_counter_rec IN csi_cp_counters_csr(p_applicable_mrs_rec.csi_item_instance_id) LOOP
          l_net_reading := 0;
          get_ctr_reading_for_datetime (p_csi_item_instance_id => p_applicable_mrs_rec.csi_item_instance_id,
                                        p_counter_id           => instance_counter_rec.counter_id,
                                        p_reading_date         => l_last_accomplishment_date,
                                        x_net_reading          => l_net_reading);

          l_last_acc_counter_val_tbl(i).uom_code := instance_counter_rec.uom_code;
          l_last_acc_counter_val_tbl(i).counter_id := instance_counter_rec.counter_id;
          l_last_acc_counter_val_tbl(i).counter_name := instance_counter_rec.counter_name;
          l_last_acc_counter_val_tbl(i).counter_value := l_net_reading;
          i := i + 1;

      END LOOP;
    ELSE  -- deferral due date is a future date.
       -- get all counter values as on l_preceding_next_due_date.
       Get_Due_at_Counter_Values (p_last_due_date => sysdate,
                                  p_last_due_counter_val_tbl => p_current_usage_tbl,
                                  p_due_date => l_last_accomplishment_date,
                                  p_counter_rules_tbl => p_counter_rules_tbl,
                                  x_due_at_counter_val_tbl => l_last_acc_counter_val_tbl,
                                  x_return_value => l_return_val);

       IF G_DEBUG = 'Y' THEN
         AHL_DEBUG_PUB.Debug('l_deferral_due_date: ' || l_last_accomplishment_date);
         IF (l_last_acc_counter_val_tbl.COUNT) > 0 THEN
            for i in l_last_acc_counter_val_tbl.FIRST..l_last_acc_counter_val_tbl.LAST LOOP
               AHL_DEBUG_PUB.Debug('i:'|| i|| ' value:' || l_last_acc_counter_val_tbl(i).counter_value || 'ID: ' || l_last_acc_counter_val_tbl(i).counter_id);
            end loop;
         END IF;
       END IF;

       -- check return value.
       IF NOT(l_return_val) THEN  -- no forecast case.
         --l_one_time_mr_flag := TRUE;
         l_no_forecast_flag := TRUE;
       END IF;

    END IF;  -- Last accomplishment date.
  ELSE  -- not based on deferral_effective_date.
    IF (l_acc_unit_effectivity_id IS NOT NULL) THEN
      i := 1;
      -- Build last accomplishment counter values.
      FOR l_acc_counter_rec IN ahl_unit_accomplish_csr(l_acc_unit_effectivity_id) LOOP
        l_last_acc_counter_val_tbl(i).uom_code := l_acc_counter_rec.uom_code;
        l_last_acc_counter_val_tbl(i).counter_id := l_acc_counter_rec.counter_id;
        l_last_acc_counter_val_tbl(i).counter_name := l_acc_counter_rec.counter_name;
        l_last_acc_counter_val_tbl(i).counter_value := l_acc_counter_rec.counter_value;
        i := i + 1;
      END LOOP;

    ELSIF (l_dependent_mr_flag) THEN
       -- no accomplishment for preceding MR available.
       -- get the next due date from temporary table for calculation.
       l_get_preceding_next_due := TRUE;
    END IF;
  END IF; -- l_acc_deferral_flag.

  -- set return parameters.
  x_accomplishment_date := l_last_accomplishment_date;
  x_last_acc_counter_val_tbl := l_last_acc_counter_val_tbl;
  x_one_time_mr_flag := l_one_time_mr_flag;
  x_dependent_mr_flag := l_dependent_mr_flag;
  x_get_preceding_next_due := l_get_preceding_next_due;
  x_no_forecast_flag := l_no_forecast_flag;
  x_mr_accomplish_exists := l_mr_accomplish_exists;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('Last Accomplished Date:' || x_accomplishment_date);
     AHL_DEBUG_PUB.debug ('Count of ctr values:' || x_last_acc_counter_val_tbl.COUNT);
     AHL_DEBUG_PUB.debug ('End Get Accomplishment Details');
  END IF;

END get_accomplishment_details;

------------------------------------------------------------------------------
-- Build unit effectivity for a given item instance and a maintenance requirement.
-- The unit effectivities created here will be written into a temporary table.

PROCEDURE Build_Effectivity ( p_applicable_mrs_rec IN applicable_mrs_rec_type,
                              p_current_usage_tbl  IN counter_values_tbl_type,
                              p_counter_rules_tbl  IN counter_rules_tbl_type )

IS

  -- retrieve current unit effectivity records.
  CURSOR ahl_unit_effectivity_csr (p_mr_header_id IN NUMBER,
                                   p_csi_item_instance_id IN NUMBER) IS
  SELECT ue.unit_effectivity_id, ue.status_code, reln.related_ue_id, reln.originator_ue_id
  FROM   ahl_unit_effectivities_app_v UE, ahl_UE_relationships reln
  WHERE  UE.unit_effectivity_id = RELN.RELATED_UE_ID(+)
       AND mr_header_id = p_mr_header_id
       AND csi_item_instance_id = p_csi_item_instance_id
       AND (UE.Status_code IS NULL OR status_code = 'INIT-DUE')
       AND UE.defer_from_ue_id IS NULL  -- do not pick deferred unit effectivities.
       AND nvl(UE.manually_planned_flag,'N') = 'N'   -- do not pick manually planned UEs.
       -- do not pick up child UEs if parent init-accomplished.
       AND NOT EXISTS (SELECT 'x' FROM AHL_UNIT_EFFECTIVITIES_B PARENT_UE
                       WHERE PARENT_UE.UNIT_EFFECTIVITY_ID = RELN.ORIGINATOR_UE_ID
                         AND PARENT_UE.STATUS_CODE = 'INIT-ACCOMPLISHED')
  ORDER BY forecast_sequence ASC;

  -- Get group MRs if any, from ahl_temp_unit_effectivities for the item instance.
  -- select only the first row.
  CURSOR ahl_temp_ue_csr (p_item_instance_id IN NUMBER,
                          p_mr_header_id     IN NUMBER,
                          p_last_due_date    IN DATE,
                          p_due_date         IN DATE ) IS
   SELECT *
   FROM (
        SELECT due_date,
               orig_csi_item_instance_id,
               orig_mr_header_id,
               --orig_forecast_sequence,
               visit_end_date
        FROM ahl_temp_unit_effectivities
        WHERE csi_item_instance_id = p_item_instance_id AND
              mr_header_id = p_mr_header_id AND
              orig_csi_item_instance_id IS NOT NULL AND
              orig_mr_header_id IS NOT NULL AND
              trunc(nvl(visit_end_date, nvl(due_date, p_last_due_date))) > trunc(p_last_due_date) AND
              trunc(nvl(visit_end_date, nvl(due_date, p_due_date+1))) <= trunc(p_due_date) AND
              preceding_check_flag = 'N'
        /* ignore records with null due dates */
        /* order selected rows so that the record with max due date is first */
        /* consider visit end date instead of due date, if it is available. */

        UNION

        -- Get SR's.
        SELECT due_date,
               csi_item_instance_id orig_csi_item_instance_id,
               mr_header_id orig_mr_header_id,
               visit_end_date
        FROM ahl_temp_unit_SR_deferrals
        WHERE csi_item_instance_id = p_item_instance_id
              AND mr_header_id = p_mr_header_id
                  AND trunc(nvl(visit_end_date, nvl(due_date, p_last_due_date))) > trunc(p_last_due_date)
              AND trunc(nvl(visit_end_date, nvl(due_date, p_due_date+1))) <= trunc(p_due_date)
              AND deferral_effective_on IS NULL -- pick only SR related MRs.
        -- ignore records with null due dates.
        -- ignore deferral records.

        ORDER BY due_date DESC
        )
   WHERE ROWNUM < 2;

  -- in case of 'next-due', we need to check p_last_due_date equality condition too.
  -- Get group MRs if any, from ahl_temp_unit_effectivities for the item instance.
  -- select only the first row.
  CURSOR ahl_temp_ue_csr1 (p_item_instance_id IN NUMBER,
                           p_mr_header_id     IN NUMBER,
                           p_last_due_date    IN DATE,
                           p_due_date         IN DATE ) IS
   SELECT *
   FROM (
        SELECT due_date,
               orig_csi_item_instance_id,
               orig_mr_header_id,
               --orig_forecast_sequence,
               visit_end_date
        FROM ahl_temp_unit_effectivities
        WHERE csi_item_instance_id = p_item_instance_id AND
              mr_header_id = p_mr_header_id AND
              orig_csi_item_instance_id IS NOT NULL AND
              orig_mr_header_id IS NOT NULL AND
              trunc(nvl(visit_end_date, nvl(due_date, p_last_due_date))) >= trunc(p_last_due_date) AND
              trunc(nvl(visit_end_date, nvl(due_date, p_due_date+1))) <= trunc(p_due_date) AND
              preceding_check_flag = 'N'
        /* ignore records with null due dates */
        /* order selected rows so that the record with max due date is first */
        /* consider visit end date instead of due date, if it is available. */

        UNION

        -- Get SR's.
        SELECT due_date,
               csi_item_instance_id orig_csi_item_instance_id,
               mr_header_id orig_mr_header_id,
               visit_end_date
        FROM ahl_temp_unit_SR_deferrals
        WHERE csi_item_instance_id = p_item_instance_id
              AND mr_header_id = p_mr_header_id
              AND trunc(nvl(visit_end_date, nvl(due_date, p_last_due_date))) >= trunc(p_last_due_date)
              AND trunc(nvl(visit_end_date, nvl(due_date, p_due_date+1))) <= trunc(p_due_date)
              AND deferral_effective_on IS NULL -- pick only SR related MRs.
        -- ignore records with null due dates.
        -- ignore deferral records.
        ORDER BY due_date DESC
        )
   WHERE ROWNUM < 2;

  -- Check if MR is a group MR.
  CURSOR group_check_csr (p_item_instance_id IN NUMBER,
                          p_mr_header_id IN NUMBER) IS
   SELECT 'x'
   FROM ahl_applicable_mr_relns
   WHERE orig_csi_item_instance_id = p_item_instance_id AND
         orig_mr_header_id = p_mr_header_id;

  -- Get next due date of preceding MR from temporary table.
  CURSOR preceding_due_date_csr (p_preceding_instance_id IN NUMBER,
                                 p_preceding_mr_header_id IN NUMBER) IS
   SELECT due_date
   FROM ahl_temp_unit_effectivities
   WHERE csi_item_instance_id = p_preceding_instance_id AND
         mr_header_id = p_preceding_mr_header_id AND
         preceding_check_flag = 'N'
   ORDER by due_date;

  -- Added for 11.5.10+ enhancements for Unplanned MRs.
  -- Read open Unplanned MRs.
  CURSOR ahl_unplanned_MRs_csr(p_item_instance_id IN NUMBER,
                               p_mr_header_id     IN NUMBER) IS
    SELECT ue.unit_effectivity_id
    FROM ahl_unit_effectivities_app_v ue
    WHERE ue.csi_item_instance_id = p_item_instance_id
       AND ue.mr_header_id = p_mr_header_id
       AND ue.status_code IS NULL
       AND ue.manually_planned_flag = 'Y'
       AND NOT EXISTS (SELECT 'x'
                       FROM ahl_ue_relationships uer, ahl_unit_effectivities_b ue1
                       WHERE uer.related_ue_id = ue.unit_effectivity_id
                         AND uer.originator_ue_id = ue1.unit_effectivity_id
                         AND ue1.object_type = 'SR');
    -- Do not pick MRs associated to a SR.
  --
  l_unit_effectivity_tbl  unit_effectivity_tbl_type;
  /* this table will contain the current unit effectivity definitions for the mr and item instance */

  i    NUMBER := 0;
  /* running index for unit effectivity tbl */

  l_visit_start_date   DATE;
  l_visit_end_date     DATE;
  l_visit_assign_code  VARCHAR2(30);

  l_forecast_sequence  NUMBER;
  l_old_UE_forecast_sequence  NUMBER;
  l_next_due_date_rec         next_due_date_rec_type;

  l_new_unit_effectivity_rec      ahl_temp_unit_effectivities%ROWTYPE;
  l_new_unit_effectivity_initrec  ahl_temp_unit_effectivities%ROWTYPE;

  l_temp_grp_mr_rec   ahl_temp_ue_csr%ROWTYPE;

  l_last_accomplishment_date  DATE;
  l_last_acc_counter_val_tbl  counter_values_tbl_type;
  l_dependent_mr_flag BOOLEAN;
  l_get_preceding_next_due BOOLEAN; -- to indicate that the dependent MR calculation is based on preceding MR's next due.
  l_preceding_next_due_date DATE;

  l_one_time_mr_flag  BOOLEAN;

  l_calc_due_date_flag   BOOLEAN := TRUE;
  -- set to true if preceding MR due date is null. So the dependent's due date
  -- will also be null. Calc due date must not be done.

  --l_bef_tolr_due_date  DATE;
  --l_aft_tolr_due_date  DATE;

  l_last_due_date  DATE;
  l_last_due_counter_val_tbl  counter_values_tbl_type;
  l_due_at_counter_val_tbl    counter_values_tbl_type;
  l_due_date       DATE;

  l_next_due_flag  BOOLEAN;
  l_grp_duedate_found  BOOLEAN;
  l_old_UE_forecast_found BOOLEAN := TRUE;

  l_return_value BOOLEAN;
  l_junk    VARCHAR2(1);
  group_check_flag  BOOLEAN := FALSE;  -- flag to check if it is a group MR.

  -- Added for 11.5.10+ enhancements for Unplanned MRs.
  -- Define rec and table type to hold Unplanned MRs.
  TYPE Unplanned_UE_rec_type IS RECORD(
     UNIT_EFFECTIVITY_ID  NUMBER,
     VISIT_END_DATE       DATE);

  TYPE Unplanned_UE_Tbl_type IS TABLE OF Unplanned_UE_rec_type INDEX BY BINARY_INTEGER;

  l_unplanned_MRs_tbl     Unplanned_UE_Tbl_type;
  l_min_visit_date        DATE;

  -- R12 to fix bug# 4224867.
  l_duplicate_MRs         NUMBER;
  l_usage_per_day         NUMBER;

  -- Added to fix bug# 6711228.
  l_no_forecast_flag      BOOLEAN;
  l_mr_accomplish_exists  BOOLEAN;

  -- Added to fix bug# 6858788
  l_last_due_mr_interval_id NUMBER;

  -- Added for performance.
  l_ue_id_tbl              nbr_tbl_type;
  l_ue_status_tbl          vchar_tbl_type;
  l_related_ue_tbl         nbr_tbl_type;
  l_orig_ue_tbl            nbr_tbl_type;

  l_buffer_limit           NUMBER := 1000;

BEGIN


  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('Start Build Effectivity for mr:csi' || p_applicable_mrs_rec.mr_header_id || ':' || p_applicable_mrs_rec.csi_item_instance_id );
  END IF;

  -- Set last accomplishment details.
  Get_accomplishment_details(p_applicable_mrs_rec => p_applicable_mrs_rec,
                             p_current_usage_tbl  => p_current_usage_tbl,
                             p_counter_rules_tbl  => p_counter_rules_tbl,
                             x_accomplishment_date => l_last_accomplishment_date,
                             x_last_acc_counter_val_tbl => l_last_acc_counter_val_tbl,
                             x_one_time_mr_flag         => l_one_time_mr_flag,
                             x_dependent_mr_flag => l_dependent_mr_flag,
                             x_get_preceding_next_due => l_get_preceding_next_due,
                             x_mr_accomplish_exists  => l_mr_accomplish_exists,
                             x_no_forecast_flag => l_no_forecast_flag );

  -- Check for one time MR case.
  IF (l_one_time_mr_flag) THEN
     --dbms_output.put_line('one time true in build');
     GOTO process_preceding_mr;
  ELSIF (l_no_forecast_flag) THEN
     RETURN;  -- no more MRs needed.
  END IF;

  -- get next accomplishment details for the preceding MR if needed.
  IF (l_get_preceding_next_due) THEN
    OPEN preceding_due_date_csr (p_applicable_mrs_rec.csi_item_instance_id,
                                 p_applicable_mrs_rec.preceding_mr_header_id);

    FETCH preceding_due_date_csr INTO l_preceding_next_due_date;
    IF (preceding_due_date_csr%NOTFOUND) OR (l_preceding_next_due_date IS NULL) THEN
        --dbms_output.put_line ('not found preceding');
        l_calc_due_date_flag := FALSE;
    ELSE
        l_last_accomplishment_date := l_preceding_next_due_date;
        --dbms_output.put_line ('found preceding due_date' ||l_preceding_next_due_date );
        -- get all counter values as on l_preceding_next_due_date.
        Get_Due_at_Counter_Values (p_last_due_date => sysdate,
                                   p_last_due_counter_val_tbl => p_current_usage_tbl,
                                   p_due_date => l_preceding_next_due_date,
                                   p_counter_rules_tbl => p_counter_rules_tbl,
                                   x_due_at_counter_val_tbl => l_last_acc_counter_val_tbl,
                                   x_return_value => l_return_value);

        IF G_DEBUG = 'Y' THEN
           AHL_DEBUG_PUB.Debug('l_preceding_due_date: '|| l_preceding_next_due_date);
           IF (l_last_acc_counter_val_tbl.COUNT) > 0 THEN
              for i in l_last_acc_counter_val_tbl.FIRST..l_last_acc_counter_val_tbl.LAST LOOP
                AHL_DEBUG_PUB.Debug('i:'|| i|| ' value:' || l_last_acc_counter_val_tbl(i).counter_value || 'ID: ' || l_last_acc_counter_val_tbl(i).counter_id);
              end loop;
           END IF;
        END IF;

        -- check return value.
        IF NOT(l_return_value) THEN  -- no forecast case.
          --l_preceding_next_due_date := NULL;
          l_calc_due_date_flag := FALSE;
        END IF;
    END IF;
    CLOSE preceding_due_date_csr;
  END IF;

  -- Read existing unit effectivity records for the mr and item instance.
  OPEN ahl_unit_effectivity_csr(p_applicable_mrs_rec.mr_header_id,
                                p_applicable_mrs_rec.csi_item_instance_id);
  i := 0;
  l_forecast_sequence := 0;
  LOOP
    /*
    FETCH ahl_unit_effectivity_csr INTO l_unit_effectivity_tbl(i).unit_effectivity_id,
                                        l_unit_effectivity_tbl(i).status_code,
                                        l_unit_effectivity_tbl(i).related_ue_id,
                                        l_unit_effectivity_tbl(i).originator_ue_id;
    */

    FETCH ahl_unit_effectivity_csr BULK COLLECT INTO l_ue_id_tbl, l_ue_status_tbl, l_related_ue_tbl,
                                                     l_orig_ue_tbl LIMIT l_buffer_limit;

    --EXIT WHEN ahl_unit_effectivity_csr%NOTFOUND;
    EXIT WHEN (l_ue_id_tbl.count = 0);

    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.debug ('Rows fetched for instance-mr is: ' || ahl_unit_effectivity_csr%ROWCOUNT);
    END IF;

    --dbms_output.put_line ('unit eff load i:' || l_unit_effectivity_tbl(i).unit_effectivity_id);

    FOR j IN l_ue_id_tbl.FIRST..l_ue_id_tbl.LAST LOOP
       i := i + 1;
       -- initialize
       l_unit_effectivity_tbl(i).unit_effectivity_id := l_ue_id_tbl(j);
       l_unit_effectivity_tbl(i).status_code := l_ue_status_tbl(j);
       l_unit_effectivity_tbl(i).related_ue_id := l_related_ue_tbl(j);
       l_unit_effectivity_tbl(i).originator_ue_id := l_orig_ue_tbl(j);

       -- Call visit work package to get visit end date if unit effectivity has been assigned to a visit.
       AHL_UMP_UTIL_PKG.get_visit_details (l_unit_effectivity_tbl(i).unit_effectivity_id,
                                           l_visit_start_date,
                                           l_visit_end_date,
                                           l_visit_assign_code);

       IF (l_visit_end_date IS NOT NULL AND trunc(l_visit_end_date) >= trunc(sysdate)) THEN
           IF G_DEBUG = 'Y' THEN
              AHL_DEBUG_PUB.Debug('Visit assigned:End Date:' || l_visit_end_date);
           END IF;

           l_unit_effectivity_tbl(i).visit_assign_flag := 'Y';
           l_unit_effectivity_tbl(i).visit_end_date := l_visit_end_date;
       ELSE
           l_unit_effectivity_tbl(i).visit_assign_flag := 'N';
           l_unit_effectivity_tbl(i).visit_end_date := null;
       END IF;

       -- Assign forecast sequence for single (non-group) MRs.
       IF (l_unit_effectivity_tbl(i).originator_ue_id IS NULL) THEN
           l_forecast_sequence := l_forecast_sequence + 1;
           l_unit_effectivity_tbl(i).forecast_sequence := l_forecast_sequence;
       END IF;
    END LOOP; -- l_ue_id_tbl

    -- clean up.
    l_ue_id_tbl.DELETE;
    l_ue_status_tbl.DELETE;
    l_related_ue_tbl.DELETE;
    l_orig_ue_tbl.DELETE;

  END LOOP;
  CLOSE ahl_unit_effectivity_csr;

  -- Added for 11.5.10+ enhancements for Unplanned MRs.
  -- Build table of visit end dates for Unplanned MRs.
  i := 0;
  FOR ahl_unplanned_MRs_rec IN ahl_unplanned_MRs_csr(p_applicable_mrs_rec.csi_item_instance_id,
                                                     p_applicable_mrs_rec.mr_header_id)
  LOOP
    -- Get visit end date; unplanned MRs is always assigned to a visit.
    AHL_UMP_UTIL_PKG.get_visit_details (ahl_unplanned_MRs_rec.unit_effectivity_id,
                                        l_visit_start_date,
                                        l_visit_end_date,
                                        l_visit_assign_code);
    IF (l_visit_end_date IS NOT NULL) THEN
      i := i + 1;
      l_unplanned_MRs_tbl(i).unit_effectivity_id := ahl_unplanned_MRs_rec.unit_effectivity_id;
      l_unplanned_MRs_tbl(i).visit_end_date := trunc(l_visit_end_date);

    END IF;

  END LOOP; -- unplanned MRs.

  -- Check for group MR.
  OPEN group_check_csr(p_applicable_mrs_rec.csi_item_instance_id,
                       p_applicable_mrs_rec.mr_header_id);
  FETCH group_check_csr INTO l_junk;
  IF (group_check_csr%NOTFOUND) THEN
      --dbms_output.put_line ('group check false');
      group_check_flag := FALSE;
  ELSE
      group_check_flag := TRUE;
  END IF;
  CLOSE group_check_csr;

  -- Initialize forecast sequence numbers.
  l_forecast_sequence := 0;
  l_old_UE_forecast_sequence := 0;
  l_old_UE_forecast_found := TRUE;

  -- Calculate Due date.
  IF (l_calc_due_date_flag) THEN -- no calculation needed if preceding mr's next due has no due date.

    --dbms_output.put_line ('bef calculate_due_date');
    --dbms_output.put_line ('accomplish:date:' || l_last_accomplishment_date);

    -- Calculate next due date.
    -- Added parameter p_dependent_mr_flag to fix bug# 6711228.
    Calculate_Due_Date (p_repetivity_flag => 'N',
                        p_applicable_mrs_rec => p_applicable_mrs_rec,
                        p_current_usage_tbl => p_current_usage_tbl,
                        p_counter_rules_tbl => p_counter_rules_tbl,
                        p_last_due_date => l_last_accomplishment_date,
                        p_last_due_counter_val_tbl => l_last_acc_counter_val_tbl,
                        p_dependent_mr_flag => l_dependent_mr_flag,
                        p_mr_accomplish_exists  => l_mr_accomplish_exists,
                        x_next_due_date_rec => l_next_due_date_rec);
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.Debug('Aft calculate_due_date nextdue');
    AHL_DEBUG_PUB.Debug('due date is ' || l_next_due_date_rec.DUE_DATE);
    AHL_DEBUG_PUB.Debug('earliest due date is ' || l_next_due_date_rec.EARLIEST_DUE_DATE);
    AHL_DEBUG_PUB.Debug('latest due date is ' || l_next_due_date_rec.latest_due_date);
  END IF;

  l_next_due_flag := TRUE;
  /* next due mr calculation. */

  -- set last_due values to current values.
  l_last_due_date := sysdate;
  l_last_due_counter_val_tbl := p_current_usage_tbl;

  -- If the MR is a dependent MR: (1) If calculated due date is earlier than preceding MR due date,
  --                                  then change due date to be equal to preceding MR due date.
  --                              (2) Update the preceding_check_flag, based on due date.
  IF (p_applicable_mrs_rec.preceding_mr_header_id IS NOT NULL) THEN
    IF (trunc(l_next_due_date_rec.DUE_DATE) < trunc(l_last_accomplishment_date)) THEN
       l_next_due_date_rec.DUE_DATE := l_last_accomplishment_date;
    END IF;

    Update_check_flag (p_applicable_mrs_rec => p_applicable_mrs_rec,
                       p_dependent_mr_flag => l_dependent_mr_flag,
                       p_next_due_date_rec => l_next_due_date_rec);
  END IF;

  -- process next due and repetivity.
  LOOP
     -- At this time assume, that there are no MRs with due dates less than the calc due date.
     l_grp_duedate_found := FALSE;

     -- Check output from calculate_due_date.
     IF (l_next_due_date_rec.due_date IS NOT NULL) THEN

        IF (l_next_due_flag) THEN
          -- read ahl_temp_unit_effectivity
          IF (l_last_due_date < l_next_due_date_rec.due_date) THEN
            OPEN ahl_temp_ue_csr1(p_applicable_mrs_rec.csi_item_instance_id,
                                  p_applicable_mrs_rec.mr_header_id,
                                  l_last_due_date,
                                  l_next_due_date_rec.due_date);
          ELSE
            OPEN ahl_temp_ue_csr1(p_applicable_mrs_rec.csi_item_instance_id,
                                  p_applicable_mrs_rec.mr_header_id,
                                  l_next_due_date_rec.due_date,
                                  l_last_due_date);
          END IF;

          FETCH ahl_temp_ue_csr1 INTO l_temp_grp_mr_rec;
          IF (ahl_temp_ue_csr1%FOUND) THEN
            --dbms_output.put_line ('exists grp rec' || l_temp_grp_mr_rec.due_date);
            /* there exists a group record with due date less than the calculated * one */
            l_grp_duedate_found := TRUE;

            -- added to fix bug# 6530920.
            -- this is to avoid creation of one child UMP row at the end of the
            -- planning window when the child MR and parent MR have the same interval
            -- threshold. Next due MR can be individual MR or part of a group MR.
            l_next_due_flag := FALSE;

          END IF;
          CLOSE ahl_temp_ue_csr1;
        ELSE
          -- read ahl_temp_unit_effectivity
          OPEN ahl_temp_ue_csr(p_applicable_mrs_rec.csi_item_instance_id,
                               p_applicable_mrs_rec.mr_header_id,
                               l_last_due_date,
                               l_next_due_date_rec.due_date);
          FETCH ahl_temp_ue_csr INTO l_temp_grp_mr_rec;
          IF (ahl_temp_ue_csr%FOUND) THEN
                --dbms_output.put_line ('exists grp rec' || l_temp_grp_mr_rec.due_date);
           /* there exists a group record with due date less than the calculated one */
            l_grp_duedate_found := TRUE;
          END IF;
          CLOSE ahl_temp_ue_csr;
        END IF;
        -- Added for 11.5.10+ Unplanned MRs enhancement.
        l_min_visit_date := NULL;
        IF (l_unplanned_MRs_tbl.COUNT > 0) THEN
          FOR i IN l_unplanned_MRs_tbl.FIRST..l_unplanned_MRs_tbl.LAST LOOP
            IF (l_unplanned_MRs_tbl(i).visit_end_date > l_last_due_date AND
                l_unplanned_MRs_tbl(i).visit_end_date <= l_next_due_date_rec.due_date) THEN
                IF (l_min_visit_date IS NULL) THEN
                   l_min_visit_date := l_unplanned_MRs_tbl(i).visit_end_date;
                ELSIF (l_min_visit_date > l_unplanned_MRs_tbl(i).visit_end_date) THEN
                   l_min_visit_date := l_unplanned_MRs_tbl(i).visit_end_date;
                END IF;
            END IF;
          END LOOP; -- l_unplanned_MRs_tbl.
        END IF; -- Count.

        -- Compare dates from ahl_temp_ue_csr and l_min_visit_date.
        IF (l_grp_duedate_found) THEN
           IF (l_min_visit_date IS NOT NULL) THEN
              IF (l_temp_grp_mr_rec.visit_end_date IS NOT NULL) THEN
                 IF (l_min_visit_date < l_temp_grp_mr_rec.visit_end_date) THEN
                    l_temp_grp_mr_rec.visit_end_date := l_min_visit_date;
                    l_temp_grp_mr_rec.due_date := NULL;
                 END IF;
              ELSIF (l_temp_grp_mr_rec.due_date IS NOT NULL) THEN
                 IF (l_min_visit_date < l_temp_grp_mr_rec.due_date) THEN
                    l_temp_grp_mr_rec.visit_end_date := l_min_visit_date;
                    l_temp_grp_mr_rec.due_date := NULL;
                 END IF;
              ELSE -- both due date and visit end dates are null.
                 l_temp_grp_mr_rec.visit_end_date := l_min_visit_date;
                 l_temp_grp_mr_rec.due_date := NULL;
              END IF;
           END IF; -- l_min_visit_date chk.
        ELSE
          IF (l_min_visit_date IS NOT NULL) THEN
            l_temp_grp_mr_rec.visit_end_date := l_min_visit_date;
            l_temp_grp_mr_rec.due_date := NULL;
            l_grp_duedate_found := TRUE;
            /*
            -- added to fix bug# 6530920.
            -- this is to avoid creation of one child UMP row at the end of the
            -- planning window when the child MR and parent MR have the same interval
            -- threshold. Next due MR can be individual MR or part of a group MR.
            l_next_due_flag := FALSE;
            */
          END IF;
        END IF; -- l_grp_duedate_found.

     END IF; -- l_next_due_date_rec.due_date chk.

     IF (l_next_due_date_rec.due_date IS NULL AND l_next_due_flag = TRUE) OR  /* no repetivity as due_date is null */
        (NOT(l_grp_duedate_found) AND l_next_due_flag = TRUE) OR
        (NOT(l_grp_duedate_found) AND l_next_due_date_rec.due_date IS NOT NULL AND l_next_due_flag = FALSE
          AND trunc(l_next_due_date_rec.due_date) <= trunc(G_last_day_of_window))
     THEN

        -- R12:Added following logic to fix bug# 4224867.
        l_duplicate_MRs := 1; -- default to create only one occurrence of UMP for a day.

        -- find out if multiple UMPs need to be created for a given day.
        IF (l_next_due_date_rec.due_date IS NOT NULL AND l_last_due_date = l_next_due_date_rec.due_date
            AND l_next_due_date_rec.counter_remain IS NOT NULL AND l_next_due_date_rec.counter_remain > 0)
        THEN
           IF G_DEBUG = 'Y' THEN
              AHL_DEBUG_PUB.Debug('Check Multiple UMPs for due date:' || l_next_due_date_rec.due_date);
              AHL_DEBUG_PUB.Debug('Counter Remain:' || l_next_due_date_rec.counter_remain );
           END IF;

           -- get usage for due date.
           get_usage_for_date(l_next_due_date_rec.due_date,
                              l_next_due_date_rec.ctr_uom_code,
                              p_counter_rules_tbl,
                              l_usage_per_day);

           l_duplicate_MRs := trunc(l_usage_per_day/l_next_due_date_rec.counter_remain);
           IF (l_duplicate_MRs = 0) THEN
              l_duplicate_MRs := 1;
           END IF;

           IF G_DEBUG = 'Y' THEN
              AHL_DEBUG_PUB.Debug('get_usage_for_date:' || l_usage_per_day);
              AHL_DEBUG_PUB.Debug('l_duplicate_MRs:' || l_duplicate_MRs);
           END IF;

        END IF; -- l_next_due_date_rec.due_date IS NOT NULL

        -- Now loop to create temp unit effectivities l_duplicate_MRs times.
        FOR m IN 1..l_duplicate_MRs LOOP
        -- R12:End code added to fix bug# 4224867.

           -- construct ahl_unit_effectivity record and write into temporary table.
           l_new_unit_effectivity_rec := l_new_unit_effectivity_initrec; -- initialise.

           -- find the corressponding match in l_unit_effectivity_tbl if exists.
           IF (l_old_UE_forecast_found = TRUE) AND (l_unit_effectivity_tbl.EXISTS(l_old_UE_forecast_sequence+1))
           THEN

             -- loop to find the next individual MR.
             LOOP
                l_old_UE_forecast_sequence := l_old_UE_forecast_sequence + 1;
                IF (l_unit_effectivity_tbl(l_old_UE_forecast_sequence).forecast_sequence is not null) THEN
                    l_new_unit_effectivity_rec.unit_effectivity_id :=
                        l_unit_effectivity_tbl(l_old_UE_forecast_sequence).unit_effectivity_id;
                        EXIT; -- matched record found.
                ELSIF NOT(l_unit_effectivity_tbl.EXISTS(l_old_UE_forecast_sequence+1)) THEN
                        l_new_unit_effectivity_rec.unit_effectivity_id := null;
                        l_old_UE_forecast_sequence := -1;
                        l_old_UE_forecast_found := FALSE;
                        EXIT;
                END IF;
             END LOOP;

           ELSE
             l_new_unit_effectivity_rec.unit_effectivity_id := null;
             l_old_UE_forecast_sequence := -1;
             l_old_UE_forecast_found := FALSE;
           END IF;


           -- Check for tolerance if visit has been assigned.
           IF (l_old_UE_forecast_found = TRUE) AND (l_next_due_date_rec.due_date IS NOT NULL) THEN
              IF (l_unit_effectivity_tbl(l_old_UE_forecast_sequence).visit_assign_flag = 'Y') THEN
                 IF l_next_due_date_rec.tolerance_before IS NOT NULL THEN
                       -- calculate due date based on forecast.
                       -- get date from forecast.
                       /*--get_date_from_uf(l_next_due_date_rec.due_at_counter_value - l_next_due_date_rec.tolerance_before,
                                        l_next_due_date_rec.ctr_uom_code,
                                        p_counter_rules_tbl,
                                        l_last_due_date,
                                        l_bef_tolr_due_date); */
                       IF ((trunc(l_unit_effectivity_tbl(l_old_UE_forecast_sequence).visit_end_date))
                            < trunc(l_next_due_date_rec.earliest_due_date)) THEN
                            -- tolerance before.
                            l_next_due_date_rec.tolerance_flag := 'Y';
                            l_next_due_date_rec.message_code := 'TOLERANCE-BEFORE';

                       END IF;
                 END IF;

                 IF l_next_due_date_rec.tolerance_after IS NOT NULL THEN
                       -- calculate due date based on forecast.
                       -- get date from forecast.
                       /*get_date_from_uf(l_next_due_date_rec.tolerance_after,
                                        l_next_due_date_rec.ctr_uom_code,
                                        p_counter_rules_tbl,
                                        l_next_due_date_rec.due_date,
                                        l_aft_tolr_due_date); */
                       IF ((trunc(l_unit_effectivity_tbl(l_old_UE_forecast_sequence).visit_end_date))
                               > trunc(l_next_due_date_rec.latest_due_date)) THEN
                            -- tolerance after.
                            l_next_due_date_rec.tolerance_flag := 'Y';
                            l_next_due_date_rec.message_code := 'TOLERANCE-EXCEEDED';

                       END IF;
                 END IF;
              END IF;
           END IF;


           l_new_unit_effectivity_rec.due_date := l_next_due_date_rec.due_date;
           l_new_unit_effectivity_rec.mr_interval_id := l_next_due_date_rec.mr_interval_id;
           l_new_unit_effectivity_rec.mr_effectivity_id := l_next_due_date_rec.mr_effectivity_id;
           l_new_unit_effectivity_rec.due_counter_value := l_next_due_date_rec.due_at_counter_value;
           l_new_unit_effectivity_rec.tolerance_flag := l_next_due_date_rec.tolerance_flag;
           l_new_unit_effectivity_rec.tolerance_before := l_next_due_date_rec.tolerance_before;
           l_new_unit_effectivity_rec.tolerance_after := l_next_due_date_rec.tolerance_after;
           l_new_unit_effectivity_rec.message_code := l_next_due_date_rec.message_code;
           l_new_unit_effectivity_rec.csi_item_instance_id := p_applicable_mrs_rec.csi_item_instance_id;
           l_new_unit_effectivity_rec.mr_header_id := p_applicable_mrs_rec.mr_header_id;
           l_new_unit_effectivity_rec.preceding_check_flag:= 'N';
           -- Added for ER# 2636001.
           l_new_unit_effectivity_rec.earliest_due_date := l_next_due_date_rec.earliest_due_date;
           l_new_unit_effectivity_rec.latest_due_date := l_next_due_date_rec.latest_due_date;
           -- Added to fix bug#2780716.
           l_new_unit_effectivity_rec.counter_id := l_next_due_date_rec.counter_id;


           -- increment forecast sequence.
           l_forecast_sequence := l_forecast_sequence + 1;
           l_new_unit_effectivity_rec.forecast_sequence := l_forecast_sequence;

           IF G_DEBUG = 'Y' THEN
              AHL_DEBUG_PUB.Debug('New Unit eff:' || l_new_unit_effectivity_rec.unit_effectivity_id);
              AHL_DEBUG_PUB.Debug('Old forecast seq:'|| l_old_UE_forecast_sequence);
           END IF;

           -- set repetivity based on next_due_flag.
           IF (l_next_due_flag) THEN
              l_new_unit_effectivity_rec.repetitive_mr_flag := 'N';
           ELSE
              l_new_unit_effectivity_rec.repetitive_mr_flag := 'Y';
           END IF;


           -- Update preceding MR details.
           IF (l_dependent_mr_flag AND l_forecast_sequence = 1) THEN
              l_new_unit_effectivity_rec.preceding_mr_header_id := p_applicable_mrs_rec.preceding_mr_header_id;
              l_new_unit_effectivity_rec.preceding_csi_item_instance_id := p_applicable_mrs_rec.csi_item_instance_id;
              l_new_unit_effectivity_rec.preceding_forecast_seq := l_forecast_sequence;
              l_dependent_mr_flag := FALSE; -- this is required only for next due.
           END IF;

           -- write into temporary table.
           IF NOT(group_check_flag) THEN

             -- create record in temporary table.
             Create_Temp_Unit_Effectivity (l_new_unit_effectivity_rec);

             IF G_DEBUG = 'Y' THEN
                AHL_DEBUG_PUB.Debug('After create_temp_unit_effectivity');
             END IF;

           ELSE
              -- Process group MR.
              Process_groupMR (p_applicable_mrs_rec,
                               l_new_unit_effectivity_rec,
                               l_unit_effectivity_tbl,
                               l_old_UE_forecast_sequence);
           END IF;

           -- Set next due flag to FALSE after writing record into temporary unit_effectivity.
           IF (l_next_due_flag) THEN
                l_next_due_flag := FALSE;
           END IF;

           -- Fix for bug# 6858788
           l_last_due_mr_interval_id := l_next_due_date_rec.mr_interval_id;

       END LOOP; -- m (Duplicate_MRs)
     END IF; -- l_next_due_date_rec.due_date IS NULL

     /* exit if one next due mr has been calculated and its due date is null
        or if next due date is beyond the rolling window date */
     EXIT WHEN ((l_next_due_flag = FALSE AND l_next_due_date_rec.due_date IS NULL) OR
                (l_next_due_flag = FALSE AND p_applicable_mrs_rec.show_repetitive_code = 'NEXT') OR
                (l_next_due_date_rec.due_date IS NOT NULL AND p_applicable_mrs_rec.effective_to IS NOT NULL AND trunc(l_next_due_date_rec.due_date) > trunc(p_applicable_mrs_rec.effective_to)) OR
                (l_next_due_flag = FALSE AND trunc(l_next_due_date_rec.due_date) > trunc(G_last_day_of_window))
               );

     -- Set from l_next_due_date_rec.
     l_due_date := l_next_due_date_rec.due_date;

     -- If grp MR exists with due date less than calculated date, then re-calculate due date.
     IF (l_grp_duedate_found) THEN

       -- Set due date to be either visit_end_date or due_date.
       IF (l_temp_grp_mr_rec.visit_end_date IS NOT NULL) THEN
          l_due_date := l_temp_grp_mr_rec.visit_end_date;
       ELSE
          l_due_date := l_temp_grp_mr_rec.due_date;
       END IF;

       -- Fix for bug# 6858788. Reset l_last_due_mr_interval_id if duedate based on group MR.
       l_last_due_mr_interval_id := NULL;

     ELSE

       -- Set values for next repetivity calculation.
       IF (l_unit_effectivity_tbl.EXISTS(l_old_UE_forecast_sequence)) THEN
         IF (l_unit_effectivity_tbl(l_old_UE_forecast_sequence).visit_assign_flag = 'Y') THEN
              l_due_date := l_unit_effectivity_tbl(l_old_UE_forecast_sequence).visit_end_date;
         END IF;
       END IF;
     END IF;

     -- If due date is a past date, then set it to sysdate.
     -- This will happen only when calculating next-due date.
     IF (trunc(l_due_date) < trunc(sysdate)) THEN
       l_due_date := sysdate;
     END IF;

     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('Processing for repetivity');
        AHL_DEBUG_PUB.Debug('Before get_due_at_counter_values');
        AHL_DEBUG_PUB.Debug('l_last_due_date: '|| l_last_due_date);
        AHL_DEBUG_PUB.Debug('l_due_date: '|| l_due_date);
        IF (l_last_due_counter_val_tbl.COUNT > 0) THEN
          FOR i in l_last_due_counter_val_tbl.FIRST..l_last_due_counter_val_tbl.LAST LOOP
            AHL_DEBUG_PUB.Debug('i:'|| i|| ' value:' || l_last_due_counter_val_tbl(i).counter_value || 'ID: ' || l_last_due_counter_val_tbl(i).counter_id);
          END LOOP;
        END IF;
     END IF;

     -- get all counter values as on l_due_date.
     Get_Due_at_Counter_Values (p_last_due_date => l_last_due_date,
                                p_last_due_counter_val_tbl => l_last_due_counter_val_tbl,
                                p_due_date => l_due_date,
                                p_counter_rules_tbl => p_counter_rules_tbl,
                                x_due_at_counter_val_tbl => l_due_at_counter_val_tbl,
                                x_return_value => l_return_value);
     l_last_due_date := l_due_date;
     l_last_due_counter_val_tbl := l_due_at_counter_val_tbl;

     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('AFter get_due_at_counter_values');
        AHL_DEBUG_PUB.Debug('l_last_due_date: '|| l_last_due_date);
        AHL_DEBUG_PUB.Debug('l_due_date: '|| l_due_date);
        IF (l_due_at_counter_val_tbl.COUNT) > 0 THEN
           for i in l_due_at_counter_val_tbl.FIRST..l_due_at_counter_val_tbl.LAST LOOP
             AHL_DEBUG_PUB.Debug('i:'|| i|| ' value:' || l_due_at_counter_val_tbl(i).counter_value || 'ID: ' || l_due_at_counter_val_tbl(i).counter_id);
           end loop;
        END IF;
     END IF;

     IF NOT(l_return_value) THEN
        EXIT; /* no forecast available so exit */
     END IF;

     -- Calculate next due date.
     Calculate_Due_Date (p_repetivity_flag => 'Y',
                         p_applicable_mrs_rec => p_applicable_mrs_rec,
                         p_current_usage_tbl => p_current_usage_tbl,
                         p_counter_rules_tbl => p_counter_rules_tbl,
                         p_last_due_date => l_last_due_date,
                         p_last_due_counter_val_tbl => l_last_due_counter_val_tbl,
                         p_mr_accomplish_exists  => l_mr_accomplish_exists,
                         p_last_due_mr_interval_id => l_last_due_mr_interval_id,
                         x_next_due_date_rec => l_next_due_date_rec);

     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('aft calculate_due_date - repetivity');
        AHL_DEBUG_PUB.Debug('due date is ' || l_next_due_date_rec.DUE_DATE);
        AHL_DEBUG_PUB.Debug('earliest due date is ' || l_next_due_date_rec.EARLIEST_DUE_DATE);
        AHL_DEBUG_PUB.Debug('latest due date is ' || l_next_due_date_rec.latest_due_date);
     END IF;

     -- Check if calculated date is same as last due date. If they are the same then, add one day.
     IF (l_next_due_date_rec.due_date IS NOT NULL) THEN
        IF (trunc(l_last_due_date) = trunc(l_next_due_date_rec.due_date)) THEN
               l_next_due_date_rec.due_date := l_next_due_date_rec.due_date + 1;
               l_next_due_date_rec.EARLIEST_DUE_DATE := NULL;
               l_next_due_date_rec.latest_due_date := NULL;

               IF G_DEBUG = 'Y' THEN
                 AHL_DEBUG_PUB.Debug('Adding one day to l_next_due_date_rec.due_date:' || l_next_due_date_rec.due_date);
               END IF;

            --IF G_DEBUG = 'Y' THEN
            --   AHL_DEBUG_PUB.Debug('Exiting build effectivity as last due = due date');
            --END IF;
            --EXIT;
        END IF;
     END IF;

  END LOOP;

  -- Fix for bug# 6711228.
  <<process_preceding_mr>>
  -- Process preceding MRs.
  IF ((p_applicable_mrs_rec.implement_status_code = 'MANDATORY') OR
     (l_mr_accomplish_exists)) THEN
      Process_PrecedingMR (p_applicable_mrs_rec => p_applicable_mrs_rec,
                           p_counter_rules_tbl  => p_counter_rules_tbl,
                           p_current_usage_tbl  => p_current_usage_tbl);

  END IF;

END Build_Effectivity;

--------------------------------------------------------------------------------------
-- Calculate due date for the item instance and mr using current usage, counter rules,
-- last accomplishment counters and forecast (defined in global variable).
-- Added parameter p_dependent_mr_flag to fix bug# 6711228 used when
-- calculating nextdue date.
-- Added parameters p_mr_accomplish_exists and p_last_due_mr_interval_id to fix bug# 6858788.
PROCEDURE Calculate_Due_Date ( p_repetivity_flag    IN VARCHAR2 := 'Y',
                               p_applicable_mrs_rec IN applicable_mrs_rec_type,
                               p_current_usage_tbl  IN counter_values_tbl_type,
                               p_counter_rules_tbl  IN counter_rules_tbl_type,
                               p_last_due_date      IN DATE,
                               p_last_due_counter_val_tbl IN counter_values_tbl_type,
                               p_dependent_mr_flag  IN BOOLEAN := FALSE,
                               p_mr_accomplish_exists IN BOOLEAN,
                               p_last_due_mr_interval_id IN NUMBER := NULL,
                               x_next_due_date_rec  OUT NOCOPY next_due_date_rec_type)

IS

  -- Read all effectivities for the mr and item instance.
  CURSOR ahl_applicable_csr (p_instance_id IN NUMBER,
                             p_mr_header_id IN NUMBER) IS
     SELECT DISTINCT mr.mr_effectivity_id, threshold_date
     FROM ahl_applicable_mrs mr, ahl_mr_effectivities eff
     WHERE mr.mr_effectivity_id = eff.mr_effectivity_id AND
           csi_item_instance_id = p_instance_id AND
           mr.mr_header_id = p_mr_header_id;

  -- read all intervals for the effectivity id.
  CURSOR ahl_mr_interval_csr (p_mr_effectivity_id IN NUMBER,
                              --p_counter_id  IN NUMBER,
                              p_counter_name  IN VARCHAR2,
                              p_counter_value IN NUMBER,
                              p_start_date IN DATE) IS
     SELECT INT.mr_interval_id, INT.start_date, INT.stop_date,
            INT.start_value, INT.stop_value, INT.counter_id,
            INT.interval_value, INT.tolerance_after, INT.tolerance_before,
            INT.earliest_due_value, -- added for bug# 6358940.
            INT.calc_duedate_rule_code  -- added for ER 7415856
     --Replaced cs_counters_v with cs_counters to fix perf bug# 3786647.
     --FROM   ahl_mr_intervals INT, cs_counters_v CTR, cs_counters_v CN
     --replaced cs_counters CTR with csi_counter_template_vl
     --and cs_counters CN with csi_counters_vl CN to fix bug# 5918525.
     FROM   ahl_mr_intervals INT, csi_counter_template_vl CTR --, csi_counters_vl CN
     WHERE  INT.counter_id = CTR.counter_id AND
            --CTR.name = CN.name AND -- bug# 5918525.
            --CTR.name = CN.counter_template_name AND -- removed for perf fix.
            CTR.name = p_counter_name AND
            INT.mr_effectivity_id = p_mr_effectivity_id AND
            --CN.counter_id = p_counter_id AND -- removed for perf fix.
            (
              ( (nvl(start_value, p_counter_value+1) <= p_counter_value AND
                 --p_counter_value < nvl(stop_value, p_counter_value+1)) OR
                 -- Fix for bug# 3482307.
                 p_counter_value <= nvl(stop_value, p_counter_value+1)) OR
                (trunc(nvl(start_date, p_start_date+1)) <= trunc(p_start_date) AND
                 --trunc(p_start_date) < trunc(nvl(stop_date, p_start_date+1)) )
                 -- Fix for bug# 3482307.
                 trunc(p_start_date) <= trunc(nvl(stop_date, p_start_date+1)) )
              )
             OR
               /* pick records with no start/stop values/dates. */
              (start_value IS NULL AND stop_value IS NULL AND start_date IS NULL AND stop_date IS NULL
               AND interval_value IS NOT NULL)
            );

  -- get the unit effectivity record for init-due for this mr and item.
  CURSOR ahl_init_due_csr (p_csi_item_instance_id IN NUMBER,
                           p_mr_header_id IN NUMBER)  IS
    SELECT ud.set_due_date, ue.unit_effectivity_id, ud.unit_deferral_id
    FROM ahl_unit_effectivities_app_v ue, ahl_unit_deferrals_vl ud
    WHERE ue.unit_effectivity_id = ud.unit_effectivity_id AND
          ud.unit_deferral_type = 'INIT-DUE' AND
          ue.csi_item_instance_id = p_csi_item_instance_id AND
          ue.mr_header_id = p_mr_header_id AND
          ue.status_code = 'INIT-DUE';

  -- get all init-due counter records setup for this unit effectivity.
  CURSOR ahl_unit_thresholds_csr (p_unit_deferral_id IN NUMBER) IS
    SELECT counter_id, counter_value
    FROM ahl_unit_thresholds
    WHERE unit_deferral_id = p_unit_deferral_id;

  -- added for performance fix bug# 6893404.
  CURSOR get_interval_ctr_name(p_mr_effectivity_id IN NUMBER) IS
    SELECT DISTINCT name counter_name
    FROM ahl_mr_intervals int, csi_counter_template_vl ctr
    WHERE int.mr_effectivity_id = p_mr_effectivity_id
      AND int.counter_id = ctr.counter_id;

  --
  DUE_DATE_NULL EXCEPTION ;
  NO_VALID_INTERVAL EXCEPTION;

  l_next_due_date_rec  Next_Due_Date_Rec_Type;

  l_due_date DATE; /* due date returned back after forecast calculation */
  l_calc_due_date  DATE; /* next due date that will be returned by this procedure */
  l_adjusted_due_date DATE; /* adjusted due date returned in case of overflow into next interval */
  l_adjusted_int_value NUMBER; /* adjusted interval value returned in case of overflow into next interval */
  l_nxt_interval_found BOOLEAN;

  l_mr_interval_id  NUMBER; /* the interval id that triggered this mr due date */
  l_due_at_counter_value NUMBER; /* next due counter value */
  l_counter_remain NUMBER;
  l_mr_interval_found BOOLEAN; /*indicates if at one mr_interval exists for the effectivity */

  -- modified to fix bug# 6725769.
  --l_old_mr_interval_found  BOOLEAN;
  l_old_ctr_interval_found  BOOLEAN;
  -- added to fix bug# 6725769.
  l_ctr_interval_found      BOOLEAN; -- indicates if a mr interval was found for a counter.

  l_temp_counter_tbl  counter_values_tbl_type;
  l_counter_value  NUMBER;
  l_current_ctr_value NUMBER;
  l_set_due_date  DATE;
  l_threshold_date  DATE;
  l_start_date DATE;
  l_start_int_match_at_ctr  NUMBER; /* interval match start counter value. */

  l_mr_interval_rec ahl_mr_interval_csr%ROWTYPE;

  l_unit_effectivity_id NUMBER;
  k   NUMBER; /* for l_temp_counter_tbl */

  l_return_val   BOOLEAN; -- return status indicator.
  l_counter_read_date   DATE;
  l_unit_deferral_id    NUMBER;

  l_reset_start_value_flag  BOOLEAN;
  l_due_counter_tbl         counter_values_tbl_type;
  l_last_due_counter_tbl    counter_values_tbl_type;

  l_adjusted_due_ctr        NUMBER;

  -- added to fix calculation of before and after tolerance dates when
  -- uom_remain < 0.
  l_calc_due_date_ctr_id    NUMBER;

  -- added to fix bug# 6358940.
  l_reset_start_date_flag   BOOLEAN;

  -- added to fix perf bug# 6893404.
  i  NUMBER; -- setting l_temp_counter_tbl index.

BEGIN

  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('In calculate due date');
  END IF;

  -- Initialize due date.
  l_calc_due_date := null;
  l_calc_due_date_ctr_id := null;

  -- Initialize OUT record.
  x_next_due_date_rec := l_next_due_date_rec;

  IF (p_repetivity_flag = 'N') THEN
    l_temp_counter_tbl := p_current_usage_tbl;
  ELSE
    l_temp_counter_tbl := p_last_due_counter_val_tbl;
  END IF;

  -- Fix for bug# 6358940. Due Date should be based only on init-due if it
  -- exists. MR thresholds should not be used.
  -- Calculate due date based on init-due defination; if exists.
  IF (p_repetivity_flag = 'N') THEN
     --dbms_output.put_line ('in INIT-due part');

     -- Check if there is any init-due record for this item instance and mr exists.
     OPEN ahl_init_due_csr(p_applicable_mrs_rec.csi_item_instance_id,
                           p_applicable_mrs_rec.mr_header_id);
     FETCH ahl_init_due_csr INTO l_set_due_date, l_unit_effectivity_id, l_unit_deferral_id;
     IF (ahl_init_due_csr%FOUND) THEN

        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.Debug('INIT-Due processing: Set due_date:' || l_set_due_date);
        END IF;
        --dbms_output.put_line ('in INIT-due part: due_date' || l_set_due_date);

        FOR threshold_rec IN ahl_unit_thresholds_csr (l_unit_deferral_id)
        LOOP
          -- for init due, ctr_value_type_code is always 'defer_to'.
          l_due_at_counter_value := threshold_rec.counter_value;
          l_counter_remain := 0;
          l_current_ctr_value := 0;
          k := 0;
          -- search for the current counter value in l_current_usage_tbl.
          IF (l_temp_counter_tbl.COUNT > 0) THEN
            FOR i IN l_temp_counter_tbl.FIRST..l_temp_counter_tbl.LAST LOOP
               IF (l_temp_counter_tbl(i).counter_id = threshold_rec.counter_id) THEN
                  l_current_ctr_value := l_temp_counter_tbl(i).counter_value;
                  k := i;
                  EXIT;
               END IF;
            END LOOP;
            l_counter_remain := l_due_at_counter_value - l_current_ctr_value;
          END IF;

          -- calculate due date from forecast.
          IF (l_counter_remain > 0) THEN
            -- get date from forecast.
            get_date_from_uf(l_counter_remain,
                             l_temp_counter_tbl(k).uom_code,
                             p_counter_rules_tbl,
                             null, -- start date = sysdate
                             l_due_date);
          ELSIF (l_counter_remain < 0) THEN
            -- Due date = counter reading date.
             get_ctr_date_for_reading (p_csi_item_instance_id => p_applicable_mrs_rec.csi_item_instance_id,
                                       p_counter_id           => l_temp_counter_tbl(k).counter_id,
                                       p_counter_value        => l_due_at_counter_value,
                                       x_ctr_record_date      => l_counter_read_date,
                                       x_return_val           => l_return_val);

             IF NOT(l_return_val) THEN
                l_due_date := sysdate;
             ELSE
                l_due_date := l_counter_read_date;
             END IF;

          ELSIF (l_counter_remain = 0) THEN  -- due_date = sysdate
            --dbms_output.put_line ('counter remain less than zero');
            l_due_date := sysdate;
          END IF;

          -- Compare with whichever first code and set l_calc_due_date.
          IF (l_due_date IS NULL) THEN
             -- Added to fix bug# 6907562.
             IF (validate_for_duedate_reset(l_due_date,
                                            l_counter_remain,
                                            l_calc_due_date,
                                            l_calc_due_date_ctr_id,
                                            x_next_due_date_rec.counter_remain)) = 'Y' THEN

               --dbms_output.put_line ('due date null');
               l_calc_due_date := l_due_date;
               x_next_due_date_rec.due_date := null;
               x_next_due_date_rec.tolerance_after := null;
               x_next_due_date_rec.tolerance_before := null;
               x_next_due_date_rec.mr_interval_id := null;
               x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
               x_next_due_date_rec.mr_effectivity_id := null;
               x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
               x_next_due_date_rec.last_ctr_value := null;
               x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(k).uom_code;
               x_next_due_date_rec.counter_id := l_temp_counter_tbl(k).counter_id;
               x_next_due_date_rec.counter_remain := l_counter_remain;
               l_calc_due_date_ctr_id := l_temp_counter_tbl(k).counter_id;
               -- fix for bug# 6907562. Loop to next threshold when due date is null.
               --EXIT;
             END IF;
          ELSE
            IF (l_calc_due_date IS NULL) THEN
               -- Added to fix bug# 6907562.
               IF (validate_for_duedate_reset(l_due_date,
                                              l_counter_remain,
                                              l_calc_due_date,
                                              l_calc_due_date_ctr_id,
                                              x_next_due_date_rec.counter_remain)) = 'Y' THEN
                 --dbms_output.put_line ('calc due date null');
                 l_calc_due_date := l_due_date;
                 x_next_due_date_rec.due_date := l_due_date;
                 x_next_due_date_rec.tolerance_after := null;
                 x_next_due_date_rec.tolerance_before := null;
                 x_next_due_date_rec.mr_interval_id := null;
                 x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
                 x_next_due_date_rec.mr_effectivity_id := null;
                 x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                 x_next_due_date_rec.last_ctr_value := null;
                 x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(k).uom_code;
                 x_next_due_date_rec.counter_id := l_temp_counter_tbl(k).counter_id;
                 x_next_due_date_rec.counter_remain := l_counter_remain;
                 l_calc_due_date_ctr_id := l_temp_counter_tbl(k).counter_id;
               END IF;
            ELSE
               IF (p_applicable_mrs_rec.whichever_first_code = 'FIRST') THEN
                 -- Check due date based on whichever_first_code.
                 -- if dates are equal, switch based on lower uom remain value. (bug# 6907562).
                 IF (l_calc_due_date > l_due_date) OR
                    (trunc(l_calc_due_date) = trunc(l_due_date) AND l_counter_remain IS NOT NULL
                        AND x_next_due_date_rec.counter_remain IS NOT NULL
                        AND l_counter_remain < x_next_due_date_rec.counter_remain) THEN
                      l_calc_due_date := l_due_date;
                      x_next_due_date_rec.due_date := l_due_date;
                      x_next_due_date_rec.tolerance_after := null;
                      x_next_due_date_rec.tolerance_before := null;
                      x_next_due_date_rec.mr_interval_id := null;
                      x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
                      x_next_due_date_rec.mr_effectivity_id := null;
                      x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                      x_next_due_date_rec.last_ctr_value := null;
                      x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(k).uom_code;
                      x_next_due_date_rec.counter_id := l_temp_counter_tbl(k).counter_id;
                      x_next_due_date_rec.counter_remain := l_counter_remain;
                      l_calc_due_date_ctr_id := l_temp_counter_tbl(k).counter_id;

                    END IF;
                 ELSE  -- whichever_first_code = 'LAST'
                    -- if dates are equal, switch based on higher uom remain value. (bug# 6907562).
                    IF (l_calc_due_date < l_due_date) OR
                       (trunc(l_calc_due_date) = trunc(l_due_date) AND l_counter_remain IS NOT NULL
                        AND x_next_due_date_rec.counter_remain IS NOT NULL
                        AND l_counter_remain > x_next_due_date_rec.counter_remain) THEN
                        --dbms_output.put_line ('set due date');
                        l_calc_due_date := l_due_date;
                        x_next_due_date_rec.due_date := l_due_date;
                        x_next_due_date_rec.tolerance_after := null;
                        x_next_due_date_rec.tolerance_before := null;
                        x_next_due_date_rec.mr_interval_id := null;
                        x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
                        x_next_due_date_rec.mr_effectivity_id := null;
                        x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                        x_next_due_date_rec.last_ctr_value := null;
                        x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(k).uom_code;
                        x_next_due_date_rec.counter_id := l_temp_counter_tbl(k).counter_id;
                        x_next_due_date_rec.counter_remain := l_counter_remain;
                        l_calc_due_date_ctr_id := l_temp_counter_tbl(k).counter_id;

                    END IF;
                 END IF; -- applicable_mrs_rec
            END IF; -- calc_due_date null
          END IF; -- l_due_date IS NULL
        END LOOP; -- set_threshold_rec

        -- Check for set due date.
        IF (l_set_due_date IS NOT NULL) THEN
              IF (l_calc_due_date IS NULL) THEN
                 -- added to fix bug# 6907562.
                 -- reset only when l_calc_due_date_ctr_id is also null.
                 IF (l_calc_due_date_ctr_id IS NULL) THEN
                   l_calc_due_date := l_set_due_date;
                   x_next_due_date_rec.due_date := l_set_due_date;
                   x_next_due_date_rec.tolerance_after := null;
                   x_next_due_date_rec.tolerance_before := null;
                   x_next_due_date_rec.mr_effectivity_id := null;
                   x_next_due_date_rec.due_at_counter_value := null;
                   x_next_due_date_rec.current_ctr_value := null;
                   x_next_due_date_rec.last_ctr_value := null;
                   x_next_due_date_rec.mr_interval_id := null;
                   x_next_due_date_rec.ctr_uom_code := null;
                   x_next_due_date_rec.counter_id := null;
                   x_next_due_date_rec.counter_remain := null;
                   l_calc_due_date_ctr_id := null;
                 END IF;
              ELSE
                 IF (p_applicable_mrs_rec.whichever_first_code = 'FIRST') THEN
                     IF (l_calc_due_date > l_set_due_date) THEN
                       --dbms_output.put_line ('set due da te');
                       l_calc_due_date := l_set_due_date;
                       x_next_due_date_rec.due_date := l_set_due_date;
                       x_next_due_date_rec.tolerance_after := null;
                       x_next_due_date_rec.tolerance_before := null;
                       x_next_due_date_rec.mr_interval_id := null;
                       x_next_due_date_rec.due_at_counter_value := null;
                       x_next_due_date_rec.mr_effectivity_id := null;
                       x_next_due_date_rec.current_ctr_value := null;
                       x_next_due_date_rec.last_ctr_value := null;
                       x_next_due_date_rec.ctr_uom_code := null;
                       x_next_due_date_rec.counter_id := null;
                       x_next_due_date_rec.counter_remain := null;
                       l_calc_due_date_ctr_id := null;

                     END IF;
                 ELSE
                    -- Check for set due date.
                    IF (l_calc_due_date < l_set_due_date) THEN
                        l_calc_due_date := l_set_due_date;
                        x_next_due_date_rec.due_date := l_set_due_date;
                        x_next_due_date_rec.tolerance_after := null;
                        x_next_due_date_rec.tolerance_before := null;
                        x_next_due_date_rec.mr_interval_id := null;
                        x_next_due_date_rec.due_at_counter_value := null;
                        x_next_due_date_rec.mr_effectivity_id := null;
                        x_next_due_date_rec.current_ctr_value := null;
                        x_next_due_date_rec.last_ctr_value := null;
                        x_next_due_date_rec.ctr_uom_code := null;
                        x_next_due_date_rec.counter_id := null;
                        x_next_due_date_rec.counter_remain := null;
                        l_calc_due_date_ctr_id := null;

                    END IF;
                 END IF; -- applicable
               END IF;
         END IF;  -- set due date
        -- If due date is less than sysdate, then flag tolerance.
        IF (x_next_due_date_rec.due_date IS NOT NULL) AND
           (trunc(x_next_due_date_rec.due_date) < trunc(sysdate)) THEN
            x_next_due_date_rec.tolerance_flag := 'Y';
            x_next_due_date_rec.message_code := 'TOLERANCE-EXCEEDED';
        END IF;
        CLOSE ahl_init_due_csr;
        RETURN; -- exit calculation.
     END IF; -- init_due_csr
     CLOSE ahl_init_due_csr;
  END IF; -- repetitive_flag

  -- Loop through each effectivity record.
  <<mr_effectivity_loop>>
  FOR effectivity_rec IN ahl_applicable_csr(p_applicable_mrs_rec.csi_item_instance_id,
                                            p_applicable_mrs_rec.mr_header_id)
  LOOP

     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('eff ID' || effectivity_rec.mr_effectivity_id );
     END IF;

     l_threshold_date := effectivity_rec.threshold_date;
     l_mr_interval_found := FALSE;
     --l_old_mr_interval_found := FALSE;

     -- Loop through all counters in l_temp_counter_tbl.
     IF (l_temp_counter_tbl.COUNT > 0) THEN

       -- instead of looping through all counters, loop through interval counters
       -- and match counter name in l_temp_counter_tbl and set index i.
       --FOR i IN l_temp_counter_tbl.FIRST..l_temp_counter_tbl.LAST LOOP

       FOR ctr_name_rec IN get_interval_ctr_name(effectivity_rec.mr_effectivity_id)  LOOP
         -- set l_temp_counter_tbl row for matching counter.
         i := -1;

         FOR k IN l_temp_counter_tbl.FIRST..l_temp_counter_tbl.LAST LOOP
           IF (l_temp_counter_tbl(k).counter_name = ctr_name_rec.counter_name) THEN
               i := k;
               EXIT;
           END IF;
         END LOOP;

         -- if no match for interval counter then
         -- proceed to next counter.
         IF (i = -1) THEN
           GOTO next_counter_loop;
         END IF;

         -- Added for fix 6725769.
         l_ctr_interval_found := FALSE;
         l_old_ctr_interval_found := FALSE;

         -- find the counter value from p_last_due_counter_val_tbl
         -- for this counter id.
         IF (p_repetivity_flag = 'N') THEN
            -- set current ctr value from l_current_usage_tbl.
            l_start_date := sysdate; /* interval start/stop dates validation on sysdate */
            l_current_ctr_value := l_temp_counter_tbl(i).counter_value;
            l_counter_value := 0; /* initialize last due counter value */

            IF (p_last_due_counter_val_tbl.COUNT > 0) THEN
                --dbms_output.put_line ('in last due counter loop-count'||p_last_due_counter_val_tbl.COUNT );
              FOR j IN p_last_due_counter_val_tbl.FIRST..p_last_due_counter_val_tbl.LAST
              LOOP
                --dbms_output.put_line ('in last due counter loop');
                IF (p_last_due_counter_val_tbl(j).counter_id = l_temp_counter_tbl(i).counter_id) THEN
                    -- counter value will be just from last due.
                    l_counter_value := p_last_due_counter_val_tbl(j).counter_value;

                    -- start interval matching at last accomplishment data as it is available.
                    l_start_int_match_at_ctr := l_counter_value;
                END IF;
              END LOOP;
            ELSE
              -- start interval matching at current counter value as last accomplishment data
              -- is not available.
              l_start_int_match_at_ctr := l_current_ctr_value;
            END IF; /* count > 0 */
         ELSE
           -- For repetity, set current_ctr_value to zero.
           -- Set l_counter_value from l_temp_counter_tbl.
           l_counter_value := l_temp_counter_tbl(i).counter_value;
           l_current_ctr_value := 0; /* initialize current usage on counter */
           l_start_date := p_last_due_date; /* interval start/stop dates validation on last due date */

           -- For repetity, l_start_int_match_at_ctr is last counter value.
           l_start_int_match_at_ctr := l_counter_value;

         END IF; /* repetivity */

         --dbms_output.put_line ('CounterID' || l_temp_counter_tbl(i).counter_id);
         --dbms_output.put_line ('counter_value' || l_counter_value);

         -- For each effectivity, loop through mr intervals.
         FOR mr_interval_rec IN ahl_mr_interval_csr(effectivity_rec.mr_effectivity_id,
                                                      --l_temp_counter_tbl(i).counter_id,
                                                      l_temp_counter_tbl(i).counter_name,
                                                      l_start_int_match_at_ctr,
                                                      l_start_date)
         LOOP

           -- reset loop variables.
           l_old_ctr_interval_found := l_ctr_interval_found;
           l_reset_start_value_flag := FALSE;
           l_reset_start_date_flag  := FALSE;

           -- added to fix bug#	6725769
           IF NOT(l_ctr_interval_found) THEN
             l_ctr_interval_found := TRUE; /* found a interval. */
           END IF;

           --l_mr_interval_found := TRUE; /* found a interval. */
           l_mr_interval_rec := mr_interval_rec;

           IF G_DEBUG = 'Y' THEN
             AHL_DEBUG_PUB.Debug('In interval table loop');
             AHL_DEBUG_PUB.Debug('mr interval:' || l_mr_interval_rec.mr_interval_id );
             AHL_DEBUG_PUB.Debug('start value:' ||l_mr_interval_rec.start_value);
             AHL_DEBUG_PUB.Debug('stop value:' ||l_mr_interval_rec.start_value);
             AHL_DEBUG_PUB.Debug('start date:' ||l_mr_interval_rec.start_date);
             AHL_DEBUG_PUB.Debug('stop date:' ||l_mr_interval_rec.start_date);
             AHL_DEBUG_PUB.Debug('Interval Value:' ||l_mr_interval_rec.tolerance_before);
             AHL_DEBUG_PUB.Debug('tolerance bef:' ||l_mr_interval_rec.tolerance_before);
             AHL_DEBUG_PUB.Debug('tolerance aft:' ||l_mr_interval_rec.tolerance_after);
             AHL_DEBUG_PUB.Debug('earliest_due_value:' ||l_mr_interval_rec.earliest_due_value);
             AHL_DEBUG_PUB.Debug('CounterID:' || l_temp_counter_tbl(i).counter_id);
             AHL_DEBUG_PUB.Debug('CounterName:' || l_temp_counter_tbl(i).counter_name);
             AHL_DEBUG_PUB.Debug('counter_value:' || l_counter_value);
             AHL_DEBUG_PUB.Debug('current ctr:' ||l_current_ctr_value);
           END IF;

           l_counter_remain := 0; /* initialize */

           l_due_at_counter_value := l_mr_interval_rec.interval_value + l_counter_value;

           -- Added for bug# 6358940(start_value).
           -- if at least one MR is accomplished and earliest_due_value is defined.
           IF (p_last_due_date IS NOT NULL AND p_repetivity_flag = 'N' AND
               mr_interval_rec.start_value IS NOT NULL AND
               p_dependent_mr_flag = FALSE) THEN
             IF (l_mr_interval_rec.earliest_due_value IS NOT NULL) THEN
                IF (l_counter_value < l_mr_interval_rec.earliest_due_value) THEN
                  l_due_at_counter_value := l_mr_interval_rec.start_value;
                  l_reset_start_value_flag := TRUE;
                END IF;
             END IF;
           -- fix for bug#6711228(issue described in problem#2).
           -- l_counter_value for this case contains the counter value as of
           -- preceding MR's due date so we need to handle this seperately.
           ELSIF (p_repetivity_flag = 'N' AND p_dependent_mr_flag = TRUE AND
                  mr_interval_rec.start_value IS NOT NULL) THEN
                  -- Added for ER 7415856
                  -- if rule code is set as INTERVAL
                  IF (l_mr_interval_rec.calc_duedate_rule_code = 'INTERVAL') THEN
                      l_due_at_counter_value := l_mr_interval_rec.start_value + l_mr_interval_rec.interval_value;
                      l_reset_start_value_flag := TRUE;
                  ELSE
                      l_due_at_counter_value := l_mr_interval_rec.start_value;
                      l_reset_start_value_flag := TRUE;
                  END IF;
           ELSE
             -- Check if due counter less than start value or start date. If yes, set it
             -- to start value.
             IF (l_mr_interval_rec.start_value IS NOT NULL) THEN
               IF (l_counter_value < l_mr_interval_rec.start_value) THEN
                 -- Added for ER 7415856
                 -- if rule code is set as INTERVAL then add interval to due counter value.
                 IF (l_mr_interval_rec.calc_duedate_rule_code = 'INTERVAL') THEN
                     l_due_at_counter_value := l_mr_interval_rec.start_value + l_mr_interval_rec.interval_value;
                     l_reset_start_value_flag := TRUE;
                 ELSE
                   l_due_at_counter_value := l_mr_interval_rec.start_value;
                   l_reset_start_value_flag := TRUE;
                 END IF;
               END IF;
             END IF;
           END IF;

           -- Added for bug# 6358940(start_date).
           IF (p_repetivity_flag = 'N') AND (mr_interval_rec.start_date IS NOT NULL) THEN
             IF (p_last_due_date IS NOT NULL AND p_dependent_mr_flag = FALSE) THEN
                -- MR accomplished
                IF (mr_interval_rec.earliest_due_value IS NOT NULL) THEN
                  IF (l_counter_value < mr_interval_rec.earliest_due_value) THEN
                    l_due_date := mr_interval_rec.start_date;
                    l_reset_start_date_flag := TRUE;
                  END IF;
                END IF;
             ELSE  -- no accomplishment. first time MR must be done on start date.
                l_due_date := mr_interval_rec.start_date;
                l_reset_start_date_flag := TRUE;
             END IF;

             -- calculate due counter value.
             IF (l_reset_start_date_flag) THEN
               IF (l_due_date < trunc(sysdate)) THEN
                 get_ctr_reading_for_date (p_csi_item_instance_id => p_applicable_mrs_rec.csi_item_instance_id,
                                           p_counter_id           => l_temp_counter_tbl(i).counter_id,
                                           p_reading_date         => l_due_date,
                                           x_net_reading          => l_due_at_counter_value);

               ELSIF (l_due_date = trunc(sysdate)) THEN
                  -- current counter value.
                  l_due_at_counter_value := l_temp_counter_tbl(i).counter_value;
               ELSE
                  -- calculate due counter value.
                  l_last_due_counter_tbl(1) := l_temp_counter_tbl(i); -- current ctr

                  -- before the due counter value.
                  Get_Due_At_Counter_Values (p_last_due_date => p_last_due_date,
                                             p_last_due_counter_val_tbl => l_last_due_counter_tbl,
                                             p_due_date => l_due_date,
                                             p_counter_rules_tbl => p_counter_rules_tbl,
                                             x_due_at_counter_val_tbl => l_due_counter_tbl,
                                             x_return_value  => l_return_val);

                  -- if forecast not setup, cannot calculate due counter value for
                  -- start date.
                  IF NOT(l_return_val) THEN
                    l_due_date := NULL;
                    RAISE DUE_DATE_NULL;
                  ELSE
                    l_due_at_counter_value := l_due_counter_tbl(1).counter_value;
                  END IF;

               END IF; -- l_due_date < trunc(sysdate)

               -- Added for ER 7415856
               IF (l_mr_interval_rec.calc_duedate_rule_code = 'INTERVAL') THEN
                     l_due_at_counter_value := l_due_at_counter_value + l_mr_interval_rec.interval_value;
                     l_reset_start_date_flag := FALSE; -- need to calculate new due date.
               END IF;
             END IF; -- (l_reset_start_date_flag)

           END IF; -- p_repetivity_flag = 'N') AND ..

           --dbms_output.put_line ('due at counter' || l_due_at_counter_value );

           -- Check for interval value overflow.
           IF (mr_interval_rec.stop_value IS NOT NULL) THEN
             --IF (l_due_at_counter_value  >= mr_interval_rec.stop_value) THEN
             -- Fix for bug# 3482307.
             IF (l_due_at_counter_value  > mr_interval_rec.stop_value) THEN

                Adjust_Interval_Value (p_mr_effectivity_id => effectivity_rec.mr_effectivity_id,
                                       p_counter_id        => l_temp_counter_tbl(i).counter_id,
                                       p_counter_value     => l_counter_value,
                                       p_interval_value    => mr_interval_rec.interval_value,
                                       p_stop_value        => mr_interval_rec.stop_value,
                                       x_adjusted_int_value => l_adjusted_int_value,
                                       x_nxt_interval_found => l_nxt_interval_found);
                -- Fix for bug# 3461118.
                IF NOT(l_nxt_interval_found) THEN
                  IF (l_ctr_interval_found = TRUE AND l_old_ctr_interval_found = FALSE) THEN
                    l_ctr_interval_found := FALSE;
                  END IF;
                  GOTO next_mr_interval_loop;
                ELSE
                  l_due_at_counter_value := l_adjusted_int_value + l_counter_value;
                END IF;
             END IF;
           END IF;


           IF (p_repetivity_flag = 'N') THEN
             l_counter_remain := l_due_at_counter_value - l_current_ctr_value;
           ELSE
             l_counter_remain := l_due_at_counter_value - l_counter_value;
           END IF;

           --dbms_output.put_line ('counter remain' || l_counter_remain );

           IF G_DEBUG = 'Y' THEN
             AHL_DEBUG_PUB.Debug('due at counter_value:' || l_due_at_counter_value);
             AHL_DEBUG_PUB.Debug('counter remain:' || l_counter_remain);
           END IF;

           -- if due date already set based on start date then skip date calculation.
           IF NOT(l_reset_start_date_flag) THEN
             -- calculate due date based on forecast.
             IF (l_counter_remain > 0) THEN
                -- get date from forecast.
                get_date_from_uf(l_counter_remain,
                                 l_temp_counter_tbl(i).uom_code,
                                 p_counter_rules_tbl,
                                 l_start_date,
                                 --null, /* start date = sysdate */
                                 l_due_date);

                --dbms_output.put_line ('due date by forecast' || l_due_date );

             ELSIF (l_counter_remain < 0) THEN
               -- Due date = counter reading date.
               get_ctr_date_for_reading (p_csi_item_instance_id => p_applicable_mrs_rec.csi_item_instance_id,
                                         p_counter_id           => l_temp_counter_tbl(i).counter_id,
                                         p_counter_value        => l_due_at_counter_value,
                                         x_ctr_record_date      => l_counter_read_date,
                                         x_return_val           => l_return_val);

               IF NOT(l_return_val) THEN
                  l_due_date := sysdate;
               ELSE
                  l_due_date := l_counter_read_date;
               END IF;

             ELSIF (l_counter_remain = 0) THEN  /* due_date = sysdate */
               --dbms_output.put_line ('counter remain less than zero');
               l_due_date := sysdate;
             END IF;
           END IF; -- l_reset_start_date_flag

           /* commented out to fix bug# 6907562
           -- Check the due date value.
           IF (l_due_date IS NULL) THEN
              RAISE DUE_DATE_NULL;
           END IF;
           */

           -- Check Due date overflow to next interval.
           IF (mr_interval_rec.stop_date IS NOT NULL) THEN
              IF (l_due_date > mr_interval_rec.stop_date) THEN

                 -- Call procedure to adjust due date.
                 Adjust_Due_Date ( p_mr_effectivity_id => effectivity_rec.mr_effectivity_id,
                                   p_start_counter_rec => l_temp_counter_tbl(i),
                                   p_start_due_date    => p_last_due_date,
                                   p_counter_rules_tbl => p_counter_rules_tbl,
                                   p_interval_value    => mr_interval_rec.interval_value,
                                   p_stop_date         => mr_interval_rec.stop_date,
                                   p_due_date          => l_due_date,
                                   x_adjusted_due_date => l_adjusted_due_date,
                                   x_adjusted_due_ctr  => l_adjusted_due_ctr,
                                   x_nxt_interval_found => l_nxt_interval_found);

                 -- Fix for bug# 3461118.
                 IF NOT(l_nxt_interval_found) THEN
                   IF (l_ctr_interval_found = TRUE AND l_old_ctr_interval_found = FALSE) THEN
                     l_ctr_interval_found := FALSE;
                   END IF;
                   GOTO next_mr_interval_loop;
                 ELSE
                   IF (l_due_date <> l_adjusted_due_date) THEN
                     l_due_at_counter_value := l_adjusted_due_ctr + l_counter_value;
                   END IF;
                   l_due_date := l_adjusted_due_date;
                 END IF;
                 --dbms_output.put_line ('adjusted_due_date' || l_due_date );

              END IF;
           END IF;

           /* fix for bug# 6858788: this causes next repetity to be over
            * interval value
           -- Call Get_Due_At_Counter_Values only if due date is a future date.
           IF (l_reset_start_value_flag) AND (trunc(l_due_date) > trunc(sysdate)) THEN
              -- Check if the counter value on the due date is less than the due counter value.
              -- If less, add a day to the due date. This would ensure that the MR is performed not
              -- before due date.
              l_last_due_counter_tbl(1) := l_temp_counter_tbl(i);

              -- before the due counter value.
              Get_Due_At_Counter_Values (p_last_due_date => p_last_due_date,
                                         p_last_due_counter_val_tbl => l_last_due_counter_tbl,
                                         p_due_date => l_due_date,
                                         p_counter_rules_tbl => p_counter_rules_tbl,
                                         x_due_at_counter_val_tbl => l_due_counter_tbl,
                                         x_return_value  => l_return_val);

              IF (l_return_val) THEN
                IF (l_due_counter_tbl(1).counter_value < l_due_at_counter_value) THEN
                   l_due_date := l_due_date + 1;
                END IF;
              END IF;

           END IF;
           */
           -- Compare with whichever first code and set l_calc_due_date.
           -- logic modified to fix bug# 6907562. Here l_due_date can be null.
           IF (l_due_date IS NULL) THEN
               -- Added to fix bug# 6907562.
               IF (validate_for_duedate_reset(l_due_date,
                                              l_counter_remain,
                                              l_calc_due_date,
                                              l_calc_due_date_ctr_id,
                                              x_next_due_date_rec.counter_remain)) = 'Y' THEN
                   --dbms_output.put_line ('due date is null');
                   l_calc_due_date := l_due_date;
                   x_next_due_date_rec.due_date := l_due_date;
                   x_next_due_date_rec.tolerance_after := l_mr_interval_rec.tolerance_after;
                   x_next_due_date_rec.tolerance_before := l_mr_interval_rec.tolerance_before;
                   x_next_due_date_rec.mr_interval_id := l_mr_interval_rec.mr_interval_id;
                   x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
                   x_next_due_date_rec.mr_effectivity_id := effectivity_rec.mr_effectivity_id;
                   x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                   x_next_due_date_rec.last_ctr_value := l_counter_value;
                   x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(i).uom_code;
                   x_next_due_date_rec.counter_id := null;
                   x_next_due_date_rec.counter_remain := l_counter_remain;
                   l_calc_due_date_ctr_id := l_temp_counter_tbl(i).counter_id;
               END IF;
           ELSE  -- due date is not null
               IF (l_calc_due_date IS NULL) THEN
                   -- Added to fix bug# 6907562.
                   IF (validate_for_duedate_reset(l_due_date,
                                                  l_counter_remain,
                                                  l_calc_due_date,
                                                  l_calc_due_date_ctr_id,
                                                  x_next_due_date_rec.counter_remain)) = 'Y' THEN

                     --dbms_output.put_line ('calc due date is null');
                     l_calc_due_date := l_due_date;
                     x_next_due_date_rec.due_date := l_due_date;
                     x_next_due_date_rec.tolerance_after := l_mr_interval_rec.tolerance_after;
                     x_next_due_date_rec.tolerance_before := l_mr_interval_rec.tolerance_before;
                     x_next_due_date_rec.mr_interval_id := l_mr_interval_rec.mr_interval_id;
                     x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
                     x_next_due_date_rec.mr_effectivity_id := effectivity_rec.mr_effectivity_id;
                     x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                     x_next_due_date_rec.last_ctr_value := l_counter_value;
                     x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(i).uom_code;
                     x_next_due_date_rec.counter_id := null;
                     x_next_due_date_rec.counter_remain := l_counter_remain;
                     l_calc_due_date_ctr_id := l_temp_counter_tbl(i).counter_id;
                   END IF;
               ELSE
                   IF (p_applicable_mrs_rec.whichever_first_code = 'FIRST') THEN
                     -- dbms_output.put_line ('applicable mr which code = first');
                     -- Check due date based on whichever_first_code.
                     -- if dates are equal, switch based on lower uom remain value. (bug# 6907562).
                     IF (l_calc_due_date > l_due_date) OR
                       (trunc(l_calc_due_date) = trunc(l_due_date) AND l_counter_remain IS NOT NULL
                        AND x_next_due_date_rec.counter_remain IS NOT NULL
                        AND l_counter_remain < x_next_due_date_rec.counter_remain) THEN

                        --dbms_output.put_line ('calc_due_date > l_due date');
                        l_calc_due_date := l_due_date;
                        x_next_due_date_rec.due_date := l_due_date;
                        x_next_due_date_rec.tolerance_after := l_mr_interval_rec.tolerance_after;
                        x_next_due_date_rec.tolerance_before := l_mr_interval_rec.tolerance_before;
                        x_next_due_date_rec.mr_interval_id := l_mr_interval_rec.mr_interval_id;
                        x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
                        x_next_due_date_rec.mr_effectivity_id := effectivity_rec.mr_effectivity_id;
                        x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                        x_next_due_date_rec.last_ctr_value := l_counter_value;
                        x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(i).uom_code;
                        x_next_due_date_rec.counter_id := null;
                        x_next_due_date_rec.counter_remain := l_counter_remain;
                        l_calc_due_date_ctr_id := l_temp_counter_tbl(i).counter_id;
                     END IF;
                   ELSE  /* whichever_first_code = 'LAST' */
                     --dbms_output.put_line ('applicable mr which code = last');
                     -- if dates are equal, switch based on higher uom remain value. (bug# 6907562).
                     IF (l_calc_due_date < l_due_date) OR
                        (trunc(l_calc_due_date) = trunc(l_due_date) AND l_counter_remain IS NOT NULL
                        AND x_next_due_date_rec.counter_remain IS NOT NULL
                        AND l_counter_remain > x_next_due_date_rec.counter_remain) THEN

                        --dbms_output.put_line ('calc_due_date < l_due date');
                        l_calc_due_date := l_due_date;
                        x_next_due_date_rec.due_date := l_due_date;
                        x_next_due_date_rec.tolerance_after := l_mr_interval_rec.tolerance_after;
                        x_next_due_date_rec.tolerance_before := l_mr_interval_rec.tolerance_before;
                        x_next_due_date_rec.mr_interval_id := l_mr_interval_rec.mr_interval_id;
                        x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
                        x_next_due_date_rec.mr_effectivity_id := effectivity_rec.mr_effectivity_id;
                        x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                        x_next_due_date_rec.last_ctr_value := l_counter_value;
                        x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(i).uom_code;
                        x_next_due_date_rec.counter_id := null;
                        x_next_due_date_rec.counter_remain := l_counter_remain;
                        l_calc_due_date_ctr_id := l_temp_counter_tbl(i).counter_id;
                     END IF;
                   END IF;
               END IF; /* calc_due_date null */
               --dbms_output.put_line ('Next mr interval');
           END IF; -- due date is null.

           IF G_DEBUG = 'Y' THEN
             AHL_DEBUG_PUB.Debug('Before Next interval table loop');
             AHL_DEBUG_PUB.Debug('l_due_date:' || l_due_date );
             AHL_DEBUG_PUB.Debug('l_calc_due_date:' || l_calc_due_date);
             AHL_DEBUG_PUB.Debug('l_calc_due_date_ctr_id:' || l_calc_due_date_ctr_id);
           END IF;

           -- Fix for bug# 3461118.
           <<next_mr_interval_loop>>
           NULL;
         END LOOP; /* mr_interval_rec */

         -- If no interval found, then check if future intervals exist
         -- and calculate date based on that interval.
         -- Added p_mr_accomplish_exists and p_last_due_mr_interval_id to fix bug# 6858788.
         -- Commented p_last_accomplishment_date and will instead use p_mr_accomplish_exists.
         IF NOT(l_ctr_interval_found) THEN
           Get_DueDate_from_NxtInterval (p_applicable_mrs_rec => p_applicable_mrs_rec,
                                         p_repetivity_flag    => p_repetivity_flag,
                                         p_mr_effectivity_id => effectivity_rec.mr_effectivity_id,
                                         p_current_ctr_rec   => l_temp_counter_tbl(i),
                                         p_counter_rules_tbl => p_counter_rules_tbl,
                                         p_current_ctr_at_date => l_start_date,
                                         p_start_int_match_at_ctr => l_start_int_match_at_ctr,
                                         p_last_accomplish_ctr_val => l_counter_value,
                                         --p_last_accomplishment_date => p_last_due_date,
                                         p_dependent_mr_flag => p_dependent_mr_flag,
                                         p_mr_accomplish_exists => p_mr_accomplish_exists,
                                         p_last_due_mr_interval_id => p_last_due_mr_interval_id,
                                         x_next_due_date_rec => l_next_due_date_rec,
                                                                --x_next_due_date_rec,
                                         x_mr_interval_found => l_ctr_interval_found,
                                         x_return_val        => l_return_val);
           IF (l_ctr_interval_found) THEN
             IF NOT(l_return_val) THEN
               RAISE DUE_DATE_NULL; -- forecast not available hence uom remain is not known.
             END IF;

             IF (l_next_due_date_rec.due_date IS NOT NULL) THEN
                IF (l_calc_due_date IS NULL) THEN
                   -- Added to fix bug# 6907562.
                   IF (validate_for_duedate_reset(l_next_due_date_rec.due_date,
                                                  l_next_due_date_rec.counter_remain,
                                                  l_calc_due_date,
                                                  l_calc_due_date_ctr_id,
                                                  x_next_due_date_rec.counter_remain)) = 'Y' THEN

                      x_next_due_date_rec := l_next_due_date_rec;
                      l_calc_due_date := x_next_due_date_rec.due_date;
                      x_next_due_date_rec.mr_effectivity_id := effectivity_rec.mr_effectivity_id;
                      x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                      x_next_due_date_rec.last_ctr_value := l_counter_value;
                      x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(i).uom_code;
                      x_next_due_date_rec.counter_id := null;
                      l_calc_due_date_ctr_id := l_temp_counter_tbl(i).counter_id;
                   END IF; -- validate_for_duedate_reset

                ELSIF (p_applicable_mrs_rec.whichever_first_code = 'FIRST') THEN
                  -- if dates are equal, switch based on lower uom remain value. (bug# 6907562).
                  IF (l_calc_due_date > l_next_due_date_rec.due_date) OR
                     (trunc(l_calc_due_date) = trunc(l_next_due_date_rec.due_date)
                     AND l_next_due_date_rec.counter_remain IS NOT NULL
                     AND x_next_due_date_rec.counter_remain IS NOT NULL
                     AND l_next_due_date_rec.counter_remain < x_next_due_date_rec.counter_remain) THEN

                      x_next_due_date_rec := l_next_due_date_rec;
                      l_calc_due_date := x_next_due_date_rec.due_date;
                      x_next_due_date_rec.mr_effectivity_id := effectivity_rec.mr_effectivity_id;
                      x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                      x_next_due_date_rec.last_ctr_value := l_counter_value;
                      x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(i).uom_code;
                      x_next_due_date_rec.counter_id := null;
                      l_calc_due_date_ctr_id := l_temp_counter_tbl(i).counter_id;
                  END IF;
                ELSIF (p_applicable_mrs_rec.whichever_first_code = 'LAST') THEN
                   -- if dates are equal, switch based on higher uom remain value. (bug# 6907562).
                   IF (l_calc_due_date < l_next_due_date_rec.due_date) OR
                      (trunc(l_calc_due_date) = trunc(l_next_due_date_rec.due_date)
                        AND l_next_due_date_rec.counter_remain IS NOT NULL
                        AND x_next_due_date_rec.counter_remain IS NOT NULL
                        AND l_next_due_date_rec.counter_remain > x_next_due_date_rec.counter_remain) THEN
                       x_next_due_date_rec := l_next_due_date_rec;
                       l_calc_due_date := x_next_due_date_rec.due_date;
                       x_next_due_date_rec.mr_effectivity_id := effectivity_rec.mr_effectivity_id;
                       x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                       x_next_due_date_rec.last_ctr_value := l_counter_value;
                       x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(i).uom_code;
                       x_next_due_date_rec.counter_id := null;
                       l_calc_due_date_ctr_id := l_temp_counter_tbl(i).counter_id;
                  END IF;
                END IF; -- l_calc_due_date IS NULL
             -- else added to fix bug# 6907562.
             ELSE -- due date is null.
               -- Added to fix bug# 6907562.
               IF (validate_for_duedate_reset(l_next_due_date_rec.due_date,
                                              l_next_due_date_rec.counter_remain,
                                              l_calc_due_date,
                                              l_calc_due_date_ctr_id,
                                              x_next_due_date_rec.counter_remain)) = 'Y' THEN
                    x_next_due_date_rec := l_next_due_date_rec;
                    l_calc_due_date := x_next_due_date_rec.due_date;
                    x_next_due_date_rec.mr_effectivity_id := effectivity_rec.mr_effectivity_id;
                    x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                    x_next_due_date_rec.last_ctr_value := l_counter_value;
                    x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(i).uom_code;
                    x_next_due_date_rec.counter_id := null;
                    l_calc_due_date_ctr_id := l_temp_counter_tbl(i).counter_id;

               END IF; -- validate_for_duedate_reset
             END IF; -- x_next_due_date_rec.due_date IS NOT NULL
           END IF; -- l_ctr_interval_found.
         END IF; -- NOT(l_ctr_interval_found)

         -- added to fix bug# 6725769.
         IF NOT(l_mr_interval_found) THEN
            IF (l_ctr_interval_found) THEN
                l_mr_interval_found := TRUE;
            END IF;
         END IF;
         --dbms_output.put_line ('next counter');

         <<next_counter_loop>>
         NULL;
       END LOOP; /* temp_counter_tbl */
     END IF; /* count > 0 */

     -- Check due date with threshold date.
     -- If threshold date exists, then the MR is not repetitive.
     IF (effectivity_rec.threshold_date IS NOT NULL) AND (p_repetivity_flag = 'N') AND
        ( (l_calc_due_date IS NOT NULL AND l_mr_interval_found = TRUE) OR  /* case of due date is not null for an interval id */
          (l_mr_interval_found = FALSE) ) /* case of no intervals defined for an effectivity */
        THEN
         --dbms_output.put_line ('in threshold');
         IF (l_calc_due_date IS NULL) THEN
             l_calc_due_date := effectivity_rec.threshold_date;
             x_next_due_date_rec.due_date := effectivity_rec.threshold_date;
             x_next_due_date_rec.tolerance_after := null;
             x_next_due_date_rec.tolerance_before := null;
             x_next_due_date_rec.mr_interval_id := null;
             x_next_due_date_rec.mr_effectivity_id := effectivity_rec.mr_effectivity_id;
             x_next_due_date_rec.due_at_counter_value := null;
             x_next_due_date_rec.current_ctr_value := null;
             x_next_due_date_rec.last_ctr_value := null;
             x_next_due_date_rec.ctr_uom_code := null;
             x_next_due_date_rec.counter_id := null;
             x_next_due_date_rec.counter_remain := null;
             l_calc_due_date_ctr_id := null;
         ELSIF (p_applicable_mrs_rec.whichever_first_code = 'FIRST') THEN
             IF (l_calc_due_date > effectivity_rec.threshold_date) THEN
                  l_calc_due_date := effectivity_rec.threshold_date;
                  x_next_due_date_rec.due_date := effectivity_rec.threshold_date;
                  x_next_due_date_rec.tolerance_after := null;
                  x_next_due_date_rec.tolerance_before := null;
                  x_next_due_date_rec.mr_interval_id := null;
                  x_next_due_date_rec.mr_effectivity_id := effectivity_rec.mr_effectivity_id;
                  x_next_due_date_rec.due_at_counter_value := null;
                  x_next_due_date_rec.current_ctr_value := null;
                  x_next_due_date_rec.last_ctr_value := null;
                  x_next_due_date_rec.ctr_uom_code := null;
                  x_next_due_date_rec.counter_id := null;
                  x_next_due_date_rec.counter_remain := null;
                  l_calc_due_date_ctr_id := null;

              END IF;
         ELSIF (p_applicable_mrs_rec.whichever_first_code = 'LAST') THEN
           /* whichever_first_code = 'LAST' */
            IF (l_calc_due_date < effectivity_rec.threshold_date) THEN
                  l_calc_due_date := effectivity_rec.threshold_date;
                  x_next_due_date_rec.due_date := effectivity_rec.threshold_date;
                  x_next_due_date_rec.tolerance_after := null;
                  x_next_due_date_rec.tolerance_before := null;
                  x_next_due_date_rec.mr_interval_id := null;
                  x_next_due_date_rec.due_at_counter_value := null;
                  x_next_due_date_rec.mr_effectivity_id := effectivity_rec.mr_effectivity_id;
                  x_next_due_date_rec.current_ctr_value := null;
                  x_next_due_date_rec.last_ctr_value := null;
                  x_next_due_date_rec.ctr_uom_code := null;
                  x_next_due_date_rec.counter_id := null;
                  x_next_due_date_rec.counter_remain := null;
                  l_calc_due_date_ctr_id := null;

            END IF;
         END IF; /* whichever_first_code */
      END IF; /* threshold_date not null */

      --dbms_output.put_line ('NEXT effectivity');
  END LOOP mr_effectivity_loop; /* effectivity_rec */

  -- Fix for bug# 6358940. Due Date should be based only on init-due if it
  -- exists. MR thresholds should not be used.
  -- Moved below logic to the beginning of the this procedure before processing
  -- effectivities.
  -- Calculate due date based on init-due defination; if exists.
  /*
  IF (p_repetivity_flag = 'N') THEN
     --dbms_output.put_line ('in INIT-due part');

     -- Check if there is any init-due record for this item instance and mr exists.
     OPEN ahl_init_due_csr(p_applicable_mrs_rec.csi_item_instance_id,
                           p_applicable_mrs_rec.mr_header_id);
     FETCH ahl_init_due_csr INTO l_set_due_date, l_unit_effectivity_id, l_unit_deferral_id;
     IF (ahl_init_due_csr%FOUND) THEN

        --dbms_output.put_line ('in INIT-due part: due_date' || l_set_due_date);

        FOR threshold_rec IN ahl_unit_thresholds_csr (l_unit_deferral_id)
        LOOP
          -- for init due, ctr_value_type_code is always 'defer_to'.
          l_due_at_counter_value := threshold_rec.counter_value;
          l_counter_remain := 0;
          l_current_ctr_value := 0;
          k := 0;
          -- search for the current counter value in l_current_usage_tbl.
          IF (l_temp_counter_tbl.COUNT > 0) THEN
            FOR i IN l_temp_counter_tbl.FIRST..l_temp_counter_tbl.LAST LOOP
               IF (l_temp_counter_tbl(i).counter_id = threshold_rec.counter_id) THEN
                  l_current_ctr_value := l_temp_counter_tbl(i).counter_value;
                  k := i;
                  EXIT;
               END IF;
            END LOOP;
            l_counter_remain := l_due_at_counter_value - l_current_ctr_value;
          END IF;

          -- calculate due date from forecast.
          IF (l_counter_remain > 0) THEN
            -- get date from forecast.
            get_date_from_uf(l_counter_remain,
                             l_temp_counter_tbl(k).uom_code,
                             p_counter_rules_tbl,
                             null, -- start date = sysdate
                             l_due_date);
          ELSIF (l_counter_remain < 0) THEN
            -- Due date = counter reading date.
             get_ctr_date_for_reading (p_csi_item_instance_id => p_applicable_mrs_rec.csi_item_instance_id,
                                       p_counter_id           => l_temp_counter_tbl(k).counter_id,
                                       p_counter_value        => l_due_at_counter_value,
                                       x_ctr_record_date      => l_counter_read_date,
                                       x_return_val           => l_return_val);

             IF NOT(l_return_val) THEN
                l_due_date := sysdate;
             ELSE
                l_due_date := l_counter_read_date;
             END IF;

          ELSIF (l_counter_remain = 0) THEN  -- due_date = sysdate
            --dbms_output.put_line ('counter remain less than zero');
            l_due_date := sysdate;
          END IF;

          IF (l_calc_due_date IS NOT NULL AND l_mr_interval_found = TRUE) OR  -- case where intervals exist.
             (l_mr_interval_found = FALSE)  THEN    -- case where no intervals.
            -- Compare with whichever first code and set l_calc_due_date.
            IF (l_due_date IS NULL) THEN
               --dbms_output.put_line ('due date null');
               l_calc_due_date := l_due_date;
               x_next_due_date_rec.due_date := null;
               x_next_due_date_rec.tolerance_after := null;
               x_next_due_date_rec.tolerance_before := null;
               x_next_due_date_rec.mr_interval_id := null;
               x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
               x_next_due_date_rec.mr_effectivity_id := null;
               x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
               x_next_due_date_rec.last_ctr_value := null;
               x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(k).uom_code;
               x_next_due_date_rec.counter_id := l_temp_counter_tbl(k).counter_id;
               x_next_due_date_rec.counter_remain := l_counter_remain;
               l_calc_due_date_ctr_id := l_temp_counter_tbl(k).counter_id;
               EXIT;
            ELSE  -- happens when no interval
              IF (l_calc_due_date IS NULL) THEN
                 --dbms_output.put_line ('calc due date null');
                 l_calc_due_date := l_due_date;
                 x_next_due_date_rec.due_date := l_due_date;
                 x_next_due_date_rec.tolerance_after := null;
                 x_next_due_date_rec.tolerance_before := null;
                 x_next_due_date_rec.mr_interval_id := null;
                 x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
                 x_next_due_date_rec.mr_effectivity_id := null;
                 x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                 x_next_due_date_rec.last_ctr_value := null;
                 x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(k).uom_code;
                 x_next_due_date_rec.counter_id := l_temp_counter_tbl(k).counter_id;
                 x_next_due_date_rec.counter_remain := l_counter_remain;
                 l_calc_due_date_ctr_id := l_temp_counter_tbl(k).counter_id;

              ELSE
                 IF (p_applicable_mrs_rec.whichever_first_code = 'FIRST') THEN
                    -- Check due date based on whichever_first_code.
                    IF (l_calc_due_date > l_due_date) THEN
                        l_calc_due_date := l_due_date;
                        x_next_due_date_rec.due_date := l_due_date;
                        x_next_due_date_rec.tolerance_after := null;
                        x_next_due_date_rec.tolerance_before := null;
                        x_next_due_date_rec.mr_interval_id := null;
                        x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
                        x_next_due_date_rec.mr_effectivity_id := null;
                        x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                        x_next_due_date_rec.last_ctr_value := null;
                        x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(k).uom_code;
                        x_next_due_date_rec.counter_id := l_temp_counter_tbl(k).counter_id;
                        x_next_due_date_rec.counter_remain := l_counter_remain;
                        l_calc_due_date_ctr_id := l_temp_counter_tbl(k).counter_id;

                    END IF;
                 ELSE  -- whichever_first_code = 'LAST'
                    IF (l_calc_due_date < l_due_date) THEN
                        --dbms_output.put_line ('set due date');
                        l_calc_due_date := l_due_date;
                        x_next_due_date_rec.due_date := l_due_date;
                        x_next_due_date_rec.tolerance_after := null;
                        x_next_due_date_rec.tolerance_before := null;
                        x_next_due_date_rec.mr_interval_id := null;
                        x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
                        x_next_due_date_rec.mr_effectivity_id := null;
                        x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
                        x_next_due_date_rec.last_ctr_value := null;
                        x_next_due_date_rec.ctr_uom_code := l_temp_counter_tbl(k).uom_code;
                        x_next_due_date_rec.counter_id := l_temp_counter_tbl(k).counter_id;
                        x_next_due_date_rec.counter_remain := l_counter_remain;
                        l_calc_due_date_ctr_id := l_temp_counter_tbl(k).counter_id;

                    END IF;
                 END IF; -- applicable_mrs_rec
              END IF; -- calc_due_date null
            END IF;
          END IF; -- calc due date and l_mr_interval_found.
        END LOOP; -- set_threshold_rec

        -- Check for set due date.
        IF (l_set_due_date IS NOT NULL) THEN
           IF (l_calc_due_date IS NOT NULL AND l_mr_interval_found = TRUE) OR  -- case where intervals exist.
              (l_mr_interval_found = FALSE)  THEN    -- case where no intervals.

              IF (l_calc_due_date IS NULL) THEN
                 l_calc_due_date := l_set_due_date;
                 x_next_due_date_rec.due_date := l_set_due_date;
                 x_next_due_date_rec.tolerance_after := null;
                 x_next_due_date_rec.tolerance_before := null;
                 x_next_due_date_rec.mr_effectivity_id := null;
                 x_next_due_date_rec.due_at_counter_value := null;
                 x_next_due_date_rec.current_ctr_value := null;
                 x_next_due_date_rec.last_ctr_value := null;
                 x_next_due_date_rec.mr_interval_id := null;
                 x_next_due_date_rec.ctr_uom_code := null;
                 x_next_due_date_rec.counter_id := null;
                 x_next_due_date_rec.counter_remain := null;
                 l_calc_due_date_ctr_id := null;

              ELSE
                 IF (p_applicable_mrs_rec.whichever_first_code = 'FIRST') THEN
                     IF (l_calc_due_date > l_set_due_date) THEN
                       --dbms_output.put_line ('set due da te');
                       l_calc_due_date := l_set_due_date;
                       x_next_due_date_rec.due_date := l_set_due_date;
                       x_next_due_date_rec.tolerance_after := null;
                       x_next_due_date_rec.tolerance_before := null;
                       x_next_due_date_rec.mr_interval_id := null;
                       x_next_due_date_rec.due_at_counter_value := null;
                       x_next_due_date_rec.mr_effectivity_id := null;
                       x_next_due_date_rec.current_ctr_value := null;
                       x_next_due_date_rec.last_ctr_value := null;
                       x_next_due_date_rec.ctr_uom_code := null;
                       x_next_due_date_rec.counter_id := null;
                       x_next_due_date_rec.counter_remain := null;
                       l_calc_due_date_ctr_id := null;

                     END IF;
                 ELSE
                    -- Check for set due date.
                    IF (l_calc_due_date < l_set_due_date) THEN
                        l_calc_due_date := l_set_due_date;
                        x_next_due_date_rec.due_date := l_set_due_date;
                        x_next_due_date_rec.tolerance_after := null;
                        x_next_due_date_rec.tolerance_before := null;
                        x_next_due_date_rec.mr_interval_id := null;
                        x_next_due_date_rec.due_at_counter_value := null;
                        x_next_due_date_rec.mr_effectivity_id := null;
                        x_next_due_date_rec.current_ctr_value := null;
                        x_next_due_date_rec.last_ctr_value := null;
                        x_next_due_date_rec.ctr_uom_code := null;
                        x_next_due_date_rec.counter_id := null;
                        x_next_due_date_rec.counter_remain := null;
                        l_calc_due_date_ctr_id := null;

                    END IF;
                 END IF; -- applicable
               END IF;
            END IF;
         END IF;  -- set due date
     END IF; -- init_due_csr
     CLOSE ahl_init_due_csr;
  END IF; -- repetitive_flag
  */
  -- After processing all effectivities, check if any interval got triggered.
  -- If not, set all values to null and exit procedure.
  IF (x_next_due_date_rec.mr_effectivity_id IS NULL) AND
     (x_next_due_date_rec.mr_interval_id IS NULL) AND (l_calc_due_date IS NULL) AND
     (x_next_due_date_rec.counter_id IS NULL) THEN
      RAISE NO_VALID_INTERVAL;
  END IF;

  -- Evaluate tolerance condition.
  IF (x_next_due_date_rec.mr_interval_id IS NOT NULL) THEN
     IF ((x_next_due_date_rec.due_at_counter_value +
         x_next_due_date_rec.tolerance_after) < x_next_due_date_rec.current_ctr_value) THEN
         x_next_due_date_rec.tolerance_flag := 'Y';
         x_next_due_date_rec.message_code := 'TOLERANCE-EXCEEDED';
     END IF;

     -- Added for ER#2636001.
     -- Calculate earliest due date.
     IF x_next_due_date_rec.tolerance_before IS NOT NULL THEN
       -- Not required: If due date is today's date then earliest due = due date.
       IF (x_next_due_date_rec.due_date IS NOT NULL) THEN
          --IF (trunc(x_next_due_date_rec.due_date) = trunc(sysdate)) THEN
          --    x_next_due_date_rec.earliest_due_date := x_next_due_date_rec.due_date;
          --ELSE
            -- find the left over counter value
            IF (p_repetivity_flag = 'N') THEN
              l_counter_remain := (x_next_due_date_rec.due_at_counter_value -
                                   x_next_due_date_rec.tolerance_before) -
                                   x_next_due_date_rec.current_ctr_value;
            ELSE
              l_counter_remain := (x_next_due_date_rec.due_at_counter_value -
                                   x_next_due_date_rec.tolerance_before) -
                                   x_next_due_date_rec.last_ctr_value;
            END IF;

            IF (l_counter_remain < 0) THEN
               -- Due date = counter reading date.
               get_ctr_date_for_reading (p_csi_item_instance_id => p_applicable_mrs_rec.csi_item_instance_id,
                                         p_counter_id           => l_calc_due_date_ctr_id,
                                         p_counter_value        => x_next_due_date_rec.due_at_counter_value -
                                                                   x_next_due_date_rec.tolerance_before,
                                         x_ctr_record_date      => l_counter_read_date,
                                         x_return_val           => l_return_val);
               IF NOT(l_return_val) THEN
                  x_next_due_date_rec.earliest_due_date := null;
               ELSE
                  x_next_due_date_rec.earliest_due_date := l_counter_read_date;
               END IF;
               -- if earliest_due_date > due date (when no counters readings exist before counter remain).
               IF (x_next_due_date_rec.earliest_due_date > x_next_due_date_rec.due_date) THEN
                   x_next_due_date_rec.earliest_due_date := x_next_due_date_rec.due_date;
               END IF;

            ELSE /* counter_remain > 0 */
               -- get date from forecast.
               get_date_from_uf(l_counter_remain,
                                x_next_due_date_rec.ctr_uom_code,
                                p_counter_rules_tbl,
                                l_start_date,
                                x_next_due_date_rec.earliest_due_date);
               --IF (trunc(x_next_due_date_rec.earliest_due_date) < trunc(sysdate)) THEN
               -- x_next_due_date_rec.earliest_due_date := sysdate;
               --END IF;
            END IF; -- counter_remain.
         --END IF; -- due_date = sysdate.
       END IF; -- due date is not null.
     END IF; -- tolerance before.

     IF (x_next_due_date_rec.tolerance_after) IS NOT NULL THEN
       -- Calculate counter remain.
       IF (p_repetivity_flag = 'N') THEN
         l_counter_remain := (x_next_due_date_rec.due_at_counter_value +
                              x_next_due_date_rec.tolerance_after) -
                              x_next_due_date_rec.current_ctr_value;
       ELSE
         l_counter_remain := (x_next_due_date_rec.due_at_counter_value +
                              x_next_due_date_rec.tolerance_after) -
                              x_next_due_date_rec.last_ctr_value;
       END IF;

       IF (l_counter_remain < 0) THEN
          -- Due date = counter reading date.
          get_ctr_date_for_reading (p_csi_item_instance_id => p_applicable_mrs_rec.csi_item_instance_id,
                                    p_counter_id           => l_calc_due_date_ctr_id,
                                    p_counter_value        => x_next_due_date_rec.due_at_counter_value +
                                                              x_next_due_date_rec.tolerance_after,
                                    x_ctr_record_date      => l_counter_read_date,
                                    x_return_val           => l_return_val);

          IF NOT(l_return_val) THEN
             x_next_due_date_rec.latest_due_date := null;
          ELSE
             x_next_due_date_rec.latest_due_date := l_counter_read_date;
          END IF;

       ELSE   /* counter_remain > 0 */
          -- Calculate latest tolerance.
          get_date_from_uf(x_next_due_date_rec.tolerance_after,
                           x_next_due_date_rec.ctr_uom_code,
                           p_counter_rules_tbl,
                           x_next_due_date_rec.due_date,
                           x_next_due_date_rec.latest_due_date);
       END IF; -- counter_remain.
     ELSE
        -- If due date is less than sysdate, then flag tolerance.
        IF (x_next_due_date_rec.due_date IS NOT NULL) AND
           (trunc(x_next_due_date_rec.due_date) < trunc(sysdate)) THEN
            x_next_due_date_rec.tolerance_flag := 'Y';
            x_next_due_date_rec.message_code := 'TOLERANCE-EXCEEDED';
        END IF;

     END IF;
     -- End of ER modifications.
  END IF;

  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('End calculate due date');
  END IF;


EXCEPTION
  WHEN DUE_DATE_NULL THEN
       x_next_due_date_rec.due_date := null;
       x_next_due_date_rec.tolerance_after := l_mr_interval_rec.tolerance_after;
       x_next_due_date_rec.tolerance_before := l_mr_interval_rec.tolerance_before;
       x_next_due_date_rec.mr_interval_id := l_mr_interval_rec.mr_interval_id;
       x_next_due_date_rec.due_at_counter_value := l_due_at_counter_value;
       x_next_due_date_rec.mr_effectivity_id := null;
       x_next_due_date_rec.current_ctr_value := l_current_ctr_value;
       x_next_due_date_rec.counter_remain := l_counter_remain;

  WHEN NO_VALID_INTERVAL THEN
       x_next_due_date_rec.due_date := null;
       x_next_due_date_rec.tolerance_after := null;
       x_next_due_date_rec.tolerance_before := null;
       x_next_due_date_rec.mr_interval_id := null;
       x_next_due_date_rec.due_at_counter_value := null;
       x_next_due_date_rec.mr_effectivity_id := null;
       x_next_due_date_rec.current_ctr_value := null;
       x_next_due_date_rec.counter_remain := null;

END Calculate_Due_Date;

-------------------------------------------------------------------------------------------
-- Calculate due at counter values for a given due due from last due date and last due counters using
-- counter rules and forecast (defined in global variable).

PROCEDURE Get_Due_At_Counter_Values ( p_last_due_date IN DATE,
                                      p_last_due_counter_val_tbl IN counter_values_tbl_type,
                                      p_due_date IN DATE,
                                      p_counter_rules_tbl IN counter_rules_tbl_type,
                                      x_due_at_counter_val_tbl OUT NOCOPY counter_values_tbl_type,
                                      x_return_value           OUT NOCOPY BOOLEAN)
IS

  l_diff_days  NUMBER := 0;
  l_counter_value NUMBER := 0;
  l_forecast_days NUMBER := 0;
  l_no_forecast BOOLEAN := FALSE;
  l_next_index NUMBER;
  l_start_date DATE;
  l_total_days_in_period NUMBER;

  l_index_found BOOLEAN;

BEGIN


  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('Start get_due_at_counter_values');
  END IF;

  -- Initialize return value.
  x_return_value := TRUE;

  -- find the difference between last due and due dates.
  l_diff_days := ABS(trunc(p_due_date) - trunc(p_last_due_date));
  --dbms_output.put_line ('l_diff_days'|| l_diff_days);

  IF (SIGN(p_due_date - p_last_due_date) = -1) THEN
     l_start_date := p_due_date;
  ELSE
     l_start_date := p_last_due_date;
  END IF;

  --dbms_output.put_line ('l_start_date' || l_start_date);
  --dbms_output.put_line ('count on last due ctr val' ||   p_last_due_counter_val_tbl.COUNT);

  -- Loop through last due counter tbl.
  IF (p_last_due_counter_val_tbl.COUNT > 0) THEN
    FOR i IN p_last_due_counter_val_tbl.FIRST..p_last_due_counter_val_tbl.LAST LOOP
      l_next_index := G_forecast_details_tbl.FIRST;
      -- set the starting index matching the start date and uom in forecast table.
      IF (l_next_index IS NULL) THEN
           l_no_forecast := TRUE;
      ELSE
        l_no_forecast := TRUE;
        FOR k IN G_forecast_details_tbl.FIRST..G_forecast_details_tbl.LAST LOOP
          IF (G_forecast_details_tbl(k).uom_code = p_last_due_counter_val_tbl(i).uom_code)
             AND (trunc(G_forecast_details_tbl(k).start_date) <= trunc(l_start_date)
             AND trunc(l_start_date) <= trunc(nvl(G_forecast_details_tbl(k).end_date,l_start_date)))
          THEN
             l_next_index := k;
             l_no_forecast := FALSE;
             EXIT;
          END IF;
        END LOOP;
      END IF;

      -- Based on counter uom_code, last_due_date, l_diff_days and G_forecast_details_tbl build counter value.
      WHILE (l_diff_days <> 0 AND l_no_forecast <> TRUE) LOOP
        IF (G_forecast_details_tbl(l_next_index).uom_code = p_last_due_counter_val_tbl(i).uom_code) THEN
           IF (trunc(G_forecast_details_tbl(l_next_index).start_date) <= trunc(l_start_date) AND
             trunc(nvl(G_forecast_details_tbl(l_next_index).end_date,l_start_date)) >= trunc(l_start_date)) THEN
             IF (G_forecast_details_tbl(l_next_index).end_date) IS NOT NULL THEN
               l_total_days_in_period := trunc(G_forecast_details_tbl(l_next_index).end_date - l_start_date) + 1;
               --dbms_output.put_line ('total days in period' || l_total_days_in_period);
               IF (l_total_days_in_period >= l_diff_days) THEN
                  l_counter_value := l_counter_value + trunc(l_diff_days * G_forecast_details_tbl(l_next_index).usage_per_day);
                  l_diff_days := 0;
                  --dbms_output.put_line ('total >= ldiff; ctr val' || l_counter_value );
               ELSE
                  l_diff_days := l_diff_days - l_total_days_in_period;
                  l_counter_value := l_counter_value + trunc(l_total_days_in_period * G_forecast_details_tbl(l_next_index).usage_per_day);
                  --dbms_output.put_line ('total < ldiff; ctr val' || l_counter_value );
                  -- Get next forecast record.
                  l_next_index := G_forecast_details_tbl.NEXT(l_next_index);
                  IF (l_next_index IS NULL) THEN
                    l_no_forecast := TRUE;
                  ELSE
                    l_start_date := G_forecast_details_tbl(l_next_index).START_DATE;
                  END IF;
               END IF; /* total days */
             ELSE
                l_counter_value := l_counter_value + trunc(l_diff_days * G_forecast_details_tbl(l_next_index).usage_per_day);
                l_diff_days := 0;
             END IF; /* end date */
           ELSE
             -- get next forecast record.
             l_next_index := G_forecast_details_tbl.NEXT(l_next_index);
             IF (l_next_index IS NULL) THEN
               l_no_forecast := TRUE;
             ELSE
               l_start_date := G_forecast_details_tbl(l_next_index).START_DATE;
             END IF;
           END IF; /* start date */
        ELSE
          l_next_index := G_forecast_details_tbl.NEXT(l_next_index);
          IF (l_next_index IS NULL) THEN
            l_no_forecast := TRUE;
          ELSE
            l_start_date := G_forecast_details_tbl(l_next_index).START_DATE;
          END IF;
        END IF; /* uom_code */
      END LOOP; /* while loop */

      IF (l_no_forecast = TRUE AND l_diff_days <> 0 ) THEN
        x_return_value := FALSE;
        EXIT;
      END IF;

      l_counter_value := Apply_ReverseCounter_Ratio ( l_counter_value,
                                                      p_last_due_counter_val_tbl(i).uom_code,
                                                      p_counter_rules_tbl);

      -- Add new counter values to return parameter.
      x_due_at_counter_val_tbl(i).counter_id := p_last_due_counter_val_tbl(i).counter_id;
      x_due_at_counter_val_tbl(i).counter_name := p_last_due_counter_val_tbl(i).counter_name;

      IF (SIGN(p_due_date - p_last_due_date) = -1) THEN
          l_counter_value := p_last_due_counter_val_tbl(i).counter_value - l_counter_value;
      ELSE
          l_counter_value := p_last_due_counter_val_tbl(i).counter_value + l_counter_value;
      END IF;

      x_due_at_counter_val_tbl(i).counter_value := l_counter_value;
      x_due_at_counter_val_tbl(i).uom_code := p_last_due_counter_val_tbl(i).uom_code;

      -- initialize start date.
      IF (SIGN(p_due_date - p_last_due_date) = -1) THEN
          l_start_date := p_due_date;
      ELSE
          l_start_date := p_last_due_date;
      END IF;
      -- Initialize counter value.
      l_counter_value := 0;

      l_diff_days := ABS(trunc(p_due_date) - trunc(p_last_due_date));

    END LOOP; /* for loop */
  END IF; /* count */

  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('End get_due_at_counter_values');
  END IF;

END Get_Due_At_Counter_Values;

---------------------------------------------------------------------------
-- Calculates the due date for the counter_remain from a given start date using forecast,
-- counter rules and counter uom.

PROCEDURE Get_Date_from_UF ( p_counter_remain IN NUMBER,
                             p_counter_uom_code IN VARCHAR2,
                             p_counter_rules_tbl IN counter_rules_tbl_type,
                             p_start_date IN DATE := NULL,
                             x_due_date         OUT NOCOPY DATE)
IS

  l_counter_remain NUMBER := p_counter_remain;
  l_forecast_days NUMBER := 0;
  l_no_forecast BOOLEAN := FALSE;
  l_total_days_in_period NUMBER := 0;
  l_index_found BOOLEAN;
  l_next_index NUMBER := 0;

  l_start_date DATE;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start get_date from UF');
     AHL_DEBUG_PUB.Debug('counter remain input to forecast' || p_counter_remain );
     AHL_DEBUG_PUB.Debug('counter uom' || p_counter_uom_code);
     AHL_DEBUG_PUB.Debug('Start date' || p_start_date);
  END IF;

  l_counter_remain := trunc(apply_counter_ratio (l_counter_remain,
                                                 p_counter_uom_code,
                                                 p_counter_rules_tbl));
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.DEBUG('counter remain after ctr_ratio' || l_counter_remain );
  END IF;

  -- Start date to begin calculation.
  IF (p_start_date IS NULL) THEN
    l_start_date := trunc(sysdate);
  ELSE
    l_start_date:= p_start_date;
  END IF;

  -- Read g_forecast_details_tbl to get forecast values.
  l_next_index := G_forecast_details_tbl.FIRST;
  IF (l_next_index IS NULL) THEN
    --dbms_output.put_line ('l_next_index is null');
    x_due_date := null;
    RETURN;
  ELSE
    l_no_forecast := TRUE;
    FOR i IN G_forecast_details_tbl.FIRST..G_forecast_details_tbl.LAST LOOP
      IF (G_forecast_details_tbl(i).uom_code = p_counter_uom_code) AND
         (trunc(G_forecast_details_tbl(i).start_date) <= trunc(l_start_date) AND
          trunc(l_start_date) <= trunc(nvl(G_forecast_details_tbl(i).end_date,l_start_date)))
      THEN
         l_next_index := i;
         l_no_forecast := FALSE;
         EXIT;
      END IF;
    END LOOP;
  END IF;

   --dbms_output.put_line ('counter remain input to forecast' || l_counter_remain );
   --dbms_output.put_line ('counter uom' ||p_counter_uom_code);

  -- Calculate due date.
  WHILE ((l_counter_remain <> 0) AND (l_no_forecast <> TRUE )) LOOP
     IF (G_forecast_details_tbl(l_next_index).uom_code = p_counter_uom_code) THEN
        IF (trunc(G_forecast_details_tbl(l_next_index).start_date) <= trunc(l_start_date) AND
            trunc(nvl(G_forecast_details_tbl(l_next_index).end_date,sysdate)) >= trunc(sysdate)) THEN

            IF (G_forecast_details_tbl(l_next_index).end_date) IS NOT NULL THEN
               l_total_days_in_period := trunc(G_forecast_details_tbl(l_next_index).end_date - l_start_date) + 1;

               IF (G_forecast_details_tbl(l_next_index).usage_per_day <> 0) THEN
                 IF (trunc(l_total_days_in_period * G_forecast_details_tbl(l_next_index).usage_per_day) >= l_counter_remain) THEN
                    l_forecast_days := l_forecast_days + trunc(l_counter_remain/G_forecast_details_tbl(l_next_index).usage_per_day);
                    l_counter_remain := 0;
                 ELSE
                    l_counter_remain := l_counter_remain - trunc(l_total_days_in_period * G_forecast_details_tbl(l_next_index).usage_per_day);
                    l_forecast_days := l_forecast_days + l_total_days_in_period;

                    -- Get next forecast record.
                    l_next_index := G_forecast_details_tbl.NEXT(l_next_index);
                    IF (l_next_index IS NULL) THEN
                      l_no_forecast := TRUE;
                    ELSE
                      l_start_date := G_forecast_details_tbl(l_next_index).START_DATE;
                    END IF;

                 END IF; /* total days */
               ELSE -- usage_per_day = 0
                 -- Get next forecast record.
                 l_next_index := G_forecast_details_tbl.NEXT(l_next_index);
                 IF (l_next_index IS NULL) THEN
                    l_no_forecast := TRUE;
                 ELSE
                    l_start_date := G_forecast_details_tbl(l_next_index).START_DATE;
                 END IF;
               END IF; -- usage_per_day <> 0
            ELSE
               IF (G_forecast_details_tbl(l_next_index).usage_per_day <> 0) THEN
                 l_forecast_days := l_forecast_days + trunc(l_counter_remain/G_forecast_details_tbl(l_next_index).usage_per_day);
                 l_counter_remain := 0;
               ELSE -- usage = 0
                 -- Get next forecast record.
                 l_next_index := G_forecast_details_tbl.NEXT(l_next_index);
                 IF (l_next_index IS NULL) THEN
                   l_no_forecast := TRUE;
                 ELSE
                   l_start_date := G_forecast_details_tbl(l_next_index).START_DATE;
                 END IF;
               END IF; -- usage_per_day <> 0
            END IF; /* end date */
        END IF; /* start date */
     ELSE
       l_next_index := G_forecast_details_tbl.NEXT(l_next_index);
       IF (l_next_index IS NULL) THEN
         l_no_forecast := TRUE;
       ELSE
         l_start_date := G_forecast_details_tbl(l_next_index).START_DATE;
       END IF;
     END IF; /* uom_code */

  END LOOP; /* while */

  IF (l_no_forecast = TRUE AND l_counter_remain <> 0) THEN
    x_due_date  := null;
  ELSE
    IF (p_start_date IS NULL) THEN
      -- Added condition to avoid due date > 31-dec-9999 when forecast
      -- is very less (like .00001, .000001 etc)
      IF (l_forecast_days > (to_date('31/12/9999','DD/MM/YYYY') - trunc(sysdate))) THEN
          x_due_date  := null;
      ELSE
          x_due_date := trunc(sysdate + l_forecast_days);
      END IF;
    ELSE
      -- Added condition to avoid due date > 31-dec-9999 when forecast
      -- is very less (like .00001, .000001 etc)
      IF (l_forecast_days > (to_date('31/12/9999','DD/MM/YYYY') - trunc(p_start_date))) THEN
          x_due_date  := null;
      ELSE
          x_due_date := trunc(p_start_date + l_forecast_days);
      END IF;
    END IF;
  END IF;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Date calculated by forecast:' || x_due_date);
     AHL_DEBUG_PUB.Debug('End Get_Date_from_UF');
  END IF;


END Get_Date_from_UF;

-------------------------------------------------------------------------------
-- This will return the adjusted interval value if the next due counter value
-- overlaps two intervals. It will be used where the overflow condition occurs
-- based on the interval's start value and stop value.

PROCEDURE Adjust_Interval_Value ( p_mr_effectivity_id IN NUMBER,
                                  p_counter_id IN NUMBER,
                                  p_counter_value IN NUMBER,
                                  p_interval_value IN NUMBER,
                                  p_stop_value IN NUMBER,
                                  x_adjusted_int_value OUT NOCOPY NUMBER,
                                  x_nxt_interval_found OUT NOCOPY BOOLEAN)
IS
  -- read intervals for the effectivity id.
  CURSOR ahl_mr_intervalvalue_csr (p_mr_effectivity_id IN NUMBER,
                                   p_counter_id  IN NUMBER,
                                   p_counter_value IN NUMBER) IS
     /*
	 SELECT INT.start_value, INT.stop_value,
            INT.interval_value
     FROM   ahl_mr_intervals INT, cs_counters_v CTR, cs_counters_v CN
     WHERE  INT.counter_id = CTR.counter_id AND
            CTR.name = CN.name AND
            INT.mr_effectivity_id = p_mr_effectivity_id AND
            CN.counter_id = p_counter_id AND
            ( nvl(start_value, p_counter_value+1) <= p_counter_value AND
              --p_counter_value < nvl(stop_value, p_counter_value)
              p_counter_value < nvl(stop_value, p_counter_value + 1)--fix for bug number 3713078
            );
	 */

	 --Priyan
	 --Query being changed due to performance related fixes
	 --Refer Bug # 4918744

	SELECT
		INT.START_VALUE,
		INT.STOP_VALUE,
		INT.INTERVAL_VALUE
	FROM
		AHL_MR_INTERVALS INT,
		CSI_COUNTER_TEMPLATE_VL CTR,
		--CSI_COUNTER_TEMPLATE_VL CN --bug# 5918525
                csi_counters_vl CN
	WHERE
		 INT.COUNTER_ID = CTR.COUNTER_ID AND
		 --CTR.NAME = CN.NAME AND -- bug# 5918525
                 CTR.NAME = CN.counter_template_name AND
		 INT.MR_EFFECTIVITY_ID = P_MR_EFFECTIVITY_ID AND
		 CN.COUNTER_ID = P_COUNTER_ID AND
		 (
			NVL(START_VALUE, P_COUNTER_VALUE +1) <= P_COUNTER_VALUE AND
			P_COUNTER_VALUE < NVL(STOP_VALUE, P_COUNTER_VALUE + 1)
		 ) ;

  l_remaining_ctr_fraction NUMBER;  /* reminder fraction that needs to be interpolated with
                                    the interval value of the next mr interval record */
  l_overflow_value  NUMBER; /* the counter value that overflows to the next interval. */
  l_next_due_counter_value NUMBER;

  -- variables used in cursor fetch.
  l_start_value  NUMBER;
  l_stop_value NUMBER;
  l_interval_value NUMBER;

BEGIN

  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('Start Adjust Interval Value');
  END IF;

  IF (p_stop_value IS NULL) THEN
    x_adjusted_int_value := p_interval_value;
    x_nxt_interval_found := TRUE;
  ELSE
    l_next_due_counter_value := p_counter_value + p_interval_value;
    l_overflow_value := l_next_due_counter_value - p_stop_value;

    x_adjusted_int_value := p_stop_value - p_counter_value;

    l_remaining_ctr_fraction := (l_overflow_value/p_interval_value);

    -- Get next record to match this interval.
    OPEN ahl_mr_intervalvalue_csr (p_mr_effectivity_id,
                                   p_counter_id,
                                   p_stop_value + 1);
    FETCH ahl_mr_intervalvalue_csr INTO l_start_value, l_stop_value, l_interval_value;
    IF (ahl_mr_intervalvalue_csr%NOTFOUND) THEN

        -- Fix for bug# 3461118.
        x_nxt_interval_found := FALSE;
        x_adjusted_int_value := p_interval_value;
    ELSE
        x_nxt_interval_found := TRUE;
        x_adjusted_int_value := x_adjusted_int_value + (l_remaining_ctr_fraction * l_interval_value);
    END IF; /* end ahl_mr_intervalvalue_csr if */

    CLOSE ahl_mr_intervalvalue_csr;

  END IF; /* p_stop_value if */

  --x_adjusted_int_value := trunc(x_adjusted_int_value);
  x_adjusted_int_value := x_adjusted_int_value;

  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('End Adjust Interval Value');
  END IF;


END Adjust_Interval_Value;

-----------------------------------------------------------------------------
-- This will return the adjusted due date if the next due date overlaps two intervals.
-- It will be used where the overflow condition occurs based on the interval's start
-- date and stop date.

PROCEDURE Adjust_Due_Date ( p_mr_effectivity_id IN NUMBER,
                            p_start_counter_rec IN counter_values_rec_type,
                            p_start_due_date    IN DATE,
                            p_counter_rules_tbl IN counter_rules_tbl_type,
                            p_interval_value IN NUMBER,
                            p_stop_date IN DATE,
                            p_due_date IN DATE,
                            x_adjusted_due_date OUT NOCOPY DATE,
                            x_adjusted_due_ctr  OUT NOCOPY NUMBER,
                            x_nxt_interval_found OUT NOCOPY BOOLEAN)

IS

  l_return_val BOOLEAN;

  l_start_counter_tbl counter_values_tbl_type;
  l_stop_counter_tbl  counter_values_tbl_type;

  l_forecast_days NUMBER;
  l_temp_due_date DATE;
  l_next_due_counter_remain NUMBER;
  l_remaining_ctr_fraction NUMBER;
--  l_remaining_ctr_value NUMBER;

  l_start_date DATE;
  l_stop_date  DATE;
  l_interval_value NUMBER;
  l_adjusted_due_ctr NUMBER;

  -- get the next interval record for the provided stop value.
  CURSOR ahl_mr_intervaldate_csr (p_mr_effectivity_id IN NUMBER,
                                  p_counter_id  IN NUMBER,
                                  p_stop_date   IN DATE) IS
    /* SELECT INT.start_date, INT.stop_date,
            INT.interval_value
     FROM   ahl_mr_intervals INT, cs_counters_v CTR, cs_counters_v CN
     WHERE  INT.counter_id = CTR.counter_id AND
            CTR.name = CN.name AND
            INT.mr_effectivity_id = p_mr_effectivity_id AND
            CN.counter_id = p_counter_id AND
            trunc(INT.start_date) = trunc(p_stop_date);
	*/

	 --Priyan
	 --Query being changed due to performance related fixes
	 --Refer Bug # 4918744
	 --Changes the usage of CS_COUNTERS_V to CSI_COUNTER_TEMPLATE_VL

	SELECT
	   INT.START_DATE,
	   INT.STOP_DATE,
	   INT.INTERVAL_VALUE
	FROM
	   AHL_MR_INTERVALS INT,
	   CSI_COUNTER_TEMPLATE_VL CTR,
	   --CSI_COUNTER_TEMPLATE_VL CN --bug# 5918525
           csi_counters_vl CN
	WHERE
	   INT.COUNTER_ID = CTR.COUNTER_ID
	   --AND CTR.NAME = CN.NAME --bug# 5918525
           AND CTR.NAME = CN.counter_template_name
	   AND INT.MR_EFFECTIVITY_ID = P_MR_EFFECTIVITY_ID
	   AND CN.COUNTER_ID = P_COUNTER_ID
	   AND TRUNC(INT.START_DATE) = TRUNC(P_STOP_DATE) ;

BEGIN

  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('Start Adjust Due Date');
  END IF;

  IF (trunc(p_due_date) <= trunc(p_stop_date)) THEN
    x_adjusted_due_date := p_due_date;
    x_nxt_interval_found := TRUE;
  ELSE
    l_start_counter_tbl(1) := p_start_counter_rec;

    -- Get counter values for stop date.
    Get_Due_At_Counter_Values (p_last_due_date => p_start_due_date,
                               p_last_due_counter_val_tbl => l_start_counter_tbl,
                               p_due_date => p_stop_date,
                               p_counter_rules_tbl => p_counter_rules_tbl,
                               x_due_at_counter_val_tbl => l_stop_counter_tbl,
                               x_return_value  => l_return_val);

    IF NOT(l_return_val) THEN
      x_adjusted_due_date := p_due_date;
      x_nxt_interval_found := FALSE;
    ELSE
      l_next_due_counter_remain := l_stop_counter_tbl(1).counter_value - p_start_counter_rec.counter_value;
      l_adjusted_due_ctr := l_next_due_counter_remain;
      l_remaining_ctr_fraction := 1 - (l_next_due_counter_remain/p_interval_value);

      -- Get next record to match this interval.

      OPEN ahl_mr_intervalDate_csr (p_mr_effectivity_id,
                                     p_start_counter_rec.counter_id,
                                     p_stop_date+1);
      FETCH ahl_mr_intervalDate_csr INTO l_start_date, l_stop_date, l_interval_value;
      IF (ahl_mr_intervalDate_csr%NOTFOUND) THEN
          -- Fix for bug# 3461118.
          x_adjusted_due_date := p_due_date;
          x_nxt_interval_found := FALSE;
      ELSE

          l_next_due_counter_remain := trunc(l_remaining_ctr_fraction * l_interval_value);
          x_nxt_interval_found := TRUE;

          -- Based on forecast get the due date.
          Get_Date_from_UF ( p_counter_remain => l_next_due_counter_remain,
                             p_counter_uom_code => p_start_counter_rec.uom_code,
                             p_counter_rules_tbl => p_counter_rules_tbl,
                             p_start_date => p_stop_date,
                             x_due_date => l_temp_due_date );
          -- l_temp_due_date is with respect to sysdate.
          IF (l_temp_due_date IS NULL) THEN
            x_adjusted_due_date := p_due_date;
          ELSE
            x_adjusted_due_date := l_temp_due_date;
            x_adjusted_due_ctr  := l_adjusted_due_ctr + l_next_due_counter_remain;
          END IF;
      END IF; /* end ahl_mr_intervalDate_csr if */
      CLOSE ahl_mr_intervalDate_csr;
    END IF;
  END IF;

  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('End Adjust Interval Value');
  END IF;


END Adjust_Due_Date;

-----------------------------------------------------------------------------
-- This procedure will return due date based on the next interval(if exists),
-- whenever an interval is not found for the current start/stop values or dates.
-- Added parameter p_dependent_mr_flag to fix bug# 6711228.
-- Added parameter p_mr_accomplish_exists and p_last_due_mr_interval_id to fix
-- bug# 6858788. Commented p_last_accomplishment_date and will instead use p_mr_accomplish_exists.
PROCEDURE Get_DueDate_from_NxtInterval(p_applicable_mrs_rec       IN  applicable_mrs_rec_type,
                                       p_repetivity_flag          IN  VARCHAR2,
                                       p_mr_effectivity_id        IN  NUMBER,
                                       p_current_ctr_rec          IN  Counter_values_rec_type,
                                       p_current_ctr_at_date      IN  DATE,
                                       p_counter_rules_tbl        IN  Counter_rules_tbl_type,
                                       p_start_int_match_at_ctr   IN  NUMBER,
                                       p_last_accomplish_ctr_val  IN  NUMBER,
                                       --p_last_accomplishment_date IN  DATE,
                                       p_dependent_mr_flag        IN  BOOLEAN,
                                       p_mr_accomplish_exists     IN  BOOLEAN,
                                       p_last_due_mr_interval_id  IN  NUMBER,
                                       x_next_due_date_rec        OUT NOCOPY next_due_date_rec_type,
                                       x_mr_interval_found        OUT NOCOPY BOOLEAN,
                                       x_return_val               OUT NOCOPY BOOLEAN)
IS

  CURSOR ahl_next_interval_ctr_csr (p_mr_effectivity_id IN NUMBER,
                                    --p_counter_id        IN NUMBER,
                                    p_counter_name      IN VARCHAR2,
                                    p_counter_value     IN NUMBER) IS
    /*
	SELECT  INT.mr_interval_id, INT.start_date, INT.stop_date,
            INT.start_value, INT.stop_value, INT.counter_id,
            INT.interval_value, INT.tolerance_after, INT.tolerance_before
     -- Replaced cs_counters_v with cs_counters to fix perf bug# 3786647.
     --FROM   ahl_mr_intervals INT, cs_counters_v CTR, cs_counters_v CN
     FROM   ahl_mr_intervals INT, cs_counters CTR, cs_counters CN
     WHERE  INT.counter_id = CTR.counter_id AND
            CTR.name = CN.name AND
            INT.mr_effectivity_id = p_mr_effectivity_id AND
            CN.counter_id = p_counter_id AND
            INT.start_value > p_counter_value
     ORDER BY INT.start_value;
	*/

	 --Priyan
	 --Query being changed due to performance related fixes
	 --Refer Bug # 4918744
	 --Changes the usage of CS_COUNTERS_V to CSI_COUNTER_TEMPLATE_VL
     -- select first row only.
     SELECT *
     FROM (
	  SELECT
	   INT.MR_INTERVAL_ID,
	   INT.START_DATE,
  	   INT.STOP_DATE,
	   INT.START_VALUE,
	   INT.STOP_VALUE,
	   INT.COUNTER_ID,
	   INT.INTERVAL_VALUE,
	   INT.TOLERANCE_AFTER,
	   INT.TOLERANCE_BEFORE,
           INT.EARLIEST_DUE_VALUE,
           INT.CALC_DUEDATE_RULE_CODE -- added for ER 7415856
	  FROM
	   AHL_MR_INTERVALS INT,
	   CSI_COUNTER_TEMPLATE_VL CTR --,
	   --CSI_COUNTER_TEMPLATE_VL CN --bug# 5918525
           --csi_counters_vl CN
	  WHERE
	   INT.COUNTER_ID = CTR.COUNTER_ID
	   -- AND CTR.NAME = CN.NAME --bug# 5918525
           --AND CTR.NAME = CN.counter_template_name
           AND CTR.NAME = p_counter_name
	   AND INT.MR_EFFECTIVITY_ID = P_MR_EFFECTIVITY_ID
	   --AND CN.COUNTER_ID = P_COUNTER_ID
	   AND INT.START_VALUE > P_COUNTER_VALUE
	  ORDER BY
	   INT.START_VALUE ASC
          )
     WHERE ROWNUM < 2;

  CURSOR ahl_next_interval_date_csr (p_mr_effectivity_id IN NUMBER,
                                     --p_counter_id        IN NUMBER,
                                     p_counter_name      IN VARCHAR2,
                                     p_start_date        IN DATE) IS

    /*SELECT  INT.mr_interval_id, INT.start_date, INT.stop_date,
            INT.tolerance_after, INT.tolerance_before, INT.interval_value
     -- Replaced cs_counters_v with cs_counters to fix perf bug# 3786647.
     --FROM   ahl_mr_intervals INT, cs_counters_v CTR, cs_counters_v CN
     FROM   ahl_mr_intervals INT, cs_counters CTR, cs_counters CN
     WHERE  INT.counter_id = CTR.counter_id AND
            CTR.name = CN.name AND
            INT.mr_effectivity_id = p_mr_effectivity_id AND
            CN.counter_id = p_counter_id AND
            INT.start_date > p_start_date
     ORDER BY INT.start_date;
	*/

	--Priyan
	 --Query being changed due to performance related fixes
	 --Refer Bug # 4918744
	 --Changes the usage of CS_COUNTERS_V to CSI_COUNTER_TEMPLATE_VL
     -- select first row only.
     SELECT *
     FROM (
	  SELECT
	   INT.MR_INTERVAL_ID,
	   INT.START_DATE,
	   INT.STOP_DATE,
	   INT.TOLERANCE_AFTER,
	   INT.TOLERANCE_BEFORE,
	   INT.INTERVAL_VALUE,
           INT.EARLIEST_DUE_VALUE,
           INT.CALC_DUEDATE_RULE_CODE -- added for ER 7415856
	  FROM
	   AHL_MR_INTERVALS INT,
	   CSI_COUNTER_TEMPLATE_VL CTR --,
	   --CSI_COUNTER_TEMPLATE_VL CN --bug# 5918525
           --csi_counters_vl CN
	  WHERE
	   INT.COUNTER_ID = CTR.COUNTER_ID
	   --AND CTR.NAME = CN.NAME --bug# 5918525
           --AND CTR.NAME = CN.counter_template_name
           AND CTR.NAME = p_counter_name
	   AND INT.MR_EFFECTIVITY_ID = P_MR_EFFECTIVITY_ID
	   --AND CN.COUNTER_ID = P_COUNTER_ID
	   AND INT.START_DATE > P_START_DATE
	  ORDER BY
	   INT.START_DATE ASC
          )
     WHERE ROWNUM < 2;


  l_counter_remain          NUMBER;
  l_counter_due_date        DATE; -- due date calculated using start-value of interval.
  l_current_ctr_tbl         counter_values_tbl_type;
  l_next_interval_ctr_rec   ahl_next_interval_ctr_csr%ROWTYPE;
  l_next_interval_date_rec  ahl_next_interval_date_csr%ROWTYPE;
  l_return_val              BOOLEAN;
  l_due_counter_tbl         counter_values_tbl_type;
  l_ctr_based               BOOLEAN; -- indicates if due date is based on start-value of interval.
  l_date_based              BOOLEAN; -- indicates if due date is based on start-date of interval.

  l_date_due_date           DATE;
  l_due_at_counter          NUMBER;

  l_mr_interval_found       BOOLEAN := FALSE; -- set to true if a future interval is found.

  -- Added to fix bug#4224867.
  l_date_based_counter_remain  NUMBER;
  l_ctr_based_counter_remain   NUMBER;

  -- Added to fix bug# 6358940.
  l_next_due_date_rec          next_due_date_rec_type;
  l_ctr_due_at_counter_value   NUMBER;

BEGIN

   IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('Start Get_DueDate_from_NxtInterval');
        AHL_DEBUG_PUB.Debug('Input Counter ID:' || p_current_ctr_rec.counter_id);
        AHL_DEBUG_PUB.Debug('Input Counter Name:' || p_current_ctr_rec.counter_name);
        AHL_DEBUG_PUB.Debug('Input Counter start value:' || p_start_int_match_at_ctr);
   END IF;

   -- Initialize.
   x_return_val := TRUE;
   l_ctr_based  := FALSE; -- indicates if due date is based on start-value of interval.
   l_date_based := FALSE; -- indicates if due date is based on start-date of interval.

   -- initialize.
   x_next_due_date_rec := l_next_due_date_rec;

   -- Find interval greater than the counter value.
   OPEN ahl_next_interval_ctr_csr(p_mr_effectivity_id,
                                  --p_current_ctr_rec.counter_id,
                                  p_current_ctr_rec.counter_name,
                                  p_start_int_match_at_ctr);
   FETCH ahl_next_interval_ctr_csr INTO l_next_interval_ctr_rec;
   IF (ahl_next_interval_ctr_csr%FOUND) THEN
     l_mr_interval_found := TRUE;

     l_counter_remain := l_next_interval_ctr_rec.start_value - p_current_ctr_rec.counter_value;
     l_ctr_due_at_counter_value := l_next_interval_ctr_rec.start_value;

     -- Added for ER 7415856
     -- if rule code is set as INTERVAL then add interval to due counter value.
     IF (l_next_interval_ctr_rec.calc_duedate_rule_code = 'INTERVAL') THEN
          l_counter_remain := l_next_interval_ctr_rec.start_value + l_next_interval_ctr_rec.interval_value
                              - p_current_ctr_rec.counter_value;
          l_ctr_due_at_counter_value := l_next_interval_ctr_rec.start_value
                                        + l_next_interval_ctr_rec.interval_value;
     END IF;

     -- Added to fix bug# 6358940
     -- here start value will not be a null value.
     IF (l_next_interval_ctr_rec.earliest_due_value IS NOT NULL
       AND p_repetivity_flag = 'N') THEN
        IF (p_mr_accomplish_exists = TRUE AND p_dependent_mr_flag = FALSE) THEN
          -- MR accomplishment exists.
          IF (p_last_accomplish_ctr_val >= l_next_interval_ctr_rec.earliest_due_value) THEN
             l_counter_remain := p_last_accomplish_ctr_val + l_next_interval_ctr_rec.interval_value
                                 - p_current_ctr_rec.counter_value;
             l_ctr_due_at_counter_value := p_last_accomplish_ctr_val
                                           + l_next_interval_ctr_rec.interval_value;

          END IF;
        END IF;
     ELSIF (l_next_interval_ctr_rec.earliest_due_value IS NULL AND p_repetivity_flag = 'N' AND
            p_mr_accomplish_exists = TRUE AND p_dependent_mr_flag = FALSE) THEN
             l_counter_remain := p_last_accomplish_ctr_val + l_next_interval_ctr_rec.interval_value
                                 - p_current_ctr_rec.counter_value;
             l_ctr_due_at_counter_value := p_last_accomplish_ctr_val
                                           + l_next_interval_ctr_rec.interval_value;

     END IF;

     -- Added to fix bug# 6858788(for repetity).
     IF (p_repetivity_flag = 'Y' AND p_last_due_mr_interval_id = l_next_interval_ctr_rec.mr_interval_id) THEN
            -- same interval threshold as previous due date calculation. Use
            -- interval value rather than start value.
             l_counter_remain := p_last_accomplish_ctr_val + l_next_interval_ctr_rec.interval_value
                                 - p_current_ctr_rec.counter_value;
             l_ctr_due_at_counter_value := p_last_accomplish_ctr_val
                                           + l_next_interval_ctr_rec.interval_value;
     -- case where last and current triggered intervals do not match. Ex: where group MR triggers.
     ELSIF (p_repetivity_flag = 'Y' AND l_next_interval_ctr_rec.earliest_due_value IS NOT NULL) THEN
         IF (p_last_accomplish_ctr_val >= l_next_interval_ctr_rec.earliest_due_value) THEN
            l_counter_remain := p_last_accomplish_ctr_val + l_next_interval_ctr_rec.interval_value
                                - p_current_ctr_rec.counter_value;
            l_ctr_due_at_counter_value := p_last_accomplish_ctr_val + l_next_interval_ctr_rec.interval_value;
         END IF;
     ELSIF (p_repetivity_flag = 'Y' AND l_next_interval_ctr_rec.earliest_due_value IS NULL) THEN
          l_counter_remain := p_last_accomplish_ctr_val + l_next_interval_ctr_rec.interval_value
                              - p_current_ctr_rec.counter_value;
          l_ctr_due_at_counter_value := p_last_accomplish_ctr_val + l_next_interval_ctr_rec.interval_value;

     END IF;

     IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.Debug('Found future interval with start value:' || l_next_interval_ctr_rec.start_value);
       AHL_DEBUG_PUB.Debug('Last due interval ID:' || p_last_due_mr_interval_id);
       AHL_DEBUG_PUB.Debug('Current interval ID:' || l_next_interval_ctr_rec.mr_interval_id);
       AHL_DEBUG_PUB.Debug('p_last_accomplish_ctr_val:' || p_last_accomplish_ctr_val);
       AHL_DEBUG_PUB.Debug('p_current_ctr_rec.counter_value:' || p_current_ctr_rec.counter_value);
       AHL_DEBUG_PUB.Debug('l_next_interval_date_rec.interval_value:' || l_next_interval_ctr_rec.interval_value);
       AHL_DEBUG_PUB.Debug('counter remain:' || l_counter_remain);
     END IF;

     -- l_counter_remain can be negative. Fix bug# 6739599.
     IF (l_counter_remain > 0) THEN
        -- calculate due date based on forecast.
        get_date_from_uf(l_counter_remain,
                         p_current_ctr_rec.uom_code,
                         p_counter_rules_tbl,
                         p_current_ctr_at_date,
                         l_counter_due_date);
     ELSIF (l_counter_remain = 0) THEN
        l_counter_due_date := trunc(sysdate);
     ELSIF (l_counter_remain < 0) THEN
        -- Due date = counter reading date.
        get_ctr_date_for_reading (p_csi_item_instance_id => p_applicable_mrs_rec.csi_item_instance_id,
                                  p_counter_id           => p_current_ctr_rec.counter_id,
                                  p_counter_value        => l_ctr_due_at_counter_value,
                                  x_ctr_record_date      => l_counter_due_date,
                                  x_return_val           => l_return_val);
        IF NOT(l_return_val) THEN
          l_counter_due_date := trunc(sysdate);
        END IF;

     END IF;

     --dbms_output.put_line ('due date by forecast' || l_due_date );

     /* commented to fix bug# 6907562.
     -- Check the due date value.
     IF (l_counter_due_date IS NULL) THEN
        CLOSE ahl_next_interval_ctr_csr;
        x_return_val := FALSE;
        RETURN;
     END IF;
     */

     -- fix bug# 4224867.
     l_ctr_based_counter_remain := l_counter_remain;

   END IF; -- ahl_next_ctr_interval_csr found.

   -- Now check for existence of interval, based on date range.
   OPEN ahl_next_interval_date_csr(p_mr_effectivity_id,
                                   --p_current_ctr_rec.counter_id,
                                   p_current_ctr_rec.counter_name,
                                   p_current_ctr_at_date);
   FETCH ahl_next_interval_date_csr INTO l_next_interval_date_rec;
   IF (ahl_next_interval_date_csr%FOUND) THEN
     l_mr_interval_found := TRUE;

     -- Added to fix bug# 6358940
     -- here start date will not be a null value.
     IF (l_next_interval_date_rec.earliest_due_value IS NOT NULL AND p_repetivity_flag = 'N') AND
        (p_mr_accomplish_exists = TRUE AND p_dependent_mr_flag = FALSE) AND -- MR accomplishment exists.
        (p_last_accomplish_ctr_val >= l_next_interval_date_rec.earliest_due_value) THEN
             l_counter_remain := p_last_accomplish_ctr_val + l_next_interval_date_rec.interval_value
                                 - p_current_ctr_rec.counter_value;
             l_due_at_counter := p_last_accomplish_ctr_val
                                 + l_next_interval_date_rec.interval_value;

     ELSIF (l_next_interval_date_rec.earliest_due_value IS NULL AND p_repetivity_flag = 'N' AND
            p_mr_accomplish_exists = TRUE AND p_dependent_mr_flag = FALSE) THEN
             l_counter_remain := p_last_accomplish_ctr_val + l_next_interval_date_rec.interval_value
                                 - p_current_ctr_rec.counter_value;
             l_due_at_counter := p_last_accomplish_ctr_val
                                 + l_next_interval_date_rec.interval_value;

     -- added to fix bug# 6858788(consider repetivity = Y).
     ELSIF (p_repetivity_flag = 'Y' AND p_last_due_mr_interval_id = l_next_interval_date_rec.mr_interval_id) THEN
            -- same interval threshold as previous due date calculation. Use
            -- interval value rather than start value.
             l_counter_remain := p_last_accomplish_ctr_val + l_next_interval_date_rec.interval_value
                                 - p_current_ctr_rec.counter_value;
             l_due_at_counter := p_last_accomplish_ctr_val
                                 + l_next_interval_date_rec.interval_value;
     -- added to fix bug# 6858788(consider repetivity = Y) where last and current interval triggered
     -- are not the same..
     ELSIF (l_next_interval_date_rec.earliest_due_value IS NOT NULL AND p_repetivity_flag = 'Y') AND
           (p_last_accomplish_ctr_val >= l_next_interval_date_rec.earliest_due_value) THEN
             l_counter_remain := p_last_accomplish_ctr_val + l_next_interval_date_rec.interval_value
                                 - p_current_ctr_rec.counter_value;
             l_due_at_counter := p_last_accomplish_ctr_val
                                 + l_next_interval_date_rec.interval_value;

     ELSIF (l_next_interval_date_rec.earliest_due_value IS NULL AND p_repetivity_flag = 'Y') THEN
             l_counter_remain := p_last_accomplish_ctr_val + l_next_interval_date_rec.interval_value
                                 - p_current_ctr_rec.counter_value;
             l_due_at_counter := p_last_accomplish_ctr_val
                                 + l_next_interval_date_rec.interval_value;

     ELSE
        --IF (ahl_next_interval_ctr_csr%FOUND) THEN
        -- Find the counter value as of l_next_interval_date_rec.start_date.
        l_current_ctr_tbl(1) := p_current_ctr_rec;
        Get_Due_At_Counter_Values (p_last_due_date => p_current_ctr_at_date,
                                   p_last_due_counter_val_tbl => l_current_ctr_tbl,
                                   p_due_date => l_next_interval_date_rec.start_date,
                                   p_counter_rules_tbl => p_counter_rules_tbl,
                                   x_due_at_counter_val_tbl => l_due_counter_tbl,
                                   x_return_value  => l_return_val);
        IF NOT(l_return_val) THEN
          CLOSE ahl_next_interval_date_csr;
          CLOSE ahl_next_interval_ctr_csr;
          -- set return values.
          x_return_val := FALSE;
          x_next_due_date_rec.due_date := l_counter_due_date;
          x_next_due_date_rec.tolerance_after := l_next_interval_ctr_rec.tolerance_after;
          x_next_due_date_rec.tolerance_before := l_next_interval_ctr_rec.tolerance_before;
          x_next_due_date_rec.mr_interval_id := l_next_interval_ctr_rec.mr_interval_id;
          x_next_due_date_rec.due_at_counter_value := null;
          x_next_due_date_rec.counter_remain := null;

          x_mr_interval_found := l_mr_interval_found;

          RETURN;
        END IF;

        -- Add interval to the counter value and get the due date for this.
        -- 11/01/07: due date should be l_next_interval_date_rec.start_date.
        l_counter_remain := l_due_counter_tbl(1).counter_value
                            -- + l_next_interval_date_rec.interval_value
                            - p_current_ctr_rec.counter_value;

        l_due_at_counter := l_due_counter_tbl(1).counter_value;
                            --+ l_next_interval_date_rec.interval_value;

        -- Added for ER 7415856
        -- if  rule code is set as INTERVAL then add interval to due counter value.
        IF (l_next_interval_date_rec.calc_duedate_rule_code = 'INTERVAL') THEN
             l_counter_remain := l_due_counter_tbl(1).counter_value + l_next_interval_date_rec.interval_value
                                 - p_current_ctr_rec.counter_value;
             l_due_at_counter := l_due_counter_tbl(1).counter_value
                                + l_next_interval_date_rec.interval_value;
        END IF;

     END IF;

     IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.Debug('Found future interval with start date:' || to_char(l_next_interval_date_rec.start_date,'DD-MON-YYYY'));
       AHL_DEBUG_PUB.Debug('counter remain:' || l_counter_remain);
       AHL_DEBUG_PUB.Debug('l_ctr_due_at_counter_value:' || l_ctr_due_at_counter_value);
       AHL_DEBUG_PUB.Debug('p_last_accomplish_ctr_val:' || p_last_accomplish_ctr_val);
       AHL_DEBUG_PUB.Debug('earliest_due_value:' || l_next_interval_date_rec.earliest_due_value);
     END IF;

     -- calculate due date based on forecast.
     get_date_from_uf(l_counter_remain,
                      p_current_ctr_rec.uom_code,
                      p_counter_rules_tbl,
                      p_current_ctr_at_date,
                      l_date_due_date);

     --dbms_output.put_line ('due date by forecast' || l_date_due_date );

     /* commented to fix bug# 6907562.
     -- Check the due date value.
     IF (l_date_due_date IS NULL) THEN
        CLOSE ahl_next_interval_ctr_csr;
        x_return_val := FALSE;
        RETURN;
     END IF;
     */

     -- fix bug# 4224867.
     l_date_based_counter_remain := l_counter_remain;

     IF (ahl_next_interval_ctr_csr%FOUND) THEN
       -- Pick one of l_date_due_date OR l_counter_due_date
       -- as the due_date based on whichever_first_code.
       -- Added null due date checks to fix bug# 6907562.
       IF (l_counter_due_date IS NULL OR l_date_due_date IS NULL) THEN
          IF (validate_for_duedate_reset(l_date_due_date,
                                     l_date_based_counter_remain,
                                     l_counter_due_date,
                                     p_current_ctr_rec.counter_id,
                                     l_ctr_based_counter_remain) = 'Y') THEN
             l_date_based := TRUE;
          ELSE
             l_ctr_based  := TRUE;
          END IF;
       ELSE

          IF (p_applicable_mrs_rec.whichever_first_code = 'FIRST') THEN
            IF (l_counter_due_date <= l_date_due_date) THEN
               l_ctr_based := TRUE;
            ELSE
               l_date_based := TRUE;
            END IF;
          ELSE --whichever_first_code = 'LAST'
            IF (l_counter_due_date < l_date_due_date) THEN
              l_date_based := TRUE;
            ELSE
              l_ctr_based := TRUE;
            END IF;
          END IF; -- whichever first code.
       END IF; -- l_counter_due_date IS NULL
     ELSE
       -- Here due_date = start_date counter + interval.
       l_date_based := TRUE;
     END IF; -- ahl_next_interval_ctr_csr.
   ELSIF (ahl_next_interval_ctr_csr%FOUND) THEN
     l_ctr_based := TRUE;
   END IF; -- ahl_next_interval_date_csr.

   CLOSE ahl_next_interval_ctr_csr;
   CLOSE ahl_next_interval_date_csr;

   -- set output parameters.
   IF (l_ctr_based) THEN
     x_next_due_date_rec.due_date := l_counter_due_date;
     x_next_due_date_rec.tolerance_after := l_next_interval_ctr_rec.tolerance_after;
     x_next_due_date_rec.tolerance_before := l_next_interval_ctr_rec.tolerance_before;
     x_next_due_date_rec.mr_interval_id := l_next_interval_ctr_rec.mr_interval_id;
     --x_next_due_date_rec.due_at_counter_value := l_next_interval_ctr_rec.start_value;
     x_next_due_date_rec.due_at_counter_value := l_ctr_due_at_counter_value;
     x_next_due_date_rec.counter_remain := l_ctr_based_counter_remain;

     /* commenting this out as this causes next repetity to be over interval
      * value (fix for bug# 6858788)
     -- Fix for bug# 6739599. l_counter_due_date can be a past date.
     IF (l_counter_due_date > trunc(sysdate)) THEN
       -- Check if the counter value on the due date is less than the due counter value.
       -- If less, add a day to the due date. This would ensure that the MR is performed not before
       -- the due counter value.
       l_current_ctr_tbl(1) := p_current_ctr_rec;
       Get_Due_At_Counter_Values (p_last_due_date => p_current_ctr_at_date,
                                  p_last_due_counter_val_tbl => l_current_ctr_tbl,
                                  p_due_date => l_counter_due_date,
                                  p_counter_rules_tbl => p_counter_rules_tbl,
                                  x_due_at_counter_val_tbl => l_due_counter_tbl,
                                  x_return_value  => l_return_val);

       IF (l_due_counter_tbl(1).counter_value < l_next_interval_ctr_rec.start_value) THEN
          l_counter_due_date := l_counter_due_date + 1;
          Get_Due_At_Counter_Values (p_last_due_date => p_current_ctr_at_date,
                                     p_last_due_counter_val_tbl => l_current_ctr_tbl,
                                     p_due_date => l_counter_due_date,
                                     p_counter_rules_tbl => p_counter_rules_tbl,
                                     x_due_at_counter_val_tbl => l_due_counter_tbl,
                                     x_return_value  => l_return_val);
          IF NOT(l_return_val) THEN  -- forecast not available.
            x_return_val := FALSE;
            RETURN;
          END IF;

          --x_next_due_date_rec.due_at_counter_value := l_due_counter_tbl(1).counter_value;
          x_next_due_date_rec.due_date := l_counter_due_date;
       END IF;
     END IF; -- l_counter_due_date > trunc(sysdate)
     */
   ELSIF (l_date_based) THEN

     x_next_due_date_rec.due_date := l_date_due_date;
     x_next_due_date_rec.tolerance_after := l_next_interval_date_rec.tolerance_after;
     x_next_due_date_rec.tolerance_before := l_next_interval_date_rec.tolerance_before;
     x_next_due_date_rec.mr_interval_id := l_next_interval_date_rec.mr_interval_id;
     x_next_due_date_rec.due_at_counter_value := l_due_at_counter;
     x_next_due_date_rec.counter_remain := l_date_based_counter_remain;
   END IF;

   x_mr_interval_found := l_mr_interval_found;

   IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('End Get_DueDate_from_NxtInterval');
   END IF;

END Get_DueDate_from_NxtInterval;

-----------------------------------------------------------------------------
-- Apply the counter ratio factor to convert a given counter value at a
-- component level to the root instance. This is needed as forecast is only
-- defined at root instance.

FUNCTION Apply_Counter_Ratio ( p_counter_remain IN NUMBER,
                               p_counter_uom_code IN VARCHAR2,
                               p_counter_rules_tbl IN counter_rules_tbl_type)
RETURN NUMBER IS

  l_counter_remain NUMBER := p_counter_remain;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Apply Counter Ratio');
  END IF;

  -- Loop through p_counter_rules_tbl.
  IF (p_counter_rules_tbl.COUNT > 0) THEN
    FOR i IN p_counter_rules_tbl.FIRST..p_counter_rules_tbl.LAST LOOP
      IF (p_counter_rules_tbl(i).uom_code = p_counter_uom_code) THEN
         l_counter_remain := p_counter_remain / p_counter_rules_tbl(i).ratio;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Apply Counter Ratio');
  END IF;

  RETURN l_counter_remain;

END Apply_Counter_Ratio;

-------------------------------------------------------------------------------
-- Apply the counter ratio factor to convert a given counter value at a root
-- instance level to the component. This is needed as forecast is only defined
-- at root instance.

FUNCTION Apply_ReverseCounter_Ratio ( p_counter_remain IN NUMBER,
                                      p_counter_uom_code IN VARCHAR2,
                                      p_counter_rules_tbl IN counter_rules_tbl_type)
RETURN NUMBER IS

  l_counter_remain NUMBER := p_counter_remain;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Apply Reverse Counter Ratio');
  END IF;


  -- Loop through p_counter_rules_tbl.
  IF (p_counter_rules_tbl.COUNT > 0) THEN
    FOR i IN p_counter_rules_tbl.FIRST..p_counter_rules_tbl.LAST LOOP
      IF (p_counter_rules_tbl(i).uom_code = p_counter_uom_code) THEN
         l_counter_remain := p_counter_remain * p_counter_rules_tbl(i).ratio;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Apply Reverse Counter Ratio');
  END IF;

  RETURN l_counter_remain;

END Apply_ReverseCounter_Ratio;

------------------------------------------------------------------------------
-- To process the decendents in case the mr is a group MR.

PROCEDURE Process_GroupMR (p_applicable_mrs_rec  IN applicable_mrs_rec_type,
                           p_new_unit_effectivity_rec IN ahl_temp_unit_effectivities%ROWTYPE,
                           p_unit_effectivity_tbl IN unit_effectivity_tbl_type,
                           p_old_UE_forecast_sequence IN NUMBER := -1)

IS

  -- Read applicable group table for validation.
  -- In this table mr_header_id/csi_item_instance_id are parents
  -- and related_mr_header_id/related_csi_item_instance_id are children.
  CURSOR ahl_applicable_grp_csr( p_item_instance_id IN NUMBER,
                                 p_mr_header_id IN NUMBER,
                                 p_level IN NUMBER) IS

    SELECT mr_header_id, csi_item_instance_id,
           related_mr_header_id,
           related_csi_item_instance_id
    FROM ahl_applicable_mr_relns
    WHERE level = p_level
    START WITH mr_header_id = p_mr_header_id AND
               csi_item_instance_id = p_item_instance_id AND
               orig_mr_header_id = p_mr_header_id AND
               orig_csi_item_instance_id = p_item_instance_id AND
               relationship_code = 'PARENT'
    CONNECT BY PRIOR related_mr_header_id = mr_header_id AND
               PRIOR related_csi_item_instance_id = csi_item_instance_id AND
               orig_mr_header_id = p_mr_header_id AND
               orig_csi_item_instance_id = p_item_instance_id AND
               relationship_code = 'PARENT'
    ORDER BY   level, mr_header_id, csi_item_instance_id;

  -- Read applicable group table for updates.
  CURSOR ahl_applicable1_grp_csr( p_item_instance_id IN NUMBER,
                                  p_mr_header_id IN NUMBER) IS

    SELECT mr_header_id, csi_item_instance_id, related_mr_header_id,
           related_csi_item_instance_id
    FROM ahl_applicable_mr_relns
    START WITH mr_header_id = p_mr_header_id AND
               csi_item_instance_id = p_item_instance_id AND
               orig_mr_header_id = p_mr_header_id AND
               orig_csi_item_instance_id = p_item_instance_id AND
               relationship_code = 'PARENT'
    CONNECT BY PRIOR related_mr_header_id = mr_header_id AND
               PRIOR related_csi_item_instance_id = csi_item_instance_id AND
               orig_mr_header_id = p_mr_header_id AND
               orig_csi_item_instance_id = p_item_instance_id AND
               relationship_code = 'PARENT'
    ORDER BY   level, mr_header_id, csi_item_instance_id;

  -- for reading unit effectivity table.
  CURSOR ahl_ue_relns_csr ( p_unit_effectivity_id IN NUMBER, p_level IN NUMBER ) IS
    SELECT ue_id, related_ue_id
    FROM ahl_ue_relationships relns
    WHERE level = p_level
    START WITH ue_id = p_unit_effectivity_id AND
               relationship_code = 'PARENT'
    CONNECT BY PRIOR related_ue_id = ue_id AND
               originator_ue_id = p_unit_effectivity_id AND
               relationship_code = 'PARENT'
    ORDER BY   level;

  -- get related unit effectivities details.
  CURSOR ahl_ue_csr ( p_ue_id IN NUMBER,
                      p_related_ue_id IN NUMBER ) IS
    SELECT ue1.mr_header_id, ue1.csi_item_instance_id,
           ue2.mr_header_id related_mr_header_id,
           ue2.csi_item_instance_id related_csi_item_instance_id
    --FROM ahl_unit_effectivities_app_v ue1, ahl_unit_effectivities_app_v ue2
    FROM ahl_unit_effectivities_b ue1, ahl_unit_effectivities_b ue2
    WHERE ue1.unit_effectivity_id = p_ue_id AND
          ue2.unit_effectivity_id = p_related_ue_id;

  -- To check if mr has a preceding mr.
  CURSOR ahl_appl_mr_csr (p_item_instance_id IN NUMBER,
                          p_mr_header_id IN NUMBER) IS
   SELECT 'x'
   FROM ahl_applicable_mrs
   WHERE csi_item_instance_id = p_item_instance_id AND
         mr_header_id = p_mr_header_id AND
         implement_status_code <> 'OPTIONAL_DO_NOT_IMPLEMENT' AND
         preceding_mr_header_id IS NOT NULL;

  l_new_unit_effectivity_rec  ahl_temp_unit_effectivities%ROWTYPE;
  l_initialize_ue_rec         ahl_temp_unit_effectivities%ROWTYPE;

  l_junk  VARCHAR2(1);
  l_visit_end_date DATE;
  l_unit_effectivity_id  NUMBER;
  l_ue_id                NUMBER;
  l_related_ue_id        NUMBER;

  TYPE ue_details_rec_type IS RECORD (
     mr_header_id NUMBER,
     csi_item_instance_id NUMBER,
     related_mr_header_id NUMBER,
     related_csi_item_instance_id NUMBER,
     match_flag  VARCHAR2(1));

  l_ue_details_rec       ue_details_rec_type;

  TYPE l_ue_details_tbl_type IS TABLE OF ue_details_rec_type INDEX BY BINARY_INTEGER;

  l_ue_details_tbl       l_ue_details_tbl_type;
  l_grp_details_tbl      l_ue_details_tbl_type;

  l_grp_match  BOOLEAN;
  l_level NUMBER;
  l_reln_found BOOLEAN;
  l_appl_grp_found BOOLEAN;

  i NUMBER;

  l_visit_status    VARCHAR2(30);

 BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Process Group MR');
  END IF;

  l_grp_match := FALSE; /* set default to be "no group" available to match against in ahl_unit_effectitivities. */

  IF (p_old_UE_forecast_sequence <> -1) THEN
  -- match the group tree under unit_effectivity_id in unit_effectivity_tbl(l_old_UE_forecast_sequence)
  -- with the one in ahl_applicable_mr_relns.

    l_level := 0;  /* tree level */
    l_unit_effectivity_id := p_unit_effectivity_tbl(p_old_UE_forecast_sequence).unit_effectivity_id;

    l_grp_match := TRUE;
    l_reln_found := TRUE; /* ue_relns record found */
    l_appl_grp_found := TRUE; /* applicable grp mrs found */

    -- Check if workorder already created.
    l_visit_status := AHL_UMP_UTIL_PKG.get_Visit_Status (l_unit_effectivity_id);

    -- when UE is on shop floor or UE status is INIT-DUE, skip group MR comparison.
    -- This will be done later in flush_from_temp_table proc.
    IF (p_unit_effectivity_tbl(p_old_UE_forecast_sequence).status_code) = 'INIT-DUE'
       OR (nvl(l_visit_status,'x') IN ('RELEASED','CLOSED')) THEN
       null; -- for init-due status skip group MR comparison. This will be done later in flush_from_temp_table proc.
       -- We need the UE id inserted as the First Due info needs to be copied to new UE
    ELSE

      WHILE ( ((l_reln_found) OR (l_appl_grp_found)) AND (l_grp_match = TRUE)) LOOP

         l_level := l_level + 1;
         --dbms_output.put_line('level:' || l_level);
         i := 1;
         FOR l_ue_relns_rec IN ahl_ue_relns_csr(l_unit_effectivity_id, l_level) LOOP
             OPEN ahl_ue_csr(l_ue_relns_rec.ue_id, l_ue_relns_rec.related_ue_id);
             FETCH ahl_ue_csr INTO l_ue_details_tbl(i).mr_header_id,
                                   l_ue_details_tbl(i).csi_item_instance_id,
                                   l_ue_details_tbl(i).related_mr_header_id,
                                   l_ue_details_tbl(i).related_csi_item_instance_id;
             IF (ahl_ue_csr%NOTFOUND) THEN
                 FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_RELN_NOTFOUND');
                 FND_MESSAGE.Set_Token('UE_ID',l_ue_relns_rec.ue_id);
                 FND_MESSAGE.Set_Token('RELATED_UE_ID', l_ue_relns_rec.related_ue_id);
                 FND_MSG_PUB.ADD;
                 CLOSE ahl_ue_csr;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             --dbms_output.put_line ('found ue relns');

             l_ue_details_tbl(i).match_flag := 'N';
             i := i + 1;
             CLOSE ahl_ue_csr;
         END LOOP;

         IF (l_ue_details_tbl.COUNT > 0 ) THEN
            l_reln_found := TRUE;
         ELSE
            l_reln_found := FALSE;
         END IF;
         --dbms_output.put_line('count ue tbl' || l_ue_details_tbl.COUNT);

         -- from applicable_mrs_group.
         i := 1;
         FOR l_appl_grp_rec IN ahl_applicable_grp_csr(p_applicable_mrs_rec.csi_item_instance_id,
                                                      p_applicable_mrs_rec.mr_header_id,
                                                      l_level)
         LOOP
             l_grp_details_tbl(i).mr_header_id := l_appl_grp_rec.mr_header_id;
             l_grp_details_tbl(i).csi_item_instance_id := l_appl_grp_rec.csi_item_instance_id;
             l_grp_details_tbl(i).related_mr_header_id := l_appl_grp_rec.related_mr_header_id;
             l_grp_details_tbl(i).related_csi_item_instance_id := l_appl_grp_rec.related_csi_item_instance_id;
             l_grp_details_tbl(i).match_flag := 'N';
             i := i + 1;
         END LOOP;

         IF (l_grp_details_tbl.COUNT > 0 ) THEN
            l_appl_grp_found := TRUE;
         ELSE
            l_appl_grp_found := FALSE;
         END IF;
         --dbms_output.put_line('count grp tbl' || l_grp_details_tbl.COUNT);

         -- Now compare l_grp_details_tbl with l_ue_details_tbl.
         IF (l_grp_details_tbl.COUNT > 0 ) THEN
           FOR i IN l_grp_details_tbl.FIRST..l_grp_details_tbl.LAST LOOP
             -- match if entry present in l_ue_details_tbl.

             IF (l_ue_details_tbl.COUNT > 0 ) THEN
               FOR j IN l_ue_details_tbl.FIRST..l_ue_details_tbl.LAST LOOP
                 IF (l_ue_details_tbl(j).mr_header_id = l_grp_details_tbl(i).mr_header_id AND
                    l_ue_details_tbl(j).csi_item_instance_id = l_grp_details_tbl(i).csi_item_instance_id AND
                    l_ue_details_tbl(j).related_csi_item_instance_id = l_grp_details_tbl(i).related_csi_item_instance_id AND
                    l_ue_details_tbl(j).related_mr_header_id = l_grp_details_tbl(i).related_mr_header_id AND
                    l_ue_details_tbl(j).match_flag = 'N' AND
                    l_grp_details_tbl(i).match_flag = 'N') THEN
                    --l_ue_details_tbl.DELETE(j);
                    --l_grp_details_tbl.DELETE(i);
                    l_ue_details_tbl(j).match_flag := 'Y';
                    l_grp_details_tbl(i).match_flag := 'Y';
                     EXIT;
                 END IF;
               END LOOP; /* ue_details */
             END IF; /* count - ue_details */
           END LOOP; /* grp_details */
         END IF; /* count - grp_details */

         -- delete records from table where match flag is Y.
         IF (l_ue_details_tbl.COUNT > 0 ) THEN
           FOR j IN l_ue_details_tbl.FIRST..l_ue_details_tbl.LAST LOOP
             IF (l_ue_details_tbl(j).match_flag = 'Y') THEN
                l_ue_details_tbl.DELETE(j);
             END IF;
           END LOOP;
         END IF;

         IF (l_grp_details_tbl.COUNT > 0 ) THEN
           FOR i IN l_grp_details_tbl.FIRST..l_grp_details_tbl.LAST LOOP
             IF (l_grp_details_tbl(i).match_flag = 'Y') THEN
               l_grp_details_tbl.DELETE(i);
             END IF;
           END LOOP;
         END IF;

         IF (l_ue_details_tbl.COUNT <= 0) AND (l_grp_details_tbl.COUNT <= 0) THEN
             l_grp_match := TRUE;

         ELSE
             l_grp_match := FALSE;

         END IF;

      END LOOP; /* while - level */
    END IF; -- status_code

  END IF; -- p_old_UE_forecast_sequence

  -- if trees match, then
  -- update the temp table record for orig MR with visit_end_date and unit_effectivity ID.
  IF (p_old_UE_forecast_sequence IS NOT NULL AND l_grp_match = TRUE) THEN

    -- get visit end date from unit_effectivity_tbl for l_old_UE_Forecast_sequence.
    l_visit_end_date := p_unit_effectivity_tbl(p_old_UE_forecast_sequence).visit_end_date;
    l_new_unit_effectivity_rec.unit_effectivity_id :=
                          p_unit_effectivity_tbl(p_old_UE_forecast_sequence).unit_effectivity_id;

  ELSE
    l_visit_end_date := null;
  END IF;

  -- construct temporary unit effectivity for group top node.

    l_new_unit_effectivity_rec.due_date := p_new_unit_effectivity_rec.due_date;
    l_new_unit_effectivity_rec.mr_interval_id := p_new_unit_effectivity_rec.mr_interval_id;
    l_new_unit_effectivity_rec.mr_effectivity_id := p_new_unit_effectivity_rec.mr_effectivity_id;
    l_new_unit_effectivity_rec.due_counter_value := p_new_unit_effectivity_rec.due_counter_value;
    l_new_unit_effectivity_rec.csi_item_instance_id := p_applicable_mrs_rec.csi_item_instance_id;
    l_new_unit_effectivity_rec.mr_header_id := p_applicable_mrs_rec.mr_header_id;
    l_new_unit_effectivity_rec.repetitive_mr_flag := p_new_unit_effectivity_rec.repetitive_mr_flag;
    l_new_unit_effectivity_rec.visit_end_date := l_visit_end_date;
    l_new_unit_effectivity_rec.forecast_sequence := p_new_unit_effectivity_rec.forecast_sequence;
    -- to indicate group.
    l_new_unit_effectivity_rec.orig_csi_item_instance_id := p_applicable_mrs_rec.csi_item_instance_id;
    l_new_unit_effectivity_rec.orig_mr_header_id := p_applicable_mrs_rec.mr_header_id;
    l_new_unit_effectivity_rec.orig_forecast_sequence := p_new_unit_effectivity_rec.forecast_sequence;
    -- Added for ER# 2636001.
    l_new_unit_effectivity_rec.earliest_due_date := p_new_unit_effectivity_rec.earliest_due_date;
    l_new_unit_effectivity_rec.latest_due_date := p_new_unit_effectivity_rec.latest_due_date;
    l_new_unit_effectivity_rec.counter_id := p_new_unit_effectivity_rec.counter_id;

    l_new_unit_effectivity_rec.tolerance_flag := p_new_unit_effectivity_rec.tolerance_flag;
    l_new_unit_effectivity_rec.tolerance_before := p_new_unit_effectivity_rec.tolerance_before;
    l_new_unit_effectivity_rec.tolerance_after := p_new_unit_effectivity_rec.tolerance_after;


  -- write into temp table.
    Create_temp_unit_effectivity(l_new_unit_effectivity_rec);

  -- Read group MR tree and apply details from p_next_due_rec_type.
  FOR l_mr_grp_rec IN ahl_applicable1_grp_csr(p_applicable_mrs_rec.csi_item_instance_id,
                                              p_applicable_mrs_rec.mr_header_id)
  LOOP

   l_new_unit_effectivity_rec := l_initialize_ue_rec;

    -- Build temp_unit_effectivity record and write into temporary table.
    -- fix bug#6530920: UOM remain issue for child MRs.
    l_new_unit_effectivity_rec.due_date := p_new_unit_effectivity_rec.due_date;
    l_new_unit_effectivity_rec.mr_interval_id := p_new_unit_effectivity_rec.mr_interval_id;
    l_new_unit_effectivity_rec.mr_effectivity_id := p_new_unit_effectivity_rec.mr_effectivity_id;
    l_new_unit_effectivity_rec.due_counter_value := p_new_unit_effectivity_rec.due_counter_value;
    l_new_unit_effectivity_rec.csi_item_instance_id := l_mr_grp_rec.related_csi_item_instance_id;
    l_new_unit_effectivity_rec.parent_csi_item_instance_id := l_mr_grp_rec.csi_item_instance_id;
    l_new_unit_effectivity_rec.mr_header_id := l_mr_grp_rec.related_mr_header_id;
    l_new_unit_effectivity_rec.parent_mr_header_id := l_mr_grp_rec.mr_header_id;
    l_new_unit_effectivity_rec.orig_csi_item_instance_id := p_applicable_mrs_rec.csi_item_instance_id;
    l_new_unit_effectivity_rec.orig_mr_header_id := p_applicable_mrs_rec.mr_header_id;
    l_new_unit_effectivity_rec.orig_forecast_sequence := p_new_unit_effectivity_rec.forecast_sequence;
    l_new_unit_effectivity_rec.repetitive_mr_flag := p_new_unit_effectivity_rec.repetitive_mr_flag;
    l_new_unit_effectivity_rec.visit_end_date := l_visit_end_date;
    l_new_unit_effectivity_rec.earliest_due_date := p_new_unit_effectivity_rec.earliest_due_date;
    l_new_unit_effectivity_rec.latest_due_date := p_new_unit_effectivity_rec.latest_due_date;
    l_new_unit_effectivity_rec.counter_id := p_new_unit_effectivity_rec.counter_id;

    l_new_unit_effectivity_rec.tolerance_flag := p_new_unit_effectivity_rec.tolerance_flag;
    l_new_unit_effectivity_rec.tolerance_before := p_new_unit_effectivity_rec.tolerance_before;
    l_new_unit_effectivity_rec.tolerance_after := p_new_unit_effectivity_rec.tolerance_after;

    l_new_unit_effectivity_rec.unit_effectivity_id := null;

    -- check if this mr has a preceding mr.
    OPEN ahl_appl_mr_csr (l_mr_grp_rec.related_csi_item_instance_id,
                          l_mr_grp_rec.related_mr_header_id);
    FETCH ahl_appl_mr_csr INTO l_junk;
    IF (ahl_appl_mr_csr%FOUND) THEN
       l_new_unit_effectivity_rec.preceding_check_flag:= 'Y';
    ELSE
       l_new_unit_effectivity_rec.preceding_check_flag:= 'N';
    END IF;
    CLOSE ahl_appl_mr_csr;

    -- write into temp table.
    Create_temp_unit_effectivity(l_new_unit_effectivity_rec);

  END LOOP;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Process GroupMR');
  END IF;

END Process_GroupMR;

-------------------------------------------------------------------------------------
-- To process the dependent MRs based on the value of preceding MR.

PROCEDURE Process_PrecedingMR (p_applicable_mrs_rec IN applicable_mrs_rec_type,
                               p_counter_rules_tbl  IN counter_rules_tbl_type,
                               p_current_usage_tbl  IN counter_values_tbl_type)
IS

  -- Declare cursor to get all MRs that have preceding MR as that in applicable_mrs_rec.
  /* modified for performance
  CURSOR ahl_preceding_mr_csr (p_mr_header_id IN NUMBER,
                               p_item_instance_id IN NUMBER) IS
    SELECT mr.mr_header_id,
           apmr.csi_item_instance_id,
           apmr.Implement_status_code,
           apmr.copy_accomplishment_code,
           apmr.show_repetitive_code,
           --apmr.preceding_mr_header_id, -- fix for bug# 5922149
           curr_mr.mr_header_id preceding_mr_header_id,
           apmr.descendent_count,
           mr.whichever_first_code,
           apmr.repetitive_flag
    FROM ahl_mr_headers_app_v mr, ahl_mr_headers_b curr_mr, ahl_applicable_mrs apmr
    --fix for bug number 5922149
    --WHERE mr.preceding_mr_header_id = curr_mr.mr_header_id AND
    WHERE mr.preceding_mr_header_id IN (SELECT t.mr_header_id FROM ahl_mr_headers_b t where t.title = curr_mr.title ) AND
          curr_mr.mr_header_id = p_mr_header_id AND
          apmr.mr_header_id = mr.mr_header_id AND
          -- Fix for bug# 6711228.
          -- validation moved to before this procedure call.
          -- curr_mr.implement_status_code = 'MANDATORY' AND
          trunc(sysdate) >= trunc(nvl(mr.effective_from, sysdate)) AND
          trunc(sysdate) <= trunc(nvl(mr.effective_to, sysdate+1)) AND
          apmr.csi_item_instance_id = p_item_instance_id;
  */

  CURSOR ahl_preceding_mr_csr (p_curr_mr_title    IN VARCHAR2,
                               p_item_instance_id IN NUMBER) IS
    SELECT mr.mr_header_id,
           mr.version_number,
           apmr.csi_item_instance_id,
           apmr.Implement_status_code,
           apmr.copy_accomplishment_code,
           apmr.show_repetitive_code,
           --apmr.preceding_mr_header_id,
           apmr.descendent_count,
           mr.whichever_first_code,
           apmr.repetitive_flag,
           mr.title,
           mr.effective_from,
           mr.effective_to
    FROM ahl_mr_headers_app_v mr, ahl_applicable_mrs apmr
    WHERE mr.preceding_mr_header_id IN (SELECT t.mr_header_id FROM ahl_mr_headers_app_v t where t.title = p_curr_mr_title ) AND
          apmr.mr_header_id = mr.mr_header_id AND
          trunc(sysdate) >= trunc(nvl(mr.effective_from, sysdate)) AND
          trunc(sysdate) <= trunc(nvl(mr.effective_to, sysdate+1)) AND
          apmr.csi_item_instance_id = p_item_instance_id;

   l_dependent_mr_rec applicable_mrs_rec_type;

   k NUMBER := 0;


BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Process PrecedingMR');
  END IF;

  -- Process mrs which are dependent on current mr and are applicable to the same item instance.
  --FOR l_appl_rec IN ahl_preceding_mr_csr(p_applicable_mrs_rec.mr_header_id,
  --                                       p_applicable_mrs_rec.csi_item_instance_id) LOOP
  FOR l_appl_rec IN ahl_preceding_mr_csr(p_applicable_mrs_rec.title,
                                         p_applicable_mrs_rec.csi_item_instance_id) LOOP

     -- Build applicable_mrs_rec.
     l_dependent_mr_rec.csi_item_instance_id := l_appl_rec.csi_item_instance_id;
     l_dependent_mr_rec.MR_header_id := l_appl_rec.MR_header_id;
     l_dependent_mr_rec.Implement_status_code := l_appl_rec.Implement_status_code;
     l_dependent_mr_rec.copy_accomplishment_code := l_appl_rec.copy_accomplishment_code;
     l_dependent_mr_rec.show_repetitive_code := l_appl_rec.show_repetitive_code;
     --l_dependent_mr_rec.preceding_mr_header_id := l_appl_rec.preceding_mr_header_id;
     l_dependent_mr_rec.preceding_mr_header_id := p_applicable_mrs_rec.mr_header_id;
     l_dependent_mr_rec.descendent_count := l_appl_rec.descendent_count;
     l_dependent_mr_rec.whichever_first_code := l_appl_rec.whichever_first_code;
     l_dependent_mr_rec.repetitive_flag := l_appl_rec.repetitive_flag;
     l_dependent_mr_rec.title := l_appl_rec.title;
     l_dependent_mr_rec.version_number := l_appl_rec.version_number;
     l_dependent_mr_rec.effective_to := l_appl_rec.effective_to;
     l_dependent_mr_rec.effective_from := l_appl_rec.effective_from;

     Build_Effectivity (p_applicable_mrs_rec => l_dependent_mr_rec,
                        p_current_usage_tbl  => p_current_usage_tbl,
                        p_counter_rules_tbl  => p_counter_rules_tbl);

  END LOOP;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Process PrecedingMR');
  END IF;


END Process_PrecedingMR;

--------------------------------------------------------------------------------
-- To update the preceding_check_flag in the temporary unit effectivities table.

PROCEDURE Update_check_flag (p_applicable_mrs_rec IN applicable_mrs_rec_type,
                             p_dependent_mr_flag IN BOOLEAN,
                             p_next_due_date_rec IN next_due_date_rec_type)
IS

  l_preceding_check_flag VARCHAR2(1);

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Update Check Flag');
  END IF;

  IF (p_dependent_mr_flag) THEN
   /* i.e accomplishment is based on preceding MR */
    IF (p_next_due_date_rec.due_date IS NULL) THEN
       null; /* leave all preceding_check_flag = 'Y' */
    ELSE
       UPDATE ahl_temp_unit_effectivities
       SET preceding_check_flag = 'N'
       WHERE csi_item_instance_id = p_applicable_mrs_rec.csi_item_instance_id
             AND mr_header_id = p_applicable_mrs_rec.mr_header_id
             AND due_date >= p_next_due_date_rec.due_date;
    END IF;
  ELSE
   /* this MR has its accomplishments; update all records irrespective of due date */
    UPDATE ahl_temp_unit_effectivities
    SET preceding_check_flag = 'N'
    WHERE csi_item_instance_id = p_applicable_mrs_rec.csi_item_instance_id
          AND mr_header_id = p_applicable_mrs_rec.mr_header_id;

  END IF;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Update Check Flag');
  END IF;

END Update_check_flag;


-----------------------------------------------------------
-- To write a record into ahl_temp_unit_effectivities.

PROCEDURE Create_temp_unit_effectivity (X_unit_effectivity_rec IN ahl_temp_unit_effectivities%ROWTYPE)

IS

BEGIN
  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Create Temporary Unit Effect');
  END IF;

  -- insert into temporary table.
  insert into ahl_temp_unit_effectivities (
    csi_item_instance_id,
    MR_header_id,
    due_date,
    mr_interval_id,
    mr_effectivity_id,
    due_counter_value,
    parent_csi_item_instance_id,
    parent_mr_header_id,
    orig_csi_item_instance_id,
    orig_mr_header_id,
    orig_forecast_sequence,
    preceding_csi_item_instance_id,
    preceding_mr_header_id,
    preceding_forecast_seq,
    forecast_sequence,
    tolerance_before,
    tolerance_after,
    preceding_check_flag,
    unit_effectivity_id,
    repetitive_mr_flag,
    tolerance_flag,
    message_code,
    service_line_id,
    program_mr_header_id,
    earliest_due_date,
    latest_due_date,
    counter_id)
  values (
    X_unit_effectivity_rec.csi_item_instance_id,
    X_unit_effectivity_rec.MR_header_id,
    X_unit_effectivity_rec.due_date,
    X_unit_effectivity_rec.mr_interval_id,
    X_unit_effectivity_rec.mr_effectivity_id,
    X_unit_effectivity_rec.due_counter_value,
    X_unit_effectivity_rec.parent_csi_item_instance_id,
    X_unit_effectivity_rec.parent_mr_header_id,
    X_unit_effectivity_rec.orig_csi_item_instance_id,
    X_unit_effectivity_rec.orig_mr_header_id,
    X_unit_effectivity_rec.orig_forecast_sequence,
    X_unit_effectivity_rec.preceding_csi_item_instance_id,
    X_unit_effectivity_rec.preceding_mr_header_id,
    X_unit_effectivity_rec.preceding_forecast_seq,
    X_unit_effectivity_rec.forecast_sequence,
    X_unit_effectivity_rec.tolerance_before,
    X_unit_effectivity_rec.tolerance_after,
    X_unit_effectivity_rec.preceding_check_flag,
    X_unit_effectivity_rec.unit_effectivity_id,
    X_unit_effectivity_rec.repetitive_mr_flag,
    X_unit_effectivity_rec.tolerance_flag,
    X_unit_effectivity_rec.message_code,
    X_unit_effectivity_rec.service_line_id,
    X_unit_effectivity_rec.program_mr_header_id,
    X_unit_effectivity_rec.earliest_due_date,
    X_unit_effectivity_rec.latest_due_date,
    X_unit_effectivity_rec.counter_id

  );

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Create Temp Unit Effect.');
  END IF;

END Create_temp_unit_effectivity;


---------------------------------------------------------------------------
-- To log error messages into a log file if called from concurrent process.

PROCEDURE log_error_messages IS

l_msg_count      NUMBER;
l_msg_index_out  NUMBER;
l_msg_data       VARCHAR2(2000);

BEGIN

IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start log error messages');
END IF;

 -- Standard call to get message count.
l_msg_count := FND_MSG_PUB.Count_Msg;

FOR i IN 1..l_msg_count LOOP
  FND_MSG_PUB.get (
      p_msg_index      => i,
      p_encoded        => FND_API.G_FALSE,
      p_data           => l_msg_data,
      p_msg_index_out  => l_msg_index_out );

  fnd_file.put_line(FND_FILE.LOG, 'Err message-'||l_msg_index_out||':' || l_msg_data);
  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Err message-'||l_msg_index_out||':' || substr(l_msg_data,1,240));
  END IF;

END LOOP;

IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End log error messages');
END IF;


END log_error_messages;

-----------------------------------------------------------------------
--  Function    : Calls FMP and populates the AHL_APPLICABLE_MRS table
--                for preventive maintenance installation.
--  Pre-reqs    :
--  Parameters  :
--
--  PopulatePM_Appl_MRs Parameters:
--       p_csi_ii_id       IN  csi item instance id  Required
--
--
--  End of Comments.

PROCEDURE PopulatePM_Appl_MRs (
    p_csi_ii_id           IN            NUMBER,
    x_return_status       OUT  NOCOPY   VARCHAR2,
    x_msg_count           OUT  NOCOPY   NUMBER,
    x_msg_data            OUT  NOCOPY   VARCHAR2,
    x_UnSch_programs_tbl  OUT  NOCOPY   PMprogram_tbl_type)

IS
 l_api_version            CONSTANT NUMBER := 1.0;
 l_appl_activities_tbl    AHL_FMP_PVT.applicable_activities_tbl_type;
 l_appl_programs_tbl      AHL_FMP_PVT.applicable_programs_tbl_type;
 l_pm_install_flag        VARCHAR2(1);

 l_duplicate_pgm_flag  BOOLEAN;
 l_pgm_index           NUMBER;
 l_UnSch_programs_tbl  PMprogram_tbl_type;

 l_activity_sch_exists_flag BOOLEAN;

BEGIN

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Start of PopulatePM_Appl_MRs');
  END IF;

  -- call api to fetch all applicable mrs for PM installation.
  AHL_FMP_PVT.get_pm_applicable_mrs(
                       p_api_version            => l_api_version,
                       p_init_msg_list          => FND_API.G_FALSE,
                       p_commit                 => FND_API.G_FALSE,
                       p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                       x_return_status          => x_return_status,
                       x_msg_count              => x_msg_count,
                       x_msg_data               => x_msg_data,
           	       p_item_instance_id       => p_csi_ii_id,
   		       x_applicable_activities_tbl     => l_appl_activities_tbl,
                       x_applicable_programs_tbl      => l_appl_programs_tbl);


  -- Raise errors if exceptions occur
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize.
  l_pgm_index := 0;

  -- Read programs table.
  IF (l_appl_programs_tbl.COUNT > 0) THEN

     FOR i IN l_appl_programs_tbl.FIRST..l_appl_programs_tbl.LAST LOOP

         l_activity_sch_exists_flag := TRUE;

         -- find the corressponding activities in l_appl_activities_tbl for the program.
         IF (l_appl_activities_tbl.COUNT > 0) THEN
            FOR j IN l_appl_activities_tbl.FIRST..l_appl_activities_tbl.LAST LOOP
               IF (l_appl_activities_tbl(j).service_line_id = l_appl_programs_tbl(i).service_line_id)
               THEN

                    INSERT INTO AHL_APPLICABLE_MRS (
                        	CSI_ITEM_INSTANCE_ID,
                  	        MR_HEADER_ID,
                        	MR_EFFECTIVITY_ID,
                    	        REPETITIVE_FLAG   ,
                          	SHOW_REPETITIVE_CODE,
                      	        IMPLEMENT_STATUS_CODE,
                                WHICHEVER_FIRST_CODE,
                                SERVICE_LINE_ID,
                                PROGRAM_MR_HEADER_ID,
                                CONTRACT_START_DATE,
                                CONTRACT_END_DATE,
                                COVERAGE_IMP_LEVEL,
                                PM_SCHEDULE_EXISTS)
                    VALUES (    l_appl_activities_tbl(j).ITEM_INSTANCE_ID,
                                l_appl_activities_tbl(j).MR_HEADER_ID,
                                l_appl_activities_tbl(j).MR_EFFECTIVITY_ID,
                                l_appl_activities_tbl(j).REPETITIVE_FLAG,
                                l_appl_activities_tbl(j).SHOW_REPETITIVE_CODE,
                                l_appl_activities_tbl(j).IMPLEMENT_STATUS_CODE,
                                l_appl_activities_tbl(j).WHICHEVER_FIRST_CODE,
                                l_appl_activities_tbl(j).SERVICE_LINE_ID,
                                l_appl_activities_tbl(j).PROGRAM_MR_HEADER_ID,
                                l_appl_programs_tbl(i).SERVICE_START_DATE,
                                l_appl_programs_tbl(i).SERVICE_END_DATE,
                                l_appl_programs_tbl(i).COVERAGE_TYPE_IMP_LEVEL,
                                nvl(l_appl_activities_tbl(j).ACT_SCHEDULE_EXISTS,'N')
                           );
                    -- Set activity_sch_exists_flag if any of the activities does
                    -- not have a schedule.
                    IF (nvl(l_appl_activities_tbl(j).act_schedule_exists,'N') = 'N') THEN
                      l_activity_sch_exists_flag := FALSE;
                    END IF;
               END IF;

               IF G_DEBUG = 'Y' THEN
                 AHL_DEBUG_PUB.debug('Successfully inserted for Act ID:' || l_appl_activities_tbl(j).MR_HEADER_ID);
               END IF;

            END LOOP; -- next activities record.
         END IF; -- activity COUNT.

         -- If this program does not have a schedule, add this program to table l_UnSch_programs_tbl
         -- if it is unique.
         IF (NOT(l_activity_sch_exists_flag)  AND
             l_appl_programs_tbl(i).mr_effectivity_id IS NOT NULL) THEN

            l_duplicate_pgm_flag := FALSE;
            -- Check if this program already exists in the table.
            IF (l_UnSch_programs_tbl.COUNT > 0) THEN
               FOR j IN l_UnSch_programs_tbl.FIRST..l_UnSch_programs_tbl.LAST LOOP
                  IF (l_UnSch_programs_tbl(j).program_mr_header_id = l_appl_programs_tbl(i).PM_program_id) THEN
                      l_duplicate_pgm_flag := TRUE;
                      EXIT;
                  END IF;
               END LOOP; -- chk next program.
            END IF; -- count > 0.

            -- if not duplicate add to program table.
            IF NOT(l_duplicate_pgm_flag) THEN
                l_pgm_index := l_pgm_index + 1;
                l_UnSch_programs_tbl(l_pgm_index).program_mr_header_id := l_appl_programs_tbl(i).PM_program_id;
                l_UnSch_programs_tbl(l_pgm_index).mr_effectivity_id := l_appl_programs_tbl(i).mr_effectivity_id;
                IF G_DEBUG = 'Y' THEN
                   AHL_DEBUG_PUB.debug('Successfully added Program to l_UnSch_programs_tbl:index:value:' || i || ':' ||
                                       l_UnSch_programs_tbl(l_pgm_index).program_mr_header_id);
                END IF;

            END IF;

         END IF;
      END LOOP; -- next program record.
    END IF; -- count > 0.

  -- set output parameter.
  x_unsch_programs_tbl := l_UnSch_programs_tbl;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('End of PopulatePM_Appl_MRs');
  END IF;

END PopulatePM_Appl_MRs;

----------------------------------------------------------------------------------
-- Process Unit for PM(preventive maintenance) installation.
PROCEDURE Process_PM_Unit(p_csi_item_instance_id IN NUMBER,
                          p_UnSch_programs_tbl   IN PMprogram_tbl_type) IS

  l_current_usage_tbl    counter_values_tbl_type;
  /* contains current counter usage */

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start of Process_PM_Unit procedure');
  END IF;

  -- Get current usage of all the counters defined for the item instance.
  get_Current_Usage (p_csi_item_instance_id,
                     l_current_usage_tbl);

  -- Calculate program end date for all MR's where program is not scheduled.
  Calc_program_end_dates (p_UnSch_programs_tbl,
                          l_current_usage_tbl);

  -- Process records with program dates scheduled.
  Process_PMSch_Activities;

  -- Process records with no program dates.
  Process_PMUnSch_Activities(l_current_usage_tbl);

  -- Assign existing unit_effectivity ID's that have not been accomplished
  -- to the newly created ones in the temporary table.
  Assign_Unit_effectivity_IDs;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End of Process_PM_Unit procedure');
  END IF;

END Process_PM_Unit;


--------------------------------------------------------------------------------

-- To calculate the program end dates for all contracts with no due date schedule.
PROCEDURE Calc_Program_End_Dates(p_UnSch_programs_tbl   IN PMprogram_tbl_type,
                                 p_current_usage_tbl    IN counter_values_tbl_type) IS

  -- get all programs which have no schedules.
  CURSOR ahl_cont_not_scheduled_csr IS
    SELECT DISTINCT appl.program_mr_header_id, mr.whichever_first_code
    FROM ahl_applicable_mrs appl, ahl_mr_headers_b mr
    -- replaced ahl_mr_headers_app_v with ahl_mr_headers_b as ahl_applicable_mrs has
    -- the filter of application_usg_code.
    WHERE appl.program_mr_header_id = mr.mr_header_id
       AND pm_schedule_exists = 'N';

  -- get details of program effectivity.
  CURSOR ahl_program_eff_csr (p_mr_effectivity_id IN NUMBER) IS
    SELECT mr_effectivity_id, program_duration, program_duration_uom_code,
           threshold_date
    FROM ahl_mr_effectivities
    where mr_effectivity_id = p_mr_effectivity_id;

  -- get all intervals for an effectivity.
  CURSOR ahl_mr_interval_csr (p_mr_effectivity_id IN NUMBER) IS
    SELECT start_value, stop_value, counter_id, counter_name, mr_interval_id
    FROM ahl_mr_intervals_v
    WHERE mr_effectivity_id = p_mr_effectivity_id;

  l_effectivity_rec   ahl_program_eff_csr%ROWTYPE;

  l_counter_rules_tbl counter_rules_tbl_type;

  l_program_due_date      DATE;
  l_program_calender_days NUMBER;
  l_UnSch_program_tbl     PMprogram_tbl_type;
  l_upd_SQLstmt_str       VARCHAR2(2000);

  l_program_expire_flag   BOOLEAN;
  /* indicates if a program has expired. */

  l_current_ctr_value NUMBER;
  l_counter_remain    NUMBER;
  l_ctr_found         BOOLEAN;
  l_current_ctr_uom   VARCHAR2(3);
  l_due_days          NUMBER;
  l_due_date          DATE;
  l_tbl_index         NUMBER;
  l_program_expired_flag  BOOLEAN;

BEGIN

  IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.Debug('Start of CALC_PROGRAM_END_DATES procedure');
  END IF;

  FOR program_rec IN ahl_cont_not_scheduled_csr LOOP
    -- Initialize variables.
    l_program_due_date := NULL;
    l_counter_remain := 0;
    l_program_calender_days := 0;
    l_UnSch_program_tbl.DELETE;
    l_tbl_index := 0;

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.Debug('Calculating program end date for:' || program_rec.program_mr_header_id);
    END IF;

    -- build temporary table containing the effectivities associated to the program.
    IF (p_UnSch_programs_tbl.COUNT > 0) THEN
       FOR i IN p_UnSch_programs_tbl.FIRST..p_UnSch_programs_tbl.LAST LOOP
          IF (p_UnSch_programs_tbl(i).program_mr_header_id = program_rec.program_mr_header_id) THEN
             l_tbl_index := l_tbl_index + 1;
             l_UnSch_program_tbl(l_tbl_index) := p_UnSch_programs_tbl(i);
             --dbms_output.put_line('program id:' || l_UnSch_program_tbl(l_tbl_index).program_mr_header_id);
          END IF;
       END LOOP;
    END IF;

    -- read effectivity attributes for the program.
    IF (l_UnSch_program_tbl.COUNT > 0) THEN
       FOR i IN l_UnSch_program_tbl.FIRST..l_UnSch_program_tbl.LAST LOOP

         IF G_DEBUG = 'Y' THEN
            AHL_DEBUG_PUB.Debug('Processing for program effectivity-id:' || l_UnSch_program_tbl(l_tbl_index).mr_effectivity_id);
         END IF;

         OPEN ahl_program_eff_csr (l_UnSch_program_tbl(i).mr_effectivity_id);
         FETCH ahl_program_eff_csr INTO l_effectivity_rec;
         IF (ahl_program_eff_csr%FOUND) THEN
            -- read intervals for the effectivity.
            FOR interval_rec IN ahl_mr_interval_csr(l_effectivity_rec.mr_effectivity_id) LOOP

              IF G_DEBUG = 'Y' THEN
                 AHL_DEBUG_PUB.Debug('Processing for interval:' || interval_rec.mr_interval_id);
              END IF;

              -- Set current usage counter value.
              l_current_ctr_value := 0;
              l_ctr_found := FALSE;
              l_current_ctr_uom := NULL;
              -- Get the interval counter's  value from l_current_usage_tbl.
              FOR i IN p_current_usage_tbl.FIRST..p_current_usage_tbl.LAST LOOP
                IF (p_current_usage_tbl(i).counter_name = interval_rec.counter_name) THEN
                   l_current_ctr_value := p_current_usage_tbl(i).counter_value;
                   l_current_ctr_uom := p_current_usage_tbl(i).uom_code;
                   l_ctr_found := TRUE;
                   EXIT;
                END IF;
              END LOOP;

              IF (l_ctr_found) THEN

                 -- Check that the current counter value less than the program stop value.
                 l_counter_remain := interval_rec.stop_value - l_current_ctr_value;

                 /* indicates if a program has expired. */
                 l_program_expire_flag := FALSE;

                 -- Using forecast find the number of days to reach stop_value.
                 IF (l_counter_remain > 0) THEN
                     -- get date from forecast.
                     get_date_from_uf(l_counter_remain,
                                      l_current_ctr_uom,
                                      l_counter_rules_tbl, -- empty table.
                                      sysdate,
                                      l_due_date);

                     -- Compare dates.
                     IF (l_program_due_date IS NULL) THEN
                       l_program_due_date := l_due_date;
                     ELSE
                       IF (l_due_date IS NOT NULL) THEN
                          IF (program_rec.whichever_first_code = 'FIRST') THEN
                             IF (trunc(l_program_due_date) > trunc(l_due_date)) THEN
                                 l_program_due_date := l_due_date;
                             END IF;
                          ELSE /* whichever_first_code = 'LAST' */
                             IF (trunc(l_program_due_date) < trunc(l_due_date)) THEN
                                 l_program_due_date := l_due_date;
                             END IF;
                          END IF;
                       END IF; -- due date null.
                     END IF;

                 ELSE
                       l_program_expire_flag := TRUE;
                       -- if program expired for mr with whichever_code = FIRST, stop calculation.
                       IF (program_rec.whichever_first_code = 'FIRST') THEN
                          -- program expired for this instance.
                          l_due_date := NULL;
                          l_program_due_date := NULL;
                          EXIT; -- exit intervals loop.
                       END IF;
                 END IF;

              END IF; /* end l_ctr_found */

            END LOOP; /* next interval_rec */

            -- calculate due date using effectivity attributes.
            IF (program_rec.whichever_first_code = 'FIRST') AND (l_program_expired_flag) THEN
                -- program expired for this instance.
                null; -- do nothing.
            ELSIF (nvl(l_effectivity_rec.program_duration,0)) <> 0 AND
               l_effectivity_rec.program_duration_uom_code IS NOT NULL
            THEN

              --dbms_output.put_line('effectivity duration:' ||l_effectivity_rec.program_duration );
              --dbms_output.put_line('effectivity duration:' ||l_effectivity_rec.program_duration_uom_code );

              IF (l_effectivity_rec.program_duration_uom_code = 'YR') THEN
                 l_due_days := trunc(ADD_MONTHS(trunc(SYSDATE), 12 * l_effectivity_rec.program_duration)) - trunc(SYSDATE);
              ELSIF (l_effectivity_rec.program_duration_uom_code = 'MTH') THEN
                 l_due_days := trunc(ADD_MONTHS(trunc(SYSDATE), l_effectivity_rec.program_duration)) - trunc(SYSDATE);
              ELSIF (l_effectivity_rec.program_duration_uom_code = 'WK') THEN
                 l_due_days := 7 * l_effectivity_rec.program_duration;
              ELSIF (l_effectivity_rec.program_duration_uom_code = 'DAY') THEN
                 l_due_days := l_effectivity_rec.program_duration;
              END IF;

              --dbms_output.put_line('due days are:' || l_due_days );

              -- Compare the due days.
              IF (l_program_calender_days = 0) THEN
                  l_program_calender_days := l_due_days;
              ELSIF (program_rec.whichever_first_code = 'FIRST') THEN
                IF (l_program_calender_days > l_due_days) THEN
                  l_program_calender_days := l_due_days;
                END IF;
              ELSE /* whichever_first_code = 'LAST' */
                IF (l_program_calender_days < l_due_days) THEN
                  l_program_calender_days := l_due_days;
                END IF;
              END IF;

            END IF; /* effectivity_rec.program_duration */

         END IF; /* effectivity_rec found */
         CLOSE ahl_program_eff_csr;

         -- chk for program expired.
         IF (program_rec.whichever_first_code = 'FIRST') AND (l_program_expired_flag) THEN
             -- program expired for this instance.
             l_program_due_date := NULL;
             EXIT; -- exit program table loop.
         END IF;

      END LOOP; /* program table */
    END IF; /* count */

    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.Debug('Program end date:' || l_program_due_date );
       AHL_DEBUG_PUB.Debug('Program calender days:' || l_program_calender_days );
    END IF;

    -- Update record in ahl_applicable_mrs with the calculated program end date.
    IF (l_program_expired_flag) THEN
       -- For this case, set program end date = sysdate -1.
       l_upd_SQLstmt_str := 'UPDATE ahl_applicable_mrs' ||
                            ' SET program_end_date = :1' ||
                            ' WHERE program_mr_header_id = :2'||
                            ' AND PM_schedule_exists = :3';

       IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.Debug('Expire SQL string:' || l_upd_SQLstmt_str);
       END IF;

       EXECUTE IMMEDIATE l_upd_SQLstmt_str USING SYSDATE - 1,
                                                 program_rec.program_mr_header_id,
                                                 'N';
    ELSE

       -- dbms_output.put_line('Not expired');
       -- set program end date = least of (program_calculated_date, contract_start + calender_days, contract_end_date)
       --UPDATE ahl_applicable_mrs
       --SET program_end_date = LEAST (nvl(l_program_due_date,contract_end_date),
       --                              decode(l_program_calender_days,0, contract_end_date, contract_start_date + l_program_calender_days),
       --                              contract_end_date)
       --WHERE program_mr_header_id = program_rec.program_mr_header_id
       --   AND PM_schedule_exists = 'N';

       -- for whichever_last, pick greatest of l_program_calender_days+ contract start date
       -- and l_program_due_date.

       IF (program_rec.whichever_first_code = 'FIRST') THEN

          l_upd_SQLstmt_str := 'UPDATE ahl_applicable_mrs' ||
                               ' SET program_end_date = LEAST (nvl(:1,contract_end_date),' ||
                                                            ' decode(:2,0, contract_end_date, contract_start_date + :3),' ||
                                                          ' contract_end_date)' ||
                            ' WHERE program_mr_header_id = :4' ||
                            '     AND PM_schedule_exists = :5';
       ELSE

          l_upd_SQLstmt_str := 'UPDATE ahl_applicable_mrs' ||
                               ' SET program_end_date = LEAST ( GREATEST (nvl(:1,contract_end_date),' ||
                                                            ' decode(:2,0, contract_end_date, contract_start_date + :3)),' ||
                                                          ' contract_end_date)' ||
                            ' WHERE program_mr_header_id = :4' ||
                            '     AND PM_schedule_exists = :5';
       END IF;


       IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.Debug('SQL string:' || l_upd_SQLstmt_str);
       END IF;

       EXECUTE IMMEDIATE l_upd_SQLstmt_str USING l_program_due_date,
                                                 l_program_calender_days,
                                                 l_program_calender_days,
                                                 program_rec.program_mr_header_id,
                                                 'N';
    END IF;

  END LOOP; /* next program rec */

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End of CALC_PROGRAM_END_DATES procedure');
  END IF;

END Calc_Program_End_Dates;

--------------------------------------------------
-- Process records with contract dates scheduled.
PROCEDURE Process_PMSch_Activities  IS

  -- get distinct activities for which due dates have been scheduled for the service.
  CURSOR ahl_sch_activity_csr IS
    SELECT DISTINCT mr_header_id, csi_item_instance_id, service_line_id,
                    program_mr_header_id, contract_end_date, program_end_date,
                    show_repetitive_code,
                    repetitive_flag
    FROM ahl_applicable_mrs
    WHERE pm_schedule_exists = 'Y';

  -- Fix for FP bug# 6327241. We should be able to process multiple contracts.
  /*
  -- get program which have service dates scheduled in the order of importance
  -- and contract_start_date. Process only the first one.
  CURSOR ahl_cont_scheduled_csr(p_mr_header_id IN NUMBER) IS
    SELECT mr_header_id, service_line_id, mr_effectivity_id,
           program_mr_header_id, contract_end_date, program_end_date
    FROM ahl_applicable_mrs
    WHERE mr_header_id = p_mr_header_id
         AND pm_schedule_exists = 'Y'
    ORDER BY coverage_imp_level , contract_start_date;
  */
  -- Temporary fix for bug# 3022915.
  -- Get due date associated to the accomplishment date.
  /*
  -- fix for FP bug# 5223862.
  CURSOR ahl_due_date_csr(p_accomplishment_date IN DATE,
                          p_mr_header_id         IN NUMBER,
                          p_csi_item_instance_id IN NUMBER) IS
    SELECT due_date
    FROM ahl_unit_effectivities_b
    WHERE mr_header_id = p_mr_header_id
      AND csi_item_instance_id = p_csi_item_instance_id
      AND trunc(accomplished_date) = trunc(p_accomplishment_date)
      AND status_code IN ('ACCOMPLISHED','INIT-ACCOMPLISHED','TERMINATED')
    ORDER BY due_date desc;
  */

  -- Added filter by service_line_id to avoid issues caused by oks bug - 4574548
  -- wherein SRs associated to higher due dates are accomplished before lesser
  -- due date and the contract may have expired/terminated.
  CURSOR ahl_due_date_csr(--p_accomplishment_date  IN DATE,
                          p_mr_header_id         IN NUMBER,
                          p_csi_item_instance_id IN NUMBER,
                          p_service_line_id      IN NUMBER) IS
    SELECT due_date, accomplished_date
    FROM ahl_unit_effectivities_b
    WHERE mr_header_id = p_mr_header_id
      AND csi_item_instance_id = p_csi_item_instance_id
      AND service_line_id = p_service_line_id
      --AND trunc(accomplished_date) = trunc(p_accomplishment_date)
      AND status_code IN ('ACCOMPLISHED','INIT-ACCOMPLISHED','TERMINATED')
    ORDER BY accomplished_date desc, due_date desc;

  --l_cont_scheduled_rec ahl_cont_scheduled_csr%ROWTYPE;
  /* record structure holding the service line and program details. */

  l_due_date        DATE;
  l_first_array_index  NUMBER;
  l_forecast_sequence  NUMBER := 0;

  -- parameters needed to call OKS API.
  l_pm_schedule_tbl OKS_PM_ENTITLEMENTS_PUB.pm_sch_tbl_type;
  l_inp_sch_rec     OKS_PM_ENTITLEMENTS_PUB.inp_sch_rec;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);


  l_del_SQLstmt_str VARCHAR2(2000);

  l_temp_unit_effectivity_rec  ahl_temp_unit_effectivities%ROWTYPE;
  /* record structure to hold the activity and due date details */

  -- Added to fix bug# 3546136.
  l_temp_ue_initrec           ahl_temp_unit_effectivities%ROWTYPE;

  -- parameters needed to call get_accomplishment_details.
  l_last_accomplishment_date  DATE;
  l_last_acc_counter_val_tbl  counter_values_tbl_type;
  l_current_usage_tbl         counter_values_tbl_type;
  l_counter_rules_tbl         counter_rules_tbl_type;
  l_dependent_mr_flag         BOOLEAN;
  l_get_preceding_next_due    BOOLEAN;
  l_applicable_mrs_rec        applicable_mrs_rec_type;
  l_one_time_mr_flag          BOOLEAN;
  l_last_due_date             DATE;

  -- Added for bug# 6711228
  l_no_forecast_flag          BOOLEAN;
  l_mr_accomplish_exists      BOOLEAN;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start of PROCESS_PMSCH_ACTIVITIES procedure');
  END IF;

  FOR sch_activity_rec IN ahl_sch_activity_csr LOOP

    IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('Processing for:' || sch_activity_rec.mr_header_id);
        AHL_DEBUG_PUB.Debug('Processing for Item Instance:' || sch_activity_rec.csi_item_instance_id);
        AHL_DEBUG_PUB.Debug('Processing for Repetitive flag:' || sch_activity_rec.repetitive_flag);
        AHL_DEBUG_PUB.Debug('Processing for SHow Repetitive code:' || sch_activity_rec.show_repetitive_code);
    END IF;

    -- initialize forecast sequence for the activity.
    l_forecast_sequence := 0;

    -- Fix for FP bug# 6327241. We should be able to process multiple contracts.
    /*
    OPEN ahl_cont_scheduled_csr(sch_activity_rec.mr_header_id);
    FETCH ahl_cont_scheduled_csr INTO l_cont_scheduled_rec;
    IF (ahl_cont_scheduled_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_PMPROGRAM_NOTFOUND');
       FND_MESSAGE.Set_Token('PMPROGRAM',sch_activity_rec.mr_header_id);
       FND_MSG_PUB.ADD;
       CLOSE ahl_cont_scheduled_csr;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- check for existence of accomplishments.

    -- initialize.
    l_one_time_mr_flag := FALSE;

    -- build applicable_mrs_rec.
    l_applicable_mrs_rec.mr_header_id := sch_activity_rec.mr_header_id;
    l_applicable_mrs_rec.csi_item_instance_id := sch_activity_rec.csi_item_instance_id;
    l_applicable_mrs_rec.repetitive_flag := sch_activity_rec.repetitive_flag;

    -- Check if accomplishment details exist.
    Get_accomplishment_details(p_applicable_mrs_rec => l_applicable_mrs_rec,
                               p_current_usage_tbl  => l_current_usage_tbl,
                               p_counter_rules_tbl  => l_counter_rules_tbl,
                               x_accomplishment_date => l_last_accomplishment_date,
                               x_last_acc_counter_val_tbl => l_last_acc_counter_val_tbl,
                               x_one_time_mr_flag         => l_one_time_mr_flag,
                               x_dependent_mr_flag => l_dependent_mr_flag,
                               x_get_preceding_next_due => l_get_preceding_next_due,
                               x_mr_accomplish_exists  => l_mr_accomplish_exists,
                               x_no_forecast_flag => l_no_forecast_flag );

    -- No need to check l_no_forecast_flag as this does not apply to PM flow.
    -- call OKS API to get due dates and process them in case one_time_mr_flag = false.
    IF NOT(l_one_time_mr_flag) THEN
    */
    -- get due date associated to the accomplishment date.
    OPEN ahl_due_date_csr (--l_last_accomplishment_date,
                           sch_activity_rec.mr_header_id,
                           sch_activity_rec.csi_item_instance_id,
                           sch_activity_rec.service_line_id);
    FETCH ahl_due_date_csr INTO l_last_due_date, l_last_accomplishment_date;
    IF (ahl_due_date_csr%FOUND) THEN
        IF (l_last_accomplishment_date IS NOT NULL) THEN
          IF G_DEBUG = 'Y' THEN
             AHL_DEBUG_PUB.debug('l_last_accomplishment_date:' || l_last_accomplishment_date);
          END IF;

          /* Fix for FP bug# 6327241
          -- get due date associated to the accomplishment date.
          OPEN ahl_due_date_csr (l_last_accomplishment_date,
                                 sch_activity_rec.mr_header_id,
                                 sch_activity_rec.csi_item_instance_id,
                                 l_cont_scheduled_rec.service_line_id);
          FETCH ahl_due_date_csr INTO l_last_due_date;
          CLOSE ahl_due_date_csr;
          */

          IF (l_last_due_date IS NOT NULL) THEN
            IF G_DEBUG = 'Y' THEN
               AHL_DEBUG_PUB.Debug('l_last_due_date is not null:' || l_last_due_date);
            END IF;

            l_last_accomplishment_date := l_last_due_date + 1;
          END IF;
        ELSE
          l_last_accomplishment_date := NULL;
        END IF;
    ELSE
     l_last_accomplishment_date := NULL;
    END IF;
    CLOSE ahl_due_date_csr;

        l_inp_sch_rec.service_line_id     := sch_activity_rec.service_line_id;
        l_inp_sch_rec.program_id          := sch_activity_rec.program_mr_header_id;
        l_inp_sch_rec.activity_id         := sch_activity_rec.mr_header_id;
        l_inp_sch_rec.schedule_start_date := l_last_accomplishment_date;
        l_inp_sch_rec.schedule_end_date   := G_last_day_of_window; /* uptill rolling window */

        -- Call contracts API to get due dates.
         OKS_PM_ENTITLEMENTS_PUB.Get_PM_Schedule (
                               p_api_version   => 1.0,
                               p_init_msg_list => OKC_API.G_FALSE,
                               p_sch_rec       => l_inp_sch_rec,
                               x_return_status => l_return_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data,
                               x_pm_schedule   => l_pm_schedule_tbl);

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF G_DEBUG = 'Y' THEN
           AHL_DEBUG_PUB.debug('Service Line ID: ' || l_inp_sch_rec.service_line_id);
           AHL_DEBUG_PUB.debug('Program ID: ' || l_inp_sch_rec.program_id);
           AHL_DEBUG_PUB.debug('Activity ID: ' || l_inp_sch_rec.activity_id);
           AHL_DEBUG_PUB.debug('Start Date: ' || to_char(l_inp_sch_rec.schedule_start_date, 'DD-MON-YYYY HH24:MI:SS'));
           AHL_DEBUG_PUB.debug('End Date: ' || to_char(l_inp_sch_rec.schedule_end_date, 'DD-MON-YYYY HH24:MI:SS'));
           AHL_DEBUG_PUB.debug('Count of l_pm_schedule_tbl is: ' || l_pm_schedule_tbl.count);

           IF (l_pm_schedule_tbl.count > 0 ) THEN
                 for i in l_pm_schedule_tbl.first..l_pm_schedule_tbl.last loop
                    AHL_DEBUG_PUB.debug('Serv Line for ' || i ||':' || l_pm_schedule_tbl(i).service_line_id);
                    AHL_DEBUG_PUB.debug('Sch ON for ' || i ||':' || l_pm_schedule_tbl(i).schedule_on);
                    AHL_DEBUG_PUB.debug('Sch Start for ' || i ||':' || l_pm_schedule_tbl(i).schedule_from);
                    AHL_DEBUG_PUB.debug('Sch End for ' || i ||':' || l_pm_schedule_tbl(i).schedule_to);
                 end loop;
           END IF;
        END IF;

        -- Write due dates into ahl temporary table.
        IF (l_pm_schedule_tbl.COUNT > 0) THEN
          l_first_array_index := l_pm_schedule_tbl.FIRST;
          /* date associated to this index will be set as 'next due' occurrence */

          FOR i IN l_pm_schedule_tbl.FIRST..l_pm_schedule_tbl.LAST LOOP

            -- initialize.
            l_due_date := NULL;
            l_temp_unit_effectivity_rec := l_temp_ue_initrec;

            IF (l_pm_schedule_tbl(i).schedule_on IS NOT NULL) AND
             (l_pm_schedule_tbl(i).schedule_on <> FND_API.G_MISS_DATE) THEN
                 l_due_date := l_pm_schedule_tbl(i).schedule_on;
            ELSIF (l_pm_schedule_tbl(i).schedule_to IS NOT NULL) AND
             (l_pm_schedule_tbl(i).schedule_to <> FND_API.G_MISS_DATE) THEN
                 l_due_date := l_pm_schedule_tbl(i).schedule_to;
            END IF;

            -- write into temporary table if due date is not null.
            IF (l_due_date IS NOT NULL) THEN

              -- Build temporary table record.
              l_temp_unit_effectivity_rec.due_date := l_due_date;
              l_temp_unit_effectivity_rec.csi_item_instance_id := sch_activity_rec.csi_item_instance_id;
              l_temp_unit_effectivity_rec.mr_header_id := sch_activity_rec.mr_header_id;
              l_temp_unit_effectivity_rec.program_mr_header_id := sch_activity_rec.program_mr_header_id;
              l_temp_unit_effectivity_rec.service_line_id := sch_activity_rec.service_line_id;
              -- Added for ER# 2636001.
              IF (l_pm_schedule_tbl(i).schedule_from IS NOT NULL AND
                  l_pm_schedule_tbl(i).schedule_from <> FND_API.G_MISS_DATE) THEN
                 l_temp_unit_effectivity_rec.earliest_due_date := l_pm_schedule_tbl(i).schedule_from;
              END IF;
              IF (l_pm_schedule_tbl(i).schedule_to IS NOT NULL AND
                  l_pm_schedule_tbl(i).schedule_to <> FND_API.G_MISS_DATE) THEN
                 l_temp_unit_effectivity_rec.latest_due_date := l_pm_schedule_tbl(i).schedule_to;
              END IF;

              -- increment forecast sequence.
              l_forecast_sequence := l_forecast_sequence + 1;
              l_temp_unit_effectivity_rec.forecast_sequence := l_forecast_sequence;

              -- set repetitive mr flag.
              IF (i = l_first_array_index) THEN
                 l_temp_unit_effectivity_rec.repetitive_mr_flag := 'N';
              ELSE
                 l_temp_unit_effectivity_rec.repetitive_mr_flag := 'Y';
              END IF;

              -- create record in temporary table.
              Create_Temp_Unit_Effectivity (l_temp_unit_effectivity_rec);

            END IF;

            -- Check show_repetitive_code value.
            -- If it is = 'NEXT' then exit loop as repetities need not be shown in UMP.
            IF (sch_activity_rec.show_repetitive_code = 'NEXT') THEN
               EXIT;
            END IF;

          END LOOP; /* next record from pm_schedule */

        END IF; /* count */
    --END IF; /* one time mr flag */

    -- Delete duplicate programs/contracts for this mr_header_id if they exist.
    l_del_SQLstmt_str := 'DELETE FROM ahl_applicable_mrs' ||
                         ' WHERE mr_header_id = :1 AND pm_schedule_exists = ''N'' '||
                         ' AND service_line_id <> :2';

    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.Debug('SQL string:' || l_del_SQLstmt_str);
    END IF;

    EXECUTE IMMEDIATE l_del_SQLstmt_str USING  sch_activity_rec.mr_header_id,
                                               sch_activity_rec.service_line_id;

    --CLOSE ahl_cont_scheduled_csr;
  END LOOP; /* for ahl_sch_program_csr */

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug('End of PROCESS_PMSCH_ACTIVITIES procedure');
  END IF;

END Process_PMSch_Activities;
----------------------------------------------------------

PROCEDURE Process_PMUnSch_Activities(p_current_usage_tbl IN counter_values_tbl_type)
IS

  -- get all programs which have no contract dates scheduled.
  CURSOR ahl_UnSch_activity_csr IS
    SELECT DISTINCT appl.mr_header_id,
                    appl.csi_item_instance_id,
                    appl.whichever_first_code,
                    appl.repetitive_flag,
                    appl.show_repetitive_code,
                      mr.effective_to,
                      mr.effective_from
    FROM ahl_applicable_mrs appl, ahl_mr_headers_b mr
    WHERE appl.mr_header_id = mr.mr_header_id AND
          appl.pm_schedule_exists = 'N';

  l_last_day_of_window   DATE;
  l_next_due_flag        BOOLEAN;
  l_last_due_date        DATE;
  l_due_date             DATE;
  l_forecast_sequence    NUMBER;
  l_return_value         BOOLEAN;
  l_contract_found_flag  BOOLEAN;
  l_contract_override_due_date DATE;
  l_cont_override_earliest_due DATE;
  l_cont_override_latest_due   DATE;

  -- parameter for calculate_due_date procedure.
  l_next_due_date_rec         next_due_date_rec_type;

  l_program_mr_header_id NUMBER;
  l_service_line_id      NUMBER;
  l_contract_start_date  DATE;

  -- parameters to call get_accomplishment_details procedure.
  l_counter_rules_tbl         counter_rules_tbl_type;
  l_last_accomplishment_date  DATE;
  l_last_acc_counter_val_tbl  counter_values_tbl_type;
  l_dependent_mr_flag         BOOLEAN;
  l_get_preceding_next_due    BOOLEAN;
  l_one_time_mr_flag          BOOLEAN;
  l_last_due_counter_val_tbl  counter_values_tbl_type;
  l_due_at_counter_val_tbl    counter_values_tbl_type;

  l_applicable_mrs_rec        applicable_mrs_rec_type;

  l_temp_unit_effectivity_rec ahl_temp_unit_effectivities%ROWTYPE;
  l_temp_ue_initrec           ahl_temp_unit_effectivities%ROWTYPE;

  -- Added for bug# 6711228
  l_no_forecast_flag          BOOLEAN;
  l_mr_accomplish_exists      BOOLEAN;

  -- Added to fix bug# 6858788.
  l_last_due_mr_interval_id   NUMBER;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start of process_pmunsch_activities procedure');
  END IF;

  FOR appl_mrs_rec IN ahl_UnSch_activity_csr LOOP

    -- initialize.
    l_forecast_sequence := 0;

    -- build applicable_mrs_rec.
    l_applicable_mrs_rec.mr_header_id := appl_mrs_rec.mr_header_id;
    l_applicable_mrs_rec.csi_item_instance_id := appl_mrs_rec.csi_item_instance_id;
    l_applicable_mrs_rec.whichever_first_code := appl_mrs_rec.whichever_first_code;
    l_applicable_mrs_rec.repetitive_flag := appl_mrs_rec.repetitive_flag;
    l_applicable_mrs_rec.show_repetitive_code := appl_mrs_rec.show_repetitive_code;
    l_applicable_mrs_rec.effective_to := appl_mrs_rec.effective_to;
    l_applicable_mrs_rec.effective_from := appl_mrs_rec.effective_from;

    IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('Processing for:' || appl_mrs_rec.mr_header_id);
    END IF;

    -- Set last accomplishment details.
    Get_accomplishment_details(p_applicable_mrs_rec => l_applicable_mrs_rec,
                               p_current_usage_tbl  => p_current_usage_tbl,
                               p_counter_rules_tbl  => l_counter_rules_tbl, -- empty table. n/a for PM installation.
                               x_accomplishment_date => l_last_accomplishment_date,
                               x_last_acc_counter_val_tbl => l_last_acc_counter_val_tbl,
                               x_one_time_mr_flag         => l_one_time_mr_flag,
                               x_dependent_mr_flag => l_dependent_mr_flag,
                               x_get_preceding_next_due => l_get_preceding_next_due,
                               x_mr_accomplish_exists  => l_mr_accomplish_exists,
                               x_no_forecast_flag => l_no_forecast_flag );

    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.Debug('Start of process_pmunsch_activities procedure');
    END IF;

    -- No need to check l_no_forecast_flag as this does not apply to PM flow.
    -- Check for one time MR case and process otherwise only.
    IF NOT(l_one_time_mr_flag) THEN
       --dbms_output.put_line('Not one time MR');

       -- Calculate next due date.
       -- Added parameter p_dependent_mr_flag to fix bug# 6711228. Issue does
       -- not impact PM calculation.
       Calculate_Due_Date (p_repetivity_flag => 'N',
                           p_applicable_mrs_rec => l_applicable_mrs_rec,
                           p_current_usage_tbl => p_current_usage_tbl,
                           p_counter_rules_tbl => l_counter_rules_tbl,   -- empty table. n/a for PM installation.
                           p_last_due_date => l_last_accomplishment_date,
                           p_last_due_counter_val_tbl => l_last_acc_counter_val_tbl,
                           p_dependent_mr_flag => l_dependent_mr_flag,
                           p_mr_accomplish_exists  => l_mr_accomplish_exists,
                           x_next_due_date_rec => l_next_due_date_rec);
      IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('Aft calculate_due_date nextdue');
        AHL_DEBUG_PUB.Debug('due date is ' || l_next_due_date_rec.DUE_DATE);
      END IF;

      l_next_due_flag := TRUE;
      /* next due mr calculation. */

      -- set last due_date values to current values.
      l_last_due_date := sysdate;
      l_last_due_counter_val_tbl := p_current_usage_tbl;

      -- process next due and repetivity.
      LOOP

        -- initialize program and service line for the calculated due date.
        l_program_mr_header_id := NULL;
        l_service_line_id      := NULL;
        l_contract_found_flag  := FALSE;
        l_contract_override_due_date := NULL;

        -- Set due_date from l_next_due_date_rec.
        l_due_date := l_next_due_date_rec.DUE_DATE;

        IF (l_next_due_flag = TRUE) OR
              -- In the case of next-due, if l_due_date is null, get the earliest
              -- contract date and program available for the activity; else if
              -- l_due_date is not null, get the appropriate contract.
           (l_next_due_flag = FALSE AND l_due_date IS NOT NULL AND
            trunc(l_due_date) <= trunc(g_last_day_of_window))
              -- In the case of repetity and l_due_date is not null.
        THEN

           -- get program and service_line_id for the due date calculated.
           get_PMprogram(p_csi_item_instance_id   => appl_mrs_rec.csi_item_instance_id,
                         p_mr_header_id           => appl_mrs_rec.mr_header_id,
                         p_last_due_date          => l_last_due_date,
                         p_due_date               => l_due_date,
                         p_earliest_due           => l_next_due_date_rec.earliest_due_date,
                         p_latest_due             => l_next_due_date_rec.latest_due_date,
                         x_program_mr_header_id   => l_program_mr_header_id,
                         x_service_line_id        => l_service_line_id,
                         x_contract_override_due_date  => l_contract_override_due_date,
                         x_cont_override_earliest_due  => l_cont_override_earliest_due,
                         x_cont_override_latest_due    => l_cont_override_latest_due,
                         x_contract_found_flag         => l_contract_found_flag);

           -- write into temporary table if contract found.
           IF (l_contract_found_flag) THEN

                 IF G_DEBUG = 'Y' THEN
                    AHL_DEBUG_PUB.debug('contract found for due date:' ||l_due_date);
                    AHL_DEBUG_PUB.debug('contract found with override date:' || l_contract_override_due_date);
                    AHL_DEBUG_PUB.debug('contract found with override earliest:' || l_cont_override_earliest_due);
                    AHL_DEBUG_PUB.debug('contract found with override latest:' || l_cont_override_latest_due);
                 END IF;

                 IF (l_contract_override_due_date IS NOT NULL) THEN

                    l_next_due_date_rec.due_date := l_contract_override_due_date;
                    l_due_date := l_contract_override_due_date;

                    -- set due counter value and related data to null; as we do not know
                    -- the triggered counter value as on l_contract_override_due_date.
                    l_next_due_date_rec.due_at_counter_value := null;
                    l_next_due_date_rec.mr_effectivity_id    := null;
                    l_next_due_date_rec.mr_interval_id       := null;
                    l_next_due_date_rec.tolerance_flag       := null;
                    l_next_due_date_rec.tolerance_before      := null;
                    l_next_due_date_rec.tolerance_after      := null;
                    l_next_due_date_rec.message_code         := null;
                    l_next_due_date_rec.counter_id         := null;

                 END IF;

                 -- Added for ER# 2636001.
                 IF (l_cont_override_earliest_due IS NOT NULL) THEN
                    l_next_due_date_rec.earliest_due_date := l_cont_override_earliest_due;
                 END IF;
                 IF (l_cont_override_latest_due IS NOT NULL) THEN
                    l_next_due_date_rec.latest_due_date := l_cont_override_latest_due;
                 END IF;

                 -- Build temporary table record.
                 l_temp_unit_effectivity_rec := l_temp_ue_initrec; -- initialize.

                 l_temp_unit_effectivity_rec.due_date := l_due_date;
                 l_temp_unit_effectivity_rec.csi_item_instance_id := appl_mrs_rec.csi_item_instance_id;
                 l_temp_unit_effectivity_rec.mr_header_id := appl_mrs_rec.mr_header_id;
                 l_temp_unit_effectivity_rec.program_mr_header_id := l_program_mr_header_id;
                 l_temp_unit_effectivity_rec.service_line_id := l_service_line_id;
                 l_temp_unit_effectivity_rec.mr_effectivity_id := l_next_due_date_rec.mr_effectivity_id;
                 l_temp_unit_effectivity_rec.mr_interval_id := l_next_due_date_rec.mr_interval_id;
                 l_temp_unit_effectivity_rec.due_counter_value := l_next_due_date_rec.due_at_counter_value;
                 l_temp_unit_effectivity_rec.tolerance_flag := l_next_due_date_rec.tolerance_flag;
                 l_temp_unit_effectivity_rec.tolerance_before := l_next_due_date_rec.tolerance_before;
                 l_temp_unit_effectivity_rec.tolerance_after := l_next_due_date_rec.tolerance_after;
                 l_temp_unit_effectivity_rec.message_code := l_next_due_date_rec.message_code;
                 l_temp_unit_effectivity_rec.preceding_check_flag:= 'N';
                 --Added for ER# 2636001.
                 l_temp_unit_effectivity_rec.earliest_due_date := l_next_due_date_rec.earliest_due_date;
                 l_temp_unit_effectivity_rec.latest_due_date := l_next_due_date_rec.latest_due_date;
                 -- Added to fix bug#
                 l_temp_unit_effectivity_rec.counter_id := l_next_due_date_rec.counter_id;

                 -- increment forecast sequence.
                 l_forecast_sequence := l_forecast_sequence + 1;
                 l_temp_unit_effectivity_rec.forecast_sequence := l_forecast_sequence;

                 -- set repetivity based on next_due_flag.
                 IF (l_next_due_flag) THEN
                    l_temp_unit_effectivity_rec.repetitive_mr_flag := 'N';
                 ELSE
                    l_temp_unit_effectivity_rec.repetitive_mr_flag := 'Y';
                 END IF;

                 -- create record in temporary table.
                 Create_Temp_Unit_Effectivity (l_temp_unit_effectivity_rec);

                 -- Set next due flag to FALSE after writing record into temporary unit_effectivity.
                 IF (l_next_due_flag) THEN
                     l_next_due_flag := FALSE;
                 END IF;

                 -- Added to fix bug# 6858788
                 l_last_due_mr_interval_id := l_next_due_date_rec.mr_interval_id;

           END IF; -- l_contract_found_flag.

        END IF; --l_next_due_flag

        -- exit to process next activity.
        EXIT WHEN (l_next_due_flag = FALSE AND l_next_due_date_rec.DUE_DATE IS NULL) OR  -- calculate_due_date returns null.
                  (l_next_due_flag = FALSE AND trunc(l_next_due_date_rec.DUE_DATE) > trunc(g_last_day_of_window)) OR
                  (l_next_due_date_rec.due_date IS NOT NULL AND appl_mrs_rec.effective_to IS NOT NULL AND trunc(l_next_due_date_rec.due_date) > trunc(appl_mrs_rec.effective_to)) OR
                  (l_next_due_flag = FALSE AND appl_mrs_rec.show_repetitive_code = 'NEXT') OR
                  (l_contract_found_flag = FALSE);  -- contract not available.

        -- If due date is a past date, then set it to sysdate.
        -- This will happen only when calculating next-due date.
        IF (trunc(l_due_date) < trunc(sysdate)) THEN
          l_due_date := sysdate;
        END IF;

        IF G_DEBUG = 'Y' THEN
           AHL_DEBUG_PUB.Debug('Processing for repetivity');
           AHL_DEBUG_PUB.Debug('l_last_due_date: '|| l_last_due_date);
           AHL_DEBUG_PUB.Debug('l_due_date: '|| l_due_date);
           IF (l_last_due_counter_val_tbl.COUNT > 0) THEN
              FOR i in l_last_due_counter_val_tbl.FIRST..l_last_due_counter_val_tbl.LAST LOOP
                AHL_DEBUG_PUB.Debug('i:'|| i|| ' value:' || l_last_due_counter_val_tbl(i).counter_value || 'ID: ' || l_last_due_counter_val_tbl(i).counter_id);
              END LOOP;
           END IF;
        END IF;


        -- get all counter values as on l_due_date.
        Get_Due_at_Counter_Values (p_last_due_date => l_last_due_date,
                                   p_last_due_counter_val_tbl => l_last_due_counter_val_tbl,
                                   p_due_date => l_due_date,
                                   p_counter_rules_tbl => l_counter_rules_tbl,
                                   x_due_at_counter_val_tbl => l_due_at_counter_val_tbl,
                                   x_return_value => l_return_value);

        IF NOT(l_return_value) THEN  -- no forecast case.
           --dbms_output.put_line('l_return_value is false');
           EXIT;
        END IF;

        -- set current values to previous values.
        l_last_due_date := l_due_date;
        l_last_due_counter_val_tbl := l_due_at_counter_val_tbl;

        IF G_DEBUG = 'Y' THEN
           AHL_DEBUG_PUB.Debug('AFter get_due_at_counter_values');
           AHL_DEBUG_PUB.Debug('l_last_due_date: '|| l_last_due_date);
           AHL_DEBUG_PUB.Debug('l_due_date: '|| l_due_date);
           IF (l_due_at_counter_val_tbl.COUNT) > 0 THEN
               FOR i in l_due_at_counter_val_tbl.FIRST..l_due_at_counter_val_tbl.LAST LOOP
                   AHL_DEBUG_PUB.Debug('i:'|| i|| ' value:' || l_due_at_counter_val_tbl(i).counter_value || 'ID: ' || l_due_at_counter_val_tbl(i).counter_id);
               end loop;
           END IF;
       END IF;

        -- Calculate next due date.
        Calculate_Due_Date (p_repetivity_flag => 'Y',
                            p_applicable_mrs_rec => l_applicable_mrs_rec,
                            p_current_usage_tbl => p_current_usage_tbl,
                            p_counter_rules_tbl => l_counter_rules_tbl,
                            p_last_due_date => l_last_due_date,
                            p_last_due_counter_val_tbl => l_last_due_counter_val_tbl,
                            p_mr_accomplish_exists  => l_mr_accomplish_exists,
                            p_last_due_mr_interval_id => l_last_due_mr_interval_id,
                            x_next_due_date_rec => l_next_due_date_rec);

        IF G_DEBUG = 'Y' THEN
           AHL_DEBUG_PUB.Debug('aft calculate_due_date - repetivity');
           AHL_DEBUG_PUB.Debug('due date is ' || l_next_due_date_rec.DUE_DATE);
        END IF;

        -- Check if calculated date is same as last due date. If they are the same then, add one day.
        IF (l_next_due_date_rec.due_date IS NOT NULL) THEN
           IF (trunc(l_last_due_date) = trunc(l_next_due_date_rec.due_date)) THEN
               l_next_due_date_rec.due_date := l_next_due_date_rec.due_date + 1;
               l_next_due_date_rec.EARLIEST_DUE_DATE := NULL;
               l_next_due_date_rec.latest_due_date := NULL;

               IF G_DEBUG = 'Y' THEN
                 AHL_DEBUG_PUB.Debug('Adding one day to l_next_due_date_rec.due_date:' || l_next_due_date_rec.due_date);
               END IF;

               --IF G_DEBUG = 'Y' THEN
               --   AHL_DEBUG_PUB.Debug('Exiting build effectivity as last due = due date');
               --END IF;
               --EXIT;
           END IF;
        END IF;

      END LOOP; /* process repetivity. */

    END IF; /* one time mr */

  END LOOP; /* ahl_UnSch_contracts_csr */

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug('End of process_pmunsch_activities procedure');
  END IF;

END Process_PMUnSch_Activities;

---------------------------------------------
-- Procedure to find the service_line_id and program for a calculated due_date.
-- The calculated due_date may be overridden by the contract/program dates.
-- Also the earliest due and latest due date will get adjusted if they are not
-- within the contract and program start/end dates.

PROCEDURE Get_PMprogram(p_csi_item_instance_id       IN  NUMBER,
                        p_mr_header_id               IN  NUMBER,
                        p_last_due_date              IN  DATE,
                        p_due_date                   IN  DATE,
                        p_earliest_due               IN  DATE,
                        p_latest_due                 IN  DATE,
                        x_program_mr_header_id       OUT NOCOPY NUMBER,
                        x_service_line_id            OUT NOCOPY NUMBER,
                        x_contract_override_due_date OUT NOCOPY DATE,
                        x_cont_override_earliest_due OUT NOCOPY DATE,
                        x_cont_override_latest_due   OUT NOCOPY DATE,
                        x_contract_found_flag        OUT NOCOPY BOOLEAN)
IS

  -- get contract/program for a given due date.
  CURSOR ahl_contract_exists_csr(p_mr_header_id  IN NUMBER,
                                 p_due_date      IN DATE) IS
    SELECT program_mr_header_id,
           service_line_id, contract_start_date, contract_end_date, program_end_date
    FROM ahl_applicable_mrs
    WHERE mr_header_id = p_mr_header_id
      AND pm_schedule_exists = 'N'
      AND trunc(program_end_date) >= trunc(p_due_date) -- eliminate expired programs.
      AND trunc(p_due_date) >= trunc(contract_start_date)
      AND trunc(p_due_date) <= LEAST(trunc(contract_end_date), nvl(trunc(program_end_date),trunc(contract_end_date)))
    ORDER BY contract_start_date;

  -- get the next contract (if available).
  CURSOR ahl_next_contract_csr (p_mr_header_id IN NUMBER,
                                p_due_date     IN DATE) IS
    SELECT program_mr_header_id,
           service_line_id,
           contract_start_date, contract_end_date, program_end_date
    FROM ahl_applicable_mrs
    WHERE pm_schedule_exists = 'N'
      AND trunc(program_end_date) >= trunc(p_due_date) -- eliminate expired programs.
      AND mr_header_id = p_mr_header_id
      AND trunc(p_due_date) <= trunc(contract_start_date)
    ORDER BY contract_start_date;


  l_program_mr_header_id  NUMBER;
  /* program header id for the due date. */

  l_service_line_id    NUMBER;
  /* service line id for the due date. */

  l_due_date           DATE := p_due_date;

  l_contract_start_date DATE;
  l_program_end_date    DATE;
  l_contract_end_date   DATE;

  l_contract_override_due_date  DATE := NULL;
  -- this is set only if there exists no contract for the
  -- input due date but there is a contract that starts at
  -- a later date.


BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug('Start of Get_PMprogram procedure for MR:Due Date is: ' ||
            p_mr_header_id || ':' || p_due_date);
  END IF;

  -- Initialize.
  x_program_mr_header_id := NULL;
  x_service_line_id := NULL;
  x_contract_override_due_date := NULL;
  x_contract_found_flag := FALSE;
  x_cont_override_earliest_due := NULL;
  x_cont_override_latest_due := NULL;

  -- if p_due_date is null, set it = sysdate; so that it picks ups the earliest contract.
  IF (l_due_date IS NULL) THEN
      l_due_date := sysdate;
  END IF;

  -- Check if calculated due date belongs to any contracts.
  OPEN ahl_contract_exists_csr (p_mr_header_id,
                                l_due_date);
  FETCH ahl_contract_exists_csr INTO l_program_mr_header_id,
                                     l_service_line_id,
                                     l_contract_start_date,
                                     l_contract_end_date,
                                     l_program_end_date;
  IF (ahl_contract_exists_csr%FOUND) THEN
     x_program_mr_header_id := l_program_mr_header_id;
     x_service_line_id := l_service_line_id;
     x_contract_override_due_date := NULL;
     x_contract_found_flag := TRUE;

     -- In the case due_date is null, return sysdate as due date.
     IF (p_due_date IS NULL) THEN
        x_contract_override_due_date := l_due_date;
     END IF;
     -- Added for ER# 2636001.
     IF (trunc(p_earliest_due) < trunc(l_contract_start_date)) THEN
       x_cont_override_earliest_due := l_contract_start_date;
     END IF;
     -- if program end date not available, then replace with contract end date.
     IF (trunc(p_latest_due) > LEAST(trunc(l_contract_end_date),
                                     trunc(nvl(l_program_end_date, l_contract_end_date))))
     THEN
         x_cont_override_latest_due  := LEAST(trunc(l_contract_end_date),
                                              trunc(nvl(l_program_end_date,l_contract_end_date)));
     END IF;

  ELSE
    -- Look for next contract if exists.
    OPEN ahl_next_contract_csr (p_mr_header_id, l_due_date);
    FETCH ahl_next_contract_csr INTO l_program_mr_header_id,
                                     l_service_line_id,
                                     l_contract_start_date,
                                     l_contract_end_date,
                                     l_program_end_date;
      IF (ahl_next_contract_csr%FOUND) THEN
         x_program_mr_header_id := l_program_mr_header_id;
         x_service_line_id := l_service_line_id;
         x_contract_override_due_date := l_contract_start_date;
         x_contract_found_flag := TRUE;

         -- Added for ER# 2636001.
         IF (trunc(p_earliest_due) < trunc(l_contract_start_date)) THEN
           x_cont_override_earliest_due := l_contract_start_date;
         END IF;
         -- if program end date not available, then replace with contract end date.
         IF (trunc(p_latest_due) > LEAST(trunc(l_contract_end_date),
                                         trunc(nvl(l_program_end_date, l_contract_end_date))))
         THEN
             x_cont_override_latest_due  := LEAST(trunc(l_contract_end_date),
                                                  trunc(nvl(l_program_end_date,l_contract_end_date)));
         END IF;

      END IF;

    CLOSE ahl_next_contract_csr;
  END IF;
  CLOSE ahl_contract_exists_csr;

  IF G_DEBUG = 'Y' THEN
    IF NOT(x_contract_found_flag) THEN
      AHL_DEBUG_PUB.debug('Contract Not Found');
    END IF;
    AHL_DEBUG_PUB.debug('End of Get_PMprogram procedure');
  END IF;

END Get_PMprogram;

-------------------------------------------------------------
-- After creation of all maintenance requirements for the instance in the temporary table,
-- assign unit effectivity IDs from existing un-accomplished maintenance requirements
-- belonging to the same instance from ahl_unit_effectivities_b.
PROCEDURE Assign_Unit_Effectivity_IDs IS

  -- Added service_line_id to fix FP bug# 5481605.
  -- read temporary table sequentially.
  CURSOR ahl_mr_header_csr IS
    SELECT DISTINCT mr_header_id, csi_item_instance_id, service_line_id
    FROM ahl_temp_unit_effectivities;

  -- retrieve current unit effectivity records.
  CURSOR ahl_unit_effectivity_csr (p_csi_item_instance_id IN NUMBER,
                                   p_mr_header_id IN NUMBER,
                                   p_service_line_id IN NUMBER,
                                   p_appl_usg_code   IN VARCHAR2) IS
    SELECT ue.unit_effectivity_id
    FROM   ahl_unit_effectivities_b UE
    WHERE  mr_header_id = p_mr_header_id
       AND csi_item_instance_id = p_csi_item_instance_id
       AND application_usg_code = p_appl_usg_code
       AND service_line_id = p_service_line_id
       AND (UE.Status_code IS NULL OR status_code IN ('INIT-DUE','DEFERRED'))
    --ORDER BY forecast_sequence ASC;
    ORDER BY unit_effectivity_id ASC;  -- fix FP bug# 5481605.

  CURSOR ahl_temp_effectivity_csr(p_csi_item_instance_id IN NUMBER,
                                  p_mr_header_id IN NUMBER,
                                  p_service_line_id IN NUMBER) IS
    SELECT unit_effectivity_id
    FROM ahl_temp_unit_effectivities
    WHERE mr_header_id = p_mr_header_id
       AND csi_item_instance_id = p_csi_item_instance_id
       AND service_line_id = p_service_line_id
    FOR UPDATE OF unit_effectivity_id
    ORDER BY forecast_sequence ASC;

  l_unit_effectivity_id  NUMBER;

  l_ue_id_tbl      nbr_tbl_type;
  l_appl_usg_code  ahl_unit_effectivities_b.application_usg_code%TYPE;

BEGIN

   IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug('Start of assign_unit_effectivity_ids procedure');
   END IF;

   -- Application usage code.
   l_appl_usg_code := FND_PROFILE.VALUE('AHL_APPLN_USAGE');

   -- For each mr_header_id assign the unit effectivity IDs.
   -- note: All mr's are for one item instance only.

   FOR mr_header_rec IN ahl_mr_header_csr LOOP
     --dbms_output.put_line('Processing for:' ||  mr_header_rec.mr_header_id);

     -- Added service_line_id to fix FP bug# 5481605.
     -- open temporary table cursor.
     OPEN ahl_temp_effectivity_csr(mr_header_rec.csi_item_instance_id,
                                   mr_header_rec.mr_header_id,
                                   mr_header_rec.service_line_id);

     -- loop through all unit_effectivity records.
     /*FOR unit_effectivity_rec IN ahl_unit_effectivity_csr(mr_header_rec.csi_item_instance_id,
                                                          mr_header_rec.mr_header_id,
                                                          mr_header_rec.service_line_id)
     */
     OPEN ahl_unit_effectivity_csr(mr_header_rec.csi_item_instance_id,
                                   mr_header_rec.mr_header_id,
                                   mr_header_rec.service_line_id,
                                   l_appl_usg_code);

     LOOP
       FETCH ahl_unit_effectivity_csr BULK COLLECT INTO l_ue_id_tbl LIMIT 1000;
       EXIT WHEN (l_ue_id_tbl.count = 0);

       IF (l_ue_id_tbl.count > 0) THEN
         FOR i IN l_ue_id_tbl.FIRST..l_ue_id_tbl.LAST LOOP

           -- Fetch record from temporary table.
           FETCH  ahl_temp_effectivity_csr INTO l_unit_effectivity_id;
           IF (ahl_temp_effectivity_csr%NOTFOUND) THEN
              -- exit ahl_unit_effectivity_csr loop as no more records to assign.
              EXIT;
           ELSE

              --dbms_output.put_line('found ue.unit_effectivity_id:' || unit_effectivity_rec.unit_effectivity_id);

              --l_unit_effectivity_id := unit_effectivity_rec.unit_effectivity_id;
              l_unit_effectivity_id := l_ue_id_tbl(i);

              -- update record.

              UPDATE ahl_temp_unit_effectivities
              SET unit_effectivity_id = l_unit_effectivity_id
              WHERE CURRENT OF ahl_temp_effectivity_csr;
           END IF; -- ahl_temp_effectivity_csr%NOTFOUND
         END LOOP; -- l_ue_id_tbl.FIRST
       END IF; -- l_ue_id_tbl.count > 0

       IF (ahl_temp_effectivity_csr%NOTFOUND) THEN
         EXIT; -- exit ahl_unit_effectivity_csr LOOP
       END IF;

       l_ue_id_tbl.DELETE;

     END LOOP; -- ahl_unit_effectivity_csr
     CLOSE ahl_temp_effectivity_csr;
     CLOSE ahl_unit_effectivity_csr;

   END LOOP; -- ahl_mr_header_csr.

   IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug('End of assign_unit_effectivity_ids procedure');
   END IF;

END Assign_Unit_Effectivity_IDs;

-------------------------------------------------------------
-- Procedure to calculate due date based on deferral details.
PROCEDURE Get_Deferred_Due_Date (p_unit_effectivity_id IN NUMBER,
                                 p_deferral_threshold_tbl IN  counter_values_tbl_type,
                                 x_due_date               OUT NOCOPY DATE,
                                 x_return_status          OUT NOCOPY VARCHAR2,
                                 x_msg_data               OUT NOCOPY VARCHAR2,
                                 x_msg_count              OUT NOCOPY NUMBER)
IS

  -- Get Unit Effectivity details.
  CURSOR ahl_unit_effectivity_csr (p_unit_effectivity_id IN NUMBER) IS
    SELECT csi_item_instance_id, mr_header_id
    FROM ahl_unit_effectivities_app_v
    WHERE unit_effectivity_id = p_unit_effectivity_id;

  -- Get MR details.
  CURSOR ahl_mr_headers_csr (p_mr_header_id IN NUMBER) IS
    SELECT whichever_first_code
    FROM ahl_mr_headers_app_v
    WHERE mr_header_id = p_mr_header_id;

  -- get the configuration structure.(G_config_node_tbl).
  CURSOR csi_reln_csr ( p_csi_item_instance_id IN NUMBER) IS
    SELECT position_reference
    FROM csi_ii_relationships
    WHERE subject_id = p_csi_item_instance_id
               AND relationship_type_code = 'COMPONENT-OF'
               AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
               AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

  -- get the counter usage
  CURSOR cs_ctr_counter_csr (p_csi_item_instance_id  IN NUMBER,
                             p_counter_id            IN NUMBER) IS
  /*
  SELECT nvl(net_reading, 0)
  FROM csi_cp_counters_v
  WHERE customer_product_id = p_csi_item_instance_id
    AND counter_id = p_counter_id;
  */

  SELECT nvl(cv.net_reading,0) net_reading
     FROM csi_counter_values_v cv
     WHERE cv.counter_id = p_counter_id
       AND cv.counter_id IN (select counter_id
                             from   csi_counter_associations cca
                             where  source_object_code = 'CP'
                             AND    source_object_id = p_csi_item_instance_id
                             AND    cca.counter_id = cv.counter_id)
       AND rownum < 2;

  i                       NUMBER;
  l_csi_item_instance_id  NUMBER;
  l_root_csi_instance_id  NUMBER;
  l_mr_header_id          NUMBER;
  l_uc_header_id          NUMBER;
  l_calc_due_date         DATE;
  l_due_date              DATE;
  l_whichever_first_code  ahl_mr_headers_app_v.whichever_first_code%TYPE;
  l_inv_master_organization_id number;
  l_inventory_item_id     number;
  l_position_reference    VARCHAR2(30);
  l_counter_rules_tbl     counter_rules_tbl_type;
  l_current_usage_tbl     counter_values_tbl_type;
  l_counter_value         number;
  l_counter_remain        number;

  -- Global variables.
  G_master_config_id      NUMBER;

BEGIN

  -- Set return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Enable Debug.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Add debug mesg.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Begin private API:' ||  G_PKG_NAME || '.' || 'Get_Deferred_Due_Date');
    AHL_DEBUG_PUB.debug('Dump of input parameters:');
    AHL_DEBUG_PUB.debug('Unit Effectivity ID:' || p_unit_effectivity_id);
    AHL_DEBUG_PUB.debug('Count on p_deferral_threshold_tbl:' || p_deferral_threshold_tbl.COUNT);
  END IF;

  -- Validate input parameters.
  IF (p_unit_effectivity_id IS NULL OR p_unit_effectivity_id = FND_API.G_MISS_NUM) THEN
     FND_MESSAGE.Set_Name('AHL','AHL_UMP_DEF_UE_NULL');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     OPEN ahl_unit_effectivity_csr (p_unit_effectivity_id);
     FETCH ahl_unit_effectivity_csr INTO l_csi_item_instance_id, l_mr_header_id;
     IF (ahl_unit_effectivity_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_DEF_UE_INVALID');
        FND_MESSAGE.Set_Token('UE_ID', p_unit_effectivity_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  IF (l_mr_header_id IS NOT NULL) THEN
     -- get MR details from ahl_mr_headers.
     OPEN ahl_mr_headers_csr(l_mr_header_id);
     FETCH ahl_mr_headers_csr INTO l_whichever_first_code;
     IF (ahl_mr_headers_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_UMP_DEF_MR_INVALID');
       FND_MESSAGE.Set_Token('UE_ID', p_unit_effectivity_id);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE ahl_mr_headers_csr;
  ELSE
     -- SR case.
     l_whichever_first_code := 'FIRST';
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Step 1');
    AHL_DEBUG_PUB.debug('MR Header ID:' || l_mr_header_id);
    AHL_DEBUG_PUB.debug('CSI Item Instance ID:' || l_csi_item_instance_id);
  END IF;

  -- Get Unit and Master Config IDs if available.
  -- Find the root item instance.
  l_root_csi_instance_id := Get_RootInstanceID(l_csi_item_instance_id);

  -- Get master and unit configuration for the root item instance.
  Get_Unit_Master_ConfigIDs (l_root_csi_instance_id,
                             l_uc_header_id, G_master_config_id);

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Step 2');
  END IF;

  -- Check for errors.
  IF FND_MSG_PUB.Count_msg > 0 THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Step 3');
  END IF;

  -- Get utilization forecast for the unit/part.
  Get_Utilization_Forecast (l_root_csi_instance_id,
                            l_uc_header_id,
                            l_inventory_item_id,
                            l_inv_master_organization_id,
                            G_forecast_details_tbl);

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Step 4');
    AHL_DEBUG_PUB.debug('Count on util forecast tbl:' || G_forecast_details_tbl.count);
  END IF;

  -- Get the position installed in.
  OPEN csi_reln_csr(l_csi_item_instance_id);
  FETCH csi_reln_csr INTO l_position_reference;
  IF (csi_reln_csr%NOTFOUND) THEN
     l_position_reference := G_master_config_id;
  END IF;
  CLOSE csi_reln_csr;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Step 5');
  END IF;

  -- Build counter rules ratio if node is not root node.
  IF (G_master_config_id IS NOT NULL AND l_position_reference IS NOT NULL) THEN
      build_Counter_Ratio(l_position_reference,
                          l_csi_item_instance_id,
                          G_master_config_id,
                          l_counter_rules_tbl);
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Step 6');
  END IF;

  -- Calculate counter_remain and call get_date_from_uf.
  IF (p_deferral_threshold_tbl.COUNT > 0) THEN
     FOR i IN p_deferral_threshold_tbl.FIRST..p_deferral_threshold_tbl.LAST LOOP
       -- get the usage based on deferral effective on.
       OPEN cs_ctr_counter_csr(l_csi_item_instance_id, p_deferral_threshold_tbl(i).counter_id);
       FETCH cs_ctr_counter_csr INTO l_counter_value;
       IF (cs_ctr_counter_csr%NOTFOUND) THEN
          IF G_DEBUG = 'Y' THEN
            AHL_DEBUG_PUB.debug('Step 7');
          END IF;
          l_counter_value := 0;
       END IF;

       CLOSE cs_ctr_counter_csr;

       IF G_DEBUG = 'Y' THEN
         AHL_DEBUG_PUB.debug('l_counter_value:' || l_counter_value);
       END IF;

       -- Get due date for counter remain.
       l_counter_remain := p_deferral_threshold_tbl(i).counter_value - l_counter_value;

       IF G_DEBUG = 'Y' THEN
         AHL_DEBUG_PUB.debug('l_counter_remain:' || l_counter_remain);
       END IF;

       -- get date from forecast.
       get_date_from_uf(l_counter_remain,
                        p_deferral_threshold_tbl(i).uom_code,
                        l_counter_rules_tbl,
                        sysdate,
                        l_due_date);

       IF (l_due_date IS NULL) THEN
           l_calc_due_date := NULL;
           EXIT;
       ELSIF (l_calc_due_date IS NULL) THEN
           l_calc_due_date := l_due_date;
       ELSIF (l_whichever_first_code = 'FIRST') THEN
           IF (trunc(l_due_date) < trunc(l_calc_due_date)) THEN
             l_calc_due_date := l_due_date;
           END IF;
       ELSIF (l_whichever_first_code = 'LAST') THEN
           IF (trunc(l_due_date) > trunc(l_calc_due_date)) THEN
             l_calc_due_date := l_due_date;
           END IF;
       END IF;

     END LOOP;
  END IF;
  x_due_date := l_calc_due_date;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;

 WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Get_Deferred_Due_Date',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


    -- Disable debug
    AHL_DEBUG_PUB.disable_debug;

END Get_Deferred_Due_Date;
------------------------------------------------------------------

-- Get the latest recorded counter reading for a given date.
PROCEDURE get_ctr_reading_for_date (p_csi_item_instance_id IN NUMBER,
                                    p_counter_id           IN NUMBER,
                                    p_reading_date         IN DATE,
                                    x_net_reading        OUT NOCOPY NUMBER) IS

  -- get the latest reading recorded for a counter on any given date.
  CURSOR cs_ctr_reading_csr(p_csi_item_instance_id IN NUMBER,
                            p_counter_id           IN NUMBER,
                            p_reading_date IN DATE) IS
    /*SELECT net_reading
    FROM cs_ctr_counter_values_v cv, cs_counter_groups cg
    WHERE cv.counter_group_id = cg.counter_group_id
      AND cg.source_object_code = 'CP'
      AND cg.source_object_id = p_csi_item_instance_id
      AND cv.counter_id = p_counter_id
      AND trunc(VALUE_TIMESTAMP) <= trunc(p_reading_date)
    ORDER BY cv.value_timestamp desc; */

	--priyan
	--Query being changed due to performance related fixes
	--Refer Bug # 4918744

        /* Commented out to fix bug# 6445866. In R12, IB is not instantiating
         * counter groups in CS_CSI_COUNTER_GROUPS.
	SELECT --DISTINCT
		CCR.NET_READING
	FROM
		CSI_COUNTERS_VL CC,
		--CS_COUNTER_GROUPS CCA,
		--priyan
		--changes for Bug #5207990.
		CS_CSI_COUNTER_GROUPS CCA,
		CSI_COUNTER_READINGS CCR
	WHERE
		CC.DEFAULTED_GROUP_ID (+)  = CCA.COUNTER_GROUP_ID
		AND CCA.SOURCE_OBJECT_CODE = 'CP'
		AND CCR.COUNTER_ID		   = CC.COUNTER_ID
		AND CCA.SOURCE_OBJECT_ID   = P_CSI_ITEM_INSTANCE_ID
		AND CC.COUNTER_ID          = P_COUNTER_ID
		AND TRUNC(CCR.VALUE_TIMESTAMP) <= TRUNC(P_READING_DATE)
	ORDER BY
		CCR.VALUE_TIMESTAMP DESC;

        */

        SELECT * FROM (
    	               SELECT CCR.NET_READING
  	               FROM
		               CSI_COUNTER_READINGS CCR
	               WHERE
		               CCR.COUNTER_ID          = P_COUNTER_ID
                               AND nvl(CCR.disabled_flag,'N') = 'N'
		               AND TRUNC(CCR.VALUE_TIMESTAMP) <= TRUNC(P_READING_DATE)
	               ORDER BY
		               CCR.VALUE_TIMESTAMP DESC
                      )
        WHERE rownum < 2;


  l_net_reading  NUMBER;

BEGIN

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug('Start of get_ctr_reading_for_date');
    END IF;

    OPEN cs_ctr_reading_csr(p_csi_item_instance_id,
                            p_counter_id,
                            p_reading_date);
    FETCH cs_ctr_reading_csr INTO l_net_reading;
    IF (cs_ctr_reading_csr%NOTFOUND) THEN
       l_net_reading := 0;
    END IF;
    CLOSE cs_ctr_reading_csr;

    x_net_reading := l_net_reading;

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug('End of get_ctr_reading_for_date');
    END IF;

END get_ctr_reading_for_date;
-----------------------------------------------------------------------

-- Get the earliest date on which a given reading was recorded.
PROCEDURE get_ctr_date_for_reading (p_csi_item_instance_id IN NUMBER,
                                    p_counter_id           IN NUMBER,
                                    p_counter_value        IN NUMBER,
                                    x_ctr_record_date    OUT NOCOPY DATE,
                                    x_return_val         OUT NOCOPY BOOLEAN) IS


  -- get the earliest reading for which the given counter value exceeds.
  CURSOR cs_ctr_reading_csr(p_csi_item_instance_id IN NUMBER,
                            p_counter_id           IN NUMBER,
                            p_counter_value        IN NUMBER) IS
    /*
	SELECT value_timestamp
    FROM cs_ctr_counter_values_v cv, cs_counter_groups cg
    WHERE cv.counter_group_id = cg.counter_group_id
      AND cg.source_object_code = 'CP'
      AND cg.source_object_id = p_csi_item_instance_id
      AND cv.counter_id = p_counter_id
      AND nvl(cv.net_reading,0) >= p_counter_value
    ORDER BY value_timestamp asc;
	*/

	--priyan
	--Query being changed due to performance related fixes
	--Refer Bug # 4918744

       /* Commented out to fix bug# 6445866. In R12, IB is not instantiating
        * counter groups in CS_CSI_COUNTER_GROUPS.

	SELECT --DISTINCT
		CCR.VALUE_TIMESTAMP
	FROM
		CSI_COUNTERS_VL CC,
		--CS_COUNTER_GROUPS CCA,
		--priyan
		--Refer Bug # 5207990 for changes.
		CS_CSI_COUNTER_GROUPS CCA,
		CSI_COUNTER_READINGS CCR
	WHERE
		CC.DEFAULTED_GROUP_ID (+)       = CCA.COUNTER_GROUP_ID
		 AND CCA.SOURCE_OBJECT_CODE		= 'CP'
		 AND CCR.COUNTER_ID				= CC.COUNTER_ID
		 AND CCA.SOURCE_OBJECT_ID		= P_CSI_ITEM_INSTANCE_ID
		 AND CC.COUNTER_ID				= P_COUNTER_ID
		 AND NVL(CCR.NET_READING,0)	>= P_COUNTER_VALUE
	ORDER BY
		CCR.VALUE_TIMESTAMP ASC;
        */

        SELECT * FROM (
                       SELECT CCR.VALUE_TIMESTAMP
                       FROM CSI_COUNTER_READINGS CCR
                       WHERE CCR.COUNTER_ID = P_COUNTER_ID
                         AND nvl(disabled_flag,'N') = 'N'
                         AND NVL(CCR.NET_READING,0) >= P_COUNTER_VALUE
                       ORDER BY CCR.VALUE_TIMESTAMP ASC
                      )
         WHERE rownum < 2;

  l_ctr_record_date    DATE;
  l_return_val         BOOLEAN := TRUE;

BEGIN


  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Start of get_ctr_date_for_reading');
  END IF;

  OPEN cs_ctr_reading_csr (p_csi_item_instance_id,
                           p_counter_id,
                           p_counter_value);
  FETCH cs_ctr_reading_csr INTO l_ctr_record_date;
  IF (cs_ctr_reading_csr%NOTFOUND) THEN
     l_return_val := FALSE;
     l_ctr_record_date := NULL;
  END IF;
  CLOSE cs_ctr_reading_csr;

  x_ctr_record_date := l_ctr_record_date;
  x_return_val := l_return_val;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('End of get_ctr_date_for_reading');
  END IF;

END get_ctr_date_for_reading;

-------------------------------------------------------------------------------
-- Calculate due date for all deferred unit effectivities.
PROCEDURE Process_Deferred_UE (p_csi_item_instance_id IN NUMBER,
                               p_current_usage_tbl  IN counter_values_tbl_type,
                               p_counter_rules_tbl  IN counter_rules_tbl_type)
IS

  -- get all deferred unit effectivity records for the instance and MR.
  CURSOR ahl_deferred_ue_csr (p_csi_item_instance_id IN NUMBER) IS

    SELECT
        UE.UNIT_EFFECTIVITY_ID,
        UE.OBJECT_TYPE,
        UE.CSI_ITEM_INSTANCE_ID,
        UE.MR_HEADER_ID,
        UE.STATUS_CODE,
        UE.DEFER_FROM_UE_ID,
        nvl(MR.whichever_first_code, 'FIRST') whichever_first_code,
        UDF.unit_deferral_type, UE.CS_INCIDENT_ID, UDF.DEFERRAL_EFFECTIVE_ON,
        UDF.AFFECT_DUE_CALC_FLAG, UDF.SET_DUE_DATE, UDF.unit_deferral_id
    FROM ahl_unit_effectivities_app_v UE, ahl_unit_deferrals_b UDF, ahl_mr_headers_b MR
    WHERE UE.defer_from_ue_id = UDF.unit_effectivity_id
      AND UE.mr_header_id = MR.mr_header_id(+)
      AND csi_item_instance_id = p_csi_item_instance_id
      AND status_code IS NULL
      --AND defer_from_ue_id IS NOT NULL -- not required as joining table ahl_unit_deferrals_b
      AND UDF.unit_deferral_type IN ('DEFERRAL', 'MEL','CDL')
      AND NOT EXISTS (SELECT 'x'
                      FROM ahl_ue_relationships
                      WHERE related_ue_id = UE.unit_effectivity_id
                        AND relationship_code = 'PARENT')
      AND UDF.approval_status_code = 'DEFERRED'
    ORDER BY DEFERRAL_EFFECTIVE_ON ASC;

  /* Commented as we retrieve this info in ahl_deferred_ue_csr
  -- Get deferral detail from ahl_unit_deferrals.
  CURSOR ahl_unit_deferral_csr (p_deferred_from_ue_id IN NUMBER) IS
    SELECT AFFECT_DUE_CALC_FLAG, SET_DUE_DATE, unit_deferral_id, deferral_effective_on
    FROM ahl_unit_deferrals_b
    WHERE unit_effectivity_id = p_deferred_from_ue_id
      AND unit_deferral_type = 'DEFERRAL';
  */

  -- Get threshold details.
  CURSOR ahl_unit_threshold_csr (p_unit_deferral_id IN NUMBER) IS
    SELECT counter_id, counter_value, ctr_value_type_code
    FROM ahl_unit_thresholds
    WHERE unit_deferral_id = p_unit_deferral_id;

  -- Read applicable relns table for group MR details.
  CURSOR ahl_applicable_grp_csr( p_item_instance_id IN NUMBER,
                                 p_mr_header_id IN NUMBER) IS

    SELECT related_mr_header_id,
           related_csi_item_instance_id,
           csi_item_instance_id parent_csi_item_instance_id,
           mr_header_id parent_mr_header_id
    FROM ahl_applicable_mr_relns
    START WITH mr_header_id = p_mr_header_id AND
               csi_item_instance_id = p_item_instance_id AND
               orig_mr_header_id = p_mr_header_id AND
               orig_csi_item_instance_id = p_item_instance_id AND
               relationship_code = 'PARENT'
    CONNECT BY PRIOR related_mr_header_id = mr_header_id AND
               PRIOR related_csi_item_instance_id = csi_item_instance_id AND
               orig_mr_header_id = p_mr_header_id AND
               orig_csi_item_instance_id = p_item_instance_id AND
               relationship_code = 'PARENT'
    ORDER BY   level;

   -- check repair category for time limit.
   cursor get_repair_category_csr(p_cs_incident_id IN NUMBER)
    is
       select nvl(repair_time,0), cs.expected_resolution_date
       from ahl_repair_categories rc, cs_incidents_all_b cs
       where rc.sr_urgency_id(+) = cs.incident_urgency_id
         and  cs.incident_id = p_cs_incident_id;

   -- Read immediate children of the SR.
   CURSOR ahl_ue_reln_csr (p_ue_id  IN NUMBER) IS
     SELECT ue.unit_effectivity_id, ue.status_code,
            UE.CSI_ITEM_INSTANCE_ID, UE.MR_HEADER_ID
     FROM ahl_ue_relationships uer, ahl_unit_effectivities_app_v ue
     WHERE ue.unit_effectivity_id = uer.related_ue_id
       AND uer.ue_id = p_ue_id;

--
  l_due_at_counter_value   NUMBER;
  --l_affect_due_date_calc   VARCHAR2(1);
  l_set_due_date           DATE;
  l_unit_deferral_id       NUMBER;
  l_deferral_effective_on  DATE;
  l_net_reading            NUMBER;
  l_due_date               DATE;
  l_counter_read_date      DATE;

  l_counter_remain         NUMBER;
  l_current_ctr_value      NUMBER;
  k                        NUMBER;
  l_return_val             BOOLEAN;

  l_calc_due_date          DATE;
  l_calc_counter_id        NUMBER;
  l_calc_tolerance_flag    ahl_unit_effectivities_app_v.tolerance_flag%TYPE;
  l_calc_message_code      ahl_unit_effectivities_app_v.message_code%TYPE;
  l_calc_due_counter_value NUMBER;

  l_visit_start_date       DATE;
  l_visit_end_date         DATE;
  l_visit_assign_code      fnd_lookups.lookup_code%TYPE;

  l_grp_match              VARCHAR2(1);
  l_grp_match1             VARCHAR2(1);

  l_unit_deferral_type     VARCHAR2(30);
  l_repair_time            NUMBER;
  l_expected_resolutn_date DATE;

  l_visit_status           ahl_visits_b.status_code%TYPE;

BEGIN

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Start of process_Deferred_ue');
  END IF;

  -- get all open deferred unit effectivities.
  FOR unit_effectivity_rec IN ahl_deferred_ue_csr(p_csi_item_instance_id) LOOP

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug('Processing ..ID:' || unit_effectivity_rec.unit_effectivity_id);
      AHL_DEBUG_PUB.debug('Processing ..unit_deferral_type:' || unit_effectivity_rec.unit_deferral_type);
    END IF;

    -- Initialize.
    l_calc_due_date := null;
    --l_calc_counter_id,
    l_calc_due_counter_value := null;
    l_calc_tolerance_flag := null;
    l_calc_message_code := null;

IF (unit_effectivity_rec.unit_deferral_type = 'DEFERRAL') THEN

        -- get deferral details.
        l_set_due_date         := unit_effectivity_rec.set_due_date;
        l_unit_deferral_id     := unit_effectivity_rec.unit_deferral_id;
        l_deferral_effective_on := unit_effectivity_rec.deferral_effective_on;

        /*
        OPEN ahl_unit_deferral_csr(unit_effectivity_rec.defer_from_ue_id);
        FETCH ahl_unit_deferral_csr INTO l_affect_due_date_calc, l_set_due_date, l_unit_deferral_id,
                                         l_deferral_effective_on;
        IF (ahl_unit_deferral_csr%NOTFOUND) THEN
           CLOSE  ahl_unit_deferral_csr;
           FND_MESSAGE.Set_Name('AHL','AHL_UMP_DEF_NOTFOUND');
           FND_MESSAGE.Set_Token('UE_ID',unit_effectivity_rec.defer_from_ue_id);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        CLOSE  ahl_unit_deferral_csr;
        */
        -- process threshold details for this deferral.
        FOR threshold_rec IN ahl_unit_threshold_csr(l_unit_deferral_id) LOOP
          l_due_at_counter_value := threshold_rec.counter_value;
          l_counter_remain := 0;
          l_current_ctr_value := 0;
          k := 0;
          -- search for the current counter value in p_current_usage_tbl.
          IF (p_current_usage_tbl.COUNT > 0) THEN
             FOR i IN p_current_usage_tbl.FIRST..p_current_usage_tbl.LAST LOOP
               IF (p_current_usage_tbl(i).counter_id = threshold_rec.counter_id) THEN
                  l_current_ctr_value := p_current_usage_tbl(i).counter_value;
                  k := i;
                  EXIT;
               END IF;
             END LOOP;

             IF G_DEBUG = 'Y' THEN
               AHL_DEBUG_PUB.debug('In threshold rec with current usg > 0: ctr val:eff on:ctr type:' || l_current_ctr_value ||':' || l_deferral_effective_on || ':' || threshold_rec.ctr_value_type_code);

             END IF;

             -- Calculate counter remain.
             IF (threshold_rec.ctr_value_type_code = 'DEFER_BY') THEN
                -- get counter usage as on deferral_effective_on date.
                get_ctr_reading_for_datetime (p_csi_item_instance_id => p_csi_item_instance_id,
                                              p_counter_id           => p_current_usage_tbl(k).counter_id,
                                              p_reading_date         => l_deferral_effective_on,
                                              x_net_reading          => l_net_reading);

                -- add net reading to the threshold value.
                l_due_at_counter_value := l_net_reading + l_due_at_counter_value;
             END IF; -- defer by.

             l_counter_remain := l_due_at_counter_value - l_current_ctr_value;

             --dbms_output.put_line ('After reading:ctr remain' || l_counter_remain);

             -- calculate due date from forecast.
             IF (l_counter_remain > 0) THEN
                --dbms_output.put_line ('counter remain greater than zero');
                -- get date from forecast.
                get_date_from_uf(l_counter_remain,
                                 p_current_usage_tbl(k).uom_code,
                                 p_counter_rules_tbl,
                                 null, /* start date = sysdate */
                                 l_due_date);
             ELSIF (l_counter_remain < 0) THEN
                 --dbms_output.put_line ('counter remain less than zero');
                 -- Due date = counter reading date.
                 get_ctr_date_for_reading (p_csi_item_instance_id => p_csi_item_instance_id,
                                           p_counter_id           => p_current_usage_tbl(k).counter_id,
                                           p_counter_value        => l_due_at_counter_value,
                                           x_ctr_record_date      => l_counter_read_date,
                                           x_return_val           => l_return_val);

                 IF NOT(l_return_val) THEN
                    l_due_date := sysdate;
                 ELSE
                    l_due_date := l_counter_read_date;
                 END IF;

             ELSIF (l_counter_remain = 0) THEN  /* due_date = sysdate */
                 --dbms_output.put_line ('counter remain is zero');
                 l_due_date := sysdate;
             END IF; -- counter remain.

             -- For MR type, based on whichever first code, set calculated due date.
             -- For SR type, whichever first code = 'FIRST'.
             IF (l_due_date IS NULL) THEN
                l_calc_due_date := NULL;
                l_calc_counter_id := p_current_usage_tbl(k).counter_id;
                l_calc_due_counter_value := l_due_at_counter_value;
                EXIT;
             ELSIF (l_calc_due_date IS NULL) THEN
                l_calc_due_date := l_due_date;
                l_calc_counter_id := p_current_usage_tbl(k).counter_id;
                l_calc_due_counter_value := l_due_at_counter_value;
             ELSE
                IF (unit_effectivity_rec.whichever_first_code = 'FIRST') THEN
                  IF (trunc(l_due_date) < trunc(l_calc_due_date)) THEN
                    l_calc_due_date := l_due_date;
                    l_calc_counter_id := p_current_usage_tbl(k).counter_id;
                    l_calc_due_counter_value := l_due_at_counter_value;
                  END IF;
                ELSE  -- whichever_first_code = 'LAST'
                  IF (trunc(l_due_date) > trunc(l_calc_due_date)) THEN
                    l_calc_due_date := l_due_date;
                    l_calc_counter_id := p_current_usage_tbl(k).counter_id;
                    l_calc_due_counter_value := l_due_at_counter_value;
                  END IF;
                END IF;
             END IF;

        --dbms_output.put_line ('Bl_calc_due_date:' || l_calc_due_date);
        --dbms_output.put_line ('Bset_due_date:' || l_set_due_date);
        --dbms_output.put_line ('Bdue_ctr_val:' || l_calc_due_counter_value);
        --dbms_output.put_line ('BcounterID:' || l_calc_counter_id);

          END IF; -- current_usage_tbl.
        END LOOP; -- threshold rec.

        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('l_calc_due_date:' || l_calc_due_date);
          AHL_DEBUG_PUB.debug('set_due_date:' || l_set_due_date);
          AHL_DEBUG_PUB.debug('due_ctr_val:' || l_calc_due_counter_value);
          AHL_DEBUG_PUB.debug('counterID:' || l_calc_counter_id);
        END IF;

        -- Check calculated due date against set_due_date.
        IF (l_calc_due_date IS NOT NULL AND l_set_due_date IS NOT NULL) THEN
          IF (unit_effectivity_rec.whichever_first_code = 'FIRST') THEN
            IF (trunc(l_set_due_date) < trunc(l_calc_due_date)) THEN
               l_calc_due_date := l_set_due_date;
               l_calc_counter_id := null;
               l_calc_due_counter_value := null;
            END IF;
          ELSE  -- whichever_first_code = 'LAST'
            IF (trunc(l_set_due_date) > trunc(l_calc_due_date)) THEN
               l_calc_due_date := l_set_due_date;
               l_calc_counter_id := null;
               l_calc_due_counter_value := null;
            END IF;
          END IF;
        ELSIF (l_set_due_date IS NOT NULL) THEN
          l_calc_due_date := l_set_due_date;
          l_calc_counter_id := null;
          l_calc_due_counter_value := null;
        END IF;

    END IF;  -- unit_effectivity_rec.unit_deferral_type = 'DEFERRAL


    -- Added for R12: MEL/CDL due date.
    IF (unit_effectivity_rec.unit_deferral_type = 'MEL'
        OR unit_effectivity_rec.unit_deferral_type = 'CDL') THEN

        -- fix bug# 5217126. This variable is inserted into the temp table.
        l_deferral_effective_on := unit_effectivity_rec.deferral_effective_on;

        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('Calculating due date for MEL/CDL');
          AHL_DEBUG_PUB.debug('Deferral Eff on:' || unit_effectivity_rec.DEFERRAL_EFFECTIVE_ON);
          AHL_DEBUG_PUB.debug('Processing ..object type:' || unit_effectivity_rec.object_type);
        END IF;

        -- validate repair category.
        -- Added expected_resolution_date to fix bug# 5217126.
        OPEN get_repair_category_csr(unit_effectivity_rec.cs_incident_id);
        FETCH get_repair_category_csr INTO l_repair_time, l_expected_resolutn_date;
        IF (get_repair_category_csr%NOTFOUND) THEN
          --l_calc_due_date := NULL;
          FND_MESSAGE.Set_Name('AHL','AHL_PUE_INCIDENT_ID_MISSING');
          FND_MESSAGE.Set_Token('CS_INC_ID',unit_effectivity_rec.cs_incident_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE

          IF l_repair_time <> 0 AND
              unit_effectivity_rec.DEFERRAL_EFFECTIVE_ON IS NOT NULL
          THEN
            l_calc_due_date := unit_effectivity_rec.DEFERRAL_EFFECTIVE_ON +
                               trunc(l_repair_time/24);
          ELSE
            -- fix for bug# 5217126.
            l_calc_due_date := l_expected_resolutn_date;
          END IF;

        END IF; -- get_repair_category_csr%NOTFOUND
        CLOSE get_repair_category_csr;

        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('MEL/CDL:Calculated due date is:' || l_calc_due_date);
          AHL_DEBUG_PUB.debug('MEL/CDL:DEFERRAL_EFFECTIVE_ON:' || l_deferral_effective_on);
        END IF;

    END IF; -- unit_effectivity_rec.unit_deferral_type = 'MEL'

    -- Call visit work package to get visit end date if unit effectivity has been assigned to a visit.
    AHL_UMP_UTIL_PKG.get_visit_details (unit_effectivity_rec.unit_effectivity_id,
                                        l_visit_start_date,
                                        l_visit_end_date,
                                        l_visit_assign_code);

    /*
    IF (l_visit_end_date IS NOT NULL AND l_calc_due_date IS NOT NULL) THEN
      IF G_DEBUG = 'Y' THEN
         AHL_DEBUG_PUB.Debug('Visit assigned:End Date:' || l_visit_end_date);
      END IF;

      IF (trunc(l_visit_end_date) < trunc(l_calc_due_date)) THEN
           l_calc_tolerance_flag := 'Y';
           l_calc_message_code := 'TOLERANCE-BEFORE';
      END IF;
    END IF;
    */

    IF (l_visit_start_date IS NOT NULL AND l_calc_due_date IS NOT NULL) THEN
      IF G_DEBUG = 'Y' THEN
         AHL_DEBUG_PUB.Debug('Visit assigned: Start Date:' || l_visit_start_date);
      END IF;
      IF (trunc(l_visit_start_date) > trunc(l_calc_due_date)) THEN
           l_calc_tolerance_flag := 'Y';
           l_calc_message_code := 'TOLERANCE-EXCEEDED';
      END IF;
    END IF;

    IF ( l_calc_due_date IS NOT NULL) THEN
      IF (trunc(l_calc_due_date) < trunc(sysdate)) THEN
         l_calc_tolerance_flag := 'Y';
         l_calc_message_code := 'TOLERANCE-EXCEEDED';
      END IF;
    END IF;

    --dbms_output.put_line ('Al_calc_due_date:' || l_calc_due_date);
    --dbms_output.put_line ('Aset_due_date:' || l_set_due_date);
    --dbms_output.put_line ('Adue_ctr_val:' || l_calc_due_counter_value);


    -- Check if workorder already created.
    l_visit_status := AHL_UMP_UTIL_PKG.get_Visit_Status(unit_effectivity_rec.unit_effectivity_id);

    IF (nvl(l_visit_status,'X') IN ('RELEASED','CLOSED')) THEN
       -- if UE is on shop floor then keep UE structure as is.
       l_grp_match := 'Y';
    ELSE
       IF (unit_effectivity_rec.object_type = 'MR') THEN

           Match_Group_MR (p_orig_csi_item_instance_id  => unit_effectivity_rec.csi_item_instance_id,
                           p_orig_mr_header_id          => unit_effectivity_rec.mr_header_id,
                           p_unit_effectivity_id        => unit_effectivity_rec.unit_effectivity_id,
                           x_group_match_flag           => l_grp_match);

       ELSE
           l_grp_match := 'Y';
           -- For SR case, for each child group MR associated match the group MR.
           FOR ahl_ue_reln_rec IN ahl_ue_reln_csr(unit_effectivity_rec.unit_effectivity_id) LOOP
              IF (ahl_ue_reln_rec.status_code = 'MR-TERMINATE') THEN
                    -- skip mr-terminated records.
                   l_grp_match1 := 'Y';
              ELSE

                   Match_Group_MR (p_orig_csi_item_instance_id  => ahl_ue_reln_rec.csi_item_instance_id,
                                   p_orig_mr_header_id          => ahl_ue_reln_rec.mr_header_id,
                                   p_unit_effectivity_id        => ahl_ue_reln_rec.unit_effectivity_id,
                                   x_group_match_flag           => l_grp_match1);

                  IF (l_grp_match1 = 'N') THEN
                      l_grp_match := 'N';
                  END IF;

              END IF;

           END LOOP;

       END IF; -- unit_effectivity_rec.object_type
    END IF; -- l_visit_status


    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.Debug('Group Match flag:l_visit_status:' || l_grp_match || ':' || l_visit_status);
    END IF;

    -- insert into deferral temp table.
    insert into ahl_temp_unit_SR_deferrals (
        unit_effectivity_id,
        object_type,
        csi_item_instance_id,
        mr_header_id,
        due_date,
        counter_id,
        due_counter_value,
        tolerance_flag,
        message_code,
        parent_csi_item_instance_id,
        parent_mr_header_id,
        orig_csi_item_instance_id,
        orig_mr_header_id,
        orig_unit_effectivity_id,
        visit_end_date,
        deferral_effective_on,
        affect_due_calc_flag,
        group_match_flag)
    VALUES (
        unit_effectivity_rec.unit_effectivity_id,
        unit_effectivity_rec.object_type,
        unit_effectivity_rec.csi_item_instance_id,
        unit_effectivity_rec.mr_header_id,
        l_calc_due_date,
        l_calc_counter_id,
        l_calc_due_counter_value,
        l_calc_tolerance_flag,
        l_calc_message_code,
        null,
        null,
        null,
        null,
        null,
        l_visit_end_date,
        l_deferral_effective_on,
        --l_affect_due_date_calc,
        unit_effectivity_rec.AFFECT_DUE_CALC_FLAG,
        l_grp_match);

    -- Insert all child MRs for group MR.
    FOR ahl_applicable_grp_rec IN ahl_applicable_grp_csr(unit_effectivity_rec.csi_item_instance_id,
                                                         unit_effectivity_rec.mr_header_id)
    LOOP
           -- insert into deferral temp table.
           insert into ahl_temp_unit_SR_deferrals (
               unit_effectivity_id,
               object_type,
               csi_item_instance_id,
               mr_header_id,
               due_date,
               due_counter_value,
               tolerance_flag,
               message_code,
               parent_csi_item_instance_id,
               parent_mr_header_id,
               orig_csi_item_instance_id,
               orig_mr_header_id,
               orig_unit_effectivity_id,
               visit_end_date,
               deferral_effective_on,
               affect_due_calc_flag,
               group_match_flag)
           VALUES (
               null,
               'MR',
               ahl_applicable_grp_rec.related_csi_item_instance_id,
               ahl_applicable_grp_rec.related_mr_header_id,
               l_calc_due_date,
               l_calc_due_counter_value,
               l_calc_tolerance_flag,
               l_calc_message_code,
               ahl_applicable_grp_rec.parent_csi_item_instance_id,
               ahl_applicable_grp_rec.parent_mr_header_id,
               unit_effectivity_rec.csi_item_instance_id,
               unit_effectivity_rec.mr_header_id,
               unit_effectivity_rec.unit_effectivity_id,
               l_visit_end_date,
               l_deferral_effective_on,
               --l_affect_due_date_calc,
               unit_effectivity_rec.AFFECT_DUE_CALC_FLAG,
               l_grp_match);

    END LOOP;
    --fix for bug#5217126
    --CLOSE ahl_unit_deferral_csr;

  END LOOP; -- unit effectivity rec.

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('End of process_Deferred_ue');
  END IF;

END Process_Deferred_UE;
-----------------------------------------------

-- Explode SR's having MRs for calculating MR due dates.
PROCEDURE Process_SR_UE (p_csi_item_instance_id IN NUMBER)  IS

  CURSOR ahl_ue_sr_csr (p_csi_item_instance_id IN NUMBER) IS
    SELECT
        UE.UNIT_EFFECTIVITY_ID,
        UE.OBJECT_TYPE,
        UE.CSI_ITEM_INSTANCE_ID,
        UE.MR_HEADER_ID,
        UE.STATUS_CODE,
        UE.DUE_DATE,
        UE.DUE_COUNTER_VALUE
    FROM ahl_unit_effectivities_app_v UE
    WHERE UE.OBJECT_TYPE = 'SR'
      AND defer_from_ue_id IS NULL
      AND csi_item_instance_id = p_csi_item_instance_id
      AND status_code IS NULL;


  -- Read applicable relns table for group MR details.
  CURSOR ahl_applicable_grp_csr( p_item_instance_id IN NUMBER,
                                 p_mr_header_id IN NUMBER) IS

    SELECT related_mr_header_id,
           related_csi_item_instance_id,
           csi_item_instance_id parent_csi_item_instance_id,
           mr_header_id parent_mr_header_id
    FROM ahl_applicable_mr_relns
    START WITH mr_header_id = p_mr_header_id AND
               csi_item_instance_id = p_item_instance_id AND
               orig_mr_header_id = p_mr_header_id AND
               orig_csi_item_instance_id = p_item_instance_id AND
               relationship_code = 'PARENT'
    CONNECT BY PRIOR related_mr_header_id = mr_header_id AND
               PRIOR related_csi_item_instance_id = csi_item_instance_id AND
               orig_mr_header_id = p_mr_header_id AND
               orig_csi_item_instance_id = p_item_instance_id AND
               relationship_code = 'PARENT'
    ORDER BY   level;


  -- Read immediate children of the SR.
  CURSOR ahl_ue_reln_csr (p_ue_id  IN NUMBER) IS
    SELECT ue.unit_effectivity_id, ue.status_code,
           UE.CSI_ITEM_INSTANCE_ID, UE.MR_HEADER_ID
    FROM ahl_ue_relationships uer, ahl_unit_effectivities_app_v ue
    WHERE ue.unit_effectivity_id = uer.related_ue_id
      AND uer.ue_id = p_ue_id;


  l_calc_tolerance_flag    ahl_unit_effectivities_app_v.tolerance_flag%TYPE;
  l_calc_message_code      ahl_unit_effectivities_app_v.message_code%TYPE;

  l_visit_start_date       DATE;
  l_visit_end_date         DATE;
  l_visit_assign_code      fnd_lookups.lookup_code%TYPE;

  l_grp_match              VARCHAR2(1);
  l_grp_match1             VARCHAR2(1);

  l_visit_status           ahl_visits_b.status_code%TYPE;

BEGIN

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Start of Process_SR_UE');
  END IF;

  -- Get all UE's with object-type = SR.
  FOR ahl_ue_sr_rec IN ahl_ue_sr_csr(p_csi_item_instance_id) LOOP

    -- Call visit work package to get visit end date if unit effectivity has been assigned to a visit.
    AHL_UMP_UTIL_PKG.get_visit_details (ahl_ue_sr_rec.unit_effectivity_id,
                                        l_visit_start_date,
                                        l_visit_end_date,
                                        l_visit_assign_code);

    IF (l_visit_end_date IS NOT NULL AND ahl_ue_sr_rec.due_date IS NOT NULL) THEN
      IF G_DEBUG = 'Y' THEN
         AHL_DEBUG_PUB.Debug('Visit assigned:End Date:' || l_visit_end_date);
      END IF;

      IF (trunc(l_visit_end_date) < trunc(ahl_ue_sr_rec.due_date )) THEN
           l_calc_tolerance_flag := 'Y';
           l_calc_message_code := 'TOLERANCE-BEFORE';
      END IF;
    END IF;

    IF (l_visit_start_date IS NOT NULL AND ahl_ue_sr_rec.due_date IS NOT NULL) THEN
      IF G_DEBUG = 'Y' THEN
         AHL_DEBUG_PUB.Debug('Visit assigned:Start Date:' || l_visit_start_date);
      END IF;

      IF (trunc(l_visit_start_date) > trunc(ahl_ue_sr_rec.due_date )) THEN
           l_calc_tolerance_flag := 'Y';
           l_calc_message_code := 'TOLERANCE-EXCEEDED';
      END IF;
    END IF;

    -- Check if workorder already created.
    l_visit_status := AHL_UMP_UTIL_PKG.get_Visit_Status(ahl_ue_sr_rec.unit_effectivity_id);

    IF (nvl(l_visit_status,'X') IN ('RELEASED','CLOSED')) THEN
       -- if UE is on shop floor then keep UE structure as is.
       l_grp_match := 'Y';
    ELSE
      -- initialize.
      l_grp_match := 'Y';

      -- For each group MR associated match the group MR.
      FOR ahl_ue_reln_rec IN ahl_ue_reln_csr(ahl_ue_sr_rec.unit_effectivity_id) LOOP
        IF (ahl_ue_reln_rec.status_code = 'MR-TERMINATE') THEN
           -- skip mr-terminated records.
           l_grp_match1 := 'Y';
        ELSE

           Match_Group_MR (p_orig_csi_item_instance_id  => ahl_ue_reln_rec.csi_item_instance_id,
                           p_orig_mr_header_id          => ahl_ue_reln_rec.mr_header_id,
                           p_unit_effectivity_id        => ahl_ue_reln_rec.unit_effectivity_id,
                           x_group_match_flag           => l_grp_match1);

          IF (l_grp_match1 = 'N') THEN
            l_grp_match := 'N';
          END IF;
        END IF;

      END LOOP;
    END IF; --l_visit_status

    -- Write SR UE into temporary table.
    insert into ahl_temp_unit_SR_deferrals (
        unit_effectivity_id,
        object_type,
        csi_item_instance_id,
        mr_header_id,
        due_date,
        due_counter_value,
        tolerance_flag,
        message_code,
        parent_csi_item_instance_id,
        parent_mr_header_id,
        orig_mr_header_id,
        orig_csi_item_instance_id,
        orig_unit_effectivity_id,
        visit_end_date,
        deferral_effective_on,
        affect_due_calc_flag,
        group_match_flag)
     VALUES (
        ahl_ue_sr_rec.unit_effectivity_id,
        ahl_ue_sr_rec.object_type,
        ahl_ue_sr_rec.csi_item_instance_id,
        null,
        ahl_ue_sr_rec.due_date,
        ahl_ue_sr_rec.due_counter_value,
        l_calc_tolerance_flag,
        l_calc_message_code,
        null,
        null,
        null,
        null,
        null,
        l_visit_end_date,
        null,
        'Y',
        l_grp_match);


      -- Write child MRs into temporary table.

      FOR ahl_applicable_grp_rec IN ahl_applicable_grp_csr(ahl_ue_sr_rec.csi_item_instance_id,
                                                           ahl_ue_sr_rec.mr_header_id)
      LOOP
           -- insert into deferral temp table.
           insert into ahl_temp_unit_SR_deferrals (
               unit_effectivity_id,
               object_type,
               csi_item_instance_id,
               mr_header_id,
               due_date,
               due_counter_value,
               tolerance_flag,
               message_code,
               parent_csi_item_instance_id,
               parent_mr_header_id,
               orig_csi_item_instance_id,
               orig_mr_header_id,
               orig_unit_effectivity_id,
               visit_end_date,
               deferral_effective_on,
               affect_due_calc_flag,
               group_match_flag)
           VALUES (
               null,
               null,
               ahl_applicable_grp_rec.related_csi_item_instance_id,
               ahl_applicable_grp_rec.related_mr_header_id,
               ahl_ue_sr_rec.due_date,
               ahl_ue_sr_rec.due_counter_value,
               l_calc_tolerance_flag,
               l_calc_message_code,
               ahl_applicable_grp_rec.parent_csi_item_instance_id,
               ahl_applicable_grp_rec.parent_mr_header_id,
               ahl_ue_sr_rec.csi_item_instance_id,
               ahl_ue_sr_rec.mr_header_id,
               ahl_ue_sr_rec.unit_effectivity_id,
               l_visit_end_date,
               null,
               'Y',
               l_grp_match);

      END LOOP;

  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('End of Process_SR_UE');
  END IF;

END Process_SR_UE;

-----------------------------------------------

-- Match if current UE group MR matches the applicable group MR.
PROCEDURE Match_Group_MR (p_orig_csi_item_instance_id  IN NUMBER,
                          p_orig_mr_header_id          IN NUMBER,
                          p_unit_effectivity_id        IN NUMBER,
                          x_group_match_flag       OUT NOCOPY VARCHAR2)
IS

  -- Get all child UE's for a given unit effectivity.
  CURSOR ahl_ue_relns_csr (p_unit_effectivity_id  IN NUMBER) IS
    SELECT related_ue_id, ue_id, level
    FROM  ahl_ue_relationships
    START WITH ue_id = p_unit_effectivity_id
           AND relationship_code = 'PARENT'
    CONNECT BY PRIOR related_ue_id = ue_id
           AND relationship_code = 'PARENT'
    ORDER BY level;

  -- get unit effectivities details.
  CURSOR ahl_ue_csr ( p_ue_id IN NUMBER,
                      p_related_ue_id IN NUMBER ) IS
    SELECT ue1.mr_header_id, ue1.csi_item_instance_id,
           ue2.mr_header_id related_mr_header_id,
           ue2.csi_item_instance_id related_csi_item_instance_id
    FROM ahl_unit_effectivities_b ue1, ahl_unit_effectivities_b ue2
    WHERE ue1.unit_effectivity_id = p_ue_id AND
          ue2.unit_effectivity_id = p_related_ue_id;

  -- Read applicable relns table for group MR details.
  CURSOR ahl_applicable_grp_csr( p_item_instance_id IN NUMBER,
                                 p_mr_header_id IN NUMBER) IS

    SELECT mr_header_id, csi_item_instance_id,
           related_mr_header_id,
           related_csi_item_instance_id, level
    FROM ahl_applicable_mr_relns
    START WITH mr_header_id = p_mr_header_id AND
               csi_item_instance_id = p_item_instance_id AND
               orig_mr_header_id = p_mr_header_id AND
               orig_csi_item_instance_id = p_item_instance_id AND
               relationship_code = 'PARENT'
    CONNECT BY PRIOR related_mr_header_id = mr_header_id AND
               PRIOR related_csi_item_instance_id = csi_item_instance_id AND
               orig_mr_header_id = p_mr_header_id AND
               orig_csi_item_instance_id = p_item_instance_id AND
               relationship_code = 'PARENT'
    ORDER BY   level;


  TYPE ue_details_rec_type IS RECORD (
     mr_header_id NUMBER,
     csi_item_instance_id NUMBER,
     related_mr_header_id NUMBER,
     related_csi_item_instance_id NUMBER,
     level                NUMBER,
     unit_effectivity_id  NUMBER,
     match_flag           VARCHAR2(1));

  l_ue_details_rec       ue_details_rec_type;

  TYPE l_ue_details_tbl_type IS TABLE OF ue_details_rec_type INDEX BY BINARY_INTEGER;

  l_ue_details_tbl       l_ue_details_tbl_type;
  l_grp_details_tbl      l_ue_details_tbl_type;
  i                      NUMBER;

BEGIN

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug('Start of Match_Group_MR');
    END IF;

    -- Match the ue relations tree with the group applicablilty tree.
    i := 1;
    FOR ahl_ue_relns_rec in ahl_ue_relns_csr(p_unit_effectivity_id) LOOP
       OPEN ahl_ue_csr(ahl_ue_relns_rec.ue_id, ahl_ue_relns_rec.related_ue_id);
       FETCH ahl_ue_csr INTO l_ue_details_tbl(i).mr_header_id,
                             l_ue_details_tbl(i).csi_item_instance_id,
                             l_ue_details_tbl(i).related_mr_header_id,
                             l_ue_details_tbl(i).related_csi_item_instance_id;
       IF (ahl_ue_csr%NOTFOUND) THEN
           FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_RELN_NOTFOUND');
           FND_MESSAGE.Set_Token('UE_ID',ahl_ue_relns_rec.ue_id);
           FND_MESSAGE.Set_Token('RELATED_UE_ID', ahl_ue_relns_rec.related_ue_id);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       l_ue_details_tbl(i).level := ahl_ue_relns_rec.level;
       l_ue_details_tbl(i).unit_effectivity_id := ahl_ue_relns_rec.related_ue_id;
       l_ue_details_tbl(i).match_flag := 'N';

       --dbms_output.put_line ('found ue relns');
       i := i + 1;
       CLOSE ahl_ue_csr;
    END LOOP;

    i := 1;
    -- from applicable_mrs_relations.
    FOR l_appl_grp_rec IN ahl_applicable_grp_csr(p_orig_csi_item_instance_id,
                                                 p_orig_mr_header_id)

    LOOP
      l_grp_details_tbl(i).mr_header_id := l_appl_grp_rec.mr_header_id;
      l_grp_details_tbl(i).csi_item_instance_id := l_appl_grp_rec.csi_item_instance_id;
      l_grp_details_tbl(i).related_mr_header_id := l_appl_grp_rec.related_mr_header_id;
      l_grp_details_tbl(i).related_csi_item_instance_id := l_appl_grp_rec.related_csi_item_instance_id;
      l_grp_details_tbl(i).level := l_appl_grp_rec.level;
      l_grp_details_tbl(i).match_flag := 'N';
      i := i + 1;
    END LOOP;

    -- Now compare l_grp_details_tbl with l_ue_details_tbl.
    IF (l_grp_details_tbl.COUNT > 0) THEN
       FOR i IN l_grp_details_tbl.FIRST..l_grp_details_tbl.LAST LOOP
         -- match if entry present in l_ue_details_tbl.
         IF (l_ue_details_tbl.COUNT > 0 ) THEN
            FOR j IN l_ue_details_tbl.FIRST..l_ue_details_tbl.LAST LOOP
              IF (l_ue_details_tbl(j).mr_header_id = l_grp_details_tbl(i).mr_header_id AND
                 l_ue_details_tbl(j).csi_item_instance_id = l_grp_details_tbl(i).csi_item_instance_id AND
                 l_ue_details_tbl(j).related_csi_item_instance_id = l_grp_details_tbl(i).related_csi_item_instance_id AND
                 l_ue_details_tbl(j).related_mr_header_id = l_grp_details_tbl(i).related_mr_header_id AND
                 l_ue_details_tbl(j).level = l_grp_details_tbl(i).level AND
                 l_ue_details_tbl(j).match_flag = 'N' AND
                 l_grp_details_tbl(i).match_flag = 'N') THEN
                     --l_ue_details_tbl.DELETE(j);
                     --l_grp_details_tbl.DELETE(i);
                     l_ue_details_tbl(j).match_flag := 'Y';
                     l_grp_details_tbl(i).match_flag := 'Y';
                     EXIT;
              END IF;
            END LOOP; /* ue_details */
         END IF; /* count - ue_details */
       END LOOP; /* grp_details */
    END IF; /* count - grp_details */

    -- delete records from table where match flag is Y.
    IF (l_ue_details_tbl.COUNT > 0 ) THEN
      FOR j IN l_ue_details_tbl.FIRST..l_ue_details_tbl.LAST LOOP
        IF (l_ue_details_tbl(j).match_flag = 'Y') THEN
           l_ue_details_tbl.DELETE(j);
        END IF;
      END LOOP;
    END IF;

    IF (l_grp_details_tbl.COUNT > 0 ) THEN
      FOR i IN l_grp_details_tbl.FIRST..l_grp_details_tbl.LAST LOOP
         IF (l_grp_details_tbl(i).match_flag = 'Y') THEN
           l_grp_details_tbl.DELETE(i);
         END IF;
      END LOOP;
    END IF;

    IF (l_ue_details_tbl.COUNT = 0) AND (l_grp_details_tbl.COUNT = 0) THEN
      x_group_match_flag := 'Y';

    ELSE
      x_group_match_flag := 'N';

    END IF;

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug('End of Match_Group_MR');
    END IF;

END Match_Group_MR;

-----------------------------------------------

PROCEDURE Process_Unplanned_UE(p_csi_item_instance_id IN NUMBER) IS
  -- Read Unplanned MRs.(only top nodes)
  CURSOR ahl_unplanned_ue_csr(p_csi_item_instance_id IN NUMBER) IS
    SELECT ue.mr_header_id,
           ue.csi_item_instance_id,
           ue.unit_effectivity_id,
           ue.status_code
    FROM ahl_unit_effectivities_app_v ue
    /*
    WHERE NOT EXISTS ( SELECT 'x'
                       --FROM ahl_ue_relationships uer, ahl_unit_effectivities_app_v ue1
                       FROM ahl_ue_relationships uer, ahl_unit_effectivities_b ue1
                       WHERE uer.related_ue_id = ue.unit_effectivity_id AND
                             uer.originator_ue_id = ue1.unit_effectivity_id AND
                             ue1.object_type <> 'SR' )
    */
    -- pick up only top nodes.
    WHERE NOT EXISTS (SELECT 'x'
                      FROM ahl_ue_relationships uer
                      WHERE uer.related_ue_id = ue.unit_effectivity_id
                        AND relationship_code = 'PARENT')
        AND ue.csi_item_instance_id = p_csi_item_instance_id
        AND nvl(ue.manually_planned_flag,'N') = 'Y'
        AND ue.object_type = 'MR'
        AND ue.defer_from_ue_id IS NULL
        AND (ue.status_code IS NULL OR ue.status_code = 'EXCEPTION');

  CURSOR ahl_applicable_mr_csr (p_csi_item_instance_id IN NUMBER,
                                p_mr_header_id         IN NUMBER) IS
    SELECT 'x'
    FROM ahl_applicable_mrs
    WHERE mr_header_id = p_mr_header_id AND
          csi_item_instance_id = p_csi_item_instance_id;


  -- Cursor to get all details of a unit effectivity record.
  CURSOR ahl_unit_effectivity_csr ( p_unit_effectivity_id IN NUMBER) IS
     SELECT
        UNIT_EFFECTIVITY_ID ,
        CSI_ITEM_INSTANCE_ID,
        MR_INTERVAL_ID,
        MR_EFFECTIVITY_ID ,
        MR_HEADER_ID,
        STATUS_CODE ,
        DUE_DATE   ,
        DUE_COUNTER_VALUE ,
        FORECAST_SEQUENCE ,
        REPETITIVE_MR_FLAG ,
        TOLERANCE_FLAG ,
        REMARKS ,
        MESSAGE_CODE ,
        PRECEDING_UE_ID ,
        DATE_RUN ,
        SET_DUE_DATE ,
        ACCOMPLISHED_DATE ,
        CANCEL_REASON_CODE,
        EARLIEST_DUE_DATE,
        LATEST_DUE_DATE,
        SERVICE_LINE_ID,
        PROGRAM_MR_HEADER_ID,
        defer_from_ue_id,
        cs_incident_id,
        qa_collection_id,
        orig_deferral_ue_id,
        application_usg_code,
        object_type,
        counter_id,
        manually_planned_flag,
        LOG_SERIES_CODE,
        LOG_SERIES_NUMBER, FLIGHT_NUMBER, MEL_CDL_TYPE_CODE,
        POSITION_PATH_ID,
        ATA_CODE, UNIT_CONFIG_HEADER_ID,
        ATTRIBUTE_CATEGORY ,
        ATTRIBUTE1,
        ATTRIBUTE2 ,
        ATTRIBUTE3 ,
        ATTRIBUTE4 ,
        ATTRIBUTE5 ,
        ATTRIBUTE6 ,
        ATTRIBUTE7 ,
        ATTRIBUTE8 ,
        ATTRIBUTE9 ,
        ATTRIBUTE10,
        ATTRIBUTE11 ,
        ATTRIBUTE12 ,
        ATTRIBUTE13 ,
        ATTRIBUTE14 ,
        ATTRIBUTE15 ,
        OBJECT_VERSION_NUMBER
     FROM ahl_unit_effectivities_vl
     WHERE unit_effectivity_id = p_unit_effectivity_id
     FOR UPDATE OF message_code NOWAIT;

  -- Read group from ahl_ue_relationships.
  CURSOR decendent_csr (p_unit_effectivity_id IN NUMBER) IS
    SELECT related_ue_id
    FROM ahl_ue_relationships
    WHERE relationship_code = 'PARENT' AND
          originator_ue_id = p_unit_effectivity_id;

  l_exception_flag  BOOLEAN;
  l_grp_match_flag  VARCHAR2(1);
  l_message_code    ahl_unit_effectivities_b.message_code%TYPE;
  l_status_code     ahl_unit_effectivities_b.status_code%TYPE;
  l_junk            VARCHAR2(1);

  l_ue_rec          ahl_unit_effectivity_csr%ROWTYPE;

  l_visit_status    VARCHAR2(30);

BEGIN

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Start of Process_Unplanned_UE');
  END IF;

  -- Loop through all Unplanned MRs.
  FOR ahl_unplanned_ue_rec IN ahl_unplanned_ue_csr(p_csi_item_instance_id) LOOP
    -- initialize.
    l_exception_flag := FALSE;

    -- Check if workorder already created.
    l_visit_status := AHL_UMP_UTIL_PKG.get_Visit_Status (ahl_unplanned_ue_rec.unit_effectivity_id);

    -- only if visit is in planning status we must mark an exception.
    -- if visit is already on the floor, we do nothing.
    IF (nvl(l_visit_status,'X') NOT IN ('RELEASED','CLOSED')) THEN

      -- Check if top node applicable.
      OPEN ahl_applicable_mr_csr(ahl_unplanned_ue_rec.csi_item_instance_id,
                                 ahl_unplanned_ue_rec.mr_header_id);
      FETCH ahl_applicable_mr_csr INTO l_junk;
      IF (ahl_applicable_mr_csr%FOUND) THEN
        --Match the group.
        Match_Group_MR (p_orig_csi_item_instance_id  => ahl_unplanned_ue_rec.csi_item_instance_id,
                        p_orig_mr_header_id          => ahl_unplanned_ue_rec.mr_header_id,
                        p_unit_effectivity_id        => ahl_unplanned_ue_rec.unit_effectivity_id,
                        x_group_match_flag           => l_grp_match_flag);

        IF (l_grp_match_flag = 'N') THEN
          l_exception_flag := TRUE;
        END IF;
      ELSE
        l_exception_flag := TRUE;
      END IF; -- ahl_applicable_mr_csr found chk.
      CLOSE ahl_applicable_mr_csr;

      IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('Group Match Flag for UE:' || ahl_unplanned_ue_rec.unit_effectivity_id || 'is:' ||
             l_grp_match_flag);
      END IF;

      -- If exception, then update the UE status to exception.
      -- If no longer an exception, then update the UE status to NULL.
      IF ((ahl_unplanned_ue_rec.status_code IS NULL) AND (l_exception_flag = TRUE)) OR
         ((ahl_unplanned_ue_rec.status_code = 'EXCEPTION') AND (l_exception_flag = FALSE)) THEN

         OPEN ahl_unit_effectivity_csr(ahl_unplanned_ue_rec.unit_effectivity_id);
         FETCH ahl_unit_effectivity_csr INTO l_ue_rec;
         IF (ahl_unit_effectivity_csr%NOTFOUND) THEN
           FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_UE_NOTFOUND');
           FND_MESSAGE.Set_Token('UE_ID',l_ue_rec.unit_effectivity_id);
           FND_MSG_PUB.ADD;
           -- dbms_output.put_line('unit effectivity not found for ue id' ||l_ue_rec.unit_effectivity_id );
           ClOSE ahl_unit_effectivity_csr;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSE
           -- set UE attributes.
           IF (ahl_unplanned_ue_rec.status_code IS NULL) AND (l_exception_flag = TRUE) THEN
              IF G_DEBUG = 'Y' THEN
                AHL_DEBUG_PUB.Debug('Updating Unplanned UE..' || l_ue_rec.unit_effectivity_id || ' to an exception');
              END IF;
              -- update unit effectivity.
              l_message_code := 'VISIT-ASSIGN';
              l_status_code := 'EXCEPTION';
           ELSE
              IF G_DEBUG = 'Y' THEN
                AHL_DEBUG_PUB.Debug('Updating Unplanned UE..' || l_ue_rec.unit_effectivity_id || ' from an exception');
              END IF;
               -- update unit effectivity.
              l_message_code := NULL;
              l_status_code := NULL;
           END IF;
           ClOSE ahl_unit_effectivity_csr;

           -- Update unit effectivity.
           AHL_UNIT_EFFECTIVITIES_PKG.Update_Row(
                  X_UNIT_EFFECTIVITY_ID   => l_ue_rec.unit_effectivity_id,
                  X_CSI_ITEM_INSTANCE_ID  => l_ue_rec.csi_item_instance_id,
                  X_MR_INTERVAL_ID        => l_ue_rec.mr_interval_id,
                  X_MR_EFFECTIVITY_ID     => l_ue_rec.mr_effectivity_id,
                  X_MR_HEADER_ID          => l_ue_rec.mr_header_id,
                  X_STATUS_CODE           => l_status_code,
                  X_DUE_DATE              => l_ue_rec.due_date,
                  X_DUE_COUNTER_VALUE     => l_ue_rec.due_counter_value,
                  X_FORECAST_SEQUENCE     => l_ue_rec.forecast_sequence,
                  X_REPETITIVE_MR_FLAG    => l_ue_rec.repetitive_mr_flag,
                  X_TOLERANCE_FLAG        => l_ue_rec.tolerance_flag,
                  X_REMARKS               => l_ue_rec.remarks,
                  X_MESSAGE_CODE          => l_message_code,
                  X_PRECEDING_UE_ID       => l_ue_rec.preceding_ue_id,
                  X_DATE_RUN              => sysdate,
                  X_SET_DUE_DATE          => l_ue_rec.set_due_date,
                  X_ACCOMPLISHED_DATE     => l_ue_rec.accomplished_date,
                  X_SERVICE_LINE_ID       => l_ue_rec.service_line_id,
                  X_PROGRAM_MR_HEADER_ID  => l_ue_rec.program_mr_header_id,
                  X_CANCEL_REASON_CODE    => l_ue_rec.cancel_reason_code,
                  X_EARLIEST_DUE_DATE     => l_ue_rec.earliest_due_date,
                  X_LATEST_DUE_DATE       => l_ue_rec.latest_due_date,
                  X_defer_from_ue_id      => l_ue_rec.defer_from_ue_id,
                  X_cs_incident_id        => l_ue_rec.cs_incident_id,
                  X_qa_collection_id      => l_ue_rec.qa_collection_id,
                  X_orig_deferral_ue_id   => l_ue_rec.orig_deferral_ue_id,
                  X_application_usg_code  => l_ue_rec.application_usg_code,
                  X_object_type           => l_ue_rec.object_type,
                  X_counter_id          => l_ue_rec.counter_id,
                  X_MANUALLY_PLANNED_FLAG => l_ue_rec.MANUALLY_PLANNED_FLAG,
                  X_LOG_SERIES_CODE       => l_ue_rec.log_series_code,
                  X_LOG_SERIES_NUMBER     => l_ue_rec.log_series_number,
                  X_FLIGHT_NUMBER         => l_ue_rec.flight_number,
                  X_MEL_CDL_TYPE_CODE     => l_ue_rec.mel_cdl_type_code,
                  X_POSITION_PATH_ID      => l_ue_rec.position_path_id,
                  X_ATA_CODE              => l_ue_rec.ATA_CODE,
                  X_UNIT_CONFIG_HEADER_ID  => l_ue_rec.unit_config_header_id,
                  X_ATTRIBUTE_CATEGORY    => l_ue_rec.attribute_category,
                  X_ATTRIBUTE1            => l_ue_rec.attribute1,
                  X_ATTRIBUTE2            => l_ue_rec.attribute2,
                  X_ATTRIBUTE3            => l_ue_rec.attribute3,
                  X_ATTRIBUTE4            => l_ue_rec.attribute4,
                  X_ATTRIBUTE5            => l_ue_rec.attribute5,
                  X_ATTRIBUTE6            => l_ue_rec.attribute6,
                  X_ATTRIBUTE7            => l_ue_rec.attribute7,
                  X_ATTRIBUTE8            => l_ue_rec.attribute8,
                  X_ATTRIBUTE9            => l_ue_rec.attribute9,
                  X_ATTRIBUTE10           => l_ue_rec.attribute10,
                  X_ATTRIBUTE11           => l_ue_rec.attribute11,
                  X_ATTRIBUTE12           => l_ue_rec.attribute12,
                  X_ATTRIBUTE13           => l_ue_rec.attribute13,
                  X_ATTRIBUTE14           => l_ue_rec.attribute14,
                  X_ATTRIBUTE15           => l_ue_rec.attribute15,
                  X_OBJECT_VERSION_NUMBER => l_ue_rec.object_version_number + 1,
                  X_LAST_UPDATE_DATE => sysdate,
                  X_LAST_UPDATED_BY => fnd_global.user_id,
                  X_LAST_UPDATE_LOGIN  => fnd_global.login_id);

           -- Now update all the child MRs status too.
           FOR ue_reln_rec IN decendent_csr(ahl_unplanned_ue_rec.unit_effectivity_id) LOOP

             OPEN ahl_unit_effectivity_csr (ue_reln_rec.related_ue_id);
             FETCH ahl_unit_effectivity_csr INTO l_ue_rec;
             IF (ahl_unit_effectivity_csr%FOUND) THEN
               AHL_UNIT_EFFECTIVITIES_PKG.Update_Row(
                  X_UNIT_EFFECTIVITY_ID   => l_ue_rec.unit_effectivity_id,
                  X_CSI_ITEM_INSTANCE_ID  => l_ue_rec.csi_item_instance_id,
                  X_MR_INTERVAL_ID        => l_ue_rec.mr_interval_id,
                  X_MR_EFFECTIVITY_ID     => l_ue_rec.mr_effectivity_id,
                  X_MR_HEADER_ID          => l_ue_rec.mr_header_id,
                  X_STATUS_CODE           => l_status_code,
                  X_DUE_DATE              => l_ue_rec.due_date,
                  X_DUE_COUNTER_VALUE     => l_ue_rec.due_counter_value,
                  X_FORECAST_SEQUENCE     => l_ue_rec.forecast_sequence,
                  X_REPETITIVE_MR_FLAG    => l_ue_rec.repetitive_mr_flag,
                  X_TOLERANCE_FLAG        => l_ue_rec.tolerance_flag,
                  X_REMARKS               => l_ue_rec.remarks,
                  X_MESSAGE_CODE          => l_message_code,
                  X_PRECEDING_UE_ID       => l_ue_rec.preceding_ue_id,
                  X_DATE_RUN              => sysdate,
                  X_SET_DUE_DATE          => l_ue_rec.set_due_date,
                  X_ACCOMPLISHED_DATE     => l_ue_rec.accomplished_date,
                  X_SERVICE_LINE_ID       => l_ue_rec.service_line_id,
                  X_PROGRAM_MR_HEADER_ID  => l_ue_rec.program_mr_header_id,
                  X_CANCEL_REASON_CODE    => l_ue_rec.cancel_reason_code,
                  X_EARLIEST_DUE_DATE     => l_ue_rec.earliest_due_date,
                  X_LATEST_DUE_DATE       => l_ue_rec.latest_due_date,
                  X_defer_from_ue_id      => l_ue_rec.defer_from_ue_id,
                  X_cs_incident_id        => l_ue_rec.cs_incident_id,
                  X_qa_collection_id      => l_ue_rec.qa_collection_id,
                  X_orig_deferral_ue_id   => l_ue_rec.orig_deferral_ue_id,
                  X_application_usg_code  => l_ue_rec.application_usg_code,
                  X_object_type           => l_ue_rec.object_type,
                  X_counter_id          => l_ue_rec.counter_id,
                  X_MANUALLY_PLANNED_FLAG => l_ue_rec.MANUALLY_PLANNED_FLAG,
                  X_LOG_SERIES_CODE       => l_ue_rec.log_series_code,
                  X_LOG_SERIES_NUMBER     => l_ue_rec.log_series_number,
                  X_FLIGHT_NUMBER         => l_ue_rec.flight_number,
                  X_MEL_CDL_TYPE_CODE     => l_ue_rec.mel_cdl_type_code,
                  X_POSITION_PATH_ID      => l_ue_rec.position_path_id,
                  X_ATA_CODE              => l_ue_rec.ATA_CODE,
                  X_UNIT_CONFIG_HEADER_ID  => l_ue_rec.unit_config_header_id,
                  X_ATTRIBUTE_CATEGORY    => l_ue_rec.attribute_category,
                  X_ATTRIBUTE1            => l_ue_rec.attribute1,
                  X_ATTRIBUTE2            => l_ue_rec.attribute2,
                  X_ATTRIBUTE3            => l_ue_rec.attribute3,
                  X_ATTRIBUTE4            => l_ue_rec.attribute4,
                  X_ATTRIBUTE5            => l_ue_rec.attribute5,
                  X_ATTRIBUTE6            => l_ue_rec.attribute6,
                  X_ATTRIBUTE7            => l_ue_rec.attribute7,
                  X_ATTRIBUTE8            => l_ue_rec.attribute8,
                  X_ATTRIBUTE9            => l_ue_rec.attribute9,
                  X_ATTRIBUTE10           => l_ue_rec.attribute10,
                  X_ATTRIBUTE11           => l_ue_rec.attribute11,
                  X_ATTRIBUTE12           => l_ue_rec.attribute12,
                  X_ATTRIBUTE13           => l_ue_rec.attribute13,
                  X_ATTRIBUTE14           => l_ue_rec.attribute14,
                  X_ATTRIBUTE15           => l_ue_rec.attribute15,
                  X_OBJECT_VERSION_NUMBER => l_ue_rec.object_version_number + 1,
                  X_LAST_UPDATE_DATE => sysdate,
                  X_LAST_UPDATED_BY => fnd_global.user_id,
                  X_LAST_UPDATE_LOGIN  => fnd_global.login_id);
             ELSE
               FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_UE_NOTFOUND');
               FND_MESSAGE.Set_Token('UE_ID',l_ue_rec.unit_effectivity_id);
               FND_MSG_PUB.ADD;
               -- dbms_output.put_line('descendent mr not found for ue id');
               ClOSE ahl_unit_effectivity_csr;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             ClOSE ahl_unit_effectivity_csr;
           END LOOP; -- decendent_csr

          END IF; -- ahl_unit_effectivity_csr%NOTFOUND chk.
      END IF;  -- unplanned status code check.
    END IF; -- l_visit_status

  END LOOP; -- next unplanned MR.

  IF (G_DEBUG = 'Y') THEN
    AHL_DEBUG_PUB.debug('End of Process_Unplanned_UE');
  END IF;

END Process_Unplanned_UE;


-----------------------------------------------

-- Procedure to calculate counter values at a given forecasted date for Reliability Fwk use.
PROCEDURE Get_Forecasted_Counter_Values(
              x_return_status          OUT NOCOPY VARCHAR2,
              x_msg_data               OUT NOCOPY VARCHAR2,
              x_msg_count              OUT NOCOPY NUMBER,
              p_init_msg_list          IN         VARCHAR2 := FND_API.G_FALSE,
              p_csi_item_instance_id   IN         NUMBER,   -- Instance Id
              p_forecasted_date        IN         DATE,
              x_counter_values_tbl    OUT NOCOPY counter_values_tbl_type) -- Forecasted Counter Vals.
IS

  l_csi_item_instance_id        NUMBER;
  l_uc_header_id                NUMBER;
  l_inventory_item_id           NUMBER;
  l_inv_master_organization_id  NUMBER;
  i                             NUMBER;

  l_current_usage_tbl    counter_values_tbl_type;
  /* contains current counter usage */

  l_counter_rules_tbl    counter_rules_tbl_type;
  /* contains current counter rules for the position */

  l_due_at_counter_val_tbl  counter_values_tbl_type;
  /* local variable to hold due at p_forecasted_date ctr values. */

  l_return_value                BOOLEAN;

BEGIN

  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('Start API Get_Forecasted_Counter_Values');
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Enable Debug.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Add debug mesg.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Begin private API:' ||  G_PKG_NAME || '.' || 'Get_Forcasted_Counter_Values');

    -- Dump input parameters.
    AHL_DEBUG_PUB.debug(' Csi Item instance ID:' || p_csi_item_instance_id);
    AHL_DEBUG_PUB.debug(' Forecasted Date:' || p_forecasted_date);

  END IF;

  -- validate item instance.
  Validate_item_instance(p_csi_item_instance_id, l_inventory_item_id,
                         l_inv_master_organization_id);

  IF FND_MSG_PUB.Count_msg > 0 THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- set instance variable.
  l_csi_item_instance_id := p_csi_item_instance_id;


  -- Set configuration variables based on installation type.
  -- If item instance is not top node, find the root item instance.
  l_csi_item_instance_id := Get_RootInstanceID(l_csi_item_instance_id);

  -- Get master and unit configuration IDs if they exist for this item instance.
  Get_Unit_Master_ConfigIDs (l_csi_item_instance_id,
                             l_uc_header_id, G_master_config_id);

  -- Check for errors.
  IF FND_MSG_PUB.Count_msg > 0 THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Build the Configuration tree structure.(G_config_node_tbl).
  Build_Config_Tree(l_csi_item_instance_id, G_master_config_id, G_CONFIG_NODE_TBL);

  -- Add debug mesg.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug(' Count on Config Node Tbl:' || G_config_node_tbl.COUNT);
    AHL_DEBUG_PUB.debug(' Root Node:' || l_csi_item_instance_id );
    AHL_DEBUG_PUB.debug(' Unit Config ID:' || l_uc_header_id);
    AHL_DEBUG_PUB.debug(' Master Config ID:' || G_master_config_id);
  END IF;

  -- Read applicable utilization forecast for the configuration.
  Get_Utilization_Forecast (l_csi_item_instance_id,
                            l_uc_header_id,
                            l_inventory_item_id,
                            l_inv_master_organization_id,
                            G_forecast_details_tbl);

  -- Build counter rules ratio if node is not root node.
  IF (G_master_config_id IS NOT NULL AND p_csi_item_instance_id <> l_csi_item_instance_id) THEN
    IF (G_config_node_tbl.count > 0) THEN
       FOR j IN G_config_node_tbl.FIRST..G_config_node_tbl.LAST LOOP
         IF (G_config_node_tbl(j).csi_item_instance_id = p_csi_item_instance_id) THEN
            i := j;
         END IF;
       END LOOP;
    END IF; -- G_config_node_tbl.count.
    build_Counter_Ratio(G_config_node_tbl(i).position_reference,
                        G_config_node_tbl(i).csi_item_instance_id,
                        G_master_config_id,
                        l_counter_rules_tbl);
  END IF; -- G_master_config_id IS NOT NULL.

  -- Get current usage for all the counters defined for the item instance.
  get_Current_Usage (p_csi_item_instance_id,
                     l_current_usage_tbl);


  -- get all counter values as on p_forecasted_date.
  Get_Due_at_Counter_Values (p_last_due_date => sysdate,
                             p_last_due_counter_val_tbl => l_current_usage_tbl,
                             p_due_date => p_forecasted_date,
                             p_counter_rules_tbl => l_counter_rules_tbl,
                             x_due_at_counter_val_tbl => l_due_at_counter_val_tbl,
                             x_return_value => l_return_value);

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('AFter get_due_at_counter_values');
     AHL_DEBUG_PUB.Debug('l_last_due_date: '|| sysdate);
     AHL_DEBUG_PUB.Debug('l_due_date: '|| p_forecasted_date);
     IF (l_due_at_counter_val_tbl.COUNT) > 0 THEN
          for i in l_due_at_counter_val_tbl.FIRST..l_due_at_counter_val_tbl.LAST LOOP
            AHL_DEBUG_PUB.Debug('i:'|| i|| ' value:' || l_due_at_counter_val_tbl(i).counter_value || 'ID: ' || l_due_at_counter_val_tbl(i).counter_id);
          end loop;
     END IF; -- count.
  END IF; -- Debug = Y

  IF NOT(l_return_value) THEN
     RAISE FND_API.G_EXC_ERROR;  /* no forecast available */
  ELSE
     x_counter_values_tbl := l_due_at_counter_val_tbl;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

  IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('End API Get_Forecasted_Counter_Values');
  END IF;

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Get_Forecasted_Counter_Values',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

    -- Disable debug
    AHL_DEBUG_PUB.disable_debug;

END Get_Forecasted_Counter_Values;
----------------------------------------------
-- Added in R12 to fix bug# 4224867.
-- find usage forecast for a given date.
PROCEDURE get_usage_for_date(p_due_date          IN DATE,
                             p_counter_uom_code  IN VARCHAR2,
                             p_counter_rules_tbl IN Counter_rules_tbl_type,
                             x_usage_per_day     OUT NOCOPY NUMBER)
IS
  l_next_index  NUMBER;

BEGIN

  x_usage_per_day := 0;

  -- Read g_forecast_details_tbl to get forecast values.
  l_next_index := G_forecast_details_tbl.FIRST;

  IF (l_next_index IS NOT NULL) THEN
    FOR i IN G_forecast_details_tbl.FIRST..G_forecast_details_tbl.LAST LOOP
      IF (G_forecast_details_tbl(i).uom_code = p_counter_uom_code) AND
         (trunc(G_forecast_details_tbl(i).start_date) <= trunc(p_due_date) AND
          trunc(p_due_date) <= trunc(nvl(G_forecast_details_tbl(i).end_date,p_due_date)))
      THEN
         x_usage_per_day := G_forecast_details_tbl(i).usage_per_day;
         EXIT;
      END IF;
    END LOOP;
  END IF;

  --dbms_output.put_line ('counter remain input to forecast' || l_counter_remain );
  --dbms_output.put_line ('counter uom' ||p_counter_uom_code);

  x_usage_per_day := Apply_ReverseCounter_Ratio ( x_usage_per_day,
                                                  p_counter_uom_code,
                                                  p_counter_rules_tbl);


END get_usage_for_date;
----------------------------------------------
-- Added to fix bug# 6875650.
-- Get the latest recorded counter reading for a given datetime.
PROCEDURE get_ctr_reading_for_datetime (p_csi_item_instance_id IN NUMBER,
                                        p_counter_id           IN NUMBER,
                                        p_reading_date         IN DATE,
                                        x_net_reading        OUT NOCOPY NUMBER) IS

  -- get the latest reading recorded for a counter on any given date.
  CURSOR cs_ctr_reading_csr(p_csi_item_instance_id IN NUMBER,
                            p_counter_id           IN NUMBER,
                            p_reading_date IN DATE) IS
        SELECT * FROM (
	               SELECT CCR.NET_READING
	               FROM
		            CSI_COUNTER_READINGS CCR
	               WHERE
		            CCR.COUNTER_ID          = P_COUNTER_ID
                         AND nvl(disabled_flag,'N') = 'N'
		         AND CCR.VALUE_TIMESTAMP   <= P_READING_DATE
      	               ORDER BY CCR.VALUE_TIMESTAMP DESC
                      )
        WHERE ROWNUM < 2;

  l_net_reading  NUMBER;

BEGIN

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug('Start of get_ctr_reading_for_datetime');
    END IF;

    OPEN cs_ctr_reading_csr(p_csi_item_instance_id,
                            p_counter_id,
                            p_reading_date);
    FETCH cs_ctr_reading_csr INTO l_net_reading;
    IF (cs_ctr_reading_csr%NOTFOUND) THEN
       l_net_reading := 0;
    END IF;
    CLOSE cs_ctr_reading_csr;

    x_net_reading := l_net_reading;

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug('End of get_ctr_reading_for_datetime');
    END IF;

END get_ctr_reading_for_datetime;

----------------------------------------------
-- added to fix bug# 6907562.
-- function that compares previous due date and uom remain with current values
-- and return Y is the current due date replaces the prev one.
FUNCTION validate_for_duedate_reset(p_due_date        IN DATE,
                                    p_uom_remain      IN NUMBER,
                                    p_prev_due_date   IN DATE,
                                    p_prev_counter_id IN NUMBER,
                                    p_prev_uom_remain IN NUMBER)
RETURN VARCHAR2 IS
  l_return_status  VARCHAR2(1);

BEGIN
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Start of validate_for_duedate_reset');
  END IF;

  l_return_status := 'N';
  IF (p_due_date IS NULL) THEN
    -- check if p_prev_counter_id is null or not. If null then this is first due date calculation.
    IF (p_prev_counter_id IS NULL) THEN
      l_return_status := 'Y';
    ELSE
      -- check prior date; it could either be null or not null.
      IF (p_prev_due_date IS NULL) THEN
        -- trigger ctr based on uom remain.
        IF (p_uom_remain < p_prev_uom_remain) THEN
           l_return_status := 'Y';
        END IF;
      ELSE -- p_prev_due_date is not null.
        -- check UOM remaining.
        IF (p_prev_uom_remain <= 0 AND p_uom_remain > 0) OR
           (p_prev_uom_remain < p_uom_remain AND p_uom_remain < 0) THEN
            null; -- do nothing
        ELSE
           l_return_status := 'Y';
        END IF; -- p_prev_uom_remain < 0
      END IF; -- p_prev_due_date
    END IF; -- p_prev_counter_id
  ELSE -- p_due_date is not null.
    IF (p_prev_due_date IS NULL) THEN
      IF (p_prev_counter_id IS NULL) THEN
        -- this is first time due due calculation.
        l_return_status := 'Y';
      ELSE
        -- prior due date is a null due date.
        -- swap based on uom remain.
        IF (p_uom_remain < p_prev_uom_remain AND p_prev_uom_remain < 0) OR
           (p_uom_remain <= 0 AND p_prev_uom_remain > 0) THEN
           l_return_status := 'Y';
        END IF;
      END IF; -- p_prev_counter_id
    END IF; -- p_prev_due_date
  END IF; -- p_due_date

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('End of validate_for_duedate_reset');
  END IF;

  RETURN l_return_status;

END validate_for_duedate_reset;

-----------------------------------------------
-- Added procedure to replace call to ahl_fmp_pvt.get_mr_affected_items for Prev. Maint
-- Called when processing based on MR invoked through concurrent program.
-- Perf fix for bug# 5093064.
PROCEDURE Process_PM_MR_Affected_Items(
    p_commit                 IN            VARCHAR2 := FND_API.G_FALSE,
    x_msg_count              OUT NOCOPY    NUMBER,
    x_msg_data               OUT NOCOPY    VARCHAR2,
    x_return_status          OUT NOCOPY    VARCHAR2,
    p_mr_header_id           IN            NUMBER,
    p_old_mr_header_id       IN            NUMBER    := NULL,
    p_concurrent_flag        IN            VARCHAR2  := 'N',
    p_num_of_workers         IN            NUMBER    := 10)

IS

  l_msg_count             NUMBER;
  l_return_status         VARCHAR2(1);
  l_msg_data              VARCHAR2(30);
  i                       NUMBER;
  l_debug                 VARCHAR2(1) := AHL_DEBUG_PUB.is_log_enabled;
  l_master_org_id         NUMBER;
  l_mr_header_id          NUMBER;

  l_csi_min_id            NUMBER;
  l_csi_max_id            NUMBER;
  l_csi_eff_min_id        NUMBER;
  l_csi_eff_max_id        NUMBER;
  l_num_workers           NUMBER;
  l_end_csi_id            NUMBER;
  l_start_csi_id          NUMBER;
  l_step                  NUMBER;
  l_req_id                NUMBER;
  l_count                 NUMBER;
  l_total_count           NUMBER := 0;

  l_csi_inst_tbl         nbr_tbl_type;

  --check whether the given mr exists
  CURSOR check_mr_exists(c_mr_header_id number)
  IS
    SELECT mr_header_id
      FROM ahl_mr_headers_app_v
     WHERE mr_header_id = c_mr_header_id;

  --get all the MR effectivity definitions for a given MR
  CURSOR get_mr_effect(c_mr_header_id NUMBER)
  IS
   SELECT mr_header_id, mr_effectivity_id, inventory_item_id
   FROM ahl_mr_effectivities_app_v
   WHERE mr_header_id = c_mr_header_id;

  -- get master org id.
  CURSOR get_master_org_id_csr (c_inventory_item_id IN NUMBER)
  IS
    SELECT itm.organization_id
    FROM mtl_system_items_b itm, mtl_parameters mtl
    WHERE itm.inventory_item_id = c_inventory_item_id
      AND   itm.organization_id = mtl.organization_id
      AND   mtl.master_organization_id = mtl.organization_id;

  -- Get min/max instance ID for a given INV ID.
  CURSOR get_minmax_inst_csr(c_inventory_item_id IN NUMBER,
                             c_inventory_org_id  IN NUMBER)
  IS
    SELECT min(instance_id), max(instance_id), count(instance_id)
    FROM csi_item_instances
    WHERE inventory_item_id = c_inventory_item_id
    AND   inv_master_organization_id = c_inventory_org_id
    AND SYSDATE between trunc(nvl(active_start_date,sysdate)) and
        trunc(nvl(active_end_date,sysdate+1))
    GROUP BY inventory_item_id, inv_master_organization_id;

  -- get instances when mr_header_id is provided.
  CURSOR get_inst( p_mr_header_id      IN NUMBER,
                   c_start_inst_id     IN NUMBER,
                   c_end_inst_id       IN NUMBER)
  IS
  SELECT cii.instance_id
    FROM csi_item_instances cii, ahl_mr_effectivities mre, mtl_system_items_b msi
    WHERE cii.inventory_item_id = msi.inventory_item_id
    AND cii.inv_master_organization_id = msi.organization_id
    AND cii.inventory_item_id = mre.inventory_item_id
    AND mre.mr_header_id = p_mr_header_id
    AND SYSDATE between trunc(nvl(cii.active_start_date,sysdate)) and
        trunc(nvl(cii.active_end_date,sysdate+1))
    AND cii.instance_id >= c_start_inst_id
    AND cii.instance_id <= c_end_inst_id;

BEGIN

  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug('Begin private API: AHL_UMP_PROCESSUNIT_PVT.PROCESS_PM_MR_AFFECTED_ITEMS');
  END IF;

  -- Check whether the mr_header_id exists --
  OPEN check_mr_exists(p_mr_header_id);
  FETCH check_mr_exists INTO l_mr_header_id;
  IF check_mr_exists%NOTFOUND THEN
    CLOSE check_mr_exists;
    FND_MESSAGE.SET_NAME('AHL','AHL_FMP_INVALID_MR');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE check_mr_exists;

  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.debug(' Phase 1');
  END IF;

  -- validate # of workers.
  l_num_workers := p_num_of_workers;

  IF (p_num_of_workers > 30) THEN
     l_num_workers := 30;
  END IF;

  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.debug(' Phase 2:l_num_workers:' || l_num_workers);
  END IF;

  FOR l_mr_effect IN get_mr_effect(p_mr_header_id)
  LOOP
    IF (l_mr_effect.inventory_item_id IS NOT NULL) THEN

        IF l_debug = 'Y' THEN
           AHL_DEBUG_PUB.debug(' Phase 3:Inv Item ID:' || l_mr_effect.inventory_item_id);
        END IF;

        --DBMS_OUTPUT.put_line('API1: Come here in case 1B and l_index is: '||l_index);

        AHL_FMP_COMMON_PVT.validate_item(x_return_status => l_return_status,
                                         x_msg_data => l_msg_data,
                                         p_item_number => NULL,
                                         p_x_inventory_item_id => l_mr_effect.inventory_item_id);
        IF (l_return_status = 'S') THEN

           IF l_debug = 'Y' THEN
              AHL_DEBUG_PUB.debug('Phase 4: Inv Item ID is Valid');
           END IF;
           -- get master organization id.
           OPEN get_master_org_id_csr(l_mr_effect.inventory_item_id);
           FETCH get_master_org_id_csr INTO l_master_org_id;
           IF (get_master_org_id_csr%NOTFOUND) THEN
              FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_MASORG_NOTFOUND');
              FND_MESSAGE.Set_Token('INV_ID',l_mr_effect.inventory_item_id);
              FND_MSG_PUB.ADD;
              --DBMS_OUTPUT.put_line('Master org not found for inventory item:' || l_mr_effect.inventory_item_id);
              ClOSE get_master_org_id_csr;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
           CLOSE get_master_org_id_csr;

           OPEN get_minmax_inst_csr(l_mr_effect.inventory_item_id,l_master_org_id);
           FETCH get_minmax_inst_csr INTO l_csi_eff_min_id, l_csi_eff_max_id, l_count;
           IF (get_minmax_inst_csr%FOUND) THEN
              IF ((l_csi_min_id IS NULL) OR (l_csi_eff_min_id < l_csi_min_id)) THEN
                  l_csi_min_id := l_csi_eff_min_id;
              END IF;

              IF ((l_csi_max_id IS NULL) OR (l_csi_max_id < l_csi_eff_max_id)) THEN
                 l_csi_max_id := l_csi_eff_max_id;
              END IF;
              l_total_count := l_count + l_total_count;

           END IF;
           CLOSE get_minmax_inst_csr;

           IF l_debug = 'Y' THEN
              AHL_DEBUG_PUB.debug(' Phase 5:csi_min:csi_max:count:' || l_csi_min_id || ':' || l_csi_max_id || ':' ||
                                    l_total_count);
           END IF;

        END IF; -- l_return_status = 'S'
      END IF; -- l_mr_effect.inventory_item_id IS NOT NULL
    END LOOP; -- l_mr_effect

    IF (p_concurrent_flag = 'Y') THEN
       -- launch workers after assigning instance range.
       IF (l_num_workers < 15) THEN
          Instance_Split_BTree(p_csi_max_id  => l_csi_max_id,
                               p_csi_min_id  => l_csi_min_id,
                               p_num_workers => p_num_of_workers,
                               p_mr_header_id => p_mr_header_id,
                               p_total_inst_count  => l_total_count);
       ELSE
          Instance_Split_Sequential(p_csi_max_id  => l_csi_max_id,
                                    p_csi_min_id  => l_csi_min_id,
                                    p_num_workers => p_num_of_workers,
                                    p_mr_header_id => p_mr_header_id);

       END IF;
    ELSE
       -- process all instances.
       OPEN get_inst(p_mr_header_id, l_csi_min_id, l_csi_max_id);
       LOOP

         FETCH get_inst BULK COLLECT INTO l_csi_inst_tbl LIMIT 1000;
         IF (l_csi_inst_tbl.count > 0) THEN
           -- call process unit for all instances.

           FOR i IN l_csi_inst_tbl.FIRST..l_csi_inst_tbl.LAST  LOOP
             -- Call Process Unit for the item instance.
             Process_Unit (
                         p_commit               => FND_API.G_TRUE,
                         p_init_msg_list        => FND_API.G_TRUE,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data,
                         x_return_status        => x_return_status,
                         p_csi_item_instance_id => l_csi_inst_tbl(i),
                         p_concurrent_flag      => 'N');

             IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               EXIT;
             END IF;

           END LOOP; -- l_csi_inst_tbl.FIRST
         END IF; -- l_csi_inst_tbl.count
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           EXIT;
         END IF;

         EXIT WHEN get_inst%NOTFOUND;
       END LOOP; -- get_inst.
       CLOSE get_inst;
    END IF; -- p_concurrent_flag

END Process_PM_MR_Affected_Items;

----------------------------------------------
-- Split instance range into blocks based on instance IDs.
PROCEDURE Instance_Split_Sequential(p_csi_max_id  in NUMBER,
                                    p_csi_min_id  IN NUMBER,
                                    p_num_workers IN NUMBER,
                                    p_mr_header_id IN NUMBER)
IS

  l_debug                 VARCHAR2(1) := AHL_DEBUG_PUB.is_log_enabled;

  l_csi_min_id            NUMBER;
  l_csi_max_id            NUMBER;
  l_csi_eff_min_id        NUMBER;
  l_csi_eff_max_id        NUMBER;
  l_num_workers           NUMBER;
  l_end_csi_id            NUMBER;
  l_start_csi_id          NUMBER;
  l_step                  NUMBER;
  l_req_id                NUMBER;

BEGIN

    l_num_workers := p_num_workers;
    l_csi_min_id := p_csi_min_id;
    l_csi_max_id := p_csi_max_id;

    -- split the instances based on # of workers and launch seperate concurrent
    -- programs to process a group of instances.
    IF (l_csi_max_id IS NOT NULL) AND (l_csi_min_id IS NOT NULL) THEN
       l_step := round((l_csi_max_id - l_csi_min_id) / l_num_workers);

       IF (l_step < 1) THEN
          l_step := l_csi_max_id - l_csi_min_id;
          l_num_workers := 1;
       END IF;

       l_start_csi_id := l_csi_min_id;

       IF l_debug = 'Y' THEN
          AHL_DEBUG_PUB.debug('l_step:' || l_step  || 'start csi: end csi' || l_start_csi_id || ':' || l_end_csi_id);
       END IF;

       -- loop through
       WHILE (l_start_csi_id < l_csi_max_id) LOOP
         l_end_csi_id := l_start_csi_id + l_step;
         IF (l_end_csi_id > l_csi_max_id) THEN
            l_end_csi_id := l_csi_max_id;
         END IF;

         IF l_debug = 'Y' THEN
          AHL_DEBUG_PUB.debug('Loop start csi: end csi' || l_start_csi_id || ':' || l_end_csi_id);
         END IF;

         -- launch BUE worker request.
         l_req_id := fnd_request.submit_request('AHL','AHLWUEFF',NULL,NULL,FALSE, p_mr_header_id, l_start_csi_id, l_end_csi_id);

         IF (l_req_id = 0 OR l_req_id IS NULL) THEN
            IF l_debug = 'Y' THEN
              AHL_DEBUG_PUB.debug('Tried to submit concurrent request but failed');
            END IF;
            fnd_file.put_line(FND_FILE.LOG, 'Failed submit concurrent request');
            fnd_file.new_line(FND_FILE.LOG,1);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         ELSE
              fnd_file.put_line(FND_FILE.LOG, 'Concurrent request ID:' || l_req_id || ' launched to process instances between:' || l_start_csi_id || ' and ' || l_end_csi_id);

            IF l_debug = 'Y' THEN
              AHL_DEBUG_PUB.debug('Concurrent request ID:' || l_req_id || ' launched to process instances between:' || l_start_csi_id || ' and ' || l_end_csi_id);
            END IF;
         END IF;

         l_start_csi_id := l_end_csi_id + 1;

       END LOOP;
    END IF;

END Instance_Split_Sequential;

----------------------------------------------
-- Split instances based on instance count.
PROCEDURE Instance_Split_BTree(p_csi_max_id  in NUMBER,
                               p_csi_min_id  IN NUMBER,
                               p_num_workers IN NUMBER,
                               p_mr_header_id IN NUMBER,
                               p_total_inst_count  IN NUMBER)
IS

  l_debug                 VARCHAR2(1) := AHL_DEBUG_PUB.is_log_enabled;
  l_step number;
  l_start_csi_id number;
  l_launched_workers number;
  l_mid_point_inst_id number;
  l_count number;
  l_req_id number;
  l_end_csi_id number;
  l_begin_count_csi_id number;

  l_tol_after number;
  l_tol_bef   number;

  l_num_workers number;

  cursor csi_inst_count_csr (p_start_inst_id in number,
                             p_end_inst_id   in number,
                             p_mr_header_id  in number) IS
    SELECT count(instance_id)
    FROM csi_item_instances csi, ahl_mr_effectivities me
    WHERE csi.instance_id >= p_start_inst_id and csi.instance_id <= p_end_inst_id
    AND csi.inventory_item_id = me.inventory_item_id
    AND me.mr_header_id = p_mr_header_id
    AND SYSDATE between trunc(nvl(active_start_date,sysdate)) and
        trunc(nvl(active_end_date,sysdate+1));

BEGIN
    IF l_debug = 'Y' THEN
       AHL_DEBUG_PUB.debug('Start of procedure: Instance_Split_BTree');
       AHL_DEBUG_PUB.debug('p_mr_header_id:' || p_mr_header_id);
       AHL_DEBUG_PUB.debug('p_num_workers:' || p_num_workers);
       AHL_DEBUG_PUB.debug('p_csi_max_id:' || p_csi_max_id);
       AHL_DEBUG_PUB.debug('p_csi_min_id:' || p_csi_min_id);
       AHL_DEBUG_PUB.debug('p_total_inst_count:' || p_total_inst_count);
    END IF;

    l_num_workers := p_num_workers;

    IF (p_total_inst_count > 0 ) THEN
       IF (l_num_workers = 1) THEN
         -- launch BUE worker request.
         l_req_id := fnd_request.submit_request('AHL','AHLWUEFF',NULL,NULL,FALSE, p_mr_header_id,
                                                p_csi_min_id, p_csi_max_id);

         IF (l_req_id = 0 OR l_req_id IS NULL) THEN
            IF l_debug = 'Y' THEN
              AHL_DEBUG_PUB.debug('Tried to submit concurrent request but failed');
            END IF;
            fnd_file.put_line(FND_FILE.LOG, 'Failed submit concurrent request');
            fnd_file.new_line(FND_FILE.LOG,1);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         ELSE
              fnd_file.put_line(FND_FILE.LOG, 'Concurrent request ID:' || l_req_id || ' launched to process instances between:' || p_csi_min_id || ' and ' || p_csi_min_id);

            IF l_debug = 'Y' THEN
              AHL_DEBUG_PUB.debug('Concurrent request ID:' || l_req_id || ' launched to process instances between:' || p_csi_min_id || ' and ' || p_csi_min_id);
            END IF;
         END IF;

       ELSE
         -- find optimal and tolerant count of instances and hence the start and
         -- end instance ID for each worker.
         l_step := round(p_total_inst_count/l_num_workers);
         IF (l_step = 0) THEN
           l_num_workers := p_total_inst_count;
           l_step := 1;
         END IF;
         l_tol_bef := l_step - trunc((0.1 * l_step));
         l_tol_after := l_step + trunc((0.1 * l_step));

         IF l_debug = 'Y' THEN
            AHL_DEBUG_PUB.debug('l_step:' || l_step);
            AHL_DEBUG_PUB.debug('l_tol_bef:' || l_tol_bef);
            AHL_DEBUG_PUB.debug('l_tol_after:' || l_tol_after);
         END IF;

         --dbms_output.put_line('l_Step:' || l_step);
         --dbms_output.put_line('l_tol_minus:' || l_tol_bef);
         --dbms_output.put_line('l_tol_plus:' || l_tol_after);

         -- use binary search logic to find the start and end points for every worker.
         l_begin_count_csi_id := p_csi_min_id;
         l_start_csi_id := p_csi_min_id;
         l_end_csi_id := p_csi_max_id;

         l_launched_workers := 0;

         --l_mid_point_inst_id := trunc((p_csi_min_id + p_csi_max_id) / 2);
         l_mid_point_inst_id := p_csi_max_id; -- start with full interval.

         WHILE (l_launched_workers < l_num_workers) loop

             WHILE (true) LOOP

               IF l_debug = 'Y' THEN
                  AHL_DEBUG_PUB.debug('Start loop:l_begin_count_csi_id:' || l_begin_count_csi_id);
                  AHL_DEBUG_PUB.debug('l_start_csi_id:' || l_start_csi_id);
                  AHL_DEBUG_PUB.debug('l_mid_point_inst_id:' || l_mid_point_inst_id);
                  --dbms_output.put_line('l_start_csi_id:' || l_start_csi_id);
                  --dbms_output.put_line('l_mid_point_inst_id:' || l_mid_point_inst_id);
               END IF;

               OPEN csi_inst_count_csr(l_begin_count_csi_id, l_mid_point_inst_id, p_mr_header_id);
               FETCH csi_inst_count_csr INTO l_count;
               CLOSE csi_inst_count_csr;

               IF l_debug = 'Y' THEN
                  AHL_DEBUG_PUB.debug('l_count:' || l_count);
               END IF;
               -- dbms_output.put_line('l_count:' || l_count);

               IF (l_count >= l_tol_bef AND l_count <= l_tol_after) THEN

                  l_launched_workers := l_launched_workers + 1;

                  -- launch BUE worker request.
                  l_req_id := fnd_request.submit_request('AHL','AHLWUEFF',NULL,NULL,FALSE, p_mr_header_id,
                                                         l_begin_count_csi_id, l_mid_point_inst_id);

                  --dbms_output.put_line('new l_launched_workers:' || l_launched_workers);
                  --dbms_output.put_line('newB l_begin_count_csi_id:' || l_begin_count_csi_id);
                  --dbms_output.put_line('newB l_mid_point_inst_id:' || l_mid_point_inst_id);

                  IF (l_req_id = 0 OR l_req_id IS NULL) THEN
                     IF l_debug = 'Y' THEN
                       AHL_DEBUG_PUB.debug('Tried to submit concurrent request but failed');
                     END IF;
                     fnd_file.put_line(FND_FILE.LOG, 'Failed submit concurrent request');
                     fnd_file.new_line(FND_FILE.LOG,1);
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSE
                     fnd_file.put_line(FND_FILE.LOG, 'Concurrent request ID:' || l_req_id ||
                     ' launched to process instances between:' || l_begin_count_csi_id || ' and ' ||
                      l_mid_point_inst_id);

                     IF l_debug = 'Y' THEN
                       AHL_DEBUG_PUB.debug('Concurrent request ID:' || l_req_id ||
                       ' launched to process instances between:' || l_begin_count_csi_id || ' and ' ||
                       l_mid_point_inst_id);
                     END IF;
                  END IF;
                  IF (l_launched_workers = l_num_workers - 1) THEN
                     -- launch last worker.
                     l_begin_count_csi_id := l_mid_point_inst_id + 1;
                     l_mid_point_inst_id := p_csi_max_id;
                     l_launched_workers := l_launched_workers + 1;
                     l_req_id := fnd_request.submit_request('AHL','AHLWUEFF',NULL,NULL,FALSE, p_mr_header_id,
                                                            l_begin_count_csi_id, l_mid_point_inst_id);
                     IF (l_req_id = 0 OR l_req_id IS NULL) THEN
                        IF l_debug = 'Y' THEN
                          AHL_DEBUG_PUB.debug('Tried to submit concurrent request but failed');
                        END IF;
                        fnd_file.put_line(FND_FILE.LOG, 'Failed submit concurrent request');
                        fnd_file.new_line(FND_FILE.LOG,1);
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                     ELSE
                        fnd_file.put_line(FND_FILE.LOG, 'Concurrent request ID:' || l_req_id ||
                        ' launched to process instances between:' || l_begin_count_csi_id || ' and ' ||
                         l_mid_point_inst_id);

                        IF l_debug = 'Y' THEN
                          AHL_DEBUG_PUB.debug('Concurrent request ID:' || l_req_id ||
                          ' launched to process instances between:' || l_begin_count_csi_id || ' and ' ||
                          l_mid_point_inst_id);
                        END IF;
                     END IF; -- l_req_id = 0 OR ..
                  END IF;
                  EXIT;
               ELSIF (l_count < l_step) THEN
                  l_start_csi_id := l_mid_point_inst_id;
                  l_mid_point_inst_id := trunc((l_mid_point_inst_id + l_end_csi_id) /2);
                  --dbms_output.put_line('new l_mid_point_inst_id:<' || l_mid_point_inst_id);
               ELSIF (l_count > l_step) THEN
                  l_end_csi_id := l_mid_point_inst_id;
                  l_mid_point_inst_id := trunc((l_mid_point_inst_id + l_start_csi_id)/2);
                  --dbms_output.put_line('new l_mid_point_inst_id:>' || l_mid_point_inst_id);

               END IF; -- l_count >= l_tol_bef..
             END LOOP; -- WHILE (true)
             -- initialize begin, start and end points for next worker.
             l_begin_count_csi_id := l_mid_point_inst_id+1;
             l_start_csi_id := l_mid_point_inst_id+1;
             l_end_csi_id := p_csi_max_id;
             l_mid_point_inst_id := trunc((l_start_csi_id + l_end_csi_id) / 2);
         END LOOP;

     END IF;
  END IF;

  IF l_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('End of procedure: Instance_Split_BTree');
  END IF;

END Instance_Split_BTree;

----------------------------------------------
-- PM Build unit Effectivities worker concurrent program.
PROCEDURE Process_Unit_Range (
                     errbuf                 OUT NOCOPY  VARCHAR2,
                     retcode                OUT NOCOPY  NUMBER,
                     p_mr_header_id         IN NUMBER,
                     p_start_instance_id    IN NUMBER,
                     p_end_instance_id      IN NUMBER)
IS

  -- get instances when mr_header_id is provided.
  CURSOR get_inst( p_mr_header_id      IN NUMBER,
                   c_start_inst_id     IN NUMBER,
                   c_end_inst_id       IN NUMBER)
  IS
  SELECT cii.instance_id
    FROM csi_item_instances cii, ahl_mr_effectivities mre, mtl_system_items_b msi
    -- repalced mtl_system_items_kfv with mtl_system items_b.
    WHERE cii.inventory_item_id = msi.inventory_item_id
    AND cii.inv_master_organization_id = msi.organization_id
    AND cii.inventory_item_id = mre.inventory_item_id
    AND mre.mr_header_id = p_mr_header_id
    AND SYSDATE between trunc(nvl(cii.active_start_date,sysdate)) and
        trunc(nvl(cii.active_end_date,sysdate+1))
    AND cii.instance_id >= c_start_inst_id
    AND cii.instance_id <= c_end_inst_id;

  -- get instances when no mr_header_id.
  CURSOR get_all_inst( c_start_inst_id IN NUMBER,
                       c_end_inst_id   IN NUMBER)
  IS
  SELECT cii.instance_id
   FROM  csi_item_instances cii, ahl_mr_effectivities mre, mtl_system_items_b msi,
         (select mr_header_id
          from ahl_mr_headers_app_v
          where type_code = 'PROGRAM') mr
   WHERE cii.inventory_item_id = msi.inventory_item_id
     AND cii.inv_master_organization_id = msi.organization_id
     AND cii.inventory_item_id = mre.inventory_item_id
     AND mre.mr_header_id = mr.mr_header_id
     AND SYSDATE between trunc(nvl(cii.active_start_date,sysdate)) and
         trunc(nvl(cii.active_end_date,sysdate+1))
     AND cii.instance_id >= c_start_inst_id
     AND cii.instance_id <= c_end_inst_id;

  l_msg_count  NUMBER;
  l_msg_data   VARCHAR2(3000);
  l_return_status VARCHAR2(1);

  -- added for performance fix 6511501.
  TYPE nbr_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_csi_inst_tbl  nbr_tbl_type;

BEGIN

    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG,'MR Header ID = '||p_mr_header_id);
      fnd_file.put_line(FND_FILE.LOG,'CSI Start Instance = '||p_start_instance_id);
      fnd_file.put_line(FND_FILE.LOG,'CSI End Instance = '||p_end_instance_id);
      fnd_file.put_line(FND_FILE.LOG,'Start Time:' || to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));
      fnd_file.new_line(FND_FILE.LOG,1);
    END IF;

    -- initialize return status.
    retcode := 0;
    IF (p_mr_header_id IS NOT NULL) THEN
      OPEN get_inst(p_mr_header_id, p_start_instance_id, p_end_instance_id);
    ELSE
      OPEN get_all_inst(p_start_instance_id, p_end_instance_id);
    END IF;


    LOOP
      IF (p_mr_header_id IS NOT NULL) THEN
        FETCH get_inst BULK COLLECT INTO l_csi_inst_tbl LIMIT 1000;
      ELSE
        FETCH get_all_inst BULK COLLECT INTO l_csi_inst_tbl LIMIT 1000;
      END IF;

      IF (l_csi_inst_tbl.count > 0) THEN
        -- call process unit for all instances.
        --FOR inst_rec IN get_inst(p_mr_header_id, p_start_instance_id, p_end_instance_id) LOOP
        FOR i IN l_csi_inst_tbl.FIRST..l_csi_inst_tbl.LAST  LOOP
           -- Call Process Unit for the item instance.
           Process_Unit (
                         p_commit               => FND_API.G_TRUE,
                         p_init_msg_list        => FND_API.G_TRUE,
                         x_msg_count            => l_msg_count,
                         x_msg_data             => l_msg_data,
                         x_return_status        => l_return_status,
                         p_csi_item_instance_id => l_csi_inst_tbl(i),
                                                   --inst_rec.instance_id,
                         p_concurrent_flag      => 'Y');

           l_msg_count := FND_MSG_PUB.Count_Msg;
           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
           THEN
               retcode := 2;  -- error based only on return status
           ELSIF (l_msg_count > 0 AND l_return_status = FND_API.G_RET_STS_SUCCESS)
           THEN
               retcode := 1;  -- warning based on return status + msg count
           END IF;

        END LOOP; -- l_csi_inst_tbl.FIRST
      END IF; -- l_csi_inst_tbl.count

      IF (p_mr_header_id IS NOT NULL) THEN
        EXIT WHEN get_inst%NOTFOUND;
      ELSE
        EXIT WHEN get_all_inst%NOTFOUND;
      END IF;

    END LOOP; -- get_inst.
    IF (p_mr_header_id IS NOT NULL) THEN
      CLOSE get_inst;
    ELSE
      CLOSE get_all_inst;
    END IF;

    IF G_DEBUG = 'Y' THEN
      fnd_file.new_line(FND_FILE.LOG,1);
      fnd_file.put_line(FND_FILE.LOG,'End Time:' || to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));
    END IF;

--
EXCEPTION
 WHEN OTHERS THEN
   retcode := 2;
   errbuf := 'Process_Unit_Range:PM:OTHERS:' || substrb(sqlerrm,1,60);

END Process_Unit_Range;

----------------------------------------------
-- Added for performance bug# 6893404.
PROCEDURE Split_Process_All_Instances(p_concurrent_flag  IN  VARCHAR2,
                                      p_commit_flag      IN  VARCHAR2,
                                      p_num_of_workers   IN  NUMBER,
                                      p_mr_header_id     IN  NUMBER,
                                      p_mtl_category_id  IN  NUMBER,
                                      p_process_option   IN  VARCHAR2,
                                      x_msg_count        OUT NOCOPY  NUMBER,
                                      x_msg_data         OUT NOCOPY  NUMBER,
                                      x_return_status    OUT NOCOPY  VARCHAR2)
IS

  l_req_id        number;
  l_conc_req_id   number;
  l_instance_id   number;

  l_num_of_workers number;

  dml_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(dml_errors, -24381);

BEGIN

  IF G_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('Start Split_Process_All_Instances:p_concurrent_flag:' || p_concurrent_flag);
     AHL_DEBUG_PUB.debug('Input MR Header ID:' || p_mr_header_id);
     AHL_DEBUG_PUB.debug('Input p_num_of_workers:' || p_num_of_workers);
  END IF;

  -- initialize return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_concurrent_flag = 'Y') THEN
    l_conc_req_id := fnd_global.conc_request_id;
  ELSE
    l_conc_req_id := fnd_global.session_id;
  END IF;

  -- validate p_num_of_workers.
  l_num_of_workers := trunc(p_num_of_workers);

  IF (l_num_of_workers IS NULL OR l_num_of_workers <= 0) THEN
    l_num_of_workers := 1;
  ELSIF l_num_of_workers > 30 THEN
    l_num_of_workers := 30;
  END IF;

  Populate_BUE_Worker(p_conc_request_id => l_conc_req_id,
                      p_concurrent_flag => p_concurrent_flag,
                      p_mtl_category_id => p_mtl_category_id,
                      p_process_option  => p_process_option,
                      errbuf            => x_msg_data,
                      x_return_status   => x_return_status);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RETURN;
  END IF;

  -- launch worker programs.
  IF (p_concurrent_flag = 'Y') THEN
      -- submit worker programs to process units.
      FOR i IN 1..l_num_of_workers LOOP
         l_req_id := fnd_request.submit_request('AHL','AHLWUEFF',NULL,NULL,FALSE, l_conc_req_id);
         IF (l_req_id = 0 OR l_req_id IS NULL) THEN
            IF G_debug = 'Y' THEN
               AHL_DEBUG_PUB.debug('Tried to submit concurrent request but failed');
            END IF;
            fnd_file.put_line(FND_FILE.LOG, 'Failed submit concurrent request');
            fnd_file.new_line(FND_FILE.LOG,1);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         ELSE
            fnd_file.put_line(FND_FILE.LOG, 'Concurrent request ID:' || l_req_id );
            IF G_debug = 'Y' THEN
               AHL_DEBUG_PUB.debug('Concurrent request ID:' || l_req_id );
            END IF;
         END IF; -- l_req_id = 0 OR ..

      END LOOP;

      -- call cleanup BUE for previously failed deletes.
     Cleanup_BUE_Worker(p_parent_conc_request_id => l_conc_req_id,
                        p_child_conc_request_id  => NULL);
  ELSE

     LOOP
        -- initialize return status.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        Get_Next_BUE_Row(p_parent_conc_pgm_id  => l_conc_req_id,
                         p_conc_child_req_id   => l_conc_req_id,
                         x_return_status       => x_return_status,
                         errbuf                => x_msg_data,
                         x_item_instance_id    => l_instance_id);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           EXIT;
        END IF;

        EXIT WHEN (l_instance_id IS NULL);

        IF G_DEBUG = 'Y' THEN
           AHL_DEBUG_PUB.debug('Now processing..:' || l_instance_id);
        END IF;

        -- Call Process Unit for the item instance.
        Process_Unit (
                p_commit               => p_commit_flag,
                p_init_msg_list        => FND_API.G_TRUE,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data,
                x_return_status        => x_return_status,
                p_csi_item_instance_id => l_instance_id,
                p_concurrent_flag      => p_concurrent_flag);

        IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) AND (p_commit_flag = FND_API.G_FALSE) THEN
          EXIT;
        END IF;

     END LOOP;

     -- cleanup worker table after processing.
     Cleanup_BUE_Worker(p_parent_conc_request_id => l_conc_req_id,
                        p_child_conc_request_id  => l_conc_req_id);

  END IF;

  IF G_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('End Split_Process_All_Instances:Return Status:' || x_return_status);
  END IF;

END Split_Process_All_Instances;

----------------------------------------------
-- BUE Worker program for AHL processing.
-- Called from BUE concurrent pgm when all units option is chosen..
-- or when BUE is run for an MR or MR revision.
PROCEDURE Process_Unit_Range (errbuf                 OUT NOCOPY  VARCHAR2,
                              retcode                OUT NOCOPY  NUMBER,
                              p_parent_conc_pgm_id   IN NUMBER)
IS
  l_instance_id     NUMBER;
  l_conc_child_req_id NUMBER;

  l_msg_count  NUMBER;
  l_msg_data   VARCHAR2(3000);
  l_return_status VARCHAR2(1);

BEGIN

  fnd_file.put_line(FND_FILE.LOG,'Start time:' || to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));

  G_DEBUG_LINE_NUM := 1;

  -- initialize return status.
  retcode := 0;

  l_conc_child_req_id := fnd_global.conc_request_id;

  IF G_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('Start Process_Unit_Range for concurrent pgm ID:' || l_conc_child_req_id);
     AHL_DEBUG_PUB.debug('Parent concurrent pgm ID:' || p_parent_conc_pgm_id);
  END IF;

  -- AHL processing.
  LOOP
    -- initialize return status.
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    G_DEBUG_LINE_NUM := 10;

    -- get next unit to process.
    Get_Next_BUE_Row(p_parent_conc_pgm_id  => p_parent_conc_pgm_id,
                     p_conc_child_req_id   => l_conc_child_req_id,
                     x_return_status       => l_return_status,
                     errbuf                => errbuf,
                     x_item_instance_id    => l_instance_id);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       EXIT;
    END IF;

    EXIT WHEN (l_instance_id IS NULL);

    fnd_file.new_line(FND_FILE.LOG,1);
    fnd_file.put_line(FND_FILE.LOG,'Now processing..:' || l_instance_id);
    fnd_file.put_line(FND_FILE.LOG,'Start time:' || to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));

    G_DEBUG_LINE_NUM := 20;

    -- Call Process Unit for the item instance.
    Process_Unit (
           p_commit               => FND_API.G_TRUE,
           p_init_msg_list        => FND_API.G_TRUE,
           x_msg_count            => l_msg_count,
           x_msg_data             => l_msg_data,
           x_return_status        => l_return_status,
           p_csi_item_instance_id => l_instance_id,
           p_concurrent_flag      => 'Y');

    fnd_file.put_line(FND_FILE.LOG,'End time:' || to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));

    l_msg_count := FND_MSG_PUB.Count_Msg;
    IF (retcode <> 2 AND l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
       retcode := 2;  -- error based only on return status
    ELSIF (retcode = 0 AND l_msg_count > 0 AND l_return_status = FND_API.G_RET_STS_SUCCESS)
    THEN
       retcode := 1;  -- warning based on return status + msg count
    END IF;

  END LOOP;

  G_DEBUG_LINE_NUM := 30;

  -- cleanup worker table after processing.
  Cleanup_BUE_Worker(p_parent_conc_request_id => p_parent_conc_pgm_id,
                     p_child_conc_request_id  => l_conc_child_req_id);


  IF G_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('Concurrent pgm retcode:' || retcode);
     AHL_DEBUG_PUB.debug('Concurrent pgm l_return_status:' || l_return_status);
     AHL_DEBUG_PUB.debug('End Process_Unit_Range for concurrent pgm ID:' || l_conc_child_req_id);
  END IF;

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   retcode := 2;
   errbuf := 'Process_Unit_Range:EXC:' || G_DEBUG_LINE_NUM || ':' || substrb(sqlerrm,1,60);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   retcode := 2;
   errbuf := 'Process_Unit_Range:UNEXP:' || G_DEBUG_LINE_NUM || ':' || substrb(sqlerrm,1,60);

 WHEN OTHERS THEN
   IF (SQLCODE = -54) THEN
     retcode := 1;
     errbuf := 'Process_Unit_Range:54:' || G_DEBUG_LINE_NUM || ':' || substrb(sqlerrm,1,60);
   ELSIF (SQLCODE = -6519) THEN
     retcode := 1;
     errbuf := 'Process_Unit_Range:6519:' || G_DEBUG_LINE_NUM || ':' || substrb(sqlerrm,1,60);
   ELSE
     retcode := 2;
     errbuf := 'Process_Unit_Range:OTH:' || G_DEBUG_LINE_NUM || ':' || substrb(sqlerrm,1,60);
   END IF;

END Process_Unit_Range;
------------------------
-- BUE Worker program for AHL processing.
-- This procedure is called after a MR is revised.
PROCEDURE Process_Unit_Range (errbuf                 OUT NOCOPY  VARCHAR2,
                              retcode                OUT NOCOPY  NUMBER,
                              p_old_mr_header_id     IN          NUMBER,
                              p_new_mr_header_id     IN          NUMBER)

IS

  l_return_status      varchar2(1);
  l_msg_count          number;
  l_msg_data           varchar2(2000);

BEGIN

    fnd_file.put_line(FND_FILE.LOG,'Start time:' || to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));

    IF G_debug = 'Y' THEN
       AHL_DEBUG_PUB.debug('Start Process_Unit_Range for MR: Old ID:New ID:' || p_old_mr_header_id || ':' || p_new_mr_header_id);
    END IF;

    -- initialize return status.
    retcode := 0;

    -- After commit call UMP BUE api to build UEs.
    AHL_UMP_PROCESSUNIT_PVT.Process_MRAffected_Units (
           p_commit          => FND_API.G_TRUE,
           x_msg_count       => l_msg_count,
           x_msg_data        => l_msg_data,
           x_return_status   => l_return_status, -- ignore status returned by this api.
           p_old_mr_header_id  => p_old_mr_header_id,
           p_mr_header_id      => p_new_mr_header_id,
           p_concurrent_flag   => 'Y',
           p_num_of_workers    => 5);

    l_msg_count := FND_MSG_PUB.Count_Msg;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
       retcode := 2;  -- error based only on return status
       log_error_messages;
    ELSIF (l_msg_count > 0 AND l_return_status = FND_API.G_RET_STS_SUCCESS)
    THEN
       retcode := 1;  -- warning based on return status + msg count
       log_error_messages;
    END IF;

    IF G_debug = 'Y' THEN
       AHL_DEBUG_PUB.debug('End Process_Unit_Range for MR: retcode:' || retcode);
    END IF;

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   retcode := 2;
   errbuf := 'Process_Unit_Range:MR:EXC:' || G_DEBUG_LINE_NUM || ':' || substrb(sqlerrm,1,60);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   retcode := 2;
   errbuf := 'Process_Unit_Range:MR:UNEXP:' || G_DEBUG_LINE_NUM || ':' || substrb(sqlerrm,1,60);

 WHEN OTHERS THEN
   IF (SQLCODE = -54) THEN
     retcode := 1;
     errbuf := 'Process_Unit_Range:54:' || G_DEBUG_LINE_NUM || ':' || substrb(sqlerrm,1,70);
   ELSIF (SQLCODE = -6519) THEN
     retcode := 1;
     errbuf := 'Process_Unit_Range:6519:' || G_DEBUG_LINE_NUM || ':' || substrb(sqlerrm,1,70);
   ELSE
     retcode := 2;
     errbuf := 'Process_Unit_Range:MR:OTH:' || substrb(sqlerrm,1,60);
   END IF;

END Process_Unit_Range;

------------------------
-- Added for performance bug# 6893404.
PROCEDURE Populate_BUE_Worker(p_conc_request_id IN  NUMBER,
                              p_concurrent_flag IN  VARCHAR2,
                              p_mtl_category_id IN  NUMBER,
                              p_process_option  IN  VARCHAR2,
                              errbuf            OUT NOCOPY VARCHAR2,
                              x_return_status   OUT NOCOPY VARCHAR2)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_instance_id_tbl   nbr_tbl_type;
  l_unit_name_tbl     vchar_tbl_type;

  -- get all valid uc headers
  CURSOR ahl_unit_config_header_csr IS
    SELECT csi_item_instance_id
    FROM  ahl_unit_config_headers
    WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
      AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
      AND unit_config_status_code <> 'DRAFT'
      AND parent_uc_header_id IS NULL;

  -- get all valid uc headers that match item category.
  CURSOR ahl_unit_itemcat_csr(p_mtl_category_id IN NUMBER) IS
    SELECT csi_item_instance_id
    FROM  ahl_unit_config_headers uc
    WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
      AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
      AND unit_config_status_code <> 'DRAFT'
      AND parent_uc_header_id IS NULL
      AND exists (select 'x'
                  from mtl_category_set_valid_cats cs, mtl_item_categories itc,
                       csi_item_instances cii2
                  where cs.category_set_id = fnd_profile.value('AHL_BUE_ITEM_CATEGORY_SET')
                    AND cs.category_set_id = itc.category_set_id
                    AND cs.category_id = itc.category_id
                    AND itc.category_id = p_mtl_category_id
                    AND cii2.instance_id = uc.csi_item_instance_id
                    AND itc.organization_id = cii2.inv_master_organization_id
                    AND itc.inventory_item_id = cii2.inventory_item_id
                  ); -- get units matching item category.


  -- get item instances matching inventory item id.
  -- when no item category and process option = 'Units or Components' or all
  CURSOR get_uc_item_inst_csr(p_opt_uc IN NUMBER) IS
    SELECT instance_id from
     (SELECT DISTINCT nvl(root_instance_id, instance_id) instance_id from
       (
        SELECT cii.instance_id,
              (select object_id from csi_ii_relationships parent
               where not exists (select 'x' from csi_ii_relationships
                                 where subject_id = parent.object_id and
                                 relationship_type_code = 'COMPONENT-OF' and
                                 trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate) and
                                 trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1)))
               start with parent.subject_id = cii.instance_id and
               parent.relationship_type_code = 'COMPONENT-OF' and
               trunc(nvl(parent.active_start_date, sysdate)) <= trunc(sysdate) and
               trunc(sysdate) < trunc(nvl(parent.active_end_date, sysdate+1))
               connect by prior parent.object_id = parent.subject_id and
               parent.relationship_type_code = 'COMPONENT-OF' and
               trunc(nvl(parent.active_start_date, sysdate)) <= trunc(sysdate) and
               trunc(sysdate) < trunc(nvl(parent.active_end_date, sysdate+1))
               ) Root_instance_id

        FROM csi_item_instances cii, ahl_mr_effectivities mre
        WHERE mre.inventory_item_id = nvl(null, mre.inventory_item_id)
          AND mre.mr_header_id = nvl(null,mre.mr_header_id)
          -- added nvl conditions above as this seems to force use of index on
          -- ahl_mr_headers_b and also brings query cost down.
          AND mre.relationship_id is null
          AND mre.inventory_item_id = cii.inventory_item_id
          AND exists (SELECT 'x' from ahl_mr_headers_app_v MR
                       WHERE MR.mr_header_id = mre.mr_header_id
                         AND MR.program_type_code NOT IN ('MO_PROC')
                         AND MR.version_number in (SELECT max(MRM.version_number)
                                                   FROM ahl_mr_headers_app_v MRM
                                                   WHERE mrm.title = mr.title
                                                     AND SYSDATE between trunc(MR.effective_from)
                                                     AND trunc(nvl(MR.effective_to,SYSDATE+1))
                                                     AND mr_status_code='COMPLETE'
                                                  )
                     )
          AND trunc(nvl(cii.active_start_date, sysdate)) <= trunc(sysdate)
          AND trunc(sysdate) < trunc(nvl(cii.active_end_date, sysdate+1))
       )
     ) valid_inst
    WHERE /*(p_opt_uc = 1 AND exists (select 'x' from ahl_unit_config_headers
                                    where csi_item_instance_id = valid_inst.instance_id
                                      AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                      AND unit_config_status_code <> 'DRAFT'
                                      AND parent_uc_header_id IS NULL
                                   ) -- get UCs only.
          )
          OR */  -- this cursor is not used when p_opt_uc = 1
          -- get components.
          (p_opt_uc = 2 AND not exists (select 'x' from ahl_unit_config_headers
                                        where csi_item_instance_id = valid_inst.instance_id
                                          AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                          AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                          -- instance is a UC if in status draft.
                                          --AND unit_config_status_code <> 'DRAFT'
                                          --AND parent_uc_header_id IS NULL
                                       )
          )
          OR
          -- get all but ignore UCs as they have alredy been selected.
          (p_opt_uc = 0 AND not exists (select 'x' from ahl_unit_config_headers
                                        where csi_item_instance_id = valid_inst.instance_id
                                          AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                          AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                          -- instance is a UC if in status draft.
                                          --AND unit_config_status_code <> 'DRAFT'
                                          --AND parent_uc_header_id IS NULL
                                       )
          );

  -- get item instances matching inventory item id, item cat and is a UC.
  -- when item category selected with process option of ALL, Units or Components.
  CURSOR get_uc_itemcat_inst_csr (p_mtl_category_id IN NUMBER,
                                  p_opt_uc          IN NUMBER) IS
    SELECT instance_id from
     (SELECT DISTINCT nvl(root_instance_id, instance_id) instance_id from
       (
        SELECT cii.instance_id,
              (select object_id from csi_ii_relationships parent
               where not exists (select 'x' from csi_ii_relationships
                                 where subject_id = parent.object_id and
                                 relationship_type_code = 'COMPONENT-OF' and
                                 trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate) and
                                 trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1)))
               start with parent.subject_id = cii.instance_id and
               parent.relationship_type_code = 'COMPONENT-OF' and
               trunc(nvl(parent.active_start_date, sysdate)) <= trunc(sysdate) and
               trunc(sysdate) < trunc(nvl(parent.active_end_date, sysdate+1))
               connect by prior parent.object_id = parent.subject_id and
               parent.relationship_type_code = 'COMPONENT-OF' and
               trunc(nvl(parent.active_start_date, sysdate)) <= trunc(sysdate) and
               trunc(sysdate) < trunc(nvl(parent.active_end_date, sysdate+1))
               ) Root_instance_id

        FROM csi_item_instances cii,
             (select distinct me.inventory_item_id
              from ahl_mr_headers_app_v mr, ahl_mr_effectivities me
              where mr.mr_header_id = me.mr_header_id AND
                    mr.mr_status_code = 'COMPLETE' AND
                    MR.program_type_code NOT IN ('MO_PROC') AND -- added in R12
                    trunc(effective_from) <= trunc(sysdate) AND
                    trunc(nvl(effective_to,sysdate)) >= trunc(sysdate)
                    and me.inventory_item_id is not null
             ) mre
        WHERE trunc(nvl(cii.active_start_date, sysdate)) <= trunc(sysdate) AND
              trunc(sysdate) < trunc(nvl(cii.active_end_date, sysdate+1))
          AND mre.inventory_item_id = cii.inventory_item_id
       )
     ) valid_inst
    WHERE exists (select 'x'
                  from mtl_category_set_valid_cats cs, mtl_item_categories itc,
                       csi_item_instances cii2
                  where cs.category_set_id = fnd_profile.value('AHL_BUE_ITEM_CATEGORY_SET')
                    AND cs.category_set_id = itc.category_set_id
                    AND cs.category_id = itc.category_id
                    AND itc.category_id = p_mtl_category_id
                    AND cii2.instance_id = valid_inst.instance_id
                    AND itc.organization_id = cii2.inv_master_organization_id
                    AND itc.inventory_item_id = cii2.inventory_item_id
                  ) -- get root nodes matching item category.

      AND ((p_opt_uc = 1 AND exists (select 'x' from ahl_unit_config_headers
                                    where csi_item_instance_id = valid_inst.instance_id
                                      AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                      AND unit_config_status_code <> 'DRAFT'
                                      AND parent_uc_header_id IS NULL
                                   ) -- get UCs only.
          )
          OR
          -- get components.
          (p_opt_uc = 2 AND not exists (select 'x' from ahl_unit_config_headers
                                        where csi_item_instance_id = valid_inst.instance_id
                                          AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                          AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                          -- instance is a UC if in status draft.
                                          --AND unit_config_status_code <> 'DRAFT'
                                          --AND parent_uc_header_id IS NULL
                                       )
          )
          OR
          -- when process option is ALL.
          -- get components in this case too as UC's have already been selected.
          (p_opt_uc = 0 AND not exists (select 'x' from ahl_unit_config_headers
                                        where csi_item_instance_id = valid_inst.instance_id
                                          AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                          AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                          -- instance is a UC if in status draft.
                                          --AND unit_config_status_code <> 'DRAFT'
                                          --AND parent_uc_header_id IS NULL
                                       )
          )
          );

  l_buffer_limit  number := 5000;
  l_opt_uc        number;

  dml_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(dml_errors, -24381);

BEGIN

  IF G_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('Start Populate_BUE_Worker for pgm ID:' || p_conc_request_id);
     AHL_DEBUG_PUB.debug('Concurrent flag:' || p_concurrent_flag);
  END IF;

  -- initialize return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_process_option = 'AHL_BUE_ALL_COMPONENTS') THEN
     l_opt_uc := 2;
  ELSIF (p_process_option = 'AHL_BUE_ALL_UNITS') THEN
     l_opt_uc := 1;
  ELSE
     l_opt_uc := 0; -- when opt is null or AHL_BUE_ALL
  END IF;

  -- get all unit configurations.
  IF (l_opt_uc IN (0,1)) THEN

      IF (p_mtl_category_id IS NULL) THEN
        OPEN ahl_unit_config_header_csr;
      ELSE
        OPEN ahl_unit_itemcat_csr(p_mtl_category_id);
      END IF;

      LOOP
        IF (p_mtl_category_id IS NULL) THEN
          FETCH ahl_unit_config_header_csr BULK COLLECT INTO l_instance_id_tbl LIMIT l_buffer_limit;
        ELSE
          FETCH ahl_unit_itemcat_csr BULK COLLECT INTO l_instance_id_tbl LIMIT l_buffer_limit;
        END IF;

        EXIT WHEN (l_instance_id_tbl.count = 0);

        -- insert into BUE table.
        FORALL instance_indx IN l_instance_id_tbl.FIRST..l_instance_id_tbl.LAST
          INSERT INTO AHL_BUE_WORKER_DATA
          (parent_conc_request_id,
           csi_item_instance_id,
           child_conc_request_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number) VALUES
           (p_conc_request_id,
            l_instance_id_tbl(instance_indx),
            null,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.conc_login_id,
            1);

        l_instance_id_tbl.DELETE;

      END LOOP;

      IF (p_mtl_category_id IS NULL) THEN
         CLOSE ahl_unit_config_header_csr;
      ELSE
         CLOSE ahl_unit_itemcat_csr;
      END IF;

  END IF; -- (l_opt_uc IN (0,1))

  IF (l_opt_uc <> 1) THEN -- skip when only processing units.
    -- now process instances based on inventory_item_id.
    IF (p_mtl_category_id IS NULL) THEN
        OPEN get_uc_item_inst_csr(l_opt_uc);
    ELSE
        OPEN get_uc_itemcat_inst_csr(p_mtl_category_id, l_opt_uc);
    END IF;

    LOOP
      IF (p_mtl_category_id IS NULL) THEN
          FETCH get_uc_item_inst_csr BULK COLLECT INTO l_instance_id_tbl LIMIT l_buffer_limit;
      ELSE
          FETCH get_uc_itemcat_inst_csr BULK COLLECT INTO l_instance_id_tbl LIMIT l_buffer_limit;
      END IF;

      EXIT WHEN (l_instance_id_tbl.count = 0);

      BEGIN
        -- insert into BUE table.
        FORALL instance_indx IN l_instance_id_tbl.FIRST..l_instance_id_tbl.LAST SAVE EXCEPTIONS
          INSERT INTO AHL_BUE_WORKER_DATA
          (parent_conc_request_id,
           csi_item_instance_id,
           child_conc_request_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number) VALUES
           (p_conc_request_id,
            l_instance_id_tbl(instance_indx),
            null,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.conc_login_id,
            1);

        EXCEPTION
          WHEN DML_ERRORS THEN
            IF (get_uc_item_inst_csr%ISOPEN) THEN
              CLOSE get_uc_item_inst_csr;
            END IF;
            IF (get_uc_itemcat_inst_csr%ISOPEN) THEN
              CLOSE get_uc_itemcat_inst_csr;
            END IF;

            x_return_status := 'E';

            IF (p_concurrent_flag = 'Y') THEN
              fnd_file.put_line(fnd_file.log, 'Following error(s) occured while inserting into table ahl_bue_worker_data');
              FOR j IN 1..sql%bulk_exceptions.count
              LOOP
                fnd_file.put_line(fnd_file.log, sql%bulk_exceptions(j).error_index || ', ' ||
                sqlerrm(-sql%bulk_exceptions(j).error_code) );
              END LOOP;
            END IF;

            FND_MESSAGE.set_name('AHL', 'AHL_UMP_BUE_WORKER_ERR');
            FND_MSG_PUB.add;
            errbuf := FND_MSG_PUB.Get;

            RETURN;
      END;

      l_instance_id_tbl.DELETE;

    END LOOP;

    IF (p_mtl_category_id IS NULL) THEN
       CLOSE get_uc_item_inst_csr;
    ELSE
       CLOSE get_uc_itemcat_inst_csr;
    END IF;
  END IF; -- l_opt_uc

  -- delete duplicate rows.
  DELETE FROM ahl_bue_worker_data
  WHERE parent_conc_request_id = p_conc_request_id
    AND rowid not in (SELECT MIN(rowid)
                      FROM ahl_bue_worker_data
                      WHERE parent_conc_request_id = p_conc_request_id
                      GROUP BY csi_item_instance_id, parent_conc_request_id) ;

  -- save changes.
  COMMIT WORK;

  IF G_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('Concurrent pgm x_return_status:' || x_return_status);
     AHL_DEBUG_PUB.debug('End Populate_BUE_Worker for pgm ID:' || p_conc_request_id);
  END IF;

END Populate_BUE_Worker;

-- Added for performance bug# 6893404.
PROCEDURE Get_Next_BUE_Row(p_parent_conc_pgm_id    IN  NUMBER,
                           p_conc_child_req_id     IN  NUMBER,
                           x_return_status         OUT NOCOPY VARCHAR2,
                           errbuf                  OUT NOCOPY VARCHAR2,
                           x_item_instance_id      OUT NOCOPY NUMBER)
IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  CURSOR ahl_bue_worker_csr (p_parent_conc_pgm_id IN NUMBER)
  IS
    SELECT rowid, csi_item_instance_id, object_version_number
    FROM ahl_bue_worker_data
    WHERE parent_conc_request_id = p_parent_conc_pgm_id
      AND child_conc_request_id IS NULL;
    --FOR UPDATE OF child_conc_request_id;

 CURSOR bue_lock_row (p_rowid IN urowid, p_parent_conc_pgm_id IN NUMBER )
  IS
    SELECT rowid, csi_item_instance_id
    FROM ahl_bue_worker_data
    WHERE parent_conc_request_id = p_parent_conc_pgm_id
      AND child_conc_request_id IS NULL
      AND ROWID = p_rowid
    FOR UPDATE OF child_conc_request_id NOWAIT;

  l_instance_id  NUMBER;

  record_locked   EXCEPTION;
  pragma exception_init (record_locked, -54);

  l_status        NUMBER;
  l_rowid         UROWID;
  l_object_version_number  NUMBER;

BEGIN
  IF G_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('Start Get_Next_BUE_Row: Parent Conc Request ID:' || p_parent_conc_pgm_id);
     AHL_DEBUG_PUB.debug('Child Conc Request ID:' || p_conc_child_req_id);
  END IF;

  --DBMS_LOCK.SLEEP(60);

  -- get next unprocessed row.
  OPEN ahl_bue_worker_csr(p_parent_conc_pgm_id);
  LOOP
     l_status := 0;
     BEGIN
        FETCH ahl_bue_worker_csr INTO l_rowid, l_instance_id, l_object_version_number;
        IF (ahl_bue_worker_csr%FOUND) THEN
            -- lock row
            OPEN bue_lock_row(l_rowid, p_parent_conc_pgm_id);
            FETCH bue_lock_row into l_rowid, l_instance_id;
            IF (bue_lock_row%FOUND) THEN
              -- update only if ovn remains the same.
              UPDATE ahl_bue_worker_data
              set child_conc_request_id = p_conc_child_req_id,
              last_update_date = sysdate,
              object_version_number = object_version_number + 1,
              last_update_login = fnd_global.login_id,
              last_updated_by = fnd_global.user_id
              WHERE ROWID = l_rowid
                AND object_version_number = l_object_version_number;
                --WHERE CURRENT OF ahl_bue_worker_csr;

              COMMIT WORK;
            ELSE
              l_status := 100;
              ROLLBACK;
            END IF;
            CLOSE bue_lock_row;

        ELSE
            l_instance_id := NULL;
            ROLLBACK;
        END IF;
      EXCEPTION
        WHEN record_locked THEN
          -- select next row.
          l_status := -54;
          ROLLBACK;
          IF (bue_lock_row%ISOPEN) THEN
             CLOSE bue_lock_row;
          END IF;

        WHEN NO_DATA_FOUND THEN
          -- select next row.
          l_status := 100;
          ROLLBACK;
          IF (bue_lock_row%ISOPEN) THEN
             CLOSE bue_lock_row;
          END IF;

        WHEN OTHERS THEN
          ROLLBACK;
          l_status := SQLCODE;
          errbuf := 'Get_Next_BUE_Row:' || substrb(sqlerrm,1,60);
          l_instance_id := NULL;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF (bue_lock_row%ISOPEN) THEN
             CLOSE bue_lock_row;
          END IF;
     END;

     IF (l_status = 0) THEN
        -- success or end of rows.
        EXIT;
     ELSIF (l_status <> -54 AND l_status <> 100) THEN
        EXIT;
     END IF;

  END LOOP; -- select next row.

  CLOSE ahl_bue_worker_csr;
  x_item_instance_id := l_instance_id;

  IF G_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('End Get_Next_BUE_Row: x_item_instance_id:' || x_item_instance_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    errbuf := 'AHL_UMP_ProcessUnit_Pvt.Process.Get_Next_BUE_Row:' || SUBSTR(SQLERRM,1,240);
    x_item_instance_id := NULL;

END Get_Next_BUE_Row;

------------------------------------------------------------------
-- Added for performance bug# 6893404.
-- procedure deletes the worker data after processing is complete.
PROCEDURE Cleanup_BUE_Worker(p_parent_conc_request_id IN  NUMBER,
                             p_child_conc_request_id  IN  NUMBER)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;

   CURSOR get_undeleted_parents(p_conc_request_id IN NUMBER) IS
     SELECT DISTINCT parent_conc_request_id
     FROM ahl_bue_worker_data
     WHERE parent_conc_request_id <> p_conc_request_id;

   CURSOR get_undeleted_child(p_conc_request_id IN NUMBER) IS
     SELECT DISTINCT child_conc_request_id
     FROM ahl_bue_worker_data
     WHERE parent_conc_request_id = p_conc_request_id;

   CURSOR lock_child_rows(p_parent_conc_id IN NUMBER,
                          p_child_conc_id  IN NUMBER) IS
     SELECT rowid
     FROM ahl_bue_worker_data
     WHERE parent_conc_request_id = p_parent_conc_id
       AND child_conc_request_id = p_child_conc_id
       FOR UPDATE OF object_version_number NOWAIT;

   CURSOR fnd_concur_csr(p_conc_req_id IN NUMBER) IS
    SELECT 'x'
    FROM fnd_concurrent_requests
    WHERE REQUEST_ID = p_conc_req_id;

   record_locked   EXCEPTION;
   pragma exception_init (record_locked, -54);

   l_req_status boolean;
   l_rphase     varchar2(80);
   l_rstatus    varchar2(80);
   l_dphase     varchar2(30);
   lc_dphase    varchar2(30);
   l_dstatus    varchar2(30);
   l_message    varchar2(240);

   l_buffer_limit number := 100;

   TYPE urowid_tbl_type IS TABLE OF urowid INDEX BY BINARY_INTEGER;

   l_rowid_tbl  urowid_tbl_type;
   l_junk       VARCHAR2(1);

BEGIN

  IF G_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('Start Cleanup_BUE_Worker: Parent Conc Request ID:' || p_parent_conc_request_id);
     AHL_DEBUG_PUB.debug('Child Conc Request ID:' || p_child_conc_request_id);
  END IF;

  IF (p_parent_conc_request_id IS NULL) THEN
    RETURN; -- do nothing
  END IF;

  IF (p_child_conc_request_id IS NOT NULL) THEN
    G_DEBUG_LINE_NUM := 300;
    -- cleanup rows processed by this worker.
    DELETE from ahl_bue_worker_data
    WHERE parent_conc_request_id = p_parent_conc_request_id
      AND child_conc_request_id = p_child_conc_request_id ;
    COMMIT WORK;
  END IF;

  IF (p_child_conc_request_id IS NULL) OR
     (p_child_conc_request_id IS NOT NULL AND p_child_conc_request_id = p_parent_conc_request_id) THEN
    -- this routine is executed by parent conc request. Modified due to ORA-00054 errors reported
    -- when workers are deleting the rows.

    G_DEBUG_LINE_NUM := 310;
    -- cleanup any orphaned rows left from other parent requests.
    FOR undeleted_parent IN get_undeleted_parents(p_parent_conc_request_id) LOOP
       /* not needed - check only child conc request status
       -- check parent status.
       l_req_status := FND_CONCURRENT.GET_REQUEST_STATUS(request_id => undeleted_parent.parent_conc_request_id,
                                                         --appl_shortname => 'AHL',
                                                         --program   => 'AHLUEFF',
                                                         phase      => l_rphase,
                                                         status     => l_rstatus,
                                                         dev_phase  => l_dphase,
                                                         dev_status => l_dstatus,
                                                         message    => l_message);
       IF (l_req_status = TRUE) AND (l_dphase = 'COMPLETE' OR l_dphase IS NULL) THEN
       */

       FOR undeleted_child IN get_undeleted_child(undeleted_parent.parent_conc_request_id) LOOP
           l_req_status := FND_CONCURRENT.GET_REQUEST_STATUS(request_id => undeleted_child.child_conc_request_id,
                                                             --appl_shortname => 'AHL',
                                                             --program   => 'AHLWUEFF',
                                                             phase      => l_rphase,
                                                             status     => l_rstatus,
                                                             dev_phase  => lc_dphase,
                                                             dev_status => l_dstatus,
                                                             message    => l_message);
           IF NOT(l_req_status) THEN
              -- check if request exists in fnd_concurrent_requests table
              OPEN fnd_concur_csr(undeleted_child.child_conc_request_id);
              FETCH fnd_concur_csr INTO l_junk;
              IF (fnd_concur_csr%NOTFOUND) THEN
                l_req_status := TRUE;
                lc_dphase := NULL;
              END IF;
              CLOSE fnd_concur_csr;
           END IF;

           IF (l_req_status = TRUE) AND (lc_dphase = 'COMPLETE' OR lc_dphase IS NULL) THEN
              -- lock and delete rows for undeleted_child.child_conc_request_id.
              OPEN lock_child_rows(undeleted_parent.parent_conc_request_id,
                                   undeleted_child.child_conc_request_id);
              G_DEBUG_LINE_NUM := 320;
              LOOP
                  G_DEBUG_LINE_NUM := 330;
                  FETCH lock_child_rows BULK COLLECT INTO l_rowid_tbl LIMIT l_buffer_limit;
                  --EXIT WHEN (l_rowid_tbl.count = 0);
                  IF (l_rowid_tbl.count = 0) THEN
                    ROLLBACK;
                    EXIT;
                  END IF;

                  G_DEBUG_LINE_NUM := 340;

                  BEGIN
                    SAVEPOINT lock_child_rows_upd_s;
                    FORALL j IN l_rowid_tbl.FIRST..l_rowid_tbl.LAST
                       -- delete for parent concurrent.
                       DELETE FROM ahl_bue_worker_data
                       WHERE rowid = l_rowid_tbl(j);

                    COMMIT;
                    --
                    EXCEPTION
                        WHEN OTHERS THEN
                          rollback to lock_child_rows_upd_s;
                          EXIT; -- abort delete for child.
                          -- dbms_output.put_line('Record Locked');
                  END;

                  l_rowid_tbl.delete;

              END LOOP;
              CLOSE lock_child_rows;

           END IF; -- l_req_status and lc_dphase
       END LOOP; -- undeleted_child IN

     --END IF; -- (l_dphase = 'COMPLETE')
    END LOOP; -- undeleted_parent IN
  END IF; -- p_child_conc_request_id IS NULL

  IF G_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('End Cleanup_BUE_Worker');
  END IF;

EXCEPTION
  WHEN record_locked THEN
    IF (lock_child_rows%ISOPEN) THEN
      CLOSE lock_child_rows;
    END IF;
    ROLLBACK;
    -- dbms_output.put_line('Record Locked');

END Cleanup_BUE_Worker;

-- Added for performance bug# 6893404.
PROCEDURE Populate_BUE_Worker_for_MR(p_conc_request_id IN  NUMBER,
                                     p_mr_header_id    IN  NUMBER,
                                     p_concurrent_flag IN  VARCHAR2,
                                     p_mtl_category_id IN  NUMBER,
                                     p_process_option  IN  VARCHAR2,
                                     x_return_status   OUT NOCOPY VARCHAR2)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- get item instances that are either components
  -- or a UC when no item category and process option = Units or Components or all.
  CURSOR get_inst_csr (p_mr_header_id IN NUMBER,
                       p_opt_uc       IN NUMBER) IS
    SELECT instance_id from
     (SELECT DISTINCT nvl(root_instance_id, instance_id) instance_id from
       (
        SELECT cii.instance_id,
              (select object_id from csi_ii_relationships parent
               where not exists (select 'x' from csi_ii_relationships
                                 where subject_id = parent.object_id and
                                 relationship_type_code = 'COMPONENT-OF' and
                                 trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate) and
                                 trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1)))
               start with parent.subject_id = cii.instance_id and
               parent.relationship_type_code = 'COMPONENT-OF' and
               trunc(nvl(parent.active_start_date, sysdate)) <= trunc(sysdate) and
               trunc(sysdate) < trunc(nvl(parent.active_end_date, sysdate+1))
               connect by prior parent.object_id = parent.subject_id and
               parent.relationship_type_code = 'COMPONENT-OF' and
               trunc(nvl(parent.active_start_date, sysdate)) <= trunc(sysdate) and
               trunc(sysdate) < trunc(nvl(parent.active_end_date, sysdate+1))
               ) Root_instance_id

        FROM csi_item_instances cii, ahl_mr_instances_temp mr
        WHERE trunc(nvl(cii.active_start_date, sysdate)) <= trunc(sysdate) AND
              trunc(sysdate) < trunc(nvl(cii.active_end_date, sysdate+1))
          AND mr.item_instance_id  = cii.instance_id
       )
     ) valid_inst
    WHERE (p_opt_uc = 1 AND exists (select 'x' from ahl_unit_config_headers
                                    where csi_item_instance_id = valid_inst.instance_id
                                      AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                      AND unit_config_status_code <> 'DRAFT'
                                      AND parent_uc_header_id IS NULL
                                   ) -- get UCs only.
          )
          OR
          -- get components.
          (p_opt_uc = 2 AND not exists (select 'x' from ahl_unit_config_headers
                                        where csi_item_instance_id = valid_inst.instance_id
                                      AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                          -- instance is a UC if in status draft.
                                          --AND unit_config_status_code <> 'DRAFT'
                                          --AND parent_uc_header_id IS NULL
                                       )
          )
          OR
          -- get all but do not select draft UCs as Process Unit will raise error.
          (p_opt_uc = 0 AND not exists (select 'x' from ahl_unit_config_headers
                                        where csi_item_instance_id = valid_inst.instance_id
                                          AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                          AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                          AND unit_config_status_code = 'DRAFT'
                                       )
          );


  -- get item instances when item category selected with process option of ALL, Units or Components.
  CURSOR get_itemcat_inst_csr (p_mr_header_id IN NUMBER,
                               p_mtl_category_id IN NUMBER,
                               p_opt_uc          IN NUMBER) IS
    SELECT instance_id from
     (SELECT DISTINCT nvl(root_instance_id, instance_id) instance_id from
       (
        SELECT cii.instance_id,
              (select object_id from csi_ii_relationships parent
               where not exists (select 'x' from csi_ii_relationships
                                 where subject_id = parent.object_id and
                                 relationship_type_code = 'COMPONENT-OF' and
                                 trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate) and
                                 trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1)))
               start with parent.subject_id = cii.instance_id and
               parent.relationship_type_code = 'COMPONENT-OF' and
               trunc(nvl(parent.active_start_date, sysdate)) <= trunc(sysdate) and
               trunc(sysdate) < trunc(nvl(parent.active_end_date, sysdate+1))
               connect by prior parent.object_id = parent.subject_id and
               parent.relationship_type_code = 'COMPONENT-OF' and
               trunc(nvl(parent.active_start_date, sysdate)) <= trunc(sysdate) and
               trunc(sysdate) < trunc(nvl(parent.active_end_date, sysdate+1))
               ) Root_instance_id

        FROM csi_item_instances cii,ahl_mr_instances_temp mr
        WHERE trunc(nvl(cii.active_start_date, sysdate)) <= trunc(sysdate) AND
              trunc(sysdate) < trunc(nvl(cii.active_end_date, sysdate+1))
          AND mr.item_instance_id  = cii.instance_id
       )
     ) valid_inst
    WHERE exists (select 'x'
                  from mtl_category_set_valid_cats cs, mtl_item_categories itc,
                       csi_item_instances cii2
                  where cs.category_set_id = fnd_profile.value('AHL_BUE_ITEM_CATEGORY_SET')
                    AND cs.category_set_id = itc.category_set_id
                    AND cs.category_id = itc.category_id
                    AND itc.category_id = p_mtl_category_id
                    AND cii2.instance_id = valid_inst.instance_id
                    AND itc.organization_id = cii2.inv_master_organization_id
                    AND itc.inventory_item_id = cii2.inventory_item_id
                  ) -- get root nodes matching item category.
      -- either UC or components.
      AND ((p_opt_uc = 1 AND exists (select 'x' from ahl_unit_config_headers
                                    where csi_item_instance_id = valid_inst.instance_id
                                      AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                      AND unit_config_status_code <> 'DRAFT'
                                      AND parent_uc_header_id IS NULL
                                   ) -- get UCs only.
          )
          OR
          -- get components.
          (p_opt_uc = 2 AND not exists (select 'x' from ahl_unit_config_headers
                                        where csi_item_instance_id = valid_inst.instance_id
                                      AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                          -- instance is a UC if in status draft.
                                          --AND unit_config_status_code <> 'DRAFT'
                                          --AND parent_uc_header_id IS NULL
                                       )
          )
          OR
          -- when process option is ALL. Ignore Draft UC's
          (p_opt_uc = 0 AND not exists (select 'x' from ahl_unit_config_headers
                                        where csi_item_instance_id = valid_inst.instance_id
                                          AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                          AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
                                          AND unit_config_status_code = 'DRAFT'
                                       )
          )
          );


  -- get UEs for the MR that are not existing in BUE worker table.
  CURSOR get_extra_ue_na(p_mr_header_id IN NUMBER,
                         p_conc_request_id IN NUMBER)  IS
    SELECT csi_item_instance_id
    FROM (
          SELECT DISTINCT nvl(Root_instance_id, csi_item_instance_id) csi_item_instance_id
          FROM (
                SELECT DISTINCT UE.csi_item_instance_id,
                                (select object_id from csi_ii_relationships parent
                                 where not exists (select 'x' from csi_ii_relationships
                                                   where subject_id = parent.object_id and
                                                   trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1)))
                                 start with parent.subject_id = UE.CSI_ITEM_INSTANCE_ID and
                                 parent.relationship_type_code = 'COMPONENT-OF' and
                                 trunc(nvl(parent.active_start_date, sysdate)) <= trunc(sysdate) and
                                 trunc(sysdate) < trunc(nvl(parent.active_end_date, sysdate+1))
                                 connect by prior parent.object_id = parent.subject_id and
                                 parent.relationship_type_code = 'COMPONENT-OF' and
                                 trunc(nvl(parent.active_start_date, sysdate)) <= trunc(sysdate) and
                                 trunc(sysdate) < trunc(nvl(parent.active_end_date, sysdate+1))
                                ) Root_instance_id

                FROM  ahl_unit_effectivities_app_v UE
                WHERE UE.mr_header_id = p_mr_header_id
                  AND (UE.status_code IS NULL OR UE.status_code IN ('INIT-DUE','EXCEPTION'))
                  AND  NOT EXISTS (Select 1
                                   FROM ahl_mr_instances_temp
                                   WHERE item_instance_id = ue.csi_item_instance_id)
                                  )
         ) valid_inst
    WHERE NOT EXISTS (Select 1
                      FROM AHL_BUE_WORKER_DATA
                      WHERE csi_item_instance_id = valid_inst.csi_item_instance_id
                        AND parent_conc_request_id = p_conc_request_id) ;

  l_relationship_tbl  nbr_tbl_type;
  l_instance_id_tbl   nbr_tbl_type;

  l_opt           number;
  l_opt_uc        number;

  l_buffer_limit  number := 1000;

  l_api_version   number := 1.0;
  l_msg_count     number;
  l_msg_data      varchar2(4000);

  dml_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(dml_errors, -24381);

  l_mr_item_instances_tbl  AHL_FMP_PVT.MR_ITEM_INSTANCE_TBL_TYPE;

BEGIN

  IF G_debug = 'Y' THEN
     AHL_DEBUG_PUB.debug('Start Populate_BUE_Worker_for_MR: Input MR Header ID:' || p_mr_header_id);
     AHL_DEBUG_PUB.debug('Input Concurrent Flag:' || p_conc_request_id);
     AHL_DEBUG_PUB.debug('Input Conc Request ID:' || p_concurrent_flag);
  END IF;

  -- initialize return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get instances applicable to the MR.
  -- this API will insert the applicable MRs into temp table ahl_mr_instances_temp
  AHL_FMP_PVT.GET_MR_AFFECTED_ITEMS (
         p_api_version => 1.0,
         p_init_msg_list => FND_API.G_TRUE,
         x_return_status => x_return_status,
         x_msg_count     => l_msg_count,
         x_msg_data      => l_msg_data,
         p_mr_header_id  => p_mr_header_id,
         p_top_node_flag => 'N',
         p_unique_inst_flag => 'Y',
         x_mr_item_inst_tbl => l_mr_item_instances_tbl );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    ROLLBACK;
    RETURN;
  END IF;


  IF (p_process_option = 'AHL_BUE_ALL_COMPONENTS') THEN
     l_opt_uc := 2;
  ELSIF (p_process_option = 'AHL_BUE_ALL_UNITS') THEN
     l_opt_uc := 1;
  ELSE
     l_opt_uc := 0;  -- when null or input is AHL_BUE_ALL
  END IF;

  -- process effectivity
  IF (p_mtl_category_id IS NULL) THEN
      OPEN get_inst_csr(p_mr_header_id, l_opt_uc);
  ELSE
      OPEN get_itemcat_inst_csr(p_mr_header_id, p_mtl_category_id, l_opt_uc);
  END IF;

  LOOP
      IF (p_mtl_category_id IS NULL) THEN
          FETCH get_inst_csr BULK COLLECT INTO l_instance_id_tbl LIMIT l_buffer_limit;
      ELSE
          FETCH get_itemcat_inst_csr BULK COLLECT INTO l_instance_id_tbl LIMIT l_buffer_limit;
      END IF;

      EXIT WHEN (l_instance_id_tbl.count = 0);

      BEGIN
        -- insert into BUE table.
        FORALL instance_indx IN l_instance_id_tbl.FIRST..l_instance_id_tbl.LAST SAVE EXCEPTIONS
          INSERT INTO AHL_BUE_WORKER_DATA
          (parent_conc_request_id,
           csi_item_instance_id,
           child_conc_request_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number) VALUES
           (p_conc_request_id,
            l_instance_id_tbl(instance_indx),
            null,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.conc_login_id,
            1);

        EXCEPTION
          WHEN DML_ERRORS THEN
            IF (get_inst_csr%ISOPEN) THEN
              CLOSE get_inst_csr;
            END IF;
            IF (get_itemcat_inst_csr%ISOPEN) THEN
              CLOSE get_itemcat_inst_csr;
            END IF;

            x_return_status := 'E';

            IF (p_concurrent_flag = 'Y') THEN
              fnd_file.put_line(fnd_file.log, 'Following error(s) occured while inserting into table ahl_bue_worker_data');
              FOR j IN 1..sql%bulk_exceptions.count
              LOOP
                fnd_file.put_line(fnd_file.log, sql%bulk_exceptions(j).error_index || ', ' ||
                sqlerrm(-sql%bulk_exceptions(j).error_code) );
              END LOOP;
            END IF;

            FND_MESSAGE.set_name('AHL', 'AHL_UMP_BUE_WORKER_ERR');
            FND_MSG_PUB.add;

            RETURN;
        END;

        l_instance_id_tbl.DELETE;

  END LOOP;

  IF (p_mtl_category_id IS NULL) THEN
     CLOSE get_inst_csr;
  ELSE
     CLOSE get_itemcat_inst_csr;
  END IF;

  l_instance_id_tbl.DELETE;

  -- process extra UE instances
  OPEN get_extra_ue_na(p_mr_header_id, p_conc_request_id);
  LOOP
    FETCH get_extra_ue_na BULK COLLECT INTO l_instance_id_tbl LIMIT l_buffer_limit;
    EXIT WHEN (l_instance_id_tbl.COUNT = 0);
    BEGIN
      -- insert into BUE table.
      FORALL instance_indx IN l_instance_id_tbl.FIRST..l_instance_id_tbl.LAST SAVE EXCEPTIONS
        INSERT INTO AHL_BUE_WORKER_DATA
          (parent_conc_request_id,
           csi_item_instance_id,
           child_conc_request_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number) VALUES
           (p_conc_request_id,
            l_instance_id_tbl(instance_indx),
            null,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.conc_login_id,
            1);

    EXCEPTION
      WHEN DML_ERRORS THEN

        IF (get_extra_ue_na%ISOPEN) THEN
          CLOSE get_extra_ue_na;
        END IF;
        x_return_status := 'E';

        IF (p_concurrent_flag = 'Y') THEN
          fnd_file.put_line(fnd_file.log, 'Following error(s) occured while inserting into table ahl_bue_worker_data');
          FOR j IN 1..sql%bulk_exceptions.count
          LOOP
            fnd_file.put_line(fnd_file.log, sql%bulk_exceptions(j).error_index || ', ' ||
            sqlerrm(-sql%bulk_exceptions(j).error_code) );
          END LOOP;
        END IF;

        FND_MESSAGE.set_name('AHL', 'AHL_UMP_BUE_WORKER_ERR');
        FND_MSG_PUB.add;

        RETURN;
      END;

      l_instance_id_tbl.DELETE;

  END LOOP;
  CLOSE get_extra_ue_na;

  -- delete duplicate rows.
  DELETE FROM ahl_bue_worker_data
  WHERE parent_conc_request_id = p_conc_request_id
    AND rowid not in (SELECT MIN(rowid)
                      FROM ahl_bue_worker_data
                      WHERE parent_conc_request_id = p_conc_request_id
                      GROUP BY csi_item_instance_id, parent_conc_request_id) ;


  -- save changes.
  COMMIT WORK;

  IF G_debug = 'Y' THEN
    AHL_DEBUG_PUB.debug('End Populate_BUE_Worker_for_MR: x_return_status:' || x_return_status);
  END IF;

END Populate_BUE_Worker_for_MR;

-- Added for performance bug# 6893404.
FUNCTION get_latest_ctr_reading(p_counter_id IN NUMBER) RETURN NUMBER
IS

  -- get net reading.
  CURSOR get_ctr_reading_csr (p_counter_id IN NUMBER) IS
     SELECT * FROM
        (SELECT net_reading
         FROM csi_counter_readings
         WHERE counter_id = p_counter_id
           AND nvl(disabled_flag,'N') = 'N'
         ORDER BY value_timestamp desc)
     WHERE rownum < 2;

  l_net_reading NUMBER;

BEGIN

  OPEN get_ctr_reading_csr(p_counter_id);
  FETCH get_ctr_reading_csr INTO l_net_reading;
  IF (get_ctr_reading_csr%NOTFOUND) THEN
     l_net_reading := 0;
  END IF;
  CLOSE get_ctr_reading_csr;

  RETURN l_net_reading;

END get_latest_ctr_reading;
----

-- procedure checks if forecast exists for all of instance's UOM and adds
-- zero forecast row if missing forecast.
PROCEDURE validate_uf_for_ctr(p_current_usage_tbl       IN counter_values_tbl_type,
                              p_x_forecast_details_tbl  IN OUT NOCOPY forecast_details_tbl_type)
IS
  l_last_index  NUMBER;
  l_uom_found_flag BOOLEAN;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('Start validate_uf_for_ctr');
  END IF;

  l_last_index := p_x_forecast_details_tbl.LAST + 1;

  IF (p_current_usage_tbl.COUNT > 0) THEN
    FOR j IN p_current_usage_tbl.FIRST..p_current_usage_tbl.LAST LOOP
       l_uom_found_flag := FALSE;
       IF (p_x_forecast_details_tbl.COUNT > 0) THEN
         FOR i IN p_x_forecast_details_tbl.FIRST..p_x_forecast_details_tbl.LAST LOOP
           IF (p_x_forecast_details_tbl(i).uom_code = p_current_usage_tbl(j).uom_code) THEN
             l_uom_found_flag := TRUE;
             EXIT;
           END IF;
         END LOOP;  -- i

         IF (l_uom_found_flag = FALSE) THEN
            p_x_forecast_details_tbl(l_last_index).uom_code := p_current_usage_tbl(j).uom_code;
            p_x_forecast_details_tbl(l_last_index).start_date := trunc(sysdate);
            p_x_forecast_details_tbl(l_last_index).end_date := NULL;
            p_x_forecast_details_tbl(l_last_index).usage_per_day := 0;

            l_last_index := l_last_index + 1;
         END IF;
       END IF;

    END LOOP; -- j
  END IF; -- p_current_usage_tbl.COUNT

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug ('Count on forecast_details' || p_x_forecast_details_tbl.COUNT);

     IF (p_x_forecast_details_tbl.COUNT > 0) THEN
       FOR i IN p_x_forecast_details_tbl.FIRST..p_x_forecast_details_tbl.LAST LOOP
             AHL_DEBUG_PUB.debug('Forecast Record ('|| i || ') Uom_Code' || p_x_forecast_details_tbl(i).uom_code);
             AHL_DEBUG_PUB.debug('Forecast Record ('|| i || ') Start Date' || p_x_forecast_details_tbl(i).start_date);
             AHL_DEBUG_PUB.debug('Forecast Record ('|| i || ') End Date' || p_x_forecast_details_tbl(i).end_date);
             AHL_DEBUG_PUB.debug('Forecast Record ('|| i || ') Usage' || p_x_forecast_details_tbl(i).usage_per_day);
       END LOOP;
     END IF;
     AHL_DEBUG_PUB.debug ('End validate_uf_for_ctr');
  END IF;

END validate_uf_for_ctr;



END AHL_UMP_ProcessUnit_PVT;

/
