--------------------------------------------------------
--  DDL for Package IGS_EN_ELGB_OVR_STEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ELGB_OVR_STEP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI52S.pls 115.6 2003/06/03 12:58:10 savenkat ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_elgb_ovr_step_id                  IN OUT NOCOPY NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_step_override_type                IN     VARCHAR2,
    x_step_override_dt                  IN     DATE,
    x_step_override_limit               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_elgb_ovr_step_id                  IN     NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_step_override_type                IN     VARCHAR2,
    x_step_override_dt                  IN     DATE,
    x_step_override_limit               IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_elgb_ovr_step_id                  IN     NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_step_override_type                IN     VARCHAR2,
    x_step_override_dt                  IN     DATE,
    x_step_override_limit               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_elgb_ovr_step_id                  IN OUT NOCOPY NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_step_override_type                IN     VARCHAR2,
    x_step_override_dt                  IN     DATE,
    x_step_override_limit               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_elgb_ovr_step_id                  IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_step_override_type                IN     VARCHAR2,
    x_elgb_override_id                  IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_elgb_ovr (
    x_elgb_override_id                  IN     NUMBER
  );


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_elgb_ovr_step_id                  IN     NUMBER      DEFAULT NULL,
    x_elgb_override_id                  IN     NUMBER      DEFAULT NULL,
    x_step_override_type                IN     VARCHAR2    DEFAULT NULL,
    x_step_override_dt                  IN     DATE        DEFAULT NULL,
    x_step_override_limit               IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_elgb_ovr_step_pkg;

 

/
