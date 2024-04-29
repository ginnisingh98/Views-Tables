--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_017
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_017" AUTHID CURRENT_USER AS
/* $Header: IGSEN96S.pls 115.4 2003/02/03 11:12:03 smanglm noship $ */

  -- gloabl package variable to store the source of invocation
  G_INVOKE_SOURCE  VARCHAR2(10):='SS';

  PROCEDURE add_to_cart_waitlist (
    p_person_number IN  VARCHAR2,
    p_career        IN  VARCHAR2,
    p_program_code  IN  VARCHAR2,
    p_term_alt_code IN  VARCHAR2,
    p_call_number   IN  NUMBER,
    p_audit_ind     IN  VARCHAR2,
    p_waitlist_ind  IN OUT NOCOPY VARCHAR2,
    p_action        IN  VARCHAR2,
    p_error_message OUT NOCOPY VARCHAR2,
    p_ret_status    OUT NOCOPY VARCHAR2);

  PROCEDURE drop_section(
    p_person_number IN         VARCHAR2,
    p_career        IN         VARCHAR2,
    p_program_code  IN         VARCHAR2,
    p_term_alt_code IN         VARCHAR2,
    p_call_number   IN         NUMBER  ,
    p_action        IN         VARCHAR2,
    p_drop_reason   IN         VARCHAR2,
    p_adm_status    IN         VARCHAR2,
    p_error_message OUT NOCOPY VARCHAR2,
    p_return_stat   OUT NOCOPY VARCHAR2);

  PROCEDURE enrp_get_default_term(
    p_term_alt_code OUT NOCOPY VARCHAR2,
    p_error_message OUT NOCOPY VARCHAR2,
    p_ret_status    OUT NOCOPY VARCHAR2 );

  PROCEDURE enrp_get_enr_method(
    p_enr_method_type OUT NOCOPY VARCHAR2,
    P_error_message   OUT NOCOPY VARCHAR2,
    p_ret_status      OUT NOCOPY VARCHAR2);

  PROCEDURE enrp_get_term_ivr_list(
    p_term_tbl        OUT NOCOPY igs_en_ivr_pub.term_tbl_type,
    p_error_message   OUT NOCOPY VARCHAR2     ,
    p_ret_status      OUT NOCOPY VARCHAR2 );

  FUNCTION enrp_get_invoke_source RETURN VARCHAR2;

  PROCEDURE enrp_msg_string_to_list(
    p_message_string       IN  VARCHAR2,
    p_delimiter            IN  VARCHAR2 DEFAULT ';',
    p_init_msg_list        IN  VARCHAR2,
    x_message_count        OUT NOCOPY NUMBER,
    x_message_data         OUT NOCOPY VARCHAR2);

  PROCEDURE enrp_validate_call_number(
    p_term_alt_code      IN VARCHAR2,
    p_call_number        IN NUMBER  ,
    p_uoo_id             OUT NOCOPY NUMBER  ,
    p_cal_type           OUT NOCOPY VARCHAR2,
    p_ci_sequence_number OUT NOCOPY NUMBER  ,
    p_error_message      OUT NOCOPY VARCHAR2,
    p_ret_status         OUT NOCOPY VARCHAR2);

  PROCEDURE enrp_validate_input_parameters(
    p_person_number       IN  VARCHAR2,
    p_career              IN  VARCHAR2,
    p_program_code        IN  VARCHAR2,
    p_term_alt_code       IN  VARCHAR2,
    p_call_number         IN  NUMBER,
    p_validation_level    IN  VARCHAR2,
    p_person_id           OUT NOCOPY NUMBER,
    p_person_type         OUT NOCOPY VARCHAR2,
    p_cal_type            OUT NOCOPY VARCHAR2,
    p_ci_sequence_number  OUT NOCOPY NUMBER,
    p_primary_code        OUT NOCOPY VARCHAR2,
    p_primary_version     OUT NOCOPY NUMBER,
    p_uoo_id              OUT NOCOPY NUMBER,
    p_error_message       OUT NOCOPY VARCHAR2,
    p_ret_status          OUT NOCOPY VARCHAR2);

  PROCEDURE enrp_validate_student(
    p_person_number IN VARCHAR2,
    p_person_id     OUT NOCOPY NUMBER,
    p_person_type   OUT NOCOPY VARCHAR2,
    p_error_message OUT NOCOPY VARCHAR2,
    p_ret_status    OUT NOCOPY VARCHAR2);

  PROCEDURE enrp_validate_term_alt_code(
    p_term_alt_code      IN VARCHAR2,
    p_cal_type           OUT NOCOPY VARCHAR2,
    p_ci_sequence_number OUT NOCOPY NUMBER  ,
    p_error_message      OUT NOCOPY VARCHAR2,
    p_ret_status         OUT NOCOPY VARCHAR2);

END igs_en_gen_017;

 

/
