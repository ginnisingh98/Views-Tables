--------------------------------------------------------
--  DDL for Package HZ_GEO_STRUCTURE_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEO_STRUCTURE_LEVELS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHGSTTS.pls 120.1 2005/07/28 02:05:07 baianand noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN  NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_parent_geography_type                 IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_relationship_type_id                  IN     NUMBER,
    x_country_code                          IN     VARCHAR2,
    x_geography_element_column              IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER,
    x_addr_val_level                        IN     VARCHAR2
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_parent_geography_type                 IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_relationship_type_id                  IN     NUMBER,
    x_country_code                          IN     VARCHAR2,
    x_geography_element_column              IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_parent_geography_type                 IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_relationship_type_id                  IN     NUMBER,
    x_country_code                          IN     VARCHAR2,
    x_geography_element_column              IN     VARCHAR2,
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
    x_geography_type                        IN OUT    NOCOPY VARCHAR2,
    x_parent_geography_type                 IN OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_relationship_type_id                  OUT    NOCOPY NUMBER,
    x_country_code                          OUT    NOCOPY VARCHAR2,
    x_geography_element_column              OUT    NOCOPY VARCHAR2,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_program_login_id                      OUT    NOCOPY NUMBER
);

PROCEDURE Delete_Row (
    x_geography_id                          IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_parent_geography_type                 IN     VARCHAR2
);

END HZ_GEO_STRUCTURE_LEVELS_PKG;

 

/
