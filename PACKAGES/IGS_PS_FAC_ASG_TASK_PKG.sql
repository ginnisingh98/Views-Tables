--------------------------------------------------------
--  DDL for Package IGS_PS_FAC_ASG_TASK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_FAC_ASG_TASK_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3HS.pls 115.4 2003/06/05 13:14:27 sarakshi noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fac_wl_id                         IN     NUMBER,
    x_faculty_task_type                 IN     VARCHAR2,
    x_confirmed_ind                     IN     VARCHAR2,
    x_num_rollover_period               IN     NUMBER,
    x_rollover_flag                     IN     VARCHAR2,
    x_dept_budget_cd                    IN     VARCHAR2,
    x_default_wl                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fac_wl_id                         IN     NUMBER,
    x_faculty_task_type                 IN     VARCHAR2,
    x_confirmed_ind                     IN     VARCHAR2,
    x_num_rollover_period               IN     NUMBER,
    x_rollover_flag                     IN     VARCHAR2,
    x_dept_budget_cd                    IN     VARCHAR2,
    x_default_wl                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fac_wl_id                         IN     NUMBER,
    x_faculty_task_type                 IN     VARCHAR2,
    x_confirmed_ind                     IN     VARCHAR2,
    x_num_rollover_period               IN     NUMBER,
    x_rollover_flag                     IN     VARCHAR2,
    x_dept_budget_cd                    IN     VARCHAR2,
    x_default_wl                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fac_wl_id                         IN     NUMBER,
    x_faculty_task_type                 IN     VARCHAR2,
    x_confirmed_ind                     IN     VARCHAR2,
    x_num_rollover_period               IN     NUMBER,
    x_rollover_flag                     IN     VARCHAR2,
    x_dept_budget_cd                    IN     VARCHAR2,
    x_default_wl                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_fac_wl_id                         IN     NUMBER,
    x_faculty_task_type                 IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_fac_wl (
    x_fac_wl_id                         IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fac_wl_id                         IN     NUMBER      DEFAULT NULL,
    x_faculty_task_type                 IN     VARCHAR2    DEFAULT NULL,
    x_confirmed_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_num_rollover_period               IN     NUMBER      DEFAULT NULL,
    x_rollover_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_dept_budget_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_default_wl                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_fac_asg_task_pkg;

 

/
