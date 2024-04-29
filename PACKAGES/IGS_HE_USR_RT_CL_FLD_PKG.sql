--------------------------------------------------------
--  DDL for Package IGS_HE_USR_RT_CL_FLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_USR_RT_CL_FLD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI16S.pls 120.1 2006/05/02 17:42:36 jbaber noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usr_rt_cl_fld_id                  IN OUT NOCOPY NUMBER,
    x_user_return_subclass              IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_constant_val                      IN     VARCHAR2,
    x_default_val                       IN     VARCHAR2,
    x_include_flag                      IN     VARCHAR2,
    x_report_null_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_usr_rt_cl_fld_id                  IN     NUMBER,
    x_user_return_subclass              IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_constant_val                      IN     VARCHAR2,
    x_default_val                       IN     VARCHAR2,
    x_include_flag                      IN     VARCHAR2,
    x_report_null_flag                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_usr_rt_cl_fld_id                  IN     NUMBER,
    x_user_return_subclass              IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_constant_val                      IN     VARCHAR2,
    x_default_val                       IN     VARCHAR2,
    x_include_flag                      IN     VARCHAR2,
    x_report_null_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usr_rt_cl_fld_id                  IN OUT NOCOPY NUMBER,
    x_user_return_subclass              IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_constant_val                      IN     VARCHAR2,
    x_default_val                       IN     VARCHAR2,
    x_include_flag                      IN     VARCHAR2,
    x_report_null_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_user_return_subclass              IN     VARCHAR2,
    x_field_number                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_usr_rtn_clas (
    x_user_return_subclass              IN     VARCHAR2
  );

/* added by rgopalan for unique constraints */

  FUNCTION get_uk_for_validation (
    x_user_return_subclass              IN     VARCHAR2,
    x_field_number                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_usr_rt_cl_fld_id                  IN     NUMBER      DEFAULT NULL,
    x_user_return_subclass              IN     VARCHAR2    DEFAULT NULL,
    x_field_number                      IN     NUMBER      DEFAULT NULL,
    x_constant_val                      IN     VARCHAR2    DEFAULT NULL,
    x_default_val                       IN     VARCHAR2    DEFAULT NULL,
    x_include_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_report_null_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_usr_rt_cl_fld_pkg;

 

/
