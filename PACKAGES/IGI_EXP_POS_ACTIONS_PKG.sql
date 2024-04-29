--------------------------------------------------------
--  DDL for Package IGI_EXP_POS_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_POS_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: igiexds.pls 120.4.12000000.1 2007/09/13 04:24:15 mbremkum ship $ */
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pos_action_id                     IN OUT NOCOPY NUMBER,
    x_position_id                       IN     NUMBER,
    x_approve                           IN     VARCHAR2,
    x_reject                            IN     VARCHAR2,
    x_hold                              IN     VARCHAR2,
    x_return                            IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_pos_action_id                     IN     NUMBER,
    x_position_id                       IN     NUMBER,
    x_approve                           IN     VARCHAR2,
    x_reject                            IN     VARCHAR2,
    x_hold                              IN     VARCHAR2,
    x_return                            IN     VARCHAR2,

    x_org_id                            IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_pos_action_id                     IN     NUMBER,
    x_position_id                       IN     NUMBER,
    x_approve                           IN     VARCHAR2,
    x_reject                            IN     VARCHAR2,
    x_hold                              IN     VARCHAR2,
    x_return                            IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pos_action_id                     IN OUT NOCOPY NUMBER,
    x_position_id                       IN     NUMBER,
    x_approve                           IN     VARCHAR2,
    x_reject                            IN     VARCHAR2,
    x_hold                              IN     VARCHAR2,
    x_return                            IN     VARCHAR2,

    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_pos_action_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_position_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_pos_action_id                     IN     NUMBER      DEFAULT NULL,
    x_position_id                       IN     NUMBER      DEFAULT NULL,
    x_approve                           IN     VARCHAR2    DEFAULT NULL,
    x_reject                            IN     VARCHAR2    DEFAULT NULL,

    x_hold                              IN     VARCHAR2    DEFAULT NULL,
    x_return                            IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igi_exp_pos_actions_pkg;

 

/
