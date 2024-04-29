--------------------------------------------------------
--  DDL for Package IGS_CO_LTR_PARM_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_LTR_PARM_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI09S.pls 115.5 2002/11/29 01:04:32 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_letter_parameter_type             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_s_letter_parameter_type           IN     VARCHAR2,
    x_letter_text                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_letter_parameter_type             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_s_letter_parameter_type           IN     VARCHAR2,
    x_letter_text                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_letter_parameter_type             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_s_letter_parameter_type           IN     VARCHAR2,
    x_letter_text                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_letter_parameter_type             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_s_letter_parameter_type           IN     VARCHAR2,
    x_letter_text                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE check_constraints (
    column_name                         IN     VARCHAR2    DEFAULT NULL,
    column_value                        IN     VARCHAR2    DEFAULT NULL
  );

  FUNCTION get_pk_for_validation (
    x_letter_parameter_type             IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_co_s_ltr_param (
    x_s_letter_parameter_type           IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_letter_parameter_type             IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_s_letter_parameter_type           IN     VARCHAR2    DEFAULT NULL,
    x_letter_text                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_co_ltr_parm_type_pkg;

 

/
