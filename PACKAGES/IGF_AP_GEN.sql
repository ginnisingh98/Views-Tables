--------------------------------------------------------
--  DDL for Package IGF_AP_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_GEN" AUTHID CURRENT_USER AS
/* $Header: IGFAP36S.pls 120.2 2005/12/11 03:59:03 appldev ship $ */

/*=========================================================================
--   Copyright (c) 2003 Oracle Corp. Redwood Shores, California, USA
--                               All rights reserved.
-- ========================================================================
--
--  DESCRIPTION
--         PL/SQL        body for package: / IGF_AP_GEN
--
--  NOTES
--  Does all the generic functionalities required by legacy processes
----------------------------------------------------------------------------------
--  HISTORY
----------------------------------------------------------------------------------
--  who         when            what
--  bvisvana    09-Dec-2005     Bug # 4773795 Added procedure update_preflend_todo_status
--  veramach    11-Dec-2003     Bug# 3184891 Removed procedure write_log
--  brajendr    16-Oct-2003     Bug # 3085558, Added function get_isir_value
--
--  rasahoo     27-Nov-2003     Bug # 3026594  Added the fucntions get_cumulative_coa_amt
--                              and get_individual_coa_amt
----------------------------------------------------------------------------------*/

  TYPE igf_ap_lookups_table IS TABLE OF VARCHAR2(227) INDEX BY BINARY_INTEGER;
  TYPE igf_ap_lkup_hash_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE l_lookups_table IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  lookups_table   DBMS_UTILITY.uncl_array;

  l_lookups_rec      l_lookups_table;
  l_lookups_type_rec l_lookups_table;

  lookup_hash_table   igf_ap_lkup_hash_table;
  indx NUMBER :=0;
  g_request_id NUMBER := NULL;


  FUNCTION get_lookup_meaning(
                              p_lookup_type  IN  VARCHAR2,
                              p_lookup_code  IN  VARCHAR2
                             ) RETURN VARCHAR2 ;

  FUNCTION get_aw_lookup_meaning(
                                 p_lookup_type    IN  VARCHAR2,
                                 p_lookup_code    IN  VARCHAR2,
                                 p_sys_award_year IN  VARCHAR2
                                ) RETURN VARCHAR2 ;

  FUNCTION check_profile RETURN VARCHAR2;

  PROCEDURE check_person(
                         p_person_number       IN           igf_aw_li_coa_ints.person_number%TYPE,
                         p_ci_cal_type         IN           igs_ca_inst.cal_type%TYPE,
                         p_ci_sequence_number  IN           igs_ca_inst.sequence_number%TYPE,
                         p_person_id           OUT  NOCOPY  igf_ap_fa_base_rec_all.person_id%TYPE,
                         p_fa_base_id          OUT  NOCOPY  igf_ap_fa_base_rec_all.base_id%TYPE
                        );


  FUNCTION VALIDATE_CAL_INST(
                           p_cal_cat         IN            igs_ca_type.s_cal_cat%TYPE,
                           p_alt_code_one    IN            igs_ca_inst.alternate_code%TYPE,
                           p_alt_code_two    IN            igs_ca_inst.alternate_code%TYPE,
                           p_cal_type        IN OUT NOCOPY igs_ca_inst.cal_type%TYPE,
                           p_sequence_number IN OUT NOCOPY igs_ca_inst.sequence_number%TYPE
                          ) RETURN BOOLEAN;

  FUNCTION check_batch(
                       p_batch_id     IN NUMBER,
                       p_batch_type   IN VARCHAR2
                      ) RETURN VARCHAR2;

  FUNCTION get_isir_value(
                          p_base_id          IN igf_ap_fa_base_rec_all.base_id%TYPE,
                          p_sar_field_name   IN igf_fc_sar_cd_mst.sar_field_name%TYPE
                         ) RETURN VARCHAR2;

  FUNCTION get_indv_efc_4_term(
                               p_base_id         IN igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_cal_type        IN igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                               p_sequence_number IN igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                               p_isir_id         IN igf_ap_isir_matched_all.isir_id%TYPE
                              ) RETURN NUMBER;

  FUNCTION get_individual_coa_amt(
                                  p_ld_start_dt    IN  DATE,
                                  p_base_id        IN  igf_ap_fa_base_rec_all.base_id%TYPE
                                 ) RETURN NUMBER;

  FUNCTION get_cumulative_coa_amt(
                                  p_ld_start_dt    IN  DATE,
                                  p_base_id        IN  igf_ap_fa_base_rec_all.base_id%TYPE
                                 ) RETURN NUMBER;

PROCEDURE update_td_status(
                           p_base_id                IN         igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_item_sequence_number   IN         igf_ap_td_item_inst_all.item_sequence_number%TYPE,
                           p_status                 IN         igf_ap_td_item_inst_all.status%TYPE,
                           p_clprl_id               IN         igf_sl_cl_pref_lenders.clprl_id%TYPE DEFAULT NULL,
                           p_return_status          OUT NOCOPY VARCHAR2
                          );

PROCEDURE update_preflend_todo_status ( p_person_id	     IN igf_ap_fa_base_rec_all.person_id%TYPE,
				                                p_return_status  OUT NOCOPY VARCHAR2
				                              ) ;

END igf_ap_gen;

 

/
