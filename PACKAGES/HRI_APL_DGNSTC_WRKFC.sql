--------------------------------------------------------
--  DDL for Package HRI_APL_DGNSTC_WRKFC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_APL_DGNSTC_WRKFC" AUTHID CURRENT_USER AS
/* $Header: hriadgwf.pkh 120.2 2006/12/05 09:29:18 smohapat noship $ */

FUNCTION get_missing_rates_sql(p_parameter_value   IN VARCHAR2)
     RETURN VARCHAR2;

FUNCTION get_user_not_in_suph
     RETURN VARCHAR2;

FUNCTION get_user_unassigned
     RETURN VARCHAR2;

FUNCTION get_no_asg_proj_end_date
     RETURN VARCHAR2;

FUNCTION get_mul_asg_breakup
     RETURN VARCHAR2;

FUNCTION get_total_hd
     RETURN VARCHAR2;

FUNCTION get_user_valid_setup
     RETURN VARCHAR2;

FUNCTION get_total_sal
     RETURN VARCHAR2;

FUNCTION get_no_review
     RETURN VARCHAR2;

FUNCTION get_total_asg
     RETURN VARCHAR2;

FUNCTION get_total_asg_by_asgtype
     RETURN VARCHAR2;

FUNCTION get_no_sprvsr
     RETURN VARCHAR2;

FUNCTION get_mul_asg
     RETURN VARCHAR2;

FUNCTION get_term_sprvsr
     RETURN VARCHAR2;

FUNCTION get_no_sal
     RETURN VARCHAR2;

FUNCTION get_dbl_cnt_abv
     RETURN VARCHAR2;

FUNCTION get_smlt_abv
     RETURN VARCHAR2;

FUNCTION get_no_abv
     RETURN VARCHAR2;

FUNCTION get_no_term_rsn
     RETURN VARCHAR2;

FUNCTION get_sup_loop_details
     RETURN VARCHAR2;

FUNCTION get_incomplete_req_sets
     RETURN VARCHAR2;

FUNCTION get_vac_wtht_mngrs
     RETURN VARCHAR2;

FUNCTION get_applcnt_wtht_vac
     RETURN VARCHAR2;

FUNCTION get_user_linemgr_info
     RETURN VARCHAR2;

FUNCTION get_user_anlstmgr_info
     RETURN VARCHAR2;

FUNCTION get_user_deptmgr_info
     RETURN VARCHAR2;

FUNCTION get_user_orgmgr_info
     RETURN VARCHAR2;

FUNCTION get_unassg_gndr_info
     RETURN VARCHAR2;

END hri_apl_dgnstc_wrkfc;

/
