--------------------------------------------------------
--  DDL for Package IGS_AD_RVGR_INC_EXC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_RVGR_INC_EXC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIF5S.pls 115.4 2002/11/28 22:35:55 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_revgr_incl_excl_id                IN OUT NOCOPY NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_incl_excl_ind                     IN     VARCHAR2,
    x_start_value                       IN     VARCHAR2,
    x_end_value                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_country                           IN     VARCHAR2,
    x_postal_incl_excl_ind              IN     VARCHAR2,
    x_postal_start_value                IN     VARCHAR2,
    x_postal_end_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_revgr_incl_excl_id                IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_incl_excl_ind                     IN     VARCHAR2,
    x_start_value                       IN     VARCHAR2,
    x_end_value                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_country                           IN     VARCHAR2,
    x_postal_incl_excl_ind              IN     VARCHAR2,
    x_postal_start_value                IN     VARCHAR2,
    x_postal_end_value                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_revgr_incl_excl_id                IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_incl_excl_ind                     IN     VARCHAR2,
    x_start_value                       IN     VARCHAR2,
    x_end_value                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_country                           IN     VARCHAR2,
    x_postal_incl_excl_ind              IN     VARCHAR2,
    x_postal_start_value                IN     VARCHAR2,
    x_postal_end_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_revgr_incl_excl_id                IN OUT NOCOPY NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_incl_excl_ind                     IN     VARCHAR2,
    x_start_value                       IN     VARCHAR2,
    x_end_value                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_country                           IN     VARCHAR2,
    x_postal_incl_excl_ind              IN     VARCHAR2,
    x_postal_start_value                IN     VARCHAR2,
    x_postal_end_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_revgr_incl_excl_id                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_apl_rprf_rgr (
    x_appl_revprof_revgr_id             IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_revgr_incl_excl_id                IN     NUMBER      DEFAULT NULL,
    x_appl_revprof_revgr_id             IN     NUMBER      DEFAULT NULL,
    x_incl_excl_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_start_value                       IN     VARCHAR2    DEFAULT NULL,
    x_end_value                         IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_country                           IN     VARCHAR2    DEFAULT NULL,
    x_postal_incl_excl_ind              IN     VARCHAR2    DEFAULT NULL,
    x_postal_start_value                IN     VARCHAR2    DEFAULT NULL,
    x_postal_end_value                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_rvgr_inc_exc_pkg;

 

/
