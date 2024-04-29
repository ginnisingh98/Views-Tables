--------------------------------------------------------
--  DDL for Package Body FUN_RULE_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_UTILITY_PKG" AS
/*$Header: FUNXTMRULGENUTB.pls 120.3 2006/02/22 10:51:20 ammishra noship $ */

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


INVAILD_DATA_TYPE                       EXCEPTION;
INVAILD_LENGTH_TYPE                     EXCEPTION;
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
    x_lookup_meaning                    OUT NOCOPY    VARCHAR2
) RETURN BOOLEAN;

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
 *   10-Sep-2004   Amulya Mishra       Created.
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
 *   10-Sep-2004   Amulya Mishra       Created.
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
 *   10-Sep-2004   Amulya Mishra       Created.
 *
 */

FUNCTION search (
    p_val                               IN     VARCHAR2,
    p_category                          IN     VARCHAR2,
    x_lookup_meaning                    OUT NOCOPY    VARCHAR2
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

BEGIN

    -- search for the value
    l_table_index := get_index( p_val || G_SPECIAL_STRING || p_category );

    IF l_table_index < table_size THEN
         l_return := TRUE;
         IF p_category = 'LOOKUP' THEN
           x_lookup_meaning := LOOKUP_MEANING_TAB(l_table_index);
         END IF;
    ELSE
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
                AND    ROWNUM = 1;

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
           l_table_index := put( p_val || G_SPECIAL_STRING || p_category );
           IF p_category = 'LOOKUP' THEN
               LOOKUP_MEANING_TAB(l_table_index) := x_lookup_meaning;
           END IF;
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
 *   10-Sep-2004    Amulya Mishra       Created.
 *
 */

FUNCTION search (
    p_val                               IN     VARCHAR2,
    p_category                          IN     VARCHAR2
) RETURN BOOLEAN IS

    l_lookup_meaning                    VARCHAR2(100);

BEGIN
    RETURN search(p_val, p_category, l_lookup_meaning);
END search;


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
 *   10-Sep-2004    Amulya Mishra      Created.
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
 *   10-Sep-2004   Amulya Mishra      Created.
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
                  'LOOKUP', l_lookup_meaning );
    RETURN l_lookup_meaning;

END Get_LookupMeaning;

/*

PROCEDURE CREATE_DUPLICATE_RULE(
          p_rule_detail_id IN FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE,
          p_rule_object_id IN FUN_RULE_DETAILS.RULE_OBJECT_ID%TYPE
          ) IS

l_next_rule_detail_id        FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE;
l_next_criteria_id           FUN_RULE_CRITERIA.CRITERIA_ID%TYPE;

l_rowid                      ROWID;

l_rule_detail_id	     FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE;
l_rule_object_id             FUN_RULE_DETAILS.RULE_OBJECT_ID%TYPE;
l_rule_name		     FUN_RULE_DETAILS.RULE_NAME%TYPE;
l_seq			     FUN_RULE_DETAILS.SEQ%TYPE;
l_operator                   FUN_RULE_DETAILS.OPERATOR%TYPE;
l_enabled_flag               FUN_RULE_DETAILS.ENABLED_FLAG%TYPE;
l_result_application_id      FUN_RULE_DETAILS.RESULT_APPLICATION_ID%TYPE;
l_result_value               FUN_RULE_DETAILS.RESULT_VALUE%TYPE;
l_created_by_module          FUN_RULE_DETAILS.CREATED_BY_MODULE%TYPE;


l_criteria_id                FUN_RULE_CRITERIA.CRITERIA_ID%TYPE;
l_criteria_param_name        FUN_RULE_CRITERIA.CRITERIA_PARAM_NAME%TYPE;
l_condition                  FUN_RULE_CRITERIA.CONDITION%TYPE;
l_param_value                FUN_RULE_CRITERIA.PARAM_VALUE%TYPE;
l_case_sensitive             FUN_RULE_CRITERIA.CASE_SENSITIVE%TYPE;


CURSOR C IS
	SELECT * FROM FUN_RULE_CRITERIA
	WHERE  RULE_DETAIL_ID = P_RULE_DETAIL_ID
FOR UPDATE NOWAIT;


BEGIN

   SELECT FUN_RULE_DETAILS_S.NEXTVAL
   INTO l_next_rule_detail_id
   FROM DUAL;

   SELECT
         RULE_OBJECT_ID,
         RULE_NAME,
         SEQ,
         OPERATOR,
         ENABLED_FLAG,
         RESULT_APPLICATION_ID,
         RESULT_VALUE,
         CREATED_BY_MODULE
   INTO
         l_rule_object_id,
         l_rule_name,
         l_seq,
         l_operator,
         l_enabled_flag,
         l_result_application_id,
         l_result_value,
         l_created_by_module

   FROM FUN_RULE_DETAILS
   WHERE RULE_OBJECT_ID = p_rule_object_id
   AND   RULE_DETAIL_ID = p_rule_detail_id;

   FUN_RULE_DETAILS_PKG.INSERT_ROW (
          X_ROWID                                =>l_rowid,
          X_RULE_DETAIL_ID	                 =>l_next_rule_detail_id,
          X_RULE_OBJECT_ID                       =>l_rule_object_id,
          X_RULE_NAME		                 =>l_rule_name,
          X_SEQ			                 =>l_seq,
          X_OPERATOR                             =>l_operator,
          X_ENABLED_FLAG                         =>l_enabled_flag,
          X_RESULT_APPLICATION_ID                =>l_result_application_id,
          X_RESULT_VALUE                         =>l_result_value,
          X_OBJECT_VERSION_NUMBER                =>1,
          X_CREATED_BY_MODULE                    =>l_created_by_module
   );

--insert criteria records for the duplicate rule.

FOR p_rule_criteria_rec IN C LOOP

    FUN_RULE_CRITERIA_PKG.INSERT_ROW (
        X_ROWID                           =>l_rowid,
        X_CRITERIA_ID                     =>p_rule_criteria_rec.criteria_id,
        X_RULE_DETAIL_ID                  =>l_next_rule_detail_id,
        X_CRITERIA_PARAM_NAME             =>p_rule_criteria_rec.criteria_param_name,
        X_CONDITION                       =>p_rule_criteria_rec.condition,
        X_PARAM_VALUE                     =>p_rule_criteria_rec.param_value,
        X_CASE_SENSITIVE                  =>p_rule_criteria_rec.case_sensitive,
        X_OBJECT_VERSION_NUMBER           =>1,
        X_CREATED_BY_MODULE               =>p_rule_criteria_rec.created_by_module
    );

END LOOP;


EXCEPTION

   WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('SQLAP','FUN_NO_RULE_DETAIL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('SQLAP','FUN_NO_RULE_DETAIL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END  CREATE_DUPLICATE_RULE;
*/

FUNCTION GET_MAX_SEQ (
                     P_RULE_OBJECT_ID IN FUN_RULE_DETAILS.RULE_OBJECT_ID%TYPE
                     )
RETURN NUMBER  IS

l_max_seq   FUN_RULE_DETAILS.SEQ%TYPE;

BEGIN
   SELECT MAX(SEQ)+1 INTO l_max_seq
   FROM FUN_RULE_DETAILS
   WHERE RULE_OBJECT_ID = P_RULE_OBJECT_ID;
   RETURN l_max_seq;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
      RETURN NULL;

   WHEN OTHERS THEN
      RETURN NULL;
END GET_MAX_SEQ;


FUNCTION getApplicationID(p_AppShortName IN VARCHAR2)
                          RETURN  NUMBER IS
  l_application_id      NUMBER;
BEGIN
        SELECT  nvl(application_id , 435)
        INTO    l_application_id
        FROM    fnd_application
        WHERE   application_short_name = p_AppShortName;

        RETURN l_application_id;
EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;

END GetApplicationID;


FUNCTION getApplicationShortName(p_ApplicationId IN NUMBER)
                          RETURN VARCHAR2
IS
  l_application_short_name      VARCHAR2(30);
BEGIN

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_UTILITY_PKG.getApplicationShortName', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_ApplicationId='||to_char(p_ApplicationId), FALSE);
   end if;

        SELECT  nvl(application_short_name, 'FUN')
        INTO    l_application_short_name
        FROM    fnd_application
        WHERE   application_id = p_ApplicationId;

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_UTILITY_PKG.getApplicationShortName', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'l_application_short_name'||l_application_short_name, FALSE);
   end if;

        RETURN l_application_short_name;
EXCEPTION
        WHEN OTHERS THEN
           IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_UTILITY_PKG.getApplicationShortName:->Exception', FALSE);
	      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , SQLERRM, FALSE);
	   END IF;

           APP_EXCEPTION.RAISE_EXCEPTION;

END getApplicationShortName;

FUNCTION getValueSetDataType(p_ValueSetId  IN NUMBER)
                          RETURN VARCHAR2
IS
  l_dataType                  VARCHAR2(10);
  l_maximum_size              NUMBER;
  params_cursor               INTEGER;
  params_rows_processed       INTEGER;

  l_ValueSetSql               VARCHAR2(1000) := 'SELECT FORMAT_TYPE, MAXIMUM_SIZE FROM FND_FLEX_VALUE_SETS WHERE
                                                 FLEX_VALUE_SET_ID = :1';

BEGIN

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_UTILITY_PKG.getValueSetDataType', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_ValueSetId='||to_char(p_ValueSetId), FALSE);
   end if;

   params_cursor := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(params_cursor, l_ValueSetSql,DBMS_SQL.native);
   dbms_sql.bind_variable(params_cursor , '1' , p_ValueSetId);

   dbms_sql.define_column(params_cursor, 1, l_dataType , 1);
   dbms_sql.define_column(params_cursor, 2, l_maximum_size);

   params_rows_processed := DBMS_SQL.EXECUTE(params_cursor);

   while(dbms_sql.fetch_rows(params_cursor) > 0 ) loop
     dbms_sql.column_value(params_cursor, 1, l_dataType );
     dbms_sql.column_value(params_cursor, 2, l_maximum_size );

     IF (l_dataType = 'C' ) THEN l_dataType := 'STRINGS'; END IF;
     IF (l_dataType = 'N' ) THEN l_dataType := 'NUMERIC'; END IF;
     IF (l_dataType = 'D' OR l_dataType = 'X') THEN
         l_dataType := 'DATE';
     END IF;

     -----------------------------------------
     -- Standard DateTime   - Y              -
     -- Old      Time       - T              -
     -- Old      DateTime   - t              -
     -----------------------------------------
     IF (l_dataType = 'T' OR l_dataType = 't' OR l_dataType = 'Y') THEN
        RAISE INVAILD_DATA_TYPE;
     END IF;

   end loop;

   DBMS_SQL.CLOSE_CURSOR(params_cursor);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_UTILITY_PKG.getValueSetDataType', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'l_dataType'||l_dataType, FALSE);
   end if;


   RETURN l_dataType;

   EXCEPTION
       WHEN INVAILD_DATA_TYPE THEN

        IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_UTILITY_PKG.getValueSetDataType:->INVAILD_DATA_TYPE', FALSE);
        END IF;

        FND_MESSAGE.SET_NAME('FUN','FUN_RULE_INVALID_CRIT_DATATYPE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       WHEN INVAILD_LENGTH_TYPE THEN
        IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_UTILITY_PKG.getValueSetDataType:->INVAILD_LENGTH_TYPE', FALSE);
        END IF;

        FND_MESSAGE.SET_NAME('FUN','FUN_RULE_INVALID_CRIT_LENGTH');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       WHEN OTHERS THEN
  	IF DBMS_SQL.IS_OPEN(params_cursor) THEN
	 DBMS_SQL.CLOSE_CURSOR(params_cursor);
	END IF;

	IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_UTILITY_PKG.getValueSetDataType:->Exception='||SQLERRM, FALSE);
	END IF;

	RAISE;

END getValueSetDataType;

FUNCTION GET_RULE_DFF_RESULT_VALUE(p_FlexFieldAppShortName	IN VARCHAR2,
                                   p_FlexFieldName		IN VARCHAR2,
				   p_AttributeCategory		IN VARCHAR2,
				   p_Attribute1			IN VARCHAR2,
				   p_Attribute2			IN VARCHAR2,
				   p_Attribute3			IN VARCHAR2,
				   p_Attribute4			IN VARCHAR2,
				   p_Attribute5			IN VARCHAR2,
				   p_Attribute6			IN VARCHAR2,
				   p_Attribute7			IN VARCHAR2,
				   p_Attribute8			IN VARCHAR2,
				   p_Attribute9			IN VARCHAR2,
				   p_Attribute10		IN VARCHAR2,
				   p_Attribute11		IN VARCHAR2,
				   p_Attribute12		IN VARCHAR2,
				   p_Attribute13		IN VARCHAR2,
				   p_Attribute14		IN VARCHAR2,
				   p_Attribute15		IN VARCHAR2
				   )
RETURN VARCHAR2 IS

  error_msg               VARCHAR2(5000);
  n                       NUMBER;
  tf                      BOOLEAN;
  s                       NUMBER;
  e                       NUMBER;
  errors_received         EXCEPTION;
  error_segment           VARCHAR2(30);

BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_UTILITY_PKG.GET_RULE_DFF_RESULT_VALUE', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_FlexFieldAppShortName='||p_FlexFieldAppShortName, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_FlexFieldName='||p_FlexFieldName, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_AttributeCategory='||p_AttributeCategory, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute1='||p_Attribute1, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute2='||p_Attribute2, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute3='||p_Attribute3, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute4='||p_Attribute4, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute5='||p_Attribute5, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute6='||p_Attribute6, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute7='||p_Attribute7, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute8='||p_Attribute8, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute9='||p_Attribute9, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute10='||p_Attribute10, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute11='||p_Attribute11, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute12='||p_Attribute12, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute13='||p_Attribute13, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute14='||p_Attribute14, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_Attribute15='||p_Attribute15, FALSE);
   end if;

   fnd_flex_descval.set_column_value('ATTRIBUTE_CATEGORY', p_AttributeCategory);
   fnd_flex_descval.set_column_value('ATTRIBUTE1', p_Attribute1);
   fnd_flex_descval.set_column_value('ATTRIBUTE2', p_Attribute2);
   fnd_flex_descval.set_column_value('ATTRIBUTE3', p_Attribute3);
   fnd_flex_descval.set_column_value('ATTRIBUTE4', p_Attribute4);
   fnd_flex_descval.set_column_value('ATTRIBUTE5', p_Attribute5);
   fnd_flex_descval.set_column_value('ATTRIBUTE6', p_Attribute6);
   fnd_flex_descval.set_column_value('ATTRIBUTE7', p_Attribute7);
   fnd_flex_descval.set_column_value('ATTRIBUTE8', p_Attribute8);
   fnd_flex_descval.set_column_value('ATTRIBUTE8', p_Attribute9);
   fnd_flex_descval.set_column_value('ATTRIBUTE10', p_Attribute10);
   fnd_flex_descval.set_column_value('ATTRIBUTE11', p_Attribute11);
   fnd_flex_descval.set_column_value('ATTRIBUTE12', p_Attribute12);
   fnd_flex_descval.set_column_value('ATTRIBUTE13', p_Attribute13);
   fnd_flex_descval.set_column_value('ATTRIBUTE14', p_Attribute14);
   fnd_flex_descval.set_column_value('ATTRIBUTE15', p_Attribute15);

   IF  FND_FLEX_DESCVAL.validate_desccols(p_FlexFieldAppShortName, p_FlexFieldName) THEN
     IF (NVL(LENGTH(FND_FLEX_DESCVAL.concatenated_ids),0) > 1) THEN
        return(FND_FLEX_DESCVAL.concatenated_ids);
     ELSE
        return(FND_FLEX_DESCVAL.concatenated_values);
     END IF;
   ELSE
     if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.message(FND_LOG.LEVEL_STATEMENT, '*************************************************', FALSE);
        fnd_log.message(FND_LOG.LEVEL_STATEMENT, '* An error has occured so we will call           ', FALSE);
        fnd_log.message(FND_LOG.LEVEL_STATEMENT, '* FND_FLEX_DESCVAL.error_segment to detemine     ', FALSE);
        fnd_log.message(FND_LOG.LEVEL_STATEMENT, '* which segment contains the error.              ', FALSE);
        fnd_log.message(FND_LOG.LEVEL_STATEMENT, '*************************************************', FALSE);
     end if;


     error_segment := FND_FLEX_DESCVAL.error_segment;
     if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'error_segment = ' || error_segment, FALSE);
     end if;
     RAISE errors_received;

   END IF;

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_UTILITY_PKG.GET_RULE_DFF_RESULT_VALUE', FALSE);
   end if;

EXCEPTION
 WHEN errors_received THEN
   error_msg := fnd_flex_descval.error_message;
   s :=1;
   e := 200;

   IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_UTILITY_PKG.GET_RULE_DFF_RESULT_VALUE:->errors_received', FALSE);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'Here are the error messages: ', FALSE);
   END IF;

   if(length(error_msg) < 200) then
      IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , error_msg, FALSE);
      END IF;

   else
     while e < 5001 and substr(error_msg, s, e) is not null
	  loop
	      IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , substr(error_msg, s, e), FALSE);
	      END IF;

	      s := s + 200;
	      e := e + 200;
     end loop;
   end if;

  RAISE_APPLICATION_ERROR(-20000,error_msg);

END get_rule_dff_result_value;

/*Usage
    fun_rule_utility_pkg.print_debug(0,'Before calling Rules Engine.');
*/

PROCEDURE print_debug(
        p_indent IN NUMBER,
        p_text IN VARCHAR2 ) IS
BEGIN
        fnd_file.put_line( FND_FILE.LOG, RPAD(' ', (1+p_indent)*2)||p_text );
EXCEPTION
        WHEN OTHERS THEN
                null;
END print_debug;


FUNCTION get_moac_org_id
RETURN NUMBER IS
BEGIN
  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_UTILITY_PKG.GET_MOAC_ORG_ID', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'MO_GLOBAL.GET_ACCESS_MODE='||MO_GLOBAL.GET_ACCESS_MODE(), FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'MO_GLOBAL.GET_CURRENT_ORG_ID='||MO_GLOBAL.GET_CURRENT_ORG_ID, FALSE);
  end if;

  IF ( MO_GLOBAL.GET_ACCESS_MODE() = 'S') THEN
    RETURN MO_GLOBAL.GET_CURRENT_ORG_ID;
  ELSE
    RETURN -2;
  END IF;
END;

/* Rule Object Instance Enhancement for MULTIVALUE:
 * This function returns TRU if the RULE_OBJECT_ID passed is an instance or not.
 */

FUNCTION IS_USE_INSTANCE(p_rule_object_id IN NUMBER)
RETURN BOOLEAN
IS
  l_parent_rule_object_id     FUN_RULE_OBJECTS_B.PARENT_RULE_OBJECT_ID%TYPE;
  params_cursor               INTEGER;
  params_rows_processed       INTEGER;

  l_sql               VARCHAR2(1000) := 'SELECT PARENT_RULE_OBJECT_ID FROM FUN_RULE_OBJECTS_B WHERE
                                                RULE_OBJECT_ID = :1';

BEGIN

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_UTILITY_PKG.IS_USE_INSTANCE', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'p_rule_object_id='||to_char(p_rule_object_id), FALSE);
   end if;

   params_cursor := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(params_cursor, l_sql,DBMS_SQL.native);
   dbms_sql.bind_variable(params_cursor , '1' , p_rule_object_id);

   dbms_sql.define_column(params_cursor, 1, l_parent_rule_object_id);

   params_rows_processed := DBMS_SQL.EXECUTE(params_cursor);

   while(dbms_sql.fetch_rows(params_cursor) > 0 ) loop
     dbms_sql.column_value(params_cursor, 1, l_parent_rule_object_id );
     if(l_parent_rule_object_id IS NULL) then
       return FALSE;
     else
       return TRUE;
     end if;
   end loop;

   DBMS_SQL.CLOSE_CURSOR(params_cursor);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_UTILITY_PKG.IS_USE_INSTANCE', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'l_parent_rule_object_id='||to_char(l_parent_rule_object_id), FALSE);
   end if;


   RETURN FALSE;

   EXCEPTION
       WHEN OTHERS THEN
  	IF DBMS_SQL.IS_OPEN(params_cursor) THEN
	 DBMS_SQL.CLOSE_CURSOR(params_cursor);
	END IF;

	IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_UTILITY_PKG.IS_USE_INSTANCE:->Exception='||SQLERRM, FALSE);
	END IF;

	RAISE;
END IS_USE_INSTANCE;

END FUN_RULE_UTILITY_PKG;

/
