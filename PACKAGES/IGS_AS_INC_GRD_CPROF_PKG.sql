--------------------------------------------------------
--  DDL for Package IGS_AS_INC_GRD_CPROF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_INC_GRD_CPROF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI56S.pls 115.3 2002/11/28 23:24:56 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inc_grd_cprof_id                  IN OUT NOCOPY NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_incomplete_grade                  IN     VARCHAR2,
    x_number_unit_time                  IN     NUMBER,
    x_type_unit_time                    IN     VARCHAR2,
    x_comp_after_dt_alias               IN     VARCHAR2,
    x_default_grade                     IN     VARCHAR2,
    x_default_mark                      IN     NUMBER,
    x_instructor_update_ind             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_inc_grd_cprof_id                  IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_incomplete_grade                  IN     VARCHAR2,
    x_number_unit_time                  IN     NUMBER,
    x_type_unit_time                    IN     VARCHAR2,
    x_comp_after_dt_alias               IN     VARCHAR2,
    x_default_grade                     IN     VARCHAR2,
    x_default_mark                      IN     NUMBER,
    x_instructor_update_ind             IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_inc_grd_cprof_id                  IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_incomplete_grade                  IN     VARCHAR2,
    x_number_unit_time                  IN     NUMBER,
    x_type_unit_time                    IN     VARCHAR2,
    x_comp_after_dt_alias               IN     VARCHAR2,
    x_default_grade                     IN     VARCHAR2,
    x_default_mark                      IN     NUMBER,
    x_instructor_update_ind             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inc_grd_cprof_id                  IN OUT NOCOPY NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_incomplete_grade                  IN     VARCHAR2,
    x_number_unit_time                  IN     NUMBER,
    x_type_unit_time                    IN     VARCHAR2,
    x_comp_after_dt_alias               IN     VARCHAR2,
    x_default_grade                     IN     VARCHAR2,
    x_default_mark                      IN     NUMBER,
    x_instructor_update_ind             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_inc_grd_cprof_id                  IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_version_number                    IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_incomplete_grade                  IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_as_grd_sch_grade (
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_grade                             IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ca_da (
    x_dt_alias                          IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_as_grd_schema (
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_inc_grd_cprof_id                  IN     NUMBER      DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_incomplete_grade                  IN     VARCHAR2    DEFAULT NULL,
    x_number_unit_time                  IN     NUMBER      DEFAULT NULL,
    x_type_unit_time                    IN     VARCHAR2    DEFAULT NULL,
    x_comp_after_dt_alias               IN     VARCHAR2    DEFAULT NULL,
    x_default_grade                     IN     VARCHAR2    DEFAULT NULL,
    x_default_mark                      IN     NUMBER      DEFAULT NULL,
    x_instructor_update_ind             IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_inc_grd_cprof_pkg;

 

/
