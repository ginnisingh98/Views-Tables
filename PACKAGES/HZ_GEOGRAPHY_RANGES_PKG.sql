--------------------------------------------------------
--  DDL for Package HZ_GEOGRAPHY_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEOGRAPHY_RANGES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHGRGTS.pls 115.0 2003/02/01 02:51:49 rnalluri noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN  NUMBER,
    x_geography_from                        IN     VARCHAR2,
    x_start_date                            IN     DATE,
    x_object_version_number                 IN     NUMBER,
    x_geography_to                          IN     VARCHAR2,
    x_identifier_type                       IN     VARCHAR2,
    x_end_date                              IN     DATE,
    x_geography_type                        IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_master_ref_geography_id               IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN     NUMBER,
    x_geography_from                        IN     VARCHAR2,
    x_start_date                            IN     DATE,
    x_object_version_number                 IN     NUMBER,
    x_geography_to                          IN     VARCHAR2,
    x_identifier_type                       IN     VARCHAR2,
    x_end_date                              IN     DATE,
    x_geography_type                        IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_master_ref_geography_id               IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN     NUMBER,
    x_geography_from                        IN     VARCHAR2,
    x_start_date                            IN     DATE,
    x_object_version_number                 IN     NUMBER,
    x_geography_to                          IN     VARCHAR2,
    x_identifier_type                       IN     VARCHAR2,
    x_end_date                              IN     DATE,
    x_geography_type                        IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_master_ref_geography_id               IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_application_id                        IN     NUMBER,
    x_program_id                            IN     NUMBER,
    x_program_login_id                      IN     NUMBER,
    x_program_application_id                IN     NUMBER,
    x_request_id                            IN     NUMBER
);

PROCEDURE Select_Row (
    x_geography_id                          IN OUT NOCOPY NUMBER,
    x_geography_from                        IN OUT    NOCOPY VARCHAR2,
    x_start_date                            IN OUT    NOCOPY DATE,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_geography_to                          OUT    NOCOPY VARCHAR2,
    x_identifier_type                       OUT    NOCOPY VARCHAR2,
    x_end_date                              OUT    NOCOPY DATE,
    x_geography_type                        OUT    NOCOPY VARCHAR2,
    x_geography_use                         OUT    NOCOPY VARCHAR2,
    x_master_ref_geography_id               OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_program_login_id                      OUT    NOCOPY NUMBER
);

PROCEDURE Delete_Row (
    x_geography_id                          IN     NUMBER,
    x_geography_from                        IN     VARCHAR2,
    x_start_date                            IN     DATE
);

END HZ_GEOGRAPHY_RANGES_PKG;

 

/
