--------------------------------------------------------
--  DDL for Package IGS_EN_SPA_TERMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPA_TERMS_API" AUTHID CURRENT_USER AS
/* $Header: IGSENB1S.pls 120.1 2005/09/23 06:36:36 appldev noship $ */

g_spa_term_cal_type        IGS_CA_INST.CAL_TYPE%TYPE;
g_spa_term_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
EN_SPAT_REC_TYPE IGS_EN_SPA_TERMS%ROWTYPE;

PROCEDURE set_spa_term_cal_type(p_spa_term_cal_type IN VARCHAR2);

PROCEDURE set_spa_term_sequence_number(p_spa_term_sequence_number IN NUMBER);

FUNCTION get_spat_att_type (
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_spat_att_type_desc (
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_spat_att_mode(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_spat_att_mode_desc(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2;


FUNCTION get_spat_location(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_spat_location_desc(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_spat_coo_id(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN NUMBER;

FUNCTION get_spat_program_version(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN NUMBER;

FUNCTION get_spat_acad_cal_type(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_spat_key_prog_flag(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_spat_fee_cat(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_spat_class_standing(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN NUMBER;

FUNCTION get_spat_primary_prg(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_curr_term(
p_cal_type IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION get_prev_term(
p_cal_type IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION get_next_term(
p_cal_type IN VARCHAR2
) RETURN VARCHAR2;


PROCEDURE validate_terms(
p_person_id IN NUMBER
);

PROCEDURE check_term_exists(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_program_version IN NUMBER,
p_term_cal_type IN VARCHAR2,
p_term_sequence_number IN NUMBER,
p_insert_rec OUT NOCOPY BOOLEAN,
p_term_record_id OUT NOCOPY NUMBER);

PROCEDURE create_update_term_rec(
p_person_id IN NUMBER ,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER,
p_ripple_frwrd IN boolean,
p_update_rec IN BOOLEAN,
p_message_name OUT NOCOPY VARCHAR2,
p_coo_id IN NUMBER DEFAULT -1,
p_key_program_flag IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
p_fee_cat IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
p_class_standing_id IN NUMBER DEFAULT -1,
p_plan_sht_status IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
p_program_changed IN BOOLEAN DEFAULT FALSE
);

PROCEDURE delete_terms_for_program(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2);

PROCEDURE change_key_program_to(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER,
p_term_rec IN EN_SPAT_REC_TYPE%TYPE);

FUNCTION get_miss_char RETURN VARCHAR2;

PROCEDURE backward_gap_fill
(
p_term_rec IN EN_SPAT_REC_TYPE%TYPE
);

PROCEDURE forward_gap_fill
(
p_term_rec IN EN_SPAT_REC_TYPE%TYPE
);

END igs_en_spa_terms_api;

 

/
