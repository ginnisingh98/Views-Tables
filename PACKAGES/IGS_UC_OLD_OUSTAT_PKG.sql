--------------------------------------------------------
--  DDL for Package IGS_UC_OLD_OUSTAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_OLD_OUSTAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI43S.pls 115.4 2002/11/29 04:57:15 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_old_outcome_status                IN     VARCHAR2,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_decision_make_id                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_old_outcome_status                IN     VARCHAR2,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_decision_make_id                  IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_old_outcome_status                IN     VARCHAR2,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_decision_make_id                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_old_outcome_status                IN     VARCHAR2,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_decision_make_id                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_choice_no                         IN     NUMBER      DEFAULT NULL,
    x_old_outcome_status                IN     VARCHAR2    DEFAULT NULL,
    x_decision_date                     IN     DATE        DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER      DEFAULT NULL,
    x_decision_make_id                  IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_old_oustat_pkg;

 

/
