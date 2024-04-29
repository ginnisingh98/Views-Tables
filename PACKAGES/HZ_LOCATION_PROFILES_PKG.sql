--------------------------------------------------------
--  DDL for Package HZ_LOCATION_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_LOCATION_PROFILES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHLOCPS.pls 115.1 2003/08/14 00:22:25 acng noship $ */

  PROCEDURE insert_row (
    x_location_profile_id                   IN OUT NOCOPY NUMBER,
    x_location_id                           IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2,
    x_effective_start_date                  IN     DATE,
    x_effective_end_date                    IN     DATE,
    x_validation_sst_flag                   IN     VARCHAR2,
    x_validation_status_code                IN     VARCHAR2,
    x_date_validated                        IN     DATE,
    x_address1                              IN     VARCHAR2,
    x_address2                              IN     VARCHAR2,
    x_address3                              IN     VARCHAR2,
    x_address4                              IN     VARCHAR2,
    x_city                                  IN     VARCHAR2,
    x_postal_code                           IN     VARCHAR2,
    x_prov_state_admin_code                 IN     VARCHAR2,
    x_county                                IN     VARCHAR2,
    x_country                               IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_location_profile_id                   IN     NUMBER,
    x_location_id                           IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2,
    x_effective_start_date                  IN     DATE,
    x_effective_end_date                    IN     DATE,
    x_validation_sst_flag                   IN     VARCHAR2,
    x_validation_status_code                IN     VARCHAR2,
    x_date_validated                        IN     DATE,
    x_address1                              IN     VARCHAR2,
    x_address2                              IN     VARCHAR2,
    x_address3                              IN     VARCHAR2,
    x_address4                              IN     VARCHAR2,
    x_city                                  IN     VARCHAR2,
    x_postal_code                           IN     VARCHAR2,
    x_prov_state_admin_code                 IN     VARCHAR2,
    x_county                                IN     VARCHAR2,
    x_country                               IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_location_profile_id                   IN     NUMBER,
    x_location_id                           IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2,
    x_effective_start_date                  IN     DATE,
    x_effective_end_date                    IN     DATE,
    x_validation_sst_flag                   IN     VARCHAR2,
    x_validation_status_code                IN     VARCHAR2,
    x_date_validated                        IN     DATE,
    x_address1                              IN     VARCHAR2,
    x_address2                              IN     VARCHAR2,
    x_address3                              IN     VARCHAR2,
    x_address4                              IN     VARCHAR2,
    x_city                                  IN     VARCHAR2,
    x_postal_code                           IN     VARCHAR2,
    x_prov_state_admin_code                 IN     VARCHAR2,
    x_county                                IN     VARCHAR2,
    x_country                               IN     VARCHAR2,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER
  );

  PROCEDURE delete_row (x_location_profile_id IN NUMBER);

END hz_location_profiles_pkg;

 

/
