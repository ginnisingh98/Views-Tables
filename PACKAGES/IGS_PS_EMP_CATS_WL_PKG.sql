--------------------------------------------------------
--  DDL for Package IGS_PS_EMP_CATS_WL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_EMP_CATS_WL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3KS.pls 120.1 2005/10/04 00:33:34 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2,
    x_expected_wl_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2,
    x_expected_wl_num                   IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2,
    x_expected_wl_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2,
    x_expected_wl_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_exp_wl (
    x_calendar_cat                      IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_cal_cat_code                      IN     VARCHAR2    DEFAULT NULL,
    x_emp_cat_code                      IN     VARCHAR2    DEFAULT NULL,
    x_expected_wl_num                   IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_emp_cats_wl_pkg;

 

/
