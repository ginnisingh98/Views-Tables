--------------------------------------------------------
--  DDL for Package IGS_UC_QUAL_DETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_QUAL_DETS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI37S.pls 120.1 2005/06/09 23:52:15 appldev  $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_qual_dets_id                      IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_approved_result                   IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_ucas_tariff                       IN     NUMBER,
    x_imported_flag                     IN     VARCHAR2,
    x_imported_date                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_qual_dets_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_approved_result                   IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_ucas_tariff                       IN     NUMBER,
    x_imported_flag                     IN     VARCHAR2,
    x_imported_date                     IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_qual_dets_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_approved_result                   IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_ucas_tariff                       IN     NUMBER,
    x_imported_flag                     IN     VARCHAR2,
    x_imported_date                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_qual_dets_id                      IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_approved_result                   IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_ucas_tariff                       IN     NUMBER,
    x_imported_flag                     IN     VARCHAR2,
    x_imported_date                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_qual_dets_id                      IN     NUMBER
  ) RETURN BOOLEAN;

  --smaddali added new field approved result for bug 2409543
  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_approved_result                   IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_as_grd_sch_grade (
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_grade                             IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ps_awd (
    x_award_cd                          IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ps_fld_of_study_all (
    x_field_of_study                    IN     VARCHAR2
  );

  PROCEDURE get_ufk_hz_parties (
    x_party_number                      IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_pe_person (
    x_person_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_qual_dets_id                      IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_exam_level                        IN     VARCHAR2    DEFAULT NULL,
    x_subject_code                      IN     VARCHAR2    DEFAULT NULL,
    x_year                              IN     NUMBER      DEFAULT NULL,
    x_sitting                           IN     VARCHAR2    DEFAULT NULL,
    x_awarding_body                     IN     VARCHAR2    DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_predicted_result                  IN     VARCHAR2    DEFAULT NULL,
    x_approved_result                   IN     VARCHAR2    DEFAULT NULL,
    x_claimed_result                    IN     VARCHAR2    DEFAULT NULL,
    x_ucas_tariff                       IN     NUMBER      DEFAULT NULL,
    x_imported_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_imported_date                     IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_qual_dets_pkg;

 

/
