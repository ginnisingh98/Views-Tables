--------------------------------------------------------
--  DDL for Package IGS_AD_APL_REV_PRF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APL_REV_PRF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIF2S.pls 115.5 2003/10/30 13:17:45 akadam noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_rev_profile_id               IN OUT NOCOPY NUMBER,
    x_review_profile_name               IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_min_evaluator                     IN     NUMBER,
    x_max_evaluator                     IN     NUMBER,
    x_prog_approval_required            IN     VARCHAR2,
    x_sequential_concurrent_ind         IN     VARCHAR2,
    x_appl_rev_profile_gr_cd            IN     VARCHAR2,
    x_site_use_code                     IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_rev_profile_id               IN     NUMBER,
    x_review_profile_name               IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_min_evaluator                     IN     NUMBER,
    x_max_evaluator                     IN     NUMBER,
    x_prog_approval_required            IN     VARCHAR2,
    x_sequential_concurrent_ind         IN     VARCHAR2,
    x_appl_rev_profile_gr_cd            IN     VARCHAR2,
    x_site_use_code                     IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_rev_profile_id               IN     NUMBER,
    x_review_profile_name               IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_min_evaluator                     IN     NUMBER,
    x_max_evaluator                     IN     NUMBER,
    x_prog_approval_required            IN     VARCHAR2,
    x_sequential_concurrent_ind         IN     VARCHAR2,
    x_appl_rev_profile_gr_cd            IN     VARCHAR2,
    x_site_use_code                     IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_rev_profile_id               IN OUT NOCOPY NUMBER,
    x_review_profile_name               IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_min_evaluator                     IN     NUMBER,
    x_max_evaluator                     IN     NUMBER,
    x_prog_approval_required            IN     VARCHAR2,
    x_sequential_concurrent_ind         IN     VARCHAR2,
    x_appl_rev_profile_gr_cd            IN     VARCHAR2,
    x_site_use_code                     IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_appl_rev_profile_id               IN     NUMBER ,
    x_closed_ind                        IN VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_review_profile_name               IN     VARCHAR2,
    x_closed_ind                        IN VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_lookups_val (
    x_appl_rev_profile_gr_cd               IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_rev_profile_id               IN     NUMBER      DEFAULT NULL,
    x_review_profile_name               IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_min_evaluator                     IN     NUMBER      DEFAULT NULL,
    x_max_evaluator                     IN     NUMBER      DEFAULT NULL,
    x_prog_approval_required            IN     VARCHAR2    DEFAULT NULL,
    x_sequential_concurrent_ind         IN     VARCHAR2    DEFAULT NULL,
    x_appl_rev_profile_gr_cd            IN     VARCHAR2    DEFAULT NULL,
    x_site_use_code                     IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_apl_rev_prf_pkg;

 

/
