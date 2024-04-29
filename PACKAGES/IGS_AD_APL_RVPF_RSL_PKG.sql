--------------------------------------------------------
--  DDL for Package IGS_AD_APL_RVPF_RSL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APL_RVPF_RSL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIF3S.pls 115.4 2002/11/28 22:35:19 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_revprof_rtscale_id           IN OUT NOCOPY NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_rating_type_id                    IN     NUMBER,
    x_rating_scale_id                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_revprof_rtscale_id           IN     NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_rating_type_id                    IN     NUMBER,
    x_rating_scale_id                   IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_revprof_rtscale_id           IN     NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_rating_type_id                    IN     NUMBER,
    x_rating_scale_id                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_revprof_rtscale_id           IN OUT NOCOPY NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_rating_type_id                    IN     NUMBER,
    x_rating_scale_id                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_appl_revprof_rtscale_id           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_appl_rev_profile_id               IN     NUMBER,
    x_rating_type_id                    IN     NUMBER,
    x_rating_scale_id                   IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igs_ad_apl_rev_prf (
    x_appl_rev_profile_id               IN     NUMBER
  );

  PROCEDURE get_fk_igs_ad_code_classes (
    x_code_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igs_ad_rating_scales (
    x_rating_scale_id                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_revprof_rtscale_id           IN     NUMBER      DEFAULT NULL,
    x_appl_rev_profile_id               IN     NUMBER      DEFAULT NULL,
    x_rating_type_id                    IN     NUMBER      DEFAULT NULL,
    x_rating_scale_id                   IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_apl_rvpf_rsl_pkg;

 

/
