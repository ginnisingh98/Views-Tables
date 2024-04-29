--------------------------------------------------------
--  DDL for Package IGS_EN_ENROLL_WLST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ENROLL_WLST" AUTHID CURRENT_USER AS
/* $Header: IGSEN73S.pls 120.3 2005/09/26 05:08:47 appldev ship $ */


/** Unit - For the Existing Unit  validations    **/

FUNCTION  validate_unit  (
p_unit_cd             IN igs_ps_unit_ofr_opt.unit_cd%TYPE,
p_version_number      IN igs_ps_unit_ofr_opt.version_number%TYPE,
p_cal_type            IN igs_ps_unit_ofr_opt.cal_type%TYPE,
p_ci_sequence_number  IN igs_ps_unit_ofr_opt.ci_sequence_number%TYPE,
p_location_cd         IN igs_ps_unit_ofr_opt.location_cd%TYPE,
p_person_id           IN IGS_EN_SU_ATTEMPT.person_id%TYPE,
p_unit_class          IN igs_ps_unit_ofr_opt.unit_class%TYPE,
p_uoo_id              IN igs_ps_unit_ofr_opt.uoo_id%TYPE,
p_message_name        OUT NOCOPY fnd_new_messages.message_name%TYPE,
p_deny_warn           OUT NOCOPY VARCHAR2,
p_course_cd           IN IGS_EN_SU_ATTEMPT.course_cd%TYPE)

RETURN BOOLEAN;


/** Program - For the validations  Programs  **/
FUNCTION validate_prog    (
p_person_id          igs_en_su_attempt.person_id%TYPE,
p_cal_type           igs_ca_inst.cal_type%TYPE,
p_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
p_uoo_id             igs_ps_unit_ofr_opt.uoo_id%TYPE,
p_course_cd          igs_en_su_attempt.course_cd%TYPE,
p_enr_method_type    igs_en_su_attempt.enr_method_type%TYPE,
p_message_name       OUT NOCOPY VARCHAR2,
p_deny_warn          OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/** Unit Steps - For the validations  Unit Steps  **/
FUNCTION validate_unit_steps(
p_person_id              igs_en_su_attempt.person_id%TYPE,
p_cal_type               igs_ca_inst.cal_type%TYPE,
p_ci_sequence_number     igs_ca_inst.sequence_number%TYPE,
p_uoo_id                 igs_ps_unit_ofr_opt.uoo_id%TYPE,
p_course_cd              igs_en_su_attempt.course_cd%TYPE,
p_enr_method_type        igs_en_su_attempt.enr_method_type%TYPE,
p_message_name           OUT NOCOPY VARCHAR2,
p_deny_warn              OUT NOCOPY VARCHAR2,
p_calling_obj            IN VARCHAR2)
RETURN BOOLEAN;

/** For Combined validations for  Unit Steps and Units - Not used in this package  for external use**/
FUNCTION validate_combined_unit(
p_person_id             IGS_EN_SU_ATTEMPT.person_id%TYPE,
p_unit_cd               igs_ps_unit_ofr_opt.unit_cd%TYPE,
p_version_number        igs_ps_unit_ofr_opt.version_number%TYPE,
p_cal_type              igs_ca_inst.cal_type%TYPE,
p_ci_sequence_number    igs_ca_inst.sequence_number%TYPE,
p_location_cd           igs_ps_unit_ofr_opt.location_cd%TYPE,
p_unit_class            igs_ps_unit_ofr_opt.unit_class%TYPE,
p_uoo_id                igs_ps_unit_ofr_opt.uoo_id%TYPE,
p_course_cd             igs_en_su_attempt.course_cd%TYPE,
p_enr_method_type       igs_en_su_attempt.enr_method_type%TYPE,
p_message_name          OUT NOCOPY VARCHAR2,
p_deny_warn             OUT NOCOPY VARCHAR2,
p_calling_obj           IN VARCHAR2)
RETURN BOOLEAN;


/** Finalize Unit - For All the validations  - Unit , Unit Steps , Program **/
FUNCTION finalize_unit (
p_person_id           igs_en_su_attempt.person_id%TYPE,
p_uoo_id              igs_ps_unit_ofr_opt.uoo_id%TYPE,
p_called_from_wlst    VARCHAR2,
p_unit_cd             igs_ps_unit_ofr_opt.unit_cd%TYPE,
p_version_number      igs_ps_unit_ofr_opt.version_number%TYPE,
p_cal_type            igs_ca_inst.cal_type%TYPE,
p_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
p_location_cd         igs_ps_unit_ofr_opt.location_cd%TYPE,
p_unit_class          igs_ps_unit_ofr_opt.unit_class%TYPE,
p_enr_method_type     igs_en_su_attempt.enr_method_type%TYPE,
p_course_cd           igs_en_su_attempt.course_cd%TYPE,
p_rsv_seat_ext_id     igs_en_su_attempt.rsv_seat_ext_id%TYPE,
p_message_name        OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/**************************Declaration of globally used  PL-SQL Tables *****/

  TYPE rec_succ_mail
  IS
    RECORD (person_id igs_en_su_attempt.person_id%TYPE,
            course_cd igs_en_su_attempt.course_cd%TYPE);

  TYPE tab_succ_mail
  IS
    TABLE OF rec_succ_mail
    INDEX BY BINARY_INTEGER;



  TYPE rec_fail_mail
  IS
    RECORD (person_id           igs_en_su_attempt.person_id%TYPE,
            course_cd           igs_en_su_attempt.course_cd%TYPE,
            message_name        fnd_new_messages.message_name%TYPE);

  TYPE tab_fail_mail
  IS
    TABLE OF rec_fail_mail
    INDEX BY BINARY_INTEGER;


/**************************Declaration of globally used  PL-SQL Tables *****/

/** The main auto enroll procedure - Called from conc now Also to be called from the TBH of IGSPI085B.pls **/

PROCEDURE enroll_from_waitlist (errbuf          OUT NOCOPY VARCHAR2,
                                retcode         OUT NOCOPY  NUMBER,
                                p_uoo_id        igs_ps_unit_ofr_opt.uoo_id%TYPE,
                                p_org_id        IN NUMBER
                                );

FUNCTION  get_message  (p_messages VARCHAR2,
                       p_message_index NUMBER)
RETURN VARCHAR2;

FUNCTION get_message_count(p_messages IN VARCHAR2)
RETURN NUMBER;

PROCEDURE ss_eval_min_or_max_cp(
p_person_id                   IN igs_en_su_attempt.person_id%TYPE,
p_load_cal_type               IN igs_ca_inst.cal_type%TYPE,
p_load_ci_sequence_number     IN igs_ca_inst.sequence_number%TYPE,
p_uoo_id                      IN igs_ps_unit_ofr_opt.uoo_id%TYPE,
p_program_cd                  IN igs_en_su_attempt.course_cd%TYPE,
p_step_type                   IN igs_en_cpd_ext.s_enrolment_step_type%TYPE,
p_credit_points               IN NUMBER,
p_message_name                OUT NOCOPY VARCHAR2,
p_deny_warn                   OUT NOCOPY VARCHAR2,
p_return_status               OUT NOCOPY VARCHAR2,
p_enr_method                  IN  igs_en_cat_prc_dtl.enr_method_type%TYPE DEFAULT NULL);

END Igs_En_Enroll_Wlst; -- end of package

 

/
