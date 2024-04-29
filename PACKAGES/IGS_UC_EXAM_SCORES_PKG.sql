--------------------------------------------------------
--  DDL for Package IGS_UC_EXAM_SCORES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_EXAM_SCORES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI18S.pls 115.4 2002/11/29 04:49:54 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_exam_scores_id                    IN OUT NOCOPY NUMBER,
    x_ref_code_type                     IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_grades                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_exam_scores_id                    IN     NUMBER,
    x_ref_code_type                     IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_grades                            IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_exam_scores_id                    IN     NUMBER,
    x_ref_code_type                     IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_grades                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_exam_scores_id                    IN OUT NOCOPY NUMBER,
    x_ref_code_type                     IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_grades                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_exam_scores_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_ref_codes (
    x_code_type                         IN     VARCHAR2,
    x_code                              IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_exam_scores_id                    IN     NUMBER      DEFAULT NULL,
    x_ref_code_type                     IN     VARCHAR2    DEFAULT NULL,
    x_exam_level                        IN     VARCHAR2    DEFAULT NULL,
    x_points                            IN     VARCHAR2    DEFAULT NULL,
    x_grades                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_exam_scores_pkg;

 

/
