--------------------------------------------------------
--  DDL for Package IGF_AP_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_GEN_001" AUTHID CURRENT_USER AS
  /* $Header: IGFAP44S.pls 120.1 2005/07/05 08:39:51 appldev ship $ */

  --  Function to get Program Attempt Start Date
  FUNCTION get_prog_att_start_dt(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
  RETURN DATE;

  -- Function to get Anticipated Completion Date
  FUNCTION get_anticip_compl_date(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
  RETURN DATE;

  -- Function to get Class Standing
  FUNCTION get_class_standing(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
  RETURN VARCHAR2;

  --  Function to get Program Type
  FUNCTION get_enrl_program_type(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
  RETURN VARCHAR2;

  --  Function to get Key Program
  PROCEDURE get_key_program(cp_base_id        IN igf_ap_fa_base_rec_all.base_id%TYPE,
                            cp_course_cd      OUT NOCOPY VARCHAR2,
                            cp_version_number OUT NOCOPY NUMBER);

  -- Procedure to get enrollment term record details
  PROCEDURE get_term_enrlmnt_dtl(cp_fa_base_id IN IGF_AP_FA_BASE_REC_ALL.BASE_ID%TYPE,
                                     cp_term_enr_dtl_rec OUT NOCOPY IGS_EN_SPA_TERMS%ROWTYPE);

  FUNCTION get_enr_eff_dt_alias_val(cp_cal_type IN igs_Ca_inst.cal_type%TYPE,
                                cp_sequence_number IN igs_ca_inst.sequence_number%TYPE)
  RETURN DATE;

  --FA 156 Changes
  ---Procedure to get Effective Term Dates
  PROCEDURE get_term_dates(
                           p_base_id            IN igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_ld_cal_type        IN igs_Ca_inst.cal_type%TYPE,
                           p_ld_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                           p_ld_start_date      OUT NOCOPY DATE,
                           p_ld_end_date        OUT NOCOPY DATE
                          );

  ---Procedure to get Effective Date
  FUNCTION get_date_alias_val(
                              p_base_id         IN igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_cal_type        IN igs_ca_inst.cal_type%TYPE,
                              p_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                              p_date_alias      IN igs_ca_da_inst.dt_alias%TYPE
                             ) RETURN DATE;

  PROCEDURE get_context_data_for_term(
                                      p_base_id            IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                                      p_ld_cal_type        IN  igs_ca_inst.cal_type%TYPE,
                                      p_ld_sequence_number IN  igs_ca_inst.sequence_number%TYPE,
                                      p_program_cd         OUT NOCOPY igs_ps_ver_all.course_cd%TYPE,
                                      p_version_num        OUT NOCOPY igs_ps_ver_all.version_number%TYPE,
                                      p_program_type       OUT NOCOPY igs_ps_ver_all.course_type%TYPE,
                                      p_org_unit           OUT NOCOPY igs_ps_ver_all.responsible_org_unit_cd%TYPE
                                     );

END IGF_AP_GEN_001;

 

/
