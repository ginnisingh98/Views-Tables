--------------------------------------------------------
--  DDL for Package IGS_UC_OFFER_CONDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_OFFER_CONDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI22S.pls 115.4 2003/11/02 18:00:46 ayedubat noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_effective_from                    IN     DATE,
    x_effective_to                      IN     DATE,
    x_status                            IN     VARCHAR2,
    x_marvin_code                       IN     VARCHAR2,
    x_summ_of_cond                      IN     VARCHAR2,
    x_letter_text                       IN     LONG,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_decision                          IN     VARCHAR2  DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_effective_from                    IN     DATE,
    x_effective_to                      IN     DATE,
    x_status                            IN     VARCHAR2,
    x_marvin_code                       IN     VARCHAR2,
    x_summ_of_cond                      IN     VARCHAR2,
    x_letter_text                       IN     LONG,
    x_decision                          IN     VARCHAR2  DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_effective_from                    IN     DATE,
    x_effective_to                      IN     DATE,
    x_status                            IN     VARCHAR2,
    x_marvin_code                       IN     VARCHAR2,
    x_summ_of_cond                      IN     VARCHAR2,
    x_letter_text                       IN     LONG,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_decision                          IN     VARCHAR2  DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_effective_from                    IN     DATE,
    x_effective_to                      IN     DATE,
    x_status                            IN     VARCHAR2,
    x_marvin_code                       IN     VARCHAR2,
    x_summ_of_cond                      IN     VARCHAR2,
    x_letter_text                       IN     LONG,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_decision                          IN     VARCHAR2  DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_condition_category                IN     VARCHAR2    DEFAULT NULL,
    x_condition_name                    IN     VARCHAR2    DEFAULT NULL,
    x_effective_from                    IN     DATE        DEFAULT NULL,
    x_effective_to                      IN     DATE        DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_marvin_code                       IN     VARCHAR2    DEFAULT NULL,
    x_summ_of_cond                      IN     VARCHAR2    DEFAULT NULL,
    x_letter_text                       IN     LONG        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_decision                          IN     VARCHAR2  DEFAULT NULL
  );

END igs_uc_offer_conds_pkg;

 

/
