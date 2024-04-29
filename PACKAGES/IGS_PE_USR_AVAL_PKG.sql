--------------------------------------------------------
--  DDL for Package IGS_PE_USR_AVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_USR_AVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI83S.pls 115.7 2002/11/29 01:33:22 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usr_act_val_id                    IN OUT NOCOPY NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_validation                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_deny_warn                         IN     VARCHAR2    DEFAULT NULL,
    x_override_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_override_dt                       IN     DATE        DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_usr_act_val_id                    IN     NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_validation                        IN     VARCHAR2,
    x_deny_warn                         IN     VARCHAR2    DEFAULT NULL,
    x_override_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_override_dt                       IN     DATE        DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_usr_act_val_id                    IN     NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_validation                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_deny_warn                         IN     VARCHAR2    DEFAULT NULL,
    x_override_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_override_dt                       IN     DATE        DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usr_act_val_id                    IN OUT NOCOPY NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_validation                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_deny_warn                         IN     VARCHAR2    DEFAULT NULL,
    x_override_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_override_dt                       IN     DATE        DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_usr_act_val_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_type                       IN     VARCHAR2,
    x_validation                        IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pe_person_types (
    x_person_type_code                  IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_usr_act_val_id                    IN     NUMBER      DEFAULT NULL,
    x_person_type                       IN     VARCHAR2    DEFAULT NULL,
    x_validation                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_deny_warn                         IN     VARCHAR2    DEFAULT NULL,
    x_override_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_override_dt                       IN     DATE        DEFAULT NULL
  );

END igs_pe_usr_aval_pkg;

 

/
