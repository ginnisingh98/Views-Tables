--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_009
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_009" AUTHID CURRENT_USER AS
/* $Header: IGSEN09S.pls 120.1 2005/09/30 02:59:08 appldev ship $ */

/*=======================================================================+
 | HISTORY
 | sarakshi    17-Nov-2004  Enh#4000939, added parameter p_trans_approved_dt,p_term_cal_type,p_term_seq_num and
 |                          p_discontinue_src_flag in function Enrp_Ins_Sct_Trnsfr
 | Nalin Kumar 23-Nov-2001 Added enrp_ins_award_aim procedure as the part of
 |                         UK Award Aims DLD Bug ID: 1366899
 | svenkata 25-02-02       Removed the procedure ENRP_INS_ENRL_FORM as part of CCR
 |                         ENCR024 .Bug # 2239050
 | amuthu   10-JUN-2003    modified as per the UK Streaming and Repeat TD (bug 2829265)
 | kkillams 17-Jun-2003    Three New parameters are added to Enrp_Ins_Pre_Pos function
 |                         w.r.t. bug 3829270
 | ptandon  7-OCT-2003     Added a new Function Enrp_Check_Usec_Core as
 |                         part of Prevent Dropping Core Units build.
 |                         Enh Bug#3052432.
 | rvangala 012-Dec-2003   Added 2 new parameters to enrp_ins_sca_hist
 | bdeviset  11-DEC-2004   Added extra parameters to Enrp_Ins_Sct_Trnsfr as
 |                         UOOID_TO_TRANSFER,SUSA_TO_TRANSFER, TRANSFER_ADV_STAND_FLAG transfer table
 | amuthu    05-JAN-2005   Added new method for deriving the core indicator value for the destinations
 |                         program attempt in a transfer enrp_chk_dest_usec_core
 | ckasu     29-SEP-2005   Modfied signature of enrp_chk_dest_usec_core inorder to include cooid as
 |                         a part of bug #4278867
 *=======================================================================*/
Procedure Enrp_Ins_Dflt_Effect(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_message_name out NOCOPY Varchar2 ,
  p_message_string IN OUT NOCOPY VARCHAR2 );


PROCEDURE enrp_ins_award_aim (
  p_person_id       IN NUMBER,
  p_course_cd       IN VARCHAR2,
  p_version_number  IN NUMBER,
  p_start_dt        IN DATE
);


Procedure Enrp_Ins_Merge_Log(
  p_smir_id IN NUMBER );

Function Enrp_Ins_Pre_Pos(
  p_acad_cal_type               IN VARCHAR2 ,
  p_acad_sequence_number        IN NUMBER ,
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_version_number              IN NUMBER ,
  p_location_cd                 IN VARCHAR2 ,
  p_attendance_mode             IN VARCHAR2 ,
  p_attendance_type             IN VARCHAR2 ,
  p_unit_set_cd                 IN VARCHAR2 ,
  p_adm_cal_type                IN VARCHAR2 ,
  p_admission_cat               IN VARCHAR2 ,
  p_log_creation_dt             IN DATE ,
  p_units_indicator             IN VARCHAR2 DEFAULT 'N', -- Added this paramter as part of Core Vs Optional DLD.
  p_warn_level                  IN OUT NOCOPY VARCHAR2 ,
  p_message_name                IN OUT NOCOPY VARCHAR2,
  p_progress_stat               IN VARCHAR2 DEFAULT NULL,
  p_progress_outcome_type       IN VARCHAR2 DEFAULT NULL,
  p_enr_method                  IN VARCHAR2 DEFAULT NULL,
  p_load_cal_type               IN VARCHAR2 DEFAULT NULL,
  p_load_ci_seq_num             IN NUMBER DEFAULT NULL)
RETURN boolean;


Function Enrp_Ins_Scae_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_enrolment_cat IN VARCHAR2 ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;


Function Enrp_Ins_Sca_Cah(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_commencement_dt IN DATE ,
  p_old_attendance_type IN VARCHAR2 ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;

-- Modified by : jbegum
-- Added 4 new parameters p_new_last_date_of_attendance , p_old_last_date_of_attendance , p_new_dropped_by , p_old_dropped_by
-- as part of Enhancement Bug # 1832130

-- Modified by : kkillams
-- Added 8 new parameters p_new_primary_program_type,p_old_primary_program_type,p_new_primary_prog_type_source,p_old_primary_prog_type_source,
-- p_new_catalog_cal_type,p_old_catalog_cal_type,p_new_catalog_seq_num,p_old_catalog_seq_num,p_new_key_program,p_old_key_program
-- as part of Enhancement Bug # 2027984

Procedure Enrp_Ins_Sca_Hist(
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_new_version_number IN IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_old_version_number IN IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_new_cal_type IN IGS_EN_STDNT_PS_ATT_ALL.CAL_TYPE%TYPE ,
  p_old_cal_type IN IGS_EN_STDNT_PS_ATT_ALL.CAL_TYPE%TYPE ,
  p_new_location_cd IN IGS_EN_STDNT_PS_ATT_ALL.location_cd%TYPE ,
  p_old_location_cd IN IGS_EN_STDNT_PS_ATT_ALL.location_cd%TYPE ,
  p_new_attendance_mode IN IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_MODE%TYPE ,
  p_old_attendance_mode IN IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_MODE%TYPE ,
  p_new_attendance_type IN IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_TYPE%TYPE ,
  p_old_attendance_type IN IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_TYPE%TYPE ,
  p_new_student_confirmed_ind IN IGS_EN_STDNT_PS_ATT_ALL.student_confirmed_ind%TYPE ,
  p_old_student_confirmed_ind IN IGS_EN_STDNT_PS_ATT_ALL.student_confirmed_ind%TYPE ,
  p_new_commencement_dt IN IGS_EN_STDNT_PS_ATT_ALL.commencement_dt%TYPE ,
  p_old_commencement_dt IN IGS_EN_STDNT_PS_ATT_ALL.commencement_dt%TYPE ,
  p_new_course_attempt_status IN IGS_EN_STDNT_PS_ATT_ALL.course_attempt_status%TYPE ,
  p_old_course_attempt_status IN IGS_EN_STDNT_PS_ATT_ALL.course_attempt_status%TYPE ,
  p_new_progression_status IN VARCHAR2 ,
  p_old_progression_status IN VARCHAR2 ,
  p_new_derived_att_type IN IGS_EN_STDNT_PS_ATT_ALL.derived_att_type%TYPE ,
  p_old_derived_att_type IN IGS_EN_STDNT_PS_ATT_ALL.derived_att_type%TYPE ,
  p_new_derived_att_mode IN IGS_EN_STDNT_PS_ATT_ALL.derived_att_mode%TYPE ,
  p_old_derived_att_mode IN IGS_EN_STDNT_PS_ATT_ALL.derived_att_mode%TYPE ,
  p_new_provisional_ind IN IGS_EN_STDNT_PS_ATT_ALL.provisional_ind%TYPE ,
  p_old_provisional_ind IN IGS_EN_STDNT_PS_ATT_ALL.provisional_ind%TYPE ,
  p_new_discontinued_dt IN IGS_EN_STDNT_PS_ATT_ALL.discontinued_dt%TYPE ,
  p_old_discontinued_dt IN IGS_EN_STDNT_PS_ATT_ALL.discontinued_dt%TYPE ,
  p_new_dscntntn_reason_cd IN IGS_EN_STDNT_PS_ATT_ALL.DISCONTINUATION_REASON_CD%TYPE ,
  p_old_dscntntn_reason_cd IN IGS_EN_STDNT_PS_ATT_ALL.DISCONTINUATION_REASON_CD%TYPE ,
  p_new_lapsed_dt IN DATE ,
  p_old_lapsed_dt IN DATE ,
  p_new_funding_source IN IGS_EN_STDNT_PS_ATT_ALL.FUNDING_SOURCE%TYPE ,
  p_old_funding_source IN IGS_EN_STDNT_PS_ATT_ALL.FUNDING_SOURCE%TYPE ,
  p_new_exam_location_cd IN IGS_EN_STDNT_PS_ATT_ALL.exam_location_cd%TYPE ,
  p_old_exam_location_cd IN IGS_EN_STDNT_PS_ATT_ALL.exam_location_cd%TYPE ,
  p_new_derived_cmpltn_yr IN IGS_EN_STDNT_PS_ATT_ALL.derived_completion_yr%TYPE ,
  p_old_derived_cmpltn_yr IN IGS_EN_STDNT_PS_ATT_ALL.derived_completion_yr%TYPE ,
  p_new_derived_cmpltn_perd IN IGS_EN_STDNT_PS_ATT_ALL.derived_completion_perd%TYPE ,
  p_old_derived_cmpltn_perd IN IGS_EN_STDNT_PS_ATT_ALL.derived_completion_perd%TYPE ,
  p_new_nominated_cmpltn_yr IN IGS_EN_STDNT_PS_ATT_ALL.nominated_completion_yr%TYPE ,
  p_old_nominated_cmpltn_yr IN IGS_EN_STDNT_PS_ATT_ALL.nominated_completion_yr%TYPE ,
  p_new_nominated_cmpltn_perd IN IGS_EN_STDNT_PS_ATT_ALL.nominated_completion_perd%TYPE ,
  p_old_nominated_cmpltn_perd IN IGS_EN_STDNT_PS_ATT_ALL.nominated_completion_perd%TYPE ,
  p_new_rule_check_ind IN IGS_EN_STDNT_PS_ATT_ALL.rule_check_ind%TYPE ,
  p_old_rule_check_ind IN IGS_EN_STDNT_PS_ATT_ALL.rule_check_ind%TYPE ,
  p_new_waive_option_check_ind IN IGS_EN_STDNT_PS_ATT_ALL.waive_option_check_ind%TYPE ,
  p_old_waive_option_check_ind IN IGS_EN_STDNT_PS_ATT_ALL.waive_option_check_ind%TYPE ,
  p_new_last_rule_check_dt IN IGS_EN_STDNT_PS_ATT_ALL.last_rule_check_dt%TYPE ,
  p_old_last_rule_check_dt IN IGS_EN_STDNT_PS_ATT_ALL.last_rule_check_dt%TYPE ,
  p_new_publish_outcomes_ind IN IGS_EN_STDNT_PS_ATT_ALL.publish_outcomes_ind%TYPE ,
  p_old_publish_outcomes_ind IN IGS_EN_STDNT_PS_ATT_ALL.publish_outcomes_ind%TYPE ,
  p_new_crs_rqrmnt_complete_ind IN IGS_EN_STDNT_PS_ATT_ALL.course_rqrmnt_complete_ind%TYPE ,
  p_old_crs_rqrmnt_complete_ind IN IGS_EN_STDNT_PS_ATT_ALL.course_rqrmnt_complete_ind%TYPE ,
  p_new_crs_rqrmnts_complete_dt IN DATE ,
  p_old_crs_rqrmnts_complete_dt IN DATE ,
  p_new_s_completed_source_type IN VARCHAR2 ,
  p_old_s_completed_source_type IN VARCHAR2 ,
  p_new_override_time_limitation IN IGS_EN_STDNT_PS_ATT_ALL.override_time_limitation%TYPE ,
  p_old_override_time_limitation IN IGS_EN_STDNT_PS_ATT_ALL.override_time_limitation%TYPE ,
  p_new_advanced_standing_ind IN IGS_EN_STDNT_PS_ATT_ALL.advanced_standing_ind%TYPE ,
  p_old_advanced_standing_ind IN IGS_EN_STDNT_PS_ATT_ALL.advanced_standing_ind%TYPE ,
  p_new_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.FEE_CAT%TYPE ,
  p_old_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.FEE_CAT%TYPE ,
  p_new_self_help_group_ind IN VARCHAR2 ,
  p_old_self_help_group_ind IN VARCHAR2 ,
  p_new_correspondence_cat IN VARCHAR2 ,
  p_old_correspondence_cat IN IGS_EN_STDNT_PS_ATT_ALL.CORRESPONDENCE_CAT%TYPE ,
  p_new_adm_adm_appl_number IN NUMBER ,
  p_old_adm_adm_appl_number IN NUMBER ,
  p_new_adm_nominated_course_cd IN VARCHAR2 ,
  p_old_adm_nominated_course_cd IN VARCHAR2 ,
  p_new_adm_sequence_number IN NUMBER ,
  p_old_adm_sequence_number IN NUMBER ,
  p_new_update_who IN IGS_EN_STDNT_PS_ATT_ALL.last_updated_by%TYPE ,
  p_old_update_who IN IGS_EN_STDNT_PS_ATT_ALL.last_updated_by%TYPE ,
  p_new_update_on IN IGS_EN_STDNT_PS_ATT_ALL.last_update_date%TYPE ,
  p_old_update_on IN IGS_EN_STDNT_PS_ATT_ALL.last_update_date%TYPE ,
  p_new_last_date_of_attendance IN IGS_EN_STDNT_PS_ATT_ALL.last_date_of_attendance%TYPE DEFAULT NULL,
  p_old_last_date_of_attendance IN IGS_EN_STDNT_PS_ATT_ALL.last_date_of_attendance%TYPE DEFAULT NULL,
  p_new_dropped_by IN IGS_EN_STDNT_PS_ATT_ALL.dropped_by%TYPE DEFAULT NULL,
  p_old_dropped_by IN IGS_EN_STDNT_PS_ATT_ALL.dropped_by%TYPE DEFAULT NULL,
  p_new_primary_program_type IN IGS_EN_STDNT_PS_ATT_ALL.primary_program_type%TYPE DEFAULT NULL,
  p_old_primary_program_type IN IGS_EN_STDNT_PS_ATT_ALL.primary_program_type%TYPE DEFAULT NULL,
  p_new_primary_prog_type_source IN IGS_EN_STDNT_PS_ATT_ALL.primary_prog_type_source%TYPE DEFAULT NULL,
  p_old_primary_prog_type_source IN IGS_EN_STDNT_PS_ATT_ALl.primary_prog_type_source%TYPE DEFAULT NULL,
  p_new_catalog_cal_type IN  IGS_EN_STDNT_PS_ATT_ALl.catalog_cal_type%TYPE DEFAULT NULL,
  p_old_catalog_cal_type IN  IGS_EN_STDNT_PS_ATT_ALl.catalog_cal_type%TYPE DEFAULT NULL,
  p_new_catalog_seq_num IN  IGS_EN_STDNT_PS_ATT_ALl.catalog_seq_num%TYPE DEFAULT NULL,
  p_old_catalog_seq_num IN  IGS_EN_STDNT_PS_ATT_ALl.catalog_seq_num%TYPE DEFAULT NULL,
  p_new_key_program IN  IGS_EN_STDNT_PS_ATT_ALl.key_program%TYPE DEFAULT 'N',
  p_old_key_program IN  IGS_EN_STDNT_PS_ATT_ALl.key_program%TYPE DEFAULT 'N',
  p_new_override_cmpl_dt IN IGS_EN_STDNT_PS_ATT_ALL.override_cmpl_dt%TYPE DEFAULT NULL,
  p_old_override_cmpl_dt IN IGS_EN_STDNT_PS_ATT_ALL.override_cmpl_dt%TYPE DEFAULT NULL ,
  p_new_manual_ovr_cmpl_dt_ind IN IGS_EN_STDNT_PS_ATT_ALL.manual_ovr_cmpl_dt_ind%TYPE DEFAULT 'N',
  p_old_manual_ovr_cmpl_dt_ind IN IGS_EN_STDNT_PS_ATT_ALL.manual_ovr_cmpl_dt_ind%TYPE DEFAULT 'N',
  p_new_coo_id IN IGS_EN_STDNT_PS_ATT_ALL.coo_id%TYPE,
  p_old_coo_id IN IGS_EN_STDNT_PS_ATT_ALL.coo_id%TYPE,
  p_new_igs_pr_class_std_id IGS_EN_STDNT_PS_ATT_ALL.igs_pr_class_std_id%TYPE DEFAULT NULL,
  p_old_igs_pr_class_std_id IGS_EN_STDNT_PS_ATT_ALL.igs_pr_class_std_id%TYPE DEFAULT NULL
);

Function Enrp_Ins_Scho_Dflt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN boolean;


Function Enrp_Ins_Sct_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_transfer_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_trans_approved_dt    IN DATE,
  p_term_cal_type        IN VARCHAR2,
  p_term_seq_num         IN NUMBER,
  p_discontinue_src_flag IN VARCHAR2,
  p_uooids_to_transfer IN VARCHAR2,
  p_susa_to_transfer IN VARCHAR2,
  p_transfer_adv_stand_flag IN VARCHAR2,
  p_status_date IN DATE,
  p_status_flag IN VARCHAR2)
RETURN BOOLEAN;

--
-- Added as Part of EN213 Build
-- This Function checks whether the given unit section is a core unit or not in the
-- current pattern of study for the given student program attempt.
--

FUNCTION enrp_check_usec_core(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2 ,
  p_uoo_id IN NUMBER )
RETURN VARCHAR2;

FUNCTION enrp_chk_dest_usec_core(
  p_person_id IN NUMBER ,
  p_src_program_cd IN VARCHAR2 ,
  p_dest_program_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2,
  p_uoo_id IN NUMBER,
  p_coo_id IN NUMBER)
RETURN VARCHAR2;


END IGS_EN_GEN_009;

 

/
