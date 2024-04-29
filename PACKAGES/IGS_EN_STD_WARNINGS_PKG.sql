--------------------------------------------------------
--  DDL for Package IGS_EN_STD_WARNINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_STD_WARNINGS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI58S.pls 120.0 2005/09/13 09:57:52 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_warning_id                        IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_message_for                       IN     VARCHAR2,
    x_message_icon                      IN     VARCHAR2,
    x_message_name                      IN     VARCHAR2,
    x_message_text                      IN     VARCHAR2,
    x_message_action                    IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_p_parameters                      IN     VARCHAR2,
    x_step_type                         IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_warning_id                        IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_message_for                       IN     VARCHAR2,
    x_message_icon                      IN     VARCHAR2,
    x_message_name                      IN     VARCHAR2,
    x_message_text                      IN     VARCHAR2,
    x_message_action                    IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_p_parameters                      IN     VARCHAR2,
    x_step_type                         IN     VARCHAR2,
    x_session_id                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_warning_id                        IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,

    x_message_for                       IN     VARCHAR2,
    x_message_icon                      IN     VARCHAR2,
    x_message_name                      IN     VARCHAR2,
    x_message_text                      IN     VARCHAR2,
    x_message_action                    IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_p_parameters                      IN     VARCHAR2,
    x_step_type                         IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_warning_id                        IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_message_for                       IN     VARCHAR2,
    x_message_icon                      IN     VARCHAR2,
    x_message_name                      IN     VARCHAR2,
    x_message_text                      IN     VARCHAR2,
    x_message_action                    IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_p_parameters                      IN     VARCHAR2,
    x_step_type                         IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_warning_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_warning_id                        IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_term_cal_type                     IN     VARCHAR2    DEFAULT NULL,
    x_term_ci_sequence_number           IN     NUMBER      DEFAULT NULL,
    x_message_for                       IN     VARCHAR2    DEFAULT NULL,
    x_message_icon                      IN     VARCHAR2    DEFAULT NULL,
    x_message_name                      IN     VARCHAR2    DEFAULT NULL,
    x_message_text                      IN     VARCHAR2    DEFAULT NULL,
    x_message_action                    IN     VARCHAR2    DEFAULT NULL,
    x_destination                       IN     VARCHAR2    DEFAULT NULL,
    x_p_parameters                      IN     VARCHAR2    DEFAULT NULL,
    x_step_type                         IN     VARCHAR2    DEFAULT NULL,
    x_session_id                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_std_warnings_pkg;

 

/
