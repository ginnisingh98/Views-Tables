--------------------------------------------------------
--  DDL for Package IGF_AW_CANCEL_AWD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_CANCEL_AWD" AUTHID CURRENT_USER AS
/* $Header: IGFAW06S.pls 120.1 2005/10/06 09:13:23 appldev ship $ */

    /*
    ||  Created On : 12-Jun-2001
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  skoppula        19-Apr-2002     Bug 2272349
    ||  (reverse chronological order - newest change first)
    */

     PROCEDURE cancel_award(
                       ERRBUF                OUT NOCOPY  VARCHAR2,
                       RETCODE               OUT NOCOPY  NUMBER,
                       p_award_year          IN   VARCHAR2,
                       p_fund_id             IN   igf_aw_award_all.fund_id%TYPE,
                       p_run_mode            IN   igf_lookups_view.lookup_code%TYPE,
                       p_base_id             IN   igf_ap_fa_con_v.base_id%TYPE,
                       p_org_id              IN   igf_aw_award_all.org_id%TYPE,
                       p_pig                 IN   igs_pe_all_persid_group_v.group_id%TYPE
                       );

    FUNCTION chk_awd_cancel(p_award_id       IN   igf_aw_award.award_id%TYPE,
                            p_base_id        IN   igf_aw_award.base_id%TYPE,
                            p_fund_id        IN   igf_aw_award.fund_id%TYPE,
                            p_msg_name       OUT NOCOPY  VARCHAR2) RETURN BOOLEAN;

    PROCEDURE cancel_award_fabase (
                                    p_ci_cal_type     IN    igs_ca_inst_all.cal_type%TYPE,
                                    p_ci_seq_num      IN    igs_ca_inst_all.sequence_number%TYPE,
                                    p_fund_id         IN    igf_aw_award_all.fund_id%TYPE,
                                    p_base_id         IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                                    p_run_mode        IN    igf_lookups_view.lookup_code%TYPE
                                  );

    FUNCTION chk_awd_exp_date (
                                p_base_id         IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                                p_fund_id         IN    igf_aw_fund_mast_all.fund_id%TYPE,
                                p_ci_cal_type     IN    igs_ca_inst_all.cal_type%TYPE,
                                p_ci_seq_num      IN    igs_ca_inst_all.sequence_number%TYPE,
                                p_run_mode        IN    igf_lookups_view.lookup_code%TYPE
                              ) RETURN BOOLEAN;

  PROCEDURE get_base_id_per_num (
                                  p_person_id       IN          hz_parties.party_id%TYPE,
                                  p_ci_cal_type     IN          igs_ca_inst_all.cal_type%TYPE,
                                  p_ci_seq_num      IN          igs_ca_inst_all.sequence_number%TYPE,
                                  p_base_id         OUT NOCOPY  igf_ap_fa_base_rec_all.base_id%TYPE,
                                  p_per_num         OUT NOCOPY  igs_pe_person_base_v.person_number%TYPE
                                );

END igf_aw_cancel_awd;

 

/
