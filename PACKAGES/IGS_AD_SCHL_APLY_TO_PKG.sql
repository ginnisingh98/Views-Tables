--------------------------------------------------------
--  DDL for Package IGS_AD_SCHL_APLY_TO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SCHL_APLY_TO_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIE4S.pls 115.6 2003/10/30 13:17:37 akadam ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sch_apl_to_id                     IN OUT NOCOPY NUMBER,
    x_school_applying_to                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sch_apl_to_id                     IN     NUMBER,
    x_school_applying_to                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sch_apl_to_id                     IN     NUMBER,
    x_school_applying_to                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sch_apl_to_id                     IN OUT NOCOPY NUMBER,
    x_school_applying_to                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_sch_apl_to_id                     IN     NUMBER ,
    x_closed_ind                        IN VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_school_applying_to                IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_closed_ind                        IN VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_or_unit (
    x_party_number                      IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sch_apl_to_id                     IN     NUMBER      DEFAULT NULL,
    x_school_applying_to                IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_schl_aply_to_pkg;

 

/
