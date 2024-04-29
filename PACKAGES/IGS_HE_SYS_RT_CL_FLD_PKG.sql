--------------------------------------------------------
--  DDL for Package IGS_HE_SYS_RT_CL_FLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_SYS_RT_CL_FLD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI14S.pls 115.3 2002/11/29 04:38:27 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_field_name                        IN     VARCHAR2,
    x_field_description                 IN     VARCHAR2,
    x_datatype                          IN     VARCHAR2,
    x_length                            IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_field_name                        IN     VARCHAR2,
    x_field_description                 IN     VARCHAR2,
    x_datatype                          IN     VARCHAR2,
    x_length                            IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_field_name                        IN     VARCHAR2,
    x_field_description                 IN     VARCHAR2,
    x_datatype                          IN     VARCHAR2,
    x_length                            IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_field_name                        IN     VARCHAR2,
    x_field_description                 IN     VARCHAR2,
    x_datatype                          IN     VARCHAR2,
    x_length                            IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_sys_rtn_clas (
    x_system_return_class_type          IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_system_return_class_type          IN     VARCHAR2    DEFAULT NULL,
    x_field_number                      IN     NUMBER      DEFAULT NULL,
    x_field_name                        IN     VARCHAR2    DEFAULT NULL,
    x_field_description                 IN     VARCHAR2    DEFAULT NULL,
    x_datatype                          IN     VARCHAR2    DEFAULT NULL,
    x_length                            IN     NUMBER      DEFAULT NULL,
    x_mandatory_flag                    IN     VARCHAR2    DEFAULT NULL,
    x_closed_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_sys_rt_cl_fld_pkg;

 

/
