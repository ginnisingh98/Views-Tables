--------------------------------------------------------
--  DDL for Package PA_DISPLAY_PERIOD_MASKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DISPLAY_PERIOD_MASKS" AUTHID CURRENT_USER AS
/* $Header: PAFPPMKS.pls 120.0 2005/05/30 11:45:23 appldev noship $ */

     -- Package Variables.
  g_preceeding_end   DATE;
  g_suceeding_start  DATE;
  g_period_mask_id   pa_period_mask_details.period_mask_id%TYPE;
  g_get_mask_start   NUMBER := 0;
  g_get_mask_end     NUMBER := 0;


/*  get_current_period_start_date() will get the current periods start date
--  it MUST have the following parameters:
--  current_planning_period,
--	period_set_name,
--  time_phase_code,
--	and either accounterd_period_type set for 'GL'
--	OR pa_period_type set for 'PA'
--	it is called by get_periods()
*/

  FUNCTION get_current_period_start_date ( p_current_planning_period IN pa_budget_versions.current_planning_period%TYPE
                                           ,p_period_set_name        IN gl_sets_of_books.period_set_name%TYPE
										   ,p_time_phase_code        IN pa_proj_fp_options.cost_time_phased_code%TYPE
										   ,p_accounted_period_type  IN gl_sets_of_books.accounted_period_type%TYPE
										   ,p_pa_period_type         IN pa_implementations_all.pa_period_type%TYPE)
										   RETURN DATE;

/*   get_period_mask_start() returns the min from_anchor_start from pa_period_mask_details
--   it will not return rows that have an from_anchor_start with -99999 or 99999
--   these are flags for preceeding and suceeding buckets
--   this function is called from get_periods to populate the pl/sql table with the
--   before anchor date records from gl_periods
*/
  FUNCTION get_period_mask_start( p_period_mask_id IN pa_period_mask_details.period_mask_id%TYPE) RETURN NUMBER;


/*   get_period_mask_end() returns the max from_anchor_end from pa_period_mask_details
--   it will not return rows that have an from_anchor_start with -99999 or 99999
--   these are flags for preceeding and suceeding buckets
--   this function is called from get_periods to populate the pl/sql table with the
--   after anchor date records from gl_periods
*/

  FUNCTION get_period_mask_end  ( p_period_mask_id IN pa_period_mask_details.period_mask_id%TYPE) RETURN NUMBER;

  TYPE period_names_type IS TABLE OF gl_periods%ROWTYPE INDEX BY BINARY_INTEGER;

    periods_tab period_names_type;

/*
--  get_periods() is the main function of this package
--  it populates the periods_tab pl/sql table with rows of data from gl_periods
--  within the masks start and end periods
--  it will also set the global variables g_preceeding_end and g_suceeding_start
--  these will be used for the proceeding buckets end period and suceeding buckets start period
--  get_periods will return 1 if it populates periods_tab pl/sql table successfully
*/

  FUNCTION get_periods ( p_budget_version_id  IN  pa_budget_versions.budget_version_id%TYPE,
                         p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE DEFAULT -1) RETURN NUMBER;


/*
--  get_min_start_period, get_max_end_period, get_min_start_date, get_max_end_date
--  are used by the start_period, end_period, start_date, and end_date functions
*/
  FUNCTION get_min_start_period    RETURN VARCHAR2;

  FUNCTION get_max_end_period      RETURN VARCHAR2;

  FUNCTION get_min_start_date      RETURN DATE;

  FUNCTION get_max_end_date        RETURN DATE;



/*
--  start_period(), end_period(), display_name(), start_date(), and end_date()
--  are the functions to be used in select statements calling this package
--  pass the parameter from_anchor_postion
*/


  FUNCTION start_period ( p_from_anchor_position IN pa_period_mask_details.from_anchor_position%TYPE ) RETURN VARCHAR2;

  FUNCTION end_period   ( p_from_anchor_position IN pa_period_mask_details.from_anchor_position%TYPE ) RETURN VARCHAR2;

  FUNCTION display_name ( p_from_anchor_position IN pa_period_mask_details.from_anchor_position%TYPE ) RETURN VARCHAR2;

  FUNCTION start_date   ( p_from_anchor_position IN pa_period_mask_details.from_anchor_position%TYPE ) RETURN DATE;

  FUNCTION end_date     ( p_from_anchor_position IN pa_period_mask_details.from_anchor_position%TYPE ) RETURN DATE;

   -- This will be called from the EditPlanLines Page to save the current planning period.
   -- Bug Fix 3975683
   -- Added Record Version Numbers.

  PROCEDURE update_current_pp (p_budget_version_id       IN  pa_budget_versions.budget_version_id%TYPE,
                               p_current_planning_period IN pa_budget_versions.current_planning_period%TYPE,
                               p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
                               p_bud_rec_ver_num         IN pa_budget_versions.record_version_number%TYPE,
                               p_fp_rec_ver_num          IN pa_proj_fp_options.record_version_number%TYPE,
                               X_Return_Status           OUT NOCOPY Varchar2,
                               X_Msg_Count               OUT NOCOPY Number,
        	               X_Msg_Data                OUT NOCOPY Varchar2);


END pa_display_period_masks;

 

/
