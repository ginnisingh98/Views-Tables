--------------------------------------------------------
--  DDL for Package Body HZ_REGISTRY_VALIDATE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_REGISTRY_VALIDATE_V2PUB" AS
/*$Header: ARH2RGVB.pls 120.126.12010000.3 2009/06/24 22:31:15 awu ship $ */

  -----------------------------------------
  -- declaration of private global varibles
  -----------------------------------------

  g_special_string CONSTANT VARCHAR2(4):= '%#@*';
  G_LENGTH         CONSTANT NUMBER := LENGTHB(g_special_string);

  TYPE val_tab_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

  --g_debug                                 BOOLEAN := FALSE;
  g_debug_count                           NUMBER := 0;

  ---------------------------------------------------

  -- define the internal table that will cache values
  ---------------------------------------------------

  VAL_TAB                                 VAL_TAB_TYPE;    -- the table of values
  TABLE_SIZE                              BINARY_INTEGER := 2048; -- the size of above tables

  ------------------------------------
  -- declaration of private procedures
  ------------------------------------
/*
  PROCEDURE enable_debug;

  PROCEDURE disable_debug;
*/

  FUNCTION get_index (
      p_val                       IN     VARCHAR2
 ) RETURN BINARY_INTEGER;

  PROCEDURE put (
      p_val                       IN     VARCHAR2
 );

  FUNCTION search (
      p_val                       IN     VARCHAR2,
      p_category                  IN     VARCHAR2
 ) RETURN BOOLEAN;

  PROCEDURE validate_rel_code(
    p_forward_rel_code      IN      VARCHAR2,
    p_backward_rel_code     IN      VARCHAR2,
    p_forward_role          IN      VARCHAR2,
    p_backward_role         IN      VARCHAR2,
    x_return_status         IN OUT NOCOPY  VARCHAR2
  );

 --Bug Number 3099624.
 PROCEDURE validate_hr_security(
      p_person_rec                     IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
      p_old_person_rec                 IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
      x_return_status                  IN OUT NOCOPY VARCHAR2
    );

 -- Bug 3175816
 PROCEDURE validate_global_loc_num(
      global_location_number           IN     HZ_PARTY_SITES.GLOBAL_LOCATION_NUMBER%TYPE,
      x_return_status                  IN OUT NOCOPY VARCHAR2
    );

PROCEDURE validate_created_by_module (
    p_create_update_flag          IN     VARCHAR2,
    p_created_by_module           IN     VARCHAR2,
    p_old_created_by_module       IN     VARCHAR2,
    x_return_status               IN OUT NOCOPY VARCHAR2
);

PROCEDURE validate_application_id (
    p_create_update_flag          IN     VARCHAR2,
    p_application_id              IN     NUMBER,
    p_old_application_id          IN     NUMBER,
    x_return_status               IN OUT NOCOPY VARCHAR2
);

PROCEDURE validate_fnd_lookup
( p_lookup_type          IN     VARCHAR2,
  p_column               IN     VARCHAR2,
  p_column_value         IN     VARCHAR2,
  p_content_source_type  IN     VARCHAR2,
  x_return_status        IN OUT NOCOPY VARCHAR2)
IS

 --Bug 3097166: Added the cursor for 'NACE' lookup type where clause to ignore
 --the period when comparing the lookup_code.

 CURSOR c_nace
 IS
 SELECT 'Y'
   FROM fnd_lookup_values
  WHERE lookup_type = p_lookup_type
    AND replace(lookup_code, '.', '') = replace(p_column_value, '.', '')
    AND ROWNUM      = 1;

 l_exist VARCHAR2(1);
BEGIN

 IF (    p_column_value IS NOT NULL
     AND p_column_value <> fnd_api.g_miss_char ) THEN
      OPEN c_nace;
      FETCH c_nace INTO l_exist;
      IF c_nace%NOTFOUND THEN
        fnd_message.set_name('AR','HZ_API_INVALID_LOOKUP');
        fnd_message.set_token('COLUMN',p_column);
        fnd_message.set_token('LOOKUP_TYPE', p_lookup_type);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_nace;
 END IF;
END validate_fnd_lookup;



  -----------------------------
  -- body of private procedures
  -----------------------------

  /**
   * PRIVATE PROCEDURE enable_debug
   *
   * DESCRIPTION
   *     Turn on debug mode.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *     HZ_UTILITY_V2PUB.enable_debug
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Jianying Huang      o Created.
   *
   */

  /*PROCEDURE enable_debug IS

  BEGIN

      g_debug_count := g_debug_count + 1;

      IF g_debug_count = 1 THEN
          IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
             fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
          THEN
             hz_utility_v2pub.enable_debug;
             g_debug := TRUE;
          END IF;
      END IF;

  END enable_debug;
  */


  /**
   * PRIVATE PROCEDURE disable_debug
   *
   * DESCRIPTION
   *     Turn off debug mode.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *     hz_utility_v2pub.disable_debug
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Jianying Huang      o Created.
   *
   */

  /*PROCEDURE disable_debug IS
  BEGIN

      IF g_debug THEN
          g_debug_count := g_debug_count - 1;

          IF g_debug_count = 0 THEN
              hz_utility_v2pub.disable_debug;
              g_debug := FALSE;
          END IF;
      END IF;

  END disable_debug;
  */

  FUNCTION get_index (
      p_val                               IN     VARCHAR2
 ) RETURN BINARY_INTEGER IS

      l_table_index                       BINARY_INTEGER;
      l_found                             BOOLEAN := FALSE;
      l_hash_value                        NUMBER;

  BEGIN

      l_table_index := DBMS_UTILITY.get_hash_value(p_val, 1, TABLE_SIZE);

      IF VAL_TAB.EXISTS(l_table_index) THEN
          IF VAL_TAB(l_table_index) = p_val THEN
              RETURN l_table_index;
          ELSE
              l_hash_value := l_table_index;
              l_table_index := l_table_index + 1;
              l_found := FALSE;

              WHILE (l_table_index < TABLE_SIZE) AND (NOT l_found) LOOP
                  IF VAL_TAB.EXISTS(l_table_index) THEN
                      IF VAL_TAB(l_table_index) = p_val THEN
                          l_found := TRUE;
                      ELSE
                          l_table_index := l_table_index + 1;
                      END IF;
                  ELSE
                      RETURN TABLE_SIZE + 1;
                  END IF;
              END LOOP;

              IF NOT l_found THEN  -- Didn't find any till the end
                  l_table_index := 1;  -- Start from the beginning

                  WHILE (l_table_index < l_hash_value) AND (NOT l_found) LOOP
                      IF VAL_TAB.EXISTS(l_table_index) THEN
                          IF VAL_TAB(l_table_index) = p_val THEN
                              l_found := TRUE;
                          ELSE
                              l_table_index := l_table_index + 1;
                          END IF;
                      ELSE
                          RETURN TABLE_SIZE + 1;
                      END IF;
                  END LOOP;
              END IF;

              IF NOT l_found THEN
                  RETURN TABLE_SIZE + 1;  -- Return a higher value
              END IF;
          END IF;
      ELSE
          RETURN TABLE_SIZE + 1;
      END IF;

      RETURN l_table_index;

  EXCEPTION
      WHEN OTHERS THEN  -- The entry doesn't exists
          RETURN TABLE_SIZE + 1;

  END get_index;

  PROCEDURE put (
      p_val                               IN     VARCHAR2
  ) IS

      l_table_index                       BINARY_INTEGER;
      l_stored                            BOOLEAN := FALSE;
      l_hash_value                        NUMBER;

  BEGIN

      l_table_index := DBMS_UTILITY.get_hash_value(p_val, 1, TABLE_SIZE);

      IF VAL_TAB.EXISTS(l_table_index) THEN
          IF VAL_TAB(l_table_index) <> p_val THEN --Collision
              l_hash_value := l_table_index;
              l_table_index := l_table_index + 1;

              WHILE (l_table_index < TABLE_SIZE) AND (NOT l_stored) LOOP
                  IF VAL_TAB.EXISTS(l_table_index) THEN
                      IF VAL_TAB(l_table_index) <> p_val THEN
                          l_table_index := l_table_index + 1;
                      END IF;
                  ELSE
                      VAL_TAB(l_table_index) := p_val;
                      l_stored := TRUE;
                  END IF;
              END LOOP;

              IF NOT l_stored THEN --Didn't find any free bucket till the end
                  l_table_index := 1;

                  WHILE (l_table_index < l_hash_value) AND (NOT l_stored) LOOP
                      IF VAL_TAB.EXISTS(l_table_index) THEN
                          IF VAL_TAB(l_table_index) <> p_val THEN
                              l_table_index := l_table_index + 1;
                          END IF;
                      ELSE
                          VAL_TAB(l_table_index) := p_val;
                          l_stored := TRUE;
                      END IF;
                  END LOOP;
              END IF;

          END IF;
      ELSE
          VAL_TAB(l_table_index) := p_val;
      END IF;

  EXCEPTION
      WHEN OTHERS THEN
          NULL;

  END put;

  FUNCTION search (
      p_val                               IN     VARCHAR2,
      p_category                          IN     VARCHAR2
  ) RETURN BOOLEAN IS

      l_table_index                       BINARY_INTEGER;
      l_return                            BOOLEAN;

      l_dummy                             VARCHAR2(1);
      l_position1                         NUMBER;
      l_position2                         NUMBER;

      l_lookup_table                      VARCHAR2(30);
      l_lookup_type                       AR_LOOKUPS.lookup_type%TYPE;
      l_lookup_code                       AR_LOOKUPS.lookup_code%TYPE;
      l_territory_code                    VARCHAR2(2);

  BEGIN

      -- search for the value
      l_table_index := get_index(p_val || G_SPECIAL_STRING || p_category);

      IF l_table_index < table_size THEN
           l_return := TRUE;
      ELSE

          --Can't find the value in the table; look in the database
          IF p_category = 'LOOKUP' THEN

              l_position1 := INSTRB(p_val, G_SPECIAL_STRING, 1, 1);
              l_lookup_table := SUBSTRB(p_val, 1, l_position1 - 1);
              l_position2 := INSTRB(p_val, G_SPECIAL_STRING, 1, 2);
              l_lookup_type := SUBSTRB(p_val, l_position1 + G_LENGTH,
                                       l_position2  - l_position1 - G_LENGTH);
              l_lookup_code := SUBSTRB(p_val, l_position2 + G_LENGTH);

              IF UPPER(l_lookup_table) = 'AR_LOOKUPS' THEN
              BEGIN
                  SELECT 'Y' INTO l_dummy
                  FROM   AR_LOOKUPS
                  WHERE  LOOKUP_TYPE = l_lookup_type
                  AND    LOOKUP_CODE = l_lookup_code
                  AND    (ENABLED_FLAG = 'Y' AND
                          TRUNC(SYSDATE) BETWEEN
                          TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND
                          TRUNC(NVL(END_DATE_ACTIVE,SYSDATE))
                        );

                  l_return := TRUE;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      l_return := FALSE;
              END;
              ELSIF UPPER(l_lookup_table) = 'SO_LOOKUPS' THEN
              BEGIN
                  SELECT 'Y' INTO l_dummy
                  FROM   SO_LOOKUPS
                  WHERE  LOOKUP_TYPE = l_lookup_type
                  AND    LOOKUP_CODE = l_lookup_code
                  AND    (ENABLED_FLAG = 'Y' AND
                          TRUNC(SYSDATE) BETWEEN
                          TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND
                          TRUNC(NVL(END_DATE_ACTIVE,SYSDATE))
                        );

                  l_return := TRUE;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      l_return := FALSE;
              END;
              ELSIF UPPER(l_lookup_table) = 'OE_SHIP_METHODS_V' THEN
              BEGIN
                  SELECT 'Y' INTO l_dummy
                  FROM   OE_SHIP_METHODS_V
                  WHERE  LOOKUP_TYPE = l_lookup_type
                  AND    LOOKUP_CODE = l_lookup_code
                  AND    (ENABLED_FLAG = 'Y' AND
                          TRUNC(SYSDATE) BETWEEN
                          TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND
                          TRUNC(NVL(END_DATE_ACTIVE,SYSDATE))
                        )
                  AND    ROWNUM = 1;

                  l_return := TRUE;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      l_return := FALSE;
              END;
              ELSIF UPPER(l_lookup_table) = 'FND_LOOKUP_VALUES' THEN
              BEGIN
                  SELECT 'Y' INTO l_dummy
                  FROM   FND_LOOKUP_VALUES
                  WHERE  LOOKUP_TYPE = l_lookup_type
                  AND    LOOKUP_CODE = l_lookup_code
                  AND    (ENABLED_FLAG = 'Y' AND
                          TRUNC(SYSDATE) BETWEEN
                          TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND
                          TRUNC(NVL(END_DATE_ACTIVE,SYSDATE))
                        )
                  AND    ROWNUM = 1;

                  l_return := TRUE;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      l_return := FALSE;
              END;
              ELSE
                  l_return := FALSE;
              END IF;
          ELSIF p_category = 'FND_TERRITORIES' THEN

            l_position1 := INSTRB( p_val, G_SPECIAL_STRING, 1, 1 );
            l_territory_code := SUBSTRB( p_val, 1, l_position1 - 1 );

            BEGIN
                SELECT null INTO l_dummy
                FROM   FND_TERRITORIES
                WHERE  TERRITORY_CODE = l_territory_code
                AND    OBSOLETE_FLAG = 'N';

                l_return := TRUE;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_return := FALSE;
            END;
          ELSE
            l_return := FALSE;
          END IF;

          --Cache the value
          IF l_return THEN
             put(p_val || G_SPECIAL_STRING || p_category);
          END IF;
      END IF;
      RETURN l_return;

  END search;

  --
  -- PROCEDURE check organization
  --
  -- DESCRIPTION
  --   Checks if the party type is an organization
  --   point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_id           ID identifying the party.
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   21-NOV-2001    Joe del Callar   bug 2120857: Created to validate party
  --                                   types for EFT and EDI contact points.
  --   22-MAY-2002   Joe del Callar    Fixed an issue where the EDI org check
  --                                   was failing due to a premature cursor
  --                                   close.
  --   23-DEC-2003   Rajib R Borah     Bug 2619099.Displayed error message
  --                                   HZ_EDI_EFT_ORG_PARTIES_ONLY instead of
  --                                   HZ_API_INVALID_PARTY_TYPE.
  --
  PROCEDURE check_organization (
    p_party_id            IN     NUMBER,
    x_return_status       IN OUT NOCOPY VARCHAR2
  ) IS
    CURSOR c_partytype IS
      SELECT hp.party_type
      FROM   hz_parties hp
      WHERE  hp.party_id = p_party_id;

    l_party_type          VARCHAR2(30);

  BEGIN

    OPEN c_partytype;
    FETCH c_partytype INTO l_party_type;
    -- Ensure that a party record was retrieved.
    IF c_partytype%NOTFOUND THEN
      -- no party and organization was found for the given ID.
      CLOSE c_partytype;
      fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
      fnd_message.set_token('FK', 'OWNER_TABLE_ID');
      fnd_message.set_token('COLUMN', 'PARTY_ID');
      fnd_message.set_token('TABLE', 'HZ_PARTIES');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    -- Check that the party is an organization.
    IF l_party_type <> 'ORGANIZATION' THEN
      -- This is not an organization.  Only organizations can have EDI
      -- contact points.

  /* Bug 2619099.
  |    fnd_message.set_name('AR', 'HZ_API_INVALID_PARTY_TYPE');      |
  |    fnd_message.set_token('PARTY_ID', TO_CHAR(p_party_id));       |
  |    fnd_message.set_token('TYPE', 'ORGANIZATION');               */
      fnd_message.set_name('AR','HZ_EDI_EFT_ORG_PARTIES_ONLY');

      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_partytype;
  END check_organization;

  --
  -- PROCEDURE validate_party_type
  --
  -- DESCRIPTION
  --   Checks if the proper party type is being applied for the given contact
  --   point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_table_name         Must be 'HZ_PARTIES' for valid execution.
  --     p_party_id           ID identifying the party.
  --     p_contact_point_type Type of contact point.  'EFT' and 'EDI'-type
  --                          contact points are accepted.  Others are ignored.
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   21-NOV-2001    Joe del Callar   bug 2120857: Created to validate party
  --                                   types for EFT and EDI contact points.
  --   23-DEC-2003    Rajib R Borah    Bug 2619099.Displayed the error message
  --                                   HZ_EDI_EFT_ORG_PARTIES_ONLY instead of
  --                                   HZ_API_INVALID_FK.
  --
  --   06-NOV-2006   Sudhir Gokavarapu Bug 6611955. Added IF ELSE condition after Party Type Check.
  --                                   Corrected IF ELSE condition for c_class Cursor Open / Close.
  PROCEDURE validate_party_type (
    p_table_name          IN     VARCHAR2,
    p_party_id            IN     NUMBER,
    p_contact_point_type  IN     VARCHAR2,
    x_return_status       IN OUT NOCOPY VARCHAR2
  ) IS

    CURSOR c_class IS
      SELECT hca.class_category,
             hca.object_version_number
      FROM   hz_code_assignments hca
      WHERE  hca.owner_table_name = 'HZ_PARTIES'
             AND hca.owner_table_id = p_party_id
             AND hca.status = 'A'
      ORDER BY 2 DESC;

    l_class_category VARCHAR2(30);
    l_dummy          NUMBER;
    l_debug_prefix                     VARCHAR2(30) := '';
  BEGIN
    -- data being validated must belong to a party.
    IF p_table_name <> 'HZ_PARTIES' THEN
      -- This is not a party type.  This procedure was called incorrectly,
      -- return a failure.
/* Bug 2619099.
 |     fnd_message.set_name('AR', 'HZ_API_INVALID_FK');  |
 |     fnd_message.set_token('FK', 'OWNER_TABLE_NAME');  |
 |     fnd_message.set_token('COLUMN', 'HZ_PARTIES');    |
 |     fnd_message.set_token('TABLE', 'FND_OBJECTS');   */
      fnd_message.set_name('AR','HZ_EDI_EFT_ORG_PARTIES_ONLY');

      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    -- validate party type based on the contact point type.
    IF p_contact_point_type = 'EDI' THEN
      -- make sure that the contact point belongs to an organization.
      check_organization(p_party_id, x_return_status);
    ELSIF p_contact_point_type = 'EFT' THEN
      -- make sure that the contact point belongs to an organization.
     check_organization(p_party_id, x_return_status);
     IF x_return_status <> fnd_api.g_ret_sts_error THEN
      -- EFT is only currently allowed for banks.

      OPEN c_class;
      FETCH c_class INTO l_class_category, l_dummy;

      -- Ensure that a party record was retrieved.
      IF c_class%NOTFOUND THEN
        -- no party and organization was found for the given ID.
        CLOSE c_class;
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'Code Assignment');
        fnd_message.set_token('VALUE', TO_CHAR(p_party_id));
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
--      END IF;
      ELSE
      -- Check that the category class is a bank.
       IF l_class_category NOT LIKE 'BANK%' THEN
        -- This is not a bank-type organization.  Only bank-type organizations
        -- can have EFT contact points.
        fnd_message.set_name('AR', 'HZ_API_INVALID_PARTY_TYPE');
        fnd_message.set_token('PARTY_ID', TO_CHAR(p_party_id));
        fnd_message.set_token('TYPE', 'BANK or BANK BRANCH');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
       END IF;
      CLOSE c_class;
      END IF;
     END IF;
    ELSE
      -- do nothing if not of either type that this procedure recognizes.
      NULL;
    END IF;
  END validate_party_type;

  PROCEDURE validate_mandatory (
      p_create_update_flag                    IN     VARCHAR2,
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     VARCHAR2,
      p_restricted                            IN     VARCHAR2 DEFAULT 'N',
      x_return_status                         IN OUT NOCOPY VARCHAR2
  ) IS

      l_error                                 BOOLEAN := FALSE;

  BEGIN

      IF p_restricted = 'N' THEN
          IF (p_create_update_flag = 'C' AND
               (p_column_value IS NULL OR
                 p_column_value = fnd_api.g_miss_char)) OR
             (p_create_update_flag = 'U' AND
               p_column_value = fnd_api.g_miss_char)
          THEN
              l_error := TRUE;
          END IF;
      ELSE
          IF (p_column_value IS NULL OR
               p_column_value = fnd_api.g_miss_char)
          THEN
              l_error := TRUE;
          END IF;
      END IF;

      IF l_error THEN
          fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
          fnd_message.set_token('COLUMN', p_column);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_mandatory;

  PROCEDURE validate_mandatory (
      p_create_update_flag                    IN     VARCHAR2,
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     NUMBER,
      p_restricted                            IN     VARCHAR2 DEFAULT 'N',
      x_return_status                         IN OUT NOCOPY VARCHAR2
 ) IS

      l_error                                 BOOLEAN := FALSE;

  BEGIN

      IF p_restricted = 'N' THEN
          IF (p_create_update_flag = 'C' AND
               (p_column_value IS NULL OR
                 p_column_value = fnd_api.g_miss_num)) OR
             (p_create_update_flag = 'U' AND
               p_column_value = fnd_api.g_miss_num)
          THEN
              l_error := TRUE;
          END IF;
      ELSE
          IF (p_column_value IS NULL OR
               p_column_value = fnd_api.g_miss_num)
          THEN
              l_error := TRUE;
          END IF;
      END IF;

      IF l_error THEN
          fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
          fnd_message.set_token('COLUMN', p_column);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_mandatory;

  PROCEDURE validate_mandatory (
      p_create_update_flag                    IN     VARCHAR2,
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     DATE,
      p_restricted                            IN     VARCHAR2 DEFAULT 'N',
      x_return_status                         IN OUT NOCOPY VARCHAR2
 ) IS

      l_error                                 BOOLEAN := FALSE;

  BEGIN

      IF p_restricted = 'N' THEN
          IF (p_create_update_flag = 'C' AND
               (p_column_value IS NULL OR
                 p_column_value = FND_API.G_MISS_DATE)) OR
             (p_create_update_flag = 'U' AND
               p_column_value = FND_API.G_MISS_DATE)
          THEN
              l_error := TRUE;
          END IF;
      ELSE
          IF (p_column_value IS NULL OR
               p_column_value = FND_API.G_MISS_DATE)
          THEN
              l_error := TRUE;
          END IF;
      END IF;

      IF l_error THEN
          fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
          fnd_message.set_token('COLUMN', p_column);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_mandatory;

  PROCEDURE validate_nonupdateable (
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     VARCHAR2,
      p_old_column_value                      IN     VARCHAR2,
      p_restricted                            IN     VARCHAR2 DEFAULT 'Y',
      x_return_status                         IN OUT NOCOPY VARCHAR2,
      p_raise_error                           IN     VARCHAR2 := 'Y'
 ) IS

      l_error                                 BOOLEAN := FALSE;

  BEGIN

      IF p_column_value IS NOT NULL THEN
          IF p_restricted = 'Y' THEN
              IF (p_column_value <> fnd_api.g_miss_char OR
                   p_old_column_value IS NOT NULL) AND
                 (p_old_column_value IS NULL OR
                   p_column_value <> p_old_column_value)
              THEN
                 l_error := TRUE;
              END IF;
          ELSE
              IF (p_old_column_value IS NOT NULL AND        -- BUG 3367582.
                  p_old_column_value <> FND_API.G_MISS_CHAR)
                  AND
                 (p_column_value = fnd_api.g_miss_char OR
                   p_column_value <> p_old_column_value)
              THEN
                 l_error := TRUE;
              END IF;
          END IF;
      END IF;
      IF l_error THEN
        IF p_raise_error = 'Y' THEN
          fnd_message.set_name('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
          fnd_message.set_token('COLUMN', p_column);
          fnd_msg_pub.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_nonupdateable;

  PROCEDURE validate_nonupdateable (
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     NUMBER,
      p_old_column_value                      IN     NUMBER,
      p_restricted                            IN     VARCHAR2 DEFAULT 'Y',
      x_return_status                         IN OUT NOCOPY VARCHAR2,
      p_raise_error                           IN     VARCHAR2 := 'Y'
 ) IS

      l_error                                 BOOLEAN := FALSE;

  BEGIN

      IF p_column_value IS NOT NULL THEN
          IF p_restricted = 'Y' THEN
              IF (p_column_value <> fnd_api.g_miss_num OR
                   p_old_column_value IS NOT NULL) AND
                 (p_old_column_value IS NULL OR
                   p_column_value <> p_old_column_value)
              THEN
                 l_error := TRUE;
              END IF;
          ELSE
              IF (p_old_column_value IS NOT NULL AND       -- Bug 3367582.
                  p_old_column_value <> FND_API.G_MISS_NUM)
                  AND
                 (p_column_value = fnd_api.g_miss_num OR
                   p_column_value <> p_old_column_value)
              THEN
                 l_error := TRUE;
              END IF;
          END IF;
      END IF;

      IF l_error THEN
        IF p_raise_error = 'Y' THEN
          fnd_message.set_name('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
          fnd_message.set_token('COLUMN', p_column);
          fnd_msg_pub.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_nonupdateable;

  PROCEDURE validate_nonupdateable (
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     DATE,
      p_old_column_value                      IN     DATE,
      p_restricted                            IN     VARCHAR2 DEFAULT 'Y',
      x_return_status                         IN OUT NOCOPY VARCHAR2,
      p_raise_error                           IN     VARCHAR2 := 'Y'
 ) IS

      l_error                                 BOOLEAN := FALSE;

  BEGIN

      IF p_column_value IS NOT NULL THEN
          IF p_restricted = 'Y' THEN
              IF (p_column_value <> FND_API.G_MISS_DATE OR
                   p_old_column_value IS NOT NULL) AND
                 (p_old_column_value IS NULL OR
                   p_column_value <> p_old_column_value)
              THEN
                 l_error := TRUE;
              END IF;
          ELSE
              IF (p_old_column_value IS NOT NULL AND        -- Bug 3367582
                  p_old_column_value <> FND_API.G_MISS_DATE)
                  AND
                 (p_column_value = FND_API.G_MISS_DATE OR
                   p_column_value <> p_old_column_value)
              THEN
                 l_error := TRUE;
              END IF;
          END IF;
      END IF;

      IF l_error THEN
        IF p_raise_error = 'Y' THEN
          fnd_message.set_name('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
          fnd_message.set_token('COLUMN', p_column);
          fnd_msg_pub.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_nonupdateable;

  PROCEDURE validate_start_end_date (
      p_create_update_flag                    IN     VARCHAR2,
      p_start_date_column_name                IN     VARCHAR2,
      p_start_date                            IN     DATE,
      p_old_start_date                        IN     DATE,
      p_end_date_column_name                  IN     VARCHAR2,
      p_end_date                              IN     DATE,
      p_old_end_date                          IN     DATE,
      x_return_status                         IN OUT NOCOPY VARCHAR2
 ) IS

      l_start_date                            DATE := p_old_start_date;
      l_end_date                              DATE := p_old_end_date;

  BEGIN

      IF p_create_update_flag = 'C' THEN
          l_start_date := p_start_date;
          l_end_date := p_end_date;
      ELSIF p_create_update_flag = 'U' THEN
          IF p_start_date IS NOT NULL
          THEN
              IF p_start_date = FND_API.G_MISS_DATE THEN
                  l_start_date := NULL;
              ELSE
                  l_start_date := p_start_date;
              END IF;
          END IF;

          IF p_end_date IS NOT NULL
          THEN
              IF p_end_date = FND_API.G_MISS_DATE THEN
                  l_end_date := NULL;
              ELSE
                  l_end_date := p_end_date;
              END IF;
          END IF;
      END IF;

      IF l_end_date IS NOT NULL AND
         l_end_date <> FND_API.G_MISS_DATE AND
         (l_start_date IS NULL OR
           l_start_date = FND_API.G_MISS_DATE OR
           l_start_date > l_end_date)
      THEN
          fnd_message.set_name('AR', 'HZ_API_DATE_GREATER');
          fnd_message.set_token('DATE2', p_end_date_column_name);
          fnd_message.set_token('DATE1', p_start_date_column_name);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_start_end_date;

  PROCEDURE validate_cannot_update_to_null (
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     VARCHAR2,
      x_return_status                         IN OUT NOCOPY VARCHAR2
 ) IS

  BEGIN

      IF p_column_value = fnd_api.g_miss_char THEN
          fnd_message.set_name('AR', 'HZ_API_NONUPDATEABLE_TO_NULL');
          fnd_message.set_token('COLUMN', p_column);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_cannot_update_to_null;

  PROCEDURE validate_cannot_update_to_null (
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     NUMBER,
      x_return_status                         IN OUT NOCOPY VARCHAR2
 ) IS

  BEGIN

      IF p_column_value = fnd_api.g_miss_num THEN
          fnd_message.set_name('AR', 'HZ_API_NONUPDATEABLE_TO_NULL');
          fnd_message.set_token('COLUMN', p_column);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_cannot_update_to_null;

  PROCEDURE validate_cannot_update_to_null (
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     DATE,
      x_return_status                         IN OUT NOCOPY VARCHAR2
 ) IS

  BEGIN

      IF p_column_value = FND_API.G_MISS_DATE THEN
          fnd_message.set_name('AR', 'HZ_API_NONUPDATEABLE_TO_NULL');
          fnd_message.set_token('COLUMN', p_column);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_cannot_update_to_null;

  PROCEDURE validate_lookup (
      p_column                                IN     VARCHAR2,
      p_lookup_table                          IN     VARCHAR2 DEFAULT 'AR_LOOKUPS',
      p_lookup_type                           IN     VARCHAR2,
      p_column_value                          IN     VARCHAR2,
      x_return_status                         IN OUT NOCOPY VARCHAR2
 ) IS

      l_error                                 BOOLEAN := FALSE;

  BEGIN

      IF p_column_value IS NOT NULL AND
         p_column_value <> fnd_api.g_miss_char THEN

          IF p_lookup_type = 'YES/NO' THEN
              IF p_column_value NOT IN ('Y', 'N') THEN
                  l_error := TRUE;
              END IF;
          ELSE
              IF NOT search(p_lookup_table || G_SPECIAL_STRING ||
                            p_lookup_type || G_SPECIAL_STRING || p_column_value,
                            'LOOKUP')
              THEN
                  l_error := TRUE;
              END IF;
          END IF;

          IF l_error THEN
              fnd_message.set_name('AR', 'HZ_API_INVALID_LOOKUP');
              fnd_message.set_token('COLUMN', p_column);
              fnd_message.set_token('LOOKUP_TYPE', p_lookup_type);
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
          END IF;
      END IF;

  END validate_lookup;

  PROCEDURE validate_country_code (
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     VARCHAR2,
      x_return_status                         IN OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

      IF p_column_value IS NOT NULL AND
         p_column_value <> FND_API.G_MISS_CHAR
      THEN
        IF NOT search(p_column_value || G_SPECIAL_STRING, 'FND_TERRITORIES')
        THEN
           fnd_message.set_name('AR', 'HZ_API_INVALID_COUNTRY_CODE');
           fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
        END IF;
      END IF;

  END validate_country_code;


  --
  -- PRIVATE PROCEDURE
  --   Main routine for contact point record validation.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_edi_rec            EDI record.
  --     p_eft_rec            EFT record.
  --     p_email_rec          Email record.
  --     p_phone_rec          Phone record.
  --     p_telex_rec          Telex record.
  --     p_web_rec            Web record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   05-DEC-2001   Joe del Callar      Bug 2116225: Modified to accept EFT
  --                                     records for bank consolidation.
  --                                     Bug 2117973: Modified to comply with
  --                                     PL/SQL coding standards.
  --   03-JAN-2002   P.Suresh            Bug No : 1946858. Added the validation that
  --                                     Inactive contact can never marked as
  --                                     preferred.
  --   17-FEB-2002   P.Suresh            Bug No : 1946858. Added the validation that
  --                                     contact_point_purpose cannot be null when
  --                                     primary_by_purpose is 'Y'.
  --   23-MAY-2002   Joe del Callar      Modified to NOT validate party type on
  --                                     EFT and EDI records during update mode
  --                                     since you are not updateable anyway.
  --   08-DEC-2003   Rajib Ranjan Borah  o Bug 2807379.Phone number column is not
  --                                     updateable to NULL.
  --   01-03-2005    Rajib Ranjan Borah  o SSM SST Integration and Extension.
  --                                     New user update rules will be used to check
  --                                     update privilege instead of checking against 'DNB'
  --                                     only.
  --   28-SEP-2005   Idris Ali           o Bug 4474646 Modified to make the error message
  --                                     more user friendly when the country code is invalid.
  --   10-SEP-2007   Neeraj Shinde       o Bug 6367289 : Added Validation - EFT type of
  --                                     contact point can only
  --                                     be assigned to Parties of type Organization.
  --   18-JUL-2008   Ajai Singh          o Bug 7046491 : Updated curser to compare the
  --                                     timezone from fnd_timezones_vl view.

  PROCEDURE validate_contact_point_main (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec             IN     hz_contact_point_v2pub.edi_rec_type := hz_contact_point_v2pub.g_miss_edi_rec,
    p_eft_rec             IN     hz_contact_point_v2pub.eft_rec_type := hz_contact_point_v2pub.g_miss_eft_rec,
    p_email_rec           IN     hz_contact_point_v2pub.email_rec_type := hz_contact_point_v2pub.g_miss_email_rec,
    p_phone_rec           IN     hz_contact_point_v2pub.phone_rec_type := hz_contact_point_v2pub.g_miss_phone_rec,
    p_telex_rec           IN     hz_contact_point_v2pub.telex_rec_type := hz_contact_point_v2pub.g_miss_telex_rec,
    p_web_rec             IN     hz_contact_point_v2pub.web_rec_type := hz_contact_point_v2pub.g_miss_web_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30) := ''; --'validate_contact_point'
    l_dummy                    VARCHAR2(10);
    l_fk_exist                 VARCHAR2(1);
    l_fk_column                VARCHAR2(30);
    l_error                    BOOLEAN := FALSE;
    l_return_status            VARCHAR2(1);

    l_owner_table_name         hz_contact_points.owner_table_name%TYPE;
    l_owner_table_id           NUMBER;
    l_contact_point_type       hz_contact_points.contact_point_type%TYPE :=
                                 p_contact_point_rec.contact_point_type;
    l_content_source_type      hz_contact_points.content_source_type%TYPE;
    l_orig_system_reference    hz_contact_points.orig_system_reference%TYPE;
    l_primary_flag             hz_contact_points.primary_flag%TYPE;
    l_preferred_flag           hz_contact_points.primary_by_purpose%TYPE;
    l_status                   hz_contact_points.status%TYPE;
    l_created_by_module        hz_contact_points.created_by_module%TYPE;
    l_application_id           NUMBER;
    l_contact_point_purpose    hz_contact_points.contact_point_purpose%TYPE;
    l_email_format             hz_contact_points.email_format%TYPE;
    l_phone_line_type          hz_contact_points.phone_line_type%TYPE;
    l_primary_by_purpose       hz_contact_points.primary_by_purpose%TYPE;

    -- Bug 2197181: added for mix-n-match
    db_actual_content_source   hz_contact_points.actual_content_source%TYPE;
    l_phone_area_code          hz_contact_points.phone_area_code%TYPE;
    l_phone_country_code       hz_contact_points.phone_country_code%TYPE;
    l_phone_number             hz_contact_points.phone_number%TYPE;
    l_phone_extension          hz_contact_points.phone_extension%TYPE;
    l_raw_phone_number         hz_contact_points.raw_phone_number%TYPE;
--  Bug 4226199 : Added for update validation
    l_email_address            hz_contact_points.email_address%TYPE;
    l_telex                    hz_contact_points.telex_number%TYPE;
    l_url                      hz_contact_points.url%TYPE;

    l_validate_osr varchar2(1) := 'Y';
    l_mosr_owner_table_id number;

    l_temp_return_status   VARCHAR2(10); -- for storing return status from
                                         -- hz_orig_system_ref_pub.get_owner_table_id

    -- Bug 2197181: selecting actual_content_source for mix-n-match
    -- Bug 4203495  selecting primary_flag
    CURSOR c_update IS
      SELECT hcp.owner_table_name,
             hcp.owner_table_id,
             hcp.contact_point_type,
             hcp.content_source_type,
             hcp.orig_system_reference,
             hcp.status,
             hcp.primary_flag,
             hcp.created_by_module,
             hcp.application_id,
             hcp.contact_point_purpose,
             hcp.email_format,
             hcp.phone_line_type,
             hcp.phone_country_code,
             hcp.primary_by_purpose,
             hcp.actual_content_source,
             hcp.phone_area_code,
             hcp.phone_country_code,
             hcp.phone_number,
             hcp.phone_extension,
             hcp.raw_phone_number,
      --  Bug 4226199 : Added for update validation
             hcp.email_address,
             hcp.telex_number,
             hcp.url
      FROM   hz_contact_points hcp
      WHERE  ROWID = p_rowid;

    CURSOR c_dup (p_contact_point_id IN NUMBER) IS
      SELECT 'Y'
      FROM   hz_contact_points hcp
      WHERE  hcp.contact_point_id = p_contact_point_id;

    CURSOR c_pexist (p_owner_table_id IN NUMBER) IS
      SELECT 'Y'
      FROM   hz_parties
      WHERE  party_id = p_owner_table_id;

    CURSOR c_psexist (p_owner_table_id IN NUMBER) IS
      SELECT 'Y'
      FROM   hz_party_sites hps
      WHERE  hps.party_site_id = p_owner_table_id;

    CURSOR c_timezone (p_timezone_id IN NUMBER) IS--updated against bug 7046491
      SELECT 'Y'
      FROM   fnd_timezones_vl ftl
      WHERE  ftl.upgrade_tz_id = p_timezone_id;

    CURSOR c_countrycode (p_phone_country_code IN VARCHAR2) IS
      SELECT 'Y'
      FROM   hz_phone_country_codes hpcc
      WHERE  hpcc.phone_country_code = p_phone_country_code
             AND ROWNUM = 1;

  BEGIN
    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_contact_point_main (+)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_contact_point_main (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    -- Select fields for later use during update.
    IF p_create_update_flag = 'U' THEN

    -- Bug 2197181: selecting actual_content_source for mix-n-match
    -- Bug 4203495: selecting primary_flag
      OPEN c_update;
      FETCH c_update
      INTO  l_owner_table_name,
            l_owner_table_id,
            l_contact_point_type,
            l_content_source_type,
            l_orig_system_reference,
            l_status,
            l_primary_flag,
            l_created_by_module,
            l_application_id,
            l_contact_point_purpose,
            l_email_format,
            l_phone_line_type,
            l_phone_country_code,
            l_primary_by_purpose,
            db_actual_content_source,
            l_phone_area_code,
            l_phone_country_code,
            l_phone_number,
            l_phone_extension,
            l_raw_phone_number,
      --  Bug 4226199 : Added for update validation
            l_email_address,
            l_telex,
            l_url;
      IF c_update%NOTFOUND THEN
        CLOSE c_update;
        -- Debug info.
        /*IF g_debug THEN
          hz_utility_v2pub.debug ('could not find record to update, rowid='||
                                  p_rowid);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'could not find record to update, rowid='||p_rowid,
                               p_msg_level=>fnd_log.level_statement);
        END IF;

        RAISE NO_DATA_FOUND;
      ELSE
        CLOSE c_update;
      END IF;
    END IF;

    --------------------------------------
    -- validate contact_point_id
    --------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- If primary key value is passed, check for uniqueness.
    -- If primary key value is not passed, it will be generated
    -- from sequence by table handler.

    IF p_create_update_flag = 'C' THEN
      IF p_contact_point_rec.contact_point_id IS NOT NULL AND
         p_contact_point_rec.contact_point_id <> fnd_api.g_miss_num
      THEN
        OPEN c_dup (p_contact_point_rec.contact_point_id);
        FETCH c_dup INTO l_dummy;

        -- key is not unique, push an error onto the stack.
        IF NVL(c_dup%FOUND, FALSE) THEN
          fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
          fnd_message.set_token('COLUMN', 'contact_point_id');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
        CLOSE c_dup;

        /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'check that contact_point_id is unique during creation. ' ||
            ' x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'check that contact_point_id is unique during creation. ' ||
                                             ' x_return_status = ' || x_return_status,

                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF;
    END IF;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validate contact_point_id ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate contact_point_id ... ' ||
                                             'x_return_status = ' || x_return_status,

                                  p_msg_level=>fnd_log.level_statement);
    END IF;
  END IF;

    --------------------------------------
    -- validate contact_point_type
    --------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- contact_point_type is mandatory field
    -- Since contact_point_type is non-updateable, we only need to check
    -- mandatory during creation.

    IF p_create_update_flag = 'C' THEN
      validate_mandatory (
        p_create_update_flag     => p_create_update_flag,
        p_column                 => 'contact_point_type',
        p_column_value           => p_contact_point_rec.contact_point_type,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'contact_point_type is mandatory. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'contact_point_type is mandatory. ' ||
                                                'x_return_status = ' || x_return_status,

                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    END IF;

    -- contact_point_type is non-updateable field
    IF p_create_update_flag = 'U' AND
       p_contact_point_rec.contact_point_type IS NOT NULL
    THEN
      validate_nonupdateable (
        p_column                 => 'contact_point_type',
        p_column_value           => p_contact_point_rec.contact_point_type,
        p_old_column_value       => l_contact_point_type,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'contact_point_type is non-updateable. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'contact_point_type is non-updateable. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -- contact_point_type is lookup code in lookup type COMMUNICATION_TYPE
    -- Since contact_point_type is non-updateable, we only need to do checking
    -- in creation mode.

    IF p_create_update_flag = 'C' THEN
      validate_lookup (
        p_column                 => 'contact_point_type',
        p_lookup_type            => 'COMMUNICATION_TYPE',
        p_column_value           => p_contact_point_rec.contact_point_type,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'contact_point_type is lookup code in lookup type COMMUNICATION_TYPE. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'contact_point_type is lookup code in lookup type COMMUNICATION_TYPE. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validate contact_point_type ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate contact_point_type ... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
  END IF;

    --------------------------------------
    -- validate owner_table_name
    --------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- owner_table_name is mandatory field
    -- Since owner_table_name is non-updateable, we only need to check
    -- mandatory during creation.

    IF p_create_update_flag = 'C' THEN
      validate_mandatory (
        p_create_update_flag     => p_create_update_flag,
        p_column                 => 'owner_table_name',
        p_column_value           => p_contact_point_rec.owner_table_name,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'owner_table_name is mandatory. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'owner_table_name is mandatory. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -- owner_table_name is non-updateable field
    IF p_create_update_flag = 'U' AND
       p_contact_point_rec.owner_table_name IS NOT NULL
    THEN
      validate_nonupdateable (
        p_column                 => 'owner_table_name',
        p_column_value           => p_contact_point_rec.owner_table_name,
        p_old_column_value       => l_owner_table_name,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'owner_table_name is non-updateable. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'owner_table_name is non-updateable. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -- owner_table_name is lookup code in lookup type OWNER_TABLE_NAME
    -- Since owner_table_name is non-updateable, we only need to do checking
    -- in creation mode.

    IF p_create_update_flag = 'C' THEN
      validate_lookup (
        p_column                 => 'owner_table_name',
        p_lookup_type            => 'OWNER_TABLE_NAME',
        p_column_value           => p_contact_point_rec.owner_table_name,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'owner_table_name is lookup code in lookup type OWNER_TABLE_NAME. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'owner_table_name is lookup code in lookup type OWNER_TABLE_NAME. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validate owner_table_name ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate owner_table_name ... ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
  END IF;

    --------------------------------------
    -- validate owner_table_id
    --------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- owner_table_id is mandatory field
    -- Since owner_table_id is non-updateable, we only need to check mandatory
    -- during creation.

    IF p_create_update_flag = 'C' THEN
      validate_mandatory (
        p_create_update_flag     => p_create_update_flag,
        p_column                 => 'owner_table_id',
        p_column_value           => p_contact_point_rec.owner_table_id,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'owner_table_id is mandatory. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'owner_table_id is mandatory. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -- owner_table_id is non-updateable field
    IF p_create_update_flag = 'U' AND
       p_contact_point_rec.owner_table_id IS NOT NULL
    THEN
      validate_nonupdateable (
        p_column                 => 'owner_table_id',
        p_column_value           => p_contact_point_rec.owner_table_id,
        p_old_column_value       => l_owner_table_id,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'owner_table_id is non-updateable. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'owner_table_id is non-updateable. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -- owner_table_id is foreign key of hz_parties if
    -- owner_table_name = HZ_PARTIES and is foreign key
    -- of hz_party_sites if owner_table_name = HZ_PARTY_SITES.

    -- Do not need to check during update because owner_table_id is
    -- non-updateable.
    IF p_create_update_flag = 'C' THEN
      IF p_contact_point_rec.owner_table_name = 'HZ_PARTIES' THEN
        OPEN c_pexist(p_contact_point_rec.owner_table_id);
        FETCH c_pexist INTO l_fk_exist;

        IF c_pexist%NOTFOUND THEN
          l_fk_exist := 'N';
          l_fk_column := 'party_id';
        END IF;

        CLOSE c_pexist;
      ELSIF p_contact_point_rec.owner_table_name = 'HZ_PARTY_SITES' THEN
        OPEN c_psexist(p_contact_point_rec.owner_table_id);
        FETCH c_psexist INTO l_fk_exist;

        IF c_psexist%NOTFOUND THEN
          l_fk_exist := 'N';
          l_fk_column := 'party_site_id';
        END IF;

        CLOSE c_psexist;
      ELSE
        l_fk_exist := 'Y';
      END IF;

      IF l_fk_exist = 'N' THEN
        fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
        fnd_message.set_token('FK', 'owner_table_id');
        fnd_message.set_token('COLUMN', l_fk_column);
        fnd_message.set_token('TABLE',
                              LOWER(p_contact_point_rec.owner_table_name));
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
       hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
       p_message=>'owner_table_id is foreign key of hz_parties if owner_table_name = HZ_PARTIES and is foreign key of hz_party_sites if owner_table_name = HZ_PARTY_SITES. ' ||
                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validate owner_table_id ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate owner_table_id ... ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
  END IF;

    --------------------------------------
    -- validate orig_system_reference
    --------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    IF (p_contact_point_rec.orig_system is not null
         and p_contact_point_rec.orig_system <>fnd_api.g_miss_char)
       and (p_contact_point_rec.orig_system_reference is not null
         and p_contact_point_rec.orig_system_reference <>fnd_api.g_miss_char)
         and p_create_update_flag = 'U'
    then
        hz_orig_system_ref_pub.get_owner_table_id
                        (p_orig_system => p_contact_point_rec.orig_system,
                        p_orig_system_reference => p_contact_point_rec.orig_system_reference,
                        p_owner_table_name => 'HZ_CONTACT_POINTS',
                        x_owner_table_id => l_mosr_owner_table_id,
                        x_return_status => l_temp_return_status);

        IF (l_temp_return_status = fnd_api.g_ret_sts_success AND
		    l_mosr_owner_table_id= nvl(p_contact_point_rec.contact_point_id,l_mosr_owner_table_id))
        THEN
                l_validate_osr := 'N';
        -- if we can get owner_table_id based on osr and os in mosr table,
        -- we will use unique osr and os for update - bypass osr validation
        ELSE l_validate_osr := 'Y';
        END IF;

        -- Call to hz_orig_system_ref_pub.get_owner_table_id API was resetting the
		-- x_return_status. Set x_return_status to error, ONLY if there is error.
		-- In case of success, leave it to carry over previous value as before this call.
		-- Fix for Bug 5498116 (29-AUG-2006)
        IF (l_temp_return_status = FND_API.G_RET_STS_ERROR) THEN
          x_return_status := l_temp_return_status;
        END IF;

    end if;
    -- orig_system_reference is non-updateable field
    IF p_create_update_flag = 'U' AND
       p_contact_point_rec.orig_system_reference IS NOT NULL and l_validate_osr = 'Y'
    THEN
      validate_nonupdateable (
        p_column                 => 'orig_system_reference',
        p_column_value           => p_contact_point_rec.orig_system_reference,
        p_old_column_value       => l_orig_system_reference,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'orig_system_reference is non-updateable. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'orig_system_reference is non-updateable. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validate orig_system_reference ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate orig_system_reference ... ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
  END IF;

    /* Bug 2197181: removed content_source_type validation as this
       column has been obsoleted for mix-n-match project.

    --------------------------------------
    -- validate content_source_type
    --------------------------------------

    -- do not need to check content_source_type is mandatory because
    -- we default content_source_type to hz_party_v2pub.g_miss_content_source_type
    -- in table handler.

    -- content_source_type is non-updateable
    IF p_create_update_flag = 'U' THEN
      validate_nonupdateable (
        p_column                 => 'content_source_type',
        p_column_value           => p_contact_point_rec.content_source_type,
        p_old_column_value       => l_content_source_type,
        x_return_status          => x_return_status);


      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'content_source_type is non-updateable. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -- content_source_type is lookup code in lookup type CONTENT_SOURCE_TYPE
    IF p_create_update_flag = 'C' AND
       p_contact_point_rec.content_source_type <>
         hz_party_v2pub.g_miss_content_source_type
    THEN
      validate_lookup (
        p_column                 => 'content_source_type',
        p_lookup_type            => 'CONTENT_SOURCE_TYPE',
        p_column_value           => p_contact_point_rec.content_source_type,
        x_return_status          => x_return_status);

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'content_source_type is lookup code in lookup type CONTENT_SOURCE_TYPE. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;


    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate content_source_type ... ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    */

    -- Bug 2197181: Added validation for mix-n-match

    ----------------------------------------
    -- validate content_source_type and actual_content_source_type
    ----------------------------------------

    HZ_MIXNM_UTILITY.ValidateContentSource (
      p_api_version                       => 'V2',
      p_create_update_flag                => p_create_update_flag,
      p_check_update_privilege            => 'N',
      p_content_source_type               => p_contact_point_rec.content_source_type,
      p_old_content_source_type           => l_content_source_type,
      p_actual_content_source             => p_contact_point_rec.actual_content_source,
      p_old_actual_content_source         => db_actual_content_source,
      p_entity_name                       => 'HZ_CONTACT_POINTS',
      x_return_status                     => x_return_status );

    --------------------------------------
    -- validate status
    --------------------------------------

    -- status cannot be set to null during update
    IF p_create_update_flag = 'U' AND
       p_contact_point_rec.status IS NOT NULL
    THEN
      validate_cannot_update_to_null (
        p_column                 => 'status',
        p_column_value           => p_contact_point_rec.status,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'Status cannot be updated to null. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Status cannot be updated to null. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- status is lookup code in lookup type REGISTRY_STATUS
    IF p_contact_point_rec.status IS NOT NULL AND
       p_contact_point_rec.status <> fnd_api.g_miss_char AND
       (p_create_update_flag = 'C' OR
        (p_create_update_flag = 'U' AND
         p_contact_point_rec.status <> NVL(l_status, fnd_api.g_miss_char)))
    THEN
      validate_lookup (
        p_column                 => 'status',
        p_lookup_type            => 'REGISTRY_STATUS',
        p_column_value           => p_contact_point_rec.status,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'status is lookup code in lookup type REGISTRY_STATUS. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                                              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;
  END IF;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validate status ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate status ... ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    --------------------------------------
    -- validate primary_flag
    --------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- primary_flag is lookup code in lookup type YES/NO
    IF p_contact_point_rec.primary_flag IS NOT NULL AND
       p_contact_point_rec.primary_flag <> fnd_api.g_miss_char
    THEN
      validate_lookup (
        p_column                 => 'primary_flag',
        p_lookup_type            => 'YES/NO',
        p_column_value           => p_contact_point_rec.primary_flag,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'primary_flag is lookup code in lookup type YES/NO. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'primary_flag is lookup code in lookup type YES/NO. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;
  END IF;

    -- check to ensure that an inactive contact is never marked
    -- as primary.
    IF p_create_update_flag = 'C' THEN
      IF p_contact_point_rec.primary_flag IS NULL OR
         p_contact_point_rec.primary_flag = fnd_api.g_miss_char
      THEN
        l_primary_flag := 'N';
      ELSE
        l_primary_flag := p_contact_point_rec.primary_flag;
      END IF;

      IF p_contact_point_rec.status IS NULL OR
         p_contact_point_rec.status = fnd_api.g_miss_char
      THEN
        l_status := 'A';
      ELSE
        l_status := p_contact_point_rec.status;
      END IF;

      IF l_primary_flag = 'Y' AND l_status <> 'A' THEN
        l_error := TRUE;
      END IF;
    ELSE
      IF p_contact_point_rec.primary_flag = 'Y' AND
         /* Bug Fix: 4203495 */
         l_primary_flag <> 'Y'                  AND
         ((p_contact_point_rec.status IS NOT NULL AND
           p_contact_point_rec.status <> 'A') OR
          (p_contact_point_rec.status IS NULL AND
           l_status <> 'A'))
      THEN
        l_error := TRUE;
      END IF;
    END IF;

    IF l_error THEN
      fnd_message.set_name('AR', 'HZ_API_INACTIVE_NOT_PRIMARY');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      -- reset l_error for later use.
          l_error := FALSE;
    END IF;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        'an inactive contact is never marked as primary. ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'an inactive contact is never marked as primary. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- check to ensure that an inactive contact is never marked
    -- as preferred.
    IF p_create_update_flag = 'C' THEN
      IF p_contact_point_rec.primary_by_purpose IS NULL OR
         p_contact_point_rec.primary_by_purpose = fnd_api.g_miss_char
      THEN
        l_preferred_flag := 'N';
      ELSE
        l_preferred_flag := p_contact_point_rec.primary_by_purpose;
      END IF;
      IF l_preferred_flag = 'Y' AND l_status <> 'A' THEN
        l_error := TRUE;
      END IF;
    ELSE
      IF p_contact_point_rec.primary_by_purpose = 'Y' AND
         ((p_contact_point_rec.status IS NOT NULL AND
           p_contact_point_rec.status <> 'A') OR
          (p_contact_point_rec.status IS NULL AND
           l_status <> 'A'))
      THEN
        l_error := TRUE;
      END IF;
    END IF;
       IF l_error THEN
          fnd_message.set_name('AR', 'HZ_API_INACTIVE_NOT_PREFERRED');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;

          -- reset l_error for later use.
          l_error := FALSE;
       END IF;
    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        'an inactive contact is never marked as preferred. ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'an inactive contact is never marked as preferred. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    ---------------------------------------------------------
    -- validate primary_by_purpose + contact_point_purpose --
    -- Bug No : 1946858
    ---------------------------------------------------------

    IF (p_create_update_flag = 'C')
    THEN
       IF p_contact_point_rec.primary_by_purpose = 'Y'
       THEN
          IF (p_contact_point_rec.contact_point_purpose IS NULL OR
              p_contact_point_rec.contact_point_purpose = FND_API.G_MISS_CHAR)
          THEN
             -- Error
             FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MAND_DEP_FIELDS' );
             FND_MESSAGE.SET_TOKEN('COLUMN1', 'primary_by_purpose');
             FND_MESSAGE.SET_TOKEN('VALUE1', 'Y');
             FND_MESSAGE.SET_TOKEN('COLUMN2','contact_point_purpose');
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;

          END IF;
       END IF;
    ELSIF (p_create_update_flag = 'U') THEN
        IF (  p_contact_point_rec.primary_by_purpose = 'Y' OR
            ( p_contact_point_rec.primary_by_purpose IS NULL AND
              l_primary_by_purpose = 'Y'))
        THEN
          IF ( p_contact_point_rec.contact_point_purpose = FND_API.G_MISS_CHAR OR
               ( p_contact_point_rec.contact_point_purpose IS NULL AND
                 l_contact_point_purpose IS NULL))
          THEN
            -- Error
             FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MAND_DEP_FIELDS' );
             FND_MESSAGE.SET_TOKEN('COLUMN1', 'primary_by_purpose');
             FND_MESSAGE.SET_TOKEN('VALUE1', 'Y');
             FND_MESSAGE.SET_TOKEN('COLUMN2','contact_point_purpose');
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
    END IF;
    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        'Purpose cannot be NULL when the contact point is preferred ' ||'x_return_status = ' ||
         x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'Purpose cannot be NULL when the contact point is preferred ' ||'x_return_status = ' ||
                                                x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;



    --------------------------------------
    -- validate contact_point_purpose
    --------------------------------------

    -- contact_point_purpose is lookup code in lookup type CONTACT_POINT_PURPOSE
    -- if contact_point_type <> 'WEB'. Please note, contact_point_type is
    -- mandatory and non-updateable.

    IF ((p_contact_point_rec.contact_point_type <> 'WEB' AND
         p_create_update_flag = 'C') OR
        (l_contact_point_type <> 'WEB' AND
         p_create_update_flag = 'U')) AND
        p_contact_point_rec.contact_point_purpose IS NOT NULL AND
        p_contact_point_rec.contact_point_purpose <> fnd_api.g_miss_char AND
        (p_create_update_flag = 'C' OR
         (p_create_update_flag = 'U' AND
          p_contact_point_rec.contact_point_purpose <>
            NVL(l_contact_point_purpose, fnd_api.g_miss_char)))
    THEN
      validate_lookup (
        p_column                 => 'contact_point_purpose',
        p_lookup_type            => 'CONTACT_POINT_PURPOSE',
        p_column_value           => p_contact_point_rec.contact_point_purpose,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'contact_point_purpose is lookup code in lookup type CONTACT_POINT_PURPOSE if contact_point_type <> WEB. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'contact_point_purpose is lookup code in lookup type CONTACT_POINT_PURPOSE if contact_point_type <> WEB. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validate contact_point_purpose ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate contact_point_purpose ... ' ||
                                             'x_return_status = ' || x_return_status,

                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    --------------------------------------
    -- validate primary_by_purpose
    --------------------------------------

    -- primary_by_purpose is lookup code in lookup type YES/NO
    IF p_contact_point_rec.primary_by_purpose IS NOT NULL AND
       p_contact_point_rec.primary_by_purpose <> fnd_api.g_miss_char
    THEN
      validate_lookup (
        p_column                 => 'primary_by_purpose',
        p_lookup_type            => 'YES/NO',
        p_column_value           => p_contact_point_rec.primary_by_purpose,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'primary_by_purpose is lookup code in lookup type YES/NO. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'primary_by_purpose is lookup code in lookup type YES/NO. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validate primary_by_purpose ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate primary_by_purpose ... ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    --------------------------------------
    -- validate created_by_module
    --------------------------------------

    validate_created_by_module(
      p_create_update_flag     => p_create_update_flag,
      p_created_by_module      => p_contact_point_rec.created_by_module,
      p_old_created_by_module  => l_created_by_module,
      x_return_status          => x_return_status);

    --------------------------------------
    -- validate application_id
    --------------------------------------

    validate_application_id(
      p_create_update_flag     => p_create_update_flag,
      p_application_id         => p_contact_point_rec.application_id,
      p_old_application_id     => l_application_id,
      x_return_status          => x_return_status);

    --------------------------------------
    -- validation based on different contact point type
    --------------------------------------

    -- l_contact_point_type is equal to p_contact_point_rec.contact_point_type
    -- during creation and is database value during update. Please note,
    -- contact_point_type is mandatory and non-updateable.

    IF l_contact_point_type = 'EDI' THEN

      --------------------------------------
      -- validate edi_id_number
      --------------------------------------
-- Bug 2384750. Commented the mandatory check on edi_id_number.
/**
  -- edi_id_number is mandatory field.
      validate_mandatory (
        p_create_update_flag     => p_create_update_flag,
        p_column                 => 'edi_id_number',
        p_column_value           => p_edi_rec.edi_id_number,
        x_return_status          => x_return_status);


      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'EDI : edi_id_number is mandatory. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

**/
      --------------------------------------
      -- validate edi party type only when the record is being created.
      --------------------------------------

      IF p_create_update_flag = 'C' THEN
        validate_party_type(
          p_table_name          => p_contact_point_rec.owner_table_name,
          p_party_id            => p_contact_point_rec.owner_table_id,
          p_contact_point_type  => l_contact_point_type,
          x_return_status       => x_return_status
        );
      END IF;
    ELSIF l_contact_point_type = 'EFT' THEN
      -- Bug 2116225: no validations currently required.  This code is just
      -- currently just a placeholder.
      -- Bug 6367289: validation added - EFT contact point can be assigned
      -- to organization party type only.
      --NULL;
      IF p_create_update_flag = 'C' THEN
              validate_party_type(
                p_table_name          => p_contact_point_rec.owner_table_name,
                p_party_id            => p_contact_point_rec.owner_table_id,
                p_contact_point_type  => l_contact_point_type,
                x_return_status       => x_return_status
              );
      END IF;
    ELSIF l_contact_point_type = 'EMAIL' THEN

      --------------------------------------
      -- validate email_format
      --------------------------------------

      -- email_format is mandatory but can be defaulted to MAILHTML during
      -- creation. It should be 'cannot_update_to_null' during update.

      IF p_create_update_flag = 'U' AND
         p_email_rec.email_format IS NOT NULL
      THEN
        validate_cannot_update_to_null (
          p_column                 => 'email_format',
          p_column_value           => p_email_rec.email_format,
          x_return_status          => x_return_status);

        /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'EMAIL : email_format cannot be updated to null. ' ||
            'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'EMAIL : email_format cannot be updated to null. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF;
        --  Bug 4226199 : check update privilege for email also
      IF p_create_update_flag = 'U' AND
      db_actual_content_source <> 'USER_ENTERED' THEN
          l_return_status := FND_API.G_RET_STS_SUCCESS;
          validate_nonupdateable (
          p_column                 => 'email_address',
          p_column_value           => p_email_rec.email_address,
          p_old_column_value       => l_email_address,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		HZ_MIXNM_UTILITY.CheckUserUpdatePrivilege(
		p_actual_content_source    => db_actual_content_source,
		p_new_actual_content_source=> p_contact_point_rec.actual_content_source,
		p_entity_name              => 'HZ_CONTACT_POINTS',
		x_return_status            => x_return_status);
-- Bug 4693719 : set global variable to Y
         HZ_UTILITY_V2PUB.G_UPDATE_ACS := 'Y';
         END IF;
        END IF;


      -- email_format is lookup code in lookup type EMAIL_FORMAT
      IF p_email_rec.email_format IS NOT NULL AND
         p_email_rec.email_format <> fnd_api.g_miss_char AND
         (p_create_update_flag = 'C' OR
          (p_create_update_flag = 'U' AND
           p_email_rec.email_format <>
             NVL(l_email_format, fnd_api.g_miss_char)))
      THEN
        validate_lookup (
          p_column                 => 'email_format',
          p_lookup_type            => 'EMAIL_FORMAT',
          p_column_value           => p_email_rec.email_format,
          x_return_status          => x_return_status);

        /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'EMAIL : email_format is lookup code in lookup type EMAIL_FORMAT. '
            || 'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'EMAIL : email_format is lookup code in lookup type EMAIL_FORMAT. '
                                                || 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          '(+) after validate email_format ... ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) after validate email_format ... ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      --------------------------------------
      -- validate email_address
      --------------------------------------

      -- email_address is mandatory field.
      validate_mandatory (
        p_create_update_flag     => p_create_update_flag,
        p_column                 => 'email_address',
        p_column_value           => p_email_rec.email_address,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'EMAIL : email_address is mandatory. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'EMAIL : email_address is mandatory. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


    ELSIF l_contact_point_type = 'PHONE' THEN

      --------------------------------------
      -- validate phone_number and raw_phone_number
      --------------------------------------

      -- phone_number and phone_area_code or raw_phone_umber must be
      -- passed in. However, you can not pass both two.

      IF p_create_update_flag = 'C' THEN
        IF ((p_phone_rec.phone_number IS NULL OR
             p_phone_rec.phone_number = fnd_api.g_miss_char) AND
            (p_phone_rec.raw_phone_number IS NULL OR
             p_phone_rec.raw_phone_number = fnd_api.g_miss_char)) OR
            ((p_phone_rec.phone_number IS NOT NULL AND
              p_phone_rec.phone_number <> fnd_api.g_miss_char) AND
             (p_phone_rec.raw_phone_number IS NOT NULL AND
              p_phone_rec.raw_phone_number <> fnd_api.g_miss_char))
        THEN
          l_error := TRUE;
        END IF;
      ELSE
        IF p_phone_rec.phone_number IS NOT NULL AND
           p_phone_rec.raw_phone_number IS NOT NULL AND
           ((p_phone_rec.phone_number = fnd_api.g_miss_char AND
             p_phone_rec.raw_phone_number = fnd_api.g_miss_char) OR
             (p_phone_rec.phone_number <> fnd_api.g_miss_char AND
              p_phone_rec.raw_phone_number <> fnd_api.g_miss_char))
        THEN
          l_error := TRUE;
        END IF;
      END IF;

      IF l_error THEN
        fnd_message.set_name('AR', 'HZ_INVALID_PHONE_PARAMETER');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;

        -- Reset l_error for later use.
        l_error := TRUE;
      END IF;
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'PHONE : phone_number and phone_area_code or raw_phone_umber must be passed in. However, you can not pass both two. ' || 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      --------------------------------------
      -- validate phone_line_type
      --------------------------------------

      -- phone_line_type is mandatory field.
      validate_mandatory (
        p_create_update_flag     => p_create_update_flag,
        p_column                 => 'phone_line_type',
        p_column_value           => p_phone_rec.phone_line_type,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'PHONE : phone_line_type is mandatory. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'PHONE : phone_line_type is mandatory. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -- phone_line_type is lookup code in lookup type PHONE_LINE_TYPE
      IF p_phone_rec.phone_line_type IS NOT NULL AND
         p_phone_rec.phone_line_type <> fnd_api.g_miss_char AND
         (p_create_update_flag = 'C' OR
          (p_create_update_flag = 'U' AND
           p_phone_rec.phone_line_type <> NVL(l_phone_line_type,
                                              fnd_api.g_miss_char)))
      THEN
        validate_lookup (
          p_column                 => 'phone_line_type',
          p_lookup_type            => 'PHONE_LINE_TYPE',
          p_column_value           => p_phone_rec.phone_line_type,
          x_return_status          => x_return_status);

        /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'PHONE : phone_line_type is lookup code in lookup type PHONE_LINE_TYPE. ' ||
            'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'PHONE : phone_line_type is lookup code in lookup type PHONE_LINE_TYPE. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          '(+) after validate phone_line_type ... ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate phone_line_type ... ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      --------------------------------------
      -- validate timezone_id
      --------------------------------------

      -- timezone_id is foreign key of hz_timezones
      IF p_phone_rec.timezone_id IS NOT NULL AND
         p_phone_rec.timezone_id <> fnd_api.g_miss_num
      THEN
        OPEN c_timezone(p_phone_rec.timezone_id);
        FETCH c_timezone INTO l_dummy;

        IF c_timezone%NOTFOUND THEN--updated against bug 7046491
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'upgrade_tz_id');
          fnd_message.set_token('COLUMN', 'upgrade_tz_id');
          fnd_message.set_token('TABLE', 'fnd_timezones_vl');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;

        CLOSE c_timezone;

        /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'PHONE : timezone_id is foreign key of hz_timezones. ' ||
            'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'PHONE : timezone_id is foreign key of hz_timezones. ' ||
                                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          '(+) after validate timezone_id ... ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) after validate timezone_id ... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      --------------------------------------
      -- validate phone_country_code
      --------------------------------------

      -- phone_country_code is foreign key of hz_phone_country_codes
      -- Bug 2007066: during update, only validate phone_country_code if it
      -- has been changed.
      IF p_phone_rec.phone_country_code IS NOT NULL AND
         p_phone_rec.phone_country_code <> fnd_api.g_miss_char AND
         (p_create_update_flag = 'C' OR
          (p_create_update_flag = 'U' AND
           p_phone_rec.phone_country_code <> NVL(l_phone_country_code,
                                                 fnd_api.g_miss_char)))
      THEN
        OPEN c_countrycode(p_phone_rec.phone_country_code);
        FETCH c_countrycode INTO l_dummy;

        IF c_countrycode%NOTFOUND THEN
        --Bug 4474646
          fnd_message.set_name('AR', 'HZ_INVALID_PHONE_COUNTRY_CODE');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;

        CLOSE c_countrycode;

        /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'PHONE : phone_country_code is foreign key of hz_phone_country_codes. ' ||
            'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'PHONE : phone_country_code is foreign key of hz_phone_country_codes. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          '(+) after validate phone_country_code ... ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) after validate phone_country_code ... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;


      --------------------------------------
      -- validate phone_number (Bug fix 2807379)
      --------------------------------------

      IF p_create_update_flag = 'U'
      AND p_phone_rec.raw_phone_number is NULL
      THEN
        validate_cannot_update_to_null(
          p_column        => 'phone_number',
          p_column_value  => p_phone_rec.phone_number,
          x_return_status => l_return_status);

        /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            '(+) phone_number cannot be updated to NULL... ' ||
            'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) phone_number cannot be updated to NULL... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          '(+) after validate phone_number ... ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) after validate phone_number ... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


    --------------------------------------
    -- validate phone_number and raw_phone_number which are third-party sourced.
    --------------------------------------

    -- phone_number and raw_phone_number can not be updated by the user if
    -- actual_content_source = 'DNB'.

    IF p_create_update_flag = 'U' AND
       l_contact_point_type = 'PHONE' AND
	--  Bug 4226199 : Call for all ACS other than UE
       db_actual_content_source <> 'USER_ENTERED' AND
       (p_phone_rec.phone_area_code||
        p_phone_rec.phone_country_code||
        p_phone_rec.phone_number||
        p_phone_rec.phone_extension||
        p_phone_rec.raw_phone_number IS NOT NULL) /* AND
       db_actual_content_source = 'DNB' AND*/
       -- SSM SST Integration and Extension
       --NVL(FND_PROFILE.value('HZ_UPDATE_THIRD_PARTY_DATA'), 'N') = 'N'
      -- HZ_UTILITY_V2PUB.is_purchased_content_source(db_actual_content_source) = 'Y'
    THEN
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      validate_nonupdateable (
        p_column                 => 'phone_area_code',
        p_column_value           => p_phone_rec.phone_area_code,
        p_old_column_value       => l_phone_area_code,
        x_return_status          => l_return_status,
        p_raise_error            => 'N');

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        validate_nonupdateable (
          p_column                 => 'phone_country_code',
          p_column_value           => p_phone_rec.phone_country_code,
          p_old_column_value       => l_phone_country_code,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');
      END IF;

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        validate_nonupdateable (
          p_column                 => 'phone_number',
          p_column_value           => p_phone_rec.phone_number,
          p_old_column_value       => l_phone_number,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');
      END IF;
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        validate_nonupdateable (
          p_column                 => 'phone_extension',
          p_column_value           => p_phone_rec.phone_extension,
          p_old_column_value       => l_phone_extension,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');
      END IF;

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        validate_nonupdateable (
          p_column                 => 'raw_phone_number',
          p_column_value           => p_phone_rec.raw_phone_number,
          p_old_column_value       => l_raw_phone_number,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          HZ_MIXNM_UTILITY.CheckUserUpdatePrivilege(
             p_actual_content_source    => db_actual_content_source,
             p_new_actual_content_source=> p_contact_point_rec.actual_content_source,
             p_entity_name              => 'HZ_CONTACT_POINTS',
             x_return_status            => x_return_status);
-- Bug 4693719 : set global variable to Y
         HZ_UTILITY_V2PUB.G_UPDATE_ACS := 'Y';

      /*FND_MESSAGE.SET_NAME('AR', 'HZ_NOTALLOW_UPDATE_THIRD_PARTY');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      */
      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'dnb phones are non-updateable. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'dnb phones are non-updateable. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;

    END IF;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validate dnb phones ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate dnb phones ... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    ELSIF l_contact_point_type = 'TLX' THEN

      --------------------------------------
      -- validate telex_number
      --------------------------------------

      -- telex_number is mandatory field.
      validate_mandatory (
        p_create_update_flag     => p_create_update_flag,
        p_column                 => 'telex_number',
        p_column_value           => p_telex_rec.telex_number,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'TELEX : telex_number is mandatory. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'TELEX : telex_number is mandatory. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

        --  Bug 4226199 : check update privilege for telex_number also
      IF p_create_update_flag = 'U' AND
      db_actual_content_source <> 'USER_ENTERED' THEN
          l_return_status := FND_API.G_RET_STS_SUCCESS;
          validate_nonupdateable (
          p_column                 => 'telex_number',
          p_column_value           => p_telex_rec.telex_number,
          p_old_column_value       => l_telex,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		HZ_MIXNM_UTILITY.CheckUserUpdatePrivilege(
		p_actual_content_source    => db_actual_content_source,
		p_new_actual_content_source=> p_contact_point_rec.actual_content_source,
		p_entity_name              => 'HZ_CONTACT_POINTS',
		x_return_status            => x_return_status);
-- Bug 4693719 : set global variable to Y
         HZ_UTILITY_V2PUB.G_UPDATE_ACS := 'Y';
         END IF;
      END IF;

    ELSIF l_contact_point_type = 'WEB' THEN

      --------------------------------------
      -- validate web_type
      --------------------------------------

      -- web_type is mandatory field.
      validate_mandatory (
        p_create_update_flag     => p_create_update_flag,
        p_column                 => 'web_type',
        p_column_value           => p_web_rec.web_type,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'WEB : web_type is mandatory. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'WEB : web_type is mandatory. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;


      --------------------------------------
      -- validate url
      --------------------------------------

      -- url is mandatory field.
      validate_mandatory (
        p_create_update_flag     => p_create_update_flag,
        p_column                 => 'url',
        p_column_value           => p_web_rec.url,
        x_return_status          => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'WEB : url is mandatory. ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'WEB : url is mandatory. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;

        --  Bug 4226199 : check update privilege for url also
      IF p_create_update_flag = 'U' AND
      db_actual_content_source <> 'USER_ENTERED' THEN
          l_return_status := FND_API.G_RET_STS_SUCCESS;
          validate_nonupdateable (
          p_column                 => 'url',
          p_column_value           => p_web_rec.url,
          p_old_column_value       => l_url,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		HZ_MIXNM_UTILITY.CheckUserUpdatePrivilege(
		p_actual_content_source    => db_actual_content_source,
		p_new_actual_content_source=> p_contact_point_rec.actual_content_source,
		p_entity_name              => 'HZ_CONTACT_POINTS',
		x_return_status            => x_return_status);
-- Bug 4693719 : set global variable to Y
         HZ_UTILITY_V2PUB.G_UPDATE_ACS := 'Y';
         END IF;
      END IF;

      --------------------------------------
      -- validate contact_point_purpose
      --------------------------------------

      -- contact_point_purpose is lookup code in lookup type
      -- CONTACT_POINT_PURPOSE_WEB if contact_point_type = 'WEB'.

      IF p_contact_point_rec.contact_point_purpose IS NOT NULL AND
         p_contact_point_rec.contact_point_purpose <> fnd_api.g_miss_char AND
         (p_create_update_flag = 'C' OR
          (p_create_update_flag = 'U' AND
           p_contact_point_rec.contact_point_purpose <>
             NVL(l_contact_point_purpose, fnd_api.g_miss_char)))
      THEN
        validate_lookup (
          p_column               => 'contact_point_purpose',
          p_lookup_type          => 'CONTACT_POINT_PURPOSE_WEB',
          p_column_value         => p_contact_point_rec.contact_point_purpose,
          x_return_status        => x_return_status);


        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
   p_message=>'WEB : contact_point_purpose is lookup code in lookup type CONTACT_POINT_PURPOSE_WEB if contact_point_type = WEB. ' || 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          '(+) after validate telex_number ... ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate telex_number ... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_contact_point_main (-)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_contact_point_main (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  END validate_contact_point_main;

  ----------------------------
  -- body of public procedures
  ----------------------------

  /**
   * PROCEDURE validate_party
   *
   * DESCRIPTION
   *     Validates party record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
   *     p_person_rec         Person record.
   *     p_old_person_rec     Old person record.
   *   IN/OUT:
   *     x_return_status      Return status after the call. The status can
   *                          be FND_API.G_RET_STS_SUCCESS (success),
   *                          FND_API.G_RET_STS_ERROR (error),
   *                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *   09-26-2003    Rajib Ranjan Borah o Commented out the validate HR security code
   *                                      and added validation code in
   *                                      validate_hr_security procedure
   *                                      which is called from validate_person
   *                                      (Bug 3099624)
   */

  PROCEDURE validate_party(
      p_create_update_flag               IN     VARCHAR2,
      p_party_rec                        IN     HZ_PARTY_V2PUB.PARTY_REC_TYPE,
      p_old_party_rec                    IN     HZ_PARTY_V2PUB.PARTY_REC_TYPE,
      p_db_created_by_module             IN     VARCHAR2,
      x_return_status                    IN OUT NOCOPY VARCHAR2
  ) IS

      l_debug_prefix                   VARCHAR2(30) := '';
      l_temp_hr_party_exist            NUMBER := 0;
      l_validate_osr varchar2(1) := 'Y';
      l_mosr_owner_table_id number;

      l_temp_return_status   VARCHAR2(10); -- for storing return status from
                                           -- hz_orig_system_ref_pub.get_owner_table_id
      /*

      CURSOR c_temp_hr_party_exist IS
      select 1
      from   per_all_people_f
      where  party_id = p_party_rec.party_id;
      */
  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_party (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_party (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -----------------------
      -- validate party_number
      -----------------------

      -- party_number is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'party_number',
              p_column_value                          => p_party_rec.party_number,
              p_old_column_value                      => p_old_party_rec.party_number,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_number is non-updateable. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_number is non-updateable. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

      ---------------------------------
      -- validate orig_system_reference
      ---------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
     IF (p_party_rec.orig_system is not null
         and p_party_rec.orig_system <>fnd_api.g_miss_char)
       and (p_party_rec.orig_system_reference is not null
         and p_party_rec.orig_system_reference <>fnd_api.g_miss_char)
          and p_create_update_flag = 'U'
      then
           hz_orig_system_ref_pub.get_owner_table_id
                        (p_orig_system => p_party_rec.orig_system,
                        p_orig_system_reference => p_party_rec.orig_system_reference,
                        p_owner_table_name => 'HZ_PARTIES',
                        x_owner_table_id => l_mosr_owner_table_id,
                        x_return_status => l_temp_return_status);

           IF (l_temp_return_status = fnd_api.g_ret_sts_success AND
               l_mosr_owner_table_id= nvl(p_party_rec.party_id,l_mosr_owner_table_id))
           THEN
                l_validate_osr := 'N';
            -- if we can get owner_table_id based on osr and os in mosr table,
            -- we will use unique osr and os for update - bypass osr validation
           ELSE l_validate_osr := 'Y';
           END IF;

          -- Call to hz_orig_system_ref_pub.get_owner_table_id API was resetting the
          -- x_return_status. Set x_return_status to error, ONLY if there is error.
          -- In case of success, leave it to carry over previous value as before this call.
          -- Fix for Bug 5498116 (29-AUG-2006)
          IF (l_temp_return_status = FND_API.G_RET_STS_ERROR) THEN
            x_return_status := l_temp_return_status;
          END IF;

    end if;
      -- orig_system_reference is non-updateable field
      IF p_create_update_flag = 'U' and l_validate_osr = 'Y' THEN
          validate_nonupdateable (
              p_column                                => 'orig_system_reference',
              p_column_value                          => p_party_rec.orig_system_reference,
              p_old_column_value                      => p_old_party_rec.orig_system_reference,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'orig_system_reference is non-updateable. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'orig_system_reference is non-updateable. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;
   END IF;

      ------------------
      -- validate status
      ------------------

      -- status cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          validate_cannot_update_to_null (
              p_column                                => 'status',
              p_column_value                          => p_party_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status is not updateable to null. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'status is not updateable to null. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- status is lookup code in lookup type REGISTRY_STATUS
      IF p_party_rec.status IS NOT NULL
         AND
         p_party_rec.status <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_party_rec.status <> p_old_party_rec.status
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'status',
              p_lookup_type                           => 'REGISTRY_STATUS',
              p_column_value                          => p_party_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;
   END IF;

      ------------------------
      -- validate HR security
      ------------------------
      --Commented out the code below in the fix for 3099624.Added HR securrity validation in validate_hr_security procedure  which is called from validate_person.
      --fix for Bug 2642597
     /*IF nvl(p_old_party_rec.orig_system_reference,'X') LIKE 'PER%' THEN
      | IF NVL(fnd_profile.value('HZ_CREATED_BY_MODULE'), '-222') <> 'HR API'
      |    AND p_create_update_flag = 'U'
      | THEN
      |    fnd_message.set_name('AR', 'HZ_CREATED_BY_MISMATCH');
      |    fnd_msg_pub.add;
      |    x_return_status := fnd_api.g_ret_sts_error;
      | END IF;
      |  END IF;
      */

     /*
      |OPEN c_temp_hr_party_exist;
      |FETCH c_temp_hr_party_exist INTO l_temp_hr_party_exist;
      |IF c_temp_hr_party_exist%NOTFOUND THEN
      |  l_temp_hr_party_exist := 0;
      |END IF;
      |CLOSE c_temp_hr_party_exist;
      |
      |IF  NVL(fnd_profile.value('HZ_CREATED_BY_MODULE'), '-222') <> 'HR API'
      |    AND l_temp_hr_party_exist = 1
      |    AND p_create_update_flag = 'U'
      |THEN
      |    fnd_message.set_name('AR', 'HZ_CREATED_BY_MISMATCH');
      |    fnd_msg_pub.add;
      |    x_return_status := fnd_api.g_ret_sts_error;
      |END IF;
      */

      -------------------------
      -- validate category_code
      -------------------------

      -- category_code is lookup code in lookup type CUSTOMER_CATEGORY
      IF p_party_rec.category_code IS NOT NULL
         AND
         p_party_rec.category_code <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_party_rec.category_code <> p_old_party_rec.category_code
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'category_code',
              p_lookup_type                           => 'CUSTOMER_CATEGORY',
              p_column_value                          => p_party_rec.category_code,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'category_code is lookup code in lookup type CUSTOMER_CATEGORY. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'category_code is lookup code in lookup type CUSTOMER_CATEGORY. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_party (-)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_party (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      --disable_debug;

  END validate_party;

  /**
   * PROCEDURE validate_person
   *
   * DESCRIPTION
   *     Validates person record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         hr security validation
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_person_rec                   Person record.
   *     p_old_person_rec               Old person record.
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *   06-FEB-2003   Porkodi C          o Bug 2684319: Added a validation for deceased_flag field.
   *   10-Mar-2003   Porkodi Chinnandar o Bug 2817974, Added a validation for date_of_death and
   *                                      date_of_birth field to have greater value for date_of_death.
   *   27-Mar-2003   Porkodi C          o Bug 2794173: Added g_miss_date check for date_of_death
   *   26-Sep-2003   Rajib Ranjan Borah o Bug 3099624: Called the validate_hr_security
   *                                      procedure to validate HR security.
   *   16-JAN-2004   Rajib Ranjan Borah o Bug 3333036.Rent_own_ind is now validated only if it
   *                                      has been updated and not for each record.
   *   13-JUL-2004   V.Ravichandran     o Bug 3704293 : Modified the code which validates
   *                                      date_of_birth and date_of_death combination in
   *                                      validate_person() procedure.
   *   25-AUG-2004   V.Ravichandran     o Bug 3747386 : Modified the code which validates
   *                                      that both first_name and last_name
   *                                      should not be null during update in validate_person()
   *                                      procedure.
   *   31-MAY-2006   Nishant Singhai    o Bug 5174379 : Person Name update allowed check added.
   */

  PROCEDURE validate_person(
      p_create_update_flag             IN     VARCHAR2,
      p_person_rec                     IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
      p_old_person_rec                 IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
      x_return_status                  IN OUT NOCOPY VARCHAR2
 ) IS

      l_debug_prefix                   VARCHAR2(30) := '';
      temp_date_of_birth               DATE;
      temp_date_of_death               DATE;
      l_change_cust_name_profile       VARCHAR2(10);


  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_person (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_person (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -------------------------------------------------------------------------
      -- Validate first_name, middle_name, last_name, pre_name_adjunct and
	  -- person_name_suffix are allowed to be updated or not
	  -- Update only if profile is set to Y or it is not set at all. If it is set
	  -- to 'N' update is not allowed.
      -- Check added for Bug 5174379 on 31-May-2006 (Nishant)
	  -------------------------------------------------------------------------
      IF p_create_update_flag = 'U' THEN

        l_change_cust_name_profile := fnd_profile.VALUE('AR_CHANGE_CUST_NAME');
        IF (NVL(l_change_cust_name_profile,'Y') = 'N') THEN -- update to party name is not allowed

          IF ((p_person_rec.person_first_name <> p_old_person_rec.person_first_name) OR
              (p_person_rec.person_middle_name <> p_old_person_rec.person_middle_name) OR
              (p_person_rec.person_last_name <> p_old_person_rec.person_last_name) OR
              (p_person_rec.person_pre_name_adjunct <> p_old_person_rec.person_pre_name_adjunct) OR
              (p_person_rec.person_name_suffix <> p_old_person_rec.person_name_suffix)
		     ) THEN
              fnd_message.set_name('AR', 'HZ_CUST_NAME_UPDT_NOT_ALLOWED');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
		  END IF;

        END IF; -- profile = N

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
		                          p_message=>'Person Name Update Allowed Check...' ||
                                             'x_return_status : ' || x_return_status ||
                                             '. Profile AR_CHANGE_CUST_NAME value :'||l_change_cust_name_profile,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF; -- create update flag = U

      -----------------------------------
      -- validate first_name or last_name
      -----------------------------------

      -- during insert, either first_name or last_name has to be passed in
      IF p_create_update_flag = 'C' THEN
          IF (p_person_rec.person_first_name = fnd_api.g_miss_char or p_person_rec.person_first_name IS NULL)
             AND
             (p_person_rec.person_last_name = fnd_api.g_miss_char or p_person_rec.person_last_name IS NULL)
          THEN
              fnd_message.set_name('AR', 'HZ_FIRST_OR_LAST_NAME_REQUIRED');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
          END IF;
      END IF;

      -- during update, both first_name or last_name cannot be set to null
      IF p_create_update_flag = 'U' THEN
      -- Bug 3747386
          IF (p_person_rec.person_first_name = fnd_api.g_miss_char
              or NVL(p_person_rec.person_first_name,p_old_person_rec.person_first_name)=fnd_api.g_miss_char)
             AND
             (p_person_rec.person_last_name = fnd_api.g_miss_char
              or NVL(p_person_rec.person_last_name,p_old_person_rec.person_last_name)=fnd_api.g_miss_char) THEN
              fnd_message.set_name('AR', 'HZ_FIRST_OR_LAST_NAME_REQUIRED');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
          END IF;
      END IF;

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'first_name or last_name is mandatory. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'first_name or last_name is mandatory. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;

      -----------------------------------
      -- validate person_pre_name_adjunct
      -----------------------------------

      -- person_pre_name_adjunct is lookup code in lookup type CONTACT_TITLE
      IF p_person_rec.person_pre_name_adjunct IS NOT NULL
         AND
         p_person_rec.person_pre_name_adjunct <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_person_rec.person_pre_name_adjunct <> p_old_person_rec.person_pre_name_adjunct
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'person_pre_name_adjunct',
              p_lookup_type                           => 'CONTACT_TITLE',
              p_column_value                          => p_person_rec.person_pre_name_adjunct,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'person_pre_name_adjunct in lookup CONTACT_TITLE. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'person_pre_name_adjunct in lookup CONTACT_TITLE. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;
      END IF;

      ----------------------------------
      -- validate head_of_household_flag
      ----------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- head_of_household_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'head_of_household_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_person_rec.head_of_household_flag,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'head_of_household_flag in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'head_of_household_flag in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      ------------------------
      -- validate rent_own_ind
      ------------------------

      --2897298, Changed the lookup type to OWN_RENT_IND
      -- rent_own_ind is lookup code in lookup type OWN_RENT_IND
      -- Bug 3333036.
      -- The validation will be called only if the value changes.

      IF p_person_rec.rent_own_ind IS NOT NULL
         AND
         p_person_rec.rent_own_ind <> fnd_api.g_miss_char
         AND
          (
            p_create_update_flag = 'C'
          OR
            (
            p_create_update_flag = 'U'
            AND
            p_person_rec.rent_own_ind <> p_old_person_rec.rent_own_ind
            )
          )
      THEN
          validate_lookup (
              p_column                                => 'rent_own_ind',
              p_lookup_type                           => 'OWN_RENT_IND',
              p_column_value                          => p_person_rec.rent_own_ind,
              x_return_status                         => x_return_status);
          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                   'rent_own_ind in lookup OWN_RENT_IND. ' ||
                   'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(
                  p_prefix=>l_debug_prefix,
                  p_message=>'rent_own_ind in lookup OWN_RENT_IND. ' ||
                             'x_return_status = ' || x_return_status,
                  p_msg_level=>fnd_log.level_statement);
          END IF;
     END IF;

      -------------------------
      -- validate deceased_flag
      -------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- deceased_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'deceased_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_person_rec.deceased_flag,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'deceased_flag in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'deceased_flag in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

     -- If date_of_death is not null then deceased_flag must be 'Y'

     --2794173, Added the g_miss_date check here
     IF (p_person_rec.date_of_death IS NOT NULL AND
         p_person_rec.date_of_death <> FND_API.G_MISS_DATE)
           THEN

              IF p_person_rec.deceased_flag <> 'Y'
                 THEN

                 fnd_message.set_name('AR', 'HZ_API_VAL_DEP_FIELDS');
                 fnd_message.set_token('COLUMN1', 'DATE_OF_DEATH');
                 fnd_message.set_token('VALUE1', 'not null');
                 fnd_message.set_token('COLUMN2', 'DECEASED_FLAG');
                 fnd_message.set_token('VALUE2', 'Y');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;
              END IF;

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'check that deceased_flag is Y when date_of_death is not null. ' ||
                    ' x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'check that deceased_flag is Y when date_of_death is not null. ' ||
                                                         ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;
        END IF;

      --2817974, Added
      -------------------------------------------
      -- validate date_of_birth and date_of_death
      -------------------------------------------

        -- date_of_birth and date_of_death should be greater than sys_date
        IF p_person_rec.date_of_birth > SYSDATE then
           fnd_message.set_name('AR','HZ_API_NO_FUTURE_DATE_ALLOWED');
           fnd_message.set_token('COLUMN','DATE_OF_BIRTH');
           fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
        END IF;

        IF p_person_rec.date_of_death > SYSDATE then
           fnd_message.set_name('AR','HZ_API_NO_FUTURE_DATE_ALLOWED');
           fnd_message.set_token('COLUMN','DATE_OF_DEATH');
           fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
        END IF;

        /*IF g_debug THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
               'after validating date_of_birth and date_of_death against SYSDATE ' ||
               'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'after validating date_of_birth and date_of_death against SYSDATE ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

        -- If date_of_birth and date_of_death are passed,
        -- then date_of_birth must be greater than or equal to
        -- date_of_death.

        -- Bug 3704293
        IF p_create_update_flag = 'U'    THEN
              IF p_person_rec.date_of_birth IS NOT NULL  then
                 temp_date_of_birth  :=  p_person_rec.date_of_birth;
              ELSE
                 temp_date_of_birth  := p_old_person_rec.date_of_birth;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_date_of_birth := p_person_rec.date_of_birth;
        END IF;

        IF p_create_update_flag = 'U'    THEN
              IF p_person_rec.date_of_death IS NOT NULL then
                 temp_date_of_death := p_person_rec.date_of_death;
              ELSE
                 temp_date_of_death := p_old_person_rec.date_of_death;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_date_of_death := p_person_rec.date_of_death;
        END IF;

        IF (temp_date_of_birth IS NOT NULL AND
            temp_date_of_birth <> FND_API.G_MISS_DATE AND
            temp_date_of_death IS NOT NULL AND
            temp_date_of_death <> FND_API.G_MISS_DATE) THEN
            validate_start_end_date (

              p_create_update_flag                    => p_create_update_flag,
              p_start_date_column_name                => 'date_of_birth',
              p_start_date                            => temp_date_of_birth,
              p_old_start_date                        => p_old_person_rec.date_of_birth,
              p_end_date_column_name                  => 'date_of_death',
              p_end_date                              => temp_date_of_death,
              p_old_end_date                          => p_old_person_rec.date_of_death,
              x_return_status                         => x_return_status
            );



            /*IF g_debug THEN
               hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 'check whether date_of_death is greater then or equal to date_of_birth. ' ||
                 'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'check whether date_of_death is greater then or equal to date_of_birth. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;
        END IF;

        /*IF g_debug THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           '(+) after validating the date_of_death and date_of_birth... ' ||
           'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) after validating the date_of_death and date_of_birth... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;



      /**
       * Bug 2197181: content_source_type is obsolete.

      ----------------------------------------------
      -- validate content_source_type
      ----------------------------------------------

      -- do not need to check content_source_type is mandatory because
      -- we default content_source_type to hz_party_v2pub.g_miss_content_source_type
      -- in table handler.

      -- since we are selecting person_profile_id from hz_person_profiles
      -- for record having content_source_type of p_person_rec.content_source_type,
      -- in this case, we do not need to check for non-updatability of content_source_type.

      -- content_source_type is lookup code in lookup type CONTENT_SOURCE_TYPE
      validate_lookup (
          p_column                                => 'content_source_type',
          p_lookup_type                           => 'CONTENT_SOURCE_TYPE',
          p_column_value                          => p_person_rec.content_source_type,
          x_return_status                         => x_return_status);


      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'content_source_type in lookup CONTENT_SOURCE_TYPE. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
      **/

      --------------------------
      -- validate marital_status
      --------------------------

      -- marital_status is lookup code in lookup type MARITAL_STATUS
      IF p_person_rec.marital_status IS NOT NULL
         AND
         p_person_rec.marital_status <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_person_rec.marital_status <> p_old_person_rec.marital_status
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'marital_status',
              p_lookup_type                           => 'MARITAL_STATUS',
              p_column_value                          => p_person_rec.marital_status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'marital_status in lookup MARITAL_STATUS. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'marital_status in lookup MARITAL_STATUS. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_person_rec.created_by_module,
        p_old_created_by_module  => p_old_person_rec.created_by_module,
        x_return_status          => x_return_status);

      --------------------------------------
      -- validate application_id
      --------------------------------------

      validate_application_id(
        p_create_update_flag     => p_create_update_flag,
        p_application_id         => p_person_rec.application_id,
        p_old_application_id     => p_old_person_rec.application_id,
        x_return_status          => x_return_status);

      --------------------------
      -- validate gender
      --------------------------

      -- gender is lookup code in lookup type HZ_GENDER
      IF p_person_rec.gender IS NOT NULL AND
         p_person_rec.gender <> fnd_api.g_miss_char AND
         (p_create_update_flag = 'C' OR
          (p_create_update_flag = 'U' AND
           p_person_rec.gender <> p_old_person_rec.gender))
      THEN
          validate_lookup (
              p_column                                => 'gender',
              p_lookup_type                           => 'HZ_GENDER',
              p_column_value                          => p_person_rec.gender,
              x_return_status                         => x_return_status);

          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
                 p_prefix       => l_debug_prefix,
                 p_message      => 'gender in lookup HZ_GENDER. ' ||
                                   'x_return_status = ' || x_return_status,
                 p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

      --------------------------
      -- validate person_iden_type
      --------------------------

      -- person_iden_type is lookup code in lookup type HZ_PERSON_IDEN_TYPE
      IF p_person_rec.person_iden_type IS NOT NULL AND
         p_person_rec.person_iden_type <> fnd_api.g_miss_char AND
         (p_create_update_flag = 'C' OR
          (p_create_update_flag = 'U' AND
           p_person_rec.person_iden_type <> p_old_person_rec.person_iden_type))
      THEN
          validate_lookup (
              p_column                                => 'person_iden_type',
              p_lookup_type                           => 'HZ_PERSON_IDEN_TYPE',
              p_column_value                          => p_person_rec.person_iden_type,
              x_return_status                         => x_return_status);

          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
                 p_prefix       => l_debug_prefix,
                 p_message      => 'person_iden_type in lookup HZ_PERSON_IDEN_TYPE. ' ||
                                   'x_return_status = ' || x_return_status,
                 p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

     -----------------------------------------------------------
     --Call to valicate against HR security (Bug Number 3099624)
     -----------------------------------------------------------
      IF(p_create_update_flag='U')
      THEN
           validate_hr_security
                (
                p_person_rec            => p_person_rec,
                p_old_person_rec        => p_old_person_rec,
                x_return_status         => x_return_status
                );
      END IF;


      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_person (-)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_person (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      --disable_debug;

  END validate_person;

  /**
   * PROCEDURE validate_hr_security
   *
   * DESCRIPTION
   *   Protects the HR data in the HZ_PERSON_PROFILES and the HZ_PARTIES tables
   *   by preventing updation by other users.
   *   If the profile option 'HZ_PROTECT_HR_PERSON_INFO' is set to 'Y',then the
   *   following fields are updateable only by HR:
   *      person_first_name
   *      person_last_name
   *      person_middle_name
   *      person_name_suffix
   *      person_previous_last_name
   *      person_title
   *      known_as
   *      person_first_name_phonetic
   *      person_last_name_phonetic
   *      person_name_phonetic
   *   If the profile option 'HZ_PROTECT_HR_PERSON_INFO' is set to 'N', then the
   *   following sensitive fields are updateable only by HR in addition to those
   *   mentioned above for the case when the profile option is set to 'Y':
   *      gender
   *      date_of_birth
   *      place_of_birth
   *      marital_status
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag            Create update flag. 'C' = create. 'U' = update.
   *     p_person_rec                    Person record.
   *     p_old_person_rec                Old person record.
   *   IN/OUT:
   *     x_return_status                 Return status after the call. The status can
   *                                     be FND_API.G_RET_STS_SUCCESS (success),
   *                                     fnd_api.g_ret_sts_error (error),
   *                                     FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *   The previous  validation for the same  purpose was  performed in the procedure
   *   HZ_REGISTRY_VALIDATE_V2PUB.validate_party and locked all fields against update
   *   as against the expected functionality of locking only the HR fields.
   *   (Bug Number 3099624).The previous validation has been commented out.
   *
   * MODIFICATION HISTORY
   *
   *   09-26-2003    Rajib Ranjan Borah  o Created.
   *
   */

PROCEDURE validate_hr_security(
      p_person_rec                     IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
      p_old_person_rec                 IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
      x_return_status                  IN OUT NOCOPY VARCHAR2
    ) IS

      cols_updated                    VARCHAR2(300) := '';
      l_debug_prefix                   VARCHAR2(30) := '';
BEGIN

     --enable_debug;

     -- Debug info.
     /*IF g_debug
     THEN
          hz_utility_v2pub.debug ('validate_hr_security (+)');
     END IF;
     */
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_hr_security (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;



     IF(NVL(p_old_person_rec.party_rec.orig_system_reference,'X') LIKE 'PER%')
     THEN
          IF (NVL(FND_PROFILE.VALUE('HZ_CREATED_BY_MODULE'), '-222') <> 'HR API')
          THEN
               IF(FND_PROFILE.VALUE('HZ_PROTECT_HR_PERSON_INFO')='Y')
               THEN
                    IF(NVL(p_person_rec.person_first_name,p_old_person_rec.person_first_name)<>p_old_person_rec.person_first_name)
                    THEN
                         cols_updated :=cols_updated||',PERSON_FIRST_NAME';
                    END IF;

                    IF(NVL(p_person_rec.person_last_name,p_old_person_rec.person_last_name)<>p_old_person_rec.person_last_name)
                    THEN
                         cols_updated :=cols_updated||',PERSON_LAST_NAME';
                    END IF;

                    IF(NVL(p_person_rec.person_middle_name,p_old_person_rec.person_middle_name)<>p_old_person_rec.person_middle_name)
                    THEN
                         cols_updated :=cols_updated||',PERSON_MIDDLE_NAME';
                    END IF;

                    IF(NVL(p_person_rec.person_name_suffix,p_old_person_rec.person_name_suffix)<>p_old_person_rec.person_name_suffix)
                    THEN
                         cols_updated :=cols_updated||',PERSON_NAME_SUFFIX';
                    END IF;

                    IF(NVL(p_person_rec.person_previous_last_name,p_old_person_rec.person_previous_last_name)<>p_old_person_rec.person_previous_last_name)
                    THEN
                         cols_updated :=cols_updated||',PERSON_PREVIOUS_LAST_NAME';
                    END IF;

                    IF(NVL(p_person_rec.known_as,p_old_person_rec.known_as)<>p_old_person_rec.known_as)
                    THEN
                         cols_updated :=cols_updated||',KNOWN_AS';
                    END IF;

                    IF(NVL(p_person_rec.person_title,p_old_person_rec.person_title)<>p_old_person_rec.person_title)
                    THEN
                         cols_updated :=cols_updated||',PERSON_TITLE';
                    END IF;

                    IF(NVL(p_person_rec.person_first_name_phonetic,p_old_person_rec.person_first_name_phonetic)<>p_old_person_rec.person_first_name_phonetic)
                    THEN
                         cols_updated :=cols_updated||',PERSON_FIRST_NAME_PHONETIC';
                    END IF;

                    IF(NVL(p_person_rec.person_last_name_phonetic,p_old_person_rec.person_last_name_phonetic)<>p_old_person_rec.person_last_name_phonetic)
                    THEN
                         cols_updated :=cols_updated||',PERSON_LAST_NAME_PHONETIC';
                    END IF;

                    IF(NVL(p_person_rec.person_name_phonetic,p_old_person_rec.person_name_phonetic)<>p_old_person_rec.person_name_phonetic)
                    THEN
                         cols_updated :=cols_updated||',PERSON_NAME_PHONETIC';
                    END IF;



                    IF(cols_updated IS NOT NULL)
                    THEN
                         cols_updated:=SUBSTR(cols_updated,2);
                         FND_MESSAGE.SET_NAME('AR', 'HZ_CREATED_BY_MISMATCH');
                         FND_MESSAGE.SET_TOKEN('COLUMN',cols_updated);
                         FND_MSG_PUB.ADD;
                         x_return_status := FND_API.G_RET_STS_ERROR;
                    END IF;

               ELSIF(FND_PROFILE.VALUE('HZ_PROTECT_HR_PERSON_INFO')='N') --elsif corresonding to --IF(FND_PROFILE.VALUE('HZ_PROTECT_PERSON_INFO')='Y')--
               THEN
                    IF(NVL(p_person_rec.person_first_name,p_old_person_rec.person_first_name)<>p_old_person_rec.person_first_name)
                    THEN
                         cols_updated :=cols_updated||',PERSON_FIRST_NAME';
                    END IF;

                    IF(NVL(p_person_rec.person_last_name,p_old_person_rec.person_last_name)<>p_old_person_rec.person_last_name)
                    THEN
                         cols_updated :=cols_updated||',PERSON_LAST_NAME';
                    END IF;

                    IF(NVL(p_person_rec.person_middle_name,p_old_person_rec.person_middle_name)<>p_old_person_rec.person_middle_name)
                    THEN
                         cols_updated :=cols_updated||',PERSON_MIDDLE_NAME';
                    END IF;

                    IF(NVL(p_person_rec.person_name_suffix,p_old_person_rec.person_name_suffix)<>p_old_person_rec.person_name_suffix)
                    THEN
                         cols_updated :=cols_updated||',PERSON_NAME_SUFFIX';
                    END IF;

                    IF(NVL(p_person_rec.person_previous_last_name,p_old_person_rec.person_previous_last_name)<>p_old_person_rec.person_previous_last_name)
                    THEN
                         cols_updated :=cols_updated||',PERSON_PREVIOUS_LAST_NAME';
                    END IF;

                    IF(NVL(p_person_rec.known_as,p_old_person_rec.known_as)<>p_old_person_rec.known_as)
                    THEN
                         cols_updated :=cols_updated||',KNOWN_AS';
                    END IF;

                    IF(NVL(p_person_rec.person_title,p_old_person_rec.person_title)<>p_old_person_rec.person_title)
                    THEN
                         cols_updated :=cols_updated||',PERSON_TITLE';
                    END IF;

                    IF(NVL(p_person_rec.person_first_name_phonetic,p_old_person_rec.person_first_name_phonetic)<>p_old_person_rec.person_first_name_phonetic)
                    THEN
                         cols_updated :=cols_updated||',PERSON_FIRST_NAME_PHONETIC';
                    END IF;

                    IF(NVL(p_person_rec.person_last_name_phonetic,p_old_person_rec.person_last_name_phonetic)<>p_old_person_rec.person_last_name_phonetic)
                    THEN
                         cols_updated :=cols_updated||',PERSON_LAST_NAME_PHONETIC';
                    END IF;

                    IF(NVL(p_person_rec.person_name_phonetic,p_old_person_rec.person_name_phonetic)<>p_old_person_rec.person_name_phonetic)
                    THEN
                         cols_updated :=cols_updated||',PERSON_NAME_PHONETIC';
                    END IF;

                    IF(NVL(p_person_rec.gender,p_old_person_rec.gender)<>p_old_person_rec.gender)
                    THEN
                         cols_updated :=cols_updated||',GENDER';
                    END IF;

                    IF(NVL(p_person_rec.date_of_birth,p_old_person_rec.date_of_birth)<>p_old_person_rec.date_of_birth)
                    THEN
                         cols_updated :=cols_updated||',DATE_OF_BIRTH';
                    END IF;

                    IF(NVL(p_person_rec.place_of_birth,p_old_person_rec.place_of_birth)<>p_old_person_rec.place_of_birth)
                    THEN
                         cols_updated :=cols_updated||',PLACE_OF_BIRTH';
                    END IF;

                    IF(NVL(p_person_rec.marital_status,p_old_person_rec.marital_status)<>p_old_person_rec.marital_status)
                    THEN
                         cols_updated :=cols_updated||',MARITAL_STATUS';
                    END IF;



                    IF(cols_updated IS NOT NULL)
                    THEN
                         cols_updated:=SUBSTR(cols_updated,2);
                         FND_MESSAGE.SET_NAME('AR', 'HZ_CREATED_BY_MISMATCH');
                         FND_MESSAGE.SET_TOKEN('COLUMN',cols_updated);
                         FND_MSG_PUB.ADD;
                         x_return_status := FND_API.G_RET_STS_ERROR;
                    END IF;

               END IF;--end if corresponding to --IF(FND_PROFILE.VALUE('HZ_PROTECT_PERSON_INFO')='YES')--

          END IF;--end if corresponding to --IF(NVL(FND_PROFILE.VALUE('HZ_CREATED_BY_MODULE'), '-222') <> 'HR API')--

     END IF;--end if corresponding to --IF(NVL(p_old_party_rec.orig_system_reference,'X') LIKE 'PER%')--


     -- Debug info.
     /*IF g_debug
     THEN
          hz_utility_v2pub.debug ('validate_hr_security (-)');
     END IF;
     */
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_hr_security (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

     --disable_debug;

END validate_hr_security;



/**
   * PROCEDURE validate_group
   *
   * DESCRIPTION
   *     Validates group record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_group_rec                    Group record.
   *     p_old_group_rec                Old group record.
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *
   */

  PROCEDURE validate_group(
      p_create_update_flag             IN     VARCHAR2,
      p_group_rec                      IN     HZ_PARTY_V2PUB.GROUP_REC_TYPE,
      p_old_group_rec                  IN     HZ_PARTY_V2PUB.GROUP_REC_TYPE,
      x_return_status                  IN OUT NOCOPY VARCHAR2
 ) IS

      l_debug_prefix                   VARCHAR2(30) := '';

  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
        hz_utility_v2pub.debug ('validate_group (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_group (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      ----------------------
      -- validate group_name
      ----------------------

      -- group_name is mandatory field
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'group_name',
          p_column_value                          => p_group_rec.group_name,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'group_name is mandatory field. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'group_name is mandatory field. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      ----------------------
      -- validate group_type
      ----------------------

      -- group_type is mandatory field
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'group_type',
          p_column_value                          => p_group_rec.group_type,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'group_type is mandatory field. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'group_type is mandatory field. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_group_rec.created_by_module,
        p_old_created_by_module  => p_old_group_rec.created_by_module,
        x_return_status          => x_return_status);

      --------------------------------------
      -- validate application_id
      --------------------------------------

      validate_application_id(
        p_create_update_flag     => p_create_update_flag,
        p_application_id         => p_group_rec.application_id,
        p_old_application_id     => p_old_group_rec.application_id,
        x_return_status          => x_return_status);

  END validate_group;

   /**
   * PROCEDURE validate_organization
   *
   * DESCRIPTION
   *     Validates organization record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_organization_rec             Organization record.
   *     p_old_organization_rec         Old organization record.
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *   11-07-2001           Sisir       o Bug:1999814;Added validation for sic_code_type
   *                                      and fiscal_yearend_month.Updation is restricted
   *                                      if the value passed is same in database.
   *   02-20-2002    Kate Shan          o Comments out NOCOPY validation for obsolete columns
   *                                    o Add non-updatable validation for content_source_type
   *   03-11-2002    Jianying Huang     o Removed non-updatable validation for content_source_type
   *   02-04-2003    Sreedhar Mohan     o Added validations for validate total_employees_ind,
   *                                      total_emp_est_ind, total_emp_min_ind, emp_at_primary_adr_est_ind,
   *                                      emp_at_primary_adr_min_ind, ceo_title, ceo_name,
   *                                      principal_title and principal_name
   *   16-JAN-2004   Rajib Ranjan Borah o Bug 3333036.Rent_own_ind is now validated only if it
   *                                      has been updated and not for each record.
   *   31-AUG-2004   V.Ravichandran     o Bug 3853738. Commented the validation for columns
   *                                      total_emp_est_ind and emp_at_primary_adr_est_ind
   *                                      against lookup_type 'YES/NO' in validate_organization
   *                                      because these columns were validated against 2 lookups.
   *   13-JAN-2005   Rajib Ranjan Borah o SSM SST Integration and Extension
   *                                      Explicit non-updateability of third party provided ceo_name
   *                                      , ceo_title, etc will not be done as update rules can be used
   *                                      for the same.
   *   31-MAY-2006   Nishant Singhai    o Org Name update allowed check added for Bug 5174379.
   */

  PROCEDURE validate_organization(
      p_create_update_flag      IN      VARCHAR2,
      p_organization_rec        IN      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
      p_old_organization_rec    IN      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
      x_return_status           IN OUT NOCOPY      VARCHAR2
 ) IS

      l_dummy                                VARCHAR2(1);
      l_debug_prefix                         VARCHAR2(30) := '';
      l_return_status                        VARCHAR2(1);

-- Bug 3040565 : Added a locla variable to store local_activity_code_type

   l_local_activity_code_type     varchar2(30);
   l_change_org_name_profile      VARCHAR2(10);


  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_organization (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_organization (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


      -- validate nonsupported column in organization profile when creating

      IF FND_PROFILE.VALUE( 'HZ_API_ERR_ON_OBSOLETE_COLUMN' ) = 'Y' THEN
        validate_org_nonsupport_column(
            p_create_update_flag,
            p_organization_rec,
            x_return_status );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      -------------------------------------------------------------------------
      -- Validate organization_name is allowed to be updated or not
	  -- Update only if profile (HZ: Change Party Name) is set to Y or it is
	  -- not set at all. If it is set to 'N' update is not allowed.
      -- Check added for Bug 5174379 on 31-May-2006 (Nishant)
	  -------------------------------------------------------------------------
      IF p_create_update_flag = 'U' THEN

        l_change_org_name_profile := fnd_profile.VALUE('AR_CHANGE_CUST_NAME');
        IF (NVL(l_change_org_name_profile,'Y') = 'N') THEN -- update to party name is not allowed

          IF (p_organization_rec.organization_name <> p_old_organization_rec.organization_name) THEN
              fnd_message.set_name('AR', 'HZ_ORG_NAME_UPDT_NOT_ALLOWED');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
		  END IF;

        END IF; -- profile = N

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
		                          p_message=>'Org Name Update Allowed Check...' ||
                                             'x_return_status : ' || x_return_status ||
                                             '. Profile AR_CHANGE_CUST_NAME value :'||l_change_org_name_profile,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF; -- create update flag = U

      -----------------------------
      -- validate organization_name
      -----------------------------

      -- organization_name is mandatory field
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'organization_name',
          p_column_value                          => p_organization_rec.organization_name,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'organization_name is mandatory field. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'organization_name is mandatory field. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -- organization_name cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          validate_cannot_update_to_null (
              p_column                                => 'organization_name',
              p_column_value                          => p_organization_rec.organization_name,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'organization_name cannot be updated to null. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                  hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'organization_name cannot be updated to null. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

      ------------------------------
      -- validate gsa_indicator_flag
      ------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- gsa_indicator_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'gsa_indicator_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.gsa_indicator_flag,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'gsa_indicator_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'gsa_indicator_flag should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      -------------------------
      -- validate sic_code_type
      -------------------------

      -- sic_code_type is lookup code in lookup type 'SIC_CODE_TYPE'
      IF p_organization_rec.sic_code_type IS NOT NULL
         AND
         p_organization_rec.sic_code_type <> fnd_api.g_miss_char
         AND
        (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_organization_rec.sic_code_type <> p_old_organization_rec.sic_code_type
         )
        )
      THEN
         validate_lookup (
          p_column                                => 'sic_code_type',
          p_lookup_type                           => 'SIC_CODE_TYPE',
          p_column_value                          => p_organization_rec.sic_code_type,
          x_return_status                         => x_return_status);

          /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'sic_code_type should be in lookup SIC_CODE_TYPE' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'sic_code_type should be in lookup SIC_CODE_TYPE' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;
      END IF;

      --------------------------------
      -- validate fiscal_yearend_month
      --------------------------------

      -- fiscal_yearend_month is lookup code in lookup type 'MONTH'
      IF p_organization_rec.fiscal_yearend_month IS NOT NULL
         AND
         p_organization_rec.fiscal_yearend_month <> fnd_api.g_miss_char
         AND
        (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_organization_rec.fiscal_yearend_month <> p_old_organization_rec.fiscal_yearend_month
         )
        )
      THEN
        validate_lookup (
          p_column                                => 'fiscal_yearend_month',
          p_lookup_type                           => 'MONTH',
          p_column_value                          => p_organization_rec.fiscal_yearend_month,
          x_return_status                         => x_return_status);

        /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'fiscal_yearend_month should be in lookup MONTH' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'fiscal_yearend_month should be in lookup MONTH' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -------------------------
      -- validate internal_flag
      -------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- internal_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'internal_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.internal_flag,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'internal_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'internal_flag should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      ------------------------
      -- validate legal_status
      ------------------------

      -- legal_status is lookup code in lookup type LEGAL_STATUS
      IF p_organization_rec.legal_status IS NOT NULL
         AND
         p_organization_rec.legal_status <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_organization_rec.legal_status <> p_old_organization_rec.legal_status
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'legal_status',
              p_lookup_type                           => 'LEGAL_STATUS',
              p_column_value                          => p_organization_rec.legal_status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'legal_status is lookup code in lookup type LEGAL_STATUS. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;*/

          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'legal_status is lookup code in lookup type LEGAL_STATUS. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;
      END IF;

      -------------------------
      -- validate hq_branch_ind
      -------------------------

      -- hq_branch_ind is lookup code in lookup type HQ_BRANCH_IND
      IF p_organization_rec.hq_branch_ind IS NOT NULL
         AND
         p_organization_rec.hq_branch_ind <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_organization_rec.hq_branch_ind <> p_old_organization_rec.hq_branch_ind
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'hq_branch_ind',
              p_lookup_type                           => 'HQ_BRANCH_IND',
              p_column_value                          => p_organization_rec.hq_branch_ind,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'hq_branch_ind is lookup code in lookup type HQ_BRANCH_IND. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'hq_branch_ind is lookup code in lookup type HQ_BRANCH_IND. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

      -----------------------
      -- validate branch_flag
      -----------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- branch_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'branch_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.branch_flag,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'branch_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'branch_flag should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      -------------------
      -- validate oob_ind
      -------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- oob_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'oob_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.oob_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'oob_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'oob_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
   END IF;

      ----------------------
      -- validate import_ind
      ----------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- import_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'import_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.import_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'import_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'import_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      ----------------------
      -- validate export_ind
      ----------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- export_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'export_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.export_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'export_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'export_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      -----------------------------
      -- validate labor_surplus_ind
      -----------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- labor_surplus_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'labor_surplus_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.labor_surplus_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'labor_surplus_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'labor_surplus_ind should be in lookup YES/NO. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      /*   obsolete column. colum migrate to hz_credit_ratings.
           Validate in HZ_PARTY_INFO_VAL.validate_credit_ratings

      -------------------------
      -- validate debarment_ind
      -------------------------

      -- debarment_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'debarment_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.debarment_ind,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'debarment_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */

      ------------------------------
      -- validate minority_owned_ind
      ------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- minority_owned_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'minority_owned_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.minority_owned_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'minority_owned_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'minority_owned_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      ---------------------------
      -- validate woman_owned_ind
      ---------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- woman_owned_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'woman_owned_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.woman_owned_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'minority_owned_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'minority_owned_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      -------------------------
      -- validate disadv_8a_ind
      -------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- disadv_8a_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'disadv_8a_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.disadv_8a_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'disadv_8a_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'disadv_8a_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      -------------------------
      -- validate small_bus_ind
      -------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- small_bus_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'small_bus_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.small_bus_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'small_bus_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'small_bus_ind should be in lookup YES/NO. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    /*  obsolete column. Column migrate to hz_credit_ratings.
        Validate in HZ_PARTY_INFO_VAL.validate_credit_ratings

      ------------------------------------
      -- validate failure_score_commentary
      ------------------------------------

      -- failure_score_commentary is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      IF p_organization_rec.failure_score_commentary IS NOT NULL
         AND
         p_organization_rec.failure_score_commentary <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_organization_rec.failure_score_commentary <> p_old_organization_rec.failure_score_commentary
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'failure_score_commentary',
              p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
              p_column_value                          => p_organization_rec.failure_score_commentary,
              x_return_status                         => x_return_status);


          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'failure_score_commentary is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;
      END IF;

      --  obsolete column. Column migrate to hz_credit_ratings.
      --  Validate in HZ_PARTY_INFO_VAL.validate_credit_ratings

      -----------------------------------
      -- validate credit_score_commentary
      -----------------------------------

      -- credit_score_commentary is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      IF p_organization_rec.credit_score_commentary IS NOT NULL
         AND
         p_organization_rec.credit_score_commentary <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_organization_rec.credit_score_commentary <> p_old_organization_rec.credit_score_commentary
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'credit_score_commentary',
              p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
              p_column_value                          => p_organization_rec.credit_score_commentary,
              x_return_status                         => x_return_status);

          IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'credit_score_commentary is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;

      END IF;
      */

      -------------------------------
      -- validate local_bus_iden_type
      -------------------------------

      -- local_bus_iden_type is lookup code in lookup type LOCAL_BUS_IDEN_TYPE
      IF p_organization_rec.local_bus_iden_type IS NOT NULL
         AND
         p_organization_rec.local_bus_iden_type <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_organization_rec.local_bus_iden_type <> p_old_organization_rec.local_bus_iden_type
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'local_bus_iden_type',
              p_lookup_type                           => 'LOCAL_BUS_IDEN_TYPE',
              p_column_value                          => p_organization_rec.local_bus_iden_type,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'local_bus_iden_type is lookup code in lookup type LOCAL_BUS_IDEN_TYPE. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'local_bus_iden_type is lookup code in lookup type LOCAL_BUS_IDEN_TYPE. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;

      END IF;

      -----------------------------
      -- validate registration_type
      -----------------------------

      -- registration_type is lookup code in lookup type REGISTRATION_TYPE
      IF p_organization_rec.registration_type IS NOT NULL
         AND
         p_organization_rec.registration_type <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_organization_rec.registration_type <> p_old_organization_rec.registration_type
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'registration_type',
              p_lookup_type                           => 'REGISTRATION_TYPE',
              p_column_value                          => p_organization_rec.registration_type,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'registration_type is lookup code in lookup type REGISTRATION_TYPE. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'registration_type is lookup code in lookup type REGISTRATION_TYPE. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

      -- Bug 3853738
      /*
      -----------------------------
      -- validate total_emp_est_ind
      -----------------------------

      -- total_emp_est_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'total_emp_est_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.total_emp_est_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'total_emp_est_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      /*
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'total_emp_est_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
      */
      --------------------------
      -- validate parent_sub_ind
      --------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- parent_sub_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'parent_sub_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.parent_sub_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'parent_sub_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'parent_sub_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      ------------------------------------
      -- validate local_activity_code_type
      ------------------------------------

      -- local_activity_code_type is lookup code in lookup type LOCAL_ACTIVITY_CODE_TYPE
      IF p_organization_rec.local_activity_code_type IS NOT NULL
         AND
         p_organization_rec.local_activity_code_type <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_organization_rec.local_activity_code_type <> p_old_organization_rec.local_activity_code_type
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'local_activity_code_type',
              p_lookup_type                           => 'LOCAL_ACTIVITY_CODE_TYPE',
              p_column_value                          => p_organization_rec.local_activity_code_type,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'local_activity_code_type is lookup code in lookup type LOCAL_ACTIVITY_CODE_TYPE. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
             p_message=>'local_activity_code_type is lookup code in lookup type LOCAL_ACTIVITY_CODE_TYPE. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

-- Bug 3040565 : Added validation for local_activity_code

      ------------------------------------
      -- validate local_activity_code
      ------------------------------------

      -- local_activity_code is lookup code in one of the lookup type  NACE, NAF, NAISC_1997

      IF p_organization_rec.local_activity_code IS NOT NULL
         AND
         p_organization_rec.local_activity_code <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_organization_rec.local_activity_code <> p_old_organization_rec.local_activity_code
         )
        )
      THEN

        l_local_activity_code_type := nvl(p_organization_rec.local_activity_code_type, p_old_organization_rec.local_activity_code_type);

        if(l_local_activity_code_type = '4' OR l_local_activity_code_type = '5') then
                l_local_activity_code_type := 'NACE';
        end if;

          validate_fnd_lookup(
              p_lookup_type                           => l_local_activity_code_type,
              p_column                                => 'local_activity_code',
              p_column_value                          => p_organization_rec.local_activity_code,
              p_content_source_type                               => 'DNB',
              x_return_status                         => x_return_status);


          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'local_activity_code is lookup code in lookup type ' || p_organization_rec.local_activity_code_type || '.' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;



      ------------------------------------
      -- validate public_private_ownership_flag
      ------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- public_private_ownership_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'public_private_ownership_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.public_private_ownership_flag,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'public_private_ownership_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'public_private_ownership_flag should be in lookup YES/NO. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

      -- Bug 3853738
      /*
      ------------------------------------
      -- validate emp_at_primary_adr_est_ind
      ------------------------------------

      -- emp_at_primary_adr_est_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'emp_at_primary_adr_est_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_organization_rec.emp_at_primary_adr_est_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'emp_at_primary_adr_est_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      /*
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'emp_at_primary_adr_est_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
      */
      /**
       * Bug 2197181: content_source_type is obsolete.

      -------------------------------
      -- validate content_source_type
      -------------------------------

      -- do not need to check content_source_type is mandatory because
      -- we default content_source_type to hz_party_v2pub.g_miss_content_source_type
      -- in table handler.

      -- since we are selecting person_profile_id from hz_organization_profiles
      -- for record having content_source_type of p_organization_rec.content_source_type,
      -- in this case, we do not need to check for non-updatability of content_source_type.

      -- content_source_type is lookup code in lookup type CONTENT_SOURCE_TYPE
      validate_lookup (
          p_column                                => 'content_source_type',
          p_lookup_type                           => 'CONTENT_SOURCE_TYPE',
          p_column_value                          => p_organization_rec.content_source_type,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'content_source_type is lookup code in lookup type CONTENT_SOURCE_TYPE. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      **/

      /*  obsolete column. Column migrate to hz_credit_ratings.
          Validate in HZ_PARTY_INFO_VAL.validate_credit_ratings

      ------------------------------------
      -- validate credit_score_commentary2
      ------------------------------------

      -- credit_score_commentary2 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary2',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.credit_score_commentary2,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary2 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      ------------------------------------
      -- validate credit_score_commentary3
      ------------------------------------

      -- credit_score_commentary3 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary3',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.credit_score_commentary3,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary3 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      ------------------------------------
      -- validate credit_score_commentary4
      ------------------------------------

      -- credit_score_commentary4 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary4',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.credit_score_commentary4,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary4 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      ------------------------------------
      -- validate credit_score_commentary5
      ------------------------------------

      -- credit_score_commentary5 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary5',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.credit_score_commentary5,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary5 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      ------------------------------------
      -- validate credit_score_commentary6
      ------------------------------------

      -- credit_score_commentary6 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary6',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.credit_score_commentary6,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary6 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      ------------------------------------
      -- validate credit_score_commentary7
      ------------------------------------

      -- credit_score_commentary7 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary7',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.credit_score_commentary7,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary7 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      ------------------------------------
      -- validate credit_score_commentary8
      ------------------------------------

      -- credit_score_commentary8 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary8',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.credit_score_commentary8,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary8 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      ------------------------------------
      -- validate credit_score_commentary9
      ------------------------------------

      -- credit_score_commentary9 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary9',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.credit_score_commentary9,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary9 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      -------------------------------------
      -- validate credit_score_commentary10
      -------------------------------------

      -- credit_score_commentary10 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary10',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.credit_score_commentary10,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary10 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;


      -------------------------------------
      -- validate failure_score_commentary2
      -------------------------------------

      -- failure_score_commentary2 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary2',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.failure_score_commentary2,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary2 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      -------------------------------------
      -- validate failure_score_commentary3
      -------------------------------------

      -- failure_score_commentary3 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary3',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.failure_score_commentary3,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary3 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      -------------------------------------
      -- validate failure_score_commentary4
      -------------------------------------

      -- failure_score_commentary4 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary4',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.failure_score_commentary4,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary4 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      -------------------------------------
      -- validate failure_score_commentary5
      -------------------------------------

      -- failure_score_commentary5 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary5',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.failure_score_commentary5,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary5 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      -------------------------------------
      -- validate failure_score_commentary6
      -------------------------------------

      -- failure_score_commentary6 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary6',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.failure_score_commentary6,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary6 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      -------------------------------------
      -- validate failure_score_commentary7
      -------------------------------------

      -- failure_score_commentary7 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary7',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.failure_score_commentary7,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary7 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      -------------------------------------
      -- validate failure_score_commentary8
      -------------------------------------

      -- failure_score_commentary8 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary8',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.failure_score_commentary8,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary8 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      -------------------------------------
      -- validate failure_score_commentary9
      -------------------------------------

      -- failure_score_commentary9 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary9',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.failure_score_commentary9,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary9 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      --------------------------------------
      -- validate failure_score_commentary10
      --------------------------------------

      -- failure_score_commentary10 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary10',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_organization_rec.failure_score_commentary10,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary10 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;

      -- Obsolete column. Column migrate to hz_credit_rating.
      -- Validate in HZ_PARTY_INFO_VAL.validate_credit_ratings

      ----------------------------------------
      -- validate maximum_credit_currency_code
      ----------------------------------------

      -- maximum_credit_currency_code is foreign key of fnd_currencies.currency_code
      IF p_organization_rec.maximum_credit_currency_code IS NOT NULL
         AND
         p_organization_rec.maximum_credit_currency_code <> fnd_api.g_miss_char
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   FND_CURRENCIES
              WHERE  CURRENCY_CODE = p_organization_rec.maximum_credit_currency_code
              AND    CURRENCY_FLAG = 'Y'
              AND    ENABLED_FLAG in ('Y', 'N');
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'maximum_credit_currency_code');
                  fnd_message.set_token('COLUMN', 'currency_code');
                  fnd_message.set_token('TABLE', 'fnd_currencies');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'maximum_credit_currency_code is foreign key of fnd_currencies.currency_code. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;

      END IF;
      */

      -------------------------------
      -- validate total_employees_ind
      -------------------------------

      -- total_employees_ind is lookup code in lookup type TOTAL_EMPLOYEES_INDICATOR
      validate_lookup (
          p_column                                => 'total_employees_ind',
          p_lookup_type                           => 'TOTAL_EMPLOYEES_INDICATOR',
          p_column_value                          => p_organization_rec.total_employees_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'total_employees_ind is lookup code in lookup type TOTAL_EMPLOYEES_INDICATOR. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'total_employees_ind is lookup code in lookup type TOTAL_EMPLOYEES_INDICATOR. ' ||
                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -----------------------------
      -- validate total_emp_est_ind
      -----------------------------

      -- total_emp_est_ind is lookup code in lookup type TOTAL_EMP_EST_IND
      validate_lookup (
          p_column                                => 'total_emp_est_ind',
          p_lookup_type                           => 'TOTAL_EMP_EST_IND',
          p_column_value                          => p_organization_rec.total_emp_est_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'total_emp_est_ind is lookup code in lookup type TOTAL_EMP_EST_IND. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'total_emp_est_ind is lookup code in lookup type TOTAL_EMP_EST_IND. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -----------------------------
      -- validate total_emp_min_ind
      -----------------------------

      -- total_emp_min_ind is lookup code in lookup type TOTAL_EMP_MIN_IND
      validate_lookup (
          p_column                                => 'total_emp_min_ind',
          p_lookup_type                           => 'TOTAL_EMP_MIN_IND',
          p_column_value                          => p_organization_rec.total_emp_min_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'total_emp_min_ind is lookup code in lookup type TOTAL_EMP_MIN_IND. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'total_emp_min_ind is lookup code in lookup type TOTAL_EMP_MIN_IND. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      --------------------------------------
      -- validate emp_at_primary_adr_est_ind
      --------------------------------------

      -- emp_at_primary_adr_est_ind is lookup code in lookup type EMP_AT_PRIMARY_ADR_EST_IND
      validate_lookup (
          p_column                                => 'emp_at_primary_adr_est_ind',
          p_lookup_type                           => 'EMP_AT_PRIMARY_ADR_EST_IND',
          p_column_value                          => p_organization_rec.emp_at_primary_adr_est_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'emp_at_primary_adr_est_ind is lookup code in lookup type EMP_AT_PRIMARY_ADR_EST_IND. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'emp_at_primary_adr_est_ind is lookup code in lookup type EMP_AT_PRIMARY_ADR_EST_IND. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      --------------------------------------
      -- validate emp_at_primary_adr_min_ind
      --------------------------------------

      -- emp_at_primary_adr_min_ind is lookup code in lookup type EMP_AT_PRIMARY_ADR_MIN_IND
      validate_lookup (
          p_column                                => 'emp_at_primary_adr_min_ind',
          p_lookup_type                           => 'EMP_AT_PRIMARY_ADR_MIN_IND',
          p_column_value                          => p_organization_rec.emp_at_primary_adr_min_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'emp_at_primary_adr_min_ind is lookup code in lookup type EMP_AT_PRIMARY_ADR_MIN_IND. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'emp_at_primary_adr_min_ind is lookup code in lookup type EMP_AT_PRIMARY_ADR_MIN_IND. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;


      --2897298, Added
      ------------------------
      -- validate rent_own_ind
      ------------------------

      -- Bug 3333036.
      -- The validation will be called only if the value changes.

      IF p_organization_rec.rent_own_ind IS NOT NULL
         AND
         p_organization_rec.rent_own_ind <> fnd_api.g_miss_char
         AND
          (
            p_create_update_flag = 'C'
          OR
            (
            p_create_update_flag = 'U'
            AND
            p_organization_rec.rent_own_ind <> p_old_organization_rec.rent_own_ind
            )
          )
      THEN
          validate_lookup (
              p_column                                => 'rent_own_ind',
              p_lookup_type                           => 'OWN_RENT_IND',
              p_column_value                          => p_organization_rec.rent_own_ind,
              x_return_status                         => x_return_status);
          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                   'rent_own_ind in lookup OWN_RENT_IND. ' ||
                   'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(
                  p_prefix=>l_debug_prefix,
                  p_message=>'rent_own_ind in lookup OWN_RENT_IND. ' ||
                             'x_return_status = ' || x_return_status,
                  p_msg_level=>fnd_log.level_statement);
          END IF;
     END IF;


      ------------------------------------------------------------------------
      --Validation for ceo_title, ceo_name, principal_title and principal_name
      ------------------------------------------------------------------------

      -- ceo_title, ceo_name, principal_title and principal_name can not be updated by the user if
      -- actual_content_source = 'DNB'.

      -- SSM SST Integration and Extension
      -- Instead of checking for DNB, check if actual_content_source is a purchased source system.
 /*
      IF p_create_update_flag = 'U' AND (
         p_organization_rec.ceo_name IS NOT NULL OR
         p_organization_rec.ceo_title IS NOT NULL OR
         p_organization_rec.principal_title IS NOT NULL OR
         p_organization_rec.principal_name IS NOT NULL ) AND
         /*p_organization_rec.actual_content_source = 'DNB' AND
         NVL(FND_PROFILE.value('HZ_UPDATE_THIRD_PARTY_DATA'), 'N') = 'N'*/
/*       HZ_UTILITY_V2PUB.is_purchased_content_source(p_organization_rec.actual_content_source) = 'Y' AND
         p_organization_rec.actual_content_source <> HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE
      THEN
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        validate_nonupdateable (
          p_column                 => 'ceo_title',
          p_column_value           => p_organization_rec.ceo_title,
          p_old_column_value       => p_old_organization_rec.ceo_title,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'ceo_name',
          p_column_value           => p_organization_rec.ceo_name,
          p_old_column_value       => p_old_organization_rec.ceo_name,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'principal_title',
          p_column_value           => p_organization_rec.principal_title,
          p_old_column_value       => p_old_organization_rec.principal_title,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

         validate_nonupdateable (
          p_column                 => 'principal_name',
          p_column_value           => p_organization_rec.principal_name,
          p_old_column_value       => p_old_organization_rec.principal_name,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

         IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'ceo_title will be considered DNB-only attributes.
                                   If you want to identify the CEO, you should not update these column,
                                   but rather add an appropriate Org Contact.',
                                   p_msg_level=>fnd_log.level_statement);
           END IF;

      END IF;

*/
      -----------------------------------
      -- validate displayed_duns_party_id
      -----------------------------------

      -- displayed_duns_party_id is foreign key of hz_parties.party_id
      IF p_organization_rec.displayed_duns_party_id IS NOT NULL
         AND
         p_organization_rec.displayed_duns_party_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_PARTIES
              WHERE  PARTY_ID = p_organization_rec.displayed_duns_party_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'displayed_duns_party_id');
                  fnd_message.set_token('COLUMN', 'party_id');
                  fnd_message.set_token('TABLE', 'hz_parties');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'displayed_duns_party_id is foreign key of hz_parties.party_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'displayed_duns_party_id is foreign key of hz_parties.party_id. ' ||
                                                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_organization_rec.created_by_module,
        p_old_created_by_module  => p_old_organization_rec.created_by_module,
        x_return_status          => x_return_status);

      --------------------------------------
      -- validate application_id
      --------------------------------------

      validate_application_id(
        p_create_update_flag     => p_create_update_flag,
        p_application_id         => p_organization_rec.application_id,
        p_old_application_id     => p_old_organization_rec.application_id,
        x_return_status          => x_return_status);

      ---------------------------------------
      -- validation for home_country
      ---------------------------------------

      -- home_country has foreign key fnd_territories.territory_code
      validate_country_code(
          p_column              => 'home_country',
          p_column_value        => p_organization_rec.home_country,
          x_return_status       => x_return_status);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_prefix       => l_debug_prefix,
          p_message      => 'home_country should be in fnd_territories.territory_code. ' ||
                            'x_return_status = ' || x_return_status,
          p_msg_level    => fnd_log.level_statement);
      END IF;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_organization (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      --disable_debug;

  END validate_organization;

 /**
   * PROCEDURE validate_global_loc_num
   *
   * DESCRIPTION
   *     Validates GLOBAL_LOCATION_NUMBER in HZ_PARTY_SITES for check-digit.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *
   *   IN:
   *     global_location_number         GLOBAL_LOCATION_NUMBER column in HZ_PARTY_SITES.
   *
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *    Please see http://www.uc-council.org/checkdig.htm for details of the check-digit
   *    validation.
   *
   * MODIFICATION HISTORY
   *
   *   19-APR-2004    Rajib Ranjan Borah     o Created. Bug 3175816.
   *
   */

  PROCEDURE validate_global_loc_num (
      global_location_number         IN              HZ_PARTY_SITES.GLOBAL_LOCATION_NUMBER%TYPE,
      x_return_status                IN OUT NOCOPY   VARCHAR2
      ) IS
      even_sum                       NUMBER := 0;
      odd_sum                        NUMBER := 0;
      global_loc_num                 NUMBER;
      check_digit                    NUMBER;
      i                              NUMBER;
      l_debug_prefix                 VARCHAR2(30):= '';
  BEGIN

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
          hz_utility_v2pub.debug(
             p_prefix      => l_debug_prefix,
             p_message     => 'validate_global_loc_num(+)',
             p_msg_level   => fnd_log.level_procedure
             );
      END IF;

      IF TRIM(TRANSLATE(global_location_number,'0123456789','          ')) IS NULL
      THEN

          global_loc_num := TO_NUMBER ( global_location_number );

          IF LENGTH(global_location_number) = 13
          THEN
              -- The 13th digit stores the check digit. Store it in a local variable and compare
              -- it with the check-digit computed for the initial 12 digits.
              check_digit    := global_loc_num MOD 10;

              global_loc_num := TRUNC (global_loc_num / 10);

              FOR i IN 1..6
              LOOP
                  even_sum       := even_sum + (global_loc_num MOD 10);
                  global_loc_num := TRUNC (global_loc_num / 10) ;

                  odd_sum        := odd_sum + (global_loc_num MOD 10);
                  global_loc_num := TRUNC (global_loc_num / 10);
              END LOOP;

              even_sum       := (even_sum * 3) + odd_sum;
              -- Now even_sum contains (3 times (even_sum)) + odd_sum

              IF ( check_digit + even_sum ) MOD 10 <> 0
              THEN -- Global location number did not satisfy the check digit validation.
                  FND_MESSAGE.SET_NAME('AR','HZ_API_GLOBAL_LOC_NUM_ERRORS');
                  FND_MSG_PUB.ADD;
                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

          ELSE  -- Global_location_number is not 13 digits long.
              FND_MESSAGE.SET_NAME('AR','HZ_API_GLOBAL_LOC_NUM_ERRORS');
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      ELSE -- corresponding to IF TRIM(TRANSLATE(global_location_number,'0123456789','          '))

          -- Since there are non numeric characters, therefore the expression evaluated in the if
          -- clause is not null.
          FND_MESSAGE.SET_NAME('AR','HZ_API_GLOBAL_LOC_NUM_ERRORS');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
          hz_utility_v2pub.debug(
              p_prefix      => l_debug_prefix,
              p_message     => 'validate_global_loc_num(-)',
              p_msg_level   => fnd_log.level_procedure
              );
       END IF;

  END validate_global_loc_num;

  /**
   * PROCEDURE validate_party_site
   *
   * DESCRIPTION
   *     Validates party site record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_party_site_rec               Party site record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *   04-19-2004    Rajib Ranjan Borah o Bug 3175816. If the value of GLOBAL_LOCATION_NUMBER
   *                                      has changed, then called validate_global_loc_num.
   *   03-May-3004 Venkata Sowjanya S     Bug No : 3609601. Commented the statements which sets tokens Column1,Column2
   *                                        for message HZ_API_INACTIVE_CANNOT_PRIM


   */

  PROCEDURE validate_party_site(
      p_create_update_flag              IN     VARCHAR2,
      p_party_site_rec                  IN     HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
      p_rowid                           IN     ROWID,
      x_return_status                   IN OUT NOCOPY VARCHAR2,
      x_loc_actual_content_source       OUT NOCOPY    VARCHAR2
 ) IS

      l_count                                NUMBER;
      l_party_id                             NUMBER;
      l_location_id                          NUMBER;
      l_party_site_number                    VARCHAR2(30);
      l_orig_system_reference                VARCHAR2(240);
      l_start_date_active                    DATE;
      l_end_date_active                      DATE;
      l_party_site_id                        NUMBER;
      l_identifying_address_flag             VARCHAR2(1);
      l_dummy                                VARCHAR2(1);
      l_created_by_module                    VARCHAR2(150);
      l_application_id                       NUMBER;
      l_status                               VARCHAR2(1);
      db_actual_content_source               VARCHAR2(30);
      l_debug_prefix                         VARCHAR2(30) := '';
      l_validate_osr varchar2(1) := 'Y';
      l_mosr_owner_table_id number;

      -- Bug 3175816
      l_global_location_number               HZ_PARTY_SITES.GLOBAL_LOCATION_NUMBER%TYPE;

      l_temp_return_status   VARCHAR2(10); -- for storing return status from
                                           -- hz_orig_system_ref_pub.get_owner_table_id
  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_party_site (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_party_site (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- select fields for later use during update.
      IF p_create_update_flag = 'U' THEN
          SELECT PARTY_ID,
                 LOCATION_ID,
                 PARTY_SITE_NUMBER,
                 ORIG_SYSTEM_REFERENCE,
                 IDENTIFYING_ADDRESS_FLAG,
                 START_DATE_ACTIVE,
                 END_DATE_ACTIVE,
                 STATUS,
                 CREATED_BY_MODULE,
                 APPLICATION_ID,
                 ACTUAL_CONTENT_SOURCE,
                 GLOBAL_LOCATION_NUMBER
          INTO   l_party_id,
                 l_location_id,
                 l_party_site_number,
                 l_orig_system_reference,
                 l_identifying_address_flag,
                 l_start_date_active,
                 l_end_date_active,
                 l_status,
                 l_created_by_module,
                 l_application_id,
                 db_actual_content_source,
                 l_global_location_number
          FROM   HZ_PARTY_SITES
          WHERE  ROWID = p_rowid;
      END IF;

      --------------------
      -- validate party_id
      --------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- party_id is mandatory field
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'party_id',
          p_column_value                          => p_party_site_rec.party_id,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'party_id is mandatory field. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is mandatory field. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -- party_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'party_id',
              p_column_value                          => p_party_site_rec.party_id,
              p_old_column_value                      => l_party_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                   hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is non-updateable field. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- party_id is foreign key of hz_parties
      -- Do not need to check during update because party_id is
      -- non-updateable.
      IF p_create_update_flag = 'C'
         AND
         p_party_site_rec.party_id IS NOT NULL
         AND
         p_party_site_rec.party_id <> fnd_api.g_miss_num
         AND
         p_party_site_rec.party_id <> -1
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_PARTIES
              WHERE  PARTY_ID = p_party_site_rec.party_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'party_id');
                  fnd_message.set_token('COLUMN', 'party_id');
                  fnd_message.set_token('TABLE', 'hz_parties');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id is foreign key of hz_parties. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                   hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is foreign key of hz_parties. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
    END IF;

      -----------------------
      -- validate location_id
      -----------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- location_id is mandatory field
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'location_id',
          p_column_value                          => p_party_site_rec.location_id,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'location_id is mandatory field. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'location_id is mandatory field. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -- location_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'location_id',
              p_column_value                          => p_party_site_rec.location_id,
              p_old_column_value                      => l_location_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'location_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'location_id is non-updateable field. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- location_id is foreign key of hz_locations.location_id.
      -- do not need to check during update because location_id is
      -- non-updateable.
      IF p_create_update_flag = 'C'
         AND
         p_party_site_rec.location_id IS NOT NULL
         AND
         p_party_site_rec.location_id <> fnd_api.g_miss_num
      THEN
          BEGIN

              -- Bug 2197181: for mix-n-match, column actual_content_source
              -- was added to hz_party_sites. It is denormalized from hz_locations.
              -- Therefore, it is selected from hz_locations to be passed back
              -- to create_party_site API.

              SELECT actual_content_source
              INTO  x_loc_actual_content_source
              FROM   HZ_LOCATIONS
              WHERE  LOCATION_ID = p_party_site_rec.location_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'location_id');
                  fnd_message.set_token('COLUMN', 'location_id');
                  fnd_message.set_token('TABLE', 'hz_locations');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'location_id is foreign key of hz_locations. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'location_id is foreign key of hz_locations. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
    END IF;

      -----------------------------
      -- validate party_site_number
      -----------------------------

      -- party_site_number is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'party_site_number',
              p_column_value                          => p_party_site_rec.party_site_number,
              p_old_column_value                      => l_party_site_number,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_site_number is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                  hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_site_number is non-updateable field. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      ---------------------------------
      -- validate orig_system_reference
      ---------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      IF (p_party_site_rec.orig_system is not null
         and p_party_site_rec.orig_system <>fnd_api.g_miss_char)
       and (p_party_site_rec.orig_system_reference is not null
         and p_party_site_rec.orig_system_reference <>fnd_api.g_miss_char)
        and p_create_update_flag = 'U'
      then
           hz_orig_system_ref_pub.get_owner_table_id
                        (p_orig_system => p_party_site_rec.orig_system,
                        p_orig_system_reference => p_party_site_rec.orig_system_reference,
                        p_owner_table_name => 'HZ_PARTY_SITES',
                        x_owner_table_id => l_mosr_owner_table_id,
                        x_return_status => l_temp_return_status);

           IF (l_temp_return_status = fnd_api.g_ret_sts_success AND
               l_mosr_owner_table_id= nvl(p_party_site_rec.party_site_id,l_mosr_owner_table_id))
           THEN
                l_validate_osr := 'N';
             -- if we can get owner_table_id based on osr and os in mosr table,
             -- we will use unique osr and os for update - bypass osr validation
           ELSE l_validate_osr := 'Y';
           END IF;

           -- Call to hz_orig_system_ref_pub.get_owner_table_id API was resetting the
           -- x_return_status. Set x_return_status to error, ONLY if there is error.
           -- In case of success, leave it to carry over previous value as before this call.
           -- Fix for Bug 5498116 (29-AUG-2006)
           IF (l_temp_return_status = FND_API.G_RET_STS_ERROR) THEN
             x_return_status := l_temp_return_status;
           END IF;

    end if;
      -- orig_system_reference is non-updateable field
      IF p_create_update_flag = 'U' and l_validate_osr = 'Y' THEN
          validate_nonupdateable (
              p_column                                => 'orig_system_reference',
              p_column_value                          => p_party_site_rec.orig_system_reference,
              p_old_column_value                      => l_orig_system_reference,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'orig_system_reference is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                  hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'orig_system_reference is non-updateable field. ' ||
                                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
  END IF;

      ----------------------------------------------
      -- validate status
      ----------------------------------------------

      -- status cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          validate_cannot_update_to_null (
              p_column                                => 'status',
              p_column_value                          => p_party_site_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status cannot be set to null during update. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'status cannot be set to null during update. ' ||
                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


          -- If for a party, DNB provides address components which are different
          -- from the ones it sent originally, the old party site is inactivated
          -- and end-dated and a new one created. We should put a check which
          -- prevents a user from activating a DNB party site that has been
          -- end-dated (because from DNB's perspective, it is no more a valid
          -- site for the party).

          IF db_actual_content_source = 'DNB' AND
             l_end_date_active IS NOT NULL AND
             l_status = 'I' AND
             p_party_site_rec.status = 'A'
          THEN
            /* new message */
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_CANT_ACTIVATE_SITE' );
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- status is lookup code in lookup type REGISTRY_STATUS
      IF p_party_site_rec.status IS NOT NULL
         AND
         p_party_site_rec.status <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_party_site_rec.status <> NVL(l_status, fnd_api.g_miss_char)
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'status',
              p_lookup_type                           => 'REGISTRY_STATUS',
              p_column_value                          => p_party_site_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
  END IF;

      ------------------------------------
      -- validate identifying_address_flag
      ------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- identifying_address_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column              => 'identifying_address_flag',
          p_lookup_type         => 'YES/NO',
          p_column_value        => p_party_site_rec.identifying_address_flag,
          x_return_status       => x_return_status
      );

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'identifying_address_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'identifying_address_flag should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      -- Bug 1882511
      -- If the identify address flag is set to Yes, the status column should
      -- not be Inactive

      IF p_party_site_rec.identifying_address_flag is NOT NULL
         AND p_party_site_rec.identifying_address_flag <> fnd_api.g_miss_char
         AND (p_create_update_flag = 'C'
              OR (p_create_update_flag = 'U'
                  AND p_party_site_rec.identifying_address_flag <>
                    NVL(l_identifying_address_flag, fnd_api.g_miss_char)))
      THEN
        SELECT DECODE(p_party_site_rec.identifying_address_flag,
                      'Y', DECODE(p_party_site_rec.status,
                                  'I', 'N',
                                  '', DECODE(l_status, 'I', 'N')),
                      'Y')
        INTO   l_dummy
        FROM   dual;

        IF l_dummy <> 'Y' THEN
          fnd_message.set_name('AR', 'HZ_API_INACTIVE_CANNOT_PRIM');
          fnd_message.set_token('ENTITY', 'Site');
         -- fnd_message.set_token('COLUMN1', 'identifying_address');
         -- fnd_message.set_token('COLUMN2', 'status');
          fnd_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'If the identify address flag is set to Yes, the status column should not be Inactive.' ||
            'x_return_status = ' || x_return_status,
            l_debug_prefix
          );
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'If the identify address flag is set to Yes, the status column should not be Inactive.' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF;

      /* comment out the validation as the language column is obsoleted in r12
      --------------------------
      -- validation for language
      --------------------------

      -- language has foreign key fnd_languages.language_code
      IF p_party_site_rec.language IS NOT NULL
         AND
         p_party_site_rec.language <> fnd_api.g_miss_char
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   FND_LANGUAGES
              WHERE  LANGUAGE_CODE = p_party_site_rec.language
              AND    INSTALLED_FLAG IN ('B', 'I');
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'language');
                  fnd_message.set_token('COLUMN', 'language_code');
                  fnd_message.set_token('TABLE', 'fnd_languages(installed)');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          -- IF g_debug THEN
          --    hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          --        'language has foreign key fnd_languages.language_code. ' ||
          --        'x_return_status = ' || x_return_status, l_debug_prefix);
          -- END IF;

          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'language has foreign key fnd_languages.language_code. ' ||
                                                   'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
      */

      -------------------------------------------------
      -- validate global_location_number.( Bug 3175816)
      -------------------------------------------------
      IF p_party_site_rec.global_location_number IS NOT NULL AND
         p_party_site_rec.global_location_number <> FND_API.G_MISS_CHAR AND
         (
          p_create_update_flag = 'C' OR
          (
           p_create_update_flag = 'U' AND
           p_party_site_rec.global_location_number <> l_global_location_number
          )
         )
      THEN
         validate_global_loc_num(
              global_location_number      =>   p_party_site_rec.global_location_number,
              x_return_status             =>   x_return_status);
      END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_party_site_rec.created_by_module,
        p_old_created_by_module  => l_created_by_module,
        x_return_status          => x_return_status);

      --------------------------------------
      -- validate application_id
      --------------------------------------

      validate_application_id(
        p_create_update_flag     => p_create_update_flag,
        p_application_id         => p_party_site_rec.application_id,
        p_old_application_id     => l_application_id,
        x_return_status          => x_return_status);

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_party_site (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

  END validate_party_site;

  /**
   * PROCEDURE validate_party_site_use
   *
   * DESCRIPTION
   *     Validates party site use record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_party_site_use_rec           Party site use record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *   11-05-2003    Rajib Ranjan Borah o Bug 2065191.Primary_per_type cannot be set to 'Y'
   *                                      if status is not 'A'.
   *                                      Added variable l_primary_per_type.
   *   03-May-3004 Venkata Sowjanya S     Bug No : 3609601. Commented the statements which sets tokens Column1,Column2
   *                                        for message HZ_API_INACTIVE_CANNOT_PRIM


   */

  PROCEDURE validate_party_site_use(
      p_create_update_flag      IN      VARCHAR2,
      p_party_site_use_rec      IN      HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE,
      p_rowid                   IN      ROWID,
      x_return_status       IN OUT NOCOPY      VARCHAR2
 ) IS

      l_count                           NUMBER;
      l_party_site_id                   NUMBER;
      l_site_use_type                   HZ_PARTY_SITE_USES.SITE_USE_TYPE%TYPE;
      l_begin_date                      DATE;
      l_dummy                           VARCHAR2(1);
      l_created_by_module               VARCHAR2(150);
      l_application_id                  NUMBER;
      l_status                          VARCHAR2(1);
      l_debug_prefix                    VARCHAR2(30) := '';
      -- Bug 2065191.
      l_primary_per_type                HZ_PARTY_SITE_USES.PRIMARY_PER_TYPE%TYPE;

  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_party_site_use (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_party_site_use (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

      -- select fields for later use during update.
      IF p_create_update_flag = 'U' THEN
          SELECT PARTY_SITE_ID,
                 SITE_USE_TYPE,
                 BEGIN_DATE,
                 STATUS,
                 CREATED_BY_MODULE,
                 APPLICATION_ID,
                 --Bug 2065191
                 PRIMARY_PER_TYPE

          INTO   l_party_site_id,
                 l_site_use_type,
                 l_begin_date,
                 l_status,
                 l_created_by_module,
                 l_application_id,
                 --BUG 2065191
                 l_primary_per_type

          FROM   HZ_PARTY_SITE_USES
          WHERE  ROWID = p_rowid;
      END IF;

      -------------------------
      -- validate party_site_id
      -------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- party_site_id is mandatory field
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'party_site_id',
          p_column_value                          => p_party_site_use_rec.party_site_id,
          x_return_status                         => x_return_status);

      -- party_site_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'party_site_id',
              p_column_value                          => p_party_site_use_rec.party_site_id,
              p_old_column_value                      => l_party_site_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_site_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_site_id is non-updateable field. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- party_site_id is foreign key of hz_party_sites.party_site_id
      -- Do not need to check during update because party_site_id is
      -- non-updateable.
      IF p_create_update_flag = 'C'
         AND
         p_party_site_use_rec.party_site_id IS NOT NULL
         AND
         p_party_site_use_rec.party_site_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_PARTY_SITES
              WHERE  PARTY_SITE_ID = p_party_site_use_rec.party_site_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'party_site_id');
                  fnd_message.set_token('COLUMN', 'party_site_id');
                  fnd_message.set_token('TABLE', 'hz_party_sites');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_site_id is foreign key of hz_party_sites.party_site_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            p_message=>'party_site_id is foreign key of hz_party_sites.party_site_id. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
  END IF;

      -------------------------
      -- validate site_use_type
      -------------------------

      -- site_use_type is mandatory field
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'site_use_type',
          p_column_value                          => p_party_site_use_rec.site_use_type,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'site_use_type is mandatory field. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'site_use_type is mandatory field. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


      -- site_use_type is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'site_use_type',
              p_column_value                          => p_party_site_use_rec.site_use_type,
              p_old_column_value                      => l_site_use_type,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'site_use_type is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'site_use_type is non-updateable field. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- site_use_type is lookup code in lookup type PARTY_SITE_USE_CODE
      validate_lookup (
          p_column                                => 'site_use_type',
          p_lookup_type                           => 'PARTY_SITE_USE_CODE',
          p_column_value                          => p_party_site_use_rec.site_use_type,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'site_use_type is lookup code in lookup type PARTY_SITE_USE_CODE. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'site_use_type is lookup code in lookup type PARTY_SITE_USE_CODE. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      ----------------------------
      -- validate primary_per_type
      ----------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- primary_per_type is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'primary_per_type',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_party_site_use_rec.primary_per_type,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'primary_per_type should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'primary_per_type should be in lookup YES/NO. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ----------------------------------------------------------
      -- validate combination of party_site_id and site_use_type
      ----------------------------------------------------------

      -- combination of party_site_id and site_use_type is unique
     if p_party_site_use_rec.status <> 'I' or (p_create_update_flag = 'C' and (p_party_site_use_rec.status is null or p_party_site_use_rec.status = fnd_api.g_miss_char ))
             -- bug 8506794, BO API allows to pass in multiple site uses at same time such as 'A', 'I', null for status
    then
      BEGIN
          SELECT 'Y'
          INTO   l_dummy
          FROM   HZ_PARTY_SITE_USES
          -- Bug 3988537.
          WHERE  PARTY_SITE_ID = nvl(p_party_site_use_rec.party_site_id,l_party_site_id)
          AND    SITE_USE_TYPE = nvl(p_party_site_use_rec.site_use_type,l_site_use_type)
          AND    STATUS = 'A'
          AND    PARTY_SITE_USE_ID <> NVL(p_party_site_use_rec.party_site_use_id, fnd_api.g_miss_num);

          fnd_message.set_name('AR', 'HZ_API_UNIQUE_SITE_USE_TYPE');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              NULL;
      END;
    end if;
      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'combination of party_site_id and site_use_type is unique. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'combination of party_site_id and site_use_type is unique. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      ------------------
      -- validate status
      ------------------

      -- status cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          validate_cannot_update_to_null (
              p_column                                => 'status',
              p_column_value                          => p_party_site_use_rec.status,
              x_return_status                         => x_return_status);
      END IF;

/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- status is lookup code in lookup type REGISTRY_STATUS
      IF p_party_site_use_rec.status IS NOT NULL
         AND
         p_party_site_use_rec.status <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_party_site_use_rec.status <> NVL(l_status, fnd_api.g_miss_char)
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'status',
              p_lookup_type                           => 'REGISTRY_STATUS',
              p_column_value                          => p_party_site_use_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;
  END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_party_site_use_rec.created_by_module,
        p_old_created_by_module  => l_created_by_module,
        x_return_status          => x_return_status);

      --------------------------------------
      -- validate application_id
      --------------------------------------

      validate_application_id(
        p_create_update_flag     => p_create_update_flag,
        p_application_id         => p_party_site_use_rec.application_id,
        p_old_application_id     => l_application_id,
        x_return_status          => x_return_status);

      -- Bug 2065191.status and primary_per_type cannot be 'I' and 'Y' at the same time.
      ----------------------------------------
      -- validate primary_per_type and status.
      ----------------------------------------

      IF NVL(p_party_site_use_rec.primary_per_type,l_primary_per_type) ='Y'
      AND NVL(p_party_site_use_rec.status,l_status) = 'I'
      THEN
          FND_MESSAGE.SET_NAME('AR','HZ_API_INACTIVE_CANNOT_PRIM');
          FND_MESSAGE.SET_TOKEN('ENTITY','Party Site Use');
      --    FND_MESSAGE.SET_TOKEN('COLUMN1','PRIMARY_PER_TYPE');
      --    FND_MESSAGE.SET_TOKEN('COLUMN2','STATUS');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_party_site_use (-)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_party_site_use (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


      --disable_debug;

  END validate_party_site_use;

  /**
   * PROCEDURE validate_org_contact
   *
   * DESCRIPTION
   *     Validates org contact record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_org_contact_rec              Org contact record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *
   */

  PROCEDURE validate_org_contact(
      p_create_update_flag      IN      VARCHAR2,
      p_org_contact_rec         IN      HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE,
      p_rowid                   IN      ROWID,
      x_return_status           IN OUT NOCOPY  VARCHAR2
 ) IS

      l_party_relationship_id           NUMBER;
      l_dummy                           VARCHAR2(1);
      l_created_by_module               VARCHAR2(150);
      l_application_id                  NUMBER;
      -- l_title                           VARCHAR2(30);
      l_job_title_code                  VARCHAR2(30);
      l_department_code                 VARCHAR2(30);
      l_debug_prefix                    VARCHAR2(30) := '';

  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_org_contact (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_org_contact (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


      -- select fields for later use during update.
      IF p_create_update_flag = 'U' THEN
          SELECT PARTY_RELATIONSHIP_ID,
                 -- TITLE,
                 JOB_TITLE_CODE,
                 DEPARTMENT_CODE,
                 CREATED_BY_MODULE,
                 APPLICATION_ID
          INTO   l_party_relationship_id,
                 -- l_title,
                 l_job_title_code,
                 l_department_code,
                 l_created_by_module,
                 l_application_id
          FROM   HZ_ORG_CONTACTS
          WHERE  ROWID = p_rowid;
      END IF;

      ---------------------------------
      -- validate party_relationship_id
      ---------------------------------

      -- party_relationship_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'party_relationship_id',
              p_column_value                          => p_org_contact_rec.party_rel_rec.relationship_id,
              p_old_column_value                      => l_party_relationship_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_relationship_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_relationship_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      /* comment out the validation as the title column is obsoleted in r12
      -----------------
      -- validate title
      -----------------

      -- title is lookup code in lookup type CONTACT_TITLE
      IF p_org_contact_rec.title IS NOT NULL
         AND
         p_org_contact_rec.title <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_org_contact_rec.title <> NVL(l_title, fnd_api.g_miss_char)
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'title',
              p_lookup_type                           => 'CONTACT_TITLE',
              p_column_value                          => p_org_contact_rec.title,
              x_return_status                         => x_return_status);

          -- IF g_debug THEN
          --    hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          --        'title is lookup code in lookup type CONTACT_TITLE. ' ||
          --        'x_return_status = ' || x_return_status, l_debug_prefix);
          --- END IF;

          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'title is lookup code in lookup type CONTACT_TITLE. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;
      */

      --------------------------
      -- validate job_title_code
      --------------------------

      -- job_title_code is lookup code in lookup type RESPONSIBILITY
      IF p_org_contact_rec.job_title_code IS NOT NULL
         AND
         p_org_contact_rec.job_title_code <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_org_contact_rec.job_title_code <> NVL(l_job_title_code, fnd_api.g_miss_char)
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'job_title_code',
              p_lookup_type                           => 'RESPONSIBILITY',
              p_column_value                          => p_org_contact_rec.job_title_code,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'job_title_code is lookup code in lookup type RESPONSIBILITY. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'job_title_code is lookup code in lookup type RESPONSIBILITY. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      -------------------------------
      -- validate decision_maker_flag
      -------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- decision_maker_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'decision_maker_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_org_contact_rec.decision_maker_flag,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'decision_maker_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'decision_maker_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;
  END IF;

      ------------------------------
      -- validate reference_use_flag
      ------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- reference_use_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'reference_use_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_org_contact_rec.reference_use_flag,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'reference_use_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'reference_use_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
  END IF;

      ---------------------------
      -- validate department_code
      ---------------------------

      -- department_code is lookup code in lookup type DEPARTMENT_TYPE
      IF p_org_contact_rec.department_code IS NOT NULL
         AND
         p_org_contact_rec.department_code <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_org_contact_rec.department_code <> NVL(l_department_code, fnd_api.g_miss_char)
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'department_code',
              p_lookup_type                           => 'DEPARTMENT_TYPE',
              p_column_value                          => p_org_contact_rec.department_code,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'department_code is lookup code in lookup type DEPARTMENT_TYPE. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'department_code is lookup code in lookup type DEPARTMENT_TYPE. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      -------------------------
      -- validate party_site_id
      -------------------------

      -- if party_site_id is passed, then it must be validated as
      -- foreign key to hz_party_sites.party_site_id
      IF p_org_contact_rec.party_site_id IS NOT NULL
         AND
         p_org_contact_rec.party_site_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_PARTY_SITES
              WHERE  PARTY_SITE_ID = p_org_contact_rec.party_site_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'party_site_id');
                  fnd_message.set_token('COLUMN', 'party_site_id');
                  fnd_message.set_token('TABLE', 'hz_party_sites');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_site_id is foreign key to hz_party_sites.party_site_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'party_site_id is foreign key to hz_party_sites.party_site_id. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;


      END IF;

      -- if party_site_id is passed then its party_id should be
      -- same as the object_id of the relationship record for the org_contact
      IF p_org_contact_rec.party_site_id IS NOT NULL
         AND
         p_org_contact_rec.party_site_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_PARTY_SITES
              WHERE  PARTY_SITE_ID = p_org_contact_rec.party_site_id
              AND    PARTY_ID = p_org_contact_rec.party_rel_rec.object_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_PARTY_OBJECT_MISMATCH');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id of party site should be same as the object_id of the relationship record. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            p_message=>'party_id of party site should be same as the object_id of the relationship record. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_org_contact_rec.created_by_module,
        p_old_created_by_module  => l_created_by_module,
        x_return_status          => x_return_status);

      --------------------------------------
      -- validate application_id
      --------------------------------------

      validate_application_id(
        p_create_update_flag     => p_create_update_flag,
        p_application_id         => p_org_contact_rec.application_id,
        p_old_application_id     => l_application_id,
        x_return_status          => x_return_status);

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_org_contact (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  END validate_org_contact;

  /**
   * PROCEDURE validate_org_contact_role
   *
   * DESCRIPTION
   *     Validates org contact role record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_org_contact_role_rec         Org contact role record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *
   */

  PROCEDURE validate_org_contact_role(
      p_create_update_flag      IN      VARCHAR2,
      p_org_contact_role_rec    IN      HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE,
      p_rowid                   IN      ROWID,
      x_return_status       IN OUT NOCOPY      VARCHAR2
 ) IS

      l_org_contact_id                  NUMBER;
      l_orig_system_reference           VARCHAR2(240);
      l_role_id                         NUMBER;
      l_dummy                           VARCHAR2(1);
      l_created_by_module               VARCHAR2(150);
      l_application_id                  NUMBER;
      l_count                           NUMBER;
      l_status                          VARCHAR2(1);
      l_debug_prefix                    VARCHAR2(30) := '';
      l_validate_osr varchar2(1) := 'Y';
      l_mosr_owner_table_id number;
      l_temp_return_status   VARCHAR2(10); -- for storing return status from
                                           -- hz_orig_system_ref_pub.get_owner_table_id
  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_org_contact_role (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_org_contact_role (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      IF p_create_update_flag = 'U' THEN
          SELECT ORG_CONTACT_ID,
                 ORIG_SYSTEM_REFERENCE,
                 STATUS,
                 CREATED_BY_MODULE,
                 APPLICATION_ID
          INTO   l_org_contact_id,
                 l_orig_system_reference,
                 l_status,
                 l_created_by_module,
                 l_application_id
          FROM   HZ_ORG_CONTACT_ROLES
          WHERE  ROWID = p_rowid;
      END IF;

      --------------------------
      -- validate org_contact_id
      --------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- org_contact_id is mandatory field
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'org_contact_id',
          p_column_value                          => p_org_contact_role_rec.org_contact_id,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'org_contact_id is mandatory field. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'org_contact_id is mandatory field. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -- org_contact_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'org_contact_id',
              p_column_value                          => p_org_contact_role_rec.org_contact_id,
              p_old_column_value                      => l_org_contact_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'org_contact_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'org_contact_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;

      END IF;

      -- org_contact_id is foreign key of hz_org_contacts.org_contact_id.
      -- do not need to check during update because org_contact_id is
      -- non-updateable.
      IF p_create_update_flag = 'C'
         AND
         p_org_contact_role_rec.org_contact_id IS NOT NULL
         AND p_org_contact_role_rec.org_contact_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_ORG_CONTACTS
              WHERE  ORG_CONTACT_ID = p_org_contact_role_rec.org_contact_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'org_contact_id');
                  fnd_message.set_token('COLUMN', 'org_contact_id');
                  fnd_message.set_token('TABLE', 'hz_org_contacts');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'org_contact_id is foreign key of hz_org_contacts.org_contact_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'org_contact_id is foreign key of hz_org_contacts.org_contact_id. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
  END IF;

      ---------------------------------
      -- validate orig_system_reference
      ---------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      IF (p_org_contact_role_rec.orig_system is not null
         and p_org_contact_role_rec.orig_system <>fnd_api.g_miss_char)
       and (p_org_contact_role_rec.orig_system_reference is not null
         and p_org_contact_role_rec.orig_system_reference <>fnd_api.g_miss_char)
         and p_create_update_flag = 'U'

        then
           hz_orig_system_ref_pub.get_owner_table_id
                        (p_orig_system => p_org_contact_role_rec.orig_system,
                        p_orig_system_reference => p_org_contact_role_rec.orig_system_reference,
                        p_owner_table_name => 'HZ_ORG_CONTACT_ROLES',
                        x_owner_table_id => l_mosr_owner_table_id,
                        x_return_status => l_temp_return_status);

           IF (l_temp_return_status = fnd_api.g_ret_sts_success AND
		       l_mosr_owner_table_id= nvl(p_org_contact_role_rec.org_contact_role_id,l_mosr_owner_table_id))
           THEN
                l_validate_osr := 'N';
            -- if we can get owner_table_id based on osr and os in mosr table,
            -- we will use unique osr and os for update - bypass osr validation
           ELSE l_validate_osr := 'Y';
           END IF;

           -- Call to hz_orig_system_ref_pub.get_owner_table_id API was resetting the
           -- x_return_status. Set x_return_status to error, ONLY if there is error.
           -- In case of success, leave it to carry over previous value as before this call.
           -- Fix for Bug 5498116 (29-AUG-2006)
           IF (l_temp_return_status = FND_API.G_RET_STS_ERROR) THEN
             x_return_status := l_temp_return_status;
           END IF;

    end if;
      -- orig_system_reference is non-updateable field
      IF p_create_update_flag = 'U'  and l_validate_osr = 'Y' THEN
          validate_nonupdateable (
              p_column                                => 'orig_system_reference',
              p_column_value                          => p_org_contact_role_rec.orig_system_reference,
              p_old_column_value                      => l_orig_system_reference,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'orig_system_reference is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'orig_system_reference is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
  END IF;

      ---------------------
      -- validate role_type
      ---------------------

      -- role_type is mandatory field
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'role_type',
          p_column_value                          => p_org_contact_role_rec.role_type,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'role_type is mandatory field. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'role_type is mandatory field. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -- role_type cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          validate_cannot_update_to_null (
              p_column                                => 'role_type',
              p_column_value                          => p_org_contact_role_rec.role_type,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'role_type cannot be set to null during update. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
             p_message=>'role_type cannot be set to null during update. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- role_type is lookup code in lookup type CONTACT_ROLE_TYPE
      validate_lookup (
          p_column                                => 'role_type',
          p_lookup_type                           => 'CONTACT_ROLE_TYPE',
          p_column_value                          => p_org_contact_role_rec.role_type,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'role_type is lookup code in lookup type CONTACT_ROLE_TYPE. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'role_type is lookup code in lookup type CONTACT_ROLE_TYPE. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      ------------------------
      -- validate primary_flag
      ------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- primary_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'primary_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_org_contact_role_rec.primary_flag,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'primary_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'primary_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      -- primary_flag can be set only for one record of org_contact_id.
      IF p_org_contact_role_rec.primary_flag = 'Y' THEN
          BEGIN
              SELECT ORG_CONTACT_ROLE_ID
              INTO   l_role_id
              FROM   HZ_ORG_CONTACT_ROLES
              WHERE  ORG_CONTACT_ID = p_org_contact_role_rec.org_contact_id
              AND    PRIMARY_FLAG = 'Y'
              AND    ROWNUM  = 1;
              /* Bug Fix: 3936336 */
              IF        l_role_id <> p_org_contact_role_rec.org_contact_role_id OR
                        p_create_update_flag = 'C' THEN
                        fnd_message.set_name('AR', 'HZ_API_UNIQUE_PRIMARY_ROLE');
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
              END IF;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  NULL;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'primary_flag can be set only for one record of org_contact_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            p_message=>'primary_flag can be set only for one record of org_contact_id. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -------------------------------------------------------
      -- validate combination of org_contact_id and role_type
      -------------------------------------------------------

      -- combination of org_contact_id and role_type must be unique.
      -- validates only when role_id in the database is different from
      -- the role_id to be updated.

      BEGIN
          SELECT ORG_CONTACT_ROLE_ID
          INTO   l_role_id
          FROM   HZ_ORG_CONTACT_ROLES
          WHERE  ORG_CONTACT_ID = NVL(p_org_contact_role_rec.org_contact_id, fnd_api.g_miss_num)
          AND    ROLE_TYPE      = p_org_contact_role_rec.role_type
          AND    STATUS         = 'A' -- Added: Bug#6411541
          AND    ROWNUM         = 1;

          IF l_role_id <> nvl(p_org_contact_role_rec.org_contact_role_id, fnd_api.g_miss_num) THEN
              fnd_message.set_name('AR', 'HZ_API_UNIQUE_ROLE_TYPE');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
          END IF;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              NULL;
      END;

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'combination of org_contact_id and role_type must be unique. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'combination of org_contact_id and role_type must be unique. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -----------------------------------------
      -- validate primary_contact_per_role_type
      -----------------------------------------

      -- primary_contact_per_role_type is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'primary_contact_per_role_type',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_org_contact_role_rec.primary_contact_per_role_type,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'primary_contact_per_role_type should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'primary_contact_per_role_type should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

      -- only one org contact can be set as primary within
      -- same organization party.
      IF p_org_contact_role_rec.primary_contact_per_role_type = 'Y' THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_RELATIONSHIPS PR,
                     HZ_ORG_CONTACTS OC,
                     HZ_ORG_CONTACT_ROLES OCR,
                     HZ_RELATIONSHIPS PR2,
                     HZ_ORG_CONTACTS OC2
              WHERE  OCR.PRIMARY_CONTACT_PER_ROLE_TYPE = 'Y'
              AND    OCR.ROLE_TYPE = p_org_contact_role_rec.role_type
              AND    OCR.ORG_CONTACT_ID = OC.ORG_CONTACT_ID
              AND    OC.PARTY_RELATIONSHIP_ID = PR.RELATIONSHIP_ID
              AND    PR.OBJECT_ID = PR2.OBJECT_ID
              AND    PR2.RELATIONSHIP_ID = OC2.PARTY_RELATIONSHIP_ID
              AND    OC2.ORG_CONTACT_ID = P_ORG_CONTACT_ROLE_REC.ORG_CONTACT_ID
              AND    PR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
              AND    PR.OBJECT_TABLE_NAME = 'HZ_PARTIES'
              AND    PR.DIRECTIONAL_FLAG = 'F'
              AND    PR2.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
              AND    PR2.OBJECT_TABLE_NAME = 'HZ_PARTIES'
              AND    PR2.DIRECTIONAL_FLAG = 'F'
	      and    ocr.org_contact_role_id <>p_org_contact_role_rec.org_contact_role_id; --db primary role id is not same as the pass in role id

              fnd_message.set_name('AR', 'HZ_API_UNIQUE_PRIMARY_ORG_CONT');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  NULL;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'only one org contact can be set as primary within same organization party. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'only one org contact can be set as primary within same organization party. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      ------------------
      -- validate status
      ------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- status is lookup code in lookup type REGISTRY_STATUS
      IF p_org_contact_role_rec.status IS NOT NULL
         AND
         p_org_contact_role_rec.status <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_org_contact_role_rec.status <> NVL(l_status, fnd_api.g_miss_char)
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'status',
              p_lookup_type                           => 'REGISTRY_STATUS',
              p_column_value                          => p_org_contact_role_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;

      END IF;
  END IF;

      -- status cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          validate_cannot_update_to_null (
              p_column                                => 'status',
              p_column_value                          => p_org_contact_role_rec.status,
              x_return_status                         => x_return_status);
      END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_org_contact_role_rec.created_by_module,
        p_old_created_by_module  => l_created_by_module,
        x_return_status          => x_return_status);

      --------------------------------------
      -- validate application_id
      --------------------------------------

      validate_application_id(
        p_create_update_flag     => p_create_update_flag,
        p_application_id         => p_org_contact_role_rec.application_id,
        p_old_application_id     => l_application_id,
        x_return_status          => x_return_status);

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_org_contact_role (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

  END validate_org_contact_role;

  /**
   * PROCEDURE validate_person_language
   *
   * DESCRIPTION
   *     Validates person language record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_person_language_rec          Person language record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *   01-10-2003    Porkodi Chinnandar o Added few lines to have validation for spoken_
   *                                      comprehension_level. The value entered for spoken_
   *                                      comprehension_level is validated against lookup type
   *                                      HZ_LANGUAGE_PROFICIENCY.
   *   18-03-2003    Porkodi Chinnandar o 2820135, Party should have only one native_languge and
   *                                      one primary language. This check has been moved to
   *                                      ARH2PISB due to the update involved in this.
   *   01-MAR-2004   Rajib Ranjan Borah o Bug 3363458.Modified previous validation to ensure
   *                                      that the primary language cannot be inactive.
   *                                      Added local variable l_primary_language_indicator
   *                                      for the same.
   *   03-May-3004 Venkata Sowjanya S     Bug No : 3609601. Commented the statements which sets tokens Column1,Column2
   *                                        for message HZ_API_INACTIVE_CANNOT_PRIM
   */

  PROCEDURE validate_person_language(
      p_create_update_flag                    IN      VARCHAR2,
      p_person_language_rec                   IN      HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE,
      p_rowid                                 IN      ROWID ,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

      l_count                                          NUMBER;
      l_dummy                                          VARCHAR2(1);
      l_party_id                                       NUMBER := p_person_language_rec.party_id;
      l_created_by_module                              VARCHAR2(150);
      l_application_id                                 NUMBER;
      l_language_name                                  VARCHAR2(4);
      l_status                                         VARCHAR2(1);
      l_debug_prefix                                   VARCHAR2(30) := '';
      l_primary_language_indicator                     VARCHAR2(1);

  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_person_language (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_person_language (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- do the query to get old values for update
      IF p_create_update_flag = 'U'
      THEN
          SELECT PARTY_ID,
                 LANGUAGE_NAME,
                 STATUS,
                 CREATED_BY_MODULE,
                 APPLICATION_ID,
                 PRIMARY_LANGUAGE_INDICATOR
          INTO   l_party_id,
                 l_language_name,
                 l_status,
                 l_created_by_module,
                 l_application_id,
                 l_primary_language_indicator
          FROM   HZ_PERSON_LANGUAGE
          WHERE  ROWID = p_rowid;
      END IF;

      --------------------------
      -- validation for party_id
      --------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- party_id is mandatory field
      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'party_id',
              p_column_value                          => p_person_language_rec.party_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id is mandatory field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is mandatory field. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- party_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'party_id',
              p_column_value                          => p_person_language_rec.party_id,
              p_old_column_value                      => l_party_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- party_id has foreign key HZ_PARTIES.PARTY_ID
      IF p_create_update_flag = 'C'
         AND
         p_person_language_rec.party_id IS NOT NULL
         AND
         p_person_language_rec.party_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   hz_parties
              WHERE  party_id = p_person_language_rec.party_id;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'party_id');
                  fnd_message.set_token('COLUMN', 'party_id');
                  fnd_message.set_token('TABLE', 'hz_parties');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id has foreign key hz_parties.party_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id has foreign key hz_parties.party_id. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
  END IF;

      -------------------------------
      -- validation for language_name
      -------------------------------

      -- language_name is mandatory field
      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'language_name',
              p_column_value                          => p_person_language_rec.language_name,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'language_name is mandatory field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'language_name is mandatory field. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- language_name is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'language_name',
              p_column_value                          => p_person_language_rec.language_name,
              p_old_column_value                      => l_language_name,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'language_name is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'language_name is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- language_name has foreign key fnd_languages.language_code
      IF p_person_language_rec.language_name IS NOT NULL
         AND
         p_person_language_rec.language_name <> fnd_api.g_miss_char
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   FND_LANGUAGES
              WHERE  LANGUAGE_CODE = p_person_language_rec.language_name;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'language_name');
                  fnd_message.set_token('COLUMN', 'language_code');
                  fnd_message.set_token('TABLE', 'fnd_languages');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'language_name has foreign key fnd_languages.language_code. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            p_message=>'language_name has foreign key fnd_languages.language_code. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- there can be only one record for a given party and language
      BEGIN
          SELECT 1
          INTO   l_dummy
          FROM   HZ_PERSON_LANGUAGE
          WHERE  PARTY_ID = l_party_id
          AND    LANGUAGE_NAME = p_person_language_rec.language_name
          AND    LANGUAGE_USE_REFERENCE_ID <> NVL(p_person_language_rec.language_use_reference_id, fnd_api.g_miss_num);

          fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
          fnd_message.set_token('COLUMN', 'language_name');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              NULL;
      END;

      ---------------------------------
      -- validation for native_language
      ---------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- native_language is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'native_language',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_person_language_rec.native_language,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'native_language should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'native_language should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      --------------------------------------------
      -- validation for spoken_comprehension_level
      --------------------------------------------

      -- spoken_comprehension_level is lookup code in lookup type HZ_LANGUAGE_PROFICIENCY
      validate_lookup (
          p_column                                => 'spoken_comprehension_level',
          p_lookup_type                           => 'HZ_LANGUAGE_PROFICIENCY',
          p_column_value                          => p_person_language_rec.spoken_comprehension_level,
          x_return_status                         => x_return_status);


      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'spoken_comprehension_level should be in lookup HZ_LANGUAGE_PROFICIENCY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'spoken_comprehension_level should be in lookup HZ_LANGUAGE_PROFICIENCY. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      --------------------------------------------
      -- validation for primary_language_indicator
      --------------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- primary_language_indicator is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'primary_language_indicator',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_person_language_rec.primary_language_indicator,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'primary_language_indicator should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'primary_language_indicator should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ------------------------
      -- validation for status
      ------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- status is lookup code in lookup type REGISTRY_STATUS
      IF p_person_language_rec.status IS NOT NULL
         AND
         p_person_language_rec.status <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_person_language_rec.status <> NVL(l_status, fnd_api.g_miss_char)
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'status',
              p_lookup_type                           => 'REGISTRY_STATUS',
              p_column_value                          => p_person_language_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
  END IF;

      -- status cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          validate_cannot_update_to_null (
              p_column                                => 'status',
              p_column_value                          => p_person_language_rec.status,
              x_return_status                         => x_return_status);
      END IF;


      -- 2820135, the following check has been made as part of this bug
      -- If the primary_language_indicator is set to Yes, the status column should
      -- not be Inactive

      -- Bug 3363458.The previous validation did not take care of the condition when
      -- the status for a primary language was updated from 'A' to 'I'.

/*
      IF p_person_language_rec.primary_language_indicator is NOT NULL
         AND p_person_language_rec.primary_language_indicator <> fnd_api.g_miss_char
         AND (p_create_update_flag = 'C'
              OR (p_create_update_flag = 'U'
                  AND p_person_language_rec.primary_language_indicator <>
                    NVL(l_primary_language_indicator, fnd_api.g_miss_char)))
      THEN
        SELECT DECODE(p_person_language_rec.primary_language_indicator,
                      'Y', DECODE(p_person_language_rec.status,
                                  'I', 'N',
                                  '', DECODE(l_status, 'I', 'N')),
                      'Y')
        INTO   l_dummy
        FROM   dual;

        IF l_dummy <> 'Y' THEN
        fnd_message.set_name('AR', 'HZ_API_INACTIVE_CANNOT_PRIM');
        fnd_message.set_token('ENTITY', 'language');
       -- fnd_message.set_token('COLUMN1', 'primary_language_indicator');
       -- fnd_message.set_token('COLUMN2', 'status');
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        */

        -- Bug 3363458.
        IF p_create_update_flag = 'C'
        THEN
            IF (p_person_language_rec.primary_language_indicator = 'Y'
               AND p_person_language_rec.status = 'I')
            THEN
                fnd_message.set_name('AR', 'HZ_API_INACTIVE_CANNOT_PRIM');
                fnd_message.set_token('ENTITY', 'Language');
        --        fnd_message.set_token('COLUMN1', 'primary_language_indicator');
        --        fnd_message.set_token('COLUMN2', 'status');
                fnd_msg_pub.add;
                x_return_status := FND_API.G_RET_STS_ERROR;

                IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                    hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    p_message=>'If the primary_language_indicator is set to Yes, the status column should not be Inactive.' ||
                    'x_return_status = ' || x_return_status,
                    p_msg_level=>fnd_log.level_statement);
                END IF;

            END IF;
        ELSE  -- p_create_update_flag = 'U'
            IF (NVL(p_person_language_rec.primary_language_indicator,l_primary_language_indicator)='Y'
               AND NVL(p_person_language_rec.status,l_status)='I')
            THEN
                fnd_message.set_name('AR', 'HZ_API_INACTIVE_CANNOT_PRIM');
                fnd_message.set_token('ENTITY', 'Language');
                --fnd_message.set_token('COLUMN1', 'primary_language_indicator');
               -- fnd_message.set_token('COLUMN2', 'status');
                fnd_msg_pub.add;
                x_return_status := FND_API.G_RET_STS_ERROR;

                IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                    hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    p_message=>'If the primary_language_indicator is set to Yes, the status column should not be Inactive.' ||
                    'x_return_status = ' || x_return_status,
                    p_msg_level=>fnd_log.level_statement);
                END IF;

            END IF;
        END IF;  -- corresponding to IF p_create_update_flag = 'C'

       /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'If the primary_language_indicator is set to Yes, the status column should not be Inactive.' ||
            'x_return_status = ' || x_return_status,
            l_debug_prefix
          );
        END IF;
        */

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_person_language_rec.created_by_module,
        p_old_created_by_module  => l_created_by_module,
        x_return_status          => x_return_status);

      --------------------------------------
      -- validate application_id
      --------------------------------------

      validate_application_id(
        p_create_update_flag     => p_create_update_flag,
        p_application_id         => p_person_language_rec.application_id,
        p_old_application_id     => l_application_id,
        x_return_status          => x_return_status);

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_person_language (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

  END validate_person_language;


  /**
   * PROCEDURE validate_citizenship
   *
   * DESCRIPTION
   *     Validates citizenship record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_citizenship_rec              Citizenship record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   31-Jan-2001    Porkodi C         o Created.
   *   10-Mar-2003    Porkodi C         o Bug 2820483, Added mandatory check for country_code
   *                                      Bug 2820462, Added the party_type check for the party_id
   *
   */

    PROCEDURE validate_citizenship(
        p_create_update_flag                    IN      VARCHAR2,
        p_citizenship_rec                       IN      HZ_PERSON_INFO_V2PUB.CITIZENSHIP_REC_TYPE,
        p_rowid                                 IN      ROWID ,
        x_return_status                         IN OUT NOCOPY  VARCHAR2
   ) IS

        l_count                                          NUMBER;
        l_dummy                                          VARCHAR2(1);
        l_party_id                                       NUMBER := p_citizenship_rec.party_id;
        l_created_by_module                              VARCHAR2(150);
        l_application_id                                 NUMBER;
        l_citizenship_id                                 NUMBER;
        l_status                                         VARCHAR2(1);
        l_debug_prefix                                   VARCHAR2(30) := '';


        CURSOR citizen_cur (p_citizenship_id IN NUMBER) IS
              SELECT 'Y'
              FROM   hz_citizenship hc
        WHERE  hc.citizenship_id = p_citizenship_id;


    BEGIN

        --enable_debug;

        -- Debug info.
        /*IF g_debug THEN
            hz_utility_v2pub.debug ('validate_citizenship (+)');
        END IF;
        */
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_citizenship (+)',
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- do the query to get old values for update
        IF p_create_update_flag = 'U'
        THEN
            SELECT CITIZENSHIP_ID,
                   PARTY_ID,
                   STATUS,
                   CREATED_BY_MODULE,
                   APPLICATION_ID
            INTO   l_citizenship_id,
                   l_party_id,
                   l_status,
                   l_created_by_module,
                   l_application_id
            FROM   HZ_CITIZENSHIP
            WHERE  ROWID = p_rowid;
        END IF;


        --------------------------------------
        -- validate citizenship_id
        --------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- If primary key value is passed, check for uniqueness.
        -- If primary key value is not passed, it will be generated
        -- from sequence by table handler.

        IF p_create_update_flag = 'C' THEN
        IF p_citizenship_rec.citizenship_id IS NOT NULL AND
           p_citizenship_rec.citizenship_id <> fnd_api.g_miss_num
        THEN
        OPEN citizen_cur (p_citizenship_rec.citizenship_id);
        FETCH citizen_cur INTO l_dummy;

        -- key is not unique, push an error onto the stack.
        IF NVL(citizen_cur%FOUND, FALSE) THEN
          fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
          fnd_message.set_token('COLUMN', 'citizenship_id');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
        CLOSE citizen_cur;

        /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'check that citizenship_id is unique during creation. ' ||
            ' x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'check that citizenship_id is unique during creation. ' ||
            ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

        END IF;
        END IF;

        /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validate citizenship_id ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate citizenship_id ... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;


        -- citizenship_id is non-updateable field
           IF p_create_update_flag = 'U' THEN
              validate_nonupdateable (
                  p_column                                => 'citizenship_id',
                  p_column_value                          => p_citizenship_rec.citizenship_id,
                  p_old_column_value                      => l_citizenship_id,
                  x_return_status                         => x_return_status);

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'citizenship_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'citizenship_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;


           END IF;
  END IF;

        --------------------------
        -- validation for party_id
        --------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- party_id is mandatory field
        IF p_create_update_flag = 'C' THEN
            validate_mandatory (
                p_create_update_flag                    => p_create_update_flag,
                p_column                                => 'party_id',
                p_column_value                          => p_citizenship_rec.party_id,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id is mandatory field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is mandatory field. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;

        -- party_id is non-updateable field
        IF p_create_update_flag = 'U' THEN
            validate_nonupdateable (
                p_column                                => 'party_id',
                p_column_value                          => p_citizenship_rec.party_id,
                p_old_column_value                      => l_party_id,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                  hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;

        -- 2820462, Party_type check has been added to the where clause
        -- party_id has foreign key HZ_PARTIES.PARTY_ID
        IF p_create_update_flag = 'C'
           AND
           p_citizenship_rec.party_id IS NOT NULL
           AND
           p_citizenship_rec.party_id <> fnd_api.g_miss_num
        THEN
            BEGIN
                SELECT 'Y'
                INTO   l_dummy
                FROM   hz_parties p
                WHERE  p.party_type='PERSON' and
                p.party_id = p_citizenship_rec.party_id;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('AR', 'HZ_API_PARTY_NOT_PERSON');
          --          fnd_message.set_token('FK', 'party_id');
                    fnd_message.set_token('TABLE_NAME', 'HZ_CITIZENSHIP');
                    fnd_message.set_token('PARTY_ID_COL', 'party_id');
                    fnd_msg_pub.add;
                    x_return_status := fnd_api.g_ret_sts_error;
            END;

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id has foreign key hz_parties.party_id. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id has foreign key hz_parties.party_id. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;
  END IF;

        ---------------------------------------
        -- validation for birth_or_selected
        ---------------------------------------

        -- birth_or_selected is lookup code in lookup type HZ_CITIZENSHIP_ACQUISITION

        validate_lookup (
            p_column                                => 'birth_or_selected',
            p_lookup_type                           => 'HZ_CITIZENSHIP_ACQUISITION',
            p_column_value                          => p_citizenship_rec.birth_or_selected,
            x_return_status                         => x_return_status);


        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'birth_or_selected should be in lookup HZ_CITIZENSHIP_ACQUISITION. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'birth_or_selected should be in lookup HZ_CITIZENSHIP_ACQUISITION. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;


        ---------------------------------------
        -- validation for country_code
        ---------------------------------------

        -- 2820483, Added the mandatory check
        -- country_code is mandatory field
        IF p_create_update_flag = 'C' THEN
            validate_mandatory (
                p_create_update_flag                    => p_create_update_flag,
                p_column                                => 'country_code',
                p_column_value                          => p_citizenship_rec.country_code,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'country_code is mandatory field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'country_code is mandatory field. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;

        -- country has foreign key fnd_territories.territory_code
        validate_country_code(
            p_column              => 'country_code',
            p_column_value        => p_citizenship_rec.country_code,
            x_return_status       => x_return_status);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
              p_prefix            => l_debug_prefix,
              p_message           => 'country_code should be in fnd_territories.territory_code. ' ||
                                     'x_return_status = ' || x_return_status,
              p_msg_level         => fnd_log.level_statement);
        END IF;

        -- 2820483, Added the following check also
        -- country_code cannot be set to null during update
        IF p_create_update_flag = 'U' THEN
            validate_cannot_update_to_null (
                p_column                                => 'country_code',
                p_column_value                          => p_citizenship_rec.country_code,
                x_return_status                         => x_return_status);
        END IF;


        ------------------------
        -- validation for status
        ------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- status is lookup code in lookup type REGISTRY_STATUS
        IF p_citizenship_rec.status IS NOT NULL
           AND
           p_citizenship_rec.status <> fnd_api.g_miss_char
           AND
           (p_create_update_flag = 'C'
            OR
            (p_create_update_flag = 'U'
             AND
             p_citizenship_rec.status <> NVL(l_status, fnd_api.g_miss_char)
           )
          )
        THEN
            validate_lookup (
                p_column                                => 'status',
                p_lookup_type                           => 'REGISTRY_STATUS',
                p_column_value                          => p_citizenship_rec.status,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;
  END IF;

        -- status cannot be set to null during update
        IF p_create_update_flag = 'U' THEN
            validate_cannot_update_to_null (
                p_column                                => 'status',
                p_column_value                          => p_citizenship_rec.status,
                x_return_status                         => x_return_status);
        END IF;

        --------------------------------------
        -- validate created_by_module
        --------------------------------------

        validate_created_by_module(
          p_create_update_flag     => p_create_update_flag,
          p_created_by_module      => p_citizenship_rec.created_by_module,
          p_old_created_by_module  => l_created_by_module,
          x_return_status          => x_return_status);

        --------------------------------------
        -- validate application_id
        --------------------------------------

        validate_application_id(
          p_create_update_flag     => p_create_update_flag,
          p_application_id         => p_citizenship_rec.application_id,
          p_old_application_id     => l_application_id,
          x_return_status          => x_return_status);

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_citizenship (-)',
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

  END validate_citizenship;


  /**
   * PROCEDURE validate_education
   *
   * DESCRIPTION
   *     Validates education record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_education_rec                Education record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   31-Jan-2001    Porkodi C         o Created.
   *   11-Mar-2003    Porkodi C         o 2820602: Changed the error message, when wrong
   *                                      party_type has been passed to the user.
   *   07-Apr-2003    Porkodi C         o 2888486: On update mutual exclusivity between
   *                                      school_party_id and school_attended_name was not
   *                                      been maintained.
   *   09-Apr-2003    Porkodi C         o 2888399: validation for start_date_attended and last_date_attended
   *                                      has been modified
   *   17-Feb-2004    Rajib Ranjan B    o Bug 3425871.Type_of_school will be validated only
   *                                      if the column value changes.
   */

    PROCEDURE validate_education(
        p_create_update_flag                    IN      VARCHAR2,
        p_education_rec                         IN      HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE,
        p_rowid                                 IN      ROWID ,
        x_return_status                         IN OUT NOCOPY  VARCHAR2
   ) IS

        l_count                                          NUMBER;
        l_education_id                                   NUMBER;
        l_dummy                                          VARCHAR2(1);
        l_party_id                                       NUMBER := p_education_rec.party_id;
        l_created_by_module                              VARCHAR2(30);
        l_application_id                                 NUMBER;
        l_status                                         VARCHAR2(1);
        l_debug_prefix                                   VARCHAR2(30) := '';
        l_start_date_attended                            DATE;
        l_last_date_attended                             DATE;
        l_school_party_id                                NUMBER;
        l_school_attended_name                           VARCHAR2(60);
        -- Code modified for Bug 3473418 starts here
        l_type_of_school                                 VARCHAR2(30);
        -- Code modified for Bug 3473418 ends here
        temp_school_party_id                             NUMBER;
        temp_school_attended_name                        VARCHAR2(60);
        temp_start_date_attended                         DATE;
        temp_last_date_attended                          DATE;

        CURSOR education_cur (p_education_id IN NUMBER) IS
              SELECT 'Y'
              FROM   hz_education hc
        WHERE  hc.education_id = p_education_id;

    BEGIN

        --enable_debug;

        -- Debug info.
        /*IF g_debug THEN
            hz_utility_v2pub.debug ('validate_education (+)');
        END IF;
        */
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_education (+)',
                               p_msg_level=>fnd_log.level_procedure);
        END IF;


        -- do the query to get old values for update
        IF p_create_update_flag = 'U'
        THEN
            SELECT EDUCATION_ID,
                   PARTY_ID,
                   START_DATE_ATTENDED,
                   LAST_DATE_ATTENDED,
                   STATUS,
                   CREATED_BY_MODULE,
                   APPLICATION_ID,
                   SCHOOL_PARTY_ID,
                   SCHOOL_ATTENDED_NAME,
                   TYPE_OF_SCHOOL
            INTO   l_education_id,
                   l_party_id,
                   l_start_date_attended,
                   l_last_date_attended,
                   l_status,
                   l_created_by_module,
                   l_application_id,
                   l_school_party_id,
                   l_school_attended_name,
                   l_type_of_school
            FROM   HZ_EDUCATION
            WHERE  ROWID = p_rowid;
        END IF;


        --------------------------------------
        -- validate education_id
        --------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- If primary key value is passed, check for uniqueness.
        -- If primary key value is not passed, it will be generated
        -- from sequence by table handler.


        IF p_create_update_flag = 'C' THEN
           IF p_education_rec.education_id IS NOT NULL AND
              p_education_rec.education_id <> fnd_api.g_miss_num
           THEN
              OPEN education_cur (p_education_rec.education_id);
              FETCH education_cur INTO l_dummy;

              -- key is not unique, push an error onto the stack.
              IF NVL(education_cur%FOUND, FALSE) THEN
                 fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
                 fnd_message.set_token('COLUMN', 'education_id');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;
              END IF;
              CLOSE education_cur;

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'check that education_id is unique during creation. ' ||
                    ' x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'check that education_id is unique during creation. ' ||
                    ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;

           END IF;
        END IF;


        -- education_id is non-updateable field
        IF p_create_update_flag = 'U' THEN
              validate_nonupdateable (
                  p_column                                => 'education_id',
                  p_column_value                          => p_education_rec.education_id,
                  p_old_column_value                      => l_education_id,
                  x_return_status                         => x_return_status);

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'education_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'education_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;

        END IF;

        /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                '(+) after validate education_id ... ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate education_id ... ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
  END IF;

        --------------------------
        -- validation for party_id
        --------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- party_id is mandatory field
        IF p_create_update_flag = 'C' THEN
            validate_mandatory (
                p_create_update_flag                    => p_create_update_flag,
                p_column                                => 'party_id',
                p_column_value                          => p_education_rec.party_id,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id is mandatory field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is mandatory field. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;

        -- party_id is non-updateable field
        IF p_create_update_flag = 'U' THEN
            validate_nonupdateable (
                p_column                                => 'party_id',
                p_column_value                          => p_education_rec.party_id,
                p_old_column_value                      => l_party_id,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
             END IF;


        END IF;

        -- 2820602, Changed message due to this bug.
        -- party_id has foreign key HZ_PARTIES.PARTY_ID
        IF p_create_update_flag = 'C'
           AND
           p_education_rec.party_id IS NOT NULL
           AND
           p_education_rec.party_id <> fnd_api.g_miss_num
        THEN
            BEGIN
                SELECT 'Y'
                INTO   l_dummy
                FROM   hz_parties p
                WHERE  p.party_id = p_education_rec.party_id and
                       party_type = 'PERSON';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                 fnd_message.set_name('AR', 'HZ_API_PARTY_NOT_PERSON');
                    fnd_message.set_token('TABLE_NAME', 'HZ_EDUCATION');
                    fnd_message.set_token('PARTY_ID_COL', 'party_id');
                    fnd_msg_pub.add;
                    x_return_status := fnd_api.g_ret_sts_error;
            END;

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id has foreign key hz_parties.party_id. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id has foreign key hz_parties.party_id. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;
  END IF;

        ------------------------------------
        -- validation for last_date_attended
        ------------------------------------

        -- If start_date_attended and last_dated_attended are passed,
        -- then last_date_attended must be greater than or equal to
        -- start_date_attended.



        --2888399, For update check added more checks

        IF p_create_update_flag = 'U'    THEN
              IF p_education_rec.start_date_attended IS NOT NULL  then
                 temp_start_date_attended := p_education_rec.start_date_attended;
              ELSE
                 temp_start_date_attended := l_start_date_attended;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_start_date_attended := p_education_rec.start_date_attended;
        END IF;

        IF p_create_update_flag = 'U'    THEN
              IF p_education_rec.last_date_attended IS NOT NULL then
                 temp_last_date_attended := p_education_rec.last_date_attended;
              ELSE
                 temp_last_date_attended := l_last_date_attended;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_last_date_attended := p_education_rec.last_date_attended;
        END IF;

        IF (temp_start_date_attended IS NOT NULL AND
            temp_start_date_attended <> FND_API.G_MISS_DATE AND
            temp_last_date_attended IS NOT NULL AND
            temp_last_date_attended <> FND_API.G_MISS_DATE) THEN

            validate_start_end_date (

              p_create_update_flag                    => p_create_update_flag,
              p_start_date_column_name                => 'start_date_attended',
              p_start_date                            => p_education_rec.start_date_attended,
              p_old_start_date                        => l_start_date_attended,
              p_end_date_column_name                  => 'last_date_attended',
              p_end_date                              => p_education_rec.last_date_attended,
              p_old_end_date                          => l_last_date_attended,
              x_return_status                         => x_return_status
            );

            /*IF g_debug THEN
               hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 'check whether last_date_attended is greater then or equal to start_date_attended. ' ||
                 'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'check whether last_date_attended is greater then or equal to start_date_attended. ' ||
                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;

        END IF;

        /*IF g_debug THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           '(+) after validating the last_date_attended and start_date_attended... ' ||
           'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) after validating the last_date_attended and start_date_attended... ' ||
           'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;



        --------------------------------------
        -- validation for school_attended_name
        --------------------------------------

        -- If school_party_id is passed, school_attended_name
        -- should not be passed.

        --2888486, Added these checks for update
        IF p_create_update_flag = 'U'    THEN
              IF p_education_rec.school_party_id IS NOT NULL then
                 temp_school_party_id := p_education_rec.school_party_id;
              ELSE
                 temp_school_party_id := l_school_party_id;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_school_party_id := p_education_rec.school_party_id;
        END IF;

        IF p_create_update_flag = 'U'    THEN
              IF p_education_rec.school_attended_name IS NOT NULL  then
                 temp_school_attended_name := p_education_rec.school_attended_name;
              ELSE
                 temp_school_attended_name := l_school_attended_name;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_school_attended_name := p_education_rec.school_attended_name;
        END IF;

        IF temp_school_party_id is NOT NULL and
           temp_school_party_id <> fnd_api.g_miss_num and
           temp_school_attended_name is NOT NULL and
           temp_school_attended_name <> fnd_api.g_miss_char then

                 fnd_message.set_name('AR', 'HZ_API_INVALID_COMBINATION2');
                 fnd_message.set_token('COLUMN1', 'school_party_id');
                 fnd_message.set_token('COLUMN2', 'school_attended_name');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;
        END IF;

        /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'check that school_attended_name is empty when school_party_id isn t. '||
                    ' x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'check that school_attended_name is empty when school_party_id isn t. '||
                    ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;


        ---------------------------------
        -- validation for school_party_id
        ---------------------------------


        -- school_party_id must exist in HZ_PARTIES
        IF p_education_rec.school_party_id IS NOT NULL
           AND
           p_education_rec.school_party_id <> fnd_api.g_miss_num
        THEN
           BEGIN
               SELECT 'Y'
               INTO   l_dummy
               FROM   HZ_PARTIES
               WHERE  PARTY_ID = p_education_rec.school_party_id AND
                      PARTY_TYPE= 'ORGANIZATION';

           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('AR', 'HZ_API_PARTY_NOT_ORG');
                    fnd_message.set_token('TABLE_NAME', 'HZ_EDUCATION');
                    fnd_message.set_token('PARTY_ID_COL', 'school_party_id');
                    fnd_msg_pub.add;
                    x_return_status := fnd_api.g_ret_sts_error;
           END;

           /*IF g_debug THEN
               hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'school_party_id should be in hz_parties.party_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
           END IF;
           */
           IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                  hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  p_message=>'school_party_id should be in hz_parties.party_id. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;

        END IF;


        ---------------------------------------
        -- validation for type_of_school
        ---------------------------------------

        -- type_of_school is a lookup code for lookup type HZ_TYPE_OF_SCHOOL

        -- Bug 3425871
        -- The validation will be called only if the value changes.

        IF p_education_rec.type_of_school IS NOT NULL
            AND
           p_education_rec.type_of_school <> fnd_api.g_miss_char
            AND
           (
            p_create_update_flag = 'C'
            OR
              (
               p_create_update_flag = 'U'
               AND
               p_education_rec.type_of_school <> l_type_of_school
              )
           )
        THEN

            validate_lookup (
                p_column                                => 'type_of_school',
                p_lookup_type                           => 'HZ_TYPE_OF_SCHOOL',
                p_column_value                          => p_education_rec.type_of_school,
                x_return_status                         => x_return_status);


            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'type_of_school should be in lookup HZ_TYPE_OF_SCHOOL. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'type_of_school should be in lookup HZ_TYPE_OF_SCHOOL. ' ||
                           'x_return_status = ' || x_return_status,
                                   p_msg_level=>fnd_log.level_statement);
            END IF;
        END IF;


        ------------------------
        -- validation for status
        ------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- status is lookup code in lookup type REGISTRY_STATUS
        IF p_education_rec.status IS NOT NULL
           AND
           p_education_rec.status <> fnd_api.g_miss_char
           AND
           (p_create_update_flag = 'C'
            OR
            (p_create_update_flag = 'U'
             AND
             p_education_rec.status <> NVL(l_status, fnd_api.g_miss_char)
           )
          )
        THEN
            validate_lookup (
                p_column                                => 'status',
                p_lookup_type                           => 'REGISTRY_STATUS',
                p_column_value                          => p_education_rec.status,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                  hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;
  END IF;

        -- status cannot be set to null during update
        IF p_create_update_flag = 'U' THEN
            validate_cannot_update_to_null (
                p_column                                => 'status',
                p_column_value                          => p_education_rec.status,
                x_return_status                         => x_return_status);
        END IF;


        --------------------------------------
        -- validate created_by_module
        --------------------------------------

        validate_created_by_module(
          p_create_update_flag     => p_create_update_flag,
          p_created_by_module      => p_education_rec.created_by_module,
          p_old_created_by_module  => l_created_by_module,
          x_return_status          => x_return_status);

        --------------------------------------
        -- validate application_id
        --------------------------------------

        validate_application_id(
          p_create_update_flag     => p_create_update_flag,
          p_application_id         => p_education_rec.application_id,
          p_old_application_id     => l_application_id,
          x_return_status          => x_return_status);

       IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_education (-)',
                               p_msg_level=>fnd_log.level_procedure);
       END IF;

  END validate_education;


/**
   * PROCEDURE validate_employment_history
   *
   * DESCRIPTION
   *     Validates employment_history record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_employment_history_rec       Employment_history record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   31-Jan-2001    Porkodi C         o Created.
   *   11-Mar-2003    Porkodi C         o 2829037, Changed the code to update values for tenure_code and
   *                                      fraction_of_tenure, while the value for faculty_position_flag is
   *                                      is null.
   *   09-Apr-2003    Porkodi C         o 2890662, validation for begin_date and end_date combination has
   *                                      been modified.
   *   25-Oct-2005   Jayashree K        o 3848056  Validation for weekly hours to hold the value 0
   */

    PROCEDURE validate_employment_history(
        p_create_update_flag                    IN      VARCHAR2,
        p_employment_history_rec                IN      HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE,
        p_rowid                                 IN      ROWID ,
        x_return_status                         IN OUT NOCOPY  VARCHAR2
   ) IS

        l_count                                          NUMBER;
        l_employment_history_id                          NUMBER;
        l_dummy                                          VARCHAR2(1);
        l_party_id                                       NUMBER := p_employment_history_rec.party_id;
        l_created_by_module                              VARCHAR2(150);
        l_application_id                                 NUMBER;
        l_status                                         VARCHAR2(1);
        l_debug_prefix                                   VARCHAR2(30) := '';
        l_begin_date                                     DATE;
        l_end_date                                       DATE;
        l_faculty_position_flag                          VARCHAR2(1);
        l_employed_by_party_id                           NUMBER;
        l_employed_by_name_company                       VARCHAR2(60);
        l_employed_as_title_code                         VARCHAR2(30);
        l_employed_as_title                              VARCHAR2(60);
        temp_faculty_position_flag                       VARCHAR2(1);
        temp_begin_date                                  DATE;
        temp_end_date                                    DATE;
        temp_employed_by_party_id                        NUMBER;
        temp_employed_by_name_company                    VARCHAR2(60);
        temp_employed_as_title_code                      VARCHAR2(30);
        temp_employed_as_title                           VARCHAR2(60);

        CURSOR employment_history_cur (p_employment_history_id IN NUMBER) IS
              SELECT 'Y'
              FROM   hz_employment_history hc
        WHERE  hc.employment_history_id = p_employment_history_id;

    BEGIN

        --enable_debug;

        -- Debug info.
        /*IF g_debug THEN
            hz_utility_v2pub.debug ('validate_employment_history (+)');
        END IF;
        */
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_employment_history (+)',
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- do the query to get old values for update
        IF p_create_update_flag = 'U'
        THEN
            SELECT EMPLOYMENT_HISTORY_ID,
                   PARTY_ID,
                   BEGIN_DATE,
                   END_DATE,
                   FACULTY_POSITION_FLAG,
                   EMPLOYED_BY_PARTY_ID,
                   EMPLOYED_BY_NAME_COMPANY,
                   EMPLOYED_AS_TITLE_CODE,
                   EMPLOYED_AS_TITLE,
                   STATUS,
                   CREATED_BY_MODULE,
                   APPLICATION_ID
            INTO   l_employment_history_id,
                   l_party_id,
                   l_begin_date,
                   l_end_date,
                   l_faculty_position_flag,
                   l_employed_by_party_id,
                   l_employed_by_name_company,
                   l_employed_as_title_code,
                   l_employed_as_title,
                   l_status,
                   l_created_by_module,
                   l_application_id
            FROM   HZ_EMPLOYMENT_HISTORY
            WHERE  ROWID = p_rowid;
        END IF;


        --------------------------------------
        -- validate employment_history_id
        --------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- If primary key value is passed, check for uniqueness.
        -- If primary key value is not passed, it will be generated
        -- from sequence by table handler.


        IF p_create_update_flag = 'C' THEN
           IF p_employment_history_rec.employment_history_id IS NOT NULL AND
              p_employment_history_rec.employment_history_id <> fnd_api.g_miss_num
           THEN
              OPEN employment_history_cur (p_employment_history_rec.employment_history_id);
              FETCH employment_history_cur INTO l_dummy;

              -- key is not unique, push an error onto the stack.
              IF NVL(employment_history_cur%FOUND, FALSE) THEN
                 fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
                 fnd_message.set_token('COLUMN', 'employment_history_id');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;
              END IF;
              CLOSE employment_history_cur;

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'check that employment_history_id is unique during creation. ' ||
                    ' x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'check that employment_history_id is unique during creation. ' ||
                        ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;

           END IF;
        END IF;


        -- employment_history_id is non-updateable field
        IF p_create_update_flag = 'U' THEN
              validate_nonupdateable (
                  p_column                                => 'employment_history_id',
                  p_column_value                          => p_employment_history_rec.employment_history_id,
                  p_old_column_value                      => l_employment_history_id,
                  x_return_status                         => x_return_status);

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'employment_history_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                  hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  p_message=>'employment_history_id is non-updateable field. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
               END IF;

        END IF;

        /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                '(+) after validation of employment_history_id ... ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) after validation of employment_history_id ... ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
  END IF;

        --------------------------
        -- validation for party_id
        --------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- party_id is mandatory field
        IF p_create_update_flag = 'C' THEN
            validate_mandatory (
                p_create_update_flag                    => p_create_update_flag,
                p_column                                => 'party_id',
                p_column_value                          => p_employment_history_rec.party_id,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id is mandatory field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is mandatory field. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
             END IF;


        END IF;

        -- party_id is non-updateable field
        IF p_create_update_flag = 'U' THEN
            validate_nonupdateable (
                p_column                                => 'party_id',
                p_column_value                          => p_employment_history_rec.party_id,
                p_old_column_value                      => l_party_id,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;

        -- party_id has foreign key HZ_PARTIES.PARTY_ID
        IF p_create_update_flag = 'C'
           AND
           p_employment_history_rec.party_id IS NOT NULL
           AND
           p_employment_history_rec.party_id <> fnd_api.g_miss_num
        THEN
            BEGIN
                SELECT 'Y'
                INTO   l_dummy
                FROM   hz_parties p
                WHERE  p.party_id = p_employment_history_rec.party_id and
                       party_type = 'PERSON';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('AR', 'HZ_API_PARTY_NOT_PERSON');
                    fnd_message.set_token('TABLE_NAME', 'HZ_EMPLOYMENT_HISTORY');
                    fnd_message.set_token('PARTY_ID_COL', 'party_id');
                    fnd_msg_pub.add;
                    x_return_status := fnd_api.g_ret_sts_error;
            END;

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id has foreign key hz_parties.party_id. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id has foreign key hz_parties.party_id. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;
  END IF;

        ------------------------------------
        -- validation for end_date
        ------------------------------------

        -- If begin_date and end_date are passed, then end_date must be
        -- greater than or equal to begin_date.



        --2890662, Added more if conditions

        IF p_create_update_flag = 'U'    THEN
              IF p_employment_history_rec.begin_date IS NOT NULL  then
                 temp_begin_date := p_employment_history_rec.begin_date;
              ELSE
                 temp_begin_date := l_begin_date;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_begin_date := p_employment_history_rec.begin_date;
        END IF;

        IF p_create_update_flag = 'U'    THEN
              IF p_employment_history_rec.end_date IS NOT NULL then
                 temp_end_date := p_employment_history_rec.end_date;
              ELSE
                 temp_end_date := l_end_date;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_end_date := p_employment_history_rec.end_date;
        END IF;

        IF (temp_begin_date IS NOT NULL AND
            temp_begin_date <> FND_API.G_MISS_DATE AND
            temp_end_date IS NOT NULL AND
            temp_end_date <> FND_API.G_MISS_DATE) THEN

            validate_start_end_date (

              p_create_update_flag                    => p_create_update_flag,
              p_start_date_column_name                => 'begin_date',
              p_start_date                            => p_employment_history_rec.begin_date,
              p_old_start_date                        => l_begin_date,
              p_end_date_column_name                  => 'end_date',
              p_end_date                              => p_employment_history_rec.end_date,
              p_old_end_date                          => l_end_date,
              x_return_status                         => x_return_status
            );

            /*IF g_debug THEN
               hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 'check whether end_date is greater than or equal to begin_date. ' ||
                 'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'check whether end_date is greater than or equal to begin_date. ' ||
                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;

        END IF;

        /*IF g_debug THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           '(+) after validating the begin_date and end_date... ' ||
           'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) after validating the begin_date and end_date... ' ||
           'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;



        ---------------------------------------
        -- validation for employment_type_code
        ---------------------------------------

        -- employment_type_code is validated against lookup type HZ_EMPLOYMENT_TYPE
        validate_lookup (
            p_column                                => 'employment_type_code',
            p_lookup_type                           => 'HZ_EMPLOYMENT_TYPE',
            p_column_value                          => p_employment_history_rec.employment_type_code,
            x_return_status                         => x_return_status);


        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'employment_type_code should be in lookup HZ_EMPLOYMENT_TYPE. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'employment_type_code should be in lookup HZ_EMPLOYMENT_TYPE. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;



        ----------------------------------------
        -- validation for employed_as_title_code
        ----------------------------------------

        -- employed_as_title_code is validated against lookup type RESPONSIBILITY
        validate_lookup (
            p_column                                => 'employed_as_title_code',
            p_lookup_type                           => 'RESPONSIBILITY',
            p_column_value                          => p_employment_history_rec.employed_as_title_code,
            x_return_status                         => x_return_status);


        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'employed_as_title_code should be in lookup RESPONSIBILITY. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'employed_as_title_code should be in lookup RESPONSIBILITY. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;



        ------------------------------------
        -- validation for employed_as_title
        ------------------------------------

        -- If employed_as_title_code is passed, employed_as_title
        -- should be null.

        IF p_create_update_flag = 'U'    THEN
              IF p_employment_history_rec.employed_as_title_code IS NOT NULL  then
                 temp_employed_as_title_code := p_employment_history_rec.employed_as_title_code;
              ELSE
                 temp_employed_as_title_code := l_employed_as_title_code;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_employed_as_title_code := p_employment_history_rec.employed_as_title_code;
        END IF;


        IF p_create_update_flag = 'U'    THEN
              IF p_employment_history_rec.employed_as_title IS NOT NULL  then
                 temp_employed_as_title := p_employment_history_rec.employed_as_title;
              ELSE
                 temp_employed_as_title := l_employed_as_title;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_employed_as_title := p_employment_history_rec.employed_as_title;
        END IF;


        IF (temp_employed_as_title_code IS NOT NULL and
            temp_employed_as_title_code <> FND_API.G_MISS_CHAR AND
            temp_employed_as_title IS NOT NULL AND
            temp_employed_as_title <> FND_API.G_MISS_CHAR) THEN

                 fnd_message.set_name('AR', 'HZ_API_INVALID_COMBINATION2');
                 fnd_message.set_token('COLUMN1', 'employed_as_title');
                 fnd_message.set_token('COLUMN2', 'employed_as_title_code');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'check that employed_as_title is empty when employed_as_title_code isn t. '||
                    ' x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'check that employed_as_title is empty when employed_as_title_code isn t. '||
                    ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;

        END IF;


        /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validating employed_as_title ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) after validating employed_as_title ... ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;



        --------------------------------------
        -- validation for employed_by_party_id
        --------------------------------------


        -- employed_by_party_id must exist in HZ_PARTIES
        IF p_employment_history_rec.employed_by_party_id IS NOT NULL
           AND
           p_employment_history_rec.employed_by_party_id <> fnd_api.g_miss_num
        THEN
           BEGIN
               SELECT 'Y'
               INTO   l_dummy
               FROM   HZ_PARTIES
               WHERE  PARTY_ID = p_employment_history_rec.employed_by_party_id;

           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                    fnd_message.set_token('FK', 'employed_by_party_id');
                    fnd_message.set_token('COLUMN', 'party_id');
                    fnd_message.set_token('TABLE', 'hz_parties');
                    fnd_msg_pub.add;
                    x_return_status := fnd_api.g_ret_sts_error;
           END;

           /*IF g_debug THEN
               hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'employed_by_party_id should be in hz_parties.party_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
           END IF;
           */
           IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'employed_by_party_id should be in hz_parties.party_id. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

        END IF;


        ------------------------------------------
        -- validation for employed_by_name_company
        ------------------------------------------

        -- If employed_by_party_id is passed, employed_by_name_company
        -- should be null.

        IF p_create_update_flag = 'U'    THEN
              IF p_employment_history_rec.employed_by_party_id IS NOT NULL  then
                 temp_employed_by_party_id := p_employment_history_rec.employed_by_party_id;
              ELSE
                 temp_employed_by_party_id := l_employed_by_party_id;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_employed_by_party_id := p_employment_history_rec.employed_by_party_id;
        END IF;


        IF p_create_update_flag = 'U'    THEN
              IF p_employment_history_rec.employed_by_name_company IS NOT NULL  then
                 temp_employed_by_name_company := p_employment_history_rec.employed_by_name_company;
              ELSE
                 temp_employed_by_name_company := l_employed_by_name_company;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_employed_by_name_company := p_employment_history_rec.employed_by_name_company;
        END IF;


        IF (temp_employed_by_party_id IS NOT NULL and
            temp_employed_by_party_id <> FND_API.G_MISS_NUM AND
            temp_employed_by_name_company IS NOT NULL AND
            temp_employed_by_name_company <> FND_API.G_MISS_CHAR) THEN

                 fnd_message.set_name('AR', 'HZ_API_INVALID_COMBINATION2');
                 fnd_message.set_token('COLUMN1', 'employed_by_name_company');
                 fnd_message.set_token('COLUMN2', 'employed_by_party_id');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'check that employed_by_name_company is empty when employed_by_party_id isn t. ' ||
                    ' x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'check that employed_by_name_company is empty when employed_by_party_id isn t. ' ||
                    ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;

        END IF;


        /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validating employed_by_name_company ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) after validating employed_by_name_company ... ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;



        --------------------------------------
        -- validation for weekly_work_hours
        --------------------------------------
        -- 3848056 Changed the condition for the Weekly Hours to hold the value 0

        -- If weekly_work_hours is passed, must be greater than or equal to  zero
        -- and less than or equal to 168.

        IF p_employment_history_rec.weekly_work_hours IS NOT NULL AND
              p_employment_history_rec.weekly_work_hours <> fnd_api.g_miss_num
           THEN

              IF p_employment_history_rec.weekly_work_hours < 0  OR
                 p_employment_history_rec.weekly_work_hours > 168  THEN

                 fnd_message.set_name('AR', 'HZ_API_VALUE_BETWEEN');
                 fnd_message.set_token('COLUMN', 'weekly_work_hours');
                 --  Bug 4226199 : This should be changed for bug 3848056
                 fnd_message.set_token('VALUE1', '0');
                 fnd_message.set_token('VALUE2', '168');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;
              END IF;

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'check that weekly_work_hours is 1 to 168 value range. ' ||
                    ' x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'check that weekly_work_hours is 1 to 168 value range. ' ||
                         ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
               END IF;

        END IF;


        /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validating weekly_work_hours ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'(+) after validating weekly_work_hours ... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;



        ---------------------------------------
        -- validation for faculty_position_flag
        ---------------------------------------

        -- faculty_position_flag is mandatory field

        validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'faculty_position_flag',
            p_column_value                          => p_employment_history_rec.faculty_position_flag,
            x_return_status                         => x_return_status);

        /*IF g_debug THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'faculty_position_flag is mandatory field. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'faculty_position_flag is mandatory field. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;



        -- faculty_position_flag is validated against lookup type YES/NO
        validate_lookup (
            p_column                                => 'faculty_position_flag',
            p_lookup_type                           => 'YES/NO',
            p_column_value                          => p_employment_history_rec.faculty_position_flag,
            x_return_status                         => x_return_status);


        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'faculty_position_flag should be in lookup YES/NO. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'faculty_position_flag should be in lookup YES/NO. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;



        --------------------------------
        -- validation for tenure_code
        --------------------------------

        -- If tenure_code is passed, faculty_position_flag
        -- should be Y.

        --2829037 added few more checks due to this bug.
        IF p_create_update_flag = 'U'    THEN
              IF p_employment_history_rec.faculty_position_flag IS NOT NULL  then
                 temp_faculty_position_flag := p_employment_history_rec.faculty_position_flag;
              ELSE
                 temp_faculty_position_flag := l_faculty_position_flag;
              END IF;
        ELSIF p_create_update_flag = 'C' THEN
              temp_faculty_position_flag := p_employment_history_rec.faculty_position_flag;
        END IF;

        IF p_employment_history_rec.tenure_code IS NOT NULL AND
           p_employment_history_rec.tenure_code <> fnd_api.g_miss_char then

           IF temp_faculty_position_flag = 'Y' THEN

                 validate_lookup (
                     p_column                                => 'tenure_code',
                     p_lookup_type                           => 'HZ_TENURE_CODE',
                     p_column_value                          => p_employment_history_rec.tenure_code,
                     x_return_status                         => x_return_status);


              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'tenure_code should be in lookup HZ_TENURE_CODE. ' ||
                    ' x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'tenure_code should be in lookup HZ_TENURE_CODE. ' ||
                         ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;

           ELSE
                 fnd_message.set_name('AR', 'HZ_API_VAL_DEP_FIELDS');
                 fnd_message.set_token('COLUMN1', 'faculty_position_flag');
                 fnd_message.set_token('COLUMN2', 'tenure_code');
                 fnd_message.set_token('VALUE1', 'N');
                 fnd_message.set_token('VALUE2', 'null');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;

            END IF;

        /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validating tenure_code ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validating tenure_code ... ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;

        END IF;

        ------------------------------------
        -- validation for fraction_of_tenure
        ------------------------------------

        -- If fraction_of_tenure is passed, faculty_position_flag
        -- should be Y.

        IF p_employment_history_rec.fraction_of_tenure IS NOT NULL AND
                 p_employment_history_rec.fraction_of_tenure <> fnd_api.g_miss_num  then
                   IF temp_faculty_position_flag = 'Y' then
                 IF p_employment_history_rec.fraction_of_tenure < 0  OR
                    p_employment_history_rec.fraction_of_tenure > 100  THEN

                    fnd_message.set_name('AR', 'HZ_API_VALUE_BETWEEN');
                    fnd_message.set_token('COLUMN', 'fraction_of_tenure');
                    fnd_message.set_token('VALUE1', '0');
                    fnd_message.set_token('VALUE2', '100');
                    fnd_msg_pub.add;
                    x_return_status := fnd_api.g_ret_sts_error;
                 END IF;

                 /*IF g_debug THEN
                    hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                       'check that fraction_of_tenure is 0 to 100 value range. ' ||
                      ' x_return_status = ' || x_return_status, l_debug_prefix);
                 END IF;
                 */
                 IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                         hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                         p_message=>'check that fraction_of_tenure is 0 to 100 value range. ' ||
                                ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
                 END IF;

         ELSE
                 fnd_message.set_name('AR', 'HZ_API_VAL_DEP_FIELDS');
                 fnd_message.set_token('COLUMN1', 'faculty_position_flag');
                 fnd_message.set_token('COLUMN2', 'fraction_of_tenure');
                 fnd_message.set_token('VALUE1', 'N');
                 fnd_message.set_token('VALUE2', 'null');

                 fnd_message.set_token('COLUMN', 'fraction_of_tenure');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;
              END IF;

        END IF;

        /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        '(+) after validating fraction_of_tenure ... ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validating fraction_of_tenure ... ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;



        ------------------------
        -- validation for status
        ------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- status is lookup code in lookup type REGISTRY_STATUS
        IF p_employment_history_rec.status IS NOT NULL
           AND
           p_employment_history_rec.status <> fnd_api.g_miss_char
           AND
           (p_create_update_flag = 'C'
            OR
            (p_create_update_flag = 'U'
             AND
             p_employment_history_rec.status <> NVL(l_status, fnd_api.g_miss_char)
           )
          )
        THEN
            validate_lookup (
                p_column                                => 'status',
                p_lookup_type                           => 'REGISTRY_STATUS',
                p_column_value                          => p_employment_history_rec.status,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
             END IF;


        END IF;
  END IF;

        -- status cannot be set to null during update
        IF p_create_update_flag = 'U' THEN
            validate_cannot_update_to_null (
                p_column                                => 'status',
                p_column_value                          => p_employment_history_rec.status,
                x_return_status                         => x_return_status);
        END IF;


        --------------------------------------
        -- validate created_by_module
        --------------------------------------

        validate_created_by_module(
          p_create_update_flag     => p_create_update_flag,
          p_created_by_module      => p_employment_history_rec.created_by_module,
          p_old_created_by_module  => l_created_by_module,
          x_return_status          => x_return_status);

        --------------------------------------
        -- validate application_id
        --------------------------------------

        validate_application_id(
          p_create_update_flag     => p_create_update_flag,
          p_application_id         => p_employment_history_rec.application_id,
          p_old_application_id     => l_application_id,
          x_return_status          => x_return_status);

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_employment_history (-)',
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

  END validate_employment_history;


/**
   * PROCEDURE validate_work_class
   *
   * DESCRIPTION
   *     Validates work_class record. Checks for
   *         uniqueness
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_work_class_rec               Work_class record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   02-Feb-2003    Porkodi C         o Created.
   *   10-Mar-2003    Porkodi C           Bug 2829041, Corrected the validation for employment_history_id
   *                                      to be a foreign key from hz_employment_history.
   *
   */

    PROCEDURE validate_work_class(
        p_create_update_flag                    IN      VARCHAR2,
        p_work_class_rec                        IN      HZ_PERSON_INFO_V2PUB.WORK_CLASS_REC_TYPE,
        p_rowid                                 IN      ROWID ,
        x_return_status                         IN OUT NOCOPY  VARCHAR2
   ) IS

        l_count                                          NUMBER;
        l_work_class_id                                  NUMBER;
        l_dummy                                          VARCHAR2(1);
        l_employment_history_id                          NUMBER := p_work_class_rec.employment_history_id;
        l_created_by_module                              VARCHAR2(150);
        l_application_id                                 NUMBER;
        l_status                                         VARCHAR2(1);
        l_debug_prefix                                   VARCHAR2(30) := '';

        CURSOR work_class_cur (p_work_class_id IN NUMBER) IS
              SELECT 'Y'
              FROM   hz_work_class hc
        WHERE  hc.work_class_id = p_work_class_id;

    BEGIN

        --enable_debug;

        -- Debug info.
        /*IF g_debug THEN
            hz_utility_v2pub.debug ('validate_work_class (+)');
        END IF;
        */
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_work_class (+)',
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- do the query to get old values for update
        IF p_create_update_flag = 'U'
        THEN
            SELECT WORK_CLASS_ID,
                   EMPLOYMENT_HISTORY_ID,
                   STATUS,
                   CREATED_BY_MODULE,
                   APPLICATION_ID
            INTO   L_work_class_id,
                   l_employment_history_id,
                   l_status,
                   l_created_by_module,
                   l_application_id
            FROM   HZ_work_class
            WHERE  ROWID = p_rowid;
        END IF;


        --------------------------------------
        -- validate work_class_id
        --------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- If primary key value is passed, check for uniqueness.
        -- If primary key value is not passed, it will be generated
        -- from sequence by table handler.


        IF p_create_update_flag = 'C' THEN
           IF p_work_class_rec.work_class_id IS NOT NULL AND
              p_work_class_rec.work_class_id <> fnd_api.g_miss_num
           THEN
              OPEN work_class_cur (p_work_class_rec.work_class_id);
              FETCH work_class_cur INTO l_dummy;

              -- key is not unique, push an error onto the stack.
              IF NVL(work_class_cur%FOUND, FALSE) THEN
                 fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
                 fnd_message.set_token('COLUMN', 'work_class_id');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;
              END IF;
              CLOSE work_class_cur;

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'check that work_class_id is unique during creation. ' ||
                    ' x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'check that work_class_id is unique during creation. ' ||
                                                   ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;

           END IF;
        END IF;


        -- work_class_id is non-updateable field
        IF p_create_update_flag = 'U' THEN
              validate_nonupdateable (
                  p_column                                => 'work_class_id',
                  p_column_value                          => p_work_class_rec.work_class_id,
                  p_old_column_value                      => l_work_class_id,
                  x_return_status                         => x_return_status);

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'work_class_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'work_class_id is non-updateable field. ' ||
                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;

        END IF;

        /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                '(+) after validation of work_class_id ... ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validation of work_class_id ... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
  END IF;

        ---------------------------------------
        -- validation for employment_history_id
        ---------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- employment_history_id is mandatory field
        IF p_create_update_flag = 'C' THEN
            validate_mandatory (
                p_create_update_flag                    => p_create_update_flag,
                p_column                                => 'employment_history_id',
                p_column_value                          => p_work_class_rec.employment_history_id,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'employment_history_id is mandatory field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'employment_history_id is mandatory field. ' ||
                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;

        -- employment_history_id is non-updateable field
        IF p_create_update_flag = 'U' THEN
            validate_nonupdateable (
                p_column                                => 'employment_history_id',
                p_column_value                          => p_work_class_rec.employment_history_id,
                p_old_column_value                      => l_employment_history_id,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'employment_history_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'employment_history_id is non-updateable field. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;

        -- employment_history_id has foreign key HZ_EMPLOYMENT_HISTORY.EMPLOYMENT_HISTORY_ID
        IF p_create_update_flag = 'C'
           AND
           p_work_class_rec.employment_history_id IS NOT NULL
           AND
           p_work_class_rec.employment_history_id <> fnd_api.g_miss_num
        THEN
            BEGIN
                SELECT 'Y'
                INTO   l_dummy
                FROM   hz_employment_history p
                WHERE  p.employment_history_id = p_work_class_rec.employment_history_id;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                    fnd_message.set_token('FK', 'employment_history_id');
                    fnd_message.set_token('COLUMN', 'employment_history_id');
                    fnd_message.set_token('TABLE', 'hz_employment_history');
                    fnd_msg_pub.add;
                    x_return_status := fnd_api.g_ret_sts_error;
            END;

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'employment_history_id has foreign key hz_employment_history.employment_history_id. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'employment_history_id has foreign key hz_employment_history.employment_history_id. ' ||
                    'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;
  END IF;

        ---------------------------------
        -- validation for work_class_name
        ---------------------------------

        -- work_class_name is mandatory field

        validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'work_class_name',
            p_column_value                          => p_work_class_rec.work_class_name,
            x_return_status                         => x_return_status);

        /*IF g_debug THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'work_class_name is mandatory field. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'work_class_name is mandatory field. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;


        ------------------------
        -- validation for status
        ------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- status is lookup code in lookup type REGISTRY_STATUS
        IF p_work_class_rec.status IS NOT NULL
           AND
           p_work_class_rec.status <> fnd_api.g_miss_char
           AND
           (p_create_update_flag = 'C'
            OR
            (p_create_update_flag = 'U'
             AND
             p_work_class_rec.status <> NVL(l_status, fnd_api.g_miss_char)
           )
          )
        THEN
            validate_lookup (
                p_column                                => 'status',
                p_lookup_type                           => 'REGISTRY_STATUS',
                p_column_value                          => p_work_class_rec.status,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;
  END IF;

        -- status cannot be set to null during update
        IF p_create_update_flag = 'U' THEN
            validate_cannot_update_to_null (
                p_column                                => 'status',
                p_column_value                          => p_work_class_rec.status,
                x_return_status                         => x_return_status);
        END IF;


        --------------------------------------
        -- validate created_by_module
        --------------------------------------

        validate_created_by_module(
          p_create_update_flag     => p_create_update_flag,
          p_created_by_module      => p_work_class_rec.created_by_module,
          p_old_created_by_module  => l_created_by_module,
          x_return_status          => x_return_status);

        --------------------------------------
        -- validate application_id
        --------------------------------------

        validate_application_id(
          p_create_update_flag     => p_create_update_flag,
          p_application_id         => p_work_class_rec.application_id,
          p_old_application_id     => l_application_id,
          x_return_status          => x_return_status);

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_work_class (-)',
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

  END validate_work_class;

/**
   * PROCEDURE validate_person_interest
   *
   * DESCRIPTION
   *     Validates person_interest record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_person_interest_rec       person_interest record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   31-Jan-2001    Porkodi C           o Created.
   *   13-Jan-2004    Rajib Ranjan Borah  o Bug 3282946.Person interest can be created for
   *                                        all type of parties and not necessarily for
   *                                        'PERSON' type parties only.
   */

    PROCEDURE validate_person_interest(
        p_create_update_flag                    IN      VARCHAR2,
        p_person_interest_rec                   IN      HZ_PERSON_INFO_V2PUB.person_interest_REC_TYPE,
        p_rowid                                 IN      ROWID ,
        x_return_status                         IN OUT NOCOPY  VARCHAR2
   ) IS

        l_count                                          NUMBER;
        l_person_interest_id                          NUMBER;
        l_dummy                                          VARCHAR2(1);
        l_party_id                                       NUMBER := p_person_interest_rec.party_id;
        l_created_by_module                              VARCHAR2(150);
        l_application_id                                 NUMBER;
        l_status                                         VARCHAR2(1);
        l_debug_prefix                                   VARCHAR2(30) := '';
        l_begin_date                                     DATE;
        l_end_date                                       DATE;

        CURSOR person_interest_cur (p_person_interest_id IN NUMBER) IS
              SELECT 'Y'
              FROM   hz_person_interest hc
        WHERE  hc.person_interest_id = p_person_interest_id;

    BEGIN

        --enable_debug;

        -- Debug info.
        /*IF g_debug THEN
            hz_utility_v2pub.debug ('validate_person_interest (+)');
        END IF;
        */
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_person_interest (+)',
                               p_msg_level=>fnd_log.level_procedure);
        END IF;


        -- do the query to get old values for update
        IF p_create_update_flag = 'U'
        THEN
            SELECT person_interest_ID,
                   PARTY_ID,
                   STATUS,
                   CREATED_BY_MODULE,
                   APPLICATION_ID
            INTO   l_person_interest_id,
                   l_party_id,
                   l_status,
                   l_created_by_module,
                   l_application_id
            FROM   HZ_person_interest
            WHERE  ROWID = p_rowid;
        END IF;


        --------------------------------------
        -- validate person_interest_id
        --------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- If primary key value is passed, check for uniqueness.
        -- If primary key value is not passed, it will be generated
        -- from sequence by table handler.


        IF p_create_update_flag = 'C' THEN
           IF p_person_interest_rec.person_interest_id IS NOT NULL AND
              p_person_interest_rec.person_interest_id <> fnd_api.g_miss_num
           THEN
              OPEN person_interest_cur (p_person_interest_rec.person_interest_id);
              FETCH person_interest_cur INTO l_dummy;

              -- key is not unique, push an error onto the stack.
              IF NVL(person_interest_cur%FOUND, FALSE) THEN
                 fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
                 fnd_message.set_token('COLUMN', 'person_interest_id');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;
              END IF;
              CLOSE person_interest_cur;

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'check that person_interest_id is unique during creation. ' ||
                    ' x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'check that person_interest_id is unique during creation. ' ||
                    ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;

           END IF;
        END IF;


        -- person_interest_id is non-updateable field
        IF p_create_update_flag = 'U' THEN
              validate_nonupdateable (
                  p_column                                => 'person_interest_id',
                  p_column_value                          => p_person_interest_rec.person_interest_id,
                  p_old_column_value                      => l_person_interest_id,
                  x_return_status                         => x_return_status);

              /*IF g_debug THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'person_interest_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
              END IF;
              */
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'person_interest_id is non-updateable field. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;

        END IF;

        /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                '(+) after validation of person_interest_id ... ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validation of person_interest_id ... ' ||
                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
  END IF;

        --------------------------
        -- validation for party_id
        --------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- party_id is mandatory field
        IF p_create_update_flag = 'C' THEN
            validate_mandatory (
                p_create_update_flag                    => p_create_update_flag,
                p_column                                => 'party_id',
                p_column_value                          => p_person_interest_rec.party_id,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id is mandatory field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                   hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is mandatory field. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;

        -- party_id is non-updateable field
        IF p_create_update_flag = 'U' THEN
            validate_nonupdateable (
                p_column                                => 'party_id',
                p_column_value                          => p_person_interest_rec.party_id,
                p_old_column_value                      => l_party_id,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id is non-updateable field. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is non-updateable field. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;

        -- party_id has foreign key HZ_PARTIES.PARTY_ID
        IF p_create_update_flag = 'C'
           AND
           p_person_interest_rec.party_id IS NOT NULL
           AND
           p_person_interest_rec.party_id <> fnd_api.g_miss_num
        THEN
            BEGIN
                SELECT 'Y'
                INTO   l_dummy
                FROM   hz_parties p
                WHERE  p.party_id = p_person_interest_rec.party_id; /*and
                       party_type = 'PERSON';*/
                       /*
                       Bug 3282946. Some teams still insert into hz_person_interest
                       for non 'PERSON' type parties.
                       */

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                    fnd_message.set_token('FK', 'party_id');
                    fnd_message.set_token('COLUMN', 'party_id');
                    fnd_message.set_token('TABLE', 'hz_parties');
                    fnd_msg_pub.add;
                    x_return_status := fnd_api.g_ret_sts_error;
            END;

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'party_id has foreign key hz_parties.party_id. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id has foreign key hz_parties.party_id. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;
  END IF;

        ---------------------------------
        -- validation for sport_indicator
        ---------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- sport_indicator is mandatory field


        -- sport_indicator is validated against lookup type YES/NO
        validate_lookup (
            p_column                                => 'sport_indicator',
            p_lookup_type                           => 'YES/NO',
            p_column_value                          => p_person_interest_rec.sport_indicator,
            x_return_status                         => x_return_status);


        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'sport_indicator should be in lookup YES/NO. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'sport_indicator should be in lookup YES/NO. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
  END IF;

        ---------------------------------
        -- validation for interest_name
        ---------------------------------

        -- interest_name is mandatory field

        validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'interest_name',
            p_column_value                          => p_person_interest_rec.interest_name,
            x_return_status                         => x_return_status);

        /*IF g_debug THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'interest_name is mandatory field. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'interest_name is mandatory field. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;


        ------------------------
        -- validation for status
        ------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
        -- status is lookup code in lookup type REGISTRY_STATUS
        IF p_person_interest_rec.status IS NOT NULL
           AND
           p_person_interest_rec.status <> fnd_api.g_miss_char
           AND
           (p_create_update_flag = 'C'
            OR
            (p_create_update_flag = 'U'
             AND
             p_person_interest_rec.status <> NVL(l_status, fnd_api.g_miss_char)
           )
          )
        THEN
            validate_lookup (
                p_column                                => 'status',
                p_lookup_type                           => 'REGISTRY_STATUS',
                p_column_value                          => p_person_interest_rec.status,
                x_return_status                         => x_return_status);

            /*IF g_debug THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                    'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                    'x_return_status = ' || x_return_status, l_debug_prefix);
            END IF;
            */
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


        END IF;
  END IF;

        -- status cannot be set to null during update
        IF p_create_update_flag = 'U' THEN
            validate_cannot_update_to_null (
                p_column                                => 'status',
                p_column_value                          => p_person_interest_rec.status,
                x_return_status                         => x_return_status);
        END IF;


        --------------------------------------
        -- validate created_by_module
        --------------------------------------

        validate_created_by_module(
          p_create_update_flag     => p_create_update_flag,
          p_created_by_module      => p_person_interest_rec.created_by_module,
          p_old_created_by_module  => l_created_by_module,
          x_return_status          => x_return_status);

        --------------------------------------
        -- validate application_id
        --------------------------------------

        validate_application_id(
          p_create_update_flag     => p_create_update_flag,
          p_application_id         => p_person_interest_rec.application_id,
          p_old_application_id     => l_application_id,
          x_return_status          => x_return_status);

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_person_interest (-)',
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

  END validate_person_interest;


  /**
   * PROCEDURE validate_location
   *
   * DESCRIPTION
   *     Validates location record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_location_rec                 Location record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *   06-FEB-2004   Jianying Huang     o Bug 3330754: modified validate_location to
   *                                      change validation for third party records
   *                                      from row level non-updateable checking to
   *                                      attribute level checking.
   *   01-03-2005    Rajib Ranjan Borah o SSM SST Integration and Extension.
   *                                      Newly created user update rules will be used
   *                                      to check update privilege.
   *
   */

  PROCEDURE validate_location(
      p_create_update_flag                    IN      VARCHAR2,
      p_location_rec                          IN      hz_location_v2pub.location_rec_type,
      p_rowid                                 IN      ROWID ,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

      l_dummy                                 VARCHAR2(1);
      l_address_effective_date                DATE;
      l_content_source_type                   HZ_LOCATIONS.CONTENT_SOURCE_TYPE%TYPE;
      l_created_by_module                     VARCHAR2(150);
      l_application_id                        NUMBER;
      l_debug_prefix                          VARCHAR2(30) := '';

      -- Bug 2197181: added for mix-n-match
      db_actual_content_source                HZ_LOCATIONS.ACTUAL_CONTENT_SOURCE%TYPE;

      -- Bug 3330754: added to support attribute level non-updateable checking for third
      -- party records.
      db_orig_system_reference                HZ_LOCATIONS.ORIG_SYSTEM_REFERENCE%TYPE;
      db_country                              HZ_LOCATIONS.COUNTRY%TYPE;
      db_address1                             HZ_LOCATIONS.ADDRESS1%TYPE;
      db_address2                             HZ_LOCATIONS.ADDRESS2%TYPE;
      db_address3                             HZ_LOCATIONS.ADDRESS3%TYPE;
      db_address4                             HZ_LOCATIONS.ADDRESS4%TYPE;
      db_city                                 HZ_LOCATIONS.CITY%TYPE;
      db_postal_code                          HZ_LOCATIONS.POSTAL_CODE%TYPE;
      db_state                                HZ_LOCATIONS.STATE%TYPE;
      db_province                             HZ_LOCATIONS.PROVINCE%TYPE;
      db_county                               HZ_LOCATIONS.COUNTY%TYPE;
      db_postal_plus4_code                    HZ_LOCATIONS.POSTAL_PLUS4_CODE%TYPE;
      db_clli_code                            HZ_LOCATIONS.CLLI_CODE%TYPE;
      db_delivery_point_code                  HZ_LOCATIONS.DELIVERY_POINT_CODE%TYPE;
      db_location_directions                  HZ_LOCATIONS.LOCATION_DIRECTIONS%TYPE;
      l_return_status                         VARCHAR2(1);

      l_vertex_taxware_installed              BOOLEAN;

  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_location (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_location (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


      -- select columns needed to be checked from table during update

      -- Bug 2197181: selecting actual_content_source for mix-n-match
      -- Bug 3330754: added to support attribute level non-updateable checking for third
      -- party records.

      IF (p_create_update_flag = 'U') THEN
          SELECT ADDRESS_EFFECTIVE_DATE,
                 CONTENT_SOURCE_TYPE,
                 created_by_module,
                 APPLICATION_ID,
                 actual_content_source,
                 -- Bug 3330754: added to support attribute level
                 -- non-updateable checking for third party records.
                 orig_system_reference,
                 country,
                 address1,
                 address2,
                 address3,
                 address4,
                 city,
                 postal_code,
                 state,
                 province,
                 county,
                 postal_plus4_code,
                 clli_code,
                 delivery_point_code,
                 location_directions
          INTO   l_address_effective_date,
                 l_content_source_type,
                 l_created_by_module,
                 l_application_id,
                 db_actual_content_source,
                 -- Bug 3330754: added to support attribute level
                 -- non-updateable checking for third party records.
                 db_orig_system_reference,
                 db_country,
                 db_address1,
                 db_address2,
                 db_address3,
                 db_address4,
                 db_city,
                 db_postal_code,
                 db_state,
                 db_province,
                 db_county,
                 db_postal_plus4_code,
                 db_clli_code,
                 db_delivery_point_code,
                 db_location_directions
          FROM   HZ_LOCATIONS
          WHERE  ROWID = p_rowid;
      END IF;

      --------------------
      -- validate address1
      --------------------

      -- address1 is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'address1',
          p_column_value                          => p_location_rec.address1,
          x_return_status                         => x_return_status);

      --------------------
      -- validate country
      --------------------

      -- country is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'country',
          p_column_value                          => p_location_rec.country,
          x_return_status                         => x_return_status);

      -- country has foreign key fnd_territories.territory_code
      validate_country_code(
          p_column                                => 'country',
          p_column_value                          => p_location_rec.country,
          x_return_status                         => x_return_status);

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
             p_prefix               => l_debug_prefix,
             p_message              => 'country has foreign key fnd_territories.territory_code. ' ||
                                       'x_return_status = ' || x_return_status,
             p_msg_level            => fnd_log.level_statement);
      END IF;

      /* Bug 2197181: removed content_source_type validation as this
         column has been obsoleted for mix-n-match project.

      -------------------------------
      -- validate content_source_type
      -------------------------------

      -- we do not need to check 'content_source_type is mandatory' because
      -- we default content_source_type to hz_party_v2pub.g_miss_content_source_type
      -- in table handler.

      -- content_source_type is non-updateable
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'content_source_type',
              p_column_value                          => p_location_rec.content_source_type,
              p_old_column_value                      => l_content_source_type,
              x_return_status                         => x_return_status);


          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'content_source_type is non-updateable. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;
      END IF;

      -- content_source_type is lookup code in lookup type CONTENT_SOURCE_TYPE
      validate_lookup (
          p_column                                => 'content_source_type',
          p_lookup_type                           => 'CONTENT_SOURCE_TYPE',
          p_column_value                          => p_location_rec.content_source_type,
          x_return_status                         => x_return_status);

      IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'content_source_type is lookup code in lookup type CONTENT_SOURCE_TYPE. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */

      -- Bug 2197181: Added validation for mix-n-match

      ----------------------------------------
      -- validate content_source_type and actual_content_source_type
      ----------------------------------------

      HZ_MIXNM_UTILITY.ValidateContentSource (
        p_api_version                       => 'V2',
        p_create_update_flag                => p_create_update_flag,
        -- Bug 3330754: replaced row level non-updateable checking to
        -- attribute level checking.
        p_check_update_privilege            => 'N',
        p_content_source_type               => p_location_rec.content_source_type,
        p_old_content_source_type           => l_content_source_type,
        p_actual_content_source             => p_location_rec.actual_content_source,
        p_old_actual_content_source         => db_actual_content_source,
        p_entity_name                       => 'HZ_LOCATIONS',
        x_return_status                     => x_return_status );

      -- Bug 3330754: added to support attribute level non-updateable checking for third
      -- party records.

      --------------------------------------
      -- validate address components which are third-party sourced.
      --------------------------------------

      -- address components can not be updated by the end-user if
      -- actual_content_source <> 'USER_ENTERED'

      IF p_create_update_flag = 'U' AND
         db_actual_content_source <> 'USER_ENTERED' -- AND
         -- SSM SST Integration and Extension
         -- Check Updateability using mix-n-match procedure rather than checking the
         -- profile value.
         /*NVL(FND_PROFILE.value('HZ_UPDATE_THIRD_PARTY_DATA'), 'N') = 'N'*/
         --HZ_UTILITY_V2PUB.is_purchased_content_source(db_actual_content_source) = 'Y'
      THEN
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        validate_nonupdateable (
          p_column                 => 'orig_system_reference',
          p_column_value           => p_location_rec.orig_system_reference,
          p_old_column_value       => db_orig_system_reference,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'country',
          p_column_value           => p_location_rec.country,
          p_old_column_value       => db_country,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'address1',
          p_column_value           => p_location_rec.address1,
          p_old_column_value       => db_address1,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'address2',
          p_column_value           => p_location_rec.address2,
          p_old_column_value       => db_address2,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'address3',
          p_column_value           => p_location_rec.address3,
          p_old_column_value       => db_address3,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'address4',
          p_column_value           => p_location_rec.address4,
          p_old_column_value       => db_address4,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'city',
          p_column_value           => p_location_rec.city,
          p_old_column_value       => db_city,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'postal_code',
          p_column_value           => p_location_rec.postal_code,
          p_old_column_value       => db_postal_code,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'state',
          p_column_value           => p_location_rec.state,
          p_old_column_value       => db_state,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'province',
          p_column_value           => p_location_rec.province,
          p_old_column_value       => db_province,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'county',
          p_column_value           => p_location_rec.county,
          p_old_column_value       => db_county,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'postal_plus4_code',
          p_column_value           => p_location_rec.postal_plus4_code,
          p_old_column_value       => db_postal_plus4_code,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'clli_code',
          p_column_value           => p_location_rec.clli_code,
          p_old_column_value       => db_clli_code,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'delivery_point_code',
          p_column_value           => p_location_rec.delivery_point_code,
          p_old_column_value       => db_delivery_point_code,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        validate_nonupdateable (
          p_column                 => 'location_directions',
          p_column_value           => p_location_rec.location_directions,
          p_old_column_value       => db_location_directions,
          x_return_status          => l_return_status,
          p_raise_error            => 'N');

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            HZ_MIXNM_UTILITY.CheckUserUpdatePrivilege(
                p_actual_content_source       => db_actual_content_source,
                p_new_actual_content_source   => p_location_rec.actual_content_source,
                p_entity_name                 => 'HZ_LOCATIONS',
                x_return_status               => x_return_status);
-- Bug 4693719 : set global variable to Y
         HZ_UTILITY_V2PUB.G_UPDATE_ACS := 'Y';
        /*
          FND_MESSAGE.SET_NAME('AR', 'HZ_NOTALLOW_UPDATE_THIRD_PARTY');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        */
        END IF;

        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix=>l_debug_prefix,
            p_message=>'third party address components are non-updateable. ' ||
                       'x_return_status = ' || x_return_status,
            p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_prefix=>l_debug_prefix,
          p_message=>'(+) after validate third party address components ... ' ||
                     'x_return_status = ' || x_return_status,
          p_msg_level=>fnd_log.level_statement);
      END IF;

      --------------------------
      -- validation for language
      --------------------------
      -- language has foreign key fnd_languages.language_code
      IF p_location_rec.language IS NOT NULL
         AND
         p_location_rec.language <> fnd_api.g_miss_char
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   FND_LANGUAGES
              WHERE  LANGUAGE_CODE = p_location_rec.language
              AND    INSTALLED_FLAG IN ('B', 'I');
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'language');
                  fnd_message.set_token('COLUMN', 'language_code');
                  fnd_message.set_token('TABLE', 'fnd_languages(installed)');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'language has foreign key fnd_languages.language_code (installed). ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            p_message=>'language has foreign key fnd_languages.language_code (installed). ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;
      END IF;

      -----------------------------
      -- validation for timezone_id
      -----------------------------
      -- timezone_id has foreign key hz_timezones.timezone_id
      IF p_location_rec.timezone_id IS NOT NULL
         AND
         p_location_rec.timezone_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_TIMEZONES
              WHERE  TIMEZONE_ID = p_location_rec.timezone_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'timezone_id');
                  fnd_message.set_token('COLUMN', 'timezone_id');
                  fnd_message.set_token('TABLE', 'hz_timezones');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'timezone_id has foreign key hz_timezones.timezone_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'timezone_id has foreign key hz_timezones.timezone_id. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_location_rec.created_by_module,
        p_old_created_by_module  => l_created_by_module,
        x_return_status          => x_return_status);

      --------------------------------------
      -- validate application_id
      --------------------------------------

      validate_application_id(
        p_create_update_flag     => p_create_update_flag,
        p_application_id         => p_location_rec.application_id,
        p_old_application_id     => l_application_id,
        x_return_status          => x_return_status);

      --------------------------------------------------------------
      -- validate sales_tax_geocode and sales_tax_inside_city_limits
      --------------------------------------------------------------
      -- Added the below validations as a part of bug fix # 4967075

      l_vertex_taxware_installed := zx_r11i_tax_partner_pkg.TAX_VENDOR_EXTENSION;

      IF p_location_rec.sales_tax_geocode IS NOT NULL AND p_location_rec.sales_tax_geocode <> fnd_api.g_miss_char THEN
         If (zx_r11i_tax_partner_pkg.IS_GEOCODE_VALID(p_location_rec.sales_tax_geocode) = FALSE) then
            x_return_status := fnd_api.g_ret_sts_error;
         end if;
      END IF;

      IF p_location_rec.sales_tax_inside_city_limits IS NOT NULL AND p_location_rec.sales_tax_inside_city_limits <> fnd_api.g_miss_char THEN
         If (zx_r11i_tax_partner_pkg.IS_CITY_LIMIT_VALID(p_location_rec.sales_tax_inside_city_limits) = FALSE) then
            x_return_status := fnd_api.g_ret_sts_error;
         end if;
      END IF;

      --------------------------
      -- tax location validation
      --------------------------

      -- do tax location validation when location is inserted from public API.
      -- restrict updates on taxable components when location is used by any
      -- non prospect customers.
      -- tax code will be created when customer account site is created for
      -- this location.

      tax_location_validation(p_location_rec,
                               p_create_update_flag,
                               x_return_status);

      IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_location (-)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_location (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      --disable_debug;

  END validate_location;

  /**
   * PROCEDURE tax_location_validation
   *
   * DESCRIPTION
   *     Validates tax location.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_location_rec                 Location record.
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *
   */

  PROCEDURE tax_location_validation(
      p_location_rec       IN      hz_location_v2pub.location_rec_type,
      p_create_update_flag IN      VARCHAR2,
      x_return_status      IN OUT NOCOPY  VARCHAR2
 ) IS
      l_location_id                NUMBER;
      l_loc_id                     NUMBER;
      l_org_id                     NUMBER;
      l_city                       VARCHAR2(60);
      l_state                      VARCHAR2(60);
      l_country                    VARCHAR2(60);
      l_county                     VARCHAR2(60);
      l_province                   VARCHAR2(60);
      l_postal_code                VARCHAR2(60);
      l_attribute1                 VARCHAR2(150);
      l_attribute2                 VARCHAR2(150);
      l_attribute3                 VARCHAR2(150);
      l_attribute4                 VARCHAR2(150);
      l_attribute5                 VARCHAR2(150);
      l_attribute6                 VARCHAR2(150);
      l_attribute7                 VARCHAR2(150);
      l_attribute8                 VARCHAR2(150);
      l_attribute9                 VARCHAR2(150);
      l_attribute10                VARCHAR2(150);

      -- old attributes of location to be modified
      o_location_id                NUMBER;
      o_loc_id                     NUMBER;
      o_org_id                     NUMBER;
      o_city                       VARCHAR2(60);
      o_state                      VARCHAR2(60);
      o_country                    VARCHAR2(60);
      o_county                     VARCHAR2(60);
      o_province                   VARCHAR2(60);
      o_postal_code                VARCHAR2(60);
      o_attribute1                 VARCHAR2(150);
      o_attribute2                 VARCHAR2(150);
      o_attribute3                 VARCHAR2(150);
      o_attribute4                 VARCHAR2(150);
      o_attribute5                 VARCHAR2(150);
      o_attribute6                 VARCHAR2(150);
      o_attribute7                 VARCHAR2(150);
      o_attribute8                 VARCHAR2(150);
      o_attribute9                 VARCHAR2(150);
      o_attribute10                VARCHAR2(150);

      l_loc_assignment_exist       VARCHAR2(1) := 'N';
      l_is_remit_to_location       VARCHAR2(1) := 'N';
      l_debug_prefix                   VARCHAR2(30) := '';

  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('tax_location_validation (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'tax_location_validation (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- tax location validation:

      l_country        :=  p_location_rec.country;
      l_city           :=  p_location_rec.city;
      l_state          :=  p_location_rec.state;
      l_county         :=  p_location_rec.county;
      l_province       :=  p_location_rec.province;
      l_postal_code    :=  p_location_rec.postal_code;
      l_attribute1     :=  p_location_rec.attribute1;
      l_attribute2     :=  p_location_rec.attribute2;
      l_attribute3     :=  p_location_rec.attribute3;
      l_attribute4     :=  p_location_rec.attribute4;
      l_attribute5     :=  p_location_rec.attribute5;
      l_attribute6     :=  p_location_rec.attribute6;
      l_attribute7     :=  p_location_rec.attribute7;
      l_attribute8     :=  p_location_rec.attribute8;
      l_attribute9     :=  p_location_rec.attribute9;
      l_attribute10    :=  p_location_rec.attribute10;

      IF p_create_update_flag = 'C' THEN
          -- no validation to be done
          -- tax code will be populated when customer account site is created.
          null;

      ELSIF p_create_update_flag = 'U' THEN

          l_location_id :=  p_location_rec.location_id;

          -- check if the location is only used by prospect customers

          BEGIN
              SELECT  'Y'
              INTO    l_loc_assignment_exist
              FROM    DUAL
              WHERE   EXISTS (SELECT  1
                               FROM    hz_loc_assignments la
                               WHERE   la.location_id = l_location_id
                            );
              SELECT  'Y'
              INTO    l_is_remit_to_location
              FROM    DUAL
              WHERE   EXISTS (SELECT  1
                               FROM    hz_party_sites ps
                               WHERE   ps.location_id = l_location_id
                               AND     ps.party_id = -1
                            );
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
              NULL;
          END;


          IF l_is_remit_to_location = 'N' and l_loc_assignment_exist = 'Y' THEN

              -- check if the taxable components are changed
              IF (  (p_location_rec.country IS NOT NULL
                         AND p_location_rec.country <> fnd_api.g_miss_char)
                     OR (p_location_rec.city IS NOT NULL
                         AND p_location_rec.city <> fnd_api.g_miss_char)
                     OR (p_location_rec.state IS NOT NULL
                         AND p_location_rec.state <> fnd_api.g_miss_char)
                     OR (p_location_rec.county IS NOT NULL
                         AND p_location_rec.county <> fnd_api.g_miss_char)
                     OR (p_location_rec.province IS NOT NULL
                         AND p_location_rec.province <> fnd_api.g_miss_char)
                     OR (p_location_rec.postal_code IS NOT NULL
                         AND p_location_rec.postal_code <> fnd_api.g_miss_char)
                     OR (p_location_rec.attribute1 IS NOT NULL
                         AND p_location_rec.attribute1 <> fnd_api.g_miss_char)
                     OR (p_location_rec.attribute2 IS NOT NULL
                         AND p_location_rec.attribute2 <> fnd_api.g_miss_char)
                     OR (p_location_rec.attribute3 IS NOT NULL
                         AND p_location_rec.attribute3 <> fnd_api.g_miss_char)
                     OR (p_location_rec.attribute4 IS NOT NULL
                         AND p_location_rec.attribute4 <> fnd_api.g_miss_char)
                     OR (p_location_rec.attribute5 IS NOT NULL
                         AND p_location_rec.attribute5 <> fnd_api.g_miss_char)
                     OR (p_location_rec.attribute6 IS NOT NULL
                         AND p_location_rec.attribute6 <> fnd_api.g_miss_char)
                     OR (p_location_rec.attribute7 IS NOT NULL
                         AND p_location_rec.attribute7 <> fnd_api.g_miss_char)
                     OR (p_location_rec.attribute8 IS NOT NULL
                         AND p_location_rec.attribute8 <> fnd_api.g_miss_char)
                     OR (p_location_rec.attribute9 IS NOT NULL
                         AND p_location_rec.attribute9 <> fnd_api.g_miss_char)
                     OR (p_location_rec.attribute10 IS NOT NULL
                         AND p_location_rec.attribute10 <> fnd_api.g_miss_char))
              THEN
                  BEGIN
                      SELECT country, city,  state, county, province,  postal_code,
                             attribute1, attribute2, attribute3, attribute4, attribute5,
                             attribute6, attribute7, attribute8, attribute9, attribute10
                      INTO   o_country, o_city, o_state, o_county, o_province, o_postal_code,
                             o_attribute1,o_attribute2,o_attribute3,o_attribute4,o_attribute5,
                             o_attribute6,o_attribute7,o_attribute8,o_attribute9,o_attribute10
                      FROM   HZ_LOCATIONS
                      WHERE  location_id = p_location_rec.location_id ;

                      IF (     o_country        <>   p_location_rec.country
                            OR  o_city           <>   p_location_rec.city
                            OR  o_state          <>   p_location_rec.state
                            OR  o_county         <>   p_location_rec.county
                            OR  o_province       <>   p_location_rec.province
                            OR  o_postal_code    <>   p_location_rec.postal_code
                            )
                      THEN
                          IF ARH_ADDR_PKG.check_tran_for_all_accts(p_location_rec.location_id)
                          THEN
                              fnd_message.set_name('AR', 'AR_CUST_ADDR_HAS_TRANSACTION');
--Bug 2452282                 fnd_message.set_token('COLUMN', 'tax related fields');
                              fnd_msg_pub.add;
                              x_return_status := fnd_api.g_ret_sts_error;
                          ELSE -- non taxable components to be modified
                              null; -- allow updates
                          END IF;
                      END IF;
                  END; -- end of first select
              END IF; -- taxable components are not changed
          END IF; -- end of p_location_rec.location_id <> -1
      END IF;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('tax_location_validation (-)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'tax_location_validation (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      --disable_debug;

  END tax_location_validation;

  /**
   * PROCEDURE validate_relationship_type
   *
   * DESCRIPTION
   *     Validates relationship type record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_relationship_type_rec        relationship type record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *   12-23-2003    Rajib Ranjan Borah o Bug 2751613.Combination of relationship phrase,subject_type
   *                                      and object_type should yield an unique phrase in the reverse
   *                                      direction.
   *   29-NOV-2004   S V Sowjanya        o Bug 3491584: Added a validation in procedure validate_relationship_type
   *                                       to throw an error message while creating non directional relationship type
   *                                       with different subject type and object type.
   *
   */

  PROCEDURE validate_relationship_type(
      p_create_update_flag                    IN      VARCHAR2,
      p_relationship_type_rec                 IN      HZ_RELATIONSHIP_TYPE_V2PUB.RELATIONSHIP_TYPE_REC_TYPE,
      p_rowid                                 IN      ROWID ,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

      l_dummy                                          VARCHAR2(1);
      l_count                                          NUMBER;
      l_code                                           VARCHAR2(30);
      l_relationship_type                              HZ_RELATIONSHIP_TYPES.RELATIONSHIP_TYPE%TYPE;
      l_forward_rel_code                               HZ_RELATIONSHIP_TYPES.FORWARD_REL_CODE%TYPE;
      l_backward_rel_code                              HZ_RELATIONSHIP_TYPES.BACKWARD_REL_CODE%TYPE;
      l_direction_code                                 HZ_RELATIONSHIP_TYPES.DIRECTION_CODE%TYPE;
      l_create_party_flag                              HZ_RELATIONSHIP_TYPES.CREATE_PARTY_FLAG%TYPE;
      l_allow_relate_to_self_flag                      HZ_RELATIONSHIP_TYPES.ALLOW_RELATE_TO_SELF_FLAG%TYPE;
      l_allow_circular_relationships                   HZ_RELATIONSHIP_TYPES.ALLOW_CIRCULAR_RELATIONSHIPS%TYPE;
      l_hierarchical_flag                              HZ_RELATIONSHIP_TYPES.HIERARCHICAL_FLAG%TYPE;
      l_multiple_parent_allowed                        HZ_RELATIONSHIP_TYPES.MULTIPLE_PARENT_ALLOWED%TYPE;
      l_incl_unrelated_entities                        HZ_RELATIONSHIP_TYPES.INCL_UNRELATED_ENTITIES%TYPE;
      l_subject_type                                   HZ_RELATIONSHIP_TYPES.SUBJECT_TYPE%TYPE;
      l_object_type                                    HZ_RELATIONSHIP_TYPES.OBJECT_TYPE%TYPE;
      l_created_by_module                              VARCHAR2(150);
      l_application_id                                 NUMBER;
      l_status                                         VARCHAR2(1);
      l_debug_prefix                                   VARCHAR2(30) := '';
      l_role                                           VARCHAR2(30);

  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_relationship_type (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_relationship_type (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

      -- select columns needed to be checked from table during update
      IF (p_create_update_flag = 'U') THEN
          SELECT RELATIONSHIP_TYPE,
                 FORWARD_REL_CODE,
                 BACKWARD_REL_CODE,
                 DIRECTION_CODE,
                 HIERARCHICAL_FLAG,
                 CREATE_PARTY_FLAG,
                 ALLOW_RELATE_TO_SELF_FLAG,
                 ALLOW_CIRCULAR_RELATIONSHIPS,
                 MULTIPLE_PARENT_ALLOWED,
                 INCL_UNRELATED_ENTITIES,
                 SUBJECT_TYPE,
                 OBJECT_TYPE,
                 ROLE,
                 CREATED_BY_MODULE,
                 APPLICATION_ID
          INTO   l_relationship_type,
                 l_forward_rel_code,
                 l_backward_rel_code,
                 l_direction_code,
                 l_hierarchical_flag,
                 l_create_party_flag,
                 l_allow_relate_to_self_flag,
                 l_allow_circular_relationships,
                 l_multiple_parent_allowed,
                 l_incl_unrelated_entities,
                 l_subject_type,
                 l_object_type,
                 l_role,
                 l_created_by_module,
                 l_application_id
          FROM   HZ_RELATIONSHIP_TYPES
          WHERE  ROWID = p_rowid;
      END IF;


      -- Validate the nonupdateability of ROLE

       IF (p_create_update_flag = 'U') THEN
          validate_nonupdateable (
          p_column                               => 'ROLE',
          p_column_value                         => p_relationship_type_rec.forward_role,
          p_old_column_value                     => l_role,
          x_return_status                        => x_return_status
          );
          --------Bug no: 3564107 ---------------------------------
          BEGIN
            SELECT ROLE INTO l_role
            FROM   HZ_RELATIONSHIP_TYPES
            WHERE  RELATIONSHIP_TYPE = l_relationship_type
            AND    FORWARD_REL_CODE  = l_backward_rel_code
            AND    BACKWARD_REL_CODE = l_forward_rel_code
            AND    SUBJECT_TYPE      = l_object_type
            AND    OBJECT_TYPE       = l_subject_type
            AND ROWNUM               = 1;

            validate_nonupdateable (
            p_column                               => 'ROLE',
            p_column_value                         => p_relationship_type_rec.backward_role,
            p_old_column_value                     => l_role,
            x_return_status                        => x_return_status
            );
          EXCEPTION
           WHEN NO_DATA_FOUND THEN
            NULL;
          END;
          --------End of Bug no: 3564107 ---------------------------------
        END IF;

      /* -- Raise an error if user tries to update forward role to NULL
      IF (p_create_update_flag = 'U') THEN
       validate_cannot_update_to_null (
        p_column              => 'role',
        p_column_value        => p_relationship_type_rec.forward_role,
        x_return_status       => x_return_status
      );

       -- Raise an error if user tries to update backward role to NULL
      IF (p_create_update_flag = 'U') THEN
       validate_cannot_update_to_null (
        p_column              => 'role',
        p_column_value        => p_relationship_type_rec.backward_role,
        x_return_status       => x_return_status
      );
      END IF;*/

      /*-- validate forward_role
             IF (p_create_update_flag = 'U') THEN
       validate_lookup (
              p_column                                => 'role',
              p_lookup_type                           => 'HZ_RELATIONSHIP_ROLE',
              p_column_value                          => p_relationship_type_rec.forward_role,
              x_return_status                         => x_return_status);
       END IF;

       -- validate backward_role
             IF (p_create_update_flag = 'U') THEN
       validate_lookup (
              p_column                                => 'role',
              p_lookup_type                           => 'HZ_RELATIONSHIP_ROLE',
              p_column_value                          => p_relationship_type_rec.backward_role,
              x_return_status                         => x_return_status);
       END IF;    */


      -----------------------------
      -- validate relationship_type
      -----------------------------

      -- relationship_type is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'relationship_type',
          p_column_value                          => p_relationship_type_rec.relationship_type,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'relationship_type is mandatory. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'relationship_type is mandatory. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -- relationship_type is non-updateable
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'relationship_type',
              p_column_value                          => p_relationship_type_rec.relationship_type,
              p_old_column_value                      => l_relationship_type,
              x_return_status                         => x_return_status);
          END IF;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'relationship_type is non-updateable. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'relationship_type is non-updateable. ' ||
                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;




      ------------------
      -- validate status
      ------------------

      -- status cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          validate_cannot_update_to_null (
              p_column                                => 'status',
              p_column_value                          => p_relationship_type_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status cannot be set to null during update. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'status cannot be set to null during update. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      -- status is lookup code in lookup type CODE_STATUS
      IF p_relationship_type_rec.status IS NOT NULL
         AND
         p_relationship_type_rec.status <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_relationship_type_rec.status <> NVL(l_status, fnd_api.g_miss_char)
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'status',
              p_lookup_type                           => 'CODE_STATUS',
              p_column_value                          => p_relationship_type_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status is lookup code in lookup type CODE_STATUS. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'status is lookup code in lookup type CODE_STATUS. ' ||
                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      -----------------------------
      -- validate create_party_flag
      -----------------------------

      -- create_party_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'create_party_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_relationship_type_rec.create_party_flag,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'create_party_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'create_party_flag should be in lookup YES/NO. ' ||
                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
     END IF;


      -- create_party_flag is non-updateable if relationship records are already created based
      -- on the current value of the flag
      IF p_create_update_flag = 'U' THEN
          IF p_relationship_type_rec.create_party_flag <> fnd_api.g_miss_char
             AND
             p_relationship_type_rec.create_party_flag IS NOT NULL
             AND
             p_relationship_type_rec.create_party_flag <> l_create_party_flag
          THEN
              IF l_create_party_flag = 'Y' AND p_relationship_type_rec.create_party_flag = 'N' THEN
                  -- check if there is any relationship with this relationship type having a party.
                  -- if there is, do not allow the update
                  BEGIN
                      SELECT 1 INTO l_count
                      FROM   HZ_RELATIONSHIPS
                      WHERE  RELATIONSHIP_TYPE = l_relationship_type
                      AND    SUBJECT_TYPE = l_subject_type
                      AND    OBJECT_TYPE = l_object_type
                      AND    RELATIONSHIP_CODE = l_forward_rel_code
                      AND    PARTY_ID IS NOT NULL
                      AND    STATUS = 'A'
                      AND    TRUNC(SYSDATE) BETWEEN TRUNC(START_DATE) AND TRUNC(NVL(END_DATE, SYSDATE))
                      AND    ROWNUM = 1;

                      -- update is not allowed, raise error
                      fnd_message.set_name('AR', 'HZ_API_CPF_NON_UPDATEABLE');
                      fnd_msg_pub.add;
                      x_return_status := fnd_api.g_ret_sts_error;

                   EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                           NULL;
                   END;
               END IF;

               IF l_create_party_flag = 'N' AND p_relationship_type_rec.create_party_flag = 'Y' THEN
                   -- check if there is any relationship with this relationship type not having a party.
                   -- if there is, do not allow the update.
                  BEGIN
                      SELECT 1 INTO l_count
                      FROM   HZ_RELATIONSHIPS
                      WHERE  RELATIONSHIP_TYPE = l_relationship_type
                      AND    SUBJECT_TYPE = l_subject_type
                      AND    OBJECT_TYPE = l_object_type
                      AND    RELATIONSHIP_CODE = l_forward_rel_code
                      AND    PARTY_ID IS NULL
                      AND    STATUS = 'A'
                      AND    TRUNC(SYSDATE) BETWEEN TRUNC(START_DATE) AND TRUNC(NVL(END_DATE, SYSDATE))
                      AND    ROWNUM = 1;

                      -- update is not allowed, raise error
                      fnd_message.set_name('AR', 'HZ_API_CPF_NON_UPDATEABLE');
                      fnd_msg_pub.add;
                      x_return_status := fnd_api.g_ret_sts_error;

                   EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                           NULL;
                   END;

              END IF;
          END IF;
      END IF;

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'create_party_flag is updateable/non-updateable. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'create_party_flag is updateable/non-updateable. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -----------------------------
      -- validate allow_circular_relationships
      -----------------------------

      -- allow_circular_relationships is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'allow_circular_relationships',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_relationship_type_rec.allow_circular_relationships,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'allow_circular_relationships should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'allow_circular_relationships should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;


      -- allow_circular_relationships is non-updateable
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'allow_circular_relationships',
              p_column_value                          => p_relationship_type_rec.allow_circular_relationships,
              p_old_column_value                      => l_allow_circular_relationships,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'allow_circular_relationships is non-updateable. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            p_message=>'allow_circular_relationships is non-updateable. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      -------------------------------------
      -- validate allow_relate_to_self_flag
      -------------------------------------

      -- allow_relate_to_self_flag is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'allow_relate_to_self_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_relationship_type_rec.allow_relate_to_self_flag,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'allow_relate_to_self_flag should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'allow_relate_to_self_flag should be in lookup YES/NO. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -- allow_relate_to_self_flag is non-updateable
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'allow_relate_to_self_flag',
              p_column_value                          => p_relationship_type_rec.allow_relate_to_self_flag,
              p_old_column_value                      => l_allow_relate_to_self_flag,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'allow_relate_to_self_flag is non-updateable. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'allow_relate_to_self_flag is non-updateable. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;


      END IF;

      ----------------------------
      -- validate forward_rel_code
      ----------------------------

      -- forward_rel_code is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'forward_rel_code',
          p_column_value                          => p_relationship_type_rec.forward_rel_code,
          x_return_status                         => x_return_status);

      -- forward_rel_code is lookup code in lookup type PARTY_RELATIONS_TYPE
      validate_lookup (
          p_column                                => 'forward_rel_code',
          p_lookup_type                           => 'PARTY_RELATIONS_TYPE',
          p_column_value                          => p_relationship_type_rec.forward_rel_code,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'forward_rel_code is lookup code in lookup type PARTY_RELATIONS_TYPE. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'forward_rel_code is lookup code in lookup type PARTY_RELATIONS_TYPE. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -- forward_rel_code is non-updateable
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'forward_rel_code',
              p_column_value                          => p_relationship_type_rec.forward_rel_code,
              p_old_column_value                      => l_forward_rel_code,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'forward_rel_code is non-updateable. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'forward_rel_code is non-updateable. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      -----------------------------
      -- validate backward_rel_code
      -----------------------------

      -- backward_rel_code is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'backward_rel_code',
          p_column_value                          => p_relationship_type_rec.backward_rel_code,
          x_return_status                         => x_return_status);

      -- backward_rel_code is lookup code in lookup type PARTY_RELATIONS_TYPE
      validate_lookup (
          p_column                                => 'backward_rel_code',
          p_lookup_type                           => 'PARTY_RELATIONS_TYPE',
          p_column_value                          => p_relationship_type_rec.backward_rel_code,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'backward_rel_code is lookup code in lookup type PARTY_RELATIONS_TYPE. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'backward_rel_code is lookup code in lookup type PARTY_RELATIONS_TYPE. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -- backward_rel_code is non-updateable
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'backward_rel_code',
              p_column_value                          => p_relationship_type_rec.backward_rel_code,
              p_old_column_value                      => l_backward_rel_code,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'backward_rel_code is non-updateable. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'backward_rel_code is non-updateable. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      -----------------------------
      -- validate direction_code
      -----------------------------

      -- direction_code is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'direction_code',
          p_column_value                          => p_relationship_type_rec.direction_code,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'direction_code is mandatory. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'direction_code is mandatory. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -- direction_code is lookup code in lookup type DIRECTION_CODE
      validate_lookup (
          p_column                                => 'direction_code',
          p_lookup_type                           => 'DIRECTION_CODE',
          p_column_value                          => p_relationship_type_rec.direction_code,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'direction_code is lookup code in lookup type DIRECTION_CODE. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'direction_code is lookup code in lookup type DIRECTION_CODE. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;


      -- direction_code is non-updateable
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'direction_code',
              p_column_value                          => p_relationship_type_rec.direction_code,
              p_old_column_value                      => l_direction_code,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'direction_code is non-updateable. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'direction_code is non-updateable. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      --------------------
      -- validate subject_type
      --------------------

      -- subject_type is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'subject_type',
          p_column_value                          => p_relationship_type_rec.subject_type,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'subject_type is mandatory. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'subject_type is mandatory. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -- subject_type has foreign key fnd_object_instance_sets.instance_set_name
      IF p_relationship_type_rec.subject_type IS NOT NULL
         AND
         p_relationship_type_rec.subject_type <> fnd_api.g_miss_char
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   FND_OBJECT_INSTANCE_SETS
              WHERE  INSTANCE_SET_NAME = p_relationship_type_rec.subject_type;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'subject_type');
                  fnd_message.set_token('COLUMN', 'instance_set_name');
                  fnd_message.set_token('TABLE', 'fnd_object_instance_sets');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'subject_type has foreign key fnd_object_instance_sets.instance_set_name. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
             p_message=>'subject_type has foreign key fnd_object_instance_sets.instance_set_name. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      -- subject_type is non-updateable
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'subject_type',
              p_column_value                          => p_relationship_type_rec.subject_type,
              p_old_column_value                      => l_subject_type,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'subject_type is non-updateable. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'subject_type is non-updateable. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      --------------------
      -- validate object_type
      --------------------

      -- object_type is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'object_type',
          p_column_value                          => p_relationship_type_rec.object_type,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'object_type is mandatory. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'object_type is mandatory. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;


      -- object_type has foreign key fnd_object_instance_sets.instance_set_name
      IF p_relationship_type_rec.object_type IS NOT NULL
         AND
         p_relationship_type_rec.object_type <> fnd_api.g_miss_char
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   FND_OBJECT_INSTANCE_SETS
              WHERE  INSTANCE_SET_NAME = p_relationship_type_rec.object_type;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'object_type');
                  fnd_message.set_token('COLUMN', 'instance_set_name');
                  fnd_message.set_token('TABLE', 'fnd_object_instance_sets');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'object_type has foreign key fnd_object_instance_sets.instance_set_name. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'object_type has foreign key fnd_object_instance_sets.instance_set_name. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      -- object_type is non-updateable
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'object_type',
              p_column_value                          => p_relationship_type_rec.object_type,
              p_old_column_value                      => l_object_type,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'object_type is non-updateable. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'object_type is non-updateable. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      ---------------------------
      -- validate the combination
      ---------------------------

      -- the combination of FORWARD_REL_CODE, SUBJECT_TYPE, OBJECT_TYPE should be
      -- able to identify a unique BACKWARD_REL_CODE. Thus a second record with same
      -- combination of FORWARD_REL_CODE, SUBJECT_TYPE, OBJECT_TYPE should have
      -- same BACKWARD_REL_CODE.
      -- 07/23/2002. this validation has been enhanced to apply the validation within a
      -- relationship type rather than doing the validation across all relatiosnhip
      -- types. bug 2453736.
      -- first check whether there is one such record
      -- Bug 2751613.This validation should work for all the different combinations.
/* Bug 2751613.
 |    SELECT COUNT(*)
 |    INTO   l_count
 |    FROM   HZ_RELATIONSHIP_TYPES
 |    WHERE  RELATIONSHIP_TYPE = p_relationship_type_rec.relationship_type
 |    AND    FORWARD_REL_CODE = p_relationship_type_rec.forward_rel_code
 |    AND    SUBJECT_TYPE = p_relationship_type_rec.subject_type
 |    AND    OBJECT_TYPE = p_relationship_type_rec.object_type;
 |
 |    IF l_count > 0 THEN
 |        --since there is one or more such records, we need to get the backward_rel_code
 |        SELECT BACKWARD_REL_CODE
 |        INTO   l_code
 |        FROM   HZ_RELATIONSHIP_TYPES
 |        WHERE  RELATIONSHIP_TYPE = p_relationship_type_rec.relationship_type
 |        AND    FORWARD_REL_CODE = p_relationship_type_rec.forward_rel_code
 |        AND    SUBJECT_TYPE = p_relationship_type_rec.subject_type
 |        AND    OBJECT_TYPE = p_relationship_type_rec.object_type
 |        AND    ROWNUM = 1;
 |        -- if the backward_rel_code passed do not match with whatever
 |        -- obtained from above query, error out NOCOPY
 |        IF l_code <> p_relationship_type_rec.backward_rel_code then
 |            fnd_message.set_name('AR', 'HZ_API_INVALID_COMBINATION');
 |            fnd_msg_pub.add;
 |            x_return_status := FND_API.G_RET_STS_ERROR;
 |        END IF;
 |    END IF;
 */

      -- Bug 2751613.
      SELECT COUNT(*)
      INTO   l_count
      FROM   HZ_RELATIONSHIP_TYPES
      WHERE
           (
           RELATIONSHIP_TYPE = p_relationship_type_rec.relationship_type
           )
          AND
           (
            (
             (SUBJECT_TYPE = p_relationship_type_rec.subject_type
             AND    OBJECT_TYPE = p_relationship_type_rec.object_type
             )
            AND
             (
              (BACKWARD_REL_CODE <> p_relationship_type_rec.backward_rel_code
              AND  FORWARD_REL_CODE = p_relationship_type_rec.forward_rel_code
              )
             OR
              (BACKWARD_REL_CODE = p_relationship_type_rec.backward_rel_code
              AND   FORWARD_REL_CODE <> p_relationship_type_rec.forward_rel_code
              )
             )
            )
           OR
            (
             (SUBJECT_TYPE = p_relationship_type_rec.object_type
             AND    OBJECT_TYPE = p_relationship_type_rec.subject_type
             )
            AND
             (
              (BACKWARD_REL_CODE <> p_relationship_type_rec.forward_rel_code
              AND  FORWARD_REL_CODE = p_relationship_type_rec.backward_rel_code
              )
             OR
              (BACKWARD_REL_CODE = p_relationship_type_rec.forward_rel_code
              AND   FORWARD_REL_CODE <> p_relationship_type_rec.backward_rel_code
              )
             )
            )
           );

      IF l_count <> 0
      THEN
        fnd_message.set_name('AR', 'HZ_API_INVALID_COMBINATION');
              fnd_msg_pub.add;
              x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'validate the combination of forward_rel_code, subject_type, object_type. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'validate the combination of forward_rel_code,backward_rel_code, subject_type, object_type. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -----------------------------
      -- check for duplicate record
      -----------------------------

      -- check for duplicate record
      BEGIN
          SELECT 1
          INTO   l_count
          FROM   HZ_RELATIONSHIP_TYPES
          WHERE  RELATIONSHIP_TYPE = p_relationship_type_rec.relationship_type
          AND    FORWARD_REL_CODE = p_relationship_type_rec.forward_rel_code
          AND    BACKWARD_REL_CODE = p_relationship_type_rec.backward_rel_code
          AND    SUBJECT_TYPE = p_relationship_type_rec.subject_type
          AND    OBJECT_TYPE = p_relationship_type_rec.object_type
          AND    RELATIONSHIP_TYPE_ID <> NVL(p_relationship_type_rec.relationship_type_id,-1);

          fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
          fnd_message.set_token('COLUMN', 'relationship type, forward rel code, backward rel code, subject type, object type');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              NULL;
      END;

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'check for duplicate record. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'check for duplicate record. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      --------------------------
      -- validate direction_code
      --------------------------

      -- if forward_rel_code and backward_rel_code are same then direction_flag
      -- cannot be 'P' or 'C'
      IF p_relationship_type_rec.forward_rel_code = p_relationship_type_rec.backward_rel_code
         AND
         p_relationship_type_rec.direction_code <> 'N'
      THEN
          fnd_message.set_name('AR', 'HZ_INVALID_DIRECTION_CODE1');
          fnd_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- if forward_rel_code and backward_rel_code are not same then direction_flag
      -- cannot be 'N'
      IF p_relationship_type_rec.forward_rel_code <> p_relationship_type_rec.backward_rel_code
         AND p_relationship_type_rec.direction_code = 'N'
      THEN
          fnd_message.set_name('AR', 'HZ_INVALID_DIRECTION_CODE2');
          fnd_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'validate direction_code. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate direction_code. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


    -----------------------------
    -- validate hierarchical_flag
    -----------------------------

    -- hierarchical_flag is lookup code in lookup type YES/NO
    validate_lookup (
        p_column                                => 'hierarchical_flag',
        p_lookup_type                           => 'YES/NO',
        p_column_value                          => p_relationship_type_rec.hierarchical_flag,
        x_return_status                         => x_return_status );

    /*IF G_DEBUG THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'hierarchical_flag in lookup YES/NO. ' ||
            'x_return_status = ' || x_return_status, l_debug_prefix );
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'hierarchical_flag in lookup YES/NO. ' ||
            'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    -- hierarchical_flag is non-updateable
    IF p_create_update_flag = 'U' THEN
        validate_nonupdateable (
            p_column                                => 'hierarchical_flag',
            p_column_value                          => p_relationship_type_rec.hierarchical_flag,
            p_old_column_value                      => l_hierarchical_flag,
            x_return_status                         => x_return_status);

        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'hierarchical_flag is non-updateable. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'hierarchical_flag is non-updateable. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;


    END IF;

    ----------------------------------------------------------------------------
    -- validate combination of hierarchical_flag and allow_circular_relationship
    ----------------------------------------------------------------------------
    -- needed only during creation since these columns cannot be updated
    IF p_create_update_flag = 'C' THEN
        -- if hierarchical_flag = 'Y', then allow_circular_relationships must be 'N'
        IF NVL(p_relationship_type_rec.hierarchical_flag, 'N') = 'Y' THEN
            IF p_relationship_type_rec.allow_circular_relationships = 'Y' THEN
                fnd_message.set_name('AR', 'HZ_API_VAL_DEP_FIELDS');
                fnd_message.set_token('COLUMN1', 'hierarchical_flag');
                fnd_message.set_token('VALUE1', 'Y(Yes)');
                fnd_message.set_token('COLUMN2', 'allow_circular_relationships');
                fnd_message.set_token('VALUE2', 'N(No)');
                fnd_msg_pub.add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'if hierarchical_flag = ''Y'', then allow_circular_relationships must be ''N''. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'if hierarchical_flag = ''Y'', then allow_circular_relationships must be ''N''. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

    END IF;

    ---------------------------------------------------------------
    -- validate combination of hierarchical_flag and direction_code
    ---------------------------------------------------------------
    -- needed only during creation since these columns cannot be updated
    IF p_create_update_flag = 'C' THEN
        -- if hierarchical_flag = 'Y', the direction_code must be 'P' or 'C'
        IF NVL(p_relationship_type_rec.hierarchical_flag, 'N') = 'Y' THEN
            IF p_relationship_type_rec.direction_code = 'N' THEN
                fnd_message.set_name('AR', 'HZ_API_VAL_DEP_FIELDS');
                fnd_message.set_token('COLUMN1', 'hierarchical_flag');
                fnd_message.set_token('VALUE1', 'Y(Yes)');
                fnd_message.set_token('COLUMN2', 'direction_code');
                fnd_message.set_token('VALUE2', 'P(Parent)/C(Child)');
                fnd_msg_pub.add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'if hierarchical_flag = ''Y'', the direction_code must be ''P'' or ''C''. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'if hierarchical_flag = ''Y'', the direction_code must be ''P'' or ''C''. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

    END IF;

      -- check for duplicate role

      IF p_create_update_flag = 'C' THEN
      BEGIN
          SELECT count(*)
          INTO   l_count
          FROM   HZ_RELATIONSHIP_TYPES
          WHERE  ROLE = p_relationship_type_rec.forward_role
           OR    ROLE = p_relationship_type_rec.backward_role;
          IF l_count > 0 THEN
          fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
          fnd_message.set_token('COLUMN', 'role');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END;
     END IF;

    -- validate role/rel_code

    IF p_create_update_flag = 'C' THEN
      IF ( p_relationship_type_rec.forward_role IS NOT NULL AND
           p_relationship_type_rec.forward_role <> fnd_api.g_miss_char) AND
          ( p_relationship_type_rec.backward_role IS NOT NULL AND
            p_relationship_type_rec.backward_role <> fnd_api.g_miss_char) THEN
        validate_rel_code(
           p_forward_rel_code          =>p_relationship_type_rec.forward_rel_code,
           p_backward_rel_code         =>p_relationship_type_rec.backward_rel_code,
           p_forward_role              => p_relationship_type_rec.forward_role,
           p_backward_role             => p_relationship_type_rec.backward_role,
           x_return_status             => x_return_status);
     END IF;
   END IF;

    -- validate lookup
    IF  p_create_update_flag = 'C' THEN
      IF p_relationship_type_rec.forward_role IS NOT NULL THEN
          validate_lookup (
              p_column                                => 'role',
              p_lookup_type                           => 'HZ_RELATIONSHIP_ROLE',
              p_column_value                          => p_relationship_type_rec.forward_role,
              x_return_status                         => x_return_status);
       END IF;
       IF p_relationship_type_rec.backward_role IS NOT NULL THEN
          validate_lookup (
              p_column                                => 'role',
              p_lookup_type                           => 'HZ_RELATIONSHIP_ROLE',
              p_column_value                          => p_relationship_type_rec.backward_role,
              x_return_status                         => x_return_status);
       END IF;
    END IF;

    ----------------------------------------------------------------------------
    -- validate combination of hierarchical_flag and allow_relate_to_self_flag
    ----------------------------------------------------------------------------
    -- needed only during creation since these columns cannot be updated
    IF p_create_update_flag = 'C' THEN
        -- if hierarchical_flag = 'Y', then allow_relate_to_self_flag must be 'N'
        IF NVL(p_relationship_type_rec.hierarchical_flag, 'N') = 'Y' THEN
            IF p_relationship_type_rec.allow_relate_to_self_flag = 'Y' THEN
                fnd_message.set_name('AR', 'HZ_API_VAL_DEP_FIELDS');
                fnd_message.set_token('COLUMN1', 'hierarchical_flag');
                fnd_message.set_token('VALUE1', 'Y(Yes)');
                fnd_message.set_token('COLUMN2', 'allow_relate_to_self_flag');
                fnd_message.set_token('VALUE2', 'N(No)');
                fnd_msg_pub.add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'if hierarchical_flag = ''Y'', then allow_relate_to_self_flag must be ''N''. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'if hierarchical_flag = ''Y'', then allow_relate_to_self_flag must be ''N''. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

    END IF;


    --------------------------------------------------------------------------
    -- validate combination of allow_circular_relationships and direction_code
    --------------------------------------------------------------------------
    -- neede only during creation since these columns cannot be updated
    IF p_create_update_flag = 'C' THEN
        -- if direction_code = 'N', the allow_circular_relationships must be 'Y'
        IF p_relationship_type_rec.direction_code = 'N' THEN
            IF NVL(p_relationship_type_rec.allow_circular_relationships, 'Y') = 'N' THEN
                fnd_message.set_name('AR', 'HZ_API_VAL_DEP_FIELDS');
                fnd_message.set_token('COLUMN1', 'direction_code');
                fnd_message.set_token('VALUE1', 'N(No)');
                fnd_message.set_token('COLUMN2', 'allow_circular_relationships');
                fnd_message.set_token('VALUE2', 'Y(Yes)');
                fnd_msg_pub.add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'if hierarchical_flag = ''Y'', the direction_code must be ''P'' or ''C''. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'if hierarchical_flag = ''Y'', the direction_code must be ''P'' or ''C''. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

    END IF;

    /* THIS UNNECESSARY VALIDATION HAS BEEN COMMENTED AFTER DISCUSSION WITH
       SRANGARA AND RPITTS, THE CONCLUSION OF WHICH IS THAT
       NON_HIERARCHICAL RELATIONSHIPS DO NOT NEED ANY VALUE
       FOR MULTIPLE_PARENT_ALLOWED,SINCE EVEN A SINGLE PARENT
       DOES NOT MAKE SENSE FOR A NON_HIERARCHICAL RELATIONSHIP TYPE.
       THE do_relationship_type IN HZ_RELATIONSHIP_TYPE_V2PUB WHICH
       DEFAULTS THE VALUE OF THIS FLAG TO "Y" FOR NON_HIERARCHICAL
       REL TYPES SHOULD ALSO BE CHANGED IN THE FUTURE.

      ----- VJN
    ------------------------------------------------------------------------
    -- validate combination of hierarchical_flag and multiple_parent_allowed
    ------------------------------------------------------------------------
    -- neede only during creation since these columns cannot be updated
    IF p_create_update_flag = 'C' THEN
        -- if hierarchical_flag = 'N', then multiple_parent_allowed must be 'Y'
        IF NVL(p_relationship_type_rec.hierarchical_flag, 'N') = 'N' THEN
            IF NVL(p_relationship_type_rec.multiple_parent_allowed, 'Y') = 'N' THEN
                fnd_message.set_name('AR', 'HZ_API_VAL_DEP_FIELDS');
                fnd_message.set_token('COLUMN1', 'hierarchical_flag');
                fnd_message.set_token('VALUE1', 'N(No)');
                fnd_message.set_token('COLUMN2', 'multiple_parent_allowed');
                fnd_message.set_token('VALUE2', 'Y(Yes)');
                fnd_msg_pub.add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'if hierarchical_flag = ''N'', the multiple_parent_allowed must be ''Y''. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

    END IF;

    */


    --------------------------------------------------------------------------------
    -- validate that all relationship type records with same relationship_type value
    -- have same values for hierarchical_flag
    --------------------------------------------------------------------------------
    -- needed only during creation since hierarchical_flag is not updatable
    IF p_create_update_flag = 'C' THEN
        BEGIN
            SELECT HIERARCHICAL_FLAG
            INTO   l_hierarchical_flag
            FROM   HZ_RELATIONSHIP_TYPES
            WHERE  RELATIONSHIP_TYPE = p_relationship_type_rec.relationship_type
            AND    ROWNUM = 1;

            IF NVL(p_relationship_type_rec.hierarchical_flag, 'N')
                     <> NVL(l_hierarchical_flag, 'N')
                   and
               NVL(p_relationship_type_rec.hierarchical_flag, 'Y')
                     <> NVL(l_hierarchical_flag, 'Y')
                THEN
                fnd_message.set_name('AR', 'HZ_DIFF_VALUE_NOT_ALLOWED');
                fnd_message.set_token('ENTITY', 'relationship type');
                fnd_message.set_token('COLUMN1', 'relationship_type');
                fnd_message.set_token('COLUMN2', 'hierarchical_flag');
                fnd_msg_pub.add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        EXCEPTION
            -- if no data found, then its fine since this is the first record
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'all relationship type records with same relationship_type value must have same values for hierarchical_flag. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'all relationship type records with same relationship_type value must have same values for hierarchical_flag. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

    END IF;

    --------------------------------------------------------------------------------
    -- validate that all relationship type records with same relationship_type value
    -- have same values for allow_circular_relationships
    --------------------------------------------------------------------------------
    -- needed only during creation since allow_circular_relationships is not updatable
    IF p_create_update_flag = 'C' THEN
        BEGIN
            SELECT ALLOW_CIRCULAR_RELATIONSHIPS
            INTO   l_allow_circular_relationships
            FROM   HZ_RELATIONSHIP_TYPES
            WHERE  RELATIONSHIP_TYPE = p_relationship_type_rec.relationship_type
            AND    ROWNUM = 1;

            IF NVL(p_relationship_type_rec.allow_circular_relationships, 'N') <>                   NVL(l_allow_circular_relationships, 'N')
               and
             NVL(p_relationship_type_rec.allow_circular_relationships, 'Y') <>
                   NVL(l_allow_circular_relationships, 'Y')
                THEN
                fnd_message.set_name('AR', 'HZ_DIFF_VALUE_NOT_ALLOWED');
                fnd_message.set_token('ENTITY', 'relationship type');
                fnd_message.set_token('COLUMN1', 'relationship_type');
                fnd_message.set_token('COLUMN2', 'allow_circular_relationships');
                fnd_msg_pub.add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        EXCEPTION
            -- if no data found, then its fine since this is the first record
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          p_message=>'all relationship type records with same relationship_type value must have same values for'||
                      ' allow_circular_relationships. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

    END IF;

    --------------------------------------------------------------------------------
    -- validate that all relationship type records with same relationship_type value
    -- have same values for multiple_parent_allowed
    --------------------------------------------------------------------------------
    -- needed only during creation since multiple_parent_allowed is not updatable
    IF p_create_update_flag = 'C' THEN
        BEGIN
            SELECT MULTIPLE_PARENT_ALLOWED
            INTO   l_multiple_parent_allowed
            FROM   HZ_RELATIONSHIP_TYPES
            WHERE  RELATIONSHIP_TYPE = p_relationship_type_rec.relationship_type
            AND    ROWNUM = 1;

            IF NVL(p_relationship_type_rec.multiple_parent_allowed, 'N') <>
                          NVL(l_multiple_parent_allowed, 'N')
               and
               NVL(p_relationship_type_rec.multiple_parent_allowed, 'Y') <>
                        NVL(l_multiple_parent_allowed, 'Y')
                THEN
                fnd_message.set_name('AR', 'HZ_DIFF_VALUE_NOT_ALLOWED');
                fnd_message.set_token('ENTITY', 'relationship type');
                fnd_message.set_token('COLUMN1', 'relationship_type');
                fnd_message.set_token('COLUMN2', 'multiple_parent_allowed');
                fnd_msg_pub.add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        EXCEPTION
            -- if no data found, then its fine since this is the first record
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'all relationship type records with same relationship_type value must have same values for multiple_parent_allowed. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'all relationship type records with same relationship_type value must have same values for multiple_parent_allowed. ' ||
                                            'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

    END IF;

    -----------------------------------
    -- validate incl_unrelated_entities
    -----------------------------------

    -- incl_unrelated_entities is lookup code in lookup type YES/NO
    validate_lookup (
        p_column                                => 'incl_unrelated_entities',
        p_lookup_type                           => 'YES/NO',
        p_column_value                          => p_relationship_type_rec.incl_unrelated_entities,
        x_return_status                         => x_return_status );

    /*IF G_DEBUG THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'incl_unrelated_entities in lookup YES/NO. ' ||
            'x_return_status = ' || x_return_status, l_debug_prefix );
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'incl_unrelated_entities in lookup YES/NO. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    -----------------------------------
    -- validate multiple_parent_allowed
    -----------------------------------

    -- multiple_parent_allowed is lookup code in lookup type YES/NO
    validate_lookup (
        p_column                                => 'multiple_parent_allowed',
        p_lookup_type                           => 'YES/NO',
        p_column_value                          => p_relationship_type_rec.multiple_parent_allowed,
        x_return_status                         => x_return_status );

    /*IF G_DEBUG THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            'multiple_parent_allowed in lookup YES/NO. ' ||
            'x_return_status = ' || x_return_status, l_debug_prefix );
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'multiple_parent_allowed in lookup YES/NO. ' ||
            'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    -- multiple_parent_allowed is non-updateable
    IF p_create_update_flag = 'U' THEN
        validate_nonupdateable (
            p_column                                => 'multiple_parent_allowed',
            p_column_value                          => p_relationship_type_rec.multiple_parent_allowed,
            p_old_column_value                      => l_multiple_parent_allowed,
            x_return_status                         => x_return_status);

        /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                'multiple_parent_allowed is non-updateable. ' ||
                'x_return_status = ' || x_return_status, l_debug_prefix);
        END IF;
        */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'multiple_parent_allowed is non-updateable. ' ||
                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;


    END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_relationship_type_rec.created_by_module,
        p_old_created_by_module  => l_created_by_module,
        x_return_status          => x_return_status);

      --------------------------------------
      -- validate application_id
      --------------------------------------

      validate_application_id(
        p_create_update_flag     => p_create_update_flag,
        p_application_id         => p_relationship_type_rec.application_id,
        p_old_application_id     => l_application_id,
        x_return_status          => x_return_status);

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_relationship_type (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

--bug 3491584
    IF (p_create_update_flag = 'C') THEN
      IF((p_relationship_type_rec.forward_rel_code = p_relationship_type_rec.backward_rel_code)
          AND (p_relationship_type_rec.subject_type <> p_relationship_type_rec.object_type))
      THEN
      fnd_message.set_name('AR', 'HZ_API_RELTYPE_INVALID');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'Same subject and object type because the relationship phrase pair has the same subject (forward) and object (backward) phrase. ' ||
                  'x_return_status = ' || x_return_status,
                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;
    END IF;

      --disable_debug;

  END validate_relationship_type;

  /**
   * PROCEDURE validate_relationship
   *
   * DESCRIPTION
   *     Validates relationship record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_relationship_rec             Relationship record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen       o Created.
   *   13-DEC-2001   Joe del Callar     Bug 2145637: Modified to use the new
   *                                    time-dependent date overlap check.
   */

  PROCEDURE validate_relationship(
    p_create_update_flag  IN      VARCHAR2,
    p_relationship_rec    IN      hz_relationship_v2pub.relationship_rec_type,
    p_rowid               IN      ROWID ,
    x_return_status       IN OUT NOCOPY  VARCHAR2
  ) IS
    l_count                 NUMBER;
    l_subject_id            NUMBER := p_relationship_rec.subject_id;
    l_object_id             NUMBER := p_relationship_rec.object_id;
    l_relationship_type     hz_relationships.relationship_type%TYPE := p_relationship_rec.relationship_type;
    l_relationship_code     hz_relationships.relationship_code%TYPE := p_relationship_rec.relationship_code;
    l_subject_type          hz_relationships.subject_type%TYPE := p_relationship_rec.subject_type;
    l_object_type           hz_relationships.object_type%TYPE := p_relationship_rec.object_type;
    l_subject_table_name    hz_relationships.subject_table_name%TYPE := p_relationship_rec.subject_table_name;
    l_object_table_name     hz_relationships.object_table_name%TYPE := p_relationship_rec.object_table_name;
    l_party_id              NUMBER;
    l_content_source_type   hz_relationships.content_source_type%TYPE;
    l_start_date            DATE := p_relationship_rec.start_date;
    l_end_date              DATE := p_relationship_rec.end_date;
    l_in                    VARCHAR2(1);
    l_overlap               VARCHAR2(1);
    l_created_by_module     VARCHAR2(150);
    l_application_id        NUMBER;
    l_status                VARCHAR2(1);
    l_debug_prefix          VARCHAR2(30) := '';

    -- Bug 2197181: Added for mix-n-match
    db_actual_content_source   hz_relationships.actual_content_source%TYPE;


    -- cursor to get all the relationship records...
    -- for given subject_id, object_id, relationship_code
    -- bug - 2528427, added relationship type to the where...
    -- clause so that time overlap is checked among records with...
    -- same relationship type, relationship code, subject id and object id
    CURSOR c1 (
      p_data_source           VARCHAR2
    ) IS
      SELECT hr.start_date,
             hr.end_date,
             hr.relationship_id,
             hr.status
      FROM   hz_relationships hr
      WHERE  hr.subject_id = l_subject_id
      AND    hr.object_id = l_object_id
      AND    hr.subject_table_name = l_subject_table_name
      AND    hr.subject_type = l_subject_type
      AND    hr.object_table_name = l_object_table_name
      AND    hr.object_type = l_object_type
      AND    hr.relationship_code = l_relationship_code
      AND    hr.relationship_type = l_relationship_type
      --AND hr.directional_flag = 'F'
      AND    hr.status = 'A'
      AND    hr.actual_content_source = p_data_source
      AND    NVL(p_relationship_rec.relationship_id, fnd_api.g_miss_num) <> hr.relationship_id;

-- Bug 3294936 : Comment rownum = 1 so that the cursor picks all records
--               with same relationship type between same subject and object.

--      AND    ROWNUM = 1;


    r1                      c1%ROWTYPE;

    l_dummy                 VARCHAR2(1);
    l_count                 NUMBER;
    l_code                  VARCHAR2(30);
  BEGIN
    --enable_debug;

    -- Debug info.
    /*IF g_debug THEN
        hz_utility_v2pub.debug ('validate_relationship (+)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_relationship (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- select columns needed to be checked from table during update
    IF (p_create_update_flag = 'U') THEN

    -- Bug 2197181: selecting actual_content_source for mix-n-match

      SELECT subject_id,
             subject_type,
             subject_table_name,
             object_id,
             object_type,
             object_table_name,
             relationship_code,
             relationship_type,
             party_id,
             content_source_type,
             start_date,
             end_date,
             status,
             created_by_module,
             application_id,
             actual_content_source
      INTO   l_subject_id,
             l_subject_type,
             l_subject_table_name,
             l_object_id,
             l_object_type,
             l_object_table_name,
             l_relationship_code,
             l_relationship_type,
             l_party_id,
             l_content_source_type,
             l_start_date,
             l_end_date,
             l_status,
             l_created_by_module,
             l_application_id,
             db_actual_content_source
      FROM   hz_relationships
      WHERE  ROWID = p_rowid;
    END IF;

    -----------------------------
    -- validate relationship_type
    -----------------------------

    -- relationship_type is mandatory
    validate_mandatory (
      p_create_update_flag    => p_create_update_flag,
      p_column                => 'relationship_type',
      p_column_value          => p_relationship_rec.relationship_type,
      x_return_status         => x_return_status);

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'relationship_type is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                             l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'relationship_type is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- relationship_type is non-updateable
    IF p_create_update_flag = 'U' THEN
      validate_nonupdateable (
        p_column                => 'relationship_type',
        p_column_value          => p_relationship_rec.relationship_type,
        p_old_column_value      => l_relationship_type,
        x_return_status         => x_return_status
      );

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'relationship_type is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                               l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'relationship_type is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -----------------------------
    -- validate relationship_code
    -----------------------------

    -- relationship_code is mandatory
    validate_mandatory (
      p_create_update_flag      => p_create_update_flag,
      p_column                  => 'relationship_code',
      p_column_value            => p_relationship_rec.relationship_code,
      x_return_status           => x_return_status
    );

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'relationship_code is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                             l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'relationship_code is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- relationship_code is non-updateable
    IF p_create_update_flag = 'U' THEN
      validate_nonupdateable (
        p_column                => 'relationship_code',
        p_column_value          => p_relationship_rec.relationship_code,
        p_old_column_value      => l_relationship_code,
        x_return_status         => x_return_status
      );

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'relationship_code is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                               l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'relationship_code is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    -- relationship_code is lookup code in lookup type PARTY_RELATIONS_TYPE
    IF p_create_update_flag = 'C' THEN
      validate_lookup (
        p_column                => 'relationship_code',
        p_lookup_type           => 'PARTY_RELATIONS_TYPE',
        p_column_value          => p_relationship_rec.relationship_code,
        x_return_status         => x_return_status
      );

      /*IF g_debug THEN
        hz_utility_v2pub.debug (
          'relationship_code is lookup code in lookup type PARTY_RELATIONS_TYPE. ' ||
            'x_return_status = ' || x_return_status,
          l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'relationship_code is lookup code in lookup type PARTY_RELATIONS_TYPE. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    ----------------------
    -- validate subject_id
    ----------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- subject_id is mandatory
    validate_mandatory (
      p_create_update_flag                    => p_create_update_flag,
      p_column                                => 'subject_id',
      p_column_value                          => p_relationship_rec.subject_id,
      x_return_status                         => x_return_status);

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'subject_id is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                             l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'subject_id is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- subject_id is non-updateable
    IF p_create_update_flag = 'U' THEN
      validate_nonupdateable (
        p_column                => 'subject_id',
        p_column_value          => p_relationship_rec.subject_id,
        p_old_column_value      => l_subject_id,
        x_return_status         => x_return_status
      );

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'subject_id is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                               l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'subject_id is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;
  END IF;

    -- check whether subject_id belongs to subject_type
    IF p_relationship_rec.subject_id IS NOT NULL
       AND p_relationship_rec.subject_id <> fnd_api.g_miss_num
       AND p_create_update_flag = 'C'
    THEN
      l_in := hz_relationship_type_v2pub.in_instance_sets (
                p_relationship_rec.subject_type,
                p_relationship_rec.subject_id
              );

      IF l_in = 'N' THEN
        fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
        fnd_message.set_token('FK', 'subject_id');
        fnd_message.set_token('COLUMN',
                              lower(p_relationship_rec.subject_type)||' id');
        fnd_message.set_token('TABLE', p_relationship_rec.subject_table_name);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'subject_id belongs to subject_type. ' ||
                                 'x_return_status = ' || x_return_status,
                               l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'subject_id belongs to subject_type. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    ------------------------------
    -- validate subject_table_name
    ------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- subject_table_name is mandatory
    validate_mandatory (
      p_create_update_flag      => p_create_update_flag,
      p_column                  => 'subject_table_name',
      p_column_value            => p_relationship_rec.subject_table_name,
      x_return_status           => x_return_status);

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'subject_table_name is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                             l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'subject_table_name is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- subject_table_name is non-updateable
    IF p_create_update_flag = 'U' THEN
      validate_nonupdateable (
        p_column                => 'subject_table_name',
        p_column_value          => p_relationship_rec.subject_table_name,
        p_old_column_value      => l_subject_table_name,
        x_return_status         => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'subject_table_name is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                               l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'subject_table_name is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -- subject_table_name has foreign key fnd_objects.obj_name
    -- do not need to check during update because subject_table_name is
    -- non-updateable.
    IF p_create_update_flag = 'C'
       AND p_relationship_rec.subject_table_name IS NOT NULL
       AND p_relationship_rec.subject_table_name <> fnd_api.g_miss_char
    THEN
      BEGIN
        SELECT 'Y'
        INTO   l_dummy
        FROM   fnd_objects fo
        WHERE  fo.obj_name = p_relationship_rec.subject_table_name;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'subject_table_name');
          fnd_message.set_token('COLUMN', 'obj_name');
          fnd_message.set_token('TABLE', 'fnd_objects');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'subject_table_name has foreign key fnd_objects.obj_name. ' ||
            'x_return_status = ' || x_return_status,
          l_debug_prefix
        );
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'subject_table_name has foreign key fnd_objects.obj_name. ' ||
            'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;
  END IF;

    ------------------------
    -- validate subject_type
    ------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- subject_type is mandatory
    validate_mandatory (
      p_create_update_flag      => p_create_update_flag,
      p_column                  => 'subject_type',
      p_column_value            => p_relationship_rec.subject_type,
      x_return_status           => x_return_status
    );

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'subject_type is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                             l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'subject_type is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- subject_type is non-updateable
    IF p_create_update_flag = 'U' THEN
      validate_nonupdateable (
        p_column                => 'subject_type',
        p_column_value          => p_relationship_rec.subject_type,
        p_old_column_value      => l_subject_type,
        x_return_status         => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'subject_type is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                               l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'subject_type is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    -- subject_type has foreign key fnd_object_instance_sets.instance_set_name
    -- do not need to check during update because subject_type is
    -- non-updateable.
    IF p_create_update_flag = 'C'
       AND p_relationship_rec.subject_type IS NOT NULL
       AND p_relationship_rec.subject_type <> fnd_api.g_miss_char
    THEN
      BEGIN
        SELECT 'Y'
        INTO   l_dummy
        FROM   fnd_object_instance_sets fois
        WHERE  fois.instance_set_name = p_relationship_rec.subject_type;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'subject_type');
          fnd_message.set_token('COLUMN', 'instance_set_name');
          fnd_message.set_token('TABLE', 'fnd_object_instance_sets');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'subject_type has foreign key fnd_object_instance_sets.instance_set_name. ' ||
            'x_return_status = ' || x_return_status,
          l_debug_prefix
        );
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'subject_type has foreign key fnd_object_instance_sets.instance_set_name. ' ||
            'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;
  END IF;

    ---------------------
    -- validate object_id
    ---------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- object_id is mandatory
    validate_mandatory (
      p_create_update_flag                    => p_create_update_flag,
      p_column                                => 'object_id',
      p_column_value                          => p_relationship_rec.object_id,
      x_return_status                         => x_return_status
    );

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'object_id is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                             l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'object_id is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- object_id is non-updateable
    IF p_create_update_flag = 'U' THEN
      validate_nonupdateable (
        p_column                => 'object_id',
        p_column_value          => p_relationship_rec.object_id,
        p_old_column_value      => l_object_id,
        x_return_status         => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'object_id is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                               l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'object_id is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
     END IF;

    END IF;
  END IF;

    -- check whether object_id belongs to object_type
    IF p_relationship_rec.object_id IS NOT NULL
       AND p_relationship_rec.object_id <> fnd_api.g_miss_num
       AND p_create_update_flag = 'C'
    THEN
      l_in := hz_relationship_type_v2pub.in_instance_sets (
                p_relationship_rec.object_type,
                p_relationship_rec.object_id
              );

      IF l_in = 'N' THEN
        fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
        fnd_message.set_token('FK', 'object_id');
        fnd_message.set_token('COLUMN',
                              LOWER(p_relationship_rec.object_type)||' id');
        fnd_message.set_token('TABLE', p_relationship_rec.object_table_name);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'object_id belongs to object_type. ' ||
                                 'x_return_status = ' || x_return_status,
                               l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'object_id belongs to object_type. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -----------------------------
    -- validate object_table_name
    -----------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- object_table_name is mandatory
    validate_mandatory (
      p_create_update_flag      => p_create_update_flag,
      p_column                  => 'object_table_name',
      p_column_value            => p_relationship_rec.object_table_name,
      x_return_status           => x_return_status
    );

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'object_table_name is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                             l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'object_table_name is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- object_table_name is non-updateable
    IF p_create_update_flag = 'U' THEN
      validate_nonupdateable (
        p_column                => 'object_table_name',
        p_column_value          => p_relationship_rec.object_table_name,
        p_old_column_value      => l_object_table_name,
        x_return_status         => x_return_status
      );

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'object_table_name is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                               l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'object_table_name is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -- object_table_name has foreign key fnd_objects.obj_name
    -- do not need to check during update because object_table_name is
    -- non-updateable.
    IF p_create_update_flag = 'C'
       AND p_relationship_rec.object_table_name IS NOT NULL
       AND p_relationship_rec.object_table_name <> fnd_api.g_miss_char
    THEN
      BEGIN
        SELECT 'Y'
        INTO   l_dummy
        FROM   fnd_objects fo
        WHERE  fo.obj_name = p_relationship_rec.object_table_name;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'object_table_name');
          fnd_message.set_token('COLUMN', 'obj_name');
          fnd_message.set_token('TABLE', 'fnd_objects');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'object_table_name has foreign key fnd_objects.obj_name. ' ||
            'x_return_status = ' || x_return_status,
          l_debug_prefix
        );
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'object_table_name has foreign key fnd_objects.obj_name. ' ||
            'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;
  END IF;

    -----------------------
    -- validate object_type
    -----------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- object_type is mandatory
    validate_mandatory (
      p_create_update_flag      => p_create_update_flag,
      p_column                  => 'object_type',
      p_column_value            => p_relationship_rec.object_type,
      x_return_status           => x_return_status
    );

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'object_type is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                             l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'object_type is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- object_type is non-updateable
    IF p_create_update_flag = 'U' THEN
      validate_nonupdateable (
        p_column                => 'object_type',
        p_column_value          => p_relationship_rec.object_type,
        p_old_column_value      => l_object_type,
        x_return_status         => x_return_status
      );

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'object_type is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                               l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'object_type is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -- object_type has foreign key fnd_object_instance_sets.instance_set_name
    -- do not need to check during update because object_type is
    -- non-updateable.
    IF p_create_update_flag = 'C'
       AND p_relationship_rec.object_type IS NOT NULL
       AND p_relationship_rec.object_type <> fnd_api.g_miss_char
    THEN
      BEGIN
        SELECT 'Y'
        INTO   l_dummy
        FROM   fnd_object_instance_sets fois
        WHERE  fois.instance_set_name = p_relationship_rec.object_type;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'object_type');
          fnd_message.set_token('COLUMN', 'instance_set_name');
          fnd_message.set_token('TABLE', 'fnd_object_instance_sets');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'object_type has foreign key fnd_object_instance_sets.instance_set_name. ' ||
            'x_return_status = ' || x_return_status,
          l_debug_prefix
        );
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'object_type has foreign key fnd_object_instance_sets.instance_set_name. ' ||
            'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;
  END IF;

    ----------------------
    -- validate start_date
    ----------------------
/* The start_date is defaulted in table handler for bug # 2260303
   Hence removed the mandatory check for start_date

    -- start_date is mandatory
    validate_mandatory (
      p_create_update_flag      => p_create_update_flag,
      p_column                  => 'start_date',
      p_column_value            => p_relationship_rec.start_date,
      x_return_status           => x_return_status
    );

    IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'start_date is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
                             l_debug_prefix);
    END IF;
*/
    -- start_date cannot be set to null during update

    IF p_create_update_flag = 'U' THEN
      validate_cannot_update_to_null (
        p_column              => 'start_date',
        p_column_value        => p_relationship_rec.start_date,
        x_return_status       => x_return_status
      );

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'start_date cannot be set to null during update. ' ||
            'x_return_status = ' || x_return_status,
          l_debug_prefix
        );
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'start_date cannot be set to null during update. ' ||
            'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    --------------------
    -- validate party_id
    --------------------

    -- party_id is non-updateable
    IF p_create_update_flag = 'U' THEN
      validate_nonupdateable (
        p_column                => 'party_id',
        p_column_value          => p_relationship_rec.party_rec.party_id,
        p_old_column_value      => l_party_id,
        x_return_status         => x_return_status);

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,'party_id is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                               l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
     END IF;

    END IF;

    ------------------
    -- validate status
    ------------------

    -- status cannot be set to null during update
    IF p_create_update_flag = 'U' THEN
      validate_cannot_update_to_null (
        p_column                                => 'status',
        p_column_value                          => p_relationship_rec.status,
        x_return_status                         => x_return_status
      );

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'status cannot be set to null during update. ' ||
            'x_return_status = ' || x_return_status,
          l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'status cannot be set to null during update. ' ||
            'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    END IF;

/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- status is lookup code in lookup type REGISTRY_STATUS
    IF p_relationship_rec.status IS NOT NULL
       AND p_relationship_rec.status <> fnd_api.g_miss_char
       AND (p_create_update_flag = 'C'
            OR (p_create_update_flag = 'U'
                AND p_relationship_rec.status <> NVL(l_status,
                                                     fnd_api.g_miss_char)))
    THEN
      validate_lookup (
        p_column                                => 'status',
        p_lookup_type                           => 'REGISTRY_STATUS',
        p_column_value                          => p_relationship_rec.status,
        x_return_status                         => x_return_status
      );

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          'status is lookup code in lookup type REGISTRY_STATUS. ' ||
            'x_return_status = ' || x_return_status,
        l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
            'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    END IF;
  END IF;

    /* Bug 2197181: removed content_source_type validation as this
       column has been obsoleted  for mix-n-match project.

    ----------------------------------------------
    -- validate content_source_type
    ----------------------------------------------

    -- do not need to chack content_source_type is mandatory because
    -- we default content_source_type to
    -- hz_party_v2pub.g_miss_content_source_type in the table handler.

    -- content_source_type is non-updateable
    IF p_create_update_flag = 'U' THEN
      validate_nonupdateable (
        p_column                => 'content_source_type',
        p_column_value          => p_relationship_rec.content_source_type,
        p_old_column_value      => l_content_source_type,
        x_return_status         => x_return_status
      );


      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'content_source_type is non-updateable. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    END IF;

    -- content_source_type is lookup code in lookup type CONTENT_SOURCE_TYPE
    validate_lookup (
      p_column                  => 'content_source_type',
      p_lookup_type             => 'CONTENT_SOURCE_TYPE',
      p_column_value            => p_relationship_rec.content_source_type,
      x_return_status           => x_return_status
    );

    IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        'content_source_type is lookup code in lookup type CONTENT_SOURCE_TYPE. ' ||
          'x_return_status = ' || x_return_status,
        l_debug_prefix
      );
    END IF;
    */

    -- Bug 2197181: Added validation for mix-n-match

    ----------------------------------------
    -- validate content_source_type and actual_content_source_type
    ----------------------------------------

    HZ_MIXNM_UTILITY.ValidateContentSource (
      p_api_version                       => 'V2',
      p_create_update_flag                => p_create_update_flag,
      p_check_update_privilege            => 'N',
      p_content_source_type               => p_relationship_rec.content_source_type,
      p_old_content_source_type           => l_content_source_type,
      p_actual_content_source             => p_relationship_rec.actual_content_source,
      p_old_actual_content_source         => db_actual_content_source,
      p_entity_name                       => 'HZ_RELATIONSHIPS',
      x_return_status                     => x_return_status );

    ----------------------------------
    -- start_date, end_date validation
    ----------------------------------

    -- end_date must be null or greater than start date
    IF (p_create_update_flag = 'C') THEN
      IF p_relationship_rec.end_date IS NOT NULL AND
         p_relationship_rec.end_date <> fnd_api.g_miss_date AND
         p_relationship_rec.end_date < p_relationship_rec.start_date
      THEN
        fnd_message.set_name('AR', 'HZ_API_START_DATE_GREATER');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
    ELSIF (p_create_update_flag = 'U') THEN
      -- old start_date, end_date has been selected from table
      -- and put into l_start_date, l_end_date

      IF p_relationship_rec.start_date <> fnd_api.g_miss_date THEN
        l_start_date := p_relationship_rec.start_date;
      END IF;

      IF p_relationship_rec.end_date IS NULL
         OR p_relationship_rec.end_date <> fnd_api.g_miss_date
      THEN
        l_end_date := p_relationship_rec.end_date;
      END IF;

      IF l_end_date IS NOT NULL
         AND l_end_date < l_start_date
      THEN
        fnd_message.set_name('AR', 'HZ_API_START_DATE_GREATER');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
    END IF;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        'end_date must be null or greater than start date. ' ||
          'x_return_status = ' || x_return_status,
        l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'end_date must be null or greater than start date. ' ||
          'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    ------------------------
    -- validate date overlap
    ------------------------

    IF p_create_update_flag = 'C' THEN
      db_actual_content_source := p_relationship_rec.actual_content_source;
    END IF;

    -- there should not be any date overlap between two identical relationships

-- Bug 3294936 : check for all records in the cursor for overlap

--    OPEN c1(db_actual_content_source);

    For r1 in c1(db_actual_content_source)
    LOOP
--    FETCH c1 into r1;
--    IF c1%FOUND THEN
      l_overlap := hz_common_pub.is_time_overlap(
                     NVL(p_relationship_rec.start_date,sysdate),
                     p_relationship_rec.end_date,
                     r1.start_date,
                     r1.end_date
                   );
      IF l_overlap = 'Y' THEN
        fnd_message.set_name('AR', 'HZ_RELATIONSHIP_DATE_OVERLAP');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
-- Bug 3294936 : Add exit to come out of loop
        EXIT;
      END IF;
    END LOOP;
--    END IF;
--    CLOSE c1;

    /*IF g_debug THEN
      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
        'there should not be any date overlap between two identical relationships. ' ||
        'x_return_status = ' || x_return_status, l_debug_prefix);
    END IF;
    */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'there should not be any date overlap between two identical relationships. ' ||
        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    --------------------------------------
    -- validate created_by_module
    --------------------------------------

    validate_created_by_module(
      p_create_update_flag     => p_create_update_flag,
      p_created_by_module      => p_relationship_rec.created_by_module,
      p_old_created_by_module  => l_created_by_module,
      x_return_status          => x_return_status);

    --------------------------------------
    -- validate application_id
    --------------------------------------

    validate_application_id(
      p_create_update_flag     => p_create_update_flag,
      p_application_id         => p_relationship_rec.application_id,
      p_old_application_id     => l_application_id,
      x_return_status          => x_return_status);

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_relationship (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  END validate_relationship;

  --
  -- DESCRIPTION
  --     Validates a contact point record (minus EFTs).  Kept for backward
  --     compatibility.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_edi_rec            EDI record.
  --     p_email_rec          Email record.
  --     p_phone_rec          Phone record.
  --     p_telex_rec          Telex record.
  --     p_web_rec            Web record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Jianying Huang      o Created.
  --   20-NOV-2001   Joe del Callar      Bug 2116225: Modified to accept EFT
  --                                     records for bank consolidation.
  --                                     Bug 2117973: Modified to comply with
  --                                     PL/SQL coding standards.
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Modified to use generic
  --                                     validation procedure for improved
  --                                     backward compatibility.
  --
  PROCEDURE validate_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec             IN     hz_contact_point_v2pub.edi_rec_type := hz_contact_point_v2pub.g_miss_edi_rec,
    p_email_rec           IN     hz_contact_point_v2pub.email_rec_type := hz_contact_point_v2pub.g_miss_email_rec,
    p_phone_rec           IN     hz_contact_point_v2pub.phone_rec_type := hz_contact_point_v2pub.g_miss_phone_rec,
    p_telex_rec           IN     hz_contact_point_v2pub.telex_rec_type := hz_contact_point_v2pub.g_miss_telex_rec,
    p_web_rec             IN     hz_contact_point_v2pub.web_rec_type := hz_contact_point_v2pub.g_miss_web_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_contact_point (+)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_contact_point (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    validate_contact_point_main(
      p_create_update_flag => p_create_update_flag,
      p_contact_point_rec  => p_contact_point_rec,
      p_edi_rec            => p_edi_rec,
      p_email_rec          => p_email_rec,
      p_phone_rec          => p_phone_rec,
      p_telex_rec          => p_telex_rec,
      p_web_rec            => p_web_rec,
      p_rowid              => p_rowid,
      x_return_status      => x_return_status
    );

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_contact_point (-)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_contact_point (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;
  END validate_contact_point;

  --
  -- DESCRIPTION
  --     Validates an EDI contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_edi_rec            EDI record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_edi_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec             IN     hz_contact_point_v2pub.edi_rec_type := hz_contact_point_v2pub.g_miss_edi_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_edi_contact_point (+)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_edi_contact_point (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    validate_contact_point_main(
      p_create_update_flag => p_create_update_flag,
      p_contact_point_rec  => p_contact_point_rec,
      p_edi_rec            => p_edi_rec,
      p_rowid              => p_rowid,
      x_return_status      => x_return_status
    );

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_edi_contact_point (-)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_edi_contact_point (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;
  END validate_edi_contact_point;

  --
  -- DESCRIPTION
  --     Validates an EFT contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_eft_rec            EFT record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_eft_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_eft_rec             IN     hz_contact_point_v2pub.eft_rec_type := hz_contact_point_v2pub.g_miss_eft_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_eft_contact_point (+)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_eft_contact_point (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    validate_contact_point_main(
      p_create_update_flag => p_create_update_flag,
      p_contact_point_rec  => p_contact_point_rec,
      p_eft_rec            => p_eft_rec,
      p_rowid              => p_rowid,
      x_return_status      => x_return_status
    );

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_eft_contact_point (-)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_eft_contact_point (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;
  END validate_eft_contact_point;

  --
  -- DESCRIPTION
  --     Validates an Web contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_web_rec            Web record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_web_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_web_rec             IN     hz_contact_point_v2pub.web_rec_type := hz_contact_point_v2pub.g_miss_web_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_web_contact_point (+)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_web_contact_point (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    validate_contact_point_main(
      p_create_update_flag => p_create_update_flag,
      p_contact_point_rec  => p_contact_point_rec,
      p_web_rec            => p_web_rec,
      p_rowid              => p_rowid,
      x_return_status      => x_return_status
    );

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_web_contact_point (-)');
    END IF;
    */


    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_web_contact_point (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;
  END validate_web_contact_point;

  --
  -- DESCRIPTION
  --     Validates an Phone contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_phone_rec          Phone record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_phone_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_phone_rec           IN     hz_contact_point_v2pub.phone_rec_type := hz_contact_point_v2pub.g_miss_phone_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.

    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_phone_contact_point (+)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_phone_contact_point (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    validate_contact_point_main(
      p_create_update_flag => p_create_update_flag,
      p_contact_point_rec  => p_contact_point_rec,
      p_phone_rec          => p_phone_rec,
      p_rowid              => p_rowid,
      x_return_status      => x_return_status
    );

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_phone_contact_point (-)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_phone_contact_point (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;
  END validate_phone_contact_point;

  --
  -- DESCRIPTION
  --     Validates an Telex contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_telex_rec          Telex record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_telex_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_telex_rec           IN     hz_contact_point_v2pub.telex_rec_type := hz_contact_point_v2pub.g_miss_telex_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_telex_contact_point (+)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_telex_contact_point (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    validate_contact_point_main(
      p_create_update_flag => p_create_update_flag,
      p_contact_point_rec  => p_contact_point_rec,
      p_telex_rec          => p_telex_rec,
      p_rowid              => p_rowid,
      x_return_status      => x_return_status
    );

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_telex_contact_point (-)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_telex_contact_point (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;
  END validate_telex_contact_point;

  --
  -- DESCRIPTION
  --     Validates an Email contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_email_rec          Email record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_email_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_email_rec           IN     hz_contact_point_v2pub.email_rec_type := hz_contact_point_v2pub.g_miss_email_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_email_contact_point (+)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_email_contact_point (+)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    validate_contact_point_main(
      p_create_update_flag => p_create_update_flag,
      p_contact_point_rec  => p_contact_point_rec,
      p_email_rec          => p_email_rec,
      p_rowid              => p_rowid,
      x_return_status      => x_return_status
    );

    -- Debug info.
    /*IF g_debug THEN
      hz_utility_v2pub.debug ('validate_email_contact_point (-)');
    END IF;
    */
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_email_contact_point (-)',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;
  END validate_email_contact_point;

  PROCEDURE  validate_org_nonsupport_column (
    p_create_update_flag                    IN     VARCHAR2,
    p_organization_rec                      IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    x_return_status                         IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
        -- Debug info.
       /* IF G_DEBUG THEN
            HZ_UTILITY_V2PUB.debug ( 'validate_org_nonsupport_column (+)' );
        END IF;
        */
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_org_nonsupport_column (+)',
                               p_msg_level=>fnd_log.level_procedure);
        END IF;


        IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.avg_high_credit IS NOT NULL AND
                 p_organization_rec.avg_high_credit <> FND_API.G_MISS_NUM )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.avg_high_credit = FND_API.G_MISS_NUM OR
                   p_organization_rec.avg_high_credit IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'avg_high_credit' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score IS NOT NULL AND
                 p_organization_rec.credit_score <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score = FND_API.G_MISS_CHAR OR
                   p_organization_rec.credit_score IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_age IS NOT NULL AND
                 p_organization_rec.credit_score_age <> FND_API.G_MISS_NUM )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_age = FND_API.G_MISS_NUM  OR
                   p_organization_rec.credit_score_age IS NOT  NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_age' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_class IS NOT NULL AND
                 p_organization_rec.credit_score_class <> FND_API.G_MISS_NUM )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_class = FND_API.G_MISS_NUM  OR
                   p_organization_rec.credit_score_class IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_class' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_commentary IS NOT NULL AND
                 p_organization_rec.credit_score_commentary <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_commentary = FND_API.G_MISS_CHAR OR
                   p_organization_rec.credit_score_commentary IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_commentary' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_commentary2 IS NOT NULL AND
                 p_organization_rec.credit_score_commentary2 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_commentary2 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.credit_score_commentary2 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_commentary2' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_commentary3 IS NOT NULL AND
                 p_organization_rec.credit_score_commentary3 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_commentary3 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.credit_score_commentary3 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_commentary3' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_commentary4 IS NOT NULL AND
                 p_organization_rec.credit_score_commentary4 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_commentary4 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.credit_score_commentary4 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_commentary4' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_commentary5 IS NOT NULL AND
                 p_organization_rec.credit_score_commentary5 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_commentary5 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.credit_score_commentary5 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_commentary5' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_commentary6 IS NOT NULL AND
                 p_organization_rec.credit_score_commentary6 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_commentary6 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.credit_score_commentary6 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_commentary6' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_commentary7 IS NOT NULL AND
                 p_organization_rec.credit_score_commentary7 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_commentary7 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.credit_score_commentary7 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_commentary7' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_commentary8 IS NOT NULL AND
                 p_organization_rec.credit_score_commentary8 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_commentary8 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.credit_score_commentary8 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_commentary8' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_commentary9 IS NOT NULL AND
                 p_organization_rec.credit_score_commentary9 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_commentary9 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.credit_score_commentary9 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_commentary9' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_commentary10 IS NOT NULL AND
                 p_organization_rec.credit_score_commentary10 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_commentary10 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.credit_score_commentary10 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_commentary10' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_date IS NOT NULL AND
                 p_organization_rec.credit_score_date <> FND_API.G_MISS_DATE )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_date = FND_API.G_MISS_DATE OR
                   p_organization_rec.credit_score_date IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_date' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_incd_default IS NOT NULL AND
                 p_organization_rec.credit_score_incd_default <> FND_API.G_MISS_NUM )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_incd_default =  FND_API.G_MISS_NUM  OR
                   p_organization_rec.credit_score_incd_default IS NOT  NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_incd_default' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.credit_score_natl_percentile IS NOT NULL AND
                 p_organization_rec.credit_score_natl_percentile <> FND_API.G_MISS_NUM)
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.credit_score_natl_percentile = FND_API.G_MISS_NUM  OR
                   p_organization_rec.credit_score_natl_percentile IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_score_natl_percentile' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.db_rating IS NOT NULL AND
                 p_organization_rec.db_rating <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.db_rating = FND_API.G_MISS_CHAR OR
                   p_organization_rec.db_rating IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'db_rating' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.debarment_ind IS NOT NULL AND
                 p_organization_rec.debarment_ind <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.debarment_ind = FND_API.G_MISS_CHAR OR
                   p_organization_rec.debarment_ind IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'debarment_ind' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.debarments_count IS NOT NULL AND
                 p_organization_rec.debarments_count <> FND_API.G_MISS_NUM )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.debarments_count = FND_API.G_MISS_NUM  OR
                   p_organization_rec.debarments_count IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'debarments_count' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.debarments_date IS NOT NULL AND
                 p_organization_rec.debarments_date <> FND_API.G_MISS_DATE )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.debarments_date = FND_API.G_MISS_DATE OR
                   p_organization_rec.debarments_date IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'debarments_date' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.high_credit IS NOT NULL AND
                 p_organization_rec.high_credit <> FND_API.G_MISS_NUM )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.high_credit = FND_API.G_MISS_NUM  OR
                   p_organization_rec.high_credit IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'high_credit' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.maximum_credit_currency_code IS NOT NULL AND
                 p_organization_rec.maximum_credit_currency_code <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.maximum_credit_currency_code = FND_API.G_MISS_CHAR OR
                   p_organization_rec.maximum_credit_currency_code IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'maximum_credit_currency_code' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.maximum_credit_recommendation IS NOT NULL AND
                 p_organization_rec.maximum_credit_recommendation <> FND_API.G_MISS_NUM)
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.maximum_credit_recommendation = FND_API.G_MISS_NUM  OR
                   p_organization_rec.maximum_credit_recommendation IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'maximum_credit_recommendation' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.paydex_norm IS NOT NULL AND
                 p_organization_rec.paydex_norm <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.paydex_norm = FND_API.G_MISS_CHAR OR
                   p_organization_rec.paydex_norm IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'paydex_norm' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.paydex_score IS NOT NULL AND
                 p_organization_rec.paydex_score <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.paydex_score = FND_API.G_MISS_CHAR OR
                   p_organization_rec.paydex_score IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'paydex_score' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.paydex_three_months_ago IS NOT NULL AND
                 p_organization_rec.paydex_three_months_ago <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.paydex_three_months_ago = FND_API.G_MISS_CHAR OR
                   p_organization_rec.paydex_three_months_ago IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'paydex_three_months_ago' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score IS NOT NULL AND
                 p_organization_rec.failure_score <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score = FND_API.G_MISS_CHAR OR
                   p_organization_rec.failure_score IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_age IS NOT NULL AND
                 p_organization_rec.failure_score_age <> FND_API.G_MISS_NUM )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_age = FND_API.G_MISS_NUM  OR
                   p_organization_rec.failure_score_age IS NOT  NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_age' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_class IS NOT NULL AND
                 p_organization_rec.failure_score_class <> FND_API.G_MISS_NUM )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_class = FND_API.G_MISS_NUM  OR
                   p_organization_rec.failure_score_class IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_class' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_commentary IS NOT NULL AND
                 p_organization_rec.failure_score_commentary <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_commentary = FND_API.G_MISS_CHAR OR
                   p_organization_rec.failure_score_commentary IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_commentary' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_commentary2 IS NOT NULL AND
                 p_organization_rec.failure_score_commentary2 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_commentary2 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.failure_score_commentary2 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_commentary2' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_commentary3 IS NOT NULL AND
                 p_organization_rec.failure_score_commentary3 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_commentary3 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.failure_score_commentary3 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_commentary3' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_commentary4 IS NOT NULL AND
                 p_organization_rec.failure_score_commentary4 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_commentary4 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.failure_score_commentary4 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_commentary4' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_commentary5 IS NOT NULL AND
                 p_organization_rec.failure_score_commentary5 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_commentary5 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.failure_score_commentary5 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_commentary5' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_commentary6 IS NOT NULL AND
                 p_organization_rec.failure_score_commentary6 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_commentary6 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.failure_score_commentary6 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_commentary6' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_commentary7 IS NOT NULL AND
                 p_organization_rec.failure_score_commentary7 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_commentary7 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.failure_score_commentary7 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_commentary7' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_commentary8 IS NOT NULL AND
                 p_organization_rec.failure_score_commentary8 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_commentary8 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.failure_score_commentary8 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_commentary8' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_commentary9 IS NOT NULL AND
                 p_organization_rec.failure_score_commentary9 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_commentary9 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.failure_score_commentary9 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_commentary9' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_commentary10 IS NOT NULL AND
                 p_organization_rec.failure_score_commentary10 <> FND_API.G_MISS_CHAR )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_commentary10 = FND_API.G_MISS_CHAR OR
                   p_organization_rec.failure_score_commentary10 IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_commentary10' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_date IS NOT NULL AND
                 p_organization_rec.failure_score_date <> FND_API.G_MISS_DATE )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_date = FND_API.G_MISS_DATE OR
                   p_organization_rec.failure_score_date IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_date' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_incd_default IS NOT NULL AND
                 p_organization_rec.failure_score_incd_default <> FND_API.G_MISS_NUM )
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_incd_default =  FND_API.G_MISS_NUM  OR
                   p_organization_rec.failure_score_incd_default IS NOT  NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_incd_default' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_natnl_percentile IS NOT NULL AND
                 p_organization_rec.failure_score_natnl_percentile <> FND_API.G_MISS_NUM)
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_natnl_percentile = FND_API.G_MISS_NUM  OR
                   p_organization_rec.failure_score_natnl_percentile IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_natnl_percentile' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.failure_score_override_code IS NOT NULL AND
                 p_organization_rec.failure_score_override_code <> FND_API.G_MISS_CHAR)
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.failure_score_override_code = FND_API.G_MISS_CHAR  OR
                   p_organization_rec.failure_score_override_code IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'failure_score_override_code' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF ( p_create_update_flag = 'C' AND
                 p_organization_rec.global_failure_score IS NOT NULL AND
                 p_organization_rec.global_failure_score <> FND_API.G_MISS_CHAR)
         OR
               ( p_create_update_flag = 'U' AND
                 ( p_organization_rec.global_failure_score = FND_API.G_MISS_CHAR  OR
                   p_organization_rec.global_failure_score IS NOT NULL
         ) )
            THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_DNB_MOVED_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'global_failure_score' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        -- Debug info.
        /*IF G_DEBUG THEN
            HZ_UTILITY_V2PUB.debug ( 'validate_org_nonsupport_column (-)' );
        END IF;
        */
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_org_nonsupport_column (-)',
                               p_msg_level=>fnd_log.level_procedure);
         END IF;

  END validate_org_nonsupport_column;

   PROCEDURE validate_rel_code (
      p_forward_rel_code                      IN     VARCHAR2,
      p_backward_rel_code                     IN     VARCHAR2,
      p_forward_role                          IN     VARCHAR2,
      p_backward_role                         IN     VARCHAR2,
      x_return_status                         IN OUT NOCOPY VARCHAR2
 ) IS

      l_error1                                 BOOLEAN := FALSE;
      l_error2                                 BOOLEAN := FALSE;

  BEGIN

      IF p_forward_rel_code = p_backward_rel_code THEN
        IF p_forward_role <> p_backward_role THEN
           fnd_message.set_name('AR', 'HZ_INVALID_ROLE1');
           fnd_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      IF p_forward_rel_code <> p_backward_rel_code THEN
        IF p_forward_role = p_backward_role THEN
           fnd_message.set_name('AR', 'HZ_INVALID_ROLE2');
           fnd_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

  END validate_rel_code;

  /**
   * PROCEDURE validate_financial_report
   *
   * DESCRIPTION
   *     Validates financial report record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_financial_report_rec         Financial report record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   29-JAN-2003   Sreedhar Mohan     o Created.
   *   11-MAR-2003   Sreedhar Mohan     o Bug 2829046: Changed the message token values.
   *   10-OCT-2003   Rajib Ranjan Borah o Bug Number 3148753.Commented old validation
   *                                      which did not take care of the case when both
   *                                      issue_period and report_start_date are not
   *                                      provided.Furthermore new validation does the check
   *                                      only if p_create_update_flag='C' as both these
   *                                      fields are non_updateable.
   *   23-MAR-2004   Rajib Ranjan Borah o Bug 3456205.Validation for party_id being a foreing
   *                                      key of HZ_PARTIES and party_type should be
   *                                      'ORGANIZATION', are performed using a single cursor now.
   *                                    o Validation on report_start_date, report_end_date,
   *                                      party_id will be performed only during creation as these
   *                                      are non-updateable columns.
   *                                    o Removed unused local variables.
   *   01-APR-2004   Rajib Ranjan Borah o Bug 3539597.Commented out changes incorporated in fix
   *                                      3200870. Issued_period and report_start_date cannot be
   *                                      both null or not null. Fix 3200870 had added
   *                                      date_report_issued to the list of attributes which cannot
   *                                      be NULL at the same time.
   *                                    o Modified cursor c_unique_financial_report_rec as it used
   *                                      fail earlier when issued_period was null.Truncated the
   *                                      date parameters.
   *  01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
   *                                      Actual_content_source will be validated against HZ_ORIG_SYSTEMS_B
   *                                      in HZ_MIXNM_UTILITY.ValidateContentSource instead of
   *                                      being validated against lookup OCNTENT_SOURCE_TYPE.
   */

  PROCEDURE validate_financial_report(
      p_create_update_flag                    IN      VARCHAR2,
      p_financial_report_rec                  IN      HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE,
      p_rowid                                 IN      ROWID,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

     CURSOR c_dup_financial_report_id (p_financial_report_id IN NUMBER) IS
      SELECT 'Y'
      FROM   hz_financial_reports hfr
      WHERE  hfr.financial_report_id = p_financial_report_id;

     CURSOR c_unique_financial_report_rec ( p_party_id IN NUMBER,
                                            p_type_of_financial_report IN VARCHAR2,
                                            p_document_reference IN VARCHAR2,
                                            p_date_report_issued IN DATE,
                                            p_issued_period IN VARCHAR2,
                                            p_report_start_date IN DATE,
                                            p_report_end_date IN DATE,
                                            p_actual_content_source IN VARCHAR2) IS
      SELECT 'Y'
      FROM   hz_financial_reports
      WHERE  party_id = p_party_id
      AND    nvl(type_of_financial_report, 'XXX') = nvl(p_type_of_financial_report, 'XXX')
      AND    nvl(document_reference, 'XXX') = nvl(p_document_reference, 'XXX')
      AND    actual_content_source = nvl(p_actual_content_source,'USER_ENTERED')
      AND    trunc(nvl(date_report_issued, to_date('12/31/4712','MM/DD/YYYY'))) =
             trunc(nvl(p_date_report_issued, to_date('12/31/4712','MM/DD/YYYY')))
      AND    nvl(issued_period, to_date('12/31/4712','MM/DD/YYYY')) =
             nvl( p_issued_period, to_date('12/31/4712','MM/DD/YYYY'))
      AND    trunc(nvl(report_start_date, to_date('12/31/4712','MM/DD/YYYY'))) =
             trunc(nvl(p_report_start_date, to_date('12/31/4712','MM/DD/YYYY')))
      AND    trunc(nvl(report_end_date, to_date('12/31/4712','MM/DD/YYYY'))) =
             trunc(nvl(p_report_end_date, to_date('12/31/4712','MM/DD/YYYY')))
             ;

      CURSOR c_partytype IS
        SELECT hp.party_type
        FROM   hz_parties hp
        WHERE  hp.party_id = p_financial_report_rec.party_id;

      l_party_type                            VARCHAR2(30);
      l_financial_report_id                   hz_financial_reports.financial_report_id%TYPE;
      l_document_reference                    hz_financial_reports.document_reference%TYPE;
      l_date_report_issued                    hz_financial_reports.date_report_issued%TYPE;
      l_issued_period                         hz_financial_reports.issued_period%TYPE;
      l_party_id                              hz_financial_reports.party_id%TYPE;
--      l_requiring_authority                   hz_financial_reports.requiring_authority%TYPE;
      l_type_of_financial_report              hz_financial_reports.type_of_financial_report%TYPE;
      l_report_start_date                     hz_financial_reports.report_start_date%TYPE;
      l_report_end_date                       hz_financial_reports.report_end_date%TYPE;
--      l_audit_ind                             hz_financial_reports.audit_ind%TYPE;
--      l_consolidated_ind                      hz_financial_reports.consolidated_ind%TYPE;
--      l_estimated_ind                         hz_financial_reports.estimated_ind%TYPE;
--      l_fiscal_ind                            hz_financial_reports.fiscal_ind%TYPE;
--      l_final_ind                             hz_financial_reports.final_ind%TYPE;
--      l_forecast_ind                          hz_financial_reports.forecast_ind%TYPE;
--      l_opening_ind                           hz_financial_reports.opening_ind%TYPE;
--      l_proforma_ind                          hz_financial_reports.proforma_ind%TYPE;
--      l_qualified_ind                         hz_financial_reports.qualified_ind%TYPE;
--      l_restated_ind                          hz_financial_reports.restated_ind%TYPE;
--      l_signed_by_principals_ind              hz_financial_reports.signed_by_principals_ind%TYPE;
--      l_trial_balance_ind                     hz_financial_reports.trial_balance_ind%TYPE;
--      l_unbalanced_ind                        hz_financial_reports.unbalanced_ind%TYPE;
      l_content_source_type                   hz_financial_reports.content_source_type%TYPE;
      l_actual_content_source                 hz_financial_reports.actual_content_source%TYPE;
--      l_request_id                            hz_financial_reports.request_id%TYPE;
      l_status                                hz_financial_reports.status%TYPE;
      l_created_by_module                     hz_financial_reports.created_by_module%TYPE;

--      l_temp_issued_period                    hz_financial_reports.issued_period%TYPE;
--      l_temp_report_start_date                hz_financial_reports.report_start_date%TYPE;
--      l_temp_report_end_date                  hz_financial_reports.report_end_date%TYPE;
      l_dummy                                 VARCHAR2(1);
      l_debug_prefix                          VARCHAR2(30) := '';

  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_financial_report (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_financial_report (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


      -- do the query to get old values for update

      -- Bug 3456205. Some of the local variables populated by this select statement were not
      -- used at all and have been commented out.

      IF p_create_update_flag = 'U'
      THEN
          SELECT FINANCIAL_REPORT_ID,
                 PARTY_ID,
                 DOCUMENT_REFERENCE,
                 DATE_REPORT_ISSUED,
                 ISSUED_PERIOD,
               --  REQUIRING_AUTHORITY,
                 TYPE_OF_FINANCIAL_REPORT,
                 REPORT_START_DATE,
                 REPORT_END_DATE,
               --  AUDIT_IND,
               --  CONSOLIDATED_IND,
               --  ESTIMATED_IND,
               --  FISCAL_IND,
               --  FINAL_IND,
               --  FORECAST_IND,
               --  OPENING_IND,
               --  PROFORMA_IND,
               --  QUALIFIED_IND,
               --  RESTATED_IND,
               --  SIGNED_BY_PRINCIPALS_IND,
               --  TRIAL_BALANCE_IND,
               --  UNBALANCED_IND,
                 CONTENT_SOURCE_TYPE,
                 ACTUAL_CONTENT_SOURCE,
               --  REQUEST_ID,
                 STATUS,
                 CREATED_BY_MODULE
          INTO   l_financial_report_id,
                 l_party_id,
                 l_document_reference,
                 l_date_report_issued,
                 l_issued_period,
               --  l_requiring_authority,
                 l_type_of_financial_report,
                 l_report_start_date,
                 l_report_end_date,
               --  l_audit_ind,
               --  l_consolidated_ind,
               --  l_estimated_ind,
               --  l_fiscal_ind,
               --  l_final_ind,
               --  l_forecast_ind,
               --  l_opening_ind,
               --  l_proforma_ind,
               --  l_qualified_ind,
               --  l_restated_ind,
               --  l_signed_by_principals_ind,
               --  l_trial_balance_ind,
               --  l_unbalanced_ind,
                 l_content_source_type,
                 l_actual_content_source,
               --  l_request_id,
                 l_status,
                 l_created_by_module
          FROM   HZ_FINANCIAL_REPORTS
          WHERE  ROWID = p_rowid;
      END IF;

      -------------------------------------
      -- validation for financial_report_id
      -------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      --check for unique financial_report_id
      IF p_create_update_flag = 'C' THEN
        IF p_financial_report_rec.financial_report_id IS NOT NULL AND
           p_financial_report_rec.financial_report_id <> fnd_api.g_miss_num
        THEN
          OPEN c_dup_financial_report_id (p_financial_report_rec.financial_report_id);
          FETCH c_dup_financial_report_id INTO l_dummy;

          -- key is not unique, push an error onto the stack.
          IF NVL(c_dup_financial_report_id%FOUND, FALSE) THEN
            fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
            fnd_message.set_token('COLUMN', 'financial_report_id');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
          END IF;
          CLOSE c_dup_financial_report_id;

          /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'check that financial_report_id is unique during creation. ' ||
              ' x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'check that financial_report_id is unique during creation. ' ||
                                    ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


        END IF;
      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          '(+) after validate financial_report_id ... ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate financial_report_id ... ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      -- financial_report_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'financial_report_id',
              p_column_value                          => p_financial_report_rec.financial_report_id,
              p_old_column_value                      => l_financial_report_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'financial_report_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'financial_report_id is non-updateable field. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;
  END IF;

      --------------------------
      -- validation for party_id
      --------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- party_id is mandatory field
      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'party_id',
              p_column_value                          => p_financial_report_rec.party_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id is mandatory field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is mandatory field. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

      -- party_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'party_id',
              p_column_value                          => p_financial_report_rec.party_id,
              p_old_column_value                      => l_party_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is non-updateable field. ' ||
                                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;
/*
      -- party_id has foreign key HZ_PARTIES.PARTY_ID
      IF p_create_update_flag = 'C'
         AND
         p_financial_report_rec.party_id IS NOT NULL
         AND
         p_financial_report_rec.party_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   hz_parties p
              WHERE  p.party_id = p_financial_report_rec.party_id;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'party_id');
                  fnd_message.set_token('COLUMN', 'party_id');
                  fnd_message.set_token('TABLE', 'hz_parties');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;
*/
          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id has foreign key hz_parties.party_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
/*          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id has foreign key hz_parties.party_id. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;
*/
      -- make sure that the l_party_id belongs to an organization.
      IF p_create_update_flag = 'C'
        /* Bug 3456205 Party_id is not updateable.
         OR
         p_create_update_flag = 'U'
         If the value is NULL / G_MISS, error should be thrown in validate_mandatory only.
         */
         AND p_financial_report_rec.party_id IS NOT NULL
         AND p_financial_report_rec.party_id <> FND_API.G_MISS_NUM
      THEN
          --Bug 2886268: Added the following code instead of calling check_organization
          OPEN c_partytype;

          FETCH c_partytype INTO l_party_type;
          IF c_partytype%FOUND
          THEN
              IF rtrim(ltrim(l_party_type)) <> 'ORGANIZATION'
              THEN
                  -- This is not an organization. Hence throw error
                  fnd_message.set_name('AR', 'HZ_API_INVALID_PARTY_TYPE');
                  fnd_message.set_token('PARTY_ID', TO_CHAR(p_financial_report_rec.party_id));
                  fnd_message.set_token('TYPE', 'ORGANIZATION');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
              END IF;
          ELSE -- 3456205
              -- party_id has foreign key HZ_PARTIES.PARTY_ID
              -- However since no record found in HZ_PARTIES, therefore throw error.
              fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
              fnd_message.set_token('FK', 'party_id');
              fnd_message.set_token('COLUMN', 'party_id');
              fnd_message.set_token('TABLE', 'hz_parties');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
          END IF;
          CLOSE c_partytype;
          --Bug 2886268: Commented out the following call as it is throwing erroneous message
          --check_organization(p_financial_report_rec.party_id, x_return_status);
      END IF;
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id has foreign key hz_parties.party_id. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      -------------------------------
      -- validation for issued_period
      -------------------------------
      --Either issued_period or report_start_date must be provided (not both).
      --Added database values when passed with null values

      --Bug Number 3148753.Commented the validation code as it only checked for the case
      --when both the values are set.
      --There is no validation for the case when both the values are not provided.

      --Furthermore as both the fields are non-updateable, therefore it is enough to check
      --during creation that only one of the fields is being provided.

      /*
      |IF ((nvl(p_financial_report_rec.issued_period, l_issued_period) IS NOT NULL AND
      |     nvl(p_financial_report_rec.issued_period, l_issued_period) <> fnd_api.g_miss_char) AND
      |    (nvl(p_financial_report_rec.report_start_date, l_report_start_date) IS NOT NULL AND
      |    nvl(p_financial_report_rec.report_start_date, l_report_start_date) <> fnd_api.g_miss_date))
      |THEN
      |   fnd_message.set_name('AR', 'HZ_API_INVALID_COMBINATION2');
      |   fnd_message.set_token('COLUMN1', 'issued_period');
      |   fnd_message.set_token('COLUMN2', 'report_start_date');
      |   fnd_msg_pub.add;
      |   x_return_status := fnd_api.g_ret_sts_error;
      |END IF;
      */

      --Bug Number 3148753.As both the fields are non-updateable,therefore validation
      --during creation is enough.


      IF(p_create_update_flag='C')
      THEN
        IF (
             (--Both the values are not set during creation.
               (
               p_financial_report_rec.issued_period IS NULL
               OR
               p_financial_report_rec.issued_period = fnd_api.g_miss_char
               )
             AND
               (
               p_financial_report_rec.report_start_date IS NULL
               OR
               p_financial_report_rec.report_start_date = fnd_api.g_miss_date
               )
/*           Bug 3539597.Commented out changes incorporated in fix 3200870.
 |           AND
 |             (
 |             p_financial_report_rec.DATE_REPORT_ISSUED IS NULL
 |             OR
 |             p_financial_report_rec.DATE_REPORT_ISSUED = fnd_api.g_miss_date
 |             )
 */
             )
           OR
             (--Both the values are provided during creation
               (
               p_financial_report_rec.issued_period IS NOT NULL
               AND
               p_financial_report_rec.issued_period <> fnd_api.g_miss_char
               )
             AND
               (
               p_financial_report_rec.report_start_date IS NOT NULL
               AND
               p_financial_report_rec.report_start_date <> fnd_api.g_miss_date
               )
             )
           )
        THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_COMBINATION2');
          fnd_message.set_token('COLUMN1', 'issued_period');
          fnd_message.set_token('COLUMN2', 'report_start_date');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
      END IF;

      -----------------------------------
      -- validation for report_start_date
      -----------------------------------

   -- bug 4417943.
   IF p_create_update_flag = 'C' /*Bug 3456205 Both these columns are non-updateable */
   AND  (
         (p_financial_report_rec.report_start_date IS NOT NULL
          AND p_financial_report_rec.report_start_date <> fnd_api.g_miss_date
          AND (p_financial_report_rec.report_end_date IS NULL OR
               p_financial_report_rec.report_end_date = fnd_api.g_miss_date )
          ) OR
          (p_financial_report_rec.report_end_date IS NOT NULL
           AND  p_financial_report_rec.report_end_date <> fnd_api.g_miss_date
           AND (p_financial_report_rec.report_start_date IS NULL OR
                p_financial_report_rec.report_start_date = fnd_api.g_miss_date)
          ))
   THEN
        fnd_message.set_name('AR', 'HZ_API_INVALID_COMBINATION3');
        fnd_message.set_token('COLUMN1', 'report_start_date');
        fnd_message.set_token('COLUMN2', 'report_end_date');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
   END IF;

      --Bug 2888670: Modified the end_date validation as per V1 validation.
      --If report_start_date is provided, then it must be less than or equal
      --to report_end_date.

      IF p_create_update_flag = 'C' THEN
         IF p_financial_report_rec.report_end_date is  NOT NULL  AND
            p_financial_report_rec.report_end_date <> FND_API.G_MISS_DATE  THEN
              if (p_financial_report_rec.report_end_date
                  < p_financial_report_rec.report_start_date
                  )  THEN
                    FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
              end if;
          END IF;
      END IF;

      /* Bug 3456205. As both report_start_date, report_end_date are non-updateable,
        therefore this validation need not be performed during updation.

      -- compare end_date with database data and user passed data.
      ELSIF p_create_update_flag = 'U' THEN
             if (p_financial_report_rec.report_end_date is  NOT NULL  AND
                 p_financial_report_rec.report_end_date <> FND_API.G_MISS_DATE)   THEN
                   if p_financial_report_rec.report_start_date is NOT NULL  AND
                      p_financial_report_rec.report_start_date <> FND_API.G_MISS_DATE  then
                        if p_financial_report_rec.report_end_date
                           < p_financial_report_rec.report_start_date then
                             FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                             FND_MSG_PUB.ADD;
                             x_return_status := FND_API.G_RET_STS_ERROR;

                        end if;
                   elsif ( p_financial_report_rec.report_end_date < l_report_start_date  OR
                           l_report_start_date is NULL) then
                           FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                           FND_MSG_PUB.ADD;
                           x_return_status := FND_API.G_RET_STS_ERROR;

                   end if;
              elsif (p_financial_report_rec.report_start_date is  NOT NULL  AND
                     p_financial_report_rec.report_start_date <> FND_API.G_MISS_DATE)   THEN
                      if l_report_end_date < p_financial_report_rec.report_start_date then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;

                      end if;
              end if;

      END IF;*/

      ---------------------------------------
      --Bug 2868953: Unique record Validation
      ---------------------------------------
      IF p_create_update_flag = 'C' THEN
         OPEN c_unique_financial_report_rec ( p_financial_report_rec.party_id,
                                              p_financial_report_rec.type_of_financial_report,
                                              p_financial_report_rec.document_reference,
                                              p_financial_report_rec.date_report_issued,
                                              p_financial_report_rec.issued_period,
                                              p_financial_report_rec.report_start_date,
                                              p_financial_report_rec.report_end_date,
                                              p_financial_report_rec.actual_content_source);

          FETCH c_unique_financial_report_rec INTO l_dummy;

          -- combination key is not unique, push an error onto the stack.
          IF NVL(c_unique_financial_report_rec%FOUND, FALSE) THEN
            fnd_message.set_name('AR', 'HZ_API_DUP_FIN_REPORT_REC');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
          END IF;
          CLOSE c_unique_financial_report_rec;

          /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'The following column combination should be unique:' ||
              ' PARTY_ID, FINANCIAL_REPORT_TYPE, DOCUMENT_REFERENCE, DATE_REPORT_ISSUED, ' ||
              ' (ISSUED_PERIOD or REPORT_START_DATE and REPORT_END_DATE).' ||
              ' x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'The following column combination should be unique:' ||
                                              ' PARTY_ID, FINANCIAL_REPORT_TYPE, DOCUMENT_REFERENCE, DATE_REPORT_ISSUED, ' ||
                                              ' (ISSUED_PERIOD or REPORT_START_DATE and REPORT_END_DATE).' ||
                                              ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
      -- type_of_financial_report is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'type_of_financial_report',
              p_column_value                          => p_financial_report_rec.type_of_financial_report,
              p_old_column_value                      => l_type_of_financial_report,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'type_of_financial_report is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'type_of_financial_report is non-updateable field. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;
      -- document_reference is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'document_reference',
              p_column_value                          => p_financial_report_rec.document_reference,
              p_old_column_value                      => l_document_reference,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'document_reference is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'document_reference is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;
      -- date_report_issued is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'date_report_issued',
              p_column_value                          => trunc(p_financial_report_rec.date_report_issued),
              p_old_column_value                      => trunc(l_date_report_issued),
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'date_report_issued is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'date_report_issued is non-updateable field. ' ||
                                               'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;
      -- issued_period is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'issued_period',
              p_column_value                          => p_financial_report_rec.issued_period,
              p_old_column_value                      => l_issued_period,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'issued_period is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'issued_period is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;
      -- report_start_date is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'report_start_date',
              p_column_value                          => trunc(p_financial_report_rec.report_start_date),
              p_old_column_value                      => trunc(l_report_start_date),
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'report_start_date is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                  hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'report_start_date is non-updateable field. ' ||
                                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;


      END IF;
      -- report_end_date is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'report_end_date',
              p_column_value                          => trunc(p_financial_report_rec.report_end_date),
              p_old_column_value                      => trunc(l_report_end_date),
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'report_end_date is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'report_end_date is non-updateable field. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;
      ------------------------------------
      --Lookup Validations
      --validation for audit_ind
      ------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- audit_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'audit_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.audit_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'audit_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'audit_ind should be in lookup YES/NO. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ----------------------------------
      -- validation for consolidated_ind
      ----------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- consolidated_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'consolidated_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.consolidated_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'consolidated_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'consolidated_ind should be in lookup YES/NO. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ------------------------------------
      --validation for estimated_ind
      ------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- estimated_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'estimated_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.estimated_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'estimated_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'estimated_ind should be in lookup YES/NO. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;
  END IF;

      ----------------------------------
      -- validation for fiscal_ind
      ----------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- fiscal_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'fiscal_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.fiscal_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'fiscal_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'fiscal_ind should be in lookup YES/NO. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

     --Bug 2940399: Added FINAL_IND column in financial_report_rec_type. Hence
     --added the validation for final_ind.

      ----------------------------------
      -- validation for final_ind
      ----------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- fiscal_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'final_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.final_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'final_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'final_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ------------------------------------
      --validation for forecast_ind
      ------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- forecast_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'forecast_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.forecast_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'forecast_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'forecast_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ----------------------------------
      -- validation for opening_ind
      ----------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- opening_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'opening_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.opening_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'opening_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'opening_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ------------------------------------
      --validation for proforma_ind
      ------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- proforma_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'proforma_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.proforma_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'proforma_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'proforma_ind should be in lookup YES/NO. ' ||
                                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ----------------------------------
      -- validation for qualified_ind
      ----------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- qualified_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'qualified_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.qualified_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'qualified_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'qualified_ind should be in lookup YES/NO. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ------------------------------------
      --validation for restated_ind
      ------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- restated_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'restated_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.restated_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'restated_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'restated_ind should be in lookup YES/NO. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ----------------------------------
      -- validation for signed_by_principals_ind
      ----------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- signed_by_principals_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'signed_by_principals_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.signed_by_principals_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'signed_by_principals_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'signed_by_principals_ind should be in lookup YES/NO. ' ||
                                             'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
     END IF;
  END IF;

      ------------------------------------
      --validation for trial_balance_ind
      ------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- trial_balance_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'trial_balance_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.trial_balance_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'trial_balance_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'trial_balance_ind should be in lookup YES/NO. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ----------------------------------
      -- validation for unbalanced_ind
      ----------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- unbalanced_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'unbalanced_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_financial_report_rec.unbalanced_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'unbalanced_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'unbalanced_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      ------------------------
      -- validation for status
      ------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- status is lookup code in lookup type REGISTRY_STATUS
      IF p_financial_report_rec.status IS NOT NULL
         AND
         p_financial_report_rec.status <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_financial_report_rec.status <> NVL(l_status, fnd_api.g_miss_char)
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'status',
              p_lookup_type                           => 'REGISTRY_STATUS',
              p_column_value                          => p_financial_report_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=> 'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;


      END IF;
  END IF;

      -- status cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          validate_cannot_update_to_null (
              p_column                                => 'status',
              p_column_value                          => p_financial_report_rec.status,
              x_return_status                         => x_return_status);
      END IF;

      --------------------------------
      --validate actual_content_source
      --------------------------------

      -- actual_content_source is mandatory field
      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'actual_content_source',
              p_column_value                          => p_financial_report_rec.actual_content_source,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'actual_content_source is mandatory field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'actual_content_source is mandatory field. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;


      END IF;

    /* SSM SST Integration and Extension
     * actual_content_source is now a foreign key to HZ_ORIG_SYSTEMS_B.orig_system where sst_flag = 'Y'.
      -- actual_content_source is lookup code in lookup type CONTENT_SOURCE_TYPE
      validate_lookup (
          p_column                                => 'actual_content_source',
          p_lookup_type                           => 'CONTENT_SOURCE_TYPE',
          p_column_value                          => p_financial_report_rec.actual_content_source,
          x_return_status                         => x_return_status);
    */
      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'actual_content_source should be in lookup CONTENT_SOURCE_TYPE. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
    /*
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'actual_content_source should be in lookup CONTENT_SOURCE_TYPE. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    */

      HZ_MIXNM_UTILITY.ValidateContentSource (
        p_api_version                       => 'V2',
        p_create_update_flag                => p_create_update_flag,
        p_check_update_privilege            => 'Y',
        p_content_source_type               => 'USER_ENTERED',
        p_old_content_source_type           => 'USER_ENTERED',
        p_actual_content_source             => p_financial_report_rec.actual_content_source,
        p_old_actual_content_source         => l_actual_content_source,
        p_entity_name                       => 'HZ_FINANCIAL_REPORTS',
        x_return_status                     => x_return_status );

      ----------------------------
      --validate created_by_module
      ----------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_financial_report_rec.created_by_module,
        p_old_created_by_module  => l_created_by_module,
        x_return_status          => x_return_status);

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_financial_report (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

  END validate_financial_report;

  /**
   * PROCEDURE validate_financial_number
   *
   * DESCRIPTION
   *     Validates financial number record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_financial_number_rec         Financial number record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   29-JAN-2003   Sreedhar Mohan     o Created.
   *
   */
 --bug 3942332: added out parameter x_actual_content_source
  PROCEDURE validate_financial_number(
      p_create_update_flag                    IN      VARCHAR2,
      p_financial_number_rec                  IN      HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE,
      p_rowid                                 IN      ROWID,
      x_return_status                         IN OUT NOCOPY  VARCHAR2,
      x_actual_content_source                 OUT NOCOPY VARCHAR2
 ) IS

     CURSOR c_dup_financial_number_id (p_financial_report_id IN NUMBER) IS
      SELECT 'Y'
      FROM   hz_financial_numbers hfr
      WHERE  hfr.financial_number_id = financial_number_id;

     CURSOR c_unique_financial_number_rec ( p_financial_report_id IN NUMBER,
                                            p_financial_number_name IN VARCHAR2) IS
      SELECT 'Y'
      FROM   hz_financial_numbers
      WHERE  financial_report_id = p_financial_report_id
      AND    nvl(financial_number_name, 'XXX') = nvl(p_financial_number_name, 'XXX');

      l_financial_number_id                   hz_financial_numbers.financial_number_id%TYPE;
      l_financial_number_name                 hz_financial_numbers.financial_number_name%TYPE;
      l_financial_report_id                   hz_financial_numbers.financial_report_id%TYPE;
      l_status                                hz_financial_numbers.status%TYPE;
      l_created_by_module                     hz_financial_numbers.created_by_module%TYPE;
      l_dummy                                 VARCHAR2(1);
      l_debug_prefix                          VARCHAR2(30) := '';

  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_financial_number (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_financial_number (+)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- do the query to get old values for update
      IF p_create_update_flag = 'U'
      THEN
          SELECT FINANCIAL_NUMBER_ID,
                 FINANCIAL_REPORT_ID,
                 FINANCIAL_NUMBER_NAME,
                 STATUS,
                 CREATED_BY_MODULE
          INTO   l_financial_number_id,
                 l_financial_report_id,
                 l_financial_number_name,
                 l_status,
                 l_created_by_module
          FROM   HZ_FINANCIAL_NUMBERS
          WHERE  ROWID = p_rowid;
      END IF;

      -------------------------------------
      -- validation for financial_number_id
      -------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      --check for unique financial_number_id
      IF p_create_update_flag = 'C' THEN
        IF p_financial_number_rec.financial_number_id IS NOT NULL AND
           p_financial_number_rec.financial_number_id <> fnd_api.g_miss_num
        THEN
          OPEN c_dup_financial_number_id (p_financial_number_rec.financial_number_id);
          FETCH c_dup_financial_number_id INTO l_dummy;

          -- key is not unique, push an error onto the stack.
          IF NVL(c_dup_financial_number_id%FOUND, FALSE) THEN
            fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
            fnd_message.set_token('COLUMN', 'financial_number_id');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
          END IF;
          CLOSE c_dup_financial_number_id;

          /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'check that financial_number_id is unique during creation. ' ||
              ' x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'check that financial_number_id is unique during creation. ' ||
                                        ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;

        END IF;
      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          '(+) after validate financial_number_id ... ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate financial_number_id ... ' ||
          'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

      -- financial_number_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'financial_number_id',
              p_column_value                          => p_financial_number_rec.financial_number_id,
              p_old_column_value                      => l_financial_number_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'financial_number_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'financial_number_id is non-updateable field. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
  END IF;

      -------------------------------------
      -- validation for financial_report_id
      -------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      --Must exist in HZ_FINANCIAL_REPORTS.  Non-updateable.
      -- financial_report_id has foreign key HZ_FINANCIAL_REPORTS.FINANCIAL_REPORT_ID
      IF p_create_update_flag = 'C'
         AND
         p_financial_number_rec.financial_report_id IS NOT NULL
         AND
         p_financial_number_rec.financial_report_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              --bug 3942332: selected actual_content_source from the hz_financial_reports record.
              --SELECT 'Y'
              --INTO l_dummy
              SELECT actual_content_source
              INTO   x_actual_content_source
              FROM   hz_financial_reports hfr
              WHERE  hfr.financial_report_id = p_financial_number_rec.financial_report_id;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'financial_report_id');
                  fnd_message.set_token('COLUMN', 'financial_report_id');
                  fnd_message.set_token('TABLE', 'hz_financial_reports');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'financial_report_id has foreign key hz_financial_reports.financial_report_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
            p_message=>'financial_report_id has foreign key hz_financial_reports.financial_report_id. ' ||
                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- financial_report_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'financial_report_id',
              p_column_value                          => p_financial_number_rec.financial_report_id,
              p_old_column_value                      => l_financial_report_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'financial_report_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'financial_report_id is non-updateable field. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- financial_report_id is mandatory field
      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'financial_report_id',
              p_column_value                          => p_financial_number_rec.financial_report_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'financial_report_id is mandatory field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'financial_report_id is mandatory field. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
  END IF;

      ---------------------------------------
      --Bug 2869162: Unique record Validation
      ---------------------------------------
      IF p_create_update_flag = 'C' THEN
         OPEN c_unique_financial_number_rec ( p_financial_number_rec.financial_report_id,
                                              p_financial_number_rec.financial_number_name);

          FETCH c_unique_financial_number_rec INTO l_dummy;

          -- combination key is not unique, push an error onto the stack.
          IF NVL(c_unique_financial_number_rec%FOUND, FALSE) THEN
            fnd_message.set_name('AR', 'HZ_API_DUP_FIN_NUMBER_REC');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
          END IF;
          CLOSE c_unique_financial_number_rec;

          /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'The following column combination should be unique:' ||
              ' FINANCIAL_REPORT_ID, FINANCIAL_NUMBER_NAME. ' ||
              ' x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'The following column combination should be unique:' ||
                                      ' FINANCIAL_REPORT_ID, FINANCIAL_NUMBER_NAME. ' ||
                                      ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;
      -----------------------------------------
      --financial_number_name in non-updateable
      -----------------------------------------
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'financial_number_name',
              p_column_value                          => p_financial_number_rec.financial_number_name,
              p_old_column_value                      => l_financial_number_name,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'financial_number_name is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                 p_message=>'financial_number_name is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
      ---------------------------------------
      -- validation for financial_number_name
      ---------------------------------------

      -- financial_number_name is lookup code in lookup type FIN_NUM_NAME
      validate_lookup (
          p_column                                => 'financial_number_name',
          p_lookup_type                           => 'FIN_NUM_NAME',
          p_column_value                          => p_financial_number_rec.financial_number_name,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'financial_number_name should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'financial_number_name should be in lookup YES/NO. ' ||
                   'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

      ------------------------
      -- validation for status
      ------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- status is lookup code in lookup type REGISTRY_STATUS
      IF p_financial_number_rec.status IS NOT NULL
         AND
         p_financial_number_rec.status <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_financial_number_rec.status <> NVL(l_status, fnd_api.g_miss_char)
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'status',
              p_lookup_type                           => 'REGISTRY_STATUS',
              p_column_value                          => p_financial_number_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
  END IF;

      -- status cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          validate_cannot_update_to_null (
              p_column                                => 'status',
              p_column_value                          => p_financial_number_rec.status,
              x_return_status                         => x_return_status);
      END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_financial_number_rec.created_by_module,
        p_old_created_by_module  => l_created_by_module,
        x_return_status          => x_return_status);

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_financial_number (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

  END validate_financial_number;

  /**
   * PROCEDURE validate_credit_rating
   *
   * DESCRIPTION
   *     Validates credit rating record. Checks for
   *         uniqueness
   *         lookup types
   *         mandatory columns
   *         non-updateable fields
   *         foreign key validations
   *         other validations
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
   *     p_credit_rating_rec            Credit rating record.
   *     p_rowid                        Rowid of the record (used only in update mode).
   *   IN/OUT:
   *     x_return_status                Return status after the call. The status can
   *                                    be FND_API.G_RET_STS_SUCCESS (success),
   *                                    fnd_api.g_ret_sts_error (error),
   *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   01-27-2003    Sreedhar Mohan     o Created.
   *   03-11-2003    Sreedhar Mohan     Changed the lookup_type to FAILURE_SCORE_OVERRIDE_CODE
   *                                    instead of FAILURE_SCORE_OVERRIDE_SCORE
   *                                    for the code credit_score_override_code
   *   03-14-2003    Sreedhar Mohan     Bug 2843453, modified such that, fincl_embt_ind should
   *                                    be validated against YES/NO instead of REGISTRY_STATUS
   *   10-09-2003    Rajib R Borah    o Bug 3090928.Commented the code to check for uniqueness of
   *                                    party_id,rated_as_of_date,rating_organization. This is now
   *                                    handled by the unique index HZ_CREDIT_RATINGS_U2.
   *   04-05-2004    Rajib R Borah    o Bug 3181460. Credit_score_natl_percentile and
   *                                    failure_score_natnl_percentile should have a value
   *                                    within 0 to 100 only.
   *                                  o Added local variables l_credit_score_natl_percentile and
   *                                    l_fail_score_natnl_percentile for the same.
   *   01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
   *                                      Actual_content_source will now be validated against
   *                                      HZ_ORIG_SYSTEMS_B by calling Hz_MIXNM_UTILITY.ValidateContentSource
   *                                      instead of being validated against lookup CONTENT_SOURCE_TYPE.
   *   01-24-2005    Kalyan           o Bug 3877782. Added the condition to consider 'start_date_active' and
   *                                    'end_date_active'.
   */

  PROCEDURE validate_credit_rating(
      p_create_update_flag                    IN      VARCHAR2,
      p_credit_rating_rec                     IN      HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE,
      p_rowid                                 IN      ROWID,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

     CURSOR c_dup_credit_rating_id (p_credting_rating_id IN NUMBER) IS
      SELECT 'Y'
      FROM   hz_credit_ratings hcr
      WHERE  hcr.credit_rating_id = p_credting_rating_id;

     CURSOR c_unique_credit_rating_rec ( p_party_id IN NUMBER,
                                         p_rated_as_of_date IN DATE,
                                         p_rating_organization IN VARCHAR2,
                                         p_actual_content_source IN VARCHAR2) IS
      SELECT 'Y'
      FROM   hz_credit_ratings hc
      WHERE  hc.party_id = p_party_id
      AND    trunc(nvl(hc.rated_as_of_date, to_date('12/31/4712','MM/DD/YYYY'))) =
             trunc(nvl(p_rated_as_of_date, to_date('12/31/4712','MM/DD/YYYY')))
      AND    nvl(hc.rating_organization, 'XXX') = nvl(p_rating_organization, 'XXX')
      AND    nvl(hc.actual_content_source, hz_party_v2pub.G_MISS_CONTENT_SOURCE_TYPE) =
             nvl(p_actual_content_source, hz_party_v2pub.G_MISS_CONTENT_SOURCE_TYPE);

      l_credit_rating_id                      hz_credit_ratings.credit_rating_id%TYPE;
      l_party_id                              hz_credit_ratings.party_id%TYPE;
      l_rating_organization                   hz_credit_ratings.rating_organization%TYPE;
      l_rated_as_of_date                      hz_credit_ratings.rated_as_of_date%TYPE;
      l_fincl_embt_ind                        hz_credit_ratings.fincl_embt_ind%TYPE;
      l_credit_score_commentary               hz_credit_ratings.credit_score_commentary%TYPE;
      l_credit_score_commentary2              hz_credit_ratings.credit_score_commentary2%TYPE;
      l_credit_score_commentary3              hz_credit_ratings.credit_score_commentary3%TYPE;
      l_credit_score_commentary4              hz_credit_ratings.credit_score_commentary4%TYPE;
      l_credit_score_commentary5              hz_credit_ratings.credit_score_commentary5%TYPE;
      l_credit_score_commentary6              hz_credit_ratings.credit_score_commentary6%TYPE;
      l_credit_score_commentary7              hz_credit_ratings.credit_score_commentary7%TYPE;
      l_credit_score_commentary8              hz_credit_ratings.credit_score_commentary8%TYPE;
      l_credit_score_commentary9              hz_credit_ratings.credit_score_commentary9%TYPE;
      l_credit_score_commentary10             hz_credit_ratings.credit_score_commentary10%TYPE;
      l_failure_score_commentary              hz_credit_ratings.failure_score_commentary%TYPE;
      l_failure_score_commentary2             hz_credit_ratings.failure_score_commentary2%TYPE;
      l_failure_score_commentary3             hz_credit_ratings.failure_score_commentary3%TYPE;
      l_failure_score_commentary4             hz_credit_ratings.failure_score_commentary4%TYPE;
      l_failure_score_commentary5             hz_credit_ratings.failure_score_commentary5%TYPE;
      l_failure_score_commentary6             hz_credit_ratings.failure_score_commentary6%TYPE;
      l_failure_score_commentary7             hz_credit_ratings.failure_score_commentary7%TYPE;
      l_failure_score_commentary8             hz_credit_ratings.failure_score_commentary8%TYPE;
      l_failure_score_commentary9             hz_credit_ratings.failure_score_commentary9%TYPE;
      l_failure_score_commentary10            hz_credit_ratings.failure_score_commentary10%TYPE;
      l_status                                hz_credit_ratings.status%TYPE;
      l_created_by_module                     hz_credit_ratings.created_by_module%TYPE;
      l_debarment_ind                         hz_credit_ratings.debarment_ind%TYPE;
      l_maximum_credit_currency_code          hz_credit_ratings.maximum_credit_currency_code%TYPE;
      l_credit_score_override_code            hz_credit_ratings.credit_score_override_code%TYPE;
      l_suit_ind                              hz_credit_ratings.suit_ind%TYPE;
      l_lien_ind                              hz_credit_ratings.lien_ind%TYPE;
      l_judgement_ind                         hz_credit_ratings.judgement_ind%TYPE;
      l_bankruptcy_ind                        hz_credit_ratings.bankruptcy_ind%TYPE;
      l_no_trade_ind                          hz_credit_ratings.no_trade_ind%TYPE;
      l_prnt_hq_bkcy_ind                      hz_credit_ratings.prnt_hq_bkcy_ind%TYPE;
      l_actual_content_source                 hz_credit_ratings.actual_content_source%TYPE;
      l_credit_score_natl_percentile          hz_credit_ratings.credit_score_natl_percentile%TYPE;
      l_fail_score_natnl_percentile           hz_credit_ratings.failure_score_natnl_percentile%TYPE;
      l_dummy                                 VARCHAR2(1);
      l_debug_prefix                          VARCHAR2(30) := '';

  BEGIN

      --enable_debug;

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_credit_rating (+)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_credit_rating (+)',
                               p_msg_level=>fnd_log.level_procedure);
       END IF;

      -- do the query to get old values for update
      IF p_create_update_flag = 'U'
      THEN
          SELECT   CREDIT_RATING_ID,
                   PARTY_ID,
                   RATING_ORGANIZATION,
                   RATED_AS_OF_DATE,
                   FINCL_EMBT_IND,
                   CREDIT_SCORE_COMMENTARY,
                   CREDIT_SCORE_COMMENTARY2,
                   CREDIT_SCORE_COMMENTARY3,
                   CREDIT_SCORE_COMMENTARY4,
                   CREDIT_SCORE_COMMENTARY5,
                   CREDIT_SCORE_COMMENTARY6,
                   CREDIT_SCORE_COMMENTARY7,
                   CREDIT_SCORE_COMMENTARY8,
                   CREDIT_SCORE_COMMENTARY9,
                   CREDIT_SCORE_COMMENTARY10,
                   FAILURE_SCORE_COMMENTARY,
                   FAILURE_SCORE_COMMENTARY2,
                   FAILURE_SCORE_COMMENTARY3,
                   FAILURE_SCORE_COMMENTARY4,
                   FAILURE_SCORE_COMMENTARY5,
                   FAILURE_SCORE_COMMENTARY6,
                   FAILURE_SCORE_COMMENTARY7,
                   FAILURE_SCORE_COMMENTARY8,
                   FAILURE_SCORE_COMMENTARY9,
                   FAILURE_SCORE_COMMENTARY10,
                   DEBARMENT_IND,
                   MAXIMUM_CREDIT_CURRENCY_CODE,
                   CREDIT_SCORE_OVERRIDE_CODE,
                   SUIT_IND,
                   LIEN_IND,
                   JUDGEMENT_IND,
                   BANKRUPTCY_IND,
                   NO_TRADE_IND,
                   PRNT_HQ_BKCY_IND,
                   ACTUAL_CONTENT_SOURCE,
                   STATUS,
                   CREATED_BY_MODULE,
                   CREDIT_SCORE_NATL_PERCENTILE,
                   FAILURE_SCORE_NATNL_PERCENTILE
          INTO     l_credit_rating_id,
                   l_party_id,
                   l_rating_organization,
                   l_rated_as_of_date,
                   l_fincl_embt_ind,
                   l_credit_score_commentary,
                   l_credit_score_commentary2,
                   l_credit_score_commentary3,
                   l_credit_score_commentary4,
                   l_credit_score_commentary5,
                   l_credit_score_commentary6,
                   l_credit_score_commentary7,
                   l_credit_score_commentary8,
                   l_credit_score_commentary9,
                   l_credit_score_commentary10,
                   l_failure_score_commentary,
                   l_failure_score_commentary2,
                   l_failure_score_commentary3,
                   l_failure_score_commentary4,
                   l_failure_score_commentary5,
                   l_failure_score_commentary6,
                   l_failure_score_commentary7,
                   l_failure_score_commentary8,
                   l_failure_score_commentary9,
                   l_failure_score_commentary10,
                   l_debarment_ind,
                   l_maximum_credit_currency_code,
                   l_credit_score_override_code,
                   l_suit_ind,
                   l_lien_ind,
                   l_judgement_ind,
                   l_bankruptcy_ind,
                   l_no_trade_ind,
                   l_prnt_hq_bkcy_ind,
                   l_actual_content_source,
                   l_status,
                   l_created_by_module,
                   l_credit_score_natl_percentile,
                   l_fail_score_natnl_percentile
          FROM   HZ_CREDIT_RATINGS
          WHERE  ROWID = p_rowid;
      END IF;

      -------------------------------------
      -- validation for credit_rating_id
      -------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      --check for unique credit_rating_id
      IF p_create_update_flag = 'C' THEN
        IF p_credit_rating_rec.credit_rating_id IS NOT NULL AND
           p_credit_rating_rec.credit_rating_id <> fnd_api.g_miss_num
        THEN
          OPEN c_dup_credit_rating_id (p_credit_rating_rec.credit_rating_id);
          FETCH c_dup_credit_rating_id INTO l_dummy;

          -- key is not unique, push an error onto the stack.
          IF NVL(c_dup_credit_rating_id%FOUND, FALSE) THEN
            fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
            fnd_message.set_token('COLUMN', 'credit_rating_id');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
          END IF;
          CLOSE c_dup_credit_rating_id;

          /*IF g_debug THEN
            hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'check that credit_rating_id is unique during creation. ' ||
              ' x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'check that credit_rating_id is unique during creation. ' ||
                                ' x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;

        END IF;
      END IF;

      /*IF g_debug THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
          '(+) after validate credit_rating_id ... ' ||
          'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'(+) after validate credit_rating_id ... ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -- credit_rating_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'credit_rating_id',
              p_column_value                          => p_credit_rating_rec.credit_rating_id,
              p_old_column_value                      => l_credit_rating_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'credit_rating_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'credit_rating_id is non-updateable field. ' ||
                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
         END IF;

      END IF;
  END IF;

      -------------------------------------
      -- validation for party_id
      -------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      --party_id is a mandatory field
      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'party_id',
              p_column_value                          => p_credit_rating_rec.party_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id is mandatory field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is mandatory field. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;

      END IF;
      -- party_id has foreign key HZ_PARTIES.PARTY_ID
      IF p_create_update_flag = 'C'
         AND
         p_credit_rating_rec.party_id IS NOT NULL
         AND
         p_credit_rating_rec.party_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   hz_parties p
              WHERE  p.party_id = p_credit_rating_rec.party_id;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'party_id');
                  fnd_message.set_token('COLUMN', 'party_id');
                  fnd_message.set_token('TABLE', 'hz_parties');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id has foreign key hz_parties.party_id. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id has foreign key hz_parties.party_id. ' ||
                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- party_id is non-updateable field
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'party_id',
              p_column_value                          => p_credit_rating_rec.party_id,
              p_old_column_value                      => l_party_id,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'party_id is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'party_id is non-updateable field. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;

      END IF;
  END IF;

      /**********************************************************************************
      Bug Number 3090928:Removed the validation below and used the unique index HZ_CREDIT_RATINGS_U2
      on table HZ_CREDIT_RATINGS to check for uniqueness.Now this check is done by handling the
      exception DUP_VAL_ON_INDEX for the unique index HZ_CREDIT_RATINGS_U2 in the procedure
      HZ_CREDIT_RATINGS_PKG.Insert_Row.
      ***********************************************************************************
      |---------------------------------------
      |--Bug 2869178: Unique record Validation
      |---------------------------------------
      |IF p_create_update_flag = 'C' THEN
      |    OPEN c_unique_credit_rating_rec (p_credit_rating_rec.party_id,
      |                                     p_credit_rating_rec.rated_as_of_date,
      |                                     p_credit_rating_rec.rating_organization,
      |                                     p_credit_rating_rec.actual_content_source);
      |    FETCH c_unique_credit_rating_rec INTO l_dummy;
      |
      |    -- combination key is not unique, push an error onto the stack.
      |    IF NVL(c_unique_credit_rating_rec%FOUND, FALSE) THEN
      |      fnd_message.set_name('AR', 'HZ_API_DUP_CREDIT_RATING_REC');
      |      fnd_msg_pub.add;
      |      x_return_status := fnd_api.g_ret_sts_error;
      |    END IF;
      |    CLOSE c_unique_credit_rating_rec;
      |
      |    IF g_debug THEN
      |      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
      |        'The following column combination should be unique:' ||
      |        ' PARTY_ID, TRUNC(RATED_AS_OF_DATE), RATING_ORGANIZATION, and ACTUAL_CONTENT_SOURCE. ' ||
      |        ' x_return_status = ' || x_return_status, l_debug_prefix);
      |    END IF;
      |END IF;
      ********************************************************************************
      End of code commented for Bug Number 3090928.
      ********************************************************************************/
      ------------------------------------
      --rated_as_of_date is not updateable
      ------------------------------------
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'rated_as_of_date',
              p_column_value                          => trunc(p_credit_rating_rec.rated_as_of_date),
              p_old_column_value                      => trunc(l_rated_as_of_date),
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'rated_as_of_date is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'rated_as_of_date is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
           END IF;

      END IF;
      ---------------------------------------
      --rating_organization is not updateable
      ---------------------------------------
      IF p_create_update_flag = 'U' THEN
          validate_nonupdateable (
              p_column                                => 'rating_organization',
              p_column_value                          => p_credit_rating_rec.rating_organization,
              p_old_column_value                      => l_rating_organization,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'rating_organization is non-updateable field. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'rating_organization is non-updateable field. ' ||
                                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
      ----------------------------------
      -- validation for fincl_embt_ind
      ----------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      --bug 2843453, fincl_embt_ind should be validated against YES/NO instead
      --of REGISTRY_STATUS
      -- fincl_embt_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'fincl_embt_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_credit_rating_rec.fincl_embt_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'fincl_embt_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'fincl_embt_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
  END IF;

      -----------------------------------------
      -- validation for credit_score_commentary
      -----------------------------------------

      -- credit_score_commentary is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.credit_score_commentary,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'credit_score_commentary should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;


      ------------------------------------------
      -- validation for credit_score_commentary2
      ------------------------------------------

      -- credit_score_commentary2 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary2',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.credit_score_commentary2,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary2 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'credit_score_commentary2 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      ------------------------------------------
      -- validation for credit_score_commentary3
      ------------------------------------------

      -- credit_score_commentary3 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary3',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.credit_score_commentary3,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary3 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'credit_score_commentary3 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      ------------------------------------------
      -- validation for credit_score_commentary4
      ------------------------------------------

      -- credit_score_commentary4 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary4',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.credit_score_commentary4,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary4 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'credit_score_commentary4 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

      ------------------------------------------
      -- validation for credit_score_commentary5
      ------------------------------------------

      -- credit_score_commentary5 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary5',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.credit_score_commentary5,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary5 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'credit_score_commentary5 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

      ------------------------------------------
      -- validation for credit_score_commentary6
      ------------------------------------------

      -- credit_score_commentary6 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary6',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.credit_score_commentary6,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary6 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'credit_score_commentary6 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

       ------------------------------------------
      -- validation for credit_score_commentary7
      ------------------------------------------

      -- credit_score_commentary7 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary7',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.credit_score_commentary7,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary7 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'credit_score_commentary7 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
     END IF;

      ------------------------------------------
      -- validation for credit_score_commentary8
      ------------------------------------------

      -- credit_score_commentary8 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary8',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.credit_score_commentary8,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary8 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'credit_score_commentary8 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      ------------------------------------------
      -- validation for credit_score_commentary9
      ------------------------------------------

      -- credit_score_commentary9 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary9',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.credit_score_commentary9,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary9 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'credit_score_commentary9 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -------------------------------------------
      -- validation for credit_score_commentary10
      -------------------------------------------

      -- credit_score_commentary10 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'credit_score_commentary10',
          p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.credit_score_commentary10,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_commentary10 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'credit_score_commentary10 should be in lookup CREDIT_SCORE_COMMENTARY. ' ||
                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      ------------------------------------------
      -- validation for failure_score_commentary
      ------------------------------------------

      -- failure_score_commentary is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.failure_score_commentary,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'failure_score_commentary should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -------------------------------------------
      -- validation for failure_score_commentary2
      -------------------------------------------

      -- failure_score_commentary2 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary2',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.failure_score_commentary2,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary2 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'failure_score_commentary2 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

      -------------------------------------------
      -- validation for failure_score_commentary3
      -------------------------------------------

      -- failure_score_commentary3 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary3',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.failure_score_commentary3,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary2 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'failure_score_commentary2 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

      -------------------------------------------
      -- validation for failure_score_commentary4
      -------------------------------------------

      -- failure_score_commentary4 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary4',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.failure_score_commentary4,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary4 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'failure_score_commentary4 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

      -------------------------------------------
      -- validation for failure_score_commentary5
      -------------------------------------------

      -- failure_score_commentary5 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary5',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.failure_score_commentary5,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary5 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'failure_score_commentary5 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -------------------------------------------
      -- validation for failure_score_commentary6
      -------------------------------------------

      -- failure_score_commentary6 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary6',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.failure_score_commentary6,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary6 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'failure_score_commentary6 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -------------------------------------------
      -- validation for failure_score_commentary7
      -------------------------------------------

      -- failure_score_commentary7 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary7',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.failure_score_commentary7,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary7 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'failure_score_commentary7 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
                          'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -------------------------------------------
      -- validation for failure_score_commentary8
      -------------------------------------------

      -- failure_score_commentary8 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary8',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.failure_score_commentary8,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary8 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'failure_score_commentary8 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -------------------------------------------
      -- validation for failure_score_commentary9
      -------------------------------------------

      -- failure_score_commentary9 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary9',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.failure_score_commentary9,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary9 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'failure_score_commentary9 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      --------------------------------------------
      -- validation for failure_score_commentary10
      --------------------------------------------

      -- failure_score_commentary10 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      validate_lookup (
          p_column                                => 'failure_score_commentary10',
          p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
          p_column_value                          => p_credit_rating_rec.failure_score_commentary10,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'failure_score_commentary10 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'failure_score_commentary10 should be in lookup FAILURE_SCORE_COMMENTARY. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

      --------------------------------------------
      -- validation for credit_score_override_code
      --------------------------------------------

      -- credit_score_override_code is lookup code in lookup type FAILURE_SCORE_OVERRIDE_CODE
      validate_lookup (
          p_column                                => 'credit_score_override_code',
          p_lookup_type                           => 'FAILURE_SCORE_OVERRIDE_CODE',
          p_column_value                          => p_credit_rating_rec.credit_score_override_code,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'credit_score_override_code should be in lookup FAILURE_SCORE_OVERRIDE_CODE. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'credit_score_override_code should be in lookup FAILURE_SCORE_OVERRIDE_CODE. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

      --------------------------------------------
      -- validation for debarment_ind
      --------------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- debarment_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'debarment_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_credit_rating_rec.debarment_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'debarment_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'debarment_ind should be in lookup YES/NO. ' ||
                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      --------------------------------------------
      -- validation for suit_ind
      --------------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- suit_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'suit_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_credit_rating_rec.suit_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'suit_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'suit_ind should be in lookup YES/NO. ' ||
                                  'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      --------------------------------------------
      -- validation for lien_ind
      --------------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- lien_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'lien_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_credit_rating_rec.lien_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'lien_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'lien_ind should be in lookup YES/NO. ' ||
                                                 'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      --------------------------------------------
      -- validation for judgement_ind
      --------------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- judgement_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'judgement_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_credit_rating_rec.judgement_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'judgement_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'judgement_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
  END IF;

      --------------------------------------------
      -- validation for no_trade_ind
      --------------------------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- no_trade_ind is lookup code in lookup type YES/NO
      validate_lookup (
          p_column                                => 'no_trade_ind',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_credit_rating_rec.no_trade_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'no_trade_ind should be in lookup YES/NO. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'no_trade_ind should be in lookup YES/NO. ' ||
                                         'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
     END IF;
  END IF;

      --------------------------------------------
      -- validation for prnt_hq_bkcy_ind
      --------------------------------------------
      --Bug 2898670: prnt_hq_bkcy_ind lookup code should be in the
      --lookup_type PRNT_HQ_IND instead of YES/NO
      validate_lookup (
          p_column                                => 'prnt_hq_bkcy_ind',
          p_lookup_type                           => 'PRNT_HQ_IND',
          p_column_value                          => p_credit_rating_rec.prnt_hq_bkcy_ind,
          x_return_status                         => x_return_status);

      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'prnt_hq_bkcy_ind should be in lookup PRNT_HQ_IND. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'prnt_hq_bkcy_ind should be in lookup PRNT_HQ_IND. ' ||
                                        'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      ----------------------------------------------
      -- validation for maximum_credit_currency_code
      ----------------------------------------------

      -- maximum_credit_currency_code is foreign key to FND_CURRENCIES.CURRENCY_CODE
      IF p_create_update_flag = 'C'
         AND
         p_credit_rating_rec.maximum_credit_currency_code IS NOT NULL
         AND
         p_credit_rating_rec.maximum_credit_currency_code <> fnd_api.g_miss_char
      THEN
          BEGIN
              --Bug 2898670: Changed the validation as the foreign key validation
              --has to be against active records
              --Bug 3877782. Added the condition to consider start_date_active and end_date_active.
              SELECT 'Y'
              INTO   l_dummy
              FROM   fnd_currencies f
              WHERE  f.currency_code = p_credit_rating_rec.maximum_credit_currency_code
              AND    currency_flag = 'Y'
              AND    enabled_flag = 'Y'
              AND    trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
                                    and      trunc(nvl(end_date_active,sysdate));
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'currency_code');
                  fnd_message.set_token('COLUMN', 'maximum_credit_currency_code');
                  fnd_message.set_token('TABLE', 'fnd_currencies');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'maximum_credit_currency_code has foreign key fnd_currencies.currency_code. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                p_message=>'maximum_credit_currency_code has foreign key fnd_currencies.currency_code. ' ||
                          'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;


      ------------------------
      -- validation for status
      ------------------------
/****Logical APIs - validation not required****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
      -- status is lookup code in lookup type REGISTRY_STATUS
      IF p_credit_rating_rec.status IS NOT NULL
         AND
         p_credit_rating_rec.status <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_rating_rec.status <> NVL(l_status, fnd_api.g_miss_char)
         )
        )
      THEN
          validate_lookup (
              p_column                                => 'status',
              p_lookup_type                           => 'REGISTRY_STATUS',
              p_column_value                          => p_credit_rating_rec.status,
              x_return_status                         => x_return_status);

          /*IF g_debug THEN
              hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                  'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                  'x_return_status = ' || x_return_status, l_debug_prefix);
          END IF;
          */
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
             p_message=>'status is lookup code in lookup type REGISTRY_STATUS. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;
  END IF;

      -- status cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          validate_cannot_update_to_null (
              p_column                                => 'status',
              p_column_value                          => p_credit_rating_rec.status,
              x_return_status                         => x_return_status);
      END IF;

      --------------------------------------------------------
      -- validate credit_score_natl_percentile ( Bug 3181460 )
      --------------------------------------------------------
      -- This column should have a value within the range 0 - 100.

      IF p_credit_rating_rec.credit_score_natl_percentile IS NOT NULL AND
         p_credit_rating_rec.credit_score_natl_percentile <> FND_API.G_MISS_NUM AND
         (p_create_update_flag = 'C' OR
          (
          p_create_update_flag = 'U' AND
          p_credit_rating_rec.credit_score_natl_percentile <> l_credit_score_natl_percentile
          )
         )
      THEN
          IF p_credit_rating_rec.credit_score_natl_percentile < 0 OR
             p_credit_rating_rec.credit_score_natl_percentile > 100
          THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_PERCENTAGE');
              FND_MESSAGE.SET_TOKEN('INVALIDVAL', p_credit_rating_rec.credit_score_natl_percentile);
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'credit_score_natl_percentile');
              FND_MSG_PUB.ADD;
              x_return_status := fnd_api.g_ret_sts_error;
          END IF;
      END IF;

      ----------------------------------------------------------
      -- validate failure_score_natnl_percentile ( Bug 3181460 )
      ----------------------------------------------------------
      -- This column should have a value within the range 0 - 100.

      IF p_credit_rating_rec.failure_score_natnl_percentile IS NOT NULL AND
         p_credit_rating_rec.failure_score_natnl_percentile <> FND_API.G_MISS_NUM AND
         (
         p_create_update_flag = 'C' OR
          (
          p_create_update_flag = 'U' AND
          p_credit_rating_rec.failure_score_natnl_percentile <> l_fail_score_natnl_percentile
          )
         )
      THEN
          IF p_credit_rating_rec.failure_score_natnl_percentile < 0 OR
             p_credit_rating_rec.failure_score_natnl_percentile > 100
          THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_PERCENTAGE');
              FND_MESSAGE.SET_TOKEN('INVALIDVAL', p_credit_rating_rec.failure_score_natnl_percentile);
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'failure_score_natnl_percentile');
              FND_MSG_PUB.ADD;
              x_return_status := fnd_api.g_ret_sts_error;
          END IF;
      END IF;


      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      validate_created_by_module(
        p_create_update_flag     => p_create_update_flag,
        p_created_by_module      => p_credit_rating_rec.created_by_module,
        p_old_created_by_module  => l_created_by_module,
        x_return_status          => x_return_status);

      --------------------------------------------------------------
      -- validate content_source_type and actual_content_source_type
      --------------------------------------------------------------
    /* SSM SST Integration and Extension
     * actual_content_source is now a foreign key to HZ_ORIG_SYSTEMS_B.orig_system with sst_flag = 'Y'.
      -- actual_content_source is lookup code in lookup type CONTENT_SOURCE_TYPE
      validate_lookup (
          p_column                                => 'actual_content_source',
          p_lookup_type                           => 'CONTENT_SOURCE_TYPE',
          p_column_value                          => p_credit_rating_rec.actual_content_source,
          x_return_status                         => x_return_status);
    */
      /*IF g_debug THEN
          hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
              'actual_content_source should be in lookup CONTENT_SOURCE_TYPE. ' ||
              'x_return_status = ' || x_return_status, l_debug_prefix);
      END IF;
      */
    /*
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
           p_message=>'actual_content_source should be in lookup CONTENT_SOURCE_TYPE. ' ||
                                                'x_return_status = ' || x_return_status,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;
    */
      HZ_MIXNM_UTILITY.ValidateContentSource (
        p_api_version                       => 'V2',
        p_create_update_flag                => p_create_update_flag,
        p_check_update_privilege            => 'Y',
        p_content_source_type               => 'USER_ENTERED',
        p_old_content_source_type           => 'USER_ENTERED',
        p_actual_content_source             => p_credit_rating_rec.actual_content_source,
        p_old_actual_content_source         => l_actual_content_source,
        p_entity_name                       => 'HZ_CREDIT_RATINGS',
        x_return_status                     => x_return_status );

      -- Debug info.
      /*IF g_debug THEN
          hz_utility_v2pub.debug ('validate_credit_rating (-)');
      END IF;
      */
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'validate_credit_rating (-)',
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      --disable_debug;

  END validate_credit_rating;


  /**
   * PROCEDURE validate_created_by_module
   *
   * DESCRIPTION
   *    validate created by module
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag      create update flag
   *     p_created_by_module       created by module
   *     p_old_created_by_module   old value of created by module
   *     x_return_status           return status
   */

  PROCEDURE validate_created_by_module (
      p_create_update_flag          IN     VARCHAR2,
      p_created_by_module           IN     VARCHAR2,
      p_old_created_by_module       IN     VARCHAR2,
      x_return_status               IN OUT NOCOPY VARCHAR2
  ) IS

      l_column                      CONSTANT VARCHAR2(30) := 'created_by_module';

  BEGIN

      -- skip mandatory and non-updateable check from logical API
      IF HZ_UTILITY_V2PUB.G_CALLING_API IS NULL THEN
        -- created_by_module is mandatory field
        -- Since created_by_module is non-updateable, we only need to check mandatory
        -- during creation.

        IF p_create_update_flag = 'C' THEN
          validate_mandatory (
            p_create_update_flag     => p_create_update_flag,
            p_column                 => l_column,
            p_column_value           => p_created_by_module,
            x_return_status          => x_return_status);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
              p_prefix               => '',
              p_message              => l_column || ' is mandatory. ' ||
                                        'x_return_status = ' || x_return_status,
              p_msg_level            => fnd_log.level_statement);
          END IF;
        END IF;

        -- created_by_module is non-updateable field. But it can be updated from
        -- NULL to some value.

        IF p_create_update_flag = 'U' AND
           p_created_by_module IS NOT NULL
        THEN
          validate_nonupdateable (
            p_column                 => l_column,
            p_column_value           => p_created_by_module,
            p_old_column_value       => p_old_created_by_module,
            p_restricted             => 'N',
            x_return_status          => x_return_status);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
              p_prefix               => '',
              p_message              => l_column || ' is non-updateable. It can be updated from NULL to a value. ' ||
                                        'x_return_status = ' || x_return_status,
              p_msg_level            => fnd_log.level_statement);
          END IF;
        END IF;
      END IF;

      -- created_by_module is lookup code in lookup type HZ_CREATED_BY_MODULES
      IF p_created_by_module IS NOT NULL AND
         p_created_by_module <> fnd_api.g_miss_char AND
         (p_create_update_flag = 'C' OR
          (p_create_update_flag = 'U' AND
           (p_old_created_by_module IS NULL OR
            p_created_by_module <> p_old_created_by_module)))
      THEN
        validate_lookup (
          p_column                   => l_column,
          p_lookup_type              => 'HZ_CREATED_BY_MODULES',
          p_column_value             => p_created_by_module,
          x_return_status            => x_return_status);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                 => '',
            p_message                => l_column || ' is lookup code in lookup type HZ_CREATED_BY_MODULES. ' ||
                                        'x_return_status = ' || x_return_status,
            p_msg_level              => fnd_log.level_statement);
        END IF;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_prefix                   => '',
          p_message                  => 'after validate ' || l_column || ' ... ' ||
                                        'x_return_status = ' || x_return_status,
          p_msg_level                => fnd_log.level_statement);
      END IF;

  END validate_created_by_module;


  /**
   * PROCEDURE validate_application_id
   *
   * DESCRIPTION
   *    validate application id
   * ARGUMENTS
   *   IN:
   *     p_create_update_flag      create update flag
   *     p_application_id          application id
   *     p_old_application_id      old value of application id
   *     x_return_status           return status
   */

  PROCEDURE validate_application_id (
      p_create_update_flag          IN     VARCHAR2,
      p_application_id              IN     NUMBER,
      p_old_application_id          IN     NUMBER,
      x_return_status               IN OUT NOCOPY VARCHAR2
  ) IS

      l_column                      CONSTANT VARCHAR2(30) := 'application_id';

  BEGIN

      -- skip non-updateable check from logical API
      IF HZ_UTILITY_V2PUB.G_CALLING_API IS NULL THEN
        -- application_id is non-updateable field. But it can be updated from NULL
        -- to some value.

        IF p_create_update_flag = 'U' AND
           p_application_id IS NOT NULL
        THEN
          validate_nonupdateable (
            p_column                 => l_column,
            p_column_value           => p_application_id,
            p_old_column_value       => p_old_application_id,
            p_restricted             => 'N',
            x_return_status          => x_return_status);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
              p_prefix               => '',
              p_message              => l_column || ' is non-updateable. It can be updated from NULL to a value. ' ||
                                        'x_return_status = ' || x_return_status,
              p_msg_level            => fnd_log.level_statement);
          END IF;
        END IF;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_prefix                   => '',
          p_message                  => 'after validate ' || l_column || ' ... ' ||
                                        'x_return_status = ' || x_return_status,
          p_msg_level                => fnd_log.level_statement);
      END IF;

  END validate_application_id;

END hz_registry_validate_v2pub;

/
