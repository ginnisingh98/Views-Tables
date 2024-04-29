--------------------------------------------------------
--  DDL for Package IGS_PS_FAC_CREDT_WRKLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_FAC_CREDT_WRKLOAD" AUTHID CURRENT_USER AS
 /* $Header: IGSPS74S.pls 120.0 2005/06/01 22:28:35 appldev noship $
   CHANGE HISTORY
   WHO               : ayedubat
   WHEN              : 24-MAY-2001
   WHAT              : Added two new Functions ,calc_total_work_load_lab and
                       calc_total_work_load_lecture */

  FUNCTION prgp_get_lead_instructor(
    p_uoo_id IN NUMBER)
  RETURN VARCHAR2;
  PRAGMA restrict_references(prgp_get_lead_instructor,wnds);

  FUNCTION calc_total_credit_point (
    p_instructor_id IN NUMBER)
  RETURN NUMBER;
  PRAGMA restrict_references(calc_total_credit_point,wnds,wnps);

  FUNCTION calc_total_work_load (
    p_instructor_id IN NUMBER)
  RETURN NUMBER;
  PRAGMA restrict_references(calc_total_work_load,wnds,wnps);

  FUNCTION calc_total_work_load_lab (
    p_instructor_id IN NUMBER)
  RETURN NUMBER;
  PRAGMA restrict_references(calc_total_work_load_lab,wnds,wnps);

  FUNCTION calc_total_work_load_lecture (
    p_instructor_id IN NUMBER)
  RETURN NUMBER;
  PRAGMA restrict_references(calc_total_work_load_lecture,wnds,wnps);

  PROCEDURE calculate_teach_work_load (
     p_uoo_id 		   IN   igs_ps_usec_tch_resp_v.uoo_id%TYPE,
     p_percent_allocation  IN   igs_ps_usec_tch_resp_v.percentage_allocation%TYPE,
     p_wl_lab 		   OUT NOCOPY  igs_ps_usec_tch_resp_v.instructional_load_lab%TYPE,
     p_wl_lecture 	   OUT NOCOPY  igs_ps_usec_tch_resp_v.instructional_load_lecture%TYPE,
     p_wl_other 	   OUT NOCOPY  igs_ps_usec_tch_resp_v.instructional_load%TYPE
    );

  FUNCTION validate_workload(p_n_uoo_id IN NUMBER,
			     p_n_tot_wl_lec OUT NOCOPY NUMBER,
			     p_n_tot_wl_lab OUT NOCOPY NUMBER,
			     p_n_tot_wl OUT NOCOPY NUMBER) RETURN BOOLEAN;

  FUNCTION get_validation_type(p_c_unit_cd IN VARCHAR2,
                               p_n_ver_num IN NUMBER) RETURN VARCHAR2;

END igs_ps_fac_credt_wrkload;

 

/
