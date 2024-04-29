--------------------------------------------------------
--  DDL for Package IGS_PS_FAC_OVR_WL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_FAC_OVR_WL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3IS.pls 115.3 2002/11/29 02:26:48 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fac_ovr_wl_id                     IN OUT NOCOPY NUMBER,
    x_fac_wl_id                         IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_new_exp_wl                        IN     NUMBER,
    x_override_reason                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fac_ovr_wl_id                     IN     NUMBER,
    x_fac_wl_id                         IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_new_exp_wl                        IN     NUMBER,
    x_override_reason                   IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fac_ovr_wl_id                     IN     NUMBER,
    x_fac_wl_id                         IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_new_exp_wl                        IN     NUMBER,
    x_override_reason                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fac_ovr_wl_id                     IN OUT NOCOPY NUMBER,
    x_fac_wl_id                         IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_new_exp_wl                        IN     NUMBER,
    x_override_reason                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_fac_ovr_wl_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_wl_over_resn (
    x_override_reason                   IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ps_fac_wl (
    x_fac_wl_id                         IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fac_ovr_wl_id                     IN     NUMBER      DEFAULT NULL,
    x_fac_wl_id                         IN     NUMBER      DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_new_exp_wl                        IN     NUMBER      DEFAULT NULL,
    x_override_reason                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_fac_ovr_wl_pkg;

 

/
