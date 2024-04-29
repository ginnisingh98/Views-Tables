--------------------------------------------------------
--  DDL for Package IGS_EN_DROP_UNITS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_DROP_UNITS_API" AUTHID CURRENT_USER AS
/* $Header: IGSEN92S.pls 120.1 2006/08/24 07:25:32 bdeviset noship $ */


 PROCEDURE reorder_drop_units (
                                   p_person_id                  IN igs_en_su_attempt.person_id%TYPE,
                                   p_course_cd                  IN igs_en_su_attempt.course_cd%TYPE,
                                   p_start_uoo_id               IN igs_en_su_attempt.uoo_id%TYPE,
                                   p_load_cal_type              IN igs_ca_inst.cal_type%TYPE,
                                   p_load_ci_seq_num            IN igs_ca_inst.sequence_number%TYPE,
                                   p_selected_uoo_ids           IN VARCHAR2,
                                   p_ret_all_uoo_ids            OUT NOCOPY VARCHAR2,
                                   p_ret_sub_uoo_ids            OUT NOCOPY VARCHAR2,
                                   p_ret_nonsub_uoo_ids         OUT NOCOPY VARCHAR2
                               );

 PROCEDURE create_ss_warning  (
                                  p_person_id                   IN igs_en_su_attempt.person_id%TYPE,
                                  p_course_cd                   IN igs_en_su_attempt.course_cd%TYPE,
                                  p_term_cal_type               IN igs_ca_inst.cal_type%TYPE,
                                  p_term_ci_sequence_number     IN igs_ca_inst.sequence_number%TYPE,
                                  p_uoo_id                      IN igs_en_su_attempt.uoo_id%TYPE,
                                  p_message_for                 IN IGS_EN_STD_WARNINGS.message_for%TYPE,
                                  p_message_icon                IN IGS_EN_STD_WARNINGS.message_icon%TYPE,
                                  p_message_name                IN IGS_EN_STD_WARNINGS.message_name%TYPE,
                                  p_message_rule_text           IN VARCHAR2,
                                  p_message_tokens              IN VARCHAR2,
                                  p_message_action              IN VARCHAR2,
                                  p_destination                 IN IGS_EN_STD_WARNINGS.destination%TYPE,
                                  p_parameters                  IN IGS_EN_STD_WARNINGS.p_parameters%TYPE,
                                  p_step_type                   IN IGS_EN_STD_WARNINGS.step_type%TYPE
                              );

 PROCEDURE drop_ss_unit_attempt (
                                  p_person_id                   IN NUMBER,
                                  p_course_cd                   IN VARCHAR2,
                                  p_course_version              IN NUMBER ,
                                  p_uoo_id                      IN NUMBER,
                                  p_load_cal_type               IN VARCHAR2,
                                  p_load_sequence_number        IN NUMBER,
                                  p_dcnt_reason_cd              IN VARCHAR2 ,
                                  p_admin_unit_status           IN VARCHAR2 ,
                                  p_effective_date              IN DATE ,
                                  p_dropped_uooids              OUT NOCOPY VARCHAR2,
                                  p_return_status               OUT NOCOPY VARCHAR2,
                                  p_message                     OUT NOCOPY VARCHAR2,
                                  p_ss_session_id               IN NUMBER
                                );

  FUNCTION update_dropped_units (
                                  p_person_id                   IN igs_en_su_attempt.person_id%TYPE,
                                  p_course_cd                   IN igs_en_su_attempt.course_cd%TYPE,
                                  p_uoo_ids                     IN VARCHAR2,
                                  p_discontinuation_reason_cd   IN VARCHAR2
                                 )
                                  RETURN VARCHAR2;
  FUNCTION update_dropped_units (
                                  p_person_id                   IN igs_en_su_attempt.person_id%TYPE,
                                  p_course_cd                   IN igs_en_su_attempt.course_cd%TYPE,
                                  p_uoo_ids                     IN VARCHAR2,
                                  p_discontinuation_reason_cd   IN VARCHAR2,
                                  p_admin_unit_status           IN VARCHAR2
                                 )
                                  RETURN VARCHAR2;

END igs_en_drop_units_api;

 

/
