--------------------------------------------------------
--  DDL for Package IGS_HE_CODE_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_CODE_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI05S.pls 115.4 2003/01/07 06:25:15 smaddali noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_code_type                         IN     VARCHAR2,
    x_value                             IN     VARCHAR2,
    x_value_description                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_closed_ind                        IN     VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_code_type                         IN     VARCHAR2,
    x_value                             IN     VARCHAR2,
    x_value_description                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_code_type                         IN     VARCHAR2,
    x_value                             IN     VARCHAR2,
    x_value_description                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_closed_ind                        IN     VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_code_type                         IN     VARCHAR2,
    x_value                             IN     VARCHAR2,
    x_value_description                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_closed_ind                        IN     VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_code_type                         IN     VARCHAR2,
    x_value                             IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_code_type                         IN     VARCHAR2,
    x_value                             IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_code_types (
    x_code_type                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_code_type                         IN     VARCHAR2    DEFAULT NULL,
    x_value                             IN     VARCHAR2    DEFAULT NULL,
    x_value_description                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL ,
    x_closed_ind                        IN     VARCHAR2 DEFAULT 'N'
  );

END igs_he_code_values_pkg;

 

/
