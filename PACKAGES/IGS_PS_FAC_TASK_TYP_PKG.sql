--------------------------------------------------------
--  DDL for Package IGS_PS_FAC_TASK_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_FAC_TASK_TYP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3FS.pls 115.4 2003/06/10 13:16:16 sarakshi noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_faculty_task_type                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_dept_budget_cd                    IN     VARCHAR2,
    x_default_wl                        IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_faculty_task_type                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_dept_budget_cd                    IN     VARCHAR2,
    x_default_wl                        IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_faculty_task_type                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_dept_budget_cd                    IN     VARCHAR2,
    x_default_wl                        IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_faculty_task_type                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_dept_budget_cd                    IN     VARCHAR2,
    x_default_wl                        IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_faculty_task_type                 IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE CHECK_CONSTRAINTS (
        Column_Name IN VARCHAR2 DEFAULT NULL,
        Column_Value IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_faculty_task_type                 IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_dept_budget_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_default_wl                        IN     NUMBER      DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_fac_task_typ_pkg;

 

/
