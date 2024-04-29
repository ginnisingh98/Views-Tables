--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_USAGES_PKG" AS
/*$Header: ARHPUCTB.pls 120.3 2005/05/24 23:22:47 jhuang noship $ */

PROCEDURE insert_row (
    x_party_usage_code            IN     VARCHAR2,
    x_party_usage_type            IN     VARCHAR2,
    x_restrict_manual_assign_flag IN     VARCHAR2,
    x_restrict_manual_update_flag IN     VARCHAR2,
    x_publish_to_wfds_flag        IN     VARCHAR2,
    x_status_flag                 IN     VARCHAR2,
    x_object_version_number       IN     NUMBER,
    x_party_usage_name            IN     VARCHAR2,
    x_description                 IN     VARCHAR2,
    x_creation_date               IN     DATE,
    x_created_by                  IN     NUMBER,
    x_last_update_date            IN     DATE,
    x_last_updated_by             IN     NUMBER,
    x_last_update_login           IN     NUMBER
) IS

BEGIN

    INSERT INTO hz_party_usages_b (
      party_usage_code,
      party_usage_type,
      restrict_manual_assign_flag,
      restrict_manual_update_flag,
      publish_to_wfds_flag,
      status_flag,
      object_version_number,
      created_by,
      creation_date,
      last_update_login,
      last_update_date,
      last_updated_by
    )
    VALUES (
      x_party_usage_code,
      x_party_usage_type,
      DECODE(x_restrict_manual_assign_flag,
             NULL, 'N',
             FND_API.G_MISS_CHAR, 'N',
             x_restrict_manual_assign_flag),
      DECODE(x_restrict_manual_update_flag,
             NULL, 'N',
             FND_API.G_MISS_CHAR, 'N',
             x_restrict_manual_update_flag),
      DECODE(x_publish_to_wfds_flag,
             NULL, 'N',
             FND_API.G_MISS_CHAR, 'N',
             x_publish_to_wfds_flag),
      DECODE(x_status_flag,
             NULL, 'A',
             FND_API.G_MISS_CHAR, 'A',
             x_status_flag),
      x_object_version_number,
      x_created_by,
      x_creation_date,
      x_last_update_login,
      x_last_update_date,
      x_last_updated_by
    );

    INSERT INTO hz_party_usages_tl (
      party_usage_code,
      language,
      source_lang,
      party_usage_name,
      description,
      created_by,
      creation_date,
      last_update_login,
      last_update_date,
      last_updated_by
    )
    SELECT
      x_party_usage_code,
      l.language_code,
      USERENV('LANG'),
      x_party_usage_name,
      x_description,
      x_created_by,
      x_creation_date,
      x_last_update_login,
      x_last_update_date,
      x_last_updated_by
    FROM  fnd_languages l
    WHERE l.installed_flag IN ('I', 'B')
    AND NOT EXISTS (
      SELECT NULL
      FROM   hz_party_usages_tl t
      WHERE  t.party_usage_code = x_party_usage_code
      AND    t.language = l.language_code
    );

END insert_row;


PROCEDURE update_row (
    x_party_usage_code            IN     VARCHAR2,
    x_party_usage_type            IN     VARCHAR2,
    x_restrict_manual_assign_flag IN     VARCHAR2,
    x_restrict_manual_update_flag IN     VARCHAR2,
    x_publish_to_wfds_flag        IN     VARCHAR2,
    x_status_flag                 IN     VARCHAR2,
    x_object_version_number       IN     NUMBER,
    x_party_usage_name            IN     VARCHAR2,
    x_description                 IN     VARCHAR2,
    x_last_update_date            IN     DATE,
    x_last_updated_by             IN     NUMBER,
    x_last_update_login           IN     NUMBER
) IS

BEGIN

    UPDATE hz_party_usages_b
    SET
      party_usage_type = x_party_usage_type,
      restrict_manual_assign_flag =
        DECODE(x_restrict_manual_assign_flag,
               NULL, restrict_manual_assign_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_restrict_manual_assign_flag),
      restrict_manual_update_flag =
        DECODE(x_restrict_manual_update_flag,
               NULL, restrict_manual_update_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_restrict_manual_update_flag),
      publish_to_wfds_flag =
        DECODE(x_publish_to_wfds_flag,
               NULL, publish_to_wfds_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_publish_to_wfds_flag),
      status_flag =
        DECODE(x_status_flag,
               NULL, status_flag,
               x_status_flag),
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               x_object_version_number),
      last_update_login = x_last_update_login,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by
    WHERE party_usage_code = x_party_usage_code;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    UPDATE hz_party_usages_tl
    SET
      party_usage_name =
        DECODE(x_party_usage_name,
               NULL, party_usage_name,
               x_party_usage_name),
      description =
        DECODE(x_description,
               NULL, description,
               x_description),
      last_update_login = x_last_update_login,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by,
      source_lang = USERENV('LANG')
    WHERE party_usage_code = x_party_usage_code
    AND   USERENV('LANG') IN (language, source_lang);

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END update_row;


PROCEDURE add_language IS

BEGIN

    DELETE FROM hz_party_usages_tl t
    WHERE NOT EXISTS (
      SELECT NULL
      FROM   hz_party_usages_b b
      WHERE  b.party_usage_code = t.party_usage_code
    );

    UPDATE hz_party_usages_tl t
    SET (
      party_usage_name,
      description
    ) = (
    SELECT
      b.party_usage_name,
      b.description
    FROM  hz_party_usages_tl b
    WHERE b.party_usage_code = t.party_usage_code
    AND   b.language = t.source_lang)
    WHERE (
        t.party_usage_code,
        t.language
      ) IN (
      SELECT
        subt.party_usage_code,
        subt.language
      FROM  hz_party_usages_tl subb, hz_party_usages_tl subt
      WHERE subb.party_usage_code = subt.party_usage_code
      AND   subb.language = subt.source_lang
      AND   (subb.party_usage_name <> subt.party_usage_name
      OR     subb.description <> subt.description
      OR    (subb.description IS NULL AND subt.description IS NOT NULL)
      OR    (subb.description IS NOT NULL and subt.description IS NULL)
    ));

    INSERT INTO hz_party_usages_tl (
      party_usage_code,
      party_usage_name,
      description,
      created_by,
      creation_date,
      last_update_login,
      last_update_date,
      last_updated_by,
      language,
      source_lang
    )
    SELECT /*+ ORDERED */
      b.party_usage_code,
      b.party_usage_name,
      b.description,
      b.created_by,
      b.creation_date,
      b.last_update_login,
      b.last_update_date,
      b.last_updated_by,
      l.language_code,
      b.source_lang
    FROM  hz_party_usages_tl b, fnd_languages l
    WHERE l.installed_flag IN ('I', 'B')
    AND b.language = USERENV('LANG')
    AND NOT EXISTS (
      SELECT NULL
      FROM   hz_party_usages_tl t
      WHERE  t.party_usage_code = b.party_usage_code
      AND    t.language = l.language_code
    );

END add_language;


PROCEDURE translate_row (
    x_party_usage_code            IN     VARCHAR2,
    x_owner                       IN     VARCHAR2,
    x_party_usage_name            IN     VARCHAR2,
    x_description                 IN     VARCHAR2
) IS

BEGIN

    translate_row (
      x_party_usage_code          => x_party_usage_code,
      x_owner                     => x_owner,
      x_party_usage_name          => x_party_usage_name,
      x_description               => x_description,
      x_last_update_date          => NULL,
      x_custom_mode               => NULL
    );

END translate_row;


/**
 * The following procedure will be called only from lct file.
 * We don't need to check last update date because:
 *
 * - Customer can't update seeded party usage codes and rules in Admin UI.
 *   Seeded party usage codes and rules can only be updated through FDNLOAD
 *   through patching process.
 * - Party usage codes created by customer through Admin UI must follow some
 *   naming convention. For instance, party usage code must end with _CUS.
 *   This will make sure that seeded party usage codes later added won't
 *   conflict with ones customer created.
 * - Same party usage name can be shared by different party usage codes
 *   (i.e. party usage codes customer created can have the same name as
 *   party usage codes seeded by us.)
 */

PROCEDURE translate_row (
    x_party_usage_code            IN     VARCHAR2,
    x_owner                       IN     VARCHAR2,
    x_party_usage_name            IN     VARCHAR2,
    x_description                 IN     VARCHAR2,
    x_last_update_date            IN     VARCHAR2,
    x_custom_mode                 IN     VARCHAR2
) IS

    f_luby                        NUMBER;  -- entity owner in file
    f_ludate                      DATE;    -- entity update date in file

BEGIN

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := NVL(TO_DATE(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    UPDATE hz_party_usages_tl
    SET
      party_usage_name =
        DECODE(x_party_usage_name,
               NULL, party_usage_name,
               x_party_usage_name),
      description =
        DECODE(x_description,
               NULL, description,
               x_description),
      last_update_date  = f_ludate,
      last_updated_by   = f_luby,
      last_update_login = 0,
      source_lang = USERENV('LANG')
    WHERE party_usage_code = x_party_usage_code
    AND   USERENV('LANG') IN (language, source_lang);

END translate_row;


PROCEDURE load_row (
    x_party_usage_code            IN     VARCHAR2,
    x_owner                       IN     VARCHAR2,
    x_party_usage_type            IN     VARCHAR2,
    x_restrict_manual_assign_flag IN     VARCHAR2,
    x_restrict_manual_update_flag IN     VARCHAR2,
    x_publish_to_wfds_flag        IN     VARCHAR2,
    x_status_flag                 IN     VARCHAR2,
    x_party_usage_name            IN     VARCHAR2,
    x_description                 IN     VARCHAR2,
    x_last_update_date            IN     VARCHAR2,
    x_custom_mode                 IN     VARCHAR2
) IS

    f_luby                        NUMBER;  -- entity owner in file
    f_ludate                      DATE;    -- entity update date in file

    CURSOR c_party_usage IS
    SELECT object_version_number
    FROM   hz_party_usages_b
    WHERE  party_usage_code = x_party_usage_code;

    db_object_version_number      NUMBER;

BEGIN

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := NVL(TO_DATE(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    OPEN c_party_usage;
    FETCH c_party_usage INTO db_object_version_number;

    -- create party usage if not found.
    -- otherwise, update

    IF (c_party_usage%NOTFOUND) THEN
      insert_row (
        x_party_usage_code            => x_party_usage_code,
        x_party_usage_type            => x_party_usage_type,
        x_restrict_manual_assign_flag => x_restrict_manual_assign_flag,
        x_restrict_manual_update_flag => x_restrict_manual_update_flag,
        x_publish_to_wfds_flag        => x_publish_to_wfds_flag,
        x_status_flag                 => x_status_flag,
        x_object_version_number       => 1,
        x_party_usage_name            => x_party_usage_name,
        x_description                 => x_description,
        x_creation_date               => f_ludate,
        x_created_by                  => f_luby,
        x_last_update_date            => f_ludate,
        x_last_updated_by             => f_luby,
        x_last_update_login           => 0
      );
    ELSE
      update_row (
        x_party_usage_code            => x_party_usage_code,
        x_party_usage_type            => x_party_usage_type,
        x_restrict_manual_assign_flag => x_restrict_manual_assign_flag,
        x_restrict_manual_update_flag => x_restrict_manual_update_flag,
        x_publish_to_wfds_flag        => x_publish_to_wfds_flag,
        x_status_flag                 => x_status_flag,
        x_object_version_number       => db_object_version_number,
        x_party_usage_name            => x_party_usage_name,
        x_description                 => x_description,
        x_last_update_date            => f_ludate,
        x_last_updated_by             => f_luby,
        x_last_update_login           => 0
      );
    END IF;

    close c_party_usage;

END load_row;


END HZ_PARTY_USAGES_PKG;

/
