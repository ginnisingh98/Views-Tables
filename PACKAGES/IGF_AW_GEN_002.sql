--------------------------------------------------------
--  DDL for Package IGF_AW_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_GEN_002" AUTHID CURRENT_USER AS
  /* $Header: IGFAW10S.pls 120.1 2006/08/04 07:39:27 veramach noship $ */
/*
||HISTORY
|| Who        When               What
|| veramach    Oct 2004        FA 152/FA 137 - Changes to wrappers to include Award Period setup
|| veramach   24-Aug-2004        FA 145 Obsoleted pell_efc_range
|| veramach   08-Apr-2004        bug 3547237
||                               Obsoleted get_fed_efc. Replaced references with igf_aw_packng_subfns.get_fed_efc
*/
FUNCTION get_sectionii_stdnt (
p_depend_stat  IN igf_lookups_view.lookup_code%TYPE,
p_class_standing IN igf_lookups_view.lookup_code%TYPE,
p_ci_cal_type IN igs_ca_inst.cal_type%TYPE,
p_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
p_minvalue IN igf_aw_fi_inc_level.minvalue%TYPE,
p_maxvalue IN igf_aw_fi_inc_level.maxvalue%TYPE,
p_efc VARCHAR2) return NUMBER;

FUNCTION get_sectionvi_fund (
p_rec_type IN igf_aw_fisap_vi_h.rec_type%TYPE,
p_fund_type IN igf_aw_award_v.fed_fund_code%TYPE,
p_depend_stat  IN igf_lookups_view.lookup_code%TYPE,
p_class_standing IN igf_lookups_view.lookup_code%TYPE,
p_ci_cal_type IN igs_ca_inst.cal_type%TYPE,
p_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
p_minvalue IN igf_aw_fi_inc_level.minvalue%TYPE,
p_maxvalue IN igf_aw_fi_inc_level.maxvalue%TYPE )
return NUMBER ;

FUNCTION get_sectionvi_stdnt (
p_rec_type IN igf_aw_fisap_vi_h.rec_type%TYPE,
p_fund_type IN igf_aw_award_v.fed_fund_code%TYPE,
p_depend_stat  IN igf_lookups_view.lookup_code%TYPE,
p_class_standing IN igf_lookups_view.lookup_code%TYPE,
p_ci_cal_type IN igs_ca_inst.cal_type%TYPE,
p_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
p_minvalue IN igf_aw_fi_inc_level.minvalue%TYPE,
p_maxvalue IN igf_aw_fi_inc_level.maxvalue%TYPE
) return NUMBER ;

--Enh Bug 2142666 EFC Build
--Procedure added for Comparing ISIR Fields in Compare Application

  PROCEDURE  compare_isirs(
                           p_isir_id      igf_ap_isir_matched_all.isir_id%TYPE,
                           p_corr_isir_id igf_ap_isir_matched_all.isir_id%TYPE,
                           p_cal_type     igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                           p_seq_num      igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
			   p_corr_status   igf_ap_isir_corr.correction_status%TYPE DEFAULT NULL
                          );


  /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 08-JAN-2001
  ||  Purpose : Bug No: 2154941 This procedure takes the base_id (Student and Award Year) as a parameter. It passes out NOCOPY the
		||            Federal and Institutional resources for that base id, and  Federal and Institutional Unmet
		||            need/Overaward for that base_id.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  PROCEDURE get_resource_need
  (
    p_base_id           IN      igf_ap_fa_base_rec.base_id%TYPE,
    p_resource_f        OUT NOCOPY     NUMBER,
    p_resource_i        OUT NOCOPY     NUMBER,
    p_unmet_need_f      OUT NOCOPY     NUMBER,
    p_unmet_need_i      OUT NOCOPY     NUMBER,
    p_resource_f_fc     OUT NOCOPY     NUMBER,
    p_resource_i_fc     OUT NOCOPY     NUMBER,
    p_awd_prd_code      IN  igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL,
    p_calc_for_subz_loan  IN             VARCHAR2  DEFAULT 'N'
  );

END igf_aw_gen_002;

 

/
