--------------------------------------------------------
--  DDL for Package IGS_UC_REF_TARIFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_REF_TARIFF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI41S.pls 115.2 2002/11/29 04:56:40 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_exam_grade                        IN     VARCHAR2,
    x_tariff_score                      IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_exam_grade                        IN     VARCHAR2,
    x_tariff_score                      IN     NUMBER,
    x_imported                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_exam_grade                        IN     VARCHAR2,
    x_tariff_score                      IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_exam_grade                        IN     VARCHAR2,
    x_tariff_score                      IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_exam_level                        IN     VARCHAR2,
    x_exam_grade                        IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_exam_level                        IN     VARCHAR2    DEFAULT NULL,
    x_exam_grade                        IN     VARCHAR2    DEFAULT NULL,
    x_tariff_score                      IN     NUMBER      DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_ref_tariff_pkg;

 

/
