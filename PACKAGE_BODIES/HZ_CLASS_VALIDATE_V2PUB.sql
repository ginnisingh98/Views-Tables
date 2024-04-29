--------------------------------------------------------
--  DDL for Package Body HZ_CLASS_VALIDATE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CLASS_VALIDATE_V2PUB" AS
/*$Header: ARH2CLVB.pls 120.57.12000000.2 2007/10/01 14:48:20 manjayar ship $ */


/*---------------------
  -- Local variables --
  ---------------------*/
-- Bug 3962783
--g_ex_invalid_param     EXCEPTION;
l_owner_table_name     VARCHAR2(30);
l_owner_table_id       VARCHAR2(30);
l_content_source_type  VARCHAR2(30);
l_class_code           VARCHAR2(30);
l_class_code2          VARCHAR2(30);
l_class_code3          VARCHAR2(30);
l_start_date_active    DATE;
l_end_date_active      DATE;
l_start_date_active2   DATE;
l_end_date_active2     DATE;
l_start                VARCHAR2(15);
l_end                  VARCHAR2(15);
l_start2               VARCHAR2(15);
l_end2                 VARCHAR2(15);
l_text                 VARCHAR2(4000);
l_column_name          VARCHAR2(240);

-----------------------------------------------------------------
-- Private procedures and functions used internally by validation
-- process. These are brought from old hz_common_pub.
-----------------------------------------------------------------

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
                fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                fnd_message.set_token('COLUMN', p_col_name);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
                RETURN;
        END IF;

        IF (create_update_flag = 'C') THEN
                IF ((NOT p_miss_allowed_in_c) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        ELSE
                IF ((NOT p_miss_allowed_in_u) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
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
                fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                fnd_message.set_token('COLUMN', p_col_name);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
                RETURN;
        END IF;

        IF (create_update_flag = 'C') THEN
                IF ((NOT p_miss_allowed_in_c) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        ELSE
                IF ((NOT p_miss_allowed_in_u) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
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
                fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                fnd_message.set_token('COLUMN', p_col_name);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
                RETURN;
        END IF;

        IF (create_update_flag = 'C') THEN
                IF ((NOT p_miss_allowed_in_c) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        ELSE
                IF ((NOT p_miss_allowed_in_u) AND
                        p_col_val IS NULL )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
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
-- Bug 3614582 : Removed TRUNC from the date comparison.
--               Also consider fnd_api.g_miss_date in comparison.
/*  ldate1 := trunc(date1);
  ldate2 := trunc(date2);*/
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
    -- bug 4212585
    AND enabled_flag = 'Y'
    AND sysdate between nvl(start_date_active,sysdate) AND nvl(end_date_active,sysdate+1)
    AND ROWNUM      = 1;

 l_exist VARCHAR2(1);
BEGIN
 IF (    p_column_value IS NOT NULL
     AND p_column_value <> fnd_api.g_miss_char ) THEN
     OPEN c1;
     FETCH c1 INTO l_exist;
     IF c1%NOTFOUND THEN
       fnd_message.set_name('AR','HZ_API_INVALID_LOOKUP');
       fnd_message.set_token('COLUMN',p_column);
       fnd_message.set_token('LOOKUP_TYPE',p_lookup_type);
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
     END IF;
     CLOSE c1;
 END IF;
END validate_fnd_lookup;

--Bug 2830772: When the content_source_type not 'USER_ENTERED' and
--lookup type is 'NACE', the overloaded procedure, validate_fnd_lookup
--will be called.
PROCEDURE validate_fnd_lookup
( p_lookup_type          IN     VARCHAR2,
  p_column               IN     VARCHAR2,
  p_column_value         IN     VARCHAR2,
  p_content_source_type  IN     VARCHAR2,
  x_return_status        IN OUT NOCOPY VARCHAR2)
IS

 --Bug 2830772: Added the cursor for 'NACE' lookup type where clause to ignore
 --the period when comparing the lookup_code.
 CURSOR c_nace
 IS
 SELECT 'Y'
   FROM fnd_lookup_values
  WHERE lookup_type = p_lookup_type
    AND replace(lookup_code, '.', '') = replace(p_column_value, '.', '')
    -- bug 4212585
    AND enabled_flag = 'Y'
    AND sysdate between nvl(start_date_active,sysdate) AND nvl(end_date_active,sysdate+1)
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

/*--------------------------------------------------------
  -- Function usable in any validation entities sections -
  --------------------------------------------------------*/

/*
If the delimiter is used for an existing class code meaning. Then this
delimiter is not valid */
FUNCTION is_valid_delimiter(p_class_category in varchar2, p_delimiter in
varchar2) return varchar2 is

    cursor get_invalid_delimiter_csr is
        select 'x'
        from fnd_lookup_values_vl
        where lookup_type = p_class_category
        and sysdate between start_date_active and nvl(end_date_active,sysdate)
        and   instrb(meaning,p_delimiter)>0;

l_tmp varchar2(1);
begin
        open get_invalid_delimiter_csr;
        fetch get_invalid_delimiter_csr into l_tmp;
        if get_invalid_delimiter_csr%NOTFOUND
        then
                close get_invalid_delimiter_csr;
                return 'Y';
        else return 'N';
        end if;
        close get_invalid_delimiter_csr;
end is_valid_delimiter;

/*
If the class code meaning contains the delimiter used for the class category,
need to modify the meaning of this class code */
FUNCTION is_valid_class_code_meaning(p_class_category in varchar2, p_meaning in
varchar2) return varchar2 is

    cursor get_invalid_meaning_csr is
        select 'x'
        from hz_class_categories
        where class_category = p_class_category
        and   instrb(p_meaning,delimiter)>0;

l_tmp varchar2(1);
begin
        open get_invalid_meaning_csr;
        fetch get_invalid_meaning_csr into l_tmp;
        if get_invalid_meaning_csr%NOTFOUND
        then
                close get_invalid_meaning_csr;
                return 'Y';
        else return 'N';
        end if;
        close get_invalid_meaning_csr;
end is_valid_class_code_meaning;

PROCEDURE check_existence_class_category
 (p_class_category     IN     VARCHAR2,
  x_return_status      IN OUT NOCOPY VARCHAR2)
IS
 CURSOR c_exist_class_category(p_class_category IN VARCHAR2)
 IS
 SELECT 'Y'
   FROM hz_class_categories
  WHERE class_category = p_class_category
    AND ROWNUM         = 1;
 l_exist   VARCHAR2(1);
BEGIN
 OPEN c_exist_class_category(p_class_category);
  FETCH c_exist_class_category INTO l_exist;
  IF c_exist_class_category%NOTFOUND THEN
   fnd_message.set_name('AR','HZ_API_INVALID_FK');
   fnd_message.set_token('FK','class_category');
   fnd_message.set_token('COLUMN','class_category');
   fnd_message.set_token('TABLE','hz_class_categories');
   fnd_msg_pub.add;
   x_return_status := fnd_api.g_ret_sts_error;
  END IF;
 CLOSE c_exist_class_category;
END check_existence_class_category;

/*

Commented this function

FUNCTION result_caller
(pack   VARCHAR2,
 comp   VARCHAR2,
 code0  VARCHAR2 DEFAULT NULL,
 code1  VARCHAR2 DEFAULT NULL,
 code2  VARCHAR2 DEFAULT NULL,
 code3  VARCHAR2 DEFAULT NULL,
 code4  VARCHAR2 DEFAULT NULL,
 code5  VARCHAR2 DEFAULT NULL,
 code6  VARCHAR2 DEFAULT NULL,
 code7  VARCHAR2 DEFAULT NULL,
 code8  VARCHAR2 DEFAULT NULL,
 code9  VARCHAR2 DEFAULT NULL,
 date0  DATE DEFAULT NULL,
 date1  DATE DEFAULT NULL,
 date2  DATE DEFAULT NULL,
 date3  DATE DEFAULT NULL,
 date4  DATE DEFAULT NULL,
 date5  DATE DEFAULT NULL,
 date6  DATE DEFAULT NULL,
 date7  DATE DEFAULT NULL,
 text   VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
 lcode0  VARCHAR2(100);
 lcode1  VARCHAR2(100);
 lcode2  VARCHAR2(100);
 lcode3  VARCHAR2(100);
 lcode4  VARCHAR2(100);
 lcode5  VARCHAR2(100);
 lcode6  VARCHAR2(100);
 lcode7  VARCHAR2(100);
 lcode8  VARCHAR2(100);
 lcode9  VARCHAR2(100);
 ldate0  DATE;
 ldate1  DATE;
 ldate2  DATE;
 ldate3  DATE;
 ldate4  DATE;
 ldate5  DATE;
 ldate6  DATE;
 ldate7  DATE;
 ltext   VARCHAR2(4000);
 result  VARCHAR2(50);
BEGIN
 IF upper(pack) = 'HZ_CLASSIFICATION_VALIDATE' THEN
   IF    upper(comp) = 'INSTANCE_ALREADY_ASSIGNED' THEN
     result := HZ_CLASSIFICATION_VALIDATE.INSTANCE_ALREADY_ASSIGNED
               (date0, date1,
                code0, code1, code2, code3,
                lcode0,
                ldate0,ldate1);
     RETURN result;
   ELSIF upper(comp) = 'PARENT_CODE' THEN
     result := HZ_CLASSIFICATION_VALIDATE.PARENT_CODE
               (code0, code1,
                date0, date1,
                lcode0,
                ldate0,ldate1);
     RETURN result;

   ELSIF upper(comp) = 'CHILD_CODE' THEN
     result := HZ_CLASSIFICATION_VALIDATE.CHILD_CODE
               (code0, code1,
                date0, date1,
                lcode0,
                ldate0,ldate1);
     RETURN result;

   ELSIF upper(comp) = 'IS_ALL_INST_LESS_ONE_CODE' THEN
     result := HZ_CLASSIFICATION_VALIDATE.IS_ALL_INST_LESS_ONE_CODE
               (code0,
                lcode0,lcode1,lcode2,lcode3,lcode4,
                ldate0,ldate1,ldate2,ldate3);
     RETURN result;

   ELSIF upper(comp) = 'IS_ALL_CODE_ONE_PARENT_ONLY' THEN
     result := HZ_CLASSIFICATION_VALIDATE.IS_ALL_CODE_ONE_PARENT_ONLY
               (code0,
                lcode0,lcode1,lcode2,
                ldate0,ldate1,ldate2,ldate3);
     RETURN result;

   ELSIF upper(comp) = 'SQL_VALID' THEN
     result := HZ_CLASSIFICATION_VALIDATE.SQL_VALID
               (text,
                lcode0);
     RETURN result;

   ELSIF upper(comp) = 'SQL_STR_BUILD' THEN
     result := HZ_CLASSIFICATION_VALIDATE.SQL_STR_BUILD
               (code0, code1, code2,
                lcode0, ltext);
     RETURN ltext;

   ELSIF upper(comp) = 'EXIST_PK_CODE_ASSIGN' THEN
     result := HZ_CLASSIFICATION_VALIDATE.EXIST_PK_CODE_ASSIGN
               (code0, code1, code2, code3, code4,
                date0,
                lcode0,ldate0);
     RETURN result;

   ELSIF upper(comp) = 'EXIST_PRIM_ASSIGN' THEN
     result := HZ_CLASSIFICATION_VALIDATE.EXIST_PRIM_ASSIGN
               (code0, code1, code2, code3, code4,
                date0, date1,
                lcode0, ldate0, ldate1);
     RETURN result;

   ELSIF upper(comp) = 'EXIST_SAME_CODE_ASSIGN' THEN
     result := HZ_CLASSIFICATION_VALIDATE.EXIST_SAME_CODE_ASSIGN
               (code0, code1, code2, code3, code4, code5,
                date0, date1,
                lcode0, ldate0, ldate1);
     RETURN result;

   ELSIF upper(comp) = 'EXIST_SECOND_ASSIGN_SAME_CODE' THEN
     result := HZ_CLASSIFICATION_VALIDATE.EXIST_SAME_CODE_ASSIGN
               (code0, code1, code2, code3, code4, code5,
                date0, date1,
                lcode0, ldate0, ldate1);
     RETURN result;

   END IF;
 END IF;

END result_caller;

*/

PROCEDURE check_start_end_active_dates(
          p_start_date_active   IN DATE,
          p_end_date_active     IN DATE,
          x_return_status       IN OUT NOCOPY VARCHAR2
)
IS
BEGIN
  --end date must be null or greater than start date
   IF  (    p_end_date_active IS NOT NULL
       AND  p_end_date_active <> fnd_api.G_MISS_DATE  )
   THEN
    IF (     p_start_date_active IS NOT NULL AND
             p_start_date_active <> fnd_api.G_MISS_DATE  AND
             p_end_date_active   <  p_start_date_active      )
    THEN
        fnd_message.set_name('AR', 'HZ_API_START_DATE_GREATER');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;
  END IF;
END check_start_end_active_dates;

-- Bug 3962783
/*
procedure check_err(
        x_return_status    IN  VARCHAR2
) IS
BEGIN
        IF x_return_status = fnd_api.g_ret_sts_error
        THEN
                RAISE g_ex_invalid_param;
        END IF;
END;
*/

/*----------------------------------------
  -- Validation for Hz_Class_Categories --
  ----------------------------------------*/
FUNCTION exist_code_ass_not_node
-- This function answer to the question:
-- Return 'Y'  if the category has one or more Non-Leaf-node Class Codes associated with instances of entities
--             active for to_date
--        'N'  otherwise
( p_class_category IN VARCHAR2)
RETURN VARCHAR2
IS
 CURSOR c1
 IS
 SELECT 'Y'
   FROM hz_code_assignments     a,
        hz_class_code_relations b
  WHERE a.class_category   = p_class_category
    AND b.class_category   = p_class_category
    AND a.class_code       = b.class_code
    AND ((       a.start_date_active <= SYSDATE
             AND NVL(a.end_date_active  , SYSDATE) >= SYSDATE )
          OR     a.start_date_active >  SYSDATE                )
    AND ((       b.start_date_active <= SYSDATE
             AND NVL(b.end_date_active  , SYSDATE) >= SYSDATE )
          OR     b.start_date_active >  SYSDATE                )
    AND ROWNUM             = 1;
 l_yn   VARCHAR2(1);
 result VARCHAR2(1);
BEGIN
 OPEN c1;
       FETCH c1 INTO l_yn;
       IF c1%NOTFOUND THEN
         -- There is no parent-level class code in this category assigned to an instance of entity.
         result := 'N';
       ELSE
         result := 'Y';
       END IF;
 CLOSE c1;
 RETURN result;
END exist_code_ass_not_node;

FUNCTION exist_reverse_relation
-- Return 'Y' if the entered sub-code was defined as the parent-code of the entered class-code within that category
--            for active periods
--        'N' otherwise
( p_class_category IN VARCHAR2,
  p_class_code     IN VARCHAR2,
  p_sub_class_code IN VARCHAR2,
  p_start_date_active IN DATE,
  p_end_date_active   IN DATE)
RETURN VARCHAR2
IS
 CURSOR c0
 IS
 SELECT start_date_active,
        end_date_active
   FROM hz_class_code_relations
  WHERE class_category = p_class_category
    AND class_code     = p_sub_class_code
    AND sub_class_code = p_class_code
    AND ((    NVL(end_date_active  , SYSDATE) >= SYSDATE
          AND NVL(start_date_active, SYSDATE) <= SYSDATE)
         OR   start_date_active > SYSDATE );
 l_start_date_active DATE;
 l_end_date_active   DATE;
 result              VARCHAR2(1);
BEGIN
 OPEN c0;
 result  := 'N';
 LOOP
     FETCH c0 INTO l_start_date_active, l_end_date_active;
     EXIT WHEN c0%NOTFOUND;
     IF is_overlap(p_start_date_active, p_end_date_active,
                   l_start_date_active, l_end_date_active) = 'Y'
     THEN
           result := 'Y';
           EXIT;
     END IF;
 END LOOP;
 CLOSE c0;
 RETURN result;
END exist_reverse_relation;

FUNCTION is_all_code_one_parent_only
-- Return Y if all class codes inside a category have no more than one parent for the current and futur period
--        N otherwise
(p_class_category     VARCHAR2,
 x_class_code         IN OUT NOCOPY VARCHAR2,
 x_class_code2        IN OUT NOCOPY VARCHAR2,
 x_sub_class_code     IN OUT NOCOPY VARCHAR2,
 x_start_date_active  IN OUT NOCOPY DATE,
 x_end_date_active    IN OUT NOCOPY DATE,
 x_start_date_active2 IN OUT NOCOPY DATE,
 x_end_date_active2   IN OUT NOCOPY DATE )
RETURN VARCHAR2
IS
 CURSOR c0
 IS
 SELECT sub_class_code,
        start_date_active,
        end_date_active
   FROM hz_class_code_relations
  WHERE class_category  = p_class_category;
 CURSOR c1(p_class_category VARCHAR2, p_sub_class_code VARCHAR2)
 IS
 SELECT class_code,
        start_date_active,
        end_date_active
   FROM hz_class_code_relations
  WHERE class_category  = p_class_category
    AND sub_class_code  = p_sub_class_code;
 sub_code_has_two_parents EXCEPTION;
 l_class_code         VARCHAR2(30);
 l_sub_class_code     VARCHAR2(30);
 l_start_date_active  DATE;
 l_end_date_active    DATE;
 result   VARCHAR2(1);
 l_count  NUMBER;
BEGIN
 result  := 'Y';
 l_count := 0;
 OPEN c0;
 LOOP
  FETCH c0 INTO l_sub_class_code, l_start_date_active, l_end_date_active;
  EXIT WHEN c0%NOTFOUND;
  IF is_overlap( l_start_date_active, l_end_date_active,
                 SYSDATE            , NULL              ) = 'Y'
  THEN
    x_sub_class_code    := l_sub_class_code;
    l_count := 0;
    OPEN c1(p_class_category, l_sub_class_code);
    LOOP
      FETCH c1 INTO l_class_code, l_start_date_active, l_end_date_active;
      EXIT WHEN c1%NOTFOUND;

      IF is_overlap( l_start_date_active, l_end_date_active,
                     SYSDATE            , NULL              ) = 'Y'
      THEN
         l_count := l_count + 1;
         IF l_count = 1 THEN
           x_class_code        := l_class_code;
           x_start_date_active := l_start_date_active;
           x_end_date_active   := l_end_date_active;
         ELSIF l_count > 1 THEN
           RAISE sub_code_has_two_parents;
         END IF;
      END IF;
    END LOOP;
    CLOSE c1;
  END IF;
 END LOOP;
 CLOSE c0;
 RETURN result;
EXCEPTION
 WHEN sub_code_has_two_parents THEN
     result := 'N';
     x_class_code2       := l_class_code;
     x_start_date_active2:= l_start_date_active;
     x_end_date_active2  := l_end_date_active;
     CLOSE c1;
     CLOSE c0;
     RETURN result;
END is_all_code_one_parent_only;

FUNCTION is_all_inst_less_one_code
-- Return Y if all the instances of 1 entity has 0 to 1 code assigned
--          for 1 category, 1 content active to day or in the futur.
--        N otherwise

-- SSM SST Integration and Extension
-- Changed all reference from content_source_type to actual_content_source.
( p_class_category      VARCHAR2,
  x_owner_table         IN OUT NOCOPY VARCHAR2,
  x_owner_table_id      IN OUT NOCOPY VARCHAR2,
  x_content_source_type IN OUT NOCOPY VARCHAR2,
  x_class_code          IN OUT NOCOPY VARCHAR2,
  x_class_code2         IN OUT NOCOPY VARCHAR2,
  x_start_date_active   IN OUT NOCOPY DATE,
  x_end_date_active     IN OUT NOCOPY DATE,
  x_start_date_active2  IN OUT NOCOPY DATE,
  x_end_date_active2    IN OUT NOCOPY DATE )
RETURN VARCHAR2
IS
 -- Bug 4942316
 CURSOR c0
 IS
 SELECT DISTINCT actual_content_source,
        owner_table_name,
	owner_table_id
   FROM hz_code_assignments ca, fnd_lookup_values_vl lv
  WHERE ca.class_category = p_class_category
    AND ca.class_category = lv.lookup_type
    AND ca.class_code = lv.lookup_code;

 CURSOR c1( l_content_source_type IN VARCHAR2, l_owner_table_name IN VARCHAR2, l_owner_table_id IN VARCHAR2)
 IS
 SELECT class_code,
        start_date_active,
        end_date_active
   FROM hz_code_assignments
  WHERE class_category      = p_class_category
    AND actual_content_source = l_content_source_type
    AND owner_table_name    = l_owner_table_name
    AND owner_table_id      = l_owner_table_id;

l_class_code            VARCHAR2(30);
l_content_source_type   VARCHAR2(30);
l_owner_table_name      VARCHAR2(30);
l_owner_table_id        VARCHAR2(30);
l_start_date_active     DATE;
l_end_date_active       DATE;
lcount                  NUMBER;
result                  VARCHAR2(1);
exist_id_multi_parent   EXCEPTION;

BEGIN
 result   := 'Y';
 OPEN c0;
 LOOP
     FETCH c0 INTO l_content_source_type, l_owner_table_name, l_owner_table_id;
     EXIT WHEN c0%NOTFOUND;
     OPEN c1( l_content_source_type, l_owner_table_name, l_owner_table_id);
     lcount   := 0;
     LOOP
         FETCH c1 INTO l_class_code, l_start_date_active, l_end_date_active;
         EXIT WHEN c1%NOTFOUND;
         IF is_overlap( l_start_date_active, l_end_date_active,
                        SYSDATE            , NULL              ) = 'Y'
         THEN
           lcount := lcount + 1;
           IF lcount = 1 THEN
              x_class_code         := l_class_code;
              x_start_date_active  := l_start_date_active;
              x_end_date_active    := l_end_date_active;
           ELSIF lcount > 1 THEN
              result := 'N';
              x_start_date_active2 := l_start_date_active;
              x_end_date_active2   := l_end_date_active;
              x_class_code2        := l_class_code;
              x_owner_table        := l_owner_table_name;
              x_owner_table_id     := l_owner_table_id;
              x_content_source_type:= l_content_source_type;
              x_start_date_active  := l_start_date_active;
              x_end_date_active    := l_end_date_active;
              RAISE exist_id_multi_parent;
           END IF;
         END IF;
     END LOOP;
     CLOSE c1;
 END LOOP;
 CLOSE c0;
 RETURN result;

EXCEPTION
 WHEN exist_id_multi_parent THEN
  CLOSE c1;
  CLOSE c0;
  RETURN result;
END is_all_inst_less_one_code;


FUNCTION exist_class_category
-- Return Y if the class category exists
--        N otherwise
(p_class_category  VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
SELECT 'Y'
  FROM hz_class_categories
 WHERE class_category = p_class_category;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END exist_class_category;

--Bug 2825328: Added over_loaded procedures for validating the non-updatable
--columns like owner_table_name, owner_table_id, and owner_table_key_1 to 5.
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
              IF (p_old_column_value IS NOT NULL AND        -- Bug 3439053.
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

--Bug 2825328: Added over_loaded procedures for validating the non-updatable
--columns like owner_table_name, owner_table_id, and owner_table_key_1 to 5.
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
              IF (p_old_column_value IS NOT NULL AND       -- Bug 3439053.
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

procedure validate_class_category(
  p_class_cat_rec     IN      HZ_CLASSIFICATION_V2PUB.CLASS_CATEGORY_REC_TYPE,
  create_update_flag  IN      VARCHAR2,
  x_return_status     IN OUT NOCOPY  VARCHAR2
) IS
  l_count NUMBER;
  l_created_by_module hz_class_categories.created_by_module%TYPE := NULL;

  CURSOR cu_lookup_type IS
  SELECT 1
  FROM fnd_lookup_types
  WHERE lookup_type = p_class_cat_rec.class_category
  AND rownum = 1;

  CURSOR c_categories IS
  select created_by_module
  from hz_class_categories
  where class_category = p_class_cat_rec.class_category;

BEGIN

        IF create_update_flag = 'U' THEN
          OPEN c_categories;
          FETCH c_categories INTO l_created_by_module;
          CLOSE c_categories;
        END IF;

--Check for mandatory columns
        check_mandatory_str_col(create_update_flag, 'class_category',
                p_class_cat_rec.class_category,
                FALSE,
                FALSE, -- cannot be missing: PK
                x_return_status);

        check_mandatory_str_col(create_update_flag, 'allow_multi_assign_flag',
                p_class_cat_rec.allow_multi_assign_flag,
                FALSE,
                TRUE,
                x_return_status);

        check_mandatory_str_col(create_update_flag, 'allow_multi_parent_flag',
                p_class_cat_rec.allow_multi_parent_flag,
                FALSE,
                TRUE,
                x_return_status);




--{HYU:bug
        check_mandatory_str_col(create_update_flag, 'allow_leaf_node_only_flag',
                p_class_cat_rec.allow_leaf_node_only_flag,
                FALSE,
                TRUE,
                x_return_status);
--}


        --Bug 2890671: created_by_module column is mandatory
        -- created_by_module is non-updateable, lookup

        hz_utility_v2pub.validate_created_by_module(
          p_create_update_flag     => create_update_flag,
          p_created_by_module      => p_class_cat_rec.created_by_module,
          p_old_created_by_module  => l_created_by_module,
          x_return_status          => x_return_status);

        --check_err( x_return_status );

--Check for lookup type validations.
  OPEN cu_lookup_type;
  FETCH cu_lookup_type INTO l_count;
  IF cu_lookup_type%NOTFOUND  THEN
        fnd_message.set_name('AR', 'HZ_API_INVALID_LOOKUP');
        fnd_message.set_token('COLUMN', 'class_category');
        fnd_message.set_token('LOOKUP_TYPE', p_class_cat_rec.class_category);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
  END IF;
  CLOSE cu_lookup_type;

        validate_fnd_lookup(
                'YES/NO',
                'allow_multi_assign_flag',
                p_class_cat_rec.allow_multi_assign_flag,
                x_return_status);
        validate_fnd_lookup(
                'YES/NO',
                'allow_multi_parent_flag',
                p_class_cat_rec.allow_multi_parent_flag,
                x_return_status);
        validate_fnd_lookup(
                'YES/NO',
                'allow_leaf_node_only_flag',
                p_class_cat_rec.allow_leaf_node_only_flag,
                x_return_status);

        --check_err( x_return_status );

-- Check PK
        IF create_update_flag = 'C' THEN
          IF exist_class_category(p_class_cat_rec.class_category) = 'Y' THEN
                        fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
                        fnd_message.set_token('COLUMN', p_class_cat_rec.class_category);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
          END IF;
      END IF;


--{HYU Bug : 1607680 allow_leaf_node_only_flag
     IF  create_update_flag = 'U' THEN

      IF (   (p_class_cat_rec.allow_leaf_node_only_flag = 'Y'               )
         AND (exist_code_ass_not_node(p_class_cat_rec.class_category) = 'Y' )  )
      THEN
         fnd_message.set_name('AR', 'HZ_API_LEAF_ONLY_NOT_ALLOWED');
         fnd_message.set_token('CLASS_CATEGORY', p_class_cat_rec.class_category);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      IF (    (p_class_cat_rec.allow_multi_parent_flag = 'N'                     )
          AND (is_all_code_one_parent_only
                 (p_class_cat_rec.class_category,
                  l_class_code,
                  l_class_code2,
                  l_class_code3,
                  l_start_date_active,
                  l_end_date_active,
                  l_start_date_active2,
                  l_end_date_active) = 'N' ) )

      THEN
         l_start   :=  TO_CHAR(l_start_date_active, 'DD-MON-RRRR');
         IF l_end_date_active IS NULL THEN
            l_end  := 'Unspecified';
         ELSE
            l_end  :=  TO_CHAR(l_end_date_active, 'DD-MON-RRRR');
         END IF;

         l_start2   :=  TO_CHAR(l_start_date_active2, 'DD-MON-RRRR');
         IF l_end_date_active2 IS NULL THEN
            l_end2  := 'Unspecified';
         ELSE
            l_end2  :=  TO_CHAR(l_end_date_active2, 'DD-MON-RRRR');
         END IF;

         fnd_message.set_name('AR', 'HZ_API_SIN_PAR_NOT_ALLOWED');
         fnd_message.set_token('CLASS_CATEGORY', p_class_cat_rec.class_category);
         fnd_message.set_token('CLASS_CODE1'   , l_class_code);
         fnd_message.set_token('CLASS_CODE2'   , l_class_code2);
         fnd_message.set_token('CLASS_CODE3'   , l_class_code3);
         fnd_message.set_token('START1'        , l_start);
         fnd_message.set_token('END1'          , l_end);
         fnd_message.set_token('START2'        , l_start2);
         fnd_message.set_token('END2'          , l_end2);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      IF (    (p_class_cat_rec.allow_multi_assign_flag = 'N'                  )
          AND (is_all_inst_less_one_code(p_class_cat_rec.class_category,
                                         l_owner_table_name,
                                         l_owner_table_id,
                                         l_content_source_type,
                                         l_class_code,
                                         l_class_code2,
                                         l_start_date_active,
                                         l_end_date_active,
                                         l_start_date_active2,
                                         l_end_date_active2 )      )='N' )
      THEN
         l_start   :=  TO_CHAR(l_start_date_active, 'DD-MON-RRRR');
         IF l_end_date_active IS NULL THEN
            l_end  := 'Unspecified';
         ELSE
            l_end  :=  TO_CHAR(l_end_date_active, 'DD-MON-RRRR');
         END IF;

         l_start2   :=  TO_CHAR(l_start_date_active2, 'DD-MON-RRRR');
         IF l_end_date_active2 IS NULL THEN
            l_end2  := 'Unspecified';
         ELSE
            l_end2  :=  TO_CHAR(l_end_date_active2, 'DD-MON-RRRR');
         END IF;

         fnd_message.set_name('AR', 'HZ_API_SIN_ASS_NOT_ALLOWED');
         fnd_message.set_token('CLASS_CATEGORY'    , p_class_cat_rec.class_category);
         fnd_message.set_token('OWNER_TABLE'       , l_owner_table_name);
         fnd_message.set_token('OWNER_TABLE_ID'    , l_owner_table_id);
         fnd_message.set_token('CONTENT_SOURCE_TYPE', l_content_source_type);
         fnd_message.set_token('CLASS_CODE1'       , l_class_code);
         fnd_message.set_token('CLASS_CODE2'       , l_class_code2);
         fnd_message.set_token('START1'            , l_start_date_active);
         fnd_message.set_token('END1'              , l_end_date_active);
         fnd_message.set_token('START2'            , l_start_date_active2);
         fnd_message.set_token('END2'  ,             l_end_date_active2);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

     END IF;
     --check_err( x_return_status );
--}
/* -- Bug 3962783
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  x_return_status := fnd_api.G_RET_STS_ERROR;
*/
END validate_class_category;



/*-------------------------------------------
  -- Validation for Hz_Class_Category_Uses --
  -------------------------------------------*/
FUNCTION existence_couple_clacat_owntab
 ( p_create_update_flag IN     VARCHAR2,
   p_class_category     IN     VARCHAR2,
   p_owner_table        IN     VARCHAR2 )
RETURN VARCHAR2
IS
 CURSOR c_nb(
   p_class_category   IN     VARCHAR2,
   p_owner_table      IN     VARCHAR2)
 IS
 SELECT COUNT(1)
   FROM hz_class_category_uses
  WHERE class_category = p_class_category
    AND owner_table    = p_owner_table;
 l_count NUMBER;
 result VARCHAR2(1);
BEGIN
 OPEN c_nb(p_class_category, p_owner_table);
  FETCH c_nb INTO l_count;
 CLOSE c_nb;
 -- In creation mode the concatenated PK should not exist
 -- In updating mode the concatenated PK can exist
 IF (   (p_create_update_flag = 'C' AND l_count <> 0 )
     OR (p_create_update_flag = 'U' AND l_count >  1 ))
 THEN
    result := 'Y';
 ELSE
    result := 'N';
 END IF;
 RETURN result;
END existence_couple_clacat_owntab;

PROCEDURE validate_class_category_use(
  p_in_rec           IN     hz_classification_V2PUB.class_category_use_rec_type,
  create_update_flag IN     VARCHAR2,
  x_return_status    IN OUT NOCOPY VARCHAR2 )
IS
  l_end_date  DATE   := NULL;
  l_count     NUMBER := 0;
  l_yn        VARCHAR2(1);
  xx_obj      varchar2(1) := NULL;
  l_created_by_module hz_class_category_uses.created_by_module%TYPE;

  CURSOR c_uses IS
  select created_by_module
  from hz_class_category_uses
  where class_category = p_in_rec.class_category
  and owner_table = p_in_rec.owner_table;

BEGIN

 IF create_update_flag = 'U' THEN
   OPEN c_uses;
   FETCH c_uses INTO l_created_by_module;
   CLOSE c_uses;
 END IF;

 -- class_category is a mandatory column
 check_mandatory_str_col(
    create_update_flag,
    'class_category',
    p_in_rec.class_category,
    FALSE,
    FALSE,
    x_return_status);

 --check_err(x_return_status);

 -- owner_table is a mandatory column
 check_mandatory_str_col(
    create_update_flag,
    'owner_table',
    p_in_rec.owner_table,
    FALSE,
    FALSE,
    x_return_status);

 --check_err(x_return_status);

 --Bug 2861251: Column name should accept null. In classification UI,
 --the column_name is getting removed.
 -- column_name is a conditional mandatory column
 -- For HZ_PARTIES, the column_name column is mandatory
 --IF UPPER(p_in_rec.owner_table) = 'HZ_PARTIES' THEN
 --check_mandatory_str_col(
 --  create_update_flag,
 --  'column_name',
 --  p_in_rec.column_name,
 --  FALSE,
 --  FALSE,
 --  x_return_status);
 --END IF;

 --Bug 2890671: created_by_module is a mandatory column
 -- created_by_module is non-updateable, lookup

 hz_utility_v2pub.validate_created_by_module(
   p_create_update_flag     => create_update_flag,
   p_created_by_module      => p_in_rec.created_by_module,
   p_old_created_by_module  => l_created_by_module,
   x_return_status          => x_return_status);

 --check_err(x_return_status);


 -------------- Changes made as per HTML Admin Project ----------------
 -- Check to make sure table name exists in fnd_objects, pk1 is valid,
 -- and pk2 is null (assumption: subsequent pks are all null if pk2 is null)

-- Check valid lookup within the correct lookup_type
-- validate_fnd_lookup(
--    'CODE_ASSIGN_OWNER_TABLE',
--    'owner_table',
--    p_in_rec.owner_table,
--    x_return_status);


 begin

 --Bug 2861251: Column name should accept null. Added or condition to accept
 --null value to column_name
    select '1' into xx_obj
    from   fnd_objects
    where  obj_name = p_in_rec.owner_table --Bug NO.:4942331 SQLID:14450613
    and    ( p_in_rec.column_name is null
               or nvl(pk1_column_name,'-999') = nvl(p_in_rec.column_name,'-999')  );

 exception
    when no_data_found then
         --Bug 2861251: Changed the message name from HZ_ADMIN_SQL_VALID_ERR
         --to HZ_API_INVALID_OBJ_NAME.
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_OBJ_NAME');
         FND_MSG_PUB.ADD;
         x_return_status := fnd_api.G_RET_STS_ERROR;
    when others then
         null;
 end;
 ---------------- End of changes for HTML Admin Project ----------------

 -- Check FK validation class_category on the hz_class_category
 check_existence_class_category(
    p_in_rec.class_category,
    x_return_status);

 --check_err(x_return_status);

 -- Check concatenated PK uniqueness (class_category, owner_table )
--HYU
 IF ( existence_couple_clacat_owntab( create_update_flag,
                                      p_in_rec.class_category,
                                      p_in_rec.owner_table)   = 'Y' ) THEN
      fnd_message.set_name('AR','HZ_API_USE_ONCE_OWNER_TABLE');
      fnd_message.set_token('CLASS_CATEGORY',p_in_rec.class_category);
      fnd_message.set_token('OWNER_TABLE'   ,p_in_rec.owner_table);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
 END IF;

 --check_err(x_return_status);
/* -- Bug 3962783
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  x_return_status := fnd_api.G_RET_STS_ERROR;
*/
END validate_class_category_use;





/*---------------------------------------------
  -- Validation for Hz_Class_Code_Assignments--
  ---------------------------------------------*/
FUNCTION date_betw_value_dates
-- Return 'Y'  if p_date_active is between the active dates of the particular Class Code
--        'N'  otherwise
( p_class_category        IN VARCHAR2,
  p_class_code            IN VARCHAR2,
  p_start_date_active     IN DATE )
RETURN VARCHAR2
IS
CURSOR cu0
IS
SELECT 'Y'
  FROM fnd_lookup_values
 WHERE lookup_type = p_class_category
   AND lookup_code = p_class_code
   AND NVL(end_date_active, p_start_date_active) >= p_start_date_active
   AND start_date_active                         <= p_start_date_active;
l_yn      VARCHAR2(1);
result    VARCHAR2(1);
BEGIN
 OPEN cu0;
   FETCH cu0 INTO l_yn;
   IF cu0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE cu0;
 RETURN result;
END date_betw_value_dates;

FUNCTION instance_already_assigned
-- Return 'Y'  If for ( 1 entity, 1 instance, 1 category , 1 content source, 1 period ),
--               we find at least 1 code different
-- Return 'N'  otherwise

-- SSM SST Integration and Extension
-- Changed all reference from content_source_type to actual_content_source.

( p_start_date_active   DATE,
  p_end_date_active     DATE,
  p_owner_table_name    VARCHAR2,
  p_owner_table_id      VARCHAR2,
  p_class_category      VARCHAR2,
  p_content_source_type VARCHAR2,
  x_class_code          IN OUT NOCOPY VARCHAR2,
  x_start_date_active   IN OUT NOCOPY DATE,
  x_end_date_active     IN OUT NOCOPY DATE)
RETURN VARCHAR2
IS
 CURSOR c0
 IS
 SELECT class_code,
        start_date_active,
        end_date_active
   FROM hz_code_assignments
  WHERE owner_table_name    =  p_owner_table_name
    AND owner_table_id      =  p_owner_table_id
    AND class_category      =  p_class_category
    AND actual_content_source =  p_content_source_type
    AND (    NVL(end_date_active, p_start_date_active) >= p_start_date_active
          OR start_date_active <= NVL(p_end_date_active, start_date_active)   )
    AND ROWNUM = 1;
 l_class_code        VARCHAR2(30);
 l_start_date_active DATE;
 l_end_date_active   DATE;
 result              VARCHAR2(1);
BEGIN
 result  := 'N';
 OPEN c0;
  FETCH c0 INTO l_class_code, l_start_date_active, l_end_date_active;
  IF c0%NOTFOUND THEN
    result := 'N';
  ELSE
    x_class_code        := l_class_code;
    x_start_date_active := l_start_date_active;
    x_end_date_active   := l_end_date_active;
    result := 'Y';
  END IF;
 CLOSE c0;
 RETURN result;
END instance_already_assigned;

FUNCTION is_leaf_node_category
-- Return 'Y'  if the Class Category entered has its ALLOW_LEAF_NODE_ONLY_FLAG to Y
--        'N' otherwise
( p_class_category IN VARCHAR2)
RETURN VARCHAR2
IS
 CURSOR c0
 IS
 SELECT allow_leaf_node_only_flag
   FROM hz_class_categories
  WHERE class_category  = p_class_category;
 l_yn   VARCHAR2(1);
 result VARCHAR2(1);
BEGIN
 OPEN c0;
       FETCH c0 INTO l_yn;
       IF l_yn = 'Y' THEN
             result := 'Y';
       ELSE
             result := 'N';
       END IF;
 CLOSE c0;
 return result;
END is_leaf_node_category;

FUNCTION is_categ_multi_assig
-- Return 'Y' if the category has its allow_multi_assign_flag to Y
--        'N' otherwise
( p_class_category VARCHAR2)
RETURN VARCHAR2
IS
CURSOR c0
IS
SELECT allow_multi_assign_flag
  FROM hz_class_categories
 WHERE class_category = p_class_category;
result VARCHAR2(1);
l_flag VARCHAR2(1);
BEGIN
 OPEN c0;
  FETCH c0 INTO l_flag;
  IF l_flag = 'Y' THEN
     result := 'Y';
  ELSE
     result := 'N';
  END IF;
 CLOSE c0;
 RETURN result;
END is_categ_multi_assig;

FUNCTION is_assig_record_id_valid
 -- Returns Y If the Record ID in the owner table associated with the category is valid
 --           and x_reason will content 'Table.column=value is valid against category.'
 -- Otherwise N and x_reason will content the message name to display
 --             HZ_API_USE_TAB_CAT if there is no usage between the category and the table
 --             HZ_API_CLA_CAT_WHERE if the value cannot be validate against the where_clause
 --             Standard Oracle error message otherwise
( p_owner_table_name IN VARCHAR2,
  p_owner_table_id   IN VARCHAR2,
  p_class_category   IN VARCHAR2,
  x_reason           IN OUT NOCOPY VARCHAR2,
  x_column_name      IN OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS
l_statement   VARCHAR2(4000);
l_text        VARCHAR2(1000);
l_result      VARCHAR2(1);
result        VARCHAR2(1);
BEGIN
 -- 1 Build the select statement
 l_result := sql_str_build( p_owner_table_name,
                            p_owner_table_id  ,
                            p_class_category  ,
                            x_column_name     ,
                            l_statement );
 IF l_result = 'N' THEN
   result := 'N';
   x_reason := l_statement;

 ELSE
 -- 2 Validation for the sql statement
  l_result := sql_valid( l_statement,
                         l_text );
  IF l_result = 'N' THEN
    result := 'N';
    IF l_text = 'NON_VALUE' THEN
      x_reason := 'HZ_API_CLA_CAT_WHERE';
      -- Msg : p_owner_table_name.l_column_name = p_owner_table_id cannot be validate
      -- against the additional_where_clause of the usage between p_owner_table_name and p_class_category.
    ELSE
      x_reason := l_text;
      -- SQL Statement formed is wrong
    END IF;
  ELSE
    result := 'Y';
    x_reason := p_owner_table_name ||'.'||l_column_name||'='||p_owner_table_id||
                ' is valid against the '||p_class_category||' category.';
  END IF;
 END IF;
 RETURN result;
END is_assig_record_id_valid;

FUNCTION sql_valid
( i_str     IN VARCHAR2,
  x_result  IN OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2
IS
 i              INTEGER;
 result         VARCHAR2(1);
 row_proc       INTEGER;
 row_fetch      INTEGER;
BEGIN
  i := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(i, i_str, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(i, 1, x_result, 1000 );
  row_proc := DBMS_SQL.EXECUTE(i);
  IF row_proc = 0 THEN
    row_fetch := DBMS_SQL.FETCH_ROWS(i);
    IF row_fetch <> 0 THEN
      DBMS_SQL.COLUMN_VALUE(i,1,x_result);
      result := 'Y';
    ELSE
      x_result :=  'NON_VALUE';
      result := 'N';
    END IF;
  END IF;
  DBMS_SQL.CLOSE_CURSOR(i);
  RETURN(result);
EXCEPTION
  WHEN OTHERS THEN
   x_result:= SUBSTRB(SQLERRM,1,100) ;
   result := 'N';
   DBMS_SQL.CLOSE_CURSOR(i);
   RETURN(result);
END sql_valid;

FUNCTION sql_str_build
 ( p_owner_table_name IN VARCHAR2,
   p_owner_table_id   IN VARCHAR2,
   p_class_category   IN VARCHAR2,
   x_column_name      IN OUT NOCOPY VARCHAR2,
   x_statement        IN OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS
 CURSOR c0
 IS
 SELECT column_name,
        additional_where_clause
   FROM hz_class_category_uses
  WHERE upper(class_category) = upper(p_class_category)
    AND upper(owner_table)    = upper(p_owner_table_name);
 l_column_name         VARCHAR2(240);
 l_add_where_clause    VARCHAR2(4000);
 result                VARCHAR2(1);
BEGIN
 OPEN c0;
  FETCH c0 INTO l_column_name, l_add_where_clause;
  IF c0%NOTFOUND THEN
   result := 'N';
   x_statement := 'HZ_API_USE_TAB_CAT';
-- Msg: HZ_API_USE_TAB_CAT = 'There is no usage for '||p_owner_table_name||' table in '||p_class_category||' category.'
  ELSE
   result := 'Y';
   x_column_name      := l_column_name;
   l_add_where_clause := RTRIM(l_add_where_clause,FND_GLOBAL.LOCAL_CHR(10));
   l_add_where_clause := RTRIM(l_add_where_clause,FND_GLOBAL.LOCAL_CHR(32));
   l_add_where_clause := RTRIM(l_add_where_clause,';');
   x_statement := 'SELECT ' || l_column_name || ' FROM ' || p_owner_table_name || FND_GLOBAL.LOCAL_CHR(10);
   IF l_add_where_clause IS NOT NULL THEN
     x_statement := x_statement || l_add_where_clause || ' AND ';
   ELSE
     x_statement := x_statement || ' WHERE ';
   END IF;
   x_statement := x_statement || l_column_name || ' = ''' || p_owner_table_id || '''';
  END IF;
 CLOSE c0;
--dbms_output.put_line(result);
 RETURN result;
END sql_str_build;


function exist_pk_code_assign
-- Return 'Y' if one code_assignment_id is found for
--              1 owner_table,
--              1 owner_table_id
--              1 category
--              1 code
--              1 source content type
--              1 start date active
--         'N' otherwise

-- SSM SST Integration and Extension
-- Changed references from content_source_type to actual_content_source
(p_owner_table_name     varchar2,
 p_owner_table_id       varchar2,
 p_class_category       varchar2,
 p_class_code           varchar2,
 p_content_source_type  varchar2,
 p_start_date_active    date,
 x_id            in out NOCOPY varchar2,
 x_end_date      in out NOCOPY date)
return varchar2
is
 cursor c0
 is
 SELECT code_assignment_id,
        end_date_active
   FROM hz_code_assignments
  WHERE owner_table_name    = p_owner_table_name
    AND owner_table_id      = p_owner_table_id
    AND class_category      = p_class_category
    AND class_code          = p_class_code
    AND actual_content_source = p_content_source_type
    AND start_date_active   = p_start_date_active;
  result     varchar2(1);
begin
 open c0;
   fetch c0 into x_id, x_end_date;
   if c0%found then
      result := 'Y';
   else
      result := 'N';
   end if;
 close c0;
 return result;
end exist_pk_code_assign;

-- SSM SST Integration and Extension
-- Changed references from content_source_type to actual_content_source

function exist_prim_assign
( create_update_flag    varchar2,
  p_class_category      varchar2,
  p_owner_table_name    varchar2,
  p_owner_table_id      varchar2,
  p_content_source_type varchar2,
  p_start_date_active   date,
  p_end_date_active     date,
  x_class_code          in out NOCOPY varchar2,
  x_start_date          in out NOCOPY date,
  x_end_date            in out NOCOPY date )
return varchar2
is
 cursor c_create
 is
 SELECT class_code,
        start_date_active,
        end_date_active
   FROM hz_code_assignments
  WHERE owner_table_name    = p_owner_table_name
    AND owner_table_id      = p_owner_table_id
    AND class_category      = p_class_category
    AND actual_content_source = p_content_source_type
    AND primary_flag        = 'Y'
    AND hz_class_validate_v2pub.is_overlap(start_date_active, end_date_active,
                                 p_start_date_active, p_end_date_active) = 'Y';
 cursor c_update
 is
 SELECT class_code,
        start_date_active,
        end_date_active
   FROM hz_code_assignments
  WHERE owner_table_name    = p_owner_table_name
    AND owner_table_id      = p_owner_table_id
    AND class_category      = p_class_category
    AND actual_content_source = p_content_source_type
    AND primary_flag        = 'Y'
    AND start_date_active  <> p_start_date_active
    AND hz_class_validate_v2pub.is_overlap(start_date_active, end_date_active,
                                 p_start_date_active, p_end_date_active) = 'Y';
 result varchar2(1);
begin
 result := 'Y';
 if create_update_flag = 'C' then
   open c_create;
     fetch c_create into x_class_code, x_start_date, x_end_date;
     if c_create%notfound then
       result := 'N';
     end if;
   close c_create;
 elsif create_update_flag = 'U' then
   open c_update;
     fetch c_update into x_class_code, x_start_date, x_end_date;
     if c_update%notfound then
       result := 'N';
     end if;
   close c_update;
 end if;
 return result;
end exist_prim_assign;

-- SSM SST Integration and Extension
-- Changed references from content_source_type to actual_content_source

function exist_same_code_assign
( create_update_flag    varchar2,
  p_class_category      varchar2,
  p_class_code          varchar2,
  p_owner_table_name    varchar2,
  p_owner_table_id      varchar2,
  p_content_source_type varchar2,
  p_start_date_active   date,
  p_end_date_active     date,
  x_class_code          in out NOCOPY varchar2,
  x_start_date          in out NOCOPY date,
  x_end_date            in out NOCOPY date )
return varchar2
is
 cursor c_create
 is
 SELECT class_code,
        start_date_active,
        end_date_active
   FROM hz_code_assignments
  WHERE owner_table_name    = p_owner_table_name
    AND owner_table_id      = p_owner_table_id
    AND class_category      = p_class_category
    AND class_code          = p_class_code
    AND actual_content_source = p_content_source_type
    AND hz_class_validate_v2pub.is_overlap(start_date_active, end_date_active,
                                 p_start_date_active, p_end_date_active) = 'Y';
 cursor c_update
 is
 SELECT class_code,
        start_date_active,
        end_date_active
   FROM hz_code_assignments
  WHERE owner_table_name    = p_owner_table_name
    AND owner_table_id      = p_owner_table_id
    AND class_category      = p_class_category
    AND class_code          = p_class_code
    AND actual_content_source = p_content_source_type
    AND start_date_active   <> p_start_date_active
    AND hz_class_validate_v2pub.is_overlap(start_date_active, end_date_active,
                                 p_start_date_active, p_end_date_active) = 'Y';
 result varchar2(1);
begin
 result := 'Y';
 if create_update_flag = 'C' then
   open c_create;
     fetch c_create into x_class_code, x_start_date, x_end_date;
     if c_create%notfound then
        result := 'N';
     end if;
   close c_create;
 elsif create_update_flag = 'U' then
   open c_update;
     fetch c_update into x_class_code, x_start_date, x_end_date;
     if c_update%notfound then
        result := 'N';
     end if;
   close c_update;
 end if;
 return result;
end exist_same_code_assign;

-- SSM SST Integration and Extension
-- Changed references from content_source_type to actual_content_source

function exist_second_assign_same_code
( create_update_flag    varchar2,
  p_class_category      varchar2,
  p_class_code          varchar2,
  p_owner_table_name    varchar2,
  p_owner_table_id      varchar2,
  p_content_source_type varchar2,
  p_start_date_active   date,
  p_end_date_active     date,
  x_class_code          in out NOCOPY varchar2,
  x_start_date          in out NOCOPY date,
  x_end_date            in out NOCOPY date )
return varchar2
is
 cursor c_create
 is
 SELECT class_code,
        start_date_active,
        end_date_active
   FROM hz_code_assignments
  WHERE owner_table_name    = p_owner_table_name
    AND owner_table_id      = p_owner_table_id
    AND class_category      = p_class_category
    AND class_code          = p_class_code
    AND actual_content_source = p_content_source_type
    AND primary_flag        = 'N'
    AND hz_class_validate_v2pub.is_overlap(start_date_active, end_date_active,
                                 p_start_date_active, p_end_date_active) = 'Y';
 cursor c_update
 is
 SELECT class_code,
        start_date_active,
        end_date_active
   FROM hz_code_assignments
  WHERE owner_table_name    = p_owner_table_name
    AND owner_table_id      = p_owner_table_id
    AND class_category      = p_class_category
    AND class_code          = p_class_code
    AND actual_content_source = p_content_source_type
    AND start_date_active   <> p_start_date_active
    AND primary_flag        = 'N'
    AND hz_class_validate_v2pub.is_overlap(start_date_active, end_date_active,
                                 p_start_date_active, p_end_date_active) = 'Y';
result varchar2(1);
begin
 result := 'Y';
 if create_update_flag = 'C' then
   open c_create;
     fetch c_create into x_class_code, x_start_date, x_end_date;
     if c_create%notfound then
       result := 'N';
     end if;
   close c_create;
 elsif create_update_flag = 'U' then
   open c_update;
     fetch c_update into x_class_code, x_start_date, x_end_date;
     if c_update%notfound then
       result := 'N';
     end if;
   close c_update;
 end if;
 return result;
end exist_second_assign_same_code;

PROCEDURE cre_upd_code_ass_com
( p_create_update_flag  varchar2,
  p_class_category      varchar2,
  p_class_code          varchar2,
  p_owner_table_name    varchar2,
  p_owner_table_id      varchar2,
  p_content_source_type varchar2,
  p_primary_flag        varchar2,
  p_start_date_active   date,
  p_end_date_active     date,
  x_return_status      IN OUT NOCOPY VARCHAR2 )
IS
 l_class_code varchar2(30);
 l_start_date date;
 l_end_date   date;

begin

  IF p_primary_flag = 'Y' THEN

    -- For (owner_table, table_id, source_content_type, category)
    -- just 1 tplet can have Primay_flag = 'Y' for 1 period
    if exist_prim_assign
         ( p_create_update_flag,
           p_class_category  ,
           p_owner_table_name,
           p_owner_table_id  ,
           p_content_source_type,
           p_start_date_active,
           p_end_date_active  ,
           l_class_code  ,
           l_start_date  ,
           l_end_date    ) = 'Y' then

         fnd_message.set_name('AR'         , 'HZ_API_DUP_COL_PRIM');
         fnd_message.set_token('CLASS_CODE', l_class_code);
         fnd_message.set_token('START_DATE_ACTIVE', l_start_date);
         fnd_message.set_token('END_DATE_ACTIVE'  , l_end_date);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;

    -- For (owner_table, table_id, source_content_type, category, code)
    -- the assignment cannot be primary and secondary in the same time
    elsif exist_second_assign_same_code
         ( p_create_update_flag,
           p_class_category ,
           p_class_code     ,
           p_owner_table_name,
           p_owner_table_id  ,
           p_content_source_type,
           p_start_date_active,
           p_end_date_active ,
           l_class_code ,
           l_start_date ,
           l_end_date   ) = 'Y'
    then
         fnd_message.set_name('AR', 'HZ_API_DUP_COD_PRIM_SECOND');
         fnd_message.set_token('CLASS_CODE', l_class_code);
         fnd_message.set_token('START_DATE_ACTIVE', l_start_date);
         fnd_message.set_token('END_DATE_ACTIVE'  , l_end_date);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
    end if;

  ELSIF p_primary_flag = 'N' THEN

    if exist_same_code_assign
         ( p_create_update_flag,
           p_class_category,
           p_class_code    ,
           p_owner_table_name,
           p_owner_table_id  ,
           p_content_source_type,
           p_start_date_active,
           p_end_date_active  ,
           l_class_code ,
           l_start_date ,
           l_end_date   ) = 'Y'
    then

         fnd_message.set_name('AR', 'HZ_API_DUP_COD_SECOND');
         fnd_message.set_token('CLASS_CODE', l_class_code);
         fnd_message.set_token('START_DATE_ACTIVE', l_start_date);
         fnd_message.set_token('END_DATE_ACTIVE'  , l_end_date);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
    end if;

   END IF;

END cre_upd_code_ass_com;

-- SSM SST Integration and Extension
-- Changed references from content_source_type to actual_content_source

procedure validate_code_assignment(
        p_in_rec                                IN      HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE,
        create_update_flag      IN      VARCHAR2,
                x_return_status                 IN OUT NOCOPY   VARCHAR2
) IS
        --l_date_active DATE;
        l_end_date  DATE := NULL;
        l_count NUMBER := 0;
        l_id NUMBER;
        bool VARCHAR2(1);
        allow_leaf_error VARCHAR2(1);

-- bug 3077574 : Added two local variables used in validation sql statement

        l_count_multi NUMBER := 0;
        l_allow_multi_assign_flag VARCHAR2(1);

-- bug 3077574 : Added a variable to store concatenated values for owner_table_key 1 to 5

        l_owner_table_keys varchar2(2000);



  l_class_category     hz_code_assignments.class_category%TYPE;
  l_class_code         hz_code_assignments.class_code%TYPE;
  l_status             hz_code_assignments.status%TYPE;
  l_start_date_active  hz_code_assignments.start_date_active%TYPE;
  l_end_date_active    hz_code_assignments.end_date_active%TYPE;
  l_owner_table_name   hz_code_assignments.owner_table_name%TYPE;
  l_owner_table_id     hz_code_assignments.owner_table_id%TYPE;
  l_owner_table_key_1  hz_code_assignments.owner_table_key_1%TYPE;
  l_owner_table_key_2  hz_code_assignments.owner_table_key_2%TYPE;
  l_owner_table_key_3  hz_code_assignments.owner_table_key_3%TYPE;
  l_owner_table_key_4  hz_code_assignments.owner_table_key_4%TYPE;
  l_owner_table_key_5  hz_code_assignments.owner_table_key_5%TYPE;
  l_content_source_type    hz_code_assignments.content_source_type%TYPE;
  l_actual_content_source  hz_code_assignments.actual_content_source%TYPE;
  l_created_by_module      hz_code_assignments.created_by_module%TYPE;

        l_primary_flag hz_code_assignments.primary_flag%TYPE;
        l_rec hz_code_assignments%ROWTYPE;

-- Bug 3293069 - Added local variable to store end_date_active

l_date DATE;


        CURSOR c_code_assign(
                p_owner_table_name VARCHAR2,
                p_owner_table_id NUMBER,
                p_class_category VARCHAR2,
                --p_class_code VARCHAR2,
                p_content_source_type VARCHAR2
                )
        IS
                SELECT * FROM hz_code_assignments
                WHERE owner_table_name = p_owner_table_name AND
                        owner_table_id = p_owner_table_id AND
                        class_category = p_class_category AND
                        status = 'A' AND
                        --class_code = p_class_code AND
                        actual_content_source = p_content_source_type;

/* Bug 3293069 - Commented the extra where clause so that the cursor picks up
 * past records also
 *
AND
                        (
                                (end_date_active IS NULL) OR
                                ( (end_date_active > SYSDATE)
                                        AND (end_date_active >= start_date_active)
                                )
                        );

*/
BEGIN

    IF create_update_flag = 'U'
    THEN

      SELECT class_category,
             class_code,
             status,
             start_date_active,
             end_date_active,
             owner_table_name,
             owner_table_id,
             owner_table_key_1,
             owner_table_key_2,
             owner_table_key_3,
             owner_table_key_4,
             owner_table_key_5,
             content_source_type,
             actual_content_source,
             created_by_module
      INTO   l_class_category,
             l_class_code,
             l_status,
             l_start_date_active,
             l_end_date_active,
             l_owner_table_name,
             l_owner_table_id,
             l_owner_table_key_1,
             l_owner_table_key_2,
             l_owner_table_key_3,
             l_owner_table_key_4,
             l_owner_table_key_5,
             l_content_source_type,
             l_actual_content_source,
             l_created_by_module
      FROM   hz_code_assignments
      WHERE  code_assignment_id = p_in_rec.code_assignment_id
      AND    rownum=1;
    END IF;

--Check for mandatory columns
        -- SHOULD ALLOW NULL?
        check_mandatory_num_col(
                create_update_flag,
                'code_assignment_id',
                p_in_rec.code_assignment_id,
                TRUE,
                FALSE,  -- update needs this to select row
                x_return_status);

        check_mandatory_str_col(
                create_update_flag,
                'owner_table_name',
                p_in_rec.owner_table_name,
                FALSE,
                TRUE,
                x_return_status);

      --Commenting out as one and only one of the following is mandatory:
      --owner_table_id or owner_table_key_1
      --check_mandatory_num_col(
      --        create_update_flag,
      --        'owner_table_id',
      --        p_in_rec.owner_table_id,
      --        FALSE,
      --        TRUE,
      --        x_return_status);

        check_mandatory_str_col(
                create_update_flag,
                'class_category',
                p_in_rec.class_category,
                FALSE,
                TRUE,
                x_return_status);

        check_mandatory_str_col(
                create_update_flag,
                'class_code',
                p_in_rec.class_code,
                FALSE,
                TRUE,
                x_return_status);

        check_mandatory_str_col(
                create_update_flag,
                'primary_flag',
                p_in_rec.primary_flag,
                FALSE,
                TRUE,
                x_return_status);

/*      check_mandatory_str_col(
                create_update_flag,
                'content_source_type',
                p_in_rec.content_source_type,
                FALSE,
                TRUE,
                x_return_status);*/

        --Bug 2890671: created_by_module is manadatory
        -- created_by_module is non-updateable, lookup

        hz_utility_v2pub.validate_created_by_module(
          p_create_update_flag     => create_update_flag,
          p_created_by_module      => p_in_rec.created_by_module,
          p_old_created_by_module  => l_created_by_module,
          x_return_status          => x_return_status);

-- Bug 3070461. Make start_date_active as non mandatory column.
-- comment the code that checks mandatory column.

/***
        check_mandatory_date_col(
                create_update_flag,
                'start_date_active',
                p_in_rec.start_date_active,
                FALSE,
                TRUE,
                x_return_status);

***/

        --check_err( x_return_status );

  --check for non-updatable columns
  --Bug 2825328: columns like owner_table_name, owner_table_id, and
  --owner_table_key_1 to 5 are non-updatable.
  -- owner_table_name is non-updateable field
    IF create_update_flag = 'U' AND
       p_in_rec.owner_table_name IS NOT NULL
    THEN
      validate_nonupdateable (
        p_column                 => 'owner_table_name',
        p_column_value           => p_in_rec.owner_table_name,
        p_old_column_value       => l_owner_table_name,
        x_return_status          => x_return_status);

    END IF;
  -- owner_table_id is non-updateable field
    IF create_update_flag = 'U' AND
       p_in_rec.owner_table_id IS NOT NULL
    THEN
      validate_nonupdateable (
        p_column                 => 'owner_table_id',
        p_column_value           => p_in_rec.owner_table_id,
        p_old_column_value       => l_owner_table_id,
        x_return_status          => x_return_status);

    END IF;
  -- owner_table_key_1 is non-updateable field
    IF create_update_flag = 'U' AND
       p_in_rec.owner_table_key_1 IS NOT NULL
    THEN
      validate_nonupdateable (
        p_column                 => 'owner_table_key_1',
        p_column_value           => p_in_rec.owner_table_key_1,
        p_old_column_value       => l_owner_table_key_1,
        x_return_status          => x_return_status);

    END IF;
  -- owner_table_name is non-updateable field
    IF create_update_flag = 'U' AND
       p_in_rec.owner_table_key_2 IS NOT NULL
    THEN
      validate_nonupdateable (
        p_column                 => 'owner_table_key_2',
        p_column_value           => p_in_rec.owner_table_key_2,
        p_old_column_value       => l_owner_table_key_2,
        x_return_status          => x_return_status);

    END IF;
  -- owner_table_name is non-updateable field
    IF create_update_flag = 'U' AND
       p_in_rec.owner_table_key_3 IS NOT NULL
    THEN
      validate_nonupdateable (
        p_column                 => 'owner_table_key_3',
        p_column_value           => p_in_rec.owner_table_key_3,
        p_old_column_value       => l_owner_table_key_3,
        x_return_status          => x_return_status);

    END IF;
  -- owner_table_name is non-updateable field
    IF create_update_flag = 'U' AND
       p_in_rec.owner_table_key_4 IS NOT NULL
    THEN
      validate_nonupdateable (
        p_column                 => 'owner_table_key_4',
        p_column_value           => p_in_rec.owner_table_key_4,
        p_old_column_value       => l_owner_table_key_4,
        x_return_status          => x_return_status);

    END IF;
  -- owner_table_name is non-updateable field
    IF create_update_flag = 'U' AND
       p_in_rec.owner_table_key_5 IS NOT NULL
    THEN
      validate_nonupdateable (
        p_column                 => 'owner_table_key_5',
        p_column_value           => p_in_rec.owner_table_key_5,
        p_old_column_value       => l_owner_table_key_5,
        x_return_status          => x_return_status);

    END IF;



-- Removing this validation as per discussions with Dylan
-- Also, code assignment UI should look against HZ_CLASS_CATEGORY_USES
-- and not go against this lookup.

--Check for lookup type validations.
--      validate_fnd_lookup(
--              'CODE_ASSIGN_OWNER_TABLE',
--              'owner_table_name',
--              p_in_rec.OWNER_TABLE_NAME,
--              x_return_status);
--- End of commenting ----------------------------

        validate_fnd_lookup(
                'YES/NO',
                'primary_flag',
                p_in_rec.primary_flag,
                x_return_status);

/* SSM SST Integration and Extension
 * New Column actual_content_source is added.
 * Validations for both content_source_type and actual_content_source will be handled
 *  in HZ_MIXNM_UTILITY.ValidateContentSource

        validate_fnd_lookup(
                'CONTENT_SOURCE_TYPE',
                'content_source_type',
                p_in_rec.CONTENT_SOURCE_TYPE,
                x_return_status);
*/

 ------------------------------------------------------------------
 -- Validation for content_source_type and actual_content_source --
 -- (SSM SST Integration and Extension)                          --
 ------------------------------------------------------------------
 HZ_MIXNM_UTILITY.ValidateContentSource(
     p_api_version                     =>  'V2',
     p_create_update_flag              =>  create_update_flag,
     p_check_update_privilege          =>  'N',
     p_content_source_type             =>  p_in_rec.content_source_type,
     p_old_content_source_type         =>  l_content_source_type,
     p_actual_content_source           =>  p_in_rec.actual_content_source,
     p_old_actual_content_source       =>  l_actual_content_source,
     p_entity_name                     =>  'HZ_CODE_ASSIGNMENTS',
     x_return_status                   =>  x_return_status);

--IF l_actual_content_source <> p_in_rec.actual_content_source
--  Bug 4226199 : call for update and for all ACS otehr than UE
IF create_update_flag = 'U' and l_actual_content_source <> 'USER_ENTERED'
THEN
    DECLARE
        l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        validate_nonupdateable(
            p_column                   =>  'CLASS_CATEGORY',
            p_column_value             =>  p_in_rec.class_category,
            p_old_column_value         =>  l_class_category,
            x_return_status            =>  l_return_status,
            p_raise_error              =>  'N');

        validate_nonupdateable(
            p_column                   =>  'CLASS_CODE',
            p_column_value             =>  p_in_rec.class_code,
            p_old_column_value         =>  l_class_code,
            x_return_status            =>  l_return_status,
            p_raise_error              =>  'N');
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            HZ_MIXNM_UTILITY.CheckUserUpdatePrivilege(
                p_actual_content_source      =>  l_actual_content_source,
                p_new_actual_content_source  =>  p_in_rec.actual_content_source,
                p_entity_name                =>  'HZ_CODE_ASSIGNMENTS',
                x_return_status              =>  x_return_status);
-- Bug 4693719 : set global variable to Y
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := 'Y';
        END IF;
    END;
END IF;
        --  Status Validation
        hz_utility_v2pub.validate_lookup('status','AR_LOOKUPS','REGISTRY_STATUS',p_in_rec.status,x_return_status);

        --check_err( x_return_status );

--Check FK validations.
--Bug 2825247: The following condition should be checked only when create_update_flag is 'C'

/* Bug 3941471. Commented this code since the existence of class category is checked
                checking for ALLOW_MULTI_ASSIGN_FLAG */

/*
  IF create_update_flag = 'C'
  THEN
    SELECT COUNT(1) INTO l_count
    FROM hz_class_categories
    WHERE class_category = p_in_rec.class_category;

    IF l_count = 0 THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
      FND_MESSAGE.SET_TOKEN('FK', 'class_category');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'class_category');
      FND_MESSAGE.SET_TOKEN('TABLE', 'hz_class_categories');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

      RAISE G_EX_INVALID_PARAM;
    END IF;
  END IF;
*/

-- Bug 3077574 : Added validation for ALLOW_MULTI_ASSIGN_FLAG = 'N'
-- Start of validation

        Begin

-- Check if the flag is set to 'N'

        select ALLOW_MULTI_ASSIGN_FLAG into l_allow_multi_assign_flag
        from hz_class_categories where
        -- Bug 3941471
        class_category = nvl(p_in_rec.class_category,l_class_category);

        Exception
                When no_data_found then
                fnd_message.set_name('AR','HZ_API_INVALID_FK');
                fnd_message.set_token('FK','class_category');
                fnd_message.set_token('COLUMN','class_category');
                fnd_message.set_token('TABLE','hz_class_categories');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
        end;

-- If the flag is set to 'N", do the validation

        if(l_allow_multi_assign_flag = 'N') then

-- condition to handle null for start and end date while creating

                if(create_update_flag = 'C') then
                        l_end_date_active := nvl(p_in_rec.end_date_active,to_date('4712/12/31','YYYY/MM/DD'));
                        l_start_date_active := nvl(p_in_rec.start_date_active,sysdate);
                end if;

                l_owner_table_keys :=   nvl(p_in_rec.owner_table_key_1, l_owner_table_key_1) ||
                                        nvl(p_in_rec.owner_table_key_2, l_owner_table_key_2) ||
                                        nvl(p_in_rec.owner_table_key_3, l_owner_table_key_3) ||
                                        nvl(p_in_rec.owner_table_key_4, l_owner_table_key_4) ||
                                        nvl(p_in_rec.owner_table_key_5, l_owner_table_key_5);
-- Bug 3455217 : Added to use in sql below.
                l_owner_table_id := nvl(p_in_rec.owner_table_id, l_owner_table_id);
-- Bug 3455217 : Chagne the OR condition between owner_table_id and combination
--               of owner_table_key_1 to owner_table_key_5 to union so that it
--               uses index on these columns. Also add NVL conditions to
--               preserve the functionality that only one of these two can be
--               present for any code assignment.
if(l_owner_table_id is not null) then
                select count(1) into l_count_multi
                from hz_code_assignments
                where class_category = p_in_rec.class_category
                AND status='A'
                AND code_Assignment_id <> nvl(p_in_rec.code_assignment_id, fnd_api.g_miss_num)
                AND owner_table_name = nvl(p_in_rec.owner_table_name, l_owner_table_name)
/*
                AND ( owner_table_id = nvl(p_in_rec.owner_table_id, l_owner_table_id)
                        OR
                          ( owner_table_key_1 || owner_table_key_2 ||
                            owner_table_key_3 || owner_table_key_4 ||
                            owner_table_key_5 = l_owner_table_keys
                          )
                    )
*/
                AND ( owner_table_id = l_owner_table_id
                       AND
                          ( owner_table_key_1 || owner_table_key_2 ||
                            owner_table_key_3 || owner_table_key_4 ||
                            owner_table_key_5 is null
                          )
                    )
-- Bug 3614582 : Removed TRUNC from the date comparison.
                AND is_overlap(nvl(p_in_rec.start_date_active, l_start_Date_active),
                                nvl(p_in_rec.end_date_active,l_end_date_Active),
                                START_DATE_ACTIVE, END_DATE_ACTIVE) = 'Y'
/*
                AND ((START_DATE_ACTIVE) between (nvl(p_in_rec.start_date_active, l_start_Date_active)) and
                                                        (decode(p_in_rec.end_date_active,
                                                        fnd_api.g_miss_date,to_date('4712/12/31','YYYY/MM/DD'),
                                                        NULL,l_end_date_active,p_in_rec.end_date_active)) OR
                     (END_DATE_ACTIVE) between (nvl(p_in_rec.start_date_active,l_start_Date_active)) and
                                                        (decode(p_in_rec.end_date_active,
                                                        fnd_api.g_miss_date,to_date('4712/12/31','YYYY/MM/DD'),
                                                        NULL,l_end_date_active,p_in_rec.end_date_active)) OR
                     (nvl(p_in_rec.start_date_active,l_start_Date_active)) between (START_DATE_ACTIVE) and
                                                        (nvl(END_DATE_ACTIVE, to_date('4712/12/31','YYYY/MM/DD'))) OR
                     (nvl(p_in_rec.end_date_active,l_end_date_Active)) between (START_DATE_ACTIVE) and
                                                        (nvl(END_DATE_ACTIVE, to_date('4712/12/31','YYYY/MM/DD')))
                )*/;
else
select count(1) into l_count_multi
                from hz_code_assignments
                where class_category = p_in_rec.class_category
                AND status='A'
                AND code_Assignment_id <> nvl(p_in_rec.code_assignment_id, fnd_api.g_miss_num)
                AND owner_table_name = nvl(p_in_rec.owner_table_name, l_owner_table_name)
                AND ( owner_table_id  is null
                       AND
                          ( nvl(owner_table_key_1 || owner_table_key_2 ||
                            owner_table_key_3 || owner_table_key_4 ||
                            owner_table_key_5, fnd_api.g_miss_char) = nvl(l_owner_table_keys, fnd_api.g_miss_char)
                          )
                    )
-- Bug 3614582 : Removed TRUNC from the date comparison.
                AND is_overlap(nvl(p_in_rec.start_date_active, l_start_Date_active),
                                nvl(p_in_rec.end_date_active,l_end_date_Active),
                                START_DATE_ACTIVE, END_DATE_ACTIVE) = 'Y'
/*
                AND ((START_DATE_ACTIVE) between (nvl(p_in_rec.start_date_active, l_start_Date_active)) and
                                                        (decode(p_in_rec.end_date_active,
                                                        fnd_api.g_miss_date,to_date('4712/12/31','YYYY/MM/DD'),
                                                        NULL,l_end_date_active,p_in_rec.end_date_active))
OR
                     (END_DATE_ACTIVE) between (nvl(p_in_rec.start_date_active,l_start_Date_active)) and
                                                        (decode(p_in_rec.end_date_active,
                                                        fnd_api.g_miss_date,to_date('4712/12/31','YYYY/MM/DD'),
                                                        NULL,l_end_date_active,p_in_rec.end_date_active))
OR
                     (nvl(p_in_rec.start_date_active,l_start_Date_active)) between (START_DATE_ACTIVE) and
                                                        (nvl(END_DATE_ACTIVE, to_date('4712/12/31','YYYY/MM/DD'))) OR
                     (nvl(p_in_rec.end_date_active,l_end_date_Active)) between (START_DATE_ACTIVE) and
                                                        (nvl(END_DATE_ACTIVE, to_date('4712/12/31','YYYY/MM/DD')))
                )*/
;
end if;

                if l_count_multi > 0 then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_ALLOW_MUL_ASSIGN_FG');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
			--Bug 3962783
                        --RAISE G_EX_INVALID_PARAM;
                end if;
        end if;

-- end of validation


  --The following FK Validation check should be commented out, as this can be validated
  --from is_valid_category
  --IF UPPER(p_in_rec.owner_table_name) = 'HZ_PARTIES'
  --THEN
  --
  --  SELECT COUNT(1) INTO l_count
  --  FROM hz_parties
  --  WHERE party_id = p_in_rec.owner_table_id;
  --
  --  IF l_count = 0 THEN
  --    FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
  --    FND_MESSAGE.SET_TOKEN('FK', p_in_rec.owner_table_name);
  --    FND_MESSAGE.SET_TOKEN('COLUMN',  p_in_rec.owner_table_id);
  --    FND_MESSAGE.SET_TOKEN('TABLE', 'hz_parties');
  --    FND_MSG_PUB.ADD;
  --    x_return_status := FND_API.G_RET_STS_ERROR;
  --
  --    RAISE G_EX_INVALID_PARAM;
  --  END IF;
  --END IF;
        --Bug 2830772: When the content_source_type not 'USER_ENTERED' and
        --lookup type is 'NACE', call the overloaded validate_fnd_lookup.
        IF( p_in_rec.actual_content_source <> 'USER_ENTERED'
            AND
            nvl(p_in_rec.class_category, l_class_category) = 'NACE'
          )
        THEN
          validate_fnd_lookup(
                      nvl(p_in_rec.class_category, l_class_category),
                      'class_code',
                      p_in_rec.class_code,
                      p_in_rec.actual_content_source,
                      x_return_status);
        ELSE
          validate_fnd_lookup(
                      nvl(p_in_rec.class_category, l_class_category),
                      'class_code',
                      p_in_rec.class_code,
                      x_return_status);
        END IF;

        --check_err( x_return_status );

        IF create_update_flag = 'C' THEN
-- Check start/end active dates
                check_start_end_active_dates(
                        p_in_rec.start_date_active,
                        p_in_rec.end_date_active,
                        x_return_status);
                --check_err( x_return_status );
        END IF;

-- Assign Leafnode only Flag
-- Bug 2689655. commented the previos code and added Validation for class_code based on allow_leaf_node_only_flag

/**
           BEGIN
                    select decode(sign(count(*)-1),0,null,'Y')
                          into allow_leaf_error
                          from hz_class_code_relations c_rel
                             , hz_class_categories c_cate
                         where c_cate.class_category=c_rel.class_category and
                        allow_leaf_node_only_flag = 'Y' and
                        --owner_table_name = nvl(p_in_rec.owner_table_name, l_owner_table_name) AND
                        --owner_table_id = nvl(p_in_rec.owner_table_id, l_owner_table_id) AND
                        c_cate.class_category = nvl(p_in_rec.class_category, l_class_category) AND
                        class_code = nvl(p_in_rec.class_code, l_class_code) AND
                        --primary_flag = p_in_rec.primary_flag AND
                        start_date_active = nvl(p_in_rec.start_date_active, l_start_date_active) AND
                        (
                                (p_in_rec.end_date_active IS NULL) OR
                                ( (nvl(p_in_rec.end_date_active, l_end_date_active) > SYSDATE)
                                        AND (nvl(p_in_rec.end_date_active, l_end_date_active) >= start_date_active)
                                )
                        );
                    if allow_leaf_error = 'Y' THEN
                        -- update would produce duplicate records
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'code_assignment_id');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE G_EX_INVALID_PARAM;
                END IF;
          EXCEPTION
                WHEN TOO_MANY_ROWS THEN
                        NULL;  -- should not happen here
                WHEN NO_DATA_FOUND THEN
                        l_count := 0;
          END;

**/

-- START validation
        Begin
        select 'Y' into allow_leaf_error
        from hz_class_code_relations c_rel, hz_class_categories c_cate
        where   c_cate.class_category=c_rel.class_category and
                allow_leaf_node_only_flag = 'Y' and
                c_cate.class_category = nvl(p_in_rec.class_category, l_class_category) AND
                class_code = nvl(p_in_rec.class_code, l_class_code) AND
                ( start_date_active between nvl(p_in_rec.start_date_active, l_start_date_active) and nvl (p_in_rec.end_date_active, l_end_date_active)
                  OR
                  nvl(p_in_rec.start_date_active, l_start_date_active) between start_date_active and nvl(end_date_active, to_date('4712/12/31','YYYY/MM/DD'))
                ) and
                rownum = 1;
        if allow_leaf_error = 'Y' THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_LEAFNODE_FLAG');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
		--Bug 3962783
                --RAISE G_EX_INVALID_PARAM;
        end if;
        exception
                when no_data_found then
                        l_count := 0;
                when others then
                        NULL;
        end;

-- End validation


        -- Check uniqueness and updateable

        BEGIN

                SELECT code_assignment_id, end_date_active
                INTO l_id, l_end_date
                FROM hz_code_assignments
                WHERE owner_table_name = nvl(p_in_rec.owner_table_name, l_owner_table_name) AND
                        owner_table_id = nvl(p_in_rec.owner_table_id, l_owner_table_id) AND
                        class_category = nvl(p_in_rec.class_category, l_class_category) AND
                        class_code = nvl(p_in_rec.class_code, l_class_code) AND
                        --primary_flag = p_in_rec.primary_flag AND
                        actual_content_source = nvl(p_in_rec.actual_content_source, l_actual_content_source) AND
                        status ='A' AND
-- Bug 3614582 : Removed TRUNC from the date comparison.
                        (start_date_active) = (nvl(p_in_rec.start_date_active, l_start_date_active)) AND--Bug no 3053541
                        (
                                (
                                (p_in_rec.end_date_active) IS NULL--Bug no 3053541
                                )
                        OR
                                (
                                (nvl(p_in_rec.end_date_active, l_end_date_active)) --Bug no 3053541
                                > SYSDATE
                                AND
                                (nvl(p_in_rec.end_date_active, l_end_date_active))--Bug no 3053541
                                >= start_date_active
                                )
                        )
                        AND --Bug no 3053541
                        (
                        code_assignment_id <> p_in_rec.code_assignment_id
                         OR
                         create_update_flag='C'
                        );

                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'owner_table_name-owner_table_id-class_category-class_code-actual_content_source-start_date_active');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
			--Bug 3962783
                        --RAISE G_EX_INVALID_PARAM;

--Commented the code below in the fix for Bug number 3053541
/*
                l_count := 1;
                --Bug 2977428 : Changed the condition for unique combination columns
                --to check only when create_update_flag = 'C'.
                IF create_update_flag = 'C'
                THEN
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'owner_table_name-owner_table_id-class_category-class_code-content_source_type-start_date_active');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE G_EX_INVALID_PARAM;
                ELSIF l_id <>p_in_rec.code_assignment_id
                THEN
                        -- update would produce duplicate records
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'code_assignment_id');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE G_EX_INVALID_PARAM;
                END IF;*/
--End of code commented in the fix for Bug number 3053541.

        EXCEPTION
                WHEN TOO_MANY_ROWS THEN
                        NULL;  -- should not happen here
                WHEN NO_DATA_FOUND THEN
                        l_count := 0;
        END;

        IF create_update_flag = 'U' THEN
                -- updating "end_date_active" allowed if:
                -- (1) it terminates the relation, OR
                -- (2) the current end_date_active is NULL
                /*
                -- (2) it does NOT revive a terminated relation AND
                --              the resulted (start_date_active, end_date_active)
                --              does not overlap with thoese of existing relations
                */

                SELECT primary_flag
                INTO   l_primary_flag
                FROM   hz_code_assignments
                WHERE  code_assignment_id = p_in_rec.code_assignment_id;

                --
                ---  Bugfix:2154581
                --
                -- Check start/end active dates
                check_start_end_active_dates(
                        nvl(p_in_rec.start_date_active, l_start_date_active),
                        nvl(p_in_rec.end_date_active, l_end_date_active),
                        x_return_status);
                --check_err( x_return_status );
                --
                IF p_in_rec.end_date_active <> FND_API.G_MISS_DATE AND
-- Bug 3293069 - Added bracket around the "AND" condition
                        (
                        (nvl(p_in_rec.end_date_active, l_end_date_active) <=
                        nvl(p_in_rec.start_date_active, l_start_date_active) ) OR
                        (nvl(p_in_rec.end_date_active, l_end_date_active) <= SYSDATE)
                        )
                THEN
                        -- terminating, allowed
                        NULL;
                ELSE
                        -- end_date_active is either NULL or > SYSDATE
                /* Bug 2450637 :  Adding the validation for
                                     overlap */

/*                 IF ( l_count>0 ) AND (l_end_date IS NOT NULL)
                                    AND (l_end_date <> p_in_rec.end_date_active)
                        THEN
                                -- cannot update
                                FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
                                FND_MESSAGE.SET_TOKEN('COLUMN', 'end_date_active');
                                FND_MSG_PUB.ADD;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                RAISE G_EX_INVALID_PARAM;
                   END IF;
*/
-- While debugging for Bug No 3053541,found that if the API is called to
-- update a record and either or all of the below values(owner_table_name,
-- owner_table_id,class_category,sontent_source_type)are not passed to the
-- API ,then the CURSOR is called with NULL as some parameters and as such
-- the cursor does not return any value.
-- Commented the cursor call and replaced it with the code below it.
/*                  FOR v_rec IN c_code_assign(
                        p_in_rec.owner_table_name,
                        p_in_rec.owner_table_id,
                        p_in_rec.class_category,
                        p_in_rec.content_source_type
                        )
*/
                    FOR v_rec IN c_code_assign(
                        nvl(p_in_rec.owner_table_name,l_owner_table_name),
                        nvl(p_in_rec.owner_table_id,l_owner_table_id),
                        nvl(p_in_rec.class_category,l_class_category),
                        nvl(p_in_rec.actual_content_source,l_actual_content_source)
                        )
                    LOOP
                        IF (v_rec.PRIMARY_FLAG = 'Y') AND
                        (p_in_rec.primary_flag = 'Y' OR
                          (l_primary_flag = 'Y' and p_in_rec.primary_flag is null)) AND
                        (v_rec.code_assignment_id <> p_in_rec.code_assignment_id) AND
                         is_overlap(nvl(p_in_rec.start_date_active, l_start_date_active),
                                        nvl(p_in_rec.end_date_active, l_end_date_active),
                                        v_rec.start_date_active,
                                        v_rec.end_date_active)='Y'
                        THEN
                                -- AN overlapping ONE EXISTS

                                -- Bug 3021505.
                                --FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
                                --FND_MESSAGE.SET_TOKEN('COLUMN', 'end_date_active');
                                FND_MESSAGE.SET_NAME('AR','HZ_API_PRI_CODE_OVERLAP');

                                FND_MSG_PUB.ADD;
                                x_return_status := FND_API.G_RET_STS_ERROR;
				--Bug 3962783
                                --RAISE G_EX_INVALID_PARAM;
                                        EXIT;
                        END IF;

-- Bug 3293069 : Check if the end_date_active is fnd_api.g_miss_date.
--               If yes, use to_date('4712/12/31','YYYY/MM/DD') for checking overlap

if(p_in_rec.end_date_active = fnd_api.g_miss_date) then
        l_date := to_date('4712/12/31','YYYY/MM/DD');
else
        l_date := p_in_rec.end_date_active;
end if;

                        IF (v_rec.class_code=p_in_rec.class_code) AND --Bug no 3053541
                           (v_rec.code_assignment_id <> p_in_rec.code_assignment_id) AND

-- Bug 3293069 : Use l_date instead of p_in_rec.end_date_active for checking overlap

                           is_overlap(nvl(p_in_rec.start_date_active, l_start_date_active),
                                        nvl(l_date, l_end_date_active),
                                        v_rec.start_date_active,
                                        v_rec.end_date_active)='Y'
                        THEN
                                FND_MESSAGE.SET_NAME('AR', 'HZ_IMP_CODE_ASSG_DATE_OVERLAP');
                                FND_MSG_PUB.ADD;
                                x_return_status := FND_API.G_RET_STS_ERROR;
				--Bug 3962783
                                --RAISE G_EX_INVALID_PARAM;
                        END IF;--Bug No 3053541.
                     END LOOP;

/*
*                       FOR v_rec IN c_code_assign(
*                               p_in_rec.owner_table_name,
*                               p_in_rec.owner_table_id,
*                               p_in_rec.class_category,
*                               p_in_rec.class_code,
*                               p_in_rec.content_source_type
*                               )
*                       LOOP
*                               IF (v_rec.start_date_active = p_in_rec.start_date_active )
*                               THEN
*                                       -- reviving?
*                                       IF (v_rec.end_date_active <= v_rec.start_date_active ) OR
*                                               (v_rec.end_date_active <= l_now )
*                                       THEN
*                                               FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
*                                               FND_MESSAGE.SET_TOKEN('COLUMN', 'end_date_active');
*                                               FND_MSG_PUB.ADD;
*                                               x_return_status := FND_API.G_RET_STS_ERROR;
*                                               RAISE G_EX_INVALID_PARAM;
*                                       END IF;
*                               ELSIF is_between(v_rec.start_date_active, p_in_rec.start_date_active, p_in_rec.end_date_active ) OR
*                                       is_between(p_in_rec.start_date_active, v_rec.start_date_active, v_rec.end_date_active )
*                               THEN
*                                       -- overlaps with this existing relation
*                                       FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
*                                       FND_MESSAGE.SET_TOKEN('COLUMN', 'end_date_active');
*                                       FND_MSG_PUB.ADD;
*                                       x_return_status := FND_API.G_RET_STS_ERROR;
*                                       RAISE G_EX_INVALID_PARAM;
*                               END IF;
*                       END LOOP;
*                       */
                END IF;
        ELSE
                -- create
                IF (p_in_rec.primary_flag = 'Y')
                THEN
                -- create primary code assignment
                        FOR v_rec IN c_code_assign(
                                p_in_rec.owner_table_name,
                                p_in_rec.owner_table_id,
                                p_in_rec.class_category,
                                p_in_rec.actual_content_source
                                )
                        LOOP
                                IF (v_rec.PRIMARY_FLAG = 'Y') AND
                                        (v_rec.class_code = p_in_rec.class_code) AND
                                         is_overlap(p_in_rec.start_date_active,
                                                        p_in_rec.end_date_active,
                                                        v_rec.start_date_active,
                                                        v_rec.end_date_active)='Y'
                                THEN
                                        -- AN overlapping ONE EXISTS

                                        /* Bug 3289620.
                                        | FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
                                        | FND_MESSAGE.SET_TOKEN('COLUMN', 'class_category-class_code');
                                        */
                                        FND_MESSAGE.SET_NAME('AR', 'HZ_IMP_CODE_ASSG_DATE_OVERLAP');

                                        FND_MSG_PUB.ADD;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
					--Bug 3962783
                                        --RAISE G_EX_INVALID_PARAM;
                                        EXIT;
                                END IF;

-- Bug 3293069 - Added end_date_active condition so that history records are not
--               updated
                                IF (v_rec.PRIMARY_FLAG = 'Y' AND
                                        ((v_rec.end_date_active is NULL) OR
                                         (v_rec.end_date_active >= sysdate)) AND
                                        v_rec.class_code <> p_in_rec.class_code)
                                THEN
                                        -- terminate original primary assignment
                                        UPDATE HZ_CODE_ASSIGNMENTS SET
                                                end_date_active = SYSDATE
                                        WHERE code_assignment_id = v_rec.code_assignment_id;
                                END IF;

-- Bug 3293069 - Added end_date_active condition so that history records are not
--               updated
                                IF (v_rec.PRIMARY_FLAG = 'N' AND
                                        ((v_rec.end_date_active is NULL) OR
                                         (v_rec.end_date_active >= sysdate)) AND
                                        v_rec.class_code = p_in_rec.class_code)
                                THEN
                                        -- terminate original non-primary assignment
                                        UPDATE HZ_CODE_ASSIGNMENTS SET
                                                end_date_active = SYSDATE
                                        WHERE code_assignment_id = v_rec.code_assignment_id;
                                END IF;
                        END LOOP;
                ELSE
                        -- create non-primary code assignment
                        FOR v_rec IN c_code_assign(
                                p_in_rec.owner_table_name,
                                p_in_rec.owner_table_id,
                                p_in_rec.class_category,
                                p_in_rec.actual_content_source
                                )
                        LOOP
                                IF (v_rec.class_code = p_in_rec.class_code)
                                THEN
-- Bug 3293069 - Added end_date_active condition so that history records are not
--               updated
                                        IF (v_rec.PRIMARY_FLAG = 'Y'
                                                And ((v_rec.end_date_active is NULL) OR
                                                (v_rec.end_date_active >= sysdate))
                                           )
                                        THEN
                                                -- AN PRIMARY ONE EXISTS, terminate it
                                                UPDATE HZ_CODE_ASSIGNMENTS SET
                                                        end_date_active = SYSDATE
                                                WHERE code_assignment_id = v_rec.code_assignment_id;
                                        ELSE
                                                -- AN NON-PRIMARY ONE EXISTS
                                                IF is_overlap(p_in_rec.start_date_active,
                                                        p_in_rec.end_date_active,
                                                        v_rec.start_date_active,
                                                        v_rec.end_date_active) = 'Y'
                                                THEN
                                                        -- overlaps with this existing one

                                                       /* Bug 3289620.
                                                        | FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
                                                        | FND_MESSAGE.SET_TOKEN('COLUMN', 'class_category-class_code');
                                                        */
                                                       FND_MESSAGE.SET_NAME('AR', 'HZ_IMP_CODE_ASSG_DATE_OVERLAP');


                                                        FND_MSG_PUB.ADD;
                                                        x_return_status := FND_API.G_RET_STS_ERROR;
							--Bug 3962783
                                                        --RAISE G_EX_INVALID_PARAM;
                                                END IF;
                                        END IF;
                                END IF;
                        END LOOP;
                END IF;
        END IF;

  --Validations for owner_table_id and owner_table_key_1 to owner_table_key_5
  --Bug 2825247: The following condition should be checked only when create_update_flag is 'C'
  IF create_update_flag = 'C'
  THEN
    IF  ((p_in_rec.owner_table_id IS NOT NULL AND
          p_in_rec.owner_table_id <> FND_API.G_MISS_NUM) AND
         (p_in_rec.owner_table_key_1 IS NOT NULL AND
          p_in_rec.owner_table_key_1 <> FND_API.G_MISS_CHAR)) OR
        ((p_in_rec.owner_table_id IS NULL OR
          p_in_rec.owner_table_id = FND_API.G_MISS_NUM) AND
         (p_in_rec.owner_table_key_1 IS NULL OR
          p_in_rec.owner_table_key_1 = FND_API.G_MISS_CHAR))
    THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_COMBINATION2');
         FND_MESSAGE.SET_TOKEN('COLUMN1', 'owner_table_id');
         FND_MESSAGE.SET_TOKEN('COLUMN2', 'owner_table_key_1');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
	 --Bug 3962783
         --RAISE G_EX_INVALID_PARAM;
    END IF;
    --If owner_table_key_1 is not supplied, then owner_table_key_2 cannot be supplied.
    IF  ((p_in_rec.owner_table_key_1 IS NULL OR
          p_in_rec.owner_table_key_1 = FND_API.G_MISS_CHAR) AND
         (p_in_rec.owner_table_key_2 IS NOT NULL AND
          p_in_rec.owner_table_key_2 <> FND_API.G_MISS_CHAR))
    THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_COMBINATION1');
         FND_MESSAGE.SET_TOKEN('COLUMN1', 'owner_table_key_1');
         FND_MESSAGE.SET_TOKEN('COLUMN2', 'owner_table_key_2');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
	 --Bug 3962783
         --RAISE G_EX_INVALID_PARAM;
    END IF;

    --If owner_table_key_2 is not supplied, then owner_table_key_3 cannot be supplied.
    IF  ((p_in_rec.owner_table_key_2 IS NULL OR
          p_in_rec.owner_table_key_2 = FND_API.G_MISS_CHAR) AND
         (p_in_rec.owner_table_key_3 IS NOT NULL AND
          p_in_rec.owner_table_key_3 <> FND_API.G_MISS_CHAR))
    THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_COMBINATION1');
         FND_MESSAGE.SET_TOKEN('COLUMN1', 'owner_table_key_2');
         FND_MESSAGE.SET_TOKEN('COLUMN2', 'owner_table_key_3');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
	 --Bug 3962783
         --RAISE G_EX_INVALID_PARAM;
    END IF;

    --If owner_table_key_3 is not supplied, then owner_table_key_4 cannot be supplied.
    IF ((p_in_rec.owner_table_key_3 IS NULL OR
         p_in_rec.owner_table_key_3 = FND_API.G_MISS_CHAR) AND
        (p_in_rec.owner_table_key_4 IS NOT NULL AND
         p_in_rec.owner_table_key_4 <> FND_API.G_MISS_CHAR))
    THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_COMBINATION1');
         FND_MESSAGE.SET_TOKEN('COLUMN1', 'owner_table_key_3');
         FND_MESSAGE.SET_TOKEN('COLUMN2', 'owner_table_key_4');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
	 --Bug 3962783
         --RAISE G_EX_INVALID_PARAM;
    END IF;

    --If owner_table_key_4 is not supplied, then owner_table_key_5 cannot be supplied.
    IF ((p_in_rec.owner_table_key_4 IS NULL OR
         p_in_rec.owner_table_key_4 = FND_API.G_MISS_CHAR) AND
        (p_in_rec.owner_table_key_5 IS NOT NULL AND
         p_in_rec.owner_table_key_5 <> FND_API.G_MISS_CHAR))
    THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_COMBINATION1');
         FND_MESSAGE.SET_TOKEN('COLUMN1', 'owner_table_key_4');
         FND_MESSAGE.SET_TOKEN('COLUMN2', 'owner_table_key_5');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
	 --Bug 3962783
         --RAISE G_EX_INVALID_PARAM;
    END IF;

    bool := HZ_CLASSIFICATION_V2PUB.IS_VALID_CATEGORY(
     p_owner_table     =>   p_in_rec.owner_table_name,
     p_class_category  =>   p_in_rec.class_category,
     p_id              =>   p_in_rec.owner_table_id,

-- Bug 3077574 : Added p_key_1 parameter in the function call

     p_key_1           =>         p_in_rec.owner_table_key_1,
     p_key_2           =>         p_in_rec.owner_table_key_2,
     p_key_3           =>         p_in_rec.owner_table_key_3,
     p_key_4           =>   p_in_rec.owner_table_key_4,
     p_key_5           =>         p_in_rec.owner_table_key_5
    );

    IF bool='F' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_PRIMARY_KEY');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
	  --Bug 3962783
          --RAISE G_EX_INVALID_PARAM;
    END IF;
  END IF;
/* -- Bug 3962783
EXCEPTION
WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  -- Loop through to put the other error messages in fnd stack
  FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
  END LOOP;
  x_return_status := fnd_api.G_RET_STS_ERROR;
*/
END;




/*---------------------------------------
  -- Validate Hz_Class_Code_Relations  --
  ---------------------------------------*/
FUNCTION child_code
-- Return Y if the p_class_code in the p_class_category for that period has one or more parent
--        N otherwise
(p_class_category    VARCHAR2,
 p_class_code        VARCHAR2,
 p_start_date_active DATE,
 p_end_date_active   DATE,
 x_parent_code       IN OUT NOCOPY VARCHAR2,
 x_start_date_active IN OUT NOCOPY DATE,
 x_end_date_active   IN OUT NOCOPY DATE)
RETURN VARCHAR2
IS
 CURSOR c_par
 IS
 SELECT class_code,
        start_date_active,
        end_date_active
   FROM hz_class_code_relations
  WHERE class_category = p_class_category
    AND sub_class_code = p_class_code
    AND hz_class_validate_v2pub.is_overlap(start_date_active, end_date_active,
                                 p_start_date_active, p_end_date_active)='Y'
    AND ROWNUM = 1;
 result VARCHAR2(1);
BEGIN
 OPEN c_par;
  FETCH c_par INTO x_parent_code, x_start_date_active, x_end_date_active;
  IF c_par%NOTFOUND THEN
   result := 'N';
  ELSE
   result := 'Y';
  END IF;
 CLOSE c_par;
 RETURN result;
END child_code;

FUNCTION parent_code
-- Return Y if the class code in the class category has already one parent
--        N otherwise
( p_class_category    VARCHAR2,
  p_class_code        VARCHAR2,
  p_start_date_active DATE,
  p_end_date_active   DATE,
  x_child_code        IN OUT NOCOPY VARCHAR2,
  x_start_date_active IN OUT NOCOPY DATE,
  x_end_date_active   IN OUT NOCOPY DATE)
RETURN VARCHAR2
IS
 result           VARCHAR2(1);
 CURSOR c0
 IS
 SELECT start_date_active,
        end_date_active ,
        sub_class_code
   FROM hz_class_code_relations
  WHERE class_category = p_class_category
    AND class_code     = p_class_code
    AND (   NVL(end_date_active, p_start_date_active) >= p_start_date_active
         OR start_date_active <= NVL(p_end_date_active, start_date_active)    )
    AND ROWNUM  = 1 ;
BEGIN
 result  := 'N';
 OPEN c0;
   FETCH c0 INTO x_start_date_active ,x_end_date_active, x_child_code ;
   IF c0%NOTFOUND THEN
     result := 'Y';
   ELSE
     result := 'N';
   END IF;
 close c0;
 RETURN result;
END parent_code;

FUNCTION is_categ_multi_parent
-- Return 'Y' if the category has its allow_multi_parent_flag to Y
--        'N' otherwise
( p_class_category VARCHAR2)
RETURN VARCHAR2
IS
CURSOR c0
IS
SELECT allow_multi_parent_flag
  FROM hz_class_categories
 WHERE class_category = p_class_category;
result VARCHAR2(1);
l_flag VARCHAR2(1);
BEGIN
 OPEN c0;
  FETCH c0 INTO l_flag;
  IF l_flag = 'Y' THEN
     result := 'Y';
  ELSE
     result := 'N';
  END IF;
 CLOSE c0;
 RETURN result;
END is_categ_multi_parent;

FUNCTION previous_generation
        (in_tab            in gen_list,
         in_class_category in varchar2,
         in_date_start     in date,
         in_date_end       in date default null,
         in_generation     in number)
return gen_list
IS
 cursor c0(in_class_category in varchar2,
           l_class_code      in varchar2,
           in_date_start     in date,
           in_date_end       in date)
 is
 select class_code,
        sub_class_code,
        start_date_active,
        end_date_active
   from hz_class_code_relations
  where class_category = in_class_category
    and sub_class_code = l_class_code
    and (hz_class_validate_v2pub.is_overlap
         (in_date_start, in_date_end,
          start_date_active, end_date_active)= 'Y');

 ltab   gen_list;
 lstart_date date;
 lend_date   date;
 result gen_list;
 lrec   c0%rowtype;
 cpt    number;
 i      number;
 j      number;

begin
 i    := 0;
 j    := 0;
 cpt  :=  in_tab.count;

 -- initial dates
 lstart_date := in_date_start;
 lend_date   := in_date_end;

 loop
   i := i + 1;
   exit when i > cpt;

   -- Use the narrowest interval of time
   if in_tab(i).end_date_active IS NOT NULL then
     if lend_date IS NULL then
       lend_date := in_tab(i).end_date_active;
     else
       if in_tab(i).end_date_active < lend_date then
         lend_date := in_tab(i).end_date_active;
       end if;
     end if;
   end if;

   if in_tab(i).start_date_active IS NOT NULL then
     if in_tab(i).start_date_active > lstart_date then
        lstart_date := in_tab(i).start_date_active;
     end if;
   end if;

   open c0(in_class_category,
           in_tab(i).class_code,
           lstart_date,
           lend_date);
   loop
     fetch c0  into lrec;
     exit when c0%notfound;
     j := j + 1;
     result(j).class_code     := lrec.class_code;
     result(j).sub_class_code := lrec.sub_class_code;
     result(j).start_date_active := lrec.start_date_active;
     result(j).end_date_active   := lrec.end_date_active;
     result(j).generation     := in_generation;
   end loop;

   close c0;
 end loop;
 return result;

end previous_generation;

FUNCTION next_generation
        (in_tab            in gen_list,
         in_class_category in varchar2,
         in_date_start     in date,
         in_date_end       in date default null,
         in_generation     in number)
return gen_list
IS
 cursor c0(in_class_category in varchar2,
           l_sub_class_code  in varchar2,
           in_date_start     in date,
           in_date_end       in date)
 is
 select class_code,
        sub_class_code,
        start_date_active,
        end_date_active
   from hz_class_code_relations
  where class_category = in_class_category
    and class_code     = l_sub_class_code
    and (hz_class_validate_v2pub.is_overlap
         (in_date_start, in_date_end,
          start_date_active, end_date_active)= 'Y');

 ltab   gen_list;
 lstart_date date;
 lend_date   date;
 result gen_list;
 lrec   c0%rowtype;
 cpt    number;
 i      number;
 j      number;

begin
 i    := 0;
 j    := 0;
 cpt  :=  in_tab.count;

 -- initial dates
 lstart_date := in_date_start;
 lend_date   := in_date_end;

 loop
   i := i + 1;
   exit when i > cpt;

   -- Use the narrowest interval of time
   if in_tab(i).end_date_active IS NOT NULL then
     if lend_date IS NULL then
       lend_date := in_tab(i).end_date_active;
     else
       if in_tab(i).end_date_active < lend_date then
         lend_date := in_tab(i).end_date_active;
       end if;
     end if;
   end if;

   if in_tab(i).start_date_active IS NOT NULL then
     if in_tab(i).start_date_active > lstart_date then
        lstart_date := in_tab(i).start_date_active;
     end if;
   end if;

   open c0(in_class_category,
           in_tab(i).sub_class_code,
           lstart_date,
           lend_date);
   loop
     fetch c0  into lrec;
     exit when c0%notfound;
     j := j + 1;
     result(j).class_code     := lrec.class_code;
     result(j).sub_class_code := lrec.sub_class_code;
     result(j).start_date_active := lrec.start_date_active;
     result(j).end_date_active   := lrec.end_date_active;
     result(j).generation     := in_generation;
   end loop;

   close c0;
 end loop;
 return result;

end next_generation;

FUNCTION tab_concatenated
( in_tab1  in gen_list,
  in_tab2  in gen_list)
RETURN gen_list
is
result  gen_list;
i       NUMBER;
k       NUMBER;
j       NUMBER;
BEGIN
 i    := in_tab1.count;
 k    := in_tab2.count;
 j    := 0;
 result := in_tab1;
 LOOP
   i := i + 1;
   j := j + 1;
   exit when j > k;
   result(i).class_code        := in_tab2(j).class_code;
   result(i).sub_class_code    := in_tab2(j).sub_class_code;
   result(i).start_date_active := in_tab2(j).start_date_active;
   result(i).end_date_active   := in_tab2(j).end_date_active;
   result(i).generation        := in_tab2(j).generation;
 END LOOP;

 RETURN result;
END tab_concatenated;

FUNCTION exist_rec_in_list_poc
(in_tab  in gen_list,
 in_rec  in gen_rec,
 in_poc  in VARCHAR2)
RETURN VARCHAR2
is
i       NUMBER;
k       NUMBER;
test    NUMBER;
result  VARCHAR2(1);
BEGIN
 result := 'N';
 k    := in_tab.count;
 i    := 0;
 LOOP
  i := i + 1;
  exit when i > k;
  IF in_poc = 'CODE' THEN
   -- Code used for parents set
   IF (    (in_tab(i).class_code )    = (in_rec.class_code)
  --     and nvl(in_tab(i).sub_class_code,'@') = nvl(in_rec.sub_class_code,'@')
  --     and in_tab(i).start_date_active       = in_rec.start_date_active
      )
   THEN
     result := 'Y';
     exit;
   END IF;
  ELSIF in_poc ='SUB' THEN
   -- Code used for children set
   IF (
        in_tab(i).sub_class_code = in_rec.sub_class_code
      )
   THEN
     result := 'Y';
     exit;
   END IF;
  END IF;
 END LOOP;
 RETURN result;
END exist_rec_in_list_poc;

FUNCTION tab_normal_poc
(in_tab  in  gen_list,
 in_poc  in  VARCHAR2)
RETURN gen_list
is
i      NUMBER;
j      NUMBER;
k      NUMBER;
lrec   gen_rec;
result gen_list;
BEGIN
 k := in_tab.count;
 i := 0;
 j := 0;
 LOOP
  i := i + 1;
  exit when i > k;
  IF in_poc = 'CODE' THEN
  -- Used for Parents set
    IF  exist_rec_in_list_poc( result, in_tab(i),'CODE') = 'N' THEN
      j := j + 1;
      result(j) := in_tab(i);
    END IF;
  ELSIF in_poc  = 'SUB' THEN
  -- Used for children set
    IF  exist_rec_in_list_poc( result, in_tab(i),'SUB') = 'N' THEN
      j := j + 1;
      result(j) := in_tab(i);
    END IF;
  END IF;
 END LOOP;
 RETURN result;
END tab_normal_poc;

FUNCTION set_of_parents
(in_class_category in varchar2,
 in_class_code in varchar2,
 in_date_start     in date,
 in_date_end       in date default null)
return  gen_list
IS
result  gen_list;
ltab    gen_list;
i       number;
lcpt    number;
begin
 -- initialize ltab
 ltab(1).class_code := in_class_code;
 --dbms_output.put_line(ltab(1).class_code);
 i := 0;
 loop
   i := i + 1;
   exit when ltab.count = 0;
   ltab :=  previous_generation
              (ltab,
               in_class_category,
               in_date_start,
               in_date_end,
               i);
   ltab := tab_normal_poc(ltab,'CODE');
   result := tab_concatenated(result,ltab);
 end loop;
 result := tab_normal_poc(result,'CODE');
 return result;
end set_of_parents;

FUNCTION set_of_children
(in_class_category in varchar2,
 in_sub_class_code in varchar2,
 in_date_start     in date,
 in_date_end       in date default null)
return  gen_list
IS
result  gen_list;
ltab    gen_list;
i       number;
lcpt    number;
l_date_start date;
l_date_end   date;
begin
 -- initialize ltab
 ltab(1).sub_class_code := in_sub_class_code;
 --dbms_output.put_line(ltab(1).sub_class_code);
 i := 0;
 loop
   i := i + 1;
   exit when ltab.count = 0;
   ltab :=  next_generation
              (ltab,
               in_class_category,
               in_date_start,
               in_date_end,
               i);
   ltab := tab_normal_poc(ltab,'SUB');
   result := tab_concatenated(result,ltab);
 end loop;
 result := tab_normal_poc(result,'SUB');
 return result;
end set_of_children;

FUNCTION is_cod1_ancest_cod2
(in_class_category in varchar2,
 in_class_code_1   in varchar2,
 in_class_code_2   in varchar2,
 in_date_start     in date,
 in_date_end       in date default null)
return varchar2
is
ltab    gen_list;
result  varchar2(1);
i       number;
cpt     number;
begin
 result := 'N';
 ltab := set_of_parents
         (in_class_category,
          in_class_code_2  ,
          in_date_start    ,
          in_date_end       );
 i := 0;
 cpt := ltab.count;
 loop
   i := i + 1;
   exit when i > cpt;
   if ltab(i).class_code = in_class_code_1 then
     result := 'Y';
     exit;
   end if;
 end loop;
 return result;
end is_cod1_ancest_cod2;

FUNCTION is_cod1_descen_cod2
(in_class_category in varchar2,
 in_class_code_1   in varchar2,
 in_class_code_2   in varchar2,
 in_date_start     in date,
 in_date_end       in date default null)
return varchar2
is
ltab    gen_list;
result  varchar2(1);
i       number;
cpt     number;
begin
 result := 'N';
 ltab := set_of_children
         (in_class_category,
          in_class_code_2  ,
          in_date_start    ,
          in_date_end       );
 i := 0;
 cpt := ltab.count;
 loop
   i := i + 1;
   exit when i > cpt;
   if ltab(i).sub_class_code = in_class_code_1 then
     result := 'Y';
     exit;
   end if;
 end loop;
 return result;
end is_cod1_descen_cod2;

Function exist_pk_relation
-- Return 'Y' if the relation Already exists
--        'N' otherwise
( p_class_category varchar2,
  p_class_code     varchar2,
  p_sub_class_code varchar2,
  p_start_date_active date,
  x_end_date_active in out NOCOPY date)
return varchar2
IS
cursor c0
IS
select end_date_active
  from hz_class_code_relations
 where class_category = p_class_category
   and class_code     = p_class_code
   and sub_class_code = p_sub_class_code
   and start_date_active = p_start_date_active
   and rownum = 1;
result varchar2(1);
begin
 open c0;
   fetch c0 into x_end_date_active;
   if c0%notfound then
     result := 'N';
   else
     result := 'Y';
   end if;
 close c0;
 return result;
end exist_pk_relation;

Function exist_overlap_relation
-- returns 'Y' if it exists a relation which overlap the one we entered
--         'N' otehrwise
( p_create_update_flag varchar2,
  p_class_category  varchar2,
  p_class_code      varchar2,
  p_sub_class_code  varchar2,
  p_start_date_active date,
  p_end_date_active   date,
  x_start_date_active in out NOCOPY date,
  x_end_date_active   in out NOCOPY date  )
Return varchar2
is
 cursor c_create
 is
 select start_date_active,
        end_date_active
   from hz_class_code_relations
  where class_category = p_class_category
    and class_code     = p_class_code
    and sub_class_code = p_sub_class_code
    and hz_class_validate_v2pub.is_overlap(start_date_active  , end_date_active,
                                 p_start_date_active, p_end_date_active )= 'Y';
 cursor c_update
 is
 select start_date_active,
        end_date_active
   from hz_class_code_relations
  where class_category = p_class_category
    and class_code     = p_class_code
    and sub_class_code = p_sub_class_code
    and start_date_active <> p_start_date_active
    and hz_class_validate_v2pub.is_overlap(start_date_active  , end_date_active,
                                 p_start_date_active, p_end_date_active ) = 'Y';
 result varchar2(1);
begin
 if p_create_update_flag = 'C' then
   open c_create;
     fetch c_create into x_start_date_active, x_end_date_active;
     if c_create%notfound then
       result := 'N';
     else
       result := 'Y';
     end if;
   close c_create;
 elsif p_create_update_flag = 'U' then
   open c_update;
     fetch c_update into x_start_date_active, x_end_date_active;
     if c_update%notfound then
       result := 'N';
     else
       result := 'Y';
     end if;
   close c_update;
 end if;
 return result;
end exist_overlap_relation;

procedure validate_class_code_relation(
  p_in_rec             IN     HZ_CLASSIFICATION_V2PUB.CLASS_CODE_RELATION_REC_TYPE,
  create_update_flag   IN     VARCHAR2,
  x_return_status      IN OUT NOCOPY VARCHAR2
) IS
        l_end_date  DATE := NULL;
        l_count NUMBER := 0;
        l_end       VARCHAR2(12);
        l_created_by_module     hz_class_code_relations.created_by_module%TYPE;
	--Bug 4897711
	la_start DATE := to_date(NULL);
	la_end   DATE := to_date(NULL);
        CURSOR c_code_rel(
              p_class_category  VARCHAR2,
              p_class_code      VARCHAR2,
              p_sub_class_code  VARCHAR2)
        IS
         SELECT created_by_module
           FROM hz_class_code_relations
          WHERE class_category = p_class_category
            AND class_code     = p_class_code
            AND sub_class_code = p_sub_class_code;

BEGIN

        IF create_update_flag = 'U' THEN
          OPEN c_code_rel(
            p_in_rec.class_category, p_in_rec.class_code, p_in_rec.sub_class_code);
          FETCH c_code_rel INTO l_created_by_module;
          CLOSE c_code_rel;
        END IF;

--Check for mandatory columns
        check_mandatory_str_col(
                create_update_flag,
                'class_category',
                p_in_rec.class_category,
                FALSE,
                FALSE,  -- cannot be missing: part of PK
                x_return_status);

        check_mandatory_str_col(
                create_update_flag,
                'class_code',
                p_in_rec.class_code,
                FALSE,
                FALSE,  -- cannot be missing: part of PK
                x_return_status);

        check_mandatory_str_col(
                create_update_flag,
                'sub_class_code',
                p_in_rec.sub_class_code,
                FALSE,
                FALSE,  -- cannot be missing: part of PK
                x_return_status);

        -- Bug 3816590
        /*
        check_mandatory_date_col(
                create_update_flag,
                'start_date_active',
                p_in_rec.start_date_active,
                FALSE,
                FALSE,  -- cannot be missing: part of PK
                x_return_status);
        */

        --Bug 2890671: created_by_module field is mandatory
        -- created_by_module is non-updateable, lookup

        hz_utility_v2pub.validate_created_by_module(
          p_create_update_flag     => create_update_flag,
          p_created_by_module      => p_in_rec.created_by_module,
          p_old_created_by_module  => l_created_by_module,
          x_return_status          => x_return_status);

--Check for lookup type validations.
        validate_fnd_lookup(p_in_rec.class_category,
                'class_code',
                p_in_rec.class_code,
                x_return_status);
        validate_fnd_lookup(p_in_rec.class_category,
                'sub_class_code',
                p_in_rec.sub_class_code,
                x_return_status);

        --check_err( x_return_status );

------------------------------------------------------
---- Validation for class code and sub clas code ----
------------------------------------------------------
      IF p_in_rec.class_code = p_in_rec.sub_class_code THEN
         fnd_message.set_name('AR', 'HZ_API_CLASS_CODE_VAL');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
	 --Bug 3962783
         --RAISE g_ex_invalid_param;
      END IF;


--Check FK validations.
--{HYU
     -- Existance of Class Category
     check_existence_class_category
        ( p_in_rec.class_category,
          x_return_status         );

     --check_err( x_return_status );
--}

--{ HYU
-- Recursive relations is not allowed
-- Relation "Parent Code A " associated with "Child Code B"
--  Code A should not have any descendent equals to Code B
--  Code B should not have any ascendant equals to Code A
IF (is_cod1_ancest_cod2( p_in_rec.class_category,
                         p_in_rec.sub_class_code,
                         p_in_rec.class_code    ,
                         p_in_rec.start_date_active,
                         p_in_rec.end_date_active) = 'Y') THEN
   IF p_in_rec.end_date_active is null then
      l_end := 'Unspecified';
   ELSE
      l_end := to_char(p_in_rec.end_date_active,'DD-MON-RRRR');
   END IF;
--   fnd_message.set_string( p_in_rec.sub_class_code ||
--                           ' has already been defined as ascendant of ' || p_in_rec.class_code ||
--                           ' for a period that overlaps the period started from ' || to_char(p_in_rec.start_date_active,'DD-MON-RRRR') ||
--                           ' to ' || l_end);
--   fnd_msg_pub.add;
   --Bug 4897711 : Added error message
   fnd_message.set_name('AR', 'HZ_API_CIRCULAR_CODE_RELATION');
   fnd_message.set_token('CLASS_CODE1', p_in_rec.class_code);
   fnd_message.set_token('CLASS_CODE2', p_in_rec.sub_class_code);
   fnd_msg_pub.add;
   x_return_status := fnd_api.g_ret_sts_error;
   --Bug 3962783
   --RAISE g_ex_invalid_param;

ELSIF  (is_cod1_descen_cod2( p_in_rec.class_category   ,
                             p_in_rec.class_code       ,
                             p_in_rec.sub_class_code   ,
                             p_in_rec.start_date_active,
                             p_in_rec.end_date_active   ) = 'Y') THEN
   IF p_in_rec.end_date_active is null then
      l_end := 'Unspecified';
   ELSE
      l_end := to_char(p_in_rec.end_date_active,'DD-MON-RRRR');
   END IF;
--   fnd_message.set_string( p_in_rec.class_code ||
--                           ' has already been defined as descendant of ' || p_in_rec.sub_class_code ||
--                           ' for a period that overlaps the period started from ' || to_char(p_in_rec.start_date_active,'DD-MON-RRRR') ||
--                           ' to ' || l_end);
--   fnd_msg_pub.add;
   --Bug 4897711 : Added error message
   fnd_message.set_name('AR', 'HZ_API_CIRCULAR_CODE_RELATION');
   fnd_message.set_token('CLASS_CODE1', p_in_rec.class_code);
   fnd_message.set_token('CLASS_CODE2', p_in_rec.sub_class_code);
   fnd_msg_pub.add;
   x_return_status := fnd_api.g_ret_sts_error;
   --Bug 3962783
   --RAISE g_ex_invalid_param;
END IF;
--}

 if create_update_flag = 'C' then
    -- Check PK
    if (exist_pk_relation( p_in_rec.class_category,
                         p_in_rec.class_code    ,
                         p_in_rec.sub_class_code,
                         p_in_rec.start_date_active,
                         l_end_date ) = 'Y'         )  then
      fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
      fnd_message.set_token('COLUMN', 'class_category-class_code-sub_class_code-start_date_active');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      --Bug 3962783
      --RAISE g_ex_invalid_param;
    end if;

    -- Check Date actives
    check_start_end_active_dates(
              p_in_rec.start_date_active,
              p_in_rec.end_date_active,
              x_return_status);

    --check_err(x_return_status);

    if exist_overlap_relation('C',
                             p_in_rec.class_category,
                             p_in_rec.class_code    ,
                             p_in_rec.sub_class_code,
                             p_in_rec.start_date_active    ,
                             p_in_rec.end_date_active      ,
			     -- Bug 4897711
                             la_start           ,
                             la_end             ) = 'Y' then
         fnd_message.set_name('AR', 'HZ_API_CLASS_REL_OVERLAP');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
	 --Bug 3962783
         --RAISE g_ex_invalid_param;
    end if;

    if (     (is_categ_multi_parent(p_in_rec.class_category) = 'N' )
         AND (child_code(p_in_rec.class_category,
                         p_in_rec.sub_class_code,
                         p_in_rec.start_date_active,
                         p_in_rec.end_date_active ,
                         l_class_code,
                         l_start_date_active,
                         l_end_date_active) = 'Y'          ) ) then
          -- If Allowed_Multi_Parent_Flag = 'N' Then check that sub_code can only have one parent
          l_start := TO_CHAR(l_start_date_active, 'DD-MON-RRRR');
           IF l_end_date_active IS NULL THEN
              l_end := 'Unspecified';
           ELSE
              l_end := TO_CHAR(l_end_date_active, 'DD-MON-RRRR');
           END IF;
          fnd_message.set_name('AR', 'HZ_API_MULTI_PARENT_FORBID');
          fnd_message.set_token('CLASS_CATEGORY', p_in_rec.class_category);
          fnd_message.set_token('CLASS_CODE3'   , p_in_rec.sub_class_code);
          fnd_message.set_token('CLASS_CODE2'   , p_in_rec.class_code);
          fnd_message.set_token('CLASS_CODE1'   , l_class_code);
          fnd_message.set_token('START1'        , l_start_date_active);
          fnd_message.set_token('END1'          , l_end_date_active  );
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
	  --Bug 3962783
          --RAISE g_ex_invalid_param;
    end if;

 end if;

-- Updating
-- Check end_date_active
 if create_update_flag = 'U' then
   if ( exist_pk_relation( p_in_rec.class_category,
                           p_in_rec.class_code    ,
                           p_in_rec.sub_class_code,
                           p_in_rec.start_date_active,
                           l_end) = 'N') then
    -- Relation does not exist
      fnd_message.set_name('AR', 'HZ_API_REL_NOT_EXIST');
      fnd_message.set_token('COLUMN', 'start_date_active-end_date_active');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      --Bug 3962783
      --RAISE g_ex_invalid_param;
    end if;

    -- Check Date actives
    check_start_end_active_dates(
                p_in_rec.start_date_active,
                p_in_rec.end_date_active,
                x_return_status);

    --check_err(x_return_status);

    if (exist_overlap_relation('U',
                             p_in_rec.class_category,
                             p_in_rec.class_code ,
                             p_in_rec.sub_class_code,
                             p_in_rec.start_date_active,
                             p_in_rec.end_date_active,
			     -- Bug 4897711
                             la_start,
                             la_end ) = 'Y') then
     -- Overlap relations are not allowed
        fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
        fnd_message.set_token('COLUMN', 'class_category-class_code-sub_class_code-start_date_active');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
	--Bug 3962783
        --RAISE g_ex_invalid_param;
    end if;
 end if;
/* -- Bug 3962783
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  x_return_status := fnd_api.G_RET_STS_ERROR;
*/
END validate_class_code_relation;

  -----------------------------------------------------------------
   /**
    * PROCEDURE chk_exist_cls_catgry_type_code
    *
    * DESCRIPTION
    *     This procedure is used to check existing record for class category type,
    *     class coding, security group id, application id, and language combination
    *     which are difined in FND_LOOKUP_VALUES_U1.
    *
    * ARGUMENTS
    *   IN:
    *     p_class_category_type          Related to class category type column
    *     p_class_category_code          Related to class code column
    *     p_security_group_id            Rleated to security group id column
    *     p_view_application_id          Related to application id column
    *
    *   IN/OUT:
    *     x_return_status                Return status after the call. The status can
    *                                    be FND_API.G_RET_STS_ERROR (error)
    *
    * NOTES
    *
    * CREATION/MODIFICATION HISTORY
    *
    *   09-20-2007    Manivannan J       o Created for Bug 6158794.
    */
   -----------------------------------------------------------------

   PROCEDURE chk_exist_cls_catgry_type_code
    (p_class_category_type IN     VARCHAR2,
     p_class_category_code IN     VARCHAR2,
     p_security_group_id   IN     NUMBER,
     p_view_application_id IN     NUMBER,
     x_return_status       IN OUT NOCOPY VARCHAR2)
   IS

    CURSOR c_exist_class_catgry_type_code(l_class_category_type VARCHAR2, l_class_category_code VARCHAR2, l_security_group_id NUMBER, l_view_application_id NUMBER)
    IS
    SELECT 'Y'
      FROM FND_LOOKUP_VALUES
     WHERE LOOKUP_TYPE = l_class_category_type
       AND LOOKUP_CODE = l_class_category_code
       AND SECURITY_GROUP_ID =l_security_group_id
       AND VIEW_APPLICATION_ID = l_view_application_id
       AND LANGUAGE = userenv('LANG')
       AND ROWNUM = 1;

    l_exist   VARCHAR2(1);

   BEGIN

    OPEN c_exist_class_catgry_type_code(p_class_category_type, p_class_category_code, p_security_group_id, p_view_application_id);
     FETCH c_exist_class_catgry_type_code INTO l_exist;
     IF c_exist_class_catgry_type_code%FOUND THEN
      fnd_message.set_name('AR','HZ_API_DUP_CLASS');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
     END IF;
    CLOSE c_exist_class_catgry_type_code;

   END chk_exist_cls_catgry_type_code;

   -----------------------------------------------------------------
   /**
    * PROCEDURE chk_exist_clas_catgry_typ_mng
    *
    * DESCRIPTION
    *     This procedure is used to check existing record for class category type,
    *     class meaning, security group id, application id, and language combination
    *     which are difined in FND_LOOKUP_VALUES_U2.
    *
    * ARGUMENTS
    *   IN:
    *     p_class_category_type          Related to class category type column
    *     p_class_category_meaning       Related to class meaning column
    *     p_security_group_id            Rleated to security group id column
    *     p_view_application_id          Related to application id column
    *
    *   IN/OUT:
    *     x_return_status                Return status after the call. The status can
    *                                    be FND_API.G_RET_STS_ERROR (error)
    *
    * NOTES
    *
    * CREATION/MODIFICATION HISTORY
    *
    *   09-20-2007    Manivannan J       o Created for Bug 6158794.
    */
   -----------------------------------------------------------------


   PROCEDURE chk_exist_clas_catgry_typ_mng
    (p_class_category_type    IN     VARCHAR2,
     p_class_category_meaning IN     VARCHAR2,
     p_security_group_id      IN     NUMBER,
     p_view_application_id    IN     NUMBER,
     x_return_status          IN OUT NOCOPY VARCHAR2)
   IS

    CURSOR c_exist_clas_catgry_typ_mng(l_class_category_type VARCHAR2, l_class_category_meaning VARCHAR2, l_security_group_id NUMBER, l_view_application_id NUMBER)
    IS
    SELECT 'Y'
      FROM FND_LOOKUP_VALUES
     WHERE LOOKUP_TYPE = l_class_category_type
       AND MEANING = l_class_category_meaning
       AND SECURITY_GROUP_ID =l_security_group_id
       AND VIEW_APPLICATION_ID = l_view_application_id
       AND LANGUAGE = userenv('LANG')
       AND ROWNUM = 1;

    l_exist   VARCHAR2(1);

   BEGIN

    OPEN c_exist_clas_catgry_typ_mng(p_class_category_type, p_class_category_meaning, p_security_group_id, p_view_application_id);
     FETCH c_exist_clas_catgry_typ_mng INTO l_exist;
     IF c_exist_clas_catgry_typ_mng%FOUND THEN
      fnd_message.set_name('AR','HZ_API_DUP_CLASS_TYPE_MEANING');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
     END IF;
    CLOSE c_exist_clas_catgry_typ_mng;

   END chk_exist_clas_catgry_typ_mng;


END HZ_CLASS_VALIDATE_V2PUB;

/
