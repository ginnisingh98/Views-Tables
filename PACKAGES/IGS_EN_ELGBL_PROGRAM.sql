--------------------------------------------------------
--  DDL for Package IGS_EN_ELGBL_PROGRAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ELGBL_PROGRAM" AUTHID CURRENT_USER AS
/* $Header: IGSEN79S.pls 120.2 2005/07/13 02:45:39 appldev ship $ */

/******************************************************************
Created By        : Vinay Chappidi
Date Created By   : 19-JUN-2001
Purpose           : When the user tries to finalize the units he has selected
                    for enrolment, program level validations have to be carried
                    on before the user is actuall enroled. These function's are
                    meant for calling from the Self-Service applications

Known limitations,
enhancements,
remarks            :
Change History
Who        When            What
ckasu       15-Jul-2005     Modified eval_program_steps,eval_max_cp,eval_min_cp,eval_unit_forced_type,
                            eval_cross_validation,eval_fail_min_cp Functions spec by adding
                            p_calling_obj as a part of EN317 SS UI Build bug#4377985
knaraset   04-Nov-2003  Added functions get_applied_min_cp, get_applied_max_cp as part of TD EN212
svenkata   6-Jun-2003   Added the routine eval_cross_validation to check for Cross element
			Validations - Bug 2829272.
amuthu     27-JAN-2003  Change the data type of two out variables from number
                        to varchar in get_per_min_max
svenkata   23-Jan-2003  Added new routines calc_min_cp, calc_max_cp and get_per_min_max_cp Bug#2728260.
Nishikant  17OCT2002   Enrl Elgbl and Validation Build. Enh Bug#2616692.
                       Four parameters p_enrollment_category, p_comm_type, p_method_type,
                       p_min_credit_point added to the signature of the Function eval_min_cp.
                       Also the parameter p_credit_points made as IN/OUT instead of IN.
                       Three parameters p_enrollment_category, p_comm_type, p_method_type added
                       to the signature of the function eval_unit_forced_type.
                       A new function eval_fail_min_cp has been added.
		       A new Procedure stdnt_crd_pnt_enrl_workflow has been added to raise a
		       bussiness event to send notification to the student that he/she has failed the
		       Minimum CP Validation.
******************************************************************/

FUNCTION eval_max_cp ( p_person_id                            NUMBER,
                       p_load_calendar_type                   VARCHAR2,
                       p_load_cal_sequence_number             NUMBER,
                       p_uoo_id                               NUMBER,
                       p_program_cd                           VARCHAR2,
                       p_program_version                      VARCHAR2,
                       p_message                          OUT NOCOPY VARCHAR2,
                       p_deny_warn                            VARCHAR2,
                       p_upd_cp                           IN  NUMBER DEFAULT NULL,
                       p_calling_obj                      IN VARCHAR2
                     ) RETURN BOOLEAN;
FUNCTION eval_min_cp( p_person_id                            NUMBER,
                       p_load_calendar_type                   VARCHAR2,
                       p_load_cal_sequence_number             NUMBER,
                       p_uoo_id                               NUMBER,
                       p_program_cd                           VARCHAR2,
                       p_program_version                      VARCHAR2,
                       p_message                          OUT NOCOPY VARCHAR2,
                       p_deny_warn                            VARCHAR2,
                       p_credit_points                 IN OUT NOCOPY NUMBER,
                       p_enrollment_category           IN     VARCHAR2 DEFAULT NULL,
                       p_comm_type                     IN     VARCHAR2 DEFAULT NULL,
                       p_method_type                   IN     VARCHAR2 DEFAULT NULL,
                       p_min_credit_point              IN OUT NOCOPY NUMBER,
                       p_calling_obj                      IN VARCHAR2
                     ) RETURN BOOLEAN;
FUNCTION eval_program_steps( p_person_id                      NUMBER,
                       p_person_type                          VARCHAR2,
                       p_load_calendar_type                   VARCHAR2,
                       p_load_cal_sequence_number             NUMBER,
                       p_uoo_id                               NUMBER,
                       p_program_cd                           VARCHAR2,
                       p_program_version                      VARCHAR2,
                       p_enrollment_category                  VARCHAR2,
                       p_comm_type                            VARCHAR2,
                       p_method_type                          VARCHAR2,
                       p_message                          OUT NOCOPY VARCHAR2,
                       p_deny_warn                        OUT NOCOPY VARCHAR2,
                       p_calling_obj                      IN VARCHAR2
                     ) RETURN BOOLEAN;
FUNCTION eval_unit_forced_type( p_person_id                   NUMBER,
                       p_load_calendar_type                   VARCHAR2,
                       p_load_cal_sequence_number             VARCHAR2,
                       p_uoo_id                               NUMBER,
                       p_course_cd                            VARCHAR2,
                       p_course_version                       VARCHAR2,
                       p_message                          OUT NOCOPY VARCHAR2,
                       p_deny_warn                            VARCHAR2,
                       p_enrollment_category           IN     VARCHAR2 DEFAULT NULL,
                       p_comm_type                     IN     VARCHAR2 DEFAULT NULL,
                       p_method_type                   IN     VARCHAR2 DEFAULT NULL,
                       p_calling_obj                      IN VARCHAR2
                     ) RETURN BOOLEAN;
FUNCTION eval_fail_min_cp(
                       p_person_id                            NUMBER,
                       p_course_cd                            VARCHAR2,
                       p_version_number                       NUMBER,
                       p_acad_cal                             VARCHAR2,
                       p_load_cal                             VARCHAR2,
                       p_load_ci_sequence_number              NUMBER,
                       p_method                               VARCHAR2
                     ) RETURN VARCHAR2;
PROCEDURE stdnt_crd_pnt_enrl_workflow(
                            p_user_name             IN VARCHAR2,
                            p_course_cd             IN VARCHAR2,
                            p_version_number        IN NUMBER,
                            p_enrolled_cp           IN NUMBER,
                            p_min_cp                IN NUMBER
			    );

FUNCTION calc_min_cp (
                       p_person_id                             NUMBER,
                       p_load_calendar_type                   VARCHAR2,
                       p_load_cal_sequence_number             NUMBER,
                       p_uoo_id                               NUMBER,
                       p_program_cd                           VARCHAR2,
                       p_program_version                      VARCHAR2,
                       p_message                      OUT NOCOPY VARCHAR2
                    ) RETURN NUMBER ;

FUNCTION calc_max_cp (
                       p_person_id                             NUMBER,
                       p_load_calendar_type                   VARCHAR2,
                       p_load_cal_sequence_number             NUMBER,
                       p_uoo_id                               NUMBER,
                       p_program_cd                           VARCHAR2,
                       p_program_version                      VARCHAR2,
                       p_message                      OUT NOCOPY VARCHAR2
                    ) RETURN NUMBER ;

PROCEDURE get_per_min_max_cp
(
                       p_person_id                            NUMBER,
                       p_load_calendar_type                   VARCHAR2,
                       p_load_cal_sequence_number             NUMBER,
                       p_program_cd                           VARCHAR2,
                       p_program_version                      VARCHAR2,
                       p_min_cp                       OUT     NOCOPY VARCHAR2 ,
                       p_max_cp                       OUT     NOCOPY VARCHAR2 ,
                       p_message                      OUT     NOCOPY VARCHAR2
) ;

FUNCTION eval_cross_validation(
                       p_person_id			IN NUMBER ,
                       p_course_cd			IN VARCHAR2 ,
                       p_program_version		IN VARCHAR2,
                       p_uoo_id				IN NUMBER,
                       p_load_cal_type			IN VARCHAR2 ,
                       p_load_ci_sequence_number	IN NUMBER ,
                       p_deny_warn			IN VARCHAR2,
                       p_upd_cp				IN  NUMBER ,
                       p_eligibility_step_type		IN VARCHAR2 ,
                       p_message			IN OUT NOCOPY VARCHAR2,
                       p_calling_obj                      IN VARCHAR2
		       )   RETURN BOOLEAN ;


FUNCTION get_applied_min_cp (
                       p_person_id            IN NUMBER,
                       p_term_cal_type        IN VARCHAR2,
                       p_term_sequence_number IN NUMBER,
                       p_program_cd           IN VARCHAR2,
                       p_program_version      IN VARCHAR2
                    ) RETURN NUMBER;

FUNCTION get_applied_max_cp (
                       p_person_id            IN NUMBER,
                       p_term_cal_type        IN VARCHAR2,
                       p_term_sequence_number IN NUMBER,
                       p_program_cd           IN VARCHAR2,
                       p_program_version      IN VARCHAR2
                    ) RETURN NUMBER;

END igs_en_elgbl_program ;

 

/
