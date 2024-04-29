--------------------------------------------------------
--  DDL for Package HZ_ADDRESS_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ADDRESS_USAGES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHGNRRS.pls 120.0 2005/07/28 02:17:13 baianand noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_usage_id                              IN OUT NOCOPY NUMBER,
    x_map_id                                IN     NUMBER,
    x_usage_code                            IN     VARCHAR2,
    x_status_flag                           IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_usage_id                              IN     NUMBER,
    x_map_id                                IN     NUMBER,
    x_usage_code                            IN     VARCHAR2,
    x_status_flag                           IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_usage_id                              IN     NUMBER,
    x_map_id                                IN     NUMBER,
    x_usage_code                            IN     VARCHAR2,
    x_status_flag                           IN     VARCHAR2,
    x_created_by                            IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER
);

PROCEDURE Select_Row (
    x_usage_id                              IN OUT NOCOPY NUMBER,
    x_map_id                                OUT    NOCOPY NUMBER,
    x_usage_code                            OUT    NOCOPY VARCHAR2,
    x_status_flag                           OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER
);

PROCEDURE Delete_Row (
    x_usage_id                              IN     NUMBER
);

END HZ_ADDRESS_USAGES_PKG;

 

/
