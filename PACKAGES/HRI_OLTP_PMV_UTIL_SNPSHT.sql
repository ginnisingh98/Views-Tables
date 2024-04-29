--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_UTIL_SNPSHT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_UTIL_SNPSHT" AUTHID CURRENT_USER AS
/* $Header: hrioputs.pkh 120.1 2005/09/20 05:10 jrstewar noship $ */

FUNCTION is_manager_senior(p_supervisor_id   IN NUMBER,
                           p_effective_date  IN DATE)
           RETURN BOOLEAN;

FUNCTION use_wrkfc_snpsht_for_mgr(p_supervisor_id   IN NUMBER,
                                  p_effective_date  IN DATE)
           RETURN BOOLEAN;

FUNCTION use_wcnt_chg_snpsht_for_mgr(p_supervisor_id   IN NUMBER,
                                     p_effective_date  IN DATE)
           RETURN BOOLEAN;

FUNCTION use_absnc_snpsht_for_mgr(p_supervisor_id   IN NUMBER,
                                  p_effective_date  IN DATE)
           RETURN BOOLEAN;


END hri_oltp_pmv_util_snpsht;

 

/
