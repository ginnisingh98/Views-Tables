--------------------------------------------------------
--  DDL for Package IGF_AW_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_GEN_005" AUTHID CURRENT_USER AS
/* $Header: IGFAW14S.pls 120.0 2005/06/02 15:53:50 appldev noship $ */
  /*======================================================================+
  |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
  |                            All rights reserved.                       |
  +=======================================================================+
  |                                                                       |
  | DESCRIPTION                                                           |
  |      PL/SQL spec for package: IGF_AW_GEN_005                          |
  |                                                                       |
  | NOTES                                                                 |
  |      Holds all the generic Routines                                   |
  |                                                                       |
  | HISTORY                                                               |
  | Who             When            What                                  |
  | veramach        Oct 2004        FA 152/FA 137 - Changes to wrappers to|
  |                                 bring in the awarding period setup    |
  | veramach        1-NOV-2003      FA 125 Multiple Distribution Methods  |
  |                                 Added procedures update_plan,         |
  |                                 update_dist_plan,delete_plan,         |
  |                                 check_plan_code                       |
  | brajendr        08-Jan-2003     Bug # 2710314                         |
  |                                 Added a Function validate_student_efc |
  |                                 for checking the validity of EFC      |
  *======================================================================*/


  PROCEDURE update_plan(
                        p_adplans_id   IN         igf_aw_awd_dist_plans.adplans_id%TYPE,
                        p_method_code  IN         VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2
                       );

  PROCEDURE update_dist_plan(
                              p_award_id igf_aw_award.award_id%TYPE
                            );

  PROCEDURE check_plan_code(
                            p_adplans_id IN         igf_aw_awd_dist_plans.adplans_id%TYPE,
                            p_result     OUT NOCOPY VARCHAR2
                           );

  PROCEDURE delete_plan(
                        p_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                        p_adterms_id igf_aw_dp_terms.adterms_id%TYPE  DEFAULT NULL
                       );

  FUNCTION get_stud_hold_effect(
                                p_orig       IN  VARCHAR2,
                                p_person_id  IN  igf_ap_fa_base_rec_all.person_id%TYPE,
                                p_fund_code  IN  igf_aw_fund_mast_all.fund_code%TYPE DEFAULT NULL,
                                p_date       IN  DATE DEFAULT NULL
                               ) RETURN VARCHAR2;


  FUNCTION validate_student_efc(
                                p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                                p_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                               ) RETURN VARCHAR2;
END igf_aw_gen_005;

 

/
