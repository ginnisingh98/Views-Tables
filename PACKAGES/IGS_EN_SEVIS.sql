--------------------------------------------------------
--  DDL for Package IGS_EN_SEVIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SEVIS" AUTHID CURRENT_USER AS
/* $Header: IGSEN97S.pls 120.1 2006/05/02 01:46:19 amuthu noship $ */

FUNCTION enrf_chk_sevis_auth_req (
        p_person_id    NUMBER,
        p_cal_type VARCHAR2,
        p_ci_sequence_number NUMBER,
        p_elgb_step VARCHAR2)
RETURN BOOLEAN ;

PROCEDURE stud_ret_to_ft_load (
        p_begin_cal_inst  IN  VARCHAR2,
        p_return_cal_inst IN  VARCHAR2,
        p_log_creation_dt OUT NOCOPY DATE );

FUNCTION enrf_get_sevis_auth_details(
        p_person_id       IN  NUMBER,
        p_auth_code       OUT NOCOPY VARCHAR2,
        p_auth_start_dt   OUT NOCOPY DATE,
        p_auth_end_dt     OUT NOCOPY DATE,
        p_comments        OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

FUNCTION enrf_get_ret_ft_note_details(
        p_person_id     IN  NUMBER,
        p_note_text     OUT NOCOPY VARCHAR2,
        p_note_start_dt OUT NOCOPY DATE,
        p_note_end_dt   OUT NOCOPY DATE,
        p_note_type     OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

FUNCTION get_visa_type(p_person_id    IN NUMBER,
                       p_no_of_months OUT NOCOPY NUMBER ) RETURN VARCHAR2;

FUNCTION is_auth_rec_duration_exceeds(
                                     p_person_id     IN NUMBER,
                                      p_start_date   IN  DATE,
                                      p_end_date     IN  DATE,
                                      p_no_of_months OUT NOCOPY NUMBER)  RETURN BOOLEAN;

PROCEDURE create_auth_cal_row (
      p_sevis_authorization_code          IN VARCHAR2,
      p_start_dt                          IN DATE,
      p_end_dt                            IN DATE,
      p_comments                          IN VARCHAR2,
      p_sevis_auth_id                     IN OUT NOCOPY NUMBER,
      p_sevis_authorization_no            IN OUT NOCOPY NUMBER,
      p_person_id                         IN NUMBER,
      p_cal_type                          IN VARCHAR2,
      p_ci_sequence_number                IN NUMBER,
      p_cancel_flag                       IN VARCHAR2);

PROCEDURE enrp_sevis_auth_dflt_dt(p_person_id          IN NUMBER,
                                  p_cal_type           IN VARCHAR2,
                                  p_ci_sequence_number IN NUMBER,
                                  p_dflt_auth_start_dt OUT NOCOPY DATE,
                                  p_dflt_auth_end_dt   OUT NOCOPY DATE);

FUNCTION is_auth_records_overlap(P_PERSON_ID IN NUMBER) RETURN BOOLEAN ;

END igs_en_sevis;

 

/
