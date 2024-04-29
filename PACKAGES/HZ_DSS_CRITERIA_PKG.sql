--------------------------------------------------------
--  DDL for Package HZ_DSS_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DSS_CRITERIA_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHPDSCS.pls 115.1 2002/09/30 06:23:42 cvijayan noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_secured_item_id                       IN OUT NOCOPY NUMBER,
    x_status                                IN     VARCHAR2,
    x_dss_group_code                        IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id1                       IN     VARCHAR2,
    x_owner_table_id2                       IN     VARCHAR2 DEFAULT NULL,
    x_owner_table_id3                       IN     VARCHAR2 DEFAULT NULL,
    x_owner_table_id4                       IN     VARCHAR2 DEFAULT NULL,
    x_owner_table_id5                       IN     VARCHAR2 DEFAULT NULL,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_dss_group_code                        IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id1                       IN     VARCHAR2,
    x_owner_table_id2                       IN     VARCHAR2 DEFAULT NULL,
    x_owner_table_id3                       IN     VARCHAR2 DEFAULT NULL,
    x_owner_table_id4                       IN     VARCHAR2 DEFAULT NULL,
    x_owner_table_id5                       IN     VARCHAR2 DEFAULT NULL,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_secured_item_id                       IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_dss_group_code                        IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id1                       IN     VARCHAR2,
    x_owner_table_id2                       IN     VARCHAR2 DEFAULT NULL,
    x_owner_table_id3                       IN     VARCHAR2 DEFAULT NULL,
    x_owner_table_id4                       IN     VARCHAR2 DEFAULT NULL,
    x_owner_table_id5                       IN     VARCHAR2 DEFAULT NULL,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Select_Row (
    x_secured_item_id                       IN OUT NOCOPY NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_dss_group_code                        OUT    NOCOPY VARCHAR2,
    x_owner_table_name                      OUT    NOCOPY VARCHAR2,
    x_owner_table_id1                       OUT    NOCOPY VARCHAR2,
    x_owner_table_id2                       OUT    NOCOPY VARCHAR2,
    x_owner_table_id3                       OUT    NOCOPY VARCHAR2,
    x_owner_table_id4                       OUT    NOCOPY VARCHAR2,
    x_owner_table_id5                       OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER
);

PROCEDURE Delete_Row (
    x_secured_item_id                       IN     NUMBER
);

END HZ_DSS_CRITERIA_PKG;

 

/
