--------------------------------------------------------
--  DDL for Package IGF_AP_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_SS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP30S.pls 120.2 2006/02/08 23:08:44 ridas ship $ */


  PROCEDURE set_internal_isir(
                              p_isir_id IN IGF_AP_ISIR_MATCHED_ALL.ISIR_ID%TYPE,
                              p_ret_isir_id IN OUT NOCOPY IGF_AP_ISIR_MATCHED_ALL.ISIR_ID%TYPE
                             );

  FUNCTION get_pid(
                   p_pid_grp IN igs_pe_persid_group.group_id%TYPE,
                   p_status  OUT NOCOPY VARCHAR2,
                   p_group_type OUT NOCOPY igs_pe_persid_group_v.group_type%TYPE
                  ) RETURN VARCHAR2;

  PROCEDURE save_as_correction_isir(
                                    p_org_isir_id      IN  igf_ap_isir_matched_all.isir_id%TYPE,
                                    p_mod_isir_id      IN  igf_ap_isir_matched_all.isir_id%TYPE,
                                    p_cal_type         IN  igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                                    p_sequence_number  IN  igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
            p_corr_status      IN  VARCHAR2 DEFAULT 'READY',
                                    x_msg_count        OUT NOCOPY NUMBER,
                                    x_msg_data         OUT NOCOPY VARCHAR2,
                                    x_return_status    OUT NOCOPY VARCHAR2,
                                    p_msg_name         OUT NOCOPY VARCHAR2
                                   );

  PROCEDURE create_simulation_isir(
                                   p_mod_isir_id    IN  igf_ap_isir_matched_all.isir_id%TYPE,
                                   x_msg_count      OUT NOCOPY NUMBER,
                                   x_msg_data       OUT NOCOPY VARCHAR2,
                                   x_return_status  OUT NOCOPY VARCHAR2
                                  );


  PROCEDURE compute_efc(
                        p_isir_id            IN  igf_ap_isir_matched_all.isir_id%TYPE,
                        p_system_award_year  IN  VARCHAR2,
                        p_ignore_warnings    IN  VARCHAR2,
                        x_msg_count          OUT NOCOPY NUMBER,
                        x_msg_data           OUT NOCOPY VARCHAR2,
                        x_return_status      OUT NOCOPY VARCHAR2
                       );

  PROCEDURE get_dynamic_dates(
                              p_sys_award_year IN VARCHAR2,
                              p_current_year   OUT NOCOPY VARCHAR2,
                              p_next_year      OUT NOCOPY VARCHAR2,
                              p_award_year     OUT NOCOPY VARCHAR2,
                              p_legal_res_dt   OUT NOCOPY VARCHAR2,
                              p_first_bachlor  OUT NOCOPY VARCHAR2,
                              p_born_before    OUT NOCOPY VARCHAR2
                             );

  PROCEDURE get_internal_isir_id (
                                  p_isir_id IN IGF_AP_ISIR_MATCHED_ALL.ISIR_ID%TYPE,
                                  p_ret_isir_id IN OUT NOCOPY IGF_AP_ISIR_MATCHED_ALL.ISIR_ID%TYPE
                                 );

  PROCEDURE insert_into_todo(
                              p_base_id NUMBER,
                              p_seq_num NUMBER,
                              p_status VARCHAR2,
                              p_req_for_app VARCHAR2,
                              p_freq_attempt NUMBER,
                              p_max_attempt NUMBER
                            );

END IGF_AP_SS_PKG;

 

/
