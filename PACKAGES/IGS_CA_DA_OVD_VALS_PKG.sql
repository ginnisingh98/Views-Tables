--------------------------------------------------------
--  DDL for Package IGS_CA_DA_OVD_VALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_DA_OVD_VALS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSCI20S.pls 120.1 2005/08/11 05:48:02 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ovrd_val_id                       IN OUT NOCOPY NUMBER,
    x_sys_date_type                     IN     VARCHAR2,
    x_element_code                      IN     VARCHAR2,
    x_element_code_value                IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ovrd_val_id                       IN     NUMBER,
    x_sys_date_type                     IN     VARCHAR2,
    x_element_code                      IN     VARCHAR2,
    x_element_code_value                IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ovrd_val_id                       IN     NUMBER,
    x_sys_date_type                     IN     VARCHAR2,
    x_element_code                      IN     VARCHAR2,
    x_element_code_value                IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ovrd_val_id                       IN OUT NOCOPY NUMBER,
    x_sys_date_type                     IN     VARCHAR2,
    x_element_code                      IN     VARCHAR2,
    x_element_code_value                IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ovrd_val_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_da_configs (
    x_sys_date_type                     IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ovrd_val_id                       IN     NUMBER      DEFAULT NULL,
    x_sys_date_type                     IN     VARCHAR2    DEFAULT NULL,
    x_element_code                      IN     VARCHAR2    DEFAULT NULL,
    x_element_code_value                IN     VARCHAR2    DEFAULT NULL,
    x_date_alias                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ca_da_ovd_vals_pkg;

 

/
