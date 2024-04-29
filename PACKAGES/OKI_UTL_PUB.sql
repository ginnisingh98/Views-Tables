--------------------------------------------------------
--  DDL for Package OKI_UTL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_UTL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPUTLS.pls 115.7 2002/12/19 20:14:23 brrao noship $ */

--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_UTL_PUB
-- Type       : Public
-- Purpose    : This package contains procedure and functions that are common
--              to other packages
-- Modification History
-- 16-July-2001 mezra         Created
-- 26-Dec-2001  mezra         Added variables used across packages.
-- 04-Jan-2002  mezra         Remove all functions and procedures for the bin.
-- 03-Apr-2002  mezra         Added set verify off and whenever sqlerror
-- 26-NOV-2002  rpotnuru     NOCOPY Changes
-- 19-Dec-2002  brrao        UTF-8 Changes to Org Name
--
-- Notes      :
--
-- End of comments
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Global constant declaration
--------------------------------------------------------------------------------
  g_all_organization_id    CONSTANT NUMBER       := -1 ;
  g_all_organization_name  CONSTANT VARCHAR2(240) := 'All Organizations' ;
  g_all_customer_id        CONSTANT NUMBER       := -1 ;
  g_all_customer_name      CONSTANT VARCHAR2(60) := 'All Customers' ;
  g_all_salesrep_id        CONSTANT NUMBER       := -1 ;
  g_all_salesrep_name      CONSTANT VARCHAR2(60) := 'All Sales Representatives' ;
  g_all_k_category_code    CONSTANT VARCHAR2(30) := '-1' ;
  g_all_k_category_meaning CONSTANT VARCHAR2(30) := 'All Contract Categories' ;
  g_all_prod_category_code CONSTANT VARCHAR2(30) := '-1' ;
  g_all_time_id            CONSTANT VARCHAR2(30) := -1 ;
  g_all_time_name          CONSTANT VARCHAR2(30) := 'All Years' ;
  g_contract_limit         CONSTANT NUMBER       :=
                           fnd_profile.value('OKI_PROBLEM_K_THRESHOLD') ;

  g_oki_app_name           CONSTANT VARCHAR2(3)  := 'OKI' ;
  g_oki_tab_owner_name     CONSTANT VARCHAR2(3)  := 'OKI' ;

  g_msg_name_table_load_fail  CONSTANT VARCHAR(30) := 'OKI_TABLE_LOAD_FAILURE' ;
  g_msg_name_loc_in_prog_fail CONSTANT VARCHAR(30) := 'OKI_LOC_IN_PROG_FAILURE' ;
  g_msg_name_no_seq_fail      CONSTANT VARCHAR(30) := 'OKI_NO_SEQUENCE_FAILURE' ;
  g_msg_name_unexpected_fail  CONSTANT VARCHAR(30) := 'OKI_UNEXPECTED_FAILURE' ;
  g_msg_name_no_hrc_id_fail   CONSTANT VARCHAR(30) := 'OKI_NO_HRC_ID_FAILURE' ;

  g_msg_name_table_load_succ  CONSTANT VARCHAR(30) := 'OKI_TABLE_LOAD_SUCCESS' ;

  g_msg_tkn_table_load_succ   CONSTANT VARCHAR(30) := 'TABLE_NAME' ;

  -- Holds the current year start / end date information from GL periods
  g_summary_build_date    DATE   := NULL ;
  g_glpr_start_date       DATE   := NULL ;
  g_glpr_end_date         DATE   := NULL ;
  g_glpr_qtr_start_date   DATE   := NULL ;
  g_glpr_qtr_end_date     DATE   := NULL ;
  g_glpr_qtr_num          NUMBER := NULL ;
  g_glpr_year_start_date  DATE   := NULL ;
  g_glpr_year_end_date    DATE   := NULL ;
  g_period_year           NUMBER := NULL ;
  g_week_start_date       DATE   := NULL ;

  -- Holds the prior year start / end date information from GL periods
  g_py_summary_build_date    DATE   := NULL ;
  g_py_glpr_start_date       DATE   := NULL ;
  g_py_glpr_end_date         DATE   := NULL ;
  g_py_glpr_qtr_start_date   DATE   := NULL ;
  g_py_glpr_qtr_end_date     DATE   := NULL ;
  g_py_glpr_qtr_num          NUMBER := NULL ;
  g_py_glpr_year_start_date  DATE   := NULL ;
  g_py_glpr_year_end_date    DATE   := NULL ;
  g_py_period_year           NUMBER := NULL ;
  g_py_week_start_date       DATE   := NULL ;

  g_not_available   CONSTANT VARCHAR2(4) := 'n.a.' ;

  -- Amount to be displayed in the bins (In Millions)
  g_display_divisor CONSTANT NUMBER := 1000000 ;
--------------------------------------------------------------------------------
-- Global exception declaration
--------------------------------------------------------------------------------
  -- Exception to immediately exit the procedure
  g_excp_exit_immediate    EXCEPTION ;
  -- Exception when there are problems retrieving a sequence number
  g_excp_no_seq            EXCEPTION ;

--------------------------------------------------------------------------------
  -- Place holder function

--------------------------------------------------------------------------------
  FUNCTION place_holder
  RETURN  VARCHAR2 ;

END oki_utl_pub ;

 

/
