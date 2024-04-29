--------------------------------------------------------
--  DDL for Package IGS_AS_APPR_GRD_SCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_APPR_GRD_SCH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI58S.pls 115.3 2002/11/28 23:25:33 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_assessment_type                   IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_default_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_assessment_type                   IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_default_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_assessment_type                   IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_default_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_assessment_type                   IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_default_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_assessment_type                   IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_as_assessmnt_typ (
    x_assessment_type                   IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ps_unit_ver (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE get_fk_igs_as_grd_schema (
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_assessment_type                   IN     VARCHAR2    DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL,
    x_default_ind                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_appr_grd_sch_pkg;

 

/
