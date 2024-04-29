--------------------------------------------------------
--  DDL for Package AMS_METRICCUSTOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_METRICCUSTOM_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvrcss.pls 120.0 2005/06/01 02:36:52 appldev noship $ */
---------------------------------------------------------------------
-- FUNCTION
--     get_rollup_value
--
-- PURPOSE
--    Get the rollup values for the events and campaigns
--
-- PARAMETERS
--    p_act_met_id: the new record to be inserted
-- RETURNS
--   l_tot_value :  sum of the roolup metrics value
--
-- NOTES
--    1. Checks whether metrics is used by campaigns.
--    2. Checks for the child campaign if exists and select the functional actual value, functional
--       forecasted value  used by it (passing the category id and sub_category_id) and sum it up.
--    3. Checks whether the metrics is used by events.
--    4. Find out the sub events associated to it and get the functional actual value,functional
--       forcasted value and it adds it up.
--    5. Calls  update API and passes the functional actual value .
--    6. Returns the total sum
---------------------------------------------------------------------

FUNCTION get_rollup_value (
  p_act_met_id IN NUMBER ) RETURN NUMBER;

--------------------------------------------------------------------

END ams_metriccustom_pvt;

 

/
