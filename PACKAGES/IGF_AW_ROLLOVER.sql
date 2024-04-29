--------------------------------------------------------
--  DDL for Package IGF_AW_ROLLOVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_ROLLOVER" AUTHID CURRENT_USER AS
/* $Header: IGFAW08S.pls 120.3 2005/10/20 23:57:40 appldev ship $ */


  PROCEDURE main(
                     errbuf                OUT NOCOPY  VARCHAR2,
                     retcode               OUT NOCOPY  NUMBER,
                     p_frm_award_year      IN  VARCHAR2,
                     --p_to_award_year       IN  VARCHAR2,
                     p_fund_attribute      IN  VARCHAR2,
                     p_org_id              IN  igf_aw_award_all.org_id%TYPE,
                     p_rate_table          IN  VARCHAR2,
                     p_inst_application    IN  VARCHAR2,
                     p_distribution_plan   IN  VARCHAR2,
                     p_coa_group           IN  VARCHAR2,
                     p_todo                IN  VARCHAR2,
                     p_award_grp           IN  VARCHAR2
                 );

  FUNCTION chk_calendar_mapping ( p_frm_cal_type          IN  igs_ca_inst_all.cal_type%TYPE,
                                  p_frm_sequence_number   IN  igs_ca_inst_all.sequence_number%TYPE,
                                  p_to_cal_type           OUT NOCOPY igs_ca_inst_all.cal_type%TYPE,
                                  p_to_sequence_number    OUT NOCOPY igs_ca_inst_all.sequence_number%TYPE
                                ) RETURN BOOLEAN;


  FUNCTION get_fund_cd  (
                          p_fund_id           IN   igf_aw_fund_mast_all.fund_id%TYPE,
                          p_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                          p_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                        ) RETURN igf_aw_fund_mast_all.fund_code%TYPE;


  FUNCTION get_plan_cd(
                          p_adplans_id        IN   igf_aw_awd_dist_plans.adplans_id%TYPE,
                          p_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                          p_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                        ) RETURN igf_aw_awd_dist_plans.awd_dist_plan_cd%TYPE;


  FUNCTION  rollover_inst_attch_todo (  p_frm_cal_type         IN   igs_ca_inst_all.cal_type%TYPE,
                                        p_frm_sequence_number  IN   igs_ca_inst_all.sequence_number%TYPE,
                                        p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                        p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE,
                                        p_application_code     IN   igf_ap_appl_setup_all.application_code%TYPE
                                        )
                                        RETURN VARCHAR;


END igf_aw_rollover;

 

/
