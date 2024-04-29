--------------------------------------------------------
--  DDL for Package Body ENI_DENORM_HRCHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DENORM_HRCHY" AS
/* $Header: ENIDENHB.pls 120.4 2007/03/13 08:52:48 lparihar ship $  */

  g_func_area_id  NUMBER := 11;  -- Variable To Hold Functional Area For Product Functional Area
  g_catset_id     NUMBER := ENI_DENORM_HRCHY.GET_CATEGORY_SET_ID;  -- Variable To Hold Product Catalog Category Set
  g_tab_schema    VARCHAR2(20) := 'ENI';

-- This Public Function will return the Default Category Set Associated with
-- Product Reporting Functional Area
FUNCTION GET_CATEGORY_SET_ID RETURN NUMBER IS
 l_catset_id  NUMBER;
BEGIN
  SELECT CATEGORY_SET_ID INTO l_catset_id
  FROM MTL_DEFAULT_CATEGORY_SETS
  WHERE FUNCTIONAL_AREA_ID = g_func_area_id;

  RETURN l_catset_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE;
END GET_CATEGORY_SET_ID;

-- This is a Private function, which will return 'Y', if DBI is installed, else 'N'
FUNCTION IS_DBI_INSTALLED RETURN VARCHAR2 IS
  l_count NUMBER;
BEGIN
  SELECT 1 INTO l_count
  FROM ALL_OBJECTS
  WHERE OBJECT_NAME = 'ENI_OLTP_ITEM_STAR'
    AND OBJECT_TYPE = 'TABLE'
    AND OWNER = g_tab_schema;

  RETURN 'Y';
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN 'N';
END IS_DBI_INSTALLED;

-- ER: 3154516
-- This Public Function will return the last updated date for Product Catalog from de-norm table
FUNCTION GET_LAST_CATALOG_UPDATE_DATE RETURN DATE IS
  l_date DATE;
BEGIN
  SELECT MAX(LAST_UPDATE_DATE) INTO l_date
  FROM ENI_DENORM_HIERARCHIES
  WHERE OBJECT_ID = g_catset_id
    AND OBJECT_TYPE = 'CATEGORY_SET';

  RETURN l_date;
END GET_LAST_CATALOG_UPDATE_DATE;

-- This Public Procedure is used to insert records in the Staging Table
-- The staging table will be used in the Incremental Load of Denorm Table.
-- All the deleted/modified/new records in the Product Catalog Hierarchy has to be
-- there in the Staging table, which has to be done by calling this procedure.
PROCEDURE INSERT_INTO_STAGING(
      p_object_type     IN VARCHAR2,
      p_object_id       IN NUMBER,
      p_child_id        IN NUMBER,
      p_parent_id       IN NUMBER,
      p_mode_flag       IN VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2,
      p_language_code   IN VARCHAR2 DEFAULT NULL) IS

  l_language_code VARCHAR2(4);
  l_count NUMBER;
BEGIN
-- validating parameters bug 3134719
  IF p_mode_flag NOT IN ('A', 'M', 'D', 'C', 'S', 'E') THEN
    x_return_status := 'E';
    IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.ADD_EXC_MSG('ENI_DENORM_HRCHY', 'INSERT_INTO_STAGING', 'Invalid Mode Flag');
    END IF;
    FND_MSG_PUB.COUNT_AND_GET( P_COUNT => x_msg_count, P_DATA => x_msg_data);
    RETURN;
  END IF;

  IF p_object_type <> 'CATEGORY_SET' THEN
    x_return_status := 'E';
    IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.ADD_EXC_MSG('ENI_DENORM_HRCHY', 'INSERT_INTO_STAGING', 'Invalid Object Type. Must be CATEGORY_SET');
    END IF;
    FND_MSG_PUB.COUNT_AND_GET( P_COUNT => x_msg_count, P_DATA => x_msg_data);
    RETURN;
  END IF;

  IF p_object_id IS NULL THEN
    x_return_status := 'E';
    IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.ADD_EXC_MSG('ENI_DENORM_HRCHY', 'INSERT_INTO_STAGING', 'Object ID can not be NULL.');
    END IF;
    FND_MSG_PUB.COUNT_AND_GET( P_COUNT => x_msg_count, P_DATA => x_msg_data);
    RETURN;
  END IF;

  IF p_child_id IS NULL THEN
    x_return_status := 'E';
    IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.ADD_EXC_MSG('ENI_DENORM_HRCHY', 'INSERT_INTO_STAGING', 'Child Category ID can not be NULL.');
    END IF;
    FND_MSG_PUB.COUNT_AND_GET( P_COUNT => x_msg_count, P_DATA => x_msg_data);
    RETURN;
  END IF;

-- for sales and marketing enhancement
-- if changes in description, skip flag, effective date then inserting separate record
  IF p_mode_flag IN ('A', 'M', 'D') THEN
    UPDATE ENI_DENORM_HRCHY_STG
    SET PARENT_ID = p_parent_id,
        MODE_FLAG = DECODE(p_mode_flag, 'A', DECODE(MODE_FLAG, 'D', 'M', 'A'), p_mode_flag)
    WHERE OBJECT_TYPE = p_object_type
      AND OBJECT_ID = p_object_id
      AND CHILD_ID = p_child_id
      AND BATCH_FLAG = 'NEXT_BATCH';

    IF SQL%NOTFOUND THEN
      INSERT INTO ENI_DENORM_HRCHY_STG (
        OBJECT_TYPE,
        OBJECT_ID,
        CHILD_ID,
        PARENT_ID,
        MODE_FLAG,
        BATCH_FLAG)
      VALUES (
        p_object_type,
        p_object_id,
        p_child_id,
        p_parent_id,
        p_mode_flag,
        'NEXT_BATCH');
    END IF;
  ELSIF p_mode_flag IN ('S', 'U', 'E') THEN
  -- S - EXCLUDE_USER_VIEW column set to 'Y'
  -- U - EXCLUDE_USER_VIEW column set to 'N'
  -- E - Change in DISABLE_DATE column of a category
  -- mode flag value 'S' will override the values 'C', 'E'
  -- if mode flag 'S' is sent twice, we will toggle mode flag to 'S', 'U'
    UPDATE ENI_DENORM_HRCHY_STG
    SET PARENT_ID = p_parent_id,
        MODE_FLAG = DECODE(MODE_FLAG, 'S', DECODE(p_mode_flag, 'E', 'S', 'S', 'U', p_mode_flag),
                                      'U', DECODE(p_mode_flag, 'E', 'U', 'S', 'S', p_mode_flag), p_mode_flag)
    WHERE OBJECT_TYPE = p_object_type
      AND OBJECT_ID = p_object_id
      AND CHILD_ID = p_child_id
      AND MODE_FLAG IN ('S', 'U', 'E', 'C')
      AND BATCH_FLAG = 'NEXT_BATCH';

    IF SQL%NOTFOUND THEN
      INSERT INTO ENI_DENORM_HRCHY_STG (
        OBJECT_TYPE,
        OBJECT_ID,
        CHILD_ID,
        PARENT_ID,
        MODE_FLAG,
        BATCH_FLAG)
      VALUES (
        p_object_type,
        p_object_id,
        p_child_id,
        p_parent_id,
        p_mode_flag,
        'NEXT_BATCH');
    END IF;
  ELSIF p_mode_flag = 'C' THEN
  -- C - change in Category Description
  -- mode flag 'C' can only override itself. i.e. if mode flag is already 'S', 'E' then no changes in mode flag
  -- if more than one record's source_lang is = language code then language code will be updated to NULL.
  -- this is because actually more than one record is updated for description in this case
  -- also if user updates the description of same category in more than one language
  -- then the language code will be updated to NULL.
    IF p_language_code IS NOT NULL THEN
      BEGIN
        SELECT 1 INTO l_count
        FROM MTL_CATEGORIES_TL
        WHERE CATEGORY_ID = p_child_id
          AND SOURCE_LANG = p_language_code;

        l_language_code := p_language_code;
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          l_language_code := NULL;
        WHEN NO_DATA_FOUND THEN
          x_return_status := 'E';
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG('ENI_DENORM_HRCHY', 'INSERT_INTO_STAGING', 'Invalid Category ID, Language combination');
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => x_msg_count, P_DATA => x_msg_data);
          RETURN;
      END;
    ELSE
      -- Selecting userenv('LANG') into language code based on
      -- the discussion with Wasi and advised by him.

      select userenv('LANG') into l_language_code from dual;
    END IF;

    UPDATE ENI_DENORM_HRCHY_STG
    SET PARENT_ID = p_parent_id,
        MODE_FLAG = DECODE(MODE_FLAG, 'S', 'S', 'U', 'U', 'E', 'E', p_mode_flag),
        LANGUAGE_CODE = DECODE(MODE_FLAG, 'C', DECODE(LANGUAGE_CODE, l_language_code, l_language_code, NULL), NULL)
    WHERE OBJECT_TYPE = p_object_type
      AND OBJECT_ID = p_object_id
      AND CHILD_ID = p_child_id
      AND MODE_FLAG IN ('S', 'U', 'E', 'C')
      AND BATCH_FLAG = 'NEXT_BATCH';

    IF SQL%NOTFOUND THEN
      INSERT INTO ENI_DENORM_HRCHY_STG (
        OBJECT_TYPE,
        OBJECT_ID,
        CHILD_ID,
        PARENT_ID,
        MODE_FLAG,
        BATCH_FLAG,
        LANGUAGE_CODE)
      VALUES (
        p_object_type,
        p_object_id,
        p_child_id,
        p_parent_id,
        p_mode_flag,
        'NEXT_BATCH',
        l_language_code);
    END IF;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := null;
EXCEPTION WHEN OTHERS THEN
  x_return_status := 'U';
  IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.ADD_EXC_MSG('ENI_DENORM_HRCHY', 'INSERT_INTO_STAGING', SQLERRM);
  END IF;
  FND_MSG_PUB.COUNT_AND_GET( P_COUNT => x_msg_count, P_DATA => x_msg_data);
END INSERT_INTO_STAGING;

-- for sales and marketing enhancement
-- This procedure loads the denorm parents table
-- this procedure is called from the main procedure if sales and marketing is installed.
PROCEDURE LOAD_DENORM_PARENTS_PROD_HRCHY(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) IS
  CURSOR C1 IS
    SELECT TL.LANGUAGE_CODE, C.CATEGORY_ID, B.DISABLE_DATE
    FROM MTL_CATEGORY_SET_VALID_CATS C, MTL_CATEGORIES_B B, FND_LANGUAGES TL
    WHERE C.CATEGORY_SET_ID = g_catset_id
      AND TL.INSTALLED_FLAG IN ('I', 'B')
      AND B.CATEGORY_ID = C.CATEGORY_ID
      AND NOT EXISTS (SELECT NULL FROM EGO_PROD_CAT_SALES_MARKET_AGV A
                      WHERE A.CATEGORY_SET_ID = g_catset_id
                      AND A.CATEGORY_ID = C.CATEGORY_ID
                      AND NVL(A.EXCLUDE_USER_VIEW, 'N') = 'Y');

  CURSOR C3(l_child_id NUMBER, l_language VARCHAR2) IS
    SELECT TL.DESCRIPTION CHILD_DESC, C.CATEGORY_ID CHILD_ID
    FROM MTL_CATEGORIES_TL TL,
      (SELECT
         CATEGORY_ID, LEVEL hrchy
       FROM MTL_CATEGORY_SET_VALID_CATS
       START WITH CATEGORY_ID = l_child_id AND CATEGORY_SET_ID = g_catset_id
       CONNECT BY PRIOR PARENT_CATEGORY_ID = CATEGORY_ID AND CATEGORY_SET_ID = g_catset_id) C
    WHERE C.CATEGORY_ID = TL.CATEGORY_ID
      AND TL.LANGUAGE = l_language
      AND NOT EXISTS (SELECT NULL FROM EGO_PROD_CAT_SALES_MARKET_AGV A
                      WHERE A.CATEGORY_SET_ID = g_catset_id
                      AND A.CATEGORY_ID = C.CATEGORY_ID
                      AND NVL(A.EXCLUDE_USER_VIEW, 'N') = 'Y')
		      ORDER BY hrchy ASC; -- Bug 4749088

  l_concat_desc VARCHAR2(4001);
  l_desc        VARCHAR2(240);
  l_attr_grp_id NUMBER;
  l_eff_level   NUMBER;
  l_imm_par_id  NUMBER;
  l_length      NUMBER;
  l_count       NUMBER;

  l_user_id          NUMBER := FND_GLOBAL.USER_ID;
  l_conc_request_id  NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  l_prog_appl_id     NUMBER := FND_GLOBAL.PROG_APPL_ID;
  l_conc_program_id  NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;

BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Initial Load of Denorm Hierarchy Parents table begining');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
  -- getting attribute group id for sales and marketing
  -- this id will be inserted into the denorm hrchy parents table
  BEGIN
    SELECT ATTR_GROUP_ID INTO l_attr_grp_id
    FROM EGO_FND_DSC_FLX_CTX_EXT
    WHERE APPLICATION_ID = 431
      AND DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_PRODUCT_CATEGORY_SET'
      AND DESCRIPTIVE_FLEX_CONTEXT_CODE = 'SalesAndMarketing';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: Attribute Group not found for Sales and Marketing');
    RAISE;
  END;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleting Denorm Hierarchy Parents table');
  DELETE ENI_DENORM_HRCHY_PARENTS;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Populating Denorm Hierarchy Parents table');
  -- for each language installed and each category in hierarchy
  l_count := 0;
  FOR i IN C1 LOOP
    -- initializing all variables
    l_concat_desc := NULL;
    l_desc := NULL;
    l_eff_level := 0;
    l_imm_par_id := null;
    l_length := 0;

    -- for each node in the hierarchy upto the top_node
    -- preparing the concatenated descriptions
    FOR k IN C3(i.CATEGORY_ID, i.LANGUAGE_CODE) LOOP
      -- to trim from the start of the string onwards to accommodate more descriptions towards the end of the string.
      -- trim upto 4000 chars
      l_length := LENGTH(k.CHILD_DESC || '/' || l_concat_desc);

      IF l_length > 4001 THEN
        l_length := -4001;
      ELSE
        l_length := 0;
      END IF;

      -- concatenating the descriptions
      l_concat_desc := SUBSTR(k.CHILD_DESC || '/' || l_concat_desc, l_length, 4001);
      -- incrementing the effective level
      l_eff_level := l_eff_level + 1;

      IF i.CATEGORY_ID = k.CHILD_ID THEN
        l_desc := k.CHILD_DESC;
      ELSIF l_imm_par_id IS NULL THEN
        l_imm_par_id := k.CHILD_ID;
      END IF;
    END LOOP;

    INSERT INTO ENI_DENORM_HRCHY_PARENTS (
      OBJECT_TYPE,
      OBJECT_ID,
      ATTRIBUTE_GROUP_ID,
      CATEGORY_ID,
      LANGUAGE,
      CATEGORY_DESC,
      CONCAT_CAT_PARENTAGE,
      CATEGORY_LEVEL_NUM,
      DISABLE_DATE,
      CATEGORY_PARENT_ID,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      PROGRAM_ID)
    VALUES (
      'CATEGORY_SET',
      g_catset_id,
      l_attr_grp_id,
      i.CATEGORY_ID,
      i.LANGUAGE_CODE,
      l_desc,
      RTRIM(l_concat_desc, '/'),
      l_eff_level,
      i.DISABLE_DATE,
      l_imm_par_id,
      l_user_id,
      SYSDATE,
      l_user_id,
      SYSDATE,
      l_user_id,
      l_conc_request_id,
      l_prog_appl_id,
      SYSDATE,
      l_conc_program_id);

    l_count := l_count + 1;
  END LOOP;

  FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' records inserted into Denorm Hierarchy Parents table.');

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Gathering statistics on table: ENI_DENORM_HRCHY_PARENTS ');
  FND_STATS.gather_table_stats (ownname=>'ENI', tabname=>'ENI_DENORM_HRCHY_PARENTS');

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Initial Load of Denorm Hierarchy Parents table Complete.');
EXCEPTION
   WHEN  NO_DATA_FOUND THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: No Data Found. Transaction will be rolled back');
      errbuf := 'No data found ' || sqlerrm;
      retcode := 2;
      ROLLBACK;
      RAISE;
   WHEN OTHERS THEN
     if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'ENI_DENORM_HRCHY.LOAD_DENORM_PARENTS_PROD_HRCHY', 'Error: ' ||
                                                  sqlerrm || ' .Transaction will be rolled back');
     end if;
      errbuf := 'Error :' || sqlerrm;
      retcode := 2;
      ROLLBACK;
      RAISE;
END LOAD_DENORM_PARENTS_PROD_HRCHY;

-- for sales and marketing enhancement
-- incremental load of denorm hierarchy parents table
-- this procedure is called from the incremental load of denorm table procedure only if
-- sales and marketing is installed
PROCEDURE SYNC_DENORM_PARENTS_PROD_HRCHY(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) IS
  CURSOR C1 IS
    SELECT TL.LANGUAGE_CODE, S.CHILD_ID, S.MODE_FLAG, S.LANGUAGE_CODE STG_LANG
    FROM ENI_DENORM_HRCHY_STG S, FND_LANGUAGES TL
    WHERE S.OBJECT_ID = g_catset_id
      AND S.OBJECT_TYPE = 'CATEGORY_SET'
      AND TL.INSTALLED_FLAG IN ('I', 'B')
      AND S.MODE_FLAG <> 'D'
      AND S.BATCH_FLAG <> 'NEXT_BATCH';

  CURSOR C2(p_child NUMBER) IS
    SELECT D.CATEGORY_ID, B.DISABLE_DATE FROM
      (SELECT C.CATEGORY_ID
       FROM MTL_CATEGORY_SET_VALID_CATS C
       WHERE NOT EXISTS (SELECT NULL FROM EGO_PROD_CAT_SALES_MARKET_AGV A
                         WHERE A.CATEGORY_SET_ID = g_catset_id
                           AND A.CATEGORY_ID = C.CATEGORY_ID
                           AND NVL(A.EXCLUDE_USER_VIEW, 'N') = 'Y')
       START WITH CATEGORY_ID = p_child AND CATEGORY_SET_ID = g_catset_id
       CONNECT BY PARENT_CATEGORY_ID = PRIOR CATEGORY_ID AND CATEGORY_SET_ID = g_catset_id) D, MTL_CATEGORIES_B B
    WHERE B.CATEGORY_ID = D.CATEGORY_ID;

  CURSOR C3(l_child_id NUMBER, l_language VARCHAR2) IS
    SELECT TL.DESCRIPTION CHILD_DESC, C.CATEGORY_ID CHILD_ID
    FROM MTL_CATEGORIES_TL TL,
      (SELECT
        CATEGORY_ID, LEVEL hrchy
       FROM MTL_CATEGORY_SET_VALID_CATS
       START WITH CATEGORY_ID = l_child_id AND CATEGORY_SET_ID = g_catset_id
       CONNECT BY PRIOR PARENT_CATEGORY_ID = CATEGORY_ID AND CATEGORY_SET_ID = g_catset_id) C
    WHERE C.CATEGORY_ID = TL.CATEGORY_ID
      AND TL.LANGUAGE = l_language
      AND NOT EXISTS (SELECT NULL FROM EGO_PROD_CAT_SALES_MARKET_AGV A
                      WHERE A.CATEGORY_SET_ID = g_catset_id
                      AND A.CATEGORY_ID = C.CATEGORY_ID
                      AND NVL(A.EXCLUDE_USER_VIEW, 'N') = 'Y')
      		      ORDER BY hrchy ASC; -- Bug 4749088

  l_concat_desc  VARCHAR2(4001);
  l_desc         VARCHAR2(240);
  l_attr_grp_id  NUMBER;
  l_include_flag VARCHAR2(1);
  l_eff_level    NUMBER;
  l_imm_par_id   NUMBER;
  l_length       NUMBER;
  l_count        NUMBER := 0;

  l_user_id          NUMBER := FND_GLOBAL.USER_ID;
  l_conc_request_id  NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  l_prog_appl_id     NUMBER := FND_GLOBAL.PROG_APPL_ID;
  l_conc_program_id  NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;

BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Incremental Load of Denorm Hierarchy Parents table begining.');

  BEGIN
    SELECT ATTR_GROUP_ID INTO l_attr_grp_id
    FROM EGO_FND_DSC_FLX_CTX_EXT
    WHERE APPLICATION_ID = 431
      AND DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_PRODUCT_CATEGORY_SET'
      AND DESCRIPTIVE_FLEX_CONTEXT_CODE = 'SalesAndMarketing';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: Attribute Group not found for Sales and Marketing');
    RAISE;
  END;

 /* Bug : 5233230
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleting records of all disabled languages from Denorm Hierarchy Parents table');
  -- Deleting all languages, which are being deactivated
  DELETE FROM ENI_DENORM_HRCHY_PARENTS B
  WHERE NOT EXISTS (SELECT NULL FROM FND_LANGUAGES L
                    WHERE L.INSTALLED_FLAG IN ('I', 'B')
                      AND B.LANGUAGE = L.LANGUAGE_CODE);

  l_count := SQL%ROWCOUNT;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' records deleted.');
Bug 5233230 */

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleting all categories which are deleted from hierarchy OR excluded from user view.');
  -- Deleting all deleted nodes
  DELETE FROM ENI_DENORM_HRCHY_PARENTS B
  WHERE B.OBJECT_TYPE = 'CATEGORY_SET'
    AND B.OBJECT_ID = g_catset_id
    AND EXISTS (SELECT NULL FROM ENI_DENORM_HRCHY_STG S
                WHERE S.OBJECT_TYPE = 'CATEGORY_SET'
                  AND S.OBJECT_ID = g_catset_id
                  AND S.CHILD_ID = B.CATEGORY_ID
                  AND S.MODE_FLAG IN ('D', 'S')
                  AND S.BATCH_FLAG <> 'NEXT_BATCH');

  l_count := SQL%ROWCOUNT;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' records deleted.');

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserting/Updating into Denorm Hierarchy Parents table');

  l_count := 0;
  FOR i IN C1 LOOP

    -- description only modified in a particular language so do not update other language records
    IF i.MODE_FLAG = 'C' AND i.LANGUAGE_CODE <> i.STG_LANG THEN
      NULL;
    ELSE
      FOR j IN C2(i.CHILD_ID) LOOP
        l_concat_desc := NULL;
        l_desc := NULL;
        l_eff_level := 0;
        l_imm_par_id := null;
        l_length := 0;

        FOR k IN C3(j.CATEGORY_ID, i.LANGUAGE_CODE) LOOP
          -- to trim from the start of the string onwards to accommodate more descriptions towards the end of the string.
          -- trim upto 4000 chars
          l_length := LENGTH(k.CHILD_DESC || '/' || l_concat_desc);

          IF l_length > 4001 THEN
            l_length := -4001;
          ELSE
            l_length := 0;
          END IF;

          -- concatenating the descriptions
          l_concat_desc := SUBSTR(k.CHILD_DESC || '/' || l_concat_desc, l_length, 4001);
          -- incrementing the effective level
          l_eff_level := l_eff_level + 1;
          IF j.CATEGORY_ID = k.CHILD_ID THEN
            l_desc := k.CHILD_DESC;
          ELSIF l_imm_par_id IS NULL THEN
            l_imm_par_id := k.CHILD_ID;
          END IF;
        END LOOP;

        UPDATE ENI_DENORM_HRCHY_PARENTS B
        SET CATEGORY_DESC = l_desc,
            CONCAT_CAT_PARENTAGE = RTRIM(l_concat_desc, '/'),
            CATEGORY_LEVEL_NUM = l_eff_level,
            DISABLE_DATE = j.DISABLE_DATE,
            CATEGORY_PARENT_ID = l_imm_par_id,
            LAST_UPDATED_BY = l_user_id,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = l_user_id,
            REQUEST_ID = l_conc_request_id,
            PROGRAM_APPLICATION_ID = l_prog_appl_id,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROGRAM_ID = l_conc_program_id
        WHERE OBJECT_TYPE = 'CATEGORY_SET'
          AND OBJECT_ID = g_catset_id
          AND CATEGORY_ID = j.CATEGORY_ID
          AND LANGUAGE = i.LANGUAGE_CODE;

        IF SQL%NOTFOUND THEN
          INSERT INTO ENI_DENORM_HRCHY_PARENTS (
            OBJECT_TYPE,
            OBJECT_ID,
            ATTRIBUTE_GROUP_ID,
            CATEGORY_ID,
            LANGUAGE,
            CATEGORY_DESC,
            CONCAT_CAT_PARENTAGE,
            CATEGORY_LEVEL_NUM,
            DISABLE_DATE,
            CATEGORY_PARENT_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            PROGRAM_ID)
          VALUES (
            'CATEGORY_SET',
            g_catset_id,
            l_attr_grp_id,
            j.CATEGORY_ID,
            i.LANGUAGE_CODE,
            l_desc,
            RTRIM(l_concat_desc, '/'),
            l_eff_level,
            j.DISABLE_DATE,
            l_imm_par_id,
            l_user_id,
            SYSDATE,
            l_user_id,
            SYSDATE,
            l_user_id,
            l_conc_request_id,
            l_prog_appl_id,
            SYSDATE,
            l_conc_program_id);
        END IF;
        l_count := l_count + 1;
      END LOOP;  -- end C2
    END IF;
  END LOOP;  -- end C1

  FND_FILE.PUT_LINE(FND_FILE.LOG, l_count || ' records inserted/updated into Denorm Hierarchy Parents table');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Incremental Load of Denorm Hierarchy Parents table Complete.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    UPDATE ENI_DENORM_HRCHY_STG
    SET BATCH_FLAG = 'NEXT_BATCH'
    WHERE BATCH_FLAG <> 'NEXT_BATCH'
      AND OBJECT_TYPE = 'CATEGORY_SET'
      AND OBJECT_ID = g_catset_id;
    COMMIT;
     if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'ENI_DENORM_HRCHY.SYNC_DENORM_PARENTS_PROD_HRCHY', 'Error: ' ||
                                                sqlerrm || ' .Transaction will be rolled back');
     end if;
    errbuf := 'Error :' || sqlerrm;
    retcode := 2;
    RAISE;
END SYNC_DENORM_PARENTS_PROD_HRCHY;

-- This Procedure Denormalizes the Product Catalog Hierarchy into Denorm Table
-- This is an Initial Load Procedure, so the Denorm Table will be Truncated first.
-- This procedure will be called from LOAD_PRODUCT_HIERARCHY procedure
PROCEDURE LOAD_HIERARCHY(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) IS

  CURSOR c1 IS
    SELECT
      T.PARENT_CATEGORY_ID     PARENT_ID,
      T.CATEGORY_ID            CHILD_ID,
      D.TOP_NODE_FLAG,
      D1.LEAF_NODE_FLAG
    FROM MTL_CATEGORY_SET_VALID_CATS T, ENI_DENORM_HIERARCHIES D, ENI_DENORM_HIERARCHIES D1
    WHERE T.CATEGORY_SET_ID = g_catset_id
      AND T.PARENT_CATEGORY_ID IS NOT NULL
      AND D.OBJECT_TYPE = 'CATEGORY_SET'
      AND D.OBJECT_ID = g_catset_id
      AND D.PARENT_ID = T.PARENT_CATEGORY_ID
      AND D.CHILD_ID = T.PARENT_CATEGORY_ID
      AND D1.OBJECT_TYPE = 'CATEGORY_SET'
      AND D1.OBJECT_ID = g_catset_id
      AND D1.PARENT_ID = T.CATEGORY_ID
      AND D1.CHILD_ID = T.CATEGORY_ID;


  l_count NUMBER := 0;
  l_dbi_installed    VARCHAR2(1) := IS_DBI_INSTALLED;  -- variable to hold installation flag for DBI
  l_user_id          NUMBER := FND_GLOBAL.USER_ID;
  l_conc_request_id  NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  l_prog_appl_id     NUMBER := FND_GLOBAL.PROG_APPL_ID;
  l_conc_program_id  NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
  l_hrchy_enabled    VARCHAR2(1);
  l_sql              VARCHAR2(32000);
  l_validate_flag    VARCHAR2(1);  -- Bug# 3306212
  l_struct_id        NUMBER;  -- Bug# 3306212

BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Denorm table Initial Load Start');

  -- Finding whether Hierarchy is enabled or not
  BEGIN  -- Bug# 3013192, Bug# 3306212
    SELECT HIERARCHY_ENABLED, VALIDATE_FLAG, STRUCTURE_ID INTO l_hrchy_enabled, l_validate_flag, l_struct_id
    FROM MTL_CATEGORY_SETS_B
    WHERE CATEGORY_SET_ID = g_catset_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Category Set associated with Product Reporting functional area');
    RAISE;
  END;

  -- Deleting records from Denorm Table for object_type = CATEGORY_SET
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Deleting Records from Denorm Table for Product Catalog');

  DELETE FROM ENI_DENORM_HIERARCHIES
  WHERE OBJECT_TYPE = 'CATEGORY_SET';

  -- Bug# 3047381, moved delete of staging table from last to begining. So that any changes in hierarchy, during Load is running
  -- will be captured in next incremental load.
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleting records from Staging table');
  -- deleting records from staging table, since all the changes are already there in Denorm table
  DELETE FROM ENI_DENORM_HRCHY_STG
  WHERE OBJECT_TYPE = 'CATEGORY_SET'
    AND OBJECT_ID = g_catset_id;

  l_count := SQL%ROWCOUNT;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' records deleted from Staging table');

  -- Inserting Self-referencing Nodes
  IF (NVL(l_validate_flag, 'N') = 'N' AND NVL(l_hrchy_enabled, 'N') = 'N') THEN
    -- Inserting Self-referencing Nodes from mtl_categories
    -- since enforce list of valid categories is not true and
    -- hierarchy is not enabled
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Inserting Self Referencing Nodes');

    INSERT INTO ENI_DENORM_HIERARCHIES(
      PARENT_ID,
      IMM_CHILD_ID,
      CHILD_ID,
      OBJECT_TYPE,
      OBJECT_ID,
      TOP_NODE_FLAG,
      LEAF_NODE_FLAG,
      ITEM_ASSGN_FLAG,
      DBI_FLAG,
      OLTP_FLAG,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      PROGRAM_ID)
    SELECT
      CATEGORY_ID,
      CATEGORY_ID,
      CATEGORY_ID,
      'CATEGORY_SET',
      g_catset_id,
      'Y' TOP_NODE_FLAG,
      'Y' LEAF_NODE_FLAG,
      'N' ITEM_ASSGN_FLAG,
      'Y' DBI_FLAG,
      'Y' OLTP_FLAG,
      l_user_id,
      SYSDATE,
      l_user_id,
      SYSDATE,
      l_user_id,
      l_conc_request_id,
      l_prog_appl_id,
      SYSDATE,
      l_conc_program_id
    FROM MTL_CATEGORIES_B
    WHERE STRUCTURE_ID = l_struct_id;
  ELSE
    -- Inserting Self-referencing Nodes
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Inserting Self Referencing Nodes');
    -- Using execute immediate to set ITEM_ASSGN_FLAG and LEAF_NODE_FLAG
    -- the same insert statement doesn't works without execute immediate
    l_sql :=
    'INSERT INTO ENI_DENORM_HIERARCHIES(
      PARENT_ID,
      IMM_CHILD_ID,
      CHILD_ID,
      OBJECT_TYPE,
      OBJECT_ID,
      TOP_NODE_FLAG,
      LEAF_NODE_FLAG,
      ITEM_ASSGN_FLAG,
      DBI_FLAG,
      OLTP_FLAG,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      PROGRAM_ID)
    SELECT
      T.CATEGORY_ID,
      T.CATEGORY_ID,
      T.CATEGORY_ID,
      ''CATEGORY_SET'',
      :g_catset_id,
      DECODE(:l_hrchy_enabled, ''Y'', DECODE(T.PARENT_CATEGORY_ID, NULL, ''Y'', ''N''), ''Y''),
      NVL((SELECT ''N'' FROM MTL_CATEGORY_SET_VALID_CATS X
           WHERE X.CATEGORY_SET_ID = T.CATEGORY_SET_ID
             AND X.PARENT_CATEGORY_ID = T.CATEGORY_ID
            AND ROWNUM = 1), ''Y'') LEAF_NODE_FLAG,
      ''N'',
      ''Y'',
      ''Y'',
      :l_user_id,
      SYSDATE,
      :l_user_id,
      SYSDATE,
      :l_user_id,
      :l_conc_request_id,
      :l_prog_appl_id,
      SYSDATE,
      :l_conc_program_id
    FROM MTL_CATEGORY_SET_VALID_CATS T
    WHERE T.CATEGORY_SET_ID = :g_catset_id';

    EXECUTE IMMEDIATE l_sql USING g_catset_id, l_hrchy_enabled, l_user_id, l_user_id, l_user_id
      , l_conc_request_id, l_prog_appl_id, l_conc_program_id, g_catset_id;

  END IF;

  l_count := SQL%ROWCOUNT;
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Inserted '||l_count||' Self-referencing records');

  IF NVL(l_hrchy_enabled, 'N') = 'Y' THEN  -- Bug# 3013192
    l_count := 0;
    -- For Inserting Parent, Immchild, Child Relationships
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Hierarchy is enabled'); -- Bug# 3013192
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Inserting Hierarchical records');

    FOR i in c1 LOOP
      INSERT INTO ENI_DENORM_HIERARCHIES (
        PARENT_ID,
        IMM_CHILD_ID,
        CHILD_ID,
        OBJECT_TYPE,
        OBJECT_ID,
        TOP_NODE_FLAG,
        LEAF_NODE_FLAG,
        ITEM_ASSGN_FLAG,
        DBI_FLAG,
        OLTP_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_UPDATE_DATE,
        PROGRAM_ID)
      SELECT
        i.PARENT_ID,
        i.CHILD_ID,
        A.CATEGORY_ID,
        'CATEGORY_SET',
        g_catset_id,
        i.TOP_NODE_FLAG,
        i.LEAF_NODE_FLAG,
        'N',
        'Y',
        'Y',
        l_user_id,
        SYSDATE,
        l_user_id,
        SYSDATE,
        l_user_id,
        l_conc_request_id,
        l_prog_appl_id,
        SYSDATE,
        l_conc_program_id
      FROM MTL_CATEGORY_SET_VALID_CATS A
      START WITH A.CATEGORY_ID = i.CHILD_ID AND A.CATEGORY_SET_ID = g_catset_id
      CONNECT BY A.PARENT_CATEGORY_ID = PRIOR A.CATEGORY_ID AND A.CATEGORY_SET_ID = g_catset_id;

      l_count := l_count + SQL%ROWCOUNT;
    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserted '||l_count||' Hierarchical records');
  END IF;

--  IF l_dbi_installed = 'Y' THEN -- ER# 3185516, updating Item Assignment Flag even in non-DBI env.
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updating Item Assignment Flag');
  -- updating Item Assignment flag for all categories, which have items attached to it
  UPDATE ENI_DENORM_HIERARCHIES B
  SET ITEM_ASSGN_FLAG = 'Y'
  WHERE B.OBJECT_TYPE = 'CATEGORY_SET'
    AND B.OBJECT_ID = g_catset_id
    AND EXISTS (SELECT NULL
                FROM MTL_ITEM_CATEGORIES C
                WHERE C.CATEGORY_SET_ID = g_catset_id
                  AND C.CATEGORY_ID = B.CHILD_ID);

  l_count := SQL%ROWCOUNT;

  FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' Records Updated for Item Assignment Flag');

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Checking Item Assignments for Unassigned');
  -- Checking Item assignment flag for Unassigned category
  -- if all items are attached to some categories within this category set then
  -- Item assignment flag for Unassigned node will be 'N'
  BEGIN
    SELECT 1 INTO l_count
    FROM MTL_SYSTEM_ITEMS_B IT
    WHERE ROWNUM = 1
      AND NOT EXISTS (SELECT NULL FROM MTL_ITEM_CATEGORIES C
                      WHERE C.CATEGORY_SET_ID = g_catset_id
                        AND C.INVENTORY_ITEM_ID = IT.INVENTORY_ITEM_ID
                        AND C.ORGANIZATION_ID = IT.ORGANIZATION_ID);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'All Items are assigned to Product Catalog');
    l_count := 0;
  END;
/* ER# 3185516, updating Item Assignment Flag even in non-DBI env.
  ELSE
    l_count := 0;
  END IF;
*/

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserting Unassigned Node');
  INSERT INTO ENI_DENORM_HIERARCHIES (
    PARENT_ID,
    IMM_CHILD_ID,
    CHILD_ID,
    OBJECT_TYPE,
    OBJECT_ID,
    TOP_NODE_FLAG,
    LEAF_NODE_FLAG,
    ITEM_ASSGN_FLAG,
    DBI_FLAG,
    OLTP_FLAG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    PROGRAM_ID)
  VALUES(
    -1,
    -1,
    -1,
    'CATEGORY_SET',
    g_catset_id,
    'Y',
    'Y',
    DECODE(l_count, 1, 'Y', 'N'),
    'Y',
    'N',
    l_user_id,
    SYSDATE,
    l_user_id,
    SYSDATE,
    l_user_id,
    l_conc_request_id,
    l_prog_appl_id,
    SYSDATE,
    l_conc_program_id);

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Gathering statistics on table: ENI_DENORM_HIERARCHIES ');
  FND_STATS.gather_table_stats (ownname=>'ENI', tabname=>'ENI_DENORM_HIERARCHIES');

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Denorm table Initial Load completed successfully');
EXCEPTION
  WHEN  NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: No Data Found. Transaction will be rolled back');
    errbuf := 'No data found ' || sqlerrm;
    retcode := 2;
    ROLLBACK;
    RAISE;
  WHEN OTHERS THEN
     if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'ENI_DENORM_HRCHY.LOAD_HIERARCHY', 'Error: ' ||
                                                sqlerrm || ' .Transaction will be rolled back');
     end if;
    errbuf := 'Error :' || sqlerrm;
    retcode := 2;
    ROLLBACK;
    RAISE;
END LOAD_HIERARCHY;

-- This Procedure Updates The Denorm Table In Incremental Mode, Wrt To Changes Made In Product Catalog Hierarchy
-- This Procedure picks up records to be added/modified from Staging table
PROCEDURE SYNC_HIERARCHY(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) IS

  CURSOR top_nodes IS
  SELECT DISTINCT TOP_NODE_ID
  FROM ENI_DENORM_HRCHY_STG
  WHERE BATCH_FLAG <> 'NEXT_BATCH'
    AND OBJECT_TYPE = 'CATEGORY_SET'
    AND OBJECT_ID = g_catset_id
    AND MODE_FLAG IN ('A', 'M');  -- modified for sales and marketing enhancement

  l_affected_child   NUMBER;
  l_affected_level   NUMBER;
  l_count            NUMBER := 0;
  l_dbi_installed    VARCHAR2(1) := IS_DBI_INSTALLED;  -- variable to hold installation flag for DBI
  l_user_id          NUMBER := FND_GLOBAL.USER_ID;
  l_conc_request_id  NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  l_prog_appl_id     NUMBER := FND_GLOBAL.PROG_APPL_ID;
  l_conc_program_id  NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
  l_sql              VARCHAR2(32000);
  l_validate_flag    VARCHAR2(1);  -- Bug# 3306212
  l_struct_id        NUMBER;  -- Bug# 3306212

BEGIN
  BEGIN -- Bug# 3306212
    SELECT VALIDATE_FLAG, STRUCTURE_ID INTO l_validate_flag, l_struct_id
    FROM MTL_CATEGORY_SETS_B
    WHERE CATEGORY_SET_ID = g_catset_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Category Set associated with Product Reporting functional area');
    RAISE;
  END;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Denorm table Incremental Load begining');

  IF NVL(l_validate_flag, 'N') = 'N' THEN -- Bug# 3306212
    INSERT INTO ENI_DENORM_HIERARCHIES(
      PARENT_ID,
      IMM_CHILD_ID,
      CHILD_ID,
      OBJECT_TYPE,
      OBJECT_ID,
      TOP_NODE_FLAG,
      LEAF_NODE_FLAG,
      ITEM_ASSGN_FLAG,
      DBI_FLAG,
      OLTP_FLAG,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      PROGRAM_ID)
    SELECT
      B.CATEGORY_ID,
      B.CATEGORY_ID,
      B.CATEGORY_ID,
      'CATEGORY_SET',
      g_catset_id,
      'Y' TOP_NODE_FLAG,
      'Y' LEAF_NODE_FLAG,
      'N' ITEM_ASSGN_FLAG,
      'Y' DBI_FLAG,
      'Y' OLTP_FLAG,
      l_user_id,
      SYSDATE,
      l_user_id,
      SYSDATE,
      l_user_id,
      l_conc_request_id,
      l_prog_appl_id,
      SYSDATE,
      l_conc_program_id
    FROM MTL_CATEGORIES_B B
    WHERE B.STRUCTURE_ID = l_struct_id
      AND NOT EXISTS (SELECT NULL FROM ENI_DENORM_HIERARCHIES H
                      WHERE H.OBJECT_TYPE = 'CATEGORY_SET'
                        AND H.OBJECT_ID = g_catset_id
                        AND H.PARENT_ID = B.CATEGORY_ID
                        AND H.CHILD_ID = B.CATEGORY_ID);
  ELSE -- Bug# 3306212 end
    -- To Get The Top Node And Child Level In Temp Table
    UPDATE ENI_DENORM_HRCHY_STG T
    SET (TOP_NODE_ID, CHILD_LEVEL)=
                (SELECT X.CATEGORY_ID, LEVEL
                 FROM MTL_CATEGORY_SET_VALID_CATS X
                 WHERE X.PARENT_CATEGORY_ID IS NULL
                 START WITH X.CATEGORY_ID = T.CHILD_ID AND X.CATEGORY_SET_ID = g_catset_id
                 CONNECT BY X.CATEGORY_ID = PRIOR X.PARENT_CATEGORY_ID AND X.CATEGORY_SET_ID = g_catset_id),
      BATCH_FLAG = 'CURRENT_BATCH'
    WHERE OBJECT_TYPE = 'CATEGORY_SET'
      AND T.OBJECT_ID = g_catset_id;

    l_count := SQL%ROWCOUNT;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' Records found in Staging Table for Incremental Load');

    -- commiting to release Lock on ENI_DENORM_HRCHY_STG table. If any exception occurs then
    -- batch_flag will be updated back to 'NEXT_BATCH' and commited.
    COMMIT;

    -- Deleting Nodes from Denorm Table, which are deleted i.e. MODE_FLAG='D'
    -- If a parent node is deleted from hierarchy, then all its children are also deleted from hierarchy
    -- and all the nodes actually deleted from hierarchy will be inserted into the staging table with
    -- mode_flag = 'D'. So we need to delete all records from denorm table, where child_id = child_id in staging table
    -- and mode_flag = 'D'
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleting Nodes from Denorm Table, which are deleted from Hierarchy');

    -- Bug# 3047381 , removed use of ROWID , instead using PK columns
    DELETE FROM ENI_DENORM_HIERARCHIES B  -- changed the statement due to performance reasons
    WHERE OBJECT_TYPE = 'CATEGORY_SET'
      AND OBJECT_ID = g_catset_id
      AND EXISTS (SELECT NULL
                  FROM ENI_DENORM_HRCHY_STG S
                  WHERE S.OBJECT_TYPE = B.OBJECT_TYPE
                    AND S.OBJECT_ID = B.OBJECT_ID
                    AND S.CHILD_ID = B.CHILD_ID
                    AND S.MODE_FLAG = 'D'
                    AND S.BATCH_FLAG = 'CURRENT_BATCH');

    l_count := SQL%ROWCOUNT;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' Records deleted from denorm table');

    -- Inserting Self Referencing Nodes For New Nodes Into Denorm Table
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserting Self-referencing nodes for new nodes');
    INSERT INTO ENI_DENORM_HIERARCHIES(
      PARENT_ID,
      IMM_CHILD_ID,
      CHILD_ID,
      OBJECT_TYPE,
      OBJECT_ID,
      TOP_NODE_FLAG,
      LEAF_NODE_FLAG,
      ITEM_ASSGN_FLAG,
      DBI_FLAG,
      OLTP_FLAG,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      PROGRAM_ID)
    SELECT
      S.CHILD_ID,
      CHILD_ID,
      CHILD_ID,
      'CATEGORY_SET',
      g_catset_id,
      DECODE(CHILD_ID, TOP_NODE_ID, 'Y', 'N'), -- Bug# 3047381, removed use of SIGN function
      'N',
      'N',
      'Y',
      'Y',
      l_user_id,
      SYSDATE,
      l_user_id,
      SYSDATE,
      l_user_id,
      l_conc_request_id,
      l_prog_appl_id,
      SYSDATE,
      l_conc_program_id
    FROM ENI_DENORM_HRCHY_STG S
    WHERE S.OBJECT_TYPE = 'CATEGORY_SET'
      AND S.OBJECT_ID = g_catset_id
      AND S.MODE_FLAG = 'A'
      AND S.BATCH_FLAG = 'CURRENT_BATCH';

    l_count := SQL%ROWCOUNT;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' Records inserted as Self-referencing nodes');

    l_count := 0;
    -- Deleting all rows, which will no longer be a part of Hierarchy
    -- whenever a node is moved i.e. MODE_FLAG='M', there will be some records in denorm table
    -- which needs to be deleted, as they will no longer will be a part of the hierarhcy
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleting records, which are no longer required, due to movement in Hierarchy');
    FOR i IN (SELECT * FROM ENI_DENORM_HRCHY_STG
              WHERE OBJECT_TYPE = 'CATEGORY_SET'
                AND OBJECT_ID = g_catset_id
                AND MODE_FLAG = 'M'
                AND BATCH_FLAG = 'CURRENT_BATCH'
                ORDER BY CHILD_LEVEL DESC) LOOP  -- Bug# 3047381, removed TOP_NODE_ID ASC from order by clause

      DELETE FROM ENI_DENORM_HIERARCHIES B
      WHERE B.OBJECT_TYPE = 'CATEGORY_SET'
        AND B.OBJECT_ID = g_catset_id
        AND EXISTS (SELECT NULL FROM ENI_DENORM_HIERARCHIES T  -- all records with child = i.child_id or children of i.child_id
                    WHERE T.OBJECT_TYPE = B.OBJECT_TYPE
                      AND T.OBJECT_ID = B.OBJECT_ID
                      AND B.CHILD_ID = T.CHILD_ID
                      AND T.PARENT_ID = i.CHILD_ID)
        AND NOT EXISTS (SELECT NULL FROM ENI_DENORM_HIERARCHIES D  -- Hierarchy below the i.child_id must not be deleted
                      WHERE D.OBJECT_TYPE = B.OBJECT_TYPE
                          AND D.OBJECT_ID = B.OBJECT_ID
                          AND B.PARENT_ID = D.CHILD_ID
                        AND D.PARENT_ID = i.CHILD_ID)
        AND NOT EXISTS (-- Find New Parents, All Records Which Are A Part Of New Hierarchy
                        SELECT NULL
                        FROM MTL_CATEGORY_SET_VALID_CATS C
                        WHERE C.PARENT_CATEGORY_ID IS NOT NULL
                          AND C.PARENT_CATEGORY_ID = B.PARENT_ID
                          AND C.CATEGORY_ID = B.IMM_CHILD_ID
                        START WITH C.CATEGORY_ID = i.PARENT_ID AND C.CATEGORY_SET_ID = g_catset_id
                        CONNECT BY C.CATEGORY_ID = PRIOR C.PARENT_CATEGORY_ID AND C.CATEGORY_SET_ID = g_catset_id);

      l_count := l_count + SQL%ROWCOUNT;
    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' Records deleted');

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserting new relations');
    l_count := 0;
    -- Creating Records For Changes In The Hierarchy
    FOR i IN top_nodes LOOP
      LOOP
        -- selecting lowest level child first
        BEGIN
          SELECT CHILD_ID , CHILD_LEVEL
            INTO l_affected_child , l_affected_level
          FROM
            (SELECT CHILD_ID, CHILD_LEVEL
             FROM ENI_DENORM_HRCHY_STG T
             WHERE OBJECT_TYPE = 'CATEGORY_SET'
               AND OBJECT_ID = g_catset_id
               AND TOP_NODE_ID = i.TOP_NODE_ID
               AND BATCH_FLAG = 'CURRENT_BATCH'
               AND MODE_FLAG IN ('A', 'M')  -- modified for sales and marketing enhancement
             ORDER BY CHILD_LEVEL DESC)
          WHERE ROWNUM=1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          l_affected_child := NULL;
          l_affected_level := NULL;
          EXIT;
        END;

        -- Inserting records due to change in hierarchy
        INSERT INTO ENI_DENORM_HIERARCHIES (
          PARENT_ID,
          IMM_CHILD_ID,
          CHILD_ID,
          OBJECT_TYPE,
          OBJECT_ID,
          TOP_NODE_FLAG,
          LEAF_NODE_FLAG,
          ITEM_ASSGN_FLAG,
          DBI_FLAG,
          OLTP_FLAG,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_UPDATE_DATE,
          PROGRAM_ID)
        SELECT
          A.PARENT_ID,
          A.IMM_CHILD_ID,
          B.CHILD_ID,
          'CATEGORY_SET',
          g_catset_id,
          DECODE(A.PARENT_ID, i.TOP_NODE_ID, 'Y', 'N'), -- Bug# 3047381, removed use of SIGN function
          'N',
          'N',
          'Y',
          'Y',
          l_user_id,
          SYSDATE,
          l_user_id,
          SYSDATE,
          l_user_id,
          l_conc_request_id,
          l_prog_appl_id,
          SYSDATE,
          l_conc_program_id
        FROM
          (SELECT PARENT_CATEGORY_ID PARENT_ID, CATEGORY_ID IMM_CHILD_ID
           FROM MTL_CATEGORY_SET_VALID_CATS
           WHERE PARENT_CATEGORY_ID IS NOT NULL
           START WITH CATEGORY_ID = l_affected_child AND CATEGORY_SET_ID = g_catset_id
           CONNECT BY CATEGORY_ID = PRIOR PARENT_CATEGORY_ID AND CATEGORY_SET_ID = g_catset_id) A,
          (SELECT CATEGORY_ID CHILD_ID
           FROM MTL_CATEGORY_SET_VALID_CATS A
           START WITH CATEGORY_ID = l_affected_child AND A.CATEGORY_SET_ID = g_catset_id
           CONNECT BY PARENT_CATEGORY_ID = PRIOR CATEGORY_ID AND A.CATEGORY_SET_ID = g_catset_id) B
        WHERE NOT EXISTS (SELECT NULL FROM ENI_DENORM_HIERARCHIES P
                          WHERE P.OBJECT_TYPE = 'CATEGORY_SET'
                            AND P.OBJECT_ID = g_catset_id
                            AND P.PARENT_ID = A.PARENT_ID
                            AND P.IMM_CHILD_ID = A.IMM_CHILD_ID
                            AND P.CHILD_ID = B.CHILD_ID);

        l_count := l_count + SQL%ROWCOUNT;

        -- Updating STG Table, making current child as PROCESSED, so that it will not be picked up again
        UPDATE ENI_DENORM_HRCHY_STG SET BATCH_FLAG = 'PROCESSED'
        WHERE OBJECT_TYPE = 'CATEGORY_SET'
          AND OBJECT_ID = g_catset_id
          AND CHILD_ID = l_affected_child
          AND BATCH_FLAG = 'CURRENT_BATCH';

      END LOOP;
    END LOOP;  -- End Loop For Top Nodes

    FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' Records inserted');

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updating Leaf Node Flag');
    -- updating leaf node flag for all records where new leaf_node_flag <> current leaf_node_flag
    -- Using Execute Immediate because the same code doesn't compiles without Execute immediate
    -- Bug# 3045649, added WHO columns in update statements
    l_sql :=
    'UPDATE ENI_DENORM_HIERARCHIES B
    SET LEAF_NODE_FLAG = DECODE(B.LEAF_NODE_FLAG, ''N'', ''Y'', ''N'') ,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = :l_user_id,
        LAST_UPDATE_LOGIN = :l_user_id,
        REQUEST_ID = :l_conc_request_id,
        PROGRAM_APPLICATION_ID = :l_prog_appl_id,
        PROGRAM_UPDATE_DATE = SYSDATE,
        PROGRAM_ID = :l_conc_program_id
    WHERE B.OBJECT_TYPE = ''CATEGORY_SET''
      AND B.OBJECT_ID = :g_catset_id
      AND B.CHILD_ID <> -1
      AND B.LEAF_NODE_FLAG <> NVL((SELECT ''N''
                                   FROM MTL_CATEGORY_SET_VALID_CATS C
                                   WHERE C.CATEGORY_SET_ID = :g_catset_id
                                     AND B.IMM_CHILD_ID = C.PARENT_CATEGORY_ID
                                     AND ROWNUM = 1), ''Y'')';

    EXECUTE IMMEDIATE l_sql USING l_user_id, l_user_id, l_conc_request_id, l_prog_appl_id, l_conc_program_id, g_catset_id, g_catset_id;

    l_count := SQL%ROWCOUNT;

    FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' Records Updated for Leaf Node Flag');

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updating Top Node Flag');
    -- updating top node flag for all records where new top_node_flag <> current top_node_flag
    -- using a inline view to improve the performance
    -- Bug# 3045649, added WHO columns in update statements
    UPDATE (
            SELECT B.PARENT_ID, DECODE(C.PARENT_CATEGORY_ID, NULL, 'Y', 'N') NEW_TOP_NODE, B.TOP_NODE_FLAG,
              B.LAST_UPDATE_DATE, B.LAST_UPDATED_BY, B.LAST_UPDATE_LOGIN, B.REQUEST_ID, B.PROGRAM_APPLICATION_ID,
              B.PROGRAM_UPDATE_DATE, B.PROGRAM_ID
            FROM ENI_DENORM_HIERARCHIES B, MTL_CATEGORY_SET_VALID_CATS C
            WHERE B.OBJECT_TYPE = 'CATEGORY_SET'
              AND B.OBJECT_ID = g_catset_id
              AND C.CATEGORY_SET_ID = B.OBJECT_ID
              AND C.CATEGORY_ID = B.PARENT_ID)
      SET
        TOP_NODE_FLAG = DECODE(TOP_NODE_FLAG, 'N', 'Y', 'N'),
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = l_user_id,
        LAST_UPDATE_LOGIN = l_user_id,
        REQUEST_ID = l_conc_request_id,
        PROGRAM_APPLICATION_ID = l_prog_appl_id,
        PROGRAM_UPDATE_DATE = SYSDATE,
        PROGRAM_ID = l_conc_program_id
    WHERE NEW_TOP_NODE <> TOP_NODE_FLAG;

    l_count := SQL%ROWCOUNT;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' Records Updated for Top Node Flag');
  END IF; -- Bug# 3306212

--  IF l_dbi_installed = 'Y' THEN -- ER# 3185516, updating Item Assignment Flag even in non-DBI env.
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updating Item Assignment Flag');
  -- updating Item Assignment flag to 'Y', if item assignment is present and current Item assgn flag is not 'Y'
  -- Bug# 3045649, added WHO columns in update statements
  UPDATE ENI_DENORM_HIERARCHIES B
  SET
    ITEM_ASSGN_FLAG = 'Y',
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = l_user_id,
    LAST_UPDATE_LOGIN = l_user_id,
    REQUEST_ID = l_conc_request_id,
    PROGRAM_APPLICATION_ID = l_prog_appl_id,
    PROGRAM_UPDATE_DATE = SYSDATE,
    PROGRAM_ID = l_conc_program_id
  WHERE B.OBJECT_TYPE = 'CATEGORY_SET'
    AND B.OBJECT_ID = g_catset_id
    AND B.CHILD_ID <> -1
    AND B.ITEM_ASSGN_FLAG <> 'Y'
    AND EXISTS (SELECT NULL
                FROM MTL_ITEM_CATEGORIES C
                WHERE C.CATEGORY_SET_ID = g_catset_id
                  AND C.CATEGORY_ID = B.CHILD_ID);

  l_count := SQL%ROWCOUNT;

  -- updating Item Assignment flag to 'N', if item assignment is not present and current Item assgn flag is not 'N'
  UPDATE ENI_DENORM_HIERARCHIES B
  SET
    ITEM_ASSGN_FLAG = 'N',
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = l_user_id,
    LAST_UPDATE_LOGIN = l_user_id,
    REQUEST_ID = l_conc_request_id,
    PROGRAM_APPLICATION_ID = l_prog_appl_id,
    PROGRAM_UPDATE_DATE = SYSDATE,
    PROGRAM_ID = l_conc_program_id
  WHERE B.OBJECT_TYPE = 'CATEGORY_SET'
    AND B.OBJECT_ID = g_catset_id
    AND B.CHILD_ID <> -1
    AND B.ITEM_ASSGN_FLAG <> 'N'
    AND NOT EXISTS (SELECT NULL
                    FROM MTL_ITEM_CATEGORIES C
                    WHERE C.CATEGORY_SET_ID = g_catset_id
                      AND C.CATEGORY_ID = B.CHILD_ID);

  l_count := l_count + SQL%ROWCOUNT;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_count||' Records Updated for Item Assignment Flag');
--  END IF; -- ER# 3185516, updating Item Assignment Flag even in non-DBI env.

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Incremental Load of Denorm table complete');
EXCEPTION
  WHEN OTHERS THEN
     if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'ENI_DENORM_HRCHY.SYNC_HIERARCHY', 'Error: ' ||
                                                sqlerrm || ' .Transaction will be rolled back');
     end if;
    errbuf := 'Error :' || sqlerrm;
    retcode := 2;
    ROLLBACK;
    -- if any error occurs, then updating staging table's batch_flag back to 'NEXT_BATCH'
    -- so that it can be picked up in next incremental load.
    UPDATE ENI_DENORM_HRCHY_STG
    SET BATCH_FLAG = 'NEXT_BATCH'
    WHERE BATCH_FLAG <> 'NEXT_BATCH'
      AND OBJECT_TYPE = 'CATEGORY_SET'
      AND OBJECT_ID = g_catset_id;
    COMMIT;
    RAISE;
END SYNC_HIERARCHY;

-- This Procedure Denormalizes the Product Catalog Hierarchy into Denorm Table
-- This will accept the parameter as 'FULL' or 'PARTIAL', depending on which, Initial or
-- Incremental Load will be called
PROCEDURE LOAD_PRODUCT_HIERARCHY(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, p_refresh_mode IN VARCHAR2) IS
  err VARCHAR2(2000);
  ret VARCHAR2(100);
  l_cnt NUMBER; -- Bug# 3057568
  l_AS_installed  BOOLEAN := FALSE; -- for Oracle Sales
  l_AMS_installed BOOLEAN := FALSE; -- for Oracle Marketing Online
  l_OZF_installed BOOLEAN := FALSE; -- for Oracle Trade Management
  l_ASN_installed BOOLEAN := FALSE; --Bug 4728981
  l_installed     BOOLEAN := FALSE;
  l_status        VARCHAR2(1) := 'N';
  l_industry      VARCHAR2(1) := NULL;

BEGIN
  -- checking installation of 'AS' (Oracle Sales) , 'AMS' (Oracle Marketing Online), 'OZF' (Oracle Trade Management)
  -- AS - 279
  -- AMS - 530
  -- OZF - 682

  -- checking installation of 'AS' (Oracle Sales)
  l_status := NULL;
  l_installed := fnd_installation.get(appl_id => 279, dep_appl_id => 279, status => l_status, industry => l_industry );
  IF NVL(l_status, 'N') = 'I' THEN
    l_AS_installed := TRUE;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Oracle Sales (AS) is installed.');
  END IF;

  -- checking installation of 'AMS' (Oracle Marketing Online)
  l_status := NULL;
  l_installed := fnd_installation.get(appl_id => 530, dep_appl_id => 530, status => l_status, industry => l_industry );
  IF NVL(l_status, 'N') = 'I' THEN
    l_AMS_installed := TRUE;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Oracle Marketing Online (AMS) is installed.');
  END IF;

  -- checking installation of 'OZF' (Oracle Trade Management)
  l_status := NULL;
  l_installed := fnd_installation.get(appl_id => 682, dep_appl_id => 682, status => l_status, industry => l_industry );
  IF NVL(l_status, 'N') = 'I' THEN
    l_OZF_installed := TRUE;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Oracle Trade Management (OZF) is installed.');
  END IF;

  -- checking installation of 'ASN'
  l_status := NULL;
  l_installed := fnd_installation.get(appl_id => 280, dep_appl_id => 280, status => l_status, industry => l_industry );
  IF NVL(l_status, 'N') = 'I' THEN
    l_ASN_installed := TRUE;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ASN is installed.');
  END IF;

  -- if any of the above applications are installed then load de-norm parents table
  IF l_AS_installed OR l_AMS_installed OR l_OZF_installed OR l_ASN_installed THEN
    l_installed := TRUE;
  ELSE
    l_installed := FALSE;
  END IF;

  IF p_refresh_mode = 'FULL' THEN
    LOAD_HIERARCHY(err, ret);
    errbuf := err;
    retcode := ret;

    -- if sales and marketing is installed then call loading of denorm hierarchy parents table
    IF NVL(retcode, 0) <> 2 AND l_installed THEN
      err := null;
      ret := null;

      LOAD_DENORM_PARENTS_PROD_HRCHY(err, ret);
      errbuf := err;
      retcode := ret;
    END IF;

  ELSIF p_refresh_mode = 'PARTIAL' THEN
    BEGIN  -- Bug# 3057568 Start
      -- Checking if De-norm table is empty then calling Initial Load, else Incr. Load
      SELECT 1 INTO l_cnt
      FROM ENI_DENORM_HIERARCHIES
      WHERE OBJECT_TYPE = 'CATEGORY_SET'
        AND ROWNUM = 1;

      SYNC_HIERARCHY(err, ret);
      errbuf := err;
      retcode := ret;

      -- if sales and marketing is installed then call loading of denorm hierarchy parents table
      IF NVL(retcode, 0) <> 2 AND l_installed THEN
        err := null;
        ret := null;
        -- if de-norm parents table is empty then call full load of only de-norm parents table
        BEGIN
          SELECT 1 INTO l_cnt
          FROM ENI_DENORM_HRCHY_PARENTS
          WHERE OBJECT_TYPE = 'CATEGORY_SET'
            AND ROWNUM = 1;

          SYNC_DENORM_PARENTS_PROD_HRCHY(err, ret);
          errbuf := err;
          retcode := ret;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'De-norm parents table is empty, calling Initial Load for de-norm parents table...');
          LOAD_DENORM_PARENTS_PROD_HRCHY(err, ret);
          errbuf := err;
          retcode := ret;
        END;
      END IF;

      -- deleting all nodes from staging table, where batch_flag is not 'NEXT_BATCH', since the batch_flag can be
      -- CURRENT_BATCH or PROCESSED
      DELETE FROM ENI_DENORM_HRCHY_STG
      WHERE BATCH_FLAG <> 'NEXT_BATCH'
        AND OBJECT_TYPE = 'CATEGORY_SET'
        AND OBJECT_ID = g_catset_id;

    EXCEPTION WHEN NO_DATA_FOUND THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'De-norm table is empty, calling Initial Load...');
      LOAD_HIERARCHY(err, ret);
      errbuf := err;
      retcode := ret;

      -- if sales and marketing is installed then call loading of denorm hierarchy parents table
      IF NVL(retcode, 0) <> 2 AND l_installed THEN
        err := null;
        ret := null;

        LOAD_DENORM_PARENTS_PROD_HRCHY(err, ret);
        errbuf := err;
        retcode := ret;
      END IF;
    END; -- Bug# 3057568 end
  END IF;

  -- synchronizing intermedia index
  BEGIN
    AD_CTX_DDL.SYNC_INDEX(g_tab_schema || '.ENI_DEN_HRCHY_PAR_IM1');
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
EXCEPTION
  WHEN OTHERS THEN
     if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'ENI_DENORM_HRCHY.LOAD_PRODUCT_HIERARCHY', 'Error: ' ||
                                                sqlerrm || ' .Transaction will be rolled back');
     end if;
    errbuf := 'Error :' || sqlerrm;
    retcode := 2;
    ROLLBACK;
    -- synchronizing intermedia index even if error occurs
    BEGIN
      AD_CTX_DDL.SYNC_INDEX(g_tab_schema || '.ENI_DEN_HRCHY_PAR_IM1');
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    RAISE;
END LOAD_PRODUCT_HIERARCHY;

-- ER# 3185516
-- This is a wrapper procedure, which will be called whenever there is a change in item assignment
-- this in turn determines whether DBI is installed or not and calls the star pkg. if installed.
PROCEDURE SYNC_CATEGORY_ASSIGNMENTS(
       p_api_version         NUMBER,
       p_init_msg_list       VARCHAR2 := 'F',
       p_inventory_item_id   NUMBER,
       p_organization_id     NUMBER,
       x_return_status       OUT NOCOPY VARCHAR2,
       x_msg_count           OUT NOCOPY NUMBER,
       x_msg_data            OUT NOCOPY VARCHAR2,
       p_category_set_id     NUMBER,
       p_old_category_id     NUMBER,
       p_new_category_id     NUMBER) IS

  l_dbi_installed    VARCHAR2(1) := IS_DBI_INSTALLED;
  l_return_status    VARCHAR2(10);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(4000);

BEGIN
  IF l_dbi_installed = 'Y' THEN
    -- calling the star package to Sync up the category assignments
    EXECUTE IMMEDIATE
      'BEGIN                                              '||
      '  ENI_ITEMS_STAR_PKG.SYNC_CATEGORY_ASSIGNMENTS(    '||
      '     p_api_version        => :p_api_version,       '||
      '     p_init_msg_list      => :p_init_msg_list,     '||
      '     p_inventory_item_id  => :p_inventory_item_id, '||
      '     p_organization_id    => :p_organization_id,   '||
      '     x_return_status      => :l_return_status,     '||
      '     x_msg_count          => :l_msg_count,         '||
      '     x_msg_data           => :l_msg_data);         '||
      'END; '
    USING
      IN  p_api_version,
      IN  p_init_msg_list,
      IN  p_inventory_item_id,
      IN  p_organization_id,
      OUT l_return_status,
      OUT l_msg_count,
      OUT l_msg_data;

    IF l_return_status = 'U' THEN
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      RETURN;
    ELSE
      x_return_status := 'S';
    END IF;

    l_return_status := NULL;
    l_msg_count := NULL;
    l_msg_data := NULL;
  END IF;

  -- if there is item assignment change for Product category set, then
  -- update the item assignments flag in de-norm table
  IF (p_category_set_id = g_catset_id
      AND NVL(p_old_category_id, -1) <> NVL(p_new_category_id, -1)) THEN
    ENI_UPD_ASSGN.UPDATE_ASSGN_FLAG(
          p_new_category_id => p_new_category_id,
          p_old_category_id => p_old_category_id,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data);

    IF l_return_status = 'U' THEN
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      RETURN;
    ELSE
      x_return_status := 'S';
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'U';
    IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.ADD_EXC_MSG('ENI_DENORM_HRCHY', 'SYNC_CATEGORY_ASSIGNMENTS', SQLERRM);
    END IF;
    FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count, p_data => x_msg_data);
END SYNC_CATEGORY_ASSIGNMENTS;

-- ER: 3185516
-- This is a wrapper procedure, which will be called after import items
-- This in calls the star pkg and updates the Item Assignment Flag in De-norm table
PROCEDURE SYNC_STAR_ITEMS_FROM_IOI(
      p_api_version         NUMBER,
      p_init_msg_list       VARCHAR2 := 'F',
      p_set_process_id      NUMBER,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2) IS

  l_dbi_installed    VARCHAR2(1) := IS_DBI_INSTALLED;
  l_return_status    VARCHAR2(10);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(4000);
  l_user_id          NUMBER := FND_GLOBAL.USER_ID;
  l_conc_request_id  NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  l_prog_appl_id     NUMBER := FND_GLOBAL.PROG_APPL_ID;
  l_conc_program_id  NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
  l_count            NUMBER;
BEGIN
  IF l_dbi_installed = 'Y' THEN
    EXECUTE IMMEDIATE
      'BEGIN                                          '||
      '  ENI_ITEMS_STAR_PKG.SYNC_STAR_ITEMS_FROM_IOI( '||
      '    p_api_version     => :p_api_version,       '||
      '    p_init_msg_list   => :p_init_msg_list,     '||
      '    p_set_process_id  => :p_set_process_id,    '||
      '    x_return_status   => :l_return_status,     '||
      '    x_msg_count       => :l_msg_count,         '||
      '    x_msg_data        => :l_msg_data);         '||
      'END;'
    USING
      IN  p_api_version,
      IN  p_init_msg_list,
      IN  p_set_process_id,
      OUT l_return_status,
      OUT l_msg_count,
      OUT l_msg_data;

    IF l_return_status = 'U' THEN
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      RETURN;
    ELSE
      x_return_status := 'S';
    END IF;
  END IF;

  -- updating Item Assignment flag for all categories, which have items attached to it
  UPDATE ENI_DENORM_HIERARCHIES B
  SET
    ITEM_ASSGN_FLAG = 'Y',
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = l_user_id,
    LAST_UPDATE_LOGIN = l_user_id,
    REQUEST_ID = l_conc_request_id,
    PROGRAM_APPLICATION_ID = l_prog_appl_id,
    PROGRAM_UPDATE_DATE = SYSDATE,
    PROGRAM_ID = l_conc_program_id
  WHERE B.OBJECT_TYPE = 'CATEGORY_SET'
    AND B.OBJECT_ID = g_catset_id
    AND B.ITEM_ASSGN_FLAG = 'N'
    AND EXISTS (SELECT NULL
                FROM MTL_ITEM_CATEGORIES C
                WHERE C.CATEGORY_SET_ID = g_catset_id
                  AND C.CATEGORY_ID = B.CHILD_ID);

  -- updating Item Assignment flag for all categories, which does not have items attached to it
  UPDATE ENI_DENORM_HIERARCHIES B
  SET
    ITEM_ASSGN_FLAG = 'N',
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = l_user_id,
    LAST_UPDATE_LOGIN = l_user_id,
    REQUEST_ID = l_conc_request_id,
    PROGRAM_APPLICATION_ID = l_prog_appl_id,
    PROGRAM_UPDATE_DATE = SYSDATE,
    PROGRAM_ID = l_conc_program_id
  WHERE B.OBJECT_TYPE = 'CATEGORY_SET'
    AND B.OBJECT_ID = g_catset_id
    AND B.ITEM_ASSGN_FLAG = 'Y'
    AND B.CHILD_ID <> -1
    AND NOT EXISTS (SELECT NULL
                    FROM MTL_ITEM_CATEGORIES C
                    WHERE C.CATEGORY_SET_ID = g_catset_id
                      AND C.CATEGORY_ID = B.CHILD_ID);

  -- Checking Item assignment flag for Unassigned category
  -- if all items are attached to some categories within this category set then
  -- Item assignment flag for Unassigned node will be 'N'

  l_count := 0;

  BEGIN
    SELECT 1 INTO l_count
    FROM MTL_SYSTEM_ITEMS_B IT
    WHERE ROWNUM = 1
      AND NOT EXISTS (SELECT NULL FROM MTL_ITEM_CATEGORIES C
                      WHERE C.CATEGORY_SET_ID = g_catset_id
                        AND C.INVENTORY_ITEM_ID = IT.INVENTORY_ITEM_ID
                        AND C.ORGANIZATION_ID = IT.ORGANIZATION_ID);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_count := 0;
  END;

  UPDATE ENI_DENORM_HIERARCHIES B
  SET
    ITEM_ASSGN_FLAG = DECODE(l_count, 0, 'N', 'Y'),
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = l_user_id,
    LAST_UPDATE_LOGIN = l_user_id,
    REQUEST_ID = l_conc_request_id,
    PROGRAM_APPLICATION_ID = l_prog_appl_id,
    PROGRAM_UPDATE_DATE = SYSDATE,
    PROGRAM_ID = l_conc_program_id
  WHERE B.OBJECT_TYPE = 'CATEGORY_SET'
    AND B.OBJECT_ID = g_catset_id
    AND B.ITEM_ASSGN_FLAG = DECODE(l_count, 0, 'Y', 'N')
    AND B.CHILD_ID = -1
    AND B.PARENT_ID = -1;

  x_return_status := 'S';
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'U';
    IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.ADD_EXC_MSG('ENI_DENORM_HRCHY', 'SYNC_STAR_ITEMS_FROM_IOI', SQLERRM);
    END IF;
    FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count, p_data => x_msg_data);
END SYNC_STAR_ITEMS_FROM_IOI;

-- This Function returns nth occurence of string value separated by delimiter parameter
-- The occurence is determined by paramter p_level
FUNCTION split_category_codes(
        p_str      VARCHAR2
       ,p_level    NUMBER
       ,p_delim    VARCHAR2 DEFAULT g_delimiter)
RETURN VARCHAR2 IS

 l_str        VARCHAR2(2000);
 l_srch_width NUMBER := Length(p_delim);
 l_st         NUMBER;
 l_end        NUMBER;
BEGIN
  l_str := Trim(p_str);
  IF l_str IS NULL THEN RETURN NULL; END IF;

  l_st := InStr(l_str,p_delim);

  IF l_st = 0 THEN
     RETURN l_str;
  ELSE
     l_st := InStr(l_str,p_delim,1,p_level);
     IF l_st = 0 THEN -- Searching beyond
       l_st  := InStr(l_str,p_delim,-1,2);
       l_end := InStr(l_str,p_delim,-1,1);
       RETURN SubStr(l_str,l_st + l_srch_width, l_end - l_st - l_srch_width);
     ELSE -- First delimiter is found
       l_end := InStr(l_str,p_delim,1,p_level + 1);
       IF l_end = 0 THEN --We are the end of string return the last node
         l_end := l_st;
         l_st  := InStr(l_str,p_delim,1,p_level-1);
         RETURN SubStr(l_str,l_st + l_srch_width, l_end - l_st - l_srch_width);
       ELSE
         RETURN SubStr(l_str,l_st + l_srch_width, l_end - l_st - l_srch_width);
       END IF;
     END IF;
  END IF;
END split_category_codes;

-- This Procedure Denormalizes the Product Catalog Hierarchy into a separate denorm table
-- [ENI_ICAT_CDENORM_HIERARCHIES]. It is designed to support SBA/OBIEE requirements.
-- The program is designed to flatten the hierarchy for levels raning between 5 and 10.
-- The number of levels to denormalize is dynamic and is governed by a profile value.
-- Currently it only supports FULL REFRESH.
PROCEDURE LOAD_OBIEE_HIERARCHY(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) IS
  err                 VARCHAR2(2000);
  ret                 VARCHAR2(100);
  l_count             NUMBER := 0;
  l_user_id           NUMBER := FND_GLOBAL.USER_ID;
  l_conc_request_id   NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  l_prog_appl_id      NUMBER := FND_GLOBAL.PROG_APPL_ID;
  l_conc_program_id   NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
  l_hrchy_enabled     VARCHAR2(1);
  l_struct_id         NUMBER;
  l_levels_to_flatten NUMBER := 5;
  l_sql               VARCHAR2(4000);
  l_product_catalog   MTL_CATEGORY_SETS_TL.CATEGORY_SET_NAME%TYPE;

BEGIN
  retcode := 0;
  FND_FILE.PUT_LINE(FND_FILE.LOG,'OBIEE Denorm table Initial Load Start');

  -- Finding whether Hierarchy is enabled or not
  BEGIN
    SELECT HIERARCHY_ENABLED, STRUCTURE_ID INTO l_hrchy_enabled, l_struct_id
    FROM MTL_CATEGORY_SETS_B
    WHERE CATEGORY_SET_ID   = g_catset_id
      AND HIERARCHY_ENABLED = 'Y';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Category Set associated with Product Reporting functional area');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'- Or the Category set is not enabled for hierarchies');
    RAISE;
  END;

  BEGIN
     SELECT csvl.category_set_name
       INTO l_product_catalog
       FROM mtl_default_category_sets mdcs
           ,mtl_category_sets_vl csvl
      WHERE csvl.category_set_id = mdcs.category_set_id AND mdcs.functional_area_id=11;
     EXCEPTION WHEN OTHERS THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception while searching for functional area 11');
       RAISE;
  END;

  --Truncate the table first [INITIAL LOAD]
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Truncating the DENORM table');

  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_tab_schema || '.ENI_ICAT_CDENORM_HIERARCHIES';

  --Fetch the profile value for No of levels to flatten
  fnd_profile.get('ENI_ICAT_DENORM_LEVEL', l_levels_to_flatten);

  IF l_levels_to_flatten IS NULL or l_levels_to_flatten > 10 or l_levels_to_flatten < 5 THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Profile [ENI: SBA/OBIEE LEVELS IN HIERARCHY] has incorrect value of: [' || l_levels_to_flatten || ']');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Setting the denormalisation to default level of 5');
     l_levels_to_flatten := 5;
  END IF;

  --Start populating the denorm table
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Denormalizing catalog [' || l_product_catalog || '] to ' || l_levels_to_flatten || ' levels.');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Denormalization is Row + Column flattening');

  l_sql :=
    'INSERT INTO eni_icat_cdenorm_hierarchies ( ' ||
           '  category_id_level1 ' ||
           ' ,category_id_level2 ' ||
           ' ,category_id_level3 ' ||
           ' ,category_id_level4 ' ||
           ' ,category_id_level5 ';

  --Add category_id_level* columns according to the profile value selected
  FOR i IN 6..l_levels_to_flatten
  LOOP
     l_sql := l_sql || ' ,category_id_level' || i;
  END LOOP;


  l_sql := l_sql ||
           ' ,leaf_category_id   ' ||
           ' ,created_by         ' ||
           ' ,creation_date      ' ||
           ' ,last_updated_by    ' ||
           ' ,last_update_date   ' ||
           ' ,last_update_login  ' ||
           ' ,request_id         ' ||
           ' ,program_application_id ' ||
           ' ,program_update_date' ||
           ' ,program_id) ';

  --Start of SELECT clause
  l_sql := l_sql ||
           '( SELECT ' ||
         '  ENI_DENORM_HRCHY.split_category_codes(catstr,1,''' || g_delimiter || ''') ' ||
         ' ,ENI_DENORM_HRCHY.split_category_codes(catstr,2,''' || g_delimiter || ''') ' ||
         ' ,ENI_DENORM_HRCHY.split_category_codes(catstr,3,''' || g_delimiter || ''') ' ||
         ' ,ENI_DENORM_HRCHY.split_category_codes(catstr,4,''' || g_delimiter || ''') ' ||
         ' ,ENI_DENORM_HRCHY.split_category_codes(catstr,5,''' || g_delimiter || ''') ';

  --Add category_id_level* columns according to the profile value selected
  FOR i IN 6..l_levels_to_flatten
  LOOP
     l_sql := l_sql || ' ,ENI_DENORM_HRCHY.split_category_codes(catstr,' || i || ',''' || g_delimiter || ''') ';
  END LOOP;

  l_sql := l_sql ||
           ' ,category_id        ' ||
         ' ,:cr_by             ' ||
           ' ,:cr_date           ' ||
           ' ,:upd_by            ' ||
           ' ,:l_upd_date        ' ||
           ' ,:upd_login         ' ||
           ' ,:l_conc_request_id ' ||
           ' ,:l_prog_appl_id    ' ||
           ' ,:p_upd_date        ' ||
           ' ,:l_conc_program_id ' ||
         ' FROM ' ||
         ' (SELECT (sys_connect_by_path(vcats.category_id,''' || g_delimiter ||
         ''') ||''' || g_delimiter || ''') catstr ' ||
         '        , vcats.category_id' ||
           '  FROM MTL_CATEGORY_SET_VALID_CATS vcats ' ||
           ' WHERE CATEGORY_SET_ID = :g_catset_id    ' ||
         '/* AND CATEGORY_ID NOT IN (SELECT        ' ||
         '   Nvl(vcats1.PARENT_CATEGORY_ID,-99) FROM MTL_CATEGORY_SET_VALID_CATS vcats1 WHERE vcats1.CATEGORY_SET_ID = :g_catset_id2) */' ||
           ' START WITH PARENT_CATEGORY_ID IS NULL   ' ||
         ' AND CATEGORY_SET_ID = :g_catset_id3     ' ||
           ' CONNECT BY PRIOR CATEGORY_ID = PARENT_CATEGORY_ID ' ||
         ' AND PRIOR    CATEGORY_SET_ID = CATEGORY_SET_ID ))' ;
  -- The NOT IN condition eliminates the row flattened rows from the result
  -- Bug 5525229 - commented the NOT IN condition

  EXECUTE IMMEDIATE l_sql
  USING l_user_id, SYSDATE, l_user_id, SYSDATE, l_user_id, l_conc_request_id ,l_prog_appl_id ,SYSDATE ,l_conc_program_id
       ,g_catset_id, g_catset_id;

  IF SQL%ROWCOUNT > 0 THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserted [' || SQL%ROWCOUNT ||'] rows into denorm table.');
  ELSE
     RAISE NO_DATA_FOUND;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert the UNASSIGNED product category row.');

  INSERT INTO eni_icat_cdenorm_hierarchies (
     category_id_level1
    ,category_id_level2
    ,category_id_level3
    ,category_id_level4
    ,category_id_level5
    ,category_id_level6
    ,category_id_level7
    ,category_id_level8
    ,category_id_level9
    ,category_id_level10
    ,leaf_category_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,request_id
    ,program_application_id
    ,program_update_date
    ,program_id)
  VALUES (
   -1,-1,-1,-1,-1,-1,-1,-1,-1,-1
  ,-1
  ,l_user_id
  ,SYSDATE
  ,l_user_id
  ,SYSDATE
  ,l_user_id
  ,l_conc_request_id
  ,l_prog_appl_id
  ,SYSDATE
  ,l_conc_program_id
  );

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Gathering statistics on table: ENI_ICAT_CDENORM_HIERARCHIES ');
  FND_STATS.gather_table_stats (ownname=>g_tab_schema, tabname=>'ENI_ICAT_CDENORM_HIERARCHIES');

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Denorm table Initial Load completed successfully');

  COMMIT;
EXCEPTION
  WHEN  NO_DATA_FOUND THEN

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: No Data Found. Transaction will be rolled back');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' Catalog [' || l_product_catalog || '] does not have any categories associated to it.');
    errbuf := SQLERRM || ' Catalog [' || l_product_catalog || '] does not have any categories associated to it.';
    retcode := 1;
    ROLLBACK;
  WHEN OTHERS THEN
     if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'ENI_DENORM_HRCHY.LOAD_OBIEE_HIERARCHY', 'Error: ' ||
                                                sqlerrm || ' .Transaction will be rolled back');
     end if;
    errbuf := 'Error :' || sqlerrm;
    retcode := 2;
    ROLLBACK;
END LOAD_OBIEE_HIERARCHY;

END ENI_DENORM_HRCHY;

/
