--------------------------------------------------------
--  DDL for Package HRI_BPL_BEN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_BEN_UTIL" AUTHID CURRENT_USER AS
/* $Header: hribbutl.pkh 120.0 2005/09/21 01:26:05 anmajumd noship $ */
--
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Name	:	HRI_BPL_BEN_UTIL
	Purpose	:	Contains all common functions and procedures for Benefits HRI.
------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
--
-- Returns Profile Value of ICX_DATE_FORMAT_MASK
FUNCTION get_date_display_format RETURN VARCHAR2;


-- Returns Profile Value of HRI_SET_EVENTS_ARCHIVE
FUNCTION get_archive_events RETURN VARCHAR2;


-- Returns Profile Value of HRI_ENBL_BEN_COL_EQ
FUNCTION enable_ben_col_evt_que RETURN BOOLEAN;


-- Returns Profile Value of BIS_GLOBAL_START_DAT
FUNCTION get_collect_start_date (p_process_code VARCHAR2, p_table_name VARCHAR2) RETURN VARCHAR2;


-- Returns Profile Value of HRI_BEN_COL_CURR_OE
FUNCTION get_curr_oe_coll_mode RETURN VARCHAR2;

-- Returns Mode of Refresh
FUNCTION get_full_refresh_flag (p_table_name VARCHAR2) RETURN VARCHAR2;
--
END HRI_BPL_BEN_UTIL;

 

/
