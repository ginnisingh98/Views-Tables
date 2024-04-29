--------------------------------------------------------
--  DDL for Package IGS_UC_COM_EBL_SUBJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_COM_EBL_SUBJ_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI08S.pls 115.4 2003/06/11 10:30:02 smaddali noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_subject_id                        IN OUT NOCOPY NUMBER,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_external_ref                      IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_subject_id                        IN     NUMBER,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_external_ref                      IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_subject_id                        IN     NUMBER,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_external_ref                      IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_subject_id                        IN OUT NOCOPY NUMBER,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_external_ref                      IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_subject_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_ref_awrdbdy (
    x_awarding_body                     IN     VARCHAR2,
    x_sitting                           IN     VARCHAR2,
    x_year                              IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_subject_id                        IN     NUMBER      DEFAULT NULL,
    x_year                              IN     NUMBER      DEFAULT NULL,
    x_sitting                           IN     VARCHAR2    DEFAULT NULL,
    x_awarding_body                     IN     VARCHAR2    DEFAULT NULL,
    x_external_ref                      IN     VARCHAR2    DEFAULT NULL,
    x_exam_level                        IN     VARCHAR2    DEFAULT NULL,
    x_title                             IN     VARCHAR2    DEFAULT NULL,
    x_subject_code                      IN     VARCHAR2    DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_com_ebl_subj_pkg;

 

/
