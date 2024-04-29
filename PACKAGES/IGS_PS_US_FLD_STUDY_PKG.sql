--------------------------------------------------------
--  DDL for Package IGS_PS_US_FLD_STUDY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_US_FLD_STUDY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI98S.pls 115.1 2003/05/21 13:50:22 jbegum noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_field_of_study                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_field_of_study                    IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_unit_set_cd                       IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_field_of_study                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_unit_set (
    x_unit_set_cd                       IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_fld_of_study (
    x_field_of_study                    IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_unit_set_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_field_of_study                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_us_fld_study_pkg;

 

/
