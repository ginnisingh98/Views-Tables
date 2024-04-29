--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_LEGACY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_LEGACY" AUTHID CURRENT_USER AS
/* $Header: IGSEN91S.pls 120.1 2005/10/28 04:14:32 appldev ship $ */

FUNCTION validate_grading_schm (
p_grade IN VARCHAR2 ,
p_uoo_id IN NUMBER ,
p_unit_cd IN VARCHAR2 ,
p_version_number IN NUMBER)
RETURN BOOLEAN ;

FUNCTION validate_disc_rsn_cd (
p_discontinuation_reason_cd IN VARCHAR2
) RETURN BOOLEAN ;

FUNCTION validate_trn_unit (
p_person_id IN NUMBER ,
p_program_cd IN VARCHAR2 ,
p_cal_type IN VARCHAR2 ,
p_ci_sequence_number IN NUMBER ,
p_unit_cd IN VARCHAR2 ,
p_location_cd IN VARCHAR2 ,
P_unit_class IN VARCHAR2 ,
p_unit_attempt_status OUT NOCOPY VARCHAR2
) RETURN BOOLEAN ;

FUNCTION  validate_transfer (
p_person_id IN NUMBER ,
p_transfer_program_cd IN VARCHAR2
) RETURN BOOLEAN ;

FUNCTION get_uoo_id (
p_cal_type IN VARCHAR2 ,
p_ci_sequence_number IN NUMBER ,
p_unit_cd IN VARCHAR2 ,
p_location_cd IN VARCHAR2 ,
P_unit_class IN VARCHAR2 ,
p_version_number IN NUMBER ,
p_uoo_id OUT NOCOPY NUMBER ,
p_owner_org_unit_cd OUT NOCOPY VARCHAR2
) RETURN BOOLEAN ;

FUNCTION get_unit_ver (
p_cal_type IN VARCHAR2 ,
p_ci_sequence_number IN NUMBER ,
p_unit_cd IN VARCHAR2 ,
p_location_cd IN VARCHAR2 ,
P_unit_class IN VARCHAR2 ,
p_version_number OUT NOCOPY NUMBER
) RETURN BOOLEAN  ;

FUNCTION validate_grad_sch_cd_ver (
p_uoo_id IN NUMBER ,
p_unit_cd IN VARCHAR2 ,
p_version_number IN NUMBER ,
p_grading_schema_code IN VARCHAR2 ,
p_gs_version_number IN NUMBER ,
P_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

FUNCTION validate_prgm_att_stat (
p_person_id IN NUMBER ,
p_course_cd IN VARCHAR2 ,
p_discontin_dt OUT NOCOPY  DATE ,
p_program_type OUT NOCOPY VARCHAR2 ,
p_commencement_dt OUT NOCOPY DATE ,
p_version_number OUT NOCOPY NUMBER)
RETURN VARCHAR2;

PROCEDURE get_last_dt_of_att (
x_person_id IN NUMBER,
x_course_cd IN VARCHAR2,
x_last_date_of_attendance OUT NOCOPY DATE );

FUNCTION get_coo_id(
p_course_cd                   IN  igs_ps_ofr_opt.course_cd%TYPE,
p_version_number              IN  igs_ps_ofr_opt.version_number%TYPE,
p_cal_type                    IN  igs_ps_ofr_opt.cal_type%TYPE,
p_location_cd                 IN  igs_ps_ofr_opt.location_cd%TYPE,
p_attendance_mode             IN  igs_ps_ofr_opt.attendance_mode%TYPE,
p_attendance_type             IN  igs_ps_ofr_opt.attendance_type%TYPE)
RETURN igs_ps_ofr_opt.coo_id%TYPE;

FUNCTION get_class_std_id(
p_class_standing         IN igs_pr_class_std.class_standing%TYPE)
RETURN igs_pr_class_std.igs_pr_class_std_id%TYPE;

FUNCTION get_course_att_status(
p_person_id                     IN igs_en_stdnt_ps_att.person_id%TYPE,
p_course_cd                     IN igs_en_stdnt_ps_att.course_cd%TYPE,
p_student_confirmed_ind         IN igs_en_stdnt_ps_att.student_confirmed_ind%TYPE,
p_discontinued_dt               IN igs_en_stdnt_ps_att.discontinued_dt%TYPE,
p_lapsed_dt                     IN igs_en_stdnt_ps_att.lapsed_dt%TYPE,
p_course_rqrmnt_complete_ind    IN igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE,
p_primary_pg_type               IN igs_en_stdnt_ps_att.primary_program_type%TYPE,
p_primary_prog_type_source      IN igs_en_stdnt_ps_att.primary_prog_type_source%TYPE,
p_course_type                   IN igs_ps_type.course_type%TYPE,
p_career_flag                   IN VARCHAR2)
RETURN igs_en_stdnt_ps_att.course_attempt_status%TYPE;

FUNCTION get_sca_dropped_by
RETURN igs_en_stdnt_ps_att.dropped_by%TYPE;

FUNCTION get_sca_prog_type(
p_course_cd             IN igs_ps_ver.course_cd%TYPE,
p_version_number         IN igs_ps_ver.version_number%TYPE)
RETURN igs_ps_ver.course_type%TYPE;

FUNCTION val_sca_start_dt (
p_student_confirmed_ind  IN igs_en_stdnt_ps_att.student_confirmed_ind%TYPE,
p_commencement_dt        IN igs_en_stdnt_ps_att.commencement_dt%TYPE)
RETURN BOOLEAN;

FUNCTION val_sca_disc_date(
p_discontinued_dt      igs_en_stdnt_ps_att.discontinued_dt%TYPE)
RETURN BOOLEAN;

FUNCTION val_sca_reqcmpl_dt(
p_course_rqrmnt_comp_ind        IN igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE,
p_course_rqrmnts_comp_dt        IN igs_en_stdnt_ps_att.course_rqrmnts_complete_dt%TYPE,
p_message_name                  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

FUNCTION val_sca_key_prg(
p_person_id             IN igs_en_stdnt_ps_att.person_id%TYPE,
p_course_cd             IN igs_en_stdnt_ps_att.course_cd%TYPE,
p_key_program           IN igs_en_stdnt_ps_att.key_program%TYPE,
p_primary_prg_type      IN igs_en_stdnt_ps_att.primary_program_type%TYPE,
p_course_attempt_st     IN igs_en_stdnt_ps_att.course_attempt_status%TYPE,
p_career_flag           VARCHAR2)
RETURN BOOLEAN;

FUNCTION val_sca_primary_pg(
p_person_id             IN igs_en_stdnt_ps_att.person_id%TYPE,
p_primary_prog_type     IN igs_en_stdnt_ps_att.primary_program_type%TYPE,
p_course_type           IN igs_ps_type.course_type%TYPE)
RETURN BOOLEAN;

FUNCTION val_sca_comp_flag (
p_course_attempt_status         IN igs_en_stdnt_ps_att.course_attempt_status%TYPE,
p_course_rqrmnt_complete_ind    IN igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE)
RETURN BOOLEAN;

FUNCTION val_sca_per_type(
p_person_id             igs_en_stdnt_ps_att.person_id%TYPE,
p_course_cd             igs_en_stdnt_ps_att.course_cd%TYPE,
p_course_attempt_status igs_en_stdnt_ps_att.course_attempt_status%TYPE)
RETURN BOOLEAN;




FUNCTION check_pre_enroll_prof (
p_unit_set_cd       IN igs_as_su_setatmpt.unit_set_cd%TYPE,
p_us_version_number     IN igs_as_su_setatmpt.us_version_number%TYPE)
RETURN BOOLEAN;


FUNCTION check_usa_overlap (
p_person_id                     IN igs_as_su_setatmpt.person_id%TYPE,
p_program_cd            IN igs_as_su_setatmpt.course_cd%TYPE,
p_selection_dt          IN igs_as_su_setatmpt.selection_dt%TYPE,
p_rqrmnts_complete_dt   IN igs_as_su_setatmpt.rqrmnts_complete_dt%TYPE,
p_end_dt                IN igs_as_su_setatmpt.end_dt%TYPE,
p_sequence_number       IN igs_as_su_setatmpt.sequence_number%TYPE,
p_unit_set_cd           IN igs_as_su_setatmpt.unit_set_cd%TYPE DEFAULT NULL,
p_us_version_number     IN igs_as_su_setatmpt.us_version_number%TYPE DEFAULT NULL,
p_message_name          OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;


FUNCTION check_dup_susa (
p_person_id                     IN igs_as_su_setatmpt.person_id%TYPE,
p_program_cd            IN igs_as_su_setatmpt.course_cd%TYPE,
p_unit_set_cd           IN igs_as_su_setatmpt.unit_set_cd%TYPE,
p_us_version_number     IN igs_as_su_setatmpt.us_version_number%TYPE,
p_selection_dt          IN igs_as_su_setatmpt.selection_dt%TYPE)
RETURN BOOLEAN;

FUNCTION validate_intm_ua_ovrlp (
  p_person_id           IN      igs_en_stdnt_ps_intm.person_id%TYPE,
  p_program_cd          IN      igs_en_stdnt_ps_intm.course_cd%TYPE,
  p_start_dt            IN      igs_en_stdnt_ps_intm.start_dt%TYPE,
  p_end_dt              IN      igs_en_stdnt_ps_intm.end_dt%TYPE
) RETURN BOOLEAN;


FUNCTION check_approv_reqd (
   p_intermission_type     IN   igs_en_stdnt_ps_intm.intermission_type%TYPE
) RETURN BOOLEAN;


FUNCTION check_study_antr_instu (
   p_intermission_type     IN   igs_en_stdnt_ps_intm.intermission_type%TYPE
) RETURN BOOLEAN;


FUNCTION check_institution (
   p_institution_name      IN    igs_en_stdnt_ps_intm.institution_name%TYPE
) RETURN BOOLEAN;


FUNCTION check_sca_status_upd (
  p_person_id              IN     igs_en_stdnt_ps_intm.person_id%TYPE,
  p_program_cd             IN     igs_en_stdnt_ps_intm.course_cd%TYPE,
  p_called_from            IN     VARCHAR2,
  p_course_attempt_status  OUT    NOCOPY igs_en_stdnt_ps_att.course_attempt_status%TYPE
) RETURN BOOLEAN;

FUNCTION validate_awd_offer_pgm(
  p_person_id  IN NUMBER,
  p_program_cd IN VARCHAR2,
  p_award_cd   IN VARCHAR2
) RETURN BOOLEAN;


END igs_en_gen_legacy;

 

/
