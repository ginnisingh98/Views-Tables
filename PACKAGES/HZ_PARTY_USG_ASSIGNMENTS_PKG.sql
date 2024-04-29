--------------------------------------------------------
--  DDL for Package HZ_PARTY_USG_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_USG_ASSIGNMENTS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPUATS.pls 120.2 2006/02/28 21:59:46 jhuang noship $ */

PROCEDURE insert_row (
    x_party_id                    IN     NUMBER,
    x_party_usage_code            IN     VARCHAR2,
    x_effective_start_date        IN     DATE,
    x_effective_end_date          IN     DATE,
    x_status_flag                 IN     VARCHAR2,
    x_comments                    IN     VARCHAR2,
    x_owner_table_name            IN     VARCHAR2,
    x_owner_table_id              IN     NUMBER,
    x_attribute_category          IN     VARCHAR2,
    x_attribute1                  IN     VARCHAR2,
    x_attribute2                  IN     VARCHAR2,
    x_attribute3                  IN     VARCHAR2,
    x_attribute4                  IN     VARCHAR2,
    x_attribute5                  IN     VARCHAR2,
    x_attribute6                  IN     VARCHAR2,
    x_attribute7                  IN     VARCHAR2,
    x_attribute8                  IN     VARCHAR2,
    x_attribute9                  IN     VARCHAR2,
    x_attribute10                 IN     VARCHAR2,
    x_attribute11                 IN     VARCHAR2,
    x_attribute12                 IN     VARCHAR2,
    x_attribute13                 IN     VARCHAR2,
    x_attribute14                 IN     VARCHAR2,
    x_attribute15                 IN     VARCHAR2,
    x_attribute16                 IN     VARCHAR2,
    x_attribute17                 IN     VARCHAR2,
    x_attribute18                 IN     VARCHAR2,
    x_attribute19                 IN     VARCHAR2,
    x_attribute20                 IN     VARCHAR2,
    x_object_version_number       IN     NUMBER,
    x_created_by_module           IN     VARCHAR2,
    x_application_id              IN     NUMBER,
    x_party_usg_assignment_id     OUT    NOCOPY NUMBER
);


PROCEDURE update_row (
    x_party_usg_assignment_id     IN     NUMBER,
    x_party_id                    IN     NUMBER,
    x_party_usage_code            IN     VARCHAR2,
    x_effective_start_date        IN     DATE,
    x_effective_end_date          IN     DATE,
    x_status_flag                 IN     VARCHAR2,
    x_comments                    IN     VARCHAR2,
    x_owner_table_name            IN     VARCHAR2,
    x_owner_table_id              IN     NUMBER,
    x_attribute_category          IN     VARCHAR2,
    x_attribute1                  IN     VARCHAR2,
    x_attribute2                  IN     VARCHAR2,
    x_attribute3                  IN     VARCHAR2,
    x_attribute4                  IN     VARCHAR2,
    x_attribute5                  IN     VARCHAR2,
    x_attribute6                  IN     VARCHAR2,
    x_attribute7                  IN     VARCHAR2,
    x_attribute8                  IN     VARCHAR2,
    x_attribute9                  IN     VARCHAR2,
    x_attribute10                 IN     VARCHAR2,
    x_attribute11                 IN     VARCHAR2,
    x_attribute12                 IN     VARCHAR2,
    x_attribute13                 IN     VARCHAR2,
    x_attribute14                 IN     VARCHAR2,
    x_attribute15                 IN     VARCHAR2,
    x_attribute16                 IN     VARCHAR2,
    x_attribute17                 IN     VARCHAR2,
    x_attribute18                 IN     VARCHAR2,
    x_attribute19                 IN     VARCHAR2,
    x_attribute20                 IN     VARCHAR2,
    x_object_version_number       IN     NUMBER
);

END HZ_PARTY_USG_ASSIGNMENTS_PKG;

 

/
