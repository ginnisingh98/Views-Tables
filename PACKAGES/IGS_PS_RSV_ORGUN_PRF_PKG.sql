--------------------------------------------------------
--  DDL for Package IGS_PS_RSV_ORGUN_PRF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_RSV_ORGUN_PRF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI1VS.pls 115.4 2003/02/18 08:52:31 npalanis ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rsv_org_unit_prf_id               IN OUT NOCOPY NUMBER,
    x_rsv_org_unit_pri_id               IN     NUMBER,
    x_preference_order                  IN     NUMBER,
    x_preference_code                   IN     VARCHAR2,
    x_preference_version                IN     NUMBER,
    x_percentage_reserved               IN     NUMBER,
    x_group_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rsv_org_unit_prf_id               IN     NUMBER,
    x_rsv_org_unit_pri_id               IN     NUMBER,
    x_preference_order                  IN     NUMBER,
    x_preference_code                   IN     VARCHAR2,
    x_preference_version                IN     NUMBER,
    x_percentage_reserved               IN     NUMBER,
    x_group_id                          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_rsv_org_unit_prf_id               IN     NUMBER,
    x_rsv_org_unit_pri_id               IN     NUMBER,
    x_preference_order                  IN     NUMBER,
    x_preference_code                   IN     VARCHAR2,
    x_preference_version                IN     NUMBER,
    x_percentage_reserved               IN     NUMBER,
    x_group_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rsv_org_unit_prf_id               IN OUT NOCOPY NUMBER,
    x_rsv_org_unit_pri_id               IN     NUMBER,
    x_preference_order                  IN     NUMBER,
    x_preference_code                   IN     VARCHAR2,
    x_preference_version                IN     NUMBER,
    x_percentage_reserved               IN     NUMBER,
    x_group_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_rsv_org_unit_prf_id               IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_rsv_org_unit_pri_id               IN     NUMBER,
    x_preference_code                   IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_rsv_ogpri_all (
    x_rsv_org_unit_pri_id               IN     NUMBER
  );

   PROCEDURE get_fk_igs_ps_ver_all (
    x_preference_code               IN     VARCHAR2,
    x_preference_version          IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_stage_type (
    x_preference_code               IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_en_unit_set_all (
    x_preference_code               IN     VARCHAR2,
    x_preference_version            IN     NUMBER
  );

   PROCEDURE get_fk_hz_parties (
    x_preference_code               IN     VARCHAR2
  );


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rsv_org_unit_prf_id               IN     NUMBER      DEFAULT NULL,
    x_rsv_org_unit_pri_id               IN     NUMBER      DEFAULT NULL,
    x_preference_order                  IN     NUMBER      DEFAULT NULL,
    x_preference_code                   IN     VARCHAR2    DEFAULT NULL,
    x_preference_version                IN     NUMBER      DEFAULT NULL,
    x_percentage_reserved               IN     NUMBER      DEFAULT NULL,
    x_group_id                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_rsv_orgun_prf_pkg;

 

/
