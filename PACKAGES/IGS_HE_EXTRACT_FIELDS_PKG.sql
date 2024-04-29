--------------------------------------------------------
--  DDL for Package IGS_HE_EXTRACT_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_EXTRACT_FIELDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE9CS.pls 120.5 2006/09/15 01:48:52 jtmathew noship $ */

-- Structure to hold Cost Centre details
TYPE cc IS TABLE of igs_he_poous_ou_cc.cost_centre%TYPE
        INDEX BY binary_integer;
TYPE subj IS TABLE of igs_he_poous_ou_cc.subject%TYPE
        INDEX BY binary_integer;
TYPE prop IS TABLE of igs_he_poous_ou_cc.proportion%TYPE
        INDEX BY binary_integer;

TYPE cc_rec IS RECORD
        (cost_centre         cc,
         subject             subj,
         proportion          prop);

-- Structure to hold Module details
TYPE unit IS TABLE of VARCHAR2(20)
        INDEX BY binary_integer;
TYPE result IS TABLE of igs_he_code_map_val.map1%TYPE
        INDEX BY binary_integer;
TYPE welsh_prop IS TABLE of igs_he_st_unt_vs.prop_of_teaching_in_welsh%TYPE
        INDEX BY binary_integer;

TYPE mod_rec IS RECORD
        (module_id         unit,
         module_result     result,
         prop_in_welsh     welsh_prop);

-- Index Table to hold the award conferral dates for the submission
TYPE awd_defn IS RECORD
  (type                igs_he_submsn_awd.type%TYPE,
   key1                igs_he_submsn_awd.key1%TYPE,
   award_start_date    igs_he_submsn_awd.award_start_date%TYPE,
   award_end_date      igs_he_submsn_awd.award_end_date%TYPE);

TYPE awd_table IS TABLE of awd_defn
        INDEX BY binary_integer;

PROCEDURE get_hesa_inst_id
          (p_hesa_inst_id          OUT NOCOPY VARCHAR2);

PROCEDURE get_campus_id
          (p_location_cd           IN  igs_en_stdnt_ps_att.location_cd%TYPE,
           p_campus_id             OUT NOCOPY VARCHAR2);

-- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
PROCEDURE get_alt_pers_id
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_id_type               IN  igs_pe_alt_pers_id.person_id_type%TYPE,
           p_api_id                OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE DEFAULT NULL,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE DEFAULT NULL);

-- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
PROCEDURE get_stdnt_id
          (p_person_id             IN  igs_en_stdnt_ps_att.person_id%TYPE,
           p_inst_id               IN  igs_or_institution.govt_institution_cd%TYPE,
           p_stdnt_id              OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE DEFAULT NULL,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE DEFAULT NULL);

PROCEDURE get_fe_stdnt_mrker
          (p_spa_fe_stdnt_mrker    IN  igs_he_st_spa.fe_student_marker%TYPE,
           p_fe_program_marker     IN  igs_he_st_prog.fe_program_marker%TYPE,
           p_funding_src           IN  igs_he_ex_rn_dat_fd.value%TYPE,
           p_fundability_cd        IN  igs_he_ex_rn_dat_fd.value%TYPE,
           p_oss_fe_stdnt_mrker    OUT NOCOPY VARCHAR2,
           p_hesa_fe_stdnt_mrker   OUT NOCOPY VARCHAR2);


PROCEDURE get_funding_src
          (p_course_cd             IN  igs_ps_ver.course_cd%TYPE,
           p_version_number        IN  igs_ps_ver.version_number%TYPE,
           p_spa_fund_src          IN  igs_en_stdnt_ps_att.funding_source%TYPE,
           p_poous_fund_src        IN  igs_he_poous.funding_source%TYPE,
           p_oss_fund_src          OUT NOCOPY VARCHAR2,
           p_hesa_fund_src         OUT NOCOPY VARCHAR2);

-- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
PROCEDURE get_fundability_cd
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_susa_fund_cd          IN  igs_he_en_susa.fundability_code%TYPE,
           p_spa_funding_source    IN  igs_en_stdnt_ps_att.funding_source%TYPE,
           p_poous_fund_cd         IN  igs_he_poous.fundability_cd%TYPE,
           p_prg_fund_cd           IN  igs_he_st_prog.fundability%TYPE,
           p_prg_funding_source    IN  igs_fi_fnd_src_rstn.funding_source%TYPE,
           p_oss_fund_cd           OUT NOCOPY VARCHAR2,
           p_hesa_fund_cd          OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE DEFAULT NULL,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE DEFAULT NULL);

-- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
PROCEDURE get_fmly_name_on_16_bday
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_fmly_name             OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE DEFAULT NULL,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE DEFAULT NULL);

PROCEDURE get_gender
          (p_gender           IN  igs_pe_person.sex%TYPE,
           p_hesa_gender      OUT NOCOPY VARCHAR2);

PROCEDURE get_domicile
          (p_ad_domicile           IN  igs_he_ad_dtl.domicile_cd%TYPE,
           p_spa_domicile          IN  igs_he_st_spa.domicile_cd%TYPE,
           p_hesa_domicile         OUT NOCOPY VARCHAR2);

-- smaddali 11-dec-03   Modified for bug#3235753 , added 1 new parameter
PROCEDURE get_nationality
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_nationality           OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE DEFAULT NULL);

PROCEDURE get_ethnicity
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_oss_eth               IN  igs_pe_stat_v.ethnic_origin_id%TYPE,
           p_hesa_eth              OUT NOCOPY VARCHAR2);

PROCEDURE get_disablity_allow
          (p_oss_dis_allow         IN  igs_he_en_susa.disability_allow%TYPE,
           p_hesa_dis_allow        OUT NOCOPY VARCHAR2);

-- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
PROCEDURE get_disablity
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_disability            OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE DEFAULT NULL,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE DEFAULT NULL);

PROCEDURE get_addnl_supp_band
          (p_oss_supp_band         IN  igs_he_en_susa.additional_sup_band%TYPE,
           p_hesa_supp_band        OUT NOCOPY VARCHAR2);

PROCEDURE get_yr_left_last_inst
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_com_dt                IN  DATE,
           p_hesa_gen_qaim         IN  VARCHAR2,
           p_ucasnum               IN  igs_pe_alt_pers_id.api_person_id%TYPE,
           p_year                  OUT NOCOPY VARCHAR2);

PROCEDURE get_new_ent_to_he
          (p_fe_stdnt_mrker        IN  igs_he_st_spa.fe_student_marker%TYPE,
           p_susa_new_ent_to_he    IN  igs_he_en_susa.new_he_entrant_cd%TYPE,
           p_yop                   IN  VARCHAR2,
           p_high_qual_on_ent      IN  igs_he_st_spa.highest_qual_on_entry%TYPE,
           p_domicile              IN  igs_he_st_spa.domicile_cd%TYPE,
           p_hesa_new_ent_to_he    OUT NOCOPY VARCHAR2);

PROCEDURE get_year_of_prog
          (p_unit_set_cd           IN  igs_he_en_susa.unit_set_cd%TYPE,
           p_year_of_prog          OUT NOCOPY VARCHAR2);

PROCEDURE get_special_student
          (p_ad_special_student       IN  igs_he_ad_dtl.special_student_cd%TYPE,
           p_spa_special_student      IN  igs_he_st_spa.special_student%TYPE,
           p_oss_special_student      OUT NOCOPY VARCHAR2,
           p_hesa_special_student     OUT NOCOPY VARCHAR2);

-- smaddali  29-oct-03  modified procedure get_year_of_student to add 1 new parameter for bug#3224246
-- jbaber    30-aug-04 - added new parameter p_susa_year_of_student for HEFD350
PROCEDURE get_year_of_student
          (p_person_id              IN  igs_he_en_susa.person_id%TYPE,
           p_course_cd              IN  igs_he_en_susa.course_cd%TYPE,
           p_unit_set_cd            IN  igs_he_en_susa.unit_set_cd%TYPE,
           p_sequence_number        IN  igs_he_en_susa.sequence_number%TYPE,
           p_year_of_student        OUT NOCOPY VARCHAR2,
           p_enrl_end_dt            IN  DATE DEFAULT NULL,
           p_susa_year_of_student   IN  igs_he_en_susa.year_stu%TYPE);


PROCEDURE get_study_location
          (p_susa_study_location     IN  igs_he_en_susa.study_location%TYPE,
           p_poous_study_location    IN  igs_he_poous.location_of_study%TYPE,
           p_prg_study_location      IN  igs_he_st_prog.location_of_study%TYPE,
           p_oss_study_location      OUT NOCOPY VARCHAR2,
           p_hesa_study_location     OUT NOCOPY VARCHAR2);

-- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
PROCEDURE get_term_time_acc
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_susa_term_time_acc    IN  igs_he_en_susa.term_time_accom%TYPE,
           p_study_location        IN  VARCHAR2,
           p_hesa_term_time_acc    OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE DEFAULT NULL,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE DEFAULT NULL);

PROCEDURE get_min_max_awd_dates
           (p_submission_name       IN  igs_he_submsn_header.submission_name%TYPE,
            p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
            p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
            p_min_start_dt          OUT NOCOPY igs_he_submsn_awd.award_start_date%TYPE,
            p_max_start_dt          OUT NOCOPY igs_he_submsn_awd.award_end_date%TYPE);

PROCEDURE get_awd_dtls
           (p_submission_name  IN igs_he_submsn_awd.submission_name%TYPE,
            p_awd_table        OUT NOCOPY awd_table,
            p_search_prog      OUT NOCOPY BOOLEAN,
            p_search_prog_type OUT NOCOPY BOOLEAN);

PROCEDURE get_awd_conferral_dates
           (p_awd_table             IN  awd_table,
            p_submission_name       IN  igs_he_ext_run_dtls.submission_name%TYPE,
            p_search_prog           IN  BOOLEAN,
            p_search_prog_type      IN  BOOLEAN,
            p_course_cd             IN  igs_ps_ver_all.course_cd%TYPE,
            p_course_type           IN  igs_ps_ver_all.course_type%TYPE,
            p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
            p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
            p_awd_conf_start_dt     OUT NOCOPY igs_he_submsn_awd.award_start_date%TYPE,
            p_awd_conf_end_dt       OUT NOCOPY igs_he_submsn_awd.award_end_date%TYPE);

PROCEDURE get_rsn_inst_left
           (p_person_id              IN  igs_he_en_susa.person_id%TYPE,
            p_course_cd              IN  igs_he_en_susa.course_cd%TYPE,
            p_crs_req_comp_ind       IN  igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE,
            p_crs_req_comp_dt        IN  igs_en_stdnt_ps_att.course_rqrmnts_complete_dt%TYPE,
            p_disc_reason_cd         IN  igs_en_stdnt_ps_att.discontinuation_reason_cd%TYPE,
            p_disc_dt                IN  igs_en_stdnt_ps_att.discontinued_dt%TYPE,
            p_enrl_start_dt          IN  igs_he_submsn_header.enrolment_start_date%TYPE,
            p_enrl_end_dt            IN  igs_he_submsn_header.enrolment_end_date%TYPE,
            p_rsn_inst_left          OUT NOCOPY VARCHAR2);


--smaddali 6-jun-2002 bug 2396174 added parameter p_course_cd
PROCEDURE get_completion_status
           (p_person_id             IN  igs_pe_person.person_id%TYPE,
            p_course_cd             IN  igs_he_st_spa.course_cd%TYPE ,
            p_susa_comp_status      IN  igs_he_en_susa.completion_status%TYPE,
            p_fe_stdnt_mrker        IN  igs_he_st_spa.fe_student_marker%TYPE,
            p_crs_req_comp_ind      IN  igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE ,
            p_discont_date          IN igs_en_stdnt_ps_att.discontinued_dt%TYPE,
            p_hesa_comp_status      OUT NOCOPY VARCHAR2);

PROCEDURE get_good_stand_mrkr
           (p_susa_good_st_mk       IN  igs_he_en_susa.good_stand_marker%TYPE,
            p_fe_stdnt_mrker        IN  igs_he_st_spa.fe_student_marker%TYPE,
            p_crs_req_comp_ind      IN  igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE ,
            p_discont_date          IN igs_en_stdnt_ps_att.discontinued_dt%TYPE,
            p_hesa_good_st_mk       OUT NOCOPY VARCHAR2);

PROCEDURE get_qual_obtained
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
           p_oss_qual_obt1         OUT NOCOPY VARCHAR2,
           p_oss_qual_obt2         OUT NOCOPY VARCHAR2,
           p_hesa_qual_obt1        OUT NOCOPY VARCHAR2,
           p_hesa_qual_obt2        OUT NOCOPY VARCHAR2,
           p_classification        OUT NOCOPY VARCHAR2);

PROCEDURE get_fe_qual_aim
            (p_spa_fe_qual_aim      IN  igs_he_st_spa.student_fe_qual_aim%TYPE,
             p_fe_stdnt_mrker       IN  igs_he_st_spa.fe_student_marker%TYPE,
             p_course_cd            IN  igs_he_st_spa.course_cd%TYPE,
             p_version_number       IN  igs_he_st_spa.version_number%TYPE,
             p_hesa_fe_qual_aim     OUT NOCOPY VARCHAR2);

PROCEDURE get_qual_aim_sbj
          (p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number        IN  igs_he_st_spa.version_number%TYPE,
           p_subject1              OUT NOCOPY VARCHAR2,
           p_subject2              OUT NOCOPY VARCHAR2,
           p_subject3              OUT NOCOPY VARCHAR2,
           p_prop_ind              OUT NOCOPY VARCHAR2);

-- smaddali added 2 new parameters for bug#3360646
PROCEDURE get_gen_qual_aim
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number        IN  igs_he_st_spa.version_number%TYPE,
           p_spa_gen_qaim          IN  igs_he_st_spa.student_qual_aim%TYPE,
           p_hesa_gen_qaim         OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE DEFAULT NULL,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE DEFAULT NULL,
           p_awd_conf_start_dt     IN  igs_he_submsn_awd.award_start_date%TYPE DEFAULT NULL);

PROCEDURE get_awd_body_12
          (p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number        IN  igs_he_st_spa.version_number%TYPE,
           p_awd1                  IN  VARCHAR2,
           p_awd2                  IN  VARCHAR2,
           p_awd_body1             OUT NOCOPY VARCHAR2,
           p_awd_body2             OUT NOCOPY VARCHAR2);

PROCEDURE get_prog_length
          (p_spa_attendance_type   IN  igs_en_stdnt_ps_att.attendance_type%TYPE,
           p_ft_compl_time         IN  igs_ps_ver.std_ft_completion_time%TYPE,
           p_pt_compl_time         IN  igs_ps_ver.std_pt_completion_time%TYPE,
           p_length                OUT NOCOPY VARCHAR2,
           p_units                 OUT NOCOPY VARCHAR2);

PROCEDURE get_teach_train_crs_id
          (p_prg_ttcid             IN  igs_he_st_prog.teacher_train_prog_id%TYPE,
           p_spa_ttcid             IN  igs_he_st_spa.teacher_train_prog_id%TYPE,
           p_hesa_ttcid            OUT NOCOPY VARCHAR2);

PROCEDURE get_itt_phsc
          (p_prg_itt_phsc          IN  igs_he_st_prog.itt_phase%TYPE,
           p_spa_itt_phsc          IN  igs_he_st_spa.itt_phase%TYPE,
           p_hesa_itt_phsc         OUT NOCOPY VARCHAR2);

PROCEDURE get_itt_mrker
          (p_prg_itt_mrker         IN  igs_he_st_prog.bilingual_itt_marker%TYPE,
           p_spa_itt_mrker         IN  igs_he_st_spa.bilingual_itt_marker%TYPE,
           p_hesa_itt_mrker        OUT NOCOPY VARCHAR2);

PROCEDURE get_teach_qual_sect
          (p_oss_teach_qual_sect     IN  igs_he_st_prog.teaching_qual_sought_sector%TYPE,
           p_hesa_teach_qual_sect    OUT NOCOPY VARCHAR2);

PROCEDURE get_teach_qual_sbj
          (p_oss_teach_qual_sbj     IN  igs_he_st_prog.teaching_qual_sought_subj1%TYPE,
           p_hesa_teach_qual_sbj    OUT NOCOPY VARCHAR2);

-- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
PROCEDURE get_fee_elig
           (p_person_id            IN  igs_pe_person.person_id%TYPE,
            p_susa_fee_elig        IN  igs_he_en_susa.fee_eligibility%TYPE,
            p_fe_stdnt_mrker       IN  igs_he_st_spa.fe_student_marker%TYPE,
            p_study_mode           IN  VARCHAR2,
            p_special_student      IN  VARCHAR2,
            p_hesa_fee_elig        OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE DEFAULT NULL,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE DEFAULT NULL);

PROCEDURE get_fee_band
          (p_hesa_fee_elig     IN  igs_he_en_susa.fee_eligibility%TYPE,
           p_susa_fee_band     IN  igs_he_en_susa.fee_band%TYPE,
           p_poous_fee_band    IN  igs_he_poous.fee_band%TYPE,
           p_prg_fee_band      IN  igs_he_st_prog.fee_band%TYPE,
           p_hesa_fee_band     OUT NOCOPY VARCHAR2);

-- smaddali  13-oct-03  modified procedure to add 2 new parameters for bug# 3179544
PROCEDURE get_amt_tuition_fees
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_cal_type              IN  igs_en_stdnt_ps_att.cal_type%TYPE,
           p_fe_prg_mrker          IN  igs_he_st_prog.fe_program_marker%TYPE,
           p_fe_stdnt_mrker        IN  igs_he_st_spa.fe_student_marker%TYPE,
           p_oss_amt               OUT NOCOPY NUMBER,
           p_hesa_amt              OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  DATE DEFAULT NULL,
           p_enrl_end_dt           IN  DATE DEFAULT NULL);

PROCEDURE get_maj_src_tu_fee
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE,
           p_special_stdnt         IN  VARCHAR2,
           p_study_mode            IN  VARCHAR2,
           p_amt_tu_fee            IN  NUMBER,
           p_susa_mstufee          IN  igs_he_en_susa.student_fee%TYPE,
           p_hesa_mstufee          OUT NOCOPY VARCHAR2);

PROCEDURE get_religion
          (p_oss_religion     IN  igs_pe_stat_v.religion%TYPE,
           p_hesa_religion    OUT NOCOPY VARCHAR2);

PROCEDURE get_sldd_disc_prv
          (p_oss_sldd_disc_prv     IN  igs_he_en_susa.sldd_discrete_prov%TYPE,
           p_fe_stdnt_mrker        IN  igs_he_st_spa.fe_student_marker%TYPE,
           p_hesa_sldd_disc_prv    OUT NOCOPY VARCHAR2);



PROCEDURE get_non_payment_rsn
          (p_oss_non_payment_rsn     IN  igs_he_en_susa.non_payment_reason%TYPE,
           p_fe_stdnt_mrker          IN  igs_he_st_spa.fe_student_marker%TYPE,
           p_hesa_non_payment_rsn    OUT NOCOPY VARCHAR2);



PROCEDURE get_oth_teach_inst
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_program_calc          IN  igs_he_st_prog.program_calc%TYPE,
           p_susa_inst1            IN  igs_he_en_susa.teaching_inst1%TYPE,
           p_poous_inst1           IN  igs_he_poous.other_instit_teach1%TYPE,
           p_prog_inst1            IN  igs_he_st_prog.other_inst_prov_teaching1%TYPE,
           p_susa_inst2            IN  igs_he_en_susa.teaching_inst1%TYPE,
           p_poous_inst2           IN  igs_he_poous.other_instit_teach1%TYPE,
           p_prog_inst2            IN  igs_he_st_prog.other_inst_prov_teaching1%TYPE,
           p_hesa_inst1            OUT NOCOPY VARCHAR2,
           p_hesa_inst2            OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE);

-- smaddali added new parameters p_enrl_start_dt , p_enrl_end_dt for bug 2437081
PROCEDURE get_prop_not_taught
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE,
           p_program_calc          IN  igs_he_st_prog.program_calc%TYPE,
           p_susa_prop             IN  igs_he_en_susa.pro_not_taught%TYPE,
           p_poous_prop            IN  igs_he_poous.prop_not_taught%TYPE,
           p_prog_prop             IN  igs_he_st_prog.prop_not_taught%TYPE,
           p_hesa_prop             OUT NOCOPY VARCHAR2);

PROCEDURE get_credit_trans_sch
          (p_oss_credit_trans_sch     IN  igs_he_st_prog.credit_transfer_scheme%TYPE,
           p_hesa_credit_trans_sch    OUT NOCOPY VARCHAR2);
--smaddali added new parameter p_susa_credit_level for bug 2415879
PROCEDURE get_credit_level
          (p_susa_credit_level          IN  igs_he_en_susa.credit_level1%TYPE ,
           p_poous_credit_level         IN  igs_he_poous.level_credit1%TYPE,
           p_hesa_credit_level          OUT NOCOPY VARCHAR2);

-- jbaber added crd_pt3-4, lvl_crd_pt3-4 for HEFD350
PROCEDURE get_credit_obtained
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_prog_calc             IN  igs_he_st_prog.program_calc%TYPE,
           p_susa_crd_pt1          IN  igs_he_en_susa.credit_pt_achieved1%TYPE,
           p_susa_crd_pt2          IN  igs_he_en_susa.credit_pt_achieved2%TYPE,
           p_susa_crd_pt3          IN  igs_he_en_susa.credit_pt_achieved3%TYPE,
           p_susa_crd_pt4          IN  igs_he_en_susa.credit_pt_achieved4%TYPE,
           p_susa_crd_lvl1         IN  igs_he_en_susa.credit_level_achieved1%TYPE,
           p_susa_crd_lvl2         IN  igs_he_en_susa.credit_level_achieved2%TYPE,
           p_susa_crd_lvl3         IN  igs_he_en_susa.credit_level_achieved3%TYPE,
           p_susa_crd_lvl4         IN  igs_he_en_susa.credit_level_achieved4%TYPE,
           p_no_crd_pt1            OUT NOCOPY VARCHAR2,
           p_no_crd_pt2            OUT NOCOPY VARCHAR2,
           p_no_crd_pt3            OUT NOCOPY VARCHAR2,
           p_no_crd_pt4            OUT NOCOPY VARCHAR2,
           p_lvl_crd_pt1           OUT NOCOPY VARCHAR2,
           p_lvl_crd_pt2           OUT NOCOPY VARCHAR2,
           p_lvl_crd_pt3           OUT NOCOPY VARCHAR2,
           p_lvl_crd_pt4           OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE  );

--jbaber added new parameter p_validation_country for HEFD350 process 2
PROCEDURE get_cost_centres
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_en_stdnt_ps_att.course_cd%TYPE,
           p_version_number        IN  igs_en_stdnt_ps_att.version_number%TYPE,
           p_unit_set_cd           IN  igs_he_poous.unit_set_cd%TYPE,
           p_us_version_number     IN  igs_he_poous.us_version_number%TYPE,
           p_cal_type              IN  igs_he_poous.cal_type%TYPE,
           p_attendance_mode       IN  igs_he_poous.attendance_mode%TYPE,
           p_attendance_type       IN  igs_he_poous.attendance_type%TYPE,
           p_location_cd           IN  igs_he_poous.location_cd%TYPE,
           p_program_calc          IN  igs_he_st_prog.program_calc%TYPE,
           p_unit_cd               IN  igs_he_st_unt_vs.unit_cd%TYPE,
           p_uv_version_number     IN  igs_he_st_unt_vs.version_number%TYPE,
           p_return_type           IN  VARCHAR2,
           p_cost_ctr_rec          IN OUT NOCOPY cc_rec,
           p_total_recs            OUT NOCOPY NUMBER,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE,
           p_sequence_number       IN  NUMBER DEFAULT NULL,
           p_validation_country    IN  igs_he_submsn_header.validation_country%TYPE);

-- jbaber 25-Nov-2004 Included p_version_number for bug # 4037237
PROCEDURE get_studies_susp
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number        IN  igs_he_st_spa.version_number%TYPE,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE,
           p_susp_act_std          OUT NOCOPY VARCHAR2);

PROCEDURE get_pyr_type
          (p_oss_pyr_type     IN  igs_he_poous.type_of_year%TYPE,
           p_hesa_pyr_type    OUT NOCOPY VARCHAR2);

PROCEDURE get_lvl_appl_to_fund
          (p_poous_lvl_appl_fund   IN  igs_he_poous.level_applicable_to_funding%TYPE,
           p_prg_lvl_appl_fund     IN  igs_he_st_prog.level_applicable_to_funding%TYPE,
           p_hesa_lvl_appl_fund    OUT NOCOPY VARCHAR2);

PROCEDURE get_comp_pyr_study(
          p_susa_comp_pyr_study   IN  igs_he_en_susa.complete_pyr_study_cd%TYPE,
          p_fundlev               IN  VARCHAR2,
          p_spcstu                IN  VARCHAR2,
          p_notact                IN  VARCHAR2,
          p_mode                  IN  VARCHAR2,
          p_typeyr                IN  VARCHAR2,
          p_crse_rqr_complete_ind IN  igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE,
          p_crse_req_complete_dt  IN  igs_en_stdnt_ps_att.course_rqrmnts_complete_dt%TYPE,
          p_disc_reason_cd        IN  igs_en_stdnt_ps_att.discontinuation_reason_cd%TYPE,
          p_discont_dt            IN  igs_en_stdnt_ps_att.discontinued_dt%TYPE,
          p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
          p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
          p_person_id             IN  igs_en_stdnt_ps_att.person_id%TYPE,
          p_course_cd             IN  igs_en_stdnt_ps_att.course_cd%TYPE,
          p_hesa_comp_pyr_study   OUT NOCOPY VARCHAR2);

PROCEDURE get_destination
          (p_oss_destination     IN  igs_he_st_spa.destination%TYPE,
           p_hesa_destination    OUT NOCOPY VARCHAR2);

PROCEDURE get_itt_outcome
          (p_oss_itt_outcome     IN   igs_he_st_spa.itt_prog_outcome%TYPE,
           p_teach_train_prg     IN   igs_he_st_spa.teacher_train_prog_id%TYPE,
           p_hesa_itt_outcome    OUT NOCOPY  VARCHAR2);

PROCEDURE get_ufi_place
          (p_oss_ufi_place     IN  igs_he_st_spa.ufi_place%TYPE,
           p_hesa_ufi_place    OUT NOCOPY VARCHAR2);

PROCEDURE get_franchising_activity
          (p_susa_franch_activity     IN  igs_he_en_susa.franchising_activity%TYPE,
           p_poous_franch_activity    IN  igs_he_poous.franchising_activity%TYPE,
           p_prog_franch_activity     IN  igs_he_st_prog.franchising_activity%TYPE,
           p_hesa_franch_activity     OUT NOCOPY VARCHAR2);

PROCEDURE get_social_class_ind
          (p_spa_social_class_ind     IN  igs_he_st_spa.social_class_ind%TYPE,
           p_adm_social_class_ind     IN  igs_he_ad_dtl.social_class_cd%TYPE,
           p_hesa_social_class_ind    OUT NOCOPY VARCHAR2);

PROCEDURE get_occupation_code
          (p_spa_occupation_code     IN  igs_he_st_spa.occupation_code%TYPE,
           p_hesa_occupation_code    OUT NOCOPY VARCHAR2);

PROCEDURE get_inst_last_attended
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_com_date              IN  DATE,
           p_inst_last_att         OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN igs_he_submsn_header.enrolment_start_date%TYPE DEFAULT NULL,
           p_enrl_end_dt           IN igs_he_submsn_header.enrolment_end_date%TYPE DEFAULT NULL);

PROCEDURE get_regulatory_body
          (p_course_cd               IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number          IN  igs_he_st_spa.version_number%TYPE,
           p_hesa_regulatory_body    OUT NOCOPY VARCHAR2);

PROCEDURE get_nhs_fund_src
          (p_spa_nhs_fund_src     IN  igs_he_st_spa.nhs_funding_source%TYPE,
           p_prg_nhs_fund_src     IN  igs_he_st_spa.nhs_funding_source%TYPE,
           p_hesa_nhs_fund_src    OUT NOCOPY VARCHAR2);

PROCEDURE get_nhs_employer
          (p_spa_nhs_employer     IN  igs_he_st_spa.nhs_employer%TYPE,
           p_hesa_nhs_employer    OUT NOCOPY VARCHAR2);

PROCEDURE get_qual_dets
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_hesa_qual             IN  VARCHAR2,
           p_no_of_qual            OUT NOCOPY NUMBER,
           p_tariff_score          OUT NOCOPY NUMBER);


PROCEDURE get_module_dets
          (p_person_id            IN  igs_pe_person.person_id%TYPE,
           p_course_cd            IN  igs_en_stdnt_ps_att.course_cd%TYPE,
           p_version_number       IN  igs_en_stdnt_ps_att.version_number%TYPE,
           p_student_inst_number  IN  igs_he_st_spa.student_inst_number%TYPE,
           p_cal_type             IN  igs_en_stdnt_ps_att.cal_type%TYPE,
           p_enrl_start_dt        IN  DATE,
           p_enrl_end_dt          IN  DATE,
           p_offset_days          IN  NUMBER,
           p_module_rec           IN OUT NOCOPY mod_rec,
           p_total_recs           OUT NOCOPY NUMBER);

-- jbaber 25-Nov-2004 Included p_version_number for bug # 4037237
PROCEDURE get_mode_of_study
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number        IN  igs_he_st_spa.version_number%TYPE,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
           p_susa_study_mode       IN  igs_he_en_susa.study_mode%TYPE,
           p_poous_study_mode      IN  igs_he_poous.attendance_mode%TYPE,
           p_attendance_type       IN  igs_en_stdnt_ps_att.attendance_type%TYPE,
           p_mode_of_study         OUT NOCOPY VARCHAR2);

FUNCTION isDormant
         (p_person_id             IN  igs_pe_person.person_id%TYPE,
          p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
          p_version_number        IN  igs_he_st_spa.version_number%TYPE,
          p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
          p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE)
RETURN BOOLEAN;

FUNCTION is_ucas_ftug
         (p_hesa_qual_aim     IN igs_he_ex_rn_dat_fd.value%TYPE,
          p_hesa_commdate     IN igs_he_ex_rn_dat_fd.value%TYPE,
          p_ucasnum           IN igs_he_ex_rn_dat_fd.value%TYPE,
          p_min_commdate      IN DATE) RETURN BOOLEAN;

PROCEDURE limit_no_of_qual
          (p_field_number   IN NUMBER,
           p_person_number  IN igs_pe_person.person_number%TYPE,
           p_course_cd      IN igs_he_st_spa.course_cd%TYPE,
           p_hesa_qual      IN VARCHAR2,
           p_no_of_qual     IN OUT NOCOPY NUMBER);

PROCEDURE limit_tariff_score
          (p_field_number  IN NUMBER,
           p_person_number IN igs_pe_person.person_number%TYPE,
           p_course_cd     IN igs_he_st_spa.course_cd%TYPE,
           p_hesa_qual     IN VARCHAR2,
           p_tariff_score  IN OUT NOCOPY igs_he_ex_rn_dat_fd.value%TYPE);

PROCEDURE get_mod_prop_fte
          (p_enrolled_credit_points   IN  igs_ps_unit_ver_v.enrolled_credit_points%TYPE,
           p_unit_level               IN  igs_ps_unit_ver_v.unit_level%TYPE,
           p_prop_of_fte              OUT NOCOPY VARCHAR2);

PROCEDURE get_mod_prop_not_taught
          (p_unit_cd               IN  igs_he_st_unt_vs.unit_cd%TYPE,
           p_version_number        IN  igs_he_st_unt_vs.version_number%TYPE,
           p_prop_not_taught       OUT NOCOPY VARCHAR2);

PROCEDURE get_mod_oth_teach_inst
          (p_unit_cd               IN  igs_he_st_unt_vs.unit_cd%TYPE,
           p_version_number        IN  igs_he_st_unt_vs.version_number%TYPE,
           p_oth_teach_inst        OUT NOCOPY VARCHAR2);

PROCEDURE get_pgce_class
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_pgce_class            OUT NOCOPY VARCHAR2);


  PROCEDURE get_commencement_dt
          ( p_hesa_commdate             IN  igs_he_st_spa_all.commencement_dt%TYPE DEFAULT NULL,
            p_enstdnt_commdate          IN  igs_en_stdnt_ps_att.commencement_dt%TYPE  DEFAULT NULL,
            p_person_id                 IN  igs_pe_person.person_id%TYPE ,
            p_course_cd                 IN  igs_he_st_spa_all.course_cd%TYPE,
            p_version_number            IN  igs_he_st_spa_all.version_number%TYPE,
            p_student_inst_number       IN  igs_he_st_spa_all.student_inst_number%TYPE,
            p_final_commdate            OUT NOCOPY igs_he_ex_rn_dat_fd.value%TYPE );


PROCEDURE get_qual_aim_sbj1
          ( p_qual_aim_subj1       IN igs_he_st_spa.qual_aim_subj1%TYPE,
            p_qual_aim_subj2       IN igs_he_st_spa.qual_aim_subj2%TYPE,
            p_qual_aim_subj3       IN igs_he_st_spa.qual_aim_subj3%TYPE,
            p_oss_qualaim_sbj      IN igs_he_code_values.value%TYPE,
            p_hesa_qualaim_sbj     OUT NOCOPY igs_he_code_values.value%TYPE);


PROCEDURE get_new_prog_length
          (p_spa_attendance_type                IN  igs_en_stdnt_ps_att.attendance_type%TYPE,
           p_program_length                     IN igs_ps_ofr_opt_all.program_length%TYPE,
           p_program_length_measurement         IN igs_ps_ofr_opt_all.program_length_measurement%TYPE,
           p_length                             OUT NOCOPY NUMBER,
           p_units                              OUT NOCOPY NUMBER);

-- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
PROCEDURE get_ucasnum
        (p_person_id        IN  igs_pe_person.person_id%TYPE,
         p_ucasnum          OUT NOCOPY igs_pe_alt_pers_id.api_person_id%TYPE,
         p_enrl_start_dt    IN  igs_he_submsn_header.enrolment_start_date%TYPE DEFAULT NULL,
         p_enrl_end_dt      IN  igs_he_submsn_header.enrolment_end_date%TYPE DEFAULT NULL);

PROCEDURE get_marital_status
        (p_oss_marital_status     IN  igs_pe_stat_v.marital_status%TYPE,
         p_hesa_marital_status    OUT NOCOPY VARCHAR2);

PROCEDURE get_dependants
       (p_oss_dependants     IN  igs_he_st_spa.dependants_cd%TYPE,
        p_hesa_dependants    OUT NOCOPY VARCHAR2);

PROCEDURE get_enh_fund_elig
       (p_susa_enh_fund_elig    IN  igs_he_en_susa.enh_fund_elig_cd%TYPE ,
        p_spa_enh_fund_elig     IN  igs_he_st_spa.enh_fund_elig_cd%TYPE,
        p_hesa_enh_fund_elig    OUT NOCOPY VARCHAR2);

PROCEDURE get_learn_dif
       (p_person_id             IN  igs_pe_person.person_id%TYPE,
        p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
        p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
        p_hesa_disability_type  OUT NOCOPY VARCHAR2);

PROCEDURE get_gov_init
       (p_spa_gov_initiatives_cd    IN  igs_he_st_spa.gov_initiatives_cd%TYPE,
        p_prog_gov_initiatives_cd   IN  igs_he_st_prog.gov_initiatives_cd%TYPE,
        p_hesa_gov_initiatives_cd   OUT NOCOPY VARCHAR2);

PROCEDURE get_units_completed
       (p_person_id              IN  igs_pe_person.person_id%TYPE,
        p_course_cd              IN  igs_ps_ver.course_cd%TYPE,
        p_enrl_end_dt            IN  igs_he_submsn_header.enrolment_end_date%TYPE,
        p_spa_units_completed    IN  igs_he_st_spa.units_completed%TYPE,
        p_hesa_units_completed   OUT NOCOPY VARCHAR2);

PROCEDURE get_disadv_uplift_elig
       (p_spa_disadv_uplift_elig_cd    IN  igs_he_st_spa.disadv_uplift_elig_cd%TYPE,
        p_prog_disadv_uplift_elig_cd   IN  igs_he_st_prog.disadv_uplift_elig_cd%TYPE,
        p_hesa_disadv_uplift_elig_cd   OUT NOCOPY VARCHAR2);

PROCEDURE get_franch_out_arr
       (p_spa_franch_out_arr_cd    IN  igs_he_st_spa.franch_out_arr_cd%TYPE,
        p_prog_franch_out_arr_cd   IN  igs_he_st_prog.franch_out_arr_cd%TYPE,
        p_hesa_franch_out_arr_cd   OUT NOCOPY VARCHAR2);

PROCEDURE get_employer_role
       (p_spa_employer_role_cd   IN  igs_he_st_spa.employer_role_cd%TYPE,
        p_hesa_employer_role_cd  OUT NOCOPY VARCHAR2);

PROCEDURE get_franchise_partner
       (p_spa_franch_partner_cd     IN  igs_he_st_spa.franch_partner_cd%TYPE,
        p_hesa_franch_partner_cd    OUT NOCOPY VARCHAR2);

PROCEDURE get_welsh_speaker_ind
       (p_person_id               IN  igs_pe_person.person_id%TYPE,
        p_hesa_welsh_speaker_ind  OUT NOCOPY VARCHAR2);

PROCEDURE get_national_id
       (p_person_id          IN  igs_pe_person.person_id%TYPE,
        p_hesa_national_id1  OUT NOCOPY VARCHAR2,
        p_hesa_national_id2  OUT NOCOPY VARCHAR2);

-- anwest 19-Dec-05 Changes as per (4731723) HE360 - HESA REQUIREMENTS FOR 2005/06 REPORTING
PROCEDURE get_welsh_bacc_qual
       (p_person_id   IN igs_pe_person.person_id%TYPE,
        p_welsh_bacc  OUT NOCOPY VARCHAR2);

END IGS_HE_EXTRACT_FIELDS_PKG;

 

/
