--------------------------------------------------------
--  DDL for Package Body HRI_BPL_BEN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_BEN_UTIL" AS
/* $Header: hribbutl.pkb 120.1 2005/11/14 08:08:42 bmanyam noship $ */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Name	:	HRI_BPL_BEN_UTIL
	Purpose	:	Contains all common functions and procedures for Benefits HRI.
-------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

--
-- Returns Profile Value of ICX_DATE_FORMAT_MASK
FUNCTION get_date_display_format
RETURN VARCHAR2 IS
    l_ret_val VARCHAR2(255);
BEGIN
    FND_PROFILE.GET(name => 'ICX_DATE_FORMAT_MASK',
                    val => l_ret_val);
    RETURN l_ret_val;
END get_date_display_format;
--

-- Returns Profile Value of HRI_SET_EVENTS_ARCHIVE
-- Identifies whether Event Quey table has to be Archived or Not.
-- Default 'No'
FUNCTION get_archive_events
RETURN VARCHAR2 IS
    l_ret_val VARCHAR2(255);
BEGIN
    FND_PROFILE.GET(name => 'HRI_SET_EVENTS_ARCHIVE',
                     val => l_ret_val);

    RETURN NVL(l_ret_val,'N');
END get_archive_events;
--

-- Returns Profile Value of HRI_ENBL_BEN_COL_EQ
-- Identifies whether BEN OLTP should log events in DBI Event Queue tables.
-- Default 'False'
FUNCTION enable_ben_col_evt_que
RETURN BOOLEAN IS
    l_col_evt BOOLEAN;
    l_ret_val VARCHAR2(255);
BEGIN
    FND_PROFILE.GET(name => 'HRI_ENBL_BEN_COL_EQ',
                     val => l_ret_val);

    IF (l_ret_val = 'Y') THEN
      l_col_evt := TRUE;
    ELSE
      l_col_evt := FALSE;
    END IF;

    RETURN l_col_evt;
END enable_ben_col_evt_que;
--

-- This is the start date for Collection, in case of Incremental Refresh.
-- This values is only passed to concurrent program.
-- Not actually used functionally, becoz all events in Event queue
-- will be collected, irrespective of start date.
FUNCTION get_collect_start_date (p_process_code VARCHAR2, p_table_name VARCHAR2)
RETURN VARCHAR2 IS
    l_start_date DATE;
    l_ret_val VARCHAR2(255);
BEGIN
    -- 4276676
    l_ret_val := hri_bpl_conc_log.get_last_collect_to_date(p_process_code, p_table_name);
    --
    RETURN l_ret_val;

END get_collect_start_date;
--

-- Returns Profile Value of HRI_BEN_COL_CURR_OE
-- Enables Benefits Collection for the Current Open Enrollment Only
-- Default 'No'
FUNCTION get_curr_oe_coll_mode
RETURN VARCHAR2 IS
    l_ret_val VARCHAR2(255);
BEGIN
    --
    FND_PROFILE.GET(name => 'HRI_BEN_COL_CURR_OE',
                     val => l_ret_val);

    RETURN NVL(l_ret_val,'N');
    --
END get_curr_oe_coll_mode;

-- Returns Mode of Refresh
FUNCTION get_full_refresh_flag (p_table_name VARCHAR2)
RETURN VARCHAR2 IS
 l_ret_val VARCHAR2(255);

BEGIN
    -- 4276676
    l_ret_val := hri_bpl_conc_admin.get_full_refresh_flag(p_table_name);
    --
    RETURN l_ret_val;
    --
END get_full_refresh_flag;

END HRI_BPL_BEN_UTIL;

/
