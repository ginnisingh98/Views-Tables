--------------------------------------------------------
--  DDL for Package IGS_EN_PLAN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_PLAN_UTILS" AUTHID CURRENT_USER AS
/* $Header: IGSEN94S.pls 120.3 2006/08/24 07:29:33 bdeviset noship $ */


PROCEDURE add_units_to_plan(P_PERSON_ID IN NUMBER,
                P_COURSE_CD IN VARCHAR2,
                P_LOAD_CAL_TYPE IN VARCHAR2,
                P_LOAD_SEQUENCE_NUMBER IN NUMBER,
                P_UOO_IDS IN VARCHAR2,
                P_RETURN_STATUS OUT NOCOPY VARCHAR2,
                P_MESSAGE_NAME OUT NOCOPY VARCHAR2,
                p_ss_session_id IN NUMBER);

PROCEDURE update_spa_terms_plan_sht_flag(
            P_PERSON_ID IN NUMBER,
            P_COURSE_CD IN VARCHAR2,
            P_TERM_CAL_TYPE IN VARCHAR2,
            P_TERM_SEQUENCE_NUMBER IN NUMBER,
            P_PLAN_SHT_FLAG IN VARCHAR2
            );
PROCEDURE update_plansheet_unitdetails(
           P_PERSON_ID IN NUMBER,
           P_COURSE_CD IN VARCHAR2,
           P_UOOID IN NUMBER,
           P_CARTFLAG IN VARCHAR2,
           P_SOURCEFLAG IN VARCHAR2,
           P_FIELDNAME IN VARCHAR2,
           P_auditVAL  IN VARCHAR2,
           P_creditVAL  IN NUMBER,
           P_gradingVAL  IN VARCHAR2
           );

PROCEDURE delete_plansheet_unit(
           P_PERSON_ID IN NUMBER,
           P_COURSE_CD IN VARCHAR2,
           P_UOOID IN NUMBER,
           P_CARTFLAG IN VARCHAR2,
           p_return_status OUT NOCOPY VARCHAR2,
           p_message_name OUT NOCOPY VARCHAR2
           );

 PROCEDURE delete_sua_from_plan(
           p_person_id IN NUMBER,
           p_course_cd IN VARCHAR2,
           p_uoo_id IN NUMBER,
           p_tch_cal IN VARCHAR2,
           p_tch_seq IN NUMBER,
           p_term_cal IN VARCHAR2,
           p_term_seq_num IN NUMBER,
           p_core  IN VARCHAR2,
           p_return_status OUT NOCOPY VARCHAR2,
           p_message_name OUT NOCOPY VARCHAR2
           );

PROCEDURE  is_core_replaced(p_n_person_id    IN NUMBER,
                            p_c_program_code IN VARCHAR2,
                            p_n_program_ver  IN NUMBER,
                            p_c_load_cal     IN VARCHAR2,
                            p_n_load_seq_num IN NUMBER,
                            p_c_core_uoo_ids IN VARCHAR2,
                            p_ss_session_id  IN NUMBER);

PROCEDURE swap_delete ( p_person_id          IN  NUMBER,
                        p_course_cd          IN  VARCHAR2,
                        p_course_version     IN  NUMBER,
                        p_usec_dtls          IN  VARCHAR2,
                        p_uoo_id             IN  NUMBER,
                        p_term_cal           IN  VARCHAR2,
                        p_term_seq_num       IN  NUMBER,
                        p_core               IN  VARCHAR2,
                        p_rel_type           IN  VARCHAR2,
                        p_ret_status         OUT  NOCOPY VARCHAR2,
                        p_msg                OUT  NOCOPY VARCHAR2);

Procedure swap_submit (person_id IN NUMBER,
                       program_cd IN VARCHAR2,
                       p_uoo_ids IN VARCHAR2);
PROCEDURE swap_drop (
              p_uoo_ids IN VARCHAR2,
              p_person_id IN NUMBER,
              p_person_type IN VARCHAR2,
              p_load_cal_type IN VARCHAR2,
              p_load_sequence_number IN NUMBER,
              p_program_cd IN VARCHAR2,
              p_program_version IN NUMBER ,
              p_message OUT NOCOPY VARCHAR2,
              p_ret_status OUT NOCOPY VARCHAR2,
              p_ss_session_id IN NUMBER);

PROCEDURE release_swap_cart(p_n_person_id IN NUMBER,
                            p_c_program_code IN VARCHAR2,
                            p_c_load_cal IN VARCHAR2,
                            p_n_load_seq_num IN NUMBER);



FUNCTION is_credit_updatable( p_person_id          IN   NUMBER,
                              p_course_cd          IN NUMBER,
                              p_uoo_id             IN   NUMBER,
                              p_cal_type           IN   VARCHAR2,
                              p_ci_sequence_number IN   NUMBER
                         ) RETURN CHAR ;

PROCEDURE swap_update(
              p_person_id                     IN NUMBER,
              p_course_cd                     IN VARCHAR2,
              p_uooid                         IN NUMBER,
              p_fieldname                     IN VARCHAR2,
              p_auditval                      IN VARCHAR2,
              p_creditval                     IN NUMBER,
              p_gradingval                    IN VARCHAR2,
              X_ROWID                         IN VARCHAR2,
              X_UNIT_CD                       IN VARCHAR2,
              X_CAL_TYPE                      IN VARCHAR2,
              X_CI_SEQUENCE_NUMBER            IN NUMBER,
              X_VERSION_NUMBER                IN NUMBER,
              X_LOCATION_CD                   IN VARCHAR2,
              X_UNIT_CLASS                    IN VARCHAR2,
              X_CI_START_DT                   IN DATE,
              X_CI_END_DT                     IN DATE,
              X_ENROLLED_DT                   IN DATE,
              X_UNIT_ATTEMPT_STATUS           IN VARCHAR2,
              X_ADMINISTRATIVE_UNIT_STATUS    IN VARCHAR2,
              X_DISCONTINUED_DT               IN DATE,
              X_RULE_WAIVED_DT                IN DATE,
              X_RULE_WAIVED_PERSON_ID         IN NUMBER,
              X_NO_ASSESSMENT_IND             IN VARCHAR2,
              X_SUP_UNIT_CD                   IN VARCHAR2,
              X_SUP_VERSION_NUMBER            IN NUMBER,
              X_EXAM_LOCATION_CD              IN VARCHAR2,
              X_ALTERNATIVE_TITLE             IN VARCHAR2,
              X_OVERRIDE_ENROLLED_CP          IN NUMBER,
              X_OVERRIDE_EFTSU                IN NUMBER,
              X_OVERRIDE_ACHIEVABLE_CP        IN NUMBER,
              X_OVERRIDE_OUTCOME_DUE_DT       IN DATE,
              X_OVERRIDE_CREDIT_REASON        IN VARCHAR2,
              X_ADMINISTRATIVE_PRIORITY       IN NUMBER,
              X_WAITLIST_DT                   IN DATE,
              X_DCNT_REASON_CD                IN VARCHAR2,
              X_GS_VERSION_NUMBER             IN NUMBER,
              X_ENR_METHOD_TYPE               IN VARCHAR2,
              X_FAILED_UNIT_RULE              IN VARCHAR2,
              X_CART                          IN VARCHAR2,
              X_RSV_SEAT_EXT_ID               IN NUMBER,
              X_ORG_UNIT_CD                   IN VARCHAR2,
              X_GRADING_SCHEMA_CODE           IN VARCHAR2,
              X_subtitle                      IN VARCHAR2,
              x_session_id                    IN NUMBER,
              X_deg_aud_detail_id             IN NUMBER,
              x_student_career_transcript     IN VARCHAR2,
              x_student_career_statistics     IN VARCHAR2,
              x_waitlist_manual_ind           IN VARCHAR2,
              X_ATTRIBUTE_CATEGORY            IN VARCHAR2,
              X_ATTRIBUTE1                    IN VARCHAR2,
              X_ATTRIBUTE2                    IN VARCHAR2,
              X_ATTRIBUTE3                    IN VARCHAR2,
              X_ATTRIBUTE4                    IN VARCHAR2,
              X_ATTRIBUTE5                    IN VARCHAR2,
              X_ATTRIBUTE6                    IN VARCHAR2,
              X_ATTRIBUTE7                    IN VARCHAR2,
              X_ATTRIBUTE8                    IN VARCHAR2,
              X_ATTRIBUTE9                    IN VARCHAR2,
              X_ATTRIBUTE10                   IN VARCHAR2,
              X_ATTRIBUTE11                   IN VARCHAR2,
              X_ATTRIBUTE12                   IN VARCHAR2,
              X_ATTRIBUTE13                   IN VARCHAR2,
              X_ATTRIBUTE14                   IN VARCHAR2,
              X_ATTRIBUTE15                   IN VARCHAR2,
              X_ATTRIBUTE16                   IN VARCHAR2,
              X_ATTRIBUTE17                   IN VARCHAR2,
              X_ATTRIBUTE18                   IN VARCHAR2,
              X_ATTRIBUTE19                   IN VARCHAR2,
              x_ATTRIBUTE20                   IN VARCHAR2,
              X_WLST_PRIORITY_WEIGHT_NUM      IN NUMBER,
              X_WLST_PREFERENCE_WEIGHT_NUM    IN NUMBER,
              X_CORE_INDICATOR_CODE           IN VARCHAR2,
              X_UPD_AUDIT_FLAG                IN VARCHAR2,
              X_SS_SOURCE_IND                 IN VARCHAR2);

PROCEDURE plan_update(
              p_person_id                     IN NUMBER,
              p_course_cd                     IN VARCHAR2,
              p_uoo_id                         IN NUMBER,
              p_fieldname                     IN VARCHAR2,
              p_auditval                      IN VARCHAR2,
              p_creditval                     IN NUMBER,
              p_gradingval                    IN VARCHAR2,
              p_row_id                        IN VARCHAR2,
              p_term_cal_type                 IN VARCHAR2,
              p_term_ci_sequence_number       IN NUMBER,
              p_no_assessment_ind             IN VARCHAR2,
              p_sup_uoo_id                    IN NUMBER,
              p_override_enrolled_cp          IN NUMBER,
              p_grading_schema_code           IN VARCHAR2,
              p_gs_version_number             IN NUMBER,
              p_core_indicator_code           IN VARCHAR2,
              p_alternative_title             IN VARCHAR2,
              p_cart_error_flag               IN VARCHAR2,
              p_session_id                    IN NUMBER
              );


PROCEDURE drop_submit (person_id IN NUMBER,
                       program_cd IN VARCHAR2,
                       p_uoo_ids IN VARCHAR2) ;

    FUNCTION get_sua_fin_mark(p_person_id IN  igs_en_su_attempt_all.person_id%TYPE,
                              p_course_cd IN igs_en_su_attempt_all.course_Cd%TYPE,
                              p_uoo_id IN igs_en_su_attempt_all.uoo_id%TYPE) RETURN NUMBER ;

     FUNCTION get_sua_fin_grade(p_person_id IN   igs_en_su_attempt_all.person_id%TYPE,
                               p_course_cd IN igs_en_su_attempt_all.course_Cd%TYPE,
                               p_uoo_id IN igs_en_su_attempt_all.uoo_id%TYPE) RETURN VARCHAR2;

END IGS_EN_PLAN_UTILS;

 

/
