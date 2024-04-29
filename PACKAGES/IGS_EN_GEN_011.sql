--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_011
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_011" AUTHID CURRENT_USER AS
/* $Header: IGSEN11S.pls 120.0 2005/06/01 17:35:41 appldev noship $ */

------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created:
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pradhakr    12/07/2001     Added one parameter p_dcnt_reason_cd in
  --			       the procedure Enrp_prc_sua_enr_ds  as part
  --  			       of Enrollment build (Bug # 1832130 )
  --kkillams    03-10-2002     1)Three New  p_unit_loc_cd, p_unit_class,p_reason
  --                           parameters are added to Enrp_Prc_Sua_Blk_E_D procedure.
  --                           2)Three New p_enforce_val,p_enroll_method,p_reason parameters
  --                           are added to Enrp_Prc_Sua_Blk_Trn procedure.
  --                           w.r.t. build Drop Trasfer workflow notification(Bug no: 2599925)
  -- kkillams  14-06-2003      Added three new parameters p_enr_method,p_load_cal_type
  --                           and p_load_cal_seq to the Enrp_Prc_Sua_Blk_E_D procedure w.r.t bug 2829270.
  -- vkarthik                  1. Added a function match_term_sca_params as a part of bug 2829263
  --                           2. Added two parameters p_term_cal_type and p_term_sequence_number
  --                              in procedure enrp_prc_sca_blk_trn
  -- stutta    03-Nov_2004     Added parameter p_course_attempt_status6 to proc Enrp_Prc_Sca_Blk_Trn.
  -------------------------------------------------------------------

Procedure Enrp_Prc_Sca_Blk_Trn(
  p_acad_cal_type           IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_course_cd               IN VARCHAR2 ,
  p_version_number          IN NUMBER ,
  p_location_cd             IN VARCHAR2 ,
  p_attendance_type         IN VARCHAR2 ,
  p_attendance_mode         IN VARCHAR2 ,
  p_group_id                IN NUMBER ,
  p_course_attempt_status1  IN VARCHAR2 ,
  p_course_attempt_status2  IN VARCHAR2 ,
  p_course_attempt_status3  IN VARCHAR2 ,
  p_course_attempt_status4  IN VARCHAR2 ,
  p_course_attempt_status5  IN VARCHAR2 ,
  p_course_attempt_status6  IN VARCHAR2 DEFAULT NULL,
  p_to_acad_cal_type        IN VARCHAR2 ,
  p_to_crs_version_number   IN NUMBER ,
  p_to_location_cd          IN VARCHAR2 ,
  p_to_attendance_type      IN VARCHAR2 ,
  p_to_attendance_mode      IN VARCHAR2 ,
  p_term_cal_type           IN VARCHAR2,
  p_term_sequence_number    IN NUMBER,
  p_creation_dt             IN OUT NOCOPY DATE );

Procedure Enrp_Prc_Sua_Blk_E_D(
  p_teach_cal_type             IN VARCHAR2 ,
  p_teach_ci_sequence_number   IN NUMBER ,
  p_course_cd                  IN VARCHAR2 ,
  p_location_cd                IN VARCHAR2 ,
  p_attendance_type            IN VARCHAR2 ,
  p_attendance_mode            IN VARCHAR2 ,
  p_unit_cd                    IN VARCHAR2 ,
  p_uv_version_number          IN NUMBER ,
  p_group_id                   IN NUMBER ,
  p_person_id                  IN NUMBER ,
  p_action1                    IN VARCHAR2 ,
  p_unit_cd1                   IN VARCHAR2 ,
  p_uv_version_number1         IN NUMBER ,
  p_location_cd1               IN VARCHAR2 ,
  p_unit_class1                IN VARCHAR2 ,
  p_action2                    IN VARCHAR2 ,
  p_unit_cd2                   IN VARCHAR2 ,
  p_uv_version_number2         IN NUMBER ,
  p_location_cd2               IN VARCHAR2 ,
  p_unit_class2                IN VARCHAR2 ,
  p_action3                    IN VARCHAR2 ,
  p_unit_cd3                   IN VARCHAR2 ,
  p_uv_version_number3         IN NUMBER ,
  p_location_cd3               IN VARCHAR2 ,
  p_unit_class3                IN VARCHAR2 ,
  p_action4                    IN VARCHAR2 ,
  p_unit_cd4                   IN VARCHAR2 ,
  p_uv_version_number4         IN NUMBER ,
  p_location_cd4               IN VARCHAR2 ,
  p_unit_class4                IN VARCHAR2 ,
  p_action5                    IN VARCHAR2 ,
  p_unit_cd5                   IN VARCHAR2 ,
  p_uv_version_number5         IN NUMBER ,
  p_location_cd5               IN VARCHAR2 ,
  p_unit_class5                IN VARCHAR2 ,
  p_action6                    IN VARCHAR2 ,
  p_unit_cd6                   IN VARCHAR2 ,
  p_uv_version_number6         IN NUMBER ,
  p_location_cd6               IN VARCHAR2 ,
  p_unit_class6                IN VARCHAR2 ,
  p_action7                    IN VARCHAR2 ,
  p_unit_cd7                   IN VARCHAR2 ,
  p_uv_version_number7         IN NUMBER ,
  p_location_cd7               IN VARCHAR2 ,
  p_unit_class7                IN VARCHAR2 ,
  p_action8                    IN VARCHAR2 ,
  p_unit_cd8                   IN VARCHAR2 ,
  p_uv_version_number8         IN NUMBER ,
  p_location_cd8               IN VARCHAR2 ,
  p_unit_class8                IN VARCHAR2 ,
  p_confirmed_ind              IN VARCHAR2 DEFAULT 'N',
  p_enrolled_dt                IN DATE ,
  p_no_assessment_ind          IN VARCHAR2 DEFAULT 'N',
  p_exam_location_cd           IN VARCHAR2 ,
  p_alternative_title          IN VARCHAR2 ,
  p_override_enrolled_cp       IN NUMBER ,
  p_override_achievable_cp     IN NUMBER DEFAULT 6,
  p_override_eftsu             IN NUMBER DEFAULT 7,
  p_override_credit_reason     IN VARCHAR2 ,
  p_administrative_unit_status IN VARCHAR2 ,
  p_discontinued_dt            IN DATE ,
  p_creation_dt                IN OUT NOCOPY DATE,
  p_dcnt_reason_cd             IN VARCHAR2 DEFAULT NULL,
  p_unit_loc_cd                IN VARCHAR2 DEFAULT NULL,
  p_unit_class                 IN VARCHAR2 DEFAULT NULL,
  p_reason                     IN VARCHAR2 DEFAULT NULL,
  p_enr_method                 IN VARCHAR2,
  p_load_cal_type              IN VARCHAR2,
  p_load_cal_seq               IN NUMBER);

Procedure Enrp_Prc_Sua_Blk_Trn(
  p_teach_cal_type           IN VARCHAR2 ,
  p_teach_ci_sequence_number IN NUMBER ,
  p_course_cd                IN VARCHAR2 ,
  p_location_cd              IN VARCHAR2 ,
  p_attendance_type          IN VARCHAR2 ,
  p_attendance_mode          IN VARCHAR2 ,
  p_group_id                 IN NUMBER ,
  p_from_unit_cd             IN VARCHAR2 ,
  p_from_uv_version_number   IN NUMBER ,
  p_from_location_cd         IN VARCHAR2 ,
  p_from_unit_class          IN VARCHAR2 ,
  p_unit_attempt_status1     IN VARCHAR2 ,
  p_unit_attempt_status2     IN VARCHAR2 ,
  p_unit_attempt_status3     IN VARCHAR2 ,
  p_to_uv_version_number     IN NUMBER ,
  p_to_location_cd           IN VARCHAR2 ,
  p_to_unit_class            IN VARCHAR2 ,
  p_creation_dt              IN OUT NOCOPY DATE,
  p_enforce_val              IN VARCHAR2 DEFAULT NULL,
  p_enroll_method            IN VARCHAR2 DEFAULT NULL,
  p_reason                   IN VARCHAR2 DEFAULT NULL);

Procedure Enrp_Set_Pee_Expry(
  p_person_id        IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt     IN DATE ,
  p_effect_type      IN VARCHAR2 ,
  p_pee_start_dt     IN DATE ,
  p_sequence_number  IN NUMBER ,
  p_expiry_dt        IN DATE ,
  p_message_name     OUT NOCOPY VARCHAR2 );

Procedure Enrp_Set_Pen_Expry(
  p_person_id        IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt     IN DATE ,
  p_sequence_number  IN NUMBER ,
  p_expiry_dt        IN DATE ,
  p_message_name     OUT NOCOPY VARCHAR2 );

Function Enrp_Upd_Acai_Accept(
  p_person_id                 IN NUMBER ,
  p_course_cd                 IN VARCHAR2 ,
  p_adm_admission_appl_number IN NUMBER ,
  p_adm_nominated_course_cd   IN VARCHAR2 ,
  p_adm_sequence_number       IN NUMBER ,
  p_message_name              OUT NOCOPY VARCHAR2 )
RETURN boolean;

Procedure Enrp_Upd_Enr_Pp(
  p_username        IN VARCHAR2 ,
  p_cal_type        IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_enrolment_cat   IN VARCHAR2 ,
  p_enr_method_type IN VARCHAR2 );

FUNCTION match_term_sca_params (
  p_sca_person_id         IN      NUMBER,
  p_sca_course_cd         IN      VARCHAR2,
  p_sca_version_number    IN      NUMBER,
  p_sca_attendance_type   IN      VARCHAR2,
  p_sca_attendance_mode   IN      VARCHAR2,
  p_sca_location_cd       IN      VARCHAR2,
  p_para_course_cd        IN      VARCHAR2,
  p_para_version_number   IN      NUMBER,
  p_para_attendance_type  IN      VARCHAR2,
  p_para_attendance_mode  IN      VARCHAR2,
  p_para_location_cd      IN      VARCHAR2,
  p_term_cal_type         IN      VARCHAR2,
  p_term_sequence_number  IN      NUMBER) RETURN VARCHAR2;
END IGS_EN_GEN_011;

 

/
