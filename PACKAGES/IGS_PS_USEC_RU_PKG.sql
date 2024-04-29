--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_RU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_RU_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2VS.pls 115.4 2002/11/29 02:20:17 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usecru_id                         IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_usecru_id                         IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_usecru_id                         IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usecru_id                         IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_usecru_id                         IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_uoo_id                            IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE get_fk_igs_ru_call (
    x_s_rule_call_cd                    IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ru_rule (
    x_rul_sequence_number               IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_usecru_id                         IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_s_rule_call_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_rul_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_usec_ru_pkg;

 

/
