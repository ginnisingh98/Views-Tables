--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_010
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_010" AUTHID CURRENT_USER AS
/* $Header: IGSEN10S.pls 120.1 2005/08/18 05:58:26 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When           What
  --Bayadav     09-Nov-2001    Added the columns catalog cal type and catalog seq num in Enrp_ins_susa_hist as a part of build of career impact DLD
  --Nalin Kumar 11-Nov-2001    Added  Procedure 'adv_stand_trans' as pert of the Career Impact DLD.
  --                           Bug# 2027984.
  --smaddali    26-dec-2001    added 18 new params from units 9-12 and unit set cd1,2 to procedures enrp_ins_snew/sret_prenrl
  --                           bug# 2156956
  --Nalin Kumar 28-Jan-2002    Added  Procedure 'enrp_ins_sca_ukstat_trnsfr' as pert of the HESA Intregation DLD (ENCR019).
  --                           Bug# 2201753.
  --Nishikant   07OCT2002      UK Enhancement Build - Enh Bug#2580731 - Added the parameter p_selection_date in the Function Enrp_Ins_Sret_Prenrl
  --kkillams    25-04-2003     New parameters  p_new_uoo_id and p_old_uoo_id to the function Enrp_Ins_Sua_Hist.
  --                           New parameter  p_uoo_id added to the  Enrp_Ins_Sua_Trnsfr and  Enrp_Ins_Suao_Discon functions
  --                           w.r.t. bug number 2829262
  --amuthu      10-JUN-2003    modified as per the UK Streaming and Repeat TD (bug 2829265)
  --kkillams    16-06-2003     Three new parameters are added to the Enrp_Ins_Snew_Prenrl and Enrp_Ins_Sret_Prenrl functions
  --                           w.r.t. bug no 2829270
  --ptandon     06-Oct-2003    Modified the specifications of Enrp_Ins_Sua_Hist and Enrp_Vald_Inst_Sua as part of
  --                           Prevent Dropping Core Units. Enh Bug# 3052432.
  -- amuthu     21-NOV-2004    Modified as part of program transfer build, modified enrp_ins_sua_trnsfr.
  --                           Added new procedure to copy outcome and placement details
  -- ckasu      11-Dec-2004    Modified signature of Enrp_del_all_Sua_Trnsfr by adding new parameter and removed
  --                           Enrp_del_Sua_Trnsfr as a part of bug#4061818
  -- smaddali  21-dec-04       created new function unit_effect_or_future_term for bug#4083358
  -- rvangala  12-AUG-2005    Bug #4551013. EN320 Build
  -------------------------------------------------------------------------------------------
FUNCTION Enrp_Ins_Snew_Prenrl(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_enrolment_cat               IN VARCHAR2 ,
  p_acad_cal_type               IN VARCHAR2 ,
  p_acad_sequence_number        IN NUMBER ,
  p_units_indicator             IN VARCHAR2 ,
  p_dflt_confirmed_course_ind   IN VARCHAR2 ,
  p_override_enr_form_due_dt    IN DATE ,
  p_override_enr_pckg_prod_dt   IN DATE ,
  p_check_eligibility_ind       IN VARCHAR2 ,
  p_acai_admission_appl_number  IN NUMBER ,
  p_acai_nominated_course_cd    IN VARCHAR2 ,
  p_acai_sequence_number        IN NUMBER ,
  p_unit1_unit_cd               IN VARCHAR2 ,
  p_unit1_cal_type              IN VARCHAR2 ,
  p_unit1_location_cd           IN VARCHAR2 ,
  p_unit1_unit_class            IN VARCHAR2 ,
  p_unit2_unit_cd               IN VARCHAR2 ,
  p_unit2_cal_type              IN VARCHAR2 ,
  p_unit2_location_cd           IN VARCHAR2 ,
  p_unit2_unit_class            IN VARCHAR2 ,
  p_unit3_unit_cd               IN VARCHAR2 ,
  p_unit3_cal_type              IN VARCHAR2 ,
  p_unit3_location_cd           IN VARCHAR2 ,
  p_unit3_unit_class            IN VARCHAR2 ,
  p_unit4_unit_cd               IN VARCHAR2 ,
  p_unit4_cal_type              IN VARCHAR2 ,
  p_unit4_location_cd           IN VARCHAR2 ,
  p_unit4_unit_class            IN VARCHAR2 ,
  p_unit5_unit_cd               IN VARCHAR2 ,
  p_unit5_cal_type              IN VARCHAR2 ,
  p_unit5_location_cd           IN VARCHAR2 ,
  p_unit5_unit_class            IN VARCHAR2 ,
  p_unit6_unit_cd               IN VARCHAR2 ,
  p_unit6_cal_type              IN VARCHAR2 ,
  p_unit6_location_cd           IN VARCHAR2 ,
  p_unit6_unit_class            IN VARCHAR2 ,
  p_unit7_unit_cd               IN VARCHAR2 ,
  p_unit7_cal_type              IN VARCHAR2 ,
  p_unit7_location_cd           IN VARCHAR2 ,
  p_unit7_unit_class            IN VARCHAR2 ,
  p_unit8_unit_cd               IN VARCHAR2 ,
  p_unit8_cal_type              IN VARCHAR2 ,
  p_unit8_location_cd           IN VARCHAR2 ,
  p_unit8_unit_class            IN VARCHAR2 ,
  p_log_creation_dt             IN DATE ,
  p_warn_level                  IN OUT NOCOPY VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2 ,
  --smaddali addded these 18 params for YOP-EN build bug#2156956
  p_unit9_unit_cd               IN VARCHAR2 DEFAULT NULL,
  p_unit9_cal_type              IN VARCHAR2 DEFAULT NULL,
  p_unit9_location_cd           IN VARCHAR2 DEFAULT NULL,
  p_unit9_unit_class            IN VARCHAR2 DEFAULT NULL,
  p_unit10_unit_cd              IN VARCHAR2 DEFAULT NULL,
  p_unit10_cal_type             IN VARCHAR2 DEFAULT NULL,
  p_unit10_location_cd          IN VARCHAR2 DEFAULT NULL,
  p_unit10_unit_class           IN VARCHAR2 DEFAULT NULL,
  p_unit11_unit_cd              IN VARCHAR2 DEFAULT NULL,
  p_unit11_cal_type             IN VARCHAR2 DEFAULT NULL,
  p_unit11_location_cd          IN VARCHAR2 DEFAULT NULL,
  p_unit11_unit_class           IN VARCHAR2 DEFAULT NULL,
  p_unit12_unit_cd              IN VARCHAR2 DEFAULT NULL,
  p_unit12_cal_type             IN VARCHAR2 DEFAULT NULL,
  p_unit12_location_cd          IN VARCHAR2 DEFAULT NULL,
  p_unit12_unit_class           IN VARCHAR2 DEFAULT NULL,
  p_unit_set_cd1                IN VARCHAR2 DEFAULT NULL,
  p_unit_set_cd2                IN VARCHAR2 DEFAULT NULL,
  p_progress_stat               IN VARCHAR2 DEFAULT NULL,
  p_dflt_enr_method             IN VARCHAR2 DEFAULT NULL,
  p_load_cal_type               IN VARCHAR2 DEFAULT NULL,
  p_load_ci_seq_num             IN NUMBER DEFAULT NULL)
RETURN boolean;


FUNCTION Enrp_Ins_Sret_Prenrl(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_enrolment_cat               IN VARCHAR2 ,
  p_acad_cal_type               IN VARCHAR2 ,
  p_acad_sequence_number        IN NUMBER ,
  p_enrol_cal_type              IN VARCHAR2 ,
  p_enrol_sequence_number       IN NUMBER ,
  p_units_ind                   IN VARCHAR2 DEFAULT 'N',
  p_override_enr_form_due_dt    IN DATE ,
  p_override_enr_pckg_prod_dt   IN DATE ,
  p_log_creation_dt             IN DATE ,
  p_warn_level                  OUT NOCOPY VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2  ,
  --smaddali addded these params for YOP-EN build bug#2156956
  p_unit1_unit_cd               IN VARCHAR2 DEFAULT NULL,
  p_unit1_cal_type              IN VARCHAR2 DEFAULT NULL,
  p_unit1_location_cd           IN VARCHAR2 DEFAULT NULL,
  p_unit1_unit_class            IN VARCHAR2 DEFAULT NULL,
  p_unit2_unit_cd               IN VARCHAR2 DEFAULT NULL,
  p_unit2_cal_type              IN VARCHAR2 DEFAULT NULL,
  p_unit2_location_cd           IN VARCHAR2 DEFAULT NULL,
  p_unit2_unit_class            IN VARCHAR2 DEFAULT NULL,
  p_unit3_unit_cd               IN VARCHAR2 DEFAULT NULL,
  p_unit3_cal_type              IN VARCHAR2 DEFAULT NULL,
  p_unit3_location_cd           IN VARCHAR2 DEFAULT NULL,
  p_unit3_unit_class            IN VARCHAR2 DEFAULT NULL,
  p_unit4_unit_cd               IN VARCHAR2 DEFAULT NULL,
  p_unit4_cal_type              IN VARCHAR2 DEFAULT NULL,
  p_unit4_location_cd           IN VARCHAR2 DEFAULT NULL,
  p_unit4_unit_class            IN VARCHAR2 DEFAULT NULL,
  p_unit5_unit_cd               IN VARCHAR2 DEFAULT NULL,
  p_unit5_cal_type              IN VARCHAR2 DEFAULT NULL,
  p_unit5_location_cd           IN VARCHAR2 DEFAULT NULL,
  p_unit5_unit_class            IN VARCHAR2 DEFAULT NULL,
  p_unit6_unit_cd               IN VARCHAR2 DEFAULT NULL,
  p_unit6_cal_type              IN VARCHAR2 DEFAULT NULL,
  p_unit6_location_cd           IN VARCHAR2 DEFAULT NULL,
  p_unit6_unit_class            IN VARCHAR2 DEFAULT NULL,
  p_unit7_unit_cd               IN VARCHAR2 DEFAULT NULL,
  p_unit7_cal_type              IN VARCHAR2 DEFAULT NULL,
  p_unit7_location_cd           IN VARCHAR2 DEFAULT NULL,
  p_unit7_unit_class            IN VARCHAR2 DEFAULT NULL,
  p_unit8_unit_cd               IN VARCHAR2 DEFAULT NULL,
  p_unit8_cal_type              IN VARCHAR2 DEFAULT NULL,
  p_unit8_location_cd           IN VARCHAR2 DEFAULT NULL,
  p_unit8_unit_class            IN VARCHAR2 DEFAULT NULL,
  p_unit9_unit_cd               IN VARCHAR2 DEFAULT NULL,
  p_unit9_cal_type              IN VARCHAR2 DEFAULT NULL,
  p_unit9_location_cd           IN VARCHAR2 DEFAULT NULL,
  p_unit9_unit_class            IN VARCHAR2 DEFAULT NULL,
  p_unit10_unit_cd              IN VARCHAR2 DEFAULT NULL,
  p_unit10_cal_type             IN VARCHAR2 DEFAULT NULL,
  p_unit10_location_cd          IN VARCHAR2 DEFAULT NULL,
  p_unit10_unit_class           IN VARCHAR2 DEFAULT NULL,
  p_unit11_unit_cd              IN VARCHAR2 DEFAULT NULL,
  p_unit11_cal_type             IN VARCHAR2 DEFAULT NULL,
  p_unit11_location_cd          IN VARCHAR2 DEFAULT NULL,
  p_unit11_unit_class           IN VARCHAR2 DEFAULT NULL,
  p_unit12_unit_cd              IN VARCHAR2 DEFAULT NULL,
  p_unit12_cal_type             IN VARCHAR2 DEFAULT NULL,
  p_unit12_location_cd          IN VARCHAR2 DEFAULT NULL,
  p_unit12_unit_class           IN VARCHAR2 DEFAULT NULL,
  p_unit_set_cd1                IN VARCHAR2 DEFAULT NULL,
  p_unit_set_cd2                IN VARCHAR2 DEFAULT NULL,
  --Added the parameter p_selection_date - UK Enhancement Build - Enh Bug#2580731 - 07OCT2002
  p_selection_date              IN DATE DEFAULT NULL,
  --Added the parameter p_completion_date - ENCR030(UK Enh) Build - Enh Bug#2708430 - 16DEC2002
  p_completion_date             IN DATE DEFAULT NULL,
  p_progress_stat               IN VARCHAR2 DEFAULT NULL,
  p_dflt_enr_method             IN VARCHAR2 DEFAULT NULL,
  p_load_cal_type               IN VARCHAR2 DEFAULT NULL,
  p_load_ci_seq_num             IN NUMBER DEFAULT NULL)
RETURN BOOLEAN;

FUNCTION Enrp_Ins_Suao_Discon(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_unit_cd                     IN VARCHAR2 ,
  p_cal_type                    IN VARCHAR2 ,
  p_ci_sequence_number          IN NUMBER ,
  p_ci_start_dt                 IN DATE ,
  p_ci_end_dt                   IN DATE ,
  p_discontinued_dt             IN DATE ,
  p_administrative_unit_status  IN VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_uoo_id                      IN  NUMBER)
RETURN BOOLEAN;


PROCEDURE Enrp_Ins_Sua_Hist(
  p_person_id                   IN IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd                   IN IGS_EN_SU_ATTEMPT_ALL.course_cd%TYPE ,
  p_unit_cd                     IN IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_cal_type                    IN IGS_EN_SU_ATTEMPT_ALL.cal_type%TYPE ,
  p_ci_sequence_number          IN IGS_EN_SU_ATTEMPT_ALL.ci_sequence_number%TYPE ,
  p_new_version_number          IN IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE ,
  p_old_version_number          IN IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE ,
  p_new_location_cd             IN IGS_EN_SU_ATTEMPT_ALL.location_cd%TYPE ,
  p_old_location_cd             IN IGS_EN_SU_ATTEMPT_ALL.location_cd%TYPE ,
  p_new_unit_class              IN IGS_EN_SU_ATTEMPT_ALL.unit_class%TYPE ,
  p_old_unit_class              IN IGS_EN_SU_ATTEMPT_ALL.unit_class%TYPE ,
  p_new_enrolled_dt             IN IGS_EN_SU_ATTEMPT_ALL.enrolled_dt%TYPE ,
  p_old_enrolled_dt             IN IGS_EN_SU_ATTEMPT_ALL.enrolled_dt%TYPE ,
  p_new_unit_attempt_status     IN IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE ,
  p_old_unit_attempt_status     IN IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE ,
  p_new_admin_unit_status       IN IGS_EN_SU_ATTEMPT_ALL.administrative_unit_status%TYPE ,
  p_old_admin_unit_status       IN IGS_EN_SU_ATTEMPT_ALL.administrative_unit_status%TYPE ,
  p_new_discontinued_dt         IN IGS_EN_SU_ATTEMPT_ALL.discontinued_dt%TYPE ,
  p_old_discontinued_dt         IN IGS_EN_SU_ATTEMPT_ALL.discontinued_dt%TYPE ,
  p_new_rule_waived_dt          IN IGS_EN_SU_ATTEMPT_ALL.rule_waived_dt%TYPE ,
  p_old_rule_waived_dt          IN IGS_EN_SU_ATTEMPT_ALL.rule_waived_dt%TYPE ,
  p_new_rule_waived_person_id   IN IGS_EN_SU_ATTEMPT_ALL.rule_waived_person_id%TYPE ,
  p_old_rule_waived_person_id   IN IGS_EN_SU_ATTEMPT_ALL.rule_waived_person_id%TYPE ,
  p_new_no_assessment_ind       IN IGS_EN_SU_ATTEMPT_ALL.no_assessment_ind%TYPE ,
  p_old_no_assessment_ind       IN IGS_EN_SU_ATTEMPT_ALL.no_assessment_ind%TYPE ,
  p_new_exam_location_cd        IN IGS_EN_SU_ATTEMPT_ALL.exam_location_cd%TYPE ,
  p_old_exam_location_cd        IN IGS_EN_SU_ATTEMPT_ALL.exam_location_cd%TYPE ,
  p_new_sup_unit_cd             IN IGS_EN_SU_ATTEMPT_ALL.sup_unit_cd%TYPE ,
  p_old_sup_unit_cd             IN IGS_EN_SU_ATTEMPT_ALL.sup_unit_cd%TYPE ,
  p_new_sup_version_number      IN IGS_EN_SU_ATTEMPT_ALL.sup_version_number%TYPE ,
  p_old_sup_version_number      IN IGS_EN_SU_ATTEMPT_ALL.sup_version_number%TYPE ,
  p_new_alternative_title       IN IGS_EN_SU_ATTEMPT_ALL.alternative_title%TYPE ,
  p_old_alternative_title       IN IGS_EN_SU_ATTEMPT_ALL.alternative_title%TYPE ,
  p_new_override_enrolled_cp    IN IGS_EN_SU_ATTEMPT_ALL.override_enrolled_cp%TYPE ,
  p_old_override_enrolled_cp    IN IGS_EN_SU_ATTEMPT_ALL.override_enrolled_cp%TYPE ,
  p_new_override_eftsu          IN IGS_EN_SU_ATTEMPT_ALL.override_eftsu%TYPE ,
  p_old_override_eftsu          IN IGS_EN_SU_ATTEMPT_ALL.override_eftsu%TYPE ,
  p_new_override_achievable_cp  IN IGS_EN_SU_ATTEMPT_ALL.override_achievable_cp%TYPE ,
  p_old_override_achievable_cp  IN IGS_EN_SU_ATTEMPT_ALL.override_achievable_cp%TYPE ,
  p_new_override_outcome_due_dt IN IGS_EN_SU_ATTEMPT_ALL.override_outcome_due_dt%TYPE ,
  p_old_override_outcome_due_dt IN IGS_EN_SU_ATTEMPT_ALL.override_outcome_due_dt%TYPE ,
  p_new_override_credit_reason  IN IGS_EN_SU_ATTEMPT_ALL.override_credit_reason%TYPE ,
  p_old_override_credit_reason  IN IGS_EN_SU_ATTEMPT_ALL.override_credit_reason%TYPE ,
  p_new_update_who              IN IGS_EN_SU_ATTEMPT_ALL.last_updated_by%TYPE ,
  p_old_update_who              IN IGS_EN_SU_ATTEMPT_ALL.last_updated_by%TYPE ,
  p_new_update_on               IN IGS_EN_SU_ATTEMPT_ALL.last_update_date%TYPE ,
  p_old_update_on               IN IGS_EN_SU_ATTEMPT_ALL.last_update_date%TYPE ,
  p_new_dcnt_reason_Cd          IN IGS_EN_SU_ATTEMPT_ALL.dcnt_reason_cd%TYPE,
  p_old_dcnt_reason_Cd          IN IGS_EN_SU_ATTEMPT_ALL.dcnt_reason_cd%TYPE,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT_ALL.uoo_id%TYPE,
  p_new_core_indicator_code     IN IGS_EN_SU_ATTEMPT_ALL.core_indicator_code%TYPE DEFAULT NULL, -- ptandon, Prevent Dropping Core Units build
  p_old_core_indicator_code     IN IGS_EN_SU_ATTEMPT_ALL.core_indicator_code%TYPE DEFAULT NULL -- ptandon, Prevent Dropping Core Units build
  );

FUNCTION Enrp_Ins_Sua_Trnsfr(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_transfer_course_cd  IN VARCHAR2 ,
  p_coo_id              IN NUMBER ,
  p_unit_cd             IN VARCHAR2 ,
  p_version_number      IN NUMBER ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_return_type         OUT NOCOPY VARCHAR2 ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER,
  p_core_ind            IN VARCHAR2,
  p_term_cal_type       IN VARCHAR2,
  p_term_seq_num        IN NUMBER)
RETURN BOOLEAN;


PROCEDURE Enrp_Ins_Susa_Hist(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_new_us_version_number IN NUMBER ,
  p_old_us_version_number IN NUMBER ,
  p_new_selection_dt IN DATE ,
  p_old_selection_dt IN DATE ,
  p_new_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_old_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_new_end_dt IN DATE ,
  p_old_end_dt IN DATE ,
  p_new_parent_unit_set_cd IN VARCHAR2 ,
  p_old_parent_unit_set_cd IN VARCHAR2 ,
  p_new_parent_sequence_number IN NUMBER ,
  p_old_parent_sequence_number IN NUMBER ,
  p_new_primary_set_ind IN VARCHAR2 DEFAULT 'N',
  p_old_primary_set_ind IN VARCHAR2 DEFAULT 'N',
  p_new_voluntary_end_ind IN VARCHAR2 DEFAULT 'N',
  p_old_voluntary_end_ind IN VARCHAR2 DEFAULT 'N',
  p_new_authorised_person_id IN NUMBER ,
  p_old_authorised_person_id IN NUMBER ,
  p_new_authorised_on IN DATE ,
  p_old_authorised_on IN DATE ,
  p_new_override_title IN VARCHAR2 ,
  p_old_override_title IN VARCHAR2 ,
  p_new_rqrmnts_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_old_rqrmnts_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_new_rqrmnts_complete_dt IN DATE ,
  p_old_rqrmnts_complete_dt IN DATE ,
  p_new_s_completed_source_type IN VARCHAR2 ,
  p_old_s_completed_source_type IN VARCHAR2 ,
  p_new_catalog_cal_type  IN VARCHAR2  DEFAULT NULL,
  p_old_catalog_cal_type  IN VARCHAR2  DEFAULT NULL,
  p_new_catalog_seq_num IN NUMBER  DEFAULT NULL,
  p_old_catalog_seq_num IN NUMBER  DEFAULT NULL,
  p_new_update_who IN IGS_EN_SU_ATTEMPT_ALL.last_updated_by%TYPE,
  p_old_update_who IN IGS_EN_SU_ATTEMPT_ALL.last_updated_by%TYPE,
  p_new_update_on IN IGS_EN_SU_ATTEMPT_ALL.last_update_date%TYPE DEFAULT NULL,
  p_old_update_on IN IGS_EN_SU_ATTEMPT_ALL.last_update_date%TYPE DEFAULT NULL);

FUNCTION Enrp_Ins_Susa_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_primary_set_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;


FUNCTION Enrp_Ins_Sut_Trnsfr(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_transfer_course_cd  IN VARCHAR2 ,
  p_transfer_dt         IN DATE ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER)
RETURN BOOLEAN;

PROCEDURE adv_stand_trans(
  p_person_id           IN NUMBER,
  p_course_cd           IN VARCHAR2,
  p_version_number      IN NUMBER,
  p_course_cd_new       IN VARCHAR2,
  p_version_number_new  IN NUMBER,
  p_message_name        OUT NOCOPY VARCHAR2
);

PROCEDURE  enrp_ins_sca_ukstat_trnsfr( p_person_id             IN  NUMBER,
                                       p_source_course_cd      IN  VARCHAR2,
                                       p_destination_course_cd IN  VARCHAR2,
                                       p_message_name          OUT NOCOPY VARCHAR2 );
FUNCTION enrp_vald_inst_sua(
p_person_id             IN  igs_en_su_attempt.person_id%TYPE,
p_course_cd             IN  igs_en_su_attempt.course_cd%TYPE,
p_unit_cd               IN  igs_en_su_attempt.unit_cd%TYPE,
p_version_number        IN  igs_en_su_attempt.version_number%TYPE,
p_teach_cal_type        IN  igs_en_su_attempt.cal_type%TYPE,
p_teach_seq_num         IN  igs_en_su_attempt.ci_sequence_number%TYPE,
p_load_cal_type         IN  igs_en_su_attempt.cal_type%TYPE,
p_load_seq_num          IN  igs_en_su_attempt.ci_sequence_number%TYPE,
p_location_cd           IN  igs_en_su_attempt.location_cd%TYPE,
p_unit_class            IN  igs_en_su_attempt.unit_class%TYPE,
p_uoo_id                IN  igs_en_su_attempt.uoo_id%TYPE,
p_enr_method            IN  igs_en_method_type.enr_method_type%TYPE,
p_core_indicator_code   IN  igs_en_su_attempt.core_indicator_code%TYPE DEFAULT NULL, -- ptandon, Prevent Dropping Core Units build
p_message               OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

FUNCTION enrf_unit_from_past(
  p_person_id IN NUMBER,
  p_source_course_cd IN VARCHAR2,
  p_uoo_id IN NUMBER,
  p_unit_attempt_status IN VARCHAR2,
  p_discontinued_dt IN DATE,
  p_term_cal_type IN VARCHAR2,
  p_term_seq_num IN NUMBER) RETURN BOOLEAN;

FUNCTION Enrp_del_all_Sua_Trnsfr(
  p_person_id           IN NUMBER ,
  p_source_course_cd    IN VARCHAR2 ,
  p_dest_course_cd      IN VARCHAR2 ,
  p_uoo_ids             IN VARCHAR2,
  P_TERM_CAL_TYPE       IN VARCHAR2,
  P_TERM_SEQ_NUM        IN NUMBER,
  p_drop                IN BOOLEAN,
  p_message_name        OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

PROCEDURE Enrp_Ins_Splace_Trnsfr (
  p_person_id IN NUMBER,
  p_source_course_cd IN VARCHAR2,
  p_dest_course_cd IN VARCHAR2,
  p_source_uoo_id IN NUMBER,
  p_dest_uoo_id IN NUMBER);

PROCEDURE Enrp_Ins_Suao_Trnsfr (
  p_person_id IN NUMBER,
  p_source_course_cd IN VARCHAR2,
  p_dest_course_cd IN VARCHAR2,
  p_source_uoo_id IN NUMBER,
  p_dest_uoo_id IN NUMBER,
  p_delete_source IN BOOLEAN);

FUNCTION enrf_sup_sua_exists(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_uoo_id IN NUMBER)
RETURN BOOLEAN;

 -- smaddali added this function for bug#4083358
 FUNCTION  unit_effect_or_future_term( p_person_id igs_en_stdnt_ps_att_all.person_id%TYPE,
                                 p_dest_course_cd igs_en_stdnt_ps_att_all.course_cd%TYPE,
                                 p_uoo_id  igs_en_su_attempt_all.uoo_id%TYPE,
                                 p_term_cal_type igs_ca_inst_all.cal_type%TYPE,
                                 p_term_seq_num igs_ca_inst_all.sequence_number%TYPE)
 RETURN BOOLEAN ;

 PROCEDURE enrp_ins_suai_trnsfr(
  p_person_id IN NUMBER,
  p_source_course_cd IN VARCHAR2,
  p_dest_course_cd IN VARCHAR2,
  p_source_uoo_id IN NUMBER,
  p_dest_uoo_id IN NUMBER,
  p_delete_source IN BOOLEAN);


END IGS_EN_GEN_010;

 

/
