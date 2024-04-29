--------------------------------------------------------
--  DDL for Package Body HZ_UTILITY_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_UTILITY_V2PUB" AS
/*$Header: ARH2UTSB.pls 120.45.12010000.2 2009/02/10 13:01:22 ajaising ship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

G_SPECIAL_STRING                        CONSTANT VARCHAR2(4):= '%#@*';
G_LENGTH                                CONSTANT NUMBER := LENGTHB( G_SPECIAL_STRING );

TYPE VAL_TAB_TYPE IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

-- file handler we will use for log file.
G_FILE                                  UTL_FILE.FILE_TYPE;

-- running in file debug mode.
G_FILE_DEBUG                            BOOLEAN := FALSE;
G_FILE_NAME                             VARCHAR2(100);
G_FILE_PATH                             VARCHAR2(200);

-- running in normal debug mode by calling dbms_output.
G_DBMS_DEBUG                            BOOLEAN := FALSE;

-- buffer size used by dbms_output.debug
G_BUFFER_SIZE                           CONSTANT NUMBER := 1000000;
G_MAX_LINE_SIZE_OF_FILE                 CONSTANT NUMBER := 1023;
G_MAX_LINE_SIZE_OF_DBMS                 CONSTANT NUMBER := 255;

-- level of debug has been called.
G_COUNT                                 NUMBER := 0;

--------------------------------------
-- define the internal table that will cache values
--------------------------------------

VAL_TAB                                 VAL_TAB_TYPE;    -- the table of values
TABLE_SIZE                              BINARY_INTEGER := 2048; -- the size of above tables
LOOKUP_MEANING_TAB                      VAL_TAB_TYPE;

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

FUNCTION get_index (
    p_val                               IN     VARCHAR2
) RETURN BINARY_INTEGER;

FUNCTION put (
    p_val                               IN     VARCHAR2
) RETURN BINARY_INTEGER;

FUNCTION search (
    p_val                               IN     VARCHAR2,
    p_category                          IN     VARCHAR2
) RETURN BOOLEAN;

FUNCTION search (
    p_val                               IN     VARCHAR2,
    p_category                          IN     VARCHAR2,
    x_lookup_meaning                    OUT NOCOPY    VARCHAR2,
    p_calling_proc                      IN  VARCHAR2
) RETURN BOOLEAN;

PROCEDURE enable_file_debug;

--------------------------------------
-- private procedures and functions
--------------------------------------

/**
 * PRIVATE FUNCTION get_index
 *
 * DESCRIPTION
 *     Gets index in caching table for a specified value.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_val                          Specified value.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

FUNCTION get_index (
    p_val                               IN     VARCHAR2
) RETURN BINARY_INTEGER IS

    l_table_index                       BINARY_INTEGER;
    l_found                             BOOLEAN := FALSE;
    l_hash_value                        NUMBER;

BEGIN

    l_table_index := DBMS_UTILITY.get_hash_value( p_val, 1, TABLE_SIZE );

    IF VAL_TAB.EXISTS(l_table_index) THEN
        IF VAL_TAB(l_table_index) = p_val THEN
            RETURN l_table_index;
        ELSE
            l_hash_value := l_table_index;
            l_table_index := l_table_index + 1;
            l_found := FALSE;

            WHILE ( l_table_index < TABLE_SIZE ) AND ( NOT l_found ) LOOP
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

                WHILE ( l_table_index < l_hash_value ) AND ( NOT l_found ) LOOP
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

/**
 * PRIVATE FUNCTION put
 *
 * DESCRIPTION
 *     Put value in caching table and return table index.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_val                          Specified value.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   03-04-2002    Jianying Huang      o Modified the procedure to be a function
 *                                       to return table index.
 *
 */

FUNCTION put (
    p_val                               IN     VARCHAR2
) RETURN BINARY_INTEGER IS

    l_table_index                       BINARY_INTEGER;
    l_stored                            BOOLEAN := FALSE;
    l_hash_value                        NUMBER;

BEGIN

    l_table_index := DBMS_UTILITY.get_hash_value( p_val, 1, TABLE_SIZE );

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

    RETURN l_table_index;
EXCEPTION
    WHEN OTHERS THEN
        NULL;

END put;

/**
 * PRIVATE FUNCTION search
 *
 * DESCRIPTION
 *     Find value with a specified category, for instance, lookup.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_val                          Specified value.
 *     p_category                     Value category. We only support
 *                                    category LOOKUP for now.
 *   OUT:
 *     x_lookup_meaning               Lookup Meaning
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   03-04-2002    Jianying Huang      o Added new parameter to return
 *                                       lookup meaning.
 *
 */

FUNCTION search (
    p_val                               IN     VARCHAR2,
    p_category                          IN     VARCHAR2,
    x_lookup_meaning                    OUT NOCOPY    VARCHAR2,
    p_calling_proc                      IN VARCHAR2
) RETURN BOOLEAN IS

    l_table_index                       BINARY_INTEGER;
    l_return                            BOOLEAN;

    l_dummy                             VARCHAR2(1);
    l_position1                         NUMBER;
    l_position2                         NUMBER;

    l_lookup_table                      VARCHAR2(30);
    l_lookup_type                       AR_LOOKUPS.lookup_type%TYPE;
    l_lookup_code                       AR_LOOKUPS.lookup_code%TYPE;

    l_relationship_type                 VARCHAR2(30);
    l_incl_unrelated_entities           VARCHAR2(1);

    --  Bug 5398089 : Added variables
    l_string VARCHAR2(255);
    l_cache BOOLEAN;

BEGIN

    -- search for the value
    l_table_index := get_index( p_val || G_SPECIAL_STRING || p_category );
    l_cache := TRUE;

    IF l_table_index < table_size THEN
       IF p_calling_proc <> 'Get_LookupMeaning' THEN
          RETURN TRUE;
       ELSE
       --  Bug 5398089 : conisder language for lookup meaning
         IF p_category = 'LOOKUP' THEN
           l_string := LOOKUP_MEANING_TAB(l_table_index);
           l_position1 := INSTRB( l_string, G_SPECIAL_STRING, 1, 1 );
           IF SUBSTRB( l_string, l_position1 + G_LENGTH ) = userenv('LANG') THEN
             -- This stores the meaning
             x_lookup_meaning := SUBSTRB( l_string, 1, l_position1 - 1 );
             RETURN TRUE;
           END IF;
           l_cache := FALSE;
         END IF;
       END IF;
    END IF;
        --Can't find the value in the table; look in the database
        IF p_category = 'LOOKUP' THEN

            l_position1 := INSTRB( p_val, G_SPECIAL_STRING, 1, 1 );
            l_lookup_table := SUBSTRB( p_val, 1, l_position1 - 1 );
            l_position2 := INSTRB( p_val, G_SPECIAL_STRING, 1, 2 );
            l_lookup_type := SUBSTRB( p_val, l_position1 + G_LENGTH,
                                     l_position2  - l_position1 - G_LENGTH );
            l_lookup_code := SUBSTRB( p_val, l_position2 + G_LENGTH );

            IF UPPER( l_lookup_table ) = 'AR_LOOKUPS' THEN
            BEGIN
                SELECT meaning INTO x_lookup_meaning
                FROM   AR_LOOKUPS
                WHERE  LOOKUP_TYPE = l_lookup_type
                AND    LOOKUP_CODE = l_lookup_code
                AND    ( ENABLED_FLAG = 'Y' AND
                         TRUNC( SYSDATE ) BETWEEN
                         TRUNC(NVL( START_DATE_ACTIVE,SYSDATE ) ) AND
                         TRUNC(NVL( END_DATE_ACTIVE,SYSDATE ) ) );

                l_return := TRUE;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_return := FALSE;
            END;
            ELSIF UPPER( l_lookup_table ) = 'SO_LOOKUPS' THEN
            BEGIN
                SELECT meaning INTO x_lookup_meaning
                FROM   SO_LOOKUPS
                WHERE  LOOKUP_TYPE = l_lookup_type
                AND    LOOKUP_CODE = l_lookup_code
                AND    ( ENABLED_FLAG = 'Y' AND
                         TRUNC( SYSDATE ) BETWEEN
                         TRUNC(NVL( START_DATE_ACTIVE,SYSDATE ) ) AND
                         TRUNC(NVL( END_DATE_ACTIVE,SYSDATE ) ) );

                l_return := TRUE;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_return := FALSE;
            END;
            ELSIF UPPER( l_lookup_table ) = 'OE_SHIP_METHODS_V' THEN
            BEGIN
                SELECT meaning INTO x_lookup_meaning
                FROM   OE_SHIP_METHODS_V
                WHERE  LOOKUP_TYPE = l_lookup_type
                AND    LOOKUP_CODE = l_lookup_code
                AND    ( ENABLED_FLAG = 'Y' AND
                         TRUNC( SYSDATE ) BETWEEN
                         TRUNC(NVL( START_DATE_ACTIVE,SYSDATE ) ) AND
                         TRUNC(NVL( END_DATE_ACTIVE,SYSDATE ) ) )
                AND    ROWNUM = 1;

                l_return := TRUE;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_return := FALSE;
            END;
            ELSIF UPPER( l_lookup_table ) = 'FND_LOOKUP_VALUES' THEN
            BEGIN
                SELECT meaning INTO x_lookup_meaning
                FROM   FND_LOOKUP_VALUES
                WHERE  LOOKUP_TYPE = l_lookup_type
                AND    LOOKUP_CODE = l_lookup_code
                AND    ( ENABLED_FLAG = 'Y' AND
                         TRUNC( SYSDATE ) BETWEEN
                         TRUNC(NVL( START_DATE_ACTIVE,SYSDATE ) ) AND
                         TRUNC(NVL( END_DATE_ACTIVE,SYSDATE ) ) )
                -- Bug 4112157
                --AND    ROWNUM = 1;
                AND LANGUAGE= userenv('LANG')
                AND VIEW_APPLICATION_ID=222
                AND SECURITY_GROUP_ID=0;

                l_return := TRUE;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_return := FALSE;
            END;
            ELSIF UPPER( l_lookup_table ) = 'FND_LANGUAGES' THEN
            BEGIN
                SELECT nls_language INTO x_lookup_meaning
                FROM   FND_LANGUAGES
                WHERE  LANGUAGE_CODE = l_lookup_code;

                l_return := TRUE;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_return := FALSE;
            END;

            ELSE
                l_return := FALSE;
            END IF;

        -- added the following section for caching of incl_unrelated_entities
        -- column value for hz_relationship_types records.
        ELSIF p_category = 'RELATIONSHIP_TYPE' THEN

            l_position1 := INSTRB( p_val, G_SPECIAL_STRING, 1, 1 );
            l_relationship_type := SUBSTRB( p_val, 1, l_position1 - 1 );

            BEGIN
                SELECT INCL_UNRELATED_ENTITIES INTO l_dummy
                FROM   HZ_RELATIONSHIP_TYPES
                WHERE  RELATIONSHIP_TYPE = l_relationship_type
                AND    ROWNUM = 1;

                IF l_dummy = 'Y' THEN
                    l_return := TRUE;
                ELSE
                    l_return := FALSE;
                END IF;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_return := FALSE;
            END;

        END IF;

        --Cache the value
        IF l_return THEN
           IF l_cache THEN
             l_table_index := put( p_val || G_SPECIAL_STRING || p_category );
           END IF;
           IF p_category = 'LOOKUP' THEN
               --  Bug 5398089 : concat meanign with langauge
               LOOKUP_MEANING_TAB(l_table_index) := x_lookup_meaning || G_SPECIAL_STRING || userenv('LANG');
           END IF;
        END IF;

    RETURN l_return;

END search;

/**
 * PRIVATE FUNCTION search
 *
 * DESCRIPTION
 *     Find value with a specified category, for instance, lookup.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_val                          Specified value.
 *     p_category                     Value category. We only support
 *                                    category LOOKUP for now.
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-04-2002    Jianying Huang      o Added new parameter to return
 *                                       lookup meaning.
 *
 */

FUNCTION search (
    p_val                               IN     VARCHAR2,
    p_category                          IN     VARCHAR2
) RETURN BOOLEAN IS

    l_lookup_meaning                    VARCHAR2(100);

BEGIN
    RETURN search(p_val, p_category, l_lookup_meaning, 'search');
END search;

/**
 * PRIVATE PROCEDURE enable_file_debug
 *
 * DESCRIPTION
 *     Enable file debug.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE enable_file_debug IS

BEGIN

    -- Open log file in 'append' mode.
    IF NOT UTL_FILE.is_open( G_FILE ) THEN
        G_FILE := UTL_FILE.fopen( G_FILE_PATH, G_FILE_NAME, 'a' );
    END IF;

    G_FILE_DEBUG := TRUE;

EXCEPTION
    WHEN UTL_FILE.INVALID_PATH THEN
        FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_INVALID_PATH' );
        FND_MESSAGE.SET_TOKEN( 'FILE_DIR', G_FILE_PATH );
        FND_MSG_PUB.ADD;
        G_FILE_DEBUG := FALSE;
        G_COUNT := 0;
        RAISE FND_API.G_EXC_ERROR;

    WHEN UTL_FILE.INVALID_MODE THEN
        FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_INVALID_MODE' );
        FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
        FND_MESSAGE.SET_TOKEN( 'FILE_MODE', 'w' );
        FND_MSG_PUB.ADD;
        G_FILE_DEBUG := FALSE;
        G_COUNT := 0;
        RAISE FND_API.G_EXC_ERROR;

    WHEN UTL_FILE.INVALID_OPERATION THEN
        FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_INVALID_OPERATN' );
        FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
        FND_MESSAGE.SET_TOKEN( 'TEMP_DIR', G_FILE_PATH );
        FND_MSG_PUB.ADD;
        G_FILE_DEBUG := FALSE;
        G_COUNT := 0;
        RAISE FND_API.G_EXC_ERROR;

END enable_file_debug;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE validate_mandatory
 *
 * DESCRIPTION
 *     Validate mandatory field.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           'C' ( create mode ), 'U' ( update mode )
 *     p_column                       Column name you want to validate.
 *     p_column_value                 Column value
 *     p_restriced                    If set to 'Y', p_column_value should be passed
 *                                    in with some value in both create and update
 *                                    mode. If set to 'N', p_column_value can be
 *                                    NULL in update mode. Default is 'N'.
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *     The procedure is overloaded for different column type, i.e. VARCHAR2,
 *     NUMBER, and DATE.
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE validate_mandatory (
    p_create_update_flag                    IN     VARCHAR2,
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    p_restricted                            IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_error                                 BOOLEAN := FALSE;

BEGIN

    IF p_restricted = 'N' THEN
        IF ( p_create_update_flag = 'C' AND
             ( p_column_value IS NULL OR
               p_column_value = FND_API.G_MISS_CHAR ) ) OR
           ( p_create_update_flag = 'U' AND
             p_column_value = FND_API.G_MISS_CHAR )
        THEN
            l_error := TRUE;
        END IF;
    ELSE
        IF ( p_column_value IS NULL OR
             p_column_value = FND_API.G_MISS_CHAR )
        THEN
            l_error := TRUE;
        END IF;
    END IF;

    IF l_error THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END validate_mandatory;

PROCEDURE validate_mandatory (
    p_create_update_flag                    IN     VARCHAR2,
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     NUMBER,
    p_restricted                            IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_error                                 BOOLEAN := FALSE;

BEGIN

    IF p_restricted = 'N' THEN
        IF ( p_create_update_flag = 'C' AND
             ( p_column_value IS NULL OR
               p_column_value = FND_API.G_MISS_NUM ) ) OR
           ( p_create_update_flag = 'U' AND
             p_column_value = FND_API.G_MISS_NUM )
        THEN
            l_error := TRUE;
        END IF;
    ELSE
        IF ( p_column_value IS NULL OR
             p_column_value = FND_API.G_MISS_NUM )
        THEN
            l_error := TRUE;
        END IF;
    END IF;

    IF l_error THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END validate_mandatory;

PROCEDURE validate_mandatory (
    p_create_update_flag                    IN     VARCHAR2,
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     DATE,
    p_restricted                            IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_error                                 BOOLEAN := FALSE;

BEGIN

    IF p_restricted = 'N' THEN
        IF ( p_create_update_flag = 'C' AND
             ( p_column_value IS NULL OR
               p_column_value = FND_API.G_MISS_DATE ) ) OR
           ( p_create_update_flag = 'U' AND
             p_column_value = FND_API.G_MISS_DATE )
        THEN
            l_error := TRUE;
        END IF;
    ELSE
        IF ( p_column_value IS NULL OR
             p_column_value = FND_API.G_MISS_DATE )
        THEN
            l_error := TRUE;
        END IF;
    END IF;

    IF l_error THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END validate_mandatory;

/**
 * PROCEDURE validate_nonupdateable
 *
 * DESCRIPTION
 *     Validate nonupdateable field.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_column                       Column name you want to validate.
 *     p_column_value                 Column value
 *     p_old_column_value             Current database column value
 *     p_restriced                    If set to 'Y', column can not be updated
 *                                    even the database value is null. This is
 *                                    default value and as long as p_column_value
 *                                    is not equal to p_old_column_error, return
 *                                    status will be set to error.
 *                                    If set to 'N', if database value is null,
 *                                    we can update it to a value. If database value
 *                                    is not null and if p_column_value is not equal
 *                                    to p_old_column_value, return status will be
 *                                    set to error.
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *     The procedure is overloaded for different column type, i.e. VARCHAR2,
 *     NUMBER, and DATE. The procedure should be called in update mode.
 *
 *     For example:
 *         IF p_create_update_flag = 'U' THEN
 *             validate_nonupdateable( ... );
 *         END IF;
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE validate_nonupdateable (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    p_old_column_value                      IN     VARCHAR2,
    p_restricted                            IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_old_column_value                      VARCHAR2(2000);
    l_error                                 BOOLEAN := FALSE;

BEGIN

    IF p_column_value IS NOT NULL THEN
      l_old_column_value := NVL(p_old_column_value, FND_API.G_MISS_CHAR);

      IF p_restricted = 'Y' THEN
        IF p_column_value <> l_old_column_value THEN
          l_error := TRUE;
        END IF;
      ELSE
        IF l_old_column_value <> FND_API.G_MISS_CHAR AND
           (p_column_value = FND_API.G_MISS_CHAR OR
            p_column_value <> l_old_column_value)
        THEN
          l_error := TRUE;
        END IF;
      END IF;
    END IF;

    IF l_error THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END validate_nonupdateable;

PROCEDURE validate_nonupdateable (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     NUMBER,
    p_old_column_value                      IN     NUMBER,
    p_restricted                            IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_old_column_value                      NUMBER;
    l_error                                 BOOLEAN := FALSE;

BEGIN

    IF p_column_value IS NOT NULL THEN
      l_old_column_value := NVL(p_old_column_value, FND_API.G_MISS_NUM);

      IF p_restricted = 'Y' THEN
        IF p_column_value <> l_old_column_value THEN
          l_error := TRUE;
        END IF;
      ELSE
        IF l_old_column_value <> FND_API.G_MISS_NUM AND
           (p_column_value = FND_API.G_MISS_NUM OR
            p_column_value <> l_old_column_value)
        THEN
          l_error := TRUE;
        END IF;
      END IF;
    END IF;

    IF l_error THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END validate_nonupdateable;

PROCEDURE validate_nonupdateable (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     DATE,
    p_old_column_value                      IN     DATE,
    p_restricted                            IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_old_column_value                      DATE;
    l_error                                 BOOLEAN := FALSE;

BEGIN

    IF p_column_value IS NOT NULL THEN
      l_old_column_value := NVL(p_old_column_value, FND_API.G_MISS_DATE);

      IF p_restricted = 'Y' THEN
        IF p_column_value <> l_old_column_value THEN
          l_error := TRUE;
        END IF;
      ELSE
        IF l_old_column_value <> FND_API.G_MISS_DATE AND
           (p_column_value = FND_API.G_MISS_DATE OR
            p_column_value <> l_old_column_value)
        THEN
          l_error := TRUE;
        END IF;
      END IF;
    END IF;

    IF l_error THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END validate_nonupdateable;

/**
 * PROCEDURE validate_start_end_date
 *
 * DESCRIPTION
 *     Validate start data can not be earlier than end date.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           'C' ( create mode ), 'U' ( update mode )
 *     p_start_date_column_name       Column name of start date
 *     p_start_date                   New start date
 *     p_old_start_date               Database start date in update mode
 *     p_end_date_column_name         Column name of end date
 *     p_end_date                     New end date
 *     p_old_end_date                 Database end date in update mode
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

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
       ( l_start_date IS NULL OR
         l_start_date = FND_API.G_MISS_DATE OR
         l_start_date > l_end_date )
    THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_DATE_GREATER' );
        FND_MESSAGE.SET_TOKEN( 'DATE2', p_end_date_column_name );
        FND_MESSAGE.SET_TOKEN( 'DATE1', p_start_date_column_name );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END validate_start_end_date;

/**
 * PROCEDURE validate_cannot_update_to_null
 *
 * DESCRIPTION
 *     Validate column cannot be updated to null.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_column                       Column name you want to validate.
 *     p_column_value                 Column value
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *     The procedure is overloaded for different column type, i.e. VARCHAR2,
 *     NUMBER, and DATE. The procedure should be called in update mode.
 *
 *     For example:
 *         IF p_create_update_flag = 'U' THEN
 *             validate_cannot_update_to_null( ... );
 *         END IF;
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE validate_cannot_update_to_null (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

BEGIN

    IF p_column_value = FND_API.G_MISS_CHAR THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_TO_NULL' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END validate_cannot_update_to_null;

PROCEDURE validate_cannot_update_to_null (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

BEGIN

    IF p_column_value = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_TO_NULL' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END validate_cannot_update_to_null;

PROCEDURE validate_cannot_update_to_null (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     DATE,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

BEGIN

    IF p_column_value = FND_API.G_MISS_DATE THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_TO_NULL' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END validate_cannot_update_to_null;

/**
 * PROCEDURE validate_cannot_update_to_null
 *
 * DESCRIPTION
 *     Validate column cannot be updated to null.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_column                       Column name you want to validate.
 *     p_lookup_table                 Table/view name you want to validate against to.
 *                                    For now, we are supporting
 *                                       AR_LOOKUPS
 *                                       SO_LOOKUPS
 *                                       OE_SHIP_METHODS_V
 *                                       FND_LOOKUP_VALUES
 *                                    Default value is AR_LOOKUPS
 *     p_lookup_type                  FND lookup type
 *     p_column_value                 Column value
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *     The procedure is using cache strategy for performance improvement.
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE validate_lookup (
    p_column                                IN     VARCHAR2,
    p_lookup_table                          IN     VARCHAR2,
    p_lookup_type                           IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_error                                 BOOLEAN := FALSE;

BEGIN

    IF p_column_value IS NOT NULL AND
       p_column_value <> FND_API.G_MISS_CHAR THEN

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
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_LOOKUP' );
            FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
            FND_MESSAGE.SET_TOKEN( 'LOOKUP_TYPE', p_lookup_type );
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

END validate_lookup;

/**
 * PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Enable file or dbms debug based on profile options.
 *     HZ_API_FILE_DEBUG_ON : Turn on/off file debug, i.e. debug message
 *                            will be written to a user specified file.
 *                            The file name and file path is stored in
 *                            profiles HZ_API_DEBUG_FILE_PATH and
 *                            HZ_API_DEBUG_FILE_NAME. File path must be
 *                            database writable.
 *     HZ_API_DBMS_DEBUG_ON : Turn on/off dbms debug.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE enable_debug IS

BEGIN

    G_COUNT := G_COUNT + 1;

    IF G_COUNT > 1 THEN
        RETURN;
    END IF;

    IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' THEN

        G_FILE_NAME := FND_PROFILE.value( 'HZ_API_DEBUG_FILE_NAME' );
        G_FILE_PATH := FND_PROFILE.value( 'HZ_API_DEBUG_FILE_PATH' );
        enable_file_debug;
/*
    ELSIF FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y' THEN

        -- Enable calls to dbms_output.
        DBMS_OUTPUT.enable( G_BUFFER_SIZE );
        G_DBMS_DEBUG := TRUE;
*/
    END IF;

END enable_debug;

/**
 * PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Disable file or dbms debug.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE disable_debug IS

BEGIN

    G_COUNT := G_COUNT - 1;

    IF G_COUNT > 0 THEN
        RETURN;
    END IF;

    IF G_FILE_DEBUG THEN
        IF UTL_FILE.is_open( G_FILE ) THEN
        BEGIN
            UTL_FILE.fclose( G_FILE );
            G_FILE_DEBUG := FALSE;
        EXCEPTION
            WHEN UTL_FILE.INVALID_FILEHANDLE THEN
                FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_INVALID_HANDLE' );
                FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
                FND_MSG_PUB.ADD;
                G_FILE_DEBUG := FALSE;
                G_COUNT := 0;
                RAISE FND_API.G_EXC_ERROR;

            WHEN UTL_FILE.WRITE_ERROR THEN
                FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_WRITE_ERROR' );
                FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
                FND_MSG_PUB.ADD;
                G_FILE_DEBUG := FALSE;
                G_COUNT := 0;
                RAISE FND_API.G_EXC_ERROR;
        END;
        END IF;
/*
    ELSIF G_DBMS_DEBUG THEN
        G_DBMS_DEBUG := FALSE;
*/
    END IF;

END disable_debug;

/**
 * PROCEDURE debug
 *
 * DESCRIPTION
 *     Put debug message.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_message                      Message you want to put in log.
 *     p_prefix                       Prefix of the message. Default value is
 *                                    DEBUG.
 *     p_msg_level                    Message Level.Default value is 1 and the value should be between
 *                                    1 and 6 corresponding to FND_LOG's
 *                                    LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
 *                                    LEVEL_ERROR      CONSTANT NUMBER  := 5;
 *                                    LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
 *                                    LEVEL_EVENT      CONSTANT NUMBER  := 3;
 *                                    LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
 *                                    LEVEL_STATEMENT  CONSTANT NUMBER  := 1;
 *     p_module_prefix                Module prefix to store package name,form name.Default value is
 *                                    HZ_Package.
 *     p_module                       Module to store Procedure Name. Default value is HZ_Module.
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   09-10-2001    Jianying Huang      o Bug 1986499: Modified 'debug' procedure to take care of
 *                                       p_message is passed as NULL: Initilized l_len, l_times to
 *                                       0 and added NVL around l_len.
 *   10-Dec-2003   Ramesh Ch           Added p_msg_level,p_module_prefix,p_module parameters
 *                                     with default values as part of Common Logging Infrastrycture Uptake.
 *                                     Also modified the logic to call FND_LOG.STRING procedure to store the
 *                                     messages in FND_LOG_MESSAGES.
 */

PROCEDURE debug (
    p_message                               IN     VARCHAR2,
    p_prefix                                IN     VARCHAR2 DEFAULT 'DEBUG',
    p_msg_level                             IN     NUMBER   DEFAULT FND_LOG.LEVEL_STATEMENT,
    p_module_prefix                         IN     VARCHAR2 DEFAULT 'HZ_Package',
    p_module                                IN     VARCHAR2 DEFAULT 'HZ_Module'
) IS

    l_message                               VARCHAR2(4000);
    l_module                                VARCHAR2(255);

BEGIN

    l_module  :=SUBSTRB('ar.hz.plsql.'||p_module_prefix||'.'||p_module,1,255);

    IF p_prefix IS NOT NULL THEN
      l_message :=SUBSTRB(p_prefix||'-'||p_message,1,4000);
    ELSE
      l_message :=SUBSTRB(p_message,1,4000);
    END IF;

  if( p_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(p_msg_level,l_module,l_message);
  end if;

END debug;

/**
 * PROCEDURE debug_return_messages
 *
 * DESCRIPTION
 *     Put debug messages based on message count in message stack.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_msg_count                    Message count in message stack.
 *     p_msg_data                     Message data if message count is 1.
 *     p_msg_type                     Message type used as prefix of the message.
 *     p_msg_level                    Message Level.Default value is 1 and the value should be between
 *                                    1 and 6 corresponding to FND_LOG's
 *                                    LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
 *                                    LEVEL_ERROR      CONSTANT NUMBER  := 5;
 *                                    LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
 *                                    LEVEL_EVENT      CONSTANT NUMBER  := 3;
 *                                    LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
 *                                    LEVEL_STATEMENT  CONSTANT NUMBER  := 1;
 *     p_module_prefix                Module prefix to store package name,form name.Default value is
 *                                    HZ_Package.
 *     p_module                       Module to store Procedure Name. Default value is HZ_Module.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   10-Dec-2003   Ramesh Ch           Added p_msg_level,p_module_prefix,p_module parameters
 *                                     with default values as part of Common Logging Infrastrycture Uptake.
 *                                     Also passed in the additional parameters when calling debug procedure.
 *
 *
 */

PROCEDURE debug_return_messages (
    p_msg_count                             IN     NUMBER,
    p_msg_data                              IN     VARCHAR2,
    p_msg_type                              IN     VARCHAR2 DEFAULT 'ERROR',
    p_msg_level                             IN     NUMBER   DEFAULT FND_LOG.LEVEL_STATEMENT,
    p_module_prefix                         IN     VARCHAR2 DEFAULT 'HZ_Package',
    p_module                                IN     VARCHAR2 DEFAULT 'HZ_Module'
) IS

    i                                       NUMBER;

BEGIN

    IF (p_msg_count <= 0) or p_msg_count is null THEN
        RETURN;
    END IF;

    IF p_msg_count = 1 THEN
        debug( p_msg_data, p_msg_type,p_msg_level,p_module_prefix,p_module);
    ELSE
        FOR i IN 1..p_msg_count LOOP
            debug( FND_MSG_PUB.Get( p_encoded => FND_API.G_FALSE ), p_msg_type,p_msg_level,p_module_prefix,p_module);
        END LOOP;
    END IF;

END debug_return_messages;

/**
 * FUNCTION get_session_process_id
 *
 * DESCRIPTION
 *     Return OS process id of current session.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

FUNCTION get_session_process_id RETURN VARCHAR2 IS

    l_spid                                  V$PROCESS.spid%TYPE;

BEGIN

    SELECT SPID INTO l_spid
    FROM V$PROCESS
    WHERE ADDR = (
        SELECT PADDR
        FROM V$SESSION
        WHERE AUDSID = USERENV('SESSIONID') );

    RETURN ( l_spid );

END get_session_process_id;

/**
 * FUNCTION
 *     created_by
 *     creation_date
 *     last_updated_by
 *     last_update_date
 *     last_update_login
 *     request_id
 *     program_id
 *     program_application_id
 *     program_update_date
 *     user_id
 *     application_id
 *
 * DESCRIPTION
 *     Return standard who value.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   01-27-2003    Sreedhar Mohan      o Added application_id.
 *
 */

FUNCTION created_by RETURN NUMBER IS
BEGIN

    RETURN NVL(FND_GLOBAL.user_id,-1);

END created_by;

FUNCTION creation_date RETURN DATE IS
BEGIN

    RETURN SYSDATE;

END creation_date;

FUNCTION last_updated_by RETURN NUMBER IS
BEGIN

    RETURN NVL(FND_GLOBAL.user_id,-1);

END last_updated_by;

FUNCTION last_update_date RETURN DATE IS
BEGIN

    RETURN SYSDATE;

END last_update_date;

FUNCTION last_update_login RETURN NUMBER IS
BEGIN

    IF FND_GLOBAL.conc_login_id = -1 OR
       FND_GLOBAL.conc_login_id IS NULL
    THEN
        RETURN FND_GLOBAL.login_id;
    ELSE
        RETURN FND_GLOBAL.conc_login_id;
    END IF;

END last_update_login;

FUNCTION request_id RETURN NUMBER IS
BEGIN

    IF FND_GLOBAL.conc_request_id = -1 OR
       FND_GLOBAL.conc_request_id IS NULL
    THEN
        RETURN NULL;
    ELSE
        RETURN FND_GLOBAL.conc_request_id;
    END IF;

END request_id;

FUNCTION program_id RETURN NUMBER IS
BEGIN

    IF FND_GLOBAL.conc_program_id = -1 OR
       FND_GLOBAL.conc_program_id IS NULL
    THEN
        RETURN NULL;
    ELSE
        RETURN FND_GLOBAL.conc_program_id;
    END IF;

END program_id;

FUNCTION program_application_id RETURN NUMBER IS
BEGIN

    IF FND_GLOBAL.prog_appl_id = -1 OR
       FND_GLOBAL.prog_appl_id IS NULL
    THEN
        RETURN NULL;
    ELSE
        RETURN FND_GLOBAL.prog_appl_id;
    END IF;

END program_application_id;

FUNCTION application_id RETURN NUMBER IS
BEGIN

    IF FND_GLOBAL.resp_appl_id = -1 OR
       FND_GLOBAL.resp_appl_id IS NULL
    THEN
        RETURN NULL;
    ELSE
        RETURN FND_GLOBAL.resp_appl_id;
    END IF;

END application_id;

FUNCTION program_update_date RETURN DATE IS
BEGIN

    IF program_id IS NULL THEN
        RETURN NULL;
    ELSE
        RETURN SYSDATE;
    END IF;

END program_update_date;

FUNCTION user_id RETURN NUMBER IS
BEGIN

    RETURN NVL(FND_GLOBAL.user_id,-1);

END user_id;

/**
 * FUNCTION incl_unrelated_entities
 *
 * DESCRIPTION
 *   Function to check the value of incl_unrelated_entities flag
 *   for a relationship type. the procedure has been put here to
 *   cache the values so that program does not hit database if the
 *   same relationship type has already been read.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_relationship_type            Relationship type.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   02-02-2002    Indrajit Sen        o Created.
 *
 */

FUNCTION incl_unrelated_entities (
    p_relationship_type                     IN     VARCHAR2
) RETURN VARCHAR2 IS

    l_error                                 BOOLEAN := FALSE;

BEGIN

    IF p_relationship_type IS NOT NULL AND
       p_relationship_type <> FND_API.G_MISS_CHAR THEN

        IF NOT search(p_relationship_type || G_SPECIAL_STRING,
                      'RELATIONSHIP_TYPE')
        THEN
            l_error := TRUE;
        END IF;
    END IF;

    IF l_error THEN
        RETURN 'N';
    ELSE
        RETURN 'Y';
    END IF;

END incl_unrelated_entities;

/**
 * FUNCTION Get_SchemaName
 *
 * DESCRIPTION
 *     Return Schema's Name By Given The Application's Short Name.
 *     The function will raise fnd_api.g_exc_unexpected_error if
 *     the short name can not be found in installation and put a
 *     message '<p_app_short_name> is not a valid oracle schema name.'
 *     in the message stack.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_app_short_name               Application short name.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang      o Created.
 *
 */

FUNCTION Get_SchemaName (
    p_app_short_name             IN     VARCHAR2
) RETURN VARCHAR2 IS

    l_status                     VARCHAR2(30);
    l_industry                   VARCHAR2(30);
    l_schema_name                VARCHAR2(30);
    l_return_value               BOOLEAN;

BEGIN

    l_return_value := fnd_installation.get_app_info(
        p_app_short_name, l_status, l_industry, l_schema_name);

    IF l_schema_name IS NULL THEN
      fnd_message.set_name('FND','FND_NO_SCHEMA_NAME');
      fnd_message.set_token('SCHEMA_NAME',p_app_short_name);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSE
      RETURN l_schema_name;
    END IF;

END Get_SchemaName;

/**
 * FUNCTION Get_AppsSchemaName
 *
 * DESCRIPTION
 *     Return APPS Schema's Name
 *     The function will raise fnd_api.g_exc_unexpected_error if
 *     the 'FND' as a short name can not be found in installation.
 *     and put a message 'FND is not a valid oracle schema name.'
 *     in the message stack.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang      o Created.
 *
 */

FUNCTION Get_AppsSchemaName RETURN VARCHAR2 IS

    l_aol_schema                 VARCHAR2(30);
    l_apps_schema                VARCHAR2(30);
    l_apps_mls_schema            VARCHAR2(30);

BEGIN

    l_aol_schema := Get_SchemaName('FND');
    system.ad_apps_private.get_apps_schema_name(
        1, l_aol_schema, l_apps_schema, l_apps_mls_schema);

    RETURN l_apps_schema;

END Get_AppsSchemaName;

/**
 * FUNCTION Get_LookupMeaning
 *
 * DESCRIPTION
 *     Get lookup meaning. Return NULL if lookup code does
 *     not exist.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_lookup_table                 Table/view name you want to validate against to.
 *                                    For now, we are supporting
 *                                       AR_LOOKUPS
 *                                       SO_LOOKUPS
 *                                       OE_SHIP_METHODS_V
 *                                       FND_LOOKUP_VALUES
 *                                    Default value is AR_LOOKUPS
 *     p_lookup_type                  FND lookup type
 *     p_lookup_code                  FND lookup code
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang      o Created.
 *
 */

FUNCTION Get_LookupMeaning (
    p_lookup_table                          IN     VARCHAR2,
    p_lookup_type                           IN     VARCHAR2,
    p_lookup_code                           IN     VARCHAR2
) RETURN VARCHAR2 IS

    l_return                                BOOLEAN;
    l_lookup_meaning                        VARCHAR2(100);

BEGIN
    l_return := search(p_lookup_table || G_SPECIAL_STRING ||
                  p_lookup_type || G_SPECIAL_STRING || p_lookup_code,
                  'LOOKUP', l_lookup_meaning, 'Get_LookupMeaning');
    RETURN l_lookup_meaning;

END Get_LookupMeaning;

/**
 * FUNCTION isColumnHasValue
 *
 * DESCRIPTION
 *    Return 'Y' if user populates the column with some value.
 *    Return 'N' if user does not.
 *    The function supports both V1 and V2 column style. It is
 *    helpful when obsolete a column and raise exception in
 *    development site based on if the column is populated.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_api_version                  'V1' is for V1 API. 'V2' is for V2 API.
 *     p_create_update_flag           'C' is for create. 'U' is for update.
 *     p_column_value                 Value of the column.
 *     p_default_value                Default value of the column. Please note,
 *                                    for V1 API, most columns are defaulted to
 *                                    FND_API.G_MISS_XXX and for V2 API, we do
 *                                    not have default value for most columns.
 *     p_old_column_value             Database value of the column. Only used
 *                                    in update mode.
 *
 * NOTES
 *   I am not making the function as public for now because it is used only by
 *   obsoleting content_source_type.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang      o Created.
 */

FUNCTION isColumnHasValue (
    p_api_version                           IN     VARCHAR2,
    p_create_update_flag                    IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    p_default_value                         IN     VARCHAR2,
    p_old_column_value                      IN     VARCHAR2
) RETURN VARCHAR2 IS

    l_column_value                          VARCHAR2(2000);
    l_old_column_value                      VARCHAR2(2000);

BEGIN

    l_column_value := NVL(p_column_value, FND_API.G_MISS_CHAR);

    IF p_create_update_flag = 'C' AND
       l_column_value <> FND_API.G_MISS_CHAR AND
       l_column_value <> NVL(p_default_value, FND_API.G_MISS_CHAR)
    THEN
      RETURN 'Y';
    ELSE
      l_old_column_value := NVL(p_old_column_value, FND_API.G_MISS_CHAR);

      IF l_column_value <> l_old_column_value AND
         l_column_value <> NVL(p_default_value, FND_API.G_MISS_CHAR)
      THEN
        RETURN 'Y';
      END IF;
    END IF;

    RETURN 'N';

END isColumnHasValue;

FUNCTION isColumnHasValue (
    p_api_version                           IN     VARCHAR2,
    p_create_update_flag                    IN     VARCHAR2,
    p_column_value                          IN     NUMBER,
    p_default_value                         IN     NUMBER,
    p_old_column_value                      IN     NUMBER
) RETURN VARCHAR2 IS

    l_column_value                          NUMBER;
    l_old_column_value                      NUMBER;

BEGIN

    l_column_value := NVL(p_column_value, FND_API.G_MISS_NUM);

    IF p_create_update_flag = 'C' AND
       l_column_value <> FND_API.G_MISS_NUM AND
       l_column_value <> NVL(p_default_value, FND_API.G_MISS_NUM)
    THEN
      RETURN 'Y';
    ELSE
      l_old_column_value := NVL(p_old_column_value, FND_API.G_MISS_NUM);

      IF l_column_value <> l_old_column_value AND
         l_column_value <> NVL(p_default_value, FND_API.G_MISS_NUM)
      THEN
        RETURN 'Y';
      END IF;
    END IF;

    RETURN 'N';

END isColumnHasValue;

FUNCTION isColumnHasValue (
    p_api_version                           IN     VARCHAR2,
    p_create_update_flag                    IN     VARCHAR2,
    p_column_value                          IN     DATE,
    p_default_value                         IN     DATE,
    p_old_column_value                      IN     DATE
) RETURN VARCHAR2 IS

    l_column_value                          DATE;
    l_old_column_value                      DATE;

BEGIN

    l_column_value := NVL(p_column_value, FND_API.G_MISS_DATE);

    IF p_create_update_flag = 'C' AND
       l_column_value <> FND_API.G_MISS_DATE AND
       l_column_value <> NVL(p_default_value, FND_API.G_MISS_DATE)
    THEN
      RETURN 'Y';
    ELSE
      l_old_column_value := NVL(p_old_column_value, FND_API.G_MISS_DATE);

      IF l_column_value <> l_old_column_value AND
         l_column_value <> NVL(p_default_value, FND_API.G_MISS_DATE) AND
         ((p_api_version = 'V1' AND
           (p_column_value IS NULL)) OR
          (p_api_version = 'V2' AND
           p_column_value IS NOT NULL))
      THEN
        RETURN 'Y';
      END IF;
    END IF;

    RETURN 'N';

END isColumnHasValue;

/**
 * FUNCTION Check_ObsoleteColumn
 *
 * DESCRIPTION
 *    Internal use only!!
 *    Set x_return_status to FND_API.G_RET_STS_ERROR when
 *    user is trying to pass value into an obsolete column
 *    in development site.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_api_version                  'V1' is for V1 API. 'V2' is for V2 API.
 *     p_create_update_flag           'C' is for create. 'U' is for update.
 *     p_column                       Column name.
 *     p_column_value                 Value of the column.
 *     p_default_value                Default value of the column. Please note,
 *                                    for V1 API, most columns are defaulted to
 *                                    FND_API.G_MISS_XXX and for V2 API, we do
 *                                    not have default value for most columns.
 *     p_old_column_value             Database value of the column. Only used
 *                                    in update mode.
 *   OUT:
 *     x_return_status                Return FND_API.G_RET_STS_ERROR if user
 *                                    is trying to pass value into an obsolete
 *                                    column in development site.
 *
 * NOTES
 *   I am not making the function as public for now because it is used only by
 *   obsoleting content_source_type. It is worth to call this function only when
 *   you obsolete one column. If you are obsoleting more than one columns, it
 *   is better to cancat them and then decide if need to raise exception. For
 *   this limitation, it is not worth to provide the function for NUMBER and
 *   DATE type of column.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang      o Created.
 */

PROCEDURE Check_ObsoleteColumn (
    p_api_version                           IN     VARCHAR2,
    p_create_update_flag                    IN     VARCHAR2,
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    p_default_value                         IN     VARCHAR2,
    p_old_column_value                      IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS
BEGIN

    IF FND_PROFILE.value('HZ_API_ERR_ON_OBSOLETE_COLUMN') = 'Y' AND
       isColumnHasValue (
         p_api_version, p_create_update_flag,
         p_column_value, p_default_value, p_old_column_value) = 'Y'
    THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OBSOLETE_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END Check_ObsoleteColumn;

FUNCTION is_active (
   start_date_active  IN  date,
   end_date_active IN date)
   RETURN VARCHAR2 IS

   active varchar2(10) := 'Yes';
   BEGIN
      if ((start_date_active > sysdate) OR (sysdate > end_date_active)) then
         active := 'No';
       end if;
      return active;
   END;

/**
 * FUNCTION get_site_use_purpose
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return the first three site use type

 * ARGUMENTS
 *   IN:
 *     p_party_site_id               party site id used to retrieve the site use purpose.
 *
 *   RETURNS    : VARCHAR2
 *
**/
function get_site_use_purpose (
    p_party_site_id                         IN     NUMBER)
RETURN VARCHAR2 IS

  l_site_use_purpose    VARCHAR2(100);
  l_top3_site_use_purposes    VARCHAR2(100) := '';
  l_count                     NUMBER := 0;

  cursor c_site_use_purposes (l_party_site_id IN NUMBER) is
    select al.MEANING
--           psu.site_use_type,
--           psu.primary_per_type
    from hz_party_sites ps,
         hz_party_site_uses psu,
         ar_lookups  al
    where
         ps.party_site_id = l_party_site_id and
         psu.party_site_id = ps.party_site_id and
         psu.status = 'A' and
         al.lookup_type  = 'PARTY_SITE_USE_CODE' and
         al.lookup_code  =  psu.SITE_USE_TYPE
         order by primary_per_type DESC;

BEGIN

  OPEN c_site_use_purposes(p_party_site_id);
  LOOP
  FETCH c_site_use_purposes INTO l_site_use_purpose;

    IF c_site_use_purposes%NOTFOUND THEN
      EXIT;
    END IF;


    IF l_count = 3 THEN
      l_top3_site_use_purposes := concat(l_top3_site_use_purposes, ', ...');
      EXIT;
    END IF;

    IF l_top3_site_use_purposes is not null THEN
      l_top3_site_use_purposes := concat(l_top3_site_use_purposes, ', ');
    END IF;

    l_top3_site_use_purposes := concat(l_top3_site_use_purposes, l_site_use_purpose);

    l_count := l_count + 1;
  END LOOP;
  CLOSE c_site_use_purposes;

  RETURN l_top3_site_use_purposes;
END get_site_use_purpose;

/**
 * FUNCTION get_all_purposes
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return all site use types

 * ARGUMENTS
 *   IN:
 *     p_party_site_id               party site id used to retrieve the site use purpose.
 *
 *   RETURNS    : VARCHAR2
 *
**/
function get_all_purposes (
    p_party_site_id                         IN     NUMBER)
RETURN VARCHAR2 IS

  l_site_use_purpose    VARCHAR2(100);
  l_all_site_use_purposes    VARCHAR2(1000) := '';

  cursor c_site_use_purposes (l_party_site_id IN NUMBER) is
    select al.MEANING
    from hz_party_sites ps,
         hz_party_site_uses psu,
         ar_lookups  al
    where
         ps.party_site_id = l_party_site_id and
         psu.party_site_id = ps.party_site_id and
         psu.status = 'A' and
         al.lookup_type  = 'PARTY_SITE_USE_CODE' and
         al.lookup_code  =  psu.SITE_USE_TYPE
         order by primary_per_type DESC;

BEGIN

  OPEN c_site_use_purposes(p_party_site_id);
  LOOP
  FETCH c_site_use_purposes INTO l_site_use_purpose;

    IF c_site_use_purposes%NOTFOUND THEN
      EXIT;
    END IF;

    IF l_all_site_use_purposes is not null THEN
      l_all_site_use_purposes := concat(l_all_site_use_purposes, ', ');
    END IF;

    l_all_site_use_purposes := concat(l_all_site_use_purposes, l_site_use_purpose);

  END LOOP;
  CLOSE c_site_use_purposes;

  RETURN l_all_site_use_purposes;
END get_all_purposes;

/**
 * FUNCTION get_acct_site_purposes
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return all acct site uses

 * ARGUMENTS
 *   IN:
 *     p_acct_site_id               acct site id used to retrieve the site use purpose.
 *
 *   RETURNS    : VARCHAR2
 *
**/
function get_acct_site_purposes (
    p_acct_site_id                         IN     NUMBER)
RETURN VARCHAR2 IS

  l_site_use_purpose    VARCHAR2(100);
  l_all_site_use_purposes    VARCHAR2(1000) := '';

  cursor c_site_use_purposes (l_acct_site_id IN NUMBER) is
    select al.MEANING
    from hz_cust_acct_sites s,
         hz_cust_site_uses u,
         ar_lookups  al
    where
         s.cust_acct_site_id = l_acct_site_id and
         u.cust_acct_site_id = s.cust_acct_site_id and
         u.status = 'A' and
         al.lookup_type  = 'SITE_USE_CODE' and
         al.lookup_code  =  u.SITE_USE_CODE
         order by al.MEANING;

BEGIN

  OPEN c_site_use_purposes(p_acct_site_id);
  LOOP
  FETCH c_site_use_purposes INTO l_site_use_purpose;

    IF c_site_use_purposes%NOTFOUND THEN
      EXIT;
    END IF;

    IF l_all_site_use_purposes is not null THEN
      l_all_site_use_purposes := concat(l_all_site_use_purposes, ', ');
    END IF;

    l_all_site_use_purposes := concat(l_all_site_use_purposes, l_site_use_purpose);

  END LOOP;
  CLOSE c_site_use_purposes;

  RETURN l_all_site_use_purposes;
END get_acct_site_purposes;


/**
 * FUNCTION validate_flex_address
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will validate the flex address
 *    and return 'Y'/'N'
 * ARGUMENTS
 *   IN:
 *     p_context_value : context_value
 *     p_address1 :      address1
 *     p_address2 :      address2
 *     p_address3 :      address3
 *     p_address4 :      address4
 *     p_address_lines_phonetic: address_lines_phonetic
 *     p_city :          city
 *     p_county :        county
 *     p_postal_code :   postal_code
 *     p_province :      province
 *     p_state :         state
 *     p_attribute1 :    attribute1
 *     p_attribute2 :    attribute2
 *     p_attribute3 :    attribute3
 *     p_attribute4 :    attribute4
 *     p_attribute5 :    attribute5
 *     p_attribute6 :    attribute6
 *     p_attribute7 :    attribute7
 *     p_attribute8 :    attribute8
 *     p_attribute9 :    attribute9
 *     p_attribute10:    attribute10
 *     p_attribute11:    attribute11
 *     p_attribute12:    attribute12
 *     p_attribute13:    attribute13
 *     p_attribute14:    attribute14
 *     p_attribute15:    attribute15
 *     p_attribute16:    attribute16
 *     p_attribute17:    attribute17
 *     p_attribute18:    attribute18
 *     p_attribute19:    attribute19
 *     p_attribute20:    attribute20
 *     p_postal_plu4_code :   postal_plu4_code --added against bug 7671107
 *
 *   RETURNS    : VARCHAR2
 *
**/
FUNCTION validate_flex_address (
    p_context_value                               IN     VARCHAR2,
    p_address1                                    IN     VARCHAR2,
    p_address2                                    IN     VARCHAR2,
    p_address3                                    IN     VARCHAR2,
    p_address4                                    IN     VARCHAR2,
    p_address_lines_phonetic                      IN     VARCHAR2,
    p_city                                        IN     VARCHAR2,
    p_county                                      IN     VARCHAR2,
    p_postal_code                                 IN     VARCHAR2,
    p_province                                    IN     VARCHAR2,
    p_state                                       IN     VARCHAR2,
    p_attribute1                                  IN     VARCHAR2,
    p_attribute2                                  IN     VARCHAR2,
    p_attribute3                                  IN     VARCHAR2,
    p_attribute4                                  IN     VARCHAR2,
    p_attribute5                                  IN     VARCHAR2,
    p_attribute6                                  IN     VARCHAR2,
    p_attribute7                                  IN     VARCHAR2,
    p_attribute8                                  IN     VARCHAR2,
    p_attribute9                                  IN     VARCHAR2,
    p_attribute10                                 IN     VARCHAR2,
    p_attribute11                                 IN     VARCHAR2,
    p_attribute12                                 IN     VARCHAR2,
    p_attribute13                                 IN     VARCHAR2,
    p_attribute14                                 IN     VARCHAR2,
    p_attribute15                                 IN     VARCHAR2,
    p_attribute16                                 IN     VARCHAR2,
    p_attribute17                                 IN     VARCHAR2,
    p_attribute18                                 IN     VARCHAR2,
    p_attribute19                                 IN     VARCHAR2,
    p_attribute20                                 IN     VARCHAR2,
    p_postal_plu4_code                            IN     VARCHAR2 --added against bug 7671107

) RETURN VARCHAR2 IS

    l_return                            VARCHAR2(1) := 'N';
    appl_short_name         varchar2(30) := 'AR';
    desc_flex_name          varchar2(30) := 'Remit Address HZ';
    values_or_ids           varchar2(10) := 'I'; --FND BUG 4220582
    validation_date         DATE         := SYSDATE;
    error_msg               VARCHAR2(5000);
    errors_received        EXCEPTION;

BEGIN

--*********************************************************
--* set the context value                                 *
--*********************************************************
FND_FLEX_DESCVAL.set_context_value(p_context_value);
--*********************************************************
--* set the address attributes value                      *
--*********************************************************
fnd_flex_descval.set_column_value('ADDRESS1', p_address1 );
fnd_flex_descval.set_column_value('ADDRESS2', p_address2 );
fnd_flex_descval.set_column_value('ADDRESS3', p_address3 );
fnd_flex_descval.set_column_value('ADDRESS4', p_address4 );
fnd_flex_descval.set_column_value('ADDRESS_LINES_PHONETIC', p_address_lines_phonetic );
fnd_flex_descval.set_column_value('CITY', p_city );
fnd_flex_descval.set_column_value('COUNTY', p_county );
fnd_flex_descval.set_column_value('STATE', p_state );
fnd_flex_descval.set_column_value('PROVINCE', p_province );
fnd_flex_descval.set_column_value('POSTAL_CODE', p_postal_code);
fnd_flex_descval.set_column_value('ATTRIBUTE1', p_attribute1 );
fnd_flex_descval.set_column_value('ATTRIBUTE2', p_attribute2 );
fnd_flex_descval.set_column_value('ATTRIBUTE3', p_attribute3 );
fnd_flex_descval.set_column_value('ATTRIBUTE4', p_attribute4 );
fnd_flex_descval.set_column_value('ATTRIBUTE5', p_attribute5 );
fnd_flex_descval.set_column_value('ATTRIBUTE6', p_attribute6 );
fnd_flex_descval.set_column_value('ATTRIBUTE7', p_attribute7 );
fnd_flex_descval.set_column_value('ATTRIBUTE8', p_attribute8 );
fnd_flex_descval.set_column_value('ATTRIBUTE9', p_attribute9 );
fnd_flex_descval.set_column_value('ATTRIBUTE10', p_attribute10 );
fnd_flex_descval.set_column_value('ATTRIBUTE11', p_attribute11 );
fnd_flex_descval.set_column_value('ATTRIBUTE12', p_attribute12 );
fnd_flex_descval.set_column_value('ATTRIBUTE13', p_attribute13 );
fnd_flex_descval.set_column_value('ATTRIBUTE14', p_attribute14 );
fnd_flex_descval.set_column_value('ATTRIBUTE15', p_attribute15 );
fnd_flex_descval.set_column_value('ATTRIBUTE16', p_attribute16 );
fnd_flex_descval.set_column_value('ATTRIBUTE17', p_attribute17 );
fnd_flex_descval.set_column_value('ATTRIBUTE18', p_attribute18 );
fnd_flex_descval.set_column_value('ATTRIBUTE19', p_attribute19 );
fnd_flex_descval.set_column_value('ATTRIBUTE20', p_attribute20 );
fnd_flex_descval.set_column_value('POSTAL_PLUS4_CODE', p_postal_plu4_code); -- added against bug 7671107

IF  FND_FLEX_DESCVAL.validate_desccols(
      appl_short_name,
      desc_flex_name,
      values_or_ids,
      validation_date)
THEN
      l_return := 'Y';
      return l_return;
ELSE
   RAISE errors_received;
END IF;

EXCEPTION
 WHEN errors_received THEN
   error_msg := fnd_flex_descval.encoded_error_message;
   FND_MESSAGE.SET_ENCODED(error_msg);
   FND_MSG_PUB.Add;
   return l_return;
 WHEN others THEN
   return l_return;

END validate_flex_address;

/**
 * FUNCTION validate_desc_flex
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will validate the descriptive flex
 *    and return 'Y'/'N'
 * ARGUMENTS
 *   IN:
 *     p_appl_short_name:appl_short_name
 *     p_desc_flex_name :desc_flex_name
 *     p_context_value : context_value
 *     p_attribute1 :    attribute1
 *     p_attribute2 :    attribute2
 *     p_attribute3 :    attribute3
 *     p_attribute4 :    attribute4
 *     p_attribute5 :    attribute5
 *     p_attribute6 :    attribute6
 *     p_attribute7 :    attribute7
 *     p_attribute8 :    attribute8
 *     p_attribute9 :    attribute9
 *     p_attribute10:    attribute10
 *     p_attribute11:    attribute11
 *     p_attribute12:    attribute12
 *     p_attribute13:    attribute13
 *     p_attribute14:    attribute14
 *     p_attribute15:    attribute15
 *     p_attribute16:    attribute16
 *     p_attribute17:    attribute17
 *     p_attribute18:    attribute18
 *     p_attribute19:    attribute19
 *     p_attribute20:    attribute20
 *     p_attribute21:    attribute21
 *     p_attribute22:    attribute22
 *     p_attribute23:    attribute23
 *     p_attribute24:    attribute24
 *   RETURNS    : VARCHAR2
 *
**/
FUNCTION validate_desc_flex (
    p_appl_short_name                             IN     VARCHAR2,
    p_desc_flex_name                              IN     VARCHAR2,
    p_context_value                               IN     VARCHAR2,
    p_attribute1                                  IN     VARCHAR2,
    p_attribute2                                  IN     VARCHAR2,
    p_attribute3                                  IN     VARCHAR2,
    p_attribute4                                  IN     VARCHAR2,
    p_attribute5                                  IN     VARCHAR2,
    p_attribute6                                  IN     VARCHAR2,
    p_attribute7                                  IN     VARCHAR2,
    p_attribute8                                  IN     VARCHAR2,
    p_attribute9                                  IN     VARCHAR2,
    p_attribute10                                 IN     VARCHAR2,
    p_attribute11                                 IN     VARCHAR2,
    p_attribute12                                 IN     VARCHAR2,
    p_attribute13                                 IN     VARCHAR2,
    p_attribute14                                 IN     VARCHAR2,
    p_attribute15                                 IN     VARCHAR2,
    p_attribute16                                 IN     VARCHAR2,
    p_attribute17                                 IN     VARCHAR2,
    p_attribute18                                 IN     VARCHAR2,
    p_attribute19                                 IN     VARCHAR2,
    p_attribute20                                 IN     VARCHAR2,
    p_attribute21                                 IN     VARCHAR2,
    p_attribute22                                 IN     VARCHAR2,
    p_attribute23                                 IN     VARCHAR2,
    p_attribute24                                 IN     VARCHAR2
) RETURN VARCHAR2 IS

    l_return                            VARCHAR2(1) := 'N';
    appl_short_name         varchar2(30) := p_appl_short_name;
    desc_flex_name          varchar2(30) := p_desc_flex_name;
    values_or_ids           varchar2(10) := 'I'; --Bug 5356950
    validation_date         DATE         := SYSDATE;
    error_msg               VARCHAR2(5000);
    errors_received        EXCEPTION;

BEGIN

--*********************************************************
--* set the context value                                 *
--*********************************************************
FND_FLEX_DESCVAL.set_context_value(p_context_value);
--*********************************************************
--* set the attributes value                                 *
--*********************************************************
fnd_flex_descval.set_column_value('ATTRIBUTE1', p_attribute1 );
fnd_flex_descval.set_column_value('ATTRIBUTE2', p_attribute2 );
fnd_flex_descval.set_column_value('ATTRIBUTE3', p_attribute3 );
fnd_flex_descval.set_column_value('ATTRIBUTE4', p_attribute4 );
fnd_flex_descval.set_column_value('ATTRIBUTE5', p_attribute5 );
fnd_flex_descval.set_column_value('ATTRIBUTE6', p_attribute6 );
fnd_flex_descval.set_column_value('ATTRIBUTE7', p_attribute7 );
fnd_flex_descval.set_column_value('ATTRIBUTE8', p_attribute8 );
fnd_flex_descval.set_column_value('ATTRIBUTE9', p_attribute9 );
fnd_flex_descval.set_column_value('ATTRIBUTE10', p_attribute10 );
fnd_flex_descval.set_column_value('ATTRIBUTE11', p_attribute11 );
fnd_flex_descval.set_column_value('ATTRIBUTE12', p_attribute12 );
fnd_flex_descval.set_column_value('ATTRIBUTE13', p_attribute13 );
fnd_flex_descval.set_column_value('ATTRIBUTE14', p_attribute14 );
fnd_flex_descval.set_column_value('ATTRIBUTE15', p_attribute15 );
fnd_flex_descval.set_column_value('ATTRIBUTE16', p_attribute16 );
fnd_flex_descval.set_column_value('ATTRIBUTE17', p_attribute17 );
fnd_flex_descval.set_column_value('ATTRIBUTE18', p_attribute18 );
fnd_flex_descval.set_column_value('ATTRIBUTE19', p_attribute19 );
fnd_flex_descval.set_column_value('ATTRIBUTE20', p_attribute20 );
IF p_desc_flex_name <> 'HZ_PARTY_SITES' THEN
fnd_flex_descval.set_column_value('ATTRIBUTE21', p_attribute21 );
fnd_flex_descval.set_column_value('ATTRIBUTE22', p_attribute22 );
fnd_flex_descval.set_column_value('ATTRIBUTE23', p_attribute23 );
fnd_flex_descval.set_column_value('ATTRIBUTE24', p_attribute24 );
END IF;

IF  FND_FLEX_DESCVAL.validate_desccols(
      appl_short_name,
      desc_flex_name,
      values_or_ids,
      validation_date)
THEN
      l_return := 'Y';
      return l_return;
ELSE
   RAISE errors_received;
END IF;

EXCEPTION
 WHEN errors_received THEN
   error_msg := fnd_flex_descval.encoded_error_message;
   FND_MESSAGE.SET_ENCODED(error_msg);
   FND_MSG_PUB.Add;
   return l_return;
 WHEN others THEN
   return l_return;

END validate_desc_flex;

/**
 * FUNCTION get_org_contact_role
 *
 * DESCRIPTION
 *    used by common party UI .
 *    added by albert (tsli)
 *    will return the first three org contact roles

 * ARGUMENTS
 *   IN:
 *     p_org_contact_id               org contact id used to retrieve the org contact roles.
 *
 *   RETURNS    : VARCHAR2
 *
**/

FUNCTION get_org_contact_role (
    p_org_contact_id              IN     NUMBER
) RETURN VARCHAR2 IS

    TYPE varchar2_table IS TABLE OF VARCHAR2(80); --5960623
    org_contact_roles_tab         varchar2_table;

    l_top3_org_contact_roles      VARCHAR2(100);
    l_count                       NUMBER;

    CURSOR c_org_contact_roles IS
    SELECT lu.meaning
    FROM   hz_org_contact_roles ocr,
           fnd_lookup_values lu
    WHERE  ocr.org_contact_id = p_org_contact_id
    AND    ocr.status = 'A'
    AND    lu.view_application_id = 222
    AND    lu.language = userenv('LANG')
    AND    lu.lookup_type = 'CONTACT_ROLE_TYPE'
    AND    lu.lookup_code = ocr.role_type;

BEGIN

    OPEN c_org_contact_roles;
    FETCH c_org_contact_roles BULK COLLECT INTO org_contact_roles_tab;

    l_top3_org_contact_roles := '';

    IF org_contact_roles_tab.count > 0 THEN
      l_count := 1;

      WHILE (l_count <= 3 AND l_count <= org_contact_roles_tab.count)
      LOOP
        IF l_count > 1 THEN
          l_top3_org_contact_roles := l_top3_org_contact_roles || ', ';
        END IF;

        l_top3_org_contact_roles := l_top3_org_contact_roles ||
                                    org_contact_roles_tab(l_count);


        l_count := l_count + 1;
      END LOOP;

      IF org_contact_roles_tab.count > 3 THEN
        l_top3_org_contact_roles := l_top3_org_contact_roles || ', ...';
      END IF;
    END IF;
    CLOSE c_org_contact_roles;

    RETURN l_top3_org_contact_roles;

END get_org_contact_role;

/**
 * FUNCTION get_primary_phone
 *
 * DESCRIPTION
 *    used by common party UI .
 *    added by albert (tsli)
 *    will return the primary phone
 * ARGUMENTS
 *   IN:
 *     p_party_id               party id used to retrieve the primary phone
 *
 *   RETURNS    : VARCHAR2
 *
**/

function get_primary_phone (
    p_party_id                         IN     NUMBER,
    p_display_purpose                  IN     VARCHAR2 := fnd_api.g_true)
RETURN VARCHAR2 IS
l_contact_point_id NUMBER;
BEGIN

    BEGIN
    select
        contact_point_id
    INTO l_contact_point_id
    from hz_contact_points CPPH
    where contact_point_type = 'PHONE'
    and primary_flag = 'Y'
    and status = 'A'
    and OWNER_TABLE_NAME = 'HZ_PARTIES'
    and OWNER_TABLE_ID = p_party_id
    and rownum = 1;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    END;

    RETURN hz_format_phone_v2pub.get_formatted_phone(l_contact_point_id,p_display_purpose);
END get_primary_phone;

/**
 * FUNCTION get_primary_email
 *
 * DESCRIPTION
 *    used by common party UI .
 *    added by albert (tsli)
 *    will return the primary email
 * ARGUMENTS
 *   IN:
 *     p_party_id               party id used to retrieve the primary email
 *
 *   RETURNS    : VARCHAR2
 *
**/
function get_primary_email (
    p_party_id                         IN     NUMBER)
RETURN VARCHAR2 IS
l_primary_email VARCHAR2(2000);
BEGIN

    select email_address
    INTO l_primary_email
    from hz_contact_points
    where contact_point_type = 'EMAIL'
    and primary_flag = 'Y'
    and status = 'A'
    and OWNER_TABLE_NAME = 'HZ_PARTIES'
    and OWNER_TABLE_ID = p_party_id
    and rownum = 1;

    RETURN l_primary_email;
END get_primary_email;

PROCEDURE find_index_name(
                        p_index_name OUT NOCOPY VARCHAR2) IS
  tmp_errm VARCHAR2(500);
  n NUMBER;
  m NUMBER;
  i NUMBER;
  BEGIN
   n := INSTR(sqlerrm, '(', 1,1) ;
   m := INSTR(sqlerrm, ')', 1,1) ;
   i := m -n;
   tmp_errm := SUBSTRB(sqlerrm, n, i);
   n := INSTR(tmp_errm, '.', 1,1) ;
   p_index_name := SUBSTRB(tmp_errm, n+1, i-1);
END find_index_name;


/**
 * FUNCTION GET_YAHOO_MAP_URL
 *
 * DESCRIPTION
 *    function that would return a html link tag which
 *    will contain the address formatted for Yahoo Maps.
 * ARGUMENTS
 *   IN:
 *        address1                IN VARCHAR2,
 *        address2                IN VARCHAR2,
 *        address3                IN VARCHAR2,
 *        address4                IN VARCHAR2,
 *        city                    IN VARCHAR2,
 *        country                 IN VARCHAR2,
 *        state                   IN VARCHAR2,
 *        postal_code             IN VARCHAR2
 *
 *   RETURNS    : VARCHAR2
 *
**/

FUNCTION GET_YAHOO_MAP_URL(address1                IN VARCHAR2,
                           address2                IN VARCHAR2,
                           address3                IN VARCHAR2,
                           address4                IN VARCHAR2,
                           city                    IN VARCHAR2,
                           country                 IN VARCHAR2,
                           state                   IN VARCHAR2,
                           postal_code             IN VARCHAR2)
RETURN VARCHAR2 AS
    url VARCHAR2(200);
    url2 VARCHAR2(700);
    country_code VARCHAR2(20);
    amp VARCHAR2(01) := '&';
    staticURL VARCHAR2(100) := 'http://maps.yahoo.com/py/maps.py?BFCat=' || amp || 'Pyt=Tmap' || amp || 'newFL=Use+Address+Below' || amp || 'Get Map=Get+Map';

BEGIN

-- Since TCA validates the country code of UK to GB and Yahoo Maps expects 'uk'
-- we resort to this work around
    IF upper(rtrim(country)) = 'GB'
    THEN
       country_code := 'UK';
    ELSE
       country_code := rtrim(country);
    END IF;

    URL2 := staticURL ||
           amp || 'addr=' || REPLACE(address1, ' ', '+') ||
           amp || 'csz=' || REPLACE(city, ' ', '+') || '+' || RTRIM(state) || '+' || RTRIM(postal_code) ||
           amp || 'country=' || country_code;

    URL := substrb(URL2, 1, 200);
    RETURN url;
END GET_YAHOO_MAP_URL;

/**
 * FUNCTION IS_PARTY_ID_IN_REQUEST_LOG
 *
 * DESCRIPTION
 *    function that would return a 'Y' if this party_id exist in hz_dnb_request_log
 *    return 'N' if not.
 * ARGUMENTS
 *     party_id             IN     NUMBER
 *
 *   RETURNS    : VARCHAR2
*/

FUNCTION IS_PARTY_ID_IN_REQUEST_LOG(
              p_party_id             IN     NUMBER)

RETURN VARCHAR2 AS

  l_exist      varchar2(1)  := 'N';

/* Bug 3301467 : Comment the cursor code

  CURSOR c IS
        select 'N'
        from hz_dnb_request_log log, hz_organization_profiles org
        where log.party_id= p_party_id
        and org.party_id=log.party_id
        and org.actual_content_source='DNB'
        and org.effective_end_date is NULL
        and trunc(org.last_update_date) > trunc(log.last_update_date)
        and rownum =1
        UNION
        select 'Y'
        from hz_dnb_request_log log, hz_organization_profiles org
        where log.party_id= p_party_id
        and org.party_id=log.party_id
        and org.actual_content_source='DNB'
        and org.effective_end_date is NULL
        and trunc(org.last_update_date) = trunc(log.last_update_date)
        and rownum =1;
*/

BEGIN

   select 'E' into l_exist
   from hz_dnb_request_log
   where party_id = p_party_id
     and rownum = 1;

     if l_exist = 'E'  then
/*
           open c;
           fetch c into l_exist;
           close c;
*/

-- Bug 3301467 : Add below statement to check if the last purchased package for
--               a party is through online mode or batch mode.
--               If it is online mode, return 'Y' else 'N'
        Begin
                select 'Y' into l_exist from hz_organization_profiles org
                where org.party_id = p_party_id
                    and  org.actual_content_source='DNB'
                    and  org.effective_end_date is NULL
                    and  trunc(org.last_update_date) =
                        (select trunc(max(log.last_update_date)) from hz_dnb_request_log log
                         where log.party_id = p_party_id);
        Exception
                when no_data_found then
                        l_exist := 'N';
        end;
     end if;

   return l_exist;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
     return l_exist;
END IS_PARTY_ID_IN_REQUEST_LOG;


/**
 * FUNCTION get_message
 *
 * DESCRIPTION
 *    returns the translated message
 * ARGUMENTS
 *     message_name
 *     token1_name, token1_value
 *     token2_name, token2_value
 *     token3_name, token3_value
 *     token4_name, token4_value
 *     token5_name, token5_value
 *
 *   RETURNS    : VARCHAR2: token sustituted, translated message
*/
FUNCTION get_message(
   app_short_name IN VARCHAR2,
   message_name IN varchar2,
   token1_name  IN VARCHAR2,
   token1_value IN VARCHAR2,
   token2_name  IN VARCHAR2,
   token2_value IN VARCHAR2,
   token3_name  IN VARCHAR2,
   token3_value IN VARCHAR2,
   token4_name  IN VARCHAR2,
   token4_value IN VARCHAR2,
   token5_name  IN VARCHAR2,
   token5_value IN VARCHAR2)
RETURN VARCHAR2 AS
BEGIN
 -- Flow
 -- 1. Set the Message Name
 -- 2. Set the token(s).
 -- 3. get translated message and return it.

 FND_MESSAGE.SET_NAME(app_short_name,message_name);
 -- not using the CASE statement to make it backward compatible.
 IF token1_name IS NOT NULL THEN
        FND_MESSAGE.SET_TOKEN(token1_name,token1_value);
 END IF;
 IF token2_name IS NOT NULL THEN
        FND_MESSAGE.SET_TOKEN(token2_name,token2_value);
 END IF;
 IF token3_name IS NOT NULL THEN
        FND_MESSAGE.SET_TOKEN(token3_name,token3_value);
 END IF;
 IF token4_name IS NOT NULL THEN
        FND_MESSAGE.SET_TOKEN(token4_name,token4_value);
 END IF;
 IF token5_name IS NOT NULL THEN
        FND_MESSAGE.SET_TOKEN(token5_name,token5_value);
 END IF;

 return FND_MESSAGE.get;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     return 'NO MESSAGE FOUND';
   WHEN OTHERS THEN
     return 'NO MESSAGE FOUND';
END get_message;


/**
 * FUNCTION is_restriction_exist
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return a flag to indicate if contact preference exist
 * ARGUMENTS
 *   IN:
 *     p_contact_level_table     contact level table
 *     p_contact_level_table_id  contact level table id
 *     p_preference_code         preference code
 *
 *   RETURNS    : VARCHAR2
 *
**/

FUNCTION is_restriction_exist (
    p_contact_level_table              IN     VARCHAR2,
    p_contact_level_table_id           IN     NUMBER,
    p_preference_code                  IN     VARCHAR2
) RETURN VARCHAR2 IS

    CURSOR c_restriction IS
    SELECT null
    FROM   hz_contact_preferences
    WHERE  contact_level_table = p_contact_level_table
    AND    contact_level_table_id = p_contact_level_table_id
    AND    preference_code = p_preference_code
    AND    status = 'A'
    AND    (preference_end_date IS NULL OR
            TRUNC(preference_end_date) >= TRUNC(sysdate))
    AND    TRUNC(preference_start_date) <= TRUNC(sysdate)
    AND    ROWNUM = 1;

    l_dummy                            VARCHAR2(1);
    l_return                           VARCHAR2(1);

BEGIN

    IF p_contact_level_table_id IS NULL THEN
      RETURN 'N';
    END IF;

   OPEN c_restriction;
   FETCH c_restriction INTO l_dummy;
   IF c_restriction%NOTFOUND THEN
     l_return := 'N';
   ELSE
     l_return := 'Y';
   END IF;
   CLOSE c_restriction;

   RETURN l_return;

END is_restriction_exist;

/**
 * FUNCTION is_purchased_content_source
 *
 * DESCRIPTION
 *    This function will return 'Y' if the source system is a purchased one.
 *    (i.e HZ_ORIG_SYSTEMS_B.orig_system_type = 'PURCHASED')
 *
 * ARGUMENTS
 *   IN:
 *     p_content_source
 *
 *   RETURNS    : VARCHAR2
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *  01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension. Created.
 *
**/
FUNCTION is_purchased_content_source (
p_content_source                        IN    VARCHAR2
) RETURN VARCHAR2 IS

    CURSOR c_content_source IS
        SELECT 'Y'
        FROM   HZ_ORIG_SYSTEMS_B
        WHERE  orig_system = p_content_source
          AND  orig_system_type = 'PURCHASED'
--        AND  status = 'A'
          AND  rownum = 1;

    l_return_value       VARCHAR2(1);

BEGIN

    OPEN  c_content_source;
    FETCH c_content_source INTO l_return_value;
    IF c_content_source%NOTFOUND THEN
        l_return_value := 'N';
    END IF;
    CLOSE c_content_source;

    RETURN l_return_value;

END is_purchased_content_source;

/**
 * FUNCTION get_lookupMeaning_lang
 *
 * DESCRIPTION
 *     This function will return the meaning in FND_LOOKUP_VALUES for the given combination
 *     of lookup_type, lookup_code and language.
 *
 * ARGUMENTS
 *   IN:
 *     p_lookup_type
 *     p_lookup_code
 *     p_language
 *
 *   RETURNS    : VARCHAR2 (FND_LOOKUP_VALUES.Meaning)
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *  09-Jan-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension. Created.
 *
**/
FUNCTION get_lookupMeaning_lang (
p_lookup_type                        IN    VARCHAR2,
p_lookup_code                        IN    VARCHAR2,
p_language                           IN    VARCHAR2
) RETURN VARCHAR2 IS

    CURSOR c_lookup_meaning_for_lang IS
        SELECT meaning
        FROM   FND_LOOKUP_VALUES
        WHERE  lookup_type = p_lookup_type
          AND  lookup_code = p_lookup_code
          AND  language    = p_language
          AND  enabled_flag = 'Y'
          AND  (end_date_active IS NULL
                OR end_date_active >= sysdate);

    l_return_value       VARCHAR2(80);

BEGIN

    OPEN  c_lookup_meaning_for_lang;
    FETCH c_lookup_meaning_for_lang INTO l_return_value;
    IF c_lookup_meaning_for_lang%NOTFOUND THEN
        l_return_value := NULL ;
    END IF;
    CLOSE c_lookup_meaning_for_lang;

    RETURN l_return_value;

END get_lookupMeaning_lang;

/**
 * FUNCTION get_lookupDesc_lang
 *
 * DESCRIPTION
 *     This function will return the description in FND_LOOKUP_VALUES for the given combination
 *     of lookup_type, lookup_code and language.
 *
 * ARGUMENTS
 *   IN:
 *     p_lookup_type
 *     p_lookup_code
 *     p_language
 *
 *   RETURNS    : VARCHAR2 (FND_LOOKUP_VALUES.Description)
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *  09-Jan-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension. Created.
 *
**/
FUNCTION get_lookupDesc_lang (
p_lookup_type                        IN    VARCHAR2,
p_lookup_code                        IN    VARCHAR2,
p_language                           IN    VARCHAR2
) RETURN VARCHAR2 IS

    CURSOR c_lookup_desc_for_lang IS
        SELECT description
        FROM   FND_LOOKUP_VALUES
        WHERE  lookup_type = p_lookup_type
          AND  lookup_code = p_lookup_code
          AND  language    = p_language
          AND  enabled_flag = 'Y'
          AND  (end_date_active IS NULL
                OR end_date_active >= sysdate);

    l_return_value       VARCHAR2(240);

BEGIN

    OPEN  c_lookup_desc_for_lang;
    FETCH c_lookup_desc_for_lang INTO l_return_value;
    IF c_lookup_desc_for_lang%NOTFOUND THEN
        l_return_value := NULL ;
    END IF;
    CLOSE c_lookup_desc_for_lang;

    RETURN l_return_value;

END get_lookupDesc_lang;



/**
 * FUNCTION check_prim_bill_to_site
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return Y if the party site is the primary Bill_To site.
 *    will return N in other cases

 * ARGUMENTS
 *   IN:
 *     p_party_site_id               party site id used to retrieve the site use purpose.
 *
 *   RETURNS    : VARCHAR2
 *
**/
function check_prim_bill_to_site (
    p_party_site_id                         IN     NUMBER)
RETURN VARCHAR2 IS


  l_bill_to_primary   VARCHAR2(1000);
  l_primary           VARCHAR2(10);
  cursor c_site_bill_to (l_party_site_id IN NUMBER) is
    select psu.primary_per_type
    from hz_party_site_uses psu
    where
         psu.party_site_id = l_party_site_id  and
         psu.status = 'A' and
         psu.site_use_type = 'BILL_TO' and
         psu.primary_per_type = 'Y'
order by primary_per_type DESC;

BEGIN

  l_bill_to_primary := 'N';
  OPEN c_site_bill_to(p_party_site_id);
  LOOP
  FETCH c_site_bill_to INTO l_primary;

    IF c_site_bill_to%NOTFOUND THEN
      EXIT;
    END IF;

    IF l_primary = 'Y' THEN
       l_bill_to_primary := 'Y';
       exit;
    END IF;

  END LOOP;
  CLOSE c_site_bill_to;

  RETURN l_bill_to_primary;
END check_prim_bill_to_site;


/**
 * FUNCTION check_prim_ship_to_site
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return Y if the party site is the primary Ship_To site.
 *    will return N in other cases

 * ARGUMENTS
 *   IN:
 *     p_party_site_id               party site id used to retrieve the site use purpose.
 *
 *   RETURNS    : VARCHAR2
 *
**/
function check_prim_ship_to_site (
    p_party_site_id                         IN     NUMBER)
RETURN VARCHAR2 IS


  l_ship_to_primary   VARCHAR2(1000);
  l_primary           VARCHAR2(10);
  cursor c_site_ship_to (l_party_site_id IN NUMBER) is
    select psu.primary_per_type
    from hz_party_site_uses psu
    where
         psu.party_site_id = l_party_site_id  and
         psu.status = 'A' and
         psu.site_use_type = 'SHIP_TO' and
         psu.primary_per_type = 'Y'
order by primary_per_type DESC;

BEGIN

  l_ship_to_primary := 'N';
  OPEN c_site_ship_to(p_party_site_id);
  LOOP
  FETCH c_site_ship_to INTO l_primary;

    IF c_site_ship_to%NOTFOUND THEN
      EXIT;
    END IF;

    IF l_primary = 'Y' THEN
       l_ship_to_primary := 'Y';
       exit;
    END IF;

  END LOOP;
  CLOSE c_site_ship_to;

  RETURN l_ship_to_primary;
END check_prim_ship_to_site;


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

BEGIN

    -- skip mandatory and non-updateable check from logical API
    IF G_CALLING_API IS NULL THEN
      -- created_by_module is mandatory field
      -- Since created_by_module is non-updateable, we only need to check mandatory
      -- during creation.

      IF p_create_update_flag = 'C' THEN
        validate_mandatory (
          p_create_update_flag     => p_create_update_flag,
          p_column                 => 'created_by_module',
          p_column_value           => p_created_by_module,
          x_return_status          => x_return_status);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          debug(
            p_prefix               => '',
            p_message              => 'created_by_module is mandatory. ' ||
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
          p_column                 => 'created_by_module',
          p_column_value           => p_created_by_module,
          p_old_column_value       => p_old_created_by_module,
          p_restricted             => 'N',
          x_return_status          => x_return_status);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          debug(
            p_prefix               => '',
            p_message              => 'created_by_module is non-updateable. It can be updated from NULL to a value. ' ||
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
        p_column                   => 'created_by_module',
        p_lookup_type              => 'HZ_CREATED_BY_MODULES',
        p_column_value             => p_created_by_module,
        x_return_status            => x_return_status);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        debug(
          p_prefix                 => '',
          p_message                => 'created_by_module is lookup code in lookup type HZ_CREATED_BY_MODULES. ' ||
                                      'x_return_status = ' || x_return_status,
          p_msg_level              => fnd_log.level_statement);
      END IF;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      debug(
        p_prefix                   => '',
        p_message                  => 'after validate created_by_module ... ' ||
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
    IF G_CALLING_API IS NULL THEN
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
          debug(
            p_prefix               => '',
            p_message              => l_column || ' is non-updateable. It can be updated from NULL to a value. ' ||
                                      'x_return_status = ' || x_return_status,
            p_msg_level            => fnd_log.level_statement);
        END IF;
      END IF;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      debug(
        p_prefix                   => '',
        p_message                  => 'after validate ' || l_column || ' ... ' ||
                                      'x_return_status = ' || x_return_status,
        p_msg_level                => fnd_log.level_statement);
    END IF;

END validate_application_id;


/**
 * FUNCTION is_role_in_relationship_group
 *
 * DESCRIPTION
 *    return if a role exists in a relationship group
 * ARGUMENTS
 *   IN:
 *     p_relationship_type_id    relationship type id
 *     p_relationship_group_code relationship group code
 */

FUNCTION is_role_in_relationship_group (
    p_relationship_type_id        IN     NUMBER,
    p_relationship_group_code     IN     VARCHAR2
) RETURN VARCHAR2 IS

    CURSOR c_groups IS
    SELECT null
    FROM   hz_code_assignments c
    WHERE  c.owner_table_name = 'HZ_RELATIONSHIP_TYPES'
    AND    c.class_category = 'RELATIONSHIP_TYPE_GROUP'
    AND    c.class_code = p_relationship_group_code
    AND    sysdate between c.start_date_active and nvl(c.end_date_active, sysdate+1)
    AND    c.status = 'A'
    AND    c.owner_table_id = p_relationship_type_id
    AND    ROWNUM = 1;

    l_dummy                       VARCHAR2(1);
    l_return                      VARCHAR2(1);

BEGIN

    OPEN c_groups;
    FETCH c_groups INTO l_dummy;
    IF c_groups%NOTFOUND THEN
      l_return := 'N';
    ELSE
      l_return := 'Y';
    END IF;
    CLOSE c_groups;

    RETURN l_return;

END is_role_in_relationship_group;


END HZ_UTILITY_V2PUB;

/
