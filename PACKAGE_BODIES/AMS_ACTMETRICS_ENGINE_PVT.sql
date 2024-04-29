--------------------------------------------------------
--  DDL for Package Body AMS_ACTMETRICS_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTMETRICS_ENGINE_PVT" AS
/* $Header: amsvmrnb.pls 120.6.12010000.2 2010/03/17 05:19:27 amlal ship $ */
--------------------------------------------------------------------------------
--
-- NAME
--    AMS_ActMetrics_Engine_PVT 11.5.10
--
-- HISTORY
-- 27-Mar-2001   huili     Created
-- 28-Mar-2001   dmvincen  added core engine
-- 23-Apr-2001   dmvincen  Fixed Traverse_one_node to hand data incosistancy.
-- 23-Apr-2001   dmvincen  Tuned select statements.
-- 17-May-2001   dmvincen  Patch for 11.5.4.07.
-- 21-May-2001   huili     fix bugs for calculation for 11.5.4.07
-- 22-May-2001   dmvincen  Updated for 11.5.4.11 (SUMMARY metrics).
-- 07-June-2001  huili     Changed to new hierarchy for new version 11.5.5
-- 13-June-2001  huili     Added bulk update to set the dirty_flag of parent act
--                         metrics when building the tree
-- 10-Jul-2001   dmvincen  Removed references to ECAM. No such object type.
-- 26-Jul-2001   huili     Removed rollup from "Deliverable"s, added debugging info.
-- 16-Aug-2001   dmvincen  Make sure all functional currencies are the same.
--                         And totaling currencies is homogeneous.
-- 21-Aug-2001   dmvincen  Syncronize the transaction currency with the object.
-- 21-Aug-2001   dmvincen  Do not rollup values of canceled objects unless
--                         actual values are incurred.  BUG# 1868868
-- 21-Aug-2001   dmvincen  Moved type definitions inside this module.  No need
--                         to expose.
-- 18-Oct-2001   dmvincen  Fixed logic error for cancelled objects.
-- 24-Oct-2001   dmvincen  Check for cancelled objects every time.
-- 29-Oct-2001   huili     Add check for the "show_campaign_flag" while looking up
--                         parent campaign for 11.5.6.05. For bug #2082639.
-- 29-Nov-2001   dmvincen  Added Update_History.
-- 14-Dec-2001   dmvincen  Added delta tracking for history.
-- 14-Dec-2001   dmvincen  Turned on history tracking.
-- 04-Jan-2002   dmvincen  Update_history adds new metrics and checks deleted.
--                         Improved queries for updating history.
--                         Changed log message for better detail and tracking.
-- 09-Jan-2002   dmvincen  BUG2175735: Performance improvements.
-- 10-Jan-2002   dmvincen  BUG2175735: Removed first_rows hint.
-- 15-Jan-2002   huili        Added the "p_update_history" to the
--                            "Refresh_Act_Metrics_Engine" module.
-- 28-Jan-2002   dmvincen  p_update_history flag excepts 'Y' and 'T'.
-- 06-Feb-2002   dmvincen  BUG2214496: Wrap delta calc with NVL(..,0).
-- 08-Mar-2002   dmvincen  Added columns to Update_History, description,
--                         act_metric_date, function_used_by_id,
--                         arc_function_used_by.
-- 28-Mar-2002   dmvincen  Added dialog and components.
-- 12-Jun-2002   dmvincen  BUG2385692: Fixed function update.
-- 27-Nov-2002   dmvincen  Added refreshing at the object level.
-- 11-Dec-2003   dmvincen  Added Batch commit.
-- 07-Feb-2003   dmvincen  BUG2789661: Added NOCOPY.
-- 13-Feb-2003   dmvincen  BUG2802817: Fixed FORALL array check.
-- 03-Mar-2003   dmvincen  Handle create actmetric failure, report and ignore.
-- 03-Mar-2003   dmvincen  Added intermediate commits to not repeat work on failure.
-- 11-Mar-2003   dmvincen  BUG2832400: Ignore invalid object hierarchy.
-- 19-Mar-2003   choang    Bug 2853777 - Added DELV to get_object_list.
-- 21-May-2003   dmvincen  Performance enhancements in calculate this metric.
-- 21-May-2003   dmvincen  Back port synchronization to 11.5.8.1R.
-- 21-Aug-2003   dmvincen  Updated variable metric calculations.
-- 21-Aug-2003   dmvincen  Updated history to include all fields.
-- 21-Aug-2003   dmvincen  Adding Formula calculation functionality.
-- 22-Aug-2003   dmvincen  Added APIs for Run_functions, Update_Variable,
--                         and Update_formulas.
-- 22-Aug-2003   dmvincen  Added Display Type support.
-- 28-Aug-2003   dmvincen  BUG3119211 - Removed a first_rows hint.
-- 29-Aug-2003   dmvincen  BUG3121639: Level counter not set correctly.
-- 17-Sep-2003   sunkumar  Object level locking introduced in get_object_lists.
-- 12-Nov-2003   choang    Removed "ams." and fixed p_commit param.
-- 14-Nov-2003   dmvincen  Setting dirty flag for formulas.
-- 14-Nov-2003   dmvincen  Purge the formula definition before reloading.
-- 25-Nov-2003   dmvincen  Check stack under flow on pop formula.
-- 25-Nov-2003   dmvincen  Always set msg_count for return values.
-- 16-Dec-2003   dmvincen  BUG3322880: Added ALIST.
-- 16-Jan-2004   dmvincen  BUG3355479,3192350: Fix to delete history.
-- 16-Jan-2004   dmvincen  Removed locking, only required when creating metrics.
-- 23-Feb-2004   dmvincen  BUG3456849: Wrong event to program link.
-- 15-Mar-2004   dmvincen  BUG3478590: Variable forecast times multi-forecast.
-- 02-Apr-2004   dmvincen  BUG3551174: Variable actual divide by zero.
-- 15-Jun-2004   dmvincen  BUG3687608: Initialize run_function arrays.
-- 17-Sep-2004   dmvincen  BUG3484528: Drive currency with display type.
--
-- Global variables and constants.
--
-- Name of the current package.
G_PKG_NAME CONSTANT VARCHAR2(30) := 'AMS_ACTMETRICS_ENGINE_PVT';
G_MAX_VALUE CONSTANT NUMBER := 3.5E24;
G_MAX_DEPTH CONSTANT NUMBER := 50;
G_MAX_DIRTY_COUNT CONSTANT NUMBER := 1000000;
--G_MSG_COUNT NUMBER := 10000;

G_BATCH_SIZE number := NVL(FND_PROFILE.value('AMS_BATCH_SIZE'),10000);
G_BATCH_PAD NUMBER := 100; -- Never save less than 100 rows.

G_MARKETING_APP_ID CONSTANT NUMBER := 530;

-- Calculation types
G_ROLLUP CONSTANT VARCHAR2(30) := 'ROLLUP';
G_SUMMARY CONSTANT VARCHAR2(30) := 'SUMMARY';
G_FUNCTION CONSTANT VARCHAR2(30) := 'FUNCTION';
G_FORMULA CONSTANT VARCHAR2(30) := 'FORMULA';
G_MANUAL CONSTANT VARCHAR2(30) := 'MANUAL';

-- Accrual type
G_VARIABLE CONSTANT VARCHAR2(30) := 'VARIABLE';

-- function metric types.
G_IS_FUNCTION CONSTANT VARCHAR2(1) := 'Y';
G_IS_PROCEDURE CONSTANT VARCHAR2(1) := 'N';

-- Frozen flag
G_NOT_FROZEN CONSTANT VARCHAR2(1) := 'N';

-- Update history flag
G_UPDATE_HISTORY CONSTANT VARCHAR2(1) := 'Y';

-- Enabled flag
G_IS_ENABLED CONSTANT VARCHAR2(1) := 'Y';

--
G_SHOW CONSTANT VARCHAR2(1) := 'Y';
G_HIDE CONSTANT VARCHAR2(1) := 'N';

-- Object Types
G_CAMP CONSTANT VARCHAR2(30) := 'CAMP';
G_CSCH CONSTANT VARCHAR2(30) := 'CSCH';
G_DELV CONSTANT VARCHAR2(30) := 'DELV';
G_EVEO CONSTANT VARCHAR2(30) := 'EVEO';
G_EVEH CONSTANT VARCHAR2(30) := 'EVEH';
G_RCAM CONSTANT VARCHAR2(30) := 'RCAM';
G_EONE CONSTANT VARCHAR2(30) := 'EONE';
--G_DILG CONSTANT VARCHAR2(30) := 'DILG';
--G_AMS_COMP_START CONSTANT VARCHAR2(30) := 'AMS_COMP_START';
--G_AMS_COMP_SHOW_WEB_PAGE CONSTANT VARCHAR2(30) := 'AMS_COMP_SHOW_WEB_PAGE';
--G_AMS_COMP_END CONSTANT VARCHAR2(30) := 'AMS_COMP_END';
G_ALIST CONSTANT VARCHAR2(30) := 'ALIST';

-- dirty flag
G_IS_DIRTY CONSTANT VARCHAR2(1) := 'Y';
G_NOT_DIRTY CONSTANT VARCHAR2(1) := 'N';
G_SAVED_DIRTY CONSTANT VARCHAR2(1) := 'S'; -- special internal flag.

-- Value types
G_RATIO CONSTANT VARCHAR2(1) := 'R';

-- Metric category name.
G_COST CONSTANT VARCHAR2(10) := 'COST';

-- Apportioning types.
G_ACTUAL CONSTANT VARCHAR2(10) := 'ACTUAL';
G_COMMITTED CONSTANT VARCHAR2(10) := 'COMMITTED';
G_FORECASTED CONSTANT VARCHAR2(10) := 'FORECASTED';

-- Metric category ids.
G_COST_ID CONSTANT NUMBER := 901;
G_REVENUE_ID CONSTANT NUMBER := 902;

-- Usage types
G_CREATED CONSTANT VARCHAR2(10) := 'CREATED';
G_USED_BY CONSTANT VARCHAR2(10) := 'USED_BY';

-- Display Types
G_INTEGER CONSTANT VARCHAR2(10) := 'INTEGER';
G_PERCENT CONSTANT VARCHAR2(10) := 'PERCENT';
G_CURRENCY CONSTANT VARCHAR2(10) := 'CURRENCY';

-- Formula Types
G_POSTFIX CONSTANT VARCHAR2(10) := 'POSTFIX';
G_CATEGORY CONSTANT VARCHAR2(10) := 'CATEGORY';
G_METRIC CONSTANT VARCHAR2(10) := 'METRIC';
G_NUMBER CONSTANT VARCHAR2(10) := 'NUMBER';
G_OPERATOR CONSTANT VARCHAR2(10) := 'OPERATOR';

-- Formula Operators
G_PLUS CONSTANT VARCHAR2(30) := 'PLUS';
G_MINUS CONSTANT VARCHAR2(30) := 'MINUS';
G_TIMES CONSTANT VARCHAR2(30) := 'TIMES';
G_DIVIDE CONSTANT VARCHAR2(30) := 'DIVIDE';

-- Hierarchy level counter starting point.
G_LEAF_LEVEL CONSTANT NUMBER := 0;

-- Object Status
G_CANCELLED CONSTANT VARCHAR2(30) := 'CANCELLED';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

--
-- Start type definition
--
TYPE act_metric_ids_type IS TABLE
  OF NUMBER INDEX BY BINARY_INTEGER;

--
-- index is metric_id
--
/** OBSOLETE
TYPE met_info_lookup_type IS RECORD (
  value_type VARCHAR2(30),         -- metric.value_type
  metric_calculation_type VARCHAR2(30),  -- metric.metric_caluclation_type
  accrual_type VARCHAR2(30),       -- metric.accural_type
  compute_using_function VARCHAR2(4000), -- metric.compute_using_function
  default_uom_code VARCHAR2(3)    -- mertric.default_uom_code
);

TYPE met_info_set_type IS TABLE
  OF met_info_lookup_type INDEX BY BINARY_INTEGER;
** OBSOLETE **/
--
--index is the activity metric id
--
TYPE act_met_ref_rec_type IS RECORD (
  activity_metric_id NUMBER,
  metric_id NUMBER,
  object_version_number NUMBER,
  metric_uom_code VARCHAR2(3),
  func_forecast_value NUMBER,
  func_actual_value NUMBER,
  func_currency_code VARCHAR2(15),
  summarize_to_metric NUMBER,
  rollup_to_metric NUMBER,
  last_calculated_date DATE,
  days_since_last_refresh NUMBER,
  diff_since_last_calc NUMBER,
  computed_using_function_value NUMBER,
  activity_metric_origin_id NUMBER,
--  variable_value NUMBER,
--  forecasted_variable_value NUMBER,
  trans_currency_code VARCHAR2(15),

  COUNT NUMBER := 0,
  parent_id NUMBER,
--  parent_type CHAR(1),
  dirty_flag CHAR(1) := G_NOT_DIRTY,
  orig_actual_value NUMBER,
  orig_forecast_value NUMBER,
  trans_actual_value NUMBER,
  trans_forecast_value NUMBER,
  depend_act_metric NUMBER,
  arc_act_metric_used_by VARCHAR2(30),
  act_metric_used_by_id NUMBER,

  value_type VARCHAR2(30),         -- metric.value_type
  metric_calculation_type VARCHAR2(30),  -- metric.metric_caluclation_type
  accrual_type VARCHAR2(30),       -- metric.accural_type
  compute_using_function VARCHAR2(4000), -- metric.compute_using_function
  default_uom_code VARCHAR2(3),    -- mertric.default_uom_code
  display_type VARCHAR2(30)
);

TYPE act_met_ref_rec_set_type IS TABLE
  OF act_met_ref_rec_type INDEX BY BINARY_INTEGER;

TYPE date_table_type IS TABLE
  OF DATE INDEX BY BINARY_INTEGER;

TYPE num_table_type IS TABLE
  OF NUMBER INDEX BY BINARY_INTEGER;

TYPE dirty_flag_table_type IS TABLE
  OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

TYPE currency_code_table_type IS TABLE
  OF VARCHAR2(15) INDEX BY BINARY_INTEGER;

TYPE varchar2_table_type IS TABLE
  OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

TYPE char1_table_type IS TABLE
  OF char(1) INDEX BY BINARY_INTEGER;

TYPE object_currency_type IS RECORD (
   obj_id NUMBER,
   obj_type VARCHAR2(30),
   currency VARCHAR2(15)
);
TYPE object_currency_table IS TABLE
   OF object_currency_type INDEX BY BINARY_INTEGER;

Empty_object_currency_table object_currency_table;

TYPE object_detail_type is record (
   obj_type VARCHAR2(30),
   obj_id NUMBER,
   currency VARCHAR2(15),
   parent_type varchar2(30),
   parent_id number,
   cancelled_flag varchar2(1),
   show_flag varchar2(1)
);

TYPE object_detail_table is table
  of object_detail_type index by binary_integer;
/**
TYPE object_list_type is record (
   obj_type varchar2(30),
   object_table object_detail_table
);

type object_list_table is table
  of object_list_type index by binary_integer;

G_OBJECT_CACHE object_list_table;
**/
/**
G_RCAM_Parents_table num_table_type;
G_CSCH_Parents_table num_table_type;
G_EVEO_Parents_table num_table_type;
G_EVEH_Parents_table num_table_type;
G_EONE_Parents_table num_table_type;

G_CAMP_status_table dirty_flag_table_type;
G_CSCH_status_table dirty_flag_table_type;
G_EVEO_status_table dirty_flag_table_type;
G_EVEH_status_table dirty_flag_table_type;
****/

type stack_element_type is record(
     forecasted_value number,
     actual_value number
);

type stack_element_table is table
  of stack_element_type index by binary_integer;

G_STACK stack_element_table;

--
-- End type definition
--


-- Start forward declaration
-- Forward Declaration for private functions since they are not in specs.

PROCEDURE write_msg(p_procedure IN VARCHAR2, p_message IN VARCHAR2)
IS

BEGIN
    Ams_Utility_Pvt.Write_Conc_Log(TO_CHAR(DBMS_UTILITY.get_time)||': '||
            G_PKG_NAME||'.'||p_procedure||': '||p_message);
--     --bms_output.put_line(TO_CHAR(DBMS_UTILITY.get_time)||': '||
--            G_PKG_NAME||'.'||p_procedure||': '||p_message);
END;

PROCEDURE write_error(p_procedure IN varchar2)
IS
   l_msg varchar2(4000);
BEGIN
--   fnd_msg_pub.reset;
   LOOP
      l_msg := fnd_msg_pub.get(p_encoded => FND_API.G_FALSE);
      EXIT WHEN l_msg IS NULL;
      write_msg(p_procedure, 'ERROR: '||l_msg);
   END LOOP;
   --fnd_msg_pub.initialize;
END;

PROCEDURE  Check_Create_Rollup_Parents (
  p_init_msg_list               IN    VARCHAR2 := Fnd_Api.G_FALSE,
  p_commit                      IN    VARCHAR2 := Fnd_Api.G_FALSE,
  x_return_status               OUT NOCOPY    VARCHAR2,
  p_object_list                 IN object_currency_table := Empty_object_currency_table
);

PROCEDURE  Check_Cr_Roll_Par_Helper (
  p_init_msg_list               IN VARCHAR2 := FND_API.G_FALSE,
  p_metric_parent_id            IN NUMBER,
  p_act_metric_id               IN NUMBER,
  p_obj_id                      IN NUMBER,
  p_obj_type                    IN VARCHAR2,
  x_act_metric_parents          IN OUT NOCOPY act_metric_ids_type,
  x_act_metrics                 IN OUT NOCOPY act_metric_ids_type,
  p_depth                       IN NUMBER := 0,
  x_creates                     IN OUT NOCOPY NUMBER,

  x_act_metric_id               OUT NOCOPY NUMBER, -- Id of the activity metric created
  x_return_status               OUT NOCOPY VARCHAR2,
  p_commit                      IN VARCHAR2 := FND_API.G_FALSE
);


--FUNCTION Exec_Function (
--   p_activity_metric_id       IN NUMBER,
--   p_function_name            IN VARCHAR2
--) RETURN NUMBER;


PROCEDURE Get_Met_Apport_Val(
   p_obj_association_id          IN  NUMBER,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_apportioned_value           OUT NOCOPY NUMBER
);

PROCEDURE GetMetCatVal (
   x_return_status             OUT NOCOPY VARCHAR2,
   p_arc_act_metric_used_by    IN  VARCHAR2,
   p_act_metric_used_by_id     IN  NUMBER,
   p_metric_category           IN  VARCHAR2,
   p_return_type               IN  VARCHAR2,
   x_value                     OUT NOCOPY NUMBER
);

FUNCTION Convert_Uom(
   p_from_uom_code  IN  VARCHAR2,
   p_to_uom_code    IN  VARCHAR2,
   p_from_quantity  IN      NUMBER,
   p_precision      IN      NUMBER   DEFAULT NULL,
   p_from_uom_name  IN  VARCHAR2 DEFAULT NULL,
   p_to_uom_name    IN  VARCHAR2 DEFAULT NULL
)
RETURN NUMBER;

PROCEDURE check_object_status(
   p_arc_act_metric_used_by IN VARCHAR2,
   p_act_metric_used_by_id IN NUMBER,
   x_is_canceled OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Object_List(p_arc_act_metric_used_by varchar2,
           p_act_metric_used_by_id number,
           x_return_status OUT NOCOPY    VARCHAR2,
           x_msg_count     OUT NOCOPY    NUMBER,
           x_msg_data      OUT NOCOPY    VARCHAR2,
           x_object_list   OUT NOCOPY    object_currency_table
);

PROCEDURE Run_Functions
        (x_errbuf       OUT NOCOPY   VARCHAR2,
         x_retcode      OUT NOCOPY   NUMBER,
         p_commit       IN    VARCHAR2 := Fnd_Api.G_TRUE,
         p_object_list  IN object_currency_table := Empty_object_currency_table,
         p_current_date IN date,
         p_func_currency IN varchar2
);

PROCEDURE UPDATE_VARIABLE
        (x_errbuf       OUT NOCOPY   VARCHAR2,
         x_retcode      OUT NOCOPY   NUMBER,
         p_commit       IN    VARCHAR2 := Fnd_Api.G_TRUE,
         p_object_list  IN object_currency_table := Empty_object_currency_table,
         p_current_date IN date,
         p_func_currency IN varchar2
);

PROCEDURE Update_formulas(
         x_errbuf       OUT NOCOPY   VARCHAR2,
         x_retcode      OUT NOCOPY   NUMBER,
         p_commit       IN VARCHAR2 := Fnd_Api.G_TRUE,
         p_object_list  IN object_currency_table := Empty_object_currency_table,
         p_current_date IN date,
         p_func_currency IN varchar2
);

PROCEDURE Clear_Cache;

FUNCTION get_object_details(p_object_type varchar2, p_object_id number)
return object_detail_type;

procedure get_parent_object(p_obj_type varchar2, p_obj_id number,
     x_parent_obj_type out nocopy varchar2, x_parent_obj_id out nocopy number,
     x_show_flag out nocopy varchar2);

-- End forward declaration

-- For Debugging only.
-- NAME
--    Show_Table
--
-- PURPOSE
--      Display the contents of the activity metric rollup table and the
--      metric definition table.
--
-- NOTES
--
-- HISTORY
-- 03/26/2001   huili      Created.
--
PROCEDURE Show_Table (
  p_dirty_table IN act_met_ref_rec_set_type --,
--  p_metric_info IN met_info_set_type
)
IS
  l_index NUMBER;
  BEGIN
  write_msg('Show_Table','The content OF the dirty act_met TABLE IS:');
  l_index := p_dirty_table.FIRST;
  LOOP
      EXIT WHEN l_index IS NULL;
      write_msg('Show_Table',
         'Act_Met_id:' || l_index
         --|| ' COUNT:' || p_dirty_table(l_index).COUNT
         || ' parent_id:' || p_dirty_table(l_index).parent_id
         || ' dirty_flag:' || p_dirty_table(l_index).dirty_flag
         || ' metric_id:' || p_dirty_table(l_index).metric_id
         --|| ' obj_ver_num:' || p_dirty_table(l_index).object_version_number
         --|| ' met_uom_code:' || p_dirty_table(l_index).metric_uom_code
         || ' f_for_value:' || p_dirty_table(l_index).func_forecast_value);
      write_msg('Show_Table',
         ' f_act_value:' || p_dirty_table(l_index).func_actual_value
         --|| ' func_curr_code:' || p_dirty_table(l_index).func_currency_code

         --|| ' l_cal_date:' || p_dirty_table(l_index).last_calculated_date
         --|| ' day_lst_fresh:' ||p_dirty_table(l_index).days_since_last_refresh
         --|| ' diff:' || p_dirty_table(l_index).diff_since_last_calc
         --|| ' o_act_val:' || p_dirty_table(l_index).orig_actual_value
         || ' o_for_val:' || p_dirty_table(l_index).orig_forecast_value

         || ' comp_us_func_value:'
              || p_dirty_table(l_index).computed_using_function_value);
      write_msg('Show_Table',
         ' act_met_or_id:' || p_dirty_table(l_index).activity_metric_origin_id
         --|| ' var_val:' || p_dirty_table(l_index).variable_value
         --|| ' tr_cur_code:' || p_dirty_table(l_index).trans_currency_code
         --|| ' tr_act_val:' || p_dirty_table(l_index).trans_actual_value
         --|| ' tr_for_val:' || p_dirty_table(l_index).trans_forecast_value
         );
      l_index := p_dirty_table.NEXT(l_index);
  END LOOP;
  write_msg('Show_Table','Finish the act metric!');
/**
  write_msg('Show_Table','The content OF the metrics info TABLE IS:');
  l_index := p_metric_info.FIRST;
  LOOP
      EXIT WHEN l_index IS NULL;
      write_msg('Show_Table','Metric_id:' || l_index || ' value_type:'
        || p_metric_info(l_index).value_type
        || ' met_cal_type:' || p_metric_info(l_index).metric_calculation_type
        || ' ac_type:' || p_metric_info(l_index).accrual_type

        || ' comp_func:' || p_metric_info(l_index).compute_using_function

        || ' def_uom_code:' || p_metric_info(l_index).default_uom_code);


    l_index := p_metric_info.NEXT(l_index);
  END LOOP;
  write_msg('Show_Table','Finish the metric');
**/
END Show_Table;

PROCEDURE Clear_Cache
is
begin
--G_OBJECT_CACHE.delete;
null;
/**
   G_RCAM_Parents_table.delete;
   G_CSCH_Parents_table.delete;
   G_EVEO_Parents_table.delete;
   G_EVEH_Parents_table.delete;
   G_EONE_Parents_table.delete;

   G_FORECASTED_STACK.delete;
   G_ACTUAL_STACK.delete;

   G_CAMP_status_table.delete;
   G_CSCH_status_table.delete;
   G_EVEO_status_table.delete;
   G_EVEH_status_table.delete;
**/
end clear_cache;

-- NAME
--     Build_Refresh_Act_Metrics
--
-- PURPOSE
--     The procedure does the following:
--     1. Select all the activity metrics with the dirty flag set;
--     2. For each activity metric in the above set, traverse the heirarchy
--        all the way up until the root node. Add each visited node to the table
--        and record the times this node gets visited;
--     3. Also record the parent node for each node to prevent database hit
--        every time.
--
-- NOTES
--
-- HISTORY
-- 03/26/2001   huili      Created.
--
PROCEDURE  Build_Refresh_Act_Metrics (

  x_dirty_act_metric_table IN OUT NOCOPY  act_met_ref_rec_set_type,
  x_max_count              IN OUT NOCOPY  NUMBER,
  p_calc_type              IN VARCHAR2,

  x_return_status          IN OUT NOCOPY  VARCHAR2,
  p_object_list            IN object_currency_table := Empty_object_currency_table
)
IS
  --
  -- Standard API information constants.
  --
  L_API_VERSION   CONSTANT NUMBER := 1.0;
  L_API_NAME      CONSTANT VARCHAR2(30) := 'BUILD_REFRESH_ACT_METRICS';
  L_FULL_NAME      CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

  l_dirty_act_metric_id NUMBER;
  l_table_ite NUMBER;

  --l_temp_act_metric_table act_met_ref_rec_set_type;
  l_temp_act_metric_record act_met_ref_rec_type;

  --select all activity metrics with dirty bit set
  -- 06/22/2001 huili changed
  CURSOR c_all_dirty_act_metrics(l_calc_type VARCHAR2)
     return act_met_ref_rec_type IS
     SELECT --/*+ first_rows */
            activity_metric_id, a.metric_id, a.object_version_number,
            metric_uom_code, func_forecasted_value, func_actual_value,
            functional_currency_code, summarize_to_metric, rollup_to_metric,
            last_calculated_date, days_since_last_refresh,
            difference_since_last_calc, computed_using_function_value,
            activity_metric_origin_id,
            --variable_value, forecasted_variable_value,
            transaction_currency_code,
            G_LEAF_LEVEL, DECODE(l_calc_type,G_ROLLUP,rollup_to_metric,summarize_to_metric),
            --NULL,
            dirty_flag,
            func_actual_value orig_actual_value,
            func_forecasted_value orig_forecasted_value,
            trans_actual_value, trans_forecasted_value, depend_act_metric,
            arc_act_metric_used_by, act_metric_used_by_id,
           value_type ,
           metric_calculation_type ,
           accrual_type ,
           compute_using_function ,
           default_uom_code, display_type
     FROM ams_act_metrics_all a, ams_metrics_all_b b
     WHERE arc_act_metric_used_by IN
         (select lookup_code from ams_lookups
          where lookup_type in ('AMS_METRIC_OBJECT_TYPE', 'AMS_METRIC_ROLLUP_TYPE'))
         -- Replaced with metadata lookups above.
         --(G_CAMP, G_CSCH, G_DELV, G_EVEO, G_EVEH, G_RCAM, G_EONE)
         --BUG2845365: Removed dialogue components.
         --G_DILG, G_AMS_COMP_START, G_AMS_COMP_SHOW_WEB_PAGE, G_AMS_COMP_END)
     AND dirty_flag = G_IS_DIRTY
     AND a.metric_id = b.metric_id
     AND b.metric_calculation_type = l_calc_type;

  CURSOR c_dirty_act_metrics_by_obj(l_calc_type VARCHAR2,
         l_object_type varchar2, l_object_id number)
     return act_met_ref_rec_type IS
     SELECT
            activity_metric_id, a.metric_id, a.object_version_number,
            metric_uom_code, func_forecasted_value, func_actual_value,
            functional_currency_code, summarize_to_metric, rollup_to_metric,
            last_calculated_date, days_since_last_refresh,
            difference_since_last_calc, computed_using_function_value,
            activity_metric_origin_id,
            -- variable_value, forecasted_variable_value,
            transaction_currency_code,
            G_LEAF_LEVEL, DECODE(l_calc_type,G_ROLLUP,rollup_to_metric,summarize_to_metric),
            --NULL,
            dirty_flag,
            func_actual_value orig_actual_value,
            func_forecasted_value orig_forecasted_value,
            trans_actual_value, trans_forecasted_value, depend_act_metric,
            arc_act_metric_used_by, act_metric_used_by_id,
           value_type ,
           metric_calculation_type ,
           accrual_type ,
           compute_using_function ,
           default_uom_code, display_type
     FROM ams_act_metrics_all a, ams_metrics_all_b b
     WHERE dirty_flag = G_IS_DIRTY
     AND a.metric_id = b.metric_id
     AND b.metric_calculation_type = l_calc_type
     AND a.arc_act_metric_used_by = l_object_type
     AND a.act_metric_used_by_id = l_object_id;

  l_act_metric_id NUMBER;
  l_metric_id NUMBER;
  l_traversed_table act_metric_ids_type;
  l_trav_table_count NUMBER := 0;
  l_count NUMBER := 0;
  l_obj_index NUMBER := 0;

  l_parent_id NUMBER;

  --select one parent activity metrics
  CURSOR c_act_metric (l_parent_act_metric_id NUMBER)
     return act_met_ref_rec_type IS
    SELECT  activity_metric_id, a.metric_id, a.object_version_number,
            metric_uom_code, func_forecasted_value, func_actual_value,
            functional_currency_code, summarize_to_metric, rollup_to_metric,
            last_calculated_date, days_since_last_refresh,
            difference_since_last_calc, computed_using_function_value,
            activity_metric_origin_id,
            -- variable_value, forecasted_variable_value,
            transaction_currency_code,
            G_LEAF_LEVEL, DECODE(metric_calculation_type,G_ROLLUP,rollup_to_metric,summarize_to_metric),
            --NULL,
            dirty_flag,
            func_actual_value orig_actual_value,
            func_forecasted_value orig_forecasted_value,
            trans_actual_value, trans_forecasted_value, depend_act_metric,
            arc_act_metric_used_by, act_metric_used_by_id,
           value_type ,
           metric_calculation_type ,
           accrual_type ,
           compute_using_function ,
           default_uom_code, display_type
    FROM ams_act_metrics_all a, ams_metrics_all_b b
    WHERE activity_metric_id = l_parent_act_metric_id
    AND a.metric_id = b.metric_id;

  l_act_metric_rec act_met_ref_rec_type;--c_act_metric_rec%ROWTYPE;
--  l_parent_type CHAR(1);
  l_used_actmet_ids act_metric_ids_type;
  l_depth NUMBER := 0;
/*****
  l_activity_metric_ids num_table_type;
  l_metric_ids num_table_type;
  l_object_version_numbers num_table_type;
  l_metric_uom_codes varchar2_table_type;
  l_func_forecast_values num_table_type;
  l_func_actual_values num_table_type;
  l_func_currency_codes varchar2_table_type;
  l_summarize_to_metrics num_table_type;
  l_rollup_to_metrics num_table_type;
  l_last_calculated_dates date_table_type;
  l_days_since_last_refreshs num_table_type;
  l_diff_since_last_calcs num_table_type;
  l_computed_using_func_values num_table_type;
  l_activity_metric_origin_ids num_table_type;
  -- l_variable_values num_table_type;
  -- l_forecasted_variable_values num_table_type;
  l_trans_currency_codes varchar2_table_type;

  l_COUNTs num_table_type;
  l_parent_ids num_table_type;
--  l_parent_types char1_table_type;
  l_dirty_flags char1_table_type;
  l_orig_actual_values num_table_type;
  l_orig_forecast_values num_table_type;
  l_trans_actual_values num_table_type;
  l_trans_forecast_values num_table_type;
  l_depend_act_metrics num_table_type;
  l_arc_act_metric_used_bys varchar2_table_type;
  l_act_metric_used_by_ids num_table_type;

  l_value_types varchar2_table_type;
  l_metric_calculation_types varchar2_table_type;
  l_accrual_types varchar2_table_type;
  l_compute_using_functions varchar2_table_type;
  l_default_uom_codes varchar2_table_type;
  l_display_types varchar2_table_type;
  ***/
BEGIN

   IF AMS_DEBUG_HIGH_ON THEN
     write_msg(L_API_NAME,'START: '||p_calc_type);
   END IF;
  --
  --Phase 1, we build the table based on all dirty records
  --
  l_obj_index := 0;
  LOOP
     IF p_object_list.count > l_obj_index THEN
        l_obj_index := l_obj_index + 1;
        OPEN c_dirty_act_metrics_by_obj(p_calc_type,
             p_object_list(l_obj_index).obj_type,p_object_list(l_obj_index).obj_id);
        --FETCH c_dirty_act_metrics_by_obj BULK COLLECT INTO
        --   l_temp_act_metric_table;
        LOOP
           FETCH c_dirty_act_metrics_by_obj into l_temp_act_metric_record;
           exit when c_dirty_act_metrics_by_obj%NOTFOUND;
           l_act_metric_id := l_temp_act_metric_record.activity_metric_id;
           x_dirty_act_metric_table(l_act_metric_id) := l_temp_act_metric_record;
           l_trav_table_count := l_traversed_table.COUNT+1;
           l_traversed_table (l_trav_table_count) := l_act_metric_id;
        END LOOP;
           /**
           l_activity_metric_ids,
           l_metric_ids,
           l_object_version_numbers ,
           l_metric_uom_codes ,
           l_func_forecast_values ,
           l_func_actual_values ,
           l_func_currency_codes ,
           l_summarize_to_metrics ,
           l_rollup_to_metrics ,
           l_last_calculated_dates ,
           l_days_since_last_refreshs ,
           l_diff_since_last_calcs ,
           l_computed_using_func_values ,
           l_activity_metric_origin_ids ,
           -- l_variable_values ,
           -- l_forecast_variable_values,
           l_trans_currency_codes ,

           l_COUNTs ,
           l_parent_ids ,
--           l_parent_types ,
           l_dirty_flags ,
           l_orig_actual_values ,
           l_orig_forecast_values ,
           l_trans_actual_values ,
           l_trans_forecast_values ,
           l_depend_act_metrics ,
           l_arc_act_metric_used_bys ,
           l_act_metric_used_by_ids ,

           l_value_types ,
           l_metric_calculation_types ,
           l_accrual_types ,
           l_compute_using_functions ,
           l_default_uom_codes,
           l_display_types ;
     **/
        CLOSE c_dirty_act_metrics_by_obj;
     ELSIF p_object_list.count = 0 THEN
        OPEN c_all_dirty_act_metrics(p_calc_type);
        --fetch c_all_dirty_act_metrics bulk collect into
        --   l_temp_act_metric_table;
        LOOP
           FETCH c_all_dirty_act_metrics into l_temp_act_metric_record;
           exit when c_all_dirty_act_metrics%NOTFOUND;
           l_act_metric_id := l_temp_act_metric_record.activity_metric_id;
           x_dirty_act_metric_table(l_act_metric_id) := l_temp_act_metric_record;
           l_trav_table_count := l_traversed_table.COUNT+1;
           l_traversed_table (l_trav_table_count) := l_act_metric_id;
        END LOOP;
    /**
        FETCH c_all_dirty_act_metrics BULK COLLECT INTO
           l_activity_metric_ids,
           l_metric_ids,
           l_object_version_numbers ,
           l_metric_uom_codes ,
           l_func_forecast_values ,
           l_func_actual_values ,
           l_func_currency_codes ,
           l_summarize_to_metrics ,
           l_rollup_to_metrics ,
           l_last_calculated_dates ,
           l_days_since_last_refreshs ,
           l_diff_since_last_calcs ,
           l_computed_using_func_values ,
           l_activity_metric_origin_ids ,
           -- l_variable_values ,
           -- l_forecast_variable_values,
           l_trans_currency_codes ,

           l_COUNTs ,
           l_parent_ids ,
--           l_parent_types ,
           l_dirty_flags ,
           l_orig_actual_values ,
           l_orig_forecast_values ,
           l_trans_actual_values ,
           l_trans_forecast_values ,
           l_depend_act_metrics ,
           l_arc_act_metric_used_bys ,
           l_act_metric_used_by_ids ,

           l_value_types ,
           l_metric_calculation_types ,
           l_accrual_types ,
           l_compute_using_functions ,
           l_default_uom_codes,
           l_display_types ;
    ****/
        CLOSE c_all_dirty_act_metrics;
     END IF;
/***
     IF l_activity_metric_ids.count > 0 THEN
        FOR l_amet_index IN l_activity_metric_ids.first..l_activity_metric_ids.last
****/
/***
     IF l_temp_act_metric_table.count > 0 then
        FOR l_amet_index in l_temp_act_metric_table.first..l_temp_act_metric_table.last
        LOOP

        l_act_metric_id := l_temp_act_metric_table(l_amet_index).activity_metric_id;
        x_dirty_act_metric_table(l_act_metric_id) := l_temp_act_metric_table(l_amet_index);
***/
/**
        l_act_metric_id := l_activity_metric_ids(l_amet_index);

        x_dirty_act_metric_table(l_act_metric_id).activity_metric_id := l_act_metric_id;
        x_dirty_act_metric_table(l_act_metric_id).metric_id := l_metric_ids  (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).object_version_number := l_object_version_numbers (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).metric_uom_code := l_metric_uom_codes (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).func_forecast_value := l_func_forecast_values (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).func_actual_value := l_func_actual_values (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).func_currency_code := l_func_currency_codes (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).summarize_to_metric := l_summarize_to_metrics (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).rollup_to_metric := l_rollup_to_metrics (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).last_calculated_date := l_last_calculated_dates (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).days_since_last_refresh := l_days_since_last_refreshs (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).diff_since_last_calc := l_diff_since_last_calcs (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).computed_using_function_value := l_computed_using_func_values (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).activity_metric_origin_id := l_activity_metric_origin_ids (l_amet_index);
        -- x_dirty_act_metric_table(l_act_metric_id).variable_value := l_variable_values (l_amet_index);
        -- x_dirty_act_metric_table(l_act_metric_id).forecasted_variable_value := l_forecasted_variable_values (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).trans_currency_code := l_trans_currency_codes (l_amet_index);

        x_dirty_act_metric_table(l_act_metric_id).COUNT := l_COUNTs (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).parent_id := l_parent_ids (l_amet_index);
--        x_dirty_act_metric_table(l_act_metric_id).parent_type := l_parent_types (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).dirty_flag := l_dirty_flags (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).orig_actual_value := l_orig_actual_values (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).orig_forecast_value := l_orig_forecast_values (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).trans_actual_value := l_trans_actual_values (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).trans_forecast_value := l_trans_forecast_values (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).depend_act_metric := l_depend_act_metrics (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).arc_act_metric_used_by := l_arc_act_metric_used_bys (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).act_metric_used_by_id := l_act_metric_used_by_ids (l_amet_index);

        x_dirty_act_metric_table(l_act_metric_id).value_type := l_value_types (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).metric_calculation_type := l_metric_calculation_types (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).accrual_type := l_accrual_types (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).compute_using_function := l_compute_using_functions (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).default_uom_code := l_default_uom_codes (l_amet_index);
        x_dirty_act_metric_table(l_act_metric_id).display_type := l_display_types (l_amet_index);
****/
/***
        l_trav_table_count := l_traversed_table.COUNT+1;
        l_traversed_table (l_trav_table_count) := l_act_metric_id;
        END LOOP;
     END IF;
***/
     EXIT WHEN p_object_list.count <= l_obj_index;
  END LOOP;

  --
  --Phase 2, we go through each record in the above table, traverse the
  --whole tree starting from that node and calculate the count number properly.
  --
  x_max_count := G_LEAF_LEVEL;
  l_table_ite := l_traversed_table.FIRST;
  LOOP
     EXIT WHEN l_table_ite IS NULL;
     IF x_dirty_act_metric_table.COUNT > G_MAX_DIRTY_COUNT THEN
       write_msg(l_api_name,'Maximum dirty activity metrics limit reached ('
                ||G_MAX_DIRTY_COUNT||').  Cannot continue.');
       EXIT;
     END IF;
     --
     --We need to traverse this node
     --
     l_parent_id := l_traversed_table(l_table_ite);
     -- Only traverse if this node has not previously been traversed.
     IF x_dirty_act_metric_table(l_parent_id).dirty_flag = G_IS_DIRTY THEN
     l_depth := 0;
     LOOP
        l_depth := l_depth +1;
        IF l_depth > 500 THEN
           --write_msg('Too deep FOR me');
           EXIT;
        END IF;
        l_act_metric_id := l_parent_id;
        l_parent_id := x_dirty_act_metric_table (l_act_metric_id).parent_id;
        EXIT WHEN l_parent_id IS NULL;
        -- If this node has been traversed then there are circular links.
        IF l_used_actmet_ids.EXISTS(l_parent_id) THEN
           x_dirty_act_metric_table(l_act_metric_id).parent_id := NULL;
           EXIT;
        ELSE
           l_used_actmet_ids(l_parent_id) := l_parent_id;
        END IF;
        --
        --if parent id is there, need to traverse parent
        --
        --
        -- if parent is in the memory table, need to adjust the traversal count
        -- and set the dirty flag to G_NOT_DIRTY
        --
        IF x_dirty_act_metric_table.EXISTS(l_parent_id) THEN
           -- If the parent's count is greater than it has been traversed,
           -- and its count is correct.  No need to continue up the hierarchy.
           EXIT WHEN x_dirty_act_metric_table(l_act_metric_id).COUNT <
                     x_dirty_act_metric_table(l_parent_id).COUNT;
           -- The parent must be calculated after all the children.
           -- The parent count must be at one greater than the maximum
           -- of all the children to be calculated in the correct order.
           x_dirty_act_metric_table(l_parent_id).COUNT
              := x_dirty_act_metric_table(l_act_metric_id).COUNT + 1;
           -- Set max_count to determine the iterations through the dirty list
           -- to complete all calculations.
           IF x_max_count < x_dirty_act_metric_table(l_parent_id).COUNT THEN
              x_max_count := x_dirty_act_metric_table(l_parent_id).COUNT;
           END IF;
           -- Only leaf nodes are flagged as dirty to identify the starting
           -- point of the calculations.
           x_dirty_act_metric_table(l_parent_id).dirty_flag := G_NOT_DIRTY;

           --
           --otherwise, need to grab one from DB
           --
        ELSE
           OPEN c_act_metric (l_parent_id);
           FETCH c_act_metric INTO l_act_metric_rec;
           IF c_act_metric%FOUND THEN
              x_dirty_act_metric_table(l_parent_id) := l_act_metric_rec;
              x_dirty_act_metric_table(l_parent_id).COUNT
                 := x_dirty_act_metric_table(l_act_metric_id).COUNT + 1;
              x_dirty_act_metric_table(l_parent_id).dirty_flag := G_NOT_DIRTY;
              -- BUG3121639: Failed to increment counter correctly.
              -- Set max_count to determine the iterations through the dirty
              -- list to complete all calculations.
              IF x_max_count < x_dirty_act_metric_table(l_parent_id).COUNT THEN
                 x_max_count := x_dirty_act_metric_table(l_parent_id).COUNT;
              END IF;
           ELSE
              -- Database incosistancy.  The parent ID is invalid.
              -- Reset the parent and stop traversing.
              x_dirty_act_metric_table (l_act_metric_id).parent_id := NULL;
              CLOSE c_act_metric;
              EXIT;
           END IF;
           CLOSE c_act_metric;
        END IF;

--        x_dirty_act_metric_table(l_parent_id).parent_type := l_parent_type;

     END LOOP;
     l_used_actmet_ids.DELETE;
     END IF; -- x_dirty_act_metric_table(l_parent_id).dirty_flag = G_DIRTY
     l_table_ite := l_traversed_table.NEXT (l_table_ite);
  END LOOP;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME,'END: '||p_calc_type||': COUNT='||x_dirty_act_metric_table.COUNT);
   END IF;
END Build_Refresh_Act_Metrics;

-- NAME
--    Calculate_This_Metric
--
-- PURPOSE
--
--
-- ALGORITHM
--      With the list of all dirty metrics iterate through to find all the
--      nodes at the current level and a dirty flag set.  Once no dirty
--      flags are found at this level, increment to the next level and
--      repeat.  End when all levels have expired.
--
-- NOTES
--
-- HISTORY
--      03/26/2001 dmvincen   Created
--      08/17/2001 dmvincen   Added check for currency consistancy.
--      08/17/2001 dmvincen   Added check for canceled business objects.
--      08/27/2001 huili      Added bulk collection to find all summary and  rollup children.
--
PROCEDURE Calculate_This_Metric(
   x_dirty_actmets IN OUT NOCOPY act_met_ref_rec_set_type,
   p_max_level IN NUMBER,
   p_calc_type IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   p_default_currency IN VARCHAR2
)
IS
   TYPE t_actmet_id IS TABLE OF ams_act_metrics_all.activity_metric_id%TYPE;
   TYPE t_value IS TABLE OF ams_act_metrics_all.FUNC_ACTUAL_VALUE%TYPE;
   TYPE t_curr IS TABLE OF ams_act_metrics_all.FUNCTIONAL_CURRENCY_CODE%TYPE;
   TYPE t_uom IS TABLE OF ams_act_metrics_all.METRIC_UOM_CODE%TYPE;
   TYPE t_objtype IS TABLE OF ams_act_metrics_all.ARC_ACT_METRIC_USED_BY%TYPE;
   TYPE t_objid IS TABLE OF ams_act_metrics_all.ACT_METRIC_USED_BY_ID%TYPE;

   l_activity_metric_ids t_actmet_id;
   l_func_forecasted_values t_value;
   l_func_actual_values t_value;
   l_functional_currency_codes t_curr;
   l_metric_uom_codes t_uom;
   l_arc_act_metric_used_bys t_objtype;
   l_act_metric_used_by_ids t_objid;

   CURSOR c_check_assoc_metric(l_metric_id NUMBER) IS
      SELECT COUNT(1)
      FROM ams_metric_accruals
      WHERE metric_id = l_metric_id;

   l_flag NUMBER;

   l_comp_actual_value NUMBER := 0;
   l_trans_actual_value NUMBER := 0;
   l_func_actual_value NUMBER := 0;
   l_func_forecast_value NUMBER := 0;
   l_final_actual_value NUMBER := 0;
   l_final_forecast_value NUMBER := 0;
   l_conv_uom_actual_value NUMBER := 0;
   l_conv_uom_forecast_value NUMBER := 0;
   l_parent_id NUMBER;
   l_child_count NUMBER := 0;
   l_current_date DATE := SYSDATE;
   l_metric_id NUMBER;
   l_id NUMBER;
   l_id_outside NUMBER;
   l_level NUMBER := G_LEAF_LEVEL-1;
   l_return_status VARCHAR2(1);
   l_arc_act_metric_used_by VARCHAR2(30);
   l_act_metric_used_by_id NUMBER;
   l_is_canceled VARCHAR2(1);
   l_func_currency_code VARCHAR2(15);
   l_child_id NUMBER;
   l_metric_uom_code VARCHAR2(3);
   l_default_uom_code VARCHAR2(3);
   l_metric_calc_type VARCHAR2(30);
   l_hits NUMBER := 0;
   l_tests NUMBER := 0;
/**
   l_CAMP_status_table dirty_flag_table_type;
   l_CSCH_status_table dirty_flag_table_type;
   l_EVEO_status_table dirty_flag_table_type;
   l_EVEH_status_table dirty_flag_table_type;
**/
   l_act_metric_id_levels num_table_type;

BEGIN

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg('Calculate_This_Metric', 'START: '||p_calc_type
        ||', max_level='||p_max_level
        ||', dirty_count='||x_dirty_actmets.count);
   END IF;

   -- Load first level and dirty metrics to short list.
   l_id := x_dirty_actmets.FIRST;
   LOOP
       exit when l_id is null;
       if x_dirty_actmets(l_id).COUNT = 0 AND
          x_dirty_actmets(l_id).dirty_flag = 'Y' then
          l_act_metric_id_levels(l_id) := 0;
       end if;
       l_id := x_dirty_actmets.next(l_id);
   END LOOP;

   LOOP

      IF l_id_outside IS NULL THEN                -- At the end of the list.
         l_level := l_level + 1;
         EXIT WHEN l_level > p_max_level;         -- All levels have expired.
         --l_id_outside := x_dirty_actmets.FIRST;   -- Reset the index.
         l_id_outside := l_act_metric_id_levels.FIRST;
         EXIT WHEN l_id_outside IS NULL;
      END IF;

      l_tests := l_tests + 1;
      -- Find an actmet that is dirty at the current level.
      IF x_dirty_actmets(l_id_outside).dirty_flag = G_IS_DIRTY AND
         x_dirty_actmets(l_id_outside).COUNT = l_level
      THEN
         l_hits := l_hits + 1;
         l_act_metric_id_levels.DELETE(l_id_outside);

         l_id := l_id_outside;
         LOOP
            EXIT WHEN l_id IS NULL;

               l_metric_calc_type := x_dirty_actmets(l_id).metric_calculation_type;
              -- Branch nodes must accumulate from all immediate children.
              IF l_metric_calc_type IN (G_SUMMARY, G_ROLLUP) THEN
                 -- Is apportioned metric.
                 IF x_dirty_actmets(l_id).activity_metric_origin_id IS NOT NULL
                 THEN
                    l_child_count := 0;

                    OPEN c_check_assoc_metric(l_metric_id);
                    FETCH c_check_assoc_metric INTO l_flag;
                    CLOSE c_check_assoc_metric;
                    IF l_flag > 0 THEN
                       l_func_actual_value :=
                              x_dirty_actmets(l_id).orig_actual_value;
                       l_func_forecast_value :=
                              x_dirty_actmets(l_id).orig_forecast_value;
                    ELSE
                       Get_Met_Apport_Val(
                           p_obj_association_id =>
                              x_dirty_actmets(l_id).activity_metric_origin_id,
                           x_return_status => x_return_status,
                           x_apportioned_value => l_func_actual_value);
                       IF x_dirty_actmets(l_id).default_uom_code IS NOT NULL
                          AND
                          x_dirty_actmets(l_id).metric_uom_code IS NOT NULL THEN
                          l_final_actual_value :=
                             -- Changed to using local definition.
                             --Ams_Refreshmetric_Pvt.CONVERT_UOM(
                             Convert_UOM(
                              p_from_uom_code =>
                                 x_dirty_actmets(l_id).metric_uom_code,
                              p_to_uom_code=>
                                 x_dirty_actmets(l_id).default_uom_code,
                              p_from_quantity => l_func_actual_value);
                           IF l_final_actual_value < 0 THEN
                              l_final_actual_value := 0;
                              RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
                           END IF;
                        ELSE
                           l_final_actual_value := l_func_actual_value;
                        END IF;
                     END IF;
                  ELSE -- metric_origin_id is null
                     -- Scan all the child nodes and accumulate.

                     l_final_actual_value := 0;
                     l_final_forecast_value := 0;
                     l_child_count := 0;

                     IF p_calc_type = G_SUMMARY THEN
                        SELECT activity_metric_id,
                               func_forecasted_value,
                               func_actual_value,
                               functional_currency_code,
                               metric_uom_code,
                               arc_act_metric_used_by,
                               act_metric_used_by_id
                        BULK COLLECT INTO l_activity_metric_ids,
                               l_func_forecasted_values,
                               l_func_actual_values,
                               l_functional_currency_codes,
                               l_metric_uom_codes,
                               l_arc_act_metric_used_bys,
                               l_act_metric_used_by_ids
                        FROM   ams_act_metrics_all
                        WHERE  summarize_to_metric = l_id;
                        --ORDER BY arc_act_metric_used_by, act_metric_used_by_id;
                     ELSE
                        SELECT activity_metric_id,
                               func_forecasted_value,
                               func_actual_value,
                               functional_currency_code,
                               metric_uom_code,
                               arc_act_metric_used_by,
                               act_metric_used_by_id
                        BULK COLLECT INTO l_activity_metric_ids,
                               l_func_forecasted_values,
                               l_func_actual_values,
                               l_functional_currency_codes,
                               l_metric_uom_codes,
                               l_arc_act_metric_used_bys,
                               l_act_metric_used_by_ids
                        FROM   ams_act_metrics_all
                        WHERE  rollup_to_metric = l_id;
                        --ORDER BY arc_act_metric_used_by, act_metric_used_by_id;
                     END IF;

                   IF l_activity_metric_ids.COUNT > 0 THEN
                      FOR l_amet_index IN  l_activity_metric_ids.FIRST..
                                      l_activity_metric_ids.LAST
                      LOOP
                         l_child_id := l_activity_metric_ids(l_amet_index);

                        IF x_dirty_actmets.EXISTS(l_child_id) THEN
                           -- Child nodes ought never be dirty.
                           IF x_dirty_actmets(l_child_id).dirty_flag = G_IS_DIRTY
                           THEN
                              RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
                           END IF;

                           l_func_actual_value := x_dirty_actmets(l_child_id).
                                    func_actual_value;
                           IF l_func_actual_value IS NOT NULL AND
                              (l_func_actual_value >= G_MAX_VALUE OR
                              l_func_actual_value <= -G_MAX_VALUE) THEN
                              l_func_actual_value := 0;
                              x_dirty_actmets(l_child_id).func_actual_value := 0;
                           END IF;
                           l_func_actual_value := NVL(l_func_actual_value,0);

                           l_func_forecast_value := x_dirty_actmets(l_child_id).
                                         func_forecast_value;
                           IF l_func_forecast_value IS NOT NULL AND
                              (l_func_forecast_value >= G_MAX_VALUE OR
                              l_func_forecast_value <= -G_MAX_VALUE) THEN
                              l_func_forecast_value := 0;
                              x_dirty_actmets(l_child_id).func_forecast_value := 0;
                           END IF;
                           l_func_forecast_value := NVL(l_func_forecast_value,0);

                           -- BUG3484528: Drive currency by display type.
                           -- l_func_currency_code :=
                           --    x_dirty_actmets(l_child_id).func_currency_code;
                           IF x_dirty_actmets(l_id).display_type =
                               G_CURRENCY THEN
                              l_func_currency_code :=
                                 NVL(x_dirty_actmets(l_child_id).
                                     func_currency_code, p_default_currency);
                           ELSE
                              l_func_currency_code := NULL;
                           END IF;
                           -- BUG3484528: END

                        ELSE -- If not in dirty table use database values.

                           l_func_actual_value :=
                              NVL(l_func_actual_values(l_amet_index), 0);

                           IF l_func_actual_value >= G_MAX_VALUE OR
                              l_func_actual_value <= -G_MAX_VALUE THEN
                              l_func_actual_value := 0;
                           END IF;

                           l_func_forecast_value :=
                              NVL(l_func_forecasted_values(l_amet_index),0);

                           IF l_func_forecast_value >= G_MAX_VALUE OR
                              l_func_forecast_value <= -G_MAX_VALUE THEN
                              l_func_forecast_value := 0;
                           END IF;

                           -- BUG3484528: Drive currency by display type.
                           -- l_func_currency_code :=
                           --    l_functional_currency_codes(l_amet_index);
                           IF x_dirty_actmets(l_id).display_type =
                               G_CURRENCY THEN
                              l_func_currency_code :=
                                NVL(l_functional_currency_codes(l_amet_index),
                                    p_default_currency);
                           ELSE
                              l_func_currency_code := NULL;
                           END IF;
                           -- BUG3484528: END

                        END IF;
                        -- Skip canceled business object with no actual values.
                        IF p_calc_type = G_ROLLUP AND
                           -- l_func_actual_value <> 0 AND
                           -- IF the object has not been looked up yet.
                           (l_arc_act_metric_used_by IS NULL OR
                           (l_arc_act_metric_used_by <>
                              l_arc_act_metric_used_bys (l_amet_index) OR
                           l_act_metric_used_by_id <>
                              l_act_metric_used_by_ids (l_amet_index) ))
                        THEN
                           l_arc_act_metric_used_by :=
                              l_arc_act_metric_used_bys (l_amet_index);
                           l_act_metric_used_by_id :=
                              l_act_metric_used_by_ids (l_amet_index);
/**
                           if l_arc_act_metric_used_by in (G_CAMP,G_RCAM) and
                              l_CAMP_status_table.exists(l_act_metric_used_by_id) then
                              l_is_canceled := l_CAMP_status_table(l_act_metric_used_by_id);
                           elsif l_arc_act_metric_used_by = G_CSCH and
                              l_CSCH_status_table.exists(l_act_metric_used_by_id) then
                              l_is_canceled := l_CSCH_status_table(l_act_metric_used_by_id);
                           elsif l_arc_act_metric_used_by = G_EVEH and
                              l_EVEH_status_table.exists(l_act_metric_used_by_id) then
                              l_is_canceled := l_EVEH_status_table(l_act_metric_used_by_id);
                           elsif l_arc_act_metric_used_by in (G_EVEO,G_EONE) and
                              l_EVEO_status_table.exists(l_act_metric_used_by_id) then
                              l_is_canceled := l_EVEO_status_table(l_act_metric_used_by_id);
                           else
**/
                              l_is_canceled := Fnd_Api.G_FALSE;
                              -- Changed to use local definition.
                              --Ams_Refreshmetric_Pvt.CHECK_OBJECT_STATUS(
                              Check_Object_Status(
                                 p_arc_act_metric_used_by => l_arc_act_metric_used_by,
                                 p_act_metric_used_by_id => l_act_metric_used_by_id,
                                 x_is_canceled => l_is_canceled
                              );
/**
                              if l_arc_act_metric_used_by in (G_CAMP,G_RCAM) then
                                 l_CAMP_status_table(l_act_metric_used_by_id) := l_is_canceled;
                              elsif l_arc_act_metric_used_by = G_CSCH then
                                 l_CSCH_status_table(l_act_metric_used_by_id) := l_is_canceled;
                              elsif l_arc_act_metric_used_by = G_EVEH then
                                 l_EVEH_status_table(l_act_metric_used_by_id) := l_is_canceled;
                              elsif l_arc_act_metric_used_by in (G_EVEO,G_EONE) then
                                 l_EVEO_status_table(l_act_metric_used_by_id) := l_is_canceled;
                              end if;
                           end if;
**/
                        END IF;

                        IF p_calc_type = G_SUMMARY OR
                           l_is_canceled = Fnd_Api.G_FALSE OR
                           l_func_actual_value <> 0
                        THEN
                           -- Validate that the currencies are the same.
                           -- BUG3484528: Drive by display type.
                           IF x_dirty_actmets(l_id).display_type = G_CURRENCY
                              AND l_func_currency_code <> p_default_currency
                           THEN
                           -- IF l_func_currency_code IS NOT NULL AND
                           --    l_func_currency_code <> p_default_currency THEN
                              Ams_Actmetric_Pvt.CONVERT_CURRENCY2(
                                   x_return_status => l_return_status,
                                   p_from_currency => l_func_currency_code,
                                   p_to_currency   => p_default_currency,
                                   p_conv_date     => l_current_date,
                                   p_from_amount   => l_func_actual_value,
                                   x_to_amount     => l_func_actual_value,
                                   p_from_amount2  => l_func_forecast_value,
                                   x_to_amount2    => l_func_forecast_value,
                                   p_round         => Fnd_Api.G_FALSE
                              );
                           END IF;
                           l_child_count := l_child_count + 1;
                           l_final_actual_value := l_final_actual_value +
                                                    l_func_actual_value;
                           l_final_forecast_value := l_final_forecast_value +
                                                    l_func_forecast_value;
                        END IF;
                     END LOOP;
                  END IF;

                  l_activity_metric_ids.DELETE;
                  l_func_forecasted_values.DELETE;
                  l_func_actual_values.DELETE;
                  l_functional_currency_codes.DELETE;
                  l_metric_uom_codes.DELETE;
                  l_arc_act_metric_used_bys.DELETE;
                  l_act_metric_used_by_ids.DELETE;

                  IF x_dirty_actmets(l_id).value_type = G_RATIO  AND
                     l_child_count > 0 THEN
                     l_final_actual_value := l_final_actual_value / l_child_count;
                     l_final_forecast_value := l_final_forecast_value / l_child_count;
                  END IF;

               END IF;
            END IF;  -- MANUAL

            l_metric_uom_code := x_dirty_actmets(l_id).metric_uom_code;
            l_default_uom_code := x_dirty_actmets(l_id).default_uom_code;
            IF l_default_uom_code IS NOT NULL AND
               l_metric_uom_code IS NOT NULL THEN
               l_conv_uom_actual_value := /*Ams_Refreshmetric_Pvt.*/CONVERT_UOM(
                  p_from_uom_code => l_default_uom_code,
                  p_to_uom_code => l_metric_uom_code,
                  p_from_quantity => l_final_actual_value);
               l_conv_uom_forecast_value := /*Ams_Refreshmetric_Pvt.*/CONVERT_UOM(
                  p_from_uom_code => l_default_uom_code,
                  p_to_uom_code => l_metric_uom_code,
                  p_from_quantity => l_final_forecast_value);
               IF l_conv_uom_actual_value < 0 OR
                  l_conv_uom_forecast_value < 0 THEN
                  RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
               END IF;
            ELSE
               l_conv_uom_actual_value := l_final_actual_value;
               l_conv_uom_forecast_value := l_final_forecast_value;
            END IF;

            -- Update all relevent fields with new values.
            x_dirty_actmets(l_id).func_actual_value := l_conv_uom_actual_value;
            x_dirty_actmets(l_id).func_forecast_value :=
                     l_conv_uom_forecast_value;
--            IF x_dirty_actmets(l_id).func_currency_code IS NOT NULL THEN
            IF x_dirty_actmets(l_id).display_type = G_CURRENCY THEN
               x_dirty_actmets(l_id).func_currency_code := p_default_currency;
            END IF;
            x_dirty_actmets(l_id).computed_using_function_value :=
                     l_comp_actual_value;
            x_dirty_actmets(l_id).diff_since_last_calc := l_func_actual_value -
                    NVL(x_dirty_actmets(l_id).func_actual_value,0);
            x_dirty_actmets(l_id).days_since_last_refresh :=
                    l_current_date - x_dirty_actmets(l_id).last_calculated_date;
            x_dirty_actmets(l_id).last_calculated_date := l_current_date;
            x_dirty_actmets(l_id).dirty_flag := G_NOT_DIRTY;

            -- Find the parent activity metric id.
            l_parent_id := x_dirty_actmets(l_id).parent_id;

            IF l_parent_id IS NOT NULL THEN
               -- Check if the parent is at the same level.
               IF x_dirty_actmets(l_parent_id).COUNT =
                     x_dirty_actmets(l_id).COUNT THEN
                  -- Recurse to calculate the parent node.
                  l_id := l_parent_id;
               ELSE
                  -- If the values have changed and at the next level
                  -- then set the parent to be dirty.
                  x_dirty_actmets(l_parent_id).dirty_flag := G_IS_DIRTY;
                  l_act_metric_id_levels(l_parent_id) := x_dirty_actmets(l_parent_id).COUNT;
                  EXIT; -- outside loop
               END IF;
            ELSE
               EXIT;
            END IF;  -- parent is not null
         END LOOP; -- top

      END IF;

      --l_id_outside := x_dirty_actmets.NEXT(l_id_outside);   -- Try the next one.
      l_id_outside := l_act_metric_id_levels.NEXT(l_id_outside);

   END LOOP;
/**
   l_CAMP_status_table.delete;
   l_CSCH_status_table.delete;
   l_EVEO_status_table.delete;
   l_EVEH_status_table.delete;
**/
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg('Calculate_This_Metric', 'END: '||p_calc_type
         ||', tests='||l_tests
         ||', hits='||l_hits);
   END IF;

END Calculate_This_Metric;

-- NAME
--    Bulk_update
--
-- PURPOSE
--
-- ALGORITHM
--
-- NOTES
--
-- HISTORY
--
PROCEDURE Bulk_update(
   x_dirty_actmet IN OUT NOCOPY act_met_ref_rec_set_type,
   p_calc_type IN VARCHAR2,
   p_commit IN varchar2,
   x_return_status OUT NOCOPY VARCHAR2
)
IS
   L_API_NAME CONSTANT VARCHAR2(100) := 'BULK_UPDATE';
   l_id NUMBER;
   l_act_met_id      num_table_type;
   l_cal_date_table  date_table_type;
   l_sin_last_ref    num_table_type;
   l_func_act_va     num_table_type;
   l_tran_act_va     num_table_type;
   l_func_for_value  num_table_type;
   l_trans_for_value num_table_type;
   l_dirty_flag      dirty_flag_table_type;
   l_diff            num_table_type;
   l_obj_version     num_table_type;
   l_func_curr_code  currency_code_table_type;
   l_trans_curr_code  currency_code_table_type;
   l_summarize_ids   num_table_type;
   l_summarize_count NUMBER := 0;
   l_index NUMBER;
   l_count NUMBER := 0;
   l_obj_currencies object_currency_table;
   l_obj_currency object_currency_type;
   l_trans_currency_code VARCHAR2(15);
   l_act_metric_used_by_id NUMBER;
   l_arc_act_metric_used_by VARCHAR2(30);
   l_today DATE := SYSDATE;
   l_actmet_id number;
   l_default_currency VARCHAR2(15) := null;
BEGIN
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'START: '||p_calc_type||': COUNT='||x_dirty_actmet.COUNT);
   END IF;
   l_default_currency := ams_actmetric_pvt.default_func_currency;
   --
   -- Phase 4, convert all currencies to transactional amount
   --
   l_id := x_dirty_actmet.FIRST;
   LOOP
      EXIT WHEN l_id IS NULL;
      -- Only convert if the currency codes are validate and not equal.
      IF x_dirty_actmet(l_id).display_type = G_CURRENCY THEN
--      IF x_dirty_actmet(l_id).func_currency_code IS NOT NULL AND
--         x_dirty_actmet(l_id).trans_currency_code IS NOT NULL THEN

         -- Verify the transaction currency code matches the object.
         l_act_metric_used_by_id := x_dirty_actmet(l_id).act_metric_used_by_id;
         l_arc_act_metric_used_by := x_dirty_actmet(l_id).arc_act_metric_used_by;
         IF l_obj_currencies.EXISTS(l_act_metric_used_by_id)
            AND l_obj_currencies(l_act_metric_used_by_id).obj_type =
                l_arc_act_metric_used_by THEN
            l_trans_currency_code :=
                l_obj_currencies(l_act_metric_used_by_id).currency;
         ELSE
            Ams_Actmetric_Pvt.GET_TRANS_CURR_CODE(
               p_obj_id  => l_act_metric_used_by_id,
               p_obj_type => l_arc_act_metric_used_by,
               x_trans_curr_code => l_trans_currency_code
            );
            l_obj_currency.obj_id := l_act_metric_used_by_id;
            l_obj_currency.obj_type := l_arc_act_metric_used_by;
            l_obj_currency.currency := l_trans_currency_code;
            l_obj_currencies(l_act_metric_used_by_id) := l_obj_currency;
         END IF;
         -- BUG 3484528: Make certian that currency codes are set.
         -- x_dirty_actmet(l_id).trans_currency_code := l_trans_currency_code;
         x_dirty_actmet(l_id).trans_currency_code :=
            nvl(l_trans_currency_code, l_default_currency);
         -- BUG 3484528: END
         Ams_Actmetric_Pvt.Convert_Currency2 (
             x_return_status => x_return_status,
             p_from_currency => x_dirty_actmet(l_id).func_currency_code,
             p_to_currency   => x_dirty_actmet(l_id).trans_currency_code,
             p_conv_date     => x_dirty_actmet(l_id).last_calculated_date,
             p_from_amount   => x_dirty_actmet(l_id).func_actual_value,
             x_to_amount     => x_dirty_actmet(l_id).trans_actual_value,
             p_from_amount2  => x_dirty_actmet(l_id).func_forecast_value,
             x_to_amount2    => x_dirty_actmet(l_id).trans_forecast_value,
             p_round         => Fnd_Api.G_TRUE);
      ELSE
         -- Otherwise transfer resulting values to the transaction values.
         x_dirty_actmet(l_id).trans_actual_value :=
                  x_dirty_actmet(l_id).func_actual_value;
         x_dirty_actmet(l_id).trans_forecast_value :=
                  x_dirty_actmet(l_id).func_forecast_value;
      END IF;
      l_id := x_dirty_actmet.NEXT(l_id);
   END LOOP;

   -- Save the activity metrics to database.

   -- Each value to be updated in the database must be written to individual
   -- tables and indexed sequencially.  Bulk update does not support refrencing
   -- individual members of an object or record (though the documentation
   -- show an example of that).  Thus individual tables for each value are
   -- required.  Also 'FORALL' only supports sequencial values.
   --
   -- Phase 5, build bulk update tables
   --
   l_index := x_dirty_actmet.FIRST;
   LOOP
     EXIT WHEN l_index IS NULL;
     -- Find a leaf that has not been saved.
     IF x_dirty_actmet(l_index).COUNT = 0 AND
        x_dirty_actmet(l_index).dirty_flag = G_NOT_DIRTY THEN
        l_actmet_id := l_index;
        -- Save the leaf and all unsaved parents.
        LOOP
           EXIT WHEN l_actmet_id IS NULL;
           EXIT WHEN x_dirty_actmet(l_actmet_id).dirty_flag = G_SAVED_DIRTY; -- already saved
           l_count := l_act_met_id.count + 1;
           l_act_met_id (l_count) := l_actmet_id;
           l_cal_date_table(l_count) := x_dirty_actmet(l_actmet_id).last_calculated_date;
           l_sin_last_ref(l_count) := x_dirty_actmet(l_actmet_id).days_since_last_refresh;
           l_func_act_va(l_count) := x_dirty_actmet(l_actmet_id).func_actual_value;
           l_tran_act_va(l_count) := x_dirty_actmet(l_actmet_id).trans_actual_value;
           l_func_for_value(l_count) := x_dirty_actmet(l_actmet_id).func_forecast_value;
           l_trans_for_value(l_count) := x_dirty_actmet(l_actmet_id).trans_forecast_value;
           l_dirty_flag(l_count) := x_dirty_actmet(l_actmet_id).dirty_flag;
           l_diff(l_count) := x_dirty_actmet(l_actmet_id).diff_since_last_calc;
           l_obj_version(l_count):= x_dirty_actmet(l_actmet_id).object_version_number;
           l_func_curr_code(l_count):= x_dirty_actmet(l_actmet_id).func_currency_code;
           l_trans_curr_code(l_count):= x_dirty_actmet(l_actmet_id).trans_currency_code;
           IF p_calc_type = G_ROLLUP AND
              x_dirty_actmet(l_actmet_id).summarize_to_metric IS NOT NULL THEN
              l_summarize_ids(l_summarize_ids.count) :=
                  x_dirty_actmet(l_actmet_id).summarize_to_metric;
           END IF;
           x_dirty_actmet(l_actmet_id).dirty_flag := G_SAVED_DIRTY; -- saved
           -- Next parent.
           l_actmet_id := x_dirty_actmet(l_actmet_id).parent_id;
        END LOOP;
     END IF;

      l_index := x_dirty_actmet.NEXT(l_index);

      IF l_act_met_id.count >= G_BATCH_SIZE
         OR (l_index IS NULL AND l_act_met_id.count > 0) THEN
         FORALL l_count IN l_act_met_id.FIRST .. l_act_met_id.LAST
            UPDATE ams_act_metrics_all
            SET last_calculated_date = l_cal_date_table (l_count),
                days_since_last_refresh = l_sin_last_ref(l_count),
                func_actual_value = l_func_act_va(l_count),
                trans_actual_value = l_tran_act_va(l_count),
                func_forecasted_value = l_func_for_value(l_count),
                trans_forecasted_value = l_trans_for_value(l_count),
                dirty_flag = l_dirty_flag(l_count),
                difference_since_last_calc = l_diff(l_count),
                functional_currency_code = l_func_curr_code(l_count),
                transaction_currency_code = l_trans_curr_code(l_count),
                last_update_date = l_today,
                object_version_number = object_version_number + 1
            WHERE activity_metric_id = l_act_met_id (l_count)
            AND OBJECT_VERSION_NUMBER = l_obj_version(l_count);
         IF p_calc_type = G_ROLLUP AND l_summarize_ids.COUNT > 0 THEN
            FORALL l_count IN l_summarize_ids.FIRST .. l_summarize_ids.LAST
               UPDATE ams_act_metrics_all
               SET dirty_flag = G_IS_DIRTY
               WHERE activity_metric_id = l_summarize_ids(l_count);
         END IF;
         -- Set the formulas to dirty that are effected by this update.
         FORALL l_count IN l_act_met_id.FIRST .. l_act_met_id.LAST
           /* update ams_act_metrics_all
            set dirty_flag = G_IS_DIRTY
            where activity_metric_id in
            (select a.activity_metric_id
            from ams_act_metrics_all a, ams_metrics_all_b m,
              ams_metric_formulas f, ams_act_metrics_all b, ams_metrics_all_b c
            where a.metric_id = m.metric_id
            and m.metric_id = f.metric_id
            and b.metric_id = c.metric_id
            and a.arc_act_metric_used_by = b.arc_act_metric_used_by
            and a.act_metric_used_by_id = b.act_metric_used_by_id
            and m.metric_calculation_type = G_FORMULA
            and ((b.metric_id = f.source_id and f.source_type = G_METRIC)
               or (c.metric_category = f.source_id and f.source_type = G_CATEGORY))
            and b.activity_metric_id = l_act_met_id (l_count)); */
	    	    --batoleti  bug# 5879514
	    update ams_act_metrics_all
            set dirty_flag = G_IS_DIRTY
            where activity_metric_id in
            (select a.activity_metric_id
            from ams_act_metrics_all a, ams_metrics_all_b m,
              ams_metric_formulas f, ams_act_metrics_all b, ams_metrics_all_b c
            where a.metric_id = m.metric_id
            and m.metric_id = f.metric_id
            and b.metric_id = c.metric_id
            and a.arc_act_metric_used_by = b.arc_act_metric_used_by
            and a.act_metric_used_by_id = b.act_metric_used_by_id
            and m.metric_calculation_type = G_FORMULA
            and ((b.metric_id in (select decode(c1.summary_metric_id, NULL, f1.source_id,c1.summary_metric_id)
                                 from ams_metric_formulas f1, ams_metrics_all_b c1
                                 where c1.metric_id=f1.source_id)     and f.source_type = G_METRIC)
               or (c.metric_category = f.source_id and f.source_type = G_CATEGORY))
            and b.activity_metric_id = l_act_met_id (l_count));

         IF p_commit = fnd_api.G_TRUE THEN
            COMMIT;
            IF AMS_DEBUG_MEDIUM_ON THEN
               write_msg(L_API_NAME, 'BATCH UPDATE COMMIT: COUNT='||
                  l_act_met_id.COUNT||', Dirty index='||l_index);
            END IF;
         END IF;
         l_act_met_id.delete;
         l_cal_date_table.delete;
         l_sin_last_ref.delete;
         l_func_act_va.delete;
         l_tran_act_va.delete;
         l_func_for_value.delete;
         l_trans_for_value.delete;
         l_dirty_flag.delete;
         l_diff.delete;
         l_func_curr_code.delete;
         l_trans_curr_code.delete;
         l_obj_version.delete;
         l_summarize_ids.delete;
      END IF;

   END LOOP;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'END: '||p_calc_type);
   END IF;
END Bulk_update;

-- NAME
--    Refresh_Act_Metrics_Engine
--
-- PURPOSE
--    A set of dirty activity metrics are passed in to have the data refreshed.
--
-- ALGORITHM
--    With the list of all dirty metrics iterate through to find all the
--    nodes at the current level and a dirty flag set.  Once no dirty
--    flags are found at this level, increment to the next level and
--    repeat.  End when all levels have expired.
--
-- NOTES
--
-- HISTORY
--      03/26/2001 dmvincen   Created
--
PROCEDURE Refresh_Act_Metrics_Engine
          (x_errbuf        OUT NOCOPY    VARCHAR2,
           x_retcode       OUT NOCOPY    NUMBER,
           p_commit        IN     VARCHAR2 := Fnd_Api.G_TRUE,
           p_run_functions IN     VARCHAR2 := Fnd_Api.G_TRUE,
           p_update_history IN    VARCHAR2 := Fnd_Api.G_FALSE
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           VARCHAR2(30) := 'Refresh_Act_Metrics_Engine';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_dirty_actmet    act_met_ref_rec_set_type;
   l_id              NUMBER;
   l_max_level       NUMBER;
   l_return_status   VARCHAR2(1) ;
   l_msg_count       NUMBER ;
   l_msg_data        VARCHAR2(2000);

   l_index           NUMBER;
   l_count           NUMBER := 1;
/**
   l_act_met_id      num_table_type;
   l_cal_date_table  date_table_type;
   l_sin_last_ref    num_table_type;
   l_func_act_va     num_table_type;
   l_tran_act_va     num_table_type;
   l_func_for_value  num_table_type;
   l_trans_for_value num_table_type;
   l_dirty_flag      dirty_flag_table_type;
   l_diff            num_table_type;
   l_obj_version     num_table_type;
**/
   l_first           NUMBER;
   l_last            NUMBER;
   l_default_currency VARCHAR2(15) := Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY;
   l_current_date    date := SYSDATE;

BEGIN
   x_retcode := 0;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME,'START');
   END IF;

   Clear_Cache;

   Check_Create_Rollup_Parents (
       p_init_msg_list               => Fnd_Api.G_TRUE,
       p_commit                      => FND_API.G_FALSE,
       x_return_status               => l_return_status
     );

   IF p_run_functions = Fnd_Api.G_TRUE THEN
      run_functions(x_errbuf => x_errbuf,
                    x_retcode => x_retcode,
                    p_commit => FND_API.G_FALSE,
                    p_current_date => l_current_date,
                    p_func_currency => l_default_currency);
   END IF;

   UPDATE_VARIABLE(x_errbuf => x_errbuf,
                   x_retcode => x_retcode,
                   p_commit => FND_API.G_FALSE,
                   p_current_date => l_current_date,
                   p_func_currency => l_default_currency);

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Build_Refresh_Act_Metrics (
      x_dirty_act_metric_table      => l_dirty_actmet,
      x_max_count                   => l_max_level,
      p_calc_type                   => G_ROLLUP,
      x_return_status               => l_return_status
      );

   -- Show_Table(l_dirty_actmet /*, l_metric_set */);

   Calculate_This_Metric(
         x_dirty_actmets   => l_dirty_actmet,
         p_max_level       => l_max_level,
         p_calc_type       => G_ROLLUP,
         x_return_status   => l_return_status,
         p_default_currency => l_default_currency);

   Bulk_Update(
       x_dirty_actmet => l_dirty_actmet,
       p_calc_type => G_ROLLUP,
       p_commit => FND_API.G_FALSE,
       x_return_status => l_return_status
   );

   l_dirty_actmet.DELETE;
   l_max_level := 0;

   Build_Refresh_Act_Metrics (
     x_dirty_act_metric_table      => l_dirty_actmet,
     x_max_count                   => l_max_level,
     p_calc_type                   => G_SUMMARY,
     x_return_status               => l_return_status
     );

   -- Show_Table(l_dirty_actmet /* , l_metric_set */ );

   Calculate_This_Metric(
         x_dirty_actmets   => l_dirty_actmet,
         p_max_level       => l_max_level,
         p_calc_type       => G_SUMMARY,
         x_return_status   => l_return_status,
         p_default_currency => l_default_currency);

   Bulk_Update(
      x_dirty_actmet => l_dirty_actmet,
      p_calc_type => G_SUMMARY,
      p_commit => FND_API.G_FALSE,
      x_return_status => l_return_status
   );

   l_dirty_actmet.DELETE;

   Update_formulas(x_errbuf => x_errbuf,
                   x_retcode => x_retcode,
                   p_commit => FND_API.G_FALSE,
                   p_current_date => l_current_date,
                   p_func_currency => l_default_currency);

   -- Update history if flag is either 'T' or 'Y'.
   -- Due to concurrent program restrictions.
   IF p_update_history IN (Fnd_Api.G_TRUE, G_UPDATE_HISTORY) THEN
      Update_History(p_commit => FND_API.G_FALSE);
   END IF;

   Clear_Cache;

   x_errbuf := l_msg_data;

   --
   -- Add success message to message list.
   --
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME,'END');
   END IF;
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      l_return_status := Fnd_Api.G_RET_STS_ERROR;
      write_error(l_api_name);
--      Fnd_Msg_Pub.Count_And_Get (
--         p_count         =>     l_msg_count,
--         p_data          =>     l_msg_data
--      );
      x_retcode := 1;
--      x_errbuf := l_msg_data;
     RAISE;
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      l_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      write_error(l_api_name);
--      Fnd_Msg_Pub.Count_And_Get (
--         p_count         =>     l_msg_count,
--         p_data          =>     l_msg_data
--      );
      x_retcode := 1;
--      x_errbuf := l_msg_data;
     RAISE;
   WHEN OTHERS THEN
      l_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_errbuf := SQLERRM;
      write_msg(l_api_name,'SQLERROR: '||x_errbuf);
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
--      Fnd_Msg_Pub.Count_And_Get (
--         p_count         =>     l_msg_count,
--         p_data          =>     l_msg_data
--      );
      x_retcode := 1;
--      x_errbuf := l_msg_data;
     RAISE;
END Refresh_Act_Metrics_Engine;

-- NAME
--    Refresh_Act_Metrics_Engine
--
-- PURPOSE
--    A set of dirty activity metrics are passed in to have the data refreshed.
--
-- ALGORITHM
--    With the list of all dirty metrics iterate through to find all the
--    nodes at the current level and a dirty flag set.  Once no dirty
--    flags are found at this level, increment to the next level and
--    repeat.  End when all levels have expired.
--
-- NOTES
--
-- HISTORY
--      03/26/2001 dmvincen   Created
--
PROCEDURE Refresh_Act_Metrics_Engine
          (p_api_version           IN     NUMBER,
           p_init_msg_list         IN     VARCHAR2 := Fnd_Api.G_TRUE,
           p_commit                IN     VARCHAR2 := Fnd_Api.G_TRUE,
           x_return_status         IN OUT NOCOPY   VARCHAR2,
           x_msg_count             IN OUT NOCOPY   NUMBER,
           x_msg_data              IN OUT NOCOPY   VARCHAR2,
           p_arc_act_metric_used_by IN varchar2,
           p_act_metric_used_by_id IN number,
           p_run_functions         IN     VARCHAR2 := Fnd_Api.G_TRUE,
           p_update_history        IN    VARCHAR2 := Fnd_Api.G_FALSE
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           VARCHAR2(30) := 'Refresh_Act_Metrics_Engine';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_dirty_actmet    act_met_ref_rec_set_type;
   l_id              NUMBER;
   l_max_level       NUMBER;
   l_return_status   VARCHAR2(1) ;
   l_msg_count       NUMBER ;
   l_msg_data        VARCHAR2(2000);

   l_index           NUMBER;
   l_count           NUMBER := 1;
/***
   l_act_met_id      num_table_type;
   l_cal_date_table  date_table_type;
   l_sin_last_ref    num_table_type;
   l_func_act_va     num_table_type;
   l_tran_act_va     num_table_type;
   l_func_for_value  num_table_type;
   l_trans_for_value num_table_type;
   l_dirty_flag      dirty_flag_table_type;
   l_diff            num_table_type;
   l_obj_version     num_table_type;
**/
   l_first           NUMBER;
   l_last            NUMBER;
   l_default_currency VARCHAR2(15) := Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY;
   l_current_date    date := SYSDATE;

   l_object_list  object_currency_table;

   l_errbuf varchar2(4000);
   l_retcode number;

BEGIN

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME,'START');
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Clear_Cache;

   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   l_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   Get_Object_List(p_arc_act_metric_used_by => p_arc_act_metric_used_by,
           p_act_metric_used_by_id => p_act_metric_used_by_id,
           x_return_status => l_return_status ,
           x_msg_count => l_msg_count     ,
           x_msg_data => l_msg_data      ,
           x_object_list => l_object_list   );

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Check_Create_Rollup_Parents (
       p_init_msg_list               => FND_API.G_FALSE,
       p_commit                      => FND_API.G_FALSE,
       x_return_status               => l_return_status,
       p_object_list                 => l_object_list
     );

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_run_functions = Fnd_Api.G_TRUE THEN
      run_functions(x_errbuf => l_errbuf,
                    x_retcode => l_retcode,
                    p_commit => FND_API.G_FALSE,
                    p_object_list => l_object_list,
                    p_current_date => l_current_date,
                    p_func_currency => l_default_currency);

   END IF;

   UPDATE_VARIABLE(x_errbuf => l_errbuf,
                   x_retcode => l_retcode,
                   p_commit => FND_API.G_FALSE,
                   p_object_list => l_object_list,
                   p_current_date => l_current_date,
                   p_func_currency => l_default_currency);

   Build_Refresh_Act_Metrics (
      x_dirty_act_metric_table      => l_dirty_actmet,
      x_max_count                   => l_max_level,
      p_calc_type                   => G_ROLLUP,
      x_return_status               => l_return_status,
      p_object_list                 => l_object_list);

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Calculate_This_Metric(
         x_dirty_actmets   => l_dirty_actmet,
         p_max_level       => l_max_level,
         p_calc_type       => G_ROLLUP,
         x_return_status   => l_return_status,
         p_default_currency => l_default_currency);

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Bulk_Update(
       x_dirty_actmet => l_dirty_actmet,
       p_calc_type => G_ROLLUP,
       p_commit => FND_API.G_FALSE,
       x_return_status => l_return_status
   );

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_dirty_actmet.DELETE;
   l_max_level := 0;

   Build_Refresh_Act_Metrics (
     x_dirty_act_metric_table      => l_dirty_actmet,
     x_max_count                   => l_max_level,
     p_calc_type                   => G_SUMMARY,
     x_return_status               => l_return_status,
     p_object_list                 => l_object_list);

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Calculate_This_Metric(
         x_dirty_actmets   => l_dirty_actmet,
         p_max_level       => l_max_level,
         p_calc_type       => G_SUMMARY,
         x_return_status   => l_return_status,
         p_default_currency => l_default_currency);

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Bulk_Update(
      x_dirty_actmet => l_dirty_actmet,
      p_calc_type => G_SUMMARY,
      p_commit => FND_API.G_FALSE,
      x_return_status => l_return_status
   );

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_dirty_actmet.DELETE;

   Update_formulas(x_errbuf => l_errbuf,
                   x_retcode => l_retcode,
                   p_commit => FND_API.G_FALSE,
                   p_object_list => l_object_list,
                   p_current_date => l_current_date,
                   p_func_currency => l_default_currency);

   -- Update history if flag is either 'T' or 'Y'.
   -- Due to concurrent program restrictions.
   IF p_update_history IN (Fnd_Api.G_TRUE, G_UPDATE_HISTORY) THEN
      Update_History(p_commit => FND_API.G_FALSE);
   END IF;

   Clear_Cache;

   Fnd_Msg_Pub.Count_And_Get (
      p_count         =>     x_msg_count,
      p_data          =>     x_msg_data
   );
   --
   -- Add success message to message list.
   --
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME,'END');
   END IF;
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
--     RAISE;
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
--     RAISE;
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
--     RAISE;
END Refresh_Act_Metrics_Engine;

-- NAME
--       Check_Create_Rollup_Parents
--
-- PURPOSE
--       The following procedure collects all activity metrics with missing
--         "rollup_to" field, while the corresponding metric template and
--         business objects that have parents, checks their ancestors along
--         the tree hierarchy, fills all the missing "rollup_to" fields of
--         the "ams_act_metrics_all" table.
--
-- NOTES
--
-- HISTORY
-- 03/19/2001   huili      Created.
-- 03/20/2001   huili      Modified to check all the ancestors
-- 10/23/2001   huili      Took out the "arc_metric_used_for_object"
--                         from the "c_act_metrics_parents" cursor.
--
PROCEDURE  Check_Create_Rollup_Parents (
  p_init_msg_list               IN VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN VARCHAR2 := Fnd_Api.G_FALSE,
  x_return_status               OUT NOCOPY VARCHAR2,
  p_object_list                 IN object_currency_table := Empty_object_currency_table
)
IS

  --
  -- Standard API information constants.
  --
  L_API_VERSION       CONSTANT NUMBER := 1.0;
  L_API_NAME          CONSTANT VARCHAR2(30) := 'CHECK_CREATE_ROLLUP_PARENTS';
  L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
  l_return_status     varchar2(1);
  l_msg_count         number;
  l_msg_data          varchar2(4000);

  l_act_metric_parents act_metric_ids_type;
  l_act_metrics act_metric_ids_type;

  l_metric_parent_id NUMBER;
  l_act_metric_id NUMBER;
  l_obj_id NUMBER;
  l_num_rows NUMBER := 0;
  l_row_count NUMBER := 1;
  l_new_act_metric_id NUMBER;
  l_obj_type VARCHAR2(30);
  l_creates NUMBER := 0;
  l_creates_committed NUMBER := 0;

  l_metric_parent_ids num_table_type;
  l_act_metric_ids num_table_type;
  l_obj_ids num_table_type;
  l_obj_types varchar2_table_type;

  l_metric_parent_ids2 num_table_type;
  l_act_metric_ids2 num_table_type;
  l_obj_ids2 num_table_type;
  l_obj_types2 varchar2_table_type;

  --select all activity metrics which have parent and missing "rollup_to_metric"
  -- BUG 3119211 - Removed first_rows hint.
  CURSOR c_act_metrics_parents IS
    SELECT --/*+ first_rows */
           a.metric_parent_id, b.activity_metric_id, b.act_metric_used_by_id,
           b.arc_act_metric_used_by
    FROM ams_metrics_all_b a, ams_act_metrics_all b
    WHERE a.metric_parent_id IS NOT NULL
    AND b.rollup_to_metric IS NULL
    AND a.metric_id = b.metric_id;
    --AND a.arc_metric_used_for_object = b.arc_act_metric_used_by;

  --select all activity metrics which have parent and missing "rollup_to_metric"
  CURSOR c_act_metrics_parents_by_obj(p_object_type varchar2, p_object_id NUMBER) IS
    SELECT /*+ first_rows */
           a.metric_parent_id, b.activity_metric_id, b.act_metric_used_by_id,
           b.arc_act_metric_used_by
    FROM ams_metrics_all_b a, ams_act_metrics_all b
    WHERE a.metric_parent_id IS NOT NULL
    AND b.rollup_to_metric IS NULL
    AND a.metric_id = b.metric_id
    AND b.arc_act_metric_used_by = p_object_type
    AND b.act_metric_used_by_id = p_object_id;
    --AND a.arc_metric_used_for_object = b.arc_act_metric_used_by;

  --l_start_time NUMBER;
  l_count NUMBER;
  l_first number;
  l_last number;

BEGIN

   SAVEPOINT CREATE_ROLLUP_PARENTS_SP1;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME,'START');
   END IF;
  --
  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
    Fnd_Msg_Pub.Initialize;
  END IF;

  --
  -- Standard check for API version compatibility.
  --
  /*** NOT REQUIRED
  IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
                                      p_api_version,
                                      L_API_NAME,
                                      G_PKG_NAME)
  THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  ****/

  --
  -- Initialize API return status to success.
  --
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF p_object_list.count = 0 THEN
     OPEN c_act_metrics_parents;
     FETCH c_act_metrics_parents BULK COLLECT INTO
      l_metric_parent_ids, l_act_metric_ids, l_obj_ids, l_obj_types;
     CLOSE c_act_metrics_parents;
  ELSE
     IF p_object_list.count > 0 THEN
        FOR l_index IN p_object_list.first..p_object_list.last
        LOOP
           OPEN c_act_metrics_parents_by_obj(p_object_list(l_index).obj_type,
              p_object_list(l_index).obj_id);
           FETCH c_act_metrics_parents_by_obj BULK COLLECT INTO
              l_metric_parent_ids2, l_act_metric_ids2, l_obj_ids2, l_obj_types2;
           CLOSE c_act_metrics_parents_by_obj;
           IF l_metric_parent_ids2.count > 0 THEN
              FOR l_index2 IN l_metric_parent_ids2.first..l_metric_parent_ids2.last
              LOOP
                 l_count:= l_metric_parent_ids.count +1;
                 l_metric_parent_ids(l_count) := l_metric_parent_ids2(l_index2);
                 l_act_metric_ids(l_count) := l_act_metric_ids2(l_index2);
                 l_obj_ids(l_count) := l_obj_ids2(l_index2);
                 l_obj_types(l_count) := l_obj_types2(l_index2);
              END LOOP;
           END IF;
        END LOOP;
     END IF;
  END IF;

   IF AMS_DEBUG_MEDIUM_ON THEN
    write_msg(L_API_NAME,'Parents to check: '||l_metric_parent_ids.count);
   END IF;
  IF l_metric_parent_ids.count > 0 THEN
/**
      G_RCAM_Parents_table.DELETE;
      G_CSCH_Parents_table.DELETE;
      G_EVEO_Parents_table.DELETE;
      G_EVEH_Parents_table.DELETE;
      G_EONE_Parents_table.DELETE;
**/
     FOR l_index IN l_metric_parent_ids.first..l_metric_parent_ids.last
     LOOP
       BEGIN
          SAVEPOINT CREATE_ROLLUP_PARENTS_SP2;
       l_new_act_metric_id := NULL;

   IF AMS_DEBUG_MEDIUM_ON THEN
    write_msg(L_API_NAME,'checking: actmetricid'||l_act_metric_ids(l_index));
   END IF;
       Check_Cr_Roll_Par_Helper (
         p_init_msg_list               => p_init_msg_list,
         p_metric_parent_id            => l_metric_parent_ids(l_index),
         p_act_metric_id               => l_act_metric_ids(l_index),
         p_obj_id                      => l_obj_ids(l_index),
         p_obj_type                     => l_obj_types(l_index),
         x_creates                     => l_creates,
         x_act_metric_parents          => l_act_metric_parents,
         x_act_metrics                 => l_act_metrics,
         x_act_metric_id               => l_new_act_metric_id,
         x_return_status               => l_return_status);

          IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
            RAISE Fnd_Api.G_EXC_ERROR;
          ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;

       EXCEPTION
          WHEN others THEN
             ROLLBACK TO CREATE_ROLLUP_PARENTS_SP2;
       END;
       -- Commit subsets of new rollup metrics
       IF (l_creates - l_creates_committed > G_BATCH_SIZE OR
           (l_index = l_metric_parent_ids.last AND
            l_creates - l_creates_committed > 0)) AND
          p_commit = FND_API.G_TRUE THEN
          COMMIT;
          l_creates_committed := l_creates;
          IF AMS_DEBUG_MEDIUM_ON THEN
             write_msg(L_API_NAME,'BATCH COMMIT: PARENTS CREATED='||l_creates);
          END IF;
       END IF;

     END LOOP;

     l_metric_parent_ids.delete;
 /**
      G_RCAM_Parents_table.DELETE;
      G_CSCH_Parents_table.DELETE;
      G_EVEO_Parents_table.DELETE;
      G_EVEH_Parents_table.DELETE;
      G_EONE_Parents_table.DELETE;
 **/
  END IF;

   IF AMS_DEBUG_HIGH_ON THEN
     write_msg(L_API_NAME,'PARENT CHECK COMPLETE: PARENTS CREATED='||l_creates);
   END IF;
  --write_msg('Per LOOP TIME: '|| (DBMS_UTILITY.get_time-l_start_time)/l_count);

  --now, do bulk update
  IF l_act_metrics.count > 0 then
     l_first := l_act_metrics.first;
     LOOP
        EXIT WHEN l_first > l_act_metrics.last;
        IF l_first + G_BATCH_SIZE + G_BATCH_PAD > l_act_metrics.last THEN
           l_last := l_act_metrics.last;
        ELSE
           l_last := l_first + G_BATCH_SIZE - 1;
        END IF;
        FORALL l_row_count IN l_first .. l_last
          UPDATE ams_act_metrics_all
          SET rollup_to_metric = l_act_metric_parents (l_row_count)
          WHERE activity_metric_id = l_act_metrics (l_row_count);

     -- 06/13/2001 huili added to set the dirty_flag of parent activity metrics
        FORALL l_row_count IN l_first .. l_last
          UPDATE ams_act_metrics_all
               SET dirty_flag = G_IS_DIRTY
          WHERE activity_metric_id = l_act_metric_parents (l_row_count)
               AND dirty_flag = G_NOT_DIRTY;
        -- Commit a batch of rollup ids.
        IF p_commit = FND_API.G_TRUE THEN
          COMMIT;
          IF AMS_DEBUG_MEDIUM_ON THEN
             write_msg(L_API_NAME,'BATCH COMMIT: ROLLUPS='||l_last);
          END IF;
        END IF;
        l_first := l_last + 1;
     END LOOP;
   END IF;
  --
  --release memory
  --
   IF AMS_DEBUG_HIGH_ON THEN
     write_msg(L_API_NAME,'END: ROWS UPDATED='||l_act_metrics.count);
   END IF;
  l_act_metric_parents.DELETE;
  l_act_metrics.DELETE;

  --
  -- Standard check for commit request.
  --
  IF Fnd_Api.To_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;
  --
  -- Standard API to get message count, and if 1,
  -- set the message data OUT variable.
  --
--  Fnd_Msg_Pub.Count_And_Get (
--    p_count           =>    x_msg_count,
--    p_data            =>    x_msg_data,
--    p_encoded         =>    Fnd_Api.G_FALSE
--  );

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_ROLLUP_PARENTS_SP1;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
--      Fnd_Msg_Pub.Count_And_Get (
--        p_count         =>     x_msg_count,
--         p_data          =>     x_msg_data
--      );
--      RAISE Fnd_Api.G_EXC_ERROR;
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_ROLLUP_PARENTS_SP1;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
--      Fnd_Msg_Pub.Count_And_Get (
--         p_count         =>     x_msg_count,
--         p_data          =>     x_msg_data
--      );
--      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;

    WHEN OTHERS THEN
      ROLLBACK TO CREATE_ROLLUP_PARENTS_SP1;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
--      Fnd_Msg_Pub.Count_And_Get (
--         p_count         =>     x_msg_count,
--         p_data          =>     x_msg_data
--      );
--      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
END Check_Create_Rollup_Parents;


-- NAME
--         Check_Cr_Roll_Par_Helper
--
-- PURPOSE
--         The following procedure checks the existance of a rollup activity metric for the
--         parent Marketing objects. If none eixists, one will be generated. The checking
--         will recursively happen along the hierarchy. The id will
--         be saved on the "ROLLUP_TO_METRIC" column of the "AMS_ACT_METRICS_ALL" table.
--
-- NOTES
--
-- HISTORY
-- 03/20/2001   huili      Created.
-- 06/07/2001   huili      Changed to the new hierarchy for new version 11.5.5
-- 07/26/2001   huili      Removed rollup from "Deliverable" business object.
-- 10/23/2001   huili      Commented out the "c_metric_used_type" cursor.
--
PROCEDURE  Check_Cr_Roll_Par_Helper (

  p_init_msg_list               IN VARCHAR2 := FND_API.G_FALSE,
  p_metric_parent_id            IN NUMBER,
  p_act_metric_id               IN NUMBER,
  p_obj_id                      IN NUMBER,
  p_obj_type                    IN VARCHAR2,
  x_act_metric_parents          IN OUT NOCOPY act_metric_ids_type,
  x_act_metrics                 IN OUT NOCOPY act_metric_ids_type,
  p_depth                       IN NUMBER := 0,
  x_creates                     IN OUT NOCOPY NUMBER,

  x_act_metric_id               OUT NOCOPY NUMBER, -- Id of the activity metric created
  x_return_status               OUT NOCOPY VARCHAR2,
  p_commit                      IN VARCHAR2 := FND_API.G_FALSE
)

IS

  l_api_version constant NUMBER := 1.0;
  l_api_name constant varchar2(30) := 'CHECK_CR_ROLL_PAR_HELPER';
  l_return_status  varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(4000);

  l_parent_obj_type VARCHAR2(30);
  l_parent_obj_id NUMBER;

  l_parent_act_metric_id NUMBER;
  l_act_metrics_rec Ams_Actmetric_Pvt.act_metric_rec_type;

  l_parent_metric_id NUMBER;
  l_new_act_metric_id NUMBER;

  l_obj_type VARCHAR2(30);
  l_error varchar2(4000);

  l_count number;

  l_show_flag varchar2(1);

  --find parent metric_id
  CURSOR c_parent_metric_id (l_metric_id NUMBER) IS
    SELECT metric_parent_id
    FROM ams_metrics_all_b
    WHERE metric_id = l_metric_id;
/**
  --check for the parent campaign
  CURSOR c_check_parent_campaign(l_act_metric_used_by_id NUMBER) IS
    SELECT parent_campaign_id
    FROM ams_campaigns_all_b
    WHERE campaign_id = l_act_metric_used_by_id
    AND UPPER(show_campaign_flag) = 'Y';

  --check for the parent event
  CURSOR c_check_parent_event_o(l_act_metric_used_by_id NUMBER) IS
    SELECT event_header_id
    FROM ams_event_offers_all_b
    WHERE event_offer_id = l_act_metric_used_by_id;

  --check for the parent event
  -- BUG 3456849: Changed parent to be a program_id.
  CURSOR c_check_parent_event_h(l_act_metric_used_by_id NUMBER) IS
    SELECT program_id
    FROM ams_event_headers_all_b
    WHERE event_header_id = l_act_metric_used_by_id;

  -- 06/23/2001 huili changed the "c_check_event_camp"
  -- 06/07/2001 huili added two cursors
  --check another type of parent event: execution campaign
  CURSOR c_check_event_camp (l_act_metric_used_by_id NUMBER) IS
    SELECT program_id
    FROM ams_event_headers_all_b
    WHERE event_header_id = l_act_metric_used_by_id;

  CURSOR c_check_camp_type (l_camp_id NUMBER) IS
         SELECT rollup_type
    FROM ams_campaigns_all_b
    WHERE campaign_id = l_camp_id;

  -- 06/23/2001 huili added
  --check the parent campaign for schedule
  CURSOR c_check_parent_schedule (l_act_metric_used_by_id NUMBER) IS
    SELECT campaign_id
    FROM ams_campaign_schedules_b
    WHERE schedule_id = l_act_metric_used_by_id;

  CURSOR c_check_parent_one_event(l_act_metric_used_by_id NUMBER) IS
    SELECT parent_id
    FROM ams_event_offers_all_b
    WHERE event_offer_id = l_act_metric_used_by_id
         AND parent_type = G_RCAM;
  -- END
**/
  -- check if act_metrics exists
  CURSOR c_verify_act_metric(l_metric_parent_id NUMBER,
         l_obj_id NUMBER,
         l_obj_code VARCHAR2) IS
    SELECT activity_metric_id
    FROM ams_act_metrics_all
    WHERE metric_id = l_metric_parent_id
    AND act_metric_used_by_id = l_obj_id
    AND arc_act_metric_used_by = l_obj_code;

BEGIN

  --
  -- Initialize API return status to success.
  --
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF p_depth > G_MAX_DEPTH THEN
     write_msg(l_api_name,'Exceeded depth '||G_MAX_DEPTH||': p_act_metric_id='||p_act_metric_id);
     RETURN;
  END IF;

  l_parent_obj_id := NULL;
  l_parent_obj_type := NULL;
/**
  -- 06/22/2001 huili changed
  IF p_obj_type IS NOT NULL THEN
    l_obj_type := UPPER (p_obj_type);
    -- campaign to program and program to another program
    IF l_obj_type in (G_CAMP, G_RCAM) THEN
      IF G_RCAM_Parents_table.EXISTS(p_obj_id) THEN
         l_parent_obj_id := G_RCAM_Parents_table(p_obj_id);
      ELSE
      OPEN c_check_parent_campaign (p_obj_id);
      FETCH c_check_parent_campaign INTO l_parent_obj_id;
      CLOSE c_check_parent_campaign;
         G_RCAM_Parents_Table(p_obj_id) := l_parent_obj_id;
      END IF;
      l_parent_obj_type := G_RCAM;
    -- schedule to campaign
    ELSIF l_obj_type = G_CSCH THEN
      IF G_CSCH_Parents_table.EXISTS(p_obj_id) THEN
         l_parent_obj_id := G_CSCH_Parents_table(p_obj_id);
      ELSE
      OPEN c_check_parent_schedule (p_obj_id);
      FETCH c_check_parent_schedule INTO l_parent_obj_id;
      CLOSE c_check_parent_schedule;
         G_CSCH_Parents_Table(p_obj_id) := l_parent_obj_id;
      END IF;
      l_parent_obj_type := G_CAMP;
    -- Event Schedule to Event
    ELSIF l_obj_type = G_EVEO THEN
      IF G_EVEO_Parents_table.EXISTS(p_obj_id) THEN
         l_parent_obj_id := G_EVEO_Parents_table(p_obj_id);
      ELSE
      OPEN c_check_parent_event_o (p_obj_id);
      FETCH c_check_parent_event_o INTO l_parent_obj_id;
      CLOSE c_check_parent_event_o;
         G_EVEO_Parents_Table(p_obj_id) := l_parent_obj_id;
      END IF;
      l_parent_obj_type := G_EVEH;
    -- Event to Program
    ELSIF l_obj_type = G_EVEH THEN
      IF G_EVEH_Parents_table.EXISTS(p_obj_id) THEN
         l_parent_obj_id := G_EVEH_Parents_table(p_obj_id);
      ELSE
      OPEN c_check_event_camp (p_obj_id);
      FETCH c_check_event_camp INTO l_parent_obj_id;
      CLOSE c_check_event_camp;
         G_EVEH_Parents_Table(p_obj_id) := l_parent_obj_id;
      END IF;
      l_parent_obj_type := G_RCAM;
    -- One Off Event to Program
    ELSIF l_obj_type = G_EONE THEN
      IF G_EONE_Parents_table.EXISTS(p_obj_id) THEN
         l_parent_obj_id := G_EONE_Parents_table(p_obj_id);
      ELSE
      OPEN c_check_parent_one_event (p_obj_id);
      FETCH c_check_parent_one_event INTO l_parent_obj_id;
      CLOSE c_check_parent_one_event;
         G_EONE_Parents_Table(p_obj_id) := l_parent_obj_id;
      END IF;
      l_parent_obj_type := G_RCAM;
    END IF;
  END IF;
**/
   IF AMS_DEBUG_MEDIUM_ON THEN
  write_msg(l_api_name, 'object='||p_obj_type||'/'||p_obj_id);
   END IF;
  get_parent_object(p_obj_type, p_obj_id, l_parent_obj_type, l_parent_obj_id,
      l_show_flag);
   IF AMS_DEBUG_MEDIUM_ON THEN
  write_msg(l_api_name, 'object='||p_obj_type||'/'||p_obj_id||', parent='||l_parent_obj_type||'/'||l_parent_obj_id);
   END IF;
  if l_show_flag = G_HIDE then
  -- Do no rollup hidden campaigns.
     l_parent_obj_id := null;
     l_parent_obj_type := null;
  end if;

  IF l_parent_obj_id IS NOT NULL THEN -- parent object exists
    OPEN c_verify_act_metric(p_metric_parent_id,
         l_parent_obj_id, l_parent_obj_type);
    l_parent_act_metric_id := NULL;
    FETCH c_verify_act_metric INTO l_parent_act_metric_id;
    CLOSE c_verify_act_metric;

   IF AMS_DEBUG_MEDIUM_ON THEN
    write_msg(L_API_NAME,'l_parent_act_metric_id='||l_parent_act_metric_id);
   END IF;
    IF l_parent_act_metric_id IS NULL THEN
      -- The parent obj exists while the corresponding act_metric does not
      -- exist then create the parent.
      l_act_metrics_rec.act_metric_used_by_id := l_parent_obj_id;
      l_act_metrics_rec.arc_act_metric_used_by := l_parent_obj_type;
      l_act_metrics_rec.metric_id := p_metric_parent_id;
      l_act_metrics_rec.application_id := G_MARKETING_APP_ID;
      l_act_metrics_rec.dirty_flag := G_IS_DIRTY;

   IF AMS_DEBUG_MEDIUM_ON THEN
    write_msg(L_API_NAME,'creating parent: metric_id='||p_metric_parent_id);
   END IF;
      Ams_Actmetric_Pvt.Create_ActMetric (
        p_api_version                => l_api_version,
        p_init_msg_list              => FND_API.G_FALSE,
        p_act_metric_rec             => l_act_metrics_rec,
        x_return_status              => l_return_status,
        x_msg_count                  => l_msg_count,
        x_msg_data                   => l_msg_data,
        x_activity_metric_id         => l_parent_act_metric_id,
        p_commit                     => FND_API.G_FALSE);

      x_creates := x_creates + 1;

      IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        IF p_init_msg_list = FND_API.G_TRUE THEN
           --write_msg(l_api_name,'CREATE_ACTMETRIC ERROR on metric_id='||p_metric_parent_id
           --  ||', obj_type='||l_parent_obj_type||', obj_id='||l_parent_obj_id);
           fnd_message.Set_Name('AMS','AMS_METR_IGNORE_ERROR');
           Fnd_Msg_Pub.Add;
           write_error(l_api_name);
        END IF;
      ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        IF p_init_msg_list = FND_API.G_TRUE THEN
           --write_msg(l_api_name,'CREATE_ACTMETRIC UNEXP on metric_id='||p_metric_parent_id
           --  ||', obj_type='||l_parent_obj_type||', obj_id='||l_parent_obj_id);
           fnd_message.Set_Name('AMS','AMS_METR_IGNORE_ERROR');
           Fnd_Msg_Pub.Add;
           write_error(l_api_name);
        END IF;
      ELSE

         IF l_parent_act_metric_id IS NOT NULL THEN
            l_count := x_act_metrics.count +1;
            x_act_metric_parents (l_count) := l_parent_act_metric_id;
            x_act_metrics (l_count) := p_act_metric_id;

            x_act_metric_id := l_parent_act_metric_id;

            --
            -- Only recursively check the newly created one since the other ones are
            -- checked by the "Check_Create_Rollup_Parents" function.
            --
            OPEN c_parent_metric_id (p_metric_parent_id);
            l_parent_metric_id := NULL;
            FETCH c_parent_metric_id INTO l_parent_metric_id;
            CLOSE c_parent_metric_id;

            l_new_act_metric_id := NULL;
            IF l_parent_metric_id IS NOT NULL THEN --parent metric exists
              Check_Cr_Roll_Par_Helper (
                p_init_msg_list             => p_init_msg_list,
                p_metric_parent_id          => l_parent_metric_id,
                p_act_metric_id             => l_parent_act_metric_id,
                p_obj_id                    => l_parent_obj_id,
                p_obj_type                  => l_parent_obj_type,
                x_creates                   => x_creates,

                x_act_metric_parents        => x_act_metric_parents,
                x_act_metrics               => x_act_metrics,
                p_depth                     => p_depth+1,
                x_act_metric_id             => l_new_act_metric_id,
                x_return_status             => x_return_status);

            END IF; --l_parent_metric_id IS NOT NULL

         ELSE -- need to update this one
            l_count := x_act_metrics.count +1;
            x_act_metric_parents (l_count) := l_parent_act_metric_id;
            x_act_metrics (l_count) := p_act_metric_id;
         END IF;--l_parent_act_metric_id IS NULL
      END IF; -- l_return_status = Fnd_Api.G_RET_STS_ERROR
    ELSE --l_parent_act_metric_id IS NOT NULL
        l_count := x_act_metrics.count +1;
        x_act_metric_parents (l_count) := l_parent_act_metric_id;
        x_act_metrics (l_count) := p_act_metric_id;
    END IF;--l_parent_act_metric_id IS NULL

  END IF; --l_parent_obj_id IS NOT NULL

  --
  -- Standard API to get message count, and if 1,
  -- set the message data OUT variable.
  --
  /*** Not required for this routine.
  Fnd_Msg_Pub.Count_And_Get (
    p_count           =>    x_msg_count,
    p_data            =>    x_msg_data,
    p_encoded         =>    Fnd_Api.G_FALSE
  );
  ****/
/*
  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
        p_count         =>     x_msg_count,
        p_data          =>     x_msg_data
      );
      RAISE Fnd_Api.G_EXC_ERROR;
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
        p_count         =>     x_msg_count,
        p_data          =>     x_msg_data
      );
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;

    WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
        p_count         =>     x_msg_count,
        p_data          =>     x_msg_data
      );
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
*/
END Check_Cr_Roll_Par_Helper;

--
-- NAME
--    Exec_Function
--
-- PURPOSE
--    Executes the given function using values derived from the
--    activity_metric_id. Return the value derived from the given function.
--
-- NOTES
--    Use Native Dynamic SQL (8i feature) for executing the function.
--
-- HISTORY
-- 07/05/1999     choang            Created.
-- 08/29/2001     huili             Added non-parameter call for execution of
--                                  stored procedures
--
FUNCTION Exec_Function (
   p_activity_metric_id       IN NUMBER := NULL,
   p_function_name            IN VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2,
   p_arc_act_metric_used_by   IN varchar2 := NULL,
   p_act_metric_used_by_id    IN number := NULL
)RETURN NUMBER
IS
   L_API_NAME CONSTANT varchar2(100) := 'EXEC_FUNCTION';
   l_return_value          NUMBER := NULL;
   l_sql_str               VARCHAR2(4000);
   l_error                 VARCHAR2(4000);
BEGIN
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   IF p_activity_metric_id IS NOT NULL THEN
      l_sql_str := 'BEGIN :return_value := ' || p_function_name ||
                     '( :activity_metric_id ); END;';
      EXECUTE IMMEDIATE l_sql_str
      USING OUT l_return_value,
      IN p_activity_metric_id;
   ELSE
      IF p_arc_act_metric_used_by IS NOT NULL AND
         p_act_metric_used_by_id IS NOT NULL THEN
         l_sql_str := 'BEGIN ' || p_function_name ||
           '( :p_arc_act_metric_used_by, :p_act_metric_used_by_id ); END;';
         EXECUTE IMMEDIATE l_sql_str
         USING IN p_arc_act_metric_used_by,
                  p_act_metric_used_by_id;
      ELSE
         l_sql_str := 'BEGIN ' ||  p_function_name || ';  END;';
         EXECUTE IMMEDIATE l_sql_str;
      END IF;
   END IF;
   RETURN l_return_value;
EXCEPTION
  WHEN OTHERS THEN
     l_error := SQLERRM;
     write_msg(L_API_NAME,'EXCEPTION: '|| l_error);
     write_msg(L_API_NAME,'SQL_STR: '||l_sql_str);
     write_msg(L_API_NAME,'ACTIVITY_METRIC_ID="'||p_activity_metric_id
       ||'", p_arc_act_metric_used_by="'||p_arc_act_metric_used_by
       ||'", p_act_metric_used_by_id="'||p_act_metric_used_by_id||'"');
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     RETURN l_return_value;
END Exec_Function;

-------------------------------------------------------------------------------
-- NAME
--    Run_Functions
-- PURPOSE
--    For all activity metrics of type FUNCTION, if the function's evaluated
--    value is different from it's original value, update the activity metric
--    to reflect the change and make it dirty, which also makes all activity
--    metrics above it in the hierarchy dirty.
-- HISTORY
-- 13-Oct-2000 choang   Created.
-- 03-Apr-2001 dmvincen Transfered from Ams_RefreshMetrics_Pvt
-- 29-Aug-2001 huili    Added stored procedure support.
-- 16-Jun-2004 dmvincen Initialize l_func_currencies and l_new_trans_actuals.
-------------------------------------------------------------------------------
PROCEDURE Run_Functions
        (x_errbuf       OUT NOCOPY   VARCHAR2,
         x_retcode      OUT NOCOPY   NUMBER,
         p_commit       IN    VARCHAR2 := Fnd_Api.G_TRUE,
         p_object_list  IN object_currency_table := Empty_object_currency_table,
         p_current_date IN date,
         p_func_currency IN varchar2
)
IS
   L_API_NAME            VARCHAR2(30) := 'Run_Functions';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_new_func_value     AMS_ACT_METRICS_ALL.FUNC_ACTUAL_VALUE%TYPE;
--   l_act_metric_rec     Ams_Actmetric_Pvt.Act_Metric_Rec_Type;

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(4000);
   cntr  NUMBER := 1;
   l_dummy_result NUMBER;
   TYPE t_procedures IS TABLE OF ams_metrics_all_b.function_name%TYPE;

   l_function_list t_procedures;
   l_function_name ams_metrics_all_b.function_name%TYPE;

   --All functions
   CURSOR c_functions IS
      SELECT /*+ first_rows */ activity_metric_id,
             function_name,
             func_actual_value,
             last_calculated_date,
             metric_category,
             TRANSACTION_CURRENCY_CODE,
             functional_currency_code
      FROM   ams_metrics_all_b a, ams_act_metrics_all b,
		       ams_lookups lkup
      WHERE  a.metric_id = b.metric_id
		-- BUG4924982: Performance, join to metric definition.
      AND a.arc_metric_used_for_object = lkup.lookup_code
      AND lookup_type = 'AMS_METRIC_OBJECT_TYPE'
      AND a.metric_calculation_type = G_FUNCTION
      AND a.function_type = G_IS_FUNCTION;

   --Some Functions
   CURSOR c_function(l_object_type varchar2, l_object_id number) IS
      SELECT /*+ first_rows */ activity_metric_id,
             function_name,
             func_actual_value,
             last_calculated_date,
             metric_category,
             TRANSACTION_CURRENCY_CODE,
             functional_currency_code
      FROM   ams_metrics_all_b a, ams_act_metrics_all b
      WHERE  a.metric_id = b.metric_id
      AND b.arc_act_metric_used_by = l_object_type
      AND b.act_metric_used_by_id = l_object_id
      AND a.metric_calculation_type = G_FUNCTION
      AND a.function_type = G_IS_FUNCTION;

   CURSOR c_met_procedures IS
      SELECT DISTINCT function_name
      FROM   ams_metrics_all_b
      WHERE  arc_metric_used_for_object IN
         (select lookup_code from ams_lookups
          where lookup_type = 'AMS_METRIC_OBJECT_TYPE')
         -- Replaced with metadata lookups above.
      --(G_CAMP, G_CSCH, G_DELV, G_EVEO, G_EVEH, G_RCAM, G_EONE)
      --BUG2845365: Removed dialogue components.
      --G_DILG, G_AMS_COMP_START, G_AMS_COMP_SHOW_WEB_PAGE, G_AMS_COMP_END)
      AND metric_calculation_type = G_FUNCTION
      AND function_type = G_IS_PROCEDURE
      AND enabled_flag = G_IS_ENABLED;

   CURSOR c_has_procedure(l_function_name varchar2,
               l_obj_type varchar2, l_obj_id number) IS
      SELECT count(1)
      FROM ams_act_metrics_all a, ams_metrics_all_b b
      WHERE a.metric_id = b.metric_id
      AND b.function_name = l_function_name
      AND a.arc_act_metric_used_by = l_obj_type
      AND a.act_metric_used_by_id = l_obj_id
      AND b.metric_calculation_type = G_FUNCTION
      AND b.function_type = G_IS_PROCEDURE
      AND b.enabled_flag = G_IS_ENABLED;

   l_count number;
   l_function_rec    c_functions%ROWTYPE;
   l_current_date  DATE :=  p_current_date;
   l_start_time NUMBER;
   l_act_metric_ids num_table_type;
   l_function_names varchar2_table_type;
   l_func_actual_values num_table_type;
   l_last_calculated_dates date_table_type;
   l_temp_act_metric_ids num_table_type;
   l_temp_function_names varchar2_table_type;
   l_temp_func_actual_values num_table_type;
   l_temp_last_calculated_dates date_table_type;
   l_new_act_metric_ids num_table_type;
   l_new_func_actuals num_table_type;
   l_new_trans_actuals num_table_type;
   l_days_since_last_refreshs num_table_type;
   l_trans_currencies varchar2_table_type;
   l_temp_trans_currencies varchar2_table_type;
   l_temp_func_currencies varchar2_table_type;
   l_func_currencies varchar2_table_type;
   l_categories num_table_type;
   l_temp_categories num_table_type;
   l_func_currency varchar2(30) := p_func_currency;

   l_error varchar2(4000);
   l_first number;
   l_last number;

BEGIN
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME,'START');
   END IF;

   --Step 1, execute all stored procedures on metric table
   OPEN c_met_procedures;
   FETCH c_met_procedures BULK COLLECT INTO l_function_list;
   CLOSE c_met_procedures;
   IF l_function_list.COUNT > 0 THEN
      FOR l_index IN l_function_list.FIRST..l_function_list.LAST
      LOOP
         IF AMS_DEBUG_HIGH_ON THEN
            write_msg(L_API_NAME,'PROCEDURE = '||l_function_list(l_index));
         END IF;
         l_start_time := DBMS_UTILITY.get_time;
         IF p_object_list.COUNT > 0 THEN
            FOR l_index2 IN p_object_list.first..p_object_list.last
            LOOP
               OPEN c_has_procedure(l_function_list(l_index),
                    p_object_list(l_index2).obj_type,
                    p_object_list(l_index2).obj_id);
               FETCH c_has_procedure INTO l_dummy_result;
               CLOSE c_has_procedure;
               IF l_dummy_result > 0 THEN
                  l_dummy_result := Exec_Function (
                       p_function_name => l_function_list(l_index),
                       x_return_status => l_return_status,
                       p_arc_act_metric_used_by => p_object_list(l_index2).obj_type,
                       p_act_metric_used_by_id => p_object_list(l_index2).obj_id);
               END IF;
            END LOOP;
         ELSE
            l_dummy_result := Exec_Function (
                       p_function_name => l_function_list(l_index),
                       x_return_status => l_return_status);
         END IF;
         IF AMS_DEBUG_HIGH_ON THEN
            write_msg(L_API_NAME,'elapse time (seconds)= '
                 || ((DBMS_UTILITY.get_time - l_start_time) / 100));
         END IF;
         IF p_commit = FND_API.G_TRUE THEN
            COMMIT;
            IF AMS_DEBUG_MEDIUM_ON THEN
               write_msg(L_API_NAME,'BATCH COMMIT');
            END IF;
         END IF;
      END LOOP;
      IF AMS_DEBUG_HIGH_ON THEN
         write_msg(L_API_NAME,'PROCEDURES RUN='||l_function_list.COUNT);
      END IF;
      l_function_list.DELETE;
   END IF;

   --Step 2, execute all function against each activity metric
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME,'COLLECTING FUNCTIONS TO RUN');
   END IF;

   IF p_object_list.count > 0 THEN
      FOR l_index IN p_object_list.first..p_object_list.last
      LOOP
         OPEN c_function(p_object_list(l_index).obj_type,
            p_object_list(l_index).obj_id);
         FETCH c_function BULK COLLECT INTO
         l_temp_act_metric_ids,
         l_temp_function_names,
         l_temp_func_actual_values,
         l_temp_last_calculated_dates,
         l_temp_categories,
         l_temp_trans_currencies,
         l_temp_func_currencies;
         CLOSE c_function;
         IF l_temp_act_metric_ids.count > 0 THEN
            FOR l_index2 IN l_temp_act_metric_ids.first..l_temp_act_metric_ids.last
            LOOP
               l_count := l_act_metric_ids.count + 1;
               l_act_metric_ids(l_count) := l_temp_act_metric_ids(l_index2);
               l_function_names(l_count) := l_temp_function_names(l_index2);
               l_func_actual_values(l_count) := l_temp_func_actual_values(l_index2);
               l_last_calculated_dates(l_count) := l_temp_last_calculated_dates(l_index2);
               l_trans_currencies(l_count) := l_temp_trans_currencies(l_index2);
               l_func_currencies(l_count) := l_temp_func_currencies(l_index2);
               /*******
               IF l_temp_categories(l_index2) IN (G_COST_ID,G_REVENUE_ID) THEN
                  l_func_currencies(l_count) := l_func_currency;
               ELSE
                  l_func_currencies(l_count) := NULL;
               END IF;
               *******/
               l_categories(l_count) := l_temp_categories(l_index2);
            END LOOP;
         END IF;
         l_temp_act_metric_ids.delete;
         l_temp_function_names.delete;
         l_temp_func_actual_values.delete;
         l_temp_last_calculated_dates.delete;
         l_temp_categories.delete;
         l_temp_trans_currencies.delete;
         l_temp_func_currencies.delete;
      END LOOP;
   ELSE
      OPEN c_functions;
      FETCH c_functions BULK COLLECT INTO
         l_act_metric_ids,
         l_function_names,
         l_func_actual_values,
         l_last_calculated_dates,
         l_categories,
         l_trans_currencies,
         l_func_currencies;
      CLOSE c_functions;
   END IF;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME,'FUNCTION METRICS TO RUN='||l_act_metric_ids.COUNT);
   END IF;

   IF l_act_metric_ids.count > 0 THEN
      FOR l_index IN l_act_metric_ids.first..l_act_metric_ids.last
      LOOP
         l_new_func_value := Exec_Function (
            p_activity_metric_id => l_act_metric_ids(l_index),
            p_function_name => l_function_names(l_index),
            x_return_status => l_return_status);

         IF AMS_DEBUG_LOW_ON THEN
            write_msg(L_API_NAME,'actmetid='||l_act_metric_ids(l_index)||
               ': function_name='||l_function_names(l_index)||
               ': actual_value='||l_func_actual_values(l_index)||
               ': new_value='||l_new_func_value);
         END IF;
         IF l_return_status <> Fnd_Api.G_RET_STS_ERROR
            AND NVL(l_new_func_value,0) <> NVL(l_func_actual_values(l_index),0)
         THEN
            l_count := l_new_act_metric_ids.count+1;
            l_new_act_metric_ids(l_count) := l_act_metric_ids(l_index);
            l_new_func_actuals(l_count) := l_new_func_value;
            l_days_since_last_refreshs(l_count) :=
                l_current_date - l_last_calculated_dates(l_index);
            l_new_trans_actuals(l_count) := l_new_func_value;
            IF l_func_currencies(l_count) IS NOT NULL THEN
               Ams_Actmetric_Pvt.Convert_Currency (
                   x_return_status => l_return_status,
                   p_from_currency => l_func_currencies(l_count),
                   p_to_currency   => l_trans_currencies(l_count),
                   p_conv_date     => l_current_date,
                   p_from_amount   => l_new_func_value,
                   x_to_amount     => l_new_trans_actuals(l_count),
                   p_round         => Fnd_Api.G_TRUE);
            ELSE
               l_new_trans_actuals(l_count) := l_new_func_value;
            END IF;
         END IF;
      END LOOP;

   IF AMS_DEBUG_HIGH_ON THEN
     write_msg(L_API_NAME,'NEW ACTUALS TO UPDATE='||l_new_act_metric_ids.COUNT);
   END IF;

      IF l_new_act_metric_ids.count > 0 THEN
         l_first := l_new_act_metric_ids.first;
         LOOP
            EXIT WHEN l_first > l_new_act_metric_ids.last;
            IF l_first + G_BATCH_SIZE + G_BATCH_PAD > l_new_act_metric_ids.last
            THEN
               l_last := l_new_act_metric_ids.last;
            ELSE
               l_last := l_first + G_BATCH_SIZE - 1;
            END IF;
            FORALL l_count IN l_first .. l_last
              UPDATE ams_act_metrics_all
              SET last_calculated_date = l_current_date,
                  last_update_date = l_current_date,
                  func_actual_value = l_new_func_actuals(l_count),
--                  FUNCTIONAL_CURRENCY_CODE = l_func_currencies(l_count),
                  days_since_last_refresh = l_days_since_last_refreshs(l_count),
                  trans_actual_value = l_new_trans_actuals(l_count)
              WHERE activity_metric_id = l_new_act_metric_ids(l_count);

            FORALL l_count IN l_first .. l_last
              UPDATE ams_act_metrics_all
                 SET dirty_flag = G_IS_DIRTY
               WHERE activity_metric_id IN
                 (SELECT rollup_to_metric FROM ams_act_metrics_all
                  WHERE activity_metric_id = l_new_act_metric_ids(l_count)
                  AND rollup_to_metric IS NOT NULL
                  UNION ALL
                  SELECT summarize_to_metric FROM ams_act_metrics_all
                  WHERE activity_metric_id = l_new_act_metric_ids(l_count)
                  AND summarize_to_metric IS NOT NULL);

            l_first := l_last + 1;
            IF p_commit = fnd_api.g_true THEN
               COMMIT;
               IF AMS_DEBUG_MEDIUM_ON THEN
                  write_msg(L_API_NAME,'BATCH COMMIT: l_last='||l_last);
               END IF;
            END IF;
         END LOOP;

         l_new_func_actuals.delete;
--         l_func_currencies.delete;
         l_days_since_last_refreshs.delete;
         l_new_trans_actuals.delete;
         l_new_act_metric_ids.delete;
      END IF;
      l_act_metric_ids.delete;
      l_function_names.delete;
      l_func_actual_values.delete;
      l_last_calculated_dates.delete;
      l_categories.delete;
      l_trans_currencies.delete;
      l_func_currencies.delete;
   END IF;
   x_errbuf := l_msg_data;
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME,'END');
   END IF;
EXCEPTION
  WHEN OTHERS THEN
     l_error := SQLERRM;
     write_msg(L_API_NAME,'EXCEPTION: '|| l_error);
END Run_Functions;

-------------------------------------------------------------------------------
-- NAME
--    Run_Functions
-- PURPOSE
--    External API to run all the function with in a single object.
-- HISTORY
-- 22-Aug_2003 dmvincen Created.
-------------------------------------------------------------------------------
PROCEDURE Run_Functions (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_arc_act_metric_used_by     IN VARCHAR2,
   p_act_metric_used_by_id      IN NUMBER
)
is
   L_API_NAME CONSTANT VARCHAR2(100) := 'RUN_FUNCTIONS';

  l_errbuf VARCHAR2(4000);
  l_retcode VARCHAR2(10);
  l_index number;
  l_object_list object_currency_table;
  l_current_date date := sysdate;
  l_default_currency VARCHAR2(15) := Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY;
begin

   savepoint sp_run_functions;

   x_return_status      := Fnd_Api.G_RET_STS_SUCCESS;

   l_index := l_object_list.count + 1;
   l_object_list(l_index).obj_type := p_arc_act_metric_used_by;
   l_object_list(l_index).obj_id := p_act_metric_used_by_id;

   run_functions(x_errbuf => l_errbuf,
                 x_retcode => l_retcode,
                 p_commit => FND_API.G_FALSE,
                 p_object_list => l_object_list,
                 p_current_date => l_current_date,
                 p_func_currency => l_default_currency);

   -- If any errors happen abort API.
   IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --COMMIT WORK;

   IF Fnd_Api.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO sp_run_functions;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded         =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_run_functions;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded         =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO sp_run_functions;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );

end run_functions;

-- NAME
--    Get_Met_Apport_Val
--
-- PURPOSE
--   Returns the Value of the Approtioned Metric
--
-- NOTES
--
-- HISTORY
-- 10/20/1999   ptendulk         Created.
--
PROCEDURE Get_Met_Apport_Val(
   p_obj_association_id          IN  NUMBER,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_apportioned_value           OUT NOCOPY NUMBER
)
IS
   l_return_status         VARCHAR2(1);
   CURSOR c_obj_det      IS
      SELECT master_object_type,
             master_object_id,
             using_object_type,
             using_object_id,
             TO_NUMBER(DECODE(usage_type,G_CREATED,100,G_USED_BY,
                       NVL(pct_of_cost_to_charge_used_by,0)))
                     pct_of_cost_to_charge_used_by,
             cost_frozen_flag
      FROM    ams_object_associations
      WHERE  object_association_id = p_obj_association_id ;
   CURSOR c_amt_met IS
      SELECT func_actual_value
      FROM    ams_act_metrics_all
      WHERE  activity_metric_origin_id = p_obj_association_id  ;
   l_obj_det_rec       c_obj_det%ROWTYPE ;
   l_amount          NUMBER ;
   l_apport_value      NUMBER ;
BEGIN
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Begin API Body
   --
   OPEN  c_obj_det ;
   FETCH c_obj_det INTO l_obj_det_rec ;
   CLOSE c_obj_det ;
--   If Cost frozen flag is 'Y' don't apportion Metric
   IF l_obj_det_rec.cost_frozen_flag = G_NOT_FROZEN THEN
      -- Call Proc to get the Value of the
      GetMetCatVal (
             x_return_status          => l_return_status,
             p_arc_act_metric_used_by => l_obj_det_rec.using_object_type,
             p_act_metric_used_by_id  => l_obj_det_rec.using_object_id,
             p_metric_category        => G_COST, --Apportioning only for Cost
             p_return_type             => G_ACTUAL, -- Return the Actual Value
             x_value                    => l_amount
                  )   ;
     IF l_return_status = Fnd_Api.G_RET_STS_SUCCESS THEN
        l_apport_value :=
              l_amount * l_obj_det_rec.pct_of_cost_to_charge_used_by/100 ;
     ELSE
          x_return_status := l_return_status ;
        RETURN;
     END IF;
   ELSE
      OPEN  c_amt_met;
     FETCH c_amt_met INTO l_apport_value ;
     CLOSE c_amt_met ;
   END IF   ;
   --
   -- Set Output Variables.
   --
   x_apportioned_value := l_apport_value ;
   --
   -- End API Body.
   --
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
END Get_Met_Apport_Val;

-- NAME
--    GetMetricCatVal
--
-- PURPOSE
--   Return the functional forecasted value, committed value, actual
--   value depending on Return type for a given metric.
--
-- NOTES
--
-- HISTORY
-- 10/13/1999   ptendulk         Created.
--
PROCEDURE GetMetCatVal (
   x_return_status             OUT NOCOPY VARCHAR2,
   p_arc_act_metric_used_by    IN  VARCHAR2,
   p_act_metric_used_by_id     IN  NUMBER,
   p_metric_category           IN  VARCHAR2,
   p_return_type               IN  VARCHAR2,
   x_value                     OUT NOCOPY NUMBER
)
IS
   CURSOR c_sum_metrics(l_metric_id IN NUMBER,
                        l_arc_act_metric_used_by VARCHAR2) IS
      SELECT metric_id
        FROM ams_metrics_all_b
       WHERE arc_metric_used_for_object = l_arc_act_metric_used_by
       START WITH metric_id = l_metric_id
     CONNECT BY PRIOR summary_metric_id = metric_id
       ORDER BY LEVEL DESC ;


   CURSOR c_cat_metrics(l_metric_category VARCHAR2,
                        l_arc_act_metric_used_by VARCHAR2,
                        l_act_metric_used_by_id NUMBER) IS
      SELECT act.activity_metric_id activity_metric_id,
             met.metric_id metric_id
        FROM ams_act_metrics_all act,ams_metrics_all_b met
       WHERE met.metric_id = act.metric_id
         AND act.arc_act_metric_used_by = l_arc_act_metric_used_by
         AND act.act_metric_used_by_id  = l_act_metric_used_by_id
         AND met.metric_category =  l_metric_category ;

   CURSOR c_amount(l_met_id IN NUMBER,
                   l_arc_act_metric_used_by VARCHAR2,
                   l_act_metric_used_by_id NUMBER) IS
      SELECT NVL(func_actual_value,0) func_actual_value,
               NVL(func_forecasted_value,0) func_forecasted_value,
             NVL(func_committed_value,0) func_committed_value
        FROM ams_act_metrics_all
       WHERE metric_id = l_met_id
         AND arc_act_metric_used_by = l_arc_act_metric_used_by
         AND act_metric_used_by_id  = l_act_metric_used_by_id ;

   l_cat_met_rec c_cat_metrics%ROWTYPE ;
   l_sum_met_rec c_sum_metrics%ROWTYPE ;
   l_amount_rec  c_amount%ROWTYPE ;
BEGIN
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Begin API Body.
   --
   -- Take the First Metric ID of all the Metrics attached to this Usage and of
   -- this class
   OPEN c_cat_metrics(p_metric_category,
                      p_arc_act_metric_used_by,
                      p_act_metric_used_by_id);
   FETCH c_cat_metrics INTO l_cat_met_rec;
   CLOSE c_cat_metrics ;

   -- This Cursor will Find out Summary Metric of all the metrics attached to
   -- this usage type (for e.g. Total Cost )
   OPEN c_sum_metrics(l_cat_met_rec.metric_id, p_arc_act_metric_used_by);
   FETCH c_sum_metrics INTO l_sum_met_rec;
   IF c_sum_metrics%NOTFOUND THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RETURN;
   END IF;
   CLOSE c_sum_metrics;

   -- Following Cursor will Find out the value for this summary metric and
   -- for this Usage
   -- ASSUMPTIONS : There will be only one Summary Metric(e.g. Total Cost)
   -- attached to one Usage(For e.g. Camp C1)
   OPEN  c_amount(l_sum_met_rec.metric_id,
                  p_arc_act_metric_used_by,
                  p_act_metric_used_by_id) ;
   FETCH c_amount INTO l_amount_rec ;
   CLOSE c_amount;

   --
   -- Set OUT values.
   --
   --   This amount is in Functional Currency Code
   IF p_return_type = G_ACTUAL THEN
        x_value := l_amount_rec.func_actual_value ;
   ELSIF p_return_type = G_FORECASTED THEN
        x_value := l_amount_rec.func_forecasted_value ;
   ELSIF p_return_type = G_COMMITTED THEN
        x_value := l_amount_rec.func_committed_value ;
   END IF;
   --
   -- End API Body.
   --
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     RETURN;
END GetMetCatVal;

--
-- NAME
--    Convert_Uom
--
-- PURPOSE
--    This Procedure will  call the Inventory API to convert Uom
--    It will return the calculated quantity (in UOM of to_uom_code )
--    All the Calculations to calculate Value of the metrics
--    are done in Base Uom defined for that Metric. So the First step before
--    calculation starts is to convert the UOM into Base UOM.
--    Once the Value is calculated it's converted back to the Original UOM
--    Activity Metric table will be updated with this UOM
-- NOTES
--
-- HISTORY
-- 09/30/1999     ptendulk            Created.
--
FUNCTION Convert_Uom(
   p_from_uom_code  IN  VARCHAR2,
   p_to_uom_code    IN  VARCHAR2,
   p_from_quantity  IN      NUMBER,
   p_precision      IN      NUMBER   DEFAULT NULL,
   p_from_uom_name  IN  VARCHAR2 DEFAULT NULL,
   p_to_uom_name    IN  VARCHAR2 DEFAULT NULL
)
RETURN NUMBER
IS
   l_to_quantity    NUMBER ;
BEGIN
   -- Call UOM Conversion API. Pass Item ID as 0 as the UOM is not attached to Item
   l_to_quantity := Inv_Convert.Inv_Um_Convert (
       item_id        => 0 ,      -- As This is Standard Conversion
         PRECISION    => p_precision,
         from_quantity=> p_from_quantity,
       from_unit      => p_from_uom_code,
       to_unit        => p_to_uom_code,
       from_name      => p_from_uom_name,
       to_name        => p_to_uom_name ) ;
    RETURN l_to_quantity ;
EXCEPTION
   WHEN OTHERS THEN
      l_to_quantity  := -1 ;
      RETURN l_to_quantity ;
END Convert_Uom;

--
-- NAME
--    check_object_status
--
-- PURPOSE
--   Check if the business object has been canceled.
--
-- NOTES
--
-- HISTORY
-- 08/16/2001  dmvincen  Created
--
PROCEDURE check_object_status(
   p_arc_act_metric_used_by IN VARCHAR2,
   p_act_metric_used_by_id IN NUMBER,
   x_is_canceled OUT NOCOPY VARCHAR2
)
IS
/**
   CURSOR c_camp(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_campaigns_all_b
      WHERE campaign_id = id
      AND status_code = G_CANCELLED;

   CURSOR c_csch(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_campaign_schedules_b
      WHERE schedule_id = id
      AND status_code = G_CANCELLED;

   CURSOR c_delv(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_deliverables_all_b
      WHERE deliverable_id = id
      AND status_code = G_CANCELLED;

   CURSOR c_eveh(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_event_headers_all_b
      WHERE event_header_id = id
      AND system_status_code = G_CANCELLED;

   CURSOR c_eveo(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_event_offers_all_b
      WHERE event_offer_id = id
      AND system_status_code IN (G_CANCELLED);
**/
   l_is_canceled VARCHAR2(1) := Fnd_Api.G_FALSE;

BEGIN
/**
   if p_arc_act_metric_used_by in (G_CAMP,G_RCAM) and
      G_CAMP_status_table.exists(p_act_metric_used_by_id) then
      l_is_canceled := g_CAMP_status_table(p_act_metric_used_by_id);
   elsif p_arc_act_metric_used_by = G_CSCH and
      G_CSCH_status_table.exists(p_act_metric_used_by_id) then
      l_is_canceled := g_CSCH_status_table(p_act_metric_used_by_id);
   elsif p_arc_act_metric_used_by = G_EVEH and
      G_EVEH_status_table.exists(p_act_metric_used_by_id) then
      l_is_canceled := g_EVEH_status_table(p_act_metric_used_by_id);
   elsif p_arc_act_metric_used_by in (G_EVEO,G_EONE) and
      G_EVEO_status_table.exists(p_act_metric_used_by_id) then
      l_is_canceled := g_EVEO_status_table(p_act_metric_used_by_id);
   else
      l_is_canceled := Fnd_Api.G_FALSE;
      IF p_arc_act_metric_used_by IN (G_RCAM, G_CAMP) THEN
         OPEN c_camp(p_act_metric_used_by_id);
         FETCH c_camp INTO l_is_canceled;
         CLOSE c_camp;

      ELSIF (p_arc_act_metric_used_by = G_CSCH) THEN
         OPEN c_csch(p_act_metric_used_by_id);
         FETCH c_csch INTO l_is_canceled;
         CLOSE c_csch;

      ELSIF (p_arc_act_metric_used_by = G_DELV) THEN
         OPEN c_delv(p_act_metric_used_by_id);
         FETCH c_delv INTO l_is_canceled;
         CLOSE c_delv;

      ELSIF (p_arc_act_metric_used_by = G_EVEH) THEN
         OPEN c_eveh(p_act_metric_used_by_id);
         FETCH c_eveh INTO l_is_canceled;
         CLOSE c_eveh;

      ELSIF p_arc_act_metric_used_by IN (G_EONE, G_EVEO) THEN
         OPEN c_eveo(p_act_metric_used_by_id);
         FETCH c_eveo INTO l_is_canceled;
         CLOSE c_eveo;

      END IF;

      if p_arc_act_metric_used_by in (G_CAMP,G_RCAM) then
         G_CAMP_status_table(p_act_metric_used_by_id) := l_is_canceled;
      elsif p_arc_act_metric_used_by = G_CSCH then
         G_CSCH_status_table(p_act_metric_used_by_id) := l_is_canceled;
      elsif p_arc_act_metric_used_by = G_EVEH then
         G_EVEH_status_table(p_act_metric_used_by_id) := l_is_canceled;
      elsif p_arc_act_metric_used_by in (G_EVEO,G_EONE) then
         G_EVEO_status_table(p_act_metric_used_by_id) := l_is_canceled;
      end if;
   end if;

   x_is_canceled := l_is_canceled;
**/
   x_is_canceled := get_object_details(p_arc_act_metric_used_by, p_act_metric_used_by_id).cancelled_flag;

END check_object_status;

-- NAME
--    UPDATE_VARIABLE
--
-- PURPOSE
--   Calculates the variable metrics based on multiplier metrics.
--   The indication to recalculate is when the multipliers last_update_date
--   is greater than the variable metrics last_calculated_date.
--   Added Forecasted_variable_value to ams_act_metrics_all.
--   The forecasted value is calculated by using the actual multiplier value
--   if non-null and non-zero, otherwise use the forecasted multiplier value.
--   The trans_actual_value for the variable metric is fixed and the actual
--   unit value (variable_value) is calculated by dividing trans_actual_value
--   by the actual multiplier value.  If the multiplier values are null then
--   the variable values are null.  If the multiplier actual value is zero
--   then the trans_actual_value is null.
--
-- NOTES
--
-- HISTORY
-- 11/15/2002  DMVINCEN  Created.
-- 08/21/2003  DMVINCEN  New logic for calculating.
--
PROCEDURE UPDATE_VARIABLE
        (x_errbuf       OUT NOCOPY   VARCHAR2,
         x_retcode      OUT NOCOPY   NUMBER,
         p_commit       IN    VARCHAR2 := Fnd_Api.G_TRUE,
         p_object_list  IN object_currency_table := Empty_object_currency_table,
         p_current_date IN date,
         p_func_currency IN varchar2
)
IS
   L_API_NAME CONSTANT VARCHAR2(100) := 'UPDATE_VARIABLE';

   CURSOR c_get_variable_metrics(l_func_currency_code varchar2) IS
   SELECT activity_metric_id,
          transaction_currency_code,
          functional_currency_code,
          actual_multiplier,
          forecast_multiplier,
          trans_actual_value,
          trans_forecasted_value,
          variable_value,
          forecasted_variable_value,
          LAST_CALCULATED_DATE
   FROM (
      SELECT a.activity_metric_id,
             a.transaction_currency_code,
             a.functional_currency_code,
             a.variable_value,
             a.forecasted_variable_value,
             a.trans_actual_value,
             a.trans_forecasted_value,
             a.last_calculated_date,
             a.dirty_flag,
             sum(c.trans_actual_value) actual_multiplier,
             sum(c.trans_forecasted_value) forecast_multiplier,
             max(c.last_update_date) last_update_date
      FROM ams_act_metrics_all a, ams_metrics_all_b b, ams_act_metrics_all c
      WHERE a.metric_id = b.metric_id
      AND b.accrual_type = G_VARIABLE
      AND a.arc_act_metric_used_by = c.arc_act_metric_used_by(+)
      AND a.act_metric_used_by_id = c.act_metric_used_by_id(+)
      AND c.metric_id = to_number(compute_using_function)
      GROUP BY a.activity_metric_id,
             a.transaction_currency_code,
             a.functional_currency_code,
             a.VARIABLE_VALUE,
             a.forecasted_variable_value,
             a.trans_actual_value,
             a.trans_forecasted_value,
             a.last_calculated_date,
             a.dirty_flag)
   WHERE last_update_date > nvl(last_calculated_date,last_update_date-1)
   OR functional_currency_code <> l_func_currency_code
   OR dirty_flag = G_IS_DIRTY;

   CURSOR c_get_variable_metrics_by_obj(l_func_currency_code varchar2,
              l_obj_type varchar2, l_obj_id number) is
   SELECT activity_metric_id,
          transaction_currency_code,
          functional_currency_code,
          actual_multiplier,
          forecast_multiplier,
          trans_actual_value,
          trans_forecasted_value,
          variable_value,
          forecasted_variable_value,
          LAST_CALCULATED_DATE
   FROM (
      SELECT a.activity_metric_id,
             a.transaction_currency_code,
             a.functional_currency_code,
             a.variable_value,
             a.forecasted_variable_value,
             a.trans_actual_value,
             a.trans_forecasted_value,
             a.last_calculated_date,
             a.dirty_flag,
             sum(c.trans_actual_value) actual_multiplier,
             sum(c.trans_forecasted_value) forecast_multiplier,
             max(c.last_update_date) last_update_date
      FROM ams_act_metrics_all a, ams_metrics_all_b b, ams_act_metrics_all c
      WHERE a.metric_id = b.metric_id
      AND b.accrual_type = G_VARIABLE
      AND a.arc_act_metric_used_by = l_obj_type
      AND a.act_metric_used_by_id = l_obj_id
      AND a.arc_act_metric_used_by = c.arc_act_metric_used_by(+)
      AND a.act_metric_used_by_id = c.act_metric_used_by_id(+)
      AND c.metric_id = to_number(compute_using_function)
      GROUP BY a.activity_metric_id,
             a.transaction_currency_code,
             a.functional_currency_code,
             a.VARIABLE_VALUE,
             a.forecasted_variable_value,
             a.trans_actual_value,
             a.trans_forecasted_value,
             a.last_calculated_date,
             a.dirty_flag)
   WHERE last_update_date > nvl(last_calculated_date,last_update_date-1)
   OR functional_currency_code <> l_func_currency_code
   OR dirty_flag = G_IS_DIRTY;


   l_count number;
   l_activity_metric_ids num_table_type;
   l_trans_currencies varchar2_table_type;
   l_func_currencies varchar2_table_type;
   l_actual_multipliers num_table_type;
   l_forecast_multipliers num_table_type;
   l_trans_actual_values num_table_type;
   l_trans_forecasted_values num_table_type;
   l_variable_values num_table_type;
   l_forecasted_variable_values num_table_type;
   l_LAST_CALCULATED_DATEs date_table_type;

   l_temp_activity_metric_ids num_table_type;
   l_temp_trans_currencies varchar2_table_type;
   l_temp_func_currencies varchar2_table_type;
   l_temp_actual_multipliers num_table_type;
   l_temp_forecast_multipliers num_table_type;
   l_temp_trans_actual_values num_table_type;
   l_temp_trans_forecasted_values num_table_type;
   l_temp_variable_values num_table_type;
   l_temp_forecasted_variable_val num_table_type;
   l_temp_LAST_CALCULATED_DATEs date_table_type;

   l_new_activity_metric_ids num_table_type;
   l_new_variable_values num_table_type;
   l_new_func_forecasted_values num_table_type;
   l_new_trans_forecasted_values num_table_type;
   l_new_func_currencies varchar2_table_type;
   l_new_days_since_last_refreshs num_table_type;
   l_new_last_calculated_dates date_table_type;
   l_new_func_actual_values num_table_type;
   l_new_forecast_variable_values num_table_type;

   l_current_date date := SYSDATE;
   l_func_currency_code varchar2(30) := Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY;
   l_return_status varchar2(10);
   l_first number;
   l_last number;

BEGIN
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'START: object_list count='||p_object_list.count);
   END IF;

   IF p_object_list.count > 0 THEN
      FOR l_index IN p_object_list.first..p_object_list.last
      LOOP
         OPEN c_get_variable_metrics_by_obj(l_func_currency_code,
              p_object_list(l_index).obj_type,p_object_list(l_index).obj_id);
         FETCH c_get_variable_metrics_by_obj BULK COLLECT INTO
            l_temp_activity_metric_ids,
            l_temp_trans_currencies,
            l_temp_func_currencies,
            l_temp_actual_multipliers,
            l_temp_forecast_multipliers,
            l_temp_trans_actual_values,
            l_temp_trans_forecasted_values,
            l_temp_variable_values,
            l_temp_forecasted_variable_val,
            l_temp_LAST_CALCULATED_DATEs;
         CLOSE c_get_variable_metrics_by_obj;
         IF l_temp_activity_metric_ids.count > 0 THEN
            FOR l_index2 IN l_temp_activity_metric_ids.first..l_temp_activity_metric_ids.last
            LOOP
               l_count := l_activity_metric_ids.count+1;
               l_activity_metric_ids(l_count) := l_temp_activity_metric_ids(l_index2);
               l_trans_currencies(l_count) := l_temp_trans_currencies(l_index2);
               l_func_currencies(l_count) := l_temp_func_currencies(l_index2);
               l_actual_multipliers(l_count) := l_temp_actual_multipliers(l_index2);
               l_forecast_multipliers(l_count) := l_temp_forecast_multipliers(l_index2);
               l_trans_actual_values(l_count) := l_temp_trans_actual_values(l_index2);
               l_trans_forecasted_values(l_count) := l_temp_trans_forecasted_values(l_index2);
               l_variable_values(l_count) := l_temp_variable_values(l_index2);
               l_forecasted_variable_values(l_count) := l_temp_forecasted_variable_val(l_index2);
               l_last_calculated_dates(l_count) := l_temp_last_calculated_dates(l_index2);
            END LOOP;
            l_temp_activity_metric_ids.delete;
            l_temp_trans_currencies.delete;
            l_temp_func_currencies.delete;
            l_temp_actual_multipliers.delete;
            l_temp_forecast_multipliers.delete;
            l_temp_trans_actual_values.delete;
            l_temp_trans_forecasted_values.delete;
            l_temp_variable_values.delete;
            l_temp_forecasted_variable_val.delete;
            l_temp_LAST_CALCULATED_DATEs.delete;
         END IF;
      END LOOP;
   ELSE
      OPEN c_get_variable_metrics(l_func_currency_code);
      FETCH c_get_variable_metrics BULK COLLECT INTO
            l_activity_metric_ids,
            l_trans_currencies,
            l_func_currencies,
            l_actual_multipliers,
            l_forecast_multipliers,
            l_trans_actual_values,
            l_trans_forecasted_values,
            l_variable_values,
            l_forecasted_variable_values,
            l_LAST_CALCULATED_DATEs;
      CLOSE c_get_variable_metrics;
   END IF;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'UPDATING: count='||l_activity_metric_ids.count);
   END IF;

   IF l_activity_metric_ids.count > 0 THEN
      FOR l_index IN l_activity_metric_ids.first..l_activity_metric_ids.last
      LOOP
         l_new_days_since_last_refreshs(l_index) :=
                  l_current_date - l_LAST_CALCULATED_DATEs(l_index);
         -- BUG3551174: Prevent divide by zero.
         IF l_actual_multipliers(l_index) is not null and
            l_actual_multipliers(l_index) <> 0 then
            l_new_variable_values(l_index) :=
               l_trans_actual_values(l_index) / l_actual_multipliers(l_index);
         ELSE
            l_new_variable_values(l_index) := NULL;
         END IF;

         IF l_forecasted_variable_values(l_index) is null THEN
            -- Calculate the forecasted unit value.
            IF l_forecast_multipliers(l_index) is not null AND
               l_forecast_multipliers(l_index) <> 0 THEN
               l_new_forecast_variable_values(l_index) :=
                  l_trans_forecasted_values(l_index) /
                    l_forecast_multipliers(l_index);
            ELSE
               l_new_forecast_variable_values(l_index) := null;
            END IF;
            l_new_trans_forecasted_values(l_index) :=
               l_trans_forecasted_values(l_index);
         ELSE
            -- Calculate the forecasted value.
            l_new_trans_forecasted_values(l_index) :=
                l_forecasted_variable_values(l_index) *
                l_forecast_multipliers(l_index);
            l_new_forecast_variable_values(l_index) :=
               l_forecasted_variable_values(l_index);
         END IF;

         IF l_trans_currencies(l_index) IS NOT NULL THEN
            l_new_func_currencies(l_index) := l_func_currency_code;
            ams_actmetric_pvt.Convert_Currency2 (
               x_return_status      => l_return_status,
               p_from_currency      => l_trans_currencies(l_index),
               p_to_currency        => l_new_func_currencies(l_index),
               p_conv_date          => l_current_date,
               p_from_amount        => l_trans_actual_values(l_index),
               x_to_amount          => l_new_func_actual_values(l_index),
               p_from_amount2       => l_new_trans_forecasted_values(l_index),
               x_to_amount2         => l_new_func_forecasted_values(l_index),
               p_round              => fnd_api.g_false);
         ELSE
            -- Variables only apply to costs and revenues.
            -- This code should never execute.
            l_new_func_currencies(l_index) := NULL;
            l_new_func_actual_values(l_index) := l_trans_actual_values(l_index);
            l_new_func_forecasted_values(l_index) := l_trans_forecasted_values(l_index);
         END IF;
      END LOOP;

      l_first := l_activity_metric_ids.first;
      LOOP
         EXIT WHEN l_first > l_activity_metric_ids.last;
         IF l_first + G_BATCH_SIZE + G_BATCH_PAD > l_activity_metric_ids.last THEN
            l_last := l_activity_metric_ids.last;
         ELSE
            l_last := l_first + G_BATCH_SIZE - 1;
         END IF;
         --FORALL l_index IN l_act_metric_ids.FIRST .. l_act_metric_ids.LAST
         FORALL l_index IN l_first .. l_last
            UPDATE ams_act_metrics_all
               SET last_calculated_date = l_current_date,
                   last_update_date = l_current_date,
                   object_version_number = object_version_number + 1,
                   functional_currency_code = l_new_func_currencies(l_index),
                   DAYS_SINCE_LAST_REFRESH = l_new_days_since_last_refreshs(l_index),
                   --trans_actual_value = l_new_trans_actual_values(l_index),
                   func_actual_value = l_new_func_actual_values(l_index),
                   func_forecasted_value = l_new_func_forecasted_values(l_index),
                   trans_forecasted_value = l_new_trans_forecasted_values(l_index),
                   variable_value = l_new_variable_values(l_index),
                   forecasted_variable_value =
                      l_new_forecast_variable_values(l_index),
                   dirty_flag = G_NOT_DIRTY
             WHERE activity_metric_id = l_activity_metric_ids(l_index);

         -- set the dirty flags for all summary and rollup parents.
         --FORALL l_index IN l_act_metric_ids.FIRST .. l_act_metric_ids.LAST
         FORALL l_index IN l_first .. l_last
             UPDATE ams_act_metrics_all
                SET dirty_flag = G_IS_DIRTY
              WHERE activity_metric_id IN
                 (SELECT rollup_to_metric FROM ams_act_metrics_all
                  WHERE activity_metric_id = l_activity_metric_ids(l_index)
                  UNION ALL
                  SELECT summarize_to_metric FROM ams_act_metrics_all
                  WHERE activity_metric_id = l_activity_metric_ids(l_index));
         l_first := l_last + 1;
         IF p_commit = FND_API.G_TRUE THEN
            COMMIT;
            IF AMS_DEBUG_MEDIUM_ON THEN
               write_msg(L_API_NAME, 'BATCH COMMIT: l_last='||l_last);
            END IF;
         END IF;
      END LOOP;

      l_activity_metric_ids.delete;
      l_trans_currencies.delete;
      l_func_currencies.delete;
      l_actual_multipliers.delete;
      l_forecast_multipliers.delete;
      l_trans_actual_values.delete;
      l_trans_forecasted_values.delete;
      l_variable_values.delete;
      l_forecasted_variable_values.delete;
      l_LAST_CALCULATED_DATEs.delete;
      l_new_activity_metric_ids.delete;
      l_new_variable_values.delete;
      l_new_func_forecasted_values.delete;
      l_new_trans_forecasted_values.delete;
      l_new_func_currencies.delete;
      l_new_days_since_last_refreshs.delete;
      l_new_last_calculated_dates.delete;
      l_new_func_actual_values.delete;
      l_new_forecast_variable_values.delete;
   END IF;
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'END');
   END IF;
END;

-------------------------------------------------------------------------------
-- NAME
--    Update_Variable
-- PURPOSE
--    External API to calculate variable metrics with in a single object.
-- HISTORY
-- 22-Aug_2003 dmvincen Created.
-------------------------------------------------------------------------------
PROCEDURE Update_Variable (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_arc_act_metric_used_by     IN VARCHAR2,
   p_act_metric_used_by_id      IN NUMBER
)
is
   L_API_NAME CONSTANT VARCHAR2(100) := 'UPDATE_VARIABLE';

  l_errbuf VARCHAR2(4000);
  l_retcode VARCHAR2(10);
  l_index number;
  l_object_list object_currency_table;
  l_current_date date := sysdate;
  l_default_currency VARCHAR2(15) := Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY;
begin

   savepoint sp_Update_Variable;

   x_return_status      := Fnd_Api.G_RET_STS_SUCCESS;

   l_index := l_object_list.count + 1;
   l_object_list(l_index).obj_type := p_arc_act_metric_used_by;
   l_object_list(l_index).obj_id := p_act_metric_used_by_id;

   Update_Variable(x_errbuf => l_errbuf,
                 x_retcode => l_retcode,
                 p_commit => FND_API.G_FALSE,
                 p_object_list => l_object_list,
                 p_current_date => l_current_date,
                 p_func_currency => l_default_currency);

   -- If any errors happen abort API.
   IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --COMMIT WORK;

   IF Fnd_Api.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO sp_Update_Variable;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded         =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_Update_Variable;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded         =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO sp_Update_Variable;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );

end Update_Variable;

-- NAME
--    get_object_details
--
-- PURPOSE
--   Get all useful details for an object.
--
-- NOTES
--
-- HISTORY
-- 09/30/2003  DMVINCEN Created.
--
FUNCTION get_object_details(p_object_type varchar2, p_object_id number)
return object_detail_type
is
  l_api_name varchar2(30) := 'GET_OBJECT_DETAILS';
  --check the parent campaign or program
  CURSOR c_check_campaign(l_act_metric_used_by_id NUMBER)
    return object_detail_type IS
    SELECT decode(rollup_type,G_RCAM,G_RCAM,G_CAMP), campaign_id, transaction_currency_code, G_RCAM, parent_campaign_id,
       decode(status_code, G_CANCELLED, Fnd_Api.G_TRUE, Fnd_Api.G_FALSE) cancelled_flag,
       upper(show_campaign_flag)
    FROM ams_campaigns_all_b
    WHERE campaign_id = l_act_metric_used_by_id;
--    AND UPPER(show_campaign_flag) = 'Y';

  CURSOR c_check_schedule (l_act_metric_used_by_id NUMBER)
    return object_detail_type IS
    SELECT G_CSCH, campaign_id, transaction_currency_code, G_CAMP, campaign_id,
       decode(status_code, G_CANCELLED, Fnd_Api.G_TRUE, Fnd_Api.G_FALSE) cancelled_flag,
       G_SHOW
    FROM ams_campaign_schedules_b
    WHERE schedule_id = l_act_metric_used_by_id;

  --check the event header
  -- BUG 3456849: Changed parent to be a program_id.
  CURSOR c_check_event_h(l_act_metric_used_by_id NUMBER)
    return object_detail_type IS
    SELECT G_EVEH, event_header_id, currency_code_tc, G_RCAM, program_id,
       decode(system_status_code, G_CANCELLED, Fnd_Api.G_TRUE, Fnd_Api.G_FALSE) cancelled_flag,
       G_SHOW
    FROM ams_event_headers_all_b
    WHERE event_header_id = l_act_metric_used_by_id;

  --check for the parent event
  CURSOR c_check_event_o(l_act_metric_used_by_id NUMBER)
    return object_detail_type IS
    SELECT event_object_type, event_offer_id, currency_code_tc,
       decode(parent_type,null,G_EVEH,parent_type) parent_type,
       decode(parent_type,null, event_header_id, parent_id) parent_id,
       decode(system_status_code, G_CANCELLED, Fnd_Api.G_TRUE, Fnd_Api.G_FALSE) cancelled_flag,
       G_SHOW
    FROM ams_event_offers_all_b
    WHERE event_offer_id = l_act_metric_used_by_id;

  CURSOR c_check_deliverable(l_act_metric_used_by_id       NUMBER)
    return object_detail_type IS
    SELECT G_DELV, deliverable_id, transaction_currency_code, NULL, NULL,
       decode(status_code, G_CANCELLED, Fnd_Api.G_TRUE, Fnd_Api.G_FALSE) cancelled_flag,
       G_SHOW
    FROM ams_deliverables_all_b
    WHERE deliverable_id = l_act_metric_used_by_id;

  CURSOR c_check_act_list(l_act_metric_used_by_id       NUMBER)
    return object_detail_type IS
    SELECT G_ALIST, act_list_header_id, Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY,
       NULL, NULL, Fnd_Api.G_FALSE cancelled_flag,
       G_SHOW
    FROM ams_act_lists
    WHERE act_list_header_id = l_act_metric_used_by_id;

   l_object_details object_detail_type;
   l_index number := 0;
   l_obj_index number := 0;
begin
/**
   IF G_OBJECT_CACHE.count > 0 then
      IF AMS_DEBUG_MEDIUM_ON THEN
       write_msg(L_API_NAME,'looking in cache for: '||p_object_type||'/'||p_object_id);
      END IF;
      for l_index in G_OBJECT_CACHE.first .. G_OBJECT_CACHE.last
      loop
         if G_OBJECT_CACHE(l_index).obj_type = p_object_type then
            if G_OBJECT_CACHE(l_index).object_table.EXISTS(p_object_id) then
               l_object_details := G_OBJECT_CACHE(l_index).object_table(p_object_id);
   IF AMS_DEBUG_MEDIUM_ON THEN
     write_msg(L_API_NAME,'object was cached: '||p_object_type||'/'||p_object_id);
   END IF;
               return l_object_details;
            end if;
            exit;
         end if;
      end loop;
   end if;

   IF AMS_DEBUG_MEDIUM_ON THEN
      write_msg(L_API_NAME,'object not cached: object'||p_object_type||'/'||p_object_id);
   END IF;
**/
   IF p_object_type in (G_CAMP, G_RCAM) THEN
      OPEN c_check_campaign (p_object_id);
      FETCH c_check_campaign INTO l_object_details;
      CLOSE c_check_campaign;
    -- schedule to campaign
    ELSIF p_object_type = G_CSCH THEN
      OPEN c_check_schedule (p_object_id);
      FETCH c_check_schedule INTO l_object_details;
      CLOSE c_check_schedule;
    -- Event Schedule to Event
    ELSIF p_object_type in (G_EVEO, G_EONE) THEN
      OPEN c_check_event_o (p_object_id);
      FETCH c_check_event_o INTO l_object_details;
      CLOSE c_check_event_o;
    -- Event to Program
    ELSIF p_object_type = G_EVEH THEN
      OPEN c_check_event_h (p_object_id);
      FETCH c_check_event_h INTO l_object_details;
      CLOSE c_check_event_h;
    -- One Off Event to Program
    ELSIF p_object_type = G_DELV THEN
      OPEN c_check_deliverable (p_object_id);
      FETCH c_check_deliverable INTO l_object_details;
      CLOSE c_check_deliverable;
    ELSIF p_object_type = G_ALIST THEN
      OPEN c_check_act_list (p_object_id);
      FETCH c_check_act_list INTO l_object_details;
      CLOSE c_check_act_list;
    END IF;
/**
   IF G_OBJECT_CACHE.count > 0 then
      for l_index in G_OBJECT_CACHE.first .. G_OBJECT_CACHE.last
      loop
         IF AMS_DEBUG_MEDIUM_ON THEN
          write_msg(L_API_NAME,'object cache type:'||G_OBJECT_CACHE(l_index).obj_type||
              ', count='||G_OBJECT_CACHE(l_index).object_table.count);
         END IF;
         if G_OBJECT_CACHE(l_index).obj_type = p_object_type then
            l_obj_index := l_index;
         IF AMS_DEBUG_MEDIUM_ON THEN
           write_msg(L_API_NAME,'found object type at: '||l_obj_index);
         END IF;
            exit;
         end if;
      end loop;
      l_obj_index := G_OBJECT_CACHE.last + 1;
   else
      l_obj_index := 1;
   end if;

   if G_OBJECT_CACHE.COUNT = 0 or l_obj_index > G_OBJECT_CACHE.last then
      IF AMS_DEBUG_MEDIUM_ON THEN
         write_msg(L_API_NAME,'adding new object type in cache:'||p_object_type);
      END IF;
      G_OBJECT_CACHE(l_obj_index).obj_type := p_object_type;
      G_OBJECT_CACHE(l_obj_index).object_table.delete;
   end if;
   G_OBJECT_CACHE(l_obj_index).object_table(p_object_id) := l_object_details;

   IF AMS_DEBUG_MEDIUM_ON THEN
      write_msg(L_API_NAME,'object_details.parent'||l_object_details.parent_type||'/'||l_object_details.parent_id);
   END IF;
**/
   return l_object_details;

end get_object_details;

procedure get_parent_object(p_obj_type varchar2, p_obj_id number,
     x_parent_obj_type out nocopy varchar2, x_parent_obj_id out nocopy number,
     x_show_flag out nocopy varchar2)
is
   l_object_details object_detail_type;
begin
   l_object_details := get_object_details(p_obj_type, p_obj_id);
   x_parent_obj_type := l_object_details.parent_type;
   x_parent_obj_id := l_object_details.parent_id;
   x_show_flag := l_object_details.show_flag;
end get_parent_object;

-- NAME
--    Get_Object_List
--
-- PURPOSE
--   Get objects to refresh, includes children and parents of given object.
--
-- NOTES
--
-- HISTORY
-- 11/15/2002  DMVINCEN Created.
-- 19-Mar-2003 choang   Bug 2853777 - Added DELV
-- 16-Dec-2003 dmvincen BUG 3322880 - Added ALIST
--
PROCEDURE Get_Object_List(p_arc_act_metric_used_by varchar2,
           p_act_metric_used_by_id number,
           x_return_status               OUT NOCOPY    VARCHAR2,
           x_msg_count                   OUT NOCOPY    NUMBER,
           x_msg_data                    OUT NOCOPY    VARCHAR2,
           x_object_list   OUT NOCOPY    object_currency_table
)
IS
   CURSOR c_get_program_family (l_act_metric_used_by_id number) IS
      SELECT campaign_id obj_id, G_RCAM obj_type,
         TRANSACTION_CURRENCY_CODE currency
      FROM ams_campaigns_all_b
      START WITH campaign_id = l_act_metric_used_by_id
      CONNECT BY campaign_id = PRIOR PARENT_CAMPAIGN_ID
      UNION ALL
      SELECT campaign_id obj_id,
         decode(rollup_type,G_RCAM,G_RCAM,G_CAMP) obj_type,
         TRANSACTION_CURRENCY_CODE currency
      FROM ams_campaigns_all_b
      WHERE parent_campaign_id = l_act_metric_used_by_id
      UNION ALL
      SELECT EVENT_HEADER_ID obj_id, G_EVEH obj_type, CURRENCY_CODE_TC currency
      FROM ams_event_headers_all_b
      WHERE PROGRAM_ID = l_act_metric_used_by_id
      UNION ALL
      SELECT EVENT_OFFER_ID obj_id, G_EONE obj_type, CURRENCY_CODE_TC currency
      FROM ams_event_offers_all_b
      WHERE parent_id = l_act_metric_used_by_id
      ORDER BY obj_type, obj_id;

   CURSOR c_get_campaign_family (l_act_metric_used_by_id number) IS
      SELECT campaign_id obj_id,
         decode(rollup_type,G_RCAM,G_RCAM,G_CAMP) obj_type,
         TRANSACTION_CURRENCY_CODE currency
      FROM ams_campaigns_all_b
      START WITH campaign_id = l_act_metric_used_by_id
      CONNECT BY campaign_id = PRIOR PARENT_CAMPAIGN_ID
      UNION ALL
      SELECT SCHEDULE_ID obj_id, G_CSCH obj_type,
         TRANSACTION_CURRENCY_CODE currency
      FROM ams_campaign_schedules_b
      WHERE CAMPAIGN_ID = l_act_metric_used_by_id
      ORDER BY obj_type, obj_id;

   CURSOR c_get_event_family (l_act_metric_used_by_id number) IS
      SELECT campaign_id obj_id, G_RCAM obj_type,
         TRANSACTION_CURRENCY_CODE currency
      FROM ams_campaigns_all_b
      START WITH campaign_id = (SELECT PROGRAM_ID FROM ams_event_headers_all_b
             WHERE event_header_id = l_act_metric_used_by_id)
      CONNECT BY campaign_id = PRIOR PARENT_CAMPAIGN_ID
      UNION ALL
      SELECT EVENT_HEADER_ID obj_id, G_EVEH obj_type, CURRENCY_CODE_TC currency
      FROM ams_event_headers_all_b
      WHERE EVENT_HEADER_ID = l_act_metric_used_by_id
      UNION ALL
      SELECT EVENT_OFFER_ID obj_id, G_EVEO obj_type, CURRENCY_CODE_TC currency
      FROM ams_event_offers_all_b
      WHERE EVENT_HEADER_ID = l_act_metric_used_by_id
      ORDER BY obj_type, obj_id;

   CURSOR c_get_csch_family (l_act_metric_used_by_id number) IS
      SELECT schedule_id obj_id, G_CSCH obj_type,TRANSACTION_CURRENCY_CODE currency
      FROM ams_campaign_schedules_b
      WHERE schedule_id = l_act_metric_used_by_id
      UNION ALL
      SELECT campaign_id obj_id,
          decode(rollup_type,G_RCAM,G_RCAM,G_CAMP) obj_type,
          TRANSACTION_CURRENCY_CODE currency
      FROM ams_campaigns_all_b
      START WITH campaign_id = (SELECT campaign_id FROM ams_campaign_schedules_b
             WHERE schedule_id = l_act_metric_used_by_id)
      CONNECT BY campaign_id = PRIOR PARENT_CAMPAIGN_ID
      ORDER BY obj_type, obj_id;

   CURSOR c_get_eveo_family (l_act_metric_used_by_id number) IS
      SELECT EVENT_OFFER_ID obj_id, G_EVEO obj_type, CURRENCY_CODE_TC currency
      FROM ams_event_offers_all_b
      WHERE EVENT_OFFER_ID = l_act_metric_used_by_id
      UNION ALL
      SELECT EVENT_HEADER_ID obj_id, G_EVEH obj_type, CURRENCY_CODE_TC currency
      FROM ams_event_headers_all_b
      WHERE EVENT_HEADER_ID = (SELECT event_header_id FROM ams_event_offers_all_b
            WHERE event_offer_id = l_act_metric_used_by_id)
      UNION ALL
      SELECT campaign_id obj_id, G_RCAM obj_type, TRANSACTION_CURRENCY_CODE currency
      FROM ams_campaigns_all_b
      START WITH campaign_id = (SELECT PROGRAM_ID FROM ams_event_headers_all_b
             WHERE event_header_id = (SELECT  event_header_id FROM ams_event_offers_all_b
             WHERE event_offer_id = l_act_metric_used_by_id))
      CONNECT BY campaign_id = PRIOR PARENT_CAMPAIGN_ID
      ORDER BY obj_type, obj_id;

   CURSOR c_get_eone_family (l_act_metric_used_by_id number) IS
      SELECT campaign_id obj_id, G_RCAM obj_type,
         TRANSACTION_CURRENCY_CODE currency
      FROM ams_campaigns_all_b
      START WITH campaign_id = (SELECT PARENT_ID FROM ams_event_offers_all_b
             WHERE event_offer_id = l_act_metric_used_by_id)
      CONNECT BY campaign_id = PRIOR PARENT_CAMPAIGN_ID
      UNION ALL
      SELECT event_offer_id obj_id, G_EONE obj_type, CURRENCY_CODE_TC currency
      FROM ams_event_offers_all_b
      WHERE event_offer_id = l_act_metric_used_by_id
      ORDER BY obj_type, obj_id;

   CURSOR c_get_deliv (p_deliverable_id NUMBER) IS
      SELECT deliverable_id obj_id, G_DELV obj_type, transaction_currency_code currency
      FROM   ams_deliverables_all_b
      WHERE  deliverable_id = p_deliverable_id;

   CURSOR c_get_act_list (p_act_list_header_id NUMBER) IS
      SELECT act_list_header_id obj_id, G_ALIST obj_type, Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY currency
      FROM   ams_act_lists
      WHERE  act_list_header_id = p_act_list_header_id;

/*** BUG2845365: Removed dialogue Components.
   CURSOR c_get_components(p_dialog_id NUMBER) IS
      SELECT dialog_id, G_DILG, NULL
      FROM AMS_DIALOGS_ALL_B
      WHERE dialog_id = p_dialog_id
      UNION ALL
      SELECT flow_component_id obj_id,component_type_code obj_type, NULL
      FROM ams_dlg_flow_comps_b
      WHERE dialog_id= p_dialog_id;
***** BUG2845365 *****/

   l_obj_ids num_table_type;
   l_obj_types varchar2_table_type;
   l_obj_currencies currency_code_table_type;
   l_obj_item object_currency_type;

/***** NOT REQUIRED *****
   l_is_locked VARCHAR2(1);
   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(2000);
****** NOT REQUIRED ****/

BEGIN
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF p_arc_act_metric_used_by = G_RCAM THEN
      OPEN c_get_program_family(p_act_metric_used_by_id);
      FETCH c_get_program_family BULK COLLECT INTO l_obj_ids, l_obj_types, l_obj_currencies;
      CLOSE c_get_program_family;
   ELSIF p_arc_act_metric_used_by = G_CAMP THEN
      OPEN c_get_campaign_family(p_act_metric_used_by_id);
      FETCH c_get_campaign_family BULK COLLECT INTO l_obj_ids, l_obj_types, l_obj_currencies;
      CLOSE c_get_campaign_family;
   ELSIF p_arc_act_metric_used_by = G_EVEH THEN
      OPEN c_get_event_family(p_act_metric_used_by_id);
      FETCH c_get_event_family BULK COLLECT INTO l_obj_ids, l_obj_types, l_obj_currencies;
      CLOSE c_get_event_family;
   ELSIF p_arc_act_metric_used_by = G_CSCH THEN
      OPEN c_get_csch_family(p_act_metric_used_by_id);
      FETCH c_get_csch_family BULK COLLECT INTO l_obj_ids, l_obj_types, l_obj_currencies;
      CLOSE c_get_csch_family;
   ELSIF p_arc_act_metric_used_by = G_EVEO THEN
      OPEN c_get_eveo_family(p_act_metric_used_by_id);
      FETCH c_get_eveo_family BULK COLLECT INTO l_obj_ids, l_obj_types, l_obj_currencies;
      CLOSE c_get_eveo_family;
   ELSIF p_arc_act_metric_used_by = G_EONE THEN
      OPEN c_get_eone_family(p_act_metric_used_by_id);
      FETCH c_get_eone_family BULK COLLECT INTO l_obj_ids, l_obj_types, l_obj_currencies;
      CLOSE c_get_eone_family;
   /***** BUG2845365: Removed Dialogue Components.
   ELSIF p_arc_act_metric_used_by = G_DILG THEN
      OPEN c_get_components(p_act_metric_used_by_id);
      FETCH c_get_components BULK COLLECT INTO l_obj_ids, l_obj_types, l_obj_currencies;
      CLOSE c_get_components;
   ****** BUG2845365 ******/
   ELSIF p_arc_act_metric_used_by = G_DELV THEN
      -- Use bulk collect as standard for this procedure
      -- in case deliverables implementation changes in
      -- the future.
      OPEN c_get_deliv (p_act_metric_used_by_id);
      FETCH c_get_deliv BULK COLLECT INTO l_obj_ids, l_obj_types, l_obj_currencies;
      CLOSE c_get_deliv;
   ELSIF p_arc_act_metric_used_by = G_ALIST THEN
      OPEN c_get_act_list (p_act_metric_used_by_id);
      FETCH c_get_act_list BULK COLLECT INTO l_obj_ids, l_obj_types, l_obj_currencies;
      CLOSE c_get_act_list;
   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_METR_INVALID_OBJECT');
         FND_MESSAGE.set_token('OBJTYPE', p_arc_act_metric_used_by);
         FND_MESSAGE.set_token('OBJID', p_act_metric_used_by_id);
         FND_MSG_PUB.add;
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   END IF;

   IF x_return_status = Fnd_Api.G_RET_STS_SUCCESS
      AND l_obj_ids.count > 0 THEN
      FOR l_index IN l_obj_ids.first .. l_obj_ids.last
      LOOP
         l_obj_item.obj_id := l_obj_ids(l_index);
         l_obj_item.obj_type := l_obj_types(l_index);
         l_obj_item.currency := l_obj_currencies(l_index);
/***** NOT REQUIRED *******
 ***** Locking is only required when created new metrics *****
          --Sunkumar Bug# 3106033
          IF l_obj_item.obj_id IS NOT NULL THEN
               l_is_locked := ams_actmetric_pvt.lock_object(
                  p_api_version            => 1 ,
                  p_init_msg_list          => Fnd_Api.G_FALSE,
                  p_arc_act_metric_used_by => l_obj_item.obj_type,
                  p_act_metric_used_by_id  => l_obj_item.obj_id,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data);

               IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
                  RAISE Fnd_Api.G_EXC_ERROR;
               ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
                  RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
               elsif l_is_locked = FND_API.G_FALSE THEN
                  -- the object needs to be lock by this process.
                  RAISE ams_utility_pvt.resource_locked;
               END IF;
         END IF;
****** NOT REQUIRED *******/

         x_object_list(l_index) := l_obj_item;
      END LOOP;
   END IF;

END GET_OBJECT_LIST;

PROCEDURE write_object_list(p_object_list in object_currency_table, p_output OUT NOCOPY varchar2 )
IS
BEGIN
IF p_object_list.COUNT  > 0 THEN
   FOR l_index IN p_object_list.FIRST..p_object_list.LAST
   LOOP
      p_output := p_output || p_object_list(l_index).obj_type
         ||'/'||p_object_list(l_index).obj_id||'/'||p_object_list(l_index).currency||'
';
   END LOOP;
END IF;
END;

/****** For development use only.  Removed for production. ******
PROCEDURE test_get_object_list(p_output out nocopy varchar2)
IS
l_object_list object_currency_table;
       l_return_status VARCHAR2(10);
       l_msg_count     NUMBER;
       l_msg_data      VARCHAR2(4000);
       l_RCAM_id NUMBER;
       l_camp_id number;
       l_csch_id number;
       l_eveh_id number;
       l_eveo_id number;
       l_eone_id number;
       l_output varchar2(4000);
BEGIN
SELECT campaign_id INTO l_RCAM_id FROM ams_campaigns_all_b
WHERE rollup_type = G_RCAM
AND parent_campaign_id IS NOT NULL
AND ROWNUM = 1;
Get_Object_List(G_RCAM,l_RCAM_id,
       l_return_status, l_msg_count, l_msg_data, l_object_list);
p_output := 'RCAM count='||l_object_list.COUNT||'
';
write_object_list(l_object_list,l_output);
p_output := p_output || l_output;
l_object_list.delete;

SELECT campaign_id into l_camp_id FROM ams_campaigns_all_b
WHERE PARENT_CAMPAIGN_ID IS NOT NULL
AND ROWNUM = 1;
Get_Object_List(G_CAMP,l_camp_id,
       l_return_status, l_msg_count, l_msg_data, l_object_list);
p_output := p_output || 'CAMP count='||l_object_list.COUNT||'
';
write_object_list(l_object_list,l_output);
p_output := p_output || l_output;
l_object_list.delete;

SELECT schedule_id INTO l_csch_id FROM ams_campaign_schedules_b
WHERE campaign_id IS NOT NULL
AND ROWNUM = 1;
Get_Object_List(G_CSCH,l_csch_id,
       l_return_status, l_msg_count, l_msg_data, l_object_list);
p_output := p_output || 'CSCH count='||l_object_list.COUNT||'
';
write_object_list(l_object_list,l_output);
p_output := p_output || l_output;
l_object_list.delete;

SELECT event_header_id INTO l_eveh_id FROM ams_event_headers_all_b
WHERE PROGRAM_ID IS NOT NULL
AND ROWNUM = 1;
Get_Object_List(G_EVEH,l_eveh_id,
       l_return_status, l_msg_count, l_msg_data, l_object_list);
p_output := p_output || 'EVEH count='||l_object_list.COUNT||'
';
write_object_list(l_object_list,l_output);
p_output := p_output || l_output;
l_object_list.delete;

SELECT event_offer_id INTO l_eveo_id FROM ams_event_offers_all_b
WHERE event_header_id IS NOT NULL
AND ROWNUM = 1;
Get_Object_List(G_EVEO,l_eveo_id,
       l_return_status, l_msg_count, l_msg_data, l_object_list);
p_output := p_output || 'EVEO count='||l_object_list.COUNT||'
';
write_object_list(l_object_list,l_output);
p_output := p_output || l_output;
l_object_list.delete;

SELECT event_offer_id INTO l_eone_id FROM ams_event_offers_all_b
WHERE PARENT_ID IS NOT NULL
AND ROWNUM = 1;
Get_Object_List(G_EONE,l_eone_id,
       l_return_status, l_msg_count, l_msg_data, l_object_list);
p_output := p_output || 'EONE count='||l_object_list.COUNT||'
';
write_object_list(l_object_list,l_output);
p_output := p_output || l_output;
l_object_list.delete;

END test_get_object_list;
****** For development only.  Removed for production. *******/


-- NAME
--    UPDATE_HISTORY
--
-- PURPOSE
--   Record historical data for activity metrics.
--
-- NOTES
--
-- HISTORY
-- 11/29/2001  DMVINCEN  Created.
-- 12/14/2001  DMVINCEN  Added delta tracking.
-- 02/06/2002  DMVINCEN  BUG2214496: delta calculations fix.
--
PROCEDURE Update_History(p_commit IN VARCHAR2)
IS
   L_API_NAME CONSTANT VARCHAR2(100) := 'UPDATE_HISTORY';

   CURSOR c_get_act_metric_hst IS
      SELECT ACT_MET_HST_ID,
         a.ACTIVITY_METRIC_ID,
         a.LAST_UPDATE_DATE,
         a.LAST_UPDATED_BY,
         a.CREATION_DATE,
         a.CREATED_BY,
         a.LAST_UPDATE_LOGIN,
         a.OBJECT_VERSION_NUMBER,
         a.ACT_METRIC_USED_BY_ID,
         a.ARC_ACT_METRIC_USED_BY,
         a.APPLICATION_ID,
         a.METRIC_ID,
         a.TRANSACTION_CURRENCY_CODE,
         a.TRANS_FORECASTED_VALUE,
         a.TRANS_COMMITTED_VALUE,
         a.TRANS_ACTUAL_VALUE,
         a.FUNCTIONAL_CURRENCY_CODE,
         a.FUNC_FORECASTED_VALUE,
         a.FUNC_COMMITTED_VALUE,
         a.DIRTY_FLAG,
         a.FUNC_ACTUAL_VALUE,
         a.LAST_CALCULATED_DATE,
         a.VARIABLE_VALUE,
         a.COMPUTED_USING_FUNCTION_VALUE,
         a.METRIC_UOM_CODE,
         a.ORG_ID,
         a.DIFFERENCE_SINCE_LAST_CALC,
         a.ACTIVITY_METRIC_ORIGIN_ID,
         a.ARC_ACTIVITY_METRIC_ORIGIN,
         a.DAYS_SINCE_LAST_REFRESH,
         a.SUMMARIZE_TO_METRIC,
         a.ROLLUP_TO_METRIC,
         a.SCENARIO_ID,
         a.ATTRIBUTE_CATEGORY,
         a.ATTRIBUTE1,
         a.ATTRIBUTE2,
         a.ATTRIBUTE3,
         a.ATTRIBUTE4,
         a.ATTRIBUTE5,
         a.ATTRIBUTE6,
         a.ATTRIBUTE7,
         a.ATTRIBUTE8,
         a.ATTRIBUTE9,
         a.ATTRIBUTE10,
         a.ATTRIBUTE11,
         a.ATTRIBUTE12,
         a.ATTRIBUTE13,
         a.ATTRIBUTE14,
         a.ATTRIBUTE15,
         a.DESCRIPTION,
         a.ACT_METRIC_DATE,
         a.ARC_FUNCTION_USED_BY,
         a.FUNCTION_USED_BY_ID,
         a.PURCHASE_REQ_RAISED_FLAG,
         a.SENSITIVE_DATA_FLAG,
         a.BUDGET_ID,
         a.FORECASTED_VARIABLE_VALUE,
         a.HIERARCHY_ID,
         a.PUBLISHED_FLAG,
         a.PRE_FUNCTION_NAME,
         a.POST_FUNCTION_NAME,
         a.START_NODE,
         a.FROM_LEVEL,
         a.TO_LEVEL,
         a.FROM_DATE,
         a.TO_DATE,
         a.AMOUNT1,
         a.AMOUNT2,
         a.AMOUNT3,
         a.PERCENT1,
         a.PERCENT2,
         a.PERCENT3,
         a.STATUS_CODE,
         a.ACTION_CODE,
         a.METHOD_CODE,
         a.BASIS_YEAR,
         a.EX_START_NODE,
         a.HIERARCHY_TYPE,
         a.DEPEND_ACT_METRIC,
         b.FUNC_FORECASTED_DELTA,
         b.FUNC_ACTUAL_DELTA
         FROM ams_act_metrics_all a, ams_act_metric_hst b
         WHERE b.activity_metric_id = a.activity_metric_id
         AND trunc(a.last_update_date) = trunc(b.last_update_date)
         AND a.last_update_date > b.last_update_date
         AND b.last_update_date =
            (SELECT MAX(last_update_date)
             FROM ams_act_metric_hst c
             WHERE c.activity_metric_id = b.activity_metric_id)
         ;

   l_ACT_MET_HST_ID num_table_type;
   l_ACTIVITY_METRIC_ID num_table_type;
   l_LAST_UPDATE_DATE date_table_type;
   l_LAST_UPDATED_BY num_table_type;
   l_CREATION_DATE date_table_type;
   l_CREATED_BY num_table_type;
   l_LAST_UPDATE_LOGIN num_table_type;
   l_OBJECT_VERSION_NUMBER num_table_type;
   l_ACT_METRIC_USED_BY_ID num_table_type;
   l_ARC_ACT_METRIC_USED_BY varchar2_table_type;
   l_APPLICATION_ID num_table_type;
   l_METRIC_ID num_table_type;
   l_TRANSACTION_CURRENCY_CODE varchar2_table_type;
   l_TRANS_FORECASTED_VALUE num_table_type;
   l_TRANS_COMMITTED_VALUE num_table_type;
   l_TRANS_ACTUAL_VALUE num_table_type;
   l_FUNCTIONAL_CURRENCY_CODE varchar2_table_type;
   l_FUNC_FORECASTED_VALUE num_table_type;
   l_FUNC_COMMITTED_VALUE num_table_type;
   l_DIRTY_FLAG varchar2_table_type;
   l_FUNC_ACTUAL_VALUE num_table_type;
   l_LAST_CALCULATED_DATE varchar2_table_type;
   l_VARIABLE_VALUE num_table_type;
   l_COMPUTED_USING_FUNCTION_VALU num_table_type;
   l_METRIC_UOM_CODE varchar2_table_type;
   l_ORG_ID num_table_type;
   l_DIFFERENCE_SINCE_LAST_CALC num_table_type;
   l_ACTIVITY_METRIC_ORIGIN_ID num_table_type;
   l_ARC_ACTIVITY_METRIC_ORIGIN varchar2_table_type;
   l_DAYS_SINCE_LAST_REFRESH num_table_type;
   l_SUMMARIZE_TO_METRIC num_table_type;
   l_ROLLUP_TO_METRIC num_table_type;
   l_SCENARIO_ID num_table_type;
   l_ATTRIBUTE_CATEGORY varchar2_table_type;
   l_ATTRIBUTE1 varchar2_table_type;
   l_ATTRIBUTE2 varchar2_table_type;
   l_ATTRIBUTE3 varchar2_table_type;
   l_ATTRIBUTE4 varchar2_table_type;
   l_ATTRIBUTE5 varchar2_table_type;
   l_ATTRIBUTE6 varchar2_table_type;
   l_ATTRIBUTE7 varchar2_table_type;
   l_ATTRIBUTE8 varchar2_table_type;
   l_ATTRIBUTE9 varchar2_table_type;
   l_ATTRIBUTE10 varchar2_table_type;
   l_ATTRIBUTE11 varchar2_table_type;
   l_ATTRIBUTE12 varchar2_table_type;
   l_ATTRIBUTE13 varchar2_table_type;
   l_ATTRIBUTE14 varchar2_table_type;
   l_ATTRIBUTE15 varchar2_table_type;
--   l_SECURITY_GROUP_ID num_table_type;
   l_FUNC_FORECASTED_DELTA num_table_type;
   l_FUNC_ACTUAL_DELTA num_table_type;
   l_DESCRIPTION varchar2_table_type;
   l_ACT_METRIC_DATE date_table_type;
   l_ARC_FUNCTION_USED_BY varchar2_table_type;
   l_FUNCTION_USED_BY_ID num_table_type;
   l_PURCHASE_REQ_RAISED_FLAG varchar2_table_type;
   l_SENSITIVE_DATA_FLAG varchar2_table_type;
   l_BUDGET_ID num_table_type;
   l_FORECASTED_VARIABLE_VALUE num_table_type;
   l_HIERARCHY_ID num_table_type;
   l_PUBLISHED_FLAG varchar2_table_type;
   l_PRE_FUNCTION_NAME varchar2_table_type;
   l_POST_FUNCTION_NAME varchar2_table_type;
   l_START_NODE num_table_type;
   l_FROM_LEVEL num_table_type;
   l_TO_LEVEL num_table_type;
   l_FROM_DATE date_table_type;
   l_TO_DATE date_table_type;
   l_AMOUNT1 num_table_type;
   l_AMOUNT2 num_table_type;
   l_AMOUNT3 num_table_type;
   l_PERCENT1 num_table_type;
   l_PERCENT2 num_table_type;
   l_PERCENT3 num_table_type;
   l_STATUS_CODE varchar2_table_type;
   l_ACTION_CODE varchar2_table_type;
   l_METHOD_CODE varchar2_table_type;
   l_BASIS_YEAR num_table_type;
   l_EX_START_NODE varchar2_table_type;
   l_HIERARCHY_TYPE varchar2_table_type;
   l_DEPEND_ACT_METRIC num_table_type;

         l_count NUMBER;
         l_count1 number;
         l_today DATE := SYSDATE;

   CURSOR c_get_deleted_today IS
      SELECT act_met_hst_id
      FROM ams_act_metric_hst a
      WHERE NOT EXISTS (SELECT 'x' FROM ams_act_metrics_all b
            WHERE a.activity_metric_id = b.activity_metric_id)
      AND last_update_date =
            (SELECT MAX(c.last_update_date)
            FROM ams_act_metric_hst c
            WHERE c.activity_metric_id = a.activity_metric_id)
      AND trunc(last_update_date) = trunc(l_today)
      AND (NVL(func_actual_value,0) <> 0 OR NVL(func_forecasted_value,0) <> 0);

BEGIN

   -- Create new history for items last updated prior to today.
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'BEGIN');
   END IF;

   INSERT INTO ams_act_metric_hst
       (ACT_MET_HST_ID,
         ACTIVITY_METRIC_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         OBJECT_VERSION_NUMBER,
         ACT_METRIC_USED_BY_ID,
         ARC_ACT_METRIC_USED_BY,
         APPLICATION_ID,
         METRIC_ID,
         TRANSACTION_CURRENCY_CODE,
         TRANS_FORECASTED_VALUE,
         TRANS_COMMITTED_VALUE,
         TRANS_ACTUAL_VALUE,
         FUNCTIONAL_CURRENCY_CODE,
         FUNC_FORECASTED_VALUE,
         FUNC_COMMITTED_VALUE,
         DIRTY_FLAG,
         FUNC_ACTUAL_VALUE,
         LAST_CALCULATED_DATE,
         VARIABLE_VALUE,
         COMPUTED_USING_FUNCTION_VALUE,
         METRIC_UOM_CODE,
         ORG_ID,
         DIFFERENCE_SINCE_LAST_CALC,
         ACTIVITY_METRIC_ORIGIN_ID,
         ARC_ACTIVITY_METRIC_ORIGIN,
         DAYS_SINCE_LAST_REFRESH,
         SUMMARIZE_TO_METRIC,
         ROLLUP_TO_METRIC,
         SCENARIO_ID,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         DESCRIPTION,
         ACT_METRIC_DATE,
         ARC_FUNCTION_USED_BY,
         FUNCTION_USED_BY_ID,
         PURCHASE_REQ_RAISED_FLAG,
         SENSITIVE_DATA_FLAG,
         BUDGET_ID,
         FORECASTED_VARIABLE_VALUE,
         HIERARCHY_ID,
         PUBLISHED_FLAG,
         PRE_FUNCTION_NAME,
         POST_FUNCTION_NAME,
         START_NODE,
         FROM_LEVEL,
         TO_LEVEL,
         FROM_DATE,
         TO_DATE,
         AMOUNT1,
         AMOUNT2,
         AMOUNT3,
         PERCENT1,
         PERCENT2,
         PERCENT3,
         STATUS_CODE,
         ACTION_CODE,
         METHOD_CODE,
         BASIS_YEAR,
         EX_START_NODE,
         HIERARCHY_TYPE,
         DEPEND_ACT_METRIC,
         FUNC_FORECASTED_DELTA,
         FUNC_ACTUAL_DELTA)
    SELECT AMS_ACT_METRIC_HST_S.NEXTVAL,
         a.ACTIVITY_METRIC_ID,
         a.LAST_UPDATE_DATE,
         a.LAST_UPDATED_BY,
         a.CREATION_DATE,
         a.CREATED_BY,
         a.LAST_UPDATE_LOGIN,
         a.OBJECT_VERSION_NUMBER,
         a.ACT_METRIC_USED_BY_ID,
         a.ARC_ACT_METRIC_USED_BY,
         a.APPLICATION_ID,
         a.METRIC_ID,
         a.TRANSACTION_CURRENCY_CODE,
         a.TRANS_FORECASTED_VALUE,
         a.TRANS_COMMITTED_VALUE,
         a.TRANS_ACTUAL_VALUE,
         a.FUNCTIONAL_CURRENCY_CODE,
         a.FUNC_FORECASTED_VALUE,
         a.FUNC_COMMITTED_VALUE,
         a.DIRTY_FLAG,
         a.FUNC_ACTUAL_VALUE,
         a.LAST_CALCULATED_DATE,
         a.VARIABLE_VALUE,
         a.COMPUTED_USING_FUNCTION_VALUE,
         a.METRIC_UOM_CODE,
         a.ORG_ID,
         a.DIFFERENCE_SINCE_LAST_CALC,
         a.ACTIVITY_METRIC_ORIGIN_ID,
         a.ARC_ACTIVITY_METRIC_ORIGIN,
         a.DAYS_SINCE_LAST_REFRESH,
         a.SUMMARIZE_TO_METRIC,
         a.ROLLUP_TO_METRIC,
         a.SCENARIO_ID,
         a.ATTRIBUTE_CATEGORY,
         a.ATTRIBUTE1,
         a.ATTRIBUTE2,
         a.ATTRIBUTE3,
         a.ATTRIBUTE4,
         a.ATTRIBUTE5,
         a.ATTRIBUTE6,
         a.ATTRIBUTE7,
         a.ATTRIBUTE8,
         a.ATTRIBUTE9,
         a.ATTRIBUTE10,
         a.ATTRIBUTE11,
         a.ATTRIBUTE12,
         a.ATTRIBUTE13,
         a.ATTRIBUTE14,
         a.ATTRIBUTE15,
         a.DESCRIPTION,
         a.ACT_METRIC_DATE,
         a.ARC_FUNCTION_USED_BY,
         a.FUNCTION_USED_BY_ID,
         a.PURCHASE_REQ_RAISED_FLAG,
         a.SENSITIVE_DATA_FLAG,
         a.BUDGET_ID,
         a.FORECASTED_VARIABLE_VALUE,
         a.HIERARCHY_ID,
         a.PUBLISHED_FLAG,
         a.PRE_FUNCTION_NAME,
         a.POST_FUNCTION_NAME,
         a.START_NODE,
         a.FROM_LEVEL,
         a.TO_LEVEL,
         a.FROM_DATE,
         a.TO_DATE,
         a.AMOUNT1,
         a.AMOUNT2,
         a.AMOUNT3,
         a.PERCENT1,
         a.PERCENT2,
         a.PERCENT3,
         a.STATUS_CODE,
         a.ACTION_CODE,
         a.METHOD_CODE,
         a.BASIS_YEAR,
         a.EX_START_NODE,
         a.HIERARCHY_TYPE,
         a.DEPEND_ACT_METRIC,
         NVL(a.FUNC_FORECASTED_VALUE,0) - NVL(b.FUNC_FORECASTED_VALUE,0),
         NVL(a.FUNC_ACTUAL_VALUE,0) - NVL(b.FUNC_ACTUAL_VALUE,0)
         FROM ams_act_metrics_all a, ams_act_metric_hst b
         WHERE a.activity_metric_id = b.activity_metric_id
         AND b.last_update_date =
            (SELECT MAX(last_update_date)
             FROM ams_act_metric_hst c
             WHERE c.activity_metric_id = a.activity_metric_id)
         AND TRUNC(a.last_update_date) > TRUNC(b.last_update_date)
         ;
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'INSERTED EXISTING METRICS: '||SQL%ROWCOUNT);
   END IF;

   IF SQL%ROWCOUNT > 0 AND p_commit = FND_API.G_TRUE THEN
      COMMIT;
      IF AMS_DEBUG_HIGH_ON THEN
         write_msg(L_API_NAME, 'COMMIT');
      END IF;
   END IF;


-- Insert new activity metrics.
  INSERT INTO ams_act_metric_hst
       (ACT_MET_HST_ID,
         ACTIVITY_METRIC_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         OBJECT_VERSION_NUMBER,
         ACT_METRIC_USED_BY_ID,
         ARC_ACT_METRIC_USED_BY,
         APPLICATION_ID,
         METRIC_ID,
         TRANSACTION_CURRENCY_CODE,
         TRANS_FORECASTED_VALUE,
         TRANS_COMMITTED_VALUE,
         TRANS_ACTUAL_VALUE,
         FUNCTIONAL_CURRENCY_CODE,
         FUNC_FORECASTED_VALUE,
         FUNC_COMMITTED_VALUE,
         DIRTY_FLAG,
         FUNC_ACTUAL_VALUE,
         LAST_CALCULATED_DATE,
         VARIABLE_VALUE,
         COMPUTED_USING_FUNCTION_VALUE,
         METRIC_UOM_CODE,
         ORG_ID,
         DIFFERENCE_SINCE_LAST_CALC,
         ACTIVITY_METRIC_ORIGIN_ID,
         ARC_ACTIVITY_METRIC_ORIGIN,
         DAYS_SINCE_LAST_REFRESH,
         SUMMARIZE_TO_METRIC,
         ROLLUP_TO_METRIC,
         SCENARIO_ID,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         DESCRIPTION,
         ACT_METRIC_DATE,
         ARC_FUNCTION_USED_BY,
         FUNCTION_USED_BY_ID,
         PURCHASE_REQ_RAISED_FLAG,
         SENSITIVE_DATA_FLAG,
         BUDGET_ID,
         FORECASTED_VARIABLE_VALUE,
         HIERARCHY_ID,
         PUBLISHED_FLAG,
         PRE_FUNCTION_NAME,
         POST_FUNCTION_NAME,
         START_NODE,
         FROM_LEVEL,
         TO_LEVEL,
         FROM_DATE,
         TO_DATE,
         AMOUNT1,
         AMOUNT2,
         AMOUNT3,
         PERCENT1,
         PERCENT2,
         PERCENT3,
         STATUS_CODE,
         ACTION_CODE,
         METHOD_CODE,
         BASIS_YEAR,
         EX_START_NODE,
         HIERARCHY_TYPE,
         DEPEND_ACT_METRIC,
         FUNC_FORECASTED_DELTA,
         FUNC_ACTUAL_DELTA)
    SELECT AMS_ACT_METRIC_HST_S.NEXTVAL,
         a.ACTIVITY_METRIC_ID,
         a.LAST_UPDATE_DATE,
         a.LAST_UPDATED_BY,
         a.CREATION_DATE,
         a.CREATED_BY,
         a.LAST_UPDATE_LOGIN,
         a.OBJECT_VERSION_NUMBER,
         a.ACT_METRIC_USED_BY_ID,
         a.ARC_ACT_METRIC_USED_BY,
         a.APPLICATION_ID,
         a.METRIC_ID,
         a.TRANSACTION_CURRENCY_CODE,
         a.TRANS_FORECASTED_VALUE,
         a.TRANS_COMMITTED_VALUE,
         a.TRANS_ACTUAL_VALUE,
         a.FUNCTIONAL_CURRENCY_CODE,
         a.FUNC_FORECASTED_VALUE,
         a.FUNC_COMMITTED_VALUE,
         a.DIRTY_FLAG,
         a.FUNC_ACTUAL_VALUE,
         a.LAST_CALCULATED_DATE,
         a.VARIABLE_VALUE,
         a.COMPUTED_USING_FUNCTION_VALUE,
         a.METRIC_UOM_CODE,
         a.ORG_ID,
         a.DIFFERENCE_SINCE_LAST_CALC,
         a.ACTIVITY_METRIC_ORIGIN_ID,
         a.ARC_ACTIVITY_METRIC_ORIGIN,
         a.DAYS_SINCE_LAST_REFRESH,
         a.SUMMARIZE_TO_METRIC,
         a.ROLLUP_TO_METRIC,
         a.SCENARIO_ID,
         a.ATTRIBUTE_CATEGORY,
         a.ATTRIBUTE1,
         a.ATTRIBUTE2,
         a.ATTRIBUTE3,
         a.ATTRIBUTE4,
         a.ATTRIBUTE5,
         a.ATTRIBUTE6,
         a.ATTRIBUTE7,
         a.ATTRIBUTE8,
         a.ATTRIBUTE9,
         a.ATTRIBUTE10,
         a.ATTRIBUTE11,
         a.ATTRIBUTE12,
         a.ATTRIBUTE13,
         a.ATTRIBUTE14,
         a.ATTRIBUTE15,
         a.DESCRIPTION,
         a.ACT_METRIC_DATE,
         a.ARC_FUNCTION_USED_BY,
         a.FUNCTION_USED_BY_ID,
         a.PURCHASE_REQ_RAISED_FLAG,
         a.SENSITIVE_DATA_FLAG,
         a.BUDGET_ID,
         a.FORECASTED_VARIABLE_VALUE,
         a.HIERARCHY_ID,
         a.PUBLISHED_FLAG,
         a.PRE_FUNCTION_NAME,
         a.POST_FUNCTION_NAME,
         a.START_NODE,
         a.FROM_LEVEL,
         a.TO_LEVEL,
         a.FROM_DATE,
         a.TO_DATE,
         a.AMOUNT1,
         a.AMOUNT2,
         a.AMOUNT3,
         a.PERCENT1,
         a.PERCENT2,
         a.PERCENT3,
         a.STATUS_CODE,
         a.ACTION_CODE,
         a.METHOD_CODE,
         a.BASIS_YEAR,
         a.EX_START_NODE,
         a.HIERARCHY_TYPE,
         a.DEPEND_ACT_METRIC,
         -- BUG2214496: Initialize to original value.
         a.FUNC_FORECASTED_VALUE,
         a.FUNC_ACTUAL_VALUE
         FROM ams_act_metrics_all a
         WHERE NOT EXISTS (SELECT 'x' FROM ams_act_metric_hst b
                  WHERE a.activity_metric_id = b.activity_metric_id);
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'INSERTED new metrics: '|| SQL%ROWCOUNT);
   END IF;

   IF SQL%ROWCOUNT > 0 AND p_commit = FND_API.G_TRUE THEN
      COMMIT;
      IF AMS_DEBUG_HIGH_ON THEN
         write_msg(L_API_NAME, 'COMMIT');
      END IF;
   END IF;

   -- Collect all items last recorded today but values have been updated again.
   OPEN c_get_act_metric_hst;
   FETCH c_get_act_metric_hst
         BULK COLLECT INTO
         l_ACT_MET_HST_ID,
         l_ACTIVITY_METRIC_ID,
         l_LAST_UPDATE_DATE,
         l_LAST_UPDATED_BY,
         l_CREATION_DATE,
         l_CREATED_BY,
         l_LAST_UPDATE_LOGIN,
         l_OBJECT_VERSION_NUMBER,
         l_ACT_METRIC_USED_BY_ID,
         l_ARC_ACT_METRIC_USED_BY,
         l_APPLICATION_ID,
         l_METRIC_ID,
         l_TRANSACTION_CURRENCY_CODE,
         l_TRANS_FORECASTED_VALUE,
         l_TRANS_COMMITTED_VALUE,
         l_TRANS_ACTUAL_VALUE,
         l_FUNCTIONAL_CURRENCY_CODE,
         l_FUNC_FORECASTED_VALUE,
         l_FUNC_COMMITTED_VALUE,
         l_DIRTY_FLAG,
         l_FUNC_ACTUAL_VALUE,
         l_LAST_CALCULATED_DATE,
         l_VARIABLE_VALUE,
         l_COMPUTED_USING_FUNCTION_VALU,
         l_METRIC_UOM_CODE,
         l_ORG_ID,
         l_DIFFERENCE_SINCE_LAST_CALC,
         l_ACTIVITY_METRIC_ORIGIN_ID,
         l_ARC_ACTIVITY_METRIC_ORIGIN,
         l_DAYS_SINCE_LAST_REFRESH,
         l_SUMMARIZE_TO_METRIC,
         l_ROLLUP_TO_METRIC,
         l_SCENARIO_ID,
         l_ATTRIBUTE_CATEGORY,
         l_ATTRIBUTE1,
         l_ATTRIBUTE2,
         l_ATTRIBUTE3,
         l_ATTRIBUTE4,
         l_ATTRIBUTE5,
         l_ATTRIBUTE6,
         l_ATTRIBUTE7,
         l_ATTRIBUTE8,
         l_ATTRIBUTE9,
         l_ATTRIBUTE10,
         l_ATTRIBUTE11,
         l_ATTRIBUTE12,
         l_ATTRIBUTE13,
         l_ATTRIBUTE14,
         l_ATTRIBUTE15,
         l_DESCRIPTION,
         l_ACT_METRIC_DATE,
         l_ARC_FUNCTION_USED_BY,
         l_FUNCTION_USED_BY_ID,
         l_PURCHASE_REQ_RAISED_FLAG,
         l_SENSITIVE_DATA_FLAG,
         l_BUDGET_ID,
         l_FORECASTED_VARIABLE_VALUE,
         l_HIERARCHY_ID,
         l_PUBLISHED_FLAG,
         l_PRE_FUNCTION_NAME,
         l_POST_FUNCTION_NAME,
         l_START_NODE,
         l_FROM_LEVEL,
         l_TO_LEVEL,
         l_FROM_DATE,
         l_TO_DATE,
         l_AMOUNT1,
         l_AMOUNT2,
         l_AMOUNT3,
         l_PERCENT1,
         l_PERCENT2,
         l_PERCENT3,
         l_STATUS_CODE,
         l_ACTION_CODE,
         l_METHOD_CODE,
         l_BASIS_YEAR,
         l_EX_START_NODE,
         l_HIERARCHY_TYPE,
         l_DEPEND_ACT_METRIC,
         l_FUNC_FORECASTED_DELTA,
         l_FUNC_ACTUAL_DELTA;
   CLOSE c_get_act_metric_hst;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME,'UPDATE repeat updates selected: '||l_act_met_hst_id.COUNT);
   END IF;

   -- If any items returned, bulk update.
   IF l_ACT_MET_HST_ID.COUNT > 0 THEN

      FORALL l_count IN l_ACT_MET_HST_ID.FIRST .. l_ACT_MET_HST_ID.LAST
         UPDATE ams_act_metric_hst
         SET LAST_UPDATE_DATE = l_LAST_UPDATE_DATE(l_count),
            LAST_UPDATED_BY = l_LAST_UPDATED_BY(l_count),
            CREATION_DATE = l_CREATION_DATE(l_count),
            CREATED_BY = l_CREATED_BY(l_count),
            LAST_UPDATE_LOGIN = l_LAST_UPDATE_LOGIN(l_count),
            OBJECT_VERSION_NUMBER = l_OBJECT_VERSION_NUMBER(l_count),
            ACT_METRIC_USED_BY_ID = l_ACT_METRIC_USED_BY_ID(l_count),
            ARC_ACT_METRIC_USED_BY = l_ARC_ACT_METRIC_USED_BY(l_count),
            APPLICATION_ID = l_APPLICATION_ID(l_count),
            METRIC_ID = l_METRIC_ID(l_count),
            TRANSACTION_CURRENCY_CODE = l_TRANSACTION_CURRENCY_CODE(l_count),
            TRANS_FORECASTED_VALUE = l_TRANS_FORECASTED_VALUE(l_count),
            TRANS_COMMITTED_VALUE = l_TRANS_COMMITTED_VALUE(l_count),
            TRANS_ACTUAL_VALUE = l_TRANS_ACTUAL_VALUE(l_count),
            FUNCTIONAL_CURRENCY_CODE = l_FUNCTIONAL_CURRENCY_CODE(l_count),
            FUNC_FORECASTED_VALUE = l_FUNC_FORECASTED_VALUE(l_count),
            FUNC_COMMITTED_VALUE = l_FUNC_COMMITTED_VALUE(l_count),
            DIRTY_FLAG = l_DIRTY_FLAG(l_count),
            FUNC_ACTUAL_VALUE = l_FUNC_ACTUAL_VALUE(l_count),
            LAST_CALCULATED_DATE = l_LAST_CALCULATED_DATE(l_count),
            VARIABLE_VALUE = l_VARIABLE_VALUE(l_count),
            COMPUTED_USING_FUNCTION_VALUE = l_COMPUTED_USING_FUNCTION_VALU(l_count),
            METRIC_UOM_CODE = l_METRIC_UOM_CODE(l_count),
            ORG_ID = l_ORG_ID(l_count),
            DIFFERENCE_SINCE_LAST_CALC = l_DIFFERENCE_SINCE_LAST_CALC(l_count),
            ACTIVITY_METRIC_ORIGIN_ID = l_ACTIVITY_METRIC_ORIGIN_ID(l_count),
            ARC_ACTIVITY_METRIC_ORIGIN = l_ARC_ACTIVITY_METRIC_ORIGIN(l_count),
            DAYS_SINCE_LAST_REFRESH = l_DAYS_SINCE_LAST_REFRESH(l_count),
            SUMMARIZE_TO_METRIC = l_SUMMARIZE_TO_METRIC(l_count),
            ROLLUP_TO_METRIC = l_ROLLUP_TO_METRIC(l_count),
            SCENARIO_ID = l_SCENARIO_ID(l_count),
            ATTRIBUTE_CATEGORY = l_ATTRIBUTE_CATEGORY(l_count),
            ATTRIBUTE1 = l_ATTRIBUTE1(l_count),
            ATTRIBUTE2 = l_ATTRIBUTE2(l_count),
            ATTRIBUTE3 = l_ATTRIBUTE3(l_count),
            ATTRIBUTE4 = l_ATTRIBUTE4(l_count),
            ATTRIBUTE5 = l_ATTRIBUTE5(l_count),
            ATTRIBUTE6 = l_ATTRIBUTE6(l_count),
            ATTRIBUTE7 = l_ATTRIBUTE7(l_count),
            ATTRIBUTE8 = l_ATTRIBUTE8(l_count),
            ATTRIBUTE9 = l_ATTRIBUTE9(l_count),
            ATTRIBUTE10 = l_ATTRIBUTE10(l_count),
            ATTRIBUTE11 = l_ATTRIBUTE11(l_count),
            ATTRIBUTE12 = l_ATTRIBUTE12(l_count),
            ATTRIBUTE13 = l_ATTRIBUTE13(l_count),
            ATTRIBUTE14 = l_ATTRIBUTE14(l_count),
            ATTRIBUTE15 = l_ATTRIBUTE15(l_count),
            DESCRIPTION = l_DESCRIPTION(l_count),
            ACT_METRIC_DATE = l_ACT_METRIC_DATE(l_count),
            ARC_FUNCTION_USED_BY = l_ARC_FUNCTION_USED_BY(l_count),
            FUNCTION_USED_BY_ID = l_FUNCTION_USED_BY_ID(l_count),
            PURCHASE_REQ_RAISED_FLAG = l_PURCHASE_REQ_RAISED_FLAG(l_count),
            SENSITIVE_DATA_FLAG = l_SENSITIVE_DATA_FLAG(l_count),
            BUDGET_ID = l_BUDGET_ID(l_count),
            FORECASTED_VARIABLE_VALUE = l_FORECASTED_VARIABLE_VALUE(l_count),
            HIERARCHY_ID = l_HIERARCHY_ID(l_count),
            PUBLISHED_FLAG = l_PUBLISHED_FLAG(l_count),
            PRE_FUNCTION_NAME = l_PRE_FUNCTION_NAME(l_count),
            POST_FUNCTION_NAME = l_POST_FUNCTION_NAME(l_count),
            START_NODE = l_START_NODE(l_count),
            FROM_LEVEL = l_FROM_LEVEL(l_count),
            TO_LEVEL = l_TO_LEVEL(l_count),
            FROM_DATE = l_FROM_DATE(l_count),
            TO_DATE = l_TO_DATE(l_count),
            AMOUNT1 = l_AMOUNT1(l_count),
            AMOUNT2 = l_AMOUNT2(l_count),
            AMOUNT3 = l_AMOUNT3(l_count),
            PERCENT1 = l_PERCENT1(l_count),
            PERCENT2 = l_PERCENT2(l_count),
            PERCENT3 = l_PERCENT3(l_count),
            STATUS_CODE = l_STATUS_CODE(l_count),
            ACTION_CODE = l_ACTION_CODE(l_count),
            METHOD_CODE = l_METHOD_CODE(l_count),
            BASIS_YEAR = l_BASIS_YEAR(l_count),
            EX_START_NODE = l_EX_START_NODE(l_count),
            HIERARCHY_TYPE = l_HIERARCHY_TYPE(l_count),
            DEPEND_ACT_METRIC = l_DEPEND_ACT_METRIC(l_count),
             -- BUG2214496: Wrap values with NVL.
             FUNC_FORECASTED_DELTA = NVL(l_FUNC_FORECASTED_DELTA(l_count),0) +
                     NVL(l_FUNC_FORECASTED_VALUE(l_count),0) -
                     NVL(FUNC_FORECASTED_VALUE,0),
             FUNC_ACTUAL_DELTA = NVL(l_FUNC_ACTUAL_DELTA(l_count),0) +
                     NVL(l_FUNC_ACTUAL_VALUE(l_count),0) -
                     NVL(FUNC_ACTUAL_VALUE,0)
         WHERE act_met_hst_id = l_ACT_MET_HST_ID(l_count);

         l_ACT_MET_HST_ID.delete;
         l_ACTIVITY_METRIC_ID.delete;
         l_LAST_UPDATE_DATE.delete;
         l_LAST_UPDATED_BY.delete;
         l_CREATION_DATE.delete;
         l_CREATED_BY.delete;
         l_LAST_UPDATE_LOGIN.delete;
         l_OBJECT_VERSION_NUMBER.delete;
         l_ACT_METRIC_USED_BY_ID.delete;
         l_ARC_ACT_METRIC_USED_BY.delete;
         l_APPLICATION_ID.delete;
         l_METRIC_ID.delete;
         l_TRANSACTION_CURRENCY_CODE.delete;
         l_TRANS_FORECASTED_VALUE.delete;
         l_TRANS_COMMITTED_VALUE.delete;
         l_TRANS_ACTUAL_VALUE.delete;
         l_FUNCTIONAL_CURRENCY_CODE.delete;
         l_FUNC_FORECASTED_VALUE.delete;
         l_FUNC_COMMITTED_VALUE.delete;
         l_DIRTY_FLAG.delete;
         l_FUNC_ACTUAL_VALUE.delete;
         l_LAST_CALCULATED_DATE.delete;
         l_VARIABLE_VALUE.delete;
         l_COMPUTED_USING_FUNCTION_VALU.delete;
         l_METRIC_UOM_CODE.delete;
         l_ORG_ID.delete;
         l_DIFFERENCE_SINCE_LAST_CALC.delete;
         l_ACTIVITY_METRIC_ORIGIN_ID.delete;
         l_ARC_ACTIVITY_METRIC_ORIGIN.delete;
         l_DAYS_SINCE_LAST_REFRESH.delete;
         l_SUMMARIZE_TO_METRIC.delete;
         l_ROLLUP_TO_METRIC.delete;
         l_SCENARIO_ID.delete;
         l_ATTRIBUTE_CATEGORY.delete;
         l_ATTRIBUTE1.delete;
         l_ATTRIBUTE2.delete;
         l_ATTRIBUTE3.delete;
         l_ATTRIBUTE4.delete;
         l_ATTRIBUTE5.delete;
         l_ATTRIBUTE6.delete;
         l_ATTRIBUTE7.delete;
         l_ATTRIBUTE8.delete;
         l_ATTRIBUTE9.delete;
         l_ATTRIBUTE10.delete;
         l_ATTRIBUTE11.delete;
         l_ATTRIBUTE12.delete;
         l_ATTRIBUTE13.delete;
         l_ATTRIBUTE14.delete;
         l_ATTRIBUTE15.delete;
         l_DESCRIPTION.delete;
         l_ACT_METRIC_DATE.delete;
         l_ARC_FUNCTION_USED_BY.delete;
         l_FUNCTION_USED_BY_ID.delete;
         l_PURCHASE_REQ_RAISED_FLAG.delete;
         l_SENSITIVE_DATA_FLAG.delete;
         l_BUDGET_ID.delete;
         l_FORECASTED_VARIABLE_VALUE.delete;
         l_HIERARCHY_ID.delete;
         l_PUBLISHED_FLAG.delete;
         l_PRE_FUNCTION_NAME.delete;
         l_POST_FUNCTION_NAME.delete;
         l_START_NODE.delete;
         l_FROM_LEVEL.delete;
         l_TO_LEVEL.delete;
         l_FROM_DATE.delete;
         l_TO_DATE.delete;
         l_AMOUNT1.delete;
         l_AMOUNT2.delete;
         l_AMOUNT3.delete;
         l_PERCENT1.delete;
         l_PERCENT2.delete;
         l_PERCENT3.delete;
         l_STATUS_CODE.delete;
         l_ACTION_CODE.delete;
         l_METHOD_CODE.delete;
         l_BASIS_YEAR.delete;
         l_EX_START_NODE.delete;
         l_HIERARCHY_TYPE.delete;
         l_DEPEND_ACT_METRIC.delete;
         l_FUNC_FORECASTED_DELTA.DELETE;
         l_FUNC_ACTUAL_DELTA.DELETE;
   END IF;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'UPDATED repeat updates: count='||SQL%ROWCOUNT);
   END IF;

   IF SQL%ROWCOUNT > 0 AND p_commit = FND_API.G_TRUE THEN
      COMMIT;
      IF AMS_DEBUG_HIGH_ON THEN
         write_msg(L_API_NAME, 'COMMIT');
      END IF;
   END IF;

   OPEN c_get_deleted_today;
   FETCH c_get_deleted_today
         BULK COLLECT INTO l_ACT_MET_HST_ID;
   CLOSE c_get_deleted_today;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'Deleted before today selected: '||l_ACT_MET_HST_ID.COUNT);
   END IF;

   IF l_ACT_MET_HST_ID.COUNT > 0 THEN
      FORALL l_count IN l_ACT_MET_HST_ID.FIRST .. l_ACT_MET_HST_ID.LAST
         UPDATE ams_act_metric_hst
         SET LAST_UPDATE_DATE = SYSDATE,
             TRANS_FORECASTED_VALUE = 0,
             TRANS_COMMITTED_VALUE = 0,
             TRANS_ACTUAL_VALUE = 0,
             FUNC_FORECASTED_VALUE = 0,
             FUNC_COMMITTED_VALUE = 0,
             FUNC_ACTUAL_VALUE = 0,
             -- BUG2214496: Wrap values with NVL.
             FUNC_FORECASTED_DELTA = NVL(FUNC_FORECASTED_DELTA,0) -
                                     NVL(FUNC_FORECASTED_VALUE,0),
             FUNC_ACTUAL_DELTA = NVL(FUNC_ACTUAL_DELTA,0) -
                                 NVL(FUNC_ACTUAL_VALUE,0)
         WHERE act_met_hst_id = l_ACT_MET_HST_ID(l_count);
      l_ACT_MET_HST_ID.DELETE;

   END IF;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'Deleted today UPDATED: '||SQL%ROWCOUNT);
   END IF;

   IF SQL%ROWCOUNT > 0 AND p_commit = FND_API.G_TRUE THEN
      COMMIT;
      IF AMS_DEBUG_HIGH_ON THEN
         write_msg(L_API_NAME, 'COMMIT');
      END IF;
   END IF;

  INSERT INTO ams_act_metric_hst
       (ACT_MET_HST_ID,
         ACTIVITY_METRIC_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         OBJECT_VERSION_NUMBER,
         ACT_METRIC_USED_BY_ID,
         ARC_ACT_METRIC_USED_BY,
         APPLICATION_ID,
         METRIC_ID,
         TRANSACTION_CURRENCY_CODE,
         TRANS_FORECASTED_VALUE,
         TRANS_COMMITTED_VALUE,
         TRANS_ACTUAL_VALUE,
         FUNCTIONAL_CURRENCY_CODE,
         FUNC_FORECASTED_VALUE,
         FUNC_COMMITTED_VALUE,
         DIRTY_FLAG,
         FUNC_ACTUAL_VALUE,
         LAST_CALCULATED_DATE,
         VARIABLE_VALUE,
         COMPUTED_USING_FUNCTION_VALUE,
         METRIC_UOM_CODE,
         ORG_ID,
         DIFFERENCE_SINCE_LAST_CALC,
         ACTIVITY_METRIC_ORIGIN_ID,
         ARC_ACTIVITY_METRIC_ORIGIN,
         DAYS_SINCE_LAST_REFRESH,
         SUMMARIZE_TO_METRIC,
         ROLLUP_TO_METRIC,
         SCENARIO_ID,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         DESCRIPTION,
         ACT_METRIC_DATE,
         ARC_FUNCTION_USED_BY,
         FUNCTION_USED_BY_ID,
         PURCHASE_REQ_RAISED_FLAG,
         SENSITIVE_DATA_FLAG,
         BUDGET_ID,
         FORECASTED_VARIABLE_VALUE,
         HIERARCHY_ID,
         PUBLISHED_FLAG,
         PRE_FUNCTION_NAME,
         POST_FUNCTION_NAME,
         START_NODE,
         FROM_LEVEL,
         TO_LEVEL,
         FROM_DATE,
         TO_DATE,
         AMOUNT1,
         AMOUNT2,
         AMOUNT3,
         PERCENT1,
         PERCENT2,
         PERCENT3,
         STATUS_CODE,
         ACTION_CODE,
         METHOD_CODE,
         BASIS_YEAR,
         EX_START_NODE,
         HIERARCHY_TYPE,
         DEPEND_ACT_METRIC,
         FUNC_FORECASTED_DELTA,
         FUNC_ACTUAL_DELTA)
    SELECT AMS_ACT_METRIC_HST_S.NEXTVAL,
         a.ACTIVITY_METRIC_ID,
         l_today,
         a.LAST_UPDATED_BY,
         a.CREATION_DATE,
         a.CREATED_BY,
         a.LAST_UPDATE_LOGIN,
         a.OBJECT_VERSION_NUMBER+1,
         a.ACT_METRIC_USED_BY_ID,
         a.ARC_ACT_METRIC_USED_BY,
         a.APPLICATION_ID,
         a.METRIC_ID,
         a.TRANSACTION_CURRENCY_CODE,
         0,
         0,
         0,
         a.FUNCTIONAL_CURRENCY_CODE,
         0,
         0,
         a.DIRTY_FLAG,
         0,
         a.LAST_CALCULATED_DATE,
         0,
         0,
         a.METRIC_UOM_CODE,
         a.ORG_ID,
         a.DIFFERENCE_SINCE_LAST_CALC,
         a.ACTIVITY_METRIC_ORIGIN_ID,
         a.ARC_ACTIVITY_METRIC_ORIGIN,
         a.DAYS_SINCE_LAST_REFRESH,
         a.SUMMARIZE_TO_METRIC,
         a.ROLLUP_TO_METRIC,
         a.SCENARIO_ID,
         a.ATTRIBUTE_CATEGORY,
         a.ATTRIBUTE1,
         a.ATTRIBUTE2,
         a.ATTRIBUTE3,
         a.ATTRIBUTE4,
         a.ATTRIBUTE5,
         a.ATTRIBUTE6,
         a.ATTRIBUTE7,
         a.ATTRIBUTE8,
         a.ATTRIBUTE9,
         a.ATTRIBUTE10,
         a.ATTRIBUTE11,
         a.ATTRIBUTE12,
         a.ATTRIBUTE13,
         a.ATTRIBUTE14,
         a.ATTRIBUTE15,
         a.DESCRIPTION,
         a.ACT_METRIC_DATE,
         a.ARC_FUNCTION_USED_BY,
         a.FUNCTION_USED_BY_ID,
         a.PURCHASE_REQ_RAISED_FLAG,
         a.SENSITIVE_DATA_FLAG,
         a.BUDGET_ID,
         0,
         a.HIERARCHY_ID,
         a.PUBLISHED_FLAG,
         a.PRE_FUNCTION_NAME,
         a.POST_FUNCTION_NAME,
         a.START_NODE,
         a.FROM_LEVEL,
         a.TO_LEVEL,
         a.FROM_DATE,
         a.TO_DATE,
         a.AMOUNT1,
         a.AMOUNT2,
         a.AMOUNT3,
         a.PERCENT1,
         a.PERCENT2,
         a.PERCENT3,
         a.STATUS_CODE,
         a.ACTION_CODE,
         a.METHOD_CODE,
         a.BASIS_YEAR,
         a.EX_START_NODE,
         a.HIERARCHY_TYPE,
         a.DEPEND_ACT_METRIC,
         -NVL(a.FUNC_FORECASTED_VALUE,0),
         -NVL(a.FUNC_ACTUAL_VALUE,0)
      FROM ams_act_metric_hst a
      WHERE NOT EXISTS (SELECT 'x' FROM ams_act_metrics_all b
            WHERE a.activity_metric_id = b.activity_metric_id)
      AND last_update_date =
            (SELECT MAX(c.last_update_date)
            FROM ams_act_metric_hst c
            WHERE c.activity_metric_id = a.activity_metric_id)
      AND last_update_date < TRUNC(l_today)
      AND (NVL(func_actual_value,0) <> 0 OR NVL(func_forecasted_value,0) <> 0);

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'Inserted delete before today: '||SQL%ROWCOUNT);
   END IF;

   IF SQL%ROWCOUNT > 0 AND p_commit = FND_API.G_TRUE THEN
      COMMIT;
      IF AMS_DEBUG_HIGH_ON THEN
         write_msg(L_API_NAME, 'COMMIT');
      END IF;
   END IF;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'COMPLETED');
   END IF;

END Update_History;

-- NAME
--    push
--
-- PURPOSE
--   Stack support for formula calculations.
--   Stores the forecasted and actual value on the stack.
--
-- NOTES
--
-- HISTORY
-- 08/21/2003  DMVINCEN  Created.
--
procedure pop(x_forecasted_value out nocopy number, x_actual_value out nocopy number)
is
  l_index number;
begin
   l_index := g_stack.count;
   if (g_stack.exists(l_index)) then
      x_forecasted_value := g_stack(l_index).forecasted_value;
      x_actual_value := g_stack(l_index).actual_value;
      g_stack.delete(l_index);
   else
      x_forecasted_value := null;
      x_actual_value := null;
   end if;
   IF AMS_DEBUG_MEDIUM_ON THEN
      write_msg('POP', 'l_index='||l_index||', forecast='||x_forecasted_value||', actual='||x_actual_value);
   END IF;
end pop;

-- NAME
--    push
--
-- PURPOSE
--   Stack support for formula calculations.
--   Stores the forecasted and actual value on the stack.
--
-- NOTES
--
-- HISTORY
-- 08/21/2003  DMVINCEN  Created.
--
procedure push(p_forecasted_value number, p_actual_value number)
is
  l_index number;
begin
   l_index := g_stack.count + 1;
   IF AMS_DEBUG_MEDIUM_ON THEN
      write_msg('PUSH', 'l_index='||l_index||', forecast='||p_forecasted_value||', actual='||p_actual_value);
   END IF;
   g_stack(l_index).forecasted_value := p_forecasted_value;
   g_stack(l_index).actual_value := p_actual_value;
end push;

-- NAME
--    apply
--
-- PURPOSE
--   Stack support for formula calculations.
--   Applies an operator to the top two values on the stack.
--   Stack operation is applied as postfix: 'a b -' or  infix: 'a - b'.
--   When pushing the values on the stack A is pushed first, and b
--   is on the top of the stack.
--
-- NOTES
--
-- HISTORY
-- 08/21/2003  DMVINCEN  Created.
--
procedure apply(p_operator varchar2)
is
  l_forecasted_value_a number;
  l_forecasted_value_b number;
  l_new_forecasted_value number;
  l_actual_value_a number;
  l_actual_value_b number;
  l_new_actual_value number;
begin
   pop(l_forecasted_value_b,l_actual_value_b);
   pop(l_forecasted_value_a,l_actual_value_a);
   if p_operator = G_PLUS then
      l_new_forecasted_value := l_forecasted_value_a + l_forecasted_value_b;
      l_new_actual_value := l_actual_value_a + l_actual_value_b;
   elsif p_operator = G_MINUS then
      l_new_forecasted_value := l_forecasted_value_a - l_forecasted_value_b;
      l_new_actual_value := l_actual_value_a - l_actual_value_b;
   elsif p_operator = G_TIMES then
      l_new_forecasted_value := l_forecasted_value_a * l_forecasted_value_b;
      l_new_actual_value := l_actual_value_a * l_actual_value_b;
   elsif p_operator = G_DIVIDE then
      if l_forecasted_value_b = 0 then
         l_new_forecasted_value := null;
      else
         l_new_forecasted_value := l_forecasted_value_a / l_forecasted_value_b;
      end if;
      if l_actual_value_b = 0 then
         l_new_actual_value := null;
      else
         l_new_actual_value := l_actual_value_a / l_actual_value_b;
      end if;
   else
      null; -- error
   end if;
   IF AMS_DEBUG_MEDIUM_ON THEN
      write_msg('APPLY', 'forecasted: '||l_new_forecasted_value||'='||l_forecasted_value_a||' '||p_operator||' '||l_forecasted_value_b);
      write_msg('APPLY', 'actual: '||l_new_actual_value||'='||l_actual_value_a||' '||p_operator||' '||l_actual_value_b);
   END IF;
   push(l_new_forecasted_value,l_new_actual_value);
end apply;

-- NAME
--    stack_count
--
-- PURPOSE
--   Return the size of the stack.
--
-- NOTES
--
-- HISTORY
-- 08/21/2003  DMVINCEN  Created.
--
FUNCTION stack_count
return number
is
begin
   return G_STACK.count;
end stack_count;

-- NAME
--    pop
--
-- PURPOSE
--   Return the top items on the stack and delete.
--
-- NOTES
--
-- HISTORY
-- 08/21/2003  DMVINCEN  Created.
--
procedure clear_stack
is
begin
   G_STACK.delete;
end clear_stack;

-- NAME
--    Update_formulas
--
-- PURPOSE
--   Compute formula metrics.
--
-- NOTES
--
-- HISTORY
-- 08/21/2003  DMVINCEN  Created.
--
PROCEDURE Update_formulas(
         x_errbuf       OUT NOCOPY   VARCHAR2,
         x_retcode      OUT NOCOPY   NUMBER,
         p_commit       IN VARCHAR2 := Fnd_Api.G_TRUE,
         p_object_list  IN object_currency_table := Empty_object_currency_table,
         p_current_date IN date,
         p_func_currency IN varchar2
)
IS
   L_API_NAME CONSTANT VARCHAR2(100) := 'UPDATE_FORMULAS';

   TYPE act_metric_formula_type is record (
     activity_metric_id number,
     metric_id number,
     arc_act_metric_used_by varchar2(30),
     act_metric_used_by_id number,
     last_calculated_date date,
     display_type varchar2(30)
   );

   TYPE act_metric_formula_table is table
     of act_metric_formula_type INDEX BY BINARY_INTEGER;

   cursor c_get_dirty_formulas
     return act_metric_formula_type is
     select a.activity_metric_id, a.metric_id ,
            a.arc_act_metric_used_by, a.act_metric_used_by_id,
            a.last_calculated_date, b.display_type
     from ams_act_metrics_all a, ams_metrics_all_b b
     where a.metric_id = b.metric_id
     and b.metric_calculation_type = G_FORMULA
     --and a.dirty_flag = G_IS_DIRTY
     order by a.metric_id;

   cursor c_get_dirty_formulas_by_obj(p_object_type VARCHAR2, p_object_id NUMBER)
     return act_metric_formula_type is
     select a.activity_metric_id, a.metric_id,
            a.arc_act_metric_used_by, a.act_metric_used_by_id,
            a.last_calculated_date, b.display_type
     from ams_act_metrics_all a, ams_metrics_all_b b
     where a.metric_id = b.metric_id
     and b.metric_calculation_type = G_FORMULA
     --and a.dirty_flag = G_IS_DIRTY
     and a.arc_act_metric_used_by = p_object_type
     and a.act_metric_used_by_id = p_object_id
     order by a.metric_id;

   TYPE metric_formula_type is record (
     source_type varchar2(30),
     source_id number,
     source_sub_id number,
     source_value number,
     token varchar2(15),
     use_sub_id_flag varchar2(1)
   );

   TYPE metric_formula_table is table
     of metric_formula_type index by binary_integer;

   cursor c_get_formula(p_metric_id NUMBER)
     return metric_formula_type is
     select source_type, source_id, source_sub_id, source_value, token,
            use_sub_id_flag
     from ams_metric_formulas f
     where f.metric_id = p_metric_id
     and f.notation_type = G_POSTFIX
     order by sequence;

   cursor c_get_values_by_metric(p_metric_id number, p_object_type VARCHAR2, p_object_id NUMBER) is
     select sum(func_forecasted_value), sum(func_actual_value), functional_currency_code
     from ams_act_metrics_all a
     where a.metric_id = p_metric_id
     and a.arc_act_metric_used_by = p_object_type
     and a.act_metric_used_by_id = p_object_id
     group by functional_currency_code;

   cursor c_get_values_by_category(p_category_id number, p_object_type VARCHAR2, p_object_id NUMBER) is
     select sum(func_forecasted_value), sum(func_actual_value), functional_currency_code
     from ams_act_metrics_all a, ams_metrics_all_b b
     where a.metric_id = b.metric_id
     and b.metric_category = p_category_id
     and a.arc_act_metric_used_by = p_object_type
     and a.act_metric_used_by_id = p_object_id
     group by functional_currency_code;

   cursor c_get_values_by_category_only(p_category_id number, p_object_type VARCHAR2, p_object_id NUMBER) is
     select sum(func_forecasted_value), sum(func_actual_value), functional_currency_code
     from ams_act_metrics_all a, ams_metrics_all_b b
     where a.metric_id = b.metric_id
     and b.metric_category = p_category_id
     and b.metric_sub_category is null
     and a.arc_act_metric_used_by = p_object_type
     and a.act_metric_used_by_id = p_object_id
     group by functional_currency_code;

   cursor c_get_values_by_sub_category(p_category_id number, p_sub_category_id number, p_object_type VARCHAR2, p_object_id NUMBER) is
     select sum(func_forecasted_value), sum(func_actual_value), functional_currency_code
     from ams_act_metrics_all a, ams_metrics_all_b b
     where a.metric_id = b.metric_id
     and b.metric_category = p_category_id
     and b.metric_sub_category = p_sub_category_id
     and a.arc_act_metric_used_by = p_object_type
     and a.act_metric_used_by_id = p_object_id
     and b.metric_calculation_type in (G_MANUAL, G_FUNCTION, G_ROLLUP)
     group by functional_currency_code;

   -- Dirty formula tables.
   l_activity_metric_ids num_table_type;
   l_metric_ids num_table_type;
   l_arc_act_metric_used_bys varchar2_table_type;
   l_act_metric_used_by_ids num_table_type;
   l_last_calculated_dates date_table_type;
   l_display_types varchar2_table_type;

   -- Temporary storage for querying by object types.
   l_temp_activity_metric_ids num_table_type;
   l_temp_metric_ids num_table_type;
   l_temp_arc_act_metric_used_bys varchar2_table_type;
   l_temp_act_metric_used_by_ids num_table_type;
   l_temp_last_calculated_dates date_table_type;
   l_temp_display_types varchar2_table_type;
   l_temp_func_forecasted_values num_table_type;
   l_temp_func_actual_values num_table_type;

   -- Formula Definition table.
   l_metric_formula_table metric_formula_table;
   l_metric_formula_record metric_formula_type;

   -- Output Data
   l_functional_currency_codes varchar2_table_type;
   l_func_forecasted_values num_table_type;
   l_func_actual_values num_table_type;
   l_transactional_currency_codes varchar2_table_type;
   l_trans_forecasted_values num_table_type;
   l_trans_actual_values num_table_type;
   l_days_since_last_refreshs num_table_type;

   l_obj_currencies object_currency_table;
   l_obj_currency object_currency_type;

   l_func_forecasted_value number;
   l_func_actual_value number;
   l_functional_currency_code varchar2(20);
   l_return_status varchar2(10);
   l_obj_index NUMBER;
   l_count number;
   l_last_metric_id number := -1;
   l_first number;
   l_last number;
begin
   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'START: object_list count='||p_object_list.count);
   END IF;

   -- Collect dirty formulas.
   IF p_object_list.count > 0 THEN
      -- Collect dirty formulas only with the object set.
      FOR l_obj_index IN p_object_list.first..p_object_list.last
      LOOP
         open c_get_dirty_formulas_by_obj(p_object_list(l_obj_index).obj_type,p_object_list(l_obj_index).obj_id);
         fetch c_get_dirty_formulas_by_obj
           bulk collect into
             l_temp_activity_metric_ids, l_temp_metric_ids,
             l_temp_arc_act_metric_used_bys, l_temp_act_metric_used_by_ids,
             l_temp_last_calculated_dates, l_temp_display_types;
         close c_get_dirty_formulas_by_obj;
         IF l_temp_activity_metric_ids.count > 0 THEN
            FOR l_index2 IN l_temp_activity_metric_ids.first..l_temp_activity_metric_ids.last
            LOOP
               l_count := l_activity_metric_ids.count+1;
               l_activity_metric_ids(l_count) := l_temp_activity_metric_ids(l_index2);
               l_metric_ids(l_count) := l_temp_metric_ids(l_index2);
               l_arc_act_metric_used_bys(l_count) := l_temp_arc_act_metric_used_bys(l_index2);
               l_act_metric_used_by_ids(l_count) := l_temp_act_metric_used_by_ids(l_index2);
               l_last_calculated_dates(l_count) := l_temp_last_calculated_dates(l_index2);
               l_display_types(l_count) := l_temp_display_types(l_index2);
            END LOOP;
            l_temp_activity_metric_ids.delete;
            l_temp_metric_ids.delete;
            l_temp_arc_act_metric_used_bys.delete;
            l_temp_act_metric_used_by_ids.delete;
            l_temp_last_calculated_dates.delete;
            l_temp_display_types.delete;
         END IF;
      end loop;
   else
      -- Collect dirty formulas system wide.
      open c_get_dirty_formulas;
      fetch c_get_dirty_formulas bulk collect into
             l_activity_metric_ids, l_metric_ids,
             l_arc_act_metric_used_bys, l_act_metric_used_by_ids,
             l_last_calculated_dates, l_display_types;
      close c_get_dirty_formulas;
   end if;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'Formula count='||l_activity_metric_ids.count);
   END IF;

   if l_activity_metric_ids.count > 0 then

      for l_index in l_activity_metric_ids.first..l_activity_metric_ids.last
      loop
         IF AMS_DEBUG_MEDIUM_ON THEN
            write_msg(L_API_NAME, 'activity_metric_id='||l_activity_metric_ids(l_index));
         END IF;
         l_days_since_last_refreshs(l_index) := p_current_date - l_last_calculated_dates(l_index);
         if l_metric_ids(l_index) <> l_last_metric_id then
            l_last_metric_id := l_metric_ids(l_index);
            l_metric_formula_table.delete;
            open c_get_formula(l_last_metric_id);
            loop
               fetch c_get_formula into l_metric_formula_record;
               exit when c_get_formula%NOTFOUND;
               l_metric_formula_table(l_metric_formula_table.count+1) := l_metric_formula_record;
            end loop;
            close c_get_formula;
         end if;
         IF AMS_DEBUG_MEDIUM_ON THEN
            write_msg(L_API_NAME, 'metric_id='||l_metric_ids(l_index)||', formula size ='||l_metric_formula_table.count);
         END IF;
         if l_metric_formula_table.count > 0 then
            clear_stack;
            for l_index2 in l_metric_formula_table.first..l_metric_formula_table.last
            loop
            IF AMS_DEBUG_LOW_ON THEN
               write_msg(L_API_NAME, 'source_type='||l_metric_formula_table(l_index2).source_type);
            END IF;
               l_func_forecasted_value := null;
               l_func_actual_value := null;
               if l_metric_formula_table(l_index2).source_type = G_METRIC then
                  open c_get_values_by_metric(l_metric_formula_table(l_index2).source_id,
                     l_arc_act_metric_used_bys(l_index),
                     l_act_metric_used_by_ids(l_index));
                  fetch c_get_values_by_metric
                    into l_func_forecasted_value, l_func_actual_value,
                         l_functional_currency_code;
                  close c_get_values_by_metric;
                  push(l_func_forecasted_value, l_func_actual_value);
               elsif l_metric_formula_table(l_index2).source_type = G_CATEGORY then
                  if l_metric_formula_table(l_index2).use_sub_id_flag = 'Y' then
                     if l_metric_formula_table(l_index2).source_sub_id is null then
                        open c_get_values_by_category_only(
                           l_metric_formula_table(l_index2).source_id,
                           l_arc_act_metric_used_bys(l_index),
                           l_act_metric_used_by_ids(l_index));
                        fetch c_get_values_by_category_only
                           into l_func_forecasted_value, l_func_actual_value,
                               l_functional_currency_code;
                        close c_get_values_by_category_only;
                     else
                        open c_get_values_by_sub_category(
                           l_metric_formula_table(l_index2).source_id,
                           l_metric_formula_table(l_index2).source_sub_id,
                           l_arc_act_metric_used_bys(l_index),
                           l_act_metric_used_by_ids(l_index));
                        fetch c_get_values_by_sub_category
                           into l_func_forecasted_value, l_func_actual_value,
                               l_functional_currency_code;
                        close c_get_values_by_sub_category;
                     end if;
                  else
                     open c_get_values_by_category(
                        l_metric_formula_table(l_index2).source_id,
                        l_arc_act_metric_used_bys(l_index),
                        l_act_metric_used_by_ids(l_index));
                     fetch c_get_values_by_category
                        into l_func_forecasted_value, l_func_actual_value,
                            l_functional_currency_code;
                     close c_get_values_by_category;
                  end if;
                  push(l_func_forecasted_value, l_func_actual_value);
               elsif l_metric_formula_table(l_index2).source_type = G_NUMBER then
                  push(l_metric_formula_table(l_index2).source_value, l_metric_formula_table(l_index2).source_value);
               elsif l_metric_formula_table(l_index2).source_type = G_OPERATOR then
                  apply(l_metric_formula_table(l_index2).token);
               else
                  null;-- error
               end if;
            end loop;
            IF AMS_DEBUG_MEDIUM_ON THEN
               write_msg(L_API_NAME, 'stack_count='||stack_count);
            END IF;
            if stack_count > 1 then
               -- error
               l_func_forecasted_values(l_index) := null;
               l_func_actual_values(l_index) := null;
            else
               pop(l_func_forecasted_value, l_func_actual_value);
            IF AMS_DEBUG_MEDIUM_ON THEN
               write_msg(L_API_NAME, 'The successfull results are='||
                         l_func_forecasted_value||'/'||l_func_actual_value);
            END IF;
               l_func_forecasted_values(l_index) := l_func_forecasted_value;
               l_func_actual_values(l_index) := l_func_actual_value;
            end if;
         else
            IF AMS_DEBUG_MEDIUM_ON THEN
               write_msg(L_API_NAME, 'No formula was found, metric_id='||
                         l_last_metric_id);
            END IF;
            -- No formula was found.
            l_func_forecasted_values(l_index) := null;
            l_func_actual_values(l_index) := null;
         end if;
         IF AMS_DEBUG_MEDIUM_ON THEN
            write_msg(L_API_NAME, 'display_type='||l_display_types(l_index));
         END IF;
         if l_display_types(l_index) = G_INTEGER then
            l_trans_forecasted_values(l_index) :=
                   l_func_forecasted_values(l_index);
            l_trans_actual_values(l_index) := l_func_actual_values(l_index);
            l_functional_currency_codes(l_index) := null;
            l_transactional_currency_codes(l_index) := null;
         elsif l_display_types(l_index) = G_PERCENT then
            l_trans_forecasted_values(l_index) :=
                   ROUND(l_func_forecasted_values(l_index) * 1000)/10;
            l_trans_actual_values(l_index) :=
                   ROUND(l_func_actual_values(l_index) * 1000)/10;
            l_functional_currency_codes(l_index) := null;
            l_transactional_currency_codes(l_index) := null;
         elsif l_display_types(l_index) = G_CURRENCY then
            l_functional_currency_codes(l_index) := p_func_currency;
            -- Verify the transaction currency code matches the object.
            IF l_obj_currencies.EXISTS(l_act_metric_used_by_ids(l_index)) AND
               l_obj_currencies(l_act_metric_used_by_ids(l_index)).obj_type =
                   l_arc_act_metric_used_bys(l_index)
            THEN
               l_transactional_currency_codes(l_index) :=
                   l_obj_currencies(l_act_metric_used_by_ids(l_index)).currency;
            ELSE
               Ams_Actmetric_Pvt.GET_TRANS_CURR_CODE(
                  p_obj_id  => l_act_metric_used_by_ids(l_index),
                  p_obj_type => l_arc_act_metric_used_bys(l_index),
                  x_trans_curr_code => l_transactional_currency_codes(l_index)
               );
               l_obj_currency.obj_id := l_act_metric_used_by_ids(l_index);
               l_obj_currency.obj_type := l_arc_act_metric_used_bys(l_index);
               l_obj_currency.currency :=
                   NVL(l_transactional_currency_codes(l_index),p_func_currency);
               l_obj_currencies(l_act_metric_used_by_ids(l_index)) :=
                   l_obj_currency;
            END IF;
            ams_actmetric_pvt.Convert_Currency2 (
               x_return_status      => l_return_status,
               p_from_currency      => l_functional_currency_codes(l_index),
               p_to_currency        => l_transactional_currency_codes(l_index),
               p_conv_date          => p_current_date,
               p_from_amount        => l_func_actual_values(l_index),
               x_to_amount          => l_trans_actual_values(l_index),
               p_from_amount2       => l_func_forecasted_values(l_index),
               x_to_amount2         => l_trans_forecasted_values(l_index),
               p_round              => fnd_api.g_false);
         else -- Error: display type not supported.
            IF AMS_DEBUG_MEDIUM_ON THEN
               write_msg(L_API_NAME, 'display_type not supported='||
                         l_display_types(l_index));
            END IF;
            l_trans_forecasted_values(l_index) := null;
            l_trans_actual_values(l_index) := null;
            l_functional_currency_codes(l_index) := null;
            l_transactional_currency_codes(l_index) := null;
         end if;
      end loop;

      l_metric_formula_table.delete;
      clear_stack;

      IF AMS_DEBUG_HIGH_ON THEN
         write_msg(L_API_NAME, 'formula calculations complete');
      END IF;

      l_first := l_activity_metric_ids.first;
      LOOP
         EXIT WHEN l_first > l_activity_metric_ids.last;
         IF l_first + G_BATCH_SIZE + G_BATCH_PAD >
                l_activity_metric_ids.last THEN
            l_last := l_activity_metric_ids.last;
         ELSE
            l_last := l_first + G_BATCH_SIZE - 1;
         END IF;
         FORALL l_index IN l_first .. l_last
            UPDATE ams_act_metrics_all
               SET last_calculated_date = p_current_date,
                   last_update_date = p_current_date,
                   object_version_number = object_version_number + 1,
                   days_since_last_refresh = l_days_since_last_refreshs(l_index),
                   transaction_currency_code = l_transactional_currency_codes(l_index),
                   functional_currency_code = l_functional_currency_codes(l_index),
                   trans_forecasted_value = l_trans_forecasted_values(l_index),
                   func_forecasted_value = l_func_forecasted_values(l_index),
                   trans_actual_value = l_trans_actual_values(l_index),
                   func_actual_value = l_func_actual_values(l_index),
                   dirty_flag = G_NOT_DIRTY
             WHERE activity_metric_id = l_activity_metric_ids(l_index);

         l_first := l_last + 1;
         IF p_commit = FND_API.G_TRUE THEN
            COMMIT;
            IF AMS_DEBUG_MEDIUM_ON THEN
               write_msg(L_API_NAME, 'BATCH COMMIT: l_last='||l_last);
            END IF;
         END IF;
      END LOOP;

      l_activity_metric_ids.delete;
      l_metric_ids.delete;
      l_arc_act_metric_used_bys.delete;
      l_act_metric_used_by_ids.delete;
      l_last_calculated_dates.delete;
      l_display_types.delete;
      l_functional_currency_codes.delete;
      l_func_forecasted_values.delete;
      l_func_actual_values.delete;
      l_transactional_currency_codes.delete;
      l_trans_forecasted_values.delete;
      l_trans_actual_values.delete;
      l_days_since_last_refreshs.delete;
      l_obj_currencies.delete;
   end if;

   IF AMS_DEBUG_HIGH_ON THEN
      write_msg(L_API_NAME, 'END');
   END IF;

end Update_formulas;

-------------------------------------------------------------------------------
-- NAME
--    Update_formulas
-- PURPOSE
--    External API to calculate Formula metrics with in a single object.
-- HISTORY
-- 22-Aug_2003 dmvincen Created.
-------------------------------------------------------------------------------
PROCEDURE Update_formulas (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_arc_act_metric_used_by     IN VARCHAR2,
   p_act_metric_used_by_id      IN NUMBER
)
is
   L_API_NAME CONSTANT VARCHAR2(100) := 'UPDATE_FORMULAS';

  l_errbuf VARCHAR2(4000);
  l_retcode VARCHAR2(10);
  l_index number;
  l_object_list object_currency_table;
  l_current_date date := sysdate;
  l_default_currency VARCHAR2(15) := Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY;
begin

   savepoint sp_Update_formulas;

   x_return_status      := Fnd_Api.G_RET_STS_SUCCESS;

   l_index := l_object_list.count + 1;
   l_object_list(l_index).obj_type := p_arc_act_metric_used_by;
   l_object_list(l_index).obj_id := p_act_metric_used_by_id;

   Update_formulas(x_errbuf => l_errbuf,
                 x_retcode => l_retcode,
                 p_commit => FND_API.G_FALSE,
                 p_object_list => l_object_list,
                 p_current_date => l_current_date,
                 p_func_currency => l_default_currency);

   -- If any errors happen abort API.
   IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --COMMIT WORK;

   IF Fnd_Api.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO sp_Update_formulas;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded         =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_Update_formulas;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded         =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO sp_Update_formulas;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );

end Update_formulas;




--========================================================================
-- PROCEDURE
--    populate_all
-- Purpose
--    1. populates metrics all denorm table completely
-- HISTORY
--    01-Oct-2003   asaha    Created.
--
--========================================================================
--
PROCEDURE populate_all(
 x_msg_data OUT NOCOPY VARCHAR2,
 x_return_status OUT NOCOPY VARCHAR2
) IS

l_metric_col_date DATE;
l_msg_data VARCHAR2(2000);


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;
x_msg_data := l_msg_data;

--bms_output.put_line('deleting all entries');
IF AMS_DEBUG_HIGH_ON THEN
   write_msg('populate_all','Deleting all entris from ams_act_metrics_all_denorm');
END IF;


delete
from ams_act_metrics_all_denorm;

----Ams_Utility_Pvt.Write_Conc_log('Inserting entries ams_act_metrics_all_denorm') ;
l_metric_col_date := SYSDATE;
--bms_output.put_line('inserting all entries with metric collection date : '||TO_CHAR(l_metric_col_date,'DD-MON-YYYY HH:MI:SS'));
IF AMS_DEBUG_HIGH_ON THEN
   write_msg('populate_all','inserting all entries with metric collection date : '||TO_CHAR(l_metric_col_date,'DD-MON-YYYY HH:MI:SS'));
END IF;


insert  into ams_act_metrics_all_denorm (creation_date,created_by,last_update_date,last_updated_by,last_update_login,act_metrics_denorm_id,metric_collection_date,object_type
,object_id,leads,top_leads,top_leads_ratio,leads_accepted,lead_acceptance_rate,dead_leads,dead_leads_ratio,opportunities
,leads_to_opportunity_rate,quotes,quotes_amount,orders,orders_amount,booked_revenue,invoiced_revenue
,booked_revenue_per_lead,invoiced_revenue_per_lead,cost,cost_per_lead,booked_roi,invoiced_roi
,responses,contact_group_size,target_group_size
,leads_forecast,top_leads_forecast,top_leads_ratio_forecast,leads_accepted_forecast,leads_accepted_ratio_forecast
,dead_leads_forecast,dead_leads_ratio_forecast,opportunities_forecast,lead_opportunity_rate_forecast
,quotes_forecast,quotes_amount_forecast,orders_forecast,orders_amount_forecast
,booked_revenue_forecast,invoiced_revenue_forecast,booked_rev_per_lead_forecast,invoiced_rev_per_lead_forecast
,cost_forecast,cost_per_lead_forecast,booked_roi_forecast,
invoiced_roi_forecast,contact_group_size_forecast,target_group_size_forecast,responses_forecast
)
select sysdate,Fnd_Global.User_Id,sysdate,Fnd_Global.User_Id,Fnd_Global.Conc_Login_Id,AMS_ACT_METRICS_ALL_DENORM_S.NEXTVAL,
sysdate,object_type,object_id
,leads,top_leads,top_leads_ratio,leads_accepted,lead_acceptance_rate
,dead_leads,dead_leads_ratio,opportunities,leads_to_opportunity_rate,quotes,quotes_amount,orders,orders_amount
,booked_revenue,invoiced_revenue,booked_revenue_per_lead,invoiced_revenue_per_lead,cost,cost_per_lead,booked_roi,
invoiced_roi,responses,contact_group_size,target_group_size
,leads_forecast,top_leads_forecast,top_leads_ratio_forecast,leads_accepted_forecast,leads_accepted_ratio_forecast
,dead_leads_forecast,dead_leads_ratio_forecast,opportunities_forecast,lead_opportunity_rate_forecast
,quotes_forecast,quotes_amount_forecast,orders_forecast,orders_amount_forecast
,booked_revenue_forecast,invoiced_revenue_forecast,booked_rev_per_lead_forecast,invoiced_rev_per_lead_forecast
,cost_forecast,cost_per_lead_forecast,booked_roi_forecast,
invoiced_roi_forecast,responses_forecast,contact_group_size_forecast,target_group_size_forecast
from (
select h1.arc_act_metric_used_by object_type,h1.act_metric_used_by_id object_id,
sum(decode(met.denorm_code,'METRIC_01',h1.func_actual_value,0)) leads,
sum(decode(met.denorm_code,'METRIC_02',h1.func_actual_value,0)) top_leads,
sum(decode(met.denorm_code,'METRIC_03',h1.func_actual_value,0)) top_leads_ratio,
sum(decode(met.denorm_code,'METRIC_04',h1.func_actual_value,0)) leads_accepted,
sum(decode(met.denorm_code,'METRIC_05',h1.func_actual_value,0)) lead_acceptance_rate,
sum(decode(met.denorm_code,'METRIC_06',h1.func_actual_value,0)) dead_leads,
sum(decode(met.denorm_code,'METRIC_07',h1.func_actual_value,0)) dead_leads_ratio,
sum(decode(met.denorm_code,'METRIC_08',h1.func_actual_value,0)) opportunities,
sum(decode(met.denorm_code,'METRIC_09',h1.func_actual_value,0)) leads_to_opportunity_rate,
sum(decode(met.denorm_code,'METRIC_10',h1.func_actual_value,0)) quotes,
sum(decode(met.denorm_code,'METRIC_11',h1.func_actual_value,0)) quotes_amount,
sum(decode(met.denorm_code,'METRIC_12',h1.func_actual_value,0)) orders,
sum(decode(met.denorm_code,'METRIC_13',h1.func_actual_value,0)) orders_amount,
sum(decode(met.denorm_code,'METRIC_14',h1.func_actual_value,0)) booked_revenue,
sum(decode(met.denorm_code,'METRIC_15',h1.func_actual_value,0)) invoiced_revenue,
sum(decode(met.denorm_code,'METRIC_16',h1.func_actual_value,0)) booked_revenue_per_lead,
sum(decode(met.denorm_code,'METRIC_17',h1.func_actual_value,0)) invoiced_revenue_per_lead,
sum(decode(met.denorm_code,'METRIC_18',h1.func_actual_value,0)) cost,
sum(decode(met.denorm_code,'METRIC_19',h1.func_actual_value,0)) cost_per_lead,
sum(decode(met.denorm_code,'METRIC_20',h1.func_actual_value,0)) booked_roi,
sum(decode(met.denorm_code,'METRIC_21',h1.func_actual_value,0)) invoiced_roi,
sum(decode(met.denorm_code,'METRIC_22',h1.func_actual_value,0)) responses,
sum(decode(met.denorm_code,'METRIC_23',h1.func_actual_value,0)) contact_group_size,
sum(decode(met.denorm_code,'METRIC_24',h1.func_actual_value,0)) target_group_size,
sum(decode(met.denorm_code,'METRIC_01',h1.func_forecasted_value,0)) leads_forecast,
sum(decode(met.denorm_code,'METRIC_02',h1.func_forecasted_value,0)) top_leads_forecast,
sum(decode(met.denorm_code,'METRIC_03',h1.func_forecasted_value,0)) top_leads_ratio_forecast,
sum(decode(met.denorm_code,'METRIC_04',h1.func_forecasted_value,0)) leads_accepted_forecast,
sum(decode(met.denorm_code,'METRIC_05',h1.func_forecasted_value,0)) leads_accepted_ratio_forecast,
sum(decode(met.denorm_code,'METRIC_06',h1.func_forecasted_value,0)) dead_leads_forecast,
sum(decode(met.denorm_code,'METRIC_07',h1.func_forecasted_value,0)) dead_leads_ratio_forecast,
sum(decode(met.denorm_code,'METRIC_08',h1.func_forecasted_value,0)) opportunities_forecast,
sum(decode(met.denorm_code,'METRIC_09',h1.func_forecasted_value,0)) lead_opportunity_rate_forecast,
sum(decode(met.denorm_code,'METRIC_10',h1.func_forecasted_value,0)) quotes_forecast,
sum(decode(met.denorm_code,'METRIC_11',h1.func_forecasted_value,0)) quotes_amount_forecast,
sum(decode(met.denorm_code,'METRIC_12',h1.func_forecasted_value,0)) orders_forecast,
sum(decode(met.denorm_code,'METRIC_13',h1.func_forecasted_value,0)) orders_amount_forecast,
sum(decode(met.denorm_code,'METRIC_14',h1.func_forecasted_value,0)) booked_revenue_forecast,
sum(decode(met.denorm_code,'METRIC_15',h1.func_forecasted_value,0)) invoiced_revenue_forecast,
sum(decode(met.denorm_code,'METRIC_16',h1.func_forecasted_value,0)) booked_rev_per_lead_forecast,
sum(decode(met.denorm_code,'METRIC_17',h1.func_forecasted_value,0)) invoiced_rev_per_lead_forecast,
sum(decode(met.denorm_code,'METRIC_18',h1.func_forecasted_value,0)) cost_forecast,
sum(decode(met.denorm_code,'METRIC_19',h1.func_forecasted_value,0)) cost_per_lead_forecast,
sum(decode(met.denorm_code,'METRIC_20',h1.func_forecasted_value,0)) booked_roi_forecast,
sum(decode(met.denorm_code,'METRIC_21',h1.func_forecasted_value,0)) invoiced_roi_forecast,
sum(decode(met.denorm_code,'METRIC_22',h1.func_forecasted_value,0)) responses_forecast,
sum(decode(met.denorm_code,'METRIC_23',h1.func_forecasted_value,0)) contact_group_size_forecast,
sum(decode(met.denorm_code,'METRIC_24',h1.func_forecasted_value,0)) target_group_size_forecast
from ams_act_metrics_all h1, ams_metrics_all_b met
where h1.metric_id = met.metric_id
and met.denorm_code in
(
'METRIC_01'
,'METRIC_02'
,'METRIC_03'
,'METRIC_04'
,'METRIC_05'
,'METRIC_06'
,'METRIC_07'
,'METRIC_08'
,'METRIC_09'
,'METRIC_10'
,'METRIC_11'
,'METRIC_12'
,'METRIC_13'
,'METRIC_14'
,'METRIC_15'
,'METRIC_16'
,'METRIC_17'
,'METRIC_18'
,'METRIC_19'
,'METRIC_20'
,'METRIC_21'
,'METRIC_22'
,'METRIC_23'
,'METRIC_24')
group by h1.arc_act_metric_used_by ,h1.act_metric_used_by_id
);

IF AMS_DEBUG_HIGH_ON THEN
   write_msg('populate_all','Done Inserting entries ams_act_metrics_all_denorm');
END IF;

--bms_output.put_line('Done Inserting entries ');

END populate_all;


--========================================================================
-- PROCEDURE
--    populate_incremental
-- Purpose
--    1. populates metrics all denorm table incrementally
-- HISTORY
--    01-Oct-2003   asaha    Created.
--
--========================================================================
PROCEDURE populate_incremental(
   p_last_run_date IN DATE,
   x_msg_data OUT NOCOPY VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2
) IS
l_metric_col_date DATE;
l_msg_data VARCHAR2(2000);

CURSOR c_new_objects_csr(p_date DATE) IS
select distinct concat(concat(arc_act_metric_used_by,'_'),TO_CHAR(act_metric_used_by_id))
from ams_act_metrics_all
where last_update_date > p_date;

new_object_row VARCHAR2(100);
l_obj_type VARCHAR2(30);
l_obj_id NUMBER;
l_no_of_objects NUMBER := 0;

l_index NUMBER;

l_calc_since DATE := sysdate - fnd_profile.value('AMS_METR_SEEDED_CALC_EXP');

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

----Ams_Utility_Pvt.Write_Conc_log('Inserting entries ams_act_metrics_all_denorm') ;
l_metric_col_date := SYSDATE;

IF AMS_DEBUG_HIGH_ON THEN
   write_msg('populate_incremental','max last run date : '||TO_CHAR(p_last_run_date,'DD-MON-YYYY HH:MI:SS'));
   write_msg('populate_incremental','metric collection date determined: '||TO_CHAR(l_metric_col_date,'DD-MON-YYYY HH:MI:SS'));
END IF;

--bms_output.put_line('last run date : '||TO_CHAR(p_last_run_date,'DD-MON-YYYY HH:MI:SS'));
--bms_output.put_line('metric collection date : '||TO_CHAR(l_metric_col_date,'DD-MON-YYYY HH:MI:SS'));

--first update those rows in ams_act_metrics_all_denorm whose values have been changed in
--ams_act_metrics_all since last metrics collection date
update ams_act_metrics_all_denorm a
set
(
a.last_updated_by
,a.last_update_date
,a.last_update_login
,a.metric_collection_date
,a.object_version_number
,a.leads,top_leads,a.top_leads_ratio,a.leads_accepted,a.lead_acceptance_rate
,a.dead_leads,a.dead_leads_ratio,opportunities,a.leads_to_opportunity_rate,a.quotes,a.quotes_amount,a.orders,a.orders_amount
,a.booked_revenue,invoiced_revenue,a.booked_revenue_per_lead,a.invoiced_revenue_per_lead,a.cost,a.cost_per_lead,a.booked_roi
,a.invoiced_roi,a.responses,a.contact_group_size,a.target_group_size
,a.leads_forecast,a.top_leads_forecast,a.top_leads_ratio_forecast,a.leads_accepted_forecast,a.leads_accepted_ratio_forecast
,a.dead_leads_forecast,a.dead_leads_ratio_forecast,a.opportunities_forecast,a.lead_opportunity_rate_forecast
,a.quotes_forecast,a.quotes_amount_forecast,a.orders_forecast,a.orders_amount_forecast
,a.booked_revenue_forecast,a.invoiced_revenue_forecast,a.booked_rev_per_lead_forecast,a.invoiced_rev_per_lead_forecast
,a.cost_forecast,a.cost_per_lead_forecast,a.booked_roi_forecast
,a.invoiced_roi_forecast,a.responses_forecast,a.contact_group_size_forecast,a.target_group_size_forecast
) =
(select Fnd_Global.User_Id,sysdate,Fnd_Global.User_Id,sysdate,
nvl(a.object_version_number,1) + 1,
sum(decode(met.denorm_code,'METRIC_01',h1.func_actual_value,0)) leads,
sum(decode(met.denorm_code,'METRIC_02',h1.func_actual_value,0)) top_leads,
sum(decode(met.denorm_code,'METRIC_03',h1.func_actual_value,0)) top_leads_ratio,
sum(decode(met.denorm_code,'METRIC_04',h1.func_actual_value,0)) leads_accepted,
sum(decode(met.denorm_code,'METRIC_05',h1.func_actual_value,0)) lead_acceptance_rate,
sum(decode(met.denorm_code,'METRIC_06',h1.func_actual_value,0)) dead_leads,
sum(decode(met.denorm_code,'METRIC_07',h1.func_actual_value,0)) dead_leads_ratio,
sum(decode(met.denorm_code,'METRIC_08',h1.func_actual_value,0)) opportunities,
sum(decode(met.denorm_code,'METRIC_09',h1.func_actual_value,0)) leads_to_opportunity_rate,
sum(decode(met.denorm_code,'METRIC_10',h1.func_actual_value,0)) quotes,
sum(decode(met.denorm_code,'METRIC_11',h1.func_actual_value,0)) quotes_amount,
sum(decode(met.denorm_code,'METRIC_12',h1.func_actual_value,0)) orders,
sum(decode(met.denorm_code,'METRIC_13',h1.func_actual_value,0)) orders_amount,
sum(decode(met.denorm_code,'METRIC_14',h1.func_actual_value,0)) booked_revenue,
sum(decode(met.denorm_code,'METRIC_15',h1.func_actual_value,0)) invoiced_revenue,
sum(decode(met.denorm_code,'METRIC_16',h1.func_actual_value,0)) booked_revenue_per_lead,
sum(decode(met.denorm_code,'METRIC_17',h1.func_actual_value,0)) invoiced_revenue_per_lead,
sum(decode(met.denorm_code,'METRIC_18',h1.func_actual_value,0)) cost,
sum(decode(met.denorm_code,'METRIC_19',h1.func_actual_value,0)) cost_per_lead,
sum(decode(met.denorm_code,'METRIC_20',h1.func_actual_value,0)) booked_roi,
sum(decode(met.denorm_code,'METRIC_21',h1.func_actual_value,0)) invoiced_roi,
sum(decode(met.denorm_code,'METRIC_22',h1.func_actual_value,0)) responses,
sum(decode(met.denorm_code,'METRIC_23',h1.func_actual_value,0)) contact_group_size,
sum(decode(met.denorm_code,'METRIC_24',h1.func_actual_value,0)) target_group_size,
sum(decode(met.denorm_code,'METRIC_01',h1.func_forecasted_value,0)) leads_forecast,
sum(decode(met.denorm_code,'METRIC_02',h1.func_forecasted_value,0)) top_leads_forecast,
sum(decode(met.denorm_code,'METRIC_03',h1.func_forecasted_value,0)) top_leads_ratio_forecast,
sum(decode(met.denorm_code,'METRIC_04',h1.func_forecasted_value,0)) leads_accepted_forecast,
sum(decode(met.denorm_code,'METRIC_05',h1.func_forecasted_value,0)) leads_accepted_ratio_forecast,
sum(decode(met.denorm_code,'METRIC_06',h1.func_forecasted_value,0)) dead_leads_forecast,
sum(decode(met.denorm_code,'METRIC_07',h1.func_forecasted_value,0)) dead_leads_ratio_forecast,
sum(decode(met.denorm_code,'METRIC_08',h1.func_forecasted_value,0)) opportunities_forecast,
sum(decode(met.denorm_code,'METRIC_09',h1.func_forecasted_value,0)) lead_opportunity_rate_forecast,
sum(decode(met.denorm_code,'METRIC_10',h1.func_forecasted_value,0)) quotes_forecast,
sum(decode(met.denorm_code,'METRIC_11',h1.func_forecasted_value,0)) quotes_amount_forecast,
sum(decode(met.denorm_code,'METRIC_12',h1.func_forecasted_value,0)) orders_forecast,
sum(decode(met.denorm_code,'METRIC_13',h1.func_forecasted_value,0)) orders_amount_forecast,
sum(decode(met.denorm_code,'METRIC_14',h1.func_forecasted_value,0)) booked_revenue_forecast,
sum(decode(met.denorm_code,'METRIC_15',h1.func_forecasted_value,0)) invoiced_revenue_forecast,
sum(decode(met.denorm_code,'METRIC_16',h1.func_forecasted_value,0)) booked_rev_per_lead_forecast,
sum(decode(met.denorm_code,'METRIC_17',h1.func_forecasted_value,0)) invoiced_rev_per_lead_forecast,
sum(decode(met.denorm_code,'METRIC_18',h1.func_forecasted_value,0)) cost_forecast,
sum(decode(met.denorm_code,'METRIC_19',h1.func_forecasted_value,0)) cost_per_lead_forecast,
sum(decode(met.denorm_code,'METRIC_20',h1.func_forecasted_value,0)) booked_roi_forecast,
sum(decode(met.denorm_code,'METRIC_21',h1.func_forecasted_value,0)) invoiced_roi_forecast,
sum(decode(met.denorm_code,'METRIC_22',h1.func_forecasted_value,0)) responses_forecast,
sum(decode(met.denorm_code,'METRIC_23',h1.func_forecasted_value,0)) contact_group_size_forecast,
sum(decode(met.denorm_code,'METRIC_24',h1.func_forecasted_value,0)) target_group_size_forecast
from ams_act_metrics_all h1, ams_metrics_all_b met
where h1.metric_id = met.metric_id
and met.denorm_code in
(
'METRIC_01'
,'METRIC_02'
,'METRIC_03'
,'METRIC_04'
,'METRIC_05'
,'METRIC_06'
,'METRIC_07'
,'METRIC_08'
,'METRIC_09'
,'METRIC_10'
,'METRIC_11'
,'METRIC_12'
,'METRIC_13'
,'METRIC_14'
,'METRIC_15'
,'METRIC_16'
,'METRIC_17'
,'METRIC_18'
,'METRIC_19'
,'METRIC_20'
,'METRIC_21'
,'METRIC_22'
,'METRIC_23'
,'METRIC_24')
and h1.arc_act_metric_used_by(+) = a.object_type
and h1.act_metric_used_by_id(+) = a.object_id
)
where a.last_update_date > l_calc_since
and exists (select 1 from ams_act_metrics_all amet, ams_metrics_all_b met
  where amet.last_update_date > a.last_update_date
  and amet.metric_id = met.metric_id
  and met.denorm_code is not null
  and amet.arc_act_metric_used_by = a.object_type
  and amet.act_metric_used_by_id = a.object_id
  and rownum = 1
  )
;


insert  into ams_act_metrics_all_denorm (creation_date,created_by,last_update_date,last_updated_by,last_update_login
,act_metrics_denorm_id,metric_collection_date,object_type
,object_id,leads,top_leads,top_leads_ratio,leads_accepted,lead_acceptance_rate,dead_leads,dead_leads_ratio,opportunities
,leads_to_opportunity_rate,quotes,quotes_amount,orders,orders_amount,booked_revenue,invoiced_revenue
,booked_revenue_per_lead,invoiced_revenue_per_lead,cost,cost_per_lead,booked_roi,invoiced_roi
,responses,contact_group_size,target_group_size
,leads_forecast,top_leads_forecast,top_leads_ratio_forecast,leads_accepted_forecast,leads_accepted_ratio_forecast
,dead_leads_forecast,dead_leads_ratio_forecast,opportunities_forecast,lead_opportunity_rate_forecast
,quotes_forecast,quotes_amount_forecast,orders_forecast,orders_amount_forecast
,booked_revenue_forecast,invoiced_revenue_forecast,booked_rev_per_lead_forecast,invoiced_rev_per_lead_forecast
,cost_forecast,cost_per_lead_forecast,booked_roi_forecast,
invoiced_roi_forecast,contact_group_size_forecast,target_group_size_forecast,responses_forecast
)
select sysdate,Fnd_Global.User_Id,sysdate,Fnd_Global.User_Id,Fnd_Global.Conc_Login_Id,AMS_ACT_METRICS_ALL_DENORM_S.NEXTVAL,
sysdate,object_type,object_id
,leads,top_leads,top_leads_ratio,leads_accepted,lead_acceptance_rate
,dead_leads,dead_leads_ratio,opportunities,leads_to_opportunity_rate,quotes,quotes_amount,orders,orders_amount
,booked_revenue,invoiced_revenue,booked_revenue_per_lead,invoiced_revenue_per_lead,cost,cost_per_lead,booked_roi,
invoiced_roi,responses,contact_group_size,target_group_size
,leads_forecast,top_leads_forecast,top_leads_ratio_forecast,leads_accepted_forecast,leads_accepted_ratio_forecast
,dead_leads_forecast,dead_leads_ratio_forecast,opportunities_forecast,lead_opportunity_rate_forecast
,quotes_forecast,quotes_amount_forecast,orders_forecast,orders_amount_forecast
,booked_revenue_forecast,invoiced_revenue_forecast,booked_rev_per_lead_forecast,invoiced_rev_per_lead_forecast
,cost_forecast,cost_per_lead_forecast,booked_roi_forecast,
invoiced_roi_forecast,responses_forecast,contact_group_size_forecast,target_group_size_forecast
from (
select h1.arc_act_metric_used_by object_type,h1.act_metric_used_by_id object_id,
sum(decode(met.denorm_code,'METRIC_01',h1.func_actual_value,0)) leads,
sum(decode(met.denorm_code,'METRIC_02',h1.func_actual_value,0)) top_leads,
sum(decode(met.denorm_code,'METRIC_03',h1.func_actual_value,0)) top_leads_ratio,
sum(decode(met.denorm_code,'METRIC_04',h1.func_actual_value,0)) leads_accepted,
sum(decode(met.denorm_code,'METRIC_05',h1.func_actual_value,0)) lead_acceptance_rate,
sum(decode(met.denorm_code,'METRIC_06',h1.func_actual_value,0)) dead_leads,
sum(decode(met.denorm_code,'METRIC_07',h1.func_actual_value,0)) dead_leads_ratio,
sum(decode(met.denorm_code,'METRIC_08',h1.func_actual_value,0)) opportunities,
sum(decode(met.denorm_code,'METRIC_09',h1.func_actual_value,0)) leads_to_opportunity_rate,
sum(decode(met.denorm_code,'METRIC_10',h1.func_actual_value,0)) quotes,
sum(decode(met.denorm_code,'METRIC_11',h1.func_actual_value,0)) quotes_amount,
sum(decode(met.denorm_code,'METRIC_12',h1.func_actual_value,0)) orders,
sum(decode(met.denorm_code,'METRIC_13',h1.func_actual_value,0)) orders_amount,
sum(decode(met.denorm_code,'METRIC_14',h1.func_actual_value,0)) booked_revenue,
sum(decode(met.denorm_code,'METRIC_15',h1.func_actual_value,0)) invoiced_revenue,
sum(decode(met.denorm_code,'METRIC_16',h1.func_actual_value,0)) booked_revenue_per_lead,
sum(decode(met.denorm_code,'METRIC_17',h1.func_actual_value,0)) invoiced_revenue_per_lead,
sum(decode(met.denorm_code,'METRIC_18',h1.func_actual_value,0)) cost,
sum(decode(met.denorm_code,'METRIC_19',h1.func_actual_value,0)) cost_per_lead,
sum(decode(met.denorm_code,'METRIC_20',h1.func_actual_value,0)) booked_roi,
sum(decode(met.denorm_code,'METRIC_21',h1.func_actual_value,0)) invoiced_roi,
sum(decode(met.denorm_code,'METRIC_22',h1.func_actual_value,0)) responses,
sum(decode(met.denorm_code,'METRIC_23',h1.func_actual_value,0)) contact_group_size,
sum(decode(met.denorm_code,'METRIC_24',h1.func_actual_value,0)) target_group_size,
sum(decode(met.denorm_code,'METRIC_01',h1.func_forecasted_value,0)) leads_forecast,
sum(decode(met.denorm_code,'METRIC_02',h1.func_forecasted_value,0)) top_leads_forecast,
sum(decode(met.denorm_code,'METRIC_03',h1.func_forecasted_value,0)) top_leads_ratio_forecast,
sum(decode(met.denorm_code,'METRIC_04',h1.func_forecasted_value,0)) leads_accepted_forecast,
sum(decode(met.denorm_code,'METRIC_05',h1.func_forecasted_value,0)) leads_accepted_ratio_forecast,
sum(decode(met.denorm_code,'METRIC_06',h1.func_forecasted_value,0)) dead_leads_forecast,
sum(decode(met.denorm_code,'METRIC_07',h1.func_forecasted_value,0)) dead_leads_ratio_forecast,
sum(decode(met.denorm_code,'METRIC_08',h1.func_forecasted_value,0)) opportunities_forecast,
sum(decode(met.denorm_code,'METRIC_09',h1.func_forecasted_value,0)) lead_opportunity_rate_forecast,
sum(decode(met.denorm_code,'METRIC_10',h1.func_forecasted_value,0)) quotes_forecast,
sum(decode(met.denorm_code,'METRIC_11',h1.func_forecasted_value,0)) quotes_amount_forecast,
sum(decode(met.denorm_code,'METRIC_12',h1.func_forecasted_value,0)) orders_forecast,
sum(decode(met.denorm_code,'METRIC_13',h1.func_forecasted_value,0)) orders_amount_forecast,
sum(decode(met.denorm_code,'METRIC_14',h1.func_forecasted_value,0)) booked_revenue_forecast,
sum(decode(met.denorm_code,'METRIC_15',h1.func_forecasted_value,0)) invoiced_revenue_forecast,
sum(decode(met.denorm_code,'METRIC_16',h1.func_forecasted_value,0)) booked_rev_per_lead_forecast,
sum(decode(met.denorm_code,'METRIC_17',h1.func_forecasted_value,0)) invoiced_rev_per_lead_forecast,
sum(decode(met.denorm_code,'METRIC_18',h1.func_forecasted_value,0)) cost_forecast,
sum(decode(met.denorm_code,'METRIC_19',h1.func_forecasted_value,0)) cost_per_lead_forecast,
sum(decode(met.denorm_code,'METRIC_20',h1.func_forecasted_value,0)) booked_roi_forecast,
sum(decode(met.denorm_code,'METRIC_21',h1.func_forecasted_value,0)) invoiced_roi_forecast,
sum(decode(met.denorm_code,'METRIC_22',h1.func_forecasted_value,0)) responses_forecast,
sum(decode(met.denorm_code,'METRIC_23',h1.func_forecasted_value,0)) contact_group_size_forecast,
sum(decode(met.denorm_code,'METRIC_24',h1.func_forecasted_value,0)) target_group_size_forecast
from ams_act_metrics_all h1, ams_metrics_all_b met
where h1.metric_id = met.metric_id
and met.denorm_code in
(
'METRIC_01'
,'METRIC_02'
,'METRIC_03'
,'METRIC_04'
,'METRIC_05'
,'METRIC_06'
,'METRIC_07'
,'METRIC_08'
,'METRIC_09'
,'METRIC_10'
,'METRIC_11'
,'METRIC_12'
,'METRIC_13'
,'METRIC_14'
,'METRIC_15'
,'METRIC_16'
,'METRIC_17'
,'METRIC_18'
,'METRIC_19'
,'METRIC_20'
,'METRIC_21'
,'METRIC_22'
,'METRIC_23'
,'METRIC_24')
and (h1.arc_act_metric_used_by,h1.act_metric_used_by_id) not in
(
select distinct object_type, object_id
from ams_act_metrics_all_denorm
)
group by h1.arc_act_metric_used_by ,h1.act_metric_used_by_id
);

--bms_output.put_line('No of objects modified '||TO_CHAR(l_no_of_objects));
IF AMS_DEBUG_HIGH_ON THEN
   write_msg('populate_incremental','No of objects modified '||TO_CHAR(l_no_of_objects));
END IF;

x_msg_data := l_msg_data;

END populate_incremental;

--========================================================================
-- PROCEDURE
--    populate_metrics_denorm
-- Purpose
--    1. populates metrics all denorm table
--    2. refreshes yearly,weekly,monthly and quarterly materialized views
-- HISTORY
--    30-Sep-2003   asaha    Created.
--
--========================================================================
PROCEDURE populate_metrics_denorm(
                errbuf            OUT NOCOPY    VARCHAR2,
                retcode           OUT NOCOPY    NUMBER,
                p_run_incremental IN     VARCHAR2 := Fnd_Api.G_TRUE
) IS

l_return_status    VARCHAR2(1) ;
l_msg_count        NUMBER ;
l_msg_data         VARCHAR2(2000);
l_api_version      NUMBER := 1.0 ;

l_metric_collection_date DATE;
l_last_run_date DATE := NULL;

CURSOR c_last_run_date_csr is
  select max(metric_collection_date)
  from ams_act_metrics_all_denorm;

BEGIN
   FND_MSG_PUB.initialize;

   --bms_output.put_line('Entered populate_metrics_denorm');
   --Ams_Utility_Pvt.Write_Conc_log('Entered populate_metrics_denorm');
   IF AMS_DEBUG_HIGH_ON THEN
     write_msg('populate_metrics_denorm','Entered populate_metrics_denorm');
   END IF;


   OPEN c_last_run_date_csr;
   FETCH c_last_run_date_csr INTO l_last_run_date;
   CLOSE c_last_run_date_csr;

   --bms_output.put_line('Last run date determined '||TO_CHAR(l_last_run_date,'DD_MON_RRRR HH:MM:SS'));
   IF AMS_DEBUG_HIGH_ON THEN
     write_msg('populate_metrics_denorm','Last run date determined '||TO_CHAR(l_last_run_date,'DD_MON_RRRR HH:MM:SS'));
   END IF;

   IF (p_run_incremental IN (Fnd_Api.G_TRUE, 'Y') AND l_last_run_date IS NOT NULL) THEN
     IF AMS_DEBUG_HIGH_ON THEN
       write_msg('populate_metrics_denorm','Calling populate incremental');
     END IF;

     --bms_output.put_line('Calling populate incremental');

     populate_incremental(l_last_run_date, l_msg_data,l_return_status);

     --bms_output.put_line('Done with populate incremental');
     IF AMS_DEBUG_HIGH_ON THEN
       write_msg('populate_metrics_denorm','Done with populate incremental');
     END IF;
   ELSE
     IF AMS_DEBUG_HIGH_ON THEN
       write_msg('populate_metrics_denorm','Calling populate all');
     END IF;
     --bms_output.put_line('Calling populate all');

     populate_all(l_msg_data, l_return_status);

     --bms_output.put_line('Done with populate all');
     IF AMS_DEBUG_HIGH_ON THEN
       write_msg('populate_metrics_denorm','Done with populate all');
     END IF;
   END IF;

   --bms_output.put_line('Calling Refresh the Materialized Views');
   IF AMS_DEBUG_HIGH_ON THEN
     write_msg('populate_metrics_denorm','Calling Refresh the Materialized Views');
   END IF;

   /* Bug#4669156: No longer need materialized views.
      Commenting out the following mv refresh calls
      Also, see High Buffer Gets issues bug#5158052 and 5158040
   */
   --dbms_snapshot.refresh('ams_act_metrics_weekly_mv','C');
   --dbms_snapshot.refresh('ams_act_metrics_qtrly_mv','C');
   --dbms_snapshot.refresh('ams_act_metrics_monthly_mv','C');
   --dbms_snapshot.refresh('ams_act_metrics_yearly_mv','C');

   --bms_output.put_line('Done Refreshing the Materialized Views');
   IF AMS_DEBUG_HIGH_ON THEN
     write_msg('populate_metrics_denorm','Done Refreshing the Materialized Views');
   END IF;

   --Write_log ;
   ----Ams_Utility_Pvt.Write_Conc_log ;

   IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
      retcode :=0;
   ELSE
      retcode  := 2;
      errbuf   :=  l_msg_data ;
   END IF;

   --bms_output.put_line('Done in populate_metrics_denorm');
   IF AMS_DEBUG_HIGH_ON THEN
     write_msg('populate_metrics_denorm','Done in populate_metrics_denorm with status : '||TO_CHAR(retcode));
   END IF;


 END populate_metrics_denorm;




END Ams_Actmetrics_Engine_Pvt;

/
