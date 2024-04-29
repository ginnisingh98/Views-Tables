--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_USG_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_USG_ASSIGNMENTS_PKG" AS
/*$Header: ARHPUATB.pls 120.2 2006/02/28 21:59:56 jhuang noship $ */

D_FUTURE_DATE                     CONSTANT DATE := TO_DATE('4712/12/31','YYYY/MM/DD');

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
) IS

BEGIN

    INSERT INTO HZ_PARTY_USG_ASSIGNMENTS (
      party_usg_assignment_id,
      party_id,
      party_usage_code,
      effective_start_date,
      effective_end_date,
      status_flag,
      comments,
      owner_table_name,
      owner_table_id,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      object_version_number,
      created_by_module,
      application_id,
      created_by,
      creation_date,
      last_update_login,
      last_update_date,
      last_updated_by,
      request_id,
      program_application_id,
      program_id,
      program_login_id
    )
    VALUES (
      hz_party_usg_assignments_s.nextval,
      x_party_id,
      x_party_usage_code,
      DECODE(x_effective_start_date,
             NULL, trunc(sysdate),
             FND_API.G_MISS_DATE, trunc(sysdate),
             trunc(x_effective_start_date)),
      DECODE(x_effective_end_date,
             NULL, D_FUTURE_DATE,
             FND_API.G_MISS_DATE, D_FUTURE_DATE,
             trunc(x_effective_end_date)),
      DECODE(x_status_flag,
             NULL, 'A',
             FND_API.G_MISS_CHAR, 'A',
             x_status_flag),
      DECODE(x_comments,
             FND_API.G_MISS_CHAR, NULL,
             x_comments),
      DECODE(x_owner_table_name,
             FND_API.G_MISS_CHAR, NULL,
             x_owner_table_name),
      DECODE(x_owner_table_id,
             FND_API.G_MISS_NUM, NULL,
             x_owner_table_id),
      DECODE(x_attribute_category,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute_category),
      DECODE(x_attribute1,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute1),
      DECODE(x_attribute2,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute2),
      DECODE(x_attribute3,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute3),
      DECODE(x_attribute4,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute4),
      DECODE(x_attribute5,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute5),
      DECODE(x_attribute6,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute6),
      DECODE(x_attribute7,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute7),
      DECODE(x_attribute8,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute8),
      DECODE(x_attribute9,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute9),
      DECODE(x_attribute10,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute10),
      DECODE(x_attribute11,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute11),
      DECODE(x_attribute12,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute12),
      DECODE(x_attribute13,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute13),
      DECODE(x_attribute14,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute14),
      DECODE(x_attribute15,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute15),
      DECODE(x_attribute16,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute16),
      DECODE(x_attribute17,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute17),
      DECODE(x_attribute18,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute18),
      DECODE(x_attribute19,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute19),
      DECODE(x_attribute20,
             FND_API.G_MISS_CHAR, NULL,
             x_attribute20),
      x_object_version_number,
      x_created_by_module,
      hz_utility_v2pub.application_id,
      hz_utility_v2pub.created_by,
      SYSDATE,
      hz_utility_v2pub.last_update_login,
      SYSDATE,
      hz_utility_v2pub.last_updated_by,
      hz_utility_v2pub.request_id,
      hz_utility_v2pub.program_application_id,
      hz_utility_v2pub.program_id,
      fnd_global.conc_login_id
    )
    RETURNING
      party_usg_assignment_id
    INTO
      x_party_usg_assignment_id;

END insert_row;


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
) IS

BEGIN

    UPDATE HZ_PARTY_USG_ASSIGNMENTS
    SET
      party_id =
        DECODE(x_party_id,
               NULL, party_id,
               x_party_id),
      party_usage_code =
        DECODE(x_party_usage_code,
               NULL, party_usage_code,
               x_party_usage_code),
      effective_start_date =
        DECODE(x_effective_start_date,
               NULL, effective_start_date,
               trunc(x_effective_start_date)),
      effective_end_date =
        DECODE(x_effective_end_date,
               NULL, effective_end_date,
               FND_API.G_MISS_DATE, D_FUTURE_DATE,
               trunc(x_effective_end_date)),
      status_flag =
        DECODE(x_status_flag,
               NULL, status_flag,
               x_status_flag),
      comments =
        DECODE(x_comments,
               NULL, comments,
               FND_API.G_MISS_CHAR, NULL,
               x_comments),
      owner_table_name =
        DECODE(x_owner_table_name,
               NULL, owner_table_name,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_name),
      owner_table_id =
        DECODE(x_owner_table_id,
               NULL, owner_table_id,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_id),
      attribute_category =
        DECODE(x_attribute_category,
               NULL, attribute_category,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute_category),
      attribute1 =
        DECODE(x_attribute1,
               NULL, attribute1,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute1),
      attribute2 =
        DECODE(x_attribute2,
               NULL, attribute2,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute2),
      attribute3 =
        DECODE(x_attribute3,
               NULL, attribute3,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute3),
      attribute4 =
        DECODE(x_attribute4,
               NULL, attribute4,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute4),
      attribute5 =
        DECODE(x_attribute5,
               NULL, attribute5,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute5),
      attribute6 =
        DECODE(x_attribute6,
               NULL, attribute6,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute6),
      attribute7 =
        DECODE(x_attribute7,
               NULL, attribute7,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute7),
      attribute8 =
        DECODE(x_attribute8,
               NULL, attribute8,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute8),
      attribute9 =
        DECODE(x_attribute9,
               NULL, attribute9,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute9),
      attribute10 =
        DECODE(x_attribute10,
               NULL, attribute10,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute10),
      attribute11 =
        DECODE(x_attribute11,
               NULL, attribute11,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute11),
      attribute12 =
        DECODE(x_attribute12,
               NULL, attribute12,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute12),
      attribute13 =
        DECODE(x_attribute13,
               NULL, attribute13,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute13),
      attribute14 =
        DECODE(x_attribute14,
               NULL, attribute14,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute14),
      attribute15 =
        DECODE(x_attribute15,
               NULL, attribute15,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute15),
      attribute16 =
        DECODE(x_attribute16,
               NULL, attribute16,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute16),
      attribute17 =
        DECODE(x_attribute17,
               NULL, attribute17,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute17),
      attribute18 =
        DECODE(x_attribute18,
               NULL, attribute18,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute18),
      attribute19 =
        DECODE(x_attribute19,
               NULL, attribute19,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute19),
      attribute20 =
        DECODE(x_attribute20,
               NULL, attribute20,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute20),
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               x_object_version_number),
      last_update_login = hz_utility_v2pub.last_update_login,
      last_update_date = SYSDATE,
      last_updated_by = hz_utility_v2pub.last_updated_by,
      request_id = hz_utility_v2pub.request_id,
      program_application_id = hz_utility_v2pub.program_application_id,
      program_id = hz_utility_v2pub.program_id,
      program_login_id = fnd_global.conc_login_id,
      application_id =
        NVL(application_id, hz_utility_v2pub.application_id)
    WHERE party_usg_assignment_id = x_party_usg_assignment_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END update_row;


END HZ_PARTY_USG_ASSIGNMENTS_PKG;

/
