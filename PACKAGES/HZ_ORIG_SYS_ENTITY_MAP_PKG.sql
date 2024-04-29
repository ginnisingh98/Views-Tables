--------------------------------------------------------
--  DDL for Package HZ_ORIG_SYS_ENTITY_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORIG_SYS_ENTITY_MAP_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHOSSTS.pls 120.1 2003/06/26 09:04:24 rpalanis noship $ */

PROCEDURE Insert_Row (
    x_orig_system                           IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_multiple_flag                         IN     VARCHAR2,
--raji
    x_multi_osr_flag                        IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_attribute_category                    IN     VARCHAR2,
    x_attribute1                            IN     VARCHAR2,
    x_attribute2                            IN     VARCHAR2,
    x_attribute3                            IN     VARCHAR2,
    x_attribute4                            IN     VARCHAR2,
    x_attribute5                            IN     VARCHAR2,
    x_attribute6                            IN     VARCHAR2,
    x_attribute7                            IN     VARCHAR2,
    x_attribute8                            IN     VARCHAR2,
    x_attribute9                            IN     VARCHAR2,
    x_attribute10                           IN     VARCHAR2,
    x_attribute11                           IN     VARCHAR2,
    x_attribute12                           IN     VARCHAR2,
    x_attribute13                           IN     VARCHAR2,
    x_attribute14                           IN     VARCHAR2,
    x_attribute15                           IN     VARCHAR2,
    x_attribute16                           IN     VARCHAR2,
    x_attribute17                           IN     VARCHAR2,
    x_attribute18                           IN     VARCHAR2,
    x_attribute19                           IN     VARCHAR2,
    x_attribute20                           IN     VARCHAR2
);

PROCEDURE Update_Row (
    x_orig_system                           IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_multiple_flag                         IN     VARCHAR2,
--raji
    x_multi_osr_flag                        IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_attribute_category                    IN     VARCHAR2,
    x_attribute1                            IN     VARCHAR2,
    x_attribute2                            IN     VARCHAR2,
    x_attribute3                            IN     VARCHAR2,
    x_attribute4                            IN     VARCHAR2,
    x_attribute5                            IN     VARCHAR2,
    x_attribute6                            IN     VARCHAR2,
    x_attribute7                            IN     VARCHAR2,
    x_attribute8                            IN     VARCHAR2,
    x_attribute9                            IN     VARCHAR2,
    x_attribute10                           IN     VARCHAR2,
    x_attribute11                           IN     VARCHAR2,
    x_attribute12                           IN     VARCHAR2,
    x_attribute13                           IN     VARCHAR2,
    x_attribute14                           IN     VARCHAR2,
    x_attribute15                           IN     VARCHAR2,
    x_attribute16                           IN     VARCHAR2,
    x_attribute17                           IN     VARCHAR2,
    x_attribute18                           IN     VARCHAR2,
    x_attribute19                           IN     VARCHAR2,
    x_attribute20                           IN     VARCHAR2
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_orig_system	                    IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_multiple_flag                         IN     VARCHAR2,
--raji
    x_multi_osr_flag                        IN     VARCHAR2,
    x_created_by                            IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_attribute_category                    IN     VARCHAR2,
    x_attribute1                            IN     VARCHAR2,
    x_attribute2                            IN     VARCHAR2,
    x_attribute3                            IN     VARCHAR2,
    x_attribute4                            IN     VARCHAR2,
    x_attribute5                            IN     VARCHAR2,
    x_attribute6                            IN     VARCHAR2,
    x_attribute7                            IN     VARCHAR2,
    x_attribute8                            IN     VARCHAR2,
    x_attribute9                            IN     VARCHAR2,
    x_attribute10                           IN     VARCHAR2,
    x_attribute11                           IN     VARCHAR2,
    x_attribute12                           IN     VARCHAR2,
    x_attribute13                           IN     VARCHAR2,
    x_attribute14                           IN     VARCHAR2,
    x_attribute15                           IN     VARCHAR2,
    x_attribute16                           IN     VARCHAR2,
    x_attribute17                           IN     VARCHAR2,
    x_attribute18                           IN     VARCHAR2,
    x_attribute19                           IN     VARCHAR2,
    x_attribute20                           IN     VARCHAR2
);

PROCEDURE Select_Row (
    x_orig_system                           IN OUT    NOCOPY VARCHAR2,
    x_owner_table_name                      IN OUT    NOCOPY VARCHAR2,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_multiple_flag                         OUT    NOCOPY VARCHAR2,
--raji
    x_multi_osr_flag                        OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_attribute_category                    OUT    NOCOPY VARCHAR2,
    x_attribute1                            OUT    NOCOPY VARCHAR2,
    x_attribute2                            OUT    NOCOPY VARCHAR2,
    x_attribute3                            OUT    NOCOPY VARCHAR2,
    x_attribute4                            OUT    NOCOPY VARCHAR2,
    x_attribute5                            OUT    NOCOPY VARCHAR2,
    x_attribute6                            OUT    NOCOPY VARCHAR2,
    x_attribute7                            OUT    NOCOPY VARCHAR2,
    x_attribute8                            OUT    NOCOPY VARCHAR2,
    x_attribute9                            OUT    NOCOPY VARCHAR2,
    x_attribute10                           OUT    NOCOPY VARCHAR2,
    x_attribute11                           OUT    NOCOPY VARCHAR2,
    x_attribute12                           OUT    NOCOPY VARCHAR2,
    x_attribute13                           OUT    NOCOPY VARCHAR2,
    x_attribute14                           OUT    NOCOPY VARCHAR2,
    x_attribute15                           OUT    NOCOPY VARCHAR2,
    x_attribute16                           OUT    NOCOPY VARCHAR2,
    x_attribute17                           OUT    NOCOPY VARCHAR2,
    x_attribute18                           OUT    NOCOPY VARCHAR2,
    x_attribute19                           OUT    NOCOPY VARCHAR2,
    x_attribute20                           OUT    NOCOPY VARCHAR2
);

END HZ_ORIG_SYS_ENTITY_MAP_PKG;

 

/
