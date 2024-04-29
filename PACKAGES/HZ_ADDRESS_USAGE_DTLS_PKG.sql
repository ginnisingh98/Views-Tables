--------------------------------------------------------
--  DDL for Package HZ_ADDRESS_USAGE_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ADDRESS_USAGE_DTLS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHGNRTS.pls 120.0 2005/07/28 02:18:12 baianand noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_usage_dtl_id                          IN OUT NOCOPY NUMBER,
    x_usage_id                              IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_usage_dtl_id                          IN     NUMBER,
    x_usage_id                              IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_usage_dtl_id                          IN     NUMBER,
    x_usage_id                              IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
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
    x_usage_dtl_id                          IN OUT NOCOPY NUMBER,
    x_usage_id                              OUT    NOCOPY NUMBER,
    x_geography_type                        OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER
);

PROCEDURE Delete_Row (
    x_usage_dtl_id                          IN     NUMBER
);

END HZ_ADDRESS_USAGE_DTLS_PKG;

 

/
