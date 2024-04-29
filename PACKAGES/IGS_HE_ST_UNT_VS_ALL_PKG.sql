--------------------------------------------------------
--  DDL for Package IGS_HE_ST_UNT_VS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_ST_UNT_VS_ALL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI24S.pls 120.1 2006/02/06 19:54:03 jbaber noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_st_unt_vs_id                 IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_prop_of_teaching_in_welsh         IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_module_length                     IN     NUMBER,
    x_proportion_of_fte                 IN     NUMBER,
    x_location_cd                       IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_exclude_flag                      IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hesa_st_unt_vs_id                 IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_prop_of_teaching_in_welsh         IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_module_length                     IN     NUMBER,
    x_proportion_of_fte                 IN     NUMBER,
    x_location_cd                       IN     VARCHAR2   DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hesa_st_unt_vs_id                 IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_prop_of_teaching_in_welsh         IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_module_length                     IN     NUMBER,
    x_proportion_of_fte                 IN     NUMBER,
    x_location_cd                       IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_exclude_flag                      IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_st_unt_vs_id                 IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_prop_of_teaching_in_welsh         IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_module_length                     IN     NUMBER,
    x_proportion_of_fte                 IN     NUMBER,
    x_location_cd                       IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_exclude_flag                      IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_hesa_st_unt_vs_id                 IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_unit_ver_all (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hesa_st_unt_vs_id                 IN     NUMBER      DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_prop_of_teaching_in_welsh         IN     NUMBER      DEFAULT NULL,
    x_credit_transfer_scheme            IN     VARCHAR2    DEFAULT NULL,
    x_module_length                     IN     NUMBER      DEFAULT NULL,
    x_proportion_of_fte                 IN     NUMBER      DEFAULT NULL,
    x_location_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2    DEFAULT NULL
  );

END igs_he_st_unt_vs_all_pkg;

 

/
