--------------------------------------------------------
--  DDL for Package IGS_UC_APP_CHO_CNDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_APP_CHO_CNDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI03S.pls 115.3 2002/11/29 04:44:49 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_choice_cond_id                IN OUT NOCOPY NUMBER,
    x_app_choice_id                     IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_condition_type                    IN     VARCHAR2,
    x_condition_desc                    IN     VARCHAR2,
    x_satisfied                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_choice_cond_id                IN     NUMBER,
    x_app_choice_id                     IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_condition_type                    IN     VARCHAR2,
    x_condition_desc                    IN     VARCHAR2,
    x_satisfied                         IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_app_choice_cond_id                IN     NUMBER,
    x_app_choice_id                     IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_condition_type                    IN     VARCHAR2,
    x_condition_desc                    IN     VARCHAR2,
    x_satisfied                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_choice_cond_id                IN OUT NOCOPY NUMBER,
    x_app_choice_id                     IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_condition_type                    IN     VARCHAR2,
    x_condition_desc                    IN     VARCHAR2,
    x_satisfied                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_app_choice_cond_id                IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_condition_type                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_app_choices (
    x_app_choice_id                     IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_app_choice_cond_id                IN     NUMBER      DEFAULT NULL,
    x_app_choice_id                     IN     NUMBER      DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_choice_no                         IN     NUMBER      DEFAULT NULL,
    x_condition_type                    IN     VARCHAR2    DEFAULT NULL,
    x_condition_desc                    IN     VARCHAR2    DEFAULT NULL,
    x_satisfied                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_app_cho_cnds_pkg;

 

/
