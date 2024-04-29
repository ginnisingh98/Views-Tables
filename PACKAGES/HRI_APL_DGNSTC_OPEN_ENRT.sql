--------------------------------------------------------
--  DDL for Package HRI_APL_DGNSTC_OPEN_ENRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_APL_DGNSTC_OPEN_ENRT" AUTHID CURRENT_USER AS
/* $Header: hriadgoe.pkh 120.0 2005/10/10 08:29:41 abparekh noship $ */
--
   FUNCTION get_pgm_for_open_le
      RETURN VARCHAR2;

--
   FUNCTION get_actn_itm_for_open_le
      RETURN VARCHAR2;

--
   FUNCTION get_ben_user_valid_setup
      RETURN VARCHAR2;

--
   FUNCTION get_pgm_witn_no_elctbl_chc
      RETURN VARCHAR2;

--
   FUNCTION get_pgm_with_no_actn_item
      RETURN VARCHAR2;

--
   FUNCTION get_emp_with_open_mnl_ler
      RETURN VARCHAR2;

--
   FUNCTION get_pln_with_no_opt
      RETURN VARCHAR2;

--
   FUNCTION get_pgm_with_rqd_actn_item
      RETURN VARCHAR2;

--
   FUNCTION get_pgm_with_inactive_status
      RETURN VARCHAR2;
--
   FUNCTION pgm_has_pln_with_rqd_actn_item (cv_pgm_id                   number,
                                            cv_end_date                 date,
                                            cv_dpnt_dsgn_lvl_cd         varchar2
                                            )
      RETURN VARCHAR2;
--
END hri_apl_dgnstc_open_enrt;

 

/
