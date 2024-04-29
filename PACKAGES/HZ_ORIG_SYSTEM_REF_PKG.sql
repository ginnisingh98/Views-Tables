--------------------------------------------------------
--  DDL for Package HZ_ORIG_SYSTEM_REF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORIG_SYSTEM_REF_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHOSRTS.pls 120.1 2003/06/26 09:08:55 rpalanis noship $ */

PROCEDURE Insert_Row (
    x_orig_system_ref_id                    IN OUT NOCOPY NUMBER,
    x_orig_system                           IN     VARCHAR2,
    x_orig_system_reference                 IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id                        IN     NUMBER,
--raji
    x_party_id                              IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_reason_code                           IN     VARCHAR2,
    x_old_orig_system_reference              IN     VARCHAR2,
    x_start_date_active                     IN     DATE,
    x_end_date_active                       IN     DATE,
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
    x_orig_system_ref_id                    IN     NUMBER,
    x_orig_system                           IN     VARCHAR2,
    x_orig_system_reference                 IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id                        IN     NUMBER,
--raji
    x_party_id                              IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_reason_code                           IN     VARCHAR2,
    x_old_orig_system_reference              IN     VARCHAR2,
    x_start_date_active                     IN     DATE,
    x_end_date_active                       IN     DATE,
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
    x_orig_system_ref_id                    IN     NUMBER,
    x_orig_system                           IN     VARCHAR2,
    x_orig_system_reference                 IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id                        IN     NUMBER,
--raji
    x_party_id                              IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_reason_code                           IN     VARCHAR2,
    x_old_orig_system_reference              IN     VARCHAR2,
    x_start_date_active                     IN     DATE,
    x_end_date_active                       IN     DATE,
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
    x_orig_system_ref_id                    IN OUT NOCOPY NUMBER,
    x_orig_system                           OUT    NOCOPY VARCHAR2,
    x_orig_system_reference                 OUT    NOCOPY VARCHAR2,
    x_owner_table_name                      OUT    NOCOPY VARCHAR2,
    x_owner_table_id                        OUT    NOCOPY NUMBER,
--raji
    x_party_id                              OUT    NOCOPY NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_reason_code                           OUT    NOCOPY VARCHAR2,
    x_old_orig_system_reference              OUT    NOCOPY VARCHAR2,
    x_start_date_active                     OUT    NOCOPY DATE,
    x_end_date_active                       OUT    NOCOPY DATE,
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

PROCEDURE Delete_Row (
    x_orig_system_ref_id                    IN     NUMBER
);

END HZ_ORIG_SYSTEM_REF_PKG;

 

/
