--------------------------------------------------------
--  DDL for Package Body HZ_GEOGRAPHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEOGRAPHIES_PKG" AS
/*$Header: ARHGEOTB.pls 120.1 2005/10/25 22:33:22 nsinghai noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN OUT NOCOPY NUMBER,
    x_object_version_number                 IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_geography_name                        IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_geography_code                        IN     VARCHAR2,
    x_start_date                            IN     DATE,
    x_end_date                              IN     DATE,
    x_multiple_parent_flag                  IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_country_code                          IN     VARCHAR2,
    x_geography_element1                    IN     VARCHAR2,
    x_geography_element1_id                 IN     NUMBER,
    x_geography_element1_code               IN     VARCHAR2,
    x_geography_element2                    IN     VARCHAR2,
    x_geography_element2_id                 IN     NUMBER,
    x_geography_element2_code               IN     VARCHAR2,
    x_geography_element3                    IN     VARCHAR2,
    x_geography_element3_id                 IN     NUMBER,
    x_geography_element3_code               IN     VARCHAR2,
    x_geography_element4                    IN     VARCHAR2,
    x_geography_element4_id                 IN     NUMBER,
    x_geography_element4_code               IN     VARCHAR2,
    x_geography_element5                    IN     VARCHAR2,
    x_geography_element5_id                 IN     NUMBER,
    x_geography_element5_code               IN     VARCHAR2,
    x_geography_element6                    IN     VARCHAR2,
    x_geography_element6_id                 IN     NUMBER,
    x_geography_element7                    IN     VARCHAR2,
    x_geography_element7_id                 IN     NUMBER,
    x_geography_element8                    IN     VARCHAR2,
    x_geography_element8_id                 IN     NUMBER,
    x_geography_element9                    IN     VARCHAR2,
    x_geography_element9_id                 IN     NUMBER,
    x_geography_element10                   IN     VARCHAR2,
    x_geography_element10_id                IN     NUMBER,
    x_geometry                              IN     MDSYS.SDO_GEOMETRY,
    x_timezone_code                         IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER,
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
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

   --dbms_output.put_line.PUT_LINE('Before Insert');
    WHILE l_success = 'N' LOOP
    BEGIN
      INSERT INTO HZ_GEOGRAPHIES (
        geography_id,
        object_version_number,
        geography_type,
        geography_name,
        geography_use,
        geography_code,
        start_date,
        end_date,
        multiple_parent_flag,
        created_by_module,
        country_code,
        geography_element1,
        geography_element1_id,
        geography_element1_code,
        geography_element2,
        geography_element2_id,
        geography_element2_code,
        geography_element3,
        geography_element3_id,
        geography_element3_code,
        geography_element4,
        geography_element4_id,
        geography_element4_code,
        geography_element5,
        geography_element5_id,
        geography_element5_code,
        geography_element6,
        geography_element6_id,
        geography_element7,
        geography_element7_id,
        geography_element8,
        geography_element8_id,
        geography_element9,
        geography_element9_id,
        geography_element10,
        geography_element10_id,
        geometry,
        timezone_code,
        last_updated_by,
        creation_date,
        created_by,
        last_update_date,
        last_update_login,
        application_id,
        program_id,
        program_login_id,
        program_application_id,
        request_id,
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
        attribute20
      )
      VALUES (
        DECODE(x_geography_id,
               FND_API.G_MISS_NUM, HZ_GEOGRAPHIES_S.NEXTVAL,
               NULL, HZ_GEOGRAPHIES_S.NEXTVAL,
               x_geography_id),
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
        DECODE(x_geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
        DECODE(x_geography_name,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_name),
        DECODE(x_geography_use,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_use),
        DECODE(x_geography_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_code),
        DECODE(x_start_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_start_date),
        DECODE(x_end_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_end_date),
        DECODE(x_multiple_parent_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_multiple_parent_flag),
        DECODE(x_created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
        DECODE(x_country_code,
               FND_API.G_MISS_CHAR, NULL,
               x_country_code),
        DECODE(x_geography_element1,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element1),
        DECODE(x_geography_element1_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element1_id),
        DECODE(x_geography_element1_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element1_code),
        DECODE(x_geography_element2,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element2),
        DECODE(x_geography_element2_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element2_id),
        DECODE(x_geography_element2_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element2_code),
        DECODE(x_geography_element3,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element3),
        DECODE(x_geography_element3_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element3_id),
        DECODE(x_geography_element3_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element3_code),
        DECODE(x_geography_element4,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element4),
        DECODE(x_geography_element4_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element4_id),
        DECODE(x_geography_element4_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element4_code),
        DECODE(x_geography_element5,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element5),
        DECODE(x_geography_element5_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element5_id),
        DECODE(x_geography_element5_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element5_code),
        DECODE(x_geography_element6,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element6),
        DECODE(x_geography_element6_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element6_id),
        DECODE(x_geography_element7,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element7),
        DECODE(x_geography_element7_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element7_id),
        DECODE(x_geography_element8,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element8),
        DECODE(x_geography_element8_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element8_id),
        DECODE(x_geography_element9,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element9),
        DECODE(x_geography_element9_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element9_id),
        DECODE(x_geography_element10,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element10),
        DECODE(x_geography_element10_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element10_id),
        x_geometry,
        DECODE(x_timezone_code,
               FND_API.G_MISS_CHAR, NULL,
               x_timezone_code),
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_update_login,
        DECODE(x_application_id,
               FND_API.G_MISS_NUM, NULL,
               x_application_id),
        hz_utility_v2pub.program_id,
        DECODE(x_program_login_id,
               FND_API.G_MISS_NUM, NULL,
               x_program_login_id),
        hz_utility_v2pub.program_application_id,
        hz_utility_v2pub.request_id,
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
               x_attribute20)
      ) RETURNING
        rowid,
        geography_id
      INTO
        x_rowid,
        x_geography_id;

      l_success := 'Y';

      --dbms_output.put_line.PUT_LINE('l_success in after insert '||l_success);

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        IF INSTR(SQLERRM, 'HZ_GEOGRAPHIES_S') <> 0 THEN
        DECLARE
          l_count             NUMBER;
          l_dummy             VARCHAR2(1);
        BEGIN
          l_count := 1;
          WHILE l_count > 0 LOOP
            SELECT HZ_GEOGRAPHIES_S.NEXTVAL
            INTO x_geography_id FROM dual;
            BEGIN
              SELECT 'Y' INTO l_dummy
              FROM HZ_GEOGRAPHIES
              WHERE geography_id = x_geography_id;
              l_count := 1;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_count := 0;
            END;
          END LOOP;
        END;
        END IF;

    END;
    END LOOP;

END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN     NUMBER,
    x_object_version_number                 IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_geography_name                        IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_geography_code                        IN     VARCHAR2,
    x_start_date                            IN     DATE,
    x_end_date                              IN     DATE,
    x_multiple_parent_flag                  IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_country_code                          IN     VARCHAR2,
    x_geography_element1                    IN     VARCHAR2,
    x_geography_element1_id                 IN     NUMBER,
    x_geography_element1_code               IN     VARCHAR2,
    x_geography_element2                    IN     VARCHAR2,
    x_geography_element2_id                 IN     NUMBER,
    x_geography_element2_code               IN     VARCHAR2,
    x_geography_element3                    IN     VARCHAR2,
    x_geography_element3_id                 IN     NUMBER,
    x_geography_element3_code               IN     VARCHAR2,
    x_geography_element4                    IN     VARCHAR2,
    x_geography_element4_id                 IN     NUMBER,
    x_geography_element4_code               IN     VARCHAR2,
    x_geography_element5                    IN     VARCHAR2,
    x_geography_element5_id                 IN     NUMBER,
    x_geography_element5_code               IN     VARCHAR2,
    x_geography_element6                    IN     VARCHAR2,
    x_geography_element6_id                 IN     NUMBER,
    x_geography_element7                    IN     VARCHAR2,
    x_geography_element7_id                 IN     NUMBER,
    x_geography_element8                    IN     VARCHAR2,
    x_geography_element8_id                 IN     NUMBER,
    x_geography_element9                    IN     VARCHAR2,
    x_geography_element9_id                 IN     NUMBER,
    x_geography_element10                   IN     VARCHAR2,
    x_geography_element10_id                IN     NUMBER,
    x_geometry                              IN     MDSYS.SDO_GEOMETRY,
    x_timezone_code                         IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER,
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
) IS
BEGIN

    UPDATE HZ_GEOGRAPHIES
    SET
      geography_id =
        DECODE(x_geography_id,
               NULL, geography_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_id),
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
      geography_type =
        DECODE(x_geography_type,
               NULL, geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
      geography_name =
        DECODE(x_geography_name,
               NULL, geography_name,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_name),
      geography_use =
        DECODE(x_geography_use,
               NULL, geography_use,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_use),
      geography_code =
        DECODE(x_geography_code,
               NULL, geography_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_code),
      start_date =
        DECODE(x_start_date,
               NULL, start_date,
               FND_API.G_MISS_DATE, NULL,
               x_start_date),
      end_date =
        DECODE(x_end_date,
               NULL, end_date,
               FND_API.G_MISS_DATE, NULL,
               x_end_date),
      multiple_parent_flag =
        DECODE(x_multiple_parent_flag,
               NULL, multiple_parent_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_multiple_parent_flag),
      created_by_module =
        DECODE(x_created_by_module,
               NULL, created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
      country_code =
        DECODE(x_country_code,
               NULL, country_code,
               FND_API.G_MISS_CHAR, NULL,
               x_country_code),
      geography_element1 =
        DECODE(x_geography_element1,
               NULL, geography_element1,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element1),
      geography_element1_id =
        DECODE(x_geography_element1_id,
               NULL, geography_element1_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element1_id),
      geography_element1_code =
        DECODE(x_geography_element1_code,
               NULL, geography_element1_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element1_code),
      geography_element2 =
        DECODE(x_geography_element2,
               NULL, geography_element2,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element2),
      geography_element2_id =
        DECODE(x_geography_element2_id,
               NULL, geography_element2_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element2_id),
      geography_element2_code =
        DECODE(x_geography_element2_code,
               NULL, geography_element2_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element2_code),
      geography_element3 =
        DECODE(x_geography_element3,
               NULL, geography_element3,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element3),
      geography_element3_id =
        DECODE(x_geography_element3_id,
               NULL, geography_element3_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element3_id),
      geography_element3_code =
        DECODE(x_geography_element3_code,
               NULL, geography_element3_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element3_code),
      geography_element4 =
        DECODE(x_geography_element4,
               NULL, geography_element4,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element4),
      geography_element4_id =
        DECODE(x_geography_element4_id,
               NULL, geography_element4_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element4_id),
      geography_element4_code =
        DECODE(x_geography_element4_code,
               NULL, geography_element4_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element4_code),
      geography_element5 =
        DECODE(x_geography_element5,
               NULL, geography_element5,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element5),
      geography_element5_id =
        DECODE(x_geography_element5_id,
               NULL, geography_element5_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element5_id),
      geography_element5_code =
        DECODE(x_geography_element5_code,
               NULL, geography_element5_code,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element5_code),
      geography_element6 =
        DECODE(x_geography_element6,
               NULL, geography_element6,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element6),
      geography_element6_id =
        DECODE(x_geography_element6_id,
               NULL, geography_element6_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element6_id),
      geography_element7 =
        DECODE(x_geography_element7,
               NULL, geography_element7,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element7),
      geography_element7_id =
        DECODE(x_geography_element7_id,
               NULL, geography_element7_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element7_id),
      geography_element8 =
        DECODE(x_geography_element8,
               NULL, geography_element8,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element8),
      geography_element8_id =
        DECODE(x_geography_element8_id,
               NULL, geography_element8_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element8_id),
      geography_element9 =
        DECODE(x_geography_element9,
               NULL, geography_element9,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element9),
      geography_element9_id =
        DECODE(x_geography_element9_id,
               NULL, geography_element9_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element9_id),
      geography_element10 =
        DECODE(x_geography_element10,
               NULL, geography_element10,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element10),
      geography_element10_id =
        DECODE(x_geography_element10_id,
               NULL, geography_element10_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_element10_id),
      geometry = geometry,
      timezone_code =
        DECODE(x_timezone_code,
               NULL, timezone_code,
               FND_API.G_MISS_CHAR, NULL,
               x_timezone_code),
      last_updated_by = hz_utility_v2pub.last_updated_by,
      creation_date = creation_date,
      created_by = created_by,
      last_update_date = hz_utility_v2pub.last_update_date,
      last_update_login = hz_utility_v2pub.last_update_login,
      application_id =
        DECODE(x_application_id,
               NULL, application_id,
               FND_API.G_MISS_NUM, NULL,
               x_application_id),
      program_id = hz_utility_v2pub.program_id,
      program_login_id =
        DECODE(x_program_login_id,
               NULL, program_login_id,
               FND_API.G_MISS_NUM, NULL,
               x_program_login_id),
      program_application_id = hz_utility_v2pub.program_application_id,
      request_id = hz_utility_v2pub.request_id,
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
               x_attribute20)
    WHERE rowid = x_rowid;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

/*PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN     NUMBER,
    x_object_version_number                 IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_geography_name                        IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_geography_code                        IN     VARCHAR2,
    x_start_date                            IN     DATE,
    x_end_date                              IN     DATE,
    x_multiple_parent_flag                  IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_country_code                          IN     VARCHAR2,
    x_geography_element1                    IN     VARCHAR2,
    x_geography_element1_id                 IN     NUMBER,
    x_geography_element1_code               IN     VARCHAR2,
    x_geography_element2                    IN     VARCHAR2,
    x_geography_element2_id                 IN     NUMBER,
    x_geography_element2_code               IN     VARCHAR2,
    x_geography_element3                    IN     VARCHAR2,
    x_geography_element3_id                 IN     NUMBER,
    x_geography_element3_code               IN     VARCHAR2,
    x_geography_element4                    IN     VARCHAR2,
    x_geography_element4_id                 IN     NUMBER,
    x_geography_element4_code               IN     VARCHAR2,
    x_geography_element5                    IN     VARCHAR2,
    x_geography_element5_id                 IN     NUMBER,
    x_geography_element5_code               IN     VARCHAR2,
    x_geography_element6                    IN     VARCHAR2,
    x_geography_element6_id                 IN     NUMBER,
    x_geography_element7                    IN     VARCHAR2,
    x_geography_element7_id                 IN     NUMBER,
    x_geography_element8                    IN     VARCHAR2,
    x_geography_element8_id                 IN     NUMBER,
    x_geography_element9                    IN     VARCHAR2,
    x_geography_element9_id                 IN     NUMBER,
    x_geography_element10                   IN     VARCHAR2,
    x_geography_element10_id                IN     NUMBER,
    x_geometry                              IN     MDSYS.SDO_GEOMETRY,
    x_timezone_code                         IN     VARCHAR2,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_application_id                        IN     NUMBER,
    x_program_id                            IN     NUMBER,
    x_program_login_id                      IN     NUMBER,
    x_program_application_id                IN     NUMBER,
    x_request_id                            IN     NUMBER,
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
) IS

    CURSOR c IS
      SELECT * FROM hz_geographies
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;
    Recinfo c%ROWTYPE;

BEGIN

    OPEN c;
    FETCH c INTO Recinfo;
    IF ( c%NOTFOUND ) THEN
      CLOSE c;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

    IF (
        ( ( Recinfo.geography_id = x_geography_id )
        OR ( ( Recinfo.geography_id IS NULL )
          AND (  x_geography_id IS NULL ) ) )
    AND ( ( Recinfo.object_version_number = x_object_version_number )
        OR ( ( Recinfo.object_version_number IS NULL )
          AND (  x_object_version_number IS NULL ) ) )
    AND ( ( Recinfo.geography_type = x_geography_type )
        OR ( ( Recinfo.geography_type IS NULL )
          AND (  x_geography_type IS NULL ) ) )
    AND ( ( Recinfo.geography_name = x_geography_name )
        OR ( ( Recinfo.geography_name IS NULL )
          AND (  x_geography_name IS NULL ) ) )
    AND ( ( Recinfo.geography_use = x_geography_use )
        OR ( ( Recinfo.geography_use IS NULL )
          AND (  x_geography_use IS NULL ) ) )
    AND ( ( Recinfo.geography_code = x_geography_code )
        OR ( ( Recinfo.geography_code IS NULL )
          AND (  x_geography_code IS NULL ) ) )
    AND ( ( Recinfo.start_date = x_start_date )
        OR ( ( Recinfo.start_date IS NULL )
          AND (  x_start_date IS NULL ) ) )
    AND ( ( Recinfo.end_date = x_end_date )
        OR ( ( Recinfo.end_date IS NULL )
          AND (  x_end_date IS NULL ) ) )
    AND ( ( Recinfo.multiple_parent_flag = x_multiple_parent_flag )
        OR ( ( Recinfo.multiple_parent_flag IS NULL )
          AND (  x_multiple_parent_flag IS NULL ) ) )
    AND ( ( Recinfo.created_by_module = x_created_by_module )
        OR ( ( Recinfo.created_by_module IS NULL )
          AND (  x_created_by_module IS NULL ) ) )
    AND ( ( Recinfo.country_code = x_country_code )
        OR ( ( Recinfo.country_code IS NULL )
          AND (  x_country_code IS NULL ) ) )
    AND ( ( Recinfo.geography_element1 = x_geography_element1 )
        OR ( ( Recinfo.geography_element1 IS NULL )
          AND (  x_geography_element1 IS NULL ) ) )
    AND ( ( Recinfo.geography_element1_id = x_geography_element1_id )
        OR ( ( Recinfo.geography_element1_id IS NULL )
          AND (  x_geography_element1_id IS NULL ) ) )
    AND ( ( Recinfo.geography_element1_code = x_geography_element1_code )
        OR ( ( Recinfo.geography_element1_code IS NULL )
          AND (  x_geography_element1_code IS NULL ) ) )
    AND ( ( Recinfo.geography_element2 = x_geography_element2 )
        OR ( ( Recinfo.geography_element2 IS NULL )
          AND (  x_geography_element2 IS NULL ) ) )
    AND ( ( Recinfo.geography_element2_id = x_geography_element2_id )
        OR ( ( Recinfo.geography_element2_id IS NULL )
          AND (  x_geography_element2_id IS NULL ) ) )
    AND ( ( Recinfo.geography_element2_code = x_geography_element2_code )
        OR ( ( Recinfo.geography_element2_code IS NULL )
          AND (  x_geography_element2_code IS NULL ) ) )
    AND ( ( Recinfo.geography_element3 = x_geography_element3 )
        OR ( ( Recinfo.geography_element3 IS NULL )
          AND (  x_geography_element3 IS NULL ) ) )
    AND ( ( Recinfo.geography_element3_id = x_geography_element3_id )
        OR ( ( Recinfo.geography_element3_id IS NULL )
          AND (  x_geography_element3_id IS NULL ) ) )
    AND ( ( Recinfo.geography_element3_code = x_geography_element3_code )
        OR ( ( Recinfo.geography_element3_code IS NULL )
          AND (  x_geography_element3_code IS NULL ) ) )
    AND ( ( Recinfo.geography_element4 = x_geography_element4 )
        OR ( ( Recinfo.geography_element4 IS NULL )
          AND (  x_geography_element4 IS NULL ) ) )
    AND ( ( Recinfo.geography_element4_id = x_geography_element4_id )
        OR ( ( Recinfo.geography_element4_id IS NULL )
          AND (  x_geography_element4_id IS NULL ) ) )
    AND ( ( Recinfo.geography_element4_code = x_geography_element4_code )
        OR ( ( Recinfo.geography_element4_code IS NULL )
          AND (  x_geography_element4_code IS NULL ) ) )
    AND ( ( Recinfo.geography_element5 = x_geography_element5 )
        OR ( ( Recinfo.geography_element5 IS NULL )
          AND (  x_geography_element5 IS NULL ) ) )
    AND ( ( Recinfo.geography_element5_id = x_geography_element5_id )
        OR ( ( Recinfo.geography_element5_id IS NULL )
          AND (  x_geography_element5_id IS NULL ) ) )
    AND ( ( Recinfo.geography_element5_code = x_geography_element5_code )
        OR ( ( Recinfo.geography_element5_code IS NULL )
          AND (  x_geography_element5_code IS NULL ) ) )
    AND ( ( Recinfo.geography_element6 = x_geography_element6 )
        OR ( ( Recinfo.geography_element6 IS NULL )
          AND (  x_geography_element6 IS NULL ) ) )
    AND ( ( Recinfo.geography_element6_id = x_geography_element6_id )
        OR ( ( Recinfo.geography_element6_id IS NULL )
          AND (  x_geography_element6_id IS NULL ) ) )
    AND ( ( Recinfo.geography_element7 = x_geography_element7 )
        OR ( ( Recinfo.geography_element7 IS NULL )
          AND (  x_geography_element7 IS NULL ) ) )
    AND ( ( Recinfo.geography_element7_id = x_geography_element7_id )
        OR ( ( Recinfo.geography_element7_id IS NULL )
          AND (  x_geography_element7_id IS NULL ) ) )
    AND ( ( Recinfo.geography_element8 = x_geography_element8 )
        OR ( ( Recinfo.geography_element8 IS NULL )
          AND (  x_geography_element8 IS NULL ) ) )
    AND ( ( Recinfo.geography_element8_id = x_geography_element8_id )
        OR ( ( Recinfo.geography_element8_id IS NULL )
          AND (  x_geography_element8_id IS NULL ) ) )
    AND ( ( Recinfo.geography_element9 = x_geography_element9 )
        OR ( ( Recinfo.geography_element9 IS NULL )
          AND (  x_geography_element9 IS NULL ) ) )
    AND ( ( Recinfo.geography_element9_id = x_geography_element9_id )
        OR ( ( Recinfo.geography_element9_id IS NULL )
          AND (  x_geography_element9_id IS NULL ) ) )
    AND ( ( Recinfo.geography_element10 = x_geography_element10 )
        OR ( ( Recinfo.geography_element10 IS NULL )
          AND (  x_geography_element10 IS NULL ) ) )
    AND ( ( Recinfo.geography_element10_id = x_geography_element10_id )
        OR ( ( Recinfo.geography_element10_id IS NULL )
          AND (  x_geography_element10_id IS NULL ) ) )
    AND ( ( Recinfo.geometry = x_geometry )
        OR ( ( Recinfo.geometry IS NULL )
          AND (  x_geometry IS NULL ) ) )
    AND ( ( Recinfo.timezone_code = x_timezone_code )
        OR ( ( Recinfo.timezone_code IS NULL )
          AND (  x_timezone_code IS NULL ) ) )
    AND ( ( Recinfo.last_updated_by = x_last_updated_by )
        OR ( ( Recinfo.last_updated_by IS NULL )
          AND (  x_last_updated_by IS NULL ) ) )
    AND ( ( Recinfo.creation_date = x_creation_date )
        OR ( ( Recinfo.creation_date IS NULL )
          AND (  x_creation_date IS NULL ) ) )
    AND ( ( Recinfo.created_by = x_created_by )
        OR ( ( Recinfo.created_by IS NULL )
          AND (  x_created_by IS NULL ) ) )
    AND ( ( Recinfo.last_update_date = x_last_update_date )
        OR ( ( Recinfo.last_update_date IS NULL )
          AND (  x_last_update_date IS NULL ) ) )
    AND ( ( Recinfo.last_update_login = x_last_update_login )
        OR ( ( Recinfo.last_update_login IS NULL )
          AND (  x_last_update_login IS NULL ) ) )
    AND ( ( Recinfo.application_id = x_application_id )
        OR ( ( Recinfo.application_id IS NULL )
          AND (  x_application_id IS NULL ) ) )
    AND ( ( Recinfo.program_id = x_program_id )
        OR ( ( Recinfo.program_id IS NULL )
          AND (  x_program_id IS NULL ) ) )
    AND ( ( Recinfo.program_login_id = x_program_login_id )
        OR ( ( Recinfo.program_login_id IS NULL )
          AND (  x_program_login_id IS NULL ) ) )
    AND ( ( Recinfo.program_application_id = x_program_application_id )
        OR ( ( Recinfo.program_application_id IS NULL )
          AND (  x_program_application_id IS NULL ) ) )
    AND ( ( Recinfo.request_id = x_request_id )
        OR ( ( Recinfo.request_id IS NULL )
          AND (  x_request_id IS NULL ) ) )
    AND ( ( Recinfo.attribute_category = x_attribute_category )
        OR ( ( Recinfo.attribute_category IS NULL )
          AND (  x_attribute_category IS NULL ) ) )
    AND ( ( Recinfo.attribute1 = x_attribute1 )
        OR ( ( Recinfo.attribute1 IS NULL )
          AND (  x_attribute1 IS NULL ) ) )
    AND ( ( Recinfo.attribute2 = x_attribute2 )
        OR ( ( Recinfo.attribute2 IS NULL )
          AND (  x_attribute2 IS NULL ) ) )
    AND ( ( Recinfo.attribute3 = x_attribute3 )
        OR ( ( Recinfo.attribute3 IS NULL )
          AND (  x_attribute3 IS NULL ) ) )
    AND ( ( Recinfo.attribute4 = x_attribute4 )
        OR ( ( Recinfo.attribute4 IS NULL )
          AND (  x_attribute4 IS NULL ) ) )
    AND ( ( Recinfo.attribute5 = x_attribute5 )
        OR ( ( Recinfo.attribute5 IS NULL )
          AND (  x_attribute5 IS NULL ) ) )
    AND ( ( Recinfo.attribute6 = x_attribute6 )
        OR ( ( Recinfo.attribute6 IS NULL )
          AND (  x_attribute6 IS NULL ) ) )
    AND ( ( Recinfo.attribute7 = x_attribute7 )
        OR ( ( Recinfo.attribute7 IS NULL )
          AND (  x_attribute7 IS NULL ) ) )
    AND ( ( Recinfo.attribute8 = x_attribute8 )
        OR ( ( Recinfo.attribute8 IS NULL )
          AND (  x_attribute8 IS NULL ) ) )
    AND ( ( Recinfo.attribute9 = x_attribute9 )
        OR ( ( Recinfo.attribute9 IS NULL )
          AND (  x_attribute9 IS NULL ) ) )
    AND ( ( Recinfo.attribute10 = x_attribute10 )
        OR ( ( Recinfo.attribute10 IS NULL )
          AND (  x_attribute10 IS NULL ) ) )
    AND ( ( Recinfo.attribute11 = x_attribute11 )
        OR ( ( Recinfo.attribute11 IS NULL )
          AND (  x_attribute11 IS NULL ) ) )
    AND ( ( Recinfo.attribute12 = x_attribute12 )
        OR ( ( Recinfo.attribute12 IS NULL )
          AND (  x_attribute12 IS NULL ) ) )
    AND ( ( Recinfo.attribute13 = x_attribute13 )
        OR ( ( Recinfo.attribute13 IS NULL )
          AND (  x_attribute13 IS NULL ) ) )
    AND ( ( Recinfo.attribute14 = x_attribute14 )
        OR ( ( Recinfo.attribute14 IS NULL )
          AND (  x_attribute14 IS NULL ) ) )
    AND ( ( Recinfo.attribute15 = x_attribute15 )
        OR ( ( Recinfo.attribute15 IS NULL )
          AND (  x_attribute15 IS NULL ) ) )
    AND ( ( Recinfo.attribute16 = x_attribute16 )
        OR ( ( Recinfo.attribute16 IS NULL )
          AND (  x_attribute16 IS NULL ) ) )
    AND ( ( Recinfo.attribute17 = x_attribute17 )
        OR ( ( Recinfo.attribute17 IS NULL )
          AND (  x_attribute17 IS NULL ) ) )
    AND ( ( Recinfo.attribute18 = x_attribute18 )
        OR ( ( Recinfo.attribute18 IS NULL )
          AND (  x_attribute18 IS NULL ) ) )
    AND ( ( Recinfo.attribute19 = x_attribute19 )
        OR ( ( Recinfo.attribute19 IS NULL )
          AND (  x_attribute19 IS NULL ) ) )
    AND ( ( Recinfo.attribute20 = x_attribute20 )
        OR ( ( Recinfo.attribute20 IS NULL )
          AND (  x_attribute20 IS NULL ) ) )
    ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row; */

PROCEDURE Select_Row (
    x_geography_id                          IN OUT NOCOPY NUMBER,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_geography_type                        OUT    NOCOPY VARCHAR2,
    x_geography_name                        OUT    NOCOPY VARCHAR2,
    x_geography_use                         OUT    NOCOPY VARCHAR2,
    x_geography_code                        OUT    NOCOPY VARCHAR2,
    x_start_date                            OUT    NOCOPY DATE,
    x_end_date                              OUT    NOCOPY DATE,
    x_multiple_parent_flag                  OUT    NOCOPY VARCHAR2,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_country_code                          OUT    NOCOPY VARCHAR2,
    x_geography_element1                    OUT    NOCOPY VARCHAR2,
    x_geography_element1_id                 OUT    NOCOPY NUMBER,
    x_geography_element1_code               OUT    NOCOPY VARCHAR2,
    x_geography_element2                    OUT    NOCOPY VARCHAR2,
    x_geography_element2_id                 OUT    NOCOPY NUMBER,
    x_geography_element2_code               OUT    NOCOPY VARCHAR2,
    x_geography_element3                    OUT    NOCOPY VARCHAR2,
    x_geography_element3_id                 OUT    NOCOPY NUMBER,
    x_geography_element3_code               OUT    NOCOPY VARCHAR2,
    x_geography_element4                    OUT    NOCOPY VARCHAR2,
    x_geography_element4_id                 OUT    NOCOPY NUMBER,
    x_geography_element4_code               OUT    NOCOPY VARCHAR2,
    x_geography_element5                    OUT    NOCOPY VARCHAR2,
    x_geography_element5_id                 OUT    NOCOPY NUMBER,
    x_geography_element5_code               OUT    NOCOPY VARCHAR2,
    x_geography_element6                    OUT    NOCOPY VARCHAR2,
    x_geography_element6_id                 OUT    NOCOPY NUMBER,
    x_geography_element7                    OUT    NOCOPY VARCHAR2,
    x_geography_element7_id                 OUT    NOCOPY NUMBER,
    x_geography_element8                    OUT    NOCOPY VARCHAR2,
    x_geography_element8_id                 OUT    NOCOPY NUMBER,
    x_geography_element9                    OUT    NOCOPY VARCHAR2,
    x_geography_element9_id                 OUT    NOCOPY NUMBER,
    x_geography_element10                   OUT    NOCOPY VARCHAR2,
    x_geography_element10_id                OUT    NOCOPY NUMBER,
    x_geometry                              OUT    NOCOPY MDSYS.SDO_GEOMETRY,
    x_timezone_code                         OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_program_login_id                      OUT    NOCOPY NUMBER,
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
) IS
BEGIN

    SELECT
      NVL(geography_id, FND_API.G_MISS_NUM),
      NVL(geography_type, FND_API.G_MISS_CHAR),
      NVL(geography_name, FND_API.G_MISS_CHAR),
      NVL(geography_use, FND_API.G_MISS_CHAR),
      NVL(geography_code, FND_API.G_MISS_CHAR),
      NVL(start_date, FND_API.G_MISS_DATE),
      NVL(end_date, FND_API.G_MISS_DATE),
      NVL(multiple_parent_flag, FND_API.G_MISS_CHAR),
      NVL(created_by_module, FND_API.G_MISS_CHAR),
      NVL(country_code, FND_API.G_MISS_CHAR),
      NVL(geography_element1, FND_API.G_MISS_CHAR),
      NVL(geography_element1_id, FND_API.G_MISS_NUM),
      NVL(geography_element1_code, FND_API.G_MISS_CHAR),
      NVL(geography_element2, FND_API.G_MISS_CHAR),
      NVL(geography_element2_id, FND_API.G_MISS_NUM),
      NVL(geography_element2_code, FND_API.G_MISS_CHAR),
      NVL(geography_element3, FND_API.G_MISS_CHAR),
      NVL(geography_element3_id, FND_API.G_MISS_NUM),
      NVL(geography_element3_code, FND_API.G_MISS_CHAR),
      NVL(geography_element4, FND_API.G_MISS_CHAR),
      NVL(geography_element4_id, FND_API.G_MISS_NUM),
      NVL(geography_element4_code, FND_API.G_MISS_CHAR),
      NVL(geography_element5, FND_API.G_MISS_CHAR),
      NVL(geography_element5_id, FND_API.G_MISS_NUM),
      NVL(geography_element5_code, FND_API.G_MISS_CHAR),
      NVL(geography_element6, FND_API.G_MISS_CHAR),
      NVL(geography_element6_id, FND_API.G_MISS_NUM),
      NVL(geography_element7, FND_API.G_MISS_CHAR),
      NVL(geography_element7_id, FND_API.G_MISS_NUM),
      NVL(geography_element8, FND_API.G_MISS_CHAR),
      NVL(geography_element8_id, FND_API.G_MISS_NUM),
      NVL(geography_element9, FND_API.G_MISS_CHAR),
      NVL(geography_element9_id, FND_API.G_MISS_NUM),
      NVL(geography_element10, FND_API.G_MISS_CHAR),
      NVL(geography_element10_id, FND_API.G_MISS_NUM),
geometry,
      NVL(timezone_code, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM),
      NVL(program_login_id, FND_API.G_MISS_NUM),
      NVL(attribute_category, FND_API.G_MISS_CHAR),
      NVL(attribute1, FND_API.G_MISS_CHAR),
      NVL(attribute2, FND_API.G_MISS_CHAR),
      NVL(attribute3, FND_API.G_MISS_CHAR),
      NVL(attribute4, FND_API.G_MISS_CHAR),
      NVL(attribute5, FND_API.G_MISS_CHAR),
      NVL(attribute6, FND_API.G_MISS_CHAR),
      NVL(attribute7, FND_API.G_MISS_CHAR),
      NVL(attribute8, FND_API.G_MISS_CHAR),
      NVL(attribute9, FND_API.G_MISS_CHAR),
      NVL(attribute10, FND_API.G_MISS_CHAR),
      NVL(attribute11, FND_API.G_MISS_CHAR),
      NVL(attribute12, FND_API.G_MISS_CHAR),
      NVL(attribute13, FND_API.G_MISS_CHAR),
      NVL(attribute14, FND_API.G_MISS_CHAR),
      NVL(attribute15, FND_API.G_MISS_CHAR),
      NVL(attribute16, FND_API.G_MISS_CHAR),
      NVL(attribute17, FND_API.G_MISS_CHAR),
      NVL(attribute18, FND_API.G_MISS_CHAR),
      NVL(attribute19, FND_API.G_MISS_CHAR),
      NVL(attribute20, FND_API.G_MISS_CHAR)
    INTO
      x_geography_id,
      x_geography_type,
      x_geography_name,
      x_geography_use,
      x_geography_code,
      x_start_date,
      x_end_date,
      x_multiple_parent_flag,
      x_created_by_module,
      x_country_code,
      x_geography_element1,
      x_geography_element1_id,
      x_geography_element1_code,
      x_geography_element2,
      x_geography_element2_id,
      x_geography_element2_code,
      x_geography_element3,
      x_geography_element3_id,
      x_geography_element3_code,
      x_geography_element4,
      x_geography_element4_id,
      x_geography_element4_code,
      x_geography_element5,
      x_geography_element5_id,
      x_geography_element5_code,
      x_geography_element6,
      x_geography_element6_id,
      x_geography_element7,
      x_geography_element7_id,
      x_geography_element8,
      x_geography_element8_id,
      x_geography_element9,
      x_geography_element9_id,
      x_geography_element10,
      x_geography_element10_id,
      x_geometry,
      x_timezone_code,
      x_application_id,
      x_program_login_id,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20
    FROM HZ_GEOGRAPHIES
    WHERE geography_id = x_geography_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'hz_geography_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_geography_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_geography_id                          IN     NUMBER
) IS
BEGIN

    DELETE FROM HZ_GEOGRAPHIES
    WHERE geography_id = x_geography_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

/*
  Procedure update_geo_element_cp is concurrent program 'Update Geography Element Columns'
  (ARHGEOEU) which will update the HZ_GEOGRAPHIES name/code value for updated identifier
  values (if primary flag is Y).
  Created By Nishant Singhai  25-Oct-2005 For Bug 4578867
*/
PROCEDURE update_geo_element_cp (
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2,
        p_geography_id          IN  NUMBER,
        p_identifier_type       IN  VARCHAR2,
        p_identifier_value      IN  VARCHAR2
        ) IS

  l_old_geo_name       VARCHAR2(360);
  l_old_geo_code       VARCHAR2(360);
  l_geography_type     VARCHAR2(30);
  l_country_code       VARCHAR2(30);
  l_err_message        VARCHAR2(500);
  l_identifier_value   VARCHAR2(360);
  l_geo_element_col    VARCHAR2(60);
  l_geo_element_code   VARCHAR2(60);
  l_geo_element_id     VARCHAR2(60);

  CURSOR c_get_geo_details (l_geo_id IN NUMBER) IS
    SELECT geography_name, geography_code, geography_type, country_code
    FROM   hz_geographies
    WHERE  geography_id = l_geo_id
    AND    geography_use = 'MASTER_REF'
    ;
BEGIN
   retcode := 0;

   IF (p_identifier_type = 'CODE') THEN
     l_identifier_value := UPPER(p_identifier_value);
   ELSE
     l_identifier_value := p_identifier_value;
   END IF;

   OPEN c_get_geo_details (p_geography_id);
   FETCH c_get_geo_details INTO l_old_geo_name, l_old_geo_code, l_geography_type, l_country_code;
   CLOSE c_get_geo_details;

   IF (l_geography_type <> 'COUNTRY') THEN
     BEGIN
       --get geography_element_column from hz_geo_structure_levels for this geography_id
       SELECT geography_element_column
       INTO   l_geo_element_col
       FROM   HZ_GEO_STRUCTURE_LEVELS
       WHERE  country_code = l_country_code
       AND    geography_type = l_geography_type
	   AND    ROWNUM < 2;

       l_geo_element_code := l_geo_element_col||'_CODE';
       l_geo_element_id := l_geo_element_col||'_ID';
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
          fnd_message.set_token('COLUMN', 'geography_element_column,country_code');
          l_err_message := FND_MESSAGE.GET;
          RAISE FND_API.G_EXC_ERROR;
     END;

   ELSIF l_geography_type = 'COUNTRY' THEN
         l_geo_element_col:= 'GEOGRAPHY_ELEMENT1';
         l_geo_element_code := 'GEOGRAPHY_ELEMENT1_CODE';
         l_geo_element_id := 'GEOGRAPHY_ELEMENT1_ID';
   END IF;

    -- denormalize the primary identifier in HZ_GEOGRAPHIES for identifier_type='NAME' and 'CODE'
    -- for this geography_id

    IF p_identifier_type = 'CODE' THEN
      UPDATE HZ_GEOGRAPHIES
         SET geography_code = l_identifier_value
       WHERE geography_id = p_geography_id;
    END IF;

    IF  p_identifier_type = 'NAME' THEN
      UPDATE HZ_GEOGRAPHIES
         SET geography_name = l_identifier_value
       WHERE geography_id = p_geography_id;
    END IF;

   -- denormalize the primary identifier in HZ_GEOGRAPHIES for identifier_type='NAME'/'CODE' in all the rows
   -- where this geography_id is de-normalized as a parent

   IF (p_identifier_type='NAME' AND l_geo_element_col IS NOT NULL)THEN

     EXECUTE IMMEDIATE 'UPDATE HZ_GEOGRAPHIES SET '||l_geo_element_col||'= :l_identifier_value '||
                   ' WHERE country_code = :l_country_code and '||
				   l_geo_element_id||'= :l_geography_id '
				   USING l_identifier_value, l_country_code, p_geography_id ;

   END IF;

   IF p_identifier_type='CODE' THEN
     IF l_geo_element_col IN ('GEOGRAPHY_ELEMENT1','GEOGRAPHY_ELEMENT2','GEOGRAPHY_ELEMENT3','GEOGRAPHY_ELEMENT4','GEOGRAPHY_ELEMENT5') THEN
        EXECUTE IMMEDIATE 'UPDATE HZ_GEOGRAPHIES SET '||l_geo_element_code||'= :l_identifier_value '||
                   ' WHERE country_code = :l_country_code and '||
				   l_geo_element_id||'= :l_geography_id '
				   USING l_identifier_value, l_country_code, p_geography_id;

    END IF;
  END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          fnd_file.put_line(fnd_file.log,l_err_message);
          retcode := '2'; -- Error
          errbuf  := l_err_message;
    WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.log,SQLERRM);
          retcode := '2'; -- Error
          errbuf := SQLERRM;
END update_geo_element_cp;

END HZ_GEOGRAPHIES_PKG;

/
