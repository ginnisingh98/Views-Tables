--------------------------------------------------------
--  DDL for Package HXC_GENERIC_RETRIEVAL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_GENERIC_RETRIEVAL_UTILS" AUTHID CURRENT_USER as
/* $Header: hxcretutl.pkh 120.5.12010000.3 2009/08/09 14:51:28 amakrish ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_generic_retrieval_utils.';  -- Global package name

TYPE r_ret_ranges IS RECORD (
  rtr_grp_id NUMBER(15)
 ,start_date DATE
 ,stop_date DATE);

TYPE t_ret_ranges IS TABLE OF r_ret_ranges INDEX BY BINARY_INTEGER;

TYPE r_ret_rule IS RECORD (
 rtr_grp_id             NUMBER(15)
,time_recipient_id	hxc_time_recipients.time_recipient_id%TYPE
,status			VARCHAR2(40)
,outcome_exists		VARCHAR2(1)
,outcome_start		BINARY_INTEGER
,outcome_stop		BINARY_INTEGER );

TYPE t_ret_rule IS TABLE OF r_ret_rule INDEX BY BINARY_INTEGER;

TYPE r_rtr_exists IS RECORD (
 rtr_start BINARY_INTEGER
,rtr_stop  BINARY_INTEGER );

TYPE t_rtr_exists IS TABLE OF r_rtr_exists INDEX BY BINARY_INTEGER;

TYPE r_pref IS RECORD (
 prefs_ok        varchar2(1)
,rtr_start      BINARY_INTEGER
,rtr_end        BINARY_INTEGER );

TYPE t_pref IS TABLE OF r_pref INDEX BY BINARY_INTEGER;

TYPE r_app_set IS RECORD (
  app_set_ok VARCHAR2(1) );

TYPE t_app_set IS TABLE OF r_app_set INDEX BY BINARY_INTEGER;

TYPE r_resource IS RECORD ( resource_id hxc_time_building_blocks.resource_id%TYPE
                          , start_time  hxc_time_building_blocks.start_time%TYPE
                          , stop_time   hxc_time_building_blocks.stop_time%TYPE );

TYPE t_resource IS TABLE OF r_resource INDEX BY BINARY_INTEGER;

g_resources t_resource;

TYPE r_rtr_outcome IS RECORD (   rtr_grp_id number(15)
			,	time_recipient_id hxc_time_recipients.time_recipient_id%TYPE
			,	start_time	  hxc_time_building_blocks.start_time%TYPE
			,	stop_time	  hxc_time_building_blocks.stop_time%TYPE );

TYPE t_rtr_outcome IS TABLE OF r_rtr_outcome INDEX BY BINARY_INTEGER;

TYPE r_errors IS RECORD ( exception_description hxc_transaction_details.exception_description%TYPE );

TYPE t_errors IS TABLE OF r_errors INDEX BY BINARY_INTEGER;


-- Bug 8366309
-- Added the below data structure to hold preferences for the employee.

-- This is a record with Flag (Y/N) and date range
-- for rules evaluation pref.
TYPE RULES_LIST IS RECORD
( flag    VARCHAR2(2),
  start_date DATE,
  end_date   DATE
);

-- Here is a table of the above record type.
TYPE RULES_TAB  IS TABLE OF RULES_LIST INDEX BY BINARY_INTEGER ;


-- Here is a record of the table above.
TYPE OTM_RULES_REC  IS RECORD
( otm_rules RULES_TAB );

-- A table of the above record type -- effectively, a table of tables.
TYPE RESOURCE_PREF_LIST IS TABLE OF OTM_RULES_REC INDEX BY BINARY_INTEGER;

-- Instantiated a global object of the above type
g_res_pref_list RESOURCE_PREF_LIST ;

-- Each of the resources you are considering would have one record
-- in the above table.  So effectively, each resource would have
-- one table of preferences, with flag, and date ranges specified.







-- public function
--   time_bld_blk_changed
--
-- description
--   This function returns TRUE if the latest version of the
--   time building block specified by P_BB_ID has a greater
--   Object Version Number in the time store than that specified
--   by P_BB_OVN
--
-- parameters
--   p_bb_id         -  time building block id
--   p_bb_ovn        -  time building block object version number

FUNCTION time_bld_blk_changed ( p_bb_id	 NUMBER
		,		p_bb_ovn NUMBER )RETURN BOOLEAN;

PROCEDURE parse_resources (
		    p_process_id   NUMBER
		,   p_ret_tr_id    NUMBER
		,   p_prefs IN OUT NOCOPY t_pref
		,   p_ret_rules IN OUT NOCOPY t_ret_rule
		,   p_rtr_outcomes IN OUT NOCOPY t_rtr_outcome
		,   p_errors IN OUT NOCOPY t_errors );

-- Added p_attribute_category for Absences Integration (Bug 8779478)
PROCEDURE chk_retrieve (
			p_resource_id	NUMBER
		,	p_bb_status	VARCHAR2
                ,       p_bb_deleted    VARCHAR2
		,	p_bb_start_time	DATE
		,	p_bb_stop_time	DATE
		,       p_bb_id         NUMBER
		,       p_bb_ovn        NUMBER
		,	p_attribute_category  VARCHAR2
                ,       p_process      VARCHAR2
		,   	p_prefs		t_pref
		,   	p_ret_rules	t_ret_rule
		,	p_rtr_outcomes	t_rtr_outcome
                ,       p_tc_bb_id      NUMBER
                ,       p_tc_bb_ovn     NUMBER
		,	p_timecard_retrieve IN OUT NOCOPY BOOLEAN
		,	p_day_retrieve	    IN OUT NOCOPY BOOLEAN
                ,       p_tc_locked         IN OUT NOCOPY BOOLEAN
		,       p_tc_first_lock     IN OUT NOCOPY BOOLEAN
		,	p_bb_skipped_reason	OUT NOCOPY VARCHAR2 );

PROCEDURE set_parent_statuses;

PROCEDURE recovery ( p_process_id     NUMBER
		   , p_process        VARCHAR2 );

FUNCTION chk_terminated ( p_conc_request_id  NUMBER ) RETURN BOOLEAN;

FUNCTION get_ret_criteria RETURN VARCHAR2;



-- Bug 8366309
-- Added new parameters for chk_need_adj
-- and a new function to check preferences.

FUNCTION chk_need_adj ( p_tc_id           NUMBER ,
                        p_tc_ovn          NUMBER ,
                        p_resource_id     NUMBER ,
                        p_date_earned     DATE   ,
                        p_bb_id           NUMBER ,
                        p_bb_ovn          NUMBER ,
                        p_action          VARCHAR2,
                        p_retr_process_id NUMBER  ) RETURN BOOLEAN ;


FUNCTION chk_otm_pref ( p_resource_id     NUMBER,
                        p_date            DATE,
                        p_process_id      NUMBER )
RETURN BOOLEAN ;


-- OTL-Absences Integration (Bug 8779478)
FUNCTION absence_link_exists ( p_element_type_id NUMBER )
RETURN BOOLEAN;


end hxc_generic_retrieval_utils;

/
