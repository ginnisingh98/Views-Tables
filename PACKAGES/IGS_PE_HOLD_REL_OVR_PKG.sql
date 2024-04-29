--------------------------------------------------------
--  DDL for Package IGS_PE_HOLD_REL_OVR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_HOLD_REL_OVR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI85S.pls 115.4 2002/11/29 01:33:54 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hold_rel_ovr_id                   IN OUT NOCOPY NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_hold_type                         IN     VARCHAR2,
    x_hold_rel_or_ovr                   IN     VARCHAR2,
    x_hold_old_end_dt                   IN     DATE,
    x_action_dt                         IN     DATE,
    x_start_date                        IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hold_rel_ovr_id                   IN     NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_hold_type                         IN     VARCHAR2,
    x_hold_rel_or_ovr                   IN     VARCHAR2,
    x_hold_old_end_dt                   IN     DATE,
    x_action_dt                         IN     DATE,
    x_start_date                        IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hold_rel_ovr_id                   IN     NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_hold_type                         IN     VARCHAR2,
    x_hold_rel_or_ovr                   IN     VARCHAR2,
    x_hold_old_end_dt                   IN     DATE,
    x_action_dt                         IN     DATE,
    x_start_date                        IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hold_rel_ovr_id                   IN OUT NOCOPY NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_hold_type                         IN     VARCHAR2,
    x_hold_rel_or_ovr                   IN     VARCHAR2,
    x_hold_old_end_dt                   IN     DATE,
    x_action_dt                         IN     DATE,
    x_start_date                        IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_hold_rel_ovr_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_elgb_override_id                  IN     NUMBER,
    x_hold_type                         IN     VARCHAR2,
    x_start_date                        IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_elgb_ovr (
    x_elgb_override_id                  IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_encmb_type (
    x_encumbrance_type                  IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hold_rel_ovr_id                   IN     NUMBER      DEFAULT NULL,
    x_elgb_override_id                  IN     NUMBER      DEFAULT NULL,
    x_hold_type                         IN     VARCHAR2    DEFAULT NULL,
    x_hold_rel_or_ovr                   IN     VARCHAR2    DEFAULT NULL,
    x_hold_old_end_dt                   IN     DATE        DEFAULT NULL,
    x_action_dt                         IN     DATE        DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_hold_rel_ovr_pkg;

 

/
