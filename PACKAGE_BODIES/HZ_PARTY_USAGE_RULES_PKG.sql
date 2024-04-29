--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_USAGE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_USAGE_RULES_PKG" AS
/*$Header: ARHPURTB.pls 120.0 2005/05/12 23:15:37 jhuang noship $ */

D_FUTURE_DATE                     CONSTANT DATE := TO_DATE('4712/12/31','YYYY/MM/DD');

PROCEDURE insert_row (
    x_party_usage_rule_id         IN     NUMBER,
    x_party_usage_rule_type       IN     VARCHAR2,
    x_party_usage_code            IN     VARCHAR2,
    x_related_party_usage_code    IN     VARCHAR2,
    x_effective_start_date        IN     DATE,
    x_effective_end_date          IN     DATE,
    x_object_version_number       IN     NUMBER,
    x_creation_date               IN     DATE,
    x_created_by                  IN     NUMBER,
    x_last_update_date            IN     DATE,
    x_last_updated_by             IN     NUMBER,
    x_last_update_login           IN     NUMBER
) IS

BEGIN

    INSERT INTO hz_party_usage_rules (
      party_usage_rule_id,
      party_usage_rule_type,
      party_usage_code,
      related_party_usage_code,
      effective_start_date,
      effective_end_date,
      object_version_number,
      created_by,
      creation_date,
      last_update_login,
      last_update_date,
      last_updated_by
    )
    VALUES (
      DECODE(x_party_usage_rule_id,
             NULL, hz_party_usage_rules_s.nextval,
             FND_API.G_MISS_CHAR, hz_party_usage_rules_s.nextval,
             x_party_usage_rule_id),
      x_party_usage_rule_type,
      x_party_usage_code,
      DECODE(x_related_party_usage_code,
             FND_API.G_MISS_CHAR, NULL,
             x_related_party_usage_code),
      DECODE(x_effective_start_date,
             NULL, trunc(sysdate),
             FND_API.G_MISS_DATE, trunc(sysdate),
             trunc(x_effective_start_date)),
      DECODE(x_effective_end_date,
             NULL, D_FUTURE_DATE,
             FND_API.G_MISS_DATE, D_FUTURE_DATE,
             trunc(x_effective_end_date)),
      x_object_version_number,
      x_created_by,
      x_creation_date,
      x_last_update_login,
      x_last_update_date,
      x_last_updated_by
    );

END insert_row;


PROCEDURE update_row (
    x_party_usage_rule_id         IN     NUMBER,
    x_party_usage_rule_type       IN     VARCHAR2,
    x_party_usage_code            IN     VARCHAR2,
    x_related_party_usage_code    IN     VARCHAR2,
    x_effective_start_date        IN     DATE,
    x_effective_end_date          IN     DATE,
    x_object_version_number       IN     NUMBER,
    x_last_update_date            IN     DATE,
    x_last_updated_by             IN     NUMBER,
    x_last_update_login           IN     NUMBER
) IS

BEGIN

    UPDATE hz_party_usage_rules
    SET
      party_usage_rule_type = x_party_usage_rule_type,
      party_usage_code = x_party_usage_code,
      related_party_usage_code =
        DECODE(x_related_party_usage_code,
               NULL, related_party_usage_code,
               FND_API.G_MISS_CHAR, NULL,
               x_related_party_usage_code),
      effective_start_date =
        DECODE(x_effective_start_date,
               NULL, effective_start_date,
               trunc(x_effective_start_date)),
      effective_end_date =
        DECODE(x_effective_end_date,
               NULL, effective_end_date,
               FND_API.G_MISS_DATE, D_FUTURE_DATE,
               trunc(x_effective_end_date)),
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               x_object_version_number),
      last_update_login = x_last_update_login,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by
    WHERE party_usage_rule_id = x_party_usage_rule_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END update_row;


/**
 * The following procedure will be called only from lct file.
 * We don't need to check last update date because:
 *
 * - Customer can't update seeded party usage rules.
 */

PROCEDURE load_row (
    x_party_usage_rule_id         IN     VARCHAR2,
    x_party_usage_rule_type       IN     VARCHAR2,
    x_party_usage_code            IN     VARCHAR2,
    x_related_party_usage_code    IN     VARCHAR2,
    x_effective_start_date        IN     VARCHAR2,
    x_effective_end_date          IN     VARCHAR2,
    x_owner                       IN     VARCHAR2,
    x_last_update_date            IN     VARCHAR2,
    x_custom_mode                 IN     VARCHAR2
) IS

    f_luby                        NUMBER;  -- entity owner in file
    f_ludate                      DATE;    -- entity update date in file

    CURSOR c_party_usage_rule IS
    SELECT object_version_number
    FROM   hz_party_usage_rules
    WHERE  party_usage_rule_id = x_party_usage_rule_id;

    -- we don't need to check transition rules created by customer
    -- because we don't allow customer create seeded->seeded
    -- transition rule.
    CURSOR c_duplicate_rule (
       p_seed                     NUMBER
    ) IS
    SELECT party_usage_rule_id, object_version_number
    FROM   hz_party_usage_rules
    WHERE  party_usage_rule_type = x_party_usage_rule_type
    AND    party_usage_code = x_party_usage_code
    AND    NVL(related_party_usage_code, '##') = NVL(x_related_party_usage_code, '##')
    AND    effective_end_date = D_FUTURE_DATE
    AND    created_by <> p_seed;

    db_object_version_number      NUMBER;
    db_party_usage_rule_id        NUMBER;
    db_object_version_number1     NUMBER;

BEGIN

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := NVL(TO_DATE(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    OPEN c_party_usage_rule;
    FETCH c_party_usage_rule INTO db_object_version_number;

    IF (c_party_usage_rule%NOTFOUND) THEN
      insert_row (
        x_party_usage_rule_id         => x_party_usage_rule_id,
        x_party_usage_rule_type       => x_party_usage_rule_type,
        x_party_usage_code            => x_party_usage_code,
        x_related_party_usage_code    => x_related_party_usage_code,
        x_effective_start_date        => TO_DATE(x_effective_start_date, 'YYYY/MM/DD'),
        x_effective_end_date          => TO_DATE(x_effective_end_date, 'YYYY/MM/DD'),
        x_object_version_number       => 1,
        x_creation_date               => f_ludate,
        x_created_by                  => f_luby,
        x_last_update_date            => f_ludate,
        x_last_updated_by             => f_luby,
        x_last_update_login           => 0
      );
    ELSE
      update_row (
        x_party_usage_rule_id         => x_party_usage_rule_id,
        x_party_usage_rule_type       => x_party_usage_rule_type,
        x_party_usage_code            => x_party_usage_code,
        x_related_party_usage_code    => x_related_party_usage_code,
        x_effective_start_date        => TO_DATE(x_effective_start_date, 'YYYY/MM/DD'),
        x_effective_end_date          => TO_DATE(x_effective_end_date, 'YYYY/MM/DD'),
        x_object_version_number       => (db_object_version_number + 1),
        x_last_update_date            => f_ludate,
        x_last_updated_by             => f_luby,
        x_last_update_login           => 0
      );
    END IF;

    CLOSE c_party_usage_rule;

    -- check the duplicate rule created by customer
    -- if there is any, inactive that rule
    --
    IF (TO_DATE(x_effective_end_date, 'YYYY/MM/DD') = D_FUTURE_DATE) THEN
      OPEN c_duplicate_rule(f_luby);
      FETCH c_duplicate_rule INTO db_party_usage_rule_id, db_object_version_number1;
      IF (c_duplicate_rule%FOUND) THEN
        update_row (
          x_party_usage_rule_id         => db_party_usage_rule_id,
          x_party_usage_rule_type       => null,
          x_party_usage_code            => null,
          x_related_party_usage_code    => null,
          x_effective_start_date        => null,
          x_effective_end_date          => sysdate,
          x_object_version_number       => (db_object_version_number1 + 1),
          x_last_update_date            => sysdate,
          x_last_updated_by             => f_luby,
          x_last_update_login           => 0
        );
      END IF;
      CLOSE c_duplicate_rule;
    END IF;

END load_row;


END HZ_PARTY_USAGE_RULES_PKG;

/
