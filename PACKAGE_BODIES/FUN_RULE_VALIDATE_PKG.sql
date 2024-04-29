--------------------------------------------------------
--  DDL for Package Body FUN_RULE_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_VALIDATE_PKG" AS
/*$Header: FUNXTMRULGENVLB.pls 120.4 2006/02/22 10:51:00 ammishra noship $ */


/*---------------------
  -- Local variables --
  ---------------------*/
g_ex_invalid_param     EXCEPTION;
l_owner_table_name     VARCHAR2(30);
l_owner_table_id       VARCHAR2(30);
l_text                 VARCHAR2(4000);
l_column_name          VARCHAR2(240);

g_special_string CONSTANT VARCHAR2(4):= '%#@*';
G_LENGTH         CONSTANT NUMBER := LENGTHB(g_special_string);

TYPE val_tab_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

---------------------------------------------------
-- define the internal table that will cache values
---------------------------------------------------

VAL_TAB                                 VAL_TAB_TYPE;    -- the table of values
TABLE_SIZE                              BINARY_INTEGER := 2048; -- the size of above tables

-----------------------------------------------------------------
-- Private procedures and functions used internally by validation
-- process.
-----------------------------------------------------------------

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

              IF UPPER(l_lookup_table) = 'FUN_LOOKUPS' THEN
              BEGIN
                  SELECT 'Y' INTO l_dummy
                  FROM   FUN_LOOKUPS
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
          END IF;

          --Cache the value
          IF l_return THEN
             put(p_val || G_SPECIAL_STRING || p_category);
          END IF;
      END IF;
      RETURN l_return;

  END search;

procedure check_mandatory_str_col
-- Control mandatory column for varchar2 type
--         create update flag belongs to [C (creation) ,U (update)]
--         Column name
--         Column Value
--         Allow Null in creation mode flag
--         Allow Null in update mode flag
--         Control Status
(       create_update_flag              IN  VARCHAR2,
        p_col_name                              IN  VARCHAR2,
        p_col_val                               IN  VARCHAR2,
        p_miss_allowed_in_c             IN  BOOLEAN,
        p_miss_allowed_in_u             IN  BOOLEAN,
        x_return_status                 IN OUT NOCOPY VARCHAR2)
IS
BEGIN
        IF (p_col_val = FND_API.G_MISS_CHAR) THEN
                fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
                fnd_message.set_token('COLUMN', p_col_name);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
                RETURN;
        END IF;

        IF (create_update_flag = 'C') THEN
                IF ((NOT p_miss_allowed_in_c) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        ELSE
                IF ((NOT p_miss_allowed_in_u) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        END IF;
END check_mandatory_str_col;


procedure check_mandatory_date_col
-- Control mandatory column for date type
--         create update flag belongs to [C (creation) ,U (update)]
--         Column name
--         Column Value
--         Allow Null in creation mode flag
--         Allow Null in update mode flag
--         Control Status
(       create_update_flag              IN  VARCHAR2,
        p_col_name                              IN      VARCHAR2,
        p_col_val                               IN  DATE,
        p_miss_allowed_in_c             IN  BOOLEAN,
        p_miss_allowed_in_u             IN  BOOLEAN,
        x_return_status                 IN OUT NOCOPY VARCHAR2)
IS
BEGIN
        IF (p_col_val = FND_API.G_MISS_DATE) THEN
                fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
                fnd_message.set_token('COLUMN', p_col_name);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
                RETURN;
        END IF;

        IF (create_update_flag = 'C') THEN
                IF ((NOT p_miss_allowed_in_c) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        ELSE
                IF ((NOT p_miss_allowed_in_u) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        END IF;
END check_mandatory_date_col;


procedure check_mandatory_num_col
-- Control mandatory column for number type
--         create update flag belongs to [C (creation) ,U (update)]
--         Column name
--         Column Value
--         Allow Null in creation mode flag
--         Allow Null in update mode flag
--         Control Status
(       create_update_flag              IN  VARCHAR2,
        p_col_name                              IN  VARCHAR2,
        p_col_val                               IN  NUMBER,
        p_miss_allowed_in_c             IN  BOOLEAN,
        p_miss_allowed_in_u             IN  BOOLEAN,
        x_return_status                 IN OUT NOCOPY VARCHAR2)
IS
BEGIN
        IF (p_col_val = FND_API.G_MISS_NUM) THEN
                fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
                fnd_message.set_token('COLUMN', p_col_name);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
                RETURN;
        END IF;

        IF (create_update_flag = 'C') THEN
                IF ((NOT p_miss_allowed_in_c) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        ELSE
                IF ((NOT p_miss_allowed_in_u) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        END IF;
END check_mandatory_num_col;


FUNCTION compare(
        date1 DATE,
        date2 DATE) RETURN NUMBER
IS
  ldate1 date;
  ldate2 date;
BEGIN
  ldate1 := date1;
  ldate2 := date2;
        IF ((ldate1 IS NULL OR ldate1 = FND_API.G_MISS_DATE) AND (ldate2 IS NULL OR ldate2 = FND_API.G_MISS_DATE)) THEN
                RETURN 0;
        ELSIF (ldate2 IS NULL OR ldate2 = FND_API.G_MISS_DATE) THEN
                RETURN -1;
        ELSIF (ldate1 IS NULL OR ldate1 = FND_API.G_MISS_DATE) THEN
                RETURN 1;
        ELSIF ( ldate1 = ldate2 ) THEN
                RETURN 0;
        ELSIF ( ldate1 > ldate2 ) THEN
                RETURN 1;
        ELSE
                RETURN -1;
        END IF;
END compare;


FUNCTION is_between
( datex DATE,
  date1 DATE,
  date2 DATE) RETURN BOOLEAN
IS
BEGIN
 IF compare(datex, date1) >= 0 AND
    compare(date2, datex) >=0 THEN
     RETURN TRUE;
 ELSE
     RETURN FALSE;
 END IF;
END is_between;


FUNCTION is_overlap
-- Returns 'Y' if period [s1,e1] overlaps [s2,e2]
--         'N' otherwise
--         NULL indicates infinite for END dates
(s1 DATE,
 e1 DATE,
 s2 DATE,
 e2 DATE)
RETURN VARCHAR2
IS
BEGIN
 IF ( is_between(s1, s2, e2) ) OR ( is_between(s2, s1, e1) ) THEN
   RETURN 'Y';
 ELSE
   RETURN 'N';
 END IF;
END is_overlap;


PROCEDURE validate_fnd_lookup
( p_lookup_type   IN     VARCHAR2,
  p_column        IN     VARCHAR2,
  p_column_value  IN     VARCHAR2,
  x_return_status IN OUT NOCOPY VARCHAR2)
IS
 CURSOR c1
 IS
 SELECT 'Y'
   FROM fnd_lookup_values
  WHERE lookup_type = p_lookup_type
    AND lookup_code = p_column_value
    AND ROWNUM      = 1;

 l_exist VARCHAR2(1);
BEGIN
 IF (    p_column_value IS NOT NULL
     AND p_column_value <> fnd_api.g_miss_char ) THEN
     OPEN c1;
     FETCH c1 INTO l_exist;
     IF c1%NOTFOUND THEN
       fnd_message.set_name('FUN','FUN_RULE_API_INVALID_LOOKUP');
       fnd_message.set_token('COLUMN',p_column);
       fnd_message.set_token('LOOKUP_TYPE',p_lookup_type);
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
     END IF;
     CLOSE c1;
 END IF;
END validate_fnd_lookup;


/*--------------------------------------------------------
  -- Function usable in any validation entities sections -
  --------------------------------------------------------*/

PROCEDURE check_existence_rules_object
 (p_rule_object_name     IN     VARCHAR2,
  p_application_id         IN     NUMBER,
  x_return_status      IN OUT NOCOPY VARCHAR2)
IS
 CURSOR c_exist_rules_object(p_rule_object_name IN VARCHAR2,p_application_id IN NUMBER )
 IS
 SELECT 'Y'
   FROM FUN_RULE_OBJECTS_B
  WHERE RULE_OBJECT_NAME = p_rule_object_name
    AND APPLICATION_ID = p_application_id
    AND ROWNUM         = 1;
 l_exist   VARCHAR2(1);
BEGIN
 OPEN c_exist_rules_object(p_rule_object_name,p_application_id);
  FETCH c_exist_rules_object INTO l_exist;
  IF c_exist_rules_object%NOTFOUND THEN
   fnd_message.set_name('FUN','FUN_RULE_API_INVALID_FK');
   fnd_message.set_token('FK','CUSTOM_OBJECT_NAME');
   fnd_message.set_token('COLUMN','CUSTOM_OBJECT_NAME');
   fnd_message.set_token('TABLE','FUN_RULES_OBJECTS');
   fnd_msg_pub.add;
   x_return_status := fnd_api.g_ret_sts_error;
  END IF;
 CLOSE c_exist_rules_object;
END check_existence_rules_object;


procedure check_err(
        x_return_status    IN  VARCHAR2
) IS
BEGIN
        IF x_return_status = fnd_api.g_ret_sts_error
        THEN
                RAISE g_ex_invalid_param;
        END IF;
END;

/**
   * PROCEDURE validate_rule_objects
   *
   * DESCRIPTION
   *     Validates rule_object record. Checks for
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
   *   17-Sep-2004    Amulya Mishra     Created.
   */

  PROCEDURE validate_rule_objects(
      p_create_update_flag                    IN      VARCHAR2,
      p_rule_objects_rec                      IN      FUN_RULE_OBJECTS_PUB.rule_objects_rec_type,
      p_rowid                                 IN      ROWID ,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

      l_dummy                                 VARCHAR2(1);
      l_rule_object_name                      FUN_RULE_OBJECTS_B.RULE_OBJECT_NAME%TYPE;
      l_user_rule_object_name                 FUN_RULE_OBJECTS_TL.USER_RULE_OBJECT_NAME%TYPE;
      l_description                           FUN_RULE_OBJECTS_TL.DESCRIPTION%TYPE;
      l_result_type                           FUN_RULE_OBJECTS_B.RESULT_TYPE%TYPE;
      l_required_flag                         FUN_RULE_OBJECTS_B.REQUIRED_FLAG%TYPE;
      l_multi_rule_result_flag                FUN_RULE_OBJECTS_B.MULTI_RULE_RESULT_FLAG%TYPE;
      l_default_value                         FUN_RULE_OBJ_ATTRIBUTES.DEFAULT_VALUE%TYPE;
      l_created_by_module                     FUN_RULE_OBJECTS_B.CREATED_BY_MODULE%TYPE;
      l_use_instance_flag                     FUN_RULE_OBJECTS_B.USE_INSTANCE_FLAG%TYPE;
      l_present                               NUMBER := 0;
      l_dataType                              VARCHAR2(10);

      l_return_status                         VARCHAR2(1);
      l_isFlexFieldValid                      BOOLEAN := FALSE;

  BEGIN


      -- select columns needed to be checked from table during update

      IF (p_create_update_flag = 'U') THEN
          SELECT b.RULE_OBJECT_NAME,
                 b.RESULT_TYPE,
                 b.REQUIRED_FLAG,
                 A.DEFAULT_VALUE,
                 b.created_by_module,
		 b.use_instance_flag
          INTO   l_rule_object_name,
                 l_result_type,
                 l_required_flag,
                 l_default_value,
                 l_created_by_module,
		 l_use_instance_flag
          FROM   FUN_RULE_OBJECTS_B B, FUN_RULE_OBJ_ATTRIBUTES A
          WHERE  B.ROWID = p_rowid
          AND B.RULE_OBJECT_ID = A.RULE_OBJECT_ID;
      END IF;


      ----------------------------------------------------
      --validate If the combination RULE_OBJECT_NAME
      --AND APPLICATION_ID for non instance already exists.
      ----------------------------------------------------
      BEGIN
       IF (p_create_update_flag = 'C') THEN
	   IF (p_rule_objects_rec.instance_label IS NULL AND
	       p_rule_objects_rec.org_id IS NULL AND
	       p_rule_objects_rec.parent_rule_object_id IS NULL) THEN
             SELECT COUNT(1)
             INTO l_present
             FROM FUN_RULE_OBJECTS_B
             WHERE RULE_OBJECT_NAME =  p_rule_objects_rec.rule_object_name
             AND   APPLICATION_ID = p_rule_objects_rec.application_id;
           ELSE
             SELECT COUNT(1)
             INTO l_present
             FROM FUN_RULE_OBJECTS_B
             WHERE RULE_OBJECT_NAME =  p_rule_objects_rec.rule_object_name
             AND   APPLICATION_ID = p_rule_objects_rec.application_id
  	     AND
	     ( (INSTANCE_LABEL IS NULL AND p_rule_objects_rec.instance_label IS NULL) OR
	       (INSTANCE_LABEL IS NOT NULL AND p_rule_objects_rec.instance_label IS NOT NULL AND INSTANCE_LABEL = p_rule_objects_rec.instance_label))
	     AND
	     ( (ORG_ID IS NULL AND p_rule_objects_rec.org_id IS NULL) OR
	       (ORG_ID IS NOT NULL AND p_rule_objects_rec.org_id IS NOT NULL AND ORG_ID = p_rule_objects_rec.org_id))
	     AND PARENT_RULE_OBJECT_ID IS NOT NULL;

           END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_present := 0;
         WHEN OTHERS THEN
            l_present := 0;
      END;

       IF l_present > 0 THEN
          fnd_message.set_name('FUN', 'FUN_RULE_API_ALREADY_EXISTING');
          fnd_message.set_token('OBJECT', p_rule_objects_rec.rule_object_name);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --------------------
      -- validate RULE_OBJECT_NAME
      --------------------

      -- RULE_OBJECT_NAME is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'RULE_OBJECT_NAME',
          p_column_value                          => p_rule_objects_rec.rule_object_name,
          x_return_status                         => x_return_status);


      --------------------
      -- validate USER_RULE_OBJECT_NAME
      --------------------

      -- USER_RULE_OBJECT_NAME is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'USER_RULE_OBJECT_NAME',
          p_column_value                          => p_rule_objects_rec.user_rule_object_name,
          x_return_status                         => x_return_status);



      --------------------
      -- validate RESULT_TYPE
      --------------------

      -- RESULT_TYPE is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'RESULT_TYPE',
          p_column_value                          => p_rule_objects_rec.result_type,
          x_return_status                         => x_return_status);


      -- RESULT_TYPE is lookup code in lookup type FUN_RULE_RESULT_TYPE
      validate_lookup (
          p_column                                => 'RESULT_TYPE',
          p_lookup_table                          => 'FUN_LOOKUPS',
          p_lookup_type                           => 'FUN_RULE_RESULT_TYPE',
          p_column_value                          => p_rule_objects_rec.result_type,
          x_return_status                         => x_return_status);

      --------------------
      -- validate USE_INSTANCE_FLAG
      --------------------

      -- USE_INSTANCE_FLAG is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'USE_INSTANCE_FLAG',
          p_column_value                          => p_rule_objects_rec.use_instance_flag,
          x_return_status                         => x_return_status);


      --------------------
      -- validate MULTI_RULE_RESULT_FLAG
      --------------------

      -- MULTI_RULE_RESULT_FLAG is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'MULTI_RULE_RESULT_FLAG',
          p_column_value                          => p_rule_objects_rec.multi_rule_result_flag,
          x_return_status                         => x_return_status);


      -- If RESULT_TYPE is DFF, then user must provide flexfield_name and flexfield_app_short_name

      IF (p_rule_objects_rec.result_type = 'MULTIVALUE') THEN
          IF(p_rule_objects_rec.flexfield_name IS NULL OR p_rule_objects_rec.flexfield_name = '' OR
   	       p_rule_objects_rec.flexfield_app_short_name IS NULL OR p_rule_objects_rec.flexfield_app_short_name = '')
	  THEN
             fnd_message.set_name('FUN', 'FUN_RULE_NO_DFF_INFO');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
	  ELSE
	    l_isFlexFieldValid := isFlexFieldValid(p_rule_objects_rec.flexfield_name , p_rule_objects_rec.flexfield_app_short_name);
	    IF(NOT l_isFlexFieldValid) THEN
              fnd_message.set_name('FUN', 'FUN_RULE_INVALID_DFF_NAME');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
	    END IF;
          END IF;
      END IF;


      -- If RESULT_TYPE is VALUESET, then user must provide flex_value_set_id
      IF (p_rule_objects_rec.result_type = 'VALUESET'
          AND (p_rule_objects_rec.flex_value_set_id IS NULL OR p_rule_objects_rec.flex_value_set_id = '')
	  ) THEN
          fnd_message.set_name('FUN', 'FUN_RULE_NO_VALUESET_INFO');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      ELSE
          --Validate if the flex_value_set_id is Valid or not.
          IF (p_rule_objects_rec.result_type = 'VALUESET' AND
	       NOT validate_flex_value_set_id(p_rule_objects_rec.flex_value_set_id)) THEN
           fnd_message.set_name('FUN', 'FUN_RULE_INVALID_VALUESET');
           fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
          ELSE
          --This call is to validate the DataType of the Valueset.
	  --Valueset should not be of TIME format.
           l_dataType := FUN_RULE_UTILITY_PKG.getValueSetDataType(p_rule_objects_rec.flex_value_set_id);
          END IF;
      END IF;

      -------------------------
      -- validate default_value and default_application_id
      -- should not be Null, if required_flag is checked 'Y'
      -- Do the checking only if use_default_value_flag is 'Y'.
      -------------------------

     /*We should not check this for MULTIVALUE result type. For MULTIVALUE, the values will be
      *populated through the UI always.
      */

     IF(p_rule_objects_rec.result_type <> 'MULTIVALUE' AND
          p_rule_objects_rec.use_default_value_flag = 'Y') THEN
      IF NVL(p_rule_objects_rec.required_flag, 'N') = 'Y' THEN
        validate_mandatory (
             p_create_update_flag                    => p_create_update_flag,
	     p_column                                => 'DEFAULT_VALUE',
	     p_column_value                          => p_rule_objects_rec.default_value,
	     x_return_status                         => x_return_status);

	validate_mandatory (
	     p_create_update_flag                    => p_create_update_flag,
	     p_column                                => 'DEFAULT_APPLICATION_ID',
	     p_column_value                          => p_rule_objects_rec.default_application_id,
	     x_return_status                         => x_return_status);

      END IF;
     END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      -- created_by_module is mandatory field
      -- Since created_by_module is non-updateable, we only need to check mandatory
      -- during creation.

      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'created_by_module',
              p_column_value                          => p_rule_objects_rec.created_by_module,
              x_return_status                         => x_return_status);
      END IF;

      -- created_by_module is non-updateable field. But it can be updated from NULL to
      -- some value.

      IF p_create_update_flag = 'U' AND
         p_rule_objects_rec.created_by_module IS NOT NULL
      THEN
          validate_nonupdateable (
              p_column                                => 'created_by_module',
              p_column_value                          => p_rule_objects_rec.created_by_module,
              p_old_column_value                      => l_created_by_module,
              p_restricted                            => 'N',
              x_return_status                         => x_return_status);
      END IF;

      -- use_instance_flag is non-updateable field.

      IF p_create_update_flag = 'U'
      THEN
          validate_nonupdateable_atall (
              p_column                                => 'use_instance_flag',
              p_column_value                          => p_rule_objects_rec.use_instance_flag,
              p_old_column_value                      => l_use_instance_flag,
              p_restricted                            => 'N',
              x_return_status                         => x_return_status);
      END IF;

      --Validate Application Id

      IF(p_rule_objects_rec.application_id IS NOT NULL) THEN
	    IF(NOT validate_application_id (p_rule_objects_rec.application_id)) THEN
              fnd_message.set_name('FUN', 'FUN_RULE_INVALID_APPL_ID');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
	    END IF;
      END IF;

      --Validate Default Application Id
      IF(p_rule_objects_rec.default_application_id IS NOT NULL) THEN
	    IF(NOT validate_application_id (p_rule_objects_rec.default_application_id)) THEN
              fnd_message.set_name('FUN', 'FUN_RULE_INVALID_APPL_ID');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
	    END IF;
      END IF;

  END validate_rule_objects;

/**
   * PROCEDURE validate_rule_object_instance
   *
   * DESCRIPTION
   *     Validates rule_object instance record. Checks for
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
   *   27-Dec-2005    Amulya Mishra     Created.
   */

  PROCEDURE validate_rule_object_instance(
      p_create_update_flag                    IN      VARCHAR2,
      p_rule_object_instance_rec              IN      FUN_RULE_OBJECTS_PUB.rule_objects_rec_type,
      p_rowid                                 IN      ROWID ,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

    l_present    number;
 BEGIN

     ----------------------------------------------------
      --validate the uniqueness of RULE_OBJECT_NAME,
      --APPLICATION_ID and not null INSTANCE_LABEL.
     ----------------------------------------------------

      BEGIN
         IF (p_create_update_flag = 'C') THEN
	   IF (p_rule_object_instance_rec.instance_label IS NOT NULL) THEN
             SELECT COUNT(1)
             INTO l_present
             FROM FUN_RULE_OBJECTS_B
             WHERE RULE_OBJECT_NAME =  p_rule_object_instance_rec.rule_object_name
             AND   APPLICATION_ID = p_rule_object_instance_rec.application_id
  	     AND
	     ( (INSTANCE_LABEL IS NULL AND p_rule_object_instance_rec.instance_label IS NULL) OR
	       (INSTANCE_LABEL IS NOT NULL AND p_rule_object_instance_rec.instance_label IS NOT NULL AND INSTANCE_LABEL = p_rule_object_instance_rec.instance_label))
	     AND
	     ( (ORG_ID IS NULL AND p_rule_object_instance_rec.org_id IS  NULL) OR
	       (ORG_ID IS NOT NULL AND p_rule_object_instance_rec.org_id IS NOT NULL AND ORG_ID = p_rule_object_instance_rec.org_id))
	     AND PARENT_RULE_OBJECT_ID IS NOT NULL;
           END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_present := 0;
         WHEN OTHERS THEN
            l_present := 0;
      END;

      IF l_present > 0 THEN
          fnd_message.set_name('FUN', 'FUN_RULE_API_ALREADY_EXISTING');
          fnd_message.set_token('OBJECT', p_rule_object_instance_rec.instance_label);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;

    --Now validate for the Rule Object Instance COlumns.

     /***********************************************************************
       Rule Object Instance Enhancement. Validations done for following.
       1)-USE_INSTANCE_FLAG  should be always N or Y.
       2)-if USE_INSTANCE_FLAG is Y, then INSTANCE_LABEL should be not null.
       3)-Validate the org_id passes from the Host Application.
      ***********************************************************************/

      -- USE_INSTANCE_FLAG is mandatory , either Y or N.
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'USE_INSTANCE_FLAG',
          p_column_value                          => p_rule_object_instance_rec.use_instance_flag,
          x_return_status                         => x_return_status);

      -- PARENT_RULE_OBJECT_ID is mandatory For Rule Object Instancein Update Mode.
      IF (p_create_update_flag = 'U') THEN
        validate_mandatory (
	    p_create_update_flag                    => 'U',
	    p_column                                => 'PARENT_RULE_OBJECT_ID',
	    p_column_value                          => p_rule_object_instance_rec.parent_rule_object_id,
	    x_return_status                         => x_return_status);

      END IF;


      IF(p_rule_object_instance_rec.org_id IS NOT NULL) THEN
	    IF(NOT validate_org_id (p_rule_object_instance_rec.org_id)) THEN
              fnd_message.set_name('FUN', 'FUN_RULE_INVALID_ORG_ID');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
	    END IF;
      END IF;

    -- validate the input record for Rule Object Data
    FUN_RULE_VALIDATE_PKG.validate_rule_objects(
      p_create_update_flag,
      p_rule_object_instance_rec,
      p_rowid,
      x_return_status
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END validate_rule_object_instance;


/**
   * PROCEDURE validate_rule_criteria_params
   *
   * DESCRIPTION
   *     Validates rule_criteria_params record. Checks for
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
   *     p_rule_crit_params_rec         Location record.
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
   *   17-Sep-2004    Amulya Mishra     Created.
   */

  PROCEDURE validate_rule_criteria_params(
      p_create_update_flag                    IN      VARCHAR2,
      p_rule_crit_params_rec                  IN      FUN_RULE_CRIT_PARAMS_PUB.rule_crit_params_rec_type,
      p_rowid                                 IN      ROWID ,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

      l_dummy                                 VARCHAR2(1);
      l_param_name                            FUN_RULE_CRIT_PARAMS_B.PARAM_NAME%TYPE;
      l_user_param_name                       FUN_RULE_CRIT_PARAMS_TL.USER_PARAM_NAME%TYPE;
      l_description                           FUN_RULE_CRIT_PARAMS_TL.DESCRIPTION%TYPE;
      l_data_type                             FUN_RULE_CRIT_PARAMS_B.DATA_TYPE%TYPE;
      l_created_by_module                     FUN_RULE_CRIT_PARAMS_B.CREATED_BY_MODULE%TYPE;
      l_return_status                         VARCHAR2(1);
      l_rule_object_id                        FUN_RULE_OBJECTS_B.RULE_OBJECT_ID%TYPE;

  BEGIN

      -- select columns needed to be checked from table during update

      IF (p_create_update_flag = 'U') THEN
          SELECT PARAM_NAME,
                 DATA_TYPE,
                 created_by_module
          INTO   l_param_name,
                 l_data_type,
                 l_created_by_module
          FROM   FUN_RULE_CRIT_PARAMS_B
          WHERE  ROWID = p_rowid;
      END IF;

      -- Validate if a valid rule object id is passed or not

      BEGIN
	    SELECT RULE_OBJECT_ID INTO l_rule_object_id
	    FROM FUN_RULE_OBJECTS_B WHERE RULE_OBJECT_ID = p_rule_crit_params_rec.rule_object_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  fnd_message.set_name('FUN', 'FUN_RULE_INVALID_ROB');
	  fnd_msg_pub.add;
	  x_return_status := fnd_api.g_ret_sts_error;
      END;


      --------------------
      -- validate PARAM_NAME
      --------------------

      -- PARAM_NAME is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'PARAM_NAME',
          p_column_value                          => p_rule_crit_params_rec.param_name,
          x_return_status                         => x_return_status);


      --------------------
      -- validate USER_PARAM_NAME
      --------------------

      -- USER_PARAM_NAME is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'USER_PARAM_NAME',
          p_column_value                          => p_rule_crit_params_rec.user_param_name,
          x_return_status                         => x_return_status);



      --------------------
      -- validate DATA_TYPE
      --------------------

      -- DATA_TYPE is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'DATA_TYPE',
          p_column_value                          => p_rule_crit_params_rec.data_type,
          x_return_status                         => x_return_status);

      -- DATA_TYPE is lookup code in lookup type FUN_RULE_DATA_TYPE
      validate_lookup (
          p_column                                => 'DATA_TYPE',
          p_lookup_table                          => 'FUN_LOOKUPS',
          p_lookup_type                           => 'FUN_RULE_DATA_TYPE',
          p_column_value                          => p_rule_crit_params_rec.data_type,
          x_return_status                         => x_return_status);


      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      -- created_by_module is mandatory field
      -- Since created_by_module is non-updateable, we only need to check mandatory
      -- during creation.

      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'created_by_module',
              p_column_value                          => p_rule_crit_params_rec.created_by_module,
              x_return_status                         => x_return_status);
      END IF;


      -- created_by_module is non-updateable field. But it can be updated from NULL to
      -- some value.

      IF p_create_update_flag = 'U' AND
         p_rule_crit_params_rec.created_by_module IS NOT NULL
      THEN
          validate_nonupdateable (
              p_column                                => 'created_by_module',
              p_column_value                          => p_rule_crit_params_rec.created_by_module,
              p_old_column_value                      => l_created_by_module,
              p_restricted                            => 'N',
              x_return_status                         => x_return_status);
      END IF;

  END validate_rule_criteria_params;


/**
   * PROCEDURE validate_rule_details
   *
   * DESCRIPTION
   *     Validates rule_details record. Checks for
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
   *     p_rule_details_rec             Location record.
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
   *   17-Sep-2004    Amulya Mishra     Created.
   */

  PROCEDURE validate_rule_details(
      p_create_update_flag                    IN      VARCHAR2,
      p_rule_details_rec                      IN      FUN_RULE_DETAILS_PUB.rule_details_rec_type,
      p_rowid                                 IN      ROWID ,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

      l_dummy                                 VARCHAR2(1);
      l_rule_name                             FUN_RULE_DETAILS.RULE_NAME%TYPE;
      l_seq                                   FUN_RULE_DETAILS.SEQ%TYPE;
      l_operator                              FUN_RULE_DETAILS.OPERATOR%TYPE;
      l_enabled_flag                          FUN_RULE_DETAILS.ENABLED_FLAG%TYPE;
      l_result_application_id                 FUN_RULE_DETAILS.RESULT_APPLICATION_ID%TYPE;
      l_result_value                          FUN_RULE_DETAILS.RESULT_VALUE%TYPE;
      l_created_by_module                     FUN_RULE_DETAILS.CREATED_BY_MODULE%TYPE;

      l_return_status                         VARCHAR2(1);

  BEGIN


      -- select columns needed to be checked from table during update

      IF (p_create_update_flag = 'U') THEN
          SELECT RULE_NAME,
                 SEQ,
                 OPERATOR,
                 ENABLED_FLAG,
                 RESULT_APPLICATION_ID,
                 RESULT_VALUE,
                 CREATED_BY_MODULE
          INTO   l_rule_name,
                 l_seq,
                 l_operator,
                 l_enabled_flag,
                 l_result_application_id,
                 l_result_value,
                 l_created_by_module
          FROM   FUN_RULE_DETAILS
          WHERE  ROWID = p_rowid;
      END IF;


      --------------------
      -- validate RULE_NAME
      --------------------

      -- RULE_NAME is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'RULE_NAME',
          p_column_value                          => p_rule_details_rec.rule_name,
          x_return_status                         => x_return_status);

      --------------------
      -- validate SEQ
      --------------------

      -- SEQ is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'SEQ',
          p_column_value                          => p_rule_details_rec.seq,
          x_return_status                         => x_return_status);

      --------------------
      -- validate OPERATOR
      --------------------

      -- OPERATOR is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'OPERATOR',
          p_column_value                          => p_rule_details_rec.operator,
          x_return_status                         => x_return_status);

      -- OPERATOR is lookup code in lookup type FUN_RULE_OPERATORS
      validate_lookup (
          p_column                                => 'OPERATOR',
          p_lookup_table                          => 'FUN_LOOKUPS',
          p_lookup_type                           => 'FUN_RULE_OPERATORS',
          p_column_value                          => p_rule_details_rec.operator,
          x_return_status                         => x_return_status);
      --------------------
      -- validate ENABLED_FLAG
      --------------------

      -- ENABLED_FLAG is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'ENABLED_FLAG',
          p_column_value                          => p_rule_details_rec.enabled_flag,
          x_return_status                         => x_return_status);


     -- RULE_OBJECT_ID has foreign key FUN_RULE_OBJECTS.RULE_OBJECT_ID
      IF p_rule_details_rec.rule_object_id IS NOT NULL
         AND
         p_rule_details_rec.rule_object_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   FUN_RULE_OBJECTS_B
              WHERE  RULE_OBJECT_ID = p_rule_details_rec.rule_object_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('FUN', 'FUN_RULE_API_INVALID_RULE');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;
      END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      -- created_by_module is mandatory field
      -- Since created_by_module is non-updateable, we only need to check mandatory
      -- during creation.

      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'created_by_module',
              p_column_value                          => p_rule_details_rec.created_by_module,
              x_return_status                         => x_return_status);
      END IF;

      -- created_by_module is non-updateable field. But it can be updated from NULL to
      -- some value.
/*
      IF p_create_update_flag = 'U' AND
         p_rule_details_rec.created_by_module IS NOT NULL
      THEN
          validate_nonupdateable (
              p_column                                => 'created_by_module',
              p_column_value                          => p_rule_details_rec.created_by_module,
              p_old_column_value                      => l_created_by_module,
              p_restricted                            => 'N',
              x_return_status                         => x_return_status,
              p_raise_error                           => 'N');
      END IF;
*/

      --Validate Default Application Id
      IF(p_rule_details_rec.result_application_id IS NOT NULL) THEN
	    IF(NOT validate_application_id (p_rule_details_rec.result_application_id)) THEN
              fnd_message.set_name('FUN', 'FUN_RULE_INVALID_APPL_ID');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
	    END IF;
      END IF;



END validate_rule_details;

/**
   * PROCEDURE validate_rule_criteria
   *
   * DESCRIPTION
   *     Validates rule_object record. Checks for
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
   *     p_criteria_rec                 Location record.
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
   *   17-Sep-2004    Amulya Mishra     Created.
   */

  PROCEDURE validate_rule_criteria(
      p_create_update_flag                    IN      VARCHAR2,
      p_rule_criteria_rec                     IN      FUN_RULE_CRITERIA_PUB.rule_criteria_rec_type,
      p_rowid                                 IN      ROWID ,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

      l_dummy                                 VARCHAR2(1);
      l_criteria_param_id                     FUN_RULE_CRITERIA.CRITERIA_PARAM_ID%TYPE;
      l_condition                             FUN_RULE_CRITERIA.CONDITION%TYPE;
      l_param_value                           FUN_RULE_CRITERIA.PARAM_VALUE%TYPE;
      l_case_sensitive_flag                   FUN_RULE_CRITERIA.CASE_SENSITIVE_FLAG%TYPE;
      l_created_by_module                     FUN_RULE_CRITERIA.CREATED_BY_MODULE%TYPE;

      l_return_status                         VARCHAR2(1);

  BEGIN


      -- select columns needed to be checked from table during update

      IF (p_create_update_flag = 'U') THEN
          SELECT CRITERIA_PARAM_ID,
                 CONDITION,
                 PARAM_VALUE,
                 CASE_SENSITIVE_FLAG,
                 created_by_module
          INTO   l_criteria_param_id,
                 l_condition,
                 l_param_value,
                 l_case_sensitive_flag,
                 l_created_by_module
          FROM   FUN_RULE_CRITERIA
          WHERE  ROWID = p_rowid;
      END IF;

      --------------------
      -- validate CRITERIA_PARAM_NAME
      --------------------

      -- CRITERIA_PARAM_NAME is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'CRITERIA_PARAM_ID',
          p_column_value                          => p_rule_criteria_rec.criteria_param_id,
          x_return_status                         => x_return_status);

      --------------------
      -- validate CONDITION
      --------------------

      -- CONDITION is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'CONDITION',
          p_column_value                          => p_rule_criteria_rec.condition,
          x_return_status                         => x_return_status);

      -- CONDITION is lookup code in lookup type FUN_RULE_OPERATORS
      validate_lookup (
          p_column                                => 'CONDITION',
          p_lookup_table                          => 'FUN_LOOKUPS',
          p_lookup_type                           => 'FUN_RULE_MATCHING_CONDITIONS',
          p_column_value                          => p_rule_criteria_rec.condition,
          x_return_status                         => x_return_status);

      -- CASE_SENSITIVE is lookup code in lookup type FUN_RULE_OPERATORS
      IF(p_rule_criteria_rec.case_sensitive_flag IS NOT NULL) THEN
        validate_lookup (
           p_column                                => 'CASE_SENSITIVE',
           p_lookup_table                          => 'FUN_LOOKUPS',
           p_lookup_type                           => 'FUN_RULE_YES_NO',
           p_column_value                          => p_rule_criteria_rec.case_sensitive_flag,
           x_return_status                         => x_return_status);
      END IF;

      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      -- created_by_module is mandatory field
      -- Since created_by_module is non-updateable, we only need to check mandatory
      -- during creation.

      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'created_by_module',
              p_column_value                          => p_rule_criteria_rec.created_by_module,
              x_return_status                         => x_return_status);
      END IF;

      -- created_by_module is non-updateable field. But it can be updated from NULL to
      -- some value.
/*
      IF p_create_update_flag = 'U' AND
         p_rule_criteria_rec.created_by_module IS NOT NULL
      THEN
          validate_nonupdateable (
              p_column                                => 'created_by_module',
              p_column_value                          => p_rule_criteria_rec.created_by_module,
              p_old_column_value                      => l_created_by_module,
              p_restricted                            => 'N',
              x_return_status                         => x_return_status);
      END IF;
*/
  END validate_rule_criteria;


/**
   * PROCEDURE validate_rich_messages
   *
   * DESCRIPTION
   *     Validates rich_messages record record. Checks for
   *         uniqueness
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
   *     p_rich_messages_rec            Rich Messages record.
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
   *   17-Sep-2004    Amulya Mishra     Created.
   */
/*
  PROCEDURE validate_rich_messages(
      p_create_update_flag                    IN      VARCHAR2,
      p_rich_messages_rec                     IN      FUN_RICH_MESSAGES_PUB.rich_messages_rec_type,
      p_rowid                                 IN      ROWID ,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

      l_dummy                                 VARCHAR2(1);
      l_message_name                          VARCHAR2(30);
      l_language_code                         VARCHAR2(4);
      l_message_text                          CLOB;
      l_application_id                        NUMBER;
      l_created_by_module                     VARCHAR2(150);
      l_present                               NUMBER := 0;

      l_return_status                         VARCHAR2(1);

  BEGIN


      -- select columns needed to be checked from table during update

      IF (p_create_update_flag = 'U') THEN
          SELECT message_name,
                 language_code,
                 application_id,
                 created_by_module
          INTO   l_message_name,
                 l_language_code,
                 l_application_id,
                 l_created_by_module
          FROM   FUN_RICH_MESSAGES_B
          WHERE  ROWID = p_rowid;
      END IF;


      --------------------------------------------
      --validate If the combination already exists.
      --------------------------------------------


      BEGIN
         IF (p_create_update_flag = 'C') THEN
            SELECT COUNT(1)
             INTO l_present
             FROM FUN_RICH_MESSAGES_B
             WHERE MESSAGE_NAME =  p_rich_messages_rec.message_name
             AND   APPLICATION_ID = p_rich_messages_rec.application_id
             AND   LANGUAGE_CODE = p_rich_messages_rec.language_code;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_present := 0;
         WHEN OTHERS THEN
            l_present := 0;
      END;

      IF l_present > 0 THEN
          fnd_message.set_name('FUN', 'FUN_RULE_API_ALREADY_EXISTING');
          fnd_message.set_token('OBJECT', p_rich_messages_rec.message_name);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;


      --------------------
      -- validate MESSAGE_NAME
      --------------------

      -- MESSAGE_NAME is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'MESSAGE_NAME',
          p_column_value                          => p_rich_messages_rec.message_name,
          x_return_status                         => x_return_status);


      --------------------
      -- validate LANGUAGE_CODE
      --------------------

      -- LANGUAGE_CODE is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'LANGUAGE_CODE',
          p_column_value                          => p_rich_messages_rec.language_code,
          x_return_status                         => x_return_status);



      --------------------
      -- validate APPLICATION_ID
      --------------------

      -- APPLICATION_ID is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'APPLICATION_ID',
          p_column_value                          => p_rich_messages_rec.application_id,
          x_return_status                         => x_return_status);


      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      -- created_by_module is mandatory field
      -- Since created_by_module is non-updateable, we only need to check mandatory
      -- during creation.

      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'created_by_module',
              p_column_value                          => p_rich_messages_rec.created_by_module,
              x_return_status                         => x_return_status);
      END IF;

      -- created_by_module is non-updateable field. But it can be updated from NULL to
      -- some value.
      IF p_create_update_flag = 'U' AND
         p_rich_messages_rec.created_by_module IS NOT NULL
      THEN
          validate_nonupdateable (
              p_column                                => 'created_by_module',
              p_column_value                          => p_rich_messages_rec.created_by_module,
              p_old_column_value                      => l_created_by_module,
              p_restricted                            => 'N',
              x_return_status                         => x_return_status,
              p_raise_error                           => 'N');
      END IF;


  END validate_rich_messages;
*/


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
                 p_column_value = FND_API.G_MISS_CHAR)) OR
             (p_create_update_flag = 'U' AND
               p_column_value = FND_API.G_MISS_CHAR)
          THEN
              l_error := TRUE;
          END IF;
      ELSE
          IF (p_column_value IS NULL OR
               p_column_value = FND_API.G_MISS_CHAR)
          THEN
              l_error := TRUE;
          END IF;
      END IF;

      IF l_error THEN
          fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
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
                 p_column_value = FND_API.G_MISS_NUM)) OR
             (p_create_update_flag = 'U' AND
               p_column_value = FND_API.G_MISS_NUM)
          THEN
              l_error := TRUE;
          END IF;
      ELSE
          IF (p_column_value IS NULL OR
               p_column_value = FND_API.G_MISS_NUM)
          THEN
              l_error := TRUE;
          END IF;
      END IF;

      IF l_error THEN
          fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
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
          fnd_message.set_name('FUN', 'FUN_RULE_API_MISSING_COLUMN');
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
          fnd_message.set_name('FUN', 'FUN_RULE_API_NONUPDATE_COLUMN');
          fnd_message.set_token('COLUMN', p_column);
          fnd_msg_pub.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_nonupdateable;


  PROCEDURE validate_nonupdateable_atall (
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     VARCHAR2,
      p_old_column_value                      IN     VARCHAR2,
      p_restricted                            IN     VARCHAR2 DEFAULT 'Y',
      x_return_status                         IN     OUT NOCOPY VARCHAR2,
      p_raise_error                           IN     VARCHAR2 := 'Y'
 ) IS

      l_error                                 BOOLEAN := FALSE;

  BEGIN
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

      IF l_error THEN
        IF p_raise_error = 'Y' THEN
          fnd_message.set_name('FUN', 'FUN_RULE_API_NONUPDATE_COLUMN');
          fnd_message.set_token('COLUMN', p_column);
          fnd_msg_pub.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

  END validate_nonupdateable_atall;


  PROCEDURE validate_lookup (
      p_column                                IN     VARCHAR2,
      p_lookup_table                          IN     VARCHAR2 DEFAULT 'FND_LOOKUP_VALUES',
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
              fnd_message.set_name('FUN', 'FUN_RULE_API_INVALID_LOOKUP');
              fnd_message.set_token('COLUMN', p_column);
              fnd_message.set_token('LOOKUP_TYPE', p_lookup_type);
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
          END IF;
      END IF;

  END validate_lookup;


/**
   * PROCEDURE validate_rich_messages
   *
   * DESCRIPTION
   *     Validates rich_messages record record. Checks for
   *         uniqueness
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
   *     p_rich_messages_rec            Rich Messages record.
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
   *   17-Sep-2004    Amulya Mishra     Created.
   */

  PROCEDURE validate_rich_messages(
      p_create_update_flag                    IN      VARCHAR2,
      p_rich_messages_rec                     IN      FUN_RICH_MESSAGES_PUB.rich_messages_rec_type,
      p_rowid                                 IN      ROWID ,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 ) IS

      l_dummy                                 VARCHAR2(1);
      l_message_name                          VARCHAR2(30);
      l_message_text                          CLOB;
      l_application_id                        NUMBER;
      l_created_by_module                     VARCHAR2(150);
      l_present                               NUMBER := 0;

      l_return_status                         VARCHAR2(1);

  BEGIN


      -- select columns needed to be checked from table during update

      IF (p_create_update_flag = 'U') THEN
          SELECT message_name,
                 application_id,
                 created_by_module
          INTO   l_message_name,
                 l_application_id,
                 l_created_by_module
          FROM   FUN_RICH_MESSAGES_B
          WHERE  ROWID = p_rowid;
      END IF;


      --------------------------------------------
      --validate If the combination already exists.
      --------------------------------------------


      BEGIN
         IF (p_create_update_flag = 'C') THEN
            SELECT COUNT(1)
             INTO l_present
             FROM FUN_RICH_MESSAGES_B
             WHERE MESSAGE_NAME =  p_rich_messages_rec.message_name
             AND   APPLICATION_ID = p_rich_messages_rec.application_id;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_present := 0;
         WHEN OTHERS THEN
            l_present := 0;
      END;

      IF l_present > 0 THEN
          fnd_message.set_name('FUN', 'FUN_RULE_API_ALREADY_EXISTING');
          fnd_message.set_token('OBJECT', p_rich_messages_rec.message_name);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;


      --------------------
      -- validate MESSAGE_NAME
      --------------------

      -- MESSAGE_NAME is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'MESSAGE_NAME',
          p_column_value                          => p_rich_messages_rec.message_name,
          x_return_status                         => x_return_status);


      --------------------
      -- validate APPLICATION_ID
      --------------------

      -- APPLICATION_ID is mandatory
      validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'APPLICATION_ID',
          p_column_value                          => p_rich_messages_rec.application_id,
          x_return_status                         => x_return_status);


      --------------------------------------
      -- validate created_by_module
      --------------------------------------

      -- created_by_module is mandatory field
      -- Since created_by_module is non-updateable, we only need to check mandatory
      -- during creation.

      IF p_create_update_flag = 'C' THEN
          validate_mandatory (
              p_create_update_flag                    => p_create_update_flag,
              p_column                                => 'created_by_module',
              p_column_value                          => p_rich_messages_rec.created_by_module,
              x_return_status                         => x_return_status);
      END IF;

      -- created_by_module is non-updateable field. But it can be updated from NULL to
      -- some value.
      IF p_create_update_flag = 'U' AND
         p_rich_messages_rec.created_by_module IS NOT NULL
      THEN
          validate_nonupdateable (
              p_column                                => 'created_by_module',
              p_column_value                          => p_rich_messages_rec.created_by_module,
              p_old_column_value                      => l_created_by_module,
              p_restricted                            => 'N',
              x_return_status                         => x_return_status,
              p_raise_error                           => 'N');
      END IF;


  END validate_rich_messages;

  FUNCTION isFlexFieldValid(p_FlexFieldName IN VARCHAR2, p_FlexFieldAppShortName IN VARCHAR2)
  RETURN BOOLEAN IS
     source_cursor               INTEGER;
     num_rows_processed          INTEGER;
     l_num                       NUMBER;

     l_DFFSql                    VARCHAR2(1000) := 'SELECT count(1) FROM   FND_DESCRIPTIVE_FLEXS FDF
                                                    WHERE FDF.DESCRIPTIVE_FLEXFIELD_NAME = :1
                                                    AND  APPLICATION_ID IN (
	   					       SELECT APPLICATION_ID
						       FROM FND_APPLICATION_VL
						       WHERE APPLICATION_SHORT_NAME = :2)';


  BEGIN

   source_cursor := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(source_cursor, l_DFFSql,DBMS_SQL.native);
   dbms_sql.bind_variable(source_cursor , '1' , p_FlexFieldName);
   dbms_sql.bind_variable(source_cursor , '2' , p_FlexFieldAppShortName);

   dbms_sql.define_column(source_cursor, 1, l_num);

   num_rows_processed := DBMS_SQL.EXECUTE(source_cursor);

   IF DBMS_SQL.FETCH_ROWS(source_cursor)>0 THEN
    -- get column values of the row
    DBMS_SQL.COLUMN_VALUE(source_cursor, 1, l_num);
   END IF;

   DBMS_SQL.CLOSE_CURSOR(source_cursor);

   IF(l_num > 0) THEN RETURN TRUE;
   ELSE RETURN FALSE;
   END IF;

   EXCEPTION
	WHEN OTHERS THEN
	IF DBMS_SQL.IS_OPEN(source_cursor) THEN
	 DBMS_SQL.CLOSE_CURSOR(source_cursor);
	END IF;
        RETURN FALSE;
   END isFlexFieldValid;

FUNCTION validate_org_id (
        p_org_id  IN    NUMBER) RETURN BOOLEAN
IS

     source_cursor               INTEGER;
     num_rows_processed          INTEGER;
     l_num                       NUMBER;

     l_DFFSql                    VARCHAR2(1000) := 'SELECT count(1) FROM   HR_OPERATING_UNITS
                                                    WHERE NVL(ORGANIZATION_ID,-1) = NVL(:1,-1)';


  BEGIN

   source_cursor := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(source_cursor, l_DFFSql,DBMS_SQL.native);
   dbms_sql.bind_variable(source_cursor , '1' , p_org_id);

   dbms_sql.define_column(source_cursor, 1, l_num);

   num_rows_processed := DBMS_SQL.EXECUTE(source_cursor);

   IF DBMS_SQL.FETCH_ROWS(source_cursor)>0 THEN
    -- get column values of the row
    DBMS_SQL.COLUMN_VALUE(source_cursor, 1, l_num);
   END IF;

   DBMS_SQL.CLOSE_CURSOR(source_cursor);

   IF(l_num > 0) THEN RETURN TRUE;
   ELSE RETURN FALSE;
   END IF;

   EXCEPTION
	WHEN OTHERS THEN
	IF DBMS_SQL.IS_OPEN(source_cursor) THEN
	 DBMS_SQL.CLOSE_CURSOR(source_cursor);
	END IF;
        RETURN FALSE;
END validate_org_id;

FUNCTION validate_application_id (
        p_application_id  IN    NUMBER) RETURN BOOLEAN
IS

     source_cursor               INTEGER;
     num_rows_processed          INTEGER;
     l_num                       NUMBER;

     l_DFFSql                    VARCHAR2(1000) := 'SELECT count(1) FROM   FND_APPLICATION
                                                    WHERE APPLICATION_ID = :1';


  BEGIN
   source_cursor := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(source_cursor, l_DFFSql,DBMS_SQL.native);
   dbms_sql.bind_variable(source_cursor , '1' , p_application_id);

   dbms_sql.define_column(source_cursor, 1, l_num);

   num_rows_processed := DBMS_SQL.EXECUTE(source_cursor);

   IF DBMS_SQL.FETCH_ROWS(source_cursor)>0 THEN
    -- get column values of the row
    DBMS_SQL.COLUMN_VALUE(source_cursor, 1, l_num);
   END IF;

   DBMS_SQL.CLOSE_CURSOR(source_cursor);

   IF(l_num > 0) THEN RETURN TRUE;
   ELSE RETURN FALSE;
   END IF;

   EXCEPTION
	WHEN OTHERS THEN
	IF DBMS_SQL.IS_OPEN(source_cursor) THEN
	 DBMS_SQL.CLOSE_CURSOR(source_cursor);
	END IF;
        RETURN FALSE;
END validate_application_id;


FUNCTION validate_flex_value_set_id(p_flex_value_set_id  IN NUMBER)
RETURN BOOLEAN
IS

     source_cursor               INTEGER;
     num_rows_processed          INTEGER;
     l_num                       NUMBER;

     l_DFFSql                    VARCHAR2(1000) := 'SELECT count(1) FROM   FND_FLEX_VALUE_SETS
                                                    WHERE FLEX_VALUE_SET_ID = :1';

  BEGIN

   source_cursor := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(source_cursor, l_DFFSql,DBMS_SQL.native);
   dbms_sql.bind_variable(source_cursor , '1' , p_flex_value_set_id);

   dbms_sql.define_column(source_cursor, 1, l_num);

   num_rows_processed := DBMS_SQL.EXECUTE(source_cursor);

   IF DBMS_SQL.FETCH_ROWS(source_cursor)>0 THEN
    -- get column values of the row
    DBMS_SQL.COLUMN_VALUE(source_cursor, 1, l_num);
   END IF;

   DBMS_SQL.CLOSE_CURSOR(source_cursor);

   IF(l_num > 0) THEN RETURN TRUE;
   ELSE RETURN FALSE;
   END IF;

   EXCEPTION
	WHEN OTHERS THEN
	IF DBMS_SQL.IS_OPEN(source_cursor) THEN
	 DBMS_SQL.CLOSE_CURSOR(source_cursor);
	END IF;
        RETURN FALSE;
END validate_flex_value_set_id;

END FUN_RULE_VALIDATE_PKG;

/
