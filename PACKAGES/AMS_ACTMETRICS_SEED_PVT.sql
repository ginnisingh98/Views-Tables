--------------------------------------------------------
--  DDL for Package AMS_ACTMETRICS_SEED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTMETRICS_SEED_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvamss.pls 120.2 2005/08/26 15:29:59 dmvincen noship $ */
--------------------------------------------------------------------------------
--
-- NAME
--    AMS_ACTMETRICS_SEED_PVT 12.0
--
-- HISTORY
-- 30-Aug-2001   dmvincen     Created
-- 05-Sep-2001   dmvincen     Changed paramters to primatives.
-- 11-Aug-2005   dmvincen     Added Inferred Calculations.
--
-- Global variables and constants.
--

--
-- Start type definition
--
TYPE num_table_type IS TABLE
  OF NUMBER INDEX BY BINARY_INTEGER;
--
-- End type definition
--


FUNCTION  convert_currency(
   p_from_currency          VARCHAR2
  ,p_from_amount            NUMBER) return NUMBER;

FUNCTION  convert_to_trans_currency(
   p_trans_currency          VARCHAR2
  ,p_from_amount            NUMBER) return NUMBER;

-- NAME
--     Calculate_Seeded_Metrics
--
-- PURPOSE
--
-- NOTES
--
-- HISTORY
-- 30-Aug-2001   dmvincen   Created.
--
PROCEDURE Calculate_Seeded_Metrics(
          p_arc_act_metric_used_by VARCHAR2 := NULL,
          p_act_metric_used_by_id NUMBER := NULL);


-- NAME
--    CALCULATE_TARGET_GROUP
--
-- PURPOSE
--
-- NOTES
--
-- HISTORY
-- 20-Aug-2003   sunkumar   Created.
--
PROCEDURE Calculate_Target_Group(
          p_arc_act_metric_used_by VARCHAR2 := NULL,
          p_act_metric_used_by_id NUMBER := NULL);



-- NAME
--     CALCULATE_SEEDED_LIST_METRICS
--
-- PURPOSE
--
-- NOTES
--
-- HISTORY
-- 20-Aug-2003   sunkumar   Created.
--
PROCEDURE Calculate_Seeded_List_Metrics(
          p_arc_act_metric_used_by VARCHAR2 := null,
          p_act_metric_used_by_id NUMBER := null);

-- NAME
--     CALCULATE_INFERRED_METRICS
--
-- PURPOSE
--
-- NOTES
--
-- HISTORY
-- 11-Aug-2005   dmvincen   Created.
--
PROCEDURE Calculate_Inferred_Metrics(
          p_arc_act_metric_used_by VARCHAR2,
          p_act_metric_used_by_id NUMBER);

PROCEDURE Calculate_Inferred_Metrics;

-- NAME
--     Update_Actmetrics_Bulk
--
-- PURPOSE
--     Bulk update the activity metrics for given ids and actual values.
--
-- NOTES
--     Only immediate parents are updated to be dirty.
--     To Do: The Costs and Revenue value must be converted.
--
-- HISTORY
-- 30-Aug-2001   dmvincen   Created.
--
PROCEDURE Update_Actmetrics_Bulk(
          p_actmetric_id_table IN num_table_type,
          p_actual_value_table IN num_table_type);

END Ams_Actmetrics_Seed_Pvt;

 

/
