--------------------------------------------------------
--  DDL for Package IGS_UC_APP_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_APP_RESULTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI06S.pls 115.4 2003/06/11 10:28:52 smaddali noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_result_id                     IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_year                              IN     VARCHAR2,
    x_sitting                           IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_subject_id                        IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_result_in_offer                   IN     VARCHAR2,
    x_ebl_result                        IN     VARCHAR2,
    x_ebl_amended_result                IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_result_id                     IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_year                              IN     VARCHAR2,
    x_sitting                           IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_subject_id                        IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_result_in_offer                   IN     VARCHAR2,
    x_ebl_result                        IN     VARCHAR2,
    x_ebl_amended_result                IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_imported                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_app_result_id                     IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_year                              IN     VARCHAR2,
    x_sitting                           IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_subject_id                        IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_result_in_offer                   IN     VARCHAR2,
    x_ebl_result                        IN     VARCHAR2,
    x_ebl_amended_result                IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_result_id                     IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_year                              IN     VARCHAR2,
    x_sitting                           IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_subject_id                        IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_result_in_offer                   IN     VARCHAR2,
    x_ebl_result                        IN     VARCHAR2,
    x_ebl_amended_result                IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_app_result_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_applicants (
    x_app_id                            IN     NUMBER
  );

  PROCEDURE get_fk_igs_uc_com_ebl_subj (
    x_subject_id                        IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_app_result_id                     IN     NUMBER      DEFAULT NULL,
    x_app_id                            IN     NUMBER      DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_enquiry_no                        IN     NUMBER      DEFAULT NULL,
    x_exam_level                        IN     VARCHAR2    DEFAULT NULL,
    x_year                              IN     VARCHAR2    DEFAULT NULL,
    x_sitting                           IN     VARCHAR2    DEFAULT NULL,
    x_award_body                        IN     VARCHAR2    DEFAULT NULL,
    x_subject_id                        IN     NUMBER      DEFAULT NULL,
    x_predicted_result                  IN     VARCHAR2    DEFAULT NULL,
    x_result_in_offer                   IN     VARCHAR2    DEFAULT NULL,
    x_ebl_result                        IN     VARCHAR2    DEFAULT NULL,
    x_ebl_amended_result                IN     VARCHAR2    DEFAULT NULL,
    x_claimed_result                    IN     VARCHAR2    DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_app_results_pkg;

 

/
