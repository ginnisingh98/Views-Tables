--------------------------------------------------------
--  DDL for Package HRI_BPL_WRKFC_EVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_WRKFC_EVT" AUTHID CURRENT_USER AS
/* $Header: hribwevt.pkh 120.0.12000000.2 2007/04/12 12:08:38 smohapat noship $ */

FUNCTION get_promotion_ind
   (p_assignment_id      IN NUMBER,
    p_business_group_id  IN NUMBER,
    p_effective_date     IN DATE,
    p_new_job_id         IN NUMBER,
    p_new_pos_id         IN NUMBER,
    p_new_grd_id         IN NUMBER,
    p_old_job_id         IN NUMBER,
    p_old_pos_id         IN NUMBER,
    p_old_grd_id         IN NUMBER)
     RETURN NUMBER;

END hri_bpl_wrkfc_evt;

 

/
