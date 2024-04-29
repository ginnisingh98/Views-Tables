--------------------------------------------------------
--  DDL for Package Body EGO_USER_ATTRS_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_USER_ATTRS_DATA_PVT" AS
/* $Header: EGOPEFDB.pls 120.65.12010000.56 2013/03/20 23:35:47 chulhale ship $ */

                      ------------------------
                      -- Private Data Types --
                      ------------------------


    TYPE LOCAL_NUMBER_TABLE IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

    TYPE LOCAL_VARCHAR_TABLE IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

    TYPE LOCAL_MEDIUM_VARCHAR_TABLE IS TABLE OF VARCHAR2(300)
      INDEX BY BINARY_INTEGER;

    TYPE LOCAL_BIG_VARCHAR_TABLE IS TABLE OF VARCHAR2(5000)
      INDEX BY BINARY_INTEGER;

    TYPE LOCAL_COL_NV_PAIR_TABLE IS TABLE OF EGO_COL_NAME_VALUE_PAIR_OBJ
      INDEX BY BINARY_INTEGER;

    TYPE LOCAL_USER_ATTR_DATA_TABLE IS TABLE OF EGO_USER_ATTR_DATA_OBJ
      INDEX BY BINARY_INTEGER;

    TYPE LOCAL_USER_ATTR_ROW_TABLE IS TABLE OF EGO_USER_ATTR_ROW_OBJ
      INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE         IS VARRAY(100) OF VARCHAR2(4000);	-- Bug 8757354
    TYPE DATE_TBL_TYPE             IS VARRAY(100) OF DATE;
    TYPE NUMBER_TBL_TYPE           IS VARRAY(100) OF NUMBER;

    ----------------------------------------------------------------------
    -- Type for tracking Attr Data for Get_User_Attrs_Data, including a --
    -- field for DATABASE_COLUMN so we can match up columns from query  --
    ----------------------------------------------------------------------
    TYPE LOCAL_USER_ATTR_DATA_REC IS RECORD
    (
        ATTR_GROUP_ID                        NUMBER
       ,APPLICATION_ID                       NUMBER
       ,ATTR_GROUP_TYPE                      VARCHAR2(40)
       ,ATTR_GROUP_NAME                      VARCHAR2(30)
       ,ATTR_NAME                            VARCHAR2(30)
       ,ATTR_DISP_NAME                       VARCHAR2(80)
       ,ATTR_DISP_VALUE                      VARCHAR2(4000)	-- Bug 8757354
       ,ATTR_UNIT_OF_MEASURE                 VARCHAR2(3)
       ,DATABASE_COLUMN                      VARCHAR2(30)
       --To pass the internal Value along with the display value
       ,ATTR_VALUE_STR                      VARCHAR(4000)	-- Bug 8757354
       ,ATTR_VALUE_NUM                      NUMBER
       ,ATTR_VALUE_DATE                     DATE
       ,DATA_TYPE_CODE                      VARCHAR2(8)


    );

    TYPE LOCAL_AUGMENTED_DATA_TABLE IS TABLE OF LOCAL_USER_ATTR_DATA_REC
      INDEX BY BINARY_INTEGER;

    TYPE LOCAL_HIERARCHY_REC IS RECORD
    (
        ATTR_GROUP_TYPE    VARCHAR2(40)
      , IS_ROOT_NODE       VARCHAR2(1)
      , IS_LEAF_NODE       VARCHAR2(1)
    );

    TYPE LOCAL_HIERARCHY_REC_TABLE IS TABLE OF LOCAL_HIERARCHY_REC
      INDEX BY BINARY_INTEGER;

    -- 13719629
    TYPE VARCHAR2_CACHE_TABTYPE IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(300);
    TYPE VARTABLE_CACHE_TABTYPE IS TABLE OF LOCAL_MEDIUM_VARCHAR_TABLE INDEX BY VARCHAR2(300);

                   ------------------------------
                   -- Private Global Variables --
                   ------------------------------

    G_PKG_NAME           CONSTANT   VARCHAR2(30) := 'EGO_USER_ATTRS_DATA_PVT';
    G_CURRENT_USER_PRIVILEGES       EGO_VARCHAR_TBL_TYPE;

    G_BULK_PROCESSING_FLAG          BOOLEAN := FALSE;
    G_DEFAULT_ON_INSERT_FLAG        BOOLEAN := FALSE;
    G_NEED_TO_RESET_AG_CACHE        BOOLEAN := TRUE;

    G_OBJECT_NAME_TO_ID_CACHE       LOCAL_VARCHAR_TABLE;
    G_ASSOCIATION_DATA_LEVEL_CACHE  LOCAL_BIG_VARCHAR_TABLE;

    --
    -- Bug 13719629. Performance issue in get table column list
    -- due to high number of executions. Adding a new PLSQL level
    -- caching infrastructure to cache metadata.
    -- sreharih. Fri Feb 17 11:08:31 PST 2012
    --

    G_VARCHAR2_CACHE_STORE          VARCHAR2_CACHE_TABTYPE;
    G_VARTABLE_CACHE_STORE          VARTABLE_CACHE_TABTYPE;


    G_DEBUG_OUTPUT_LEVEL            NUMBER := 0;
    G_ADD_ERRORS_TO_FND_STACK       VARCHAR2(1) := 'N';
    G_USER_ROW_IDENTIFIER           NUMBER := 0;

    G_B_TABLE_DML                   VARCHAR2(32767);
    G_TL_TABLE_DML                  VARCHAR2(32767);

    G_BIND_INDEX                    NUMBER := 0;
    G_BIND_DATATYPE_TBL             VARCHAR2_TBL_TYPE;
    G_BIND_TEXT_TBL                 VARCHAR2_TBL_TYPE;
    G_BIND_DATE_TBL                 DATE_TBL_TYPE;
    G_BIND_NUMBER_TBL               NUMBER_TBL_TYPE;
    G_BIND_IDENTIFIER_TBL           VARCHAR2_TBL_TYPE;
    G_B_BIND_IDENTIFIER_TBL         VARCHAR2_TBL_TYPE;
    G_TL_BIND_IDENTIFIER_TBL        VARCHAR2_TBL_TYPE;

    G_B_BIND_INDEX                  NUMBER := 0;
    G_B_BIND_DATATYPE_TBL           VARCHAR2_TBL_TYPE;
    G_B_BIND_TEXT_TBL               VARCHAR2_TBL_TYPE;
    G_B_BIND_DATE_TBL               DATE_TBL_TYPE;
    G_B_BIND_NUMBER_TBL             NUMBER_TBL_TYPE;

    G_TL_BIND_INDEX                 NUMBER := 0;
    G_TL_BIND_DATATYPE_TBL          VARCHAR2_TBL_TYPE;
    G_TL_BIND_TEXT_TBL              VARCHAR2_TBL_TYPE;
    G_TL_BIND_DATE_TBL              DATE_TBL_TYPE;
    G_TL_BIND_NUMBER_TBL            NUMBER_TBL_TYPE;

    G_DATA_LEVEL_NAME               VARCHAR2(30);
    G_DATA_LEVEL_ID                 NUMBER;
    -----------------------------------------------------
    -- This is a private additional mode for use in    --
    -- calls to Process_Row from Implement_Change_Line --
    -----------------------------------------------------
    G_IMPLEMENT_CREATE_MODE  CONSTANT VARCHAR2(10) := 'IMP_CREATE';

    G_HIERARCHY_CACHE                 LOCAL_HIERARCHY_REC_TABLE;
    --in GTIN while creating a row 'SYNC' is passed which changes to 'UPDATE' or 'CREATE'
    G_SYNC_TO_UPDATE                  VARCHAR2(1) := 'N';

    G_RET_STS_SUCCESS       VARCHAR2(1) := 'S';
    G_RET_STS_ERROR         VARCHAR2(1) := 'E';
    G_RET_STS_UNEXP_ERROR   VARCHAR2(1) := 'U';

		----Bug 9277377
    g_tab_name                               VARCHAR2(30) := NULL;
    g_owner                                  VARCHAR2(30) := NULL;

-- for development user to enable and disable debug
G_ENABLE_DEBUG BOOLEAN := FALSE;
--Added by geguo for 9373845
G_WHO_CREATION_DATE       DATE := NULL;
G_WHO_LAST_UPDATE_DATE    DATE := NULL;

                 ---------------------------------
                 -- Private Debugging Procedure --
                 ---------------------------------

----------------------------------------------------------------------
/*
 * The following procedure is for debugging purposes.  Its functionality is
 * controlled by the global variable G_DEBUG_OUTPUT_LEVEL, whose values are:
 *
 * 3: LONG debug messages
 * 2: MEDIUM debug messages
 * 1: SHORT debug messages
 * 0: NO debug messages
 *
 * The procedure will only print messages at the specified level or lower.
 * When logging messages, specify their debug level or let it default to 3.
 *(You will also have to call "set serveroutput on" to see the output.)
 */

PROCEDURE Debug_Msg(
        p_message                       IN   VARCHAR2
       ,p_level_of_debug                IN   NUMBER       DEFAULT 3
)
IS

-- PRAGMA AUTONOMOUS_TRANSACTION;  --- commented bug 9231200

BEGIN
-- IF G_ENABLE_DEBUG THEN
--    sri_debug('EGOPEFDB ' ||p_message);
-- END IF;
 IF (LENGTH(p_message) > 200) THEN
   Debug_Msg(SUBSTR(p_message, 1, 200), p_level_of_debug);
   Debug_Msg(SUBSTR(p_message, 201), p_level_of_debug);
 ELSIF (LENGTH(p_message) > 0) THEN
   ERROR_HANDLER.Write_Debug('['||TO_CHAR(SYSDATE, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT)||'] '||p_message);
--   dbms_output.put_line(p_message);
 END IF;
END Debug_Msg;

----------------------------------------------------------------------

/*
 * For debugging of SQL strings whose length exceeds the 2000 byte
 * buffer limit on DBMS_OUTPUT.PUT_LINE.  This procedure handles
 * strings of any length up to the VARCHAR2 PL/SQL limit of 32767
 * bytes by making recursive calls as necessary.
 * (Debug_Msg is defined at the end of this package body.)
 */

PROCEDURE Debug_SQL (
        p_long_message                  IN   VARCHAR2
       ,p_level_of_debug                IN   NUMBER := 3
)
IS

  BEGIN
NULL;
/***
    IF (p_level_of_debug <= G_DEBUG_OUTPUT_LEVEL) THEN
      IF (LENGTH(p_long_message) > 5000) THEN
        Debug_SQL(SUBSTR(p_long_message, 1, 5000), p_level_of_debug);
        Debug_SQL(SUBSTR(p_long_message, 5001), p_level_of_debug);
      ELSE
        Debug_Msg(SUBSTR(p_long_message, 1, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 201, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 401, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 601, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 801, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 1001, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 1201, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 1401, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 1601, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 1801, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 2001, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 2201, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 2401, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 2601, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 2801, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 3001, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 3201, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 3401, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 3601, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 3801, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 4001, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 4201, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 4401, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 4601, 200), p_level_of_debug);
        Debug_Msg(SUBSTR(p_long_message, 4801, 200), p_level_of_debug);
      END IF;
    END IF;
***/
END Debug_SQL;
    --
    -- Bug 13719629. Performance issue in get table column list
    -- due to high number of executions. Adding a new PLSQL level
    -- caching infrastructure to cache metadata.
    -- sreharih. Fri Feb 17 11:08:31 PST 2012
    --
--
-- Preprocess and build key
--
FUNCTION build_key(p_key IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN
 RETURN substr(p_key, 1, 300);
END build_key;

--
-- Get cached varchar2 value
--
FUNCTION get_cached_varchar(p_key IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN
  IF(G_VARCHAR2_CACHE_STORE.EXISTS(p_key)) THEN
     Debug_Msg('Cache hit for ' || p_key || ' : returning ' || G_VARCHAR2_CACHE_STORE(p_key));
     RETURN G_VARCHAR2_CACHE_STORE(p_key);
  END IF;
    Debug_Msg('Cache miss for ' || p_key || ' : returning NULL');
  RETURN NULL;

END get_cached_varchar;

--
-- Cache varchar2 value
--
PROCEDURE cache_varchar(p_key   IN VARCHAR2,
                        p_value IN VARCHAR2) IS


BEGIN

  G_VARCHAR2_CACHE_STORE(p_key) := p_value;

END cache_varchar;

--
-- Get cached varchar2 TABLE
--
FUNCTION get_cached_vartable(p_key IN VARCHAR2) RETURN LOCAL_MEDIUM_VARCHAR_TABLE IS
  l_ret LOCAL_MEDIUM_VARCHAR_TABLE;
BEGIN
  IF(G_VARTABLE_CACHE_STORE.EXISTS(p_key)) THEN
     Debug_Msg('Cache hit for ' || p_key );
     l_ret := G_VARTABLE_CACHE_STORE(p_key);
  ELSE
     Debug_Msg('Cache miss for ' || p_key || ' : returning NULL');
  END IF;

  RETURN l_ret;

END get_cached_vartable;

--
-- Cache varchar2 TABLE
--

PROCEDURE cache_vartable(p_key   IN VARCHAR2,
                         p_value IN LOCAL_MEDIUM_VARCHAR_TABLE) IS


BEGIN

  G_VARTABLE_CACHE_STORE(p_key) := p_value;

END cache_vartable;

-- End 13719629

----------------------------------------------------------------------



           ---------------------------------------------
           -- Private Helper Procedures and Functions --
           ---------------------------------------------

----------------------------------------------------------------------
--
-- Private
--
----------------------------------
-- Covert data level name to Id --
----------------------------------
FUNCTION Get_Data_Level_Id ( p_application_id    IN VARCHAR2
                            ,p_attr_group_type   IN VARCHAR2
                            ,p_data_level_name   IN VARCHAR2
)
RETURN NUMBER
IS
   l_data_level_id   NUMBER;
BEGIN

   IF(p_data_level_name IS NULL) THEN
     RETURN NULL;
   END IF;

   IF(p_data_level_name = G_DATA_LEVEL_NAME) THEN
     RETURN G_DATA_LEVEL_ID;
   END IF;

   SELECT DATA_LEVEL_ID
     INTO l_data_level_id
     FROM EGO_DATA_LEVEL_B
    WHERE APPLICATION_ID = p_application_id
      AND ATTR_GROUP_TYPE = p_attr_group_type
      AND DATA_LEVEL_NAME = p_data_level_name;

   IF(l_data_level_id IS NOT NULL) THEN
     G_DATA_LEVEL_ID := l_data_level_id;
     G_DATA_LEVEL_NAME := p_data_level_name;
   END IF;

   RETURN l_data_level_id;
EXCEPTION
   WHEN OTHERS THEN
   Debug_Msg('Failed Get_Data_Level_Id-'||SQLERRM,0);
   RAISE FND_API.G_EXC_ERROR;
END Get_Data_Level_Id;
---------------------------------------------------------------------

--
-- Private
--
--------------------------------
-- Is name value pairs valid  --
--------------------------------
PROCEDURE Is_Name_Value_Pairs_Valid
   ( p_attr_group_id               IN NUMBER
    ,p_data_level_name             IN VARCHAR2
    ,p_class_code_hierarchy        IN VARCHAR2
    ,p_data_level_name_value_pairs IN EGO_COL_NAME_VALUE_PAIR_ARRAY
    ,x_data_level_id               OUT NOCOPY NUMBER
    ,x_name_value_pair_valid       OUT NOCOPY VARCHAR2
   ) IS

  l_api_name               VARCHAR2(30) := 'Is_Name_Value_Pairs_Valid';
  l_dynamic_sql            VARCHAR2(5000);
  l_name_value_pair_valid  BOOLEAN := FALSE;
  l_dl_metadata_obj        EGO_DATA_LEVEL_METADATA_OBJ;

BEGIN
  Debug_Msg(l_api_name || '  cannot find an unique data level using  ag_ID, DATA_LEVEL, CLASS_CODE '||
             p_attr_group_id ||', '||p_data_level_name||', '||p_class_code_hierarchy,1);
  --
  -- if the passed in pk values satisfy the data level, call perform_dml_on_temlate_row
  -- old code will return only one record
  -- new code will have p_data_level and must return only one record
  --
  BEGIN
    l_dynamic_sql := 'SELECT DISTINCT(assoc.data_level_id) ' ||
                      ' FROM ego_data_level_b dl, ego_obj_ag_assocs_b assoc, ego_fnd_dsc_flx_ctx_ext ag '||
                     ' WHERE ag.attr_group_id = '||p_attr_group_id ||
                       ' AND dl.attr_group_type = ag.descriptive_flexfield_name '||
                       ' AND dl.application_id = ag.application_id ';
    IF p_data_level_name IS NOT NULL THEN
      l_dynamic_sql := l_dynamic_sql ||
                       ' AND dl.data_level_name = '''||p_data_level_name||'''';
    END IF;
   l_dynamic_sql := l_dynamic_sql ||
                       ' AND dl.data_level_id = assoc.data_level_id ' ||
                       ' AND assoc.attr_group_id = ag.attr_group_id '||
                       ' AND assoc.classification_code IN ('||p_class_code_hierarchy ||')';
    Debug_Msg(l_api_name || '   complete query '|| l_dynamic_sql,1);
    EXECUTE IMMEDIATE l_dynamic_sql
    INTO x_data_level_id;
  EXCEPTION
    WHEN OTHERS THEN
     Debug_Msg(l_api_name || '   EXCEPTION '||SQLERRM,1);
     x_data_level_id := NULL;
     x_name_value_pair_valid := FND_API.G_FALSE;
  END;
  l_name_value_pair_valid := FALSE;
  IF x_data_level_id IS NOT NULL THEN
    -- if the pk's passed satisfy this data_level, call Perform_DML_On_Template_Row
    Debug_Msg(l_api_name || '  we have valid data_level_id as  '|| x_data_level_id,1);
    l_dl_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Data_Level_Metadata(x_data_level_id);
    IF l_dl_metadata_obj IS NULL THEN
      Debug_Msg(l_api_name || '  in invalid as we cannot have dl metadata object '|| x_data_level_id,1);
      l_name_value_pair_valid := FALSE;
    ELSE
      IF (p_data_level_name_value_pairs IS NULL OR p_data_level_name_value_pairs.COUNT = 0) THEN
        Debug_Msg(l_api_name || '  101 ',1);
        IF l_dl_metadata_obj.pk_column_name1 IS NULL AND
           l_dl_metadata_obj.pk_column_name2 IS NULL AND
           l_dl_metadata_obj.pk_column_name3 IS NULL AND
           l_dl_metadata_obj.pk_column_name4 IS NULL AND
           l_dl_metadata_obj.pk_column_name5 IS NULL THEN
        Debug_Msg(l_api_name || '  102 ',1);
          l_name_value_pair_valid := TRUE;
        END IF;
      ELSE
        FOR i IN p_data_level_name_value_pairs.FIRST .. p_data_level_name_value_pairs.LAST LOOP
        Debug_Msg(l_api_name || '  103 ',1);
          IF (p_data_level_name_value_pairs(i).name IS NOT NULL
              AND
              (
                (p_data_level_name_value_pairs(i).name = l_dl_metadata_obj.pk_column_name1 OR l_dl_metadata_obj.pk_column_name1 IS NULL)
                OR
                (p_data_level_name_value_pairs(i).name = l_dl_metadata_obj.pk_column_name2 OR l_dl_metadata_obj.pk_column_name2 IS NULL)
                OR
                (p_data_level_name_value_pairs(i).name = l_dl_metadata_obj.pk_column_name3 OR l_dl_metadata_obj.pk_column_name3 IS NULL)
                OR
                (p_data_level_name_value_pairs(i).name = l_dl_metadata_obj.pk_column_name4 OR l_dl_metadata_obj.pk_column_name4 IS NULL)
                OR
                (p_data_level_name_value_pairs(i).name = l_dl_metadata_obj.pk_column_name5 OR l_dl_metadata_obj.pk_column_name5 IS NULL)
              )
             ) THEN
        Debug_Msg(l_api_name || '  104 ',1);
            l_name_value_pair_valid := TRUE;
          ELSE
        Debug_Msg(l_api_name || '  105 ',1);
            l_name_value_pair_valid := FALSE;
            EXIT; -- exit the loop
          END IF;
        END LOOP;
      END IF;
    END IF;
  END IF;

        Debug_Msg(l_api_name || '  106 ',1);
  IF l_name_value_pair_valid THEN
        Debug_Msg(l_api_name || '  107 ',1);
    x_name_value_pair_valid := FND_API.G_TRUE;
  ELSE
        Debug_Msg(l_api_name || '  108 ',1);
    x_name_value_pair_valid := FND_API.G_FALSE;
  END IF;

END Is_Name_Value_Pairs_Valid;

--
-- Private
-- To Check whether the attribute is null or not
--
FUNCTION All_Attr_Values_Are_Null (
        p_attr_name_value_pairs    IN   EGO_USER_ATTR_DATA_TABLE
)
RETURN BOOLEAN
IS

    l_attr_count      NUMBER;
    l_all_are_null    BOOLEAN := TRUE;

  BEGIN

    Debug_Msg('In All_Attr_Values_Are_Null, starting', 2);

    IF (p_attr_name_value_pairs IS NOT NULL AND p_attr_name_value_pairs.COUNT > 0) THEN

      l_attr_count := p_attr_name_value_pairs.FIRST;

      WHILE (l_attr_count <= p_attr_name_value_pairs.LAST)
      LOOP
        EXIT WHEN (NOT l_all_are_null);

          IF (p_attr_name_value_pairs(l_attr_count).ATTR_VALUE_STR IS NOT NULL OR
              p_attr_name_value_pairs(l_attr_count).ATTR_VALUE_NUM IS NOT NULL OR
              p_attr_name_value_pairs(l_attr_count).ATTR_VALUE_DATE IS NOT NULL OR
              p_attr_name_value_pairs(l_attr_count).ATTR_DISP_VALUE IS NOT NULL) THEN
            l_all_are_null := FALSE;
          END IF;

        l_attr_count := p_attr_name_value_pairs.NEXT(l_attr_count);
      END LOOP;
    END IF;

    Debug_Msg('In All_Attr_Values_Are_Null, done', 2);

    RETURN l_all_are_null;

END All_Attr_Values_Are_Null;

----------------------------------------------------------------------

--
-- Private
--
FUNCTION Get_Hierarchy_For_AG_Type (
        p_ag_type                       IN   VARCHAR2
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
)
RETURN LOCAL_HIERARCHY_REC
IS

    l_hierarchy_cache_index NUMBER;
    l_hierarchy_row_index   NUMBER;
    l_dynamic_sql           VARCHAR2(200);
    l_hierarchy_query       VARCHAR2(4000);
    l_pk_column_index       NUMBER;
    l_pk_value1             VARCHAR2(150);
    l_pk_value2             VARCHAR2(150);
    l_pk_value3             VARCHAR2(150);
    l_pk_value4             VARCHAR2(150);
    l_pk_value5             VARCHAR2(150);

    TYPE LOCAL_RESULT_PAIR IS RECORD
    (
        IS_ROOT_NODE        VARCHAR2(1)
      , IS_LEAF_NODE        VARCHAR2(1)
    );

    l_result                LOCAL_RESULT_PAIR;
    l_return_value          LOCAL_HIERARCHY_REC;

    --Variables for Dynamic Cursor execution
    TYPE cur_typ IS REF CURSOR;

    c_cursor              cur_typ;
    l_hier_res_found      BOOLEAN := FALSE;

  BEGIN

    Debug_Msg('In Get_Hierarchy_From_AG_Type, starting for p_ag_type '||p_ag_type, 2);

    IF (G_HIERARCHY_CACHE.FIRST IS NOT NULL) THEN

      l_hierarchy_cache_index := G_HIERARCHY_CACHE.FIRST;
      WHILE (l_hierarchy_cache_index <= G_HIERARCHY_CACHE.LAST)
      LOOP
        EXIT WHEN (l_hierarchy_row_index IS NOT NULL);
        IF (G_HIERARCHY_CACHE(l_hierarchy_cache_index).ATTR_GROUP_TYPE = p_ag_type) THEN
          l_hierarchy_row_index := l_hierarchy_cache_index;
        END IF;
        l_hierarchy_cache_index := G_HIERARCHY_CACHE.NEXT(l_hierarchy_cache_index);
      END LOOP;
    ELSE
       Debug_Msg(' G_HIERARCHY_CACHE IS NULL ');
       l_hierarchy_cache_index := 1;
    END IF;

    IF (l_hierarchy_row_index IS NULL) THEN

      -- get hierarchy query for this object and run it
      l_dynamic_sql := 'SELECT HIERARCHY_NODE_QUERY FROM EGO_FND_DESC_FLEXS_EXT '||
                       'WHERE DESCRIPTIVE_FLEXFIELD_NAME = :1';

      EXECUTE IMMEDIATE l_dynamic_sql INTO l_hierarchy_query USING p_ag_type;

      Debug_Msg('In Get_Hierarchy_From_AG_Type,  l_hierarchy_query = '||l_hierarchy_query);

      IF (l_hierarchy_query IS NOT NULL) THEN

        -- prepare the hierarchy query binds and run it
        IF (p_pk_column_name_value_pairs IS NOT NULL AND p_pk_column_name_value_pairs.COUNT > 0) THEN

          l_pk_column_index := p_pk_column_name_value_pairs.FIRST;
          WHILE (l_pk_column_index <= p_pk_column_name_value_pairs.LAST)
          LOOP

            IF (p_pk_column_name_value_pairs(l_pk_column_index).VALUE IS NOT NULL AND
                LENGTH(p_pk_column_name_value_pairs(l_pk_column_index).VALUE) > 0) THEN

              IF (l_pk_column_index = p_pk_column_name_value_pairs.FIRST) THEN
                l_pk_value1 := p_pk_column_name_value_pairs(l_pk_column_index).VALUE;
              ELSIF (l_pk_column_index = p_pk_column_name_value_pairs.FIRST+1) THEN
                l_pk_value2 := p_pk_column_name_value_pairs(l_pk_column_index).VALUE;
              ELSIF (l_pk_column_index = p_pk_column_name_value_pairs.FIRST+2) THEN
                l_pk_value3 := p_pk_column_name_value_pairs(l_pk_column_index).VALUE;
              ELSIF (l_pk_column_index = p_pk_column_name_value_pairs.FIRST+3) THEN
                l_pk_value4 := p_pk_column_name_value_pairs(l_pk_column_index).VALUE;
              ELSIF (l_pk_column_index = p_pk_column_name_value_pairs.FIRST+4) THEN
                l_pk_value5 := p_pk_column_name_value_pairs(l_pk_column_index).VALUE;
              END IF;

          Debug_Msg('In Get_Hierarchy_From_AG_Type, Debug [p_pk_column_name_value_pairs(l_pk_column_index).VALUE] = '||p_pk_column_name_value_pairs(l_pk_column_index).VALUE);

            END IF;

            l_pk_column_index := p_pk_column_name_value_pairs.NEXT(l_pk_column_index);
          END LOOP;

        END IF;

        -- assuming that if pk_value3 is defined, pk_value1 and 2 are defined as well
        IF (l_pk_value5 IS NOT NULL) THEN
          OPEN c_cursor FOR l_hierarchy_query USING l_pk_value1, l_pk_value2, l_pk_value3, l_pk_value4, l_pk_value5;
          FETCH c_cursor INTO l_result;
          IF c_cursor%FOUND THEN
            l_hier_res_found := TRUE;
          END IF;
          CLOSE c_cursor;

        ELSIF (l_pk_value4 IS NOT NULL) THEN
          OPEN c_cursor FOR l_hierarchy_query USING l_pk_value1, l_pk_value2, l_pk_value3, l_pk_value4;
          FETCH c_cursor INTO l_result;
          IF c_cursor%FOUND THEN
            l_hier_res_found := TRUE;
          END IF;
          CLOSE c_cursor;

        ELSIF (l_pk_value3 IS NOT NULL) THEN
          OPEN c_cursor FOR l_hierarchy_query USING l_pk_value1, l_pk_value2, l_pk_value3;
          FETCH c_cursor INTO l_result;
          IF c_cursor%FOUND THEN
            l_hier_res_found := TRUE;
          END IF;
          CLOSE c_cursor;

        ELSIF (l_pk_value2 IS NOT NULL) THEN

          OPEN c_cursor FOR l_hierarchy_query USING l_pk_value1, l_pk_value2;
          FETCH c_cursor INTO l_result;
          IF c_cursor%FOUND THEN
            l_hier_res_found := TRUE;
          END IF;
          CLOSE c_cursor;

        ELSIF (l_pk_value1 IS NOT NULL) THEN
          OPEN c_cursor FOR l_hierarchy_query USING l_pk_value1;
          FETCH c_cursor INTO l_result;
          IF c_cursor%FOUND THEN
            l_hier_res_found := TRUE;
          END IF;
          CLOSE c_cursor;

        ELSE
          OPEN c_cursor FOR l_hierarchy_query;
          FETCH c_cursor INTO l_result;
          IF c_cursor%FOUND THEN
            l_hier_res_found := TRUE;
          END IF;
          CLOSE c_cursor;

        END IF;

        -- cache the results
        IF l_hier_res_found THEN
          l_return_value.IS_ROOT_NODE := l_result.IS_ROOT_NODE;
          l_return_value.IS_LEAF_NODE := l_result.IS_LEAF_NODE;
        ELSE
          -- default values if query returned no results
          l_return_value.IS_ROOT_NODE := 'N';
          l_return_value.IS_LEAF_NODE := 'N';
        END IF;

      ELSE
       -- if no query was found, return default values
        l_return_value.IS_ROOT_NODE := 'N';
        l_return_value.IS_LEAF_NODE := 'N';
      END IF;

      l_return_value.ATTR_GROUP_TYPE := p_ag_type;
      Debug_Msg('In Get_Hierarchy_From_AG_Type, l_hierarchy_cache_index = '||To_Char(l_hierarchy_cache_index));
      Debug_Msg('l_return_value.IS_ROOT_NODE = '||l_return_value.IS_ROOT_NODE||' and l_return_value.IS_LEAF_NODE = '||l_return_value.IS_LEAF_NODE);
      IF(l_hierarchy_cache_index IS NULL) THEN
        l_hierarchy_cache_index := G_HIERARCHY_CACHE.LAST + 1;
      END IF;
      G_HIERARCHY_CACHE(l_hierarchy_cache_index) := l_return_value;

    ELSE
      l_return_value := G_HIERARCHY_CACHE(l_hierarchy_row_index);
    END IF;

    RETURN l_return_value;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      Debug_Msg('In Get_Hierarchy_From_AG_Type, EXCEPTION  NO_DATA_FOUND ');
      RETURN NULL;

END Get_Hierarchy_For_AG_Type;

----------------------------------------------------------------------

--
-- Private
--  Get_Changed_Attributes - returns an attribute diff table that lists
--  the old and new attribute values for the given DML operation
--
PROCEDURE Get_Changed_Attributes (
     p_dml_operation                IN  VARCHAR2
    ,p_object_name                  IN  VARCHAR2
    ,p_pk_column_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
    ,p_attr_group_metadata_obj      IN  EGO_ATTR_GROUP_METADATA_OBJ
    ,p_ext_table_metadata_obj       IN  EGO_EXT_TABLE_METADATA_OBJ
    ,p_data_level                   IN  VARCHAR2   DEFAULT NULL --R12C
    ,p_data_level_name_value_pairs  IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
    ,p_attr_name_value_pairs        IN  EGO_USER_ATTR_DATA_TABLE
    ,p_extension_id                 IN  NUMBER     DEFAULT NULL
    ,p_entity_id                    IN  NUMBER     DEFAULT NULL
    ,p_entity_index                 IN  NUMBER     DEFAULT NULL
    ,p_entity_code                  IN  VARCHAR2   DEFAULT NULL
    ,px_attr_diffs                  IN  OUT NOCOPY EGO_USER_ATTR_DIFF_TABLE
                                 )
  IS

    l_api_name                      VARCHAR2(30) := 'Get_Changed_Attributes';
    l_attrs_index                   NUMBER;
    l_dynamic_sql                   VARCHAR2(32767);

    l_data_level_string             VARCHAR2(1000);
    l_ag_predicate_list             VARCHAR2(20000);
    l_db_column_query_table         LOCAL_BIG_VARCHAR_TABLE;
    l_curr_ag_request_obj           EGO_ATTR_GROUP_REQUEST_OBJ;
    l_curr_attr_metadata_obj        EGO_ATTR_METADATA_OBJ;
    l_curr_augmented_attr_rec       LOCAL_USER_ATTR_DATA_REC;
    l_curr_aug_table_index          NUMBER;
    l_augmented_data_table          LOCAL_AUGMENTED_DATA_TABLE;
    l_table_of_high_ind_for_AG_ID   LOCAL_NUMBER_TABLE;
    l_curr_db_column_name           VARCHAR2(30);
    l_db_column_list                VARCHAR2(10000);
    l_to_char_db_col_expression     VARCHAR2(90);
    l_db_column_tables_index        NUMBER;
    l_int_to_disp_val_string        VARCHAR2(32767);
    l_db_column_name_table          LOCAL_VARCHAR_TABLE;
    l_start_index                   NUMBER;
    l_substring_length              NUMBER;
    l_temp_db_query_string          VARCHAR2(32767);
    l_pk_col_string                 VARCHAR2(1000);
    l_cursor_id                     NUMBER;
    l_extension_id                  NUMBER;
    l_dummy                         NUMBER;

    l_attr_name_value_rec           EGO_USER_ATTR_DATA_OBJ;
    l_retrieved_value               VARCHAR2(4000); --bug 12979914
    l_data_type_codes_table         LOCAL_VARCHAR_TABLE;
    l_attr_diffs_last               NUMBER;
    l_data_level_id                 NUMBER;
    l_dl_col_mdata_array            EGO_COL_METADATA_ARRAY;

  BEGIN

    Debug_Msg(l_api_name||' starting', 1);

    IF (p_dml_operation = 'INSERT') THEN

      -----------------------------------------------------------------------
      -- For the INSERT case, just record the new attribute values         --
      -----------------------------------------------------------------------
      Debug_Msg(l_api_name||' insert', 1);

      px_attr_diffs := EGO_USER_ATTR_DIFF_TABLE();
      l_attrs_index := p_attr_name_value_pairs.FIRST;
      WHILE (l_attrs_index <= p_attr_name_value_pairs.LAST)
      LOOP

        l_attr_name_value_rec := p_attr_name_value_pairs(l_attrs_index);

        l_curr_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                      p_attr_group_metadata_obj.attr_metadata_table
                                     ,l_attr_name_value_rec.ATTR_NAME
                                    );

        px_attr_diffs.EXTEND();
        px_attr_diffs(px_attr_diffs.LAST) :=
          EGO_USER_ATTR_DIFF_OBJ(l_curr_attr_metadata_obj.ATTR_ID            --  attr_id
                                ,l_curr_attr_metadata_obj.ATTR_NAME          --  attr_name
                                ,null                                        --  old_attr_value_str
                                ,null                                        --  old_attr_value_num
                                ,null                                        --  old_attr_value_date
                                ,null                                        --  old_attr_uom
                                ,l_attr_name_value_rec.ATTR_VALUE_STR        --  new_attr_value_str
                                ,l_attr_name_value_rec.ATTR_VALUE_NUM        --  new_attr_value_num
                                ,l_attr_name_value_rec.ATTR_VALUE_DATE       --  new_attr_value_date
                                ,l_attr_name_value_rec.ATTR_UNIT_OF_MEASURE  --  new_attr_uom
                                ,l_curr_attr_metadata_obj.UNIQUE_KEY_FLAG    --  unique_key_flag
                                ,null                                        --  extension_id
                                );

        l_attrs_index := p_attr_name_value_pairs.NEXT(l_attrs_index);

        Debug_Msg(l_api_name||' attr('||to_char(l_attrs_index)||
                  '):'||l_attr_name_value_rec.ATTR_NAME||
                  ' str:'||l_attr_name_value_rec.ATTR_VALUE_STR||
                  ' num:'||l_attr_name_value_rec.ATTR_VALUE_NUM||
                  ' date:'||l_attr_name_value_rec.ATTR_VALUE_DATE||
                  ' uom:'||l_attr_name_value_rec.ATTR_UNIT_OF_MEASURE);

      END LOOP;

    ELSIF (p_dml_operation = 'UPDATE' ) THEN

      -----------------------------------------------------------------------
      -- For the UPDATE case, record the new attribute values, then query  --
      -- for the old values, and pack both into the attr diffs table       --
      -----------------------------------------------------------------------
      Debug_Msg(l_api_name||' update', 1);

      -----------------------------------------------------------------------
      -- For every Attribute in our table of Attribute names, we find its  --
      -- metadata and build an augmented version of a Data record for it,  --
      -- which we then add to a table for later use in correlating a given --
      -- Database Column to the appropriate Attribute and then building an --
      -- Attr Data object for that Attr and its value.                     --
      -----------------------------------------------------------------------
      px_attr_diffs := EGO_USER_ATTR_DIFF_TABLE();
      l_attrs_index := p_attr_name_value_pairs.FIRST;
      WHILE (l_attrs_index <= p_attr_name_value_pairs.LAST)
      LOOP

        l_attr_name_value_rec := p_attr_name_value_pairs(l_attrs_index);
        l_curr_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                      p_attr_group_metadata_obj.attr_metadata_table
                                     ,l_attr_name_value_rec.ATTR_NAME
                                    );
        l_curr_augmented_attr_rec.ATTR_GROUP_ID := p_attr_group_metadata_obj.ATTR_GROUP_ID;
        l_curr_augmented_attr_rec.APPLICATION_ID := p_attr_group_metadata_obj.APPLICATION_ID;
        l_curr_augmented_attr_rec.ATTR_GROUP_TYPE := p_attr_group_metadata_obj.ATTR_GROUP_TYPE;
        l_curr_augmented_attr_rec.ATTR_GROUP_NAME := p_attr_group_metadata_obj.ATTR_GROUP_NAME;
        l_curr_augmented_attr_rec.ATTR_NAME := l_curr_attr_metadata_obj.ATTR_NAME;
        l_curr_augmented_attr_rec.ATTR_DISP_NAME := l_curr_attr_metadata_obj.ATTR_DISP_NAME;
        l_curr_augmented_attr_rec.DATABASE_COLUMN := l_curr_attr_metadata_obj.DATABASE_COLUMN;

        -----------------------------------------------------------------------
        -- Store data type codes in a local table so we don't have to call   --
        -- Find_Metadata_For_Attr again for each attribute                   --
        -----------------------------------------------------------------------
        l_data_type_codes_table(l_data_type_codes_table.COUNT+1) := l_curr_attr_metadata_obj.DATA_TYPE_CODE;

        Debug_Msg(l_api_name||' attr '||to_char(l_attrs_index)||':'||l_curr_attr_metadata_obj.ATTR_NAME, 1);

        -----------------------------------------------------------------------
        -- For now, store the new values in the diff table. Later we'll get  --
        -- the old values                                                    --
        -----------------------------------------------------------------------
        px_attr_diffs.EXTEND();
        px_attr_diffs(px_attr_diffs.LAST) :=
          EGO_USER_ATTR_DIFF_OBJ(l_curr_attr_metadata_obj.ATTR_ID           --  attr_id
                                ,l_curr_attr_metadata_obj.ATTR_NAME         --  attr_name
                                ,null                                       --  old_attr_value_str
                                ,null                                       --  old_attr_value_num
                                ,null                                       --  old_attr_value_date
                                ,null                                       --  old_attr_uom
                                ,l_attr_name_value_rec.ATTR_VALUE_STR       --  new_attr_value_str
                                ,l_attr_name_value_rec.ATTR_VALUE_NUM       --  new_attr_value_num
                                ,l_attr_name_value_rec.ATTR_VALUE_DATE      --  new_attr_value_date
                                ,l_attr_name_value_rec.ATTR_UNIT_OF_MEASURE --  new_attr_uom
                                ,l_curr_attr_metadata_obj.UNIQUE_KEY_FLAG   --  unique_key_flag
                                ,null                                       --  extension_id
                                );

        ----------------------------------------------------
        -- Record the index at which we store this record --
        ----------------------------------------------------
        l_curr_aug_table_index := l_augmented_data_table.COUNT+1;
        l_augmented_data_table(l_curr_aug_table_index) := l_curr_augmented_attr_rec;

        -----------------------------------------------------------------------------
        -- If the Database Column for this Attribute is one that has not yet been  --
        -- processed, put it into the l_db_column_name_table and put its name and  --
        -- its l_db_column_name_table index into the l_db_column_list. If this has --
        -- already been done for this column, get the index from l_db_column_list. --
        -----------------------------------------------------------------------------
        l_curr_db_column_name := l_curr_augmented_attr_rec.DATABASE_COLUMN;

        IF (l_db_column_list IS NULL OR
            INSTR(l_db_column_list, l_curr_db_column_name||':') = 0) THEN

          l_db_column_tables_index := l_db_column_name_table.COUNT+1;
          l_db_column_name_table(l_db_column_tables_index) := l_curr_db_column_name;
          l_db_column_list := l_db_column_list || l_curr_db_column_name || ':'||l_db_column_tables_index||', ';

        ELSE

          l_start_index := INSTR(l_db_column_list, l_curr_db_column_name||':') + LENGTH(l_curr_db_column_name||':');
          l_substring_length := INSTR(l_db_column_list, ',', l_start_index) - l_start_index;
          l_db_column_tables_index := TO_NUMBER(SUBSTR(l_db_column_list, l_start_index, l_substring_length));

        END IF;

        l_to_char_db_col_expression := EGO_USER_ATTRS_COMMON_PVT.Create_DB_Col_Alias_If_Needed(l_curr_attr_metadata_obj);

        ----------------------------------------------------------------------
        -- If this Attribute does not have a Value Set that distinguishes   --
        -- between Internal and Display Values, we just make sure that a    --
        -- query for this Database Column name (as determined by the index) --
        -- is in the l_db_column_query_table (we don't want to overwrite a  --
        -- possibly more complicated query with our simple formatted one,   --
        -- which is why we only add it if one doesn't already exist).       --
        ----------------------------------------------------------------------
        IF (NOT l_db_column_query_table.EXISTS(l_db_column_tables_index)) THEN
          l_db_column_query_table(l_db_column_tables_index) := l_to_char_db_col_expression;
        END IF;

        ------------------------------------------------------------
        -- We now have the formatted database column name and the --
        -- Int -> Disp value conversion query; now we see whether --
        -- there is yet a DECODE query for this database column,  --
        -- and either create one or add to the existing one       --
        ------------------------------------------------------------
        IF ((NOT l_db_column_query_table.EXISTS(l_db_column_tables_index)) OR
            l_db_column_query_table(l_db_column_tables_index) = l_to_char_db_col_expression) THEN

          IF (p_attr_group_metadata_obj.ATTR_GROUP_ID_FLAG = 'Y') THEN
            l_db_column_query_table(l_db_column_tables_index) := '' ||
            'DECODE(ATTR_GROUP_ID,'||l_curr_attr_metadata_obj.ATTR_GROUP_ID||',('||
            l_int_to_disp_val_string||l_to_char_db_col_expression||'),'||
            l_to_char_db_col_expression||') '||l_curr_db_column_name;
          ELSE
            l_db_column_query_table(l_db_column_tables_index) := '' ||
              l_to_char_db_col_expression||' '||l_curr_db_column_name;
          END IF;

        ELSE

          ---------------------------------------------------
          -- Otherwise, we get the current DECODE query... --
          ---------------------------------------------------
          l_temp_db_query_string := l_db_column_query_table(l_db_column_tables_index);

          ---------------------------------------------
          -- ...insert our new portion at index 22   --
          -- (i.e., after 'DECODE(ATTR_GROUP_ID,'... --
          ---------------------------------------------
          l_temp_db_query_string := SUBSTR(l_temp_db_query_string, 1, 21) ||
                                      l_curr_attr_metadata_obj.ATTR_GROUP_ID||',('||
                                      l_int_to_disp_val_string||
                                      l_to_char_db_col_expression||'),'||
                                      SUBSTR(l_temp_db_query_string, 22);

          -------------------------------------------------------------------------
          -- ...and put the updated query back into the l_db_column_query_table. --
          -------------------------------------------------------------------------
          l_db_column_query_table(l_db_column_tables_index) := l_temp_db_query_string;

        END IF;

        l_attrs_index := p_attr_name_value_pairs.NEXT(l_attrs_index);
      END LOOP;

      --------------------------------------------------------------------------------
      -- Now we build a query list with all of our Database Column query components --
      --------------------------------------------------------------------------------
      l_db_column_list := '';
      FOR i IN l_db_column_query_table.FIRST .. l_db_column_query_table.LAST
      LOOP

        l_db_column_list := l_db_column_list || l_db_column_query_table(i) || ',';

      END LOOP;

      -----------------------------------------------------
      -- Trim the trailing bits from the DB Column lists --
      -----------------------------------------------------
      l_db_column_list := RTRIM(l_db_column_list, ',');

      Debug_Msg(l_api_name||' pk cols '||l_pk_col_string);

      Init();
      FND_DSQL.Add_Text('SELECT EXTENSION_ID, ' ||l_db_column_list||
                         ' FROM ' ||NVL(p_attr_group_metadata_obj.EXT_TABLE_VL_NAME
                                       ,p_attr_group_metadata_obj.EXT_TABLE_B_NAME)||
                        ' WHERE ');

      ----------------------------------------------------------------------
      -- We know this call will succeed because we checked the PK columns --
      -- against the metadata in Perform_Preliminary_Checks, above        --
      ----------------------------------------------------------------------
      l_pk_col_string := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                           p_ext_table_metadata_obj.pk_column_metadata
                          ,p_pk_column_name_value_pairs
                          ,'EQUALS'
                          ,TRUE);

      -----------------------------------------------------------------------
      -- If extension ID info is available, select on it.                  --
      -----------------------------------------------------------------------
      IF (p_extension_id IS NOT NULL) THEN
        FND_DSQL.Add_Text(' AND EXTENSION_ID = ');
        Add_Bind(p_value => p_extension_id);
      END IF;

      ----------------------------------------------------------------------------
      --We add the data_level_id to the where clause, it would be passed in
      --by the implementing team if the R12C changes for enhanced data level
      --support have been taken up.
      ----------------------------------------------------------------------------
      IF(p_data_level IS NOT NULL
         AND
         FND_API.TO_BOOLEAN(
              EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(p_table_name  => p_attr_group_metadata_obj.ext_table_vl_name
                                                           ,p_column_name => 'DATA_LEVEL_ID'
                                                           )
                           )
         ) THEN

        l_data_level_id := Get_Data_Level_Id( p_attr_group_metadata_obj.APPLICATION_ID
                                             ,p_attr_group_metadata_obj.ATTR_GROUP_TYPE
                                             ,p_data_level);

        FND_DSQL.Add_Text(' AND DATA_LEVEL_ID = ');
        Add_Bind (p_bind_identifier => 'DATA_LEVEL_ID'
                 ,p_value           =>  l_data_level_id);

      END IF;

--AMAY TODO: just use EXT ID here and nothing else!!!
-- check with dylan: can we assume we have ext id at perform dml on row pvt
      Debug_Msg(l_api_name||' dyn_sql '||l_dynamic_sql);

      IF (p_attr_group_metadata_obj.ATTR_GROUP_ID_FLAG = 'Y') THEN

        ------------------------------------------------
        -- Build a predicate for each Attribute Group --
        -- and concatenate it into a master predicate --
        ------------------------------------------------
        FND_DSQL.Add_Text(' AND (ATTR_GROUP_ID = ');
        Add_Bind(p_value => p_attr_group_metadata_obj.ATTR_GROUP_ID);

        ---------------------------------------------------------------
        -- Make a string to use in the query; it will be of the form --
        -- 'DATA_LEVEL_1 = <value> AND ... DATA_LEVEL_N = <value>';  --
        -- we know this call will succeed because we built the array --
        -- of data level name/value pairs ourselves using metadata.  --
        ---------------------------------------------------------------

        l_dl_col_mdata_array:= EGO_USER_ATTRS_COMMON_PVT.Get_Data_Level_Col_Array(p_attr_group_metadata_obj.APPLICATION_ID,
                                                                                  p_attr_group_metadata_obj.ATTR_GROUP_TYPE);

        l_data_level_string := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                 l_dl_col_mdata_array
                                ,p_data_level_name_value_pairs
                                ,'EQUALS'
                                ,TRUE
                                ,' AND '
                               );
        FND_DSQL.Add_Text(')');

      END IF;

      Debug_SQL(l_dynamic_sql);

      ----------------------------------
      -- Open a cursor for processing --
      ----------------------------------
      l_cursor_id := DBMS_SQL.OPEN_CURSOR;
      FND_DSQL.Set_Cursor(l_cursor_id);

      -------------------------------------
      -- Parse our dynamic SQL statement --
      -------------------------------------
      DBMS_SQL.PARSE(l_cursor_id, FND_DSQL.Get_Text(), DBMS_SQL.NATIVE);

      ------------------------
      -- Bind our variables --
      ------------------------
      FND_DSQL.Do_Binds();

      --------------------------------------------------------------------------
      -- Register the data types of the columns we are selecting in our query --
      -- (in the VARCHAR2 case, that includes stating the maximum size that a --
      -- value in the column might be; to be safe we will use 1000 bytes).    --
      -- First we register the EXTENSION_ID and ATTR_GROUP_ID...              --
      --------------------------------------------------------------------------
      DBMS_SQL.Define_Column(l_cursor_id, 1, l_extension_id);

      -----------------------------------
      -- ...then the Database Columns. --
      -----------------------------------
      FOR i IN l_db_column_name_table.FIRST .. l_db_column_name_table.LAST
      LOOP

        --------------------------------------------------------------------
        -- We cast everything to string for assignment to ATTR_DISP_VALUE --
        --------------------------------------------------------------------
        DBMS_SQL.Define_Column(l_cursor_id, i+1, l_retrieved_value, 4000); --bug 12979914

      END LOOP;

      -------------------------------
      -- Execute our dynamic query --
      -------------------------------
      l_dummy := DBMS_SQL.Execute(l_cursor_id);

      Debug_Msg(l_api_name||' executed the query', 3);

      -----------------------------------------------------------------------
      -- Loop through the result set rows and decode the results into the  --
      -- appropriate fields of the attr diff object based on data type     --
      -----------------------------------------------------------------------

      l_attr_diffs_last := px_attr_diffs.LAST;
      WHILE (DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0)
      LOOP

        FOR i IN l_db_column_name_table.FIRST .. l_db_column_name_table.LAST
        LOOP

          ----------------------------------------------------------------------
          -- Update the correct record in attr diffs.  Use l_attr_diffs_last  --
          -- so that insertions do not affect loop iteration                  --
          ----------------------------------------------------------------------
          FOR j IN px_attr_diffs.FIRST .. l_attr_diffs_last
          LOOP

            IF (l_db_column_name_table(i) = l_augmented_data_table(j).DATABASE_COLUMN) THEN

              DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_extension_id);

              ------------------------------------------------
              -- We use i+1 because of the offset caused by --
              -- requesting EXTENSION_ID                    --
              ------------------------------------------------
              DBMS_SQL.COLUMN_VALUE(l_cursor_id, i+1, l_retrieved_value);

              Debug_Msg(l_api_name||' db col: '||l_db_column_name_table(i)||' val: '||l_retrieved_value, 1);

              IF (px_attr_diffs(j).OLD_ATTR_VALUE_NUM IS NULL AND
                  px_attr_diffs(j).OLD_ATTR_VALUE_DATE IS NULL AND
                  px_attr_diffs(j).OLD_ATTR_VALUE_STR IS NULL) THEN

                ---------------------------------------------------
                -- No entry exists in diff table for this column --
                ---------------------------------------------------
                px_attr_diffs(j).EXTENSION_ID := l_extension_id;

                IF (l_data_type_codes_table(j) = 'N') THEN
                  px_attr_diffs(j).OLD_ATTR_VALUE_NUM :=
                    TO_NUMBER(l_retrieved_value);
                ELSIF (l_data_type_codes_table(j) = 'X') THEN
                  px_attr_diffs(j).OLD_ATTR_VALUE_DATE :=
                    TRUNC(TO_DATE(l_retrieved_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));
                ELSIF (l_data_type_codes_table(j) = 'Y') THEN
                  px_attr_diffs(j).OLD_ATTR_VALUE_DATE :=
                    TO_DATE(l_retrieved_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
                ELSE
                  px_attr_diffs(j).OLD_ATTR_VALUE_STR := l_retrieved_value;
                END IF;

              ELSE

                ---------------------------------------------------
                -- An entry already exists in diff table for     --
                -- this column, so add a new record at the end   --
                ---------------------------------------------------
                px_attr_diffs.EXTEND();
                px_attr_diffs(px_attr_diffs.LAST) :=
                       EGO_USER_ATTR_DIFF_OBJ(px_attr_diffs(j).ATTR_ID         --  attr_id
                                             ,px_attr_diffs(j).ATTR_NAME       --  attr_name
                                             ,null                             --  old_attr_value_str
                                             ,null                             --  old_attr_value_num
                                             ,null                             --  old_attr_value_date
                                             ,null                             --  old_attr_uom
                                             ,null                             --  new_attr_value_str
                                             ,null                             --  new_attr_value_num
                                             ,null                             --  new_attr_value_date
                                             ,null                             --  new_attr_uom
                                             ,px_attr_diffs(j).UNIQUE_KEY_FLAG --  unique_key_flag
                                             ,l_extension_id                   --  extension_id
                                             );
                IF (l_data_type_codes_table(j) = 'N') THEN
                  px_attr_diffs(px_attr_diffs.LAST).OLD_ATTR_VALUE_NUM :=
                    TO_NUMBER(l_retrieved_value);
                ELSIF (l_data_type_codes_table(j) = 'X') THEN
                  px_attr_diffs(px_attr_diffs.LAST).OLD_ATTR_VALUE_DATE :=
                    TRUNC(TO_DATE(l_retrieved_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));
                ELSIF (l_data_type_codes_table(j) = 'Y') THEN
                  px_attr_diffs(px_attr_diffs.LAST).OLD_ATTR_VALUE_DATE :=
                    TO_DATE(l_retrieved_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
                ELSE
                  px_attr_diffs(px_attr_diffs.LAST).OLD_ATTR_VALUE_STR := l_retrieved_value;
                END IF;

              END IF;

            END IF;
          END LOOP;
        END LOOP;
      END LOOP;

      -----------------------------------------
      -- Close the cursor when we're through --
      -----------------------------------------
      IF (l_cursor_id IS NOT NULL) THEN
        DBMS_SQL.Close_Cursor(l_cursor_id);
        l_cursor_id := NULL;
      END IF;
    -- Start ssingal -For Ucc Net Attribute Propagation
    ELSIF (p_dml_operation = 'DELETE' ) THEN
      Debug_Msg(l_api_name||' Transaction Type is Delete ', 1);

      px_attr_diffs    :=      EGO_USER_ATTR_DIFF_TABLE();
      l_attrs_index    :=      p_attr_name_value_pairs.FIRST;

      WHILE (l_attrs_index <= p_attr_name_value_pairs.LAST)
      LOOP
        l_attr_name_value_rec :=  p_attr_name_value_pairs(l_attrs_index);
        l_curr_attr_metadata_obj :=   EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr
                                      (
                                        p_attr_group_metadata_obj.attr_metadata_table,
                                        l_attr_name_value_rec.ATTR_NAME
                                      );
         px_attr_diffs.EXTEND();
         -- For Transaction Type Delete
         -- Pass the old Attribute Data
         -- in the Diff Object
         px_attr_diffs(px_attr_diffs.LAST) :=
                       EGO_USER_ATTR_DIFF_OBJ(l_curr_attr_metadata_obj.ATTR_ID            --  attr_id
                                             ,l_curr_attr_metadata_obj.ATTR_NAME          --  attr_name
                                             ,l_attr_name_value_rec.ATTR_VALUE_STR        --  old_attr_value_str
                                             ,l_attr_name_value_rec.ATTR_VALUE_NUM        --  old_attr_value_num
                                             ,l_attr_name_value_rec.ATTR_VALUE_DATE       --  old_attr_value_date
                                             ,l_attr_name_value_rec.ATTR_UNIT_OF_MEASURE  --  old_attr_uom
                                             ,null                                        --  new_attr_value_str
                                             ,null                                        --  new_attr_value_num
                                             ,null                                        --  new_attr_value_date
                                             ,null                                        --  new_attr_uom
                                             ,l_curr_attr_metadata_obj.UNIQUE_KEY_FLAG    --  unique_key_flag
                                             ,null                                        --  extension_id
                                             );
        l_attrs_index         :=      p_attr_name_value_pairs.NEXT(l_attrs_index);

      END LOOP;
    END IF;
    -- End ssingal -For Ucc Net Attribute Propagation

    -----------------------------------------
    -- Display what's in the diff object   --
    -----------------------------------------
    FOR a IN px_attr_diffs.FIRST .. px_attr_diffs.LAST
    LOOP

      Debug_Msg(l_api_name||' diff '||a||':'||
                px_attr_diffs(a).ATTR_ID||','||px_attr_diffs(a).OLD_ATTR_VALUE_STR||','||
                px_attr_diffs(a).OLD_ATTR_VALUE_NUM||','||px_attr_diffs(a).OLD_ATTR_VALUE_DATE||','||
                px_attr_diffs(a).OLD_ATTR_UOM||','||px_attr_diffs(a).NEW_ATTR_VALUE_STR||','||
                px_attr_diffs(a).NEW_ATTR_VALUE_NUM||','||px_attr_diffs(a).NEW_ATTR_VALUE_DATE||','||
                px_attr_diffs(a).NEW_ATTR_UOM||','||px_attr_diffs(a).UNIQUE_KEY_FLAG||','||
                px_attr_diffs(a).EXTENSION_ID);

    END LOOP;

    Debug_Msg(l_api_name||' done', 1);

  EXCEPTION
  WHEN OTHERS THEN
    Debug_Msg(l_api_name||' API failed: '||SQLERRM, 1);
    RETURN;

END Get_Changed_Attributes;

----------------------------------------------------------------------

--
-- Private
--
PROCEDURE Propagate_Attributes (
          p_pk_column_name_value_pairs    IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_class_code_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_data_level_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_attr_diffs                    IN  EGO_USER_ATTR_DIFF_TABLE
        , p_transaction_type              IN  VARCHAR2
        , p_attr_group_metadata_obj       IN  EGO_ATTR_GROUP_METADATA_OBJ
        , x_return_status                 OUT NOCOPY VARCHAR2
        , x_error_message                 OUT NOCOPY VARCHAR2
        )
  IS
    l_dynamic_sql           VARCHAR2(4000);
  BEGIN

    Debug_Msg('In Propagate_Attributes, starting', 1);

    IF (p_attr_group_metadata_obj.HIERARCHY_PROPAGATION_API IS NOT NULL) THEN

      Debug_Msg('In Propagate_Attributes, executing API: '||p_attr_group_metadata_obj.HIERARCHY_PROPAGATION_API, 1);

      BEGIN

        EXECUTE IMMEDIATE 'BEGIN '||p_attr_group_metadata_obj.HIERARCHY_PROPAGATION_API||'(:1, :2, :3, :4, :5, :6, :7); END;'
        USING  IN  p_pk_column_name_value_pairs
       , IN  p_class_code_name_value_pairs
       , IN  p_data_level_name_value_pairs
             , IN  p_attr_diffs
             , IN  p_transaction_type
             , IN  p_attr_group_metadata_obj.ATTR_GROUP_ID
             , OUT x_error_message;

      EXCEPTION
        WHEN OTHERS THEN
          Debug_Msg('In Propagate_Attributes, API failed: '||SQLERRM, 1);
          x_return_status := G_RET_STS_UNEXP_ERROR;
          x_error_message := SQLERRM;
          RETURN;
      END;

    END IF;
    IF x_error_message IS NULL THEN
      x_return_status := G_RET_STS_SUCCESS;
      Debug_Msg('In Propagate_Attributes, returned successfully ', 1);
    ELSE
      x_return_status := G_RET_STS_ERROR;
      Debug_Msg('In Propagate_Attributes, returned with error: '||x_error_message, 1);
    END IF;

    Debug_Msg('In Propagate_Attributes, done', 1);

END Propagate_Attributes;

----------------------------------------------------------------------

--
-- Private
--
PROCEDURE Convert_Attr_Diff_To_Data (
          p_attr_diff_tbl                 IN EGO_USER_ATTR_DIFF_TABLE
        , px_attr_data_tbl                IN OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
        , p_true_if_new                   IN BOOLEAN := TRUE
        -- px_is_delete returns true if this diff object contains a delete operation
        , px_is_delete                    OUT NOCOPY BOOLEAN
        , x_error_message                 OUT NOCOPY VARCHAR2
        )
  IS
    l_dynamic_sql           VARCHAR2(4000);
    l_row_identifier        NUMBER;
    l_debug_msg             VARCHAR2(10);
  BEGIN

    Debug_Msg('In Convert_Attr_Diff_To_data, starting', 1);
    px_is_delete := TRUE;

    IF p_attr_diff_tbl IS NOT NULL THEN

      FOR i IN p_attr_diff_tbl.FIRST..p_attr_diff_tbl.LAST LOOP

        IF px_attr_data_tbl IS NULL THEN
          Debug_Msg('In Convert_Attr_Diff_To_Data, px_attr_data_tbl is NULL', 1);
          px_attr_data_tbl := EGO_USER_ATTR_DATA_TABLE();
        END IF;

        -- Set row identifier based on previous contents of diff table
        l_row_identifier := 1;
        FOR j IN p_attr_diff_tbl.FIRST..i-1 LOOP

          IF (p_attr_diff_tbl(i).ATTR_NAME = p_attr_diff_tbl(j).ATTR_NAME) THEN

            l_row_identifier := l_row_identifier + 1;

          END IF;

        END LOOP;

        px_attr_data_tbl.EXTEND;

        IF (p_true_if_new) THEN
          px_attr_data_tbl(i) :=
            EGO_USER_ATTR_DATA_OBJ
      ( l_row_identifier
      , p_attr_diff_tbl(i).ATTR_NAME
      , p_attr_diff_tbl(i).NEW_ATTR_VALUE_STR
      , p_attr_diff_tbl(i).NEW_ATTR_VALUE_NUM
      , p_attr_diff_tbl(i).NEW_ATTR_VALUE_DATE
      , NULL--p_attr_diff_tbl(i).ATTR_DISP_VALUE
      , p_attr_diff_tbl(i).NEW_ATTR_UOM
      , NULL--p_attr_diff_tbl(i).USER_ROW_IDENTIFIER
      );
        ELSE
          px_attr_data_tbl(i) :=
            EGO_USER_ATTR_DATA_OBJ
      ( l_row_identifier
      , p_attr_diff_tbl(i).ATTR_NAME
      , p_attr_diff_tbl(i).OLD_ATTR_VALUE_STR
      , p_attr_diff_tbl(i).OLD_ATTR_VALUE_NUM
      , p_attr_diff_tbl(i).OLD_ATTR_VALUE_DATE
      , NULL--p_attr_diff_tbl(i).ATTR_DISP_VALUE
      , p_attr_diff_tbl(i).OLD_ATTR_UOM
      , NULL--p_attr_diff_tbl(i).USER_ROW_IDENTIFIER
      );
        END IF;

        -- turn px_is_delete off/false if we find a new attribute value
        IF px_is_delete AND
           (p_attr_diff_tbl(i).NEW_ATTR_VALUE_STR IS NOT NULL OR
            p_attr_diff_tbl(i).NEW_ATTR_VALUE_NUM IS NOT NULL OR
            p_attr_diff_tbl(i).NEW_ATTR_VALUE_DATE IS NOT NULL OR
            p_attr_diff_tbl(i).NEW_ATTR_UOM IS NOT NULL)
        THEN

          px_is_delete := FALSE;

        END IF;

      END LOOP;

    END IF;

    if px_is_delete
    then
      l_debug_msg := 'True' ;
    else
      l_debug_msg := 'False' ;
    end if;

    Debug_Msg('In Convert_Attr_Diff_To_Data, done, px_is_delete = '||l_debug_msg);

END Convert_Attr_Diff_To_Data;


----------------------------------------------------------------------
--
-- Private
--
FUNCTION Build_Sorted_Data_Table (
        p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
)
RETURN LOCAL_USER_ATTR_DATA_TABLE
IS


    l_attr_data_table_index  NUMBER;
    l_current_data_element   EGO_USER_ATTR_DATA_OBJ;
    l_current_row_id         NUMBER;
    l_row_id_ordinality_table LOCAL_NUMBER_TABLE;
    l_row_id_ordinality      NUMBER;
    l_sorted_data_index_table LOCAL_NUMBER_TABLE;
    l_s_a_d_table_index      NUMBER;
    l_sorted_attr_data_table LOCAL_USER_ATTR_DATA_TABLE;
    l_sorted_row_id_table    LOCAL_NUMBER_TABLE;
 	  l_sorted_data_element    EGO_USER_ATTR_DATA_TABLE;
 	  temp                     EGO_USER_ATTR_DATA_OBJ;

  BEGIN

    Debug_Msg('In Build_Sorted_Data_Table, starting', 2);

    ----------------------------------------------------------------------
    -- This function sorts the elements of p_attributes_data_table by   --
    -- ROW_IDENTIFIER.  It works by putting all elements for each       --
    -- distinct ROW_IDENTIFIER into their own "region" of an index-by   --
    -- table, l_sorted_attr_data_table.  To keep track of the correct   --
    -- index in each region at which we will insert the next element,   --
    -- we use two "helper tables": l_row_id_ordinality_table, the first --
    -- helper table, stores the ordinal number of each ROW_IDENTIFIER,  --
    -- and l_sorted_data_index_table, the second helper table, stores   --
    -- the next available index in the ROW_IDENTIFIER region for the    --
    -- ordinal number we fetched from l_row_id_ordinality_table.  This  --
    -- solution will allow us to process 1000 rows of data in each call --
    -- with 1000 elements for each row of data.                         --
    --                                                                  --
    -- EXAMPLE: we have two ROW_IDENTIFIERs: 1678 and 239330, and each  --
    -- of these ROW_IDENTIFIERs has five elements.  So this function    --
    -- loops through all ten passed-in elements and sorts them by       --
    -- ROW_IDENTIFIER, as follows (for three of the ten elements).      --
    -- First element ROW_IDENTIFIER is 239330.  Since there's nothing   --
    -- in l_row_id_ordinality_table for 239330, we add an entry with    --
    -- 239330 as the key and 1 (l_row_id_ordinality_table's current     --
    -- count + 1) as the value.  That value, 1, is now the ordinal      --
    -- number of 239330 (because 239330 is the *1*st ROW_IDENTIFIER     --
    -- we processed).  We use this ordinality to determine that the     --
    -- region in l_sorted_attr_data_table for 239330 is the region      --
    -- starting at (1 * 1000) = 1000.  Since this is the first element  --
    -- for this region, the first available index will be 1000, which   --
    -- we store in l_sorted_data_index_table.  Then, when we fetch      --
    -- the index, we increment the next available index to 1001.        --
    -- We use 1000 to add the first element to l_sorted_data_table.     --
    -- Second element ROW_IDENTIFIER is 1678.  Since there's nothing    --
    -- in l_row_id_ordinality_table for 1678, we add an entry with      --
    -- 1678 as the key and 2 (l_row_id_ordinality_table's current       --
    -- count + 1) as the value.  That value, 2, is now the ordinal      --
    -- number of 1678 (because 1678 is the *2*nd ROW_IDENTIFIER         --
    -- we processed).  We use this ordinality to determine that the     --
    -- region in l_sorted_attr_data_table for 1678 is the region        --
    -- starting at (2 * 1000) = 2000.  Since this is the first element  --
    -- for this region, the first available index will be 2000, which   --
    -- we store in l_sorted_data_index_table.  Then, when we fetch      --
    -- the index, we increment the next available index to 2001.        --
    -- We use 2000 to add the second element to l_sorted_data_table.    --
    -- Third element ROW_IDENTIFIER is 239330.  We find the ordinality  --
    -- for 239330 from l_row_id_ordinality_table as 1, and we use that  --
    -- to find the next available index from l_sorted_data_index_table  --
    -- as 1001.  Then we increment the next available index to 1002,    --
    -- and we use 1001 to add the third element to l_sorted_data_table. --
    ----------------------------------------------------------------------
    /*l_attr_data_table_index := p_attributes_data_table.FIRST;
    WHILE (l_attr_data_table_index <= p_attributes_data_table.LAST)
    LOOP

      l_current_data_element := p_attributes_data_table(l_attr_data_table_index);
      l_current_row_id := l_current_data_element.ROW_IDENTIFIER;

      IF (NOT l_row_id_ordinality_table.EXISTS(l_current_row_id)) THEN
        l_row_id_ordinality_table(l_current_row_id) := l_row_id_ordinality_table.COUNT + 1;
      END IF;
      l_row_id_ordinality := l_row_id_ordinality_table(l_current_row_id);

      IF (NOT l_sorted_data_index_table.EXISTS(l_row_id_ordinality)) THEN
        l_sorted_data_index_table(l_row_id_ordinality) := l_row_id_ordinality * 1000;
      END IF;
      l_s_a_d_table_index := l_sorted_data_index_table(l_row_id_ordinality);
      l_sorted_data_index_table(l_row_id_ordinality) :=
        l_sorted_data_index_table(l_row_id_ordinality) + 1;

      l_sorted_attr_data_table(l_s_a_d_table_index) := l_current_data_element;

      l_attr_data_table_index := p_attributes_data_table.NEXT(l_attr_data_table_index);
    END LOOP;

    Debug_Msg('In Build_Sorted_Data_Table, p_attributes_data_table.COUNT is '||
              p_attributes_data_table.COUNT||' and l_sorted_attr_data_table.COUNT is '||
              l_sorted_attr_data_table.COUNT);
    Debug_Msg('In Build_Sorted_Data_Table, done', 2);*/

		--bug 7711838 commented the above as this will not sort the data table records based on row identifier
 	     --Simply it will group all the records with the same Row Identifier according to the order in which they are
 	     --in Data table. Actual sorting will not take place
 	     --7711838 begin


             --
             -- Bug 12626471. PLSQL numeric or value error is thrown
             -- if p_attributes_data_table is passed NULL. It can be
             -- passed null for DELETE mode. Adding a NULL check.
             -- sreharih. Tue Aug  2 12:14:29 PDT 2011
             --
          IF  p_attributes_data_table IS NOT NULL AND p_attributes_data_table.COUNT > 0 THEN
 	     l_attr_data_table_index := p_attributes_data_table.FIRST;
 	     l_sorted_data_element:=  p_attributes_data_table;
 	     FOR i IN  l_sorted_data_element.FIRST .. l_sorted_data_element.LAST
 	     LOOP
 	        FOR j IN i+1 .. l_sorted_data_element.LAST
 	        LOOP
 	             IF(l_sorted_data_element(i).ROW_IDENTIFIER >= l_sorted_data_element(j).ROW_IDENTIFIER) THEN
 	                  temp := l_sorted_data_element(i);
 	                  l_sorted_data_element(i):=l_sorted_data_element(j);
 	                  l_sorted_data_element(j):=temp;
 	             END IF;
 	        END LOOP ;
 	     END LOOP;

 	     l_attr_data_table_index := l_sorted_data_element.FIRST;

 	     WHILE (l_attr_data_table_index <= l_sorted_data_element.LAST)
 	     LOOP
 	       l_current_data_element := l_sorted_data_element(l_attr_data_table_index);
 	       l_current_row_id := l_current_data_element.ROW_IDENTIFIER;
 	       l_sorted_attr_data_table(l_attr_data_table_index) := l_current_data_element;
 	       l_attr_data_table_index := l_sorted_data_element.NEXT(l_attr_data_table_index);
 	     END LOOP;

          END IF;
 	    -- 7711838 end

    RETURN l_sorted_attr_data_table;

END Build_Sorted_Data_Table;

----------------------------------------------------------------------

--
-- Private
--
FUNCTION Build_Sorted_Row_Table (
        p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
) RETURN LOCAL_USER_ATTR_ROW_TABLE IS

    l_sorted_attr_row_table  LOCAL_USER_ATTR_ROW_TABLE;
    l_attr_row_table_index   NUMBER;
    l_current_row_element    EGO_USER_ATTR_ROW_OBJ;
    l_current_row_id         NUMBER;
    l_row_id_index_table     LOCAL_NUMBER_TABLE;

  BEGIN

    Debug_Msg('In Build_Sorted_Row_Table, starting', 2);

    l_attr_row_table_index := p_attributes_row_table.FIRST;
    WHILE (l_attr_row_table_index <= p_attributes_row_table.LAST)
    LOOP

      l_current_row_element := p_attributes_row_table(l_attr_row_table_index);
      l_current_row_id := l_current_row_element.ROW_IDENTIFIER;
      l_sorted_attr_row_table(l_current_row_id) := l_current_row_element;

      l_attr_row_table_index := p_attributes_row_table.NEXT(l_attr_row_table_index);
    END LOOP;

    Debug_Msg('In Build_Sorted_Row_Table, done', 2);

    RETURN l_sorted_attr_row_table;

END Build_Sorted_Row_Table;

----------------------------------------------------------------------

--
-- Private
--
FUNCTION Get_Object_Id_From_Name (
        p_object_name                   IN   VARCHAR2
)
RETURN NUMBER
IS

    l_object_name_table_index NUMBER;
    l_object_id              NUMBER;

  BEGIN

    Debug_Msg('In Get_Object_Id_From_Name, starting for p_object_name '||p_object_name, 2);

    IF (G_OBJECT_NAME_TO_ID_CACHE.FIRST IS NOT NULL) THEN
      l_object_name_table_index := G_OBJECT_NAME_TO_ID_CACHE.FIRST;
      WHILE (l_object_name_table_index <= G_OBJECT_NAME_TO_ID_CACHE.LAST)
      LOOP
        EXIT WHEN (l_object_id IS NOT NULL);

        IF (G_OBJECT_NAME_TO_ID_CACHE(l_object_name_table_index) = p_object_name) THEN
          l_object_id := l_object_name_table_index;
        END IF;

        l_object_name_table_index := G_OBJECT_NAME_TO_ID_CACHE.NEXT(l_object_name_table_index);
      END LOOP;
    END IF;

    IF (l_object_id IS NULL) THEN

      SELECT OBJECT_ID
        INTO l_object_id
        FROM FND_OBJECTS
       WHERE OBJ_NAME = p_object_name;

      G_OBJECT_NAME_TO_ID_CACHE(l_object_id) := p_object_name;

    END IF;

    Debug_Msg('In Get_Object_Id_From_Name, done: returning l_object_id as '||l_object_id, 2);

    RETURN l_object_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      Debug_Msg('In Get_Object_Id_From_Name, EXCEPTION NO_DATA_FOUND', 1);
      RETURN NULL;

END Get_Object_Id_From_Name;

----------------------------------------------------------------------

--
-- Private
--
FUNCTION Build_Data_Level_Array (
        p_object_name       IN  VARCHAR2
       ,p_data_level_id     IN  NUMBER DEFAULT NULL
       ,p_data_level_1      IN  VARCHAR2
       ,p_data_level_2      IN  VARCHAR2
       ,p_data_level_3      IN  VARCHAR2
       ,p_data_level_4      IN  VARCHAR2
       ,p_data_level_5      IN  VARCHAR2
)
RETURN EGO_COL_NAME_VALUE_PAIR_ARRAY
IS

    l_object_id                     NUMBER;
    l_ext_table_metadata_obj        EGO_EXT_TABLE_METADATA_OBJ;
    l_data_level_metadata_array     EGO_COL_METADATA_ARRAY;
    l_data_level_1_name_value_pair  EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_data_level_2_name_value_pair  EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_data_level_3_name_value_pair  EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_data_level_4_name_value_pair  EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_data_level_5_name_value_pair  EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_data_level_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_data_level_metadata           EGO_DATA_LEVEL_METADATA_OBJ;
  BEGIN

    Debug_Msg('In Build_Data_Level_Array, starting', 2);

    -----------------------------------------------------------------
    -- Added for R12C, in case the data_level_id is passed we need --
    -- to process it accordingly.                                  --
    -----------------------------------------------------------------
    IF(p_data_level_id IS NOT NULL) THEN

      l_data_level_metadata := EGO_USER_ATTRS_COMMON_PVT.get_data_level_metadata(p_data_level_id);
      IF(l_data_level_metadata.PK_COLUMN_NAME1 IS NOT NULL) THEN
         l_data_level_1_name_value_pair := EGO_COL_NAME_VALUE_PAIR_OBJ(l_data_level_metadata.PK_COLUMN_NAME1,p_data_level_1);
      END IF;

      IF(l_data_level_metadata.PK_COLUMN_NAME2 IS NOT NULL) THEN
         l_data_level_2_name_value_pair := EGO_COL_NAME_VALUE_PAIR_OBJ(l_data_level_metadata.PK_COLUMN_NAME2,p_data_level_2);
      END IF;

      IF(l_data_level_metadata.PK_COLUMN_NAME3 IS NOT NULL) THEN
         l_data_level_3_name_value_pair := EGO_COL_NAME_VALUE_PAIR_OBJ(l_data_level_metadata.PK_COLUMN_NAME3,p_data_level_3);
      END IF;

      IF(l_data_level_metadata.PK_COLUMN_NAME4 IS NOT NULL) THEN
         l_data_level_4_name_value_pair := EGO_COL_NAME_VALUE_PAIR_OBJ(l_data_level_metadata.PK_COLUMN_NAME4,p_data_level_4);
      END IF;

      IF(l_data_level_metadata.PK_COLUMN_NAME5 IS NOT NULL) THEN
         l_data_level_5_name_value_pair := EGO_COL_NAME_VALUE_PAIR_OBJ(l_data_level_metadata.PK_COLUMN_NAME5,p_data_level_5);
      END IF;

      IF (l_data_level_5_name_value_pair IS NOT NULL) THEN
        l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                           l_data_level_1_name_value_pair
                                          ,l_data_level_2_name_value_pair
                                          ,l_data_level_3_name_value_pair
                                          ,l_data_level_4_name_value_pair
                                          ,l_data_level_5_name_value_pair
                                         );
      ELSIF (l_data_level_4_name_value_pair IS NOT NULL) THEN
        l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                           l_data_level_1_name_value_pair
                                          ,l_data_level_2_name_value_pair
                                          ,l_data_level_3_name_value_pair
                                          ,l_data_level_4_name_value_pair
                                         );
      ELSIF (l_data_level_3_name_value_pair IS NOT NULL) THEN
        l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                           l_data_level_1_name_value_pair
                                          ,l_data_level_2_name_value_pair
                                          ,l_data_level_3_name_value_pair
                                         );
      ELSIF (l_data_level_2_name_value_pair IS NOT NULL) THEN
        l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                           l_data_level_1_name_value_pair
                                          ,l_data_level_2_name_value_pair
                                         );
      ELSIF (l_data_level_1_name_value_pair IS NOT NULL) THEN
        l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                           l_data_level_1_name_value_pair
                                         );
      ELSE
        l_data_level_name_value_pairs := NULL;
      END IF;
    IF (l_data_level_name_value_pairs IS NOT NULL AND l_data_level_name_value_pairs.COUNT IS NOT NULL) THEN
      Debug_Msg('In Build_Data_Level_Array, l_data_level_name_value_pairs.COUNT is ' ||l_data_level_name_value_pairs.COUNT);
    ELSE
      Debug_Msg('In Build_Data_Level_Array, l_data_level_name_value_pairs is NULL or empty');
    END IF;
      RETURN l_data_level_name_value_pairs;

    END IF;
    -----------------------------------------------------------------------------R12C end
    l_object_id := Get_Object_Id_From_Name(p_object_name);
    l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(l_object_id);
    l_data_level_metadata_array := l_ext_table_metadata_obj.data_level_metadata;

    IF (l_data_level_metadata_array IS NOT NULL AND l_data_level_metadata_array(1) IS NOT NULL) THEN
      l_data_level_1_name_value_pair := EGO_COL_NAME_VALUE_PAIR_OBJ(
                                          l_data_level_metadata_array(1).COL_NAME
                                         ,p_data_level_1
                                        );
      IF (l_data_level_metadata_array.EXISTS(2) AND l_data_level_metadata_array(2) IS NOT NULL) THEN
        l_data_level_2_name_value_pair := EGO_COL_NAME_VALUE_PAIR_OBJ(
                                            l_data_level_metadata_array(2).COL_NAME
                                           ,p_data_level_2
                                          );
        IF (l_data_level_metadata_array.EXISTS(3) AND l_data_level_metadata_array(3) IS NOT NULL) THEN
          l_data_level_3_name_value_pair := EGO_COL_NAME_VALUE_PAIR_OBJ(
                                            l_data_level_metadata_array(3).COL_NAME
                                           ,p_data_level_3
                                          );
        END IF;
      END IF;

      IF (l_data_level_3_name_value_pair IS NOT NULL) THEN
        l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                           l_data_level_1_name_value_pair
                                          ,l_data_level_2_name_value_pair
                                          ,l_data_level_3_name_value_pair
                                         );
      ELSIF (l_data_level_2_name_value_pair IS NOT NULL) THEN
        l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                           l_data_level_1_name_value_pair
                                          ,l_data_level_2_name_value_pair
                                         );
      ELSE
        l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                           l_data_level_1_name_value_pair
                                         );

      END IF;
    END IF;

    IF (l_data_level_name_value_pairs IS NOT NULL AND l_data_level_name_value_pairs.COUNT IS NOT NULL) THEN
      Debug_Msg('In Build_Data_Level_Array, l_data_level_name_value_pairs.COUNT is ' ||l_data_level_name_value_pairs.COUNT);
    ELSE
      Debug_Msg('In Build_Data_Level_Array, l_data_level_name_value_pairs is NULL or empty');
    END IF;
    Debug_Msg('In Build_Data_Level_Array, done', 2);

    RETURN l_data_level_name_value_pairs;

END Build_Data_Level_Array;

----------------------------------------------------------------------

--
-- Private
--
FUNCTION Format_Sysdate_Expression (
        p_sysdate_expression    IN   VARCHAR2
)
RETURN VARCHAR2
IS
    l_dynamic_sql         VARCHAR2(200);
    l_formatted_string    VARCHAR2(150);

  BEGIN

    --------------------------------------------------------------
    -- We need to remove any '$' chars used to tokenize Sysdate --
    -- (these are used when the Value Set bounds are defined).  --
    --------------------------------------------------------------
    l_formatted_string := TRIM(REPLACE(p_sysdate_expression, '$'));

    ----------------------------------------------------------------
    -- Now we rely on dynamic SQL to treat the bound string as an --
    -- expression for a Date object, and we call TO_CHAR on it to --
    -- turn it into a string version of that Date, formatted into --
    -- our standard format.                                       --
    ----------------------------------------------------------------
    l_dynamic_sql := 'SELECT TO_CHAR('||l_formatted_string||', '''||
                     EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||''') FROM DUAL';
    Debug_Msg('In Format_Sysdate_Expression, l_dynamic_sql is as follows:', 3);
    Debug_SQL(l_dynamic_sql);
    EXECUTE IMMEDIATE l_dynamic_sql INTO l_formatted_string;

    RETURN l_formatted_string;

END Format_Sysdate_Expression;

----------------------------------------------------------------------

--
-- Private
--
FUNCTION Find_Name_Value_Pair_For_Attr (
        p_attr_name_value_pairs   IN  EGO_USER_ATTR_DATA_TABLE
       ,p_attr_name               IN  VARCHAR2
)
RETURN EGO_USER_ATTR_DATA_OBJ
IS

    l_table_index     NUMBER;
    l_attr_data_obj   EGO_USER_ATTR_DATA_OBJ;

  BEGIN

    Debug_Msg('In Find_Name_Value_Pair_For_Attr, starting for p_attr_name '||p_attr_name, 2);

    IF (p_attr_name_value_pairs IS NOT NULL AND
        p_attr_name_value_pairs.COUNT > 0) THEN

      l_table_index := p_attr_name_value_pairs.FIRST;

      IF (p_attr_name IS NOT NULL) THEN

        WHILE (l_table_index <= p_attr_name_value_pairs.LAST)
        LOOP
          EXIT WHEN (p_attr_name_value_pairs(l_table_index).ATTR_NAME = p_attr_name);

          l_table_index := p_attr_name_value_pairs.NEXT(l_table_index);
        END LOOP;

        -----------------------------------------------
        -- Make sure we have the correct table index --
        -----------------------------------------------
        IF (l_table_index IS NOT NULL AND
            p_attr_name_value_pairs(l_table_index).ATTR_NAME = p_attr_name) THEN
          l_attr_data_obj := p_attr_name_value_pairs(l_table_index);
        END IF;
      END IF;
    END IF;

    Debug_Msg('In Find_Name_Value_Pair_For_Attr, done', 2);

    RETURN l_attr_data_obj;

END Find_Name_Value_Pair_For_Attr;

----------------------------------------------------------------------

--
-- Private
--
FUNCTION Find_Metadata_For_Col (
        p_ext_table_col_metadata  IN  EGO_COL_METADATA_ARRAY
       ,p_col_name                IN  VARCHAR2
)
RETURN EGO_COL_METADATA_OBJ
IS

    l_col_metadata_index  NUMBER;
    l_col_metadata_obj    EGO_COL_METADATA_OBJ;

  BEGIN

    l_col_metadata_index := p_ext_table_col_metadata.FIRST;
    WHILE (l_col_metadata_index <= p_ext_table_col_metadata.LAST)
    LOOP
      EXIT WHEN (l_col_metadata_obj IS NOT NULL);

      IF (UPPER(p_col_name) = UPPER(p_ext_table_col_metadata(l_col_metadata_index).COL_NAME)) THEN
        l_col_metadata_obj := p_ext_table_col_metadata(l_col_metadata_index);
      END IF;


      Debug_Msg('In Find_Metadata_For_Col, next metadata column found - ' ||
                UPPER(p_ext_table_col_metadata(l_col_metadata_index).COL_NAME), 5);

      l_col_metadata_index := p_ext_table_col_metadata.NEXT(l_col_metadata_index);
    END LOOP;

    RETURN l_col_metadata_obj;

  EXCEPTION
    WHEN OTHERS THEN
      Debug_Msg('In Find_Metadata_For_Col, EXCEPTION OTHERS', 1);
      RETURN NULL;

END Find_Metadata_For_Col;

----------------------------------------------------------------------

--
-- Private
--
-- This procedure adds text and/or bind variables, as appropriate, to a dynamic SQL
-- statement being constructed using the FND_DSQL package.  We assume that we are
-- in the midst of building a statement, so we do not call Init().
-- The procedure appends a final p_separator value onto the FND_DSQL list
--
-- The procedure's allowable p_mode values are:
-- 'VALUES': adds bind variables for Attr values, separated appropriately, to FND_DSQL
-- 'VALUES_DEF': special case of VALUES that uses DEFAULT_VALUE for any NULL Attributes
-- 'COLUMNS': adds a comma-delimited list of ext table column names and no bind variables
-- 'COLUMNS_DEF': special case of COLUMNS to match with VALUES_DEF
-- 'EQUALS': adds a list of elements of the form 'ColumnN = :N', where N is a number;
--           the bind variables are added by calls to Add_Bind(), passing the
--           relevant Attribute data values
--
-- The parameter p_which_attrs determines which Attributes are considered in processing
-- NOTE: if p_mode is 'VALUES_DEF' or 'COLUMNS_DEF', *ALL* Attributes will be considered,
-- but the rest of the constraints below will still apply for the p_which_attrs values:
-- 'ALL': processes all Attributes in p_attr_metadata_table
-- 'TRANS': processes passed-in Attributes of data type Translatable Text
-- 'NONTRANS': processes passed-in Attributes that are *not* Translatable Text
-- 'UNIQUE_KEY': processes passed-in Attributes whose UNIQUE_KEY flag is 'Y'

PROCEDURE Add_Attr_Info_To_Statement (
        p_attr_metadata_table     IN  EGO_ATTR_METADATA_TABLE
       ,p_attr_name_value_pairs   IN  EGO_USER_ATTR_DATA_TABLE
       ,p_separator               IN  VARCHAR2
       ,p_mode                    IN  VARCHAR2
       ,p_which_attrs             IN  VARCHAR2
) IS

    l_metadata_driven     BOOLEAN;
    l_for_loop_index      NUMBER;
    l_for_loop_last       NUMBER;
    l_attr_metadata_obj   EGO_ATTR_METADATA_OBJ;
    l_attr_data_obj       EGO_USER_ATTR_DATA_OBJ;
    l_unique_key_flag     VARCHAR2(1);
    l_data_type           VARCHAR2(1);
    l_column_name         VARCHAR2(30);
    l_default_value       EGO_ATTRS_V.DEFAULT_VALUE%TYPE;
    l_candidate_value     VARCHAR2(4000); -- Bug 8757354
    l_uom_column          VARCHAR2(30);
    l_uom_value           VARCHAR2(10);

  BEGIN

    Debug_Msg('In Add_Attr_Info_To_Statement, starting', 2);
    Debug_Msg('In Add_Attr_Info_To_Statement, mode is '||p_mode||' and p_which_attrs is '|| p_which_attrs);
    ----------------------------------------------------------------------------
    -- If l_metadata_driven is TRUE, we loop through all metadata objects,    --
    -- because we want to process every Attribute in the Attribute Group even --
    -- if the caller didn't pass in an Attr Data object for each of them.     --
    -- Otherwise, we loop through all name/value pairs, ignoring Attributes   --
    -- that are in the Attribute Group but aren't mentioned by the caller.    --
    ----------------------------------------------------------------------------
    l_metadata_driven := (p_which_attrs = 'ALL' OR
                          p_mode = 'VALUES_DEF' OR
                          p_mode = 'COLUMNS_DEF');

    IF (l_metadata_driven OR
        (p_attr_name_value_pairs IS NOT NULL AND
         p_attr_name_value_pairs.COUNT > 0)) THEN

      IF (l_metadata_driven) THEN
        l_for_loop_index := p_attr_metadata_table.FIRST;
        l_for_loop_last := p_attr_metadata_table.LAST;
      ELSE
        l_for_loop_index := p_attr_name_value_pairs.FIRST;
        l_for_loop_last := p_attr_name_value_pairs.LAST;
      END IF;

      WHILE (l_for_loop_index <= l_for_loop_last)
      LOOP

        ----------------------------------------------------------------
        -- 1). Find the metadata and data objects for this Attribute; --
        -- if l_metadata_driven is TRUE, then l_attr_data_obj may be  --
        -- null, because the caller may not have passed in an Attr    --
        -- Data object for that Attribute.                            --
        ----------------------------------------------------------------
        IF (l_metadata_driven) THEN
          l_attr_metadata_obj := p_attr_metadata_table(l_for_loop_index);
          l_attr_data_obj := Find_Name_Value_Pair_For_Attr(
                               p_attr_name_value_pairs
                              ,l_attr_metadata_obj.ATTR_NAME
                             );
        ELSE
          l_attr_data_obj := p_attr_name_value_pairs(l_for_loop_index);
          l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                   p_attr_metadata_table => p_attr_metadata_table
                                  ,p_attr_name           => l_attr_data_obj.ATTR_NAME
                                 );
        END IF;

        ------------------------------------------------------------
        -- 2). Find the UNIQUE_KEY_FLAG and DATA_TYPE_CODE values --
        ------------------------------------------------------------
        l_unique_key_flag := l_attr_metadata_obj.UNIQUE_KEY_FLAG;
        l_data_type := l_attr_metadata_obj.DATA_TYPE_CODE;

        -----------------------------------------------------------------
        -- 3). If this Attribute should be processed (according to the --
        -- p_which_attrs value and relevant metadata), find the value  --
        -- (either passed in, Default, or NULL) and also the Database  --
        -- Column.  We use these two pieces of information as well as  --
        -- things like Data Type to build our list as specified by the --
        -- value of p_mode (e.g., 'COLUMNS', 'VALUES_DEF', etc.).      --
        -- Note that if the Attribute has a Value Set, we should have  --
        -- replaced the passed-in Value (which may have either been    --
        -- the Display Value or the Internal Value) with the Internal  --
        -- Value in Validate_Row.                                      --
        -----------------------------------------------------------------
        IF ((UPPER(p_which_attrs) = 'ALL') OR
            (UPPER(p_which_attrs) = 'UNIQUE_KEY' AND l_unique_key_flag = 'Y') OR
            (UPPER(p_which_attrs) = 'TRANS' AND
             l_data_type = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) OR
            (UPPER(p_which_attrs) = 'NONTRANS' AND
             l_data_type <> EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE)) THEN

          ---------------------------------------------------------------------------
          -- Reset UOM, column name, default and value variables each time through --
          ---------------------------------------------------------------------------
          l_uom_column := NULL;
          l_uom_value := NULL;
          l_candidate_value := NULL;

          l_column_name := l_attr_metadata_obj.DATABASE_COLUMN;

          IF (UPPER(p_mode) = 'VALUES_DEF') THEN
            l_default_value := l_attr_metadata_obj.DEFAULT_VALUE;
          ELSE
            l_default_value := NULL;
          END IF;

          ---------------------------------------------------------------
          -- First, try to use the value appropriate for the data type --
          ---------------------------------------------------------------
          IF (l_data_type IS NULL OR
              l_data_type = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
              l_data_type = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

            l_candidate_value := l_attr_data_obj.ATTR_VALUE_STR;
            Debug_Msg('Candidate value:'||l_candidate_value);

          ELSIF (l_data_type = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

            l_candidate_value := TO_CHAR(l_attr_data_obj.ATTR_VALUE_NUM);

            --------------------------------------------------------------------
            -- For all Number Attributes with UOM info, get the data/metadata --
            --------------------------------------------------------------------
            IF (l_attr_data_obj.ATTR_UNIT_OF_MEASURE IS NOT NULL) THEN

              IF (INSTR(l_column_name, 'N_EXT_ATTR') = 1) THEN
                l_uom_column := 'UOM_' || SUBSTR(l_column_name, 3);
              ELSE
                l_uom_column := 'UOM_' || l_column_name;
              END IF;
              l_uom_value := '''' || l_attr_data_obj.ATTR_UNIT_OF_MEASURE || '''';

            END IF;

          ELSIF (l_data_type = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) THEN

            l_candidate_value := TO_CHAR(TRUNC(l_attr_data_obj.ATTR_VALUE_DATE),
                                         EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);

          ELSIF (l_data_type = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

            l_candidate_value := TO_CHAR(l_attr_data_obj.ATTR_VALUE_DATE,
                                         EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);

          END IF;

          ----------------------------------------------------------
          -- If what we got is null, try to use the default value --
          ----------------------------------------------------------
          IF (l_candidate_value IS NULL AND
              l_default_value IS NOT NULL) THEN

            ---------------------------------------
            -- Format default value if necessary --
            ---------------------------------------
            IF ((l_data_type = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
                 l_data_type = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) AND
                INSTR(UPPER(l_default_value), 'SYSDATE') > 0) THEN
              l_default_value := Format_Sysdate_Expression(l_default_value);
            END IF;

/***
ASSUMPTIONS:
1). the UI validates that Number default values with UOM are in the UOM base
2). the UI validates that Date default values are in
    EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT and that
    Standard Date default values are truncated appropriately
***/

            l_candidate_value := l_default_value;

          END IF;

          ----------------------------------------------
          -- Add column info to the list if necessary --
          ----------------------------------------------
          IF (UPPER(p_mode) = 'EQUALS' OR
              UPPER(p_mode) = 'COLUMNS' OR
              UPPER(p_mode) = 'COLUMNS_DEF') THEN

            FND_DSQL.Add_Text(l_column_name);

            IF (UPPER(p_mode) = 'EQUALS') THEN

              IF (l_candidate_value IS NULL AND p_separator = ' AND ') THEN

                FND_DSQL.Add_Text(' IS ');

              ELSE

                FND_DSQL.Add_Text(' = ');

              END IF;

            ELSE

              FND_DSQL.Add_Text(p_separator);

            END IF;
          END IF;

          ---------------------------------------------
          -- Add value info to the list if necessary --
          ---------------------------------------------
          IF (UPPER(p_mode) = 'EQUALS' OR
              UPPER(p_mode) = 'VALUES' OR
              UPPER(p_mode) = 'VALUES_DEF') THEN

            IF (l_candidate_value IS NULL) THEN

              FND_DSQL.Add_Text(' NULL ');

            ELSIF (l_data_type IS NULL OR
                   l_data_type = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
                   l_data_type = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

              /* Bug 9204753. RTRIM() the Attribute Value, for Char and Translatable Text Data Types,
                 before adding it to SQL statement, so that spaces at the end will be truncated. */
	      Add_Bind(p_bind_identifier => l_attr_metadata_obj.ATTR_GROUP_NAME||'$$'||l_attr_metadata_obj.ATTR_NAME
                      ,p_value           =>  RTRIM(l_candidate_value));

            ELSIF (l_data_type = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

              Add_Bind(p_bind_identifier => l_attr_metadata_obj.ATTR_GROUP_NAME||'$$'||l_attr_metadata_obj.ATTR_NAME
                      ,p_value           => TO_NUMBER(l_candidate_value));

            ELSIF (l_data_type = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
                   l_data_type = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

              Add_Bind(p_bind_identifier => l_attr_metadata_obj.ATTR_GROUP_NAME||'$$'||l_attr_metadata_obj.ATTR_NAME
                      ,p_value           => TO_DATE(l_candidate_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));

            END IF;

            FND_DSQL.Add_Text(p_separator);

          END IF;

          -------------------------------------------
          -- Add UOM info to the list if necessary --
          -------------------------------------------
          IF (l_uom_column IS NOT NULL) THEN

            IF (UPPER(p_mode) = 'EQUALS' OR
                UPPER(p_mode) = 'COLUMNS' OR
                UPPER(p_mode) = 'COLUMNS_DEF') THEN

              FND_DSQL.Add_Text(l_uom_column);

              IF (UPPER(p_mode) = 'EQUALS') THEN

                IF (l_uom_value IS NULL AND p_separator = ' AND ') THEN

                  FND_DSQL.Add_Text(' IS ');

                ELSE

                  FND_DSQL.Add_Text(' = ');

                END IF;

              ELSE

                FND_DSQL.Add_Text(p_separator);

              END IF;
            END IF;

            IF (UPPER(p_mode) = 'EQUALS' OR
                UPPER(p_mode) = 'VALUES' OR
                UPPER(p_mode) = 'VALUES_DEF') THEN

              IF (l_uom_value IS NULL) THEN

                FND_DSQL.Add_Text(' NULL ');

              ELSE

                FND_DSQL.Add_Text(l_uom_value);

              END IF;

              FND_DSQL.Add_Text(p_separator);

            END IF;
          END IF;
        END IF;

        IF (l_metadata_driven) THEN
          l_for_loop_index := p_attr_metadata_table.NEXT(l_for_loop_index);
        ELSE
          l_for_loop_index := p_attr_name_value_pairs.NEXT(l_for_loop_index);
        END IF;
      END LOOP;
    END IF;

    Debug_Msg('In Add_Attr_Info_To_Statement, done', 2);

END Add_Attr_Info_To_Statement;

----------------------------------------------------------------------
  --
  -- Private
  --
  ----------------------------------------------------------------------

PROCEDURE Remove_OrderBy_Clause(
        px_where_clause                 IN OUT NOCOPY VARCHAR2
) IS

  l_search_ordby_clause      LONG;
  l_ord_index                NUMBER;
  l_by_index                 NUMBER;
  l_last_ord_index           NUMBER;
  --bug 5119374
  l_has_order_by             BOOLEAN := FALSE;

  BEGIN
    -- initialize variables

    l_search_ordby_clause := UPPER(px_where_clause);
    l_ord_index := INSTR(l_search_ordby_clause, 'ORDER ');

    IF l_ord_index <> 0 THEN
      l_last_ord_index := l_ord_index;
      --bug 5119374
      l_has_order_by :=TRUE;
    ELSE
      l_last_ord_index := length(px_where_clause);
    END IF;

    -- find the index of the last 'ORDER BY' clause

    WHILE (l_ord_index <> 0) LOOP
      l_by_index := INSTR(SUBSTR(l_search_ordby_clause, l_ord_index + 5), 'BY ');
      IF l_by_index <> 0 THEN
        l_search_ordby_clause := SUBSTR(l_search_ordby_clause, l_ord_index + 5 + l_by_index + 2);
        l_ord_index := INSTR(l_search_ordby_clause, 'ORDER ');

        -- if there are more 'ORDER BY' clauses, increment index:
        -- l_last_ord_index  += 5 letters for 'ORDER' +
        --                   +  index of 'BY' + 2 letters for 'BY'
        --                   +  (index of the next 'ORDER BY' - 1)

        IF l_ord_index <> 0 THEN
          l_last_ord_index := l_last_ord_index + 5 + l_by_index + 2 + l_ord_index - 1;
        END IF;
      ELSE
        l_ord_index := 0;
      END IF;
    END LOOP;

    -- if there is a close bracket: 'ORDER BY' clause is nested -> do nothing
    -- if no close bracket, remove 'ORDER BY' clause
    -- if after ORDER BY both '(' and also ')' exist then is not a subquery if and only if there is again no ')' after the previous
    -- checks. e.g. "ORDER BY TO_NUMBER()" or "ORDER BY TO_NUMBER(X) ) "
    --                                                                                                       ^ for closing the subquery
    IF (l_has_order_by
         AND ( INSTR(l_search_ordby_clause, ')') = 0
                   OR ( INSTR(l_search_ordby_clause, '(') <> 0
                          AND INSTR(l_search_ordby_clause, ')') <> 0
                          AND (
                                INSTR(l_search_ordby_clause,')')= length(l_search_ordby_clause)  --bug 12630681
                             OR INSTR(SUBSTR(l_search_ordby_clause, INSTR(l_search_ordby_clause,')') + 1 ), ')' ) = 0 )
                        )
                )
         ) THEN --bug 5119374
      px_where_clause := RTRIM(SUBSTR(px_where_clause, 0, l_last_ord_index - 1));
    END IF;

END Remove_OrderBy_Clause;

----------------------------------------------------------------------

-- This procedure builds a WHERE clause, which it adds to a SQL statement being
-- built using the FND_DSQL package.  This procedure neither initializes nor
-- executes that statement; it just adds text and bind variables through calls
-- to FND_DSQL procedures.

PROCEDURE Build_Where_Clause (
        p_attr_group_metadata_obj       IN  EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN  EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN  VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_name_value_pairs         IN  EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
) IS

    l_api_name               VARCHAR2(30) := 'Build_Where_Clause';
    l_pk_col_string          VARCHAR2(1000) := '';
    l_data_level_string      VARCHAR2(1000) := '';
    l_data_level_id          NUMBER;
    l_dl_col_mdata_array     EGO_COL_METADATA_ARRAY;
  BEGIN

    Debug_Msg(l_api_name || ' starting, p_data_level='||p_data_level, 2);
    ---------------------------------------------------------------
    -- We add the Unique Key portion of the clause first because --
    -- Add_Attr_Info_To_Statement appends a trailing separator   --
    -- to the list if it adds anything to it; this also means we --
    -- don't need to add an ' AND ' after we add the Unique Key  --
    -- info, because Add_Attr_Info_To_Statement does that for us --
    ---------------------------------------------------------------
    IF (p_attr_name_value_pairs IS NOT NULL AND
        p_attr_name_value_pairs.COUNT > 0 AND
        p_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y') THEN

      Add_Attr_Info_To_Statement(p_attr_group_metadata_obj.attr_metadata_table
                                ,p_attr_name_value_pairs
                                ,' AND '
                                ,'EQUALS'
                                ,'UNIQUE_KEY');

    END IF;

    IF (p_attr_group_metadata_obj.ATTR_GROUP_ID_FLAG ='Y') THEN
      FND_DSQL.Add_Text(' ATTR_GROUP_ID = ');
      Add_Bind(p_value => p_attr_group_metadata_obj.ATTR_GROUP_ID);
    ELSE
      FND_DSQL.Add_Text(' 1 = 1 ');
    END IF;

    --------------------------------------------------------------
    -- Added in R12C, for implementations uptaking the enhanced --
    -- support for data level p_data_level would be passed in.  --
    --------------------------------------------------------------
      IF(p_data_level IS NOT NULL
         AND
         FND_API.TO_BOOLEAN(
              has_column_in_table_view(p_object_name  => p_attr_group_metadata_obj.ext_table_vl_name
                                                           ,p_column_name => 'DATA_LEVEL_ID'
                                                           )
                           )
         ) THEN
      -- CONVERTING THE DATA_LEVEL_NAME TO ID --
      l_data_level_id := Get_Data_Level_Id( p_attr_group_metadata_obj.APPLICATION_ID
                                           ,p_attr_group_metadata_obj.ATTR_GROUP_TYPE
                                           ,p_data_level);

      FND_DSQL.Add_Text(' AND DATA_LEVEL_ID = ');
      Add_Bind(p_value => l_data_level_id);
    END IF;

Debug_Msg(l_api_name ||' calling EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols for pk ');
    l_pk_col_string := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                         p_ext_table_metadata_obj.pk_column_metadata
                        ,p_pk_column_name_value_pairs
                        ,'EQUALS'
                        ,TRUE
                        ,' AND '
                       );

Debug_Msg(l_api_name ||' calling EGO_USER_ATTRS_COMMON_PVT.Get_Data_Level_Col_Array ');
    l_dl_col_mdata_array:= EGO_USER_ATTRS_COMMON_PVT.Get_Data_Level_Col_Array(p_attr_group_metadata_obj.APPLICATION_ID,
                                                                             p_attr_group_metadata_obj.ATTR_GROUP_TYPE);

Debug_Msg(l_api_name ||' calling EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols for data level ');
    l_data_level_string := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                             l_dl_col_mdata_array
                            ,p_data_level_name_value_pairs
                            ,'EQUALS'
                            ,TRUE
                            ,' AND '
                           );
Debug_Msg(l_api_name ||' after the l_data_level_string :=  ... l_data_level_string='||l_data_level_string);
    -------------------------------------------------------------------------
    -- Since we will be querying on the extension table's VL, we no longer --
    -- need to constrain our queries by language (the VL does that for us) --
    -------------------------------------------------------------------------

    Debug_Msg(l_api_name || ' done', 2);

END Build_Where_Clause;

----------------------------------------------------------------------

PROCEDURE Sort_Attr_Values_Table (
        p_attr_group_metadata_obj   IN EGO_ATTR_GROUP_METADATA_OBJ
       ,px_attr_name_value_pairs    IN OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
) IS

    l_sorted_attr_data_table   LOCAL_USER_ATTR_DATA_TABLE;
    l_sorted_data_table_index  NUMBER;
    l_attr_data_index          NUMBER;
    l_attr_metadata_obj        EGO_ATTR_METADATA_OBJ;

  BEGIN

    Debug_Msg('In Sort_Attr_Values_Table, starting', 2);

    -----------------------------------------------------------------------
    -- First, put the Attributes into a temp table according to SEQUENCE --
    -----------------------------------------------------------------------
    IF (px_attr_name_value_pairs IS NOT NULL AND
        px_attr_name_value_pairs.COUNT > 0) THEN
      l_attr_data_index := px_attr_name_value_pairs.FIRST;
      WHILE (l_attr_data_index <= px_attr_name_value_pairs.LAST)
      LOOP

        l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                 p_attr_metadata_table => p_attr_group_metadata_obj.attr_metadata_table
                                ,p_attr_name           => px_attr_name_value_pairs(l_attr_data_index).ATTR_NAME
                               );

        l_sorted_attr_data_table(l_attr_metadata_obj.SEQUENCE) := px_attr_name_value_pairs(l_attr_data_index);

        l_attr_data_index := px_attr_name_value_pairs.NEXT(l_attr_data_index);
      END LOOP;

      ------------------------------------------------
      -- Next, clear out the name/value pairs table --
      -- to make room for the sorted Attributes     --
      ------------------------------------------------
      px_attr_name_value_pairs.DELETE();

      ---------------------------------------------------------------------------
      -- Finally, return the Attributes to the name/value pairs table in order --
      ---------------------------------------------------------------------------
      l_sorted_data_table_index := l_sorted_attr_data_table.FIRST;
      WHILE (l_sorted_data_table_index <= l_sorted_attr_data_table.LAST)
      LOOP
        px_attr_name_value_pairs.EXTEND();
        px_attr_name_value_pairs(px_attr_name_value_pairs.LAST) := l_sorted_attr_data_table(l_sorted_data_table_index);
        l_sorted_data_table_index := l_sorted_attr_data_table.NEXT(l_sorted_data_table_index);
      END LOOP;
    END IF;

    Debug_Msg('In Sort_Attr_Values_Table, done', 2);

END Sort_Attr_Values_Table;

----------------------------------------------------------------------

-- This function has two basic modes: if p_return_bound_sql is FALSE, then we
-- initialize FND_DSQL to constuct/bind/execute the query and return the result.
-- If TRUE, we build and return the query itself.  In this case, we don't pass
-- p_final_bind_value or p_attr_name_value_pairs, and when replacing Attr Group
-- tokens we construct a nested query to get the value required by the token.
FUNCTION Tokenized_Val_Set_Query (
        p_attr_metadata_obj             IN  EGO_ATTR_METADATA_OBJ
       ,p_attr_group_metadata_obj       IN  EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN  EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_entity_id                     IN  VARCHAR2
       ,p_entity_index                  IN  NUMBER
       ,p_entity_code                   IN  VARCHAR2
       ,p_add_errors_to_fnd_stack       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_attr_name_value_pairs         IN  EGO_USER_ATTR_DATA_TABLE
       ,p_is_disp_to_int_query          IN  BOOLEAN
       ,p_final_bind_value              IN  VARCHAR2
       ,p_return_bound_sql              IN  BOOLEAN DEFAULT FALSE
)
RETURN VARCHAR2
IS

    l_head_of_query              VARCHAR2(32767);
    l_tail_of_query              VARCHAR2(32767);
    l_has_tokens_left            BOOLEAN;
    l_token_start_index          NUMBER;
    l_token_end_index            NUMBER;
    l_token                      VARCHAR2(50);
    l_source_of_replacement      VARCHAR2(30);
    l_token_replacement          VARCHAR2(4000);	-- Bug 8757354
    l_token_data_type            VARCHAR2(1);
    l_pk_array_index             NUMBER;
    l_replacement_attr_metadata  EGO_ATTR_METADATA_OBJ;
    l_replacement_attr_data      EGO_USER_ATTR_DATA_OBJ;
    l_retrieved_value            VARCHAR2(4000); --bug 12979914
    l_error_message_name         VARCHAR2(30);
    l_token_table                ERROR_HANDLER.Token_Tbl_Type;
    l_cursor_id                  NUMBER;
    l_dynamic_sql                VARCHAR2(32767);
    l_number_of_rows             NUMBER;

  BEGIN

    Debug_Msg('In Tokenized_Val_Set_Query, starting', 2);

    --------------------------------------------------------------------------
    -- If this function is being called from another package, then we won't --
    -- have initialized G_USER_ROW_IDENTIFIER yet; we try to use the row    --
    -- identifier from p_attr_name_value_pairs, but if it is NULL or empty  --
    -- we use the value 1 instead                                           --
    --------------------------------------------------------------------------
    IF (G_USER_ROW_IDENTIFIER = 0) THEN
      IF (p_attr_name_value_pairs IS NOT NULL AND
          p_attr_name_value_pairs.COUNT > 0) THEN
        G_USER_ROW_IDENTIFIER := p_attr_name_value_pairs(p_attr_name_value_pairs.FIRST).USER_ROW_IDENTIFIER;
      ELSE
        G_USER_ROW_IDENTIFIER := 1;
      END IF;
    END IF;

    IF (p_is_disp_to_int_query) THEN
      l_tail_of_query := p_attr_metadata_obj.DISP_TO_INT_VAL_QUERY;
    ELSE
      l_tail_of_query := p_attr_metadata_obj.INT_TO_DISP_VAL_QUERY;
    END IF;

    Debug_Msg('In Tokenized_Val_Set_Query, query starts as follows:');
    Debug_Sql(l_tail_of_query);

    --------------------------------------------------------------------------------
    -- We only process the query if the Attribute has a Value Set of type "Table" --
    -- (because that's the only case in which there may be tokens to replace)     --
    --------------------------------------------------------------------------------
    IF (p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE) THEN

      l_has_tokens_left := (INSTR(UPPER(l_tail_of_query), ':$OBJECT$.') > 0 OR
                            INSTR(UPPER(l_tail_of_query), ':$ATTRIBUTEGROUP$.') > 0);

      IF (l_has_tokens_left) THEN
        Debug_Msg('In Tokenized_Val_Set_Query, query has tokens to process');

        IF (NOT p_return_bound_sql) THEN
          Init();
        END IF;

      ELSE
        Debug_Msg('In Tokenized_Val_Set_Query, query has no tokens');
      END IF;

      WHILE (l_has_tokens_left)
      LOOP

        -------------------------------------------------------------------------
        -- Get the token (even in the case where it's at the end of the query) --
        -------------------------------------------------------------------------
        l_token_start_index := INSTR(l_tail_of_query, ':$');
        l_token_end_index := INSTR(l_tail_of_query, ' ', l_token_start_index);
/***
Assumption: here we assume a space after the bind variable; perhaps we shouldn't
***/
        IF (l_token_end_index = 0) THEN
          l_token_end_index := LENGTH(l_tail_of_query) + 1;
        END IF;
        l_token := SUBSTR(l_tail_of_query, l_token_start_index, (l_token_end_index - l_token_start_index));

        ----------------------------------------------------------------
        -- Ensure we have a legitimate token and not a false positive --
        ----------------------------------------------------------------
        IF ((INSTR(UPPER(l_token), ':$OBJECT$.') = 1) OR
            (INSTR(UPPER(l_token), ':$ATTRIBUTEGROUP$.') = 1)) THEN

          l_source_of_replacement := SUBSTR(l_token, INSTR(l_token, '.') + 1);

          ------------------------------
          -- If we have a PK token... --
          ------------------------------
          IF (INSTR(UPPER(l_token), ':$OBJECT$.') = 1) THEN

            -----------------------------------------------------------
            -- ...find the appropriate PK value to replace the token --
            -----------------------------------------------------------
            l_pk_array_index := p_pk_column_name_value_pairs.FIRST;
            WHILE (l_pk_array_index <= p_pk_column_name_value_pairs.LAST)
            LOOP
              EXIT WHEN (l_token_replacement IS NOT NULL);

              --------------------------------------------------------------
              -- Case insensitive comparison for Primary Key column names --
              --------------------------------------------------------------
              IF (UPPER(l_source_of_replacement) =
                  UPPER(p_pk_column_name_value_pairs(l_pk_array_index).NAME)) THEN
                l_token_replacement := p_pk_column_name_value_pairs(l_pk_array_index).VALUE;
              END IF;

              l_pk_array_index := p_pk_column_name_value_pairs.NEXT(l_pk_array_index);
            END LOOP;

            --------------------------------------------------------------------
            -- If we couldn't find a token replacement, the token must be bad --
            --------------------------------------------------------------------
            IF (l_token_replacement IS NULL) THEN

              l_error_message_name := 'EGO_EF_TOKEN_ERR_PK';

              l_token_table(1).TOKEN_NAME := 'ATTR_NAME';
              l_token_table(1).TOKEN_VALUE := p_attr_metadata_obj.ATTR_DISP_NAME;
              l_token_table(2).TOKEN_NAME := 'AG_NAME';
              l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
              l_token_table(3).TOKEN_NAME := 'BAD_PK_NAME';
              l_token_table(3).TOKEN_VALUE := l_source_of_replacement;
              l_token_table(4).TOKEN_NAME := 'OBJ_NAME';
              l_token_table(4).TOKEN_VALUE := p_ext_table_metadata_obj.OBJ_NAME;

              ERROR_HANDLER.Add_Error_Message(
                p_message_name      => l_error_message_name
               ,p_application_id    => 'EGO'
               ,p_token_tbl         => l_token_table
               ,p_message_type      => FND_API.G_RET_STS_ERROR
               ,p_row_identifier    => G_USER_ROW_IDENTIFIER
               ,p_entity_id         => p_entity_id
               ,p_entity_index      => p_entity_index
               ,p_entity_code       => p_entity_code
               ,p_addto_fnd_stack   => p_add_errors_to_fnd_stack
              );

              RAISE FND_API.G_EXC_ERROR;
            END IF;

          ------------------------------------
          -- Otherwise, we have an AG token --
          ------------------------------------
          ELSIF (INSTR(UPPER(l_token), ':$ATTRIBUTEGROUP$.') = 1) THEN

            -----------------------------------------
            -- Find the metadata for the Attribute --
            -- whose value will replace the token  --
            -----------------------------------------
            l_replacement_attr_metadata := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                             p_attr_metadata_table => p_attr_group_metadata_obj.attr_metadata_table
                                            ,p_attr_name           => l_source_of_replacement
                                           );

            IF (l_replacement_attr_metadata IS NULL OR
                l_replacement_attr_metadata.ATTR_NAME IS NULL) THEN

              ----------------------------------------------------------------------
              -- If the Attribute Group token yielded no metadata, it must be bad --
              ----------------------------------------------------------------------
              l_error_message_name := 'EGO_EF_TOKEN_ERR_AG';

              l_token_table(1).TOKEN_NAME := 'ATTR_NAME';
              l_token_table(1).TOKEN_VALUE := p_attr_metadata_obj.ATTR_DISP_NAME;
              l_token_table(2).TOKEN_NAME := 'AG_NAME';
              l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
              l_token_table(3).TOKEN_NAME := 'BAD_ATTR_NAME';
              l_token_table(3).TOKEN_VALUE := l_source_of_replacement;

              ERROR_HANDLER.Add_Error_Message(
                p_message_name      => l_error_message_name
               ,p_application_id    => 'EGO'
               ,p_token_tbl         => l_token_table
               ,p_message_type      => FND_API.G_RET_STS_ERROR
               ,p_row_identifier    => G_USER_ROW_IDENTIFIER
               ,p_entity_id         => p_entity_id
               ,p_entity_index      => p_entity_index
               ,p_entity_code       => p_entity_code
               ,p_addto_fnd_stack   => p_add_errors_to_fnd_stack
              );

              RAISE FND_API.G_EXC_ERROR;

            ELSE

              IF (p_return_bound_sql) THEN

                ----------------------------------------------------------
                -- If we are constructing and returning the query, then --
                -- we don't have p_attr_name_value_pairs, so we'll have --
                -- to use the replacement's database column name        --
                ----------------------------------------------------------
                l_token_replacement := l_replacement_attr_metadata.DATABASE_COLUMN;

              ELSIF (p_attr_name_value_pairs IS NOT NULL) THEN

                --------------------------------------------------------------------------------
                -- If we have Attr values, try replacing the token with the appropriate value --
                --------------------------------------------------------------------------------
                l_replacement_attr_data := Find_Name_Value_Pair_For_Attr(p_attr_name_value_pairs
                                                                        ,l_replacement_attr_metadata.ATTR_NAME);

                IF (l_replacement_attr_data IS NOT NULL) THEN

                  IF (l_replacement_attr_metadata.DATA_TYPE_CODE IS NULL OR
                      l_replacement_attr_metadata.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
                      l_replacement_attr_metadata.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

                    /* FP bug 8499883 with base bug 8215594
                    l_token_replacement := l_replacement_attr_data.ATTR_VALUE_STR; */
                    l_token_replacement := nvl(l_replacement_attr_data.ATTR_VALUE_STR,l_replacement_attr_data.ATTR_DISP_VALUE);

                  ELSIF (l_replacement_attr_metadata.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

                    l_token_replacement := TO_CHAR(l_replacement_attr_data.ATTR_VALUE_NUM);

                  ELSIF (l_replacement_attr_metadata.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
                         l_replacement_attr_metadata.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

                    l_token_replacement := TO_CHAR(l_replacement_attr_data.ATTR_VALUE_DATE, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);

                  END IF;

                  -----------------------------------------------------------------------
                  -- If we don't have an internal value for this Attr but we do have a --
                  -- display value AND if the Attr does not have a bind value VS query --
                  -- (i.e., if we can guarantee it won't need Tokenized_Val_Set_Query) --
                  -- then we can try to get its internal value for our query           --
                  -- NOTE: we have to be careful here, because we're flirting with a   --
                  -- possibly tricky pseudo-recursion                                  --
                  -----------------------------------------------------------------------
				  --for bug 10428782, if l_token_replacement is still a display value from a value set, we need get internal value for it.
                  IF ((l_token_replacement IS NULL or
				      (l_replacement_attr_metadata.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE OR
				       l_replacement_attr_metadata.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE OR
					   l_replacement_attr_metadata.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE)) AND
                      l_replacement_attr_data.ATTR_DISP_VALUE IS NOT NULL AND
                      (l_replacement_attr_metadata.VS_BIND_VALUES_CODE IS NULL OR
                       l_replacement_attr_metadata.VS_BIND_VALUES_CODE = 'N' OR
                       l_replacement_attr_metadata.VS_BIND_VALUES_CODE = 'O')) THEN --bug 13478195

                    Debug_Msg('In Tokenized_Val_Set_Query, trying to get int value for bind value Attr '||l_replacement_attr_data.ATTR_NAME);

/***
ASSUMPTION:
We assume that all UK Attrs for the query have their int values already
We sort by sequence, which should ensure that bind value Attrs are processed, but
it won't guarantee that UK Attrs are processed...
***/

                    l_token_replacement := Get_Int_Val_For_Disp_Val(
                                             p_attr_metadata_obj             => l_replacement_attr_metadata
                                            ,p_attr_value_obj                => l_replacement_attr_data
                                            ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
                                            ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
                                            ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
                                            ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
                                            ,p_entity_id                     => p_entity_id
                                            ,p_entity_index                  => p_entity_index
                                            ,p_entity_code                   => p_entity_code
                                            ,p_attr_name_value_pairs         => p_attr_name_value_pairs
                                           );

                    Debug_Msg('In Tokenized_Val_Set_Query, got int value for bind value Attr '||l_replacement_attr_data.ATTR_NAME||' as '||l_token_replacement);
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;

          -----------------------------------------------------------------------------
          -- By this point we have either a replacement value or NULL (which we just --
          -- pass and let things break); now we paste what we have into the query    --
          -----------------------------------------------------------------------------
          IF (p_return_bound_sql) THEN
            l_head_of_query := l_head_of_query ||
                               SUBSTR(l_tail_of_query, 1, (l_token_start_index - 1)) ||
                               l_token_replacement;
          ELSE
            FND_DSQL.Add_Text(SUBSTR(l_tail_of_query, 1, (l_token_start_index - 1)));
            Add_Bind(p_value => l_token_replacement);
          END IF;

        ELSE

          ---------------------------------------------------------------------
          -- In case of a false positive, we put what we thought was a token --
          -- back into the query, and we move forward past the end of it     --
          ---------------------------------------------------------------------
          IF (p_return_bound_sql) THEN
            l_head_of_query := l_head_of_query ||
                               SUBSTR(l_tail_of_query, 1, (l_token_end_index - 1));
          ELSE
            FND_DSQL.Add_Text(SUBSTR(l_tail_of_query, 1, (l_token_end_index - 1)));
          END IF;

        END IF;

        ------------------------------------------------------------------------------
        -- Clip the part of the query we just processed (even if it wasn't a token) --
        ------------------------------------------------------------------------------
        l_tail_of_query := SUBSTR(l_tail_of_query, l_token_end_index);

        l_has_tokens_left := (INSTR(UPPER(l_tail_of_query), ':$OBJECT$') > 0 OR
                              INSTR(UPPER(l_tail_of_query), ':$ATTRIBUTEGROUP$') > 0);
        l_token_replacement := NULL;
        l_replacement_attr_metadata := NULL;

      END LOOP;
    END IF;

    -------------------------------------------------------------------
    -- After processing all tokens (or if we didn't process at all), --
    -- we get the remainder of the query, bind the passed-in value,  --
    -- execute the query, and return our results                     --
    -------------------------------------------------------------------
    IF (p_return_bound_sql) THEN
      l_dynamic_sql := l_head_of_query || l_tail_of_query;

      Debug_Msg('In Tokenized_Val_Set_Query, l_dynamic_sql to be returned is as follows:', 3);
      Debug_SQL(l_dynamic_sql);
      Debug_Msg('In Tokenized_Val_Set_Query, done', 2);
      RETURN l_dynamic_sql;

    ELSE
      FND_DSQL.Add_Text(l_tail_of_query);
      Add_Bind(p_value => p_final_bind_value);

      l_dynamic_sql := FND_DSQL.Get_Text(FALSE);

      Debug_Msg('In Tokenized_Val_Set_Query, l_dynamic_sql to be executed is as follows:', 3);
      Debug_SQL(FND_DSQL.Get_Text(TRUE));

      l_cursor_id := DBMS_SQL.Open_Cursor;

      DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.Native);
      FND_DSQL.Set_Cursor(l_cursor_id);
      FND_DSQL.Do_Binds();
      DBMS_SQL.Define_Column(l_cursor_id, 1, l_retrieved_value, 4000); --bug 12979914

      l_number_of_rows := DBMS_SQL.Execute_And_Fetch(l_cursor_id);

      IF (l_number_of_rows > 0) THEN

        DBMS_SQL.Column_Value(l_cursor_id, 1, l_retrieved_value);

      END IF;

      DBMS_SQL.Close_Cursor(l_cursor_id);
      fnd_dsql.init(); --bug 13478195

      Debug_Msg('In Tokenized_Val_Set_Query, l_retrieved_value is as follows: '||
                l_retrieved_value);
      Debug_Msg('In Tokenized_Val_Set_Query, done', 2);
      RETURN l_retrieved_value;

    END IF;

END Tokenized_Val_Set_Query;

----------------------------------------------------------------------

FUNCTION Get_Int_Val_For_Disp_Val (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,p_attr_value_obj                IN   EGO_USER_ATTR_DATA_OBJ
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
)
RETURN VARCHAR2
IS

    l_dynamic_sql            VARCHAR2(32767);
    l_disp_value             VARCHAR2(4000);	-- Bug 8757354
    l_int_value              VARCHAR2(4000);	-- Bug 8757354

  BEGIN

    ----------------------------------------------------------------------
    -- For Attributes with either "Independent" or "Table" Value Sets,  --
    -- there are Display Values and Internal Values that are different; --
    -- we store the Internal Values, but since the caller may only know --
    -- the Display Value we have this procedure to convert a given Disp --
    -- Value to its corresponding Int Value.  We treat Int Value and    --
    -- Disp Value as strings, but either may represent a Number or Date --
    ----------------------------------------------------------------------
    l_disp_value := p_attr_value_obj.ATTR_DISP_VALUE;

    Debug_Msg('In Get_Int_Val_For_Disp_Val, starting for l_disp_value '||l_disp_value, 2);

    IF (p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE  OR
        p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE ) THEN
--PERF TUNING 4957648
      l_dynamic_sql := 'SELECT DISTINCT FLEX_VALUE '||
                         ' FROM FND_FLEX_VALUES_VL '||
                        ' WHERE FLEX_VALUE_SET_ID = :1 '||
                          ' AND ENABLED_FLAG = ''Y'' '||
                          ' AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE) '||
                          ' AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE) '||
                          ' AND FLEX_VALUE_MEANING = :2 ';

      EXECUTE IMMEDIATE l_dynamic_sql
         INTO l_int_value
        USING p_attr_metadata_obj.VALUE_SET_ID, l_disp_value;

    ELSIF (p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE) THEN

      ---------------------------------------------------------------------
      -- If the Table Value Set doesn't have an Additional Where Clause  --
      -- with bind values, we can go ahead and execute the query without --
      -- tokenizing at all                                               --
      ---------------------------------------------------------------------
      IF (p_attr_metadata_obj.VS_BIND_VALUES_CODE IS NULL OR
          p_attr_metadata_obj.VS_BIND_VALUES_CODE = 'N') THEN

        EXECUTE IMMEDIATE p_attr_metadata_obj.DISP_TO_INT_VAL_QUERY||' :1 AND ROWNUM < 2'
           INTO l_int_value
          USING l_disp_value;

      ELSE

        --------------------------------------------------------------------
        -- This is the hard case; it's a Table Value Set whose Additional --
        -- Where Clause has bind values, which means we'll have to call   --
        -- Tokenized_Val_Set_Query to execute the query on our behalf     --
        --------------------------------------------------------------------
        l_int_value := Tokenized_Val_Set_Query(
                         p_attr_metadata_obj           => p_attr_metadata_obj
                        ,p_attr_group_metadata_obj     => p_attr_group_metadata_obj
                        ,p_ext_table_metadata_obj      => p_ext_table_metadata_obj
                        ,p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
                        ,p_data_level_name_value_pairs => p_data_level_name_value_pairs
                        ,p_entity_id                   => p_entity_id
                        ,p_entity_index                => p_entity_index
                        ,p_entity_code                 => p_entity_code
                        ,p_attr_name_value_pairs       => p_attr_name_value_pairs
                        ,p_is_disp_to_int_query        => TRUE
                        ,p_final_bind_value            => l_disp_value
                       );

        Debug_Msg('In Get_Int_Val_For_Disp_Val, Tokenized_Val_Set_Query returned '||l_int_value, 3);

      END IF;
    END IF;

    Debug_Msg('In Get_Int_Val_For_Disp_Val, disp val of '||l_disp_value||' got int val as '||l_int_value);
    Debug_Msg('In Get_Int_Val_For_Disp_Val, done', 2);

    RETURN l_int_value;

  ------------------------------------------------------------------
  -- In cases where the Attribute value is not in the Value Set,  --
  -- we may get the ORA-01403 "NO_DATA_FOUND" error, and in cases --
  -- where we failed to substitute the bind values, we raise an   --
  -- error; so our EXCEPTION block catches those and returns NULL --
  ------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      Debug_Msg('In Get_Int_Val_For_Disp_Val, EXCEPTION OTHERS', 1);
      RETURN NULL;

END Get_Int_Val_For_Disp_Val;

----------------------------------------------------------------------

FUNCTION Get_Disp_Val_For_Int_Val (
        p_attr_int_value                IN   VARCHAR2   DEFAULT NULL
       ,p_attr_value_obj                IN   EGO_USER_ATTR_DATA_OBJ DEFAULT NULL
       ,p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_entity_id                     IN   VARCHAR2   DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
)
RETURN VARCHAR2
IS

    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    l_val_set_query          VARCHAR2(32767);
    l_attr_int_value         VARCHAR2(4000);	-- Bug 8757354
    l_attr_disp_value        VARCHAR2(4000);	-- Bug 8757354

  BEGIN

    Debug_Msg('In Get_Disp_Val_For_Int_Val, starting', 2);

    -------------------------------------------------------------------------------
    -- We get the Internal Value for the Attribute, either passed in directly or --
    -- passed in as a field in a data object; in the latter case, we assume that --
    -- the data type is correct because this was checked in Validate_Row already --
    -------------------------------------------------------------------------------
    IF (p_attr_int_value IS NOT NULL) THEN

      l_attr_int_value := p_attr_int_value;

    ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE IS NULL OR
           p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
           p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

      l_attr_int_value := p_attr_value_obj.ATTR_VALUE_STR;

    ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

      l_attr_int_value := TO_CHAR(p_attr_value_obj.ATTR_VALUE_NUM);

    ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
           p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

      l_attr_int_value := TO_CHAR(p_attr_value_obj.ATTR_VALUE_DATE, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);

    END IF;

    l_attr_int_value := TRIM(l_attr_int_value);

    -------------------------------------------------------------------
    -- Next we handle the simple cases (i.e., all queries without an --
    -- Additional Where Clause containing user-defined bind values)  --
    -------------------------------------------------------------------
    -- fix for bug 4543638 included translatable independent validation code to get disp value
    IF (p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE OR
        p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE
        ) THEN

      ---------------------------------------------------------------
      -- Even though our Attribute metadata object has this query  --
      -- stored, we use this version because our stored version    --
      -- has the Value Set ID hard-coded, whereas this version has --
      -- it as a bind value (which is more efficient); the stored  --
      -- version is only for use in Get_User_Attrs_Data            --
      ---------------------------------------------------------------
--PERF TUNING 4957648

      IF(p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN --bug 14268474

        l_val_set_query := 'SELECT DISTINCT FLEX_VALUE_MEANING '||
                           ' FROM FND_FLEX_VALUES_VL '||
                          ' WHERE FLEX_VALUE_SET_ID = :1 '||
                            ' AND ENABLED_FLAG = ''Y'' '||
                            ' AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE) '||
                            ' AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE) '||
                            ' AND TO_NUMBER(FLEX_VALUE) = :2 ';

      ELSE
        l_val_set_query := 'SELECT DISTINCT FLEX_VALUE_MEANING '||
                           ' FROM FND_FLEX_VALUES_VL '||
                          ' WHERE FLEX_VALUE_SET_ID = :1 '||
                            ' AND ENABLED_FLAG = ''Y'' '||
                            ' AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE) '||
                            ' AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE) '||
                            ' AND FLEX_VALUE = :2 ';

      END IF;

      EXECUTE IMMEDIATE l_val_set_query
         INTO l_attr_disp_value
        USING p_attr_metadata_obj.VALUE_SET_ID, l_attr_int_value;

    ELSIF (p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE AND
           (p_attr_metadata_obj.VS_BIND_VALUES_CODE IS NULL OR
            p_attr_metadata_obj.VS_BIND_VALUES_CODE = 'N')) THEN

      EXECUTE IMMEDIATE p_attr_metadata_obj.INT_TO_DISP_VAL_QUERY||' :1 AND ROWNUM < 2'
         INTO l_attr_disp_value
        USING l_attr_int_value;

    ELSE

      --------------------------------------------------------------------
      -- This is the hard case; it's a Table Value Set whose Additional --
      -- Where Clause has bind values, which means we'll have to call   --
      -- Tokenized_Val_Set_Query to execute the query on our behalf     --
      --------------------------------------------------------------------
      IF (p_ext_table_metadata_obj IS NOT NULL) THEN
        l_ext_table_metadata_obj := p_ext_table_metadata_obj;
      ELSE
        l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(Get_Object_Id_From_Name(p_object_name));
      END IF;

      l_attr_disp_value := Tokenized_Val_Set_Query(
                             p_attr_metadata_obj           => p_attr_metadata_obj
                            ,p_attr_group_metadata_obj     => p_attr_group_metadata_obj
                            ,p_ext_table_metadata_obj      => l_ext_table_metadata_obj
                            ,p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
                            ,p_data_level_name_value_pairs => p_data_level_name_value_pairs
                            ,p_entity_id                   => p_entity_id
                            ,p_entity_index                => p_entity_index
                            ,p_entity_code                 => p_entity_code
                            ,p_attr_name_value_pairs       => p_attr_name_value_pairs
                            ,p_is_disp_to_int_query        => FALSE
                            ,p_final_bind_value            => l_attr_int_value
                           );

    END IF;

    Debug_Msg('In Get_Disp_Val_For_Int_Val, done; returning '||l_attr_disp_value, 2);

    RETURN l_attr_disp_value;

  EXCEPTION
    WHEN OTHERS THEN
      Debug_Msg('In Get_Disp_Val_For_Int_Val, got exception '||SQLERRM, 3);
      RETURN NULL;

END Get_Disp_Val_For_Int_Val;

----------------------------------------------------------------------

FUNCTION Get_Extension_Id_For_Row (
        p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_extra_pk_col_name_val_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT NULL
)
RETURN NUMBER
IS

    l_api_name               VARCHAR2(30)  := 'Get_Extension_Id_For_Row';
    l_vl_name                VARCHAR2(30);
    l_change_where_clause    VARCHAR2(1000);
    l_extra_where_clause     VARCHAR2(5000);
    l_cursor_id              NUMBER;
    l_dynamic_sql            VARCHAR2(15000);
    l_data_level_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_number_of_rows         NUMBER;
    l_extension_id           NUMBER;
    l_index                  NUMBER;

  BEGIN

    Debug_Msg(l_api_name || ' starting with p_data_level='||p_data_level, 2);

    --------------------------------------------------------------------------
    -- Determine whether we're in Change mode and set variables accordingly --
    --------------------------------------------------------------------------
    IF (p_change_obj IS NOT NULL
        AND
       (p_pending_vl_name IS NOT NULL OR p_pending_b_table_name IS NOT NULL)) THEN

      IF (p_pending_vl_name IS NOT NULL) THEN
        l_vl_name := p_pending_vl_name;
      ELSE
        l_vl_name := p_pending_b_table_name;
      END IF;

      IF (p_change_obj.CHANGE_ID IS NOT NULL) THEN
        l_change_where_clause := ' CHANGE_ID = '||p_change_obj.CHANGE_ID||' AND ';
      ELSE
        l_change_where_clause := ' AND CHANGE_ID IS NULL AND ';
      END IF;

      IF (p_change_obj.CHANGE_LINE_ID IS NOT NULL) THEN
        l_change_where_clause := l_change_where_clause||'CHANGE_LINE_ID = '||p_change_obj.CHANGE_LINE_ID||' AND ';
      ELSE
        l_change_where_clause := l_change_where_clause||'CHANGE_LINE_ID IS NULL AND ';
      END IF;

      --------------------------------------------------------------
      -- If querying from the pending table, we ignore Data Level --
      --------------------------------------------------------------
      l_data_level_name_value_pairs := NULL;

    ELSE

      IF (p_attr_group_metadata_obj.EXT_TABLE_VL_NAME IS NOT NULL) THEN
        l_vl_name := p_attr_group_metadata_obj.EXT_TABLE_VL_NAME;
      ELSE
        l_vl_name := p_attr_group_metadata_obj.EXT_TABLE_B_NAME;
      END IF;

      l_change_where_clause := '';

      l_data_level_name_value_pairs := p_data_level_name_value_pairs;

    END IF;



    --------------------------------------------------------------------------
    -- Include the extra pk's in the query if provided --
    --------------------------------------------------------------------------
    l_extra_where_clause := ' 1=1 ';

    IF (p_extra_pk_col_name_val_pairs IS NOT NULL AND
        (p_pending_vl_name IS NOT NULL OR p_pending_b_table_name IS NOT NULL)) THEN

      IF (p_pending_vl_name IS NOT NULL) THEN
        l_vl_name := p_pending_vl_name;
      ELSE
        l_vl_name := p_pending_b_table_name;
      END IF;

      IF (p_extra_pk_col_name_val_pairs IS NOT NULL AND p_extra_pk_col_name_val_pairs.COUNT > 0) THEN
        l_index := p_extra_pk_col_name_val_pairs.FIRST;
        WHILE (l_index IS NOT NULL)
        LOOP
          IF (p_extra_pk_col_name_val_pairs(l_index).NAME IS NOT NULL) THEN

                l_extra_where_clause := l_extra_where_clause || ' AND ';

            IF (p_extra_pk_col_name_val_pairs(l_index).VALUE IS NOT NULL) THEN
                l_extra_where_clause := l_extra_where_clause || p_extra_pk_col_name_val_pairs(l_index).NAME || ' = '
                                                             || p_extra_pk_col_name_val_pairs(l_index).VALUE || '  '  ;
            ELSE
                l_extra_where_clause := l_extra_where_clause || p_extra_pk_col_name_val_pairs(l_index).NAME || ' IS NULL  ';
            END IF;
          END IF;
          l_index := p_extra_pk_col_name_val_pairs.NEXT(l_index);
        END LOOP;
      END IF;
    END IF;

    -----------------------------------------------
    -- We clear FND_DSQL and start our new query --
    -----------------------------------------------
    Init();
    FND_DSQL.Add_Text('SELECT EXTENSION_ID FROM ' || l_vl_name ||
                      ' WHERE 1=1 AND ' || l_change_where_clause||l_extra_where_clause||' AND ');

    Debug_Msg(l_api_name ||' calling  Build_Where_Clause', 3);
    Build_Where_Clause(p_attr_group_metadata_obj
                      ,p_ext_table_metadata_obj
                      ,p_pk_column_name_value_pairs
                      ,p_data_level
                      ,l_data_level_name_value_pairs -- NULL if we're in Change mode
                      ,p_attr_name_value_pairs);
    Debug_Msg(l_api_name ||' returning  Build_Where_Clause', 3);

    l_dynamic_sql := FND_DSQL.Get_Text(FALSE);

    Debug_Msg(l_api_name ||' l_dynamic_sql is as follows: '||l_dynamic_sql, 3);
    Debug_SQL(FND_DSQL.Get_Text(TRUE));
    ----------------------------------------
    -- Now we open a cursor for our query --
    ----------------------------------------
    l_cursor_id := DBMS_SQL.Open_Cursor;

    --------------------------------------------------
    -- Next we parse the query, bind our variables, --
    -- and tell DBMS_SQL what we want it to return  --
    --------------------------------------------------
    DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.Native);
    FND_DSQL.Set_Cursor(l_cursor_id);
    FND_DSQL.Do_Binds();
    DBMS_SQL.Define_Column(l_cursor_id, 1, l_extension_id);
    ---------------------------------------------------------------------
    -- We execute the query and see how many rows we get; if we get no --
    -- rows, we return NULL, and if we get too many rows, we return -1 --
    ---------------------------------------------------------------------
    l_number_of_rows := DBMS_SQL.Execute_And_Fetch(l_cursor_id);
    IF (l_number_of_rows = 1) THEN
      DBMS_SQL.Column_Value(l_cursor_id, 1, l_extension_id);
    ELSIF (l_number_of_rows > 1) THEN
      l_extension_id := -1;
    END IF;

    ---------------------------------------------------------
    -- Finally, we close the cursor and return our results --
    ---------------------------------------------------------
    DBMS_SQL.Close_Cursor(l_cursor_id);
    Debug_Msg('In Get_Extension_Id_For_Row, done; l_extension_id is '||l_extension_id, 2);

    RETURN l_extension_id;
EXCEPTION
  WHEN OTHERS THEN
     Debug_Msg(' Get_Extension_Id_For_Row EXCEPTION - '||SQLERRM);

END Get_Extension_Id_For_Row;

----------------------------------------------------------------------

FUNCTION Fetch_UK_Attr_Names_Table (
        p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
)
RETURN LOCAL_MEDIUM_VARCHAR_TABLE
IS

    l_uk_attr_names_table    LOCAL_MEDIUM_VARCHAR_TABLE;
    l_uk_attr_names_table_index NUMBER := 1;
    l_uk_attrs_count         NUMBER;
    l_table_index            NUMBER;
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;

  BEGIN

    ----------------------------------------------------------------
    -- We find out how many UK Attrs there are in the Attr Group, --
    -- so we don't waste time looping after we've found them all  --
    ----------------------------------------------------------------
    l_uk_attrs_count := p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT;

    l_table_index := p_attr_group_metadata_obj.attr_metadata_table.FIRST;
    WHILE (l_table_index <= p_attr_group_metadata_obj.attr_metadata_table.LAST)
    LOOP
      EXIT WHEN (l_uk_attr_names_table.COUNT = l_uk_attrs_count);

      -----------------------------------------------------
      -- If we find a UK Attr, add its name to our table --
      -----------------------------------------------------
      IF (p_attr_group_metadata_obj.attr_metadata_table(l_table_index).UNIQUE_KEY_FLAG = 'Y') THEN

        l_uk_attr_names_table(l_uk_attr_names_table_index) := p_attr_group_metadata_obj.attr_metadata_table(l_table_index).ATTR_DISP_NAME;
        l_uk_attr_names_table_index := l_uk_attr_names_table_index + 1;

      END IF;

      l_table_index := p_attr_group_metadata_obj.attr_metadata_table.NEXT(l_table_index);
    END LOOP;

    RETURN l_uk_attr_names_table;

END Fetch_UK_Attr_Names_Table;

-------------------------------------------------------------------------------
-- Added for Bug 9137842
-- Function Fetch_UK_Attr_Display_Values will populate the
-- p_attr_group_metadata_obj.ATTR_DISP_VALUE with either ATTR_VALUE_STR
-- or ATTR_VALUE_NUM or ATTR_VALUE_DATE based on the call.
-------------------------------------------------------------------------------

  FUNCTION Fetch_UK_Attr_Display_Values(p_attr_group_metadata_obj     IN EGO_ATTR_GROUP_METADATA_OBJ,
                                        p_ext_table_metadata_obj      IN EGO_EXT_TABLE_METADATA_OBJ DEFAULT NULL,
                                        p_pk_column_name_value_pairs  IN EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL,
                                        p_data_level_name_value_pairs IN EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL,
                                        p_entity_id                   IN VARCHAR2 DEFAULT NULL,
                                        p_entity_index                IN NUMBER DEFAULT NULL,
                                        p_entity_code                 IN VARCHAR2 DEFAULT NULL,
                                        p_attr_name_value_pairs       IN EGO_USER_ATTR_DATA_TABLE,
                                        p_attr_name_value             IN VARCHAR2,
                                        l_table_index                 IN NUMBER

)
RETURN varchar2
IS
    l_vs_table_name             EGO_VALIDATION_TABLE_INFO_V.application_table_name%type;  -- bug 14619994
    l_vs_value_column           EGO_VALIDATION_TABLE_INFO_V.value_column_name%type;  -- bug 14619994
    l_vs_id_column              EGO_VALIDATION_TABLE_INFO_V.id_column_name%type; -- bug 14619994
    l_dynamic_query             VARCHAR2(2000);
    l_disp_value                LOCAL_BIG_VARCHAR_TABLE;
    l_attr_value_date           VARCHAR2(50);
    l_validation_type           VARCHAR2(10):= 'NULL';
    l_vs_where_clause           VARCHAR2(1000);
    l_attr_metadata_obj EGO_ATTR_METADATA_OBJ;
    l_display_value     VARCHAR2(4000);
BEGIN
      SELECT validation_type INTO l_validation_type
      FROM FND_FLEX_VALUE_SETS WHERE
      flex_value_set_id= p_attr_group_metadata_obj.attr_metadata_table(l_table_index).VALUE_SET_ID ;

      IF l_validation_type='F' THEN --  TABLE Validation type
         SELECT
               application_table_name,
               value_column_name,
               id_column_name,
               additional_where_clause
          INTO
               l_vs_table_name,
               l_vs_value_column,
               l_vs_id_column,
               l_vs_where_clause
          FROM EGO_VALIDATION_TABLE_INFO_V
          WHERE id_column_name IS NOT NULL
          AND   flex_value_set_id=p_attr_group_metadata_obj.attr_metadata_table(l_table_index).VALUE_SET_ID;

----bug 16073812
  ---------------------------------
      -- Trim off any leading spaces --
      ---------------------------------
          l_vs_where_clause := LTRIM(l_vs_where_clause);
           ---------------------------------------------
      -- Check whether the trimmed string starts --
      -- with 'WHERE'; if so, trim the 'WHERE'   --
      ---------------------------------------------
      IF (INSTR(UPPER(SUBSTR(l_vs_where_clause, 1, 6)), 'WHERE') <> 0) THEN
        l_vs_where_clause := SUBSTR(l_vs_where_clause, 6);
      END IF;
      Remove_OrderBy_Clause(l_vs_where_clause);
      -----------------------------------------------------
      -- Now, if where clause is non-empty, add an 'AND' --
      -- so that we can append our own where criteria    --
      -----------------------------------------------------

      IF (LENGTH(l_vs_where_clause) > 0) THEN

        ------------------------------------------------------
        -- In case the where clause has new line or tabs    --
        -- we need to remove it BugFix:4101091              --
        ------------------------------------------------------
        SELECT REPLACE(l_vs_where_clause,FND_GLOBAL.LOCAL_CHR(10),FND_GLOBAL.LOCAL_CHR(32)) INTO l_vs_where_clause FROM dual; --replacing new line character
        SELECT REPLACE(l_vs_where_clause,FND_GLOBAL.LOCAL_CHR(13),FND_GLOBAL.LOCAL_CHR(32)) INTO l_vs_where_clause FROM dual; --removing carriage return
        -------------------------------------------------------------------------
        -- well if there is still some special character left we cant help it. --
        -------------------------------------------------------------------------

        ------------------------------------------------------
        -- In case the where clause starts with an Order By --
        -- we need to add a 1=1 before the order by         --
        ------------------------------------------------------
        IF ( INSTR(LTRIM(UPPER(l_vs_where_clause)),'ORDER ') = 1 ) THEN
           IF (INSTR(UPPER(
                           SUBSTR(LTRIM(l_vs_where_clause),INSTR(LTRIM(UPPER(l_vs_where_clause)),'ORDER ')+6 )
                          ),'BY ') <> 0) THEN
            l_vs_where_clause := ' 1=1   ' || l_vs_where_clause ;
            END IF;
        END IF;

          l_dynamic_query :='SELECT '|| l_vs_value_column ||' FROM '||l_vs_table_name||' WHERE to_char('|| l_vs_id_column || ') = to_char('''||p_attr_name_value||''')'||' AND '||l_vs_where_clause;
      ELSE

          l_dynamic_query := 'SELECT ' || l_vs_value_column || ' FROM ' ||
                           l_vs_table_name || ' WHERE to_char(' ||
                           l_vs_id_column || ') = to_char(''' ||
                           p_attr_name_value || ''')';
      END IF;



		      IF (INSTR(UPPER(l_dynamic_query), ':$') > 0) THEN
		        l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(p_attr_metadata_table => p_attr_group_metadata_obj.attr_metadata_table,
		                                                                                p_attr_name           => p_attr_name_value_pairs(l_table_index)
		                                                                                                        .ATTR_NAME);

		        l_display_value := Tokenized_Val_Set_Query(p_attr_metadata_obj           => l_attr_metadata_obj,
		                                                   p_attr_group_metadata_obj     => p_attr_group_metadata_obj,
		                                                   p_ext_table_metadata_obj      => p_ext_table_metadata_obj,
		                                                   p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs,
		                                                   p_data_level_name_value_pairs => p_data_level_name_value_pairs,
		                                                   p_entity_id                   => p_entity_id,
		                                                   p_entity_index                => p_entity_index,
		                                                   p_entity_code                 => p_entity_code,
		                                                   p_attr_name_value_pairs       => p_attr_name_value_pairs,
		                                                   p_is_disp_to_int_query        => FALSE,
		                                                   p_final_bind_value            => p_attr_name_value,
		                                                   p_return_bound_sql            => FALSE);
		        l_disp_value(l_table_index) := l_display_value;

		      ELSE
		        EXECUTE IMMEDIATE l_dynamic_query
		          INTO l_disp_value(l_table_index);
		        Debug_Msg('in Fetch_UK_Attr_Display_Values, error is here ', 1);
		      END IF;
        ELSE -- Translatable Independent Validation Type
            IF p_attr_name_value_pairs(l_table_index).ATTR_VALUE_DATE IS NOT NULL THEN

                l_attr_value_date :=To_char(p_attr_name_value_pairs(l_table_index).ATTR_VALUE_DATE,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);

                SELECT
                        display_name INTO l_disp_value(l_table_index)
                  FROM ego_value_set_values_v
                  WHERE value_set_id=p_attr_group_metadata_obj.attr_metadata_table(l_table_index).VALUE_SET_ID
                  AND internal_name= trim(l_attr_value_date);

            ELSE
                  SELECT
                        display_name INTO l_disp_value(l_table_index)
                  FROM ego_value_set_values_v
                  WHERE value_set_id=p_attr_group_metadata_obj.attr_metadata_table(l_table_index).VALUE_SET_ID
                  AND To_Char(internal_name)= p_attr_name_value;
            END IF;
         END IF;

          RETURN  l_disp_value(l_table_index) ;

      EXCEPTION
           WHEN NO_DATA_FOUND THEN
           l_disp_value(l_table_index) := p_attr_name_value ;
           RETURN  l_disp_value(l_table_index) ;


END Fetch_UK_Attr_Display_Values;
----------------------------------------------------------------------

  FUNCTION Fetch_UK_Attr_Values_Table(p_attr_group_metadata_obj     IN EGO_ATTR_GROUP_METADATA_OBJ,
                                      p_ext_table_metadata_obj      IN EGO_EXT_TABLE_METADATA_OBJ DEFAULT NULL,
                                      p_pk_column_name_value_pairs  IN EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL,
                                      p_data_level_name_value_pairs IN EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL,
                                      p_entity_id                   IN VARCHAR2 DEFAULT NULL,
                                      p_entity_index                IN NUMBER DEFAULT NULL,
                                      p_entity_code                 IN VARCHAR2 DEFAULT NULL,
                                      p_attr_name_value_pairs       IN EGO_USER_ATTR_DATA_TABLE)
RETURN LOCAL_BIG_VARCHAR_TABLE
IS

    l_uk_attr_values_table   LOCAL_BIG_VARCHAR_TABLE;
    l_uk_attr_values_table_index NUMBER := 1;
    l_uk_attrs_count         NUMBER;
    l_table_index            NUMBER;
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;

  BEGIN

    ----------------------------------------------------------------
    -- We find out how many UK Attrs there are in the Attr Group, --
    -- so we don't waste time looping after we've found them all  --
    ----------------------------------------------------------------
    l_uk_attrs_count := p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT;

    IF (p_attr_name_value_pairs IS NULL OR
        p_attr_name_value_pairs.COUNT = 0) THEN

      --------------------------------------------------------
      -- If there were no values passed in, we need to show --
      -- 'NULL' in our error message for each UK value      --
      --------------------------------------------------------
      FOR i IN 1 .. l_uk_attrs_count
      LOOP
        l_uk_attr_values_table(i) := 'NULL';
      END LOOP;

    ELSE

      l_table_index := p_attr_name_value_pairs.FIRST;
      WHILE (l_table_index <= p_attr_name_value_pairs.LAST)
      LOOP
        EXIT WHEN (l_uk_attr_values_table.COUNT = l_uk_attrs_count);

        l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                 p_attr_metadata_table => p_attr_group_metadata_obj.attr_metadata_table
                                ,p_attr_name           => p_attr_name_value_pairs(l_table_index).ATTR_NAME
                               );

        -----------------------------------------------------
        -- If we find a UK Attr value, add it to our table --
        -----------------------------------------------------
        IF (l_attr_metadata_obj.UNIQUE_KEY_FLAG = 'Y') THEN

          IF (l_attr_metadata_obj.DATA_TYPE_CODE IS NULL OR
              l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
              l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

            l_uk_attr_values_table(l_uk_attr_values_table_index) := Fetch_UK_Attr_Display_Values(p_attr_group_metadata_obj,
                                                                                                 p_ext_table_metadata_obj,
                                                                                                 p_pk_column_name_value_pairs,
                                                                                                 p_data_level_name_value_pairs,
                                                                                                 p_entity_id,
                                                                                                 p_entity_index,
                                                                                                 p_entity_code,
                                                                                                 p_attr_name_value_pairs,
                                                                                                 p_attr_name_value_pairs(l_table_index)
                                                                                                 .ATTR_VALUE_STR,
                                                                                                 l_table_index);

          ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

 			l_uk_attr_values_table(l_uk_attr_values_table_index) := Fetch_UK_Attr_Display_Values(p_attr_group_metadata_obj,
                                                                                                 p_ext_table_metadata_obj,
                                                                                                 p_pk_column_name_value_pairs,
                                                                                                 p_data_level_name_value_pairs,
                                                                                                 p_entity_id,
                                                                                                 p_entity_index,
                                                                                                 p_entity_code,
                                                                                                 p_attr_name_value_pairs,
                                                                                                 p_attr_name_value_pairs(l_table_index)
                                                                                                 .ATTR_VALUE_NUM,
                                                                                                 l_table_index);

          ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
                 l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

            l_uk_attr_values_table(l_uk_attr_values_table_index) := Fetch_UK_Attr_Display_Values(p_attr_group_metadata_obj,
                                                                                                 p_ext_table_metadata_obj,
                                                                                                 p_pk_column_name_value_pairs,
                                                                                                 p_data_level_name_value_pairs,
                                                                                                 p_entity_id,
                                                                                                 p_entity_index,
                                                                                                 p_entity_code,
                                                                                                 p_attr_name_value_pairs,
                                                                                                 p_attr_name_value_pairs(l_table_index)
                                                                                                 .ATTR_VALUE_DATE,
                                                                                                 l_table_index);

          END IF;

          l_uk_attr_values_table_index := l_uk_attr_values_table_index + 1;
        END IF;

        l_table_index := p_attr_name_value_pairs.NEXT(l_table_index);
      END LOOP;
    END IF;

    RETURN l_uk_attr_values_table;

END Fetch_UK_Attr_Values_Table;

----------------------------------------------------------------------

FUNCTION Fetch_UK_Attr_Names_List (
        p_uk_attr_names_table           IN   LOCAL_MEDIUM_VARCHAR_TABLE
)
RETURN VARCHAR2
IS

    l_uk_attr_names_table_index NUMBER;
    l_uk_attr_names_list       VARCHAR2(100) := ''; -- tokens can only be 100 bytes long

  BEGIN

    --------------------------------------------------------------
    -- If there are more than 5 Unique Key Attributes, we try   --
    -- to make a list of them all; however, since ERROR_HANDLER --
    -- tokens can only be 100 bytes, we may well not be able    --
    -- to provide a complete list.  In that case, we tokenize   --
    -- the message with another message that basically says,    --
    -- "(the list is too long to display here)"                 --
    --------------------------------------------------------------
    l_uk_attr_names_table_index := p_uk_attr_names_table.FIRST;
    WHILE (l_uk_attr_names_table_index <= p_uk_attr_names_table.LAST)
    LOOP
      l_uk_attr_names_list := l_uk_attr_names_list ||
                              p_uk_attr_names_table(l_uk_attr_names_table_index) ||
                              ', ';
      l_uk_attr_names_table_index := p_uk_attr_names_table.NEXT(l_uk_attr_names_table_index);
    END LOOP;

    RETURN l_uk_attr_names_list;

  EXCEPTION
    WHEN OTHERS THEN
      Debug_Msg(' Fetch_UK_Attr_Names_List EXCEPTION OTHERS - '||SQLERRM);
      RETURN ERROR_HANDLER.Translate_Message('EGO', 'EGO_UK_TOO_LONG_TO_LIST');

END Fetch_UK_Attr_Names_List;

----------------------------------------------------------------------

PROCEDURE Get_Err_Info_For_UK_Not_Resp (
        p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_is_err_in_production_table    IN   BOOLEAN
       ,x_unique_key_err_msg            OUT NOCOPY VARCHAR2
       ,x_token_table                   OUT NOCOPY ERROR_HANDLER.Token_Tbl_Type
) IS

    l_uk_attr_names_table   LOCAL_MEDIUM_VARCHAR_TABLE;

  BEGIN

    l_uk_attr_names_table := Fetch_UK_Attr_Names_Table(p_attr_group_metadata_obj);

    IF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT = 1) THEN

      x_unique_key_err_msg := 'EGO_EF_UK1_NOT_RESP';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK1_NAME';
      x_token_table(2).TOKEN_VALUE := l_uk_attr_names_table(1);

    ELSIF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT = 2) THEN

      x_unique_key_err_msg := 'EGO_EF_UK2_NOT_RESP';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK1_NAME';
      x_token_table(2).TOKEN_VALUE := l_uk_attr_names_table(1);
      x_token_table(3).TOKEN_NAME := 'UK2_NAME';
      x_token_table(3).TOKEN_VALUE := l_uk_attr_names_table(2);

    ELSIF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT = 3) THEN

      x_unique_key_err_msg := 'EGO_EF_UK3_NOT_RESP';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK1_NAME';
      x_token_table(2).TOKEN_VALUE := l_uk_attr_names_table(1);
      x_token_table(3).TOKEN_NAME := 'UK2_NAME';
      x_token_table(3).TOKEN_VALUE := l_uk_attr_names_table(2);
      x_token_table(4).TOKEN_NAME := 'UK3_NAME';
      x_token_table(4).TOKEN_VALUE := l_uk_attr_names_table(3);

    ELSIF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT = 4) THEN

      x_unique_key_err_msg := 'EGO_EF_UK4_NOT_RESP';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK1_NAME';
      x_token_table(2).TOKEN_VALUE := l_uk_attr_names_table(1);
      x_token_table(3).TOKEN_NAME := 'UK2_NAME';
      x_token_table(3).TOKEN_VALUE := l_uk_attr_names_table(2);
      x_token_table(4).TOKEN_NAME := 'UK3_NAME';
      x_token_table(4).TOKEN_VALUE := l_uk_attr_names_table(3);
      x_token_table(5).TOKEN_NAME := 'UK4_NAME';
      x_token_table(5).TOKEN_VALUE := l_uk_attr_names_table(4);

    ELSIF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT = 5) THEN

      x_unique_key_err_msg := 'EGO_EF_UK5_NOT_RESP';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK1_NAME';
      x_token_table(2).TOKEN_VALUE := l_uk_attr_names_table(1);
      x_token_table(3).TOKEN_NAME := 'UK2_NAME';
      x_token_table(3).TOKEN_VALUE := l_uk_attr_names_table(2);
      x_token_table(4).TOKEN_NAME := 'UK3_NAME';
      x_token_table(4).TOKEN_VALUE := l_uk_attr_names_table(3);
      x_token_table(5).TOKEN_NAME := 'UK4_NAME';
      x_token_table(5).TOKEN_VALUE := l_uk_attr_names_table(4);
      x_token_table(6).TOKEN_NAME := 'UK5_NAME';
      x_token_table(6).TOKEN_VALUE := l_uk_attr_names_table(5);

    ELSE

      x_unique_key_err_msg := 'EGO_EF_LONG_UK_NOT_RESP';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK_NAME_LIST';
      x_token_table(2).TOKEN_VALUE := Fetch_UK_Attr_Names_List(l_uk_attr_names_table);

    END IF;

END Get_Err_Info_For_UK_Not_Resp;

----------------------------------------------------------------------

  PROCEDURE Get_Err_Info_For_UK_Violation(p_attr_group_metadata_obj     IN EGO_ATTR_GROUP_METADATA_OBJ,
                                          p_ext_table_metadata_obj      IN EGO_EXT_TABLE_METADATA_OBJ DEFAULT NULL,
                                          p_pk_column_name_value_pairs  IN EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL,
                                          p_data_level_name_value_pairs IN EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL,
                                          p_entity_id                   IN VARCHAR2 DEFAULT NULL,
                                          p_entity_index                IN NUMBER DEFAULT NULL,
                                          p_entity_code                 IN VARCHAR2 DEFAULT NULL,
                                          p_attr_name_value_pairs       IN EGO_USER_ATTR_DATA_TABLE,
                                          p_is_err_in_production_table  IN BOOLEAN,
                                          x_unique_key_err_msg          OUT NOCOPY VARCHAR2,
                                          x_token_table                 OUT NOCOPY ERROR_HANDLER.Token_Tbl_Type) IS

    l_uk_attr_names_table   LOCAL_MEDIUM_VARCHAR_TABLE;
    l_uk_attr_values_table   LOCAL_BIG_VARCHAR_TABLE;

  BEGIN

    l_uk_attr_names_table := Fetch_UK_Attr_Names_Table(p_attr_group_metadata_obj);
	l_uk_attr_values_table := Fetch_UK_Attr_Values_Table(p_attr_group_metadata_obj,
                                                         p_ext_table_metadata_obj,
                                                         p_pk_column_name_value_pairs,
                                                         p_data_level_name_value_pairs,
                                                         p_entity_id,
                                                         p_entity_index,
                                                         p_entity_code,
                                                         p_attr_name_value_pairs);

    IF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT = 1) THEN

      x_unique_key_err_msg := 'EGO_EF_UK1_VIOLATION';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK1_NAME';
      x_token_table(2).TOKEN_VALUE := l_uk_attr_names_table(1);
      x_token_table(3).TOKEN_NAME := 'ATTR1_VALUE';
      x_token_table(3).TOKEN_VALUE := l_uk_attr_values_table(1);

    ELSIF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT = 2) THEN

      x_unique_key_err_msg := 'EGO_EF_UK2_VIOLATION';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK1_NAME';
      x_token_table(2).TOKEN_VALUE := l_uk_attr_names_table(1);
      x_token_table(3).TOKEN_NAME := 'ATTR1_VALUE';
      x_token_table(3).TOKEN_VALUE := l_uk_attr_values_table(1);
      x_token_table(4).TOKEN_NAME := 'UK2_NAME';
      x_token_table(4).TOKEN_VALUE := l_uk_attr_names_table(2);
      x_token_table(5).TOKEN_NAME := 'ATTR2_VALUE';
      x_token_table(5).TOKEN_VALUE := l_uk_attr_values_table(2);

    ELSIF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT = 3) THEN

      x_unique_key_err_msg := 'EGO_EF_UK3_VIOLATION';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK1_NAME';
      x_token_table(2).TOKEN_VALUE := l_uk_attr_names_table(1);
      x_token_table(3).TOKEN_NAME := 'ATTR1_VALUE';
      x_token_table(3).TOKEN_VALUE := l_uk_attr_values_table(1);
      x_token_table(4).TOKEN_NAME := 'UK2_NAME';
      x_token_table(4).TOKEN_VALUE := l_uk_attr_names_table(2);
      x_token_table(5).TOKEN_NAME := 'ATTR2_VALUE';
      x_token_table(5).TOKEN_VALUE := l_uk_attr_values_table(2);
      x_token_table(6).TOKEN_NAME := 'UK3_NAME';
      x_token_table(6).TOKEN_VALUE := l_uk_attr_names_table(3);
      x_token_table(7).TOKEN_NAME := 'ATTR3_VALUE';
      x_token_table(7).TOKEN_VALUE := l_uk_attr_values_table(3);

    ELSIF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT = 4) THEN

      x_unique_key_err_msg := 'EGO_EF_UK4_VIOLATION';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK1_NAME';
      x_token_table(2).TOKEN_VALUE := l_uk_attr_names_table(1);
      x_token_table(3).TOKEN_NAME := 'ATTR1_VALUE';
      x_token_table(3).TOKEN_VALUE := l_uk_attr_values_table(1);
      x_token_table(4).TOKEN_NAME := 'UK2_NAME';
      x_token_table(4).TOKEN_VALUE := l_uk_attr_names_table(2);
      x_token_table(5).TOKEN_NAME := 'ATTR2_VALUE';
      x_token_table(5).TOKEN_VALUE := l_uk_attr_values_table(2);
      x_token_table(6).TOKEN_NAME := 'UK3_NAME';
      x_token_table(6).TOKEN_VALUE := l_uk_attr_names_table(3);
      x_token_table(7).TOKEN_NAME := 'ATTR3_VALUE';
      x_token_table(7).TOKEN_VALUE := l_uk_attr_values_table(3);
      x_token_table(8).TOKEN_NAME := 'UK4_NAME';
      x_token_table(8).TOKEN_VALUE := l_uk_attr_names_table(4);
      x_token_table(9).TOKEN_NAME := 'ATTR4_VALUE';
      x_token_table(9).TOKEN_VALUE := l_uk_attr_values_table(4);

    ELSIF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT = 5) THEN

      x_unique_key_err_msg := 'EGO_EF_UK4_VIOLATION';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK1_NAME';
      x_token_table(2).TOKEN_VALUE := l_uk_attr_names_table(1);
      x_token_table(3).TOKEN_NAME := 'ATTR1_VALUE';
      x_token_table(3).TOKEN_VALUE := l_uk_attr_values_table(1);
      x_token_table(4).TOKEN_NAME := 'UK2_NAME';
      x_token_table(4).TOKEN_VALUE := l_uk_attr_names_table(2);
      x_token_table(5).TOKEN_NAME := 'ATTR2_VALUE';
      x_token_table(5).TOKEN_VALUE := l_uk_attr_values_table(2);
      x_token_table(6).TOKEN_NAME := 'UK3_NAME';
      x_token_table(6).TOKEN_VALUE := l_uk_attr_names_table(3);
      x_token_table(7).TOKEN_NAME := 'ATTR3_VALUE';
      x_token_table(7).TOKEN_VALUE := l_uk_attr_values_table(3);
      x_token_table(8).TOKEN_NAME := 'UK4_NAME';
      x_token_table(8).TOKEN_VALUE := l_uk_attr_names_table(4);
      x_token_table(9).TOKEN_NAME := 'ATTR4_VALUE';
      x_token_table(9).TOKEN_VALUE := l_uk_attr_values_table(4);
      x_token_table(10).TOKEN_NAME := 'UK5_NAME';
      x_token_table(10).TOKEN_VALUE := l_uk_attr_names_table(5);
      x_token_table(11).TOKEN_NAME := 'ATTR5_VALUE';
      x_token_table(11).TOKEN_VALUE := l_uk_attr_values_table(5);

    ELSE

      x_unique_key_err_msg := 'EGO_EF_LONG_UK_VIOLATION';

      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'UK_NAME_LIST';
      x_token_table(2).TOKEN_VALUE := Fetch_UK_Attr_Names_List(l_uk_attr_names_table);

    END IF;

END Get_Err_Info_For_UK_Violation;

----------------------------------------------------------------------

PROCEDURE Get_Extension_Id_And_Mode (
        p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_extension_id                  IN   NUMBER     DEFAULT NULL
       ,p_mode                          IN   VARCHAR2   DEFAULT NULL
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_extra_pk_col_name_val_pairs IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT NULL
       ,p_entity_id                     IN   VARCHAR2   DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_mode                          OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Get_Extension_Id_And_Mode';

    l_is_change_case         BOOLEAN;
    l_extra_pk_present       BOOLEAN;
    l_production_ext_id      NUMBER;
    l_pending_ext_id         NUMBER;
    l_error_message_name     VARCHAR2(30);
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;

  BEGIN

    Debug_Msg('In Get_Extension_Id_And_Mode, starting with p_mode as '||p_mode||' and p_extension_id as '||p_extension_id, 2);

Debug_Msg('In Get_Extension_Id_And_Mode,  p_data_level='||p_data_level);

    --------------------------------------------------------------
    -- In this section we try to find extension IDs for the row --
    -- whose data we have in both the production table and, if  --
    -- appropriate, in the pending table; this effort serves as --
    -- the Unique Key check for multi-row Attribute Groups and  --
    -- will also allow us to determine (or validate) the mode.  --
    --------------------------------------------------------------
    l_is_change_case := (p_change_obj IS NOT NULL);

    l_production_ext_id := Get_Extension_Id_For_Row(
                             p_attr_group_metadata_obj     => p_attr_group_metadata_obj
                            ,p_ext_table_metadata_obj      => p_ext_table_metadata_obj
                            ,p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
                            ,p_data_level                  => p_data_level
                            ,p_data_level_name_value_pairs => p_data_level_name_value_pairs
                            ,p_attr_name_value_pairs       => p_attr_name_value_pairs
                           );

    IF (l_is_change_case) THEN

      l_pending_ext_id := Get_Extension_Id_For_Row(
                            p_attr_group_metadata_obj     => p_attr_group_metadata_obj
                           ,p_ext_table_metadata_obj      => p_ext_table_metadata_obj
                           ,p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
                           ,p_data_level                  => p_data_level
                           ,p_data_level_name_value_pairs => p_data_level_name_value_pairs
                           ,p_attr_name_value_pairs       => p_attr_name_value_pairs
                           ,p_change_obj                  => p_change_obj
                           ,p_pending_b_table_name        => p_pending_b_table_name
                           ,p_pending_vl_name             => p_pending_vl_name
                          );

    END IF;

    l_extra_pk_present := (p_extra_pk_col_name_val_pairs IS NOT NULL);


    IF (l_extra_pk_present) THEN

      l_pending_ext_id := Get_Extension_Id_For_Row(
                            p_attr_group_metadata_obj     => p_attr_group_metadata_obj
                           ,p_ext_table_metadata_obj      => p_ext_table_metadata_obj
                           ,p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
                           ,p_data_level                  => p_data_level
                           ,p_data_level_name_value_pairs => p_data_level_name_value_pairs
                           ,p_attr_name_value_pairs       => p_attr_name_value_pairs
                           ,p_change_obj                  => p_change_obj
                           ,p_extra_pk_col_name_val_pairs => p_extra_pk_col_name_val_pairs
                           ,p_pending_b_table_name        => p_pending_b_table_name
                           ,p_pending_vl_name             => p_pending_vl_name
                          );

      -- Here we are assuming that the extension_id passed is the correct one even though
      -- we cannot find it in the pending table. This was a specific requirement raised by
      -- CM where they do not save the UK's which are not changed in the pending table and
      -- hence they want this check to be overlooked.
      -- GNANDA
      IF (p_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y' AND
          l_pending_ext_id IS NULL AND
          p_extension_id IS NOT NULL) THEN
          l_pending_ext_id := p_extension_id;
      END IF;



    END IF;

    Debug_Msg('In Get_Extension_Id_And_Mode, l_production_ext_id is '||l_production_ext_id||' and l_pending_ext_id is '||l_pending_ext_id, 3);

    IF (p_attr_group_metadata_obj.MULTI_ROW_CODE = 'N') THEN
      IF (p_extension_id IS NOT NULL) THEN

        x_extension_id := p_extension_id;

      ELSE

        -----------------------------------------------------
        -- If we're inserting into the pending table a row --
        -- that comes from a production row, we'll want to --
        -- preserve the production row's extension ID      --
        -----------------------------------------------------
        IF (l_is_change_case AND
            p_mode = G_CREATE_MODE AND
            p_change_obj.ACD_TYPE <> 'ADD') THEN

          x_extension_id := l_production_ext_id;

        END IF;
      END IF;
    ELSIF (p_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y') THEN
      IF (p_extension_id IS NOT NULL) THEN

        IF (p_mode = G_DELETE_MODE OR
            (l_is_change_case AND p_change_obj.ACD_TYPE = 'DELETE')) THEN

          ------------------------------------------------------------
          -- If user is trying to delete from the UI, we don't want --
          -- to worry about Unique Key violations; we just want to  --
          -- delete whatever row the user tells us to delete        --
          ------------------------------------------------------------
          x_extension_id := p_extension_id;

        ELSE

          ----------------------------------------------------------------------------
          -- If the extension ID is passed in and the Attribute Group is multi-row, --
          -- then we have to ensure that the values we'll be updating won't result  --
          -- in a Unique Key violation.  So we check to ensure that a row like the  --
          -- passed-in row doesn't exist in the production table (and, if we're in  --
          -- change case, we check the pending table as well).  If we get an ext ID --
          -- for either table that's not the same as the passed-in ext ID, we raise --
          -- an error.  If, on the other hand, whatever ext IDs we find match the   --
          -- passed-in ext ID, that just means we found the row that the user wants --
          -- to update, so we have no problem.  Likewise, if we don't find any ext  --
          -- IDs, that means the user is changing Unique Key values to some new and --
          -- still-unique combination, in which case we accept the passed-in ext ID --
          ----------------------------------------------------------------------------
          IF ((l_production_ext_id IS NOT NULL AND
               l_production_ext_id <> p_extension_id) OR
              (l_pending_ext_id IS NOT NULL AND
               l_pending_ext_id <> p_extension_id)) THEN

            IF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT > 0) THEN

              -----------------------------------------------
              -- If we found more than one row, the Unique --
              -- Key is not respected in the current data  --
              -----------------------------------------------
              IF (l_production_ext_id = -1 OR
                  l_pending_ext_id = -1) THEN

                Get_Err_Info_For_UK_Not_Resp(p_attr_group_metadata_obj
                                            ,(l_production_ext_id = -1)
                                            ,l_error_message_name
                                            ,l_token_table);

              -----------------------------------------------------------------
              -- If, on the other hand, we found exactly one row, the Unique --
              -- Key is respected but the current row would violate it       --
              -----------------------------------------------------------------
              ELSE
				Get_Err_Info_For_UK_Violation(p_attr_group_metadata_obj,
                                              p_ext_table_metadata_obj,
                                              p_pk_column_name_value_pairs,
                                              p_data_level_name_value_pairs,
                                              p_entity_id,
                                              p_entity_index,
                                              p_entity_code,
                                              p_attr_name_value_pairs,
                                              (l_production_ext_id IS NOT NULL),
                                              l_error_message_name,
                                              l_token_table);

              END IF;

            ELSE

              l_error_message_name := 'EGO_EF_NO_UNIQUE_KEY';

              l_token_table(1).TOKEN_NAME := 'AG_NAME';
              l_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;

            END IF;

          ----------------------------------------------------------
          -- As mentioned above, if both are null then we assume  --
          -- that we're changing UK values and that the passed-in --
          -- ext ID must be the correct ext ID to do so           --
          ----------------------------------------------------------
          ELSIF (l_production_ext_id IS NULL AND
                 l_pending_ext_id IS NULL) THEN

            x_extension_id := p_extension_id;

          END IF;
        END IF;
      ELSE

        -------------------------------------------------------------------------
        -- In this case the extension IDs we fetched will determine whether we --
        -- are inserting or updating--and, if the latter, which row we update. --
        -------------------------------------------------------------------------
        IF (l_production_ext_id IS NOT NULL OR
            l_pending_ext_id IS NOT NULL) THEN

          -------------------------------------------------------------------------
          -- If we found more than one row in either table (signaled by the -1)  --
          -- then we either have no Unique Key or one that's not respected       --
          -------------------------------------------------------------------------
          IF (l_production_ext_id = -1 OR
              l_pending_ext_id = -1) THEN

            IF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT > 0) THEN

              ----------------------------------------------------------
              -- If we found more than one row, the Unique Key is not --
              -- respected in the current data in at least one table  --
              ----------------------------------------------------------
              Get_Err_Info_For_UK_Not_Resp(p_attr_group_metadata_obj
                                          ,(l_production_ext_id = -1)
                                          ,l_error_message_name
                                          ,l_token_table);


            ELSE

              l_error_message_name := 'EGO_EF_NO_UNIQUE_KEY';

              l_token_table(1).TOKEN_NAME := 'AG_NAME';
              l_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;

            END IF;

          ---------------------------------------------------------
          -- If the mode is 'CREATE', then the current row would --
          -- violate the UK if any of the following applies:     --
          -- * user is inserting into the pending table and      --
          --   + there's already a row in the pending table, or  --
          --   + the ACD type is also 'CREATE', and there's      --
          --     already a row in the production table           --
          -- * user is inserting into the production table and   --
          --   there's already a row in the production table     --
          ---------------------------------------------------------
          ELSIF (p_mode = G_CREATE_MODE AND
                 ((l_is_change_case AND
                   (l_pending_ext_id IS NOT NULL OR
                    (p_change_obj.ACD_TYPE = 'ADD' AND
                     l_production_ext_id IS NOT NULL))) OR
                  ((NOT l_is_change_case AND NOT l_extra_pk_present) AND
                   l_production_ext_id IS NOT NULL))) THEN

            IF (p_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT > 0) THEN

              -------------------------------------------------------
              -- If we found an ext ID for at least one table, the --
              -- Unique Key would be violated by adding this row   --
              -------------------------------------------------------
                Get_Err_Info_For_UK_Violation(p_attr_group_metadata_obj,
                                              p_ext_table_metadata_obj,
                                              p_pk_column_name_value_pairs,
                                              p_data_level_name_value_pairs,
                                              p_entity_id,
                                              p_entity_index,
                                              p_entity_code,
                                              p_attr_name_value_pairs,
                                              (l_production_ext_id IS NOT NULL),
                                              l_error_message_name,
                                              l_token_table);
            ELSE

              l_error_message_name := 'EGO_EF_NO_UK_FOR_CREATE';

              l_token_table(1).TOKEN_NAME := 'AG_NAME';
              l_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;

            END IF;
          END IF;
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    -- Whatever error message we built in the preceding lines, we now log --
    ------------------------------------------------------------------------
    IF (l_error_message_name IS NOT NULL) THEN

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => l_error_message_name
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );

      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_extension_id IS NULL) THEN
      --------------------------------------------------------------------
      -- If there was no error and we don't yet have the ext ID, set it --
      -- based on the table on which the user is trying to perform DML  --
      --------------------------------------------------------------------
      IF (l_is_change_case OR l_extra_pk_present) THEN
        x_extension_id := l_pending_ext_id;
      ELSE
        x_extension_id := l_production_ext_id;
      END IF;
    END IF;

    --------------------------------------------------------------------------
    -- If the caller didn't pass a mode, we behave as if we're in SYNC mode --
    --------------------------------------------------------------------------
    IF (p_mode IS NOT NULL AND
        UPPER(p_mode) <> G_SYNC_MODE) THEN
      x_mode := UPPER(p_mode);
    ELSE
      IF (x_extension_id IS NULL) THEN
        x_mode := G_CREATE_MODE;
      ELSE
        x_mode := G_UPDATE_MODE;
      END IF;
    END IF;

    ------------------------------------------------------------------
    -- If we don't have an extension ID at this point, then either  --
    -- we are in CREATE mode or there's an error somewhere.  If, on --
    -- the other hand, we *do* have an extension ID and the mode is --
    -- CREATE, that's also an error (unless we're in Change mode,   --
    -- in which case we sometimes take in an extension ID)          --
    ------------------------------------------------------------------
    IF (x_extension_id IS NULL AND x_mode <> G_CREATE_MODE) THEN

      l_error_message_name := 'EGO_EF_ROW_NOT_FOUND';

      l_token_table(1).TOKEN_NAME := 'AG_NAME';
      l_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => l_error_message_name
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );

      RAISE FND_API.G_EXC_ERROR;

    ELSIF (x_extension_id IS NOT NULL AND
           x_mode = G_CREATE_MODE AND
           (NOT l_is_change_case OR p_change_obj.ACD_TYPE = 'ADD')) THEN

      l_error_message_name := 'EGO_EF_ROW_ALREADY_EXISTS';

      l_token_table(1).TOKEN_NAME := 'AG_NAME';
      l_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => l_error_message_name
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );

      RAISE FND_API.G_EXC_ERROR;

    END IF;

    ----------------------------------------------------------------------
    -- There is one circumstance (coming from Implement_Change_Line) in --
    -- which we take in an extension ID but want to operate in CREATE   --
    -- mode; to pass our error checks, we use G_IMPLEMENT_CREATE_MODE   --
    ----------------------------------------------------------------------
    IF (x_mode = G_IMPLEMENT_CREATE_MODE) THEN
      x_mode := G_CREATE_MODE;
    END IF;

    ----------------------------------------------------------------------
    -- If we're bulkloading, we don't accept empty rows in CREATE mode; --
    -- from the UI we do, because there are cases (e.g., seeded AGs) in --
    -- which other teams' code always assumes that a join to our tables --
    -- will succeed (even if there's no data in our tables)             --
    ----------------------------------------------------------------------
    IF (x_mode = G_CREATE_MODE AND
        All_Attr_Values_Are_Null(p_attr_name_value_pairs) AND
        G_BULK_PROCESSING_FLAG) THEN

      l_error_message_name := 'EGO_EF_NO_ATTR_VALS_TO_INSERT';

      l_token_table(1).TOKEN_NAME := 'AG_NAME';
      l_token_table(1).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => l_error_message_name
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );

      RAISE FND_API.G_EXC_ERROR;

    END IF;
    Debug_Msg('In Get_Extension_Id_And_Mode, done', 2);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg(' Get_Extension_Id_And_Mode EXCEPTION FND_API.G_EXC_ERROR ');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN

      Debug_Msg(' Get_Extension_Id_And_Mode EXCEPTION OTHERS '||SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      l_token_table.DELETE();
      l_token_table(1).TOKEN_NAME := 'PKG_NAME';
      l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
      l_token_table(2).TOKEN_NAME := 'API_NAME';
      l_token_table(2).TOKEN_VALUE := l_api_name;
      l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
      l_token_table(3).TOKEN_VALUE := SQLERRM;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => 'EGO_PLSQL_ERR'
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );

END Get_Extension_Id_And_Mode;

----------------------------------------------------------------------

FUNCTION Do_All_Attrs_Exist (
        p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
)
RETURN BOOLEAN
IS

    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_attr_count             NUMBER;
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;
    l_all_exist              BOOLEAN := TRUE;

  BEGIN

    Debug_Msg('In Do_All_Attrs_Exist, starting', 2);

    l_token_table(1).TOKEN_NAME := 'BAD_ATTR_NAME';
    -- the token value will be set every time we find a missing Attr
    l_token_table(2).TOKEN_NAME := 'AG_NAME';
    l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_NAME;

    IF (p_attr_name_value_pairs IS NOT NULL AND
        p_attr_name_value_pairs.COUNT > 0) THEN
      l_attr_count := p_attr_name_value_pairs.FIRST;
      WHILE (l_attr_count <= p_attr_name_value_pairs.LAST)
      LOOP

        l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                 p_attr_metadata_table => p_attr_group_metadata_obj.attr_metadata_table
                                ,p_attr_name           => p_attr_name_value_pairs(l_attr_count).ATTR_NAME
                               );
        IF (l_attr_metadata_obj IS NULL OR
            l_attr_metadata_obj.ATTR_NAME IS NULL) THEN

          --------------------------------------------------------------------
          -- If we can't find metadata for this Attribute, report the error --
          --------------------------------------------------------------------
          l_all_exist := FALSE;

          l_token_table(1).TOKEN_VALUE := p_attr_name_value_pairs(l_attr_count).ATTR_NAME;

          ERROR_HANDLER.Add_Error_Message(
            p_message_name      => 'EGO_EF_ATTR_DOES_NOT_EXIST'
           ,p_application_id    => 'EGO'
           ,p_token_tbl         => l_token_table
           ,p_message_type      => FND_API.G_RET_STS_ERROR
           ,p_row_identifier    => G_USER_ROW_IDENTIFIER
           ,p_entity_id         => p_entity_id
           ,p_entity_index      => p_entity_index
           ,p_entity_code       => p_entity_code
           ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
          );

        END IF;

        l_attr_count := p_attr_name_value_pairs.NEXT(l_attr_count);
      END LOOP;
    END IF;

    Debug_Msg('In Do_All_Attrs_Exist, done', 2);

    RETURN l_all_exist;

END Do_All_Attrs_Exist;

----------------------------------------------------------------------


FUNCTION Are_These_Col_Names_Right (
        p_ext_table_col_metadata        IN   EGO_COL_METADATA_ARRAY
       ,p_col_name_value_pairs          IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
)
RETURN BOOLEAN
IS

    l_name_value_pair_index  NUMBER;
    l_col_metadata_obj       EGO_COL_METADATA_OBJ;
    l_col_name_candidate     VARCHAR2(30);
    l_are_names_right        BOOLEAN := TRUE;
    l_found_this_col_name    BOOLEAN := FALSE;

  BEGIN

    Debug_Msg('In Are_These_Col_Names_Right, starting');

    --------------------------------------------------------------
    -- Loop through the name/value pair array: for every column --
    -- name, look in the extension table metadata column list   --
    -- to find a match.  If we don't find a match, we return    --
    -- FALSE; if we find matches for all the columns in the     --
    -- name/value pair list, we return TRUE.  If the name/value --
    -- pair array is null or empty, it passes.                  --
    --------------------------------------------------------------
    IF (p_col_name_value_pairs IS NOT NULL AND
        p_col_name_value_pairs.COUNT > 0) THEN

      l_name_value_pair_index := p_col_name_value_pairs.FIRST;
      WHILE (l_name_value_pair_index <= p_col_name_value_pairs.LAST)
      LOOP
        EXIT WHEN (NOT l_are_names_right);

        l_col_name_candidate := p_col_name_value_pairs(l_name_value_pair_index).NAME;
        l_found_this_col_name := FALSE;

        -----------------------------------------------------
        -- If we can find this candidate or if it's a list --
        -- of related classification codes, we pass it     --
        -----------------------------------------------------
        IF (INSTR(UPPER(l_col_name_candidate), 'RELATED_CLASS_CODE_LIST') <> 0) THEN

          l_found_this_col_name := TRUE;

        ELSE

          l_col_metadata_obj := Find_Metadata_For_Col(p_ext_table_col_metadata
                                                     ,l_col_name_candidate);
          l_found_this_col_name := (l_col_metadata_obj IS NOT NULL);

        END IF;

        l_are_names_right := l_found_this_col_name;

        IF (NOT l_are_names_right) THEN
          Debug_Msg('In Are_These_Col_Names_Right, unidentified column name is: '||l_col_name_candidate);
        END IF;

        l_name_value_pair_index := p_col_name_value_pairs.NEXT(l_name_value_pair_index);
      END LOOP;
    END IF;

    IF (l_are_names_right) THEN
      Debug_Msg('In Are_These_Col_Names_Right, returning TRUE');
    ELSE
      Debug_Msg('In Are_These_Col_Names_Right, returning FALSE');
    END IF;

    RETURN l_are_names_right;

END Are_These_Col_Names_Right;

----------------------------------------------------------------------

FUNCTION Are_Ext_Table_Col_Names_Right (
        p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
)
RETURN BOOLEAN
IS

    l_are_names_right        BOOLEAN := TRUE;

  BEGIN

    Debug_Msg('In Are_Ext_Table_Col_Names_Right, starting', 2);

    l_are_names_right := Are_These_Col_Names_Right(p_ext_table_metadata_obj.pk_column_metadata
                                                  ,p_pk_column_name_value_pairs);

    IF (l_are_names_right AND
        p_class_code_name_value_pairs IS NOT NULL) THEN
      l_are_names_right := Are_These_Col_Names_Right(p_ext_table_metadata_obj.class_code_metadata
                                                    ,p_class_code_name_value_pairs);
    END IF;

    IF (l_are_names_right) THEN
      Debug_Msg('In Are_Ext_Table_Col_Names_Right, done; returning TRUE', 2);
    ELSE
      Debug_Msg('In Are_Ext_Table_Col_Names_Right, done; returning FALSE', 2);
    END IF;

    RETURN l_are_names_right;

  EXCEPTION
    WHEN OTHERS THEN
      Debug_Msg(' Are_Ext_Table_Col_Names_Right EXCEPTION OTHERS '||SQLERRM);
      RETURN FALSE;

END Are_Ext_Table_Col_Names_Right;

----------------------------------------------------------------------

FUNCTION Is_Data_Level_Correct (
        p_object_id                     IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_group_disp_name          IN   VARCHAR2
       ,x_err_msg_name                  OUT NOCOPY VARCHAR2
       ,x_token_table                   OUT NOCOPY ERROR_HANDLER.Token_Tbl_Type
)
RETURN BOOLEAN IS

    l_api_name                VARCHAR2(50) := 'Is_Data_Level_Correct';
    l_cursor_id               NUMBER;
    l_dummy                   NUMBER;
    l_obj_and_class           VARCHAR2(1100);
    l_data_level              EGO_OBJ_AG_ASSOCS_B.DATA_LEVEL%TYPE;
    l_data_level_id           NUMBER;
    l_is_data_level_correct   BOOLEAN := TRUE;
    l_cc_value_list           VARCHAR2(1000);
    l_dynamic_sql             VARCHAR2(5500);
    l_data_level_index        NUMBER;
    l_data_level_progress_point VARCHAR2(10);
    l_wrong_data_level        VARCHAR2(80);
    l_item_ag_count          INT;
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_enabled_data_level_table EGO_DATA_LEVEL_TABLE;
    l_data_level_metadata      EGO_DATA_LEVEL_METADATA_OBJ;
    l_column_matched           BOOLEAN;
    l_data_level_matched       BOOLEAN;
    l_dl_pk_col_list           VARCHAR2(200);

    l_data_level_list    VARCHAR2(5000);
    l_start_index        NUMBER;
    l_end_index          NUMBER;

  BEGIN
    --bug 7701752 : if AG is EGO_ITEMMGMT_GROUP and ItemDetailImage,ItemDetailDesc, exclude it, because it is associated by default, added by chris.zhao at 2009-01-19
    SELECT COUNT (*)
      INTO l_item_ag_count
      FROM ego_attr_groups_v
     WHERE attr_group_type = 'EGO_ITEMMGMT_GROUP' AND (attr_group_id = 1 OR attr_group_id = 2) AND attr_group_id = p_attr_group_id ;

    IF (l_item_ag_count > 0)
    THEN
      debug_msg (' For pseudo association, exclude ItemDetailImage,ItemDetailDesc for ITEM AG', 2);
      RETURN TRUE;
    END IF;

    Debug_Msg(l_api_name || ' starting with p_data_level '||p_data_level, 2);

    -----------------------------------------------------------------
    -- If data level has been provided we need to verify it from   --
    -- the metadata.                                               --
    -----------------------------------------------------------------
    IF (p_data_level IS NOT NULL) THEN

      l_data_level_matched := FALSE;
      l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata
                                          (p_attr_group_id  =>  p_attr_group_id);
      l_enabled_data_level_table := l_attr_group_metadata_obj.ENABLED_DATA_LEVELS;

      FOR i IN l_enabled_data_level_table.FIRST .. l_enabled_data_level_table.LAST
      LOOP
        IF(l_enabled_data_level_table(i).DATA_LEVEL_NAME = p_data_level) THEN
          l_data_level_metadata := EGO_USER_ATTRS_COMMON_PVT.get_data_level_metadata(
                                       p_data_level_id => l_enabled_data_level_table(i).DATA_LEVEL_ID
                                                                                    );
          l_data_level_matched := TRUE;
          l_column_matched := TRUE;
          l_dl_pk_col_list := '';
          IF p_data_level_name_value_pairs IS NOT NULL AND p_data_level_name_value_pairs.COUNT > 0 THEN
            FOR j IN p_data_level_name_value_pairs.FIRST .. p_data_level_name_value_pairs.LAST
            LOOP
               --Each col in the provided dl pk col list should be valid
               IF(    p_data_level_name_value_pairs(j).NAME <> l_data_level_metadata.PK_COLUMN_NAME1
                  AND p_data_level_name_value_pairs(j).NAME <> l_data_level_metadata.PK_COLUMN_NAME2
                  AND p_data_level_name_value_pairs(j).NAME <> l_data_level_metadata.PK_COLUMN_NAME3
                  AND p_data_level_name_value_pairs(j).NAME <> l_data_level_metadata.PK_COLUMN_NAME4
                  AND p_data_level_name_value_pairs(j).NAME <> l_data_level_metadata.PK_COLUMN_NAME5) THEN
                 l_column_matched:= FALSE;
               END IF;
               l_dl_pk_col_list := l_dl_pk_col_list||' '||p_data_level_name_value_pairs(j).NAME;
            END LOOP;

            -- All the pk columns should be present in the provided DL columns list.
            IF(    (l_data_level_metadata.PK_COLUMN_NAME1 IS NOT NULL AND INSTR(l_dl_pk_col_list,l_data_level_metadata.PK_COLUMN_NAME1) = 0)
               AND (l_data_level_metadata.PK_COLUMN_NAME2 IS NOT NULL AND INSTR(l_dl_pk_col_list,l_data_level_metadata.PK_COLUMN_NAME2) = 0)
               AND (l_data_level_metadata.PK_COLUMN_NAME3 IS NOT NULL AND INSTR(l_dl_pk_col_list,l_data_level_metadata.PK_COLUMN_NAME3) = 0)
               AND (l_data_level_metadata.PK_COLUMN_NAME4 IS NOT NULL AND INSTR(l_dl_pk_col_list,l_data_level_metadata.PK_COLUMN_NAME4) = 0)
               AND (l_data_level_metadata.PK_COLUMN_NAME5 IS NOT NULL AND INSTR(l_dl_pk_col_list,l_data_level_metadata.PK_COLUMN_NAME5) = 0)
              ) THEN
                 l_column_matched:= FALSE;
            END IF;
          END IF;

          IF(NOT l_column_matched) THEN
            RETURN FALSE;
          END IF;
        END IF;   --l_enabled_data_level_table(i).DATA_LEVEL_NAME = p_data_level
      END LOOP;

      IF(l_data_level_matched AND l_column_matched) THEN
      --If the passed in data level is fine we check the association of the data level with the classification
        Init();
        FND_DSQL.Add_Text(' SELECT DATA_LEVEL FROM EGO_OBJ_AG_ASSOCS_B'||
                          '  WHERE OBJECT_ID =  ');
        Add_Bind(p_value => p_object_id);
        FND_DSQL.Add_Text('    AND ATTR_GROUP_ID = ');
        Add_Bind(p_value => p_attr_group_id);
        FND_DSQL.Add_Text('    AND ROWNUM = 1');
        FND_DSQL.Add_Text('    AND CLASSIFICATION_CODE IN (');
        l_cc_value_list := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                             p_ext_table_metadata_obj.class_code_metadata
                            ,p_class_code_name_value_pairs
                            ,'VALUES_ALL_CC'
                            ,TRUE
                           );
        FND_DSQL.Add_Text(')');
        l_cursor_id := DBMS_SQL.Open_Cursor;
        DBMS_SQL.Parse(l_cursor_id, FND_DSQL.Get_Text(), DBMS_SQL.Native);
        FND_DSQL.Set_Cursor(l_cursor_id);
        FND_DSQL.Do_Binds();
        DBMS_SQL.Define_Column(l_cursor_id, 1, l_data_level, 30);
        l_dummy := DBMS_SQL.Execute(l_cursor_id);
        l_dummy := DBMS_SQL.Fetch_Rows(l_cursor_id);

        IF (l_dummy = 0) THEN
           RAISE NO_DATA_FOUND;
        END IF;

        --bug 9170700
        DBMS_SQL.Close_Cursor(l_cursor_id);

        l_is_data_level_correct := TRUE;
      ELSE
        l_is_data_level_correct := FALSE;
      END IF;

    ELSE  -- p_data_level IS NULL
      --
      -- R12 code
      --
      l_cc_value_list := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                           p_ext_table_metadata_obj.class_code_metadata
                          ,p_class_code_name_value_pairs
                          ,'VALUES_ALL_CC'
                          ,FALSE
                         );

      Debug_Msg('In Is_Data_Level_Correct, got l_cc_value_list as '||l_cc_value_list);

      l_obj_and_class := '$'||TO_CHAR(p_object_id)||':'||l_cc_value_list||':';

      Debug_Msg('In Is_Data_Level_Correct, got l_obj_and_class as '||l_obj_and_class);

      IF (G_ASSOCIATION_DATA_LEVEL_CACHE.EXISTS(p_attr_group_id) AND
          INSTR(G_ASSOCIATION_DATA_LEVEL_CACHE(p_attr_group_id), l_obj_and_class) > 0) THEN

        Debug_Msg('In Is_Data_Level_Correct, found association '||l_obj_and_class||' in the cache');
         l_data_level_list := G_ASSOCIATION_DATA_LEVEL_CACHE(p_attr_group_id);
         l_start_index := INSTR(l_data_level_list, l_obj_and_class) + LENGTH(l_obj_and_class);
         l_end_index := INSTR(l_data_level_list, '$', l_start_index);
         l_data_level := SUBSTR(l_data_level_list, l_start_index, (l_end_index - l_start_index));
      ELSE

        Init();
        FND_DSQL.Add_Text(' SELECT DECODE(ATTRIBUTE2, 1, ATTRIBUTE3,'||
                                                    ' 2, ATTRIBUTE5,'||
                                                    ' 3, ATTRIBUTE7,'||
                                                       ' ''NONE'')'||
                            ' FROM FND_LOOKUP_VALUES'||
                           ' WHERE LOOKUP_TYPE = ''EGO_EF_DATA_LEVEL'''||
                 ' AND LANGUAGE = USERENV(''LANG'')'||
                             ' AND LOOKUP_CODE = (SELECT DATA_LEVEL'||
                                                  ' FROM EGO_OBJ_AG_ASSOCS_B'||
                                                 ' WHERE OBJECT_ID = ');
        Add_Bind(p_value => p_object_id);
        FND_DSQL.Add_Text(' AND ATTR_GROUP_ID = ');
        Add_Bind(p_value => p_attr_group_id);
        FND_DSQL.Add_Text(' AND ROWNUM = 1');

        IF (LENGTH(l_cc_value_list) > 0) THEN
          FND_DSQL.Add_Text(' AND CLASSIFICATION_CODE IN (');
          l_cc_value_list := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                               p_ext_table_metadata_obj.class_code_metadata
                              ,p_class_code_name_value_pairs
                              ,'VALUES_ALL_CC'
                              ,TRUE
                             );
          FND_DSQL.Add_Text(')');
        END IF;

        FND_DSQL.Add_Text(') ');

        Debug_Msg('Bind params for the preceding SQL: '||p_object_id||' and '||p_attr_group_id, 3);

        l_cursor_id := DBMS_SQL.Open_Cursor;
        DBMS_SQL.Parse(l_cursor_id, FND_DSQL.Get_Text(), DBMS_SQL.Native);
        FND_DSQL.Set_Cursor(l_cursor_id);
        FND_DSQL.Do_Binds();
        DBMS_SQL.Define_Column(l_cursor_id, 1, l_data_level, 30);
        l_dummy := DBMS_SQL.Execute(l_cursor_id);
        l_dummy := DBMS_SQL.Fetch_Rows(l_cursor_id);

        IF (l_dummy = 0) THEN
          RAISE NO_DATA_FOUND;
        END IF;

        DBMS_SQL.Column_Value(l_cursor_id, 1, l_data_level);
        DBMS_SQL.Close_Cursor(l_cursor_id);

        IF (G_ASSOCIATION_DATA_LEVEL_CACHE.EXISTS(p_attr_group_id)) THEN

          G_ASSOCIATION_DATA_LEVEL_CACHE(p_attr_group_id) := l_obj_and_class||
                                                             l_data_level||'$ '||
                                                             G_ASSOCIATION_DATA_LEVEL_CACHE(p_attr_group_id);
          Debug_Msg('In Is_Data_Level_Correct, added association '||l_obj_and_class||' to the cached list');

        ELSE

          G_ASSOCIATION_DATA_LEVEL_CACHE(p_attr_group_id) := l_obj_and_class||
                                                             l_data_level||'$ ';

          Debug_Msg('In Is_Data_Level_Correct, started cached list with association '||l_obj_and_class);

        END IF;
      END IF;

      Debug_Msg('In Is_Data_Level_Correct, the data level for this association is '||l_data_level);

      ------------------------------------------------------------------------
      -- At this point we have the Data Level at which this Attribute Group --
      -- is associated to this Object; now we need to make sure that we     --
      -- have values for all Data Levels up to and including this one and   --
      -- that we don't have values for any Data Levels past this one.       --
      ------------------------------------------------------------------------
      IF (l_data_level = 'NONE') THEN
        l_data_level_progress_point := 'AFTER';
      ELSE
        l_data_level_progress_point := 'BEFORE';
      END IF;

      ------------------------------------------------------------------
      -- If user hasn't passed in a data level array or has passed in --
      -- an array with a NULL first value, then NONE is the only      --
      -- correct value for the data level of this association         --
      ------------------------------------------------------------------
      IF (p_data_level_name_value_pairs IS NULL OR
          p_data_level_name_value_pairs.COUNT = 0 OR
          p_data_level_name_value_pairs(p_data_level_name_value_pairs.FIRST).VALUE IS NULL) THEN

        l_is_data_level_correct := (l_data_level = 'NONE');

      ELSE

        l_data_level_index := p_data_level_name_value_pairs.FIRST;

        WHILE (l_data_level_index <= p_data_level_name_value_pairs.LAST)
        LOOP
          EXIT WHEN (NOT l_is_data_level_correct);

          IF (p_data_level_name_value_pairs(l_data_level_index).NAME = l_data_level) THEN
            l_data_level_progress_point := 'AT';
            Debug_Msg('In Is_Data_Level_Correct, found the data level for this association at index '||
                      l_data_level_index||' in the passed-in DL array');
          END IF;

          IF ((l_data_level_progress_point = 'BEFORE' OR
               l_data_level_progress_point = 'AT') AND
              p_data_level_name_value_pairs(l_data_level_index).VALUE IS NULL) THEN

            --------------------------------------------------------------------
            -- If the user didn't pass a value for the current data level and --
            -- should have, then he/she must have been trying to process the  --
            -- Attr data for the data level above the current one (e.g., Item --
            -- instead of Item Revision, Structure instead of Component, or   --
            -- Project instead of Task), so we report that this is incorrect  --
            -- NOTE: The data level index will never be 1, because we checked --
            -- that case just before we entered the loop                      --
            --------------------------------------------------------------------
            IF (l_data_level_index = 2) THEN
              l_wrong_data_level := p_ext_table_metadata_obj.DATA_LEVEL_MEANING_1;
            ELSIF (l_data_level_index = 3) THEN
              l_wrong_data_level := p_ext_table_metadata_obj.DATA_LEVEL_MEANING_2;
            END IF;

            l_is_data_level_correct := FALSE;

          ELSIF (l_data_level_progress_point = 'AFTER' AND
                 p_data_level_name_value_pairs(l_data_level_index).VALUE IS NOT NULL) THEN

            ----------------------------------------------------------------------
            -- If, on the other hand, the user passed a data level value for    --
            -- some data level beyond the correct one (e.g., Item Revision when --
            -- trying to process Attr data for an Attr Group associated at the  --
            -- Item level), we report this mistake as well                      --
            ----------------------------------------------------------------------
            IF (l_data_level_index = 1) THEN
              l_wrong_data_level := p_ext_table_metadata_obj.DATA_LEVEL_MEANING_2;
            ELSIF (l_data_level_index = 2) THEN
              l_wrong_data_level := p_ext_table_metadata_obj.DATA_LEVEL_MEANING_3;
            END IF;

            l_is_data_level_correct := FALSE;

          END IF;

          ---------------------------------------------------------
          -- Once we've processed the correct data level we will --
          -- need to process all subsequent data levels as well, --
          -- noting that they are AFTER the correct data level   --
          ---------------------------------------------------------
          IF (l_data_level_progress_point = 'AT') THEN
            l_data_level_progress_point := 'AFTER';
          END IF;

          ------------------------------------------------------------
          -- If we're going to do another loop, increment the index --
          ------------------------------------------------------------
          IF (l_is_data_level_correct) THEN
            l_data_level_index := p_data_level_name_value_pairs.NEXT(l_data_level_index);
          END IF;
        END LOOP;
      END IF;
    END IF;

    IF (NOT l_is_data_level_correct) THEN
      x_err_msg_name := 'EGO_EF_DATA_LEVEL_INCORRECT';
      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_disp_name;
      x_token_table(2).TOKEN_NAME := 'DATA_LEVEL';
      x_token_table(2).TOKEN_VALUE := NVL(l_wrong_data_level,p_data_level);
      Debug_Msg('In Is_Data_Level_Correct, returning FALSE because l_data_level is '||
                l_data_level ||
                ', l_data_level_progress_point is '||
                l_data_level_progress_point||
                ' and l_wrong_data_level is '||l_wrong_data_level);
    END IF;

    Debug_Msg('In Is_Data_Level_Correct, done', 2);
    RETURN l_is_data_level_correct;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      Debug_Msg('In Is_Data_Level_Correct, got NO_DATA_FOUND exception so returning FALSE');
      IF (l_cursor_id IS NOT NULL) THEN
        DBMS_SQL.Close_Cursor(l_cursor_id);
      END IF;
      --------------------------------------------------------------------
      -- In this case, the Attribute Group isn't even associated to the --
      -- passed-in Classification Code, so we try to query up the       --
      -- Classification Meaning to make a user-friendly error message   --
      --------------------------------------------------------------------
      x_err_msg_name := 'EGO_EF_AG_NOT_ASSOCIATED';
      x_token_table(1).TOKEN_NAME := 'AG_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_group_disp_name;
      x_token_table(2).TOKEN_NAME := 'CLASS_MEANING';
      BEGIN
        SELECT EGO_EXT_FWK_PUB.Get_Class_Meaning(p_object_id, p_class_code_name_value_pairs(1).VALUE)
          INTO x_token_table(2).TOKEN_VALUE
          FROM DUAL;
      EXCEPTION
        WHEN OTHERS THEN
          x_token_table(2).TOKEN_VALUE := p_class_code_name_value_pairs(1).VALUE;
      END;
      RETURN FALSE;

END Is_Data_Level_Correct;

----------------------------------------------------------------------

FUNCTION Disp_Val_Replacement_Is_Bad (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,px_attr_value_obj               IN OUT NOCOPY EGO_USER_ATTR_DATA_OBJ
)
RETURN BOOLEAN
IS
    l_conv_rate              NUMBER; -- Bug 16502567
  BEGIN

    Debug_Msg('In Disp_Val_Replacement_Is_Bad, starting', 2);

    IF (p_attr_metadata_obj.VALIDATION_CODE IS NULL OR
        NOT (p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE OR
             p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE)) THEN

      IF (px_attr_value_obj.ATTR_DISP_VALUE IS NOT NULL) THEN

        IF ((p_attr_metadata_obj.DATA_TYPE_CODE IS NULL OR
             p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
             p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) AND
            px_attr_value_obj.ATTR_VALUE_STR IS NULL) THEN

          Debug_Msg('In Disp_Val_Replacement_Is_Bad, putting '||
                    px_attr_value_obj.ATTR_DISP_VALUE||
                    ' into ATTR_VALUE_STR column', 3);
          px_attr_value_obj.ATTR_VALUE_STR := px_attr_value_obj.ATTR_DISP_VALUE;

        ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE AND
               px_attr_value_obj.ATTR_VALUE_NUM IS NULL) THEN

          Debug_Msg('In Disp_Val_Replacement_Is_Bad, putting '||
                    px_attr_value_obj.ATTR_DISP_VALUE||
                    ' into ATTR_VALUE_NUM column', 3);
-- Bug 16502567 Start
-- Note: ATTR_DISP_VALUE on ATTR_UNIT_OF_MEASURE while ATTR_VALUE_NUM on UNIT_OF_MEASURE_BASE
          l_conv_rate := 1;
          IF ( px_attr_value_obj.ATTR_UNIT_OF_MEASURE IS NOT NULL AND p_attr_metadata_obj.UNIT_OF_MEASURE_BASE IS NOT NULL
               AND  px_attr_value_obj.ATTR_UNIT_OF_MEASURE <> p_attr_metadata_obj.UNIT_OF_MEASURE_BASE ) THEN

                   BEGIN
                     SELECT CONVERSION_RATE
                     INTO l_conv_rate
                     FROM MTL_UOM_CONVERSIONS
                     WHERE UOM_CLASS = p_attr_metadata_obj.UNIT_OF_MEASURE_CLASS
                     AND UOM_CODE = px_attr_value_obj.ATTR_UNIT_OF_MEASURE
                     AND ROWNUM = 1;
                     Debug_Msg('In Disp_Val_Replacement_Is_Bad UOM conversion rate is ' || to_char(l_conv_rate));
                   EXCEPTION
                     WHEN OTHERS THEN
                     Debug_Msg('In Disp_Val_Replacement_Is_Bad UOM conversion Exception ');
                     l_conv_rate := 1;
                   END;
          END IF;
          px_attr_value_obj.ATTR_VALUE_NUM := l_conv_rate * TO_NUMBER(px_attr_value_obj.ATTR_DISP_VALUE);
-- Bug 16502567 End

        ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE AND
               px_attr_value_obj.ATTR_VALUE_DATE IS NULL) THEN

          Debug_Msg('In Disp_Val_Replacement_Is_Bad, putting '||
                    px_attr_value_obj.ATTR_DISP_VALUE||
                    ' into ATTR_VALUE_DATE column', 3);
          px_attr_value_obj.ATTR_VALUE_DATE := TRUNC(TO_DATE(px_attr_value_obj.ATTR_DISP_VALUE, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));

        ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE AND
               px_attr_value_obj.ATTR_VALUE_DATE IS NULL) THEN

          Debug_Msg('In Disp_Val_Replacement_Is_Bad, putting '||
                    px_attr_value_obj.ATTR_DISP_VALUE||
                    ' into ATTR_VALUE_DATE column', 3);
          px_attr_value_obj.ATTR_VALUE_DATE := TO_DATE(px_attr_value_obj.ATTR_DISP_VALUE, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);

        END IF;
      END IF;
    END IF;

    ----------------------------------------------------
    -- If we've gotten here, either we didn't replace --
    -- or else the replacement was a valid one        --
    ----------------------------------------------------
    Debug_Msg('In Disp_Val_Replacement_Is_Bad, returning FALSE', 2);
    RETURN FALSE;

  EXCEPTION
    WHEN OTHERS THEN
      Debug_Msg('In Disp_Val_Replacement_Is_Bad, returning TRUE', 2);
      ------------------------------------------------------------------------
      -- We assume this means we tried to replace and got a data type clash --
      ------------------------------------------------------------------------
      RETURN TRUE;

END Disp_Val_Replacement_Is_Bad;

----------------------------------------------------------------------

FUNCTION Is_Required_Flag_Respected (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,p_mode                          IN   VARCHAR2
       ,p_attr_value_obj                IN   EGO_USER_ATTR_DATA_OBJ
       ,p_attr_group_disp_name          IN   VARCHAR2
       ,x_err_msg_name                  OUT NOCOPY VARCHAR2
       ,x_token_table                   OUT NOCOPY ERROR_HANDLER.Token_Tbl_Type
)
RETURN BOOLEAN
IS

    l_value                  VARCHAR2(4000);	-- Bug 8757354
    l_is_req_flag_resp       BOOLEAN := TRUE;

  BEGIN

    Debug_Msg('In Is_Required_Flag_Respected, starting', 2);

    IF (p_attr_metadata_obj.DATA_TYPE_CODE IS NULL OR
        p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
        p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN
      l_value := p_attr_value_obj.ATTR_VALUE_STR;
    ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
      l_value := p_attr_value_obj.ATTR_VALUE_NUM;
    ELSE
      l_value := p_attr_value_obj.ATTR_VALUE_DATE;
    END IF;

    ------------------------------------------------------------------
    -- If they didn't pass a value of the correct data type AND the --
    -- Attribute has a Value Set of type Independent or Table, then --
    -- we give them one last chance by assuming that they passed a  --
    -- Display Value (which we will later convert to an Internal    --
    -- Value in Is_Value_Set_Respected)                             --
    ------------------------------------------------------------------
    IF (l_value IS NULL AND
        (p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE OR
         p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE OR
         p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE)) THEN
      l_value := p_attr_value_obj.ATTR_DISP_VALUE;
    END IF;

    --------------------------------------------------------------
    -- If the Attribute is required, we're in CREATE mode, no   --
    -- value was passed, and no Default Value is defined (or we --
    -- aren't using the Default Value), then we raise an error  --
    --------------------------------------------------------------
    IF (p_attr_metadata_obj.REQUIRED_FLAG = 'Y' AND
        (UPPER(p_mode) = G_CREATE_MODE OR UPPER(p_mode) = G_UPDATE_MODE) AND --gnanda:BugFix:4640128
        l_value IS NULL AND
        (p_attr_metadata_obj.DEFAULT_VALUE IS NULL OR
        NOT G_DEFAULT_ON_INSERT_FLAG)) THEN
      Debug_Msg('In Is_Required_Flag_Respected, required Attr '||p_attr_value_obj.ATTR_NAME||' has no value in '||p_mode||' mode');

      l_is_req_flag_resp := FALSE;

      x_err_msg_name := 'EGO_EF_NO_VAL_FOR_REQ_ATTR';

      x_token_table(1).TOKEN_NAME := 'ATTR_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_metadata_obj.ATTR_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'AG_NAME';
      x_token_table(2).TOKEN_VALUE := p_attr_group_disp_name;

    END IF;

    Debug_Msg('In Is_Required_Flag_Respected, done', 2);

  RETURN l_is_req_flag_resp;

END Is_Required_Flag_Respected;

----------------------------------------------------------------------

FUNCTION Is_Data_Type_Correct (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,p_attr_value_obj                IN   EGO_USER_ATTR_DATA_OBJ
       ,p_attr_group_disp_name          IN   VARCHAR2
       ,x_err_msg_name                  OUT NOCOPY VARCHAR2
       ,x_token_table                   OUT NOCOPY ERROR_HANDLER.Token_Tbl_Type
)
RETURN BOOLEAN
IS

    l_value                  VARCHAR2(4000); -- Bug 8757354
    l_is_data_type_correct   BOOLEAN := TRUE;

  BEGIN

    Debug_Msg('In Is_Data_Type_Correct, starting', 2);

    IF
       (
         (
           p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
           p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE
         ) AND
         (
           p_attr_value_obj.ATTR_VALUE_STR IS NULL AND
           (
             p_attr_value_obj.ATTR_VALUE_NUM IS NOT NULL OR
             p_attr_value_obj.ATTR_VALUE_DATE IS NOT NULL
           )
         )
       ) THEN

      l_value := NVL(TO_CHAR(p_attr_value_obj.ATTR_VALUE_NUM),
                     TO_CHAR(p_attr_value_obj.ATTR_VALUE_DATE, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));

    ELSIF (
            (
              p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE
            ) AND
            (
              p_attr_value_obj.ATTR_VALUE_NUM IS NULL AND
              (
                p_attr_value_obj.ATTR_VALUE_STR IS NOT NULL OR
                p_attr_value_obj.ATTR_VALUE_DATE IS NOT NULL
              )
            )
          ) THEN

      l_value := NVL(p_attr_value_obj.ATTR_VALUE_STR,
                     TO_CHAR(p_attr_value_obj.ATTR_VALUE_DATE, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));

    ELSIF (
            (
              p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
              p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE
            ) AND
            (
              p_attr_value_obj.ATTR_VALUE_DATE IS NULL AND
              (
                p_attr_value_obj.ATTR_VALUE_STR IS NOT NULL OR
                p_attr_value_obj.ATTR_VALUE_NUM IS NOT NULL
              )
            )
          ) THEN

      l_value := NVL(p_attr_value_obj.ATTR_VALUE_STR,
                     TO_CHAR(p_attr_value_obj.ATTR_VALUE_NUM));

    END IF;

    IF (l_value IS NOT NULL) THEN

      Debug_Msg('In Is_Data_Type_Correct, Attr '||p_attr_value_obj.ATTR_NAME||
                ' has no value of the correct data type, '||p_attr_metadata_obj.DATA_TYPE_MEANING);

      l_is_data_type_correct := FALSE;

      x_err_msg_name := 'EGO_EF_DATA_TYPE_INCORRECT';

      x_token_table(1).TOKEN_NAME := 'ATTR_NAME';
      x_token_table(1).TOKEN_VALUE := p_attr_metadata_obj.ATTR_DISP_NAME;
      x_token_table(2).TOKEN_NAME := 'AG_NAME';
      x_token_table(2).TOKEN_VALUE := p_attr_group_disp_name;
      x_token_table(3).TOKEN_NAME := 'DATA_TYPE';
      x_token_table(3).TOKEN_VALUE := p_attr_metadata_obj.DATA_TYPE_MEANING;
      x_token_table(4).TOKEN_NAME := 'VALUE';
      x_token_table(4).TOKEN_VALUE := p_attr_value_obj.ATTR_DISP_VALUE;

    END IF;

    Debug_Msg('In Is_Data_Type_Correct, done', 2);

  RETURN l_is_data_type_correct;

END Is_Data_Type_Correct;

----------------------------------------------------------------------

FUNCTION Is_Min_Or_Max_Value_Respected (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,p_attr_value_obj                IN   EGO_USER_ATTR_DATA_OBJ
       ,p_min_or_max                    IN   VARCHAR2
)
RETURN BOOLEAN
IS

    l_is_range_respected     BOOLEAN := TRUE;
    l_value_bound_string     VARCHAR2(150);

  BEGIN

    Debug_Msg('In Is_Min_Or_Max_Value_Respected, starting', 2);

    IF (p_min_or_max = 'MIN') THEN
      l_value_bound_string := p_attr_metadata_obj.MINIMUM_VALUE;
    ELSIF (p_min_or_max = 'MAX') THEN
      l_value_bound_string := p_attr_metadata_obj.MAXIMUM_VALUE;
    END IF;

    IF (l_value_bound_string IS NOT NULL) THEN

      Debug_Msg('In Is_Min_Or_Max_Value_Respected, '||p_attr_value_obj.ATTR_NAME||
                ' has a '||p_min_or_max||' value of '||l_value_bound_string);

      -----------------
      -- Number case --
      -----------------
      IF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

        IF ((p_min_or_max = 'MIN' AND
             p_attr_value_obj.ATTR_VALUE_NUM < TO_NUMBER(l_value_bound_string)) OR
            (p_min_or_max = 'MAX' AND
             p_attr_value_obj.ATTR_VALUE_NUM > TO_NUMBER(l_value_bound_string))) THEN
          l_is_range_respected := FALSE;
        END IF;

      ---------------
      -- Date case --
      ---------------
      ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
             p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

        -----------------------------------------------------------------
        -- We store Min/Max Values in Timestamp format, which includes --
        -- a decimal millisecond component; but since the TO_DATE      --
        -- function doesn't allow for milliseconds, we have to trim    --
        -- that part of the string in order to compare the value.      --
        -- We also allow Min/Max Values to be expressions of the form  --
        -- "$SYSDATE$ [+/- {integer}]"; if this value bound string is  --
        -- in such a form, we turn it into a string in                 --
        -- EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT.                    --
        -----------------------------------------------------------------
        IF (INSTR(l_value_bound_string, '.', -1) > 0) THEN
          l_value_bound_string := SUBSTR(l_value_bound_string, 1, INSTR(l_value_bound_string, '.') - 1);
        ELSIF (INSTR(UPPER(l_value_bound_string), 'SYSDATE') > 0) THEN

          l_value_bound_string := Format_Sysdate_Expression(l_value_bound_string);

        END IF;

        IF (
             (
               (
                 p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE AND
                 (
                   p_min_or_max = 'MIN' AND
                   p_attr_value_obj.ATTR_VALUE_DATE < TRUNC(TO_DATE(l_value_bound_string, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT))
                 )
               )
               OR
               (
                 p_min_or_max = 'MAX' AND
                 TRUNC(p_attr_value_obj.ATTR_VALUE_DATE) > TO_DATE(l_value_bound_string, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT)
               )
             )
             OR
             (
               (
                 p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE AND
                 (
                   p_min_or_max = 'MIN' AND
                   p_attr_value_obj.ATTR_VALUE_DATE < TO_DATE(l_value_bound_string, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT)
                 )
               )
               OR
               (
                 p_min_or_max = 'MAX' AND
                 p_attr_value_obj.ATTR_VALUE_DATE > TO_DATE(l_value_bound_string, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT)
               )
             )
           ) THEN

          l_is_range_respected := FALSE;

        END IF;
      END IF;
    END IF;

    IF (l_is_range_respected) THEN
      Debug_Msg('In Is_Min_Or_Max_Value_Respected, returning TRUE');
    ELSE
      Debug_Msg('In Is_Min_Or_Max_Value_Respected, returning FALSE');
    END IF;
    Debug_Msg('In Is_Min_Or_Max_Value_Respected, done', 2);

    RETURN l_is_range_respected;

EXCEPTION
  WHEN OTHERS THEN
    Debug_Msg('In Is_Min_Or_Max_Value_Respected, EXCEPTION OTHERS '||SQLERRM);
    RETURN FALSE;

END Is_Min_Or_Max_Value_Respected;

----------------------------------------------------------------------

FUNCTION Is_Max_Size_Respected (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,p_attr_value_obj                IN   EGO_USER_ATTR_DATA_OBJ
       ,p_attr_group_disp_name          IN   VARCHAR2
       ,x_err_msg_name                  OUT NOCOPY VARCHAR2
       ,x_token_table                   OUT NOCOPY ERROR_HANDLER.Token_Tbl_Type
)
RETURN BOOLEAN
IS

    l_is_max_size_respected  BOOLEAN := TRUE;
    l_value                  VARCHAR2(4000);	-- Bug 8757354

  BEGIN

    Debug_Msg('In Is_Max_Size_Respected, starting', 2);

    ---------------------------------------------------------------
    -- NOTE: We don't enforce maximum size with Date Attributes, --
    -- because the size depends on the format of the Date, which --
    -- we can't know at this point.                              --
    -- Also, we use LENGTH rather than LENGTH for these checks  --
    -- because we want to know the number of characters rather   --
    -- than the number of bytes (for multi-byte support).        --
    ---------------------------------------------------------------

    IF (p_attr_metadata_obj.DATA_TYPE_CODE IS NULL OR
        p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
        p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

      IF (p_attr_metadata_obj.MAXIMUM_SIZE > 0 AND
          p_attr_metadata_obj.MAXIMUM_SIZE <
          LENGTHB(p_attr_value_obj.ATTR_VALUE_STR)) THEN  --for bug 9748517, use byte size to determin size for multi-byte language
        l_is_max_size_respected := FALSE;
        l_value := p_attr_value_obj.ATTR_VALUE_STR;
      END IF;

    ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

      IF (p_attr_metadata_obj.MAXIMUM_SIZE > 0 AND
          p_attr_metadata_obj.MAXIMUM_SIZE <
          LENGTH(TO_CHAR(p_attr_value_obj.ATTR_VALUE_NUM))) THEN
        l_is_max_size_respected := FALSE;
        l_value := TO_CHAR(p_attr_value_obj.ATTR_VALUE_NUM);
      END IF;

    END IF;

    IF (NOT l_is_max_size_respected) THEN

      x_err_msg_name := 'EGO_EF_MAX_SIZE_VIOLATED';

      x_token_table(1).TOKEN_NAME := 'VALUE';
      x_token_table(1).TOKEN_VALUE := l_value;
      x_token_table(2).TOKEN_NAME := 'ATTR_NAME';
      x_token_table(2).TOKEN_VALUE := p_attr_metadata_obj.ATTR_DISP_NAME;
      x_token_table(3).TOKEN_NAME := 'AG_NAME';
      x_token_table(3).TOKEN_VALUE := p_attr_group_disp_name;

    END IF;

    Debug_Msg('In Is_Max_Size_Respected, done', 2);

    RETURN l_is_max_size_respected;

END Is_Max_Size_Respected;

----------------------------------------------------------------------

FUNCTION Is_UOM_Valid (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,px_attr_value_obj               IN OUT NOCOPY EGO_USER_ATTR_DATA_OBJ
)
RETURN BOOLEAN
IS

    l_is_uom_valid           BOOLEAN := TRUE;
    l_dummy                  VARCHAR2(1);

  BEGIN

    Debug_Msg('In Is_UOM_Valid, starting', 2);

    ------------------------------------------------------------------------------
    -- If there is a UOM, we see whether it's a member of the correct UOM class --
    -- (we query against MTL_UNITS_OF_MEASURE_TL because there is no _B table)  --
    ------------------------------------------------------------------------------
    IF (px_attr_value_obj.ATTR_UNIT_OF_MEASURE IS NOT NULL) THEN

      BEGIN
        SELECT 'X'
          INTO l_dummy
          FROM MTL_UNITS_OF_MEASURE_TL
         WHERE UOM_CLASS = p_attr_metadata_obj.UNIT_OF_MEASURE_CLASS
           AND UOM_CODE = px_attr_value_obj.ATTR_UNIT_OF_MEASURE
           AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_is_uom_valid := FALSE;
      END;

    -- BUG 8632453
    ELSE IF (px_attr_value_obj.ATTR_UNIT_OF_MEASURE IS NULL AND
             p_attr_metadata_obj.UNIT_OF_MEASURE_CLASS IS NOT NULL) THEN
          l_is_uom_valid := FALSE;

    END IF;
    --END OF BUG 8632453


    END IF;

    IF (l_is_uom_valid) THEN
      Debug_Msg('In Is_UOM_Valid, returning TRUE');
    ELSE
      Debug_Msg('In Is_UOM_Valid, returning FALSE');
    END IF;

    Debug_Msg('In Is_UOM_Valid, done', 2);

  RETURN l_is_uom_valid;

END Is_UOM_Valid;

----------------------------------------------------------------------

FUNCTION Is_Value_Set_Respected (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,px_attr_value_obj               IN OUT NOCOPY EGO_USER_ATTR_DATA_OBJ
)
RETURN BOOLEAN
IS

    l_int_value              VARCHAR2(4000);	-- Bug 8757354
    l_disp_value             VARCHAR2(4000);	-- Bug 8757354
    l_is_val_set_respected   BOOLEAN := TRUE;
    l_err_msg_name           VARCHAR2(30);
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;

  BEGIN

    Debug_Msg('In Is_Value_Set_Respected, starting', 2);

    IF (p_attr_metadata_obj.VALUE_SET_ID IS NOT NULL) THEN

      Debug_Msg('In Is_Value_Set_Respected, '||px_attr_value_obj.ATTR_NAME||
                ' has Value Set of validation type '||p_attr_metadata_obj.VALIDATION_CODE);

      IF (p_attr_metadata_obj.VALIDATION_CODE = 'N') THEN

        l_is_val_set_respected := Is_Min_Or_Max_Value_Respected(p_attr_metadata_obj
                                                               ,px_attr_value_obj
                                                               ,'MIN');

        IF (NOT l_is_val_set_respected) THEN

          IF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

            l_err_msg_name := 'EGO_EF_MIN_VAL_NUM_VIOLATED';

            l_token_table(1).TOKEN_NAME := 'ATTR_NAME';
            l_token_table(1).TOKEN_VALUE := p_attr_metadata_obj.ATTR_DISP_NAME;
            l_token_table(2).TOKEN_NAME := 'AG_NAME';
            l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
            l_token_table(3).TOKEN_NAME := 'MIN_NUM_VALUE';
            l_token_table(3).TOKEN_VALUE := p_attr_metadata_obj.MINIMUM_VALUE;

          ELSE

            l_err_msg_name := 'EGO_EF_MIN_VAL_DATE_VIOLATED';

            l_token_table(1).TOKEN_NAME := 'ATTR_NAME';
            l_token_table(1).TOKEN_VALUE := p_attr_metadata_obj.ATTR_DISP_NAME;
            l_token_table(2).TOKEN_NAME := 'AG_NAME';
            l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
            l_token_table(3).TOKEN_NAME := 'MIN_DATE_VALUE';
            l_token_table(3).TOKEN_VALUE := p_attr_metadata_obj.MINIMUM_VALUE;

          END IF;

        ELSE

          l_is_val_set_respected := Is_Min_Or_Max_Value_Respected(p_attr_metadata_obj
                                                                 ,px_attr_value_obj
                                                                 ,'MAX');

          IF (NOT l_is_val_set_respected) THEN

            IF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

              l_err_msg_name := 'EGO_EF_MAX_VAL_NUM_VIOLATED';

              l_token_table(1).TOKEN_NAME := 'ATTR_NAME';
              l_token_table(1).TOKEN_VALUE := p_attr_metadata_obj.ATTR_DISP_NAME;
              l_token_table(2).TOKEN_NAME := 'AG_NAME';
              l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
              l_token_table(3).TOKEN_NAME := 'MAX_NUM_VALUE';
              l_token_table(3).TOKEN_VALUE := p_attr_metadata_obj.MAXIMUM_VALUE;

            ELSE

              l_err_msg_name := 'EGO_EF_MAX_VAL_DATE_VIOLATED';

              l_token_table(1).TOKEN_NAME := 'ATTR_NAME';
              l_token_table(1).TOKEN_VALUE := p_attr_metadata_obj.ATTR_DISP_NAME;
              l_token_table(2).TOKEN_NAME := 'AG_NAME';
              l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
              l_token_table(3).TOKEN_NAME := 'MAX_DATE_VALUE';
              l_token_table(3).TOKEN_VALUE := p_attr_metadata_obj.MAXIMUM_VALUE;

            END IF;
          END IF;
        END IF;

      ----------------------------------------------------------------------------
      -- If the Attribute has a Value Set whose Values have different Internal  --
      -- and Display Values, we need to validate the passed-in value (which has --
      -- to be either an Internal Value or a Display Value for the Value Set)   --
      ----------------------------------------------------------------------------
      ELSIF (p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE OR
             p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE OR
             p_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE) THEN

        -------------------------------------------
        -- If the user passed the Display Value, --
        -- we will try to get the Internal Value --
        -------------------------------------------
        IF (px_attr_value_obj.ATTR_DISP_VALUE IS NOT NULL AND
            px_attr_value_obj.ATTR_VALUE_STR IS NULL AND
            px_attr_value_obj.ATTR_VALUE_NUM IS NULL AND
            px_attr_value_obj.ATTR_VALUE_DATE IS NULL) THEN

          l_int_value := Get_Int_Val_For_Disp_Val(
                           p_attr_metadata_obj             => p_attr_metadata_obj
                          ,p_attr_value_obj                => px_attr_value_obj
                          ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
                          ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
                          ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
                          ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
                          ,p_entity_id                     => p_entity_id
                          ,p_entity_index                  => p_entity_index
                          ,p_entity_code                   => p_entity_code
                          ,p_attr_name_value_pairs         => p_attr_name_value_pairs
                         );

          IF (l_int_value IS NOT NULL) THEN
            IF (p_attr_metadata_obj.DATA_TYPE_CODE IS NULL OR
                p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
                p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

              px_attr_value_obj.ATTR_VALUE_STR := l_int_value;

            ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

              px_attr_value_obj.ATTR_VALUE_NUM := TO_NUMBER(l_int_value);

            ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) THEN

              px_attr_value_obj.ATTR_VALUE_DATE := TRUNC(TO_DATE(l_int_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));

            ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

              px_attr_value_obj.ATTR_VALUE_DATE := TO_DATE(l_int_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);

            END IF;
          ELSE

            l_is_val_set_respected := FALSE;

            l_err_msg_name := 'EGO_EF_INDEPENDENT_VS_VIOLATED';

            l_token_table(1).TOKEN_NAME := 'VALUE';
            l_token_table(1).TOKEN_VALUE := px_attr_value_obj.ATTR_DISP_VALUE;
            l_token_table(2).TOKEN_NAME := 'ATTR_NAME';
            l_token_table(2).TOKEN_VALUE := p_attr_metadata_obj.ATTR_DISP_NAME;
            l_token_table(3).TOKEN_NAME := 'AG_NAME';
            l_token_table(3).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;

            Debug_Msg('In Is_Value_Set_Respected, disp value passed was bad; VS is violated');
          END IF;

        ---------------------------------------------------------------
        -- If, on the other hand, the user passed the Interal Value, --
        -- we verify it by trying to get the Display Value           --
        ---------------------------------------------------------------
        ELSIF (px_attr_value_obj.ATTR_VALUE_STR IS NOT NULL OR
               px_attr_value_obj.ATTR_VALUE_NUM IS NOT NULL OR
               px_attr_value_obj.ATTR_VALUE_DATE IS NOT NULL) THEN

          l_disp_value := Get_Disp_Val_For_Int_Val(
                            p_attr_value_obj                => px_attr_value_obj
                           ,p_attr_metadata_obj             => p_attr_metadata_obj
                           ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
                           ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
                           ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
                           ,p_entity_id                     => p_entity_id
                           ,p_entity_index                  => p_entity_index
                           ,p_entity_code                   => p_entity_code
                           ,p_attr_name_value_pairs         => p_attr_name_value_pairs
                           ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
                          );

          IF (l_disp_value IS NULL) THEN

            l_is_val_set_respected := FALSE;

            l_err_msg_name := 'EGO_EF_INDEPENDENT_VS_VIOLATED';

            IF (px_attr_value_obj.ATTR_VALUE_STR IS NOT NULL) THEN
              l_int_value := px_attr_value_obj.ATTR_VALUE_STR;
            ELSIF (px_attr_value_obj.ATTR_VALUE_NUM IS NOT NULL) THEN
              l_int_value := px_attr_value_obj.ATTR_VALUE_NUM;
            ELSE
              l_int_value := px_attr_value_obj.ATTR_VALUE_DATE;
            END IF;

            l_token_table(1).TOKEN_NAME := 'VALUE';
            l_token_table(1).TOKEN_VALUE := l_int_value;
            l_token_table(2).TOKEN_NAME := 'ATTR_NAME';
            l_token_table(2).TOKEN_VALUE :=p_attr_metadata_obj.ATTR_DISP_NAME;
            l_token_table(3).TOKEN_NAME := 'AG_NAME';
            l_token_table(3).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;

            Debug_Msg('In Is_Value_Set_Respected, int value passed was bad; VS is violated');
          END IF;
        END IF;
      END IF;
    END IF;

    ----------------------------------------------------------
    -- If we found an error and didn't log it in one of the --
    -- functions we called, then we need to log it now      --
    ----------------------------------------------------------
    IF (NOT l_is_val_set_respected AND l_err_msg_name IS NOT NULL) THEN

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => l_err_msg_name
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );

    END IF;

    IF (l_is_val_set_respected) THEN
      Debug_Msg('In Is_Value_Set_Respected, returning TRUE');
    ELSE
      Debug_Msg('In Is_Value_Set_Respected, returning FALSE');
    END IF;

    Debug_Msg('In Is_Value_Set_Respected, done', 2);

    RETURN l_is_val_set_respected;

  EXCEPTION
    WHEN OTHERS THEN
      Debug_Msg('In Is_Min_Or_Max_Value_Respected, EXCEPTION OTHERS '||SQLERRM);
      RETURN FALSE;

END Is_Value_Set_Respected;

----------------------------------------------------------------------

FUNCTION Verify_All_Required_Attrs (
        p_passed_attr_names_table       IN   LOCAL_VARCHAR_TABLE
       ,p_attr_metadata_table           IN   EGO_ATTR_METADATA_TABLE
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_attr_group_disp_name          IN   VARCHAR2
       ,px_attr_name_value_pairs        IN OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
)
RETURN BOOLEAN
IS

    l_has_all_required_attrs BOOLEAN := TRUE;
    l_metadata_table_index   NUMBER;
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;
    l_passed_attrs_table_index NUMBER;
    l_already_processed      BOOLEAN;
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;

  BEGIN

    l_token_table(1).TOKEN_NAME := 'ATTR_NAME';
    -- the token value will be supplied in the loop itself
    l_token_table(2).TOKEN_NAME := 'AG_NAME';
    l_token_table(2).TOKEN_VALUE := p_attr_group_disp_name;

    Debug_Msg('In Verify_All_Required_Attrs, starting', 2);

    -----------------------------------------------------
    -- We loop through all Attributes in the Attribute --
    -- Group, looking for required Attributes          --
    -----------------------------------------------------
    l_metadata_table_index := p_attr_metadata_table.FIRST;
    WHILE (l_metadata_table_index <= p_attr_metadata_table.LAST)
    LOOP

      l_already_processed := FALSE;
      l_attr_metadata_obj := p_attr_metadata_table(l_metadata_table_index);
      IF (l_attr_metadata_obj.REQUIRED_FLAG = 'Y') THEN

        --------------------------------------------
        -- For every required Attribute, we check --
        -- whether or not we already processed it --
        --------------------------------------------
        l_passed_attrs_table_index := p_passed_attr_names_table.FIRST;
        WHILE (l_passed_attrs_table_index <= p_passed_attr_names_table.LAST)
        LOOP
          EXIT WHEN (l_already_processed);

          IF (p_passed_attr_names_table(l_passed_attrs_table_index) = l_attr_metadata_obj.ATTR_NAME) THEN

            l_already_processed := TRUE;

          END IF;

          l_passed_attrs_table_index := p_passed_attr_names_table.NEXT(l_passed_attrs_table_index);
        END LOOP;

        -------------------------------------------------------------------------
        -- If the required Attribute wasn't passed but has a default value, we --
        -- create a data object for it and put it into our name/value pairs    --
        -- table (trusting Get_List_For_Attrs to default it as necessary); if  --
        -- there is no default value, we add the Attribute's name to the list  --
        -- of missing Attributes                                               --
        -------------------------------------------------------------------------
        IF (NOT l_already_processed) THEN

          IF (l_attr_metadata_obj.DEFAULT_VALUE IS NOT NULL) THEN

            Debug_Msg('In Verify_All_Required_Attrs, non-passed required Attribute '||l_attr_metadata_obj.ATTR_DISP_NAME||' has a default value');

            DECLARE

              l_attr_data_obj           EGO_USER_ATTR_DATA_OBJ;

            BEGIN

              l_attr_data_obj := EGO_USER_ATTR_DATA_OBJ(
                                   px_attr_name_value_pairs(px_attr_name_value_pairs.FIRST).ROW_IDENTIFIER
                                  ,l_attr_metadata_obj.ATTR_NAME
                                  ,null -- ATTR_VALUE_STR
                                  ,null -- ATTR_VALUE_NUM
                                  ,null -- ATTR_VALUE_DATE
                                  ,null -- ATTR_DISP_VALUE
                                  ,l_attr_metadata_obj.UNIT_OF_MEASURE_BASE
                                  ,-1   -- USER_ROW_IDENTIFIER
                                 );

              px_attr_name_value_pairs.EXTEND();
--
-- ASSUMPTION: this table does not need to be re-sorted by sequence, because we've
-- passed the only place where sequence matters (i.e., Tokenized_Val_Set_Query)
--
              px_attr_name_value_pairs(px_attr_name_value_pairs.LAST) := l_attr_data_obj;
            END;
          ELSE

            Debug_Msg('In Verify_All_Required_Attrs, non-passed required Attribute '||l_attr_metadata_obj.ATTR_DISP_NAME||' has no default value');

            l_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.ATTR_DISP_NAME;

            ERROR_HANDLER.Add_Error_Message(
              p_message_name      => 'EGO_EF_NO_VAL_FOR_REQ_ATTR'
             ,p_application_id    => 'EGO'
             ,p_token_tbl         => l_token_table
             ,p_message_type      => FND_API.G_RET_STS_ERROR
             ,p_row_identifier    => G_USER_ROW_IDENTIFIER
             ,p_entity_id         => p_entity_id
             ,p_entity_index      => p_entity_index
             ,p_entity_code       => p_entity_code
             ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
            );

            l_has_all_required_attrs := FALSE;

          END IF;
        END IF;
      END IF;

      l_metadata_table_index := p_attr_metadata_table.NEXT(l_metadata_table_index);
    END LOOP;

    Debug_Msg('In Verify_All_Required_Attrs, done', 2);

    RETURN l_has_all_required_attrs;

END Verify_All_Required_Attrs;

----------------------------------------------------------------------

FUNCTION Get_Requested_Attr_Names (
        p_row_identifier                IN   NUMBER
       ,p_attr_group_disp_name          IN   VARCHAR2
       ,p_attr_name_list                IN   VARCHAR2
       ,p_attr_metadata_table           IN   EGO_ATTR_METADATA_TABLE
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
)
RETURN LOCAL_VARCHAR_TABLE
IS

    l_attr_name_list         VARCHAR2(3000) := p_attr_name_list;
    l_attr_name_table        LOCAL_VARCHAR_TABLE;
    l_next_attr_name         VARCHAR2(30);
    l_candidate_attr         EGO_ATTR_METADATA_OBJ;
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_metadata_table_index   NUMBER;
    l_found_bad_names        BOOLEAN := FALSE;

  BEGIN

    Debug_Msg('In Get_Requested_Attr_Names, starting', 2);

    IF (LENGTH(l_attr_name_list) > 0) THEN
      WHILE (LENGTH(l_attr_name_list) > 0)
      LOOP

        IF (INSTR(l_attr_name_list, ',') > 0) THEN

          l_next_attr_name := SUBSTR(l_attr_name_list, 1, INSTR(l_attr_name_list, ',') - 1);
          l_attr_name_list := SUBSTR(l_attr_name_list, INSTR(l_attr_name_list, ',') + 1);

        ELSE

          l_next_attr_name := l_attr_name_list;
          l_attr_name_list := '';

        END IF;

        l_next_attr_name := TRIM(l_next_attr_name);

        Debug_Msg('In Get_Requested_Attr_Names, trying to add '||l_next_attr_name||' to table', 3);

        l_candidate_attr := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                              p_attr_metadata_table => p_attr_metadata_table
                             ,p_attr_name           => l_next_attr_name
                            );

        IF (l_candidate_attr IS NOT NULL AND
            l_candidate_attr.ATTR_NAME IS NOT NULL) THEN

          l_attr_name_table(l_attr_name_table.COUNT+1) := l_next_attr_name;

        ELSE

          l_found_bad_names := TRUE;

          l_token_table(1).TOKEN_NAME := 'BAD_ATTR_NAME';
          l_token_table(1).TOKEN_VALUE := l_next_attr_name;
          l_token_table(2).TOKEN_NAME := 'AG_NAME';
          l_token_table(2).TOKEN_VALUE := p_attr_group_disp_name;

          ERROR_HANDLER.Add_Error_Message(
            p_message_name      => 'EGO_EF_ATTR_DOES_NOT_EXIST'
           ,p_application_id    => 'EGO'
           ,p_token_tbl         => l_token_table
           ,p_message_type      => FND_API.G_RET_STS_ERROR
           ,p_row_identifier    => p_row_identifier
           ,p_entity_id         => p_entity_id
           ,p_entity_index      => p_entity_index
           ,p_entity_code       => p_entity_code
           ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
          );

        END IF;

      END LOOP;
    ELSE -- if the list is empty, we return all Attributes in the Attribute Group
     --bug 5494760 the p_attr_metadata_table can be null, if no attribute
     -- is created under the attribute group.
     IF p_attr_metadata_table IS NOT NULL THEN
      l_metadata_table_index := p_attr_metadata_table.FIRST;
      WHILE (l_metadata_table_index <= p_attr_metadata_table.LAST)
      LOOP
        l_attr_name_table(l_attr_name_table.COUNT+1) := p_attr_metadata_table(l_metadata_table_index).ATTR_NAME;
        l_metadata_table_index := p_attr_metadata_table.NEXT(l_metadata_table_index);
      END LOOP;
     END IF;--p_attr_metadata_table IS NOT NULL
    END IF;

    -- If we fail, we need to pass something back to indicate that failure
    IF (l_found_bad_names) THEN
      l_attr_name_table(-1) := 'FAILED';
    END IF;

    Debug_Msg('In Get_Requested_Attr_Names, done', 2);

    RETURN l_attr_name_table;

END Get_Requested_Attr_Names;

----------------------------------------------------------------------

PROCEDURE Generate_Attr_Int_Values (
        p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_entity_id                     IN   VARCHAR2   DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,px_attr_name_value_pairs        IN OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
) IS

    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_attr_value_index       NUMBER;
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;
    l_int_value              VARCHAR2(4000);	-- Bug 8757354
    l_err_msg_name           VARCHAR2(30);

  BEGIN

    Debug_Msg('In Generate_Attr_Int_Values, starting', 2);

    IF (px_attr_name_value_pairs IS NOT NULL AND
        px_attr_name_value_pairs.COUNT > 0) THEN
      l_attr_value_index := px_attr_name_value_pairs.FIRST;
      WHILE (l_attr_value_index <= px_attr_name_value_pairs.LAST)
      LOOP

        l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                 p_attr_metadata_table => p_attr_group_metadata_obj.attr_metadata_table
                                ,p_attr_name           => px_attr_name_value_pairs(l_attr_value_index).ATTR_NAME
                               );

        ----------------------------------------------------------------------------
        -- If the Attribute has a Value Set of a type that has different internal --
        -- and display values, we only want to try getting the internal value if  --
        -- the caller has passed in the display value and nothing else; otherwise --
        -- we want to use the passed-in internal value and thus avoid a query.    --
        ----------------------------------------------------------------------------
        IF ((l_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE OR
             l_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE OR
             l_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE) AND
            (px_attr_name_value_pairs(l_attr_value_index).ATTR_DISP_VALUE IS NOT NULL) AND
            (px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_STR IS NULL AND
             px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_NUM IS NULL AND
             px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_DATE IS NULL)) THEN

          l_int_value := Get_Int_Val_For_Disp_Val(
                           p_attr_metadata_obj             => l_attr_metadata_obj
                          ,p_attr_value_obj                => px_attr_name_value_pairs(l_attr_value_index)
                          ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
                          ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
                          ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
                          ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
                          ,p_entity_id                     => p_entity_id
                          ,p_entity_index                  => p_entity_index
                          ,p_entity_code                   => p_entity_code
                          ,p_attr_name_value_pairs         => px_attr_name_value_pairs
                         );

          IF (l_int_value IS NOT NULL) THEN
            IF (l_attr_metadata_obj.DATA_TYPE_CODE IS NULL OR
                l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
                l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN
              px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_STR := l_int_value;
            ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
              px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_NUM := TO_NUMBER(l_int_value);
            ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) THEN
              px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_DATE := TRUNC(TO_DATE(l_int_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));
            ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
              px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_DATE := TO_DATE(l_int_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
            END IF;
          ELSE

            l_err_msg_name := 'EGO_EF_INDEPENDENT_VS_VIOLATED';

            l_token_table(1).TOKEN_NAME := 'VALUE';
            l_token_table(1).TOKEN_VALUE := px_attr_name_value_pairs(l_attr_value_index).ATTR_DISP_VALUE;
            l_token_table(2).TOKEN_NAME := 'ATTR_NAME';
            l_token_table(2).TOKEN_VALUE := l_attr_metadata_obj.ATTR_DISP_NAME;
            l_token_table(3).TOKEN_NAME := 'AG_NAME';
            l_token_table(3).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;

            x_return_status := FND_API.G_RET_STS_ERROR;

          END IF;

        -----------------------------------------------------------------------------------
        -- We also check for the (common) case where the Attribute doesn't have distinct --
        -- internal and display values but the user passed the value as ATTR_DISP_VALUE  --
        -- anyway, just for convenience; in this case, we try to interpret the passed-in --
        -- value as being of the appropriate data type.  If we cannot do so, we report   --
        -- the problem,                                                                  --
        -----------------------------------------------------------------------------------
        ELSIF (Disp_Val_Replacement_Is_Bad(l_attr_metadata_obj
                                          ,px_attr_name_value_pairs(l_attr_value_index))) THEN

          l_err_msg_name := 'EGO_EF_DATA_TYPE_INCORRECT';

          l_token_table(1).TOKEN_NAME := 'ATTR_NAME';
          l_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.ATTR_DISP_NAME;
          l_token_table(2).TOKEN_NAME := 'AG_NAME';
          l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
          l_token_table(3).TOKEN_NAME := 'DATA_TYPE';
          l_token_table(3).TOKEN_VALUE := l_attr_metadata_obj.DATA_TYPE_MEANING;
          l_token_table(4).TOKEN_NAME := 'VALUE';
          l_token_table(4).TOKEN_VALUE := px_attr_name_value_pairs(l_attr_value_index).ATTR_DISP_VALUE;

          x_return_status := FND_API.G_RET_STS_ERROR;


        ------------------------------------------------------------------------------
        -- Finally, we check for the much less common case where the Attribute is a --
        -- Date, but the value passed in is a $SYSDATE$ expression of some sort; in --
        -- such a case, we want to replace the expression with the appropriate Date --
        ------------------------------------------------------------------------------
        ELSIF ((l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
                l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE)
                AND
               (px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_STR IS NOT NULL AND
                px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_DATE IS NULL)) THEN

          DECLARE
            l_formatted_expression   VARCHAR2(150);
          BEGIN
            l_formatted_expression := Format_Sysdate_Expression(px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_STR);

            IF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) THEN
              px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_DATE := TRUNC(TO_DATE(l_formatted_expression, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));
            ELSE
              px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_DATE := TO_DATE(l_formatted_expression, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              l_err_msg_name := 'EGO_EF_DATA_TYPE_INCORRECT';
              l_token_table(1).TOKEN_NAME := 'ATTR_NAME';
              l_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.ATTR_DISP_NAME;
              l_token_table(2).TOKEN_NAME := 'AG_NAME';
              l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
              l_token_table(3).TOKEN_NAME := 'DATA_TYPE';
              l_token_table(3).TOKEN_VALUE := l_attr_metadata_obj.DATA_TYPE_MEANING;
              l_token_table(4).TOKEN_NAME := 'VALUE';
              l_token_table(4).TOKEN_VALUE := px_attr_name_value_pairs(l_attr_value_index).ATTR_VALUE_STR;
              x_return_status := FND_API.G_RET_STS_ERROR;
          END;
        END IF;

        ----------------------------------------------------------------------------
        -- If processing for this Attribute failed, we log the error but continue --
        -- to process remaining Attributes (so we can report all errors at once)  --
        ----------------------------------------------------------------------------
        IF (l_err_msg_name IS NOT NULL) THEN

          Debug_Msg('Adding '||l_err_msg_name||' to error table for row '||px_attr_name_value_pairs(px_attr_name_value_pairs.FIRST).ROW_IDENTIFIER);

          ERROR_HANDLER.Add_Error_Message(
            p_message_name      => l_err_msg_name
           ,p_application_id    => 'EGO'
           ,p_token_tbl         => l_token_table
           ,p_message_type      => FND_API.G_RET_STS_ERROR
           ,p_row_identifier    => G_USER_ROW_IDENTIFIER
           ,p_entity_id         => p_entity_id
           ,p_entity_index      => p_entity_index
           ,p_entity_code       => p_entity_code
           ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
          );
        END IF;

        l_err_msg_name := NULL;
        l_token_table.DELETE();
        l_attr_value_index := px_attr_name_value_pairs.NEXT(l_attr_value_index);
      END LOOP;
    END IF;

    Debug_Msg('In Generate_Attr_Int_Values, done', 2);

END Generate_Attr_Int_Values;

----------------------------------------------------------------------
PROCEDURE Raise_WF_Event_If_Enabled (
        p_dml_type                      IN   VARCHAR2
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_extension_id                  IN   NUMBER
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_pre_event_flag                IN   VARCHAR2 DEFAULT NULL  --4105841
       ,p_data_level_id                 IN   VARCHAR2 DEFAULT NULL
       ,px_attr_diffs                   IN   EGO_USER_ATTR_DIFF_TABLE
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Raise_WF_Event_If_Enabled';
    l_event_name             VARCHAR2(240);
    l_is_event_enabled_flag  VARCHAR2(1);
    l_primary_key_1_col_name VARCHAR2(30);
    l_primary_key_1_value    VARCHAR2(150);
    l_primary_key_2_col_name VARCHAR2(30);
    l_primary_key_2_value    VARCHAR2(150);
    l_primary_key_3_col_name VARCHAR2(30);
    l_primary_key_3_value    VARCHAR2(150);
    l_primary_key_4_col_name VARCHAR2(30);
    l_primary_key_4_value    VARCHAR2(150);
    l_primary_key_5_col_name VARCHAR2(30);
    l_primary_key_5_value    VARCHAR2(150);
    l_data_level_1_col_name  VARCHAR2(30);
    l_data_level_1_value     VARCHAR2(150);
    l_data_level_2_col_name  VARCHAR2(30);
    l_data_level_2_value     VARCHAR2(150);
    l_data_level_3_col_name  VARCHAR2(30);
    l_data_level_3_value     VARCHAR2(150);
    l_data_level_4_col_name  VARCHAR2(30);
    l_data_level_4_value     VARCHAR2(150);
    l_data_level_5_col_name  VARCHAR2(30);
    l_data_level_5_value     VARCHAR2(150);

    l_event_key              VARCHAR2(240);
    l_attr_name              VARCHAR2(240);
    --Start 4105841 Business Event Enh
    l_attr_name_val_index    NUMBER;
    l_attrs_index            NUMBER;
    l_attr_rec               EGO_ATTR_REC;
    l_attr_name_val          EGO_ATTR_TABLE;
    l_dml_type               VARCHAR2(10);
    l_dummy                  NUMBER;
    --End 4105841
    l_curr_attr_metadata_obj        EGO_ATTR_METADATA_OBJ; -- abedajna, Bug 6134504
  BEGIN


    ----------------------------------------------------------------------
    -- If there is a Business Event defined for this Attr Group Type... --
    ----------------------------------------------------------------------
    Debug_Msg( l_api_name ||' started');
    IF p_pre_event_flag IS NULL THEN
      BEGIN
        SELECT BUSINESS_EVENT_NAME
          INTO l_event_name
          FROM EGO_FND_DESC_FLEXS_EXT
         WHERE APPLICATION_ID = p_attr_group_metadata_obj.APPLICATION_ID
           AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_metadata_obj.ATTR_GROUP_TYPE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    ELSE
      BEGIN --Added for 4105841
        SELECT PRE_BUSINESS_EVENT_NAME
          INTO l_event_name
          FROM EGO_FND_DESC_FLEXS_EXT
         WHERE APPLICATION_ID = p_attr_group_metadata_obj.APPLICATION_ID
           AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_metadata_obj.ATTR_GROUP_TYPE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    IF (l_event_name IS NOT NULL) THEN
      -----------------------------------------------------------
      -- ...and if this Attr Group is enabled for the Event... --
      -----------------------------------------------------------


      IF p_pre_event_flag IS NULL THEN
        /*
  SELECT BUSINESS_EVENT_FLAG
          INTO l_is_event_enabled_flag
          FROM EGO_FND_DSC_FLX_CTX_EXT
         WHERE ATTR_GROUP_ID = p_attr_group_metadata_obj.ATTR_GROUP_ID;*/
        SELECT COUNT(*)
          INTO l_dummy
          FROM EGO_ATTR_GROUP_DL
         WHERE ATTR_GROUP_ID = p_attr_group_metadata_obj.ATTR_GROUP_ID
           AND DATA_LEVEL_ID = NVL(p_data_level_id,DATA_LEVEL_ID)
           AND RAISE_POST_EVENT = 'Y'; -- abedajna 6137035
        IF (l_dummy > 0) THEN
          l_is_event_enabled_flag := 'Y';
        ELSE
          l_is_event_enabled_flag := 'N';
        END IF;

      ELSE  --Added for 4105841
      /*
        SELECT PRE_BUSINESS_EVENT_FLAG
          INTO l_is_event_enabled_flag
          FROM EGO_FND_DSC_FLX_CTX_EXT
         WHERE ATTR_GROUP_ID = p_attr_group_metadata_obj.ATTR_GROUP_ID;*/
        SELECT COUNT(*)
          INTO l_dummy
          FROM EGO_ATTR_GROUP_DL
         WHERE ATTR_GROUP_ID = p_attr_group_metadata_obj.ATTR_GROUP_ID
           AND DATA_LEVEL_ID = NVL(p_data_level_id,DATA_LEVEL_ID)
           AND RAISE_PRE_EVENT = 'Y';  --abedajna 6137035
        IF (l_dummy > 0) THEN
          l_is_event_enabled_flag := 'Y';
        ELSE
          l_is_event_enabled_flag := 'N';
        END IF;
      END IF;

    END IF;

    IF (l_is_event_enabled_flag = 'Y') THEN

        ------------------------------------------------------------
        -- ...then we gather PKs and data levels in order to call --
        -- our wrapper to the WF code to raise the Business Event --
        ------------------------------------------------------------
      l_primary_key_1_col_name := p_pk_column_name_value_pairs(1).NAME;
      l_primary_key_1_value := p_pk_column_name_value_pairs(1).VALUE;

      IF (p_pk_column_name_value_pairs.COUNT > 1 AND
          p_pk_column_name_value_pairs(2) IS NOT NULL) THEN

        l_primary_key_2_col_name := p_pk_column_name_value_pairs(2).NAME;
        l_primary_key_2_value := p_pk_column_name_value_pairs(2).VALUE;

        IF (p_pk_column_name_value_pairs.COUNT > 2 AND
            p_pk_column_name_value_pairs(3) IS NOT NULL) THEN

          l_primary_key_3_col_name := p_pk_column_name_value_pairs(3).NAME;
          l_primary_key_3_value := p_pk_column_name_value_pairs(3).VALUE;

          IF (p_pk_column_name_value_pairs.COUNT > 3 AND
              p_pk_column_name_value_pairs(4) IS NOT NULL) THEN

            l_primary_key_4_col_name := p_pk_column_name_value_pairs(4).NAME;
            l_primary_key_4_value := p_pk_column_name_value_pairs(4).VALUE;

            IF (p_pk_column_name_value_pairs.COUNT > 4 AND
                p_pk_column_name_value_pairs(5) IS NOT NULL) THEN

              l_primary_key_5_col_name := p_pk_column_name_value_pairs(5).NAME;
              l_primary_key_5_value := p_pk_column_name_value_pairs(5).VALUE;

            END IF;
          END IF;
        END IF;
      END IF;

      IF (p_data_level_name_value_pairs IS NOT NULL AND
          p_data_level_name_value_pairs.COUNT > 0 AND
          p_data_level_name_value_pairs(1) IS NOT NULL) THEN

        l_data_level_1_col_name := p_data_level_name_value_pairs(1).NAME;
        l_data_level_1_value := p_data_level_name_value_pairs(1).VALUE;

        IF (p_data_level_name_value_pairs.COUNT > 1 AND
            p_data_level_name_value_pairs(2) IS NOT NULL) THEN

          l_data_level_2_col_name := p_data_level_name_value_pairs(2).NAME;
          l_data_level_2_value := p_data_level_name_value_pairs(2).VALUE;

          IF (p_data_level_name_value_pairs.COUNT > 2 AND
              p_data_level_name_value_pairs(3) IS NOT NULL) THEN

            l_data_level_3_col_name := p_data_level_name_value_pairs(3).NAME;
            l_data_level_3_value := p_data_level_name_value_pairs(3).VALUE;

              IF (p_data_level_name_value_pairs.COUNT > 3 AND
                  p_data_level_name_value_pairs(4) IS NOT NULL) THEN

                l_data_level_4_col_name := p_data_level_name_value_pairs(4).NAME;
                l_data_level_4_value := p_data_level_name_value_pairs(4).VALUE;

                 IF (p_data_level_name_value_pairs.COUNT > 4 AND
                     p_data_level_name_value_pairs(5) IS NOT NULL) THEN

                   l_data_level_5_col_name := p_data_level_name_value_pairs(5).NAME;
                   l_data_level_5_value := p_data_level_name_value_pairs(5).VALUE;
                 END IF;
              END IF;
          END IF;
        END IF;
      END IF;

      --------------------------------------------------------------------
      -- To generate a unique instance key, we take the first 225 chars --
      -- of the Event name and append a timestamp of the current time   --
      --------------------------------------------------------------------
      l_event_key := SUBSTRB(l_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS') || TO_CHAR(dbms_random.value(1,100));

      Debug_Msg('In Raise_WF_Event_If_Enabled, raising event with key '||l_event_key||' and DML_TYPE '||p_dml_type, 3);
      -- Start 4105841

      l_attrs_index    := px_attr_diffs.FIRST;
      l_attr_name_val  := EGO_ATTR_TABLE();
      l_attr_rec       := EGO_ATTR_REC('','');
      ---  In case of update compare and add...the changed ones....
      l_dml_type := p_dml_type;
      IF l_dml_type = 'UPDATE' AND G_SYNC_TO_UPDATE = 'Y' THEN
        l_dml_type := 'CREATE';
/*        IF p_pre_event_flag IS NULL THEN --modify it after raising post event.
          G_SYNC_TO_UPDATE := 'N';
        END IF;     */
      END IF;

      IF(l_dml_type = 'UPDATE') THEN
        WHILE (l_attrs_index <= px_attr_diffs.LAST) LOOP
          l_attr_rec.attr_name := px_attr_diffs(l_attrs_index).attr_name;
-- abedajna Bug 6134504 begin
            l_curr_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                      p_attr_group_metadata_obj.attr_metadata_table
                                     ,l_attr_rec.attr_name );
-- abedajna Bug 6134504 end
          IF(NVL(px_attr_diffs(L_ATTRS_INDEX).OLD_ATTR_VALUE_STR,FND_API.G_MISS_CHAR)<>
             NVL(px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_STR,FND_API.G_MISS_CHAR)) THEN
            l_attr_name_val.EXTEND();
            l_attr_rec.attr_value := px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_STR;
            l_attr_name_val(l_attr_name_val.LAST) := l_attr_rec;
          ELSIF ( NVL(px_attr_diffs(L_ATTRS_INDEX).OLD_ATTR_VALUE_NUM,FND_API.G_MISS_NUM)<>
                  NVL(px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_NUM,FND_API.G_MISS_NUM))THEN
            l_attr_name_val.EXTEND();
            l_attr_rec.attr_value := to_char(px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_NUM);
            l_attr_name_val(l_attr_name_val.LAST) :=l_attr_rec;
          ELSIF (NVL(px_attr_diffs(L_ATTRS_INDEX).OLD_ATTR_VALUE_DATE,FND_API.G_MISS_DATE)<>
                 NVL(px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_DATE,FND_API.G_MISS_DATE))THEN
            l_attr_name_val.EXTEND();
--          l_attr_rec.attr_value := to_char(px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_DATE);
-- abedajna Bug 6134504 begin
            if ( l_curr_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE ) then -- timestamp
                l_attr_rec.attr_value := to_char(px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_DATE, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
            elsif ( l_curr_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) then -- date
                l_attr_rec.attr_value := to_char(px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_DATE);
            end if;
-- abedajna Bug 6134504 end
            l_attr_name_val(l_attr_name_val.LAST) :=  l_attr_rec;
          END IF;
          l_attrs_index := px_attr_diffs.NEXT(l_attrs_index);
        END LOOP;

      ---for create add all attributes
      ELSIF(l_dml_type = 'CREATE') then
        WHILE (l_attrs_index <= px_attr_diffs.LAST) LOOP
          l_attr_rec.attr_name := px_attr_diffs(l_attrs_index).attr_name;
-- abedajna Bug 6134504 begin
            l_curr_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                      p_attr_group_metadata_obj.attr_metadata_table
                                     ,l_attr_rec.attr_name );
-- abedajna Bug 6134504 end
          IF px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_STR IS NOT NULL  THEN
            l_attr_rec.attr_value := px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_STR;
          ELSIF px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_NUM IS NOT NULL THEN
            l_attr_rec.attr_value := TO_CHAR(px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_num);
          ELSIF px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_DATE IS NOT NULL THEN
--            l_attr_rec.attr_value := TO_CHAR(px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_DATE);
-- abedajna Bug 6134504 begin
            if ( l_curr_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE ) then -- timestamp
                l_attr_rec.attr_value := to_char(px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_DATE, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
            elsif ( l_curr_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) then -- date
                l_attr_rec.attr_value := to_char(px_attr_diffs(L_ATTRS_INDEX).NEW_ATTR_VALUE_DATE);
            end if;
-- abedajna Bug 6134504 end
          ELSE
            l_attr_rec.attr_value := null;
          END IF;

          l_attr_name_val.EXTEND();
          l_attr_name_val(l_attr_name_val.LAST) :=  l_attr_rec;
          l_attrs_index := px_attr_diffs.NEXT(l_attrs_index);
        END LOOP;

     ---for delete add all 'old' attributes
     ELSIF(l_dml_type = 'DELETE') then
        WHILE (l_attrs_index <= px_attr_diffs.LAST) LOOP
          l_attr_rec.attr_name := px_attr_diffs(l_attrs_index).attr_name;
-- abedajna Bug 6134504 begin
            l_curr_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                      p_attr_group_metadata_obj.attr_metadata_table
                                     ,l_attr_rec.attr_name );
-- abedajna Bug 6134504 end
          IF px_attr_diffs(L_ATTRS_INDEX).OLD_ATTR_VALUE_STR IS NOT NULL  THEN
            l_attr_rec.attr_value := px_attr_diffs(L_ATTRS_INDEX).OLD_ATTR_VALUE_STR;
          ELSIF px_attr_diffs(L_ATTRS_INDEX).OLD_ATTR_VALUE_NUM IS NOT NULL THEN
            l_attr_rec.attr_value := TO_CHAR(px_attr_diffs(L_ATTRS_INDEX).OLD_ATTR_VALUE_num);
          ELSIF px_attr_diffs(L_ATTRS_INDEX).OLD_ATTR_VALUE_DATE IS NOT NULL THEN
--            l_attr_rec.attr_value := TO_CHAR(px_attr_diffs(L_ATTRS_INDEX).OLD_ATTR_VALUE_DATE);
-- abedajna Bug 6134504 begin
            if ( l_curr_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) then -- timestamp
                l_attr_rec.attr_value := to_char(px_attr_diffs(L_ATTRS_INDEX).OLD_ATTR_VALUE_DATE, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
            elsif ( l_curr_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) then -- date
                l_attr_rec.attr_value := to_char(px_attr_diffs(L_ATTRS_INDEX).OLD_ATTR_VALUE_DATE);
            end if;
-- abedajna Bug 6134504 end
          ELSE
            l_attr_rec.attr_value := null;
          END IF;

          l_attr_name_val.EXTEND();
          l_attr_name_val(l_attr_name_val.LAST) :=  l_attr_rec;
          l_attrs_index := px_attr_diffs.NEXT(l_attrs_index);
        END LOOP;
      END IF;

      ---Raise the event
      IF l_attr_name_val.count() > 0 THEN --if attributes are there raise it,
        IF p_pre_event_flag IS NULL THEN --Raise post Event
           EGO_WF_WRAPPER_PVT.Raise_WF_Business_Event(
            p_event_name                  => l_event_name
           ,p_event_key                   => l_event_key
           ,p_dml_type                    => l_dml_type
           ,p_attr_group_name             => p_attr_group_metadata_obj.ATTR_GROUP_NAME
           ,p_extension_id                => p_extension_id
           ,p_primary_key_1_col_name      => l_primary_key_1_col_name
           ,p_primary_key_1_value         => l_primary_key_1_value
           ,p_primary_key_2_col_name      => l_primary_key_2_col_name
           ,p_primary_key_2_value         => l_primary_key_2_value
           ,p_primary_key_3_col_name      => l_primary_key_3_col_name
           ,p_primary_key_3_value         => l_primary_key_3_value
           ,p_primary_key_4_col_name      => l_primary_key_4_col_name
           ,p_primary_key_4_value         => l_primary_key_4_value
           ,p_primary_key_5_col_name      => l_primary_key_5_col_name
           ,p_primary_key_5_value         => l_primary_key_5_value
           ,p_data_level_id               => p_data_level_id
           ,p_data_level_1_col_name       => l_data_level_1_col_name
           ,p_data_level_1_value          => l_data_level_1_value
           ,p_data_level_2_col_name       => l_data_level_2_col_name
           ,p_data_level_2_value          => l_data_level_2_value
           ,p_data_level_3_col_name       => l_data_level_3_col_name
           ,p_data_level_3_value          => l_data_level_3_value
           ,p_data_level_4_col_name       => l_data_level_4_col_name
           ,p_data_level_4_value          => l_data_level_4_value
           ,p_data_level_5_col_name       => l_data_level_5_col_name
           ,p_data_level_5_value          => l_data_level_5_value
           ,p_user_row_identifier         => G_USER_ROW_IDENTIFIER
           ,p_entity_id                   => p_entity_id
           ,p_entity_index                => p_entity_index
           ,p_entity_code                 => p_entity_code
           ,p_add_errors_to_fnd_stack     => G_ADD_ERRORS_TO_FND_STACK
          );
        ELSE --raise PreEvent
          EGO_WF_WRAPPER_PVT.Raise_WF_Business_Event(
            p_event_name                  => l_event_name
           ,p_event_key                   => l_event_key
           ,p_pre_event_flag              => 'T'
           ,p_dml_type                    => l_dml_type
           ,p_attr_group_name             => p_attr_group_metadata_obj.ATTR_GROUP_NAME
           ,p_extension_id                => p_extension_id
           ,p_primary_key_1_col_name      => l_primary_key_1_col_name
           ,p_primary_key_1_value         => l_primary_key_1_value
           ,p_primary_key_2_col_name      => l_primary_key_2_col_name
           ,p_primary_key_2_value         => l_primary_key_2_value
           ,p_primary_key_3_col_name      => l_primary_key_3_col_name
           ,p_primary_key_3_value         => l_primary_key_3_value
           ,p_primary_key_4_col_name      => l_primary_key_4_col_name
           ,p_primary_key_4_value         => l_primary_key_4_value
           ,p_primary_key_5_col_name      => l_primary_key_5_col_name
           ,p_primary_key_5_value         => l_primary_key_5_value
           ,p_data_level_id               => p_data_level_id
           ,p_data_level_1_col_name       => l_data_level_1_col_name
           ,p_data_level_1_value          => l_data_level_1_value
           ,p_data_level_2_col_name       => l_data_level_2_col_name
           ,p_data_level_2_value          => l_data_level_2_value
           ,p_data_level_3_col_name       => l_data_level_3_col_name
           ,p_data_level_3_value          => l_data_level_3_value
           ,p_data_level_4_col_name       => l_data_level_4_col_name
           ,p_data_level_4_value          => l_data_level_4_value
           ,p_data_level_5_col_name       => l_data_level_5_col_name
           ,p_data_level_5_value          => l_data_level_5_value
           ,p_user_row_identifier         => G_USER_ROW_IDENTIFIER
           ,p_attr_name_val_tbl           => l_attr_name_val
           ,p_entity_id                   => p_entity_id
           ,p_entity_index                => p_entity_index
           ,p_entity_code                 => p_entity_code
           ,p_add_errors_to_fnd_stack     => G_ADD_ERRORS_TO_FND_STACK
          );
        END IF;--end pre event flag.
      END IF; ---end count attributes.
    END IF;--end if if flag enabled
    Debug_Msg( l_api_name ||' done ');
  EXCEPTION
    --- If subscription fails...don't add to the stack, already added in EGO_WF_WRAPPER_PVT
    WHEN EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC THEN
        raise EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC;

    WHEN OTHERS THEN
      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        Debug_Msg('GOT EXCEPTION' || SQLERRM);
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_PLSQL_ERR'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => G_USER_ROW_IDENTIFIER
         ,p_entity_id         => p_entity_id
         ,p_entity_index      => p_entity_index
         ,p_entity_code       => p_entity_code
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );
      END;
END Raise_WF_Event_If_Enabled;


----------------------------------------------------------------------


                  -------------------------------
                  -- Private Set-up Procedures --
                  -------------------------------

----------------------------------------------------------------------

PROCEDURE Perform_Preliminary_Checks (
        p_object_name                   IN   VARCHAR2
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
) IS

    l_object_id              NUMBER;
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    l_err_msg_name           VARCHAR2(30);

  BEGIN

    Debug_Msg('In Perform_Preliminary_Checks, starting', 2);

    ---------------------------------------------------------------------------------
    -- The first thing we do is make sure the passed-in Object Name is a valid one --
    -- (the procedure we call caches Object ID, so the call is not a wasted query) --
    ---------------------------------------------------------------------------------
    l_object_id := Get_Object_Id_From_Name(p_object_name);
    IF (l_object_id IS NULL) THEN

      l_token_table(1).TOKEN_NAME := 'OBJ_NAME';
      l_token_table(1).TOKEN_VALUE := p_object_name;

      l_err_msg_name := 'EGO_EF_NO_OBJ_ID_FOR_NAME';
      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => l_err_msg_name
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );

      RAISE FND_API.G_EXC_ERROR;

    END IF;

    ---------------------------------------------------------------
    -- Next, we make sure the column names passed in by as part  --
    -- of the name/value pair arrays match up with the extension --
    -- table metadata (again, the Ext Table object we find will  --
    -- be cached for later use, so asking for it now is OK).     --
    ---------------------------------------------------------------
    l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(l_object_id);

    Debug_Msg('In Perform_Preliminary_Checks, getting ext table metadata for object ' || l_object_id, 2);

    IF (l_ext_table_metadata_obj IS NULL) THEN
      l_token_table(1).TOKEN_NAME := 'OBJECT_NAME';
      l_token_table(1).TOKEN_VALUE := p_object_name;
      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => 'EGO_EF_EXT_TABLE_METADATA_ERR'
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (NOT Are_Ext_Table_Col_Names_Right(l_ext_table_metadata_obj
                                         ,p_pk_column_name_value_pairs
                                         ,p_class_code_name_value_pairs)) THEN
      l_token_table(1).TOKEN_NAME := 'OBJ_NAME';
      l_token_table(1).TOKEN_VALUE := p_object_name;
      l_err_msg_name := 'EGO_EF_EXT_TBL_COL_NAME_ERR';
      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => l_err_msg_name
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -----------------------------------------------------------------------------
    -- Next, we check that the Primary Key column array has at least one value --
    -----------------------------------------------------------------------------
    IF (p_pk_column_name_value_pairs IS NULL OR
        p_pk_column_name_value_pairs(p_pk_column_name_value_pairs.FIRST) IS NULL OR
        p_pk_column_name_value_pairs(p_pk_column_name_value_pairs.FIRST).VALUE IS NULL) THEN

      IF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 1) THEN
        l_err_msg_name := 'EGO_EF_NO_PK_VALUES_1';
        l_token_table(1).TOKEN_NAME := 'PK1_COL_NAME';
        l_token_table(1).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME;
        l_token_table(2).TOKEN_NAME := 'OBJ_NAME';
        l_token_table(2).TOKEN_VALUE := p_object_name;
      ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 2) THEN
        l_err_msg_name := 'EGO_EF_NO_PK_VALUES_2';
        l_token_table(1).TOKEN_NAME := 'PK1_COL_NAME';
        l_token_table(1).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME;
        l_token_table(2).TOKEN_NAME := 'PK2_COL_NAME';
        l_token_table(2).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME;
        l_token_table(3).TOKEN_NAME := 'OBJ_NAME';
        l_token_table(3).TOKEN_VALUE := p_object_name;
      ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 3) THEN
        l_err_msg_name := 'EGO_EF_NO_PK_VALUES_3';
        l_token_table(1).TOKEN_NAME := 'PK1_COL_NAME';
        l_token_table(1).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME;
        l_token_table(2).TOKEN_NAME := 'PK2_COL_NAME';
        l_token_table(2).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME;
        l_token_table(3).TOKEN_NAME := 'PK3_COL_NAME';
        l_token_table(3).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME;
        l_token_table(4).TOKEN_NAME := 'OBJ_NAME';
        l_token_table(4).TOKEN_VALUE := p_object_name;
      ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 4) THEN
        l_err_msg_name := 'EGO_EF_NO_PK_VALUES_4';
        l_token_table(1).TOKEN_NAME := 'PK1_COL_NAME';
        l_token_table(1).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME;
        l_token_table(2).TOKEN_NAME := 'PK2_COL_NAME';
        l_token_table(2).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME;
        l_token_table(3).TOKEN_NAME := 'PK3_COL_NAME';
        l_token_table(3).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME;
        l_token_table(4).TOKEN_NAME := 'PK4_COL_NAME';
        l_token_table(4).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME;
        l_token_table(5).TOKEN_NAME := 'OBJ_NAME';
        l_token_table(5).TOKEN_VALUE := p_object_name;
      ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 5) THEN
        l_err_msg_name := 'EGO_EF_NO_PK_VALUES_5';
        l_token_table(1).TOKEN_NAME := 'PK1_COL_NAME';
        l_token_table(1).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME;
        l_token_table(2).TOKEN_NAME := 'PK2_COL_NAME';
        l_token_table(2).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME;
        l_token_table(3).TOKEN_NAME := 'PK3_COL_NAME';
        l_token_table(3).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME;
        l_token_table(4).TOKEN_NAME := 'PK4_COL_NAME';
        l_token_table(4).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME;
        l_token_table(5).TOKEN_NAME := 'PK5_COL_NAME';
        l_token_table(5).TOKEN_VALUE := l_ext_table_metadata_obj.pk_column_metadata(5).COL_NAME;
        l_token_table(6).TOKEN_NAME := 'OBJ_NAME';
        l_token_table(6).TOKEN_VALUE := p_object_name;
      END IF;
      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => l_err_msg_name
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    Debug_Msg('In Perform_Preliminary_Checks, done', 2);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg('In Perform_Preliminary_Checks, EXCEPTION FND_API.G_EXC_ERROR', 2);
      x_return_status := FND_API.G_RET_STS_ERROR;

END Perform_Preliminary_Checks;

----------------------------------------------------------------------
-- if p_data_level_row_obj is sent,
-- the privilege will be taken from data_level_row_obj
-- else it is taken from p_attr_group_metadata_obj
----------------------------------------------------------------------
PROCEDURE Check_Privileges (
        p_attr_group_metadata_obj  IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_data_level_row_obj       IN   EGO_DATA_LEVEL_ROW_OBJ  DEFAULT NULL
       ,p_ignore_edit_privilege    IN   BOOLEAN    DEFAULT FALSE
       ,p_entity_id                IN   NUMBER     DEFAULT NULL
       ,p_entity_index             IN   NUMBER     DEFAULT NULL
       ,p_entity_code              IN   VARCHAR2   DEFAULT NULL
       ,x_return_status            OUT  NOCOPY VARCHAR2
) IS

    l_privilege_table_index  NUMBER;
    l_has_view_privilege     BOOLEAN := FALSE;
    l_has_edit_privilege     BOOLEAN := FALSE;
    l_error_message_name     VARCHAR2(30);
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_view_privilege         fnd_form_functions.function_name%TYPE;
    l_edit_privilege         fnd_form_functions.function_name%TYPE;

  BEGIN

    Debug_Msg('In Check_Privileges, starting', 2);
IF (p_data_level_row_obj IS NULL) THEN
Debug_Msg(' Check_Privileges  view priv: '|| p_data_level_row_obj.view_privilege_id ||' edit priv: '||p_data_level_row_obj.edit_privilege_id);
ELSE
Debug_Msg(' Check_Privileges  view priv: '|| p_attr_group_metadata_obj.VIEW_PRIVILEGE ||' edit priv: '||p_attr_group_metadata_obj.EDIT_PRIVILEGE);
END IF;

    ---------------------------------------------------------------
    -- First check for View privilege; if there is one, the user --
    -- must have it to even see the AG, let alone modify it      --
    ---------------------------------------------------------------
    IF (p_data_level_row_obj IS NULL AND p_attr_group_metadata_obj.VIEW_PRIVILEGE IS NULL)
       OR
       (p_data_level_row_obj IS NOT NULL and p_data_level_row_obj.view_privilege_id IS NULL) THEN

      l_has_view_privilege := TRUE;

    ELSE

      IF p_data_level_row_obj IS NOT NULL THEN
        SELECT function_name
        INTO l_view_privilege
        FROM fnd_form_functions
        WHERE function_id = p_data_level_row_obj.view_privilege_id;
      ELSE
        l_view_privilege  := p_attr_group_metadata_obj.VIEW_PRIVILEGE;
      END IF;
Debug_Msg(' Check_Privileges  view priv: '|| l_view_privilege );
      --------------------------------------------------------
      -- NOTE: We assume that this procedure is only called --
      -- when G_CURRENT_USER_PRIVILEGES is not NULL         --
      --------------------------------------------------------
      IF (G_CURRENT_USER_PRIVILEGES IS NOT NULL AND G_CURRENT_USER_PRIVILEGES.COUNT > 0) THEN
        l_privilege_table_index := G_CURRENT_USER_PRIVILEGES.FIRST;
        WHILE (l_privilege_table_index <= G_CURRENT_USER_PRIVILEGES.LAST)
        LOOP
          EXIT WHEN l_has_view_privilege;

          IF (G_CURRENT_USER_PRIVILEGES(l_privilege_table_index) = l_view_privilege) THEN
            l_has_view_privilege := TRUE;
          END IF;

          l_privilege_table_index := G_CURRENT_USER_PRIVILEGES.NEXT(l_privilege_table_index);
        END LOOP;
      END IF;
    END IF;

    ----------------------------------------------------------------------
    -- If the user has View privilege (or if there is none defined), we --
    -- check for Edit privilege (assuming that p_ignore_edit_privilege  --
    -- is FALSE); if there is an Edit privilege, the user must have it  --
    ----------------------------------------------------------------------
    IF (NOT l_has_view_privilege) THEN
      l_error_message_name := 'EGO_EF_AG_USER_VIEW_PRIV_ERR';
    ELSE

      IF ( p_ignore_edit_privilege
          OR
          (p_data_level_row_obj IS NULL AND p_attr_group_metadata_obj.EDIT_PRIVILEGE IS NULL)
          OR
          (p_data_level_row_obj IS NOT NULL and p_data_level_row_obj.edit_privilege_id IS NULL) ) THEN

        l_has_edit_privilege := TRUE;

      ELSE
        IF p_data_level_row_obj IS NOT NULL THEN
          IF p_data_level_row_obj.edit_privilege_id IS NOT NULL THEN
            SELECT function_name
            INTO l_edit_privilege
            FROM fnd_form_functions
            WHERE function_id = p_data_level_row_obj.edit_privilege_id;
          ELSE
            l_edit_privilege := NULL;
          END IF;
        ELSE
          l_edit_privilege := p_attr_group_metadata_obj.EDIT_PRIVILEGE;
        END IF;
Debug_Msg(' Check_Privileges  edit priv: '|| l_edit_privilege );

        IF (G_CURRENT_USER_PRIVILEGES.COUNT > 0) THEN
          l_privilege_table_index := G_CURRENT_USER_PRIVILEGES.FIRST;
          WHILE (l_privilege_table_index <= G_CURRENT_USER_PRIVILEGES.LAST)
          LOOP
            EXIT WHEN l_has_edit_privilege;

            IF (G_CURRENT_USER_PRIVILEGES(l_privilege_table_index) = l_edit_privilege) THEN
              l_has_edit_privilege := TRUE;
            END IF;

            l_privilege_table_index := G_CURRENT_USER_PRIVILEGES.NEXT(l_privilege_table_index);
          END LOOP;
        END IF;
      END IF;
    END IF;

    IF (l_has_edit_privilege) THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSIF (l_error_message_name IS NULL) THEN
      l_error_message_name := 'EGO_EF_AG_USER_PRIV_ERR';
    END IF;

    -----------------------------------------------------------------------
    -- If the user is missing a necessary privilege, we report the error --
    -----------------------------------------------------------------------
    IF (l_error_message_name IS NOT NULL) THEN

      l_token_table(1).TOKEN_NAME := 'USER_NAME';
      l_token_table(1).TOKEN_VALUE := FND_GLOBAL.USER_NAME;
      l_token_table(2).TOKEN_NAME := 'AG_NAME';
      l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name                  => l_error_message_name
       ,p_application_id                => 'EGO'
       ,p_token_tbl                     => l_token_table
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_row_identifier                => G_USER_ROW_IDENTIFIER
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_addto_fnd_stack               => G_ADD_ERRORS_TO_FND_STACK
      );

      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    Debug_Msg('In Check_Privileges, done; x_return_status is '||x_return_status, 2);

END Check_Privileges;

----------------------------------------------------------------------

PROCEDURE Set_Up_Business_Object_Session (
        p_bulkload_flag                 IN   BOOLEAN
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER
       ,p_init_error_handler_flag       IN   BOOLEAN
       ,p_object_name                   IN   VARCHAR2
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_init_fnd_msg_list             IN   VARCHAR2
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2
       ,p_default_user_row_identifier   IN   NUMBER     DEFAULT NULL
       ,p_use_def_vals_on_insert_flag   IN   BOOLEAN    DEFAULT FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
) IS

    l_err_msg_name           VARCHAR2(30);
    l_api_name               VARCHAR2(50) := 'Set_Up_Business_Object_Session(): ';

  BEGIN
Debug_Msg(l_api_name || 'starting', 3);
    ------------------------------------------------------------------
    -- This flag determines when certain validations are performed, --
    -- how error-handling proceeds, how caching is handled, etc.    --
    ------------------------------------------------------------------
    G_BULK_PROCESSING_FLAG := p_bulkload_flag;

    ---------------------------------------------------------------
    -- This flag determines whether calls to Insert_Row will use --
    -- Default Values for Attributes that are NULL or not passed --
    ---------------------------------------------------------------
    G_DEFAULT_ON_INSERT_FLAG := p_use_def_vals_on_insert_flag OR p_bulkload_flag;

    ---------------------------------------------------------------------------
    -- This table holds the current user's privileges on the current object; --
    -- if it is non-null and non-empty, we will use it to perform data       --
    -- security checks for all Attribute Groups that have privileges defined --
    ---------------------------------------------------------------------------
    G_CURRENT_USER_PRIVILEGES := p_user_privileges_on_object;

    ---------------------------------------------------------------------
    -- If non-null, this is the number we should use for logging error --
    -- messages that are outside of the context of any particular row  --
    ---------------------------------------------------------------------
    IF (p_default_user_row_identifier IS NOT NULL) THEN
      G_USER_ROW_IDENTIFIER := p_default_user_row_identifier;
    END IF;

    --------------------------------------------------------------------------
    -- Reset our cache of metadata so we pick up the latest state of things --
    -- (we only want to do this once per bulkload and once per UI call)     --
    --------------------------------------------------------------------------
    IF (G_NEED_TO_RESET_AG_CACHE) THEN

      EGO_USER_ATTRS_COMMON_PVT.Reset_Cache_And_Globals();
      G_ASSOCIATION_DATA_LEVEL_CACHE.DELETE();
      G_HIERARCHY_CACHE.DELETE();

      IF (G_BULK_PROCESSING_FLAG) THEN

        G_NEED_TO_RESET_AG_CACHE := FALSE;

      END IF;
    END IF;

    ---------------------------------------
    -- This global holds the debug level --
    ---------------------------------------
    G_DEBUG_OUTPUT_LEVEL := p_debug_level;

    -----------------------------------------
    -- Initialize FND_MSG_PUB if necessary --
    -----------------------------------------
    IF (FND_API.To_Boolean(p_init_fnd_msg_list)) THEN

      FND_MSG_PUB.Initialize;

    END IF;

    ---------------------------------------
    -- Set up ERROR_HANDLER if necessary --
    ---------------------------------------
    IF (p_init_error_handler_flag) THEN

      ERROR_HANDLER.Initialize();

      ----------------------------------------------------------
      -- If we're debugging we have to set up a Debug session --
      ----------------------------------------------------------
      IF (p_debug_level > 0) THEN

        Set_Up_Debug_Session(p_entity_id, p_entity_code, p_debug_level);

      END IF;
    END IF;

    IF (FND_API.To_Boolean(p_add_errors_to_fnd_stack)) THEN
      G_ADD_ERRORS_TO_FND_STACK := 'Y';
    ELSE
      G_ADD_ERRORS_TO_FND_STACK := 'N';
    END IF;

    ---------------------------------------------------
    -- Before we begin processing rows, we make sure --
    -- the basic information passed in is correct    --
    ---------------------------------------------------
    Perform_Preliminary_Checks(
        p_object_name                   => p_object_name
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,x_return_status                 => x_return_status
    );
Debug_Msg(l_api_name || 'done', 3);

END Set_Up_Business_Object_Session;

----------------------------------------------------------------------

PROCEDURE Close_Business_Object_Session (
        p_init_error_handler_flag       IN   BOOLEAN
       ,p_log_errors                    IN   BOOLEAN
       ,p_write_to_concurrent_log       IN   BOOLEAN
) IS

  BEGIN

    --------------------------------------------
    -- We log errors if we were told to do so --
    --------------------------------------------
    IF (p_log_errors) THEN
      IF (p_write_to_concurrent_log) THEN
        ERROR_HANDLER.Log_Error(
          p_write_err_to_inttable       => 'Y'
         ,p_write_err_to_conclog        => 'Y'
         ,p_write_err_to_debugfile      => ERROR_HANDLER.Get_Debug()
        );
      ELSE
        ERROR_HANDLER.Log_Error(
          p_write_err_to_inttable       => 'Y'
         ,p_write_err_to_debugfile      => ERROR_HANDLER.Get_Debug()
        );
      END IF;
    END IF;

    --------------------------------------------------------
    -- Set our various flags back to their initial values --
    --------------------------------------------------------
    -- FP Bug:6266004 (Base Bug:6086581)
    -- Start Reverting the fix done as a part of bug 3713278

    G_BULK_PROCESSING_FLAG := FALSE;
    G_DEFAULT_ON_INSERT_FLAG := FALSE;
    G_NEED_TO_RESET_AG_CACHE := TRUE;
    G_ADD_ERRORS_TO_FND_STACK := 'N';

    --Bug Fix 3713728
    --------------------------------------------------------
    -- We conditionally clear the user cache , only if it
    -- is not in Bulk Load Session
    --------------------------------------------------------

--    IF(G_BULK_PROCESSING_FLAG = FALSE) THEN
--      G_NEED_TO_RESET_AG_CACHE := TRUE;
--    END IF;
--    G_BULK_PROCESSING_FLAG := FALSE;
    --Bug Fix 3713728

    -- FP Bug:6266004 (Base Bug:6086581)
    -- End Reverting the fix done as a part of bug 3713278

    --------------------------------------------------------------
    -- If we were debugging, we have to close the debug session --
    --------------------------------------------------------------
    IF (p_init_error_handler_flag AND
        G_DEBUG_OUTPUT_LEVEL > 0 AND
        ERROR_HANDLER.Get_Debug() = 'Y') THEN

      ERROR_HANDLER.Close_Debug_Session();
      G_DEBUG_OUTPUT_LEVEL := 0;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN

      ----------------------------------------------------------
      -- The ERROR_HANDLER call may fail for various reasons, --
      -- but we don't want that to halt our processing        --
      ----------------------------------------------------------
      NULL;

END Close_Business_Object_Session;

----------------------------------------------------------------------


-- As a part of the Bug 8939034, Removed the hint BYPASS_UJVC.
-- p_to_table_name is not passed in any call to the below function, So the currently update expression
-- having the hint BYPASS_UJVC will not execute at all, as result removing the hint BYPASS_UJVC.
-- If any future use is planned to use the below function by passing the p_to_table_name,
-- we have to re-evaluate the hint in update expression.
FUNCTION Get_Table_Columns_List (
        p_application_id                IN   NUMBER
       ,p_from_table_name               IN   VARCHAR2
       ,p_from_cols_to_exclude_list     IN   VARCHAR2   DEFAULT NULL
       ,p_from_table_alias_prefix       IN   VARCHAR2   DEFAULT NULL
       ,p_to_table_name                 IN   VARCHAR2   DEFAULT NULL
       ,p_to_table_alias_prefix         IN   VARCHAR2   DEFAULT NULL
       ,p_in_line_view_where_clause     IN   VARCHAR2   DEFAULT NULL
       ,p_cast_date_cols_to_char        IN   BOOLEAN    DEFAULT FALSE
)
RETURN VARCHAR2
IS

    l_dynamic_sql             VARCHAR2(20000);
    l_table_column_names_list VARCHAR2(32767);
    l_in_update_mode          BOOLEAN;
    l_update_expression       VARCHAR2(32767);
    l_column_name             VARCHAR2(30);
    l_column_type             VARCHAR2(1);

    TYPE DYNAMIC_CUR IS REF CURSOR;
    l_dynamic_cursor         DYNAMIC_CUR;

  BEGIN

    -------------------------------------------------------------------
    -- Build a query to fetch names of all columns we want to append --
    -------------------------------------------------------------------
    l_dynamic_sql := ' SELECT COLUMN_NAME, Decode(DATA_TYPE,''NUMBER'',''N'', ''DATE'',''D'',''VARCHAR2'',''V'',NULL) COLUMN_TYPE '|| --BugFix:5503749 (FND_COLUMNS has the TL columns registered for the B table also hence cannot FND_COLUMNS now)
                       ' FROM SYS.ALL_TAB_COLUMNS ' ||
                      ' WHERE TABLE_NAME = :1 ';
    --Bug No:5346472
    -- We can't use a bind as :3 which is replaced by
    -- p_from_cols_to_exclude_list below.Since it is of type VARCHAR2
    -- and mainly it contains a long string with comma seperated values.
    -- Using :3 in this case will fetch wrong results.
    IF (p_from_cols_to_exclude_list IS NOT NULL) THEN
      --Bug no:5346472
      --l_dynamic_sql := l_dynamic_sql||' AND C.COLUMN_NAME NOT IN ( :3 )';
      l_dynamic_sql := l_dynamic_sql||' AND COLUMN_NAME NOT IN ( '||p_from_cols_to_exclude_list||' )';
    END IF;
    l_dynamic_sql := l_dynamic_sql||' ORDER BY COLUMN_NAME';

    -----------------------------------------------------------------------
    -- Determine whether we're in update mode (in which, instead of just --
    -- making a list of column names, we make an update expression using --
    -- the two table names (and possibly aliases) passed in)             --
    -----------------------------------------------------------------------
    l_in_update_mode := (p_to_table_name IS NOT NULL);

    ----------------------------------------------------
    -- Fetch all the table column names, prefixing or --
    -- building an update expression as appropriate   --
    ----------------------------------------------------
    IF (p_from_cols_to_exclude_list IS NOT NULL) THEN
      OPEN l_dynamic_cursor FOR l_dynamic_sql
      USING p_from_table_name;--Bug No:5346472 --, p_from_cols_to_exclude_list;
    ELSE
      OPEN l_dynamic_cursor FOR l_dynamic_sql
      USING p_from_table_name;
    END IF;
    LOOP
      FETCH l_dynamic_cursor INTO l_column_name, l_column_type;
      EXIT WHEN l_dynamic_cursor%NOTFOUND;

      -------------------------------------------
      -- If we're casting Dates to char, do so --
      -------------------------------------------
      IF (p_cast_date_cols_to_char AND l_column_type = 'D') THEN
        l_table_column_names_list := l_table_column_names_list||' TO_CHAR(';
      END IF;

      -------------------------------------------
      -- If there's a from table alias, add it --
      -------------------------------------------
      IF (p_from_table_alias_prefix IS NOT NULL) THEN
        l_table_column_names_list := l_table_column_names_list||p_from_table_alias_prefix||'.';
      END IF;

      ------------------------------------------------------------------
      -- Whether or not there's an alias, add the current column name --
      ------------------------------------------------------------------
      l_table_column_names_list := l_table_column_names_list || l_column_name || ' ';

      -----------------------------------------------------------
      -- If we're in update mode, add a from column alias, the --
      -- to column and its alias (we assume table aliases in   --
      -- update mode), and append to our update expression     --
      -----------------------------------------------------------
      IF (l_in_update_mode) THEN
        l_table_column_names_list := l_table_column_names_list ||
                                     p_from_table_alias_prefix || '_' ||
                                     l_column_name || ',' ||
                                     p_to_table_alias_prefix || '.' ||
                                     l_column_name || ' ' ||
                                     p_to_table_alias_prefix || '_' ||
                                     l_column_name;

        l_update_expression := l_update_expression ||
                               p_to_table_alias_prefix || '_' ||
                               l_column_name || '=' ||
                               p_from_table_alias_prefix || '_' ||
                               l_column_name || ',';

      END IF;

      ---------------------------------------------------------------------
      -- If we're casting Dates to char, close the parentheses correctly --
      ---------------------------------------------------------------------
      IF (p_cast_date_cols_to_char) THEN
        IF (l_column_type = 'D') THEN
          l_table_column_names_list := l_table_column_names_list||','''||
                                       EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||''') '||
                                       l_column_name;
        END IF;
      END IF;

      ---------------------------------------------------------
      -- Add a comma to end each loop regardless of the mode --
      ---------------------------------------------------------
      l_table_column_names_list := l_table_column_names_list || ',';

    END LOOP;
    CLOSE l_dynamic_cursor;

    -----------------------------------------------------------------------
    -- Trim the trailing ',' from l_table_column_names_list if necessary --
    -----------------------------------------------------------------------
    IF (LENGTH(l_table_column_names_list) > 0) THEN
      l_table_column_names_list := RTRIM(l_table_column_names_list, ',');
    END IF;

    -----------------------------------------------------------------
    -- Trim the trailing ',' from l_update_expression if necessary --
    -----------------------------------------------------------------
    IF (LENGTH(l_update_expression) > 0) THEN
      l_update_expression := RTRIM(l_update_expression, ',');
    END IF;

    ----------------------------------------------------------------------
    -- If we're in update mode, assemble the complete update expression --
    ----------------------------------------------------------------------
    IF (l_in_update_mode) THEN
     -- Bug 8939034 : Start - Removed the hint BYPASS_UJVC
     -- l_table_column_names_list := 'UPDATE /*+ BYPASS_UJVC */ (SELECT '||l_table_column_names_list||
      l_table_column_names_list := 'UPDATE (SELECT '||l_table_column_names_list||
     -- Bug 8939034 : End
                                   ' FROM '||p_from_table_name||' '||p_from_table_alias_prefix||
                                   ','||p_to_table_name||' '||p_to_table_alias_prefix||' '||
                                   p_in_line_view_where_clause||') SET '||l_update_expression;
    END IF;

    RETURN l_table_column_names_list;

END Get_Table_Columns_List;

----------------------------------------------------------------------



                    ----------------------------
                    -- Private Procedure APIs --
                    ----------------------------

----------------------------------------------------------------------

PROCEDURE Insert_Row (
        p_api_version                   IN   NUMBER
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_language_to_process           IN   VARCHAR2
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ
       ,p_extra_pk_col_name_val_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_extra_attr_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2
       ,p_pending_tl_table_name         IN   VARCHAR2
       ,p_execute_dml                   IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_commit                        IN   VARCHAR2
       ,p_bulkload_flag                 IN   BOOLEAN    DEFAULT FALSE
       ,px_attr_diffs                   IN OUT NOCOPY EGO_USER_ATTR_DIFF_TABLE
       ,p_raise_business_event          IN   BOOLEAN DEFAULT TRUE
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Insert_Row';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_b_table_name           VARCHAR2(30);
    l_tl_table_name          VARCHAR2(30);
    l_pk_col_names           VARCHAR2(175);
    l_dl_col_names           VARCHAR2(200);
    l_cc_col_names           VARCHAR2(50);
    l_change_col_names       VARCHAR2(50);
    l_all_col_names          VARCHAR2(425);
    l_pk_col_values          VARCHAR2(775);
    l_dl_col_values          VARCHAR2(100);
    l_cc_col_values          VARCHAR2(300);
    l_change_col_values      VARCHAR2(50);
    l_all_col_values         VARCHAR2(1175);
    l_default_values_or_not  VARCHAR2(10);
    l_default_columns_or_not VARCHAR2(11);
    l_new_extension_id       NUMBER;
    l_dynamic_sql            VARCHAR2(32767); --the largest a VARCHAR2 can be
    l_cursor_id              NUMBER;
    l_number_of_rows         NUMBER;
    l_dummy                  VARCHAR2(1175);
    l_error_message          VARCHAR2(4000);
    l_event_name             VARCHAR2(240);
    l_is_event_enabled_flag  VARCHAR2(1);
    l_event_key              VARCHAR2(240);
    l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_parameter_t            WF_PARAMETER_T:= WF_PARAMETER_T(null, null);

    l_propagate_hierarchy    BOOLEAN := TRUE;
    l_attr_diffs_event       EGO_USER_ATTR_DIFF_TABLE;
    l_pre_raise_flag         VARCHAR2(1);  --4105841

    l_extra_col_names        VARCHAR2(10000);
    l_extra_col_values       VARCHAR2(10000);
    l_index                  NUMBER;

    l_current_user_id        NUMBER := FND_GLOBAL.User_Id;
    l_current_login_id       NUMBER := FND_GLOBAL.Login_Id;
    l_data_level_id          NUMBER;
    l_dl_col_mdata_array     EGO_COL_METADATA_ARRAY;

    l_column_exists          VARCHAR2(1);  -- Bug 10097738
  BEGIN

    Debug_Msg('In Insert_Row, starting', 1);

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Insert_Row;
    END IF;

    l_pre_raise_flag := 'F';
    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_bulkload_flag) THEN
      l_propagate_hierarchy := FALSE;
    END IF;

    ----------------------------------------------------------------------
    -- We take in p_extension_id for the case where the caller wants to --
    -- add a row to the pending changes table based on a production row --
    -- for a Multi-Row Attr Group but with changed values for unique    --
    -- key Attrs; in such a case, we won't be able to find the current  --
    -- Extension ID from the production row (since we rely on UK values --
    -- our Get_Extension_Id_For_Row query), so it must be passed in.    --
    -- We also take in p_extension_id from Implement_Change_Line.       --
    ----------------------------------------------------------------------
    IF (p_extension_id IS NOT NULL) THEN
      l_new_extension_id := p_extension_id;
    END IF;

    ----------------------------
    -- Add the extra columns .--
    ----------------------------
    l_extra_col_names := '';
    l_extra_col_values := '';

    IF(p_extra_pk_col_name_val_pairs IS NOT NULL) THEN

      l_index := p_extra_pk_col_name_val_pairs.FIRST;
      WHILE (l_index IS NOT NULL)
      LOOP

         IF (p_extra_pk_col_name_val_pairs(l_index).NAME IS NOT NULL) THEN
           l_extra_col_names := l_extra_col_names || p_extra_pk_col_name_val_pairs(l_index).NAME || ' , ';
           IF (p_extra_pk_col_name_val_pairs(l_index).VALUE IS NOT NULL) THEN
             l_extra_col_values := l_extra_col_values || p_extra_pk_col_name_val_pairs(l_index).VALUE || ' , ';
           ELSE
             l_extra_col_values := l_extra_col_values || ' NULL , ';
           END IF;
         END IF;
      l_index := p_extra_pk_col_name_val_pairs.NEXT(l_index);

      END LOOP;
    END IF;


    IF(p_extra_attr_name_value_pairs IS NOT NULL) THEN
      l_index := p_extra_attr_name_value_pairs.FIRST;

      WHILE (l_index IS NOT NULL)
      LOOP
         IF (p_extra_attr_name_value_pairs(l_index).NAME IS NOT NULL) THEN

           l_extra_col_names := l_extra_col_names || p_extra_attr_name_value_pairs(l_index).NAME || ' , ';
           IF (p_extra_attr_name_value_pairs(l_index).VALUE IS NOT NULL) THEN
             l_extra_col_values := l_extra_col_values || p_extra_attr_name_value_pairs(l_index).VALUE || ' , ';
           ELSE
             l_extra_col_values := l_extra_col_values || ' NULL , ';
           END IF;

         END IF;
         l_index := p_extra_attr_name_value_pairs.NEXT(l_index);
      END LOOP;
    END IF;

    --------------------------------------------------------------------------
    -- Determine whether we're in Change mode and set variables accordingly --
    --------------------------------------------------------------------------
    IF (p_change_obj IS NOT NULL AND
        p_pending_b_table_name IS NOT NULL AND
        p_pending_tl_table_name IS NOT NULL) THEN

      IF (p_extension_id IS NULL) THEN
        IF (p_change_obj.ACD_TYPE <> 'ADD') THEN

          l_new_extension_id := Get_Extension_Id_For_Row(
                                  p_attr_group_metadata_obj     => p_attr_group_metadata_obj
                                 ,p_ext_table_metadata_obj      => p_ext_table_metadata_obj
                                 ,p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
                                 ,p_data_level                  => p_data_level
                                 ,p_data_level_name_value_pairs => p_data_level_name_value_pairs
                                 ,p_attr_name_value_pairs       => p_attr_name_value_pairs
                                );

        END IF;
      END IF;

      l_b_table_name := p_pending_b_table_name;
      l_tl_table_name := p_pending_tl_table_name;
      l_change_col_names := ' CHANGE_ID, CHANGE_LINE_ID, ACD_TYPE, ';
      IF (p_change_obj.CHANGE_ID IS NOT NULL) THEN
        l_change_col_values := p_change_obj.CHANGE_ID||', ';
      ELSE
        l_change_col_values := 'NULL, ';
      END IF;
      IF (p_change_obj.CHANGE_LINE_ID IS NOT NULL) THEN
        l_change_col_values := l_change_col_values||
                               p_change_obj.CHANGE_LINE_ID||', ';
      ELSE
        l_change_col_values := l_change_col_values||'NULL, ';
      END IF;
      IF (p_change_obj.ACD_TYPE IS NOT NULL) THEN
        l_change_col_values := l_change_col_values || '''' || p_change_obj.ACD_TYPE || ''', ';
      ELSE
        l_change_col_values := l_change_col_values || '''NULL'', ';
      END IF;

    ELSE

      l_b_table_name := p_attr_group_metadata_obj.EXT_TABLE_B_NAME;
      l_tl_table_name := p_attr_group_metadata_obj.EXT_TABLE_TL_NAME;
      l_change_col_names := '';
      l_change_col_values := '';

    END IF;

    ---------------------------------
    -- we need to construct the    --
    -- DML for the provided tables --
    ---------------------------------

   IF (p_pending_b_table_name IS NOT NULL) THEN
      l_b_table_name := p_pending_b_table_name;
   END IF;

   IF (p_pending_b_table_name IS NOT NULL) THEN
      l_tl_table_name := p_pending_tl_table_name;
   END IF;

    ------------------------------------------------------------------
    -- If we haven't set it yet, get a sequence-generated extension --
    -- ID to use for insertion into both the base and TL tables     --
    ------------------------------------------------------------------
    IF (l_new_extension_id IS NULL) THEN
      SELECT EGO_EXTFWK_S.NEXTVAL INTO l_new_extension_id FROM DUAL;
    END IF;

    --Start 4105841
    Get_Changed_Attributes(
          p_dml_operation                 => 'INSERT'
        , p_object_name                   => null
        , p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
        , p_attr_group_metadata_obj       => p_attr_group_metadata_obj
        , p_ext_table_metadata_obj        => p_ext_table_metadata_obj
        , p_data_level                    => p_data_level
        , p_data_level_name_value_pairs   => p_data_level_name_value_pairs
        , p_attr_name_value_pairs         => p_attr_name_value_pairs
        , p_extension_id                  => null
        , p_entity_id                     => p_entity_id
        , p_entity_index                  => p_entity_index
        , p_entity_code                   => p_entity_code
        , px_attr_diffs                   => l_attr_diffs_event);
    --End 4105841

    -- Only propagate if at least one attribute has EIH code = LP/AP
    IF (l_propagate_hierarchy AND
        p_attr_group_metadata_obj.HIERARCHY_PROPAGATE_FLAG = 'Y') THEN
    --4105841 : Removing call to Get_Changed_Attributes as it's called before this check
      px_attr_diffs := l_attr_diffs_event;
    END IF;

    -----------------------------------------------
    -- Now we open a cursor for the statement(s) --
    -- and initialize FND_DSQL for our DMLs      --
    -----------------------------------------------
    l_cursor_id := DBMS_SQL.Open_Cursor;
    Init();

    --------------------------------------------------------------------------------
    -- If we're bulkloading, we want to default any values the user left blank,   --
    -- but if we're coming from the UI, then the user explicitly set them to NULL --
    --------------------------------------------------------------------------------
    IF (G_DEFAULT_ON_INSERT_FLAG) THEN

      l_default_values_or_not := 'VALUES_DEF';
      l_default_columns_or_not := 'COLUMNS_DEF';

    ELSE

      l_default_values_or_not := 'VALUES';
      l_default_columns_or_not := 'COLUMNS';

    END IF;

    ------------------------------------------------------------------
    -- We pass p_language_to_process from Implement_Change_Line; if --
    -- we have it, then we only insert if the passed-in language is --
    -- equal to USERENV('LANG'); otherwise we behave normally       --
    ------------------------------------------------------------------
    IF (p_language_to_process IS NULL OR
        p_language_to_process = USERENV('LANG')) THEN

      ------------------------------------------------------
      -- FND_DSQL and start our first DML statement       --
      -- NOTE: we insert into both tables regardless of   --
      -- whether there are any Attr values for each table --
      -- so that the VL doesn't have to outer join        --
      ------------------------------------------------------

      -- CM expects extension Id to be the first bind
      -- in the generated DML
      FND_DSQL.Add_Text('INSERT INTO '||l_b_table_name||
                        ' ('||
                        'EXTENSION_ID, ');

      -----------------------------------------------------
      -- Add attr_group_id only if table has this column --
      -----------------------------------------------------
      IF (p_attr_group_metadata_obj.ATTR_GROUP_ID_FLAG ='Y') THEN
        FND_DSQL.Add_Text('ATTR_GROUP_ID, ');
      END IF;

      -----------------------------------------------------
      -- Add data_level_id only if it has been provided  --
      -----------------------------------------------------
      IF(p_data_level IS NOT NULL
         AND
         FND_API.TO_BOOLEAN(
              EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(p_table_name  => l_b_table_name
                                                           ,p_column_name => 'DATA_LEVEL_ID'
                                                           )
                           )
         ) THEN
        FND_DSQL.Add_Text('DATA_LEVEL_ID, ');
      END IF;

      --------------------------------------------------------------------------
      -- We trust that the names and values (fetched separately) will match   --
      -- up, because we checked this in Validate_Row.  If the caller bypassed --
      -- Validate_Row and went straight to Perform_DML_On_Row, then our       --
      -- assumption that names and values will match up could cause an error. --
      --------------------------------------------------------------------------

Debug_Msg(l_api_name || ' calling  EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols for PK ');
      l_pk_col_names := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                    p_ext_table_metadata_obj.pk_column_metadata
                                                   ,p_pk_column_name_value_pairs
                                                   ,'NAMES'
                                                   ,TRUE
                                                  );
Debug_Msg(l_api_name || ' calling  EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols for CC ');
      l_cc_col_names := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                    p_ext_table_metadata_obj.class_code_metadata
                                                   ,p_class_code_name_value_pairs
                                                   ,'NAMES'
                                                   ,TRUE
                                                   ,', '
                                                  );
      --------------------------------------------
      -- NOTE: if inserting into the pending    --
      -- table, we don't insert Data Level info --
      --------------------------------------------

      l_dl_col_mdata_array := EGO_USER_ATTRS_COMMON_PVT.Get_Data_Level_Col_Array(p_attr_group_metadata_obj.APPLICATION_ID,
                                                                                 p_attr_group_metadata_obj.ATTR_GROUP_TYPE);
/***
        FOR i IN l_dl_col_mdata_array.FIRST .. l_dl_col_mdata_array.LAST
        LOOP
           Debug_Msg('dl col--'||l_dl_col_mdata_array(i).COL_NAME);
        END LOOP;
***/
      IF (p_data_level_name_value_pairs IS NOT NULL AND
          p_data_level_name_value_pairs.COUNT > 0 AND
          p_change_obj IS NULL) THEN
Debug_Msg(l_api_name || ' calling  EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols for DL ');
        l_dl_col_names := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                      l_dl_col_mdata_array
                                                     ,p_data_level_name_value_pairs
                                                     ,'NAMES'
                                                     ,TRUE
                                                     ,', '
                                                    );
      END IF;

Debug_Msg('  l_dl_col_names-'||l_dl_col_names);

      FND_DSQL.Add_Text(', ' || l_change_col_names || l_extra_col_names);

      -----------------------------------------------
      -- Add the Attr column info to the statement --
      -----------------------------------------------
Debug_Msg(l_api_name || ' calling  Add_Attr_Info_To_Statement ');
      Add_Attr_Info_To_Statement(p_attr_group_metadata_obj.attr_metadata_table
                                ,p_attr_name_value_pairs
                                ,', '
                                ,l_default_columns_or_not
                                ,'NONTRANS');

      ----------------------------------------------------------------------
      -- (No need to add a comma here, because Add_Attr_Info_To_Statement --
      -- adds a trailing separator to the list if it adds anything to it) --
      ----------------------------------------------------------------------
			 -- Bug 10097738 : Start
 	       IF (p_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y') THEN
 	         -- check if the column UNIQUE_VALUE exists in the _b table

 	         -- The below function returns 'T' or 'F'
					 l_column_exists:= HAS_COLUMN_IN_TABLE_VIEW(l_b_table_name,'UNIQUE_VALUE');

 	         -- Add UNIQUE_VALUE only if table has this column for multi row UDAs only
 	         IF (FND_API.TO_BOOLEAN(l_column_exists)) THEN
 	           FND_DSQL.Add_Text('UNIQUE_VALUE, ');
 	         END IF;
 	       END IF;
 	       -- Bug 10097738 : End

      -------------------------------------
      -- Add the rest of the column info --
      -------------------------------------
      FND_DSQL.Add_Text('CREATED_BY, '||
                        'CREATION_DATE, '||
                        'LAST_UPDATED_BY, '||
                        'LAST_UPDATE_DATE, '||
                        'LAST_UPDATE_LOGIN'||
                        ') VALUES ( ');

      ------------------------------------------------
      -- Now bind the values, including Attr values --
      ------------------------------------------------
      Add_Bind(p_bind_identifier => 'EXTENSION_ID'
              ,p_value           => l_new_extension_id);

      -----------------------------------------------------
      -- Add attr_group_id only if table has this column --
      -----------------------------------------------------
      IF (p_attr_group_metadata_obj.ATTR_GROUP_ID_FLAG ='Y') THEN
        FND_DSQL.Add_Text(', ');
        Add_Bind(p_bind_identifier => 'ATTR_GROUP_ID'
                 ,p_value          => p_attr_group_metadata_obj.ATTR_GROUP_ID);
      END IF;

      -----------------------------------------------------
      -- Add data_level_id only if it has been provided  --
      -----------------------------------------------------
      Debug_Msg(' in insert_row -- p_data_level-'||p_data_level);
      IF(p_data_level IS NOT NULL
         AND
         FND_API.TO_BOOLEAN(
              EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(p_table_name  => l_b_table_name
                                                           ,p_column_name => 'DATA_LEVEL_ID'
                                                           )
                           )
         ) THEN
        l_data_level_id := Get_Data_Level_Id( p_attr_group_metadata_obj.APPLICATION_ID
                                             ,p_attr_group_metadata_obj.ATTR_GROUP_TYPE
                                             ,p_data_level);
        FND_DSQL.Add_Text(', ');
        Add_Bind(p_bind_identifier => 'DATA_LEVEL_ID'
                ,p_value           => l_data_level_id);
      Debug_Msg(' in insert_row -- l_data_level_id-'||l_data_level_id);
      END IF;


      FND_DSQL.Add_Text(', ');
Debug_Msg(l_api_name || ' calling  EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols for PK 2 ');
      l_pk_col_values := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                     p_ext_table_metadata_obj.pk_column_metadata
                                                    ,p_pk_column_name_value_pairs
                                                    ,'VALUES'
                                                    ,TRUE
                                                   );
Debug_Msg(l_api_name || ' calling  EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols for CC 2 ');
      l_cc_col_values := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                     p_ext_table_metadata_obj.class_code_metadata
                                                    ,p_class_code_name_value_pairs
                                                    ,'VALUES'
                                                    ,TRUE
                                                    ,', '
                                                   );
      --------------------------------------------
      -- NOTE: if inserting into the pending    --
      -- table, we don't insert Data Level info --
      --------------------------------------------
      IF (p_data_level_name_value_pairs IS NOT NULL AND
          p_data_level_name_value_pairs.COUNT > 0 AND
          p_change_obj IS NULL) THEN
Debug_Msg(l_api_name || ' calling  EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols for DL 2 ');
        l_dl_col_values := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                       l_dl_col_mdata_array
                                                      ,p_data_level_name_value_pairs
                                                      ,'VALUES'
                                                      ,TRUE
                                                      ,', '
                                                     );
      END IF;

      FND_DSQL.Add_Text(', '||l_change_col_values|| l_extra_col_values);

      Add_Attr_Info_To_Statement(p_attr_group_metadata_obj.attr_metadata_table
                                ,p_attr_name_value_pairs
                                ,', '
                                ,l_default_values_or_not
                                ,'NONTRANS');

      ----------------------------------------------------------------------
      -- (No need to add a comma here, because Add_Attr_Info_To_Statement --
      -- adds a trailing separator to the list if it adds anything to it) --
      ----------------------------------------------------------------------

      -- Bug 10097738 : Start
      IF (p_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y' AND FND_API.TO_BOOLEAN(l_column_exists)) THEN
        FND_DSQL.Add_Bind(l_new_extension_id);    -- inserting the ext id value in UNIQUE_VALUE column for MR UDAs
        FND_DSQL.Add_Text(', ');
      END IF;
      -- Bug 10097738 : End

      Add_Bind(p_bind_identifier => 'CREATED_BY'
              ,p_value           => l_current_user_id);
      FND_DSQL.Add_Text(', ');
      --Added by geguo for 9373845
      SELECT NVL(G_WHO_CREATION_DATE, SYSDATE),
             NVL(G_WHO_LAST_UPDATE_DATE, SYSDATE)
        INTO G_WHO_CREATION_DATE, G_WHO_LAST_UPDATE_DATE
        FROM DUAL;

      Add_Bind(p_bind_identifier => 'CREATION_DATE'
              ,p_value           => G_WHO_CREATION_DATE);
      FND_DSQL.Add_Text(', ');
      Add_Bind(p_bind_identifier => 'LAST_UPDATED_BY'
              ,p_value           => l_current_user_id);
      FND_DSQL.Add_Text(', ');

      --Added by geguo for 9373845
      Add_Bind(p_bind_identifier => 'LAST_UPDATE_DATE'
              ,p_value           => G_WHO_LAST_UPDATE_DATE);
      FND_DSQL.Add_Text(', ');
      Add_Bind(p_bind_identifier => 'LAST_UPDATE_LOGIN'
              ,p_value           => l_current_login_id);
      FND_DSQL.Add_Text(')');

      l_dynamic_sql := FND_DSQL.Get_Text(FALSE);

      Debug_Msg('In Insert_Row, l_dynamic_sql for base table is as follows:', 3);
      Debug_Msg(l_dynamic_sql,3);
      Debug_SQL(FND_DSQL.Get_Text(TRUE));
      Set_Binds_And_Dml(l_dynamic_sql,'B');

      ---------------------------------------------------------------------
      -- Next we parse the statement, bind our variables, and execute it --
      ---------------------------------------------------------------------

      IF (p_execute_dml = FND_API.G_TRUE) THEN
        DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.Native);
        FND_DSQL.Set_Cursor(l_cursor_id);
        FND_DSQL.Do_Binds();
      END IF;

      --
      -- Bug 12603968. Resetting the global variables.
      -- See bugdb for details.
      -- sreharih. Tue May 31 14:54:01 PDT 2011.
      --
      G_WHO_CREATION_DATE := NULL;
      G_WHO_LAST_UPDATE_DATE := NULL;
      --Bug 12603968 End

      --Start 4105841 Raise pre event
      IF (p_change_obj IS  NULL) THEN
        IF(p_raise_business_event) THEN
          Raise_WF_Event_If_Enabled(
                p_dml_type                      => 'CREATE'
               ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
               ,p_extension_id                  => l_new_extension_id
               ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
               ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
               ,p_entity_id                     => p_entity_id
               ,p_entity_index                  => p_entity_index
               ,p_entity_code                   => p_entity_code
               ,p_pre_event_flag                => 'T'
               ,p_data_level_id                 => l_data_level_id
               ,px_attr_diffs                   => l_attr_diffs_event
              );
          l_pre_raise_flag := 'T';
        END IF;
      END IF;
      --End 4105841

      IF (p_execute_dml = FND_API.G_TRUE) THEN
        l_number_of_rows := DBMS_SQL.Execute(l_cursor_id);
      END IF;

    END IF;


    ----------------------------------------------------------------
    -- Now we do basically the same thing except for the TL table --
    -- NOTE: again, we insert into the TL table regardless of     --
    -- whether there are any translatable Attr values so that the --
    -- VL doesn't have to outer join                              --
    ----------------------------------------------------------------
    IF (p_attr_group_metadata_obj.EXT_TABLE_TL_NAME IS NOT NULL) THEN

      Init();
      -- CM expects extension Id to be the first bind
      -- in the generated DML
      FND_DSQL.Add_Text('INSERT INTO '||l_tl_table_name||
                        ' ('||
                        'EXTENSION_ID, ');

      -----------------------------------------------------
      -- Add attr_group_id only if table has this column --
      -----------------------------------------------------
      IF (p_attr_group_metadata_obj.ATTR_GROUP_ID_FLAG ='Y') THEN
        FND_DSQL.Add_Text('ATTR_GROUP_ID, ');
      END IF;

      -----------------------------------------------------
      -- Add data_level_id only if it has been provided  --
      -----------------------------------------------------
      IF(p_data_level IS NOT NULL
         AND
         FND_API.TO_BOOLEAN(
              EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(p_table_name  => l_tl_table_name
                                                           ,p_column_name => 'DATA_LEVEL_ID'
                                                           )
                           )
         ) THEN
        FND_DSQL.Add_Text('DATA_LEVEL_ID, ');
      END IF;

      l_pk_col_names := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                    p_ext_table_metadata_obj.pk_column_metadata
                                                   ,p_pk_column_name_value_pairs
                                                   ,'NAMES'
                                                   ,TRUE
                                                  );
      l_cc_col_names := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                    p_ext_table_metadata_obj.class_code_metadata
                                                   ,p_class_code_name_value_pairs
                                                   ,'NAMES'
                                                   ,TRUE
                                                   ,', '
                                                  );
      IF (p_data_level_name_value_pairs IS NOT NULL AND
          p_data_level_name_value_pairs.COUNT > 0 AND
          p_change_obj IS NULL) THEN
        l_dl_col_names := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                      l_dl_col_mdata_array
                                                     ,p_data_level_name_value_pairs
                                                     ,'NAMES'
                                                     ,TRUE
                                                     ,', '
                                                    );
      END IF;

      FND_DSQL.Add_Text(', ' || l_change_col_names||l_extra_col_names);

      Add_Attr_Info_To_Statement(p_attr_group_metadata_obj.attr_metadata_table
                                ,p_attr_name_value_pairs
                                ,', '
                                ,l_default_columns_or_not
                                ,'TRANS');

      ----------------------------------------------------------------------
      -- (No need to add a comma here, because Add_Attr_Info_To_Statement --
      -- adds a trailing separator to the list if it adds anything to it) --
      ----------------------------------------------------------------------

      FND_DSQL.Add_Text('CREATED_BY, '||
                        'CREATION_DATE, '||
                        'LAST_UPDATED_BY, '||
                        'LAST_UPDATE_DATE, '||
                        'LAST_UPDATE_LOGIN, '||
                        'SOURCE_LANG, '||
                        'LANGUAGE) '||
                        'SELECT ');

      Add_Bind(p_bind_identifier => 'EXTENSION_ID'
              ,p_value           => l_new_extension_id);

      -----------------------------------------------------
      -- Add attr_group_id only if table has this column --
      -----------------------------------------------------
      IF (p_attr_group_metadata_obj.ATTR_GROUP_ID_FLAG ='Y') THEN
        FND_DSQL.Add_Text(', ');
        Add_Bind(p_bind_identifier => 'ATTR_GROUP_ID'
                ,p_value           => p_attr_group_metadata_obj.ATTR_GROUP_ID);
      END IF;

      -----------------------------------------------------
      -- Add data_level_id only if it has been provided  --
      -----------------------------------------------------
      IF(p_data_level IS NOT NULL
         AND
         FND_API.TO_BOOLEAN(
              EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(p_table_name  => l_tl_table_name
                                                           ,p_column_name => 'DATA_LEVEL_ID'
                                                           )
                           )
         ) THEN
        l_data_level_id := Get_Data_Level_Id( p_attr_group_metadata_obj.APPLICATION_ID
                                             ,p_attr_group_metadata_obj.ATTR_GROUP_TYPE
                                             ,p_data_level);
        FND_DSQL.Add_Text(', ');
        Add_Bind(p_bind_identifier => 'DATA_LEVEL_ID'
                ,p_value           => l_data_level_id);
      END IF;

      FND_DSQL.Add_Text(', ');
      l_pk_col_values := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                     p_ext_table_metadata_obj.pk_column_metadata
                                                    ,p_pk_column_name_value_pairs
                                                    ,'VALUES'
                                                    ,TRUE
                                                   );
      l_cc_col_values := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                     p_ext_table_metadata_obj.class_code_metadata
                                                    ,p_class_code_name_value_pairs
                                                    ,'VALUES'
                                                    ,TRUE
                                                    ,', '
                                                   );
      IF (p_data_level_name_value_pairs IS NOT NULL AND
          p_data_level_name_value_pairs.COUNT > 0 AND
          p_change_obj IS NULL) THEN
        l_dl_col_values := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                                       l_dl_col_mdata_array
                                                      ,p_data_level_name_value_pairs
                                                      ,'VALUES'
                                                      ,TRUE
                                                      ,', '
                                                     );
      END IF;

      FND_DSQL.Add_Text(', '||l_change_col_values||l_extra_col_values);

      Add_Attr_Info_To_Statement(p_attr_group_metadata_obj.attr_metadata_table
                                ,p_attr_name_value_pairs
                                ,', '
                                ,l_default_values_or_not
                                ,'TRANS');

      ----------------------------------------------------------------------
      -- (No need to add a comma here, because Add_Attr_Info_To_Statement --
      -- adds a trailing separator to the list if it adds anything to it) --
      ----------------------------------------------------------------------

      Add_Bind(p_bind_identifier => 'CREATED_BY'
              ,p_value           => l_current_user_id);
      FND_DSQL.Add_Text(', ');
      Add_Bind(p_bind_identifier => 'CREATION_DATE'
              ,p_value           => SYSDATE);
      FND_DSQL.Add_Text(', ');
      Add_Bind(p_bind_identifier => 'LAST_UPDATED_BY'
              ,p_value           => l_current_user_id);
      FND_DSQL.Add_Text(', ');
      Add_Bind(p_bind_identifier => 'LAST_UPDATE_DATE'
              ,p_value           => SYSDATE);
      FND_DSQL.Add_Text(', ');
      Add_Bind(p_bind_identifier => 'LAST_UPDATE_LOGIN'
              ,p_value           => l_current_login_id);
      FND_DSQL.Add_Text(', ');
      Add_Bind(p_bind_identifier => 'SOURCE_LANG'
              ,p_value           => USERENV('LANG'));
      FND_DSQL.Add_Text(', L.LANGUAGE_CODE '||
                        'FROM '||
                        'FND_LANGUAGES L '||
                        'WHERE L.INSTALLED_FLAG IN (''I'', ''B'')');

      -----------------------------------------------------------------
      -- We pass p_language_to_process from Implement_Change_Line so --
      -- that each pending TL row only inserts one production row    --
      -----------------------------------------------------------------
      IF (p_language_to_process IS NOT NULL) THEN
        FND_DSQL.Add_Text(' AND L.LANGUAGE_CODE = ');
        Add_Bind(p_bind_identifier => 'LANGUAGE'
                ,p_value           => p_language_to_process);
      END IF;

      l_dynamic_sql := FND_DSQL.Get_Text(FALSE);

      Set_Binds_And_Dml(l_dynamic_sql,'TL');

      Debug_Msg('In Insert_Row, l_dynamic_sql for TL table is as follows:', 3);
      Debug_SQL(FND_DSQL.Get_Text(TRUE));

      ---------------------------------------------------
      -- We re-use our cursor from the first statement --
      ---------------------------------------------------
      IF (p_execute_dml = FND_API.G_TRUE) THEN
        DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.Native);
        FND_DSQL.Set_Cursor(l_cursor_id);
       FND_DSQL.Do_Binds();
      END IF;

      ---Start 4105841
      --raise the event if it has not been raised

      IF  (p_change_obj IS NULL) AND (l_pre_raise_flag = 'F') THEN
        IF(p_raise_business_event) THEN
          Raise_WF_Event_If_Enabled(
                p_dml_type                      => 'CREATE'
               ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
               ,p_extension_id                  => l_new_extension_id
               ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
               ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
               ,p_entity_id                     => p_entity_id
               ,p_entity_index                  => p_entity_index
               ,p_entity_code                   => p_entity_code
               ,p_pre_event_flag                => 'T'
               ,p_data_level_id                 => l_data_level_id
               ,px_attr_diffs                   => l_attr_diffs_event
               );
          l_pre_raise_flag := 'T';
        END IF;
      END IF;
      --End 4105841

      IF (p_execute_dml = FND_API.G_TRUE) THEN
        l_number_of_rows := DBMS_SQL.Execute(l_cursor_id);
      END IF;

    END IF;

    ----------------------------------
    -- Finally, we close our cursor --
    ----------------------------------
    DBMS_SQL.Close_Cursor(l_cursor_id);

    IF (l_propagate_hierarchy
        AND p_attr_group_metadata_obj.HIERARCHY_PROPAGATE_FLAG = 'Y'
        AND px_attr_diffs.COUNT > 0 AND p_execute_dml = FND_API.G_TRUE) THEN --Bug fix 5220020
      Propagate_Attributes( p_pk_column_name_value_pairs
                          , p_class_code_name_value_pairs
                          , p_data_level_name_value_pairs
                          , px_attr_diffs
                          , G_CREATE_MODE
                          , p_attr_group_metadata_obj
                          , x_return_status
                          , l_error_message);
    END IF;
    IF (x_return_status IN (G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR )) THEN
      fnd_message.set_name('EGO','EGO_GENERIC_MSG_TEXT');
      fnd_message.set_token('MESSAGE',l_error_message);
      fnd_msg_pub.Add;
      RETURN;
    END IF;

    --------------------------------------------------
    -- If we inserted into the production tables... --
    -- we see about raising a Business Event      --
    --------------------------------------------------
    IF (p_change_obj IS NULL) THEN
      IF(p_raise_business_event) THEN
      Raise_WF_Event_If_Enabled(
        p_dml_type                      => 'CREATE'
       ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
       ,p_extension_id                  => l_new_extension_id
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_data_level_id                 => l_data_level_id
       ,px_attr_diffs                   => l_attr_diffs_event
      );
      END IF;
    END IF;

    x_extension_id := l_new_extension_id;

    Debug_Msg('In Insert_Row, done', 1);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    -----------------------------------------------------------
    -- There are no expected errors in this procedure, so... --
    -----------------------------------------------------------
    --Start 4105841
    --Checking for Exception raised by preAttribute Change Event
    --don't put to the stack already added in EGO_WF_WRAPPER_PVT
    WHEN EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC THEN
      Debug_Msg('Insert_Row EXCEPTION  EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC ');
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO insert_row;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --End 4105841

    WHEN OTHERS THEN

      Debug_Msg('Insert_Row EXCEPTION  others '||SQLERRM);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO insert_row;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_PLSQL_ERR'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => G_USER_ROW_IDENTIFIER
         ,p_entity_id         => p_entity_id
         ,p_entity_index      => p_entity_index
         ,p_entity_code       => p_entity_code
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );
      END;

END Insert_Row;

----------------------------------------------------------------------

PROCEDURE Update_Row (
        p_api_version                   IN   NUMBER
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_language_to_process           IN   VARCHAR2
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ
       ,p_extra_attr_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_extra_pk_col_name_val_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2
       ,p_pending_tl_table_name         IN   VARCHAR2
       ,p_execute_dml                   IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_commit                        IN   VARCHAR2
       ,p_bulkload_flag                 IN   BOOLEAN    DEFAULT FALSE
       ,px_attr_diffs                   IN OUT NOCOPY EGO_USER_ATTR_DIFF_TABLE
       ,p_raise_business_event          IN   BOOLEAN DEFAULT TRUE
       ,x_return_status                 OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Row';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_b_table_name           VARCHAR2(30);
    l_tl_table_name          VARCHAR2(30);
    l_which_attrs_to_update  VARCHAR2(10);
    l_attr_value_string      VARCHAR2(10000);
    l_change_col_where_string VARCHAR2(100);
    l_change_col_value_string VARCHAR2(50);
    l_extra_col_value_string VARCHAR2(10000);
    l_extra_col_where_string VARCHAR2(10000);
    l_dynamic_sql            VARCHAR2(32767); --the largest a VARCHAR2 can be
    l_cursor_id              NUMBER;
    l_number_of_rows         NUMBER;

    l_event_name             VARCHAR2(240);
    l_is_event_enabled_flag  VARCHAR2(1);
    l_event_key              VARCHAR2(240);
    l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_parameter_t            WF_PARAMETER_T:= WF_PARAMETER_T(null, null);
    l_error_message          VARCHAR2(4000);
    l_propagate_hierarchy    BOOLEAN := TRUE;
    --Start 4105841
    l_attr_diffs_event       EGO_USER_ATTR_DIFF_TABLE;
    l_pre_event_flag         VARCHAR2(1);
    --End 4105841
    ctr                      NUMBER;
    l_index                  NUMBER;

    l_current_user_id        NUMBER := FND_GLOBAL.User_Id;
    l_current_login_id       NUMBER := FND_GLOBAL.Login_Id;
    --Start Bug 5211171
     l_col_value             VARCHAR2(1000);
     l_col_name              VARCHAR2(1000);
     l_col_values_index      NUMBER;
    --End Bug 5211171
    l_data_level_id          NUMBER;

  BEGIN

    Debug_Msg('In Update_Row, starting', 1);

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT update_row;
    END IF;

    l_pre_event_flag := 'F';
    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_bulkload_flag) THEN
      l_propagate_hierarchy := FALSE;
    END IF;

    -----------------------------------------------------------------------------------
    -- In case the extra columns are passed to be updated we push them into the dml
    -----------------------------------------------------------------------------------
    l_extra_col_value_string := null;
    ctr := 0;
    IF (p_extra_attr_name_value_pairs IS NOT NULL AND
        p_extra_attr_name_value_pairs.COUNT > 0) THEN

      l_index := p_extra_attr_name_value_pairs.FIRST;
      WHILE (l_index IS NOT NULL)
      LOOP
        IF (p_extra_attr_name_value_pairs(l_index).NAME IS NOT NULL) THEN
           ctr := ctr+1;
           IF ( ctr >1 ) THEN
             l_extra_col_value_string := l_extra_col_value_string||' , ';
           END IF;
           IF (p_extra_attr_name_value_pairs(l_index).VALUE IS NOT NULL) THEN
              l_extra_col_value_string := l_extra_col_value_string || p_extra_attr_name_value_pairs(l_index).NAME || ' = '
                                                                   ||  p_extra_attr_name_value_pairs(l_index).VALUE ;
           ELSE
              l_extra_col_value_string := l_extra_col_value_string || p_extra_attr_name_value_pairs(l_index).NAME || ' =  NULL ';
           END IF;
        END IF;
        l_index := p_extra_attr_name_value_pairs.NEXT(l_index);
      END LOOP;

    END IF;

    ------------------------------------------------------------------------------------------
    -- In case the extra pk columns values are passed we add them into the dml where clause
    ------------------------------------------------------------------------------------------

    l_extra_col_where_string := ' ';

    IF (p_extra_pk_col_name_val_pairs IS NOT NULL AND
        p_extra_pk_col_name_val_pairs.COUNT > 0) THEN

      l_index := p_extra_pk_col_name_val_pairs.FIRST;
      WHILE (l_index IS NOT NULL)
      LOOP

        IF (p_extra_pk_col_name_val_pairs(l_index).NAME IS NOT NULL) THEN
           l_extra_col_where_string := l_extra_col_where_string || ' AND ';
           IF (p_extra_pk_col_name_val_pairs(l_index).VALUE IS NOT NULL) THEN
              l_extra_col_where_string := l_extra_col_where_string || p_extra_pk_col_name_val_pairs(l_index).NAME || ' = '
                                                                   ||  p_extra_pk_col_name_val_pairs(l_index).VALUE ;
           ELSE
              l_extra_col_where_string := l_extra_col_where_string || p_extra_pk_col_name_val_pairs(l_index).NAME || ' IS  NULL ';
           END IF;
        END IF;
        l_index := p_extra_pk_col_name_val_pairs.NEXT(l_index);

      END LOOP;

    END IF;

   --------------------------------------------------------------------------
    -- Determine whether we're in Change mode and set variables accordingly --
    --------------------------------------------------------------------------
    IF (p_change_obj IS NOT NULL AND
        p_pending_b_table_name IS NOT NULL AND
        p_pending_tl_table_name IS NOT NULL) THEN

      l_b_table_name := p_pending_b_table_name;
      l_tl_table_name := p_pending_tl_table_name;
      IF (p_change_obj.CHANGE_ID IS NOT NULL) THEN
        l_change_col_where_string := ' AND CHANGE_ID = '||p_change_obj.CHANGE_ID||' AND ';
      ELSE
        l_change_col_where_string := ' AND CHANGE_ID IS NULL AND ';
      END IF;
      IF (p_change_obj.CHANGE_LINE_ID IS NOT NULL) THEN
        l_change_col_where_string := l_change_col_where_string||
                                     'CHANGE_LINE_ID = '||
                                     p_change_obj.CHANGE_LINE_ID||' ';
      ELSE
        l_change_col_where_string := l_change_col_where_string||
                                     'CHANGE_LINE_ID IS NULL ';
      END IF;

      -------------------------
      -- Update the ACD Type --
      -------------------------
      l_change_col_value_string := 'ACD_TYPE = '''||
                                   NVL(p_change_obj.ACD_TYPE, 'NULL')||''', ';
    ELSE

      l_b_table_name := p_attr_group_metadata_obj.EXT_TABLE_B_NAME;
      l_tl_table_name := p_attr_group_metadata_obj.EXT_TABLE_TL_NAME;
      l_change_col_where_string := '';
      l_change_col_value_string := '';

    END IF;

    -------------------------------------------------------------------------------
    -- In case the p_pending_b_table_name and p_pending_tl_table_name are passed
    -- we will use them.
    -------------------------------------------------------------------------------
    IF (p_pending_b_table_name IS NOT NULL) THEN
        l_b_table_name := p_pending_b_table_name;
        l_tl_table_name := p_pending_tl_table_name;
    END IF;

     -- Start 4105841
     Get_Changed_Attributes(
            p_dml_operation                 => 'UPDATE'
          , p_object_name                   =>  null
          , p_pk_column_name_value_pairs    =>  p_pk_column_name_value_pairs
          , p_attr_group_metadata_obj       =>  p_attr_group_metadata_obj
          , p_ext_table_metadata_obj        =>  p_ext_table_metadata_obj
          , p_data_level                    =>  p_data_level
          , p_data_level_name_value_pairs   =>  p_data_level_name_value_pairs
          , p_attr_name_value_pairs         =>  p_attr_name_value_pairs
          , p_extension_id                  =>  p_extension_id
          , p_entity_id                     =>  p_entity_id
          , p_entity_index                  =>  p_entity_index
          , p_entity_code                   =>  p_entity_code
          , px_attr_diffs                   =>  l_attr_diffs_event);
    -- End 4105841
    -- Only propagate if at least one attribute has EIH code = LP/AP
    IF (l_propagate_hierarchy AND
        p_attr_group_metadata_obj.HIERARCHY_PROPAGATE_FLAG = 'Y') THEN
    --4105841 : Removing call to Get_Changed_Attributes as it's called before this check
      px_attr_diffs := l_attr_diffs_event;
    END IF;
    --------------------------------------------------------------
    -- First we open a cursor for use in one or both statements --
    --------------------------------------------------------------
    l_cursor_id := DBMS_SQL.Open_Cursor;

    ------------------------------------------------------------------
    -- We pass p_language_to_process from Implement_Change_Line; if --
    -- we have it, then we only insert if the passed-in language is --
    -- equal to USERENV('LANG').  Otherwise we update the base      --
    -- table if there are any non-translatable Attributes.          --
    ------------------------------------------------------------------
    IF (p_attr_group_metadata_obj.TRANS_ATTRS_COUNT <
        p_attr_group_metadata_obj.attr_metadata_table.COUNT AND
        (p_language_to_process IS NULL OR
         p_language_to_process = USERENV('LANG'))) THEN

      Init();
      FND_DSQL.Add_Text('UPDATE '||l_b_table_name||
                        ' SET '||l_extra_col_value_string||l_change_col_value_string);

      Add_Attr_Info_To_Statement(p_attr_group_metadata_obj.attr_metadata_table
                                ,p_attr_name_value_pairs
                                ,', '
                                ,'EQUALS'
                                ,'NONTRANS');

      ----------------------------------------------------------------------
      -- (No need to add a comma here, because Add_Attr_Info_To_Statement --
      -- adds a trailing separator to the list if it adds anything to it) --
      ----------------------------------------------------------------------

      FND_DSQL.Add_Text('LAST_UPDATED_BY = ');
      Add_Bind(p_bind_identifier => 'LAST_UPDATED_BY'
              ,p_value           => l_current_user_id);
      FND_DSQL.Add_Text(', ');
      FND_DSQL.Add_Text('LAST_UPDATE_DATE = ');
      --Added by geguo for 9373845
      SELECT NVL(G_WHO_LAST_UPDATE_DATE, SYSDATE) INTO G_WHO_LAST_UPDATE_DATE FROM DUAL;
      Add_Bind(p_bind_identifier => 'LAST_UPDATE_DATE'
              ,p_value           => G_WHO_LAST_UPDATE_DATE);
      FND_DSQL.Add_Text(', ');
      FND_DSQL.Add_Text('LAST_UPDATE_LOGIN = ');
      Add_Bind(p_bind_identifier => 'LAST_UPDATE_LOGIN'
              ,p_value           => l_current_login_id);

      FND_DSQL.Add_Text(' WHERE EXTENSION_ID = ');
      Add_Bind(p_bind_identifier => 'EXTENSION_ID'
              ,p_value           => p_extension_id);

      ----------------------------------------------------------------------------
      --We add the data_level_id to the where clause, it would be passed in
      --by the implementing team if the R12C changes for enhanced data level
      --support have been taken up.
      ----------------------------------------------------------------------------
      IF(p_data_level IS NOT NULL
         AND
         FND_API.TO_BOOLEAN(
              EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(p_table_name  => l_b_table_name
                                                           ,p_column_name => 'DATA_LEVEL_ID'
                                                           )
                           )
         ) THEN

        l_data_level_id := Get_Data_Level_Id( p_attr_group_metadata_obj.APPLICATION_ID
                                             ,p_attr_group_metadata_obj.ATTR_GROUP_TYPE
                                             ,p_data_level);

      FND_DSQL.Add_Text(' AND DATA_LEVEL_ID = ');
      Add_Bind(p_bind_identifier => 'DATA_LEVEL_ID'
              ,p_value           => l_data_level_id);

      END IF;

      --Start Bug 5211171
      IF (p_data_level_name_value_pairs IS NOT NULL
         AND p_data_level_name_value_pairs.COUNT <> 0
         AND p_data_level_name_value_pairs(p_data_level_name_value_pairs.FIRST).VALUE IS NOT NULL) THEN
           l_col_values_index := p_data_level_name_value_pairs.FIRST;
           WHILE (l_col_values_index <= p_data_level_name_value_pairs.LAST)
           LOOP

             l_col_name := p_data_level_name_value_pairs(l_col_values_index).NAME;
             l_col_value := p_data_level_name_value_pairs(l_col_values_index).VALUE;
             IF (l_col_value is not NULL) THEN
               FND_DSQL.Add_Text(' AND '||l_col_name||' = ');
               Add_Bind(p_bind_identifier => l_col_name
                       ,p_value           => l_col_value);
             END IF;
             l_col_values_index := p_data_level_name_value_pairs.NEXT(l_col_values_index);
           END LOOP;
      END IF;--p_data_level_name_value_pairs IS NOT NULL
      --End Bug 5211171

      FND_DSQL.Add_Text(l_change_col_where_string);
      FND_DSQL.Add_Text(l_extra_col_where_string);



      l_dynamic_sql := FND_DSQL.Get_Text(FALSE);

      Debug_Msg('In Update_Row, l_dynamic_sql for base table is as follows:', 3);
      Debug_Msg('In Update_Row, l_dynamic_sql:'||l_dynamic_sql, 3);
      Debug_SQL(FND_DSQL.Get_Text(TRUE));
      Set_Binds_And_Dml(l_dynamic_sql ,'B');

      IF (p_execute_dml = FND_API.G_TRUE) THEN
        DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.Native);
        FND_DSQL.Set_Cursor(l_cursor_id);
        FND_DSQL.Do_Binds();
      END IF;

      --
      -- Bug 12603968. Resetting the global variables.
      -- See bugdb for details.
      -- sreharih. Tue May 31 14:54:01 PDT 2011.
      --
      G_WHO_CREATION_DATE := NULL;
      G_WHO_LAST_UPDATE_DATE := NULL;
      --Bug 12603968 End

      --Start 4105841 Raise Pre Event
      IF (p_change_obj IS NULL) THEN
        IF(p_raise_business_event) THEN
        Raise_WF_Event_If_Enabled(
            p_dml_type                      => 'UPDATE'
           ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
           ,p_extension_id                  => p_extension_id
           ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
           ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
           ,p_entity_id                     => p_entity_id
           ,p_entity_index                  => p_entity_index
           ,p_entity_code                   => p_entity_code
           ,p_pre_event_flag                => 'T'
           ,p_data_level_id                 => l_data_level_id
           ,px_attr_diffs                   => l_attr_diffs_event
          );
        l_pre_event_flag := 'T';
        END IF;
       END IF;
       --End 4105841

      IF (p_execute_dml =  FND_API.G_TRUE) THEN
        l_number_of_rows := DBMS_SQL.Execute(l_cursor_id);
      END IF;

    END IF;

    -------------------------------------------
    -- If there are translatable Attributes, --
    -- we will need to update the TL table   --
    -------------------------------------------
    IF (p_attr_group_metadata_obj.TRANS_ATTRS_COUNT > 0 AND
        p_attr_group_metadata_obj.EXT_TABLE_TL_NAME IS NOT NULL) THEN

      Init();
      FND_DSQL.Add_Text('UPDATE '||l_tl_table_name||
                        ' SET '||l_change_col_value_string);

      Add_Attr_Info_To_Statement(p_attr_group_metadata_obj.attr_metadata_table
                                ,p_attr_name_value_pairs
                                ,', '
                                ,'EQUALS'
                                ,'TRANS');

      ----------------------------------------------------------------------
      -- (No need to add a comma here, because Add_Attr_Info_To_Statement --
      -- adds a trailing separator to the list if it adds anything to it) --
      ----------------------------------------------------------------------

      FND_DSQL.Add_Text('LAST_UPDATED_BY = ');
      Add_Bind(p_bind_identifier => 'LAST_UPDATED_BY'
              ,p_value           => l_current_user_id);
      FND_DSQL.Add_Text(', ');
      FND_DSQL.Add_Text('LAST_UPDATE_DATE = ');
      Add_Bind(p_bind_identifier => 'LAST_UPDATE_DATE'
              ,p_value           => SYSDATE);
      FND_DSQL.Add_Text(', ');
      FND_DSQL.Add_Text('LAST_UPDATE_LOGIN = ');
      Add_Bind(p_bind_identifier => 'LAST_UPDATE_LOGIN'
              ,p_value           => l_current_login_id);
       --Bug 10065435
      FND_DSQL.Add_Text(', ');
      IF (p_language_to_process IS NOT NULL and p_language_to_process <> USERENV('LANG')) THEN
           FND_DSQL.Add_Text('SOURCE_LANG = DECODE(SOURCE_LANG, LANGUAGE,''' || p_language_to_process || ''', SOURCE_LANG)');
      else
        FND_DSQL.Add_Text('SOURCE_LANG = ');
      	Add_Bind(p_bind_identifier => 'SOURCE_LANG'
              ,p_value           => USERENV('LANG'));
      end if;       -- end Bug 10065435

      FND_DSQL.Add_Text(' WHERE EXTENSION_ID = ');
      Add_Bind(p_bind_identifier => 'EXTENSION_ID'
              ,p_value           => p_extension_id);

      ----------------------------------------------------------------------------
      --We add the data_level_id to the where clause, it would be passed in
      --by the implementing team if the R12C changes for enhanced data level
      --support have been taken up.
      ----------------------------------------------------------------------------
      IF(p_data_level IS NOT NULL
         AND
         FND_API.TO_BOOLEAN(
              EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(p_table_name  => l_tl_table_name
                                                           ,p_column_name => 'DATA_LEVEL_ID'
                                                           )
                           )
         ) THEN

        l_data_level_id := Get_Data_Level_Id( p_attr_group_metadata_obj.APPLICATION_ID
                                             ,p_attr_group_metadata_obj.ATTR_GROUP_TYPE
                                             ,p_data_level);

      FND_DSQL.Add_Text(' AND DATA_LEVEL_ID = ');
      Add_Bind(p_bind_identifier => 'DATA_LEVEL_ID'
              ,p_value           => l_data_level_id);

      END IF;


       --Start Bug 5211171
      IF (p_data_level_name_value_pairs IS NOT NULL
         AND p_data_level_name_value_pairs.COUNT <> 0
         AND p_data_level_name_value_pairs(p_data_level_name_value_pairs.FIRST).VALUE IS NOT NULL) THEN
           l_col_values_index := p_data_level_name_value_pairs.FIRST;
           Debug_Msg('In UPDATE_ROW ,p_data_level_name_value_pairs IS NOT NULL');
           WHILE (l_col_values_index <= p_data_level_name_value_pairs.LAST)
           LOOP
             l_col_name := p_data_level_name_value_pairs(l_col_values_index).NAME;
             l_col_value := p_data_level_name_value_pairs(l_col_values_index).VALUE;
             IF (l_col_value is not NULL) THEN
               FND_DSQL.Add_Text(' AND '||l_col_name||' = ');
               Add_Bind(p_bind_identifier => l_col_name
                       ,p_value           => l_col_value);
             END IF;
             l_col_values_index := p_class_code_name_value_pairs.NEXT(l_col_values_index);
           END LOOP;
      END IF;--p_data_level_name_value_pairs IS NOT NULL
      --End Bug 5211171

      FND_DSQL.Add_Text(l_change_col_where_string);
      FND_DSQL.Add_Text(l_extra_col_where_string); -- bug 8349515

      -----------------------------------------------------------------
      -- We pass p_language_to_process from Implement_Change_Line so --
      -- that each pending TL row only updates one production row    --
      -----------------------------------------------------------------
      IF (p_language_to_process IS NOT NULL) THEN
        FND_DSQL.Add_Text(' AND ((SOURCE_LANG = ');
        Add_Bind(p_bind_identifier => 'SOURCE_LANG'
                ,p_value           => USERENV('LANG'));
        FND_DSQL.Add_Text(' AND LANGUAGE = ');
        Add_Bind(p_bind_identifier => 'LANGUAGE'
                ,p_value           => p_language_to_process);
        FND_DSQL.Add_Text(') OR (SOURCE_LANG <> ');
        Add_Bind(p_bind_identifier => 'SOURCE_LANG'
                ,p_value           => USERENV('LANG'));
        FND_DSQL.Add_Text(' AND LANGUAGE = ');
        Add_Bind(p_bind_identifier => 'LANGUAGE'
                ,p_value           => USERENV('LANG'));
        --added for bug 10065435
        FND_DSQL.Add_Text(') OR (SOURCE_LANG = ');
        Add_Bind(p_bind_identifier => 'SOURCE_LANG'
                ,p_value           => p_language_to_process);
        FND_DSQL.Add_Text(' AND LANGUAGE = ');
        Add_Bind(p_bind_identifier => 'LANGUAGE'
                ,p_value           => p_language_to_process);
        --end for bug 10065435
        FND_DSQL.Add_Text('))');
      ELSE
        ----------------------------------------------------------
        -- In all other flows, we want to update all rows whose --
        -- language or source language is the current language  --
        ----------------------------------------------------------
        FND_DSQL.Add_Text(' AND (LANGUAGE = ');
        Add_Bind(p_bind_identifier => 'LANGUAGE'
                ,p_value           => USERENV('LANG'));
        FND_DSQL.Add_Text(' OR SOURCE_LANG = ');
        Add_Bind(p_bind_identifier => 'SOURCE_LANG'
                ,p_value           => USERENV('LANG'));
        FND_DSQL.Add_Text(')');
      END IF;


      l_dynamic_sql := FND_DSQL.Get_Text(FALSE);
      Set_Binds_And_Dml(l_dynamic_sql ,'TL');

      Debug_Msg('In Update_Row, l_dynamic_sql for TL table is as follows:', 3);
      Debug_SQL(FND_DSQL.Get_Text(TRUE));

      IF (p_execute_dml = FND_API.G_TRUE) THEN
        DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.Native);
        FND_DSQL.Set_Cursor(l_cursor_id);
        FND_DSQL.Do_Binds();
      END IF;

      --Start 4105841
      --Raise pre Event if not already raised
      IF (p_change_obj IS NULL) AND (l_pre_event_flag = 'F') THEN
        IF(p_raise_business_event) THEN
        Raise_WF_Event_If_Enabled(
            p_dml_type                      => 'UPDATE'
           ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
           ,p_extension_id                  => p_extension_id
           ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
           ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
           ,p_entity_id                     => p_entity_id
           ,p_entity_index                  => p_entity_index
           ,p_entity_code                   => p_entity_code
           ,p_pre_event_flag                => 'T'
           ,p_data_level_id                 => l_data_level_id
           ,px_attr_diffs                   => l_attr_diffs_event
          );
        l_pre_event_flag := 'T';
        END IF;
      END IF;
      --End 4105841

      IF (p_execute_dml = FND_API.G_TRUE) THEN
        l_number_of_rows := DBMS_SQL.Execute(l_cursor_id);
      END IF;


    END IF;


    ----------------------------------
    -- Finally, we close our cursor --
    ----------------------------------
    DBMS_SQL.Close_Cursor(l_cursor_id);

    --
    -- If caller passes multiple rows with same UK values, what should I do?
    -- Currently, I think they'll be treated as multiple instances of the same row,
    -- so the data for the last-loaded one will overwrite all previous data.
    -- I think that's OK.
    --

    IF (l_propagate_hierarchy
        AND p_attr_group_metadata_obj.HIERARCHY_PROPAGATE_FLAG = 'Y'
        AND px_attr_diffs.COUNT > 0 AND p_execute_dml = FND_API.G_TRUE) THEN --Bug fix 5220020
      Propagate_Attributes( p_pk_column_name_value_pairs
                          , p_class_code_name_value_pairs
                          , p_data_level_name_value_pairs
                          , px_attr_diffs
                          , G_UPDATE_MODE
                          , p_attr_group_metadata_obj
                          , x_return_status
                          , l_error_message);
    END IF;
    IF (x_return_status IN (G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR )) THEN
      fnd_message.set_name('EGO','EGO_GENERIC_MSG_TEXT');
      fnd_message.set_token('MESSAGE',l_error_message);
      fnd_msg_pub.Add;
      RETURN;
    END IF;

    --------------------------------------------------
    -- If we inserted into the production tables... --
    -- we see about raising a Business Event      --
    --------------------------------------------------
    IF (p_change_obj IS NULL) THEN
     IF(p_raise_business_event) THEN
      Raise_WF_Event_If_Enabled(
        p_dml_type                      => 'UPDATE'
       ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
       ,p_extension_id                  => p_extension_id
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_data_level_id                 => l_data_level_id
       ,px_attr_diffs                   => l_attr_diffs_event
      );
      END IF;
    END IF;

    Debug_Msg('In Update_Row, done', 1);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    -----------------------------------------------------------
    -- There are no expected errors in this procedure, so... --
    -----------------------------------------------------------
    --Start 4105841
    --Checking for Exception raised by preAttribute Change Event
    --don't put to the stack already added in EGO_WF_WRAPPER_PVT
    WHEN EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC THEN
      Debug_Msg('Update_Row EXCEPTION  EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC ');

      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO update_row;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --End 4105841

    WHEN OTHERS THEN
      Debug_Msg('Update_Row EXCEPTION  others '||SQLERRM);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO update_row;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_PLSQL_ERR'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => G_USER_ROW_IDENTIFIER
         ,p_entity_id         => p_entity_id
         ,p_entity_index      => p_entity_index
         ,p_entity_code       => p_entity_code
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );
      END;

END Update_Row;

----------------------------------------------------------------------
PROCEDURE Delete_Row (
        p_api_version                   IN   NUMBER
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER
        -- Start ssingal -For Ucc Net Attribute Propagation
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
        -- End ssingal
       ,p_language_to_process           IN   VARCHAR2
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ
       ,p_extra_pk_col_name_val_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2
       ,p_pending_tl_table_name         IN   VARCHAR2
       ,p_execute_dml                   IN   VARCHAR2   DEFAULT FND_API.G_TRUE
        -- Start ssingal -For Ucc Net Attribute Propagation
       ,p_bulkload_flag                 IN   BOOLEAN DEFAULT FALSE
       ,px_attr_diffs                   IN   OUT NOCOPY EGO_USER_ATTR_DIFF_TABLE
        -- End ssingal -For Ucc Net Attribute Propagation
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_commit                        IN   VARCHAR2
       ,p_raise_business_event          IN   BOOLEAN DEFAULT TRUE
       ,x_return_status                 OUT  NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Row';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_b_table_name           VARCHAR2(30);
    l_tl_table_name          VARCHAR2(30);
    l_change_col_where_string VARCHAR2(1000);
    l_dynamic_sql            VARCHAR2(1000);
    l_error_message          VARCHAR2(4000);
    l_event_name             VARCHAR2(240);
    l_is_event_enabled_flag  VARCHAR2(1);
    l_event_key              VARCHAR2(240);
    l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_parameter_t            WF_PARAMETER_T:= WF_PARAMETER_T(null, null);
    -- Start ssingal -For Ucc Net Attribute Propagation
    l_propagate_hierarchy    BOOLEAN :=TRUE;
    -- End ssingal -For Ucc Net Attribute Propagation
    --Start 4105841
    l_attr_diffs_event       EGO_USER_ATTR_DIFF_TABLE;
    l_extra_col_where_string VARCHAR2(1000);
    l_index                  NUMBER;
    l_data_level_id          NUMBER;

  BEGIN

    Debug_Msg('In Delete_Row, starting', 1);

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT delete_row;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_extension_id IS NULL) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Start ssingal -For Ucc Net Attribute Propagation
    IF  p_bulkload_flag THEN
      l_propagate_hierarchy := FALSE;
    END IF;

    --Start 4105841
    Get_Changed_Attributes(
           p_dml_operation                 => 'DELETE'
         , p_object_name                   =>  null
         , p_pk_column_name_value_pairs    =>  p_pk_column_name_value_pairs
         , p_attr_group_metadata_obj       =>  p_attr_group_metadata_obj
         , p_ext_table_metadata_obj        =>  p_ext_table_metadata_obj
         , p_data_level                    =>  p_data_level
         , p_data_level_name_value_pairs   =>  p_data_level_name_value_pairs
         , p_attr_name_value_pairs         =>  p_attr_name_value_pairs
         , p_extension_id                  =>  p_extension_id
         , p_entity_id                     =>  p_entity_id
         , p_entity_index                  =>  p_entity_index
         , p_entity_code                   =>  p_entity_code
         , px_attr_diffs                   =>  l_attr_diffs_event);
    --End 4105841

   IF (l_propagate_hierarchy AND
        p_attr_group_metadata_obj.HIERARCHY_PROPAGATE_FLAG = 'Y'
       ) THEN
    --4105841 : Removing call to Get_Changed_Attributes as it's called before this check
       px_attr_diffs :=  l_attr_diffs_event;
     END IF;

    -- End ssingal -For Ucc Net Attribute Propagation

    --------------------------------------------------------------------------
    -- Determine whether we're in Change mode and set variables accordingly --
    --------------------------------------------------------------------------

    IF (p_change_obj IS NOT NULL AND
        p_pending_b_table_name IS NOT NULL AND
        p_pending_tl_table_name IS NOT NULL) THEN

      l_b_table_name := p_pending_b_table_name;
      l_tl_table_name := p_pending_tl_table_name;
      IF (p_change_obj.CHANGE_ID IS NOT NULL) THEN
        l_change_col_where_string := ' AND CHANGE_ID = '||p_change_obj.CHANGE_ID||' AND ';
      ELSE
        l_change_col_where_string := ' AND CHANGE_ID IS NULL AND ';
      END IF;
      IF (p_change_obj.CHANGE_LINE_ID IS NOT NULL) THEN
        l_change_col_where_string := l_change_col_where_string||
                                     'CHANGE_LINE_ID = '||
                                     p_change_obj.CHANGE_LINE_ID||' ';
      ELSE
        l_change_col_where_string := l_change_col_where_string||
                                     'CHANGE_LINE_ID IS NULL ';
      END IF;
    ELSE

      l_b_table_name := p_attr_group_metadata_obj.EXT_TABLE_B_NAME;
      l_tl_table_name := p_attr_group_metadata_obj.EXT_TABLE_TL_NAME;
      l_change_col_where_string := '';

    END IF;

    ------------------------------------------------------------------------------------------
    -- In case the extra pk columns values are passed we add them into the dml where clause
    ------------------------------------------------------------------------------------------

    l_extra_col_where_string := ' ';

    IF (p_extra_pk_col_name_val_pairs IS NOT NULL AND
        p_extra_pk_col_name_val_pairs.COUNT > 0) THEN

      l_index := p_extra_pk_col_name_val_pairs.FIRST;
      WHILE (l_index IS NOT NULL)
      LOOP

        IF (p_extra_pk_col_name_val_pairs(l_index).NAME IS NOT NULL) THEN
           l_extra_col_where_string := l_extra_col_where_string || ' AND ';
           IF (p_extra_pk_col_name_val_pairs(l_index).VALUE IS NOT NULL) THEN
              l_extra_col_where_string := l_extra_col_where_string || p_extra_pk_col_name_val_pairs(l_index).NAME || ' = '
                                                                   ||  p_extra_pk_col_name_val_pairs(l_index).VALUE ;
           ELSE
              l_extra_col_where_string := l_extra_col_where_string || p_extra_pk_col_name_val_pairs(l_index).NAME || ' IS  NULL ';
           END IF;
        END IF;
        l_index := p_extra_pk_col_name_val_pairs.NEXT(l_index);

      END LOOP;

    END IF;

    -------------------------------------------------------------------------------
    -- In case the p_pending_b_table_name and p_pending_tl_table_name are passed
    -- we will use them.
    -------------------------------------------------------------------------------
    IF (p_pending_b_table_name IS NOT NULL) THEN
        l_b_table_name := p_pending_b_table_name;
        l_tl_table_name := p_pending_tl_table_name;
    END IF;

    l_data_level_id := Get_Data_Level_Id( p_attr_group_metadata_obj.APPLICATION_ID
                                         ,p_attr_group_metadata_obj.ATTR_GROUP_TYPE
                                         ,p_data_level);

    ---------------------------------------------------------------
    -- We pass p_language_to_process from Implement_Change_Line; --
    -- if we have it, then we only delete from the base table if --
    -- the passed-in language is equal to USERENV('LANG') and we --
    -- only delete the TL row for that language.                 --
    -- Otherwise we delete from both tables normally.            --
    ---------------------------------------------------------------
    IF (p_language_to_process IS NULL OR
        p_language_to_process = USERENV('LANG')) THEN
      l_dynamic_sql := 'DELETE FROM '||l_b_table_name||
                       ' WHERE EXTENSION_ID = '||p_extension_id||l_change_col_where_string||l_extra_col_where_string;

      Debug_SQL(l_dynamic_sql);
      --Start 4105841 Raise Pre event
      IF (p_change_obj IS NULL) THEN
       IF(p_raise_business_event) THEN
        Raise_WF_Event_If_Enabled(
          p_dml_type                      => 'DELETE'
         ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
         ,p_extension_id                  => p_extension_id
         ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
         ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
         ,p_entity_id                     => p_entity_id
         ,p_entity_index                  => p_entity_index
         ,p_entity_code                   => p_entity_code
         ,p_pre_event_flag                => 'T'
         ,p_data_level_id                 => l_data_level_id
         ,px_attr_diffs                   => l_attr_diffs_event
        );
        END IF;
      END IF;
      --End 4105841

      Set_Binds_And_Dml(l_dynamic_sql ,'B');

      IF (p_execute_dml = FND_API.G_TRUE) THEN
        EXECUTE IMMEDIATE l_dynamic_sql;
      END IF;
    END IF;

    IF (l_tl_table_name IS NOT NULL) THEN

      l_dynamic_sql := 'DELETE FROM '||l_tl_table_name||
                       ' WHERE EXTENSION_ID = '||p_extension_id||l_change_col_where_string||l_extra_col_where_string;

      -----------------------------------------------------------------
      -- We pass p_language_to_process from Implement_Change_Line so --
      -- that each pending TL row only deletes one production row    --
      -----------------------------------------------------------------
      IF (p_language_to_process IS NOT NULL) THEN
        FND_DSQL.Add_Text(' AND LANGUAGE = ');
        Add_Bind(p_value => p_language_to_process);
      END IF;
    END IF;

    Debug_SQL(l_dynamic_sql);

    Set_Binds_And_Dml(l_dynamic_sql ,'TL');

    IF (p_execute_dml = FND_API.G_TRUE) THEN
      EXECUTE IMMEDIATE l_dynamic_sql;
    END IF;
    -- Start ssingal -For Ucc Net Attribute Propagation

    -- Only propagate if at least one attribute has EIH code = LP/AP
    IF (l_propagate_hierarchy AND
        p_attr_group_metadata_obj.HIERARCHY_PROPAGATE_FLAG = 'Y'
        AND px_attr_diffs.COUNT > 0  AND p_execute_dml = FND_API.G_TRUE) THEN --Bug fix 5220020

      Propagate_Attributes( p_pk_column_name_value_pairs
                          , p_class_code_name_value_pairs
                          , p_data_level_name_value_pairs
                          , px_attr_diffs
                          , G_DELETE_MODE
                          , p_attr_group_metadata_obj
                          , x_return_status
                          , l_error_message);
    END IF;
    -- End ssingal -For Ucc Net Attribute Propagation
    IF (x_return_status IN (G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR )) THEN
      fnd_message.set_name('EGO','EGO_GENERIC_MSG_TEXT');
      fnd_message.set_token('MESSAGE',l_error_message);
      fnd_msg_pub.Add;
      RETURN;
    END IF;

    -------------------------------------------------
    -- If we deleted from the production tables... --
    -- we see about raising a Business Event      --
    -------------------------------------------------
    IF (p_change_obj IS NULL) THEN
      IF(p_raise_business_event) THEN
      Raise_WF_Event_If_Enabled(
        p_dml_type                      => 'DELETE'
       ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
       ,p_extension_id                  => p_extension_id
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_data_level_id                 => l_data_level_id
       ,px_attr_diffs                   => l_attr_diffs_event
      );
      END IF;
    END IF;

    Debug_Msg('In Delete_Row, done', 1);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    -----------------------------------------------------------
    -- There are no expected errors in this procedure, so... --
    -----------------------------------------------------------
    --Start 4105841
    --Checking for Exception raised by preAttribute Change Event
    --don't put to the stack already added in EGO_WF_WRAPPER_PVT
    WHEN EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC THEN
      Debug_Msg('Delete_Row EXCEPTION  EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC ');

      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO delete_row;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --End 4105841
    WHEN OTHERS THEN
      Debug_Msg('Delete_Row EXCEPTION  others '||SQLERRM);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO delete_row;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_PLSQL_ERR'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => G_USER_ROW_IDENTIFIER
         ,p_entity_id         => p_entity_id
         ,p_entity_index      => p_entity_index
         ,p_entity_code       => p_entity_code
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );
      END;

END Delete_Row;

----------------------------------------------------------------------

PROCEDURE Validate_Row_Pvt (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_validate_hierarchy            IN   VARCHAR2   DEFAULT FND_API.G_TRUE --Added for bugFix:5275391
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER
       ,p_mode                          IN   VARCHAR2
       ,p_entity_id                     IN   VARCHAR2   DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,px_attr_name_value_pairs        IN OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Validate_Row_Pvt';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_is_valid_row           BOOLEAN := TRUE;
    l_err_msg_name           VARCHAR2(30);
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_is_duplicate_attr      BOOLEAN;
    l_duplicate_attr_index   NUMBER;
    l_attr_value_index       NUMBER;
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;
    l_attr_name_table        LOCAL_VARCHAR_TABLE;
    l_hierarchy_results      LOCAL_HIERARCHY_REC;

  BEGIN

    Debug_Msg(l_api_name || ' starting', 1);

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Debug_Msg(l_api_name || ' calling Is_Data_Level_Correct ', 1);
    IF (NOT Is_Data_Level_Correct(
              p_object_id                     => p_object_id
             ,p_attr_group_id                 => p_attr_group_metadata_obj.ATTR_GROUP_ID
             ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
             ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
             ,p_data_level                    => p_data_level
             ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
             ,p_attr_group_disp_name          => p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME
             ,x_err_msg_name                  => l_err_msg_name
             ,x_token_table                   => l_token_table)
       ) THEN

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => l_err_msg_name
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );

      l_token_table.DELETE();

      l_is_valid_row := FALSE;

      Debug_Msg(l_api_name || ' l_is_valid_row is now FALSE ', 1);

    END IF;
    Debug_Msg(l_api_name || ' returned Is_Data_Level_Correct ', 1);

IF px_attr_name_value_pairs.COUNT > 0 THEN
    Debug_Msg(l_api_name || ' px_attr_name_value_pairs has values', 1);
ELSE
    Debug_Msg(l_api_name || ' px_attr_name_value_pairs IS NULL!! ', 1);
END IF;
    l_attr_value_index := px_attr_name_value_pairs.FIRST;
    WHILE (l_attr_value_index <= px_attr_name_value_pairs.LAST)
    LOOP

      l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                               p_attr_metadata_table => p_attr_group_metadata_obj.attr_metadata_table
                              ,p_attr_name           => px_attr_name_value_pairs(l_attr_value_index).ATTR_NAME
                             );

      ---------------------------------------------------------------------------
      -- First we check whether we have already processed this Attribute.  The --
      -- caller may have passed multiple values for the same Attribute, which  --
      -- is an error, and we also don't want to spend time validating the same --
      -- Attribute more than once.                                             --
      ---------------------------------------------------------------------------
      l_is_duplicate_attr := FALSE;
      IF (l_attr_name_table.COUNT > 0) THEN
        l_duplicate_attr_index := l_attr_name_table.FIRST;
        WHILE (l_duplicate_attr_index <= l_attr_name_table.LAST)
        LOOP
          EXIT WHEN (l_is_duplicate_attr);
          IF (l_attr_metadata_obj.ATTR_NAME = l_attr_name_table(l_duplicate_attr_index)) THEN
            l_is_duplicate_attr := TRUE;
          END IF;
          l_duplicate_attr_index := l_attr_name_table.NEXT(l_duplicate_attr_index);
        END LOOP;
      END IF;

      IF (l_is_duplicate_attr) THEN

        l_err_msg_name := 'EGO_EF_MULT_VALUES_FOR_ATTR';

        l_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.ATTR_DISP_NAME;
        l_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;

            Debug_Msg(l_api_name ||'Adding '||l_err_msg_name||' to error table for row '||px_attr_name_value_pairs(px_attr_name_value_pairs.FIRST).ROW_IDENTIFIER);

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => l_err_msg_name
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => G_USER_ROW_IDENTIFIER
         ,p_entity_id         => p_entity_id
         ,p_entity_index      => p_entity_index
         ,p_entity_code       => p_entity_code
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );

        l_token_table.DELETE();

        l_is_valid_row := FALSE;

            Debug_Msg(l_api_name ||'l_is_valid_row is now FALSE', 1);

      ELSE

        ----------------------------------------------------------------------
        -- Add the Internal Name for checking against subsequent Attributes --
        ----------------------------------------------------------------------
        l_attr_name_table(l_attr_name_table.COUNT+1) := l_attr_metadata_obj.ATTR_NAME;

        ---------------------------------------------------------------------------
        -- If the Attribute is marked as Required and the mode is G_CREATE_MODE, --
        -- then the user must pass a value for the Attribute                     --
        ---------------------------------------------------------------------------
            Debug_Msg(l_api_name ||' loop '||l_attr_value_index||', checking required flag');

        IF (NOT Is_Required_Flag_Respected(l_attr_metadata_obj
                                          ,p_mode
                                          ,px_attr_name_value_pairs(l_attr_value_index)
                                          ,p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME
                                          ,l_err_msg_name
                                          ,l_token_table)) THEN

          Debug_Msg(l_api_name ||'Adding '||l_err_msg_name||' to error table for row '||px_attr_name_value_pairs(px_attr_name_value_pairs.FIRST).ROW_IDENTIFIER);

          ERROR_HANDLER.Add_Error_Message(
            p_message_name      => l_err_msg_name
           ,p_application_id    => 'EGO'
           ,p_token_tbl         => l_token_table
           ,p_message_type      => FND_API.G_RET_STS_ERROR
           ,p_row_identifier    => G_USER_ROW_IDENTIFIER
           ,p_entity_id         => p_entity_id
           ,p_entity_index      => p_entity_index
           ,p_entity_code       => p_entity_code
           ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
          );

          l_token_table.DELETE();

          l_is_valid_row := FALSE;

          Debug_Msg(l_api_name ||' l_is_valid_row is now FALSE', 1);

        END IF;

        ---------------------------------------------------------------------------
        -- The user must pass a value of the correct data type for the Attribute --
        ---------------------------------------------------------------------------
            Debug_Msg(l_api_name ||' loop '||l_attr_value_index||', checking data type');

        IF (NOT Is_Data_Type_Correct(l_attr_metadata_obj
                                    ,px_attr_name_value_pairs(l_attr_value_index)
                                    ,p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME
                                    ,l_err_msg_name
                                    ,l_token_table)) THEN

          Debug_Msg(l_api_name ||'Adding '||l_err_msg_name||' to error table for row '||px_attr_name_value_pairs(px_attr_name_value_pairs.FIRST).ROW_IDENTIFIER);

          ERROR_HANDLER.Add_Error_Message(
            p_message_name      => l_err_msg_name
           ,p_application_id    => 'EGO'
           ,p_token_tbl         => l_token_table
           ,p_message_type      => FND_API.G_RET_STS_ERROR
           ,p_row_identifier    => G_USER_ROW_IDENTIFIER
           ,p_entity_id         => p_entity_id
           ,p_entity_index      => p_entity_index
           ,p_entity_code       => p_entity_code
           ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
          );

          l_token_table.DELETE();

          l_is_valid_row := FALSE;

          Debug_Msg(l_api_name ||'l_is_valid_row is now FALSE', 1);

        END IF;

        -------------------------------------------------------------------------
        -- Some Attributes have a maximum allowable size; we enforce that here --
        -------------------------------------------------------------------------
            Debug_Msg(l_api_name ||' loop '||l_attr_value_index||', checking max size');

        IF (NOT Is_Max_Size_Respected(l_attr_metadata_obj
                                     ,px_attr_name_value_pairs(l_attr_value_index)
                                     ,p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME
                                     ,l_err_msg_name
                                     ,l_token_table)) THEN

          Debug_Msg(l_api_name ||'Adding '||l_err_msg_name||' to error table for row '||px_attr_name_value_pairs(px_attr_name_value_pairs.FIRST).ROW_IDENTIFIER);

          ERROR_HANDLER.Add_Error_Message(
            p_message_name      => l_err_msg_name
           ,p_application_id    => 'EGO'
           ,p_token_tbl         => l_token_table
           ,p_message_type      => FND_API.G_RET_STS_ERROR
           ,p_row_identifier    => G_USER_ROW_IDENTIFIER
           ,p_entity_id         => p_entity_id
           ,p_entity_index      => p_entity_index
           ,p_entity_code       => p_entity_code
           ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
          );

          l_token_table.DELETE();

          l_is_valid_row := FALSE;

          Debug_Msg(l_api_name ||' l_is_valid_row is now FALSE', 1);

        END IF;

        -------------------------------------------------------------------
        -- If the Attribute has a Unit Of Measure, we need to process it --
        -------------------------------------------------------------------
            Debug_Msg(l_api_name ||' loop '||l_attr_value_index||', processing UOM');

        IF (NOT Is_UOM_Valid(l_attr_metadata_obj
                            ,px_attr_name_value_pairs(l_attr_value_index))) THEN

          l_token_table(1).TOKEN_NAME := 'ATTR_NAME';
          l_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.ATTR_DISP_NAME;

          l_token_table(2).TOKEN_NAME := 'UOM_CLASS';
          l_token_table(2).TOKEN_VALUE := l_attr_metadata_obj.UNIT_OF_MEASURE_CLASS;

          l_err_msg_name := 'EGO_EF_UOM_NOT_IN_UOM_CLASS';

          Debug_Msg(l_api_name ||'Adding '||l_err_msg_name||' to error table for row '||px_attr_name_value_pairs(px_attr_name_value_pairs.FIRST).ROW_IDENTIFIER);

          ERROR_HANDLER.Add_Error_Message(
            p_message_name      => l_err_msg_name
           ,p_application_id    => 'EGO'
           ,p_token_tbl         => l_token_table
           ,p_message_type      => FND_API.G_RET_STS_ERROR
           ,p_row_identifier    => G_USER_ROW_IDENTIFIER
           ,p_entity_id         => p_entity_id
           ,p_entity_index      => p_entity_index
           ,p_entity_code       => p_entity_code
           ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
          );

          l_token_table.DELETE();

          l_is_valid_row := FALSE;

              Debug_Msg(l_api_name ||' l_is_valid_row is now FALSE', 1);

        END IF;

        --------------------------------------------------------------
        -- Finally, we check all user-defined Value Set constraints --
        -- (We log errors in this function itself rather than here) --
        --------------------------------------------------------------
        Debug_Msg(l_api_name ||' loop '||l_attr_value_index||', checking Value Set');

        IF (NOT Is_Value_Set_Respected(l_attr_metadata_obj
                                      ,p_attr_group_metadata_obj
                                      ,p_ext_table_metadata_obj
                                      ,p_pk_column_name_value_pairs
                                      ,p_data_level_name_value_pairs
                                      ,p_entity_id
                                      ,p_entity_index
                                      ,p_entity_code
                                      ,px_attr_name_value_pairs
                                      ,px_attr_name_value_pairs(l_attr_value_index))) THEN

          l_is_valid_row := FALSE;

          Debug_Msg(l_api_name ||' l_is_valid_row is now FALSE', 1);

        END IF;

        -------------------------------------------------------------------------
        -- Check if hierarchy security flags prevent the current changes from
        -- being made.
        -------------------------------------------------------------------------

        IF (FND_API.To_Boolean(p_validate_hierarchy) AND--Added for bugFix:5275391
            NOT (l_attr_metadata_obj.EDIT_IN_HIERARCHY_CODE = 'A' OR
                 l_attr_metadata_obj.EDIT_IN_HIERARCHY_CODE = 'AP')
           ) THEN
          -- Get is_root/is_leaf
          l_hierarchy_results :=
            Get_Hierarchy_For_AG_Type(p_attr_group_metadata_obj.ATTR_GROUP_TYPE
                                     ,p_pk_column_name_value_pairs);

          -- Compare results of hierarchy query to vih/eih modes
          IF (l_attr_metadata_obj.EDIT_IN_HIERARCHY_CODE = 'R' OR
              l_attr_metadata_obj.EDIT_IN_HIERARCHY_CODE = 'RP') THEN

            IF (l_hierarchy_results.IS_ROOT_NODE <> 'Y') THEN

              -- ERROR!  TODO: handle this correctly
              l_err_msg_name := 'HIERARCHY SECURITY VALIDATION';
              Debug_Msg(l_api_name ||'Adding '||l_err_msg_name||' to error table for row '||px_attr_name_value_pairs(px_attr_name_value_pairs.FIRST).ROW_IDENTIFIER);

              ERROR_HANDLER.Add_Error_Message(
                p_message_name      => l_err_msg_name
               ,p_application_id    => 'EGO'
               ,p_token_tbl         => l_token_table
               ,p_message_type      => FND_API.G_RET_STS_ERROR
               ,p_row_identifier    => G_USER_ROW_IDENTIFIER
               ,p_entity_id         => p_entity_id
               ,p_entity_index      => p_entity_index
               ,p_entity_code       => p_entity_code
               ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
              );

              l_token_table.DELETE();
              l_is_valid_row := FALSE;
              Debug_Msg(l_api_name ||' l_is_valid_row is now FALSE', 1);

            END IF;

          ELSIF (l_attr_metadata_obj.EDIT_IN_HIERARCHY_CODE = 'L' OR
                 l_attr_metadata_obj.EDIT_IN_HIERARCHY_CODE = 'LP') THEN

            IF (l_hierarchy_results.IS_LEAF_NODE <> 'Y') THEN

              -- ERROR!  TODO: handle this correctly
              l_err_msg_name := 'HIERARCHY SECURITY VALIDATION';
              Debug_Msg(l_api_name ||'Adding '||l_err_msg_name||' to error table for row '||px_attr_name_value_pairs(px_attr_name_value_pairs.FIRST).ROW_IDENTIFIER);

              ERROR_HANDLER.Add_Error_Message(
                p_message_name      => l_err_msg_name
               ,p_application_id    => 'EGO'
               ,p_token_tbl         => l_token_table
               ,p_message_type      => FND_API.G_RET_STS_ERROR
               ,p_row_identifier    => G_USER_ROW_IDENTIFIER
               ,p_entity_id         => p_entity_id
               ,p_entity_index      => p_entity_index
               ,p_entity_code       => p_entity_code
               ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
              );

              l_token_table.DELETE();

              l_is_valid_row := FALSE;

              Debug_Msg(l_api_name ||' l_is_valid_row is now FALSE', 1);

            END IF;

          END IF;

        END IF;

      END IF;

      l_attr_value_index := px_attr_name_value_pairs.NEXT(l_attr_value_index);
    END LOOP;

    -------------------------------------------------------------------------
    -- Finally, if the mode is 'CREATE', we want to check whether the user --
    -- failed to pass any required Attributes.  If we find a non-passed    --
    -- required Attribute, we check whether it has a default value: if so, --
    -- we build an Attribute data object for it and add it to our list of  --
    -- Attr values, but if not we raise an error for each missing required --
    -- Attribute (these errors are logged in the function itself).         --
    -------------------------------------------------------------------------
    IF (p_mode = G_CREATE_MODE AND
        NOT Verify_All_Required_Attrs(l_attr_name_table
                                     ,p_attr_group_metadata_obj.attr_metadata_table
                                     ,p_entity_id
                                     ,p_entity_index
                                     ,p_entity_code
                                     ,p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME
                                     ,px_attr_name_value_pairs)) THEN

      l_is_valid_row := FALSE;

      Debug_Msg(l_api_name ||' l_is_valid_row is now FALSE', 1);

    END IF;

    Debug_Msg(l_api_name ||' done', 1);

    IF (NOT l_is_valid_row) THEN

      RAISE FND_API.G_EXC_ERROR;

    END IF;

-----------------------------------

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg(l_api_name ||' EXCEPTION FND_API.G_EXC_ERROR  raised ', 1);
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      Debug_Msg(l_api_name ||' EXCEPTION OTHERS  raised '||SQLERRM, 1);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      l_token_table.DELETE();
      l_token_table(1).TOKEN_NAME := 'PKG_NAME';
      l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
      l_token_table(2).TOKEN_NAME := 'API_NAME';
      l_token_table(2).TOKEN_VALUE := l_api_name;
      l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
      l_token_table(3).TOKEN_VALUE := SQLERRM;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => 'EGO_PLSQL_ERR'
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );

END Validate_Row_Pvt;

----------------------------------------------------------------------

PROCEDURE Perform_DML_On_Row_Pvt (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_language_to_process           IN   VARCHAR2   DEFAULT NULL
       ,p_mode                          IN   VARCHAR2
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_extra_pk_col_name_val_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_extra_attr_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT NULL
       ,p_execute_dml                   IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_entity_id                     IN   VARCHAR2   DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_commit                        IN   VARCHAR2
       ,p_bulkload_flag                 IN   BOOLEAN    DEFAULT FALSE
       ,p_raise_business_event          IN   BOOLEAN    DEFAULT TRUE
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Perform_DML_On_Row_Pvt';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;
    l_attr_diffs             EGO_USER_ATTR_DIFF_TABLE := EGO_USER_ATTR_DIFF_TABLE();

  BEGIN

    Debug_Msg(l_api_name || ' starting with p_data_level '||p_data_level, 1);

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Perform_DML_On_Row_PVT;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_mode = G_CREATE_MODE) THEN
      Insert_Row(
        p_api_version                   => p_api_version
       ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
       ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => p_extension_id
       ,p_attr_name_value_pairs         => p_attr_name_value_pairs
       ,p_language_to_process           => p_language_to_process
       ,p_change_obj                    => p_change_obj
       ,p_extra_pk_col_name_val_pairs   => p_extra_pk_col_name_val_pairs
       ,p_extra_attr_name_value_pairs   => p_extra_attr_name_value_pairs
       ,p_pending_b_table_name          => p_pending_b_table_name
       ,p_pending_tl_table_name         => p_pending_tl_table_name
       ,p_execute_dml                   => p_execute_dml
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_commit                        => FND_API.G_FALSE
       ,p_bulkload_flag                 => p_bulkload_flag
       ,px_attr_diffs                   => l_attr_diffs
       ,p_raise_business_event          => p_raise_business_event
       ,x_extension_id                  => x_extension_id
       ,x_return_status                 => x_return_status
      );
    ELSIF (p_mode = G_UPDATE_MODE) THEN
      Update_Row(
        p_api_version                   => p_api_version
       ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
       ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => p_extension_id
       ,p_attr_name_value_pairs         => p_attr_name_value_pairs
       ,p_language_to_process           => p_language_to_process
       ,p_change_obj                    => p_change_obj
       ,p_extra_pk_col_name_val_pairs   => p_extra_pk_col_name_val_pairs
       ,p_extra_attr_name_value_pairs   => p_extra_attr_name_value_pairs
       ,p_pending_b_table_name          => p_pending_b_table_name
       ,p_pending_tl_table_name         => p_pending_tl_table_name
       ,p_execute_dml                   => p_execute_dml
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_commit                        => FND_API.G_FALSE
       ,p_bulkload_flag                 => p_bulkload_flag
       ,px_attr_diffs                   => l_attr_diffs
       ,p_raise_business_event          => p_raise_business_event
       ,x_return_status                 => x_return_status
      );
    ELSIF (p_mode = G_DELETE_MODE) THEN -- mode must be G_DELETE_MODE
      Delete_Row(
        p_api_version                   => p_api_version
       ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => p_extension_id
       ,p_attr_name_value_pairs         => p_attr_name_value_pairs
       ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
       ,p_language_to_process           => p_language_to_process
       ,p_change_obj                    => p_change_obj
       ,p_extra_pk_col_name_val_pairs   => p_extra_pk_col_name_val_pairs
       ,p_pending_b_table_name          => p_pending_b_table_name
       ,p_pending_tl_table_name         => p_pending_tl_table_name
       ,p_execute_dml                   => p_execute_dml
       ,p_bulkload_flag                 => p_bulkload_flag
       ,px_attr_diffs                   => l_attr_diffs
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_commit                        => FND_API.G_FALSE
       ,p_raise_business_event          => p_raise_business_event
       ,x_return_status                 => x_return_status
      );
    ELSE
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(x_extension_id IS NULL AND p_extension_id IS NOT NULL ) THEN
       x_extension_id := p_extension_id;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    Debug_Msg( l_api_name || ' ending ', 1);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg( l_api_name || ' EXCEPTION FND_API.G_EXC_ERROR ', 1);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Perform_DML_On_Row_PVT;
      END IF;
      -----------------------------------------------------------
      -- If we get here, then the nested API call (whichever   --
      -- it was) must have failed; that call will have already --
      -- initialized the relevant out parameters.              --
      -----------------------------------------------------------

    WHEN OTHERS THEN
      Debug_Msg( l_api_name || ' EXCEPTION OTHERS '||SQLERRM, 1);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Perform_DML_On_Row_PVT;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_PLSQL_ERR'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => G_USER_ROW_IDENTIFIER
         ,p_entity_id         => p_entity_id
         ,p_entity_index      => p_entity_index
         ,p_entity_code       => p_entity_code
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );
      END;

END Perform_DML_On_Row_Pvt;

----------------------------------------------------------------------
-- private procedure
----------------------------------------------------------------------
PROCEDURE Perform_DML_On_Template_Row (
        p_object_id                     IN   NUMBER
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_commit                        IN   VARCHAR2
       ,px_attr_name_value_pairs        IN OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
) IS

    l_api_name               VARCHAR2(50) := 'Perform_DML_On_Template_Row';
    l_extension_id           NUMBER;
    l_dummy_ext_id           NUMBER;
    l_mode                   VARCHAR2(10);
    l_return_status          VARCHAR2(1);

  BEGIN
    Debug_Msg(l_api_name || ' starting ',1);
    -------------------------------------------------------------------------------
    -- If an Attribute in this Attribute Group has a "Table" Value Set that uses --
    -- bind values, we will have to sort the name/value pairs table so that the  --
    -- upcoming calls to Get_Int_Val_For_Disp_Val all behave as they should      --
    -------------------------------------------------------------------------------
    IF (p_attr_group_metadata_obj.SORT_ATTR_VALUES_FLAG = 'Y') THEN
      Sort_Attr_Values_Table(p_attr_group_metadata_obj
                            ,px_attr_name_value_pairs);
    END IF;

    -----------------------------------------------------------------------
    -- We now make sure we are dealing with only the internal values for --
    -- all Attributes (this is important to do before looking for the    --
    -- extension ID because we may need Unique Key Attribute internal    --
    -- values to perform the extension ID search)                        --
    -----------------------------------------------------------------------
    Debug_Msg(l_api_name || ' calling Generate_Attr_Int_Values ',1);
    Generate_Attr_Int_Values(
      p_attr_group_metadata_obj       => p_attr_group_metadata_obj
     ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
     ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
     ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
     ,px_attr_name_value_pairs        => px_attr_name_value_pairs
     ,x_return_status                 => l_return_status
                            );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --------------------------------------------------
    -- Find out whether we're inserting or updating --
    -- (and check for Unique Key violations)        --
    --------------------------------------------------
    Debug_Msg(l_api_name || ' calling Get_Extension_Id_And_Mode ',1);
    Get_Extension_Id_And_Mode(
      p_attr_group_metadata_obj       => p_attr_group_metadata_obj
     ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
     ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
     ,p_data_level                    => p_data_level
     ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
     ,p_attr_name_value_pairs         => px_attr_name_value_pairs
     ,x_extension_id                  => l_extension_id
     ,x_mode                          => l_mode
     ,x_return_status                 => l_return_status
                             );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    ----------------------------------------------------------------------
    -- Validate the current collection of Attribute values prior to DML --
    ----------------------------------------------------------------------
    Debug_Msg(l_api_name || ' calling Validate_Row_Pvt ',1);
    Validate_Row_Pvt(
      p_api_version                   => 1.0
     ,p_object_id                     => p_object_id
     ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
     ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
     ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
     ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
     ,p_data_level                    => p_data_level
     ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
     ,p_extension_id                  => l_extension_id
     ,p_mode                          => l_mode
     ,px_attr_name_value_pairs        => px_attr_name_value_pairs
     ,x_return_status                 => l_return_status
                    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -----------------------------------------------------
    -- If the row is valid, either insert or update it --
    -----------------------------------------------------
    Debug_Msg(l_api_name || ' calling Perform_DML_On_Row_Pvt ',1);
    Perform_DML_On_Row_Pvt(
      p_api_version                   => 1.0
     ,p_object_id                     => p_object_id
     ,p_attr_group_metadata_obj       => p_attr_group_metadata_obj
     ,p_ext_table_metadata_obj        => p_ext_table_metadata_obj
     ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
     ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
     ,p_data_level                    => p_data_level
     ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
     ,p_extension_id                  => l_extension_id
     ,p_attr_name_value_pairs         => px_attr_name_value_pairs
     ,p_mode                          => l_mode
     ,p_commit                        => p_commit
     ,x_extension_id                  => l_dummy_ext_id
     ,x_return_status                 => l_return_status
                          );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    Debug_Msg(l_api_name || ' ending ',1);

END Perform_DML_On_Template_Row;

----------------------------------------------------------------------

PROCEDURE Perform_Setup_Operations (
        p_object_name                   IN  VARCHAR2
       ,p_attr_group_id                 IN  NUMBER
       ,p_application_id                IN  NUMBER
       ,p_attr_group_type               IN  VARCHAR2
       ,p_attr_group_name               IN  VARCHAR2
       ,p_pk_column_name_value_pairs    IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN  NUMBER
       ,p_entity_id                     IN  VARCHAR2
       ,p_entity_index                  IN  NUMBER
       ,p_entity_code                   IN  VARCHAR2
       ,p_debug_level                   IN  NUMBER     DEFAULT 0
       ,p_add_errors_to_fnd_stack       IN  VARCHAR2
       ,p_use_def_vals_on_insert_flag   IN  BOOLEAN    DEFAULT FALSE
       ,p_init_fnd_msg_list             IN  VARCHAR2
       ,p_mode                          IN  VARCHAR2
       ,p_change_obj                    IN  EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_extra_pk_col_name_val_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_pending_b_table_name          IN  VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN  VARCHAR2   DEFAULT NULL
       ,p_bulkload_flag                 IN  BOOLEAN    DEFAULT FALSE
       ,px_object_id                    IN OUT NOCOPY NUMBER
       ,px_attr_name_value_pairs        IN OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_attr_group_metadata_obj       OUT NOCOPY EGO_ATTR_GROUP_METADATA_OBJ
       ,x_ext_table_metadata_obj        OUT NOCOPY EGO_EXT_TABLE_METADATA_OBJ
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_mode                          OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Perform_Setup_Operations';
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_err_msg_name           VARCHAR2(30);

  BEGIN

    Debug_Msg(l_api_name || ' starting', 2);

    ------------------------------------------------------------------------
    -- We need to record which row number we are processing so we can log --
    -- error messages appropriately.  We need to use a global variable to --
    -- handle the case where p_attr_name_value_pairs is NULL or empty     --
    ------------------------------------------------------------------------
    IF (px_attr_name_value_pairs IS NULL OR px_attr_name_value_pairs.COUNT = 0) THEN
      G_USER_ROW_IDENTIFIER := 1;
    ELSE
      G_USER_ROW_IDENTIFIER := px_attr_name_value_pairs(px_attr_name_value_pairs.FIRST).USER_ROW_IDENTIFIER;
    END IF;

    ---------------------------------------------------------------------------
    -- If G_BULK_PROCESSING_FLAG has not been set to true, then we're coming --
    -- from the UI and we haven't yet set up our Business Object session     --
    ---------------------------------------------------------------------------
    IF (NOT G_BULK_PROCESSING_FLAG) THEN

      Debug_Msg(l_api_name || ' before Set_Up_Business_Object_Session ', 2);
      Set_Up_Business_Object_Session(
          p_bulkload_flag                 => p_bulkload_flag
         ,p_entity_id                     => p_entity_id
         ,p_entity_index                  => p_entity_index
         ,p_entity_code                   => p_entity_code
         ,p_debug_level                   => p_debug_level
         ,p_init_error_handler_flag       => (p_debug_level > 0)
         ,p_object_name                   => p_object_name
         ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
         ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
         ,p_init_fnd_msg_list             => p_init_fnd_msg_list
         ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
         ,p_use_def_vals_on_insert_flag   => p_use_def_vals_on_insert_flag
         ,x_return_status                 => x_return_status
      );
      Debug_Msg(l_api_name || ' done Set_Up_Business_Object_Session: '||x_return_status, 2);
      ----------------------------------------------------------------------
      -- If an error was found, we've already added it to the error stack --
      ----------------------------------------------------------------------
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

        RAISE FND_API.G_EXC_ERROR;

      END IF;
    END IF;

    IF (px_object_id IS NULL) THEN
      px_object_id := Get_Object_Id_From_Name(p_object_name);
    END IF;

    x_attr_group_metadata_obj :=
      EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(p_attr_group_id
                                                       ,p_application_id
                                                       ,p_attr_group_type
                                                       ,p_attr_group_name);
    Debug_Msg(l_api_name || ' before validations:  p_attr_group_id-'||p_attr_group_id||
                            ' p_application_id-'||p_application_id ||
                            ' p_attr_group_type-'||p_attr_group_type||
                            ' p_attr_group_name-'||p_attr_group_name);

    ------------------------------------------------------
    -- We check for the possibility that we didn't find --
    -- the metadata to correctly process this row       --
    ------------------------------------------------------
    IF (x_attr_group_metadata_obj IS NULL) THEN

      IF (p_application_id IS NOT NULL AND
          p_attr_group_type IS NOT NULL AND
          p_attr_group_name IS NOT NULL) THEN

        l_err_msg_name := 'EGO_EF_ATTR_GROUP_PK_NOT_FOUND';

        l_token_table(1).TOKEN_NAME := 'APP_ID';
        l_token_table(1).TOKEN_VALUE := p_application_id;
        l_token_table(2).TOKEN_NAME := 'AG_TYPE';
        l_token_table(2).TOKEN_VALUE := p_attr_group_type;
        l_token_table(3).TOKEN_NAME := 'AG_NAME';
        l_token_table(3).TOKEN_VALUE := p_attr_group_name;

      ELSE

        l_err_msg_name := 'EGO_EF_ATTR_GROUP_ID_NOT_FOUND';

        l_token_table(1).TOKEN_NAME := 'AG_ID';
        l_token_table(1).TOKEN_VALUE := p_attr_group_id;

      END IF;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => l_err_msg_name
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );
     Debug_Msg(l_api_name || 'before raising exception 0 ');
      RAISE FND_API.G_EXC_ERROR;

    ELSIF (NOT Do_All_Attrs_Exist(x_attr_group_metadata_obj
                                 ,px_attr_name_value_pairs
                                 ,p_entity_id
                                 ,p_entity_index
                                 ,p_entity_code)) THEN

      ----------------------------------------------------------------
      -- We've logged an error for every Attr that we couldn't find --
      ----------------------------------------------------------------
     Debug_Msg(l_api_name || 'before raising exception 1 ');
      RAISE FND_API.G_EXC_ERROR;

    END IF;

    x_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(px_object_id);
    IF (x_ext_table_metadata_obj IS NULL) THEN

      l_token_table.DELETE();
      l_token_table(1).TOKEN_NAME := 'OBJECT_NAME';
      l_token_table(1).TOKEN_VALUE := p_object_name;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => 'EGO_EF_EXT_TABLE_METADATA_ERR'
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );
     Debug_Msg(l_api_name || 'before raising exception 2 ');

      RAISE FND_API.G_EXC_ERROR;

    END IF;

    -------------------------------------------------------------------------------
    -- If an Attribute in this Attribute Group has a "Table" Value Set that uses --
    -- bind values, we will have to sort the name/value pairs table so that the  --
    -- upcoming calls to Get_Int_Val_For_Disp_Val all behave as they should      --
    -------------------------------------------------------------------------------
    IF (x_attr_group_metadata_obj.SORT_ATTR_VALUES_FLAG = 'Y') THEN

      Sort_Attr_Values_Table(x_attr_group_metadata_obj
                            ,px_attr_name_value_pairs);

    END IF;
Debug_Msg(l_api_name || 'before Generate_Attr_Int_Values ');
    --------------------------------------------------------------------------------------
    -- We now make sure we are dealing with only the internal values for all Attributes --
    -- (this is important to do before looking for the extension ID because we may need --
    -- Unique Key Attribute internal values to perform the extension ID search)         --
    --------------------------------------------------------------------------------------
    Generate_Attr_Int_Values(
        p_attr_group_metadata_obj      => x_attr_group_metadata_obj
       ,p_ext_table_metadata_obj       => x_ext_table_metadata_obj
       ,p_pk_column_name_value_pairs   => p_pk_column_name_value_pairs
       ,p_data_level_name_value_pairs  => p_data_level_name_value_pairs
       ,p_entity_id                    => p_entity_id
       ,p_entity_index                 => p_entity_index
       ,p_entity_code                  => p_entity_code
       ,px_attr_name_value_pairs       => px_attr_name_value_pairs
       ,x_return_status                => x_return_status);

Debug_Msg(l_api_name || 'done Generate_Attr_Int_Values: '||x_return_status);
    ------------------------------------------------------------
    -- If errors were found in processing the display values, --
    -- we've already added them to the error stack            --
    ------------------------------------------------------------
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --------------------------------------------------------------------
    -- Now we determine whether we're creating, updating or deleting, --
    -- what the Extension ID is in the latter two cases, and whether  --
    -- our data violates any Unique Key constraints                   --
    --------------------------------------------------------------------
    Get_Extension_Id_And_Mode(
      p_attr_group_metadata_obj       => x_attr_group_metadata_obj
     ,p_ext_table_metadata_obj        => x_ext_table_metadata_obj
     ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
     ,p_data_level                    => p_data_level
     ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
     ,p_attr_name_value_pairs         => px_attr_name_value_pairs
     ,p_extension_id                  => p_extension_id
     ,p_mode                          => p_mode
     ,p_change_obj                    => p_change_obj
     ,p_extra_pk_col_name_val_pairs   => p_extra_pk_col_name_val_pairs
     ,p_pending_b_table_name          => p_pending_b_table_name
     ,p_pending_vl_name               => p_pending_vl_name
     ,p_entity_id                     => p_entity_id
     ,p_entity_index                  => p_entity_index
     ,p_entity_code                   => p_entity_code
     ,x_extension_id                  => x_extension_id
     ,x_mode                          => x_mode
     ,x_return_status                 => x_return_status
    );
    -----------------------------------------------------
    -- If errors were found in the previous procedure, --
    -- we've already added them to the error stack     --
    -----------------------------------------------------
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    Debug_Msg(l_api_name || ' after checking, x_mode is '||x_mode);
    IF (UPPER(x_mode) = G_UPDATE_MODE OR UPPER(x_mode) = G_DELETE_MODE) THEN
      Debug_Msg(l_api_name || ' after checking, x_extension_id is '||x_extension_id);
    END IF;

    Debug_Msg(l_api_name || ' done', 2);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg(l_api_name || ' EXCEPTION FND_API.G_EXC_ERROR', 1);
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      Debug_Msg(l_api_name || ' EXCEPTION OTHERS '||SQLERRM, 1);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_token_table.DELETE();
      l_token_table(1).TOKEN_NAME := 'PKG_NAME';
      l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
      l_token_table(2).TOKEN_NAME := 'API_NAME';
      l_token_table(2).TOKEN_VALUE := l_api_name;
      l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
      l_token_table(3).TOKEN_VALUE := SQLERRM;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => 'EGO_PLSQL_ERR'
       ,p_application_id    => 'EGO'
       ,p_token_tbl         => l_token_table
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_row_identifier    => G_USER_ROW_IDENTIFIER
       ,p_entity_id         => p_entity_id
       ,p_entity_index      => p_entity_index
       ,p_entity_code       => p_entity_code
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );

END Perform_Setup_Operations;

----------------------------------------------------------------------



                      -----------------------
                      -- Public Procedures --
                      -----------------------

----------------------------------------------------------------------

PROCEDURE Process_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
       ,p_change_info_table             IN   EGO_USER_ATTR_CHANGE_TABLE DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT  NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT  NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT  NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT  NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT  NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT  NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT  0
       ,p_validate_only                 IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_validate_hierarchy            IN   VARCHAR2   DEFAULT  FND_API.G_TRUE
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_raise_business_event          IN   BOOLEAN    DEFAULT  TRUE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
    l_extension_id           NUMBER;
    l_mode                   VARCHAR2(10);

BEGIN

    Process_User_Attrs_Data
    (
        p_api_version                   => p_api_version
       ,p_object_name                   => p_object_name
       ,p_attributes_row_table          => p_attributes_row_table
       ,p_attributes_data_table         => p_attributes_data_table
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_user_privileges_on_object     => p_user_privileges_on_object
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_debug_level                   => p_debug_level
       ,p_validate_only                 => p_validate_only  --bug 5122295
       ,p_validate_hierarchy            => p_validate_hierarchy
       ,p_init_error_handler            => p_init_error_handler
       ,p_write_to_concurrent_log       => p_write_to_concurrent_log
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_log_errors                    => p_log_errors
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,p_commit                        => p_commit
       ,p_raise_business_event          => p_raise_business_event
       ,x_extension_id                  => l_extension_id
       ,x_mode                          => l_mode
       ,x_failed_row_id_list            => x_failed_row_id_list
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

END;
-------------------------------------------------------------------------------

PROCEDURE Process_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
       ,p_change_info_table             IN   EGO_USER_ATTR_CHANGE_TABLE DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT  NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT  NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT  NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT  NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT  NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT  NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT  0
       ,p_validate_only                 IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_validate_hierarchy            IN   VARCHAR2   DEFAULT  FND_API.G_TRUE
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_raise_business_event          IN   BOOLEAN    DEFAULT  TRUE
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_mode                          OUT NOCOPY VARCHAR2
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Process_User_Attrs_Data';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_default_user_row_id    NUMBER;
    l_sorted_attr_data_table LOCAL_USER_ATTR_DATA_TABLE;
    l_sorted_attr_row_table  LOCAL_USER_ATTR_ROW_TABLE;
    l_sorted_row_table_index NUMBER;
    l_current_row_element    EGO_USER_ATTR_ROW_OBJ;
    l_mode                   VARCHAR2(10);
    l_sorted_data_table_index NUMBER;
    l_got_all_attrs_for_this_row BOOLEAN := FALSE;
    l_current_data_element   EGO_USER_ATTR_DATA_OBJ;
    l_next_row_id            NUMBER;
    l_row_attrs_table        EGO_USER_ATTR_DATA_TABLE;
    l_data_level_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_current_row_change_obj EGO_USER_ATTR_CHANGE_OBJ;
    l_return_status          VARCHAR2(1);
    l_errorcode              NUMBER;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);
    l_data_level_id          NUMBER;
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;

l_dummy_row       EGO_USER_ATTR_ROW_OBJ;
  BEGIN

    Debug_Msg(l_api_name || ' starting', 1);

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --------------------------------------------------------------------------------
    -- Start by dealing with caching, error-handling, and preliminary validations --
    --------------------------------------------------------------------------------
    IF (p_attributes_data_table IS NOT NULL AND
        p_attributes_data_table.COUNT > 0) THEN
      l_default_user_row_id := p_attributes_data_table(p_attributes_data_table.FIRST).USER_ROW_IDENTIFIER;
    ELSE
      l_default_user_row_id := 0;
    END IF;

    Set_Up_Business_Object_Session(
        p_bulkload_flag                 => TRUE
       ,p_user_privileges_on_object     => p_user_privileges_on_object
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_debug_level                   => p_debug_level
       ,p_init_error_handler_flag       => FND_API.To_Boolean(p_init_error_handler)
       ,p_object_name                   => p_object_name
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,p_default_user_row_identifier   => l_default_user_row_id
       ,x_return_status                 => x_return_status
    );

    ----------------------------------------------------------------------
    -- If an error was found, we've already added it to the error stack --
    ----------------------------------------------------------------------
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      --------------------------------------------------
      -- Mark every row in this instance as a failure --
      --------------------------------------------------
      FOR r IN p_attributes_row_table.FIRST .. p_attributes_row_table.LAST
      LOOP

        x_failed_row_id_list := x_failed_row_id_list ||
                                p_attributes_row_table(r).ROW_IDENTIFIER || ',';

      END LOOP;

      ------------------------------------------------------------------
      -- Trim the trailing ',' from x_failed_row_id_list if necessary --
      ------------------------------------------------------------------
      x_failed_row_id_list := RTRIM(x_failed_row_id_list, ',');

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    ---------------------------------------------------------------
    -- If we pass the preliminary tests, we can process the data --
    ---------------------------------------------------------------
    l_sorted_attr_data_table := Build_Sorted_Data_Table(p_attributes_data_table);
    l_sorted_attr_row_table := Build_Sorted_Row_Table(p_attributes_row_table);

    l_sorted_row_table_index := l_sorted_attr_row_table.FIRST;
    WHILE (l_sorted_row_table_index <= l_sorted_attr_row_table.LAST)
    LOOP
Debug_Msg('1 in the loop ');

      ----------------------------------------------
      -- Initialize local variables for each loop --
      ----------------------------------------------
      l_got_all_attrs_for_this_row := FALSE;
      l_return_status := NULL;
      l_errorcode := NULL;
      l_msg_count := 0;
      l_msg_data := NULL;
      l_current_row_element := l_sorted_attr_row_table(l_sorted_row_table_index);
      l_mode := UPPER(l_current_row_element.TRANSACTION_TYPE);

      -----------------------------------------------------------
      -- Either make a new table or clear out the existing one --
      -----------------------------------------------------------
      IF (l_row_attrs_table IS NULL) THEN
        l_row_attrs_table := EGO_USER_ATTR_DATA_TABLE();
      ELSE
        l_row_attrs_table.DELETE();
      END IF;

      --------------------------------------------------------------------------
      -- If it's our first time through, initialize l_sorted_data_table_index --
      -- (for subsequent loops we want it to retain its current value so we   --
      -- can continue to step through the data table bit by bit in each loop) --
      --------------------------------------------------------------------------
      IF (l_sorted_data_table_index IS NULL) THEN
        l_sorted_data_table_index := l_sorted_attr_data_table.FIRST;
      END IF;

      --------------------------------------------------------------------------
      -- Step through the table collecting all Attr Data objects for this row --
      --------------------------------------------------------------------------
      WHILE (l_sorted_data_table_index <= l_sorted_attr_data_table.LAST)
      LOOP
        EXIT WHEN (l_got_all_attrs_for_this_row);

        l_current_data_element := l_sorted_attr_data_table(l_sorted_data_table_index);
        IF (l_current_data_element.ROW_IDENTIFIER = l_current_row_element.ROW_IDENTIFIER) THEN

          ---------------------------------------------------
          -- Add the current Attr Data object to the table --
          ---------------------------------------------------
          l_row_attrs_table.EXTEND();
          l_row_attrs_table(l_row_attrs_table.LAST()) := l_current_data_element;

          ---------------------------------------
          -- Update the index for another loop --
          ---------------------------------------
          l_sorted_data_table_index := l_sorted_attr_data_table.NEXT(l_sorted_data_table_index);

        ELSE

          ------------------------------------------------------------
          -- In this case we don't want to update the index because --
          -- the current index already belongs to the next row      --
          ------------------------------------------------------------
          l_got_all_attrs_for_this_row := TRUE;

        END IF;
      END LOOP;

      ---------------------------------------------------------------
      -- Try to get the change info for this row (if there is any) --
      ---------------------------------------------------------------
      IF (p_change_info_table IS NOT NULL AND
          p_change_info_table.EXISTS(l_current_row_element.ROW_IDENTIFIER)) THEN
        l_current_row_change_obj := p_change_info_table(l_current_row_element.ROW_IDENTIFIER);
      ELSE
        l_current_row_change_obj := NULL;
      END IF;
Debug_Msg('10 AGID-'||l_current_row_element.ATTR_GROUP_ID);
      ---------------------------------------------------------
      -- At this point we have all the Attr Data objects for --
      -- this row, and we'll be ready to call Process_Row as --
      -- soon as we create a Data Level array for the row    --
      ---------------------------------------------------------

      l_data_level_id := Get_Data_Level_Id( l_current_row_element.ATTR_GROUP_APP_ID
                                           ,l_current_row_element.ATTR_GROUP_TYPE
                                           ,l_current_row_element.DATA_LEVEL);
Debug_Msg('11 ');

      l_data_level_name_value_pairs :=
             Build_Data_Level_Array(p_object_name    => p_object_name
                                   ,p_data_level_id  => l_data_level_id
                                   ,p_data_level_1   => l_current_row_element.DATA_LEVEL_1
                                   ,p_data_level_2   => l_current_row_element.DATA_LEVEL_2
                                   ,p_data_level_3   => l_current_row_element.DATA_LEVEL_3
                                   ,p_data_level_4   => l_current_row_element.DATA_LEVEL_4
                                   ,p_data_level_5   => l_current_row_element.DATA_LEVEL_5
                                    );
Debug_Msg('12 ');


    Debug_Msg(l_api_name || ' calling Process_Row ', 1);
Debug_Msg(l_api_name ||  ' l_current_row_element.ATTR_GROUP_ID '||l_current_row_element.ATTR_GROUP_ID);
Debug_Msg(l_api_name ||  ' l_current_row_element.DATA_LEVEL '||l_current_row_element.DATA_LEVEL );
IF l_data_level_name_value_pairs IS NOT NULL THEN
  FOR i IN l_data_level_name_value_pairs.FIRST .. l_data_level_name_value_pairs.LAST
  LOOP
     Debug_Msg(l_api_name || ' NAME: '|| l_data_level_name_value_pairs(i).NAME || ' VALUE: '||l_data_level_name_value_pairs(i).VALUE) ;
  END LOOP;
END IF;
IF l_row_attrs_table IS NOT NULL AND l_row_attrs_table.COUNT > 0 THEN
  FOR i in l_row_attrs_table.FIRST .. l_row_attrs_table.LAST
  LOOP
    Debug_Msg(l_api_name || ' DATA_LEVEL: '|| i);
--    Debug_Msg(l_api_name || ' ATTR_GROUP_NAME: '|| l_row_attrs_table(i).ATTR_GROUP_NAME || ' DATA_LEVEL: '||l_row_attrs_table(i).DATA_LEVEL);
  END LOOP;
END IF;

      Process_Row(
        p_api_version                   => 1.0
       ,p_object_name                   => p_object_name
       ,p_attr_group_id                 => l_current_row_element.ATTR_GROUP_ID
       ,p_application_id                => l_current_row_element.ATTR_GROUP_APP_ID
       ,p_attr_group_type               => l_current_row_element.ATTR_GROUP_TYPE
       ,p_attr_group_name               => l_current_row_element.ATTR_GROUP_NAME
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => l_current_row_element.DATA_LEVEL
       ,p_data_level_name_value_pairs   => l_data_level_name_value_pairs
       ,p_attr_name_value_pairs         => l_row_attrs_table
       ,p_validate_only                 => p_validate_only
       ,p_validate_hierarchy            => p_validate_hierarchy
       ,p_mode                          => l_mode
       ,p_change_obj                    => l_current_row_change_obj
       ,p_pending_b_table_name          => p_pending_b_table_name
       ,p_pending_tl_table_name         => p_pending_tl_table_name
       ,p_pending_vl_name               => p_pending_vl_name
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_raise_business_event          => p_raise_business_event
       ,x_extension_id                  => x_extension_id
       ,x_mode                          => x_mode
       ,x_return_status                 => l_return_status
       ,x_errorcode                     => l_errorcode
       ,x_msg_count                     => l_msg_count
       ,x_msg_data                      => l_msg_data
      );

      Debug_Msg(l_api_name || ' after processing row '||
                l_current_row_element.ROW_IDENTIFIER||' in mode '||l_mode||
                ', l_msg_data is '||l_msg_data||', l_return_status is '||
                l_return_status||' and l_msg_count is '||l_msg_count, 1);

      -------------------------------------------------------
      -- Check whether this row was successfully processed --
      -------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

        ----------------------------------------------------------------------------
        -- Since this row failed, put its ROW_IDENTIFIER into the failed row list --
        ----------------------------------------------------------------------------
        x_failed_row_id_list := x_failed_row_id_list ||
                                l_current_row_element.ROW_IDENTIFIER || ',';

        ------------------------------------------------
        -- We keep x_return_status updated to reflect --
        -- the most serious error we come across      --
        ------------------------------------------------
        IF (x_return_status IS NULL OR
            x_return_status = FND_API.G_RET_STS_SUCCESS OR
            (x_return_status = FND_API.G_RET_STS_ERROR AND
             l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)) THEN

          x_return_status := l_return_status;

        END IF;
      END IF;

      l_sorted_row_table_index := l_sorted_attr_row_table.NEXT(l_sorted_row_table_index);
    END LOOP;

    ------------------------------------------------------------------
    -- Trim the trailing ',' from x_failed_row_id_list if necessary --
    ------------------------------------------------------------------
    x_failed_row_id_list := RTRIM(x_failed_row_id_list, ',');

    x_msg_count := ERROR_HANDLER.Get_Message_Count();

    IF (x_msg_count > 0) THEN

      RAISE FND_API.G_EXC_ERROR;

    END IF;

    Debug_Msg('In Process_User_Attrs_Data, done', 1);

    Close_Business_Object_Session(
      p_init_error_handler_flag     => FND_API.To_Boolean(p_init_error_handler)
     ,p_log_errors                  => FND_API.To_Boolean(p_log_errors)
     ,p_write_to_concurrent_log     => FND_API.To_Boolean(p_write_to_concurrent_log)
    );

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    IF (x_return_status IS NULL) THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

  EXCEPTION

    ----------------------------------------------------------------------------
    -- We do not ROLLBACK in this procedure: standard behavior for Business   --
    -- Objects is for each row being processed to succeed or fail independent --
    -- of the status of other rows, so we let Process_Row ROLLBACK any errors --
    -- it encounters.  If callers want different behavior, they can establish --
    -- a SAVEPOINT prior to calling this procedure and ROLLBACK if we report  --
    -- any errors.                                                            --
    ----------------------------------------------------------------------------
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg(l_api_name || ' EXCEPTION FND_API.G_EXC_ERROR ', 1);

      -----------------------------------------------------------------------------
      -- Since we want to commit all successful rows, we will always call commit --
      -----------------------------------------------------------------------------
      IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;

      --bug 9559993
      x_return_status := FND_API.G_RET_STS_ERROR;

      Close_Business_Object_Session(
        p_init_error_handler_flag     => FND_API.To_Boolean(p_init_error_handler)
       ,p_log_errors                  => FND_API.To_Boolean(p_log_errors)
       ,p_write_to_concurrent_log     => FND_API.To_Boolean(p_write_to_concurrent_log)
      );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

    WHEN OTHERS THEN

      Debug_Msg(l_api_name || ' EXCEPTION OTHERS '||SQLERRM, 1);
      -----------------------------------------------------------------------------
      -- Since we want to commit all successful rows, we will always call commit --
      -----------------------------------------------------------------------------
      IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_PLSQL_ERR'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => G_USER_ROW_IDENTIFIER
         ,p_entity_id         => p_entity_id
         ,p_entity_index      => p_entity_index
         ,p_entity_code       => p_entity_code
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );
      END;

      Close_Business_Object_Session(
        p_init_error_handler_flag     => FND_API.To_Boolean(p_init_error_handler)
       ,p_log_errors                  => FND_API.To_Boolean(p_log_errors)
       ,p_write_to_concurrent_log     => FND_API.To_Boolean(p_write_to_concurrent_log)
      );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

END Process_User_Attrs_Data;



--
-- Bug 1276239. Performance issue in Get_User_Attrs_Data.
-- Added below supporting methods to build the dynamic SQL
-- predicate using fnd_dsql methods.
-- sreharih. Thu Aug 25 12:44:00 PDT 2011
--


--
-- Simple procedure to add AND operator.
--
PROCEDURE add_and IS

BEGIN
 fnd_dsql.add_text(' AND ');
END add_and;


--
-- Add predicate based on column metadata and name value
-- pairs.
-- params
-- p_col_meta_data    - Column metadata array
-- p_nameval_pairs    - Name-Value pair array. Name should be
--                      same as p_col_meta_data.col_name
-- p_add_and          - Pass true if "AND" string must be added
--                      in the begining.
-- x_predicate_added  - Returns true if a predicate is added by
--                      this method.
--
PROCEDURE add_nameval_predicate (
                              p_col_metadata    IN EGO_COL_METADATA_ARRAY,
                              p_nameval_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY,
                              p_add_and         IN BOOLEAN,
                              x_predicate_added OUT NOCOPY boolean) IS

 l_predicate VARCHAR2(32767);
 l_add_and   BOOLEAN := false;

BEGIN

  Debug_msg('add_nameval_predicate: ' || 'Entering method');

  IF p_col_metadata IS NULL OR p_col_metadata.COUNT <= 0 OR
     p_nameval_pairs IS NULL OR p_nameval_pairs.COUNT <= 0 THEN

     Debug_msg('add_nameval_predicate: ' || ' name value pair or col metadata is null. So returning');
     x_predicate_added := FALSE;
     RETURN;
  END IF;

  l_add_and := p_add_and;
  FOR i IN p_col_metadata.FIRST .. p_col_metadata.LAST LOOP
    IF p_col_metadata(i).col_name IS NOT NULL THEN
      Debug_msg('add_nameval_predicate: ' || ' processing ' || p_col_metadata(i).col_name);

      FOR j IN p_nameval_pairs.FIRST .. p_nameval_pairs.LAST LOOP
        IF p_nameval_pairs(j).name = p_col_metadata(i).col_name THEN

           IF l_add_and THEN
             add_and;
           END IF;
          Debug_msg('add_nameval_predicate: ' || ' adding predicate for ' || p_col_metadata(i).col_name || ' value ' || p_nameval_pairs(j).value);

           IF p_nameval_pairs(j).value IS NULL THEN
             l_predicate  := p_col_metadata(i).col_name || ' IS NULL ';
             fnd_dsql.add_text(l_predicate);
           ELSE
             l_predicate  := p_col_metadata(i).col_name || ' = ';
             fnd_dsql.add_text(l_predicate);
             fnd_dsql.add_bind(p_nameval_pairs(j).value);
           END IF;
           x_predicate_added := TRUE;
           l_add_and := TRUE;
        END IF;
      END LOOP;

    END IF;
  END LOOP;
  Debug_msg('add_nameval_predicate: ' || 'Returning');

END add_nameval_predicate;

--
-- 12765239. Incorporating review comment.
-- Added new method to convert data level object
-- to col metadata array.
--
FUNCTION to_col_metadata_array (p_in IN EGO_DATA_LEVEL_METADATA_OBJ)
                                                 RETURN EGO_COL_METADATA_ARRAY IS

 l_out EGO_COL_METADATA_ARRAY;
 l_count NUMBER;
BEGIN
  Debug_msg('to_col_metadata_array : ' || 'Entering');
  l_out := EGO_COL_METADATA_ARRAY();
  l_count := 1;

  -- There is a mismatch in column_type VARCHAR size.
  -- since we dont know what to do with it, its better
  -- to make it raise runtime exception.
  IF p_in IS NOT NULL THEN
    IF p_in.pk_column_name1 IS NOT NULL THEN
      Debug_msg('to_col_metadata_array : ' || 'Adding pk_column_name1 ' || p_in.pk_column_name1 || '-' || p_in.pk_column_type1);
      l_out.EXTEND;
      l_out(l_count) := EGO_COL_METADATA_OBJ(p_in.pk_column_name1,p_in.pk_column_type1);
      l_count := l_count + 1;
    END IF;

    IF p_in.pk_column_name2 IS NOT NULL THEN
      Debug_msg('to_col_metadata_array : ' || 'Adding pk_column_name2 ' || p_in.pk_column_name2 || '-' || p_in.pk_column_type2);
      l_out.EXTEND;
      l_out(l_count)  := EGO_COL_METADATA_OBJ(p_in.pk_column_name2,p_in.pk_column_type2);
      l_count := l_count + 1;
    END IF;

    IF p_in.pk_column_name3 IS NOT NULL THEN
      Debug_msg('to_col_metadata_array : ' || 'Adding pk_column_name3 ' || p_in.pk_column_name3 || '-' || p_in.pk_column_type3);
      l_out.EXTEND;
      l_out(l_count)  := EGO_COL_METADATA_OBJ(p_in.pk_column_name3,p_in.pk_column_type3);
      l_count := l_count + 1;
    END IF;

    IF p_in.pk_column_name4 IS NOT NULL THEN
      Debug_msg('to_col_metadata_array : ' || 'Adding pk_column_name4 ' || p_in.pk_column_name4 || '-' || p_in.pk_column_type4);
      l_out.EXTEND;
      l_out(l_count)  := EGO_COL_METADATA_OBJ(p_in.pk_column_name4,p_in.pk_column_type4);
      l_count := l_count + 1;
    END IF;

    IF p_in.pk_column_name5 IS NOT NULL THEN
      Debug_msg('to_col_metadata_array : ' || 'Adding pk_column_name5 ' || p_in.pk_column_name5 || '-' || p_in.pk_column_type5);
      l_out.EXTEND;
      l_out(l_count)  := EGO_COL_METADATA_OBJ(p_in.pk_column_name5,p_in.pk_column_type5);
      l_count := l_count + 1;
    END IF;

 END IF;
 RETURN l_out;
END to_col_metadata_array;
--
-- Add data level predicate.
-- params
-- p_data_level_id          - Data level ID
-- p_has_data_level_col     - Pass "true" if the table has data level
--                            ID column
-- p_data_level_metadata    - Data level metadata
-- p_data_level_value_pairs - Data level name value pairs.
-- p_add_and                - Pass true if "AND" string must be added
--                            in the begining.
-- x_predicate_added        - Returns true if a predicate is added by
--                            this method.
--
PROCEDURE add_datalevel_predicate (
                              p_data_level_id             IN NUMBER,
                              p_has_data_level_col        IN BOOLEAN,
                              p_ext_data_level_metadata   IN EGO_COL_METADATA_ARRAY,
                              p_data_level_metadata       IN EGO_DATA_LEVEL_METADATA_OBJ,
                              p_data_level_value_pairs    IN EGO_COL_NAME_VALUE_PAIR_ARRAY,
                              p_add_and                   IN BOOLEAN,
                              x_predicate_added           OUT NOCOPY BOOLEAN) IS

 l_ret             BOOLEAN;
 l_predicate_added BOOLEAN;
BEGIN
  Debug_msg('add_datalevel_predicate: ' || 'Entering');

  l_ret := FALSE;
  IF p_data_level_id IS NOT NULL AND p_has_data_level_col THEN
    IF p_add_and THEN
      add_and;
    END IF;
    Debug_msg('add_datalevel_predicate: ' || 'Added data_level_id condition DATA_LEVEL_ID = ' || p_data_level_id);
    fnd_dsql.add_text(' DATA_LEVEL_ID = ');
    fnd_dsql.add_bind(p_data_level_id);
    l_ret := TRUE;
  END IF;

  Debug_msg('add_datalevel_predicate: ' || 'Adding ext table prediacate');
  -- we are passing old data level meta data for backward compatibility.
  -- R12.C onwards we use data level meta data only from ego_data_level_b.
  add_nameval_predicate(p_col_metadata    => p_ext_data_level_metadata,
                        p_nameval_pairs   => p_data_level_value_pairs,
                        p_add_and         => l_ret OR p_add_and,
                        x_predicate_added => l_predicate_added);

  Debug_msg('add_datalevel_predicate: ' || 'Adding data level pkcol predicates ');
  add_nameval_predicate(p_col_metadata    => to_col_metadata_array(p_data_level_metadata),
                        p_nameval_pairs   => p_data_level_value_pairs,
                        p_add_and         => l_ret OR l_predicate_added,
                        x_predicate_added => l_predicate_added);

  Debug_msg('add_datalevel_predicate: ' || 'Returning');
  x_predicate_added := l_ret OR l_predicate_added;

END add_datalevel_predicate;

--
-- Add AG predicate.
-- params
-- p_attr_group_id          - Attribute Group ID.
-- p_add_and                - Pass true if "AND" string must be added
--                            in the begining.
-- x_predicate_added        - Returns true if a predicate is added by
--                            this method.
--

PROCEDURE add_ag_predicate ( p_attr_group_id   IN NUMBER,
                             p_add_and         IN BOOLEAN,
                             x_predicate_added OUT NOCOPY BOOLEAN) IS

BEGIN
    IF p_add_and THEN
     add_and;
    END IF;
    fnd_dsql.add_text(' ATTR_GROUP_ID = ');
    fnd_dsql.add_bind(p_attr_group_id);
    x_predicate_added := TRUE;
END add_ag_predicate;

--
-- Return Attribute Group Defaulting property value.
--
FUNCTION get_ag_defaulting (p_attr_group_id IN NUMBER,
                            p_data_level    IN VARCHAR2) RETURN VARCHAR2 IS

 CURSOR c IS
   SELECT agdl.defaulting
     FROM ego_attr_group_dl agdl,
          ego_data_level_b dl
    WHERE agdl.attr_group_id = p_attr_group_id
      AND agdl.data_level_id = dl.data_level_id
      AND dl.data_level_name = p_data_level;

 l_temp ego_attr_group_dl.defaulting%TYPE;

BEGIN
 OPEN c;
 FETCH c INTO l_temp;
 CLOSE c;

 RETURN l_temp;
END get_ag_defaulting;

--
-- Return style item detail.
--
PROCEDURE get_style_item_details (p_organization_id   IN NUMBER,
                                  p_inventory_item_id IN NUMBER,
                                  x_style_flag        OUT NOCOPY VARCHAR2,
                                  x_style_item_id     OUT NOCOPY NUMBER) IS

 CURSOR c IS
  SELECT msib.style_item_flag, msib.style_item_id
    FROM mtl_system_items_b msib
   WHERE msib.organization_id = p_organization_id
     AND msib.inventory_item_id = p_inventory_item_id;


BEGIN

 OPEN c;
 FETCH c INTO x_style_flag, x_style_item_id;
 CLOSE c;

END get_style_item_details;

--
-- Process primary key col value pair for EGO_ITEMMGMT_GROUP.
--
--
FUNCTION get_itmmgmt_pkcol(p_attr_group_id     IN NUMBER,
                           p_data_level        IN VARCHAR2,
                           p_pkcol_value_pairs IN EGO_COL_NAME_VALUE_PAIR_ARRAY)
                                                      RETURN EGO_COL_NAME_VALUE_PAIR_ARRAY IS

 l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
 l_inventory_item_id          mtl_system_items_b.inventory_item_id%TYPE;
 l_organization_id            mtl_system_items_b.organization_id%TYPE;
 l_style_item_flag            mtl_system_items_b.style_item_flag%TYPE;
 l_style_item_id              mtl_system_items_b.style_item_id%TYPE;
 l_defaulting                 ego_attr_group_dl.defaulting%TYPE;

BEGIN
    Debug_msg('get_itmmgmt_pkcol: ' || ' Entering method');
    l_pk_column_name_value_pairs := p_pkcol_value_pairs;

    IF (l_pk_column_name_value_pairs IS NOT NULL AND
        l_pk_column_name_value_pairs.COUNT > 0) THEN

         FOR i IN l_pk_column_name_value_pairs.FIRST .. l_pk_column_name_value_pairs.LAST LOOP
              IF (l_pk_column_name_value_pairs(i).NAME = 'INVENTORY_ITEM_ID') THEN
                    l_inventory_item_id := l_pk_column_name_value_pairs(i).VALUE;
                    Debug_msg('get_itmmgmt_pkcol: ' || ' l_inventory_item_id =  ' || l_inventory_item_id);
              ELSIF (l_pk_column_name_value_pairs(i).NAME = 'ORGANIZATION_ID') THEN
                     l_organization_id := l_pk_column_name_value_pairs(i).VALUE;
                    Debug_msg('get_itmmgmt_pkcol: ' || ' l_organization_id =  ' || l_organization_id);
              END IF;
         END LOOP;


          -- 'I' for Inheritance, 'D'for defaulting
          l_defaulting := get_ag_defaulting(p_attr_group_id => p_attr_group_id,
                                            p_data_level    => p_data_level);

          Debug_msg('get_itmmgmt_pkcol: ' || ' l_defaulting = ' || l_defaulting);

          --
          -- For Inherited-AG SKUs get the value from parent Style Item
          --

          IF (l_defaulting = 'I') THEN

                   get_style_item_details(p_organization_id   => l_organization_id,
                                          p_inventory_item_id => l_inventory_item_id,
                                          x_style_flag        => l_style_item_flag,
                                          x_style_item_id     => l_style_item_id);

                  Debug_msg('get_itmmgmt_pkcol: ' || ' l_style_item_flag = ' || l_style_item_flag ||
                                                     ' l_style_item_id = '   || l_style_item_id);

                  -- style flag is N for SKUs
                  IF (l_style_item_flag = 'N') THEN

                     l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
                                         (EGO_COL_NAME_VALUE_PAIR_OBJ( 'INVENTORY_ITEM_ID' , to_char(l_style_item_id))
                                          ,EGO_COL_NAME_VALUE_PAIR_OBJ( 'ORGANIZATION_ID' , to_char(l_organization_id))
                                         );

                  END IF; --END IF FOR STYLE_ITEM_FLAG
          END IF; -- defaulting

     END IF; -- null check

     RETURN l_pk_column_name_value_pairs;

END get_itmmgmt_pkcol;

--
-- Add Primary Key predicates.
-- params
-- p_attr_group_type        - Attribute Group Type
-- p_attr_group_id          - Attribute Group ID.
-- p_data_level             - Data level
-- p_pkcol_value_pairs      - Primary key column-value pairs
-- p_pk_column_metadata     - Primary key column metadata.
-- p_add_and                - Pass true if "AND" string must be added
--                            in the begining.
-- x_predicate_added        - Returns true if a predicate is added by
--                            this method.
--

PROCEDURE add_pkcol_predicate (p_attr_group_type    IN VARCHAR2,
                               p_attr_group_id      IN NUMBER,
                               p_data_level         IN VARCHAR2,
                               p_pkcol_value_pairs  IN EGO_COL_NAME_VALUE_PAIR_ARRAY,
                               p_pk_column_metadata IN EGO_COL_METADATA_ARRAY,
                               p_add_and            IN BOOLEAN,
                               x_predicate_added    OUT NOCOPY BOOLEAN) IS

 l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
BEGIN
  l_pk_column_name_value_pairs := p_pkcol_value_pairs;
  IF (p_attr_group_type = 'EGO_ITEMMGMT_GROUP') THEN
       l_pk_column_name_value_pairs :=  get_itmmgmt_pkcol(p_attr_group_id     => p_attr_group_id,
                                                          p_data_level        => p_data_level,
                                                          p_pkcol_value_pairs => l_pk_column_name_value_pairs);
  END IF;

  add_nameval_predicate(p_col_metadata    => p_pk_column_metadata,
                        p_nameval_pairs   => l_pk_column_name_value_pairs,
                        p_add_and         => p_add_and,
                        x_predicate_added => x_predicate_added);

END add_pkcol_predicate;


FUNCTION get_uom_value (p_uom_db_column_name IN VARCHAR2,
                        p_table_name         IN VARCHAR2,
                        p_extension_id       IN NUMBER) RETURN VARCHAR2 IS

    l_dynamic_sql      VARCHAR2(32767);
    l_uom_value        VARCHAR2(30);
    l_cursor_id        NUMBER;
    l_dummy            NUMBER;
BEGIN
    Debug_msg('get_uom_value: ' || 'Entering method');

    fnd_dsql.init();
    fnd_dsql.add_text (' SELECT ' || p_uom_db_column_name ||
                       ' FROM ' || p_table_name  ||
                       ' WHERE EXTENSION_ID = ');
    fnd_dsql.add_bind(p_extension_id);
    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    l_dynamic_sql := fnd_dsql.get_text;

    Debug_msg('get_uom_value: ' || ' Query ' || l_dynamic_sql);

    DBMS_SQL.PARSE(l_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
    fnd_dsql.set_cursor(l_cursor_id);
    fnd_dsql.do_binds;

    dbms_sql.define_column(l_cursor_id, 1, l_uom_value, 3);
    l_dummy := DBMS_SQL.Execute(l_cursor_id);

    Debug_msg('get_uom_value: ' || 'Executed the query');

   WHILE (DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0)
   LOOP
      dbms_sql.column_value(l_cursor_id, 1, l_uom_value);
   END LOOP;

   IF (l_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_cursor_id);
   END IF;

   Debug_msg('uom value = ' || l_uom_value);
   RETURN l_uom_value;

END get_uom_value;

--
-- Bug 1276239. End of new supporting methods.
-- sreharih. Thu Aug 25 12:44:00 PDT 2011
--


--
-- Bug 1276239. Performance issue in Get_User_Attrs_Data.
-- Following changes made.
--  a. Removed redundant code(logic) like
--       i. Usage of DECODE in SELECT. It was required based on old
--          logic when we had only one SQL for all requested AGs.
--          The current logic builds one SQL per AG.
--      ii. We were buidling data level primary key prediactes twice.
--  b. Replaced literal logic with binds. Using FND_DSQL and newly
--     created encapsulated methods.
--  c. Replaced literal logic for UOM value query with binds. Also
--     we are using only EXTENSION_ID predicate for it as other
--     conditions are not necessary.
--
-- sreharih. Thu Aug 25 12:44:00 PDT 2011
--

----------------------------------------------------------------------

PROCEDURE Get_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
       ,x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Get_User_Attrs_Data';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_object_id                   NUMBER;
    l_ext_table_metadata_obj      EGO_EXT_TABLE_METADATA_OBJ;
    l_request_table_index         NUMBER;
    l_curr_ag_request_obj         EGO_ATTR_GROUP_REQUEST_OBJ;
    l_curr_ag_metadata_obj        EGO_ATTR_GROUP_METADATA_OBJ;
    l_can_view_this_attr_group    BOOLEAN;
    l_augmented_data_table        LOCAL_AUGMENTED_DATA_TABLE;
    l_requested_attr_names_table  LOCAL_VARCHAR_TABLE;
    l_attr_list_index             NUMBER;
    l_curr_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;
    l_new_attr_metadata_obj       EGO_ATTR_METADATA_OBJ;
    l_curr_augmented_attr_rec     LOCAL_USER_ATTR_DATA_REC;
    l_curr_aug_table_index        NUMBER;
    l_table_of_low_ind_for_AG_ID  LOCAL_NUMBER_TABLE;
    l_table_of_high_ind_for_AG_ID LOCAL_NUMBER_TABLE;
    l_ag_predicate_list           VARCHAR2(20000);
    l_curr_db_column_name         VARCHAR2(30);
    l_to_char_db_col_expression   VARCHAR2(90);
    l_db_column_list              VARCHAR2(32767);
    l_db_column_tables_index      NUMBER;
    l_db_column_name_table        LOCAL_VARCHAR_TABLE;
    l_db_column_query_table       LOCAL_BIG_VARCHAR_TABLE;
    l_start_index                 NUMBER;
    l_substring_length            NUMBER;
    l_temp_db_query_string        VARCHAR2(32767);
    l_int_to_disp_val_string      VARCHAR2(32767);
    l_data_level_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_pk_col_string               VARCHAR2(1000);
    l_data_level_string           VARCHAR2(1000);
    l_dynamic_sql                 VARCHAR2(32767);
    l_cursor_id                   NUMBER;
    l_dummy                       NUMBER;
    l_varchar_example             VARCHAR2(1000);
    l_number_example              NUMBER;
    l_date_example                DATE;
    l_curr_AG_ID                  NUMBER;
    l_low_aug_tab_ind_for_AG_ID   NUMBER;
    l_high_aug_tab_ind_for_AG_ID  NUMBER;
    l_need_to_build_a_row_obj     BOOLEAN := TRUE;
    l_extension_id                NUMBER;
    --ENHR12:added for passing the internal value of an
    --attribute along with the display value.
    l_dbcol_cntr                  NUMBER:=0;
    l_char_value                  VARCHAR2(100);
    --bug 5494760
    l_has_attrs                   VARCHAR2(1) :='N';
    l_curr_ag_vl_name             VARCHAR2(30);
    l_curr_ag_table_name          VARCHAR2(30);

l_token_table               ERROR_HANDLER.Token_Tbl_Type;
l_curr_data_level_metadata  EGO_DATA_LEVEL_METADATA_OBJ;
l_curr_data_level_row_obj   EGO_DATA_LEVEL_ROW_OBJ;
l_has_data_level_col            BOOLEAN  := FALSE;    -- TRUE is for R12C
l_dl_view_privilege  fnd_form_functions.function_name%TYPE;

    --bug 8218727
    l_dynamic_sql2                 VARCHAR2(32767);
    l_uom_value                    VARCHAR2(3);
    l_cursor_id2                   NUMBER;
    l_conv_rate                    NUMBER;

    --start bug 8588077
    l_current_attr_group_id       NUMBER;
    l_col_values_index            NUMBER;
    l_col_value_item_id           VARCHAR2(1000);
    l_col_value_org_id            VARCHAR2(30);
    l_col_name                    VARCHAR2(30);
    l_ag_inherited_query          VARCHAR2(3000);
    l_defaulting                  VARCHAR2(5);
    l_style_item_flag_query       VARCHAR2(3000);
    l_style_item_flag             VARCHAR2(5);
    l_style_item_id               NUMBER;
    l_input_data_level_id         NUMBER;
    l_pk_column_name_value_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY;
    -- Bug 12765239.
    l_add_and                     BOOLEAN := false;
    l_predicate_added             BOOLEAN := false;
  BEGIN

    Debug_Msg(l_api_name||'  starting', 1);
    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

Debug_Msg(l_api_name||'  call compatible', 3);


Debug_Msg(l_api_name||' Set_Up_Business_Object_Session(', 3);
Debug_Msg(l_api_name||'   p_bulkload_flag                 => TRUE', 3);
Debug_Msg(l_api_name||'   p_user_privileges_on_object     => <unprintable>', 3);
Debug_Msg(l_api_name||'   p_entity_id                     => ' || p_entity_id, 3);
Debug_Msg(l_api_name||'   p_entity_index                  => ' || p_entity_index, 3);
Debug_Msg(l_api_name||'   p_entity_code                   => ' || p_entity_code, 3);
Debug_Msg(l_api_name||'   p_debug_level                   => ' || p_debug_level, 3);
Debug_Msg(l_api_name||'   p_init_error_handler_flag       => ' || p_init_error_handler, 3);
Debug_Msg(l_api_name||'   p_object_name                   => ' || p_object_name, 3);
Debug_Msg(l_api_name||'   p_pk_column_name_value_pairs    => <unprintable>', 3);
Debug_Msg(l_api_name||'   p_class_code_name_value_pairs   => NULL', 3);
Debug_Msg(l_api_name||'   p_init_fnd_msg_list             => ' || p_init_fnd_msg_list, 3);
Debug_Msg(l_api_name||'   p_add_errors_to_fnd_stack       => ' || p_add_errors_to_fnd_stack, 3);
Debug_Msg(l_api_name||'   x_return_status                 => ' || x_return_status, 3);
Debug_Msg(l_api_name||' );', 3);
    --------------------------------------------------------------------------------
    -- Start by dealing with caching, error-handling, and preliminary validations --
    --------------------------------------------------------------------------------

    Set_Up_Business_Object_Session(
        p_bulkload_flag                 => TRUE
       ,p_user_privileges_on_object     => p_user_privileges_on_object
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_debug_level                   => p_debug_level
       ,p_init_error_handler_flag       => FND_API.To_Boolean(p_init_error_handler)
       ,p_object_name                   => p_object_name
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => NULL -- SSARNOBA - I'm not sure if this should be null
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,x_return_status                 => x_return_status
    );
Debug_Msg(l_api_name || ' after Set_Up_Business_Object_Session ', 3);

    ----------------------------------------------------------------------
    -- If an error was found, we've already added it to the error stack --
    ----------------------------------------------------------------------
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -------------------------------------------------
    -- We could have a batch metadata retrieval procedure for the *_User_Attrs_Data calls;
    -- it would batch fetch all the metadata for the relevent AGs and then store them in
    -- the cache (well, at least fifty of them; if more than fifty, it would still work well)
    -------------------------------------------------

Debug_Msg(l_api_name || ' p_attr_group_request_table.count = '||p_attr_group_request_table.count);
    IF (p_attr_group_request_table IS NOT NULL AND
        p_attr_group_request_table.COUNT > 0) THEN

      -------------------------------------------------------------
      -- First, get metadata for later use in building the query --
      -- (we know both of these calls will succeed because they  --
      -- were tested in Perform_Preliminary_Checks, above)       --
      -------------------------------------------------------------
      l_object_id := Get_Object_Id_From_Name(p_object_name);
      l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(l_object_id);

      --=======================================================================--
      -- Because there might be hundreds of Attribute Groups for which we need --
      -- to get data, we can't assume that we could store metadata for each of --
      -- them; so we do all processing that requires metadata at one time for  --
      -- each Attribute Group to avoid possibly having to refetch metadata for --
      -- any Attribute Group.                                                  --
      --=======================================================================--
      l_request_table_index := p_attr_group_request_table.FIRST;
      <<GUAD_ag_requests_loop>>
      WHILE (l_request_table_index <= p_attr_group_request_table.LAST)
      LOOP
        l_curr_ag_request_obj := p_attr_group_request_table(l_request_table_index);

Debug_Msg(l_api_name || ' ');
Debug_Msg(l_api_name || ' Attribute Group Request (       -- ' || l_request_table_index || '.');
Debug_Msg(l_api_name || '   ATTR_GROUP_ID   =  ' || l_curr_ag_request_obj.ATTR_GROUP_ID);
Debug_Msg(l_api_name || '   APPLICATION_ID  =  ' || l_curr_ag_request_obj.APPLICATION_ID);
Debug_Msg(l_api_name || '   ATTR_GROUP_TYPE =  ' || l_curr_ag_request_obj.ATTR_GROUP_TYPE);
Debug_Msg(l_api_name || '   ATTR_GROUP_NAME =  ' || l_curr_ag_request_obj.ATTR_GROUP_NAME);
Debug_Msg(l_api_name || '   DATA_LEVEL      =  ' || l_curr_ag_request_obj.DATA_LEVEL);
Debug_Msg(l_api_name || '   DATA_LEVEL_1    =  ' || l_curr_ag_request_obj.DATA_LEVEL_1);
Debug_Msg(l_api_name || '   DATA_LEVEL_2    =  ' || l_curr_ag_request_obj.DATA_LEVEL_2);
Debug_Msg(l_api_name || '   DATA_LEVEL_3    =  ' || l_curr_ag_request_obj.DATA_LEVEL_3);
Debug_Msg(l_api_name || '   DATA_LEVEL_4    =  ' || l_curr_ag_request_obj.DATA_LEVEL_4);
Debug_Msg(l_api_name || '   DATA_LEVEL_5    =  ' || l_curr_ag_request_obj.DATA_LEVEL_5);
Debug_Msg(l_api_name || '   ATTR_NAME_LIST  =  ' || l_curr_ag_request_obj.ATTR_NAME_LIST);
Debug_Msg(l_api_name || ' )  ');

        -- Get the metadata for this attribute group
        l_curr_ag_metadata_obj :=
          EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(l_curr_ag_request_obj.ATTR_GROUP_ID
                                                           ,l_curr_ag_request_obj.APPLICATION_ID
                                                           ,l_curr_ag_request_obj.ATTR_GROUP_TYPE
                                                           ,l_curr_ag_request_obj.ATTR_GROUP_NAME);

        -- Determine if the EXT table has a data level column
        l_has_data_level_col := FND_API.TO_BOOLEAN(EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(l_curr_ag_metadata_obj.EXT_TABLE_B_NAME, 'DATA_LEVEL_ID'));


        ----------------------------------------------------------------------
        -- Scan the list of enabled data levels, and see if the data level  --
        -- of the current attribute group is in this list                   --
        ----------------------------------------------------------------------

        l_curr_data_level_row_obj := NULL;

        IF l_has_data_level_col THEN

          IF (l_curr_ag_metadata_obj.ENABLED_DATA_LEVELS IS NOT NULL AND
              l_curr_ag_metadata_obj.ENABLED_DATA_LEVELS.COUNT <> 0) THEN

Debug_Msg(l_api_name || ' passed data level name '|| l_curr_ag_request_obj.data_level);
Debug_Msg(l_api_name || ' ' || l_curr_ag_metadata_obj.ENABLED_DATA_LEVELS.COUNT || ' data level(s) enabled for AG ' || l_curr_ag_request_obj.ATTR_GROUP_ID);

            -- Loop 1.1
            FOR dl_index IN l_curr_ag_metadata_obj.ENABLED_DATA_LEVELS.FIRST ..
                            l_curr_ag_metadata_obj.ENABLED_DATA_LEVELS.LAST
            LOOP

Debug_Msg(l_api_name ||' Enabled data level - '|| l_curr_ag_metadata_obj.ENABLED_DATA_LEVELS(dl_index).data_level_name || ' (' || l_curr_ag_metadata_obj.ENABLED_DATA_LEVELS(dl_index).data_level_id || ')');

              IF l_curr_ag_metadata_obj.ENABLED_DATA_LEVELS(dl_index).data_level_name = l_curr_ag_request_obj.data_level THEN

Debug_Msg(l_api_name||' Creating data level row obj ');

                l_curr_data_level_row_obj := l_curr_ag_metadata_obj.ENABLED_DATA_LEVELS(dl_index);

                IF l_curr_data_level_row_obj IS NOT NULL THEN
Debug_Msg(l_api_name || 'Data level metadata found');
                  l_curr_data_level_metadata := EGO_USER_ATTRS_COMMON_PVT.Get_Data_Level_Metadata(l_curr_data_level_row_obj.data_level_id);
                  EXIT; -- exit the loop as we found the DL metadata
                END IF;
              END IF;
            END LOOP;

Debug_Msg(l_api_name || ' ');
Debug_Msg(l_api_name || ', Data Level Metadata (');
Debug_Msg(l_api_name || ',   DATA_LEVEL_ID        = ' || l_curr_data_level_metadata.DATA_LEVEL_ID);
Debug_Msg(l_api_name || ',   DATA_LEVEL_NAME      = ' || l_curr_data_level_metadata.DATA_LEVEL_NAME);
Debug_Msg(l_api_name || ',   USER_DATA_LEVEL_NAME = ' || l_curr_data_level_metadata.USER_DATA_LEVEL_NAME);
Debug_Msg(l_api_name || ',   PK1_COLUMN_NAME      = ' || l_curr_data_level_metadata.PK_COLUMN_NAME1);
Debug_Msg(l_api_name || ',   PK2_COLUMN_NAME      = ' || l_curr_data_level_metadata.PK_COLUMN_NAME2);
Debug_Msg(l_api_name || ',   PK3_COLUMN_NAME      = ' || l_curr_data_level_metadata.PK_COLUMN_NAME3);
Debug_Msg(l_api_name || ',   PK4_COLUMN_NAME      = ' || l_curr_data_level_metadata.PK_COLUMN_NAME4);
Debug_Msg(l_api_name || ',   PK5_COLUMN_NAME      = ' || l_curr_data_level_metadata.PK_COLUMN_NAME5);
Debug_Msg(l_api_name || ',   PK1_COLUMN_TYPE      = ' || l_curr_data_level_metadata.PK_COLUMN_TYPE1);
Debug_Msg(l_api_name || ',   PK2_COLUMN_TYPE      = ' || l_curr_data_level_metadata.PK_COLUMN_TYPE2);
Debug_Msg(l_api_name || ',   PK3_COLUMN_TYPE      = ' || l_curr_data_level_metadata.PK_COLUMN_TYPE3);
Debug_Msg(l_api_name || ',   PK4_COLUMN_TYPE      = ' || l_curr_data_level_metadata.PK_COLUMN_TYPE4);
Debug_Msg(l_api_name || ',   PK5_COLUMN_TYPE      = ' || l_curr_data_level_metadata.PK_COLUMN_TYPE5);
Debug_Msg(l_api_name || ',   DL_PROD_TABLE_NAME   = ' || l_curr_data_level_metadata.DL_PROD_TABLE_NAME);
Debug_Msg(l_api_name || ', )');
Debug_Msg(l_api_name || ' ');
          IF l_curr_data_level_row_obj IS NULL THEN
            -- the data level is not correct, flash error message.

Debug_Msg(l_api_name || ' Data level not in list of enabled data levels');

            l_token_table(1).TOKEN_NAME := 'DL_NAME';
            l_token_table(1).TOKEN_VALUE := '';
            l_token_table(2).TOKEN_NAME := 'AG_NAME';
            l_token_table(2).TOKEN_VALUE := l_curr_ag_metadata_obj.attr_group_disp_name;

            -- The data level XXX is not associated with the attribute
            -- group XXX
            ERROR_HANDLER.Add_Error_Message(
              p_message_name      => 'EGO_EF_DL_AG_INVALID'
             ,p_application_id    => 'EGO'
             ,p_token_tbl         => l_token_table
             ,p_message_type      => FND_API.G_RET_STS_ERROR
             ,p_row_identifier    => G_USER_ROW_IDENTIFIER
             ,p_entity_id         => p_entity_id
             ,p_entity_index      => p_entity_index
             ,p_entity_code       => p_entity_code
             ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
            );
            l_token_table.DELETE();
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- We've found the metadata for the data level of this attribute group

Debug_Msg(l_api_name || ' ');
Debug_Msg(l_api_name || ', Data Level Metadata (');
Debug_Msg(l_api_name || ',   DATA_LEVEL_ID        = ' || l_curr_data_level_metadata.DATA_LEVEL_ID);
Debug_Msg(l_api_name || ',   DATA_LEVEL_NAME      = ' || l_curr_data_level_metadata.DATA_LEVEL_NAME);
Debug_Msg(l_api_name || ',   USER_DATA_LEVEL_NAME = ' || l_curr_data_level_metadata.USER_DATA_LEVEL_NAME);
Debug_Msg(l_api_name || ',   PK1_COLUMN_NAME      = ' || l_curr_data_level_metadata.PK_COLUMN_NAME1);
Debug_Msg(l_api_name || ',   PK2_COLUMN_NAME      = ' || l_curr_data_level_metadata.PK_COLUMN_NAME2);
Debug_Msg(l_api_name || ',   PK3_COLUMN_NAME      = ' || l_curr_data_level_metadata.PK_COLUMN_NAME3);
Debug_Msg(l_api_name || ',   PK4_COLUMN_NAME      = ' || l_curr_data_level_metadata.PK_COLUMN_NAME4);
Debug_Msg(l_api_name || ',   PK5_COLUMN_NAME      = ' || l_curr_data_level_metadata.PK_COLUMN_NAME5);
Debug_Msg(l_api_name || ',   PK1_COLUMN_TYPE      = ' || l_curr_data_level_metadata.PK_COLUMN_TYPE1);
Debug_Msg(l_api_name || ',   PK2_COLUMN_TYPE      = ' || l_curr_data_level_metadata.PK_COLUMN_TYPE2);
Debug_Msg(l_api_name || ',   PK3_COLUMN_TYPE      = ' || l_curr_data_level_metadata.PK_COLUMN_TYPE3);
Debug_Msg(l_api_name || ',   PK4_COLUMN_TYPE      = ' || l_curr_data_level_metadata.PK_COLUMN_TYPE4);
Debug_Msg(l_api_name || ',   PK5_COLUMN_TYPE      = ' || l_curr_data_level_metadata.PK_COLUMN_TYPE5);
Debug_Msg(l_api_name || ',   DL_PROD_TABLE_NAME   = ' || l_curr_data_level_metadata.DL_PROD_TABLE_NAME);
Debug_Msg(l_api_name || ', )');
Debug_Msg(l_api_name || ' ');
          END IF;
        END IF;  -- has_data_level
Debug_Msg(l_api_name || ' level 1 done ');

        -- bug 5494760.  Go ahead for processing the Attribute Group only if the
        -- attribute group has got some attibutes in it.we return ATTR_METADATA_TABLE
        -- as a null if there are no attributes in the attribute group that is passed in.
        IF  (l_curr_ag_metadata_obj.ATTR_METADATA_TABLE IS NOT NULL AND l_curr_ag_metadata_obj.ATTR_METADATA_TABLE.COUNT <> 0 ) THEN
          -- set the flag to 'Y' even if  there is atleast one attribute group
          -- which has attributes in it.
          l_has_attrs := 'Y';
          -- get the view name
          l_curr_ag_vl_name := l_curr_ag_metadata_obj.EXT_TABLE_VL_NAME;
          -- get the table name also
          l_curr_ag_table_name := l_curr_ag_metadata_obj.EXT_TABLE_B_NAME;
          --
          -- Here we use l_curr_ag_metadata_obj.ATTR_GROUP_ID as our row identifier for
          -- error-reporting purposes; make sure it's known and that it's consistent!
          --
          G_USER_ROW_IDENTIFIER := l_curr_ag_metadata_obj.ATTR_GROUP_ID;

          l_can_view_this_attr_group := TRUE;

          -----------------------------------------------------------
          -- If the Attr Group is secured (either explicitly or by --
          -- a default privilege for this Object) AND the caller   --
          -- passed a table of privileges, then we ensure that the --
          -- user has the required View privilege for this AG      --
          -----------------------------------------------------------
          IF (G_CURRENT_USER_PRIVILEGES IS NOT NULL) THEN

            Check_Privileges(
              p_attr_group_metadata_obj  => l_curr_ag_metadata_obj
             ,p_data_level_row_obj       => l_curr_data_level_row_obj
             ,p_ignore_edit_privilege    => TRUE
             ,p_entity_id                => p_entity_id
             ,p_entity_index             => p_entity_index
             ,p_entity_code              => p_entity_code
             ,x_return_status            => x_return_status
            );

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              l_can_view_this_attr_group := FALSE;
            END IF;
          END IF;

        IF (l_can_view_this_attr_group) THEN
Debug_Msg(l_api_name || ' user can view the AG ');
          -------------------------------------------------------
          -- Build a Data Level array for this Attribute Group --
          -------------------------------------------------------
          IF l_curr_data_level_row_obj IS NULL THEN
Debug_Msg(l_api_name || ' 100 ');
            -- r12 code
            l_data_level_name_value_pairs :=
               Build_Data_Level_Array(p_object_name    => p_object_name
                                     ,p_data_level_id  => NULL
                                     ,p_data_level_1   => l_curr_ag_request_obj.DATA_LEVEL_1
                                     ,p_data_level_2   => l_curr_ag_request_obj.DATA_LEVEL_2
                                     ,p_data_level_3   => l_curr_ag_request_obj.DATA_LEVEL_3
                                     ,p_data_level_4   => NULL
                                     ,p_data_level_5   => NULL
                                     );
          ELSE
Debug_Msg(l_api_name || ' 200 ');
Debug_Msg('Data level id ' || l_curr_data_level_row_obj.data_level_id);
            -- r12C code
            l_data_level_name_value_pairs :=
               Build_Data_Level_Array(p_object_name    => p_object_name
                                     ,p_data_level_id  => l_curr_data_level_row_obj.data_level_id
                                     ,p_data_level_1   => l_curr_ag_request_obj.DATA_LEVEL_1
                                     ,p_data_level_2   => l_curr_ag_request_obj.DATA_LEVEL_2
                                     ,p_data_level_3   => l_curr_ag_request_obj.DATA_LEVEL_3
                                     ,p_data_level_4   => l_curr_ag_request_obj.DATA_LEVEL_4
                                     ,p_data_level_5   => l_curr_ag_request_obj.DATA_LEVEL_5
                                     );
Debug_Msg(l_api_name || ', data level key values = (' || l_curr_ag_request_obj.DATA_LEVEL_1 || ',' ||
                                                         l_curr_ag_request_obj.DATA_LEVEL_2 || ',' ||
                                                         l_curr_ag_request_obj.DATA_LEVEL_3 || ',' ||
                                                         l_curr_ag_request_obj.DATA_LEVEL_4 || ',' ||
                                                         l_curr_ag_request_obj.DATA_LEVEL_5 || ')', 5);


          END IF;

Debug_Msg(l_api_name || ' data level name value pairs built ');


          ----------------------------------------------------------------------------------
          -- Get a list of the names of all requested Attributes for this Attribute Group --
          -- (this procedure also checks to be sure each name exists in the metadata)     --
          ----------------------------------------------------------------------------------
          l_requested_attr_names_table := Get_Requested_Attr_Names(l_curr_ag_metadata_obj.ATTR_GROUP_ID
                                                                  ,l_curr_ag_request_obj.ATTR_GROUP_NAME
                                                                  ,l_curr_ag_request_obj.ATTR_NAME_LIST
                                                                  ,l_curr_ag_metadata_obj.attr_metadata_table
                                                                  ,p_entity_id
                                                                  ,p_entity_index
                                                                  ,p_entity_code);

Debug_Msg(l_api_name || ' requested attr names table built ');
          ---------------------------------------------------------------------------
          -- See whether we put error messages onto the stack in the previous call --
          ---------------------------------------------------------------------------
          IF (l_requested_attr_names_table.EXISTS(-1)) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          --===================================================================--
          -- Loop 1.2
          -- For every Attribute in our table of Attribute names, we find its  --
          -- metadata and build an augmented version of a Data record for it,  --
          -- which we then add to a table for later use in correlating a given --
          -- Database Column to the appropriate Attribute and then building an --
          -- Attr Data object for that Attr and its value.  We also record the --
          -- index bounds in the data table for any given AG ID in order to    --
          -- limit the search for the correct augmented data record given the  --
          -- current AG ID and Database Column that we are processing.         --
          --===================================================================--
          l_attr_list_index := l_requested_attr_names_table.FIRST;

          <<GUAD_attributes_loop>>
          WHILE (l_attr_list_index <= l_requested_attr_names_table.LAST)
          LOOP
Debug_Msg(l_api_name || ' processing attr at  '||l_attr_list_index);

            ---------------------------------------------------
            -- We know this call will succeed because it was --
            -- tested in Get_Requested_Attr_Names, above     --
            ---------------------------------------------------
            l_curr_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                          p_attr_metadata_table => l_curr_ag_metadata_obj.attr_metadata_table
                                         ,p_attr_name           => l_requested_attr_names_table(l_attr_list_index)
                                        );
Debug_Msg(l_api_name || ' processing attr '|| l_attr_list_index || ' - ' ||l_curr_augmented_attr_rec.ATTR_NAME);
            l_curr_augmented_attr_rec.ATTR_GROUP_ID := l_curr_ag_metadata_obj.ATTR_GROUP_ID;
            l_curr_augmented_attr_rec.APPLICATION_ID := l_curr_ag_metadata_obj.APPLICATION_ID;
            l_curr_augmented_attr_rec.ATTR_GROUP_TYPE := l_curr_ag_metadata_obj.ATTR_GROUP_TYPE;
            l_curr_augmented_attr_rec.ATTR_GROUP_NAME := l_curr_ag_metadata_obj.ATTR_GROUP_NAME;
            l_curr_augmented_attr_rec.ATTR_NAME := l_curr_attr_metadata_obj.ATTR_NAME;
            l_curr_augmented_attr_rec.ATTR_DISP_NAME := l_curr_attr_metadata_obj.ATTR_DISP_NAME;
            l_curr_augmented_attr_rec.DATABASE_COLUMN := l_curr_attr_metadata_obj.DATABASE_COLUMN;
            l_curr_augmented_attr_rec.ATTR_UNIT_OF_MEASURE := l_curr_attr_metadata_obj.UNIT_OF_MEASURE_BASE; --Bug#7662816
            --ENHR12:added for passing the internal value of an
            --attribute along with the display value.
            l_curr_augmented_attr_rec.DATA_TYPE_CODE:=l_curr_attr_metadata_obj.DATA_TYPE_CODE;
            ----------------------------------------------------
            -- Record the index at which we store this record --
            ----------------------------------------------------
            l_curr_aug_table_index := l_augmented_data_table.COUNT+1;
            l_augmented_data_table(l_curr_aug_table_index) := l_curr_augmented_attr_rec;

            -----------------------------------------------------------------
            -- If it's the first index for this AG ID, store it as such... --
            -----------------------------------------------------------------
            IF (NOT l_table_of_low_ind_for_AG_ID.EXISTS(l_curr_augmented_attr_rec.ATTR_GROUP_ID)) THEN
              l_table_of_low_ind_for_AG_ID(l_curr_augmented_attr_rec.ATTR_GROUP_ID) := l_curr_aug_table_index;
            END IF;

            ------------------------------------------------------
            -- ...and since it's always the last index (so far) --
            -- for this AG ID, store it as that as well.        --
            ------------------------------------------------------
            l_table_of_high_ind_for_AG_ID(l_curr_augmented_attr_rec.ATTR_GROUP_ID) := l_curr_aug_table_index;

            -----------------------------------------------------------------------------
            -- If the Database Column for this Attribute is one that has not yet been  --
            -- processed, put it into the l_db_column_name_table and put its name and  --
            -- its l_db_column_name_table index into the l_db_column_list. If this has --
            -- already been done for this column, get the index from l_db_column_list. --
            -----------------------------------------------------------------------------
            l_curr_db_column_name := l_curr_augmented_attr_rec.DATABASE_COLUMN;

            IF (l_db_column_list IS NULL OR
                INSTR(l_db_column_list, l_curr_db_column_name||':') = 0) THEN

              l_db_column_tables_index := l_db_column_name_table.COUNT+1;
              l_db_column_name_table(l_db_column_tables_index) := l_curr_db_column_name;
              l_db_column_list := l_db_column_list || l_curr_db_column_name || ':'||l_db_column_tables_index||', ';

            ELSE

              l_start_index := INSTR(l_db_column_list, l_curr_db_column_name||':') + LENGTH(l_curr_db_column_name||':');
              l_substring_length := INSTR(l_db_column_list, ',', l_start_index) - l_start_index;
              l_db_column_tables_index := TO_NUMBER(SUBSTR(l_db_column_list, l_start_index, l_substring_length));

            END IF;

            ---------------------------------------------------------------
            -- By default we want to cast the database column values we  --
            -- retrieve to strings (for assignment in ATTR_DISP_VALUE);  --
            -- the exception to this is if an Attr has a Table Value Set --
            -- (in which case the Int -> Disp value query may assume the --
            -- data type of the database column to be a Date or Number)  --
            ---------------------------------------------------------------
            l_to_char_db_col_expression := EGO_USER_ATTRS_COMMON_PVT.Create_DB_Col_Alias_If_Needed(l_curr_attr_metadata_obj,'EMSI');

            IF (l_curr_attr_metadata_obj.INT_TO_DISP_VAL_QUERY IS NULL) THEN

              ----------------------------------------------------------------------
              -- If this Attribute does not have a Value Set that distinguishes   --
              -- between Internal and Display Values, we just make sure that a    --
              -- query for this Database Column name (as determined by the index) --
              -- is in the l_db_column_query_table (we don't want to overwrite a  --
              -- possibly more complicated query with our simple formatted one,   --
              -- which is why we only add it if one doesn't already exist).       --
              ----------------------------------------------------------------------
              IF (NOT l_db_column_query_table.EXISTS(l_db_column_tables_index)) THEN

                --ENHR12:changed for passing the internal value of an
                --attribute along with the display value.
                --------------------------------------------------------------------------
                -- Syalaman - Following If condition is added as part of fix for bug 5859465.
                -- If l_to_char_db_col_expression has coloumn name starting with TO_CHAR,
                -- i.e., for ex., TO_CHAR(N_EXT_ATTR1), then add N_EXT_ATTR1 as alias name
                -- to the column.
                --------------------------------------------------------------------------
                IF (InStr(l_to_char_db_col_expression,'TO_CHAR') = 1) THEN
                  l_db_column_query_table(l_db_column_tables_index) := l_to_char_db_col_expression|| ' ' ||
                                                                      l_curr_db_column_name|| ','||
                                                                      l_to_char_db_col_expression||'  INTERNAL_NAME';
                ELSE
                  l_db_column_query_table(l_db_column_tables_index) := l_to_char_db_col_expression|| ','||
                                                                      l_to_char_db_col_expression||'  INTERNAL_NAME';
                END IF;
                -- end of fix for bug 5859465.

              END IF;

            ELSE

              --------------------------------------------------------------------
              -- Since the Attribute has different Internal and Display Values, --
              -- we build or update a DECODE query for the Database Column (so  --
              -- that each AG's use of the column gets the correct Disp value)  --
              --------------------------------------------------------------------
              IF (l_curr_attr_metadata_obj.VALIDATION_CODE IN (
                  EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE,
                  EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE)
                 ) THEN

                l_int_to_disp_val_string := l_curr_attr_metadata_obj.INT_TO_DISP_VAL_QUERY;

              ELSIF (l_curr_attr_metadata_obj.VALIDATION_CODE =
                     EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE) THEN

                ----------------------------------------------------------------
                -- In this case we DON'T want to cast the result to a string, --
                -- so we revert our expression to being the database column   --
                ----------------------------------------------------------------
                l_to_char_db_col_expression := 'EMSI.'||l_curr_db_column_name;

                ------------------------------------------------------------------
                -- This call will tokenize the query if (and only if) necessary --
                ------------------------------------------------------------------
                l_int_to_disp_val_string := Tokenized_Val_Set_Query(
                       p_attr_metadata_obj             => l_curr_attr_metadata_obj
                      ,p_attr_group_metadata_obj       => l_curr_ag_metadata_obj
                      ,p_ext_table_metadata_obj        => l_ext_table_metadata_obj
                      ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
                      ,p_data_level_name_value_pairs   => l_data_level_name_value_pairs
                      ,p_entity_id                     => p_entity_id
                      ,p_entity_index                  => p_entity_index
                      ,p_entity_code                   => p_entity_code
                      ,p_attr_name_value_pairs         => NULL
                      ,p_is_disp_to_int_query          => FALSE
                      ,p_final_bind_value              => NULL
                      ,p_return_bound_sql              => TRUE
                     );

              END IF;

              --
              -- Bug 1276239. Removed old logic of DECODE(attr_group_id).
              -- In old logic we used to build one single SQL for all AGs.
              -- So we needed DECODE(attr_group_id). However after version 120.48
              -- logic got changed to build one SQL per AG. So we dont need
              -- DECODE statements.
              -- sreharih. Thu Aug 25 12:44:00 PDT 2011
              --

              l_db_column_query_table(l_db_column_tables_index) := '' ||
                '( ' || l_int_to_disp_val_string || ' ' || l_to_char_db_col_expression || ' ) '||l_curr_db_column_name||','||l_to_char_db_col_expression||'  INTERNAL_NAME ';


            END IF;

            l_attr_list_index := l_requested_attr_names_table.NEXT(l_attr_list_index);
          END LOOP attributes_loop;

          --Bug Fix - 3828505
        ELSE
          Debug_Msg(l_api_name || ' user can NOT view the AG ');
        END IF; -- the if check for l_can_view_this_attr_group
       END IF;--l_curr_ag_metadata_obj.ATTR_METADATA_TABLE IS NOT NULL--bug 5494760

       --bug 5494760
       --if there isn't a single attribute group which has attributes in it, return from
       --here itself instead of framing the query and executing it.
       IF (l_has_attrs <> 'Y') THEN
         Debug_Msg(l_api_name||'  there are no attribute groups in the list that has attributes in it.', 1);
         ------------------------------------------------------
         -- We log all errors we got as we close our session --
         ------------------------------------------------------
         Close_Business_Object_Session(
          p_init_error_handler_flag    => FND_API.To_Boolean(p_init_error_handler)
         ,p_log_errors                 => TRUE
         ,p_write_to_concurrent_log    => FALSE
         );

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         RETURN ;
       END IF;

        --------------------------------------------------------------------
        -- It's possible that the user did not have sufficient privileges --
        -- to view even one of the requested Attr Groups; we need to see  --
        -- whether we built any Database Column query components at all   --
        --------------------------------------------------------------------
        IF (l_db_column_query_table.COUNT > 0) THEN

          --------------------------------------------------------------------------------
          -- Loop 1.3                                                                   --
          -- Now we build a query list with all of our Database Column query components --
          --------------------------------------------------------------------------------
          l_db_column_list := '';
          FOR i IN l_db_column_query_table.FIRST .. l_db_column_query_table.LAST
          LOOP
            l_db_column_list := l_db_column_list || l_db_column_query_table(i) || ',';
          END LOOP;

          -----------------------------------------------------------------------
          -- Trim the trailing bits from the Attr Group ID and DB Column lists --
          -----------------------------------------------------------------------
          l_db_column_list := RTRIM(l_db_column_list, ',');

          --
          -- Bug 1276239. Logic to use fnd_dsql.
          -- Encapsulated logic to build pkcol, data level and ag
          -- predicates in simple method and calling it from
          -- here.
          -- sreharih. Thu Aug 25 12:44:00 PDT 2011
          --

          fnd_dsql.init();
          fnd_dsql.add_text(' SELECT EXTENSION_ID, ATTR_GROUP_ID, '||l_db_column_list||
                             ' FROM ' ||NVL(l_curr_ag_vl_name,l_curr_ag_table_name)||' EMSI'||
                            ' WHERE ' );
          l_add_and := FALSE;

          add_pkcol_predicate (
                    p_attr_group_type    => l_curr_ag_metadata_obj.ATTR_GROUP_TYPE,
                    p_attr_group_id      => l_curr_ag_metadata_obj.ATTR_GROUP_ID,
                    p_data_level         => l_curr_ag_request_obj.DATA_LEVEL,
                    p_pkcol_value_pairs  => p_pk_column_name_value_pairs,
                    p_pk_column_metadata => l_ext_table_metadata_obj.pk_column_metadata,
                    p_add_and            => l_add_and,
                    x_predicate_added    => l_predicate_added);

          l_add_and := l_add_and OR l_predicate_added;

          add_datalevel_predicate (
                    p_data_level_id            => l_curr_data_level_row_obj.data_level_id,
                    p_has_data_level_col       => l_has_data_level_col,
                    p_ext_data_level_metadata  => l_ext_table_metadata_obj.data_level_metadata,
                    p_data_level_metadata      => l_curr_data_level_metadata,
                    p_data_level_value_pairs   => l_data_level_name_value_pairs,
                    p_add_and                  => l_add_and,
                    x_predicate_added          => l_predicate_added);

          l_add_and := l_add_and OR l_predicate_added;

          add_ag_predicate(
                   p_attr_group_id   => l_curr_ag_metadata_obj.attr_group_id,
                   p_add_and         => l_add_and,
                   x_predicate_added => l_predicate_added);


          l_dynamic_sql := fnd_dsql.get_text;


          Debug_Msg(l_dynamic_sql);

          ----------------------------------
          -- Open a cursor for processing --
          ----------------------------------
          l_cursor_id := DBMS_SQL.OPEN_CURSOR;
          -------------------------------------
          -- Parse our dynamic SQL statement --
          -------------------------------------
          DBMS_SQL.PARSE(l_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
          fnd_dsql.set_cursor(l_cursor_id);
          fnd_dsql.do_binds;
          --------------------------------------------------------------------------
          -- Register the data types of the columns we are selecting in our query --
          -- (in the VARCHAR2 case, that includes stating the maximum size that a --
          -- value in the column might be; to be safe we will use 1000 bytes).    --
          -- First we register the EXTENSION_ID and ATTR_GROUP_ID...              --
          --------------------------------------------------------------------------
          DBMS_SQL.Define_Column(l_cursor_id, 1, l_extension_id);
          DBMS_SQL.Define_Column(l_cursor_id, 2, l_curr_AG_ID);

          -----------------------------------
          -- Loop 1.4
          -- ...then the Database Columns. --
          -----------------------------------
          FOR i IN l_db_column_name_table.FIRST .. l_db_column_name_table.LAST
          LOOP

-- Assumption: TVS values will be castable to string (I know all else will be)

            --------------------------------------------------------------------
            -- We cast everything to string for assignment to ATTR_DISP_VALUE --
            --------------------------------------------------------------------
            -- Syalaman - Fix for bug 5859465
            DBMS_SQL.Define_Column(l_cursor_id, (i*2)+1, l_varchar_example, 4000); --bug 12979914

            --ENHR12:changed for passing the internal value of the attribute
            --along with the display value.
            -- Syalaman - Fix for bug 5859465
            DBMS_SQL.Define_Column(l_cursor_id, (i*2)+2, l_varchar_example, 4000); --bug 12979914
          END LOOP;

          -------------------------------
          -- Execute our dynamic query --
          -------------------------------
          l_dummy := DBMS_SQL.Execute(l_cursor_id);
          Debug_Msg(l_api_name||'  executed the query', 3);

          --===============================================================================--
          -- Loop 1.5                                                                      --
          -- As we loop through the result set rows (which are ordered by ATTR_GROUP_ID),  --
          -- we search through l_augmented_data_table (which is also ordered by AG ID).    --
          -- Since all augmented data elements for a given AG ID are in a certain index    --
          -- range in l_augmented_data_table, we can save time by searching for the record --
          -- for a particular AG ID and Database Column only in the subset of the data     --
          -- table holding records for that AG ID.  Earlier we recorded the lowest and     --
          -- highest index in the data table whose elements corresponded to a given AG ID; --
          -- we use those numbers to limit our search to the relevent subsets of the data  --
          -- table.  The variables we use for this search bounding are:                    --
          -- 1). l_curr_AG_ID, which holds the AG ID for the current result set row,       --
          -- 2). l_low_aug_tab_ind_for_AG_ID, which holds the lowest index in the data     --
          -- table for an Attribute record belonging to the current AG ID, and             --
          -- 3). l_high_aug_tab_ind_for_AG_ID, which holds the highest such index.         --
          --===============================================================================--
          <<GUAD_all_attributes_loop>>
          WHILE (DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0)
          LOOP

            ----------------------------------------------------------------
            -- Get the EXTENSION_ID and ATTR_GROUP_ID for the current row --
            ----------------------------------------------------------------
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_extension_id);
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 2, l_curr_AG_ID);

            -----------------------------------------------------------------
            -- Reset the variable that tells us whether we need to build a --
            -- new row object for the out parameter x_attributes_row_table --
            -----------------------------------------------------------------
            l_need_to_build_a_row_obj := TRUE;

            -- Update the search bounds (they will only change with a new AG ID) --

            l_low_aug_tab_ind_for_AG_ID := l_table_of_low_ind_for_AG_ID(l_curr_AG_ID);
            l_high_aug_tab_ind_for_AG_ID := l_table_of_high_ind_for_AG_ID(l_curr_AG_ID);

            --==============================================================--
            -- Loop 1.5.1                                                   --
            --==============================================================--

            <<GUAD_column_name_loop>>
            FOR i IN l_db_column_name_table.FIRST .. l_db_column_name_table.LAST
            LOOP
              --checking this in case none of the column  for a given i and j match
              --and always the l_dbcol_cntr follows the pattern that it will be 1
              --less than the i here.
              IF(l_dbcol_cntr <i-1) THEN
                l_dbcol_cntr:=i-1;
              END IF;
              ------------------------------------------------------
              -- Clear the record for a fresh start to every loop --
              ------------------------------------------------------
              l_curr_augmented_attr_rec.ATTR_GROUP_ID := NULL;
              l_curr_augmented_attr_rec.APPLICATION_ID := NULL;
              l_curr_augmented_attr_rec.ATTR_GROUP_TYPE := NULL;
              l_curr_augmented_attr_rec.ATTR_GROUP_NAME := NULL;
              l_curr_augmented_attr_rec.ATTR_NAME := NULL;
              l_curr_augmented_attr_rec.ATTR_DISP_NAME := NULL;
              l_curr_augmented_attr_rec.ATTR_DISP_VALUE := NULL;
              l_curr_augmented_attr_rec.ATTR_UNIT_OF_MEASURE := NULL;
              l_curr_augmented_attr_rec.DATABASE_COLUMN := NULL;
              --ENHR12:added for passing the internal value of the attribute
              --along with the display value.
              l_curr_augmented_attr_rec.ATTR_VALUE_STR := NULL;
              l_curr_augmented_attr_rec.ATTR_VALUE_DATE := NULL;
              l_curr_augmented_attr_rec.ATTR_VALUE_NUM := NULL;
              l_curr_augmented_attr_rec.DATA_TYPE_CODE := NULL;

--
--  TO DO: include ATTR_UNIT_OF_MEASURE in the data you pull from the extension table
--

              --============================================================--
              -- Loop 1.5.1.1                                               --
              -- Search within the range of augmented Data records for this --
              -- AG ID                                                      --
              --============================================================--
              <<GUAD_augmented_data_recs_loop>>
              FOR j IN l_low_aug_tab_ind_for_AG_ID .. l_high_aug_tab_ind_for_AG_ID
              LOOP
                EXIT WHEN (l_curr_augmented_attr_rec.ATTR_GROUP_ID IS NOT NULL);
                --------------------------------------------------------
                -- If the current Data record is associated with the  --
                -- current Database Column, store the column's value  --
                -- temporarily (we will build an Attr Data object for --
                -- it in a few more lines).                           --
                --------------------------------------------------------
                IF (l_db_column_name_table(i) = l_augmented_data_table(j).DATABASE_COLUMN) THEN
                  l_curr_augmented_attr_rec := l_augmented_data_table(j);

                  --ENHR12:added for passing the internal value of the attribute
                  --along with the display value.
                  --setting the Display Value.
                  DBMS_SQL.COLUMN_VALUE(l_cursor_id, (i*2)+1, l_curr_augmented_attr_rec.ATTR_DISP_VALUE); -- Fix for bug 5859465

                  --setting the intrnal value of the Attribute depending on the DATA_TYPE_CODE
                  --if the attribute is of type Translatable(A) or Char(C)
                  IF ('C'=l_curr_augmented_attr_rec.DATA_TYPE_CODE OR 'A'=l_curr_augmented_attr_rec.DATA_TYPE_CODE) THEN
                     DBMS_SQL.COLUMN_VALUE(l_cursor_id, (i*2)+2, l_curr_augmented_attr_rec.ATTR_VALUE_STR); -- Fix for bug 5859465
                     l_curr_augmented_attr_rec.ATTR_VALUE_DATE:=null;
                     l_curr_augmented_attr_rec.ATTR_VALUE_NUM:=null;
                      --if the attribute is of type Date(X) or DateTime(Y)
                  ELSIF('X'=l_curr_augmented_attr_rec.DATA_TYPE_CODE OR 'Y'=l_curr_augmented_attr_rec.DATA_TYPE_CODE) THEN
                     DBMS_SQL.COLUMN_VALUE(l_cursor_id, (i*2)+2,l_char_value);  -- Fix for bug 5859465
                     l_curr_augmented_attr_rec.ATTR_VALUE_STR:=null;
                     l_curr_augmented_attr_rec.ATTR_VALUE_NUM:=null;
                     l_curr_augmented_attr_rec.ATTR_VALUE_DATE:=TO_DATE(l_char_value,'yyyy/mm/dd HH24:MI:SS');
                      --if the attribute is of type NUMBER(N)
                  ELSIF('N'=l_curr_augmented_attr_rec.DATA_TYPE_CODE) THEN
                    DBMS_SQL.COLUMN_VALUE(l_cursor_id, (i*2)+2, l_char_value);  -- Fix for bug 5859465
                    l_curr_augmented_attr_rec.ATTR_VALUE_STR:=null;
                    l_curr_augmented_attr_rec.ATTR_VALUE_DATE:=null;
                    l_curr_augmented_attr_rec.ATTR_VALUE_NUM:=TO_NUMBER(l_char_value);
                    --bug 8218727
                    /*FP bug 8547119 with base bug 8545032, remove the IF clause
                    IF(l_curr_attr_metadata_obj.UNIT_OF_MEASURE_CLASS IS NOT NULL) THEN*/

                    /*FP bug 8547119 with base bug 8545032, remove the IF clause
                    END IF;--end if for l_curr_attr_metadata_obj.UNIT_OF_MEASURE_CLASS IS NOT NULL*/

                    l_attr_list_index := l_requested_attr_names_table.FIRST;
                    WHILE (l_attr_list_index <= l_requested_attr_names_table.LAST)
                    LOOP

                      IF (l_curr_augmented_attr_rec.ATTR_NAME = l_requested_attr_names_table(l_attr_list_index)) THEN
                        l_new_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                          p_attr_metadata_table => l_curr_ag_metadata_obj.attr_metadata_table
                                         ,p_attr_name           => l_requested_attr_names_table(l_attr_list_index)
                                        );
                        exit;
                      END IF;
                      l_attr_list_index := l_requested_attr_names_table.NEXT(l_attr_list_index);
                    END LOOP;
                   IF(l_new_attr_metadata_obj.UNIT_OF_MEASURE_CLASS IS NOT NULL) THEN

                        --
                        -- Bug 1276239. Encapsulated logic to find
                        -- uom value in get_uom_value method which
                        -- will use fnd_dsql to build and execute
                        -- query.
                        -- sreharih. Thu Aug 25 12:44:00 PDT 2011
                        --

                     l_uom_value := get_uom_value (
                                        p_uom_db_column_name => 'UOM'||substr(l_augmented_data_table(j).DATABASE_COLUMN,2),
                                        p_table_name         => NVL(l_curr_ag_vl_name,l_curr_ag_table_name),
                                        p_extension_id       => l_extension_id);

                     l_curr_augmented_attr_rec.ATTR_UNIT_OF_MEASURE := l_uom_value;

                     l_conv_rate := 1;

                     SELECT CONVERSION_RATE
                       INTO l_conv_rate
                       FROM MTL_UOM_CONVERSIONS
                      WHERE UOM_CLASS = l_new_attr_metadata_obj.UNIT_OF_MEASURE_CLASS
                        AND UOM_CODE = NVL(l_uom_value, l_new_attr_metadata_obj.UNIT_OF_MEASURE_BASE)
                        AND ROWNUM = 1;

                     IF(l_conv_rate = 0) THEN l_conv_rate := 1; END IF;
                     l_curr_augmented_attr_rec.ATTR_VALUE_NUM := l_curr_augmented_attr_rec.ATTR_VALUE_NUM/l_conv_rate;
                     l_curr_augmented_attr_rec.ATTR_DISP_VALUE := l_curr_augmented_attr_rec.ATTR_VALUE_NUM;
                   END IF;
                   -- end of fixing bug 8218727
                  END IF;

                  -----------------------------------------------------------
                  -- If this is the first Data record for the current row, --
                  -- we build a Row object and put it into the row table.  --
                  -----------------------------------------------------------
                  IF (l_need_to_build_a_row_obj) THEN
                    IF (x_attributes_row_table IS NULL) THEN
                      x_attributes_row_table := EGO_USER_ATTR_ROW_TABLE();
                    END IF;
                    x_attributes_row_table.EXTEND();
                    IF l_has_data_level_col THEN
                      x_attributes_row_table(x_attributes_row_table.LAST) :=
                        EGO_USER_ATTR_ROW_OBJ(
                          l_extension_id
                         ,l_curr_augmented_attr_rec.ATTR_GROUP_ID
                         ,l_curr_augmented_attr_rec.APPLICATION_ID
                         ,l_curr_augmented_attr_rec.ATTR_GROUP_TYPE
                         ,l_curr_augmented_attr_rec.ATTR_GROUP_NAME
                         ,l_curr_ag_request_obj.data_level        -- DATA_LEVEL
                         ,l_curr_ag_request_obj.data_level_1    -- DATA_LEVEL_1
                         ,l_curr_ag_request_obj.data_level_2    -- DATA_LEVEL_2
                         ,l_curr_ag_request_obj.data_level_3    -- DATA_LEVEL_3
                         ,l_curr_ag_request_obj.data_level_4    -- DATA_LEVEL_4
                         ,l_curr_ag_request_obj.data_level_5    -- DATA_LEVEL_5
                         ,null                              -- TRANSACTION_TYPE
                        );
                    ELSE
                      x_attributes_row_table(x_attributes_row_table.LAST) :=
                        EGO_USER_ATTR_ROW_OBJ(
                          l_extension_id
                         ,l_curr_augmented_attr_rec.ATTR_GROUP_ID
                         ,l_curr_augmented_attr_rec.APPLICATION_ID
                         ,l_curr_augmented_attr_rec.ATTR_GROUP_TYPE
                         ,l_curr_augmented_attr_rec.ATTR_GROUP_NAME
                         ,NULL                                    -- DATA_LEVEL
                         ,NULL                                  -- DATA_LEVEL_1
                         ,NULL                                  -- DATA_LEVEL_2
                         ,NULL                                  -- DATA_LEVEL_3
                         ,NULL                                  -- DATA_LEVEL_4
                         ,NULL                                  -- DATA_LEVEL_5
                         ,NULL                              -- TRANSACTION_TYPE
                        );
                    END IF;
                    l_need_to_build_a_row_obj := FALSE;
                  END IF;

                  -----------------------------------------------------
                  -- Once we have the value for this Data record, we --
                  -- put a Data object for it into the result table; --
                  -- the caller will later use ROW_IDENTIFIER (which --
                  -- in our case is l_extension_id) to find a row    --
                  -- object for any data object.                     --
                  -----------------------------------------------------
                  IF (x_attributes_data_table IS NULL) THEN
                    x_attributes_data_table := EGO_USER_ATTR_DATA_TABLE();
                  END IF;

                  x_attributes_data_table.EXTEND();
                  x_attributes_data_table(x_attributes_data_table.LAST) :=
                  --changed as a part of
                  --ENHR12:for passing the internal value of the attribute along
                  --with the display value.
                    EGO_USER_ATTR_DATA_OBJ(
                      l_extension_id
                     ,l_curr_augmented_attr_rec.ATTR_NAME
                     ,l_curr_augmented_attr_rec.ATTR_VALUE_STR-- ATTR_VALUE_STR
                     ,l_curr_augmented_attr_rec.ATTR_VALUE_NUM-- ATTR_VALUE_NUM
                     ,l_curr_augmented_attr_rec.ATTR_VALUE_DATE
                                                             -- ATTR_VALUE_DATE
                     ,l_curr_augmented_attr_rec.ATTR_DISP_VALUE
                     ,l_curr_augmented_attr_rec.ATTR_UNIT_OF_MEASURE    -- ATTR_UNIT_OF_MEASURE --Bug#7662816
                     ,null                               -- USER_ROW_IDENTIFIER
                    );

Debug_Msg(l_api_name || l_curr_augmented_attr_rec.ATTR_NAME || ' = ' || l_curr_augmented_attr_rec.ATTR_VALUE_STR   );

                END IF;
              END LOOP GUAD_augmented_data_recs_loop;
            END LOOP GUAD_column_name_loop;
          END LOOP GUAD_all_attributes_loop;

          -----------------------------------------
          -- Close the cursor when we're through --
          -----------------------------------------
          IF (l_cursor_id IS NOT NULL) THEN
            DBMS_SQL.Close_Cursor(l_cursor_id);
            l_cursor_id := NULL;
          END IF;
        ELSE
Debug_Msg(l_api_name||' l_db_column_query_table.COUNT = ' || l_db_column_query_table.COUNT, 1);
        END IF;  -- l_db_column_query_table.COUNT

        l_dbcol_cntr := 0;
        l_db_column_name_table.DELETE;
        l_db_column_query_table.DELETE;
        l_request_table_index := p_attr_group_request_table.NEXT(l_request_table_index);
      END LOOP GUAD_ag_requests_loop;

    END IF;

    Debug_Msg(l_api_name||'  done', 1);

    ------------------------------------------------------
    -- We log all errors we got as we close our session --
    ------------------------------------------------------
    Close_Business_Object_Session(
      p_init_error_handler_flag       => FND_API.To_Boolean(p_init_error_handler)
     ,p_log_errors                    => TRUE
     ,p_write_to_concurrent_log       => FALSE
    );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg(l_api_name || ' FND_API.G_EXC_ERROR '||SQLERRM);
      -----------------------------------------
      -- Close the cursor if it's still open --
      -----------------------------------------
      IF (l_cursor_id IS NOT NULL) THEN
        DBMS_SQL.Close_Cursor(l_cursor_id);
        l_cursor_id := NULL;
      END IF;

      ------------------------------------------------------
      -- We log all errors we got as we close our session --
      ------------------------------------------------------
      Close_Business_Object_Session(
        p_init_error_handler_flag       => FND_API.To_Boolean(p_init_error_handler)
       ,p_log_errors                    => TRUE
       ,p_write_to_concurrent_log       => FALSE
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

      x_msg_count := ERROR_HANDLER.Get_Message_Count();
      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

    WHEN OTHERS THEN

      Debug_Msg(l_api_name || ' EXCEPTION OTHERS '||SQLERRM);
      -----------------------------------------
      -- Close the cursor if it's still open --
      -----------------------------------------
      IF (l_cursor_id IS NOT NULL) THEN
        DBMS_SQL.Close_Cursor(l_cursor_id);
        l_cursor_id := NULL;
      END IF;
      ------------------------------------------------------
      -- We log all errors we got as we close our session --
      ------------------------------------------------------
      Close_Business_Object_Session(
        p_init_error_handler_flag       => FND_API.To_Boolean(p_init_error_handler)
       ,p_log_errors                    => TRUE
       ,p_write_to_concurrent_log       => FALSE
      );

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_token_table(1).TOKEN_NAME := 'PKG_NAME';
      l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
      l_token_table(2).TOKEN_NAME := 'API_NAME';
      l_token_table(2).TOKEN_VALUE := l_api_name;
      l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
      l_token_table(3).TOKEN_VALUE := SQLERRM;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name              => 'EGO_PLSQL_ERR'
       ,p_application_id            => 'EGO'
       ,p_token_tbl                 => l_token_table
       ,p_message_type              => FND_API.G_RET_STS_ERROR
       ,p_row_identifier            => G_USER_ROW_IDENTIFIER
       ,p_entity_id                 => p_entity_id
       ,p_entity_index              => p_entity_index
       ,p_entity_code               => p_entity_code
       ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
      );
      l_token_table.DELETE();
      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          IF message_list IS NOT NULL AND message_list.count > 0 THEN
            x_msg_data := message_list(message_list.FIRST).message_text;
          ELSE
            x_msg_data := 'Where from did I come here?? ';
          END IF;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

END Get_User_Attrs_Data;

----------------------------------------------------------------------

PROCEDURE Process_Row (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_validate_hierarchy            IN   VARCHAR2   DEFAULT FND_API.G_TRUE--Added for bugFix:5275391
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_validate_only                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_language_to_process           IN   VARCHAR2   DEFAULT NULL
       ,p_mode                          IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT NULL
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_raise_business_event          IN   BOOLEAN DEFAULT TRUE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
    l_extension_id           NUMBER;
    l_mode                   VARCHAR2(10);

  BEGIN

      Process_Row(
        p_api_version                   => p_api_version
       ,p_object_name                   => p_object_name
       ,p_attr_group_id                 => p_attr_group_id
       ,p_application_id                => p_application_id
       ,p_attr_group_type               => p_attr_group_type
       ,p_attr_group_name               => p_attr_group_name
       ,p_validate_hierarchy            => p_validate_hierarchy
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => p_extension_id
       ,p_attr_name_value_pairs         => p_attr_name_value_pairs
       ,p_validate_only                 => p_validate_only
       ,p_language_to_process           => p_language_to_process --bug 	10065435
       ,p_mode                          => p_mode
       ,p_change_obj                    => p_change_obj
       ,p_pending_b_table_name          => p_pending_b_table_name
       ,p_pending_tl_table_name         => p_pending_tl_table_name
       ,p_pending_vl_name               => p_pending_vl_name
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_raise_business_event                   => p_raise_business_event
       ,x_extension_id                  => l_extension_id
       ,x_mode                          => l_mode
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
      );

END Process_Row;

------------------------------------------------------------------------------------------

PROCEDURE Process_Row (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_validate_hierarchy            IN   VARCHAR2   DEFAULT FND_API.G_TRUE--Added for bugFix:5275391
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_validate_only                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_language_to_process           IN   VARCHAR2   DEFAULT NULL
       ,p_mode                          IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT NULL
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_raise_business_event          IN   BOOLEAN DEFAULT TRUE
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_mode                          OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Process_Row';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_object_id              NUMBER;
    l_attr_name_value_pairs   EGO_USER_ATTR_DATA_TABLE;
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    l_extension_id           NUMBER;
    l_mode                   VARCHAR2(10);


  BEGIN

    Debug_Msg(l_api_name || ' starting ',1);

    -- SAVEPOINT Process_Row_PUB;
    -- (See EXCEPTION notes for why this is commented out)

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_object_id := p_object_id;
    l_attr_name_value_pairs := p_attr_name_value_pairs;

    Debug_Msg(l_api_name || ' calling  Perform_Setup_Operations ',1);
    Perform_Setup_Operations(
        p_object_name                   => p_object_name
       ,p_attr_group_id                 => p_attr_group_id
       ,p_application_id                => p_application_id
       ,p_attr_group_type               => p_attr_group_type
       ,p_attr_group_name               => p_attr_group_name
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => p_extension_id
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_mode                          => p_mode
       ,p_change_obj                    => p_change_obj
       ,p_pending_b_table_name          => p_pending_b_table_name
       ,p_pending_vl_name               => p_pending_vl_name
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,px_object_id                    => l_object_id
       ,px_attr_name_value_pairs        => l_attr_name_value_pairs
       ,x_attr_group_metadata_obj       => l_attr_group_metadata_obj
       ,x_ext_table_metadata_obj        => l_ext_table_metadata_obj
       ,x_extension_id                  => l_extension_id
       ,x_mode                          => l_mode
       ,x_return_status                 => x_return_status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_extension_id IS NOT NULL THEN
      x_extension_id := l_extension_id;
    END IF;

    IF l_mode IS NOT NULL THEN
      x_mode := l_mode;
    END IF;

    ------------------------------------------------------------
    -- If the Attr Group is secured (either explicitly or by  --
    -- default privileges for this Object) AND the caller has --
    -- passed a table of privileges, then we ensure that the  --
    -- user has the required privileges for this Attr Group   --
    ------------------------------------------------------------
    IF ((l_attr_group_metadata_obj.VIEW_PRIVILEGE IS NOT NULL OR
         l_attr_group_metadata_obj.EDIT_PRIVILEGE IS NOT NULL) AND
        G_CURRENT_USER_PRIVILEGES IS NOT NULL) THEN

    Debug_Msg(l_api_name || ' calling Check_Privileges ',1);
      Check_Privileges(
        p_attr_group_metadata_obj  => l_attr_group_metadata_obj
       ,p_data_level_row_obj       => NULL
       ,p_entity_id                => p_entity_id
       ,p_entity_index             => p_entity_index
       ,p_entity_code              => p_entity_code
       ,x_return_status            => x_return_status
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    IF (l_mode IS NULL OR
        l_mode <> G_DELETE_MODE) THEN

    Debug_Msg(l_api_name || ' calling Validate_Row_Pvt ',1);
      Validate_Row_Pvt(
        p_api_version                   => p_api_version
       ,p_object_id                     => l_object_id
       ,p_validate_hierarchy            => p_validate_hierarchy
       ,p_attr_group_metadata_obj       => l_attr_group_metadata_obj
       ,p_ext_table_metadata_obj        => l_ext_table_metadata_obj
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => l_extension_id
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_mode                          => l_mode
       ,px_attr_name_value_pairs        => l_attr_name_value_pairs
       ,x_return_status                 => x_return_status
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;


    IF( p_validate_only = FND_API.G_FALSE) THEN

      Debug_Msg(l_api_name||' done with Validate_Row_Pvt and about to call Perform_DML_On_Row_Pvt', 2);

      Perform_DML_On_Row_Pvt(
          p_api_version                   => p_api_version
         ,p_object_id                     => l_object_id
         ,p_attr_group_metadata_obj       => l_attr_group_metadata_obj
         ,p_ext_table_metadata_obj        => l_ext_table_metadata_obj
         ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
         ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
         ,p_data_level                    => p_data_level
         ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
         ,p_extension_id                  => l_extension_id
         ,p_attr_name_value_pairs         => l_attr_name_value_pairs
         ,p_language_to_process           => p_language_to_process
         ,p_mode                          => l_mode
         ,p_change_obj                    => p_change_obj
         ,p_pending_b_table_name          => p_pending_b_table_name
         ,p_pending_tl_table_name         => p_pending_tl_table_name
         ,p_entity_id                     => p_entity_id
         ,p_entity_index                  => p_entity_index
         ,p_entity_code                   => p_entity_code
         ,p_commit                        => FND_API.G_FALSE
         ,p_raise_business_event          => p_raise_business_event
         ,x_extension_id                  => x_extension_id
         ,x_return_status                 => x_return_status
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      Debug_Msg('In Process_Row, done', 1);

    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    ----------------------------------------------------------------------------
    -- We don't do a ROLLBACK in this exception block; all exceptions will    --
    -- be either from nested API calls failing, in which case those APIs      --
    -- will have done ROLLBACKs already, or from some errors in this API      --
    -- itself, which doesn't do any DML operations and so has nothing to      --
    -- roll back.  (Also, when I was building this package and had a ROLLBACK --
    -- call in this exception block, I kept getting the following error:      --
    --                                                                        --
    --       'ORA-01086: savepoint 'PROCESS_ROW_PUB' never established'       --
    --                                                                        --
    -- so I took out the ROLLBACK call, which wasn't necessary anyway.)       --
    ----------------------------------------------------------------------------

    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg(l_api_name || ' EXCEPTION FND_API.G_EXC_ERROR');

      IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;
      x_msg_count := ERROR_HANDLER.Get_Message_Count();
      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

    WHEN OTHERS THEN
      Debug_Msg(l_api_name || ' EXCEPTION OTHERS '||SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_PLSQL_ERR'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => G_USER_ROW_IDENTIFIER
         ,p_entity_id         => p_entity_id
         ,p_entity_index      => p_entity_index
         ,p_entity_code       => p_entity_code
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );
      END;

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

END Process_Row;

----------------------------------------------------------------------

-- This version just performs some preliminary setup operations and
-- and then calls the "private" signature, Validate_Row_Pvt

PROCEDURE Validate_Row (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_mode                          IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Validate_Row';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_object_id              NUMBER;
    l_attr_name_value_pairs   EGO_USER_ATTR_DATA_TABLE;
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    l_extension_id           NUMBER;
    l_mode                   VARCHAR2(10);

  BEGIN

    Debug_Msg(l_api_name||' starting ', 1);

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Validate_Row_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

-----------------------------------

    l_object_id := p_object_id;
    l_attr_name_value_pairs := p_attr_name_value_pairs;

    Perform_Setup_Operations(
        p_object_name                   => p_object_name
       ,p_attr_group_id                 => p_attr_group_id
       ,p_application_id                => p_application_id
       ,p_attr_group_type               => p_attr_group_type
       ,p_attr_group_name               => p_attr_group_name
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => p_extension_id
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_mode                          => p_mode
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,px_object_id                    => l_object_id
       ,px_attr_name_value_pairs        => l_attr_name_value_pairs
       ,x_attr_group_metadata_obj       => l_attr_group_metadata_obj
       ,x_ext_table_metadata_obj        => l_ext_table_metadata_obj
       ,x_extension_id                  => l_extension_id
       ,x_mode                          => l_mode
       ,x_return_status                 => x_return_status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    Debug_Msg(l_api_name||' calling Validate_Row_Pvt ', 1);
    Validate_Row_Pvt(
        p_api_version                   => p_api_version
       ,p_object_id                     => l_object_id
       ,p_attr_group_metadata_obj       => l_attr_group_metadata_obj
       ,p_ext_table_metadata_obj        => l_ext_table_metadata_obj
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => l_extension_id
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_mode                          => l_mode
       ,px_attr_name_value_pairs        => l_attr_name_value_pairs
       ,x_return_status                 => x_return_status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    Close_Business_Object_Session(
      p_init_error_handler_flag       => FALSE
     ,p_log_errors                    => FND_API.To_Boolean(p_log_errors)
     ,p_write_to_concurrent_log       => FND_API.To_Boolean(p_write_to_concurrent_log)
    );

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    Debug_Msg(l_api_name||' ending ', 1);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg(l_api_name || ' EXCEPTION FND_API.G_EXC_ERROR');
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Validate_Row_PUB;
      END IF;
      Close_Business_Object_Session(
        p_init_error_handler_flag     => FALSE
       ,p_log_errors                  => FND_API.To_Boolean(p_log_errors)
       ,p_write_to_concurrent_log     => FND_API.To_Boolean(p_write_to_concurrent_log)
      );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();
      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

    WHEN OTHERS THEN
      Debug_Msg(l_api_name || ' EXCEPTION OTHERS '||SQLERRM);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Validate_Row_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_PLSQL_ERR'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => G_USER_ROW_IDENTIFIER
         ,p_entity_id         => p_entity_id
         ,p_entity_index      => p_entity_index
         ,p_entity_code       => p_entity_code
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );
      END;

      Close_Business_Object_Session(
        p_init_error_handler_flag     => FALSE
       ,p_log_errors                  => FND_API.To_Boolean(p_log_errors)
       ,p_write_to_concurrent_log     => FND_API.To_Boolean(p_write_to_concurrent_log)
      );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

END Validate_Row;


----------------------------------------------------------------------

-- The API returns the complete DML for a given attribute group
-- with the corresponding binds. In case the DML is to be done
-- on a table other than the one seeded for the given attr group
-- type the table names can be passed as p_alternate_ext_*_table_name
----------------------------------------------------------------------

PROCEDURE Generate_DML_For_Row (
        p_api_version                      IN   NUMBER
       ,p_object_id                        IN   NUMBER     DEFAULT NULL
       ,p_object_name                      IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                    IN   NUMBER     DEFAULT NULL
       ,p_application_id                   IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type                  IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name                  IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs       IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                       IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                     IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs            IN   EGO_USER_ATTR_DATA_TABLE
       ,p_mode                             IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_extra_pk_col_name_val_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_extra_attr_name_value_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_alternate_ext_b_table_name       IN   VARCHAR2   DEFAULT NULL
       ,p_alternate_ext_tl_table_name      IN   VARCHAR2   DEFAULT NULL
       ,p_alternate_ext_vl_name            IN   VARCHAR2   DEFAULT NULL
       ,p_execute_dml                      IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_entity_id                        IN   NUMBER     DEFAULT NULL
       ,p_entity_index                     IN   NUMBER     DEFAULT NULL
       ,p_entity_code                      IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                      IN   NUMBER     DEFAULT 0
       ,p_use_def_vals_on_insert           IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list                IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log          IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack          IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                           IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_bulkload_flag                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_raise_business_event             IN   BOOLEAN DEFAULT TRUE
       ,x_return_status                    OUT NOCOPY VARCHAR2
       ,x_errorcode                        OUT NOCOPY NUMBER
       ,x_msg_count                        OUT NOCOPY NUMBER
       ,x_msg_data                         OUT NOCOPY VARCHAR2
       ,x_b_dml_for_ag                     OUT NOCOPY VARCHAR2
       ,x_tl_dml_for_ag                    OUT NOCOPY VARCHAR2
       ,x_b_bind_count                     OUT NOCOPY NUMBER
       ,x_tl_bind_count                    OUT NOCOPY NUMBER
       ,x_b_bind_attr_table                OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_tl_bind_attr_table               OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
 ) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Generate_DML_For_Row';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_object_id              NUMBER;
    l_attr_name_value_pairs   EGO_USER_ATTR_DATA_TABLE;
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    l_extension_id           NUMBER;
    l_mode                   VARCHAR2(10);
    l_dml                    VARCHAR2(32767);
    l_b_dml_bind_list        EGO_USER_ATTR_DATA_TABLE;
    l_tl_dml_bind_list       EGO_USER_ATTR_DATA_TABLE;
    l_bind_name              VARCHAR2(100);

  BEGIN

    Debug_Msg(l_api_name||' starting ', 1);
    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (FND_API.To_Boolean(p_init_fnd_msg_list)) THEN
      ERROR_HANDLER.Initialize();
    END IF;

    G_B_TABLE_DML   := '';
    G_TL_TABLE_DML  := '';
    G_BIND_INDEX    := 0;
    G_TL_BIND_INDEX := 0;
    G_B_BIND_INDEX  := 0;

   FOR i IN 1 .. 100 LOOP

    G_BIND_IDENTIFIER_TBL(i) := NULL;
    G_BIND_DATATYPE_TBL(i) := NULL;
    G_BIND_TEXT_TBL(i) := NULL;
    G_BIND_DATE_TBL(i) := NULL;
    G_BIND_NUMBER_TBL(i) := NULL;

    G_B_BIND_IDENTIFIER_TBL(i) := NULL;
    G_B_BIND_DATATYPE_TBL(i) := NULL;
    G_B_BIND_TEXT_TBL(i) := NULL;
    G_B_BIND_DATE_TBL(i) := NULL;
    G_B_BIND_NUMBER_TBL(i) := NULL;

    G_TL_BIND_IDENTIFIER_TBL(i) := NULL;
    G_TL_BIND_DATATYPE_TBL(i) := NULL;
    G_TL_BIND_TEXT_TBL(i) := NULL;
    G_TL_BIND_DATE_TBL(i) := NULL;
    G_TL_BIND_NUMBER_TBL(i) := NULL;

   END LOOP;

    G_SYNC_TO_UPDATE := 'N';
    l_object_id := p_object_id;
    l_attr_name_value_pairs := p_attr_name_value_pairs;

    Perform_Setup_Operations(
        p_object_name                   => p_object_name
       ,p_attr_group_id                 => p_attr_group_id
       ,p_application_id                => p_application_id
       ,p_attr_group_type               => p_attr_group_type
       ,p_attr_group_name               => p_attr_group_name
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => p_extension_id
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_mode                          => p_mode
       ,p_extra_pk_col_name_val_pairs   => p_extra_pk_col_name_val_pairs
       ,p_pending_b_table_name          => p_alternate_ext_b_table_name
       ,p_pending_vl_name               => p_alternate_ext_vl_name
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,p_use_def_vals_on_insert_flag   => FND_API.To_Boolean(p_use_def_vals_on_insert)
       ,p_debug_level                   => p_debug_level
       ,p_bulkload_flag                 => FND_API.To_Boolean(p_bulkload_flag)
       ,px_object_id                    => l_object_id
       ,px_attr_name_value_pairs        => l_attr_name_value_pairs
       ,x_attr_group_metadata_obj       => l_attr_group_metadata_obj
       ,x_ext_table_metadata_obj        => l_ext_table_metadata_obj
       ,x_extension_id                  => l_extension_id
       ,x_mode                          => l_mode
       ,x_return_status                 => x_return_status
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    Debug_Msg(l_api_name||' calling  Perform_DML_On_Row_Pvt', 1);
    Perform_DML_On_Row_Pvt(
        p_api_version                   => p_api_version
       ,p_object_id                     => l_object_id
       ,p_attr_group_metadata_obj       => l_attr_group_metadata_obj
       ,p_ext_table_metadata_obj        => l_ext_table_metadata_obj
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => p_extension_id
       ,p_attr_name_value_pairs         => l_attr_name_value_pairs
       ,p_mode                          => l_mode
       ,p_extra_pk_col_name_val_pairs   => p_extra_pk_col_name_val_pairs
       ,p_extra_attr_name_value_pairs   => p_extra_attr_name_value_pairs
       ,p_pending_b_table_name          => p_alternate_ext_b_table_name
       ,p_pending_tl_table_name         => p_alternate_ext_tl_table_name
       ,p_execute_dml                   => p_execute_dml
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_commit                        => FND_API.G_FALSE
       ,p_raise_business_event          => p_raise_business_event
       ,p_bulkload_flag                 => FND_API.To_Boolean(p_bulkload_flag)
       ,x_extension_id                  => l_extension_id
       ,x_return_status                 => x_return_status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_b_dml_for_ag      := G_B_TABLE_DML;
    x_tl_dml_for_ag     := G_TL_TABLE_DML;
    x_b_bind_count      := G_B_BIND_INDEX;
    x_tl_bind_count     := G_TL_BIND_INDEX;

    l_b_dml_bind_list   := EGO_USER_ATTR_DATA_TABLE();
    l_tl_dml_bind_list  := EGO_USER_ATTR_DATA_TABLE();

    FOR i in 1 .. G_B_BIND_INDEX
    LOOP

      l_bind_name := ':FND_BIND'||TO_CHAR(i);
      l_b_dml_bind_list.EXTEND();
      IF(G_B_BIND_DATATYPE_TBL(i) = 'D') THEN
        l_b_dml_bind_list(i) := EGO_USER_ATTR_DATA_OBJ(NULL,l_bind_name,NULL,NULL,G_B_BIND_DATE_TBL(i),G_B_BIND_IDENTIFIER_TBL(i),NULL,NULL);
      ELSIF (G_B_BIND_DATATYPE_TBL(i) = 'N') THEN
        l_b_dml_bind_list(i) := EGO_USER_ATTR_DATA_OBJ(NULL,l_bind_name,NULL,G_B_BIND_NUMBER_TBL(i),NULL,G_B_BIND_IDENTIFIER_TBL(i),NULL,NULL);
      ELSE
        l_b_dml_bind_list(i) := EGO_USER_ATTR_DATA_OBJ(NULL,l_bind_name,G_B_BIND_TEXT_TBL(i),NULL,NULL,G_B_BIND_IDENTIFIER_TBL(i),NULL,NULL);
      END IF;
    END LOOP;


    FOR j in 1 .. G_TL_BIND_INDEX
    LOOP

      l_bind_name := ':FND_BIND'||TO_CHAR(j);
      l_tl_dml_bind_list.EXTEND();
      IF(G_TL_BIND_DATATYPE_TBL(j) = 'D') THEN
        l_tl_dml_bind_list(j) := EGO_USER_ATTR_DATA_OBJ(NULL,l_bind_name,NULL,NULL,G_TL_BIND_DATE_TBL(j),G_TL_BIND_IDENTIFIER_TBL(j),NULL,NULL);
      ELSIF (G_TL_BIND_DATATYPE_TBL(j) = 'N') THEN
        l_tl_dml_bind_list(j) := EGO_USER_ATTR_DATA_OBJ(NULL,l_bind_name,NULL,G_TL_BIND_NUMBER_TBL(j),NULL,G_TL_BIND_IDENTIFIER_TBL(j),NULL,NULL);
      ELSE
        l_tl_dml_bind_list(j) := EGO_USER_ATTR_DATA_OBJ(NULL,l_bind_name,G_TL_BIND_TEXT_TBL(j),NULL,NULL,G_TL_BIND_IDENTIFIER_TBL(j),NULL,NULL);
      END IF;
    END LOOP;

    x_b_bind_attr_table  := l_b_dml_bind_list;
    x_tl_bind_attr_table := l_tl_dml_bind_list;

    Close_Business_Object_Session(
      p_init_error_handler_flag       => (p_debug_level > 0)
     ,p_log_errors                    => FND_API.To_Boolean(p_log_errors)
     ,p_write_to_concurrent_log       => FND_API.To_Boolean(p_write_to_concurrent_log)
    );

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Debug_Msg(l_api_name||' ending ', 1);

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg(l_api_name || ' EXCEPTION FND_API.G_EXC_ERROR');

      Close_Business_Object_Session(
        p_init_error_handler_flag     => (p_debug_level > 0)
       ,p_log_errors                  => FND_API.To_Boolean(p_log_errors)
       ,p_write_to_concurrent_log     => FND_API.To_Boolean(p_write_to_concurrent_log)
      );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();
      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

    WHEN OTHERS THEN
      Debug_Msg(l_api_name || ' EXCEPTION OTHERS '||SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_PLSQL_ERR'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => G_USER_ROW_IDENTIFIER
         ,p_entity_id         => p_entity_id
         ,p_entity_index      => p_entity_index
         ,p_entity_code       => p_entity_code
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );
      END;

      Close_Business_Object_Session(
        p_init_error_handler_flag     => (p_debug_level > 0)
       ,p_log_errors                  => FND_API.To_Boolean(p_log_errors)
       ,p_write_to_concurrent_log     => FND_API.To_Boolean(p_write_to_concurrent_log)
      );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

END Generate_DML_For_Row;

----------------------------------------------------------------------



----------------------------------------------------------------------
-- This API returns the extension id of the attr group row          --
----------------------------------------------------------------------

FUNCTION Get_Extension_Id (
        p_object_name                      IN   VARCHAR2
       ,p_attr_group_id                    IN   NUMBER     DEFAULT NULL
       ,p_application_id                   IN   NUMBER
       ,p_attr_group_type                  IN   VARCHAR2
       ,p_attr_group_name                  IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs       IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                       IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_name_value_pairs            IN   EGO_USER_ATTR_DATA_TABLE
       ,p_extra_pk_col_name_val_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_extra_attr_name_value_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_alternate_ext_b_table_name       IN   VARCHAR2   DEFAULT NULL
       ,p_alternate_ext_tl_table_name      IN   VARCHAR2   DEFAULT NULL
       ,p_alternate_ext_vl_name            IN   VARCHAR2   DEFAULT NULL
       ) RETURN NUMBER
 IS

    l_attr_name_value_pairs   EGO_USER_ATTR_DATA_TABLE;
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_ext_table_metadata_obj  EGO_EXT_TABLE_METADATA_OBJ;
    l_ext_id                  NUMBER;
    l_object_id               NUMBER;

 BEGIN

    l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(p_attr_group_id
                                                                                  ,p_application_id
                                                                                  ,p_attr_group_type
                                                                                  ,p_attr_group_name);
    BEGIN
      SELECT OBJECT_ID INTO l_object_id
        FROM FND_OBJECTS
       WHERE OBJ_NAME = p_object_name;
    EXCEPTION
      WHEN OTHERS THEN
       NULL;
    END;

    l_ext_table_metadata_obj :=  EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(l_object_id);

    l_ext_id := Get_Extension_Id_For_Row(
                                          p_attr_group_metadata_obj     => l_attr_group_metadata_obj
                                         ,p_ext_table_metadata_obj      => l_ext_table_metadata_obj
                                         ,p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
                                         ,p_data_level                  => p_data_level
                                         ,p_data_level_name_value_pairs => p_data_level_name_value_pairs
                                         ,p_attr_name_value_pairs       => p_attr_name_value_pairs
                                         ,p_extra_pk_col_name_val_pairs => p_extra_pk_col_name_val_pairs
                                         ,p_pending_b_table_name        => p_alternate_ext_b_table_name
                                         ,p_pending_vl_name             => p_alternate_ext_vl_name
                                        );
    RETURN l_ext_id;

 END Get_Extension_Id;



--gnanda end






----------------------------------------------------------------------

-- This version just performs some preliminary setup operations and
-- and then calls the "private" signature, Perform_DML_On_Row_Pvt

PROCEDURE Perform_DML_On_Row (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_mode                          IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_use_def_vals_on_insert        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_bulkload_flag                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
    l_extension_id           NUMBER;
    l_mode                   VARCHAR2(10);
  BEGIN

    Perform_DML_On_Row(
        p_api_version                   => p_api_version
       ,p_object_id                     => p_object_id
       ,p_object_name                   => p_object_name
       ,p_attr_group_id                 => p_attr_group_id
       ,p_application_id                => p_application_id
       ,p_attr_group_type               => p_attr_group_type
       ,p_attr_group_name               => p_attr_group_name
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level --R12C
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => p_extension_id
       ,p_attr_name_value_pairs         => p_attr_name_value_pairs
       ,p_mode                          => p_mode
       ,p_change_obj                    => p_change_obj
       ,p_pending_b_table_name          => p_pending_b_table_name
       ,p_pending_tl_table_name         => p_pending_tl_table_name
       ,p_pending_vl_name               => p_pending_vl_name
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_debug_level                   => p_debug_level
       ,p_use_def_vals_on_insert        => p_use_def_vals_on_insert
       ,p_log_errors                    => p_log_errors
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_write_to_concurrent_log       => p_write_to_concurrent_log
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,p_commit                        => p_commit
       ,p_bulkload_flag                 => p_bulkload_flag
       ,x_extension_id                  => l_extension_id
       ,x_mode                          => l_mode
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

END Perform_DML_On_Row;

----------------------------------------------------------------------

/* Overload method with additional parameters x_extension_id, x_mode */

PROCEDURE Perform_DML_On_Row (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_mode                          IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_use_def_vals_on_insert        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_bulkload_flag                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       --Added by geguo for 9373845 begin
       ,p_creation_date                 IN   DATE       DEFAULT NULL
       ,p_last_update_date              IN   DATE       DEFAULT NULL
       --Added by geguo 9373845 end
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_mode                          OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Perform_DML_On_Row';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_object_id              NUMBER;
    l_attr_name_value_pairs   EGO_USER_ATTR_DATA_TABLE;
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    l_extension_id           NUMBER;
    l_mode                   VARCHAR2(10);


  BEGIN
    --Added by geguo for 9373845
    G_WHO_CREATION_DATE      := p_creation_date;
    G_WHO_LAST_UPDATE_DATE   := p_last_update_date;
    Debug_Msg(l_api_name||' starting with data_level = '||p_data_level, 1);

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Perform_DML_On_Row_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (FND_API.To_Boolean(p_init_fnd_msg_list)) THEN
      ERROR_HANDLER.Initialize();
    END IF;
    G_SYNC_TO_UPDATE := 'N';
    l_object_id := p_object_id;
    l_attr_name_value_pairs := p_attr_name_value_pairs;

    Perform_Setup_Operations(
        p_object_name                   => p_object_name
       ,p_attr_group_id                 => p_attr_group_id
       ,p_application_id                => p_application_id
       ,p_attr_group_type               => p_attr_group_type
       ,p_attr_group_name               => p_attr_group_name
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => p_extension_id
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_mode                          => p_mode
       ,p_change_obj                    => p_change_obj
       ,p_pending_b_table_name          => p_pending_b_table_name
       ,p_pending_vl_name               => p_pending_vl_name
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,p_use_def_vals_on_insert_flag   => FND_API.To_Boolean(p_use_def_vals_on_insert)
       ,p_debug_level                   => p_debug_level
       ,p_bulkload_flag                 => FND_API.To_Boolean(p_bulkload_flag)
       ,px_object_id                    => l_object_id
       ,px_attr_name_value_pairs        => l_attr_name_value_pairs
       ,x_attr_group_metadata_obj       => l_attr_group_metadata_obj
       ,x_ext_table_metadata_obj        => l_ext_table_metadata_obj
       ,x_extension_id                  => x_extension_id
       ,x_mode                          => x_mode
       ,x_return_status                 => x_return_status
    );
    IF p_mode = 'SYNC'  --doing it for GTIN Attribute Group
       AND (l_mode = 'UPDATE'
            AND p_attr_group_type in ('EGO_ITEM_GTIN_ATTRS','EGO_ITEM_GTIN_MULTI_ATTRS'))
    THEN
      G_SYNC_TO_UPDATE := 'Y' ;
    END IF;
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_extension_id := x_extension_id;
    l_mode         := x_mode;

    Debug_Msg(l_api_name||' calling Perform_DML_On_Row_Pvt', 1);

    Perform_DML_On_Row_Pvt(
        p_api_version                   => p_api_version
       ,p_object_id                     => l_object_id
       ,p_attr_group_metadata_obj       => l_attr_group_metadata_obj
       ,p_ext_table_metadata_obj        => l_ext_table_metadata_obj
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => l_extension_id
       ,p_attr_name_value_pairs         => l_attr_name_value_pairs
       ,p_mode                          => l_mode
       ,p_change_obj                    => p_change_obj
       ,p_pending_b_table_name          => p_pending_b_table_name
       ,p_pending_tl_table_name         => p_pending_tl_table_name
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_commit                        => FND_API.G_FALSE
       ,p_bulkload_flag                 => FND_API.To_Boolean(p_bulkload_flag)
       ,x_extension_id                  => x_extension_id
       ,x_return_status                 => x_return_status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    Close_Business_Object_Session(
      p_init_error_handler_flag       => (p_debug_level > 0)
     ,p_log_errors                    => FND_API.To_Boolean(p_log_errors)
     ,p_write_to_concurrent_log       => FND_API.To_Boolean(p_write_to_concurrent_log)
    );

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg(l_api_name || ' EXCEPTION FND_API.G_EXC_ERROR');
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Perform_DML_On_Row_PUB;
      END IF;
      Close_Business_Object_Session(
        p_init_error_handler_flag     => (p_debug_level > 0)
       ,p_log_errors                  => FND_API.To_Boolean(p_log_errors)
       ,p_write_to_concurrent_log     => FND_API.To_Boolean(p_write_to_concurrent_log)
      );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();
      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

    WHEN OTHERS THEN
      Debug_Msg(l_api_name || ' EXCEPTION OTHERS '||SQLERRM);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Perform_DML_On_Row_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_PLSQL_ERR'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => G_USER_ROW_IDENTIFIER
         ,p_entity_id         => p_entity_id
         ,p_entity_index      => p_entity_index
         ,p_entity_code       => p_entity_code
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );
      END;

      Close_Business_Object_Session(
        p_init_error_handler_flag     => (p_debug_level > 0)
       ,p_log_errors                  => FND_API.To_Boolean(p_log_errors)
       ,p_write_to_concurrent_log     => FND_API.To_Boolean(p_write_to_concurrent_log)
      );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

END Perform_DML_On_Row;

----------------------------------------------------------------------
-- Public
----------------------------------------------------------------------

PROCEDURE Perform_DML_From_Template (
        p_api_version                   IN   NUMBER
       ,p_template_id                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2 DEFAULT NULL
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_attr_group_ids_to_exclude     IN   EGO_NUMBER_TBL_TYPE           DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Perform_DML_From_Template';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_object_id              NUMBER;
    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    l_class_code_hierarchy   VARCHAR2(16000);
    l_last_loop_index        NUMBER;
    l_this_loop_index        NUMBER;
    l_decode_index           NUMBER;
    l_cc_hierarchy_for_decode VARCHAR2(16100);
    l_dynamic_sql            VARCHAR2(30000);
    l_prev_loop_ag_id        NUMBER;
    l_prev_loop_row_number   NUMBER;
    l_at_start_of_ag         BOOLEAN;
    l_at_start_of_row        BOOLEAN;
    l_row_index              NUMBER := 0;
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_attr_name_value_pairs  EGO_USER_ATTR_DATA_TABLE;
    l_extension_id           NUMBER;
    l_mode                   VARCHAR2(10);
    l_attr_group_ids_to_exclude VARCHAR2(16000);
    l_attr_group_id          NUMBER;
    l_cursor_id              NUMBER;
    l_rows_fetched           NUMBER;
    l_cc_data_type           VARCHAR2(8);
    l_next_cc                VARCHAR2(150);
    l_cc_begin_pos           NUMBER;
    l_is_last_cc             BOOLEAN;
    --Start Bug 5211171
    l_rev_level              VARCHAR2(1000);
    l_decode_query           VARCHAR2(32767);
    --End Bug 5211171
    l_data_level_id          NUMBER;
    l_Perform_DML_On_Template_Row     VARCHAR2(1);

    TYPE TEMPL_ATTR_REC IS RECORD (
        ATTRIBUTE_GROUP_ID          EGO_TEMPL_ATTRIBUTES.ATTRIBUTE_GROUP_ID%TYPE
       ,ATTRIBUTE_ID                EGO_TEMPL_ATTRIBUTES.ATTRIBUTE_ID%TYPE
       ,ROW_NUMBER                  EGO_TEMPL_ATTRIBUTES.ROW_NUMBER%TYPE
       ,ATTRIBUTE_STRING_VALUE      EGO_TEMPL_ATTRIBUTES.ATTRIBUTE_STRING_VALUE%TYPE
       ,ATTRIBUTE_NUMBER_VALUE      EGO_TEMPL_ATTRIBUTES.ATTRIBUTE_NUMBER_VALUE%TYPE
       ,ATTRIBUTE_UOM_CODE          EGO_TEMPL_ATTRIBUTES.ATTRIBUTE_UOM_CODE%TYPE
       ,ATTRIBUTE_DATE_VALUE        EGO_TEMPL_ATTRIBUTES.ATTRIBUTE_DATE_VALUE%TYPE
       ,ATTRIBUTE_TRANSLATED_VALUE  EGO_TEMPL_ATTRIBUTES.ATTRIBUTE_TRANSLATED_VALUE%TYPE
                                  );
    l_templ_attr_rec         TEMPL_ATTR_REC;

  BEGIN
    Debug_Msg(l_api_name||' starting ', 1);

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Perform_DML_From_Template;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ------------------------------------------------------------------
    -- Initialize the Business Object (flags, error-handling, etc.) --
    ------------------------------------------------------------------
    Set_Up_Business_Object_Session(
        p_bulkload_flag                => FALSE
       ,p_debug_level                  => p_debug_level
       ,p_init_error_handler_flag      => TRUE
       ,p_object_name                  => p_object_name
       ,p_pk_column_name_value_pairs   => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs  => p_class_code_name_value_pairs
       ,p_init_fnd_msg_list            => p_init_fnd_msg_list
       ,p_add_errors_to_fnd_stack      => p_add_errors_to_fnd_stack
       ,p_default_user_row_identifier  => l_row_index
       ,x_return_status                => x_return_status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    ----------------------------------------------
    -- Get the Object ID and Ext Table metadata --
    ----------------------------------------------
    l_object_id := Get_Object_Id_From_Name(p_object_name);

    l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(l_object_id);

    -----------------------------------------------------------------
    -- Build a DECODE string for the Classification Code Hierarchy --
    -----------------------------------------------------------------
    WHILE (INSTR(l_class_code_hierarchy, ',', (l_last_loop_index + 1)) > 0)
    LOOP

      l_this_loop_index := INSTR(l_class_code_hierarchy, ',', (l_last_loop_index + 1));
      l_cc_hierarchy_for_decode := l_cc_hierarchy_for_decode ||
                                   SUBSTR(l_class_code_hierarchy
                                         ,l_last_loop_index
                                         ,(l_this_loop_index - l_last_loop_index)) ||
                                   ', ' || l_decode_index;

      l_decode_index := l_decode_index + 1;
      l_last_loop_index := l_this_loop_index;

    END LOOP;

    l_cc_hierarchy_for_decode := l_cc_hierarchy_for_decode ||
          SUBSTR(l_class_code_hierarchy,l_last_loop_index) ||
          ', ' || l_decode_index;

    Debug_Msg(l_api_name||' l_cc_hierarchy_for_decode '|| l_cc_hierarchy_for_decode, 1);
    -----------------------------------------------------------------
    -- Build a list of attribute group ids to exclude from the     --
    -- query useful for applying a template while ignoring         --
    -- attribute groups under change control (part of bug 3781216) --
    -----------------------------------------------------------------
    l_attr_group_ids_to_exclude := '';
    IF (p_attr_group_ids_to_exclude IS NOT NULL AND
        p_attr_group_ids_to_exclude.COUNT > 0) THEN

      l_attr_group_ids_to_exclude := ' AND ETA_OUTER.ATTRIBUTE_GROUP_ID NOT IN ( ';

      FOR i IN p_attr_group_ids_to_exclude.FIRST .. p_attr_group_ids_to_exclude.LAST
      LOOP
        l_attr_group_id := p_attr_group_ids_to_exclude(i);
        l_attr_group_ids_to_exclude := l_attr_group_ids_to_exclude || l_attr_group_id || ',';
      END LOOP;

      -- Get rid of trailing comma
      l_attr_group_ids_to_exclude := RTRIM(l_attr_group_ids_to_exclude, ',') || ' ) ';

    END IF;

    -----------------------------------------------------------------
    -- Build a Dynamic SQL query to get all Attributes for which   --
    -- the passed-in Template has enabled values in the current    --
    -- Classification Code hierarchy (the query returns the lowest --
    -- level values, thus implementing Template value inheritance  --
    -- and overriding)                                             --
    -----------------------------------------------------------------
    l_cursor_id := DBMS_SQL.Open_Cursor;
    Init();
    FND_DSQL.Add_Text(
      'SELECT ETA_OUTER.ATTRIBUTE_GROUP_ID,' ||
            ' ETA_OUTER.ATTRIBUTE_ID,' ||
            ' ETA_OUTER.ROW_NUMBER,' ||
            ' ETA_OUTER.ATTRIBUTE_STRING_VALUE,' ||
            ' ETA_OUTER.ATTRIBUTE_NUMBER_VALUE,' ||
            ' ETA_OUTER.ATTRIBUTE_UOM_CODE,' ||
            ' ETA_OUTER.ATTRIBUTE_DATE_VALUE,' ||
            ' ETA_OUTER.ATTRIBUTE_TRANSLATED_VALUE' ||
       ' FROM EGO_TEMPL_ATTRIBUTES   ETA_OUTER'
                     );
    IF p_data_level IS NOT NULL THEN
      FND_DSQL.Add_Text(
           ' , EGO_DATA_LEVEL_B DL ' ||
      ' WHERE DL.data_level_name = '
                       );
      Add_Bind(p_value => p_data_level);
      FND_DSQL.Add_Text(
        ' AND DL.data_level_id = ETA_OUTER.data_level_id '
                       );
    ELSE
      FND_DSQL.Add_Text(' WHERE 1 = 1');
    END IF;
    FND_DSQL.Add_Text(' AND ETA_OUTER.TEMPLATE_ID = ');
    Add_Bind(p_value => p_template_id);
    FND_DSQL.Add_Text(' AND ETA_OUTER.CLASSIFICATION_CODE IN (');

    -- we assume here that the calling procedure has passed in some class codes
    l_class_code_hierarchy := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                l_ext_table_metadata_obj.class_code_metadata
                               ,p_class_code_name_value_pairs
                               ,'VALUES_ALL_CC'
                               ,TRUE
                              );
    Debug_Msg(l_api_name||' l_class_code_hierarchy '|| l_class_code_hierarchy, 1);

    FND_DSQL.Add_Text(')' ||
        ' AND ETA_OUTER.ENABLED_FLAG = ''Y''' ||
        l_attr_group_ids_to_exclude||
        ' AND (ETA_OUTER.TEMPLATE_ID' ||
            ' ,ETA_OUTER.ATTRIBUTE_GROUP_ID' ||
            ' ,ETA_OUTER.ATTRIBUTE_ID' ||
            ' ,ETA_OUTER.ROW_NUMBER' ||
            ' ,DECODE(ETA_OUTER.CLASSIFICATION_CODE, ');

    l_cc_data_type := l_ext_table_metadata_obj.class_code_metadata(l_ext_table_metadata_obj.class_code_metadata.FIRST).DATA_TYPE;
    -----------------------------------------------------------------
    -- Build a DECODE string for the Classification Code Hierarchy --
    -----------------------------------------------------------------
    l_last_loop_index := 1;
    l_decode_index := 0;
    l_is_last_cc := FALSE;
    LOOP

      l_this_loop_index := INSTR(l_class_code_hierarchy, ',', l_last_loop_index);

      IF (l_this_loop_index = 0) THEN
        l_this_loop_index := LENGTH(l_class_code_hierarchy) + 1;
        l_is_last_cc := TRUE;
      END IF;
      l_next_cc := SUBSTR(l_class_code_hierarchy
                              ,l_last_loop_index
                              ,(l_this_loop_index - l_last_loop_index));
      IF (l_cc_data_type = 'NUMBER' OR l_cc_data_type = 'INTEGER') THEN
        Add_Bind(p_value => TO_NUMBER(l_next_cc));
      ELSIF (l_cc_data_type = 'VARCHAR' OR l_cc_data_type = 'VARCHAR2') THEN
        l_cc_begin_pos := INSTR(l_next_cc, '''') + 1;
        Add_Bind(p_value => SUBSTR(l_next_cc,
                                 l_cc_begin_pos,
                                 INSTR(l_next_cc, '''', -1) - l_cc_begin_pos));
      END IF;
      FND_DSQL.Add_Text(', ' || l_decode_index);

      EXIT WHEN (l_is_last_cc);

      FND_DSQL.Add_Text(', ');
      l_decode_index := l_decode_index + 1;
      l_last_loop_index := l_this_loop_index + 1;

    END LOOP;

    FND_DSQL.Add_Text('))' ||
            ' IN (SELECT ETA.TEMPLATE_ID' ||
                      ' ,ETA.ATTRIBUTE_GROUP_ID' ||
                      ' ,ETA.ATTRIBUTE_ID' ||
                      ' ,ETA.ROW_NUMBER' ||
                      ' ,MIN(DECODE(ETA.CLASSIFICATION_CODE, ');

    -----------------------------------------------------------------
    -- Build a DECODE string for the Classification Code Hierarchy --
    -----------------------------------------------------------------
    l_last_loop_index := 1;
    l_decode_index := 0;
    l_is_last_cc := FALSE;
    LOOP

      l_this_loop_index := INSTR(l_class_code_hierarchy, ',', l_last_loop_index);

      IF(l_this_loop_index = 0) THEN
        l_this_loop_index := LENGTH(l_class_code_hierarchy) + 1;
        l_is_last_cc := TRUE;
      END IF;
      l_next_cc := SUBSTR(l_class_code_hierarchy
                         ,l_last_loop_index
                         ,(l_this_loop_index - l_last_loop_index)
                         );
      IF (l_cc_data_type = 'NUMBER' OR l_cc_data_type = 'INTEGER') THEN
        Add_Bind(p_value => TO_NUMBER(l_next_cc));
      ELSIF (l_cc_data_type = 'VARCHAR' OR l_cc_data_type = 'VARCHAR2') THEN
        l_cc_begin_pos := INSTR(l_next_cc, '''') + 1;
        Add_Bind(p_value => SUBSTR(l_next_cc,
                                   l_cc_begin_pos,
                                   INSTR(l_next_cc, '''', -1) - l_cc_begin_pos));
      END IF;
      FND_DSQL.Add_Text(', ' || l_decode_index);

      EXIT WHEN (l_is_last_cc);

      FND_DSQL.Add_Text(', ');
      l_decode_index := l_decode_index + 1;
      l_last_loop_index := l_this_loop_index + 1;

    END LOOP;

    FND_DSQL.Add_Text(')) STEPS_ABOVE_CURR' ||
                  ' FROM EGO_TEMPL_ATTRIBUTES ETA' ||
                 ' WHERE ETA.TEMPLATE_ID = ');
    Add_Bind(p_value => p_template_id);
    FND_DSQL.Add_Text(
                   ' AND ETA.CLASSIFICATION_CODE IN (');

    l_class_code_hierarchy := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                                    l_ext_table_metadata_obj.class_code_metadata
                                   ,p_class_code_name_value_pairs
                                   ,'VALUES_ALL_CC'
                                   ,TRUE
                              );

    FND_DSQL.Add_Text(')' ||
                 ' GROUP BY ETA.TEMPLATE_ID, ETA.ATTRIBUTE_GROUP_ID, ETA.ATTRIBUTE_ID, ETA.ROW_NUMBER)' ||
      ' ORDER BY ETA_OUTER.ATTRIBUTE_GROUP_ID, ETA_OUTER.ROW_NUMBER');

    -----------------------------------------------------------------------------------
    -- Parse and execute the query, and associate the output columns with our record --
    -----------------------------------------------------------------------------------
    Debug_Msg(l_api_name||' complete query '|| FND_DSQL.Get_Text(), 1);
    Debug_Msg(l_api_name||' using binds template_id: '||p_template_id||' , '||
              ' class code: '||l_class_code_hierarchy
              , 1);

    DBMS_SQL.Parse(l_cursor_id, FND_DSQL.Get_Text(), DBMS_SQL.Native);
    FND_DSQL.Set_Cursor(l_cursor_id);
    FND_DSQL.Do_Binds();
    DBMS_SQL.Define_Column(l_cursor_id, 1, l_templ_attr_rec.ATTRIBUTE_GROUP_ID);
    DBMS_SQL.Define_Column(l_cursor_id, 2, l_templ_attr_rec.ATTRIBUTE_ID);
    DBMS_SQL.Define_Column(l_cursor_id, 3, l_templ_attr_rec.ROW_NUMBER);
    DBMS_SQL.Define_Column(l_cursor_id, 4, l_templ_attr_rec.ATTRIBUTE_STRING_VALUE, 150);
    DBMS_SQL.Define_Column(l_cursor_id, 5, l_templ_attr_rec.ATTRIBUTE_NUMBER_VALUE);
    DBMS_SQL.Define_Column(l_cursor_id, 6, l_templ_attr_rec.ATTRIBUTE_UOM_CODE, 3);
    DBMS_SQL.Define_Column(l_cursor_id, 7, l_templ_attr_rec.ATTRIBUTE_DATE_VALUE);
    DBMS_SQL.Define_Column(l_cursor_id, 8, l_templ_attr_rec.ATTRIBUTE_TRANSLATED_VALUE, 1000);
    l_rows_fetched := DBMS_SQL.Execute(l_cursor_id);

    WHILE (DBMS_SQL.Fetch_Rows(l_cursor_id) > 0)
    LOOP

      DBMS_SQL.Column_Value(l_cursor_id, 1, l_templ_attr_rec.ATTRIBUTE_GROUP_ID);
      DBMS_SQL.Column_Value(l_cursor_id, 2, l_templ_attr_rec.ATTRIBUTE_ID);
      DBMS_SQL.Column_Value(l_cursor_id, 3, l_templ_attr_rec.ROW_NUMBER);
      DBMS_SQL.Column_Value(l_cursor_id, 4, l_templ_attr_rec.ATTRIBUTE_STRING_VALUE);
      DBMS_SQL.Column_Value(l_cursor_id, 5, l_templ_attr_rec.ATTRIBUTE_NUMBER_VALUE);
      DBMS_SQL.Column_Value(l_cursor_id, 6, l_templ_attr_rec.ATTRIBUTE_UOM_CODE);
      DBMS_SQL.Column_Value(l_cursor_id, 7, l_templ_attr_rec.ATTRIBUTE_DATE_VALUE);
      DBMS_SQL.Column_Value(l_cursor_id, 8, l_templ_attr_rec.ATTRIBUTE_TRANSLATED_VALUE);

      Debug_Msg(l_api_name ||' processing AG '||l_templ_attr_rec.ATTRIBUTE_GROUP_ID,1);
      -----------------------------------------------------------------------
      -- Find out whether we're at the beginning of an Attr Group or a row --
      -----------------------------------------------------------------------
      l_at_start_of_ag := (l_prev_loop_ag_id IS NULL OR
                           l_templ_attr_rec.ATTRIBUTE_GROUP_ID <> l_prev_loop_ag_id);

      ----------------------------------------------------------
      -- If we switched Attr Groups, we switched rows as well --
      ----------------------------------------------------------
      l_at_start_of_row := (l_at_start_of_ag OR
                            l_prev_loop_row_number IS NULL OR
                            l_templ_attr_rec.ROW_NUMBER <> l_prev_loop_row_number);

      -------------------------------------------------------------
      -- If we are at the start of the first row, initialize our --
      -- name/value pair array.  Otherwise, we want to process   --
      -- the data we've collected over the previous few loops    --
      -------------------------------------------------------------
      IF (l_at_start_of_row) THEN

        l_row_index := l_row_index + 1;

        IF (l_prev_loop_row_number IS NULL) THEN
          l_attr_name_value_pairs := EGO_USER_ATTR_DATA_TABLE();
        ELSE

          --Start Bug 5211171
/***

          Debug_Msg(l_api_name||' ATTR_GROUP_ID '||l_attr_group_metadata_obj.ATTR_GROUP_ID, 1);
          Debug_Msg(l_api_name||' CLASS_CODE_HIERARCHY OBTAINED '||l_class_code_hierarchy, 1);
          Debug_Msg(l_api_name||' OBJECT_NAME '||p_object_name, 1);
          Debug_Msg(l_api_name||' OBJECT_ID '||l_object_id, 1);

          l_decode_query := 'SELECT DECODE(ATTRIBUTE2, 1, ATTRIBUTE3, 2, ATTRIBUTE5,3, ATTRIBUTE7,''NONE'') ';
          l_decode_query := l_decode_query||' FROM FND_LOOKUP_VALUES ';
          l_decode_query := l_decode_query||' WHERE LOOKUP_TYPE = ''EGO_EF_DATA_LEVEL'' ';
          l_decode_query := l_decode_query||' AND LANGUAGE = USERENV(''LANG'') ';
          l_decode_query := l_decode_query||' AND LOOKUP_CODE = (SELECT DATA_LEVEL ';
          l_decode_query := l_decode_query||' FROM EGO_OBJ_AG_ASSOCS_B ';
          l_decode_query := l_decode_query||' WHERE OBJECT_ID  = '||l_object_id;
          l_decode_query := l_decode_query||' AND ATTR_GROUP_ID = '||l_attr_group_metadata_obj.ATTR_GROUP_ID;
          l_decode_query := l_decode_query||' AND ROWNUM = 1 ';
          l_decode_query := l_decode_query||' AND CLASSIFICATION_CODE IN ('||l_class_code_hierarchy;
          l_decode_query := l_decode_query||'))';

          EXECUTE IMMEDIATE l_decode_query INTO l_rev_level;
          Debug_Msg(l_api_name||' DECODE QUERY  :'||l_decode_query, 1);

          Debug_Msg(l_api_name||' OBTAINED REVISION LEVEL,'||l_rev_level, 1);

          IF ( (l_rev_level = 'NONE' AND p_data_level_name_value_pairs IS NULL)
               OR
               (l_rev_level <> 'NONE' AND p_data_level_name_value_pairs IS NOT NULL )
             ) THEN

***/

          Is_Name_Value_Pairs_Valid
             ( p_attr_group_id               => l_attr_group_metadata_obj.attr_group_id
              ,p_data_level_name             => p_data_level
              ,p_class_code_hierarchy        => l_class_code_hierarchy
              ,p_data_level_name_value_pairs => p_data_level_name_value_pairs
              ,x_data_level_id               => l_data_level_id
              ,x_name_value_pair_valid       => l_Perform_DML_On_Template_Row
             );

          IF FND_API.TO_BOOLEAN(l_Perform_DML_On_Template_Row) THEN
            Debug_Msg(l_api_name ||' CALLING Perform_DML_On_Template_Row in the loop ',1);
            Perform_DML_On_Template_Row(
                  p_object_id                    => l_object_id
                  ,p_attr_group_metadata_obj     => l_attr_group_metadata_obj
                  ,p_ext_table_metadata_obj      => l_ext_table_metadata_obj
                  ,p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
                  ,p_class_code_name_value_pairs => p_class_code_name_value_pairs
                  ,p_data_level                  => p_data_level
                  ,p_data_level_name_value_pairs => p_data_level_name_value_pairs
                  ,px_attr_name_value_pairs      => l_attr_name_value_pairs
                  ,p_commit                      => FND_API.G_FALSE -- we don't commit until the end
                  );
          ELSE
            Debug_Msg(l_api_name ||' no need to call Perform_DML_On_Template_Row in the loop ',1);
          END IF;
         --End Bug 5211171

          ----------------------------------------------
          -- After processing this row, clear out the --
          -- name/value pairs array for the next row  --
          ----------------------------------------------
          l_attr_name_value_pairs.DELETE();
        END IF;

        ----------------------------------------------------------
        -- If we switched Attr Groups as well as rows, we fetch --
        -- l_attr_group_metadata_obj for the new Attr Group     --
        ----------------------------------------------------------
        IF (l_at_start_of_ag) THEN

          l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                         p_attr_group_id => l_templ_attr_rec.ATTRIBUTE_GROUP_ID
                                       );

          IF (l_attr_group_metadata_obj IS NULL) THEN

            l_token_table(1).TOKEN_NAME := 'AG_ID';
            l_token_table(1).TOKEN_VALUE := l_templ_attr_rec.ATTRIBUTE_GROUP_ID;

            ERROR_HANDLER.Add_Error_Message(
              p_message_name      => 'EGO_EF_ATTR_GROUP_ID_NOT_FOUND'
             ,p_application_id    => 'EGO'
             ,p_token_tbl         => l_token_table
             ,p_message_type      => FND_API.G_RET_STS_ERROR
             ,p_row_identifier    => l_row_index + 1 --we haven't incremented yet
             ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
            );

            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

      l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                               p_attr_metadata_table => l_attr_group_metadata_obj.attr_metadata_table
                              ,p_attr_id             => l_templ_attr_rec.ATTRIBUTE_ID
                             );

      IF (l_attr_metadata_obj IS NULL OR
          l_attr_metadata_obj.ATTR_NAME IS NULL) THEN

        l_token_table(1).TOKEN_NAME := 'ATTR_ID';
        l_token_table(1).TOKEN_VALUE := l_templ_attr_rec.ATTRIBUTE_ID;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_EF_ATTR_ID_NOT_FOUND'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_row_identifier    => l_row_index + 1 --we haven't incremented yet
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );

        RAISE FND_API.G_EXC_ERROR;
      END IF;

      ------------------------------------------------------------------
      -- Whether or not we're at the start of a row, we've fetched a  --
      -- record, so we load its values into the name/value pair array --
      -- NOTE: we will have display values instead of internal values --
      -- for Attributes with Value Sets that use bind values, in such --
      -- cases, we store the Template record value in ATTR_DISP_VALUE --
      -- instead of ATTR_VALUE_STR, and we will later convert it into --
      -- its corresponding internal value before validating the row   --
      ------------------------------------------------------------------
      l_attr_name_value_pairs.EXTEND();
      IF (l_attr_metadata_obj.VS_BIND_VALUES_CODE IS NOT NULL AND
          l_attr_metadata_obj.VS_BIND_VALUES_CODE <> 'N') THEN

        l_attr_name_value_pairs(l_attr_name_value_pairs.LAST) :=
          EGO_USER_ATTR_DATA_OBJ(
            l_row_index
           ,l_attr_metadata_obj.ATTR_NAME
           ,null -- ATTR_VALUE_STR
           ,l_templ_attr_rec.ATTRIBUTE_NUMBER_VALUE
           ,l_templ_attr_rec.ATTRIBUTE_DATE_VALUE
           ,NVL(l_templ_attr_rec.ATTRIBUTE_STRING_VALUE,l_templ_attr_rec.ATTRIBUTE_TRANSLATED_VALUE)
           ,l_templ_attr_rec.ATTRIBUTE_UOM_CODE
           ,l_row_index
          );

      ELSE

        l_attr_name_value_pairs(l_attr_name_value_pairs.LAST) :=
          EGO_USER_ATTR_DATA_OBJ(
            l_row_index
           ,l_attr_metadata_obj.ATTR_NAME
           ,NVL(l_templ_attr_rec.ATTRIBUTE_STRING_VALUE,l_templ_attr_rec.ATTRIBUTE_TRANSLATED_VALUE)
           ,l_templ_attr_rec.ATTRIBUTE_NUMBER_VALUE
           ,l_templ_attr_rec.ATTRIBUTE_DATE_VALUE
           ,null -- ATTR_DISP_VALUE
           ,l_templ_attr_rec.ATTRIBUTE_UOM_CODE
           ,l_row_index
          );

      END IF;

      --------------------------------------------------
      -- Now we update these values for the next loop --
      --------------------------------------------------
      l_prev_loop_ag_id := l_templ_attr_rec.ATTRIBUTE_GROUP_ID;
      l_prev_loop_row_number := l_templ_attr_rec.ROW_NUMBER;

    END LOOP;

    --bug 9170700
    DBMS_SQL.Close_Cursor(l_cursor_id);

    ------------------------------------------------------------------------
    -- Now we process the last row (i.e., the row whose values we've been --
    -- collecting in the last few loops but that we've not yet processed) --
    ------------------------------------------------------------------------
    l_row_index := l_row_index + 1;

    IF (l_prev_loop_row_number IS NOT NULL) THEN
      --Start Bug 5211171
/***
      l_decode_query := 'SELECT DECODE(ATTRIBUTE2, 1, ATTRIBUTE3, 2, ATTRIBUTE5,3, ATTRIBUTE7,''NONE'') ';
      l_decode_query := l_decode_query||' FROM FND_LOOKUP_VALUES ';
      l_decode_query := l_decode_query||' WHERE LOOKUP_TYPE = ''EGO_EF_DATA_LEVEL'' ';
      l_decode_query := l_decode_query||' AND LANGUAGE = USERENV(''LANG'') ';
      l_decode_query := l_decode_query||' AND LOOKUP_CODE = (SELECT DATA_LEVEL ';
      l_decode_query := l_decode_query||' FROM EGO_OBJ_AG_ASSOCS_B ';
      l_decode_query := l_decode_query||' WHERE OBJECT_ID  = '||l_object_id;
      l_decode_query := l_decode_query||' AND ATTR_GROUP_ID = '||l_prev_loop_ag_id;
      l_decode_query := l_decode_query||' AND ROWNUM = 1 ';
      l_decode_query := l_decode_query||' AND CLASSIFICATION_CODE IN ('||l_class_code_hierarchy;
      l_decode_query := l_decode_query||'))';

      EXECUTE IMMEDIATE l_decode_query INTO l_rev_level;

      Debug_Msg(l_api_name||' OUT OF LOOP REVISION_LEVEL OBTAINED :'||l_rev_level,1);
***/
      Is_Name_Value_Pairs_Valid
         ( p_attr_group_id               => l_prev_loop_ag_id
          ,p_data_level_name             => p_data_level
          ,p_class_code_hierarchy        => l_class_code_hierarchy
          ,p_data_level_name_value_pairs => p_data_level_name_value_pairs
          ,x_data_level_id               => l_data_level_id
          ,x_name_value_pair_valid       => l_Perform_DML_On_Template_Row
         );

      IF FND_API.TO_BOOLEAN(l_Perform_DML_On_Template_Row) THEN
        Debug_Msg(l_api_name || ' CALLING Perform_DML_On_Template_Row for data level out of loop',1);
        Perform_DML_On_Template_Row(
            p_object_id                     => l_object_id
           ,p_attr_group_metadata_obj       => l_attr_group_metadata_obj
           ,p_ext_table_metadata_obj        => l_ext_table_metadata_obj
           ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
           ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
           ,p_data_level                    => p_data_level
           ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
           ,px_attr_name_value_pairs        => l_attr_name_value_pairs
           ,p_commit                        => FND_API.G_FALSE -- we don't commit until the end
          );
      ELSE
        Debug_Msg(l_api_name || ' no need to call Perform_DML_On_Template_Row for data level out of loop',1);
      END IF;
      --End Bug 5211171

    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    Debug_Msg(l_api_name||' done ',1);
    G_ENABLE_DEBUG := FALSE;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg(l_api_name || ' EXCEPTION FND_API.G_EXC_ERROR');
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Perform_DML_From_Template;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count > 0) THEN

        ------------------------------------------------------
        -- We log all errors we got as we close our session --
        ------------------------------------------------------
        Close_Business_Object_Session(
          p_init_error_handler_flag       => FALSE
         ,p_log_errors                    => TRUE
         ,p_write_to_concurrent_log       => FALSE
        );

        IF (x_msg_count = 1) THEN
          DECLARE
            message_list  ERROR_HANDLER.Error_Tbl_Type;
          BEGIN
            ERROR_HANDLER.Get_Message_List(message_list);
            x_msg_data := message_list(message_list.FIRST).message_text;
          END;
        ELSE
          x_msg_data := NULL;
        END IF;
      END IF;

    WHEN OTHERS THEN
      Debug_Msg(l_api_name || ' EXCEPTION OTHERS'||SQLERRM);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Perform_DML_From_Template;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      l_token_table(1).TOKEN_NAME := 'PKG_NAME';
      l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
      l_token_table(2).TOKEN_NAME := 'API_NAME';
      l_token_table(2).TOKEN_VALUE := l_api_name;
      l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
      l_token_table(3).TOKEN_VALUE := SQLERRM;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name        => 'EGO_PLSQL_ERR'
       ,p_application_id      => 'EGO'
       ,p_token_tbl           => l_token_table
       ,p_message_type        => FND_API.G_RET_STS_ERROR
       ,p_row_identifier      => l_row_index
       ,p_addto_fnd_stack     => G_ADD_ERRORS_TO_FND_STACK
      );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      ------------------------------------------------------
      -- We log all errors we got as we close our session --
      ------------------------------------------------------
      Close_Business_Object_Session(
        p_init_error_handler_flag       => FALSE
       ,p_log_errors                    => TRUE
       ,p_write_to_concurrent_log       => FALSE
      );

      IF (x_msg_count = 1) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      ELSE
        x_msg_data := NULL;
      END IF;

END Perform_DML_From_Template;

----------------------------------------------------------------------

PROCEDURE Copy_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_old_pk_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_old_data_level_id             IN   NUMBER   DEFAULT  NULL
       ,p_old_dtlevel_col_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_new_pk_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_new_data_level_id             IN   NUMBER   DEFAULT  NULL
       ,p_new_dtlevel_col_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_new_cc_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_attr_group_list               IN   VARCHAR2   DEFAULT  NULL
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Copy_User_Attrs_Data';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_object_id                NUMBER;
    l_b_table_name             VARCHAR2(30);
    l_tl_table_name            VARCHAR2(30);
    l_vl_name                  VARCHAR2(30);
    l_ext_table_metadata_obj     EGO_EXT_TABLE_METADATA_OBJ;
    l_pk_col_metadata_array      EGO_COL_METADATA_ARRAY;
    l_data_level_metadata_array  EGO_COL_METADATA_ARRAY;
    l_class_code_metadata_array  EGO_COL_METADATA_ARRAY;
    l_pk_index                 NUMBER;
    l_dtlevel_index            NUMBER;
    l_cc_col_index             NUMBER;
    l_cc_value_index           NUMBER;
    l_found_value_for_this_col BOOLEAN;
    l_insert_pk_sql            VARCHAR2(500);
    l_insert_dtlevel_sql       VARCHAR2(500) := '';
    l_insert_class_code_sql    VARCHAR2(100) := '';
    l_select_pk_sql            VARCHAR2(2000);
    l_select_dtlevel_sql       VARCHAR2(2000) := '';
    l_select_class_code_sql    VARCHAR2(500) := '';
    l_where_pk_sql             VARCHAR2(2000);
    l_where_dtlevel_sql        VARCHAR2(2000) := '';
    l_where_not_in_sql         VARCHAR2(1000);
    l_column_name_to_copy      VARCHAR2(30);
    l_base_table_copy_dml      VARCHAR2(10000) := '';
    l_tl_table_copy_dml        VARCHAR2(10000) := '';
    l_copy_from_ext_id         NUMBER;
    l_copy_to_ext_id           NUMBER;
    l_dynamic_sql              VARCHAR2(500);
    l_b_table_col_names_list   VARCHAR2(3000);
    l_tl_table_col_names_list  VARCHAR2(3000);

    l_current_user_id        NUMBER := FND_GLOBAL.User_Id;
    l_current_login_id       NUMBER := FND_GLOBAL.Login_Id;
    l_dummy                  INTEGER;
    l_pk_cursor              INTEGER;
    l_pk_array               dbms_sql.Varchar2_Table;
    l_dt_array               dbms_sql.Varchar2_Table;
    l_pk_array_index         NUMBER := 0;
    l_dt_array_index         NUMBER := 0;

l_has_data_level_id   BOOLEAN  := FALSE;    -- TRUE is for R12C
l_all_dl_cols      VARCHAR2(500);
l_dummy_string     VARCHAR2(32767);
l_delimator_loc    NUMBER;
l_pk_name          VARCHAR2(30);
l_attr_group_type  VARCHAR2(40);

    TYPE DYNAMIC_CUR IS REF CURSOR;
    l_dynamic_cursor         DYNAMIC_CUR;

    CURSOR group_types_cursor (cp_application_id NUMBER, cp_object_id NUMBER)
    IS
    SELECT DISTINCT FDF.DESCRIPTIVE_FLEXFIELD_NAME  ATTR_GROUP_TYPE
      FROM EGO_OBJECT_EXT_TABLES_B                  EOET
          ,FND_DESCRIPTIVE_FLEXS                    FDF
     WHERE EOET.APPLICATION_ID = cp_application_id
       AND EOET.OBJECT_ID = cp_object_id
       AND FDF.APPLICATION_ID = cp_application_id
       AND EOET.APPLICATION_ID = FDF.APPLICATION_ID
       AND EOET.EXT_TABLE_NAME = FDF.APPLICATION_TABLE_NAME;

  l_key               VARCHAR2(300);               -- bug 13719629
  l_key2              VARCHAR2(300);               -- bug 13719629
  l_attr_group_types  LOCAL_MEDIUM_VARCHAR_TABLE;  -- bug 13719629
  l_cached_not_in_sql VARCHAR2(1000);              -- bug 13719629


  BEGIN

    Debug_Msg(l_api_name || ' Starting ');

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Copy_User_Attrs_Data_PUB;
    END IF;

    -- Initialize FND_MSG_PUB if necessary
    IF (FND_API.To_Boolean(p_init_fnd_msg_list)) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize ERROR_HANDLER if necessary
    IF (FND_API.To_Boolean(p_init_error_handler)) THEN
      ERROR_HANDLER.Initialize();
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (FND_API.To_Boolean(p_add_errors_to_fnd_stack)) THEN
      G_ADD_ERRORS_TO_FND_STACK := 'Y';
    ELSE
      G_ADD_ERRORS_TO_FND_STACK := 'N';
    END IF;

    IF (p_object_id IS NULL) THEN
      l_object_id := Get_Object_Id_From_Name(p_object_name);
    ELSE
      l_object_id := p_object_id;
    END IF;

    --------------------------------------------------------------------
    -- The metadata for all extension tables (though not their names) --
    -- will be the same for all group types, so we only query it once --
    --------------------------------------------------------------------
    l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(l_object_id);

    ---------------------------------------------------------------------
    -- Now we build strings that will be necessary for the rest of the --
    -- processing and, like l_ext_table_metadata_obj, won't change     --
    ---------------------------------------------------------------------
    l_pk_col_metadata_array := l_ext_table_metadata_obj.pk_column_metadata;
    l_data_level_metadata_array := l_ext_table_metadata_obj.data_level_metadata;
    l_class_code_metadata_array := l_ext_table_metadata_obj.class_code_metadata;

    IF p_old_data_level_id IS NOT NULL OR p_new_data_level_id IS NOT NULL THEN
      l_has_data_level_id := TRUE;
    ELSE
      l_has_data_level_id := FALSE;
    END IF;
    -- processing the pk cols
    IF (p_old_pk_col_value_pairs.COUNT <> p_new_pk_col_value_pairs.COUNT) THEN
      x_msg_data := 'EGO_EF_CP_PK_COL_COUNT_ERR';
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_pk_index := p_old_pk_col_value_pairs.FIRST;
    WHILE (l_pk_index <= p_old_pk_col_value_pairs.LAST)
    LOOP
      -- assuming that the l_pk_col_metadata_array will be greater than or equal to p_old_pk_col_value_pairs
      IF (p_old_pk_col_value_pairs(l_pk_index).NAME = p_new_pk_col_value_pairs(l_pk_index).NAME AND
          p_old_pk_col_value_pairs(l_pk_index).NAME = l_pk_col_metadata_array(l_pk_index).COL_NAME) THEN

        IF (p_old_pk_col_value_pairs(l_pk_index).VALUE IS NOT NULL AND
            p_new_pk_col_value_pairs(l_pk_index).VALUE IS NOT NULL) THEN
          l_select_pk_sql := l_select_pk_sql ||'''' ||p_new_pk_col_value_pairs(l_pk_index).VALUE ||''', ';
          l_pk_array_index := l_pk_array_index +1 ;
          l_pk_array(l_pk_array_index) := p_old_pk_col_value_pairs(l_pk_index).VALUE;
          l_where_pk_sql  := l_where_pk_sql ||p_old_pk_col_value_pairs(l_pk_index).NAME ||' = :PK' ||l_pk_array_index ||' AND ';
          l_insert_pk_sql := l_insert_pk_sql ||p_old_pk_col_value_pairs(l_pk_index).NAME ||', ';
        END IF;
        l_where_not_in_sql := l_where_not_in_sql ||'''' ||l_pk_col_metadata_array(l_pk_index).COL_NAME ||''', ' ;
      ELSE
        x_msg_data := 'EGO_EF_CP_PK_COL_NAME_ERR';
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_pk_index := p_old_pk_col_value_pairs.NEXT(l_pk_index);
    END LOOP;

    Debug_Msg(l_api_name || ' After PK loop l_insert_pk_sql: '||l_insert_pk_sql);
    Debug_Msg(l_api_name || ' After PK loop l_select_pk_sql: '||l_select_pk_sql);
    Debug_Msg(l_api_name || ' After PK loop l_where_pk_sql: '||l_where_pk_sql);

    --processing data levels
    IF p_old_data_level_id IS NOT NULL OR p_new_data_level_id IS NOT NULL THEN

      -- R12C code changes is this based on data_level_id or an assumption!!
      -- preparing where clause from the data levels
      IF p_old_dtlevel_col_value_pairs IS NOT NULL AND p_old_dtlevel_col_value_pairs.COUNT > 0 THEN
        l_dtlevel_index := p_old_dtlevel_col_value_pairs.FIRST;
        WHILE (l_dtlevel_index <= p_old_dtlevel_col_value_pairs.LAST)
        LOOP
          IF (p_old_dtlevel_col_value_pairs(l_dtlevel_index).VALUE IS NOT NULL) THEN
            l_dt_array_index := l_dt_array_index +1 ;
            l_dt_array(l_dt_array_index) := p_old_dtlevel_col_value_pairs(l_dtlevel_index).VALUE;
            l_where_dtlevel_sql := l_where_dtlevel_sql ||p_old_dtlevel_col_value_pairs(l_dtlevel_index).NAME ||' = :DT' ||l_dt_array_index || ' AND ';
          ELSE
            l_where_dtlevel_sql := l_where_dtlevel_sql ||p_old_dtlevel_col_value_pairs(l_dtlevel_index).NAME ||' IS NULL AND ';
          END IF;  -- if null
          l_dtlevel_index := p_old_dtlevel_col_value_pairs.NEXT(l_dtlevel_index);
        END LOOP;
      END IF;

      -- preparing select and insert statement for new data levels
      IF p_new_dtlevel_col_value_pairs IS NOT NULL AND p_new_dtlevel_col_value_pairs.COUNT > 0 THEN
        l_dtlevel_index := p_new_dtlevel_col_value_pairs.FIRST;
        WHILE (l_dtlevel_index <= p_new_dtlevel_col_value_pairs.LAST)
        LOOP
          IF (p_new_dtlevel_col_value_pairs(l_dtlevel_index).VALUE IS NOT NULL) THEN
            l_select_dtlevel_sql := l_select_dtlevel_sql ||'''' ||p_new_dtlevel_col_value_pairs(l_dtlevel_index).VALUE ||''', ';
          ELSE
            l_select_dtlevel_sql := l_select_dtlevel_sql || ' NULL, ';
          END IF;  -- if null
          l_insert_dtlevel_sql := l_insert_dtlevel_sql ||p_new_dtlevel_col_value_pairs(l_dtlevel_index).NAME ||', ';
          l_dtlevel_index := p_new_dtlevel_col_value_pairs.NEXT(l_dtlevel_index);
        END LOOP;
      END IF;

  ELSE  --  p_old_data_level_id IS NOT NULL OR p_new_data_level_id IS NOT NULL

     -- existing code
      -- need to process data level only if it's not null
      IF (p_old_dtlevel_col_value_pairs IS NULL AND
          p_new_dtlevel_col_value_pairs IS NULL AND
          l_data_level_metadata_array IS NOT NULL) THEN
        x_msg_data := 'EGO_EF_CP_DL_NOT_PASSED_ERR';
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (p_old_dtlevel_col_value_pairs IS NOT NULL AND
             p_new_dtlevel_col_value_pairs  IS NOT NULL) THEN
        IF (p_old_dtlevel_col_value_pairs.COUNT <> p_new_dtlevel_col_value_pairs.COUNT)  THEN
          x_msg_data := 'EGO_EF_CP_DL_COUNT_ERR';
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        l_dtlevel_index := p_old_dtlevel_col_value_pairs.FIRST;
        WHILE (l_dtlevel_index <= p_old_dtlevel_col_value_pairs.LAST)
        LOOP
          -- need to check if the names are correct.
          IF (p_old_dtlevel_col_value_pairs(l_dtlevel_index).NAME = p_new_dtlevel_col_value_pairs(l_dtlevel_index).NAME AND
              p_old_dtlevel_col_value_pairs(l_dtlevel_index).NAME = l_data_level_metadata_array(l_dtlevel_index).COL_NAME) THEN

            IF (p_old_dtlevel_col_value_pairs(l_dtlevel_index).VALUE IS NOT NULL AND
                p_new_dtlevel_col_value_pairs(l_dtlevel_index).VALUE IS NOT NULL) THEN
              l_select_dtlevel_sql := l_select_dtlevel_sql ||'''' ||p_new_dtlevel_col_value_pairs(l_dtlevel_index).VALUE ||''', ';
              l_dt_array_index := l_dt_array_index +1 ;
              l_dt_array(l_dt_array_index) := p_old_dtlevel_col_value_pairs(l_dtlevel_index).VALUE;
              l_where_dtlevel_sql := l_where_dtlevel_sql ||p_old_dtlevel_col_value_pairs(l_dtlevel_index).NAME ||' = :DT' ||l_dt_array_index || ' AND ';
            ELSE
              l_select_dtlevel_sql := l_select_dtlevel_sql || ' NULL, ';
              l_where_dtlevel_sql := l_where_dtlevel_sql ||p_old_dtlevel_col_value_pairs(l_dtlevel_index).NAME ||' IS NULL AND ';
            END IF;  -- if null
            l_insert_dtlevel_sql := l_insert_dtlevel_sql ||p_old_dtlevel_col_value_pairs(l_dtlevel_index).NAME ||', ';
            l_where_not_in_sql := l_where_not_in_sql ||'''' ||l_data_level_metadata_array(l_dtlevel_index).COL_NAME ||''', ';
          ELSE
            x_msg_data := 'EGO_EF_CP_DL_NAME_ERR';
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          l_dtlevel_index := p_old_dtlevel_col_value_pairs.NEXT(l_dtlevel_index);
        END LOOP;
      END IF; -- if data level IS NOT NULL
    END IF;  -- p_old_data_level_id IS NOT NULL OR p_new_data_level_id IS NOT NULL

    Debug_Msg(l_api_name || ' After DL loop l_insert_dtlevel_sql: '||l_insert_dtlevel_sql);
    Debug_Msg(l_api_name || ' After DL loop l_select_dtlevel_sql: '||l_select_dtlevel_sql);
    Debug_Msg(l_api_name || ' After DL loop l_where_dtlevel_sql: '||l_where_dtlevel_sql);
    Debug_Msg(l_api_name || ' After DL loop l_where_not_in_sql: '||l_where_not_in_sql);

    --processing classification codes
    l_cc_col_index := l_class_code_metadata_array.FIRST;
    WHILE (l_cc_col_index <= l_class_code_metadata_array.LAST)
    LOOP
      EXIT WHEN l_class_code_metadata_array(l_cc_col_index).COL_NAME IS NULL;

      l_insert_class_code_sql := l_insert_class_code_sql ||
                                 l_class_code_metadata_array(l_cc_col_index).COL_NAME ||
                                 ', ';
      l_where_not_in_sql := l_where_not_in_sql ||
                            '''' ||
                            l_class_code_metadata_array(l_cc_col_index).COL_NAME ||
                            ''', ' ;

      l_found_value_for_this_col := FALSE;
      IF (p_new_cc_col_value_pairs IS NOT NULL AND
          p_new_cc_col_value_pairs.COUNT > 0) THEN

        -- loop through the passed-in name value pair array to find the right value for selecting
        l_cc_value_index := p_new_cc_col_value_pairs.FIRST;
        WHILE (l_cc_value_index <= p_new_cc_col_value_pairs.LAST)
        LOOP
          EXIT WHEN (l_found_value_for_this_col);

          IF (l_class_code_metadata_array(l_cc_col_index).COL_NAME =
              p_new_cc_col_value_pairs(l_cc_value_index).NAME) THEN

            l_select_class_code_sql := l_select_class_code_sql || '''' ||
                                       p_new_cc_col_value_pairs(l_cc_value_index).VALUE ||
                                       ''', ';
            l_found_value_for_this_col := TRUE;
          END IF;

          l_cc_value_index := p_new_cc_col_value_pairs.NEXT(l_cc_value_index);
        END LOOP;
      END IF;

      -- if we didn't find a value for the new classification code, we just copy the old one
      IF (NOT l_found_value_for_this_col) THEN
        l_select_class_code_sql := l_select_class_code_sql ||
                                   l_class_code_metadata_array(l_cc_col_index).COL_NAME ||
                                   ', ';
      END IF;

      l_cc_col_index := l_class_code_metadata_array.NEXT(l_cc_col_index);
    END LOOP;
    Debug_Msg(l_api_name || ' After CC loop l_select_class_code_sql: '||l_select_class_code_sql);

    -- appending the rest of columns to where not in sql
    l_where_not_in_sql := l_where_not_in_sql ||
                          '''EXTENSION_ID'', '||
                          '''DATA_LEVEL_ID'', '||
                          '''CREATED_BY'', '||
                          '''CREATION_DATE'', '||
                          '''LAST_UPDATED_BY'', '||
                          '''LAST_UPDATE_DATE'', '||
                          '''LAST_UPDATE_LOGIN''';

    -----------------------------------------------------------------
    -- we loop through all ATTR_GROUP_TYPE values for this object, --
    -- inserting rows into the B and TL tables for each group type --
    -----------------------------------------------------------------


    --
    -- Bug 13719629. Performance issue in get table column list
    -- due to high number of executions. Added PLSQL caching
    -- logic for attr group type.
    -- sreharih. Fri Feb 17 11:08:31 PST 2012
    --
    l_key := build_key('COPY_UDA_AGT_' || to_char(p_application_id) || '-' || to_char(l_object_id));
    l_attr_group_types := get_cached_vartable(p_key => l_key);

    IF l_attr_group_types IS NULL OR l_attr_group_types.COUNT = 0 THEN
       OPEN group_types_cursor(p_application_id, l_object_id);
       FETCH group_types_cursor BULK COLLECT INTO l_attr_group_types;
       CLOSE group_types_cursor;
       cache_vartable(p_key   => l_key,
                      p_value => l_attr_group_types);
    END IF;

    IF l_attr_group_types IS NOT NULL AND l_attr_group_types.COUNT > 0 THEN
      FOR agt_itr IN l_attr_group_types.FIRST..l_attr_group_types.LAST
      LOOP

      Debug_Msg(l_api_name || ' In Group Rec Loop : '|| l_attr_group_types(agt_itr));
      SELECT EXT_TABLE_NAME, EXT_TL_TABLE_NAME, EXT_VL_NAME, ATTR_GROUP_TYPE
        INTO l_b_table_name, l_tl_table_name, l_vl_name, l_attr_group_type
        FROM EGO_ATTR_GROUP_TYPES_V
       WHERE APPLICATION_ID = p_application_id
         AND ATTR_GROUP_TYPE = l_attr_group_types(agt_itr);

      l_has_data_level_id := FND_API.TO_BOOLEAN(EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(
                                    p_table_name  => l_b_table_name
                                   ,p_column_name => 'DATA_LEVEL_ID')
                                             );
      IF l_has_data_level_id THEN
        l_all_dl_cols := EGO_USER_ATTRS_COMMON_PVT.Get_All_Data_Level_PK_Names
                                       (p_application_id  => p_application_id
                                       ,p_attr_group_type => l_attr_group_type);
        -- l_all_dl_cols are in the format a,b,c
        -- this need to be changed as 'a','b','c'
		if(l_all_dl_cols is not null) then --for bug 12636760, check if l_all_dl_cols is null
        l_where_not_in_sql := l_where_not_in_sql || ', '||REPLACE(''''||l_all_dl_cols||'''',', ',''', ''');
        l_all_dl_cols := l_all_dl_cols ||', ';
		end if;
        --
        -- l_select_dtlevel_sql
        -- must be the given new dt level cols + null for the remaining columns in l_all_cols
        -- in the same order as in l_all_cols
        --
        l_select_dtlevel_sql := '';
        l_dummy_string := l_all_dl_cols;
        WHILE l_dummy_string IS NOT NULL LOOP
          l_delimator_loc := INSTR(l_dummy_string,',');
          IF l_delimator_loc = 0 THEN
            l_pk_name := l_dummy_string;
            l_dummy_string := NULL;
          ELSE
            l_pk_name := SUBSTR(l_dummy_string,0,l_delimator_loc);
            l_dummy_string := SUBSTR(l_dummy_string,l_delimator_loc+1);
          END IF;
          l_pk_name :=  TRIM(SUBSTR(TRIM(l_pk_name),1,LENGTH(TRIM(l_pk_name))-1));
          IF INSTR(l_insert_dtlevel_sql,l_pk_name) = 0 THEN
            l_select_dtlevel_sql := l_select_dtlevel_sql || ' NULL, ';
          ELSE
            IF p_new_dtlevel_col_value_pairs IS NOT NULL AND p_new_dtlevel_col_value_pairs.COUNT > 0 THEN
              l_dtlevel_index := p_new_dtlevel_col_value_pairs.FIRST;
              WHILE (l_dtlevel_index <= p_new_dtlevel_col_value_pairs.LAST)
              LOOP
                IF (p_new_dtlevel_col_value_pairs(l_dtlevel_index).NAME = l_pk_name) THEN
                  l_select_dtlevel_sql := l_select_dtlevel_sql ||'''' ||p_new_dtlevel_col_value_pairs(l_dtlevel_index).VALUE ||''', ';
                  EXIT;
                END IF;  -- if null
                l_insert_dtlevel_sql := l_insert_dtlevel_sql ||p_new_dtlevel_col_value_pairs(l_dtlevel_index).NAME ||', ';
                l_dtlevel_index := p_new_dtlevel_col_value_pairs.NEXT(l_dtlevel_index);
              END LOOP;
            END IF;
          END IF;
        END LOOP;
      END IF; -- l_has_data_level
      ----------------------------------------------
      -- Fetch all the base table column names... --
      ----------------------------------------------

    --
    -- Bug 13719629. Performance issue in get table column list
    -- due to high number of executions. Added PLSQL caching
    -- logic for column list.
    -- l_where_not_in_sql may not be same for combination of l_b_table_name
    -- and p_application_id. Hence we are caching it seperately and
    -- re-evaulating column list if it is different.
    -- sreharih. Fri Feb 17 11:08:31 PST 2012
    --
    l_key := build_key('COPYUDA_B_' || to_char(p_application_id) || '-' || l_b_table_name);
    l_b_table_col_names_list := get_cached_varchar(p_key => l_key);

    l_key2 := build_key('COPYUDA_NOTINSQL_' || to_char(p_application_id) || '-' || l_b_table_name);
    l_cached_not_in_sql := get_cached_varchar(p_key => l_key2);
    Debug_msg(' l_cached_not_in_sql = ' || l_cached_not_in_sql);
    Debug_msg(' l_where_not_in_sql = ' || l_where_not_in_sql);

    IF l_cached_not_in_sql IS NULL OR l_cached_not_in_sql <> l_where_not_in_sql THEN
       Debug_msg('l_cached_not_in_sql is null or is not equal to ');
       cache_varchar(p_key   => l_key2,
                     p_value => l_where_not_in_sql);
    END IF;

    IF l_b_table_col_names_list IS NULL OR l_cached_not_in_sql <> l_where_not_in_sql THEN
      Debug_Msg(l_api_name || ' before Get_Table_Columns_List '||l_where_not_in_sql );
      l_b_table_col_names_list := Get_Table_Columns_List(
                                    p_application_id            => p_application_id
                                   ,p_from_table_name           => l_b_table_name
                                   ,p_from_cols_to_exclude_list => l_where_not_in_sql
                                  );
      Debug_Msg(l_api_name || ' after Get_Table_Columns_List '|| l_b_table_col_names_list);
      cache_varchar(p_key   => l_key,
                    p_value => l_b_table_col_names_list);
    END IF;


      -------------------------------------- -----------------------
      -- ...and all the TL table column names (if there are any) --
      -------------------------------------------------------------
      IF (l_tl_table_name IS NOT NULL) THEN

              --
              -- Bug 13719629. Performance issue in get table column list
              -- due to high number of executions. Added PLSQL caching
              -- logic for column list.
              -- sreharih. Fri Feb 17 11:08:31 PST 2012
              --
              l_key := build_key('COPYUDA_TL_' || to_char(p_application_id) || '-' || l_tl_table_name);
              l_tl_table_col_names_list := get_cached_varchar(p_key => l_key);

              IF l_tl_table_col_names_list IS NULL OR l_cached_not_in_sql <> l_where_not_in_sql THEN
                l_tl_table_col_names_list := Get_Table_Columns_List(
                                       p_application_id            => p_application_id
                                      ,p_from_table_name           => l_tl_table_name
                                      ,p_from_cols_to_exclude_list => l_where_not_in_sql
                                     );
                cache_varchar(p_key   => l_key,
                              p_value => l_tl_table_col_names_list);

              END IF;

      END IF;

      -----------------------------------------
      -- Build DML statements to use in each --
      -- iteration of our extension ID loop  --
      -----------------------------------------

      -- Bug 4071472
      -- Appending a comma in the end
      IF( l_b_table_col_names_list IS NOT NULL )
      THEN
        l_b_table_col_names_list := l_b_table_col_names_list||',';
      END IF;

      IF( l_tl_table_col_names_list IS NOT NULL )
      THEN
        l_tl_table_col_names_list := l_tl_table_col_names_list||',';
      END IF;
      Debug_Msg(l_api_name || ' Before Query l_insert_pk_sql: '||l_insert_pk_sql);
      Debug_Msg(l_api_name || ' Before Query l_all_dl_cols: '|| l_all_dl_cols );
      Debug_Msg(l_api_name || ' Before Query l_insert_class_code_sql: '||l_insert_class_code_sql );
      Debug_Msg(l_api_name || ' Before Query l_b_table_col_names_list: '|| l_b_table_col_names_list);
      Debug_Msg(l_api_name || ' Before Query l_select_pk_sql: '|| l_select_pk_sql);
      Debug_Msg(l_api_name || ' Before Query l_select_dtlevel_sql: '|| l_select_dtlevel_sql);
      Debug_Msg(l_api_name || ' Before Query l_select_class_code_sql: '|| l_select_class_code_sql );
      Debug_Msg(l_api_name || ' Before Query l_b_table_col_names_list: '|| l_b_table_col_names_list);
      Debug_Msg(l_api_name || ' Before Query l_tl_table_col_names_list: '|| l_tl_table_col_names_list);

      IF l_has_data_level_id THEN
        l_base_table_copy_dml := ' INSERT INTO '||l_b_table_name||
                                 ' (EXTENSION_ID, '||
                                    l_insert_pk_sql ||' '||
                                  ' DATA_LEVEL_ID, '||
                                    l_all_dl_cols ||' '||
                                    l_insert_class_code_sql ||' '||
                                    l_b_table_col_names_list||' '||
                                   'CREATED_BY, '||
                                   'CREATION_DATE, '||
                                   'LAST_UPDATED_BY, '||
                                   'LAST_UPDATE_DATE, '||
                                   'LAST_UPDATE_LOGIN)'||
                                 ' SELECT '||
                                    ':1, '||
                                    l_select_pk_sql ||' '||
                                    p_new_data_level_id ||', '||
                                    l_select_dtlevel_sql ||' '||
                                    l_select_class_code_sql ||' '||
                                    l_b_table_col_names_list||' '||
                                    l_current_user_id||', '||
                                   'SYSDATE, '||
                                    l_current_user_id||', '||
                                   'SYSDATE, '||
                                    l_current_login_id||
                                 ' FROM '||l_b_table_name||
                                ' WHERE EXTENSION_ID = :2';
        IF (l_tl_table_name IS NOT NULL) THEN
          l_tl_table_copy_dml := ' INSERT INTO '||l_tl_table_name||
                                 ' (EXTENSION_ID, '||
                                    l_insert_pk_sql ||' '||
                                  ' DATA_LEVEL_ID, '||
                                    l_all_dl_cols ||' '||
                                    l_insert_class_code_sql ||' '||
                                    l_tl_table_col_names_list||' '||
                                   'CREATED_BY, '||
                                   'CREATION_DATE, '||
                                   'LAST_UPDATED_BY, '||
                                   'LAST_UPDATE_DATE, '||
                                   'LAST_UPDATE_LOGIN)'||
                                 ' SELECT '||
                                    ':1, '||
                                    l_select_pk_sql ||' '||
                                    p_new_data_level_id ||', '||
                                    l_select_dtlevel_sql ||' '||
                                    l_select_class_code_sql ||' '||
                                    l_tl_table_col_names_list||' '||
                                    l_current_user_id||', '||
                                   'SYSDATE, '||
                                    l_current_user_id||', '||
                                   'SYSDATE, '||
                                    l_current_login_id||
                                 ' FROM '||l_tl_table_name||
                                ' WHERE EXTENSION_ID = :2';
        END IF;
      ELSE
        l_base_table_copy_dml := ' INSERT INTO '||l_b_table_name||
                                 ' (EXTENSION_ID, '||
                                    l_insert_pk_sql ||' '||
                                    l_insert_dtlevel_sql ||' '||
                                    l_insert_class_code_sql ||' '||
                                    l_b_table_col_names_list||' '||
                                   'CREATED_BY, '||
                                   'CREATION_DATE, '||
                                   'LAST_UPDATED_BY, '||
                                   'LAST_UPDATE_DATE, '||
                                   'LAST_UPDATE_LOGIN)'||
                                 ' SELECT '||
                                    ':1, '||
                                    l_select_pk_sql ||' '||
                                    l_select_dtlevel_sql ||' '||
                                    l_select_class_code_sql ||' '||
                                    l_b_table_col_names_list||' '||
                                    l_current_user_id||', '||
                                   'SYSDATE, '||
                                    l_current_user_id||', '||
                                   'SYSDATE, '||
                                    l_current_login_id||
                                 ' FROM '||l_b_table_name||
                                ' WHERE EXTENSION_ID = :2';

        IF (l_tl_table_name IS NOT NULL) THEN
          l_tl_table_copy_dml := ' INSERT INTO '||l_tl_table_name||
                                 ' (EXTENSION_ID, '||
                                    l_insert_pk_sql ||' '||
                                    l_insert_dtlevel_sql ||' '||
                                    l_insert_class_code_sql ||' '||
                                    l_tl_table_col_names_list||' '||
                                   'CREATED_BY, '||
                                   'CREATION_DATE, '||
                                   'LAST_UPDATED_BY, '||
                                   'LAST_UPDATE_DATE, '||
                                   'LAST_UPDATE_LOGIN)'||
                                 ' SELECT '||
                                    ':1, '||
                                    l_select_pk_sql ||' '||
                                    l_select_dtlevel_sql ||' '||
                                    l_select_class_code_sql ||' '||
                                    l_tl_table_col_names_list||' '||
                                    l_current_user_id||', '||
                                   'SYSDATE, '||
                                    l_current_user_id||', '||
                                   'SYSDATE, '||
                                    l_current_login_id||
                                 ' FROM '||l_tl_table_name||
                                ' WHERE EXTENSION_ID = :2';
        END IF;
      END IF;  -- l_has_data_level
      Debug_Msg(l_api_name || ' l_base_table_copy_dml: '||l_base_table_copy_dml);
      Debug_Msg(l_api_name || ' l_tl_table_copy_dml: '||l_tl_table_copy_dml);
      ------------------------------------------------------------------------
      -- We build a cursor to query extension IDs from the copy-from object --
      -- and to generate extension IDs for the copy-to object; then we loop --
      -- through that cursor inserting rows for the copy-to object into the --
      -- B and TL tables, using the copy-from object's values.              --
      ------------------------------------------------------------------------
      --bug 8655864 start
      Debug_msg(l_api_name || ' l_where_dtlevel_sql: ' || l_where_dtlevel_sql);
      IF (p_attr_group_list IS NOT NULL) THEN

        l_dynamic_sql := ' SELECT EXTENSION_ID, EGO_EXTFWK_S.NEXTVAL '||
                         ' FROM '||NVL(l_vl_name, l_b_table_name)||
                         ' WHERE '||l_where_pk_sql||l_where_dtlevel_sql||
                         ' ATTR_GROUP_ID IN ('||p_attr_group_list||')';

      ELSE
        l_dynamic_sql := ' SELECT EXTENSION_ID, EGO_EXTFWK_S.NEXTVAL '||
                         ' FROM '||NVL(l_vl_name, l_b_table_name)||
                         ' WHERE '||l_where_pk_sql||l_where_dtlevel_sql;

      -------------------------------------------------------------
      -- Trim the last 'AND' that is left on l_where_dtlevel_sql --
      -------------------------------------------------------------
       l_dynamic_sql := SUBSTR(l_dynamic_sql, 1, LENGTH(l_dynamic_sql) - LENGTH(' AND'));
      END IF;

      --13871278 using binding in l_dynamic_sql
      l_pk_cursor := dbms_sql.open_cursor;
      DBMS_SQL.PARSE(l_pk_cursor, l_dynamic_sql, DBMS_SQL.native);
      DBMS_SQL.DEFINE_COLUMN(l_pk_cursor, 1, l_copy_from_ext_id);
      DBMS_SQL.DEFINE_COLUMN(l_pk_cursor, 2, l_copy_to_ext_id);
      FOR l_pk_index IN 1 .. l_pk_array.count
      LOOP
          DBMS_SQL.BIND_VARIABLE(l_pk_cursor, ':PK'||(l_pk_index), l_pk_array(l_pk_index));
      END LOOP;
      FOR l_dtlevel_index IN 1 .. l_dt_array.count
      LOOP
          DBMS_SQL.BIND_VARIABLE(l_pk_cursor, ':DT'||(l_dtlevel_index), l_dt_array(l_dtlevel_index));
      END LOOP;
      l_dummy := DBMS_SQL.EXECUTE(l_pk_cursor);
      --bug 8655864 end
      --OPEN l_dynamic_cursor FOR l_dynamic_sql;
      LOOP
        --FETCH l_dynamic_cursor INTO l_copy_from_ext_id, l_copy_to_ext_id;
        IF DBMS_SQL.FETCH_ROWS(l_pk_cursor)>0 THEN
          DBMS_SQL.COLUMN_VALUE(l_pk_cursor, 1, l_copy_from_ext_id);
          DBMS_SQL.COLUMN_VALUE(l_pk_cursor, 2, l_copy_to_ext_id);

        --EXIT WHEN l_dynamic_cursor%NOTFOUND;

          EXECUTE IMMEDIATE l_base_table_copy_dml USING l_copy_to_ext_id, l_copy_from_ext_id;

          IF (l_tl_table_name IS NOT NULL) THEN
            EXECUTE IMMEDIATE l_tl_table_copy_dml USING l_copy_to_ext_id, l_copy_from_ext_id;

          END IF;
        ELSE
          Debug_Msg(l_api_name || ' NO RECORDS in l_pk_cursor');
          EXIT;
        END IF;
      END LOOP;
      DBMS_SQL.CLOSE_CURSOR(l_pk_cursor);
      --CLOSE l_dynamic_cursor;
     END LOOP;
    END IF; -- l_attr_group_types

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg(l_api_name || ' EXCEPTION FND_API.G_EXC_ERROR');
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Copy_User_Attrs_Data_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name      => x_msg_data
       ,p_application_id    => 'EGO'
       ,p_message_type      => FND_API.G_RET_STS_ERROR
       ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
      );

    WHEN OTHERS THEN
      IF DBMS_SQL.IS_OPEN(l_pk_cursor) then
         DBMS_SQL.CLOSE_CURSOR(l_pk_cursor);
      END IF;
      Debug_Msg(l_api_name || ' EXCEPTION OTHERS '||SQLERRM);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Copy_User_Attrs_Data_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name      => 'EGO_PLSQL_ERR'
         ,p_application_id    => 'EGO'
         ,p_token_tbl         => l_token_table
         ,p_message_type      => FND_API.G_RET_STS_ERROR
         ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
        );
      END;

END Copy_User_Attrs_Data;

---------------------------------------------------------------------------

PROCEDURE Implement_Change_Line (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_production_b_table_name       IN   VARCHAR2
       ,p_production_tl_table_name      IN   VARCHAR2
       ,p_change_b_table_name           IN   VARCHAR2
       ,p_change_tl_table_name          IN   VARCHAR2
       ,p_tables_application_id         IN   NUMBER
       ,p_change_line_id                IN   NUMBER
       ,p_old_data_level_nv_pairs       IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_new_data_level_nv_pairs       IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_related_class_code_function   IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Implement_Change_Line';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_object_id              NUMBER;
    l_data_level_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_current_dl_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    l_chng_col_names_list    VARCHAR2(20000);
    l_cols_to_exclude_list   VARCHAR2(2000);
    l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_b_chng_cols_list       VARCHAR2(10000);
    l_tl_chng_cols_list      VARCHAR2(10000);
    l_history_b_chng_cols_list VARCHAR2(10000);
    l_history_tl_chng_cols_list VARCHAR2(10000);
    l_history_b_prod_cols_list VARCHAR2(10000);
    l_history_tl_prod_cols_list VARCHAR2(10000);
    l_dynamic_sql            VARCHAR2(32767); --the largest a VARCHAR2 can be
    l_cursor_id              NUMBER;
    l_column_count           NUMBER;
    l_desc_table             DBMS_SQL.Desc_Tab;
    l_retrieved_value        VARCHAR2(1000);
    l_dummy                  NUMBER;
    l_current_column_index   NUMBER;
    l_current_row_language   VARCHAR2(30);
    l_current_row_source_lang VARCHAR2(30);
    l_current_acd_type       VARCHAR2(30);
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_current_pending_ext_id NUMBER;
    l_current_column_name    VARCHAR2(30);
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;
    l_dummy_err_msg_name     VARCHAR2(30);
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_attr_name_value_pairs  EGO_USER_ATTR_DATA_TABLE := EGO_USER_ATTR_DATA_TABLE();
    l_uom_column_nv_pairs    LOCAL_COL_NV_PAIR_TABLE;
    l_uom_nv_pairs_index     NUMBER := 0;
    l_current_uom_col_nv_obj EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_attr_col_name_for_uom_col VARCHAR2(30);
    l_current_production_ext_id NUMBER;
    l_mode_for_current_row   VARCHAR2(10);
    l_ext_id_for_current_row NUMBER;
    l_utility_dynamic_sql    VARCHAR2(32767); --the largest a VARCHAR2 can be
    l_return_status          VARCHAR2(1);
    l_errorcode              NUMBER;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);

  BEGIN

    Debug_Msg('In Implement_Change_Line, starting', 1);

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Implement_Change_Line_PUB;
    END IF;

    -- Initialize FND_MSG_PUB and ERROR_HANDLER if necessary
    IF (FND_API.To_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.Initialize;
      ERROR_HANDLER.Initialize;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -----------------------------------------------
    -- First, we get the Object ID for our calls --
    -----------------------------------------------
    l_object_id := Get_Object_Id_From_Name(p_object_name);

    ----------------------------------------------------
    -- Determine whether we got new Data Level values --
    ----------------------------------------------------
    IF (p_new_data_level_nv_pairs IS NOT NULL) THEN
      l_data_level_name_value_pairs := p_new_data_level_nv_pairs;
    ELSE
      l_data_level_name_value_pairs := p_old_data_level_nv_pairs;
    END IF;

    ---------------------------------------------------------
    -- Get the necessary metadata for our production table --
    ---------------------------------------------------------
    l_ext_table_metadata_obj :=
      EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(l_object_id);

    ----------------------------------------------------------
    -- Build a PK name/value pair array and begin the lists --
    -- of column names to fetch explicitly instead of from  --
    -- our constructed table columns list                   --
    ----------------------------------------------------------

    --
    -- ASSUMPTION: no PKs will ever be DATE objects
    --
    IF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 5) THEN
      l_pk_column_name_value_pairs :=
        EGO_COL_NAME_VALUE_PAIR_ARRAY(
          EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME, NULL
          )
         ,EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME, NULL
          )
         ,EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME, NULL
          )
         ,EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME, NULL
          )
         ,EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(5).COL_NAME, NULL
          )
        );
      l_chng_col_names_list := 'B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME||
                               ',B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME||
                               ',B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME||
                               ',B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME||
                               ',B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(5).COL_NAME;
      l_cols_to_exclude_list := ''''||
                                l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME||
                                ''','''||
                                l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME||
                                ''','''||
                                l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME||
                                ''','''||
                                l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME||
                                ''','''||
                                l_ext_table_metadata_obj.pk_column_metadata(5).COL_NAME||
                                '''';
    ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 4) THEN
      l_pk_column_name_value_pairs :=
        EGO_COL_NAME_VALUE_PAIR_ARRAY(
          EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME, NULL
          )
         ,EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME, NULL
          )
         ,EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME, NULL
          )
         ,EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME, NULL
          )
        );
      l_chng_col_names_list := 'B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME||
                               ',B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME||
                               ',B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME||
                               ',B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME;
      l_cols_to_exclude_list := ''''||
                                l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME||
                                ''','''||
                                l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME||
                                ''','''||
                                l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME||
                                ''','''||
                                l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME||
                                '''';
    ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 3) THEN
      l_pk_column_name_value_pairs :=
        EGO_COL_NAME_VALUE_PAIR_ARRAY(
          EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME, NULL
          )
         ,EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME, NULL
          )
         ,EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME, NULL
          )
        );
      l_chng_col_names_list := 'B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME||
                               ',B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME||
                               ',B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME;
      l_cols_to_exclude_list := ''''||
                                l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME||
                                ''','''||
                                l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME||
                                ''','''||
                                l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME||
                                '''';
    ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 2) THEN
      l_pk_column_name_value_pairs :=
        EGO_COL_NAME_VALUE_PAIR_ARRAY(
          EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME, NULL
          )
         ,EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME, NULL
          )
        );
      l_chng_col_names_list := 'B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME||
                               ',B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME;
      l_cols_to_exclude_list := ''''||
                                l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME||
                                ''','''||
                                l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME||
                                '''';
    ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 1) THEN
      l_pk_column_name_value_pairs :=
        EGO_COL_NAME_VALUE_PAIR_ARRAY(
          EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME, NULL
          )
        );
      l_chng_col_names_list := 'B.'||
                               l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME;
      l_cols_to_exclude_list := ''''||
                                l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME||
                                '''';
    END IF;

    ----------------------------------------------------------
    -- Now we add Classification Code columns to the lists, --
    -- if necessary; this includes room for a list of Class --
    -- Codes that are related to the current Class Code     --
    ----------------------------------------------------------
    IF (l_ext_table_metadata_obj.class_code_metadata IS NOT NULL AND
        l_ext_table_metadata_obj.class_code_metadata.COUNT > 0 AND
        l_ext_table_metadata_obj.class_code_metadata(1).COL_NAME IS NOT NULL) THEN
      l_class_code_name_value_pairs :=
        EGO_COL_NAME_VALUE_PAIR_ARRAY(
          EGO_COL_NAME_VALUE_PAIR_OBJ(
            l_ext_table_metadata_obj.class_code_metadata(1).COL_NAME, NULL
          ),
          EGO_COL_NAME_VALUE_PAIR_OBJ(
            'RELATED_CLASS_CODE_LIST_1', NULL
          )
        );

      l_chng_col_names_list := l_chng_col_names_list||',B.'||
                               l_ext_table_metadata_obj.class_code_metadata(1).COL_NAME;

      l_cols_to_exclude_list := l_cols_to_exclude_list||','''||
                                l_ext_table_metadata_obj.class_code_metadata(1).COL_NAME||
                                '''';
    END IF;

    -----------------------------------------------------------------
    -- For Data Level, we exclude the columns but don't explicitly --
    -- include them, because we already have the values we want    --
    -----------------------------------------------------------------
    IF (l_ext_table_metadata_obj.data_level_metadata IS NOT NULL) THEN
      IF (l_ext_table_metadata_obj.data_level_metadata.COUNT > 0) THEN
        l_cols_to_exclude_list :=
          l_cols_to_exclude_list||','''||
          l_ext_table_metadata_obj.data_level_metadata(1).COL_NAME||
          '''';
      END IF;
      IF (l_ext_table_metadata_obj.data_level_metadata.COUNT > 1) THEN
        l_cols_to_exclude_list :=
          l_cols_to_exclude_list||','''||
          l_ext_table_metadata_obj.data_level_metadata(2).COL_NAME||
          '''';
      END IF;
      IF (l_ext_table_metadata_obj.data_level_metadata.COUNT > 2) THEN
        l_cols_to_exclude_list :=
          l_cols_to_exclude_list||','''||
          l_ext_table_metadata_obj.data_level_metadata(3).COL_NAME||
          '''';
      END IF;
    END IF;

    ---------------------------------------------------------------
    -- Next, we add to the lists the rest of the columns that we --
    -- either want to get explicitly or don't want to get at all --
    ---------------------------------------------------------------
    l_chng_col_names_list := l_chng_col_names_list||
                             ',B.ACD_TYPE,B.ATTR_GROUP_ID,B.EXTENSION_ID';
    l_cols_to_exclude_list := l_cols_to_exclude_list||
                              ',''ACD_TYPE'',''ATTR_GROUP_ID'',''EXTENSION_ID'','||
                              '''CHANGE_ID'',''CHANGE_LINE_ID'','||
                              '''IMPLEMENTATION_DATE'',''CREATED_BY'','||
                              '''CREATION_DATE'',''LAST_UPDATED_BY'','||
                              '''LAST_UPDATE_DATE'',''LAST_UPDATE_LOGIN''';

    ----------------------------------------------------------
    -- Get lists of columns for the B and TL pending tables --
    -- (i.e., all Attr cols and the language cols from TL)  --
    ----------------------------------------------------------
    l_b_chng_cols_list := Get_Table_Columns_List(
                            p_application_id            => p_tables_application_id
                           ,p_from_table_name           => p_change_b_table_name
                           ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                           ,p_cast_date_cols_to_char    => TRUE
                          );
    l_tl_chng_cols_list := Get_Table_Columns_List(
                             p_application_id            => p_tables_application_id
                            ,p_from_table_name           => p_change_tl_table_name
                            ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                            ,p_cast_date_cols_to_char    => TRUE
                           );

    --------------------------------------------------------
    -- While we're getting lists of columns, we also get  --
    -- lists for later use in copying old production rows --
    -- into the pending tables as HISTORY rows            --
    --------------------------------------------------------
    l_cols_to_exclude_list := '''CHANGE_ID'', ''CHANGE_LINE_ID'', ''ACD_TYPE'', ''IMPLEMENTATION_DATE'', ''EXTENSION_ID'' , ''PROGRAM_ID'', ''PROGRAM_UPDATE_DATE'' , ''REQUEST_ID'' ,''PROGRAM_APPLICATION_ID'' ';

    l_history_b_chng_cols_list := Get_Table_Columns_List(
                                    p_application_id            => p_tables_application_id
                                   ,p_from_table_name           => p_change_b_table_name
                                   ,p_from_table_alias_prefix   => 'CT'
                                   ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                  );
    l_history_tl_chng_cols_list := Get_Table_Columns_List(
                                     p_application_id            => p_tables_application_id
                                    ,p_from_table_name           => p_change_tl_table_name
                                    ,p_from_table_alias_prefix   => 'CT'
                                    ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                   );
    l_history_b_prod_cols_list := Get_Table_Columns_List(
                                    p_application_id            => p_tables_application_id
                                   ,p_from_table_name           => p_production_b_table_name
                                   ,p_from_table_alias_prefix   => 'PT'
                                   ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                  );
    l_history_tl_prod_cols_list := Get_Table_Columns_List(
                                     p_application_id            => p_tables_application_id
                                    ,p_from_table_name           => p_production_tl_table_name
                                    ,p_from_table_alias_prefix   => 'PT'
                                    ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                   );

    -------------------------------------------------
    -- Now we build the SQL for our dynamic cursor --
    -------------------------------------------------
    l_dynamic_sql := 'SELECT '||l_chng_col_names_list||','||
                                l_b_chng_cols_list||','||
                                l_tl_chng_cols_list||
                      ' FROM '||p_change_b_table_name||' B,'||
                                p_change_tl_table_name||' TL'||
                     ' WHERE B.ACD_TYPE <> ''HISTORY'' AND B.IMPLEMENTATION_DATE IS NULL'||
                       ' AND B.EXTENSION_ID = TL.EXTENSION_ID'||
                       ' AND B.ACD_TYPE = TL.ACD_TYPE'||
                       ' AND B.CHANGE_LINE_ID = TL.CHANGE_LINE_ID'||
                       ' AND B.CHANGE_LINE_ID = :1';

    l_cursor_id := DBMS_SQL.Open_Cursor;
    DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.Native);
    DBMS_SQL.Bind_Variable(l_cursor_id, ':1', p_change_line_id);
    DBMS_SQL.Describe_Columns(l_cursor_id, l_column_count, l_desc_table);

    FOR i IN 1 .. l_column_count
    LOOP
      -------------------------------------------------------------
      -- We define all columns as VARCHAR2(1000) for convenience --
       -- ASSUMPTION: no PKs will ever be DATE objects           --
      -------------------------------------------------------------
      DBMS_SQL.Define_Column(l_cursor_id, i, l_retrieved_value, 1000);
    END LOOP;

    ----------------------------------
    -- Execute our dynamic query... --
    ----------------------------------
    l_dummy := DBMS_SQL.Execute(l_cursor_id);

    ----------------------------------------------------
    -- ...then loop through the result set, gathering --
    -- the column values and then calling Process_Row --
    ----------------------------------------------------
    WHILE (DBMS_SQL.Fetch_Rows(l_cursor_id) > 0)
    LOOP

      l_current_column_index := 1;
      l_attr_name_value_pairs.DELETE();

      ------------------------------------
      -- Get the PK values for this row --
      ------------------------------------
      IF (l_pk_column_name_value_pairs.COUNT > 0) THEN
        DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
        l_current_column_index := l_current_column_index + 1;
        l_pk_column_name_value_pairs(1).VALUE := SUBSTRB(l_retrieved_value, 1, 150);
      END IF;
      IF (l_pk_column_name_value_pairs.COUNT > 1) THEN
        DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
        l_current_column_index := l_current_column_index + 1;
        l_pk_column_name_value_pairs(2).VALUE := SUBSTRB(l_retrieved_value, 1, 150);
      END IF;
      IF (l_pk_column_name_value_pairs.COUNT > 2) THEN
        DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
        l_current_column_index := l_current_column_index + 1;
        l_pk_column_name_value_pairs(3).VALUE := SUBSTRB(l_retrieved_value, 1, 150);
      END IF;
      IF (l_pk_column_name_value_pairs.COUNT > 3) THEN
        DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
        l_current_column_index := l_current_column_index + 1;
        l_pk_column_name_value_pairs(4).VALUE := SUBSTRB(l_retrieved_value, 1, 150);
      END IF;
      IF (l_pk_column_name_value_pairs.COUNT > 4) THEN
        DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
        l_current_column_index := l_current_column_index + 1;
        l_pk_column_name_value_pairs(5).VALUE := SUBSTRB(l_retrieved_value, 1, 150);
      END IF;

      ------------------------------------------------
      -- Get the Class Code value, if there is one, --
      -- and try to get related Class Codes as well --
      ------------------------------------------------
      IF (l_class_code_name_value_pairs IS NOT NULL AND
          l_class_code_name_value_pairs.COUNT > 0) THEN
        DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
        l_current_column_index := l_current_column_index + 1;
        l_class_code_name_value_pairs(1).VALUE := SUBSTRB(l_retrieved_value, 1, 150);

        EXECUTE IMMEDIATE 'BEGIN '||p_related_class_code_function||'(:1, :2); END;'
        USING IN  l_class_code_name_value_pairs(1).VALUE,
              OUT l_class_code_name_value_pairs(2).VALUE;
      END IF;

      ----------------------------
      -- Determine the ACD Type --
      ----------------------------
      DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
      l_current_column_index := l_current_column_index + 1;
      l_current_acd_type := l_retrieved_value;

      ---------------------------------------------------------
      -- Find the Attr Group metadata from the Attr Group ID --
      ---------------------------------------------------------
      DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
      l_current_column_index := l_current_column_index + 1;
      l_attr_group_metadata_obj :=
        EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
          p_attr_group_id => TO_NUMBER(l_retrieved_value)
        );

      ---------------------------------------------------------------
      -- Determine whether this Attr Group needs Data Level values --
      ---------------------------------------------------------------
      IF (Is_Data_Level_Correct
             (p_object_id                     => l_object_id
             ,p_attr_group_id                 => l_attr_group_metadata_obj.ATTR_GROUP_ID
             ,p_ext_table_metadata_obj        => l_ext_table_metadata_obj
             ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
             ,p_data_level                    => NULL
             ,p_data_level_name_value_pairs   => l_data_level_name_value_pairs
             ,p_attr_group_disp_name          => l_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME
             ,x_err_msg_name                  => l_dummy_err_msg_name
             ,x_token_table                   => l_token_table)
         ) THEN
        l_current_dl_name_value_pairs := l_data_level_name_value_pairs;
      ELSE
        --------------------------------------------------------------------
        -- If the passed-in Data Levels are incorrect (e.g., they include --
        -- Revision ID for an Attr Group associated at the Item level),   --
        -- we will try to pass NULL and hope it works.  NOTE: this is an  --
        -- imperfect fix; it'll work for Items, but maybe not in general  --
        --------------------------------------------------------------------
/***
TO DO: make this logic more robust; right now it assumes that either
we use all the passed-in Data Levels or none of them, but what about
someday if there's a multi-DL implementation (i.e., one in which there's
more than a binary situation of "passing DL" or "not passing DL"--e.g.,
"passing some but not all DL")?
***/
        l_token_table.DELETE();
        l_current_dl_name_value_pairs := NULL;
      END IF;

      --------------------------
      -- Get the extension ID --
      --------------------------
      DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
      l_current_column_index := l_current_column_index + 1;
      l_current_pending_ext_id := TO_NUMBER(l_retrieved_value);

      -------------------------------------------------------------------
      -- Now we loop through the rest of the columns assigning values  --
      -- to Attr data objects, which we add to a table of such objects --
      -------------------------------------------------------------------
      FOR i IN l_current_column_index .. l_column_count
      LOOP

        -----------------------------------------------
        -- Get the current column name and its value --
        -----------------------------------------------
        l_current_column_name := l_desc_table(i).COL_NAME;
        DBMS_SQL.Column_Value(l_cursor_id, i, l_retrieved_value);

        ------------------------------------------------------------------------
        -- See whether the current column belongs to a User-Defined Attribute --
        ------------------------------------------------------------------------
        l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                 p_attr_metadata_table => l_attr_group_metadata_obj.attr_metadata_table
                                ,p_db_column_name      => l_current_column_name
                               );

        ------------------------------------------------
        -- If the current column is an Attr column... --
        ------------------------------------------------
        IF (l_attr_metadata_obj IS NOT NULL AND
            l_attr_metadata_obj.ATTR_NAME IS NOT NULL) THEN

          -----------------------------------------------------
          -- ...then we add its value to our Attr data table --
          -----------------------------------------------------
          l_attr_name_value_pairs.EXTEND();
          l_attr_name_value_pairs(l_attr_name_value_pairs.LAST) :=
            EGO_USER_ATTR_DATA_OBJ(
              1
             ,l_attr_metadata_obj.ATTR_NAME
             ,null -- ATTR_VALUE_STR
             ,null -- ATTR_VALUE_NUM
             ,null -- ATTR_VALUE_DATE
             ,null -- ATTR_DISP_VALUE
             ,null -- ATTR_UNIT_OF_MEASURE (will be set below if necessary)
             ,-1
            );

          --------------------------------------------------------
          -- We assign l_retrieved_value according to data type --
          --------------------------------------------------------
          IF (l_attr_metadata_obj.DATA_TYPE_CODE = 'N') THEN
            -----------------------------
            -- We deal with UOMs below --
            -----------------------------
            l_attr_name_value_pairs(l_attr_name_value_pairs.LAST).ATTR_VALUE_NUM :=
              TO_NUMBER(l_retrieved_value);
          ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = 'X') THEN
            l_attr_name_value_pairs(l_attr_name_value_pairs.LAST).ATTR_VALUE_DATE :=
              TRUNC(TO_DATE(l_retrieved_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));
          ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = 'Y') THEN
            l_attr_name_value_pairs(l_attr_name_value_pairs.LAST).ATTR_VALUE_DATE :=
              TO_DATE(l_retrieved_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
          ELSE
            l_attr_name_value_pairs(l_attr_name_value_pairs.LAST).ATTR_VALUE_STR :=
              l_retrieved_value;
          END IF;
        ELSIF (INSTR(l_current_column_name, 'UOM_') = 1) THEN

          --------------------------------------------
          -- Store the UOM column's name and value  --
          -- in a PL/SQL table for assignment below --
          --------------------------------------------
          l_uom_nv_pairs_index := l_uom_nv_pairs_index + 1;
          l_uom_column_nv_pairs(l_uom_nv_pairs_index) :=
            EGO_COL_NAME_VALUE_PAIR_OBJ(l_current_column_name, l_retrieved_value);

        ELSIF (l_current_column_name = 'LANGUAGE') THEN

          -------------------------------------------------------
          -- Determine the Language for passing to Process_Row --
          -------------------------------------------------------
          l_current_row_language := l_retrieved_value;

        ELSIF (l_current_column_name = 'SOURCE_LANG') THEN

          ------------------------------------------------
          -- Determine the Source Lang for knowing when --
          -- to insert a History row into the B table   --
          ------------------------------------------------
          l_current_row_source_lang := l_retrieved_value;

        END IF;
      END LOOP;

      ---------------------------------------------------------
      -- If we gathered any UOM data, we assign all gathered --
      -- UOM values to the appropriate Attr data object      --
      ---------------------------------------------------------
      IF (l_uom_nv_pairs_index > 0) THEN

        FOR i IN 1 .. l_uom_nv_pairs_index
        LOOP

          l_current_uom_col_nv_obj := l_uom_column_nv_pairs(i);

          ----------------------------------------------
          -- We derive the Attr's DB column name from --
          -- the UOM column name in one of two ways   --
          ----------------------------------------------
          IF (INSTR(l_current_uom_col_nv_obj.NAME, 'UOM_EXT_ATTR') = 1) THEN
            l_attr_col_name_for_uom_col := 'N_'||SUBSTR(l_current_uom_col_nv_obj.NAME, 5);
          ELSE
            l_attr_col_name_for_uom_col := SUBSTR(l_current_uom_col_nv_obj.NAME, 5);
          END IF;

          -------------------------------------------------------------
          -- Now we find the Attr from the column name we've derived --
          -- and set its Attr data object's UOM field with our value --
          -------------------------------------------------------------
          IF (l_attr_name_value_pairs IS NOT NULL AND
              l_attr_name_value_pairs.COUNT > 0) THEN

            l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                     p_attr_metadata_table => l_attr_group_metadata_obj.attr_metadata_table
                                    ,p_db_column_name      => l_attr_col_name_for_uom_col
                                   );

            ------------------------------------------------------------------
            -- If we found the metadata object, we look for the data object --
            ------------------------------------------------------------------
            IF (l_attr_metadata_obj IS NOT NULL AND
                l_attr_metadata_obj.ATTR_NAME IS NOT NULL) THEN

              FOR j IN l_attr_name_value_pairs.FIRST .. l_attr_name_value_pairs.LAST
              LOOP
                IF (l_attr_name_value_pairs(j).ATTR_NAME =
                    l_attr_metadata_obj.ATTR_NAME) THEN

                  -----------------------------------------------------------
                  -- When we find the data object, we set its UOM and exit --
                  -----------------------------------------------------------
                  l_attr_name_value_pairs(j).ATTR_UNIT_OF_MEASURE :=
                    l_current_uom_col_nv_obj.VALUE;
                  EXIT;

                END IF;
              END LOOP;
            END IF;
          END IF;
        END LOOP;
      END IF;

      -------------------------------------------------------------------
      -- Now that we've got all necessary data and metadata, we try to --
      -- find a corresponding production row for this pending row; we  --
      -- use the new data level values if we have them, because we are --
      -- trying to see whether or not the row we're about to move into --
      -- the production table already exists there                     --
      -------------------------------------------------------------------
      l_current_production_ext_id :=
        Get_Extension_Id_For_Row(
          p_attr_group_metadata_obj     => l_attr_group_metadata_obj
         ,p_ext_table_metadata_obj      => l_ext_table_metadata_obj
         ,p_pk_column_name_value_pairs  => l_pk_column_name_value_pairs
         ,p_data_level_name_value_pairs => l_current_dl_name_value_pairs
         ,p_attr_name_value_pairs       => l_attr_name_value_pairs
        );

      ---------------------------------------------------------------------
      -- The mode and extension ID we pass to Process_Row are determined --
      -- by the existence of a production row, the ACD Type, and in some --
      -- cases by whether the Attr Group is single-row or multi-row      --
      ---------------------------------------------------------------------
      IF (l_current_acd_type = 'ADD') THEN
        IF (l_current_production_ext_id IS NULL) THEN
          ---------------------------------------
          -- If ACD Type is CREATE and there's --
          -- no production row, we create one  --
          ---------------------------------------
          l_mode_for_current_row := G_IMPLEMENT_CREATE_MODE;
          l_ext_id_for_current_row := l_current_pending_ext_id;
        ELSE
          IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'N') THEN
            ------------------------------------------------------
            -- If ACD Type is CREATE, there's a production row, --
            -- and it's a single-row Attr Group, then someone   --
            -- created the row after this change was proposed,  --
            -- so we'll update the production row; we'll also   --
            -- copy the production Ext ID into the pending row  --
            -- to record the fact that this pending row updated --
            -- this production row                              --
            ------------------------------------------------------
            l_mode_for_current_row := G_UPDATE_MODE;
            l_ext_id_for_current_row := l_current_production_ext_id;

            ------------------------------------------------------------
            -- Process_Row will only process our pending B table row  --
            -- in the loop when LANGUAGE is NULL or when LANGUAGE =   --
            -- SOURCE_LANG, so we change the pending row in that loop --
            ------------------------------------------------------------
            IF (l_current_row_language IS NULL OR
                l_current_row_language = l_current_row_source_lang) THEN

              l_utility_dynamic_sql := 'UPDATE '||p_change_b_table_name||
                                         ' SET EXTENSION_ID = :1'||
                                       ' WHERE EXTENSION_ID = :2'||
                                         ' AND ACD_TYPE = ''ADD'''||
                                         ' AND CHANGE_LINE_ID = :3';
              EXECUTE IMMEDIATE l_utility_dynamic_sql
              USING l_current_production_ext_id
                   ,l_current_pending_ext_id
                   ,p_change_line_id;

            END IF;

            l_utility_dynamic_sql := 'UPDATE '||p_change_tl_table_name||
                                       ' SET EXTENSION_ID = :1'||
                                     ' WHERE EXTENSION_ID = :2'||
                                       ' AND ACD_TYPE = ''ADD'''||
                                       ' AND CHANGE_LINE_ID = :3'||
                                       ' AND LANGUAGE = :4';
            EXECUTE IMMEDIATE l_utility_dynamic_sql
            USING l_current_production_ext_id
                 ,l_current_pending_ext_id
                 ,p_change_line_id
                 ,l_current_row_language;

          ELSE
            ---------------------------------------------------------------
            -- We let the ADD + multi-row + existing production row case --
            -- through so Get_Extension_Id_And_Mode can throw the error  --
            ---------------------------------------------------------------
            l_mode_for_current_row := G_IMPLEMENT_CREATE_MODE;
            l_ext_id_for_current_row := l_current_pending_ext_id;
          END IF;
        END IF;
      ELSIF (l_current_acd_type = 'CHANGE') THEN
        IF (l_current_production_ext_id IS NULL) THEN
          -------------------------------------------------------------
          -- In every case below, we'll use the pending extension ID --
          -------------------------------------------------------------
          l_ext_id_for_current_row := l_current_pending_ext_id;

          --
          -- TO DO: check if pendingExtID is in prod; if so, error
          --

          IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'N') THEN
            -------------------------------------------------------
            -- If ACD Type is CHANGE, there's no production row, --
            -- and it's a single-row Attr Group, that means that --
            -- the row was somehow deleted since this change was --
            -- proposed, so we'll need to re-insert the row.     --
            -------------------------------------------------------
            l_mode_for_current_row := G_IMPLEMENT_CREATE_MODE;
          ELSE
            -------------------------------------------------------
            -- If ACD Type is CHANGE, there's no production row, --
            -- and it's a multi-row Attr Group, there are two    --
            -- possibilities: either the row was deleted since   --
            -- this change was proposed (in which case we will   --
            -- re-insert the row) or else this change involves   --
            -- changing Unique Key values (in which case the     --
            -- production row really does still exist, and we    --
            -- really do want to change it); we look for the     --
            -- production row using the pending extension ID to  --
            -- see which of these two possibilities we face now  --
            -------------------------------------------------------
            EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM '||p_change_b_table_name||
                              ' WHERE EXTENSION_ID = :1'
            INTO l_dummy
            USING l_current_pending_ext_id;

            IF (l_dummy > 0) THEN
              l_mode_for_current_row := G_UPDATE_MODE;
            ELSE
              l_mode_for_current_row := G_IMPLEMENT_CREATE_MODE;
            END IF;
          END IF;
        ELSE
          ---------------------------------------
          -- If ACD Type is CHANGE and there's --
          -- a production row, we change it    --
          ---------------------------------------
          l_mode_for_current_row := G_UPDATE_MODE;
          l_ext_id_for_current_row := l_current_production_ext_id;
        END IF;
      ELSIF (l_current_acd_type = 'DELETE') THEN
        IF (l_current_production_ext_id IS NULL) THEN
          ---------------------------------------
          -- If ACD Type is DELETE and there's --
          -- no production row, we do nothing  --
          ---------------------------------------
          l_mode_for_current_row := 'SKIP';
        ELSE
          ---------------------------------------
          -- If ACD Type is DELETE and there's --
          -- a production row, we delete it    --
          ---------------------------------------
          l_mode_for_current_row := G_DELETE_MODE;
          l_ext_id_for_current_row := l_current_production_ext_id;
        END IF;
      END IF;

      IF (l_mode_for_current_row <> 'SKIP') THEN

        -----------------------------------------------------------
        -- If we're altering a production row, we first copy the --
        -- row into the pending tables with the ACD Type HISTORY --
        -----------------------------------------------------------
        IF (l_mode_for_current_row = G_DELETE_MODE OR
            l_mode_for_current_row = G_UPDATE_MODE) THEN

          -----------------------------------------------------------
          -- Process_Row will only process our pending B table row --
          -- in the loop when LANGUAGE is NULL or when LANGUAGE =  --
          -- SOURCE_LANG, so we insert a History row in that loop  --
          -----------------------------------------------------------
          IF (l_current_row_language IS NULL OR
              l_current_row_language = l_current_row_source_lang) THEN
            l_utility_dynamic_sql := ' INSERT INTO '||p_change_b_table_name||' CT ('||
                                     l_history_b_chng_cols_list||
                                     ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, CT.ACD_TYPE'||
                                     ', CT.EXTENSION_ID) SELECT '||
                                     l_history_b_prod_cols_list||
                                     ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'''||
                                     ', PT.EXTENSION_ID FROM '||
                                     p_production_b_table_name||' PT, '||
                                     p_change_b_table_name||
                                     ' CT WHERE PT.EXTENSION_ID = :1'||
                                     ' AND CT.EXTENSION_ID = :2'||
                                     ' AND CT.CHANGE_LINE_ID = :3'||
                                     ' AND CT.ACD_TYPE = :4';

            EXECUTE IMMEDIATE l_utility_dynamic_sql
            USING l_ext_id_for_current_row, l_current_pending_ext_id,
                  p_change_line_id, l_current_acd_type;

          END IF;

          ------------------------------------------------------------
          -- Process_Row will only process the pending TL table row --
          -- whose language matches LANGUAGE, so we only insert a   --
          -- History row for that row                               --
          ------------------------------------------------------------
          l_utility_dynamic_sql := ' INSERT INTO '||p_change_tl_table_name||' CT ('||
                                   l_history_tl_chng_cols_list||
                                   ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, CT.ACD_TYPE'||
                                   ', CT.EXTENSION_ID) SELECT '||
                                   l_history_tl_prod_cols_list||
                                   ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'''||
                                   ', PT.EXTENSION_ID FROM '||
                                   p_production_tl_table_name||' PT, '||
                                   p_change_tl_table_name||
                                   ' CT WHERE PT.EXTENSION_ID = :1'||
                                   ' AND CT.EXTENSION_ID = :2'||
                                   ' AND CT.CHANGE_LINE_ID = :3'||
                                   ' AND CT.ACD_TYPE = :4'||
                                   ' AND CT.LANGUAGE = PT.LANGUAGE AND CT.LANGUAGE = :5';

          EXECUTE IMMEDIATE l_utility_dynamic_sql
          USING l_ext_id_for_current_row, l_current_pending_ext_id,
                p_change_line_id, l_current_acd_type, l_current_row_language;

        END IF;

        ---------------------------------------------------------------------
        -- Now at last we're ready to call Process_Row on this pending row --
        ---------------------------------------------------------------------

        Process_Row(
          p_api_version                   => 1.0
         ,p_object_name                   => p_object_name
         ,p_attr_group_id                 => l_attr_group_metadata_obj.ATTR_GROUP_ID
         ,p_application_id                => l_attr_group_metadata_obj.APPLICATION_ID
         ,p_attr_group_type               => l_attr_group_metadata_obj.ATTR_GROUP_TYPE
         ,p_attr_group_name               => l_attr_group_metadata_obj.ATTR_GROUP_NAME
         ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
         ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
         ,p_data_level_name_value_pairs   => l_current_dl_name_value_pairs
         ,p_extension_id                  => l_ext_id_for_current_row
         ,p_attr_name_value_pairs         => l_attr_name_value_pairs
         ,p_language_to_process           => l_current_row_language
         ,p_mode                          => l_mode_for_current_row
         ,p_add_errors_to_fnd_stack       => FND_API.G_TRUE
         ,x_return_status                 => x_return_status
         ,x_errorcode                     => x_errorcode
         ,x_msg_count                     => x_msg_count
         ,x_msg_data                      => x_msg_data
        );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END LOOP;
    DBMS_SQL.Close_Cursor(l_cursor_id);

    ---------------------------------------------------------------------------
    -- Finally, set the IMPLEMENTATION_DATE for all rows we just implemented --
    ---------------------------------------------------------------------------
    EXECUTE IMMEDIATE ' UPDATE '||p_change_b_table_name||
                         ' SET IMPLEMENTATION_DATE = :1'||
                       ' WHERE CHANGE_LINE_ID = :2'
    USING SYSDATE, p_change_line_id;
    EXECUTE IMMEDIATE ' UPDATE '||p_change_tl_table_name||
                         ' SET IMPLEMENTATION_DATE = :1'||
                       ' WHERE CHANGE_LINE_ID = :2'
    USING SYSDATE, p_change_line_id;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Debug_Msg('In Implement_Change_Line, done', 1);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg('In Implement_Change_Line, EXCEPTION FND_API.G_EXC_ERROR ', 1);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Implement_Change_Line_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

      -----------------------------------------------------------------
      -- If Process_Row didn't return any errors, make one ourselves --
      -----------------------------------------------------------------
      IF (x_msg_data IS NULL AND x_msg_count = 0) THEN
        ERROR_HANDLER.Add_Error_Message(
          p_message_name              => 'EGO_EF_IMPLEMENT_ERR'
         ,p_application_id            => 'EGO'
         ,p_message_type              => FND_API.G_RET_STS_ERROR
         ,p_addto_fnd_stack           => 'Y'
        );
      END IF;

      -------------------------------------------------------------------
      -- If Process_Row had more than one error, return the first one  --
      -- (or else return the one we just added to ERROR_HANDLER above) --
      -------------------------------------------------------------------
      IF (x_msg_data IS NULL AND x_msg_count > 0) THEN
        DECLARE
          message_list  ERROR_HANDLER.Error_Tbl_Type;
        BEGIN
          ERROR_HANDLER.Get_Message_List(message_list);
          x_msg_data := message_list(message_list.FIRST).message_text;
        END;
      END IF;

    Debug_Msg('In Implement_Change_Line, got expected error: x_msg_data is '||x_msg_data, 3);

    WHEN OTHERS THEN
      Debug_Msg('In Implement_Change_Line, EXCEPTION OTHERS ', 1);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Implement_Change_Line_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_dummy_entity_index     NUMBER;
        l_dummy_entity_id        VARCHAR2(60);
        l_dummy_message_type     VARCHAR2(1);
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name                  => 'EGO_PLSQL_ERR'
         ,p_application_id                => 'EGO'
         ,p_token_tbl                     => l_token_table
         ,p_message_type                  => FND_API.G_RET_STS_ERROR
         ,p_addto_fnd_stack               => 'Y'
        );

        ERROR_HANDLER.Get_Message(x_message_text => x_msg_data
                                 ,x_entity_index => l_dummy_entity_index
                                 ,x_entity_id    => l_dummy_entity_id
                                 ,x_message_type => l_dummy_message_type);
      END;

    Debug_Msg('In Implement_Change_Line, got unexpected error: x_msg_data is '||x_msg_data, 3);

END Implement_Change_Line;

----------------------------------------------------------------------

--------------------------------------------------------------------
-- This procedure retrieves directly from the extension table the --
-- internal value for an attribute.                               --
--------------------------------------------------------------------

PROCEDURE Get_Ext_Data (
        p_attr_group_metadata_obj   IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_attr_metadata_obj         IN   EGO_ATTR_METADATA_OBJ
       ,p_pk_col1                   IN   VARCHAR2
       ,p_pk_col2                   IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col3                   IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col4                   IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col5                   IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value1                 IN   VARCHAR2
       ,p_pk_value2                 IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value3                 IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value4                 IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value5                 IN   VARCHAR2   DEFAULT NULL
       ,p_data_level                IN   VARCHAR2   DEFAULT NULL
       ,p_dl_pk_values              IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_dl_metadata_obj           IN   EGO_DATA_LEVEL_METADATA_OBJ   DEFAULT NULL
       ,x_str_val                   OUT  NOCOPY     VARCHAR2
       ,x_num_val                   OUT  NOCOPY     NUMBER
       ,x_date_val                  OUT  NOCOPY     DATE
)
IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Get_Ext_Data';
    l_db_column_alias        VARCHAR2(90);
    l_dynamic_sql            VARCHAR2(7000);
    l_bind_index             NUMBER;
    l_cursor                 NUMBER;
    l_row_count              NUMBER;
    l_str                    VARCHAR2(200);

l_token_table          ERROR_HANDLER.Token_Tbl_Type;
l_has_data_level_id    BOOLEAN  := FALSE;                   -- TRUE is for R12C

-- In EGOBETRU.sql, we have the following type declaration:
--   TYPE LOCAL_VARCHAR_TABLE        IS TABLE OF VARCHAR2(80)
l_bind_value_table     LOCAL_VARCHAR_TABLE;
l_bind_var_name        VARCHAR2(80);
l_bind_var_value       VARCHAR2(80);
l_bind_var_value_num       NUMBER;

l_dl_pk_index          NUMBER;
l_dl_metadata_obj      EGO_DATA_LEVEL_METADATA_OBJ;

BEGIN

Debug_Msg(l_api_name || '' );
Debug_Msg(l_api_name || ' Get_Ext_Data (' );
Debug_Msg(l_api_name || '   p_attr_group_metadata_obj => <not printed>');
Debug_Msg(l_api_name || '   p_attr_metadata_obj       => <not printed>');
Debug_Msg(l_api_name || '   p_pk_col1                 => ' || p_pk_col1);
Debug_Msg(l_api_name || '   p_pk_col2                 => ' || p_pk_col2);
Debug_Msg(l_api_name || '   p_pk_col3                 => ' || p_pk_col3);
Debug_Msg(l_api_name || '   p_pk_col4                 => ' || p_pk_col4);
Debug_Msg(l_api_name || '   p_pk_col5                 => ' || p_pk_col5);
Debug_Msg(l_api_name || '   p_pk_value1               => ' || p_pk_value1);
Debug_Msg(l_api_name || '   p_pk_value2               => ' || p_pk_value2);
Debug_Msg(l_api_name || '   p_pk_value3               => ' || p_pk_value3);
Debug_Msg(l_api_name || '   p_pk_value4               => ' || p_pk_value4);
Debug_Msg(l_api_name || '   p_pk_value5               => ' || p_pk_value5);
Debug_Msg(l_api_name || '   p_data_level              => ' || p_data_level);
Debug_Msg(l_api_name || '   p_dl_pk_values            => <not printed>');
Debug_Msg(l_api_name || '   p_dl_metadata_obj         => <not printed>');
Debug_Msg(l_api_name || ' )' );

    --======================================================================--
    --                       1. Build the query                             --
    --======================================================================--

    x_str_val         := NULL;
    x_num_val         := NULL;
    x_date_val        := NULL;

    l_db_column_alias := EGO_USER_ATTRS_COMMON_PVT.Create_DB_Col_Alias_If_Needed(p_attr_metadata_obj);

    l_cursor          := DBMS_SQL.OPEN_CURSOR;
    l_bind_index      := 0;

    --------------------------
    -- SELECT, FROM clauses --
    --------------------------

    l_dynamic_sql := 'SELECT ' || l_db_column_alias ||
                     ' FROM ' || NVL(p_attr_group_metadata_obj.EXT_TABLE_VL_NAME
                                     ,p_attr_group_metadata_obj.EXT_TABLE_B_NAME) ||
                     ' WHERE ';

    ------------------------------------------
    -- WHERE conditions: Attribute Group ID --
    ------------------------------------------

    IF (p_attr_group_metadata_obj.ATTR_GROUP_ID_FLAG ='Y') THEN
      l_bind_value_table(l_bind_index) := p_attr_group_metadata_obj.ATTR_GROUP_ID;
Debug_Msg(l_api_name || ' Bind value :' || (l_bind_index + 1) || ' has value ' || l_bind_value_table(l_bind_index) || ' (ATTR_GROUP_ID)');
      l_bind_index := l_bind_index + 1;
      l_dynamic_sql := l_dynamic_sql ||  ' ATTR_GROUP_ID = :1 AND ';
    END IF;

    -----------------------------------
    -- WHERE conditions: Primary key --
    -----------------------------------

    l_bind_value_table(l_bind_index) := p_pk_value1;
Debug_Msg(l_api_name || ' Bind value :' || (l_bind_index + 1) || ' has value ' || l_bind_value_table(l_bind_index) || ' (' || p_pk_col1 || ')');
    l_bind_index := l_bind_index + 1;
    l_dynamic_sql := l_dynamic_sql || p_pk_col1 || ' = :' || l_bind_index;


    IF (p_pk_col2 IS NOT NULL) THEN
      l_bind_value_table(l_bind_index) := p_pk_value2;
Debug_Msg(l_api_name || ' Bind value :' || (l_bind_index + 1) || ' has value ' || l_bind_value_table(l_bind_index) || ' (' || p_pk_col2 || ')');
      l_bind_index := l_bind_index + 1;
      l_dynamic_sql := l_dynamic_sql || ' AND ' || p_pk_col2 || ' = :' || l_bind_index;

      IF (p_pk_col3 IS NOT NULL) THEN
        l_bind_value_table(l_bind_index) := p_pk_value3;
Debug_Msg(l_api_name || ' Bind value :' || (l_bind_index + 1) || ' has value ' || l_bind_value_table(l_bind_index) || ' (' || p_pk_col3 || ')');
        l_bind_index := l_bind_index + 1;
        l_dynamic_sql := l_dynamic_sql || ' AND ' || p_pk_col3 || ' = :' || l_bind_index;

        IF (p_pk_col4 IS NOT NULL) THEN
          l_bind_value_table(l_bind_index) := p_pk_value4;
          l_bind_index := l_bind_index + 1;
          l_dynamic_sql := l_dynamic_sql || ' AND ' || p_pk_col4 || ' = :' || l_bind_index;

          IF (p_pk_col5 IS NOT NULL) THEN
            l_bind_value_table(l_bind_index) := p_pk_value5;
            l_bind_index := l_bind_index + 1;
            l_dynamic_sql := l_dynamic_sql || ' AND ' || p_pk_col5 || ' = :' || l_bind_index;
          END IF;
        END IF;
      END IF;
    END IF;

    --------------------------------------------------------------
    -- WHERE conditions: Data Level ID, Data Level Primary Keys --
    --------------------------------------------------------------

    l_has_data_level_id := FND_API.TO_BOOLEAN(
                 EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(p_table_name => p_attr_group_metadata_obj.EXT_TABLE_B_NAME
                                                              ,p_column_name => 'DATA_LEVEL_ID')
                                             );

    IF p_data_level IS NOT NULL AND l_has_data_level_id THEN
      IF p_dl_metadata_obj IS NULL THEN
          l_dl_metadata_obj := NULL;
          IF (p_attr_group_metadata_obj.ENABLED_DATA_LEVELS IS NOT NULL AND p_attr_group_metadata_obj.ENABLED_DATA_LEVELS.COUNT <> 0) THEN

            FOR dl_index IN p_attr_group_metadata_obj.ENABLED_DATA_LEVELS.FIRST .. p_attr_group_metadata_obj.ENABLED_DATA_LEVELS.LAST
            LOOP

              IF p_attr_group_metadata_obj.ENABLED_DATA_LEVELS(dl_index).data_level_name = p_data_level THEN
                l_dl_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Data_Level_Metadata(p_attr_group_metadata_obj.ENABLED_DATA_LEVELS(dl_index).data_level_id);
Debug_Msg(l_api_name || ' Data level found, exiting loop.');
                -- exit the loop as we found the DL
                EXIT;
              END IF;

            END LOOP;

            IF l_dl_metadata_obj IS NULL THEN
              -- the data level is not correct, flash error message.
              l_token_table(1).TOKEN_NAME := 'DL_NAME';
              l_token_table(1).TOKEN_VALUE := p_data_level;
              l_token_table(2).TOKEN_NAME := 'AG_NAME';
              l_token_table(2).TOKEN_VALUE := p_attr_group_metadata_obj.attr_group_disp_name;
              ERROR_HANDLER.Add_Error_Message(
                  p_message_name      => 'EGO_EF_DL_AG_INVALID'
                 ,p_application_id    => 'EGO'
                 ,p_token_tbl         => l_token_table
                 ,p_message_type      => FND_API.G_RET_STS_ERROR
                 ,p_row_identifier    => G_USER_ROW_IDENTIFIER
                 ,p_entity_id         => NULL
                 ,p_entity_index      => NULL
                 ,p_entity_code       => NULL
                 ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
                );
              l_token_table.DELETE();
              RAISE FND_API.G_EXC_ERROR;
            END IF;

          END IF;
      ELSE
        l_dl_metadata_obj := p_dl_metadata_obj;
      END IF;

      IF l_dl_metadata_obj IS NOT NULL THEN
        l_bind_value_table(l_bind_index) := l_dl_metadata_obj.data_level_id;
        l_bind_index := l_bind_index + 1;
        l_dynamic_sql := l_dynamic_sql || ' AND DATA_LEVEL_ID = :' || l_bind_index;
        IF p_dl_pk_values IS NOT NULL AND p_dl_pk_values.COUNT > 0 THEN
          l_dl_pk_index := p_dl_pk_values.FIRST;

          WHILE (l_dl_pk_index <= p_dl_pk_values.LAST)
          LOOP
            IF p_dl_pk_values(l_dl_pk_index).NAME IS NOT NULL AND
               p_dl_pk_values(l_dl_pk_index).NAME IN
                     (l_dl_metadata_obj.pk_column_name1
                     ,l_dl_metadata_obj.pk_column_name2
                     ,l_dl_metadata_obj.pk_column_name3
                     ,l_dl_metadata_obj.pk_column_name4
                     ,l_dl_metadata_obj.pk_column_name5 ) THEN
              l_bind_value_table(l_bind_index) := p_dl_pk_values(l_dl_pk_index).NAME;
              l_bind_index := l_bind_index + 1;
              l_dynamic_sql := l_dynamic_sql || ' AND ' || p_dl_pk_values(l_dl_pk_index).NAME || ' = :' || l_bind_index;
            END IF;
            l_dl_pk_index := p_dl_pk_values.NEXT(l_dl_pk_index);
          END LOOP;

        END IF;
      END IF;
    END IF; -- p_data_level IS NOT NULL
Debug_Msg(l_api_name || ' Query is:' );
Debug_Msg(l_api_name || '   ' || l_dynamic_sql );
Debug_Msg(l_api_name || ' ' );

    --======================================================================--
    --         2. Parse the query and bind the input variables              --
    --======================================================================--

    DBMS_SQL.PARSE(l_cursor, l_dynamic_sql, DBMS_SQL.NATIVE);

Debug_Msg('Get_Ext_Data(): Bind value table has ' || l_bind_value_table.COUNT || ' elements');

    -- Bind the attribute group ID value, and the primary key values for the object
    FOR i IN l_bind_value_table.FIRST .. l_bind_value_table.LAST
    LOOP
       l_bind_var_name  := ':' || (i + 1);
       l_bind_var_value := l_bind_value_table(i);
       l_bind_var_value_num    := to_number(l_bind_var_value);
Debug_Msg(l_api_name || ' Binding '|| l_bind_var_name || ' to value ' || l_bind_var_value_num);

      DBMS_SQL.BIND_VARIABLE(
        c      => l_cursor,                                        -- SQL query
        name   => l_bind_var_name,                        -- bind variable name
        value  => l_bind_var_value                 -- bind value (VARCHAR2(80))
      );
    END LOOP;

    ------------------------
    -- Define the outputs --
    ------------------------
    IF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
      DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, x_num_val);
    ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = 'X' OR p_attr_metadata_obj.DATA_TYPE_CODE = 'Y') THEN
      DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_str,150);
    ELSE
      DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, x_str_val, 150);
    END IF;

    --======================================================================--
    --    3. Execute the query and fetch the attribute internal value       --
    --======================================================================--

    l_row_count := DBMS_SQL.EXECUTE_AND_FETCH(l_cursor, FALSE);
    IF (l_row_count > 0) THEN

      IF (p_attr_metadata_obj.DATA_TYPE_CODE = 'N') THEN
        DBMS_SQL.COLUMN_VALUE(l_cursor, 1, x_num_val);
      ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = 'X' OR p_attr_metadata_obj.DATA_TYPE_CODE = 'Y') THEN
        DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_str);
        x_date_val := TO_DATE(l_str,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
      ELSE
        DBMS_SQL.COLUMN_VALUE(l_cursor, 1, x_str_val);
      END IF;
    END IF;

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

Debug_Msg(l_api_name || ' Done.' );

END Get_Ext_Data;

----------------------------------------------------------------------

/*
 * Get_User_Attr_Val
 * -----------------
 */
FUNCTION Get_User_Attr_Val (
        p_appl_id           IN   NUMBER
       ,p_attr_grp_type     IN   VARCHAR2
       ,p_attr_grp_name     IN   VARCHAR2               -- Attribute Group Name
       ,p_attr_name         IN   VARCHAR2                     -- Attribute Name
       ,p_object_name       IN   VARCHAR2
       ,p_pk_col1           IN   VARCHAR2
       ,p_pk_col2           IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col3           IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col4           IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col5           IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value1         IN   VARCHAR2
       ,p_pk_value2         IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value3         IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value4         IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value5         IN   VARCHAR2   DEFAULT NULL
       ,p_data_level        IN   VARCHAR2   DEFAULT NULL
       ,p_dl_pk_values      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
)
RETURN VARCHAR2
IS

    l_api_name VARCHAR2(30) := 'Get_User_Attr_Val():';
    l_attr_group_metadata_obj      EGO_ATTR_GROUP_METADATA_OBJ;
                                                    -- declared in EGOSEFD2.sql
    l_attr_metadata_obj            EGO_ATTR_METADATA_OBJ;
    l_pk_column_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_attr_int_value         VARCHAR2(4000);	-- Bug 8757354
    l_attr_disp_value        VARCHAR2(4000);	-- Bug 8757354

    l_attr_metadata_table    EGO_ATTR_METADATA_TABLE;
    l_attr_name_value_pairs  EGO_USER_ATTR_DATA_TABLE;
    l_attr_counter           NUMBER;
    l_temp_attr_metadata     EGO_ATTR_METADATA_OBJ;
    l_temp_str               VARCHAR2(150);
    l_temp_num               NUMBER;
    l_temp_date              DATE;
    --bug 5094087
    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);

l_token_table                 ERROR_HANDLER.Token_Tbl_Type;
l_has_data_level_id           BOOLEAN  := TRUE;    -- TRUE is for R12C
l_curr_data_level_metadata    EGO_DATA_LEVEL_METADATA_OBJ := NULL;
l_curr_data_level_row_obj     EGO_DATA_LEVEL_ROW_OBJ;

  BEGIN

Debug_Msg(l_api_name || '(');
Debug_Msg(l_api_name || '    p_appl_id                 => ' || p_appl_id);
Debug_Msg(l_api_name || '    p_attr_grp_type           => ' || p_attr_grp_type);
Debug_Msg(l_api_name || '    p_attr_grp_name           => ' || p_attr_grp_name);
Debug_Msg(l_api_name || '    p_attr_name               => ' || p_attr_name);
Debug_Msg(l_api_name || '    p_object_name             => ' || p_object_name);
Debug_Msg(l_api_name || '    p_pk_col1                 => ' || p_pk_col1);
Debug_Msg(l_api_name || '    p_pk_col2                 => ' || p_pk_col2);
Debug_Msg(l_api_name || '    p_pk_col3                 => ' || p_pk_col3);
Debug_Msg(l_api_name || '    p_pk_col4                 => ' || p_pk_col4);
Debug_Msg(l_api_name || '    p_pk_col5                 => ' || p_pk_col5);
Debug_Msg(l_api_name || '    p_pk_value1               => ' || p_pk_value1);
Debug_Msg(l_api_name || '    p_pk_value2               => ' || p_pk_value2);
Debug_Msg(l_api_name || '    p_pk_value3               => ' || p_pk_value3);
Debug_Msg(l_api_name || '    p_pk_value4               => ' || p_pk_value4);
Debug_Msg(l_api_name || '    p_pk_value5               => ' || p_pk_value5);
Debug_Msg(l_api_name || '    p_data_level              => ' || p_data_level);
Debug_Msg(l_api_name || '    p_dl_pk_values            => <not printed>');
Debug_Msg(l_api_name || ' )' );

    l_attr_int_value := NULL;

    -----------------------------------------
    -- Get or build the necessary metadata --
    -----------------------------------------
    l_attr_group_metadata_obj :=
      EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                 p_application_id  => p_appl_id
                                ,p_attr_group_type => p_attr_grp_type
                                ,p_attr_group_name => p_attr_grp_name
                               );

    l_attr_metadata_table := l_attr_group_metadata_obj.attr_metadata_table;
    l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                             p_attr_metadata_table => l_attr_group_metadata_obj.attr_metadata_table
                            ,p_attr_name           => p_attr_name
                           );

Debug_Msg(l_api_name || ' Found attribute group metadata ');
Debug_Msg(l_api_name || ' l_attr_metadata_obj (');
Debug_Msg(l_api_name || '   ATTR_GROUP_ID              = ' || l_attr_group_metadata_obj.ATTR_GROUP_ID);
Debug_Msg(l_api_name || '   APPLICATION_ID             = ' || l_attr_group_metadata_obj.APPLICATION_ID);
Debug_Msg(l_api_name || '   ATTR_GROUP_TYPE            = ' || l_attr_group_metadata_obj.ATTR_GROUP_TYPE);
Debug_Msg(l_api_name || '   ATTR_GROUP_NAME            = ' || l_attr_group_metadata_obj.ATTR_GROUP_NAME);
Debug_Msg(l_api_name || '   ATTR_GROUP_DISP_NAME       = ' || l_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME);
Debug_Msg(l_api_name || '   AGV_NAME                   = ' || l_attr_group_metadata_obj.AGV_NAME);
Debug_Msg(l_api_name || '   MULTI_ROW_CODE             = ' || l_attr_group_metadata_obj.MULTI_ROW_CODE);
Debug_Msg(l_api_name || '   VIEW_PRIVILEGE             = ' || l_attr_group_metadata_obj.VIEW_PRIVILEGE);
Debug_Msg(l_api_name || '   EDIT_PRIVILEGE             = ' || l_attr_group_metadata_obj.EDIT_PRIVILEGE);
Debug_Msg(l_api_name || '   EXT_TABLE_B_NAME           = ' || l_attr_group_metadata_obj.EXT_TABLE_B_NAME);
Debug_Msg(l_api_name || '   EXT_TABLE_TL_NAME          = ' || l_attr_group_metadata_obj.EXT_TABLE_TL_NAME);
Debug_Msg(l_api_name || '   EXT_TABLE_VL_NAME          = ' || l_attr_group_metadata_obj.EXT_TABLE_VL_NAME);
Debug_Msg(l_api_name || '   SORT_ATTR_VALUES_FLAG      = ' || l_attr_group_metadata_obj.SORT_ATTR_VALUES_FLAG);
Debug_Msg(l_api_name || '   UNIQUE_KEY_ATTRS_COUNT     = ' || l_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT);
Debug_Msg(l_api_name || '   TRANS_ATTRS_COUNT          = ' || l_attr_group_metadata_obj.TRANS_ATTRS_COUNT);
Debug_Msg(l_api_name || '   ATTR_METADATA_TABLE        = <not displayed>');
Debug_Msg(l_api_name || '   ATTR_GROUP_ID_FLAG         = ' || l_attr_group_metadata_obj.ATTR_GROUP_ID_FLAG);
Debug_Msg(l_api_name || '   HIERARCHY_NODE_QUERY       = ' || l_attr_group_metadata_obj.HIERARCHY_NODE_QUERY);
Debug_Msg(l_api_name || '   HIERARCHY_PROPAGATION_API  = ' || l_attr_group_metadata_obj.HIERARCHY_PROPAGATION_API);
Debug_Msg(l_api_name || '   HIERARCHY_PROPAGATE_FLAG   = ' || l_attr_group_metadata_obj.HIERARCHY_PROPAGATE_FLAG);
Debug_Msg(l_api_name || '   ENABLED_DATA_LEVELS        =  <not displayed>');
Debug_Msg(l_api_name || '   VARIANT                    = ' || l_attr_group_metadata_obj.VARIANT);
Debug_Msg(l_api_name || ' )');


    -- Get data level metadata, if applicable
    IF p_data_level IS NOT NULL THEN
      -- check if the passed in data level is valid for this attribute group.
        Debug_Msg(l_api_name || ' Non-null data level');
        l_has_data_level_id := FND_API.TO_BOOLEAN(
                 EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(p_table_name => l_attr_group_metadata_obj.EXT_TABLE_B_NAME
                                                              ,p_column_name => 'DATA_LEVEL_ID')
                                                 );
        IF l_has_data_level_id THEN
          l_curr_data_level_row_obj := NULL;
          Debug_Msg(l_api_name || ' Has Data Level');
          IF (l_attr_group_metadata_obj.ENABLED_DATA_LEVELS IS NOT NULL AND
              l_attr_group_metadata_obj.ENABLED_DATA_LEVELS.COUNT <> 0) THEN

            Debug_Msg(l_api_name || ' ' || l_attr_group_metadata_obj.ENABLED_DATA_LEVELS.COUNT || ' data level(s) enabled');

            ------------------------------------------------------------------
            -- See if the supplied data level is in the list of enabled     --
            -- data levels for this attribute group.                        --
            ------------------------------------------------------------------
            FOR dl_index IN l_attr_group_metadata_obj.ENABLED_DATA_LEVELS.FIRST ..
                            l_attr_group_metadata_obj.ENABLED_DATA_LEVELS.LAST
            LOOP
              Debug_Msg(l_api_name || ' enabled data level: ' ||
                        l_attr_group_metadata_obj.ENABLED_DATA_LEVELS(dl_index).data_level_name || '(' ||
                        l_attr_group_metadata_obj.ENABLED_DATA_LEVELS(dl_index).data_level_id || ')');
              IF l_attr_group_metadata_obj.ENABLED_DATA_LEVELS(dl_index).data_level_name = p_data_level THEN
                l_curr_data_level_metadata := EGO_USER_ATTRS_COMMON_PVT.Get_Data_Level_Metadata(l_attr_group_metadata_obj.ENABLED_DATA_LEVELS(dl_index).data_level_id);
                Debug_Msg(l_api_name || ' Found Data Level, finished searching.');
                EXIT;
              END IF;
            END LOOP;

            ------------------------------------------------------------------
            -- If the specified data level was not in the list of enabled   --
            -- data levels flash error message.                             --
            ------------------------------------------------------------------
            IF l_curr_data_level_metadata IS NULL THEN
              Debug_Msg(l_api_name || ' Couldn''t find data level.');
              l_token_table(1).TOKEN_NAME  := 'DL_NAME';
              l_token_table(1).TOKEN_VALUE := p_data_level;
              l_token_table(2).TOKEN_NAME  := 'AG_NAME';
              l_token_table(2).TOKEN_VALUE := l_attr_group_metadata_obj.attr_group_name;
              ERROR_HANDLER.Add_Error_Message(
                  p_message_name      => 'EGO_EF_DL_AG_INVALID'
                 ,p_application_id    => 'EGO'
                 ,p_token_tbl         => l_token_table
                 ,p_message_type      => FND_API.G_RET_STS_ERROR
                 ,p_row_identifier    => G_USER_ROW_IDENTIFIER
                 ,p_entity_id         => NULL
                 ,p_entity_index      => NULL
                 ,p_entity_code       => NULL
                 ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
                );
              l_token_table.DELETE();
              RAISE FND_API.G_EXC_ERROR;
            END IF;

          END IF;
        END IF;  -- has_data_level

    END IF;

    IF (p_pk_col2 IS NOT NULL AND
        p_pk_col3 IS NOT NULL AND
        p_pk_col4 IS NOT NULL AND
        p_pk_col5 IS NOT NULL) THEN

      l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                        EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col1, p_pk_value1)
                                       ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col2, p_pk_value2)
                                       ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col3, p_pk_value3)
                                       ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col4, p_pk_value4)
                                       ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col5, p_pk_value5)
                                      );

    ------------------------------------------------------------------
    -- We build a name/value pair array for our Primary Keys to use --
    -- in tokenizing our query; NOTE: We assume (and require) that  --
    -- at least one Primary Key name/value pair is passed           --
    ------------------------------------------------------------------
    ELSIF (p_pk_col2 IS NOT NULL AND
           p_pk_col3 IS NOT NULL AND
           p_pk_col4 IS NOT NULL) THEN

      l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                        EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col1, p_pk_value1)
                                       ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col2, p_pk_value2)
                                       ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col3, p_pk_value3)
                                       ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col4, p_pk_value4)
                                      );

    ELSIF (p_pk_col2 IS NOT NULL AND
           p_pk_col3 IS NOT NULL) THEN

      l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                        EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col1, p_pk_value1)
                                       ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col2, p_pk_value2)
                                       ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col3, p_pk_value3)
                                      );

    ELSIF (p_pk_col2 IS NOT NULL) THEN

      l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                        EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col1, p_pk_value1)
                                       ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col2, p_pk_value2)
                                      );

    ELSE

      l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                        EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_col1, p_pk_value1)
                                      );

    END IF;

    Debug_Msg('In Find_Metadata_For_Attr, about to get attribute''s internal value', 5);

    --------------------------------------------------------------------
    -- Build a query to get the Attribute's internal (database) value --
    -- NOTE: We assume an association at the top data level           --
    --------------------------------------------------------------------
    Get_Ext_Data(
        p_attr_group_metadata_obj  =>  l_attr_group_metadata_obj
       ,p_attr_metadata_obj        =>  l_attr_metadata_obj
       ,p_pk_col1                  =>  p_pk_col1
       ,p_pk_col2                  =>  p_pk_col2
       ,p_pk_col3                  =>  p_pk_col3
       ,p_pk_col4                  =>  p_pk_col4
       ,p_pk_col5                  =>  p_pk_col5
       ,p_pk_value1                =>  p_pk_value1
       ,p_pk_value2                =>  p_pk_value2
       ,p_pk_value3                =>  p_pk_value3
       ,p_pk_value4                =>  p_pk_value4
       ,p_pk_value5                =>  p_pk_value5
       ,p_data_level               =>  p_data_level
       ,p_dl_pk_values             =>  p_dl_pk_values
       ,p_dl_metadata_obj          =>  l_curr_data_level_metadata
       ,x_str_val                  =>  l_temp_str
       ,x_num_val                  =>  l_temp_num
       ,x_date_val                 =>  l_temp_date
    );

    Debug_Msg('In Find_Metadata_For_Attr, attribute''s internal value = ' || l_temp_str || l_temp_num || l_temp_date, 5);

    IF (l_temp_str IS NOT NULL) THEN
      l_attr_int_value := l_temp_str;
/*Added for Bug#8354072 - Begins here * :  TO_CHAR function truncate the 0 before '.', adding it for UI display*/
       ELSIF (l_temp_num IS NOT NULL AND 0 < l_temp_num AND l_temp_num< 1) THEN
         l_attr_int_value := '0' || TO_CHAR(l_temp_num);
       ELSIF (l_temp_num IS NOT NULL AND -1 < l_temp_num AND l_temp_num < 0) THEN
         l_attr_int_value := '-0' || substr(TO_CHAR(l_temp_num), 2);
/*Added for Bug#8354072 - Ends here */
    ELSIF (l_temp_num IS NOT NULL) THEN
      l_attr_int_value := TO_CHAR(l_temp_num);
    ELSIF (l_temp_date IS NOT NULL) THEN
    --bug 5094087
      l_attr_int_value := TO_CHAR(l_temp_date,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
    END IF;

    ----------------------------------------------------------
    -- At this point I have the internal value; if the Attr --
    -- has a display value, I need to try to get it instead --
    ----------------------------------------------------------
    -- fix for bug 4543638 included translatable independent validation code to get disp value
    IF (l_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE OR
        l_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE OR
        l_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE) THEN

      ------------------------------------------------------------
      -- We must query up the rest of the attribute data in the --
      -- same group in case there are binds                     --
      ------------------------------------------------------------
      l_attr_name_value_pairs := EGO_USER_ATTR_DATA_TABLE();

      l_attr_counter := l_attr_metadata_table.FIRST();
      WHILE (l_attr_counter IS NOT NULL)
      LOOP

        l_temp_attr_metadata := l_attr_metadata_table(l_attr_counter);
        Get_Ext_Data(
            p_attr_group_metadata_obj  =>  l_attr_group_metadata_obj
           ,p_attr_metadata_obj        =>  l_temp_attr_metadata
           ,p_pk_col1                  =>  p_pk_col1
           ,p_pk_col2                  =>  p_pk_col2
           ,p_pk_col3                  =>  p_pk_col3
           ,p_pk_col4                  =>  p_pk_col4
           ,p_pk_col5                  =>  p_pk_col5
           ,p_pk_value1                =>  p_pk_value1
           ,p_pk_value2                =>  p_pk_value2
           ,p_pk_value3                =>  p_pk_value3
           ,p_pk_value4                =>  p_pk_value4
           ,p_pk_value5                =>  p_pk_value5
           ,p_data_level               =>  p_data_level
           ,p_dl_pk_values             =>  p_dl_pk_values
           ,p_dl_metadata_obj          =>  l_curr_data_level_metadata
           ,x_str_val                  =>  l_temp_str
           ,x_num_val                  =>  l_temp_num
           ,x_date_val                 =>  l_temp_date
        );

        l_attr_name_value_pairs.EXTEND();
        l_attr_name_value_pairs(l_attr_name_value_pairs.LAST) :=
          EGO_USER_ATTR_DATA_OBJ (
            1
           ,l_temp_attr_metadata.ATTR_NAME
           ,l_temp_str                                        -- ATTR_VALUE_STR
           ,l_temp_num                                        -- ATTR_VALUE_NUM
           ,l_temp_date                                      -- ATTR_VALUE_DATE
           ,NULL                                             -- ATTR_DISP_VALUE
           ,NULL                                        -- ATTR_UNIT_OF_MEASURE
           ,1
          );

        l_attr_counter := l_attr_metadata_table.NEXT(l_attr_counter);

      END LOOP;

      l_attr_disp_value := Get_Disp_Val_For_Int_Val(
                             p_attr_int_value                => l_attr_int_value
                            ,p_attr_metadata_obj             => l_attr_metadata_obj
                            ,p_attr_group_metadata_obj       => l_attr_group_metadata_obj
                            ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
                            ,p_object_name                   => p_object_name
                            ,p_attr_name_value_pairs         => l_attr_name_value_pairs
                           );

    END IF;

    -----------------------------------------------------
    -- If the Attr has no display value or we couldn't --
    -- find it, we simply return the internal value    --
    -----------------------------------------------------
    IF (l_attr_disp_value IS NULL) THEN
     --bug 5094087
      --------------------------------------------------------------
        -- If the Attribute is of Date or DateTime then we        --
        -- change the format to user preferences, else we return  --
        -- the obtained String as it is.                          --
        ------------------------------------------------------------
      IF ( l_attr_metadata_obj.DATA_TYPE_CODE IN
             (EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE,
              EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) )
      THEN
        l_attr_disp_value := EGO_USER_ATTRS_COMMON_PVT.Get_User_Pref_Date_Time_Val(
                                       p_date => TO_DATE(l_attr_int_value,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT)
                                      ,p_attr_type => l_attr_metadata_obj.DATA_TYPE_CODE
                                      ,x_return_status =>l_return_status
                                      ,x_msg_count     =>l_msg_count
                                      ,x_msg_data      =>l_msg_data
                                      );
      ELSE
         l_attr_disp_value := l_attr_int_value;
      END IF;
    END IF;
     --bug 5094087
     ------------------------------------------------------------
     -- If the Display value is NOT NULL and Attribute is of Date
     -- or DateTime and is coming from a Independent Type
     -- of Valueset then we change the format to user preferences,
     -- else we return the obtained String as it is.
     ------------------------------------------------------------
       IF ((l_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE )
           AND (l_attr_metadata_obj.DATA_TYPE_CODE IN
                 (EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE,
                  EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE)))
       THEN
        l_attr_disp_value := EGO_USER_ATTRS_COMMON_PVT.Get_User_Pref_Date_Time_Val(
                                     p_date => TO_DATE(l_attr_disp_value,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT)
                                    ,p_attr_type => l_attr_metadata_obj.DATA_TYPE_CODE
                                    ,x_return_status =>l_return_status
                                    ,x_msg_count     =>l_msg_count
                                    ,x_msg_data      =>l_msg_data
                                    );
      END IF;
    RETURN l_attr_disp_value;
  ---------------------------------------------------------------------------------
  -- In case of any error, we try to return l_attr_int_value (which may be NULL) --
  ---------------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      Debug_Msg(' Get_User_Attr_Val EXCEPTION OTHERS '||SQLERRM);
      RETURN l_attr_int_value;

END Get_User_Attr_Val;

----------------------------------------------------------------------

PROCEDURE Set_Up_Debug_Session (
        p_entity_id                     IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_debug_level                   IN   NUMBER DEFAULT 0
) IS

  --local variables
   --bug 12868802 UTL_FILE_DIR length defined in ORA.init can be longer than 512 in 10g or later,
     --so it may cause ORA-06502, replace with v$parameter.value%TYPE; which work in all cases.


    l_output_dir             v$parameter.value%TYPE;
    l_return_status          VARCHAR2(1);
    l_error_mesg             VARCHAR2(512);

  BEGIN

    IF (ERROR_HANDLER.Get_Debug() = 'N') THEN

      IF (p_debug_level > 0) THEN

        SELECT VALUE
          INTO l_output_dir
          FROM V$PARAMETER
         WHERE NAME = 'utl_file_dir';

        ---------------------------------------
        -- This global holds the debug level --
        ---------------------------------------
        G_DEBUG_OUTPUT_LEVEL := p_debug_level;

        ------------------------------------------------------
        -- Trim to get only the first directory in the list --
        ------------------------------------------------------
        IF (INSTR(l_output_dir, ',') > 0) THEN
          l_output_dir := SUBSTR(l_output_dir, 1, INSTR(l_output_dir, ',') - 1);
        END IF;

        ERROR_HANDLER.Open_Debug_Session(
          p_debug_filename   => 'EGO_USER_ATTRS_DATA_PVT-'||TO_CHAR(SYSDATE, 'J.SSSSS')||'.log'
         ,p_output_dir       => l_output_dir
         ,x_return_status    => l_return_status
         ,x_error_mesg       => l_error_mesg
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

          ERROR_HANDLER.Add_Error_Message(
            p_message_text      => l_error_mesg
           ,p_message_type      => 'E'
           ,p_entity_code       => p_entity_code
           ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
          );

        END IF;
      END IF;
    END IF;

END Set_Up_Debug_Session;

----------------------------------------------------------------------

PROCEDURE Update_Attributes (
          p_pk_column_name_value_pairs    IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_class_code_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_data_level                    IN VARCHAR2  DEFAULT NULL
        , p_data_level_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_attr_diffs                    IN EGO_USER_ATTR_DIFF_TABLE
        , p_transaction_type              IN VARCHAR2
        , p_attr_group_id                 IN NUMBER DEFAULT NULL
        , x_error_message                 OUT NOCOPY VARCHAR2
        )
  IS

    l_object_id                 NUMBER;
    l_attr_group_metadata_obj   EGO_ATTR_GROUP_METADATA_OBJ;
    l_ext_table_metadata_obj    EGO_EXT_TABLE_METADATA_OBJ;
    l_extension_id              NUMBER;
    l_old_attr_name_value_pairs EGO_USER_ATTR_DATA_TABLE;
    l_new_attr_name_value_pairs EGO_USER_ATTR_DATA_TABLE;
    l_mode                      VARCHAR2(10);
    l_return_status             VARCHAR2(1);
    l_row_identifier            NUMBER;
    l_max_row_identifier        NUMBER;
    l_perform_dml               BOOLEAN := TRUE;
    l_is_delete                 BOOLEAN;


  BEGIN

    -- get object id
    Debug_Msg('In Update_Attributes, called with transaction type '||p_transaction_type);

    l_object_id := Get_Object_Id_From_Name('EGO_ITEM');

    Debug_Msg('In Update_Attributes, retrieved l_object_id as '||l_object_id, 2);
    Debug_Msg('In Update_Attributes, getting AG metadata for '||p_attr_group_id, 2);

    l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata
                                   ( p_attr_group_id => p_attr_group_id );

    Debug_Msg('In Update_Attributes, got AG metadata: '||
      l_attr_group_metadata_obj.attr_group_id||','||
      l_attr_group_metadata_obj.application_id||','||
      l_attr_group_metadata_obj.attr_group_type||','||
      l_attr_group_metadata_obj.attr_group_name||','||
      l_attr_group_metadata_obj.attr_group_disp_name
      , 2);

    l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(l_object_id);
    Convert_Attr_Diff_To_Data(p_attr_diffs, l_old_attr_name_value_pairs, FALSE, l_is_delete, x_error_message);
    Convert_Attr_Diff_To_Data(p_attr_diffs, l_new_attr_name_value_pairs, TRUE, l_is_delete, x_error_message);

    Debug_Msg('In Update_Attributes, got AG and ext table objs, getting ext id ');

    if l_old_attr_name_value_pairs is not null then
      for i in l_old_attr_name_value_pairs.FIRST .. l_old_attr_name_value_pairs.LAST loop
        Debug_Msg('In Update_Attributes, old('||i||') '
          ||l_old_attr_name_value_pairs(i).ROW_IDENTIFIER||','
          ||l_old_attr_name_value_pairs(i).ATTR_NAME||','
          ||l_old_attr_name_value_pairs(i).ATTR_VALUE_STR||','
          ||l_old_attr_name_value_pairs(i).ATTR_VALUE_NUM);
      end loop;
    end if;
    if l_new_attr_name_value_pairs is not null then
      for i in l_new_attr_name_value_pairs.FIRST .. l_new_attr_name_value_pairs.LAST loop
        Debug_Msg('In Update_Attributes, new('||i||') '
          ||l_new_attr_name_value_pairs(i).ROW_IDENTIFIER||','
          ||l_new_attr_name_value_pairs(i).ATTR_NAME||','
          ||l_new_attr_name_value_pairs(i).ATTR_VALUE_STR||','
          ||l_new_attr_name_value_pairs(i).ATTR_VALUE_NUM);
      end loop;
    end if;

    -- try to find an extension id, which tells us whether to CREATE/UPDATE/DELETE
    l_extension_id := Get_Extension_Id_For_Row
                          ( p_attr_group_metadata_obj     => l_attr_group_metadata_obj
                          , p_ext_table_metadata_obj      => l_ext_table_metadata_obj
                          , p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
                          , p_data_level                  => p_data_level
                          , p_data_level_name_value_pairs => p_data_level_name_value_pairs
                          , p_attr_name_value_pairs       => l_old_attr_name_value_pairs
                          );

    IF (l_extension_id IS NULL) THEN

      -- fallback on new values (to handle case where update_attrs is called
      -- redundantly on the each, which has already been updated)

      l_extension_id := Get_Extension_Id_For_Row
                          ( p_attr_group_metadata_obj     => l_attr_group_metadata_obj
                          , p_ext_table_metadata_obj      => l_ext_table_metadata_obj
                          , p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
                          , p_data_level                  => p_data_level
                          , p_data_level_name_value_pairs => p_data_level_name_value_pairs
                          , p_attr_name_value_pairs       => l_new_attr_name_value_pairs
                          );

    END IF;

    Debug_Msg('In Update_Attributes, using ext id '||l_extension_id);

    IF p_transaction_type = 'SYNC' THEN
      -- are we updating or deleting this row?
      --  uses data contained in diff object to find out
      IF (l_is_delete) THEN
        l_mode := G_DELETE_MODE;
      ELSE
        IF (l_extension_id IS NOT NULL) THEN
          l_mode := G_UPDATE_MODE;
        ELSE
          l_mode := G_CREATE_MODE;
        END IF;
      END IF;
    ELSE -- transaction type is DELETE
      l_mode := p_transaction_type;
      IF (l_extension_id IS NULL) THEN
        l_perform_dml := FALSE;
      END IF;
    END IF;   -- p_transaction_type = 'SYNC'

    IF l_perform_dml THEN

      Debug_Msg('In Update_Attributes, calling perform_dml_on_row_pvt with mode '||l_mode, 2);

      Perform_DML_On_Row_Pvt(
        p_api_version                   => 1.0
       ,p_object_id                     => l_object_id
       ,p_attr_group_metadata_obj       => l_attr_group_metadata_obj
       ,p_ext_table_metadata_obj        => l_ext_table_metadata_obj
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level                    => p_data_level
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_extension_id                  => l_extension_id
       ,p_attr_name_value_pairs         => l_new_attr_name_value_pairs
       ,p_mode                          => l_mode
       ,p_commit                        => FND_API.G_FALSE
       ,p_bulkload_flag                 => TRUE
       ,x_extension_id                  => l_extension_id
       ,x_return_status                 => l_return_status
      );
      Debug_Msg('In Update_Attributes, Perform_DML_On_Row_Pvt returned with status '||l_return_status, 2);
    ELSE
      Debug_Msg('In Update_Attributes, skipped perform_dml');
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      Debug_Msg('In Update_Attributes, ERROR ret status: '||l_return_status, 2);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      Debug_Msg('In Update_Attributes, EXCEPTION FND_API.G_EXC_ERROR');
      x_error_message := FND_API.G_RET_STS_ERROR;

END Update_Attributes;

----------------------------------------------------------------------

-- Either pass in attr_group_id or attr_group_name
PROCEDURE Get_Attr_Diffs (
          p_object_name                   IN VARCHAR2
        , p_pk_column_name_value_pairs    IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_class_code_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
        , p_data_level_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_attr_group_id                 IN NUMBER DEFAULT NULL
        , p_application_id                IN NUMBER DEFAULT NULL
        , p_attr_group_type               IN VARCHAR2 DEFAULT NULL
        , p_attr_group_name               IN VARCHAR2 DEFAULT NULL
        , px_attr_diffs                   IN OUT NOCOPY EGO_USER_ATTR_DIFF_TABLE
        , x_error_message                 OUT NOCOPY VARCHAR2
        )
  IS
    l_attr_name_value_pairs               EGO_USER_ATTR_DATA_TABLE;
    l_attr_name_value_rec                 EGO_USER_ATTR_DATA_OBJ;
    l_attr_metadata_obj                   EGO_ATTR_METADATA_OBJ;
    l_ext_table_metadata_obj              EGO_EXT_TABLE_METADATA_OBJ;
    l_attr_group_metadata_obj             EGO_ATTR_GROUP_METADATA_OBJ;
    l_object_id                           NUMBER;
    l_attr_diffs                          EGO_USER_ATTR_DIFF_TABLE;

  BEGIN

    Debug_Msg('In Get_Attr_Diffs, starting');

    -- get list of attributes in this group
    l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata
                                   ( p_attr_group_id
                                   , p_application_id
                                   , p_attr_group_type
                                   , p_attr_group_name
                                   );

    FOR i IN  l_attr_group_metadata_obj.attr_metadata_table.FIRST .. l_attr_group_metadata_obj.attr_metadata_table.LAST
    LOOP

      l_attr_metadata_obj := l_attr_group_metadata_obj.attr_metadata_table(i);

      IF (l_attr_name_value_pairs IS NULL) THEN
        l_attr_name_value_pairs := EGO_USER_ATTR_DATA_TABLE();
      END IF;

      -- add all attributes to the name_value pairs table, to pass into Get_Change_Attrs
      l_attr_name_value_pairs.EXTEND();
      l_attr_name_value_pairs(l_attr_name_value_pairs.LAST) :=
        EGO_USER_ATTR_DATA_OBJ(1
                              ,l_attr_metadata_obj.ATTR_NAME
                              ,null
                              ,null
                              ,null
                              ,null
                              ,null
                              ,1
                              );

    END LOOP;

    -- get other objects necessary for Get_Change_Attrs call
    l_object_id := Get_Object_Id_From_Name(p_object_name);
    l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(l_object_id);

    -- call Get_Changed_Attrs to get diffs as output
    Get_Changed_Attributes(
           p_dml_operation                 => 'UPDATE'
         , p_object_name                   =>  p_object_name
         , p_pk_column_name_value_pairs    =>  p_pk_column_name_value_pairs
         , p_attr_group_metadata_obj       =>  l_attr_group_metadata_obj
         , p_ext_table_metadata_obj        =>  l_ext_table_metadata_obj
         , p_data_level                    =>  p_data_level
         , p_data_level_name_value_pairs   =>  p_data_level_name_value_pairs
         , p_attr_name_value_pairs         =>  l_attr_name_value_pairs
         , p_extension_id                  =>  null
         , p_entity_id                     =>  null
         , p_entity_index                  =>  null
         , p_entity_code                   =>  null
         , px_attr_diffs                   =>  l_attr_diffs);

    -- Bug 4029064: need to remove diff object if both new and old values are null
    FOR i IN l_attr_diffs.FIRST .. l_attr_diffs.LAST
    LOOP

      IF (l_attr_diffs(i).old_attr_value_str IS NOT NULL OR
          l_attr_diffs(i).new_attr_value_str IS NOT NULL OR
          l_attr_diffs(i).old_attr_value_num IS NOT NULL OR
          l_attr_diffs(i).new_attr_value_num IS NOT NULL OR
          l_attr_diffs(i).old_attr_value_date IS NOT NULL OR
          l_attr_diffs(i).new_attr_value_date IS NOT NULL OR
          l_attr_diffs(i).old_attr_uom IS NOT NULL OR
          l_attr_diffs(i).new_attr_uom IS NOT NULL) THEN

        IF px_attr_diffs IS NULL THEN
          px_attr_diffs := EGO_USER_ATTR_DIFF_TABLE();
        END IF;

        px_attr_diffs.EXTEND();
        px_attr_diffs(px_attr_diffs.LAST) := l_attr_diffs(i);

      END IF;

    END LOOP;

    Debug_Msg('In Get_Attr_Diffs, finished');

  EXCEPTION
    WHEN OTHERS THEN
      Debug_Msg('In Get_Attr_Diffs, EXCEPTION FND_API.G_EXC_ERROR');
      RAISE FND_API.G_EXC_ERROR;

END Get_Attr_Diffs;

---------------------------------------------------------------------------------
/*
 * Get_Attr_Disp_Val_From_ValueSet
 * -------------------------------
 * Function returns the display value
 * of the attribute for a given internal value.
 */
 --gnanda api created for bug  4038065
FUNCTION Get_Attr_Disp_Val_From_VSet (
         p_application_id               IN   NUMBER
        ,p_attr_internal_date_value     IN   DATE     DEFAULT NULL
        ,p_attr_internal_str_value      IN   VARCHAR2 DEFAULT NULL
        ,p_attr_internal_num_value      IN   NUMBER   DEFAULT NULL
        ,p_attr_internal_name           IN   VARCHAR2
        ,p_attr_group_type              IN   VARCHAR2
        ,p_attr_group_int_name          IN   VARCHAR2
        ,p_attr_id                      IN   NUMBER
        ,p_object_name                  IN   VARCHAR2
        ,p_pk1_column_name              IN   VARCHAR2
        ,p_pk1_value                    IN   VARCHAR2
        ,p_pk2_column_name              IN   VARCHAR2 DEFAULT NULL
        ,p_pk2_value                    IN   VARCHAR2 DEFAULT NULL
        ,p_pk3_column_name              IN   VARCHAR2 DEFAULT NULL
        ,p_pk3_value                    IN   VARCHAR2 DEFAULT NULL
        ,p_pk4_column_name              IN   VARCHAR2 DEFAULT NULL
        ,p_pk4_value                    IN   VARCHAR2 DEFAULT NULL
        ,p_pk5_column_name              IN   VARCHAR2 DEFAULT NULL
        ,p_pk5_value                    IN   VARCHAR2 DEFAULT NULL
        ,p_data_level1_column_name      IN   VARCHAR2 DEFAULT NULL
        ,p_data_level1_value            IN   VARCHAR2 DEFAULT NULL
        ,p_data_level2_column_name      IN   VARCHAR2 DEFAULT NULL
        ,p_data_level2_value            IN   VARCHAR2 DEFAULT NULL
        ,p_data_level3_column_name      IN   VARCHAR2 DEFAULT NULL
        ,p_data_level3_value            IN   VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2
IS
       l_attr_value_obj                EGO_USER_ATTR_DATA_OBJ;
       l_attr_metadata_obj             EGO_ATTR_METADATA_OBJ;
       l_attr_metadata_obj_table       EGO_ATTR_METADATA_TABLE;
       l_attr_group_metadata_obj       EGO_ATTR_GROUP_METADATA_OBJ;
       l_pk_column_name_value_pairs    EGO_COL_NAME_VALUE_PAIR_ARRAY;
       l_data_level_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
       l_attr_disp_value               VARCHAR2(5000);
  BEGIN
       l_attr_value_obj :=  EGO_USER_ATTR_DATA_OBJ (null
                                                   ,p_attr_internal_name
                                                   ,p_attr_internal_str_value
                                                   ,p_attr_internal_num_value
                                                   ,p_attr_internal_date_value
                                                   ,null
                                                   ,null
                                                   ,null
                                                   );

       l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                                    p_attr_group_id   => NULL
                                                   ,p_application_id  => p_application_id
                                                   ,p_attr_group_type => p_attr_group_type
                                                   ,p_attr_group_name => p_attr_group_int_name
                                                   );

--todo:  why is this  here?
       IF FND_API.TO_BOOLEAN(EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(l_attr_group_metadata_obj.EXT_TABLE_B_NAME, 'DATA_LEVEL_ID')) THEN
         -- data level exists
NULL;
       END IF;

       l_attr_metadata_obj_table := l_attr_group_metadata_obj.ATTR_METADATA_TABLE;
       IF l_attr_metadata_obj_table.count > 0 THEN
        FOR i IN l_attr_metadata_obj_table.FIRST .. l_attr_metadata_obj_table.LAST LOOP
         IF l_attr_metadata_obj_table(i).attr_name = p_attr_internal_name THEN
           l_attr_metadata_obj := l_attr_metadata_obj_table(i);
         END IF;
        END LOOP;
       END IF;

       l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                                    EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk1_column_name,p_pk1_value)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk2_column_name,p_pk2_value)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk3_column_name,p_pk3_value)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk4_column_name,p_pk4_value)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk5_column_name,p_pk5_value)
                                                   );
       l_data_level_name_value_pairs :=  EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                                    EGO_COL_NAME_VALUE_PAIR_OBJ(p_data_level1_column_name,p_data_level1_value)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_data_level2_column_name,p_data_level2_value)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_data_level3_column_name,p_data_level3_value)
                                                   );
       l_attr_disp_value := Get_Disp_Val_For_Int_Val(
                                                   p_attr_value_obj                => l_attr_value_obj
                                                  ,p_attr_metadata_obj             => l_attr_metadata_obj
                                                  ,p_attr_group_metadata_obj       => l_attr_group_metadata_obj
                                                  ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
                                                  ,p_data_level_name_value_pairs   => l_data_level_name_value_pairs
                                                  ,p_object_name                   => p_object_name
                                                  );

       RETURN l_attr_disp_value;

  EXCEPTION
    WHEN OTHERS THEN
      Debug_Msg('In Get_Attr_Disp_Val_From_ValueSet, got exception '||SQLERRM, 3);
      RETURN NULL;

END Get_Attr_Disp_Val_From_VSet;




/*
 * Get_Attr_Int_Val_From_VSet
 * -------------------------------
 * Function returns the internal value for a given display
 * value of the value set. In case the attribute does not have
 * a value set attached the display value privded to the api is
 * returned back.
 */

---------------------------------------------------------------------------
FUNCTION Get_Attr_Int_Val_From_VSet (
         p_application_id               IN   NUMBER
        ,p_attr_disp_value              IN   VARCHAR2
        ,p_attr_internal_name           IN   VARCHAR2
        ,p_attr_group_type              IN   VARCHAR2
        ,p_attr_group_int_name          IN   VARCHAR2
        ,p_attr_group_id                IN   NUMBER
        ,p_attr_id                      IN   NUMBER
        ,p_return_intf_col              IN   VARCHAR2
        ,p_object_name                  IN   VARCHAR2
        ,p_ext_table_metadata_obj       IN   EGO_EXT_TABLE_METADATA_OBJ
        ,p_pk1_column_name              IN   VARCHAR2
        ,p_pk1_value                    IN   VARCHAR2
        ,p_pk2_column_name              IN   VARCHAR2
        ,p_pk2_value                    IN   VARCHAR2
        ,p_pk3_column_name              IN   VARCHAR2
        ,p_pk3_value                    IN   VARCHAR2
        ,p_pk4_column_name              IN   VARCHAR2
        ,p_pk4_value                    IN   VARCHAR2
        ,p_pk5_column_name              IN   VARCHAR2
        ,p_pk5_value                    IN   VARCHAR2
        ,p_data_level1_column_name      IN   VARCHAR2
        ,p_data_level1_value            IN   VARCHAR2
        ,p_data_level2_column_name      IN   VARCHAR2
        ,p_data_level2_value            IN   VARCHAR2
        ,p_data_level3_column_name      IN   VARCHAR2
        ,p_data_level3_value            IN   VARCHAR2
        ,p_entity_id                    IN   VARCHAR2
        ,p_entity_index                 IN   NUMBER
        ,p_entity_code                  IN   VARCHAR2
)
RETURN VARCHAR2
IS
       l_attr_value_obj                EGO_USER_ATTR_DATA_OBJ;
       l_attr_metadata_obj             EGO_ATTR_METADATA_OBJ;
       l_attr_metadata_obj_table       EGO_ATTR_METADATA_TABLE;
       l_attr_group_metadata_obj       EGO_ATTR_GROUP_METADATA_OBJ;
       l_pk_column_name_value_pairs    EGO_COL_NAME_VALUE_PAIR_ARRAY;
       l_data_level_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
       l_attr_internal_value           VARCHAR2(4000);
       l_ext_table_metadata_obj        EGO_EXT_TABLE_METADATA_OBJ;
  BEGIN
       l_attr_value_obj :=  EGO_USER_ATTR_DATA_OBJ (null
                                                   ,p_attr_internal_name
                                                   ,null
                                                   ,null
                                                   ,null
                                                   ,p_attr_disp_value
                                                   ,null
                                                   ,null
                                                   );
       l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                                    p_attr_group_id   => NULL
                                                   ,p_application_id  => p_application_id
                                                   ,p_attr_group_type => p_attr_group_type
                                                   ,p_attr_group_name => p_attr_group_int_name
                                                   );

       IF l_attr_group_metadata_obj IS NULL THEN
         RETURN NULL;
       END IF;

       l_attr_metadata_obj_table := l_attr_group_metadata_obj.ATTR_METADATA_TABLE;
       IF l_attr_metadata_obj_table.count > 0 THEN
        FOR i IN l_attr_metadata_obj_table.FIRST .. l_attr_metadata_obj_table.LAST LOOP
         IF l_attr_metadata_obj_table(i).attr_name = p_attr_internal_name THEN
           l_attr_metadata_obj := l_attr_metadata_obj_table(i);
         END IF;
        END LOOP;
       END IF;

      -- If the value
       BEGIN
          IF l_attr_metadata_obj IS NULL THEN
            RETURN NULL;
          ELSE
            IF l_attr_metadata_obj.VALUE_SET_ID IS NULL THEN
               -- if the data is coming from intf table we have a possibility that its not
               -- valid in terms of datatype. We return a null in such a case.
               IF p_return_intf_col IS NOT NULL THEN
                  IF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE)
                     AND (p_return_intf_col = 'ATTR_VALUE_NUM') THEN
                    RETURN TO_CHAR(TO_NUMBER(p_attr_disp_value));
                  ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE
                         OR l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE)
                        AND (p_return_intf_col = 'ATTR_VALUE_DATE') THEN
                    RETURN TO_CHAR(TO_DATE(p_attr_disp_value,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT),EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
                  ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE
                         OR l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE)
                     AND (p_return_intf_col = 'ATTR_VALUE_STR') THEN
                    RETURN p_attr_disp_value;
                  ELSE
                    RETURN NULL;
                  END IF;
               ELSE
                 RETURN p_attr_disp_value;
               END IF;
            END IF;
          END IF;
       EXCEPTION
         WHEN OTHERS THEN
          RETURN NULL;
       END;


       -- This api can be used as a part of the VO query to fetch the internal values for
       -- an attribute in the interface table. In this case we will return a value only for
       -- the appropriate column.
       IF p_return_intf_col IS NOT NULL THEN

         IF p_return_intf_col = 'ATTR_VALUE_STR' THEN
            IF (l_attr_metadata_obj.DATA_TYPE_CODE <> EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE
                AND l_attr_metadata_obj.DATA_TYPE_CODE <> EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE)  THEN
                 RETURN NULL;
            END IF;

         ELSIF p_return_intf_col = 'ATTR_VALUE_NUM' THEN
            IF l_attr_metadata_obj.DATA_TYPE_CODE <> EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE THEN
                 RETURN NULL;
            END IF;

         ELSIF p_return_intf_col = 'ATTR_VALUE_DATE' THEN
            IF (l_attr_metadata_obj.DATA_TYPE_CODE <> EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE
                AND l_attr_metadata_obj.DATA_TYPE_CODE <> EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE)  THEN
                 RETURN NULL;
            END IF;

         END IF;

       END IF;

       l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                    EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk1_column_name,p_pk1_value)
                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk2_column_name,p_pk2_value)
                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk3_column_name,p_pk3_value)
                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk4_column_name,p_pk4_value)
                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk5_column_name,p_pk5_value)
                   );

       l_data_level_name_value_pairs :=  EGO_COL_NAME_VALUE_PAIR_ARRAY(
                    EGO_COL_NAME_VALUE_PAIR_OBJ(p_data_level1_column_name,p_data_level1_value)
                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_data_level2_column_name,p_data_level2_value)
                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(p_data_level3_column_name,p_data_level3_value)
                   );


      IF (p_ext_table_metadata_obj IS NOT NULL) THEN
        l_ext_table_metadata_obj := p_ext_table_metadata_obj;
      ELSE
        l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(Get_Object_Id_From_Name(p_object_name));
      END IF;


      l_attr_internal_value := Get_Int_Val_For_Disp_Val(
                    p_attr_metadata_obj           =>l_attr_metadata_obj
                   ,p_attr_value_obj              =>l_attr_value_obj
                   ,p_attr_group_metadata_obj     =>l_attr_group_metadata_obj
                   ,p_ext_table_metadata_obj      =>l_ext_table_metadata_obj
                   ,p_pk_column_name_value_pairs  =>l_pk_column_name_value_pairs
                   ,p_data_level_name_value_pairs =>l_data_level_name_value_pairs
                   ,p_entity_id                   =>p_entity_id
                   ,p_entity_index                =>p_entity_index
                   ,p_entity_code                 =>p_entity_code
                   ,p_attr_name_value_pairs       =>null
                   );


      BEGIN
        IF p_return_intf_col IS NOT NULL THEN
           IF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE)
               AND (p_return_intf_col = 'ATTR_VALUE_NUM') THEN
                  l_attr_internal_value := TO_CHAR(TO_NUMBER(l_attr_internal_value));
           ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE
                  OR l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE)
                  AND (p_return_intf_col = 'ATTR_VALUE_DATE') THEN
                     l_attr_internal_value := TO_CHAR(TO_DATE(l_attr_internal_value,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT),EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
           ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE
                  OR l_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE)
                  AND (p_return_intf_col = 'ATTR_VALUE_STR') THEN
                    l_attr_internal_value := l_attr_internal_value;
           END IF;
        END IF;
      EXCEPTION
         WHEN OTHERS THEN
          l_attr_internal_value := NULL;
      END;


      RETURN l_attr_internal_value;

END Get_Attr_Int_Val_From_VSet;

---------------------------------------------------------------------------

PROCEDURE Process_Data_Level_Nvp(
        p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,x_data_level_obj                OUT NOCOPY  EGO_COL_NAME_VALUE_PAIR_OBJ
       ,x_data_level_index              OUT NOCOPY  NUMBER
) IS
    l_api_name VARCHAR2(30) := 'Process_data_level_nvp';
  BEGIN

Debug_Msg(l_api_name||' starting', 2);

    IF p_data_level_name_value_pairs IS NULL THEN
Debug_Msg(l_api_name||' p_data_level_name_value_pairs IS NULL. Returning.', 2);
      RETURN;
    END IF;


    IF p_data_level_name_value_pairs.COUNT > 0 THEN
      FOR i IN p_data_level_name_value_pairs.FIRST .. p_data_level_name_value_pairs.LAST
      LOOP

Debug_Msg(l_api_name||' pair ' || i, 2);

        IF (i = p_data_level_name_value_pairs.FIRST AND
            p_data_level_name_value_pairs(i).NAME IS NOT NULL)
           OR
           (p_data_level_name_value_pairs(i).VALUE IS NOT NULL AND
            p_data_level_name_value_pairs(i).NAME IS NOT NULL)
        THEN

           x_data_level_obj   := p_data_level_name_value_pairs(i);
           x_data_level_index := i;

        END IF;
      END LOOP;
    ELSE
Debug_Msg(l_api_name||' p_data_level_name_value_pairs.COUNT = ' || p_data_level_name_value_pairs.COUNT, 2);
    END IF;                       -- IF p_data_level_name_value_pairs.COUNT > 0


    IF x_data_level_obj IS NULL THEN
Debug_Msg(l_api_name||' x_data_level_obj IS NULL', 2);
    ELSE
Debug_Msg(l_api_name||' chosen data level pair = (' || x_data_level_obj.NAME || ', ' || x_data_level_obj.VALUE || ')', 2);
    END IF;
Debug_Msg(l_api_name||' done', 2);

END Process_Data_Level_Nvp;

---------------------------------------------------------------------------

PROCEDURE Process_Class_Code_Nvp(
        p_class_code_name_value_pairs   IN         EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,x_base_class_obj                OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_OBJ
       ,x_related_class_obj             OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_OBJ
) IS
    l_api_name  VARCHAR2(30) := 'Process_Class_Code_Nvp';
  BEGIN

    Debug_Msg(l_api_name||' starting', 2);

    IF p_class_code_name_value_pairs IS NULL THEN
      RETURN;
    END IF;

    FOR i IN p_class_code_name_value_pairs.FIRST .. p_class_code_name_value_pairs.LAST
    LOOP

      IF i = p_class_code_name_value_pairs.FIRST AND
         p_class_code_name_value_pairs(i).VALUE IS NOT NULL AND
         p_class_code_name_value_pairs(i).NAME IS NOT NULL
      THEN

         x_base_class_obj := p_class_code_name_value_pairs(i);

      ELSIF i = p_class_code_name_value_pairs.FIRST + 1 AND
            p_class_code_name_value_pairs(i).VALUE IS NOT NULL AND
            p_class_code_name_value_pairs(i).NAME IS NOT NULL

      THEN

         x_related_class_obj := p_class_code_name_value_pairs(i);
         exit;

      END IF;
    END LOOP;

    Debug_Msg(l_api_name||' base class code pair = (' ||
              x_base_class_obj.NAME || ', ' || x_base_class_obj.VALUE || ')', 3);

    Debug_Msg(l_api_name||' related class code pair = (' ||
              x_related_class_obj.NAME || ', ' || x_related_class_obj.VALUE || ')', 3);

    Debug_Msg(l_api_name||' done', 2);

END Process_Class_Code_Nvp;

---------------------------------------------------------------------------

PROCEDURE Build_Class_Code_Table(
        p_class_code_name_value_pairs   IN         EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,x_class_code_table              OUT NOCOPY LOCAL_MEDIUM_VARCHAR_TABLE
) IS
    l_base_class_obj    EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_related_class_obj EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_remaining         VARCHAR2(300);
    l_current_val       VARCHAR2(300); --EGO_COL_NAME_VALUE_PAIR_OBJ.VALUE%TYPE;
    l_index             NUMBER;
  BEGIN

    Debug_Msg('In Build_Class_Code_Table, starting', 2);

    Process_Class_Code_Nvp(
        p_class_code_name_value_pairs  => p_class_code_name_value_pairs
       ,x_base_class_obj               => l_base_class_obj
       ,x_related_class_obj            => l_related_class_obj
    );

    IF l_base_class_obj IS NULL THEN
      RETURN;
    END IF;

    x_class_code_table(1) := l_base_class_obj.VALUE;

    IF l_related_class_obj IS NULL OR
       l_related_class_obj.VALUE IS NULL OR
       LENGTH(l_related_class_obj.VALUE) = 0
    THEN
      RETURN;
    END IF;

    l_remaining := l_related_class_obj.VALUE;
    l_index     := INSTR(l_remaining, ',');

    WHILE (l_index >  0) LOOP
       l_current_val := SUBSTR(l_remaining, 1, l_index - 1);
       l_remaining   := SUBSTR(l_remaining, l_index + 1, LENGTH(l_remaining));

       x_class_code_table(x_class_code_table.COUNT+1) := LTRIM(RTRIM(l_current_val));

       l_index := INSTR(l_remaining, ',');
    END LOOP;

    -- take care of the last value
    x_class_code_table(x_class_code_table.COUNT+1) := LTRIM(RTRIM(l_remaining));

    Debug_Msg('In Build_Class_Code_Table, done', 2);

END Build_Class_Code_Table;

/*----------------------------------------------------------------------------

  DESCRIPTION
    Extracts the values from the (column name, value) pairs in the
    data level pairs array and sets them as out parameters

  AUTHOR
    ssarnoba

  RELEASE
    R12C

  NOTES
    (-) If duplicate column names are specified, the last one's value is
        set to the out parameter

----------------------------------------------------------------------------*/
PROCEDURE Extract_Data_Level_Values(
   p_data_level_name               IN   EGO_DATA_LEVEL_VL.DATA_LEVEL_NAME%TYPE
  ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,x_data_level_1                  OUT  NOCOPY VARCHAR2
  ,x_data_level_2                  OUT  NOCOPY VARCHAR2
  ,x_data_level_3                  OUT  NOCOPY VARCHAR2
)
IS
   l_api_name              CONSTANT VARCHAR2(30) := 'Extract_Data_Level_Values';
   p_dl1_column                     VARCHAR2(20);
   p_dl2_column                     VARCHAR2(20);
   p_dl3_column                     VARCHAR2(20);
   iter_col_name                    VARCHAR2(150);
   iter_value                       VARCHAR2(150);

   CURSOR get_data_levek_col_names (cp_data_level_name EGO_DATA_LEVEL_B.DATA_LEVEL_NAME%TYPE)
   IS
   SELECT pk1_column_name, pk2_column_name, pk3_column_name
   FROM   ego_data_level_vl
   WHERE  data_level_name = cp_data_level_name;

BEGIN

  Debug_Msg(l_api_name || '  Begin', 2);
  Debug_Msg(l_api_name || '  p_data_level_name - ' || p_data_level_name, 2);

  ----------------------------------------------------------------------------
  -- Determine which array element value will populate which OUT            --
  -- parameter                                                              --
  ----------------------------------------------------------------------------

  -- e.g.
  --
  --   (-) x_data_level_1 gets populated with the value from
  --       (PK2_VALUE, value)
  --   (-) x_data_level_2 gets populated with the value from
  --       (PK1_VALUE, value)00

  -- We can't use SELECT INTO because the WHERE clause contains a parameter,
  -- not a literal. The SQL engine cannot determine that only one row
  -- will be returned. So instead we have to use a cursor.

  OPEN get_data_levek_col_names (p_data_level_name);
  FETCH get_data_levek_col_names INTO p_dl1_column, p_dl2_column, p_dl3_column;

  Debug_Msg(l_api_name || '  PK Columns determined', 2);
  Debug_Msg(l_api_name || '    p_dl1_column: ' || p_dl1_column, 2);
  Debug_Msg(l_api_name || '    p_dl2_column: ' || p_dl2_column, 2);
  Debug_Msg(l_api_name || '    p_dl3_column: ' || p_dl3_column, 2);

  Debug_Msg(l_api_name || '  Number of data level pairs: ' || p_data_level_name_value_pairs.COUNT, 2);

  ----------------------------------------------------------------------------
  -- Iterate over the list and extract each value in the pair, placing it   --
  -- in one of the OUT parameters                                           --
  ----------------------------------------------------------------------------

  IF (p_data_level_name_value_pairs.COUNT > 0) THEN

    FOR i IN p_data_level_name_value_pairs.FIRST ..
             p_data_level_name_value_pairs.LAST
    LOOP
      Debug_Msg(l_api_name || '  data level pair ' || i, 2);

      -- Get the column name and value
      iter_col_name := p_data_level_name_value_pairs(i).NAME;
      iter_value    := p_data_level_name_value_pairs(i).VALUE;

      -- Put the value in the correct OUT parameter
      IF    (iter_col_name = p_dl1_column) THEN
        x_data_level_1 := iter_value;
      ELSIF (iter_col_name = p_dl2_column) THEN
        x_data_level_2 := iter_value;
      ELSIF (iter_col_name = p_dl3_column) THEN
        x_data_level_3 := iter_value;
      END IF;

    END LOOP;

  END IF;

  Debug_Msg(l_api_name || '  End', 2);

END Extract_Data_Level_Values;


----------------------------------------------------------------------------


PROCEDURE Process_Data_Level_Values(
        p_data_level_obj  IN         EGO_COL_NAME_VALUE_PAIR_OBJ
       ,p_data_level_ind  IN         NUMBER
       ,x_data_level_1    OUT NOCOPY VARCHAR2
       ,x_data_level_2    OUT NOCOPY VARCHAR2
       ,x_data_level_3    OUT NOCOPY VARCHAR2
) IS

  BEGIN

    Debug_Msg('In Process_Data_Level_Values, starting', 2);

    -- reset values
    x_data_level_1 := null;
    x_data_level_2 := null;
    x_data_level_3 := null;

    IF p_data_level_obj.VALUE IS NULL THEN
       RETURN;
    END IF;

    -- data level is 1 below the index, since index = 1
    -- corresponds to the top data level (data level 0)
    IF p_data_level_ind = 2 THEN
      x_data_level_1 := p_data_level_obj.VALUE;
    ELSIF p_data_level_ind = 3 THEN
      x_data_level_2 := p_data_level_obj.VALUE;
    ELSIF p_data_level_ind = 4 THEN
      x_data_level_3 := p_data_level_obj.VALUE;
    END IF;

    Debug_Msg('In Process_Data_Level_Values, done', 2);

END Process_Data_Level_Values;


/*----------------------------------------------------------------------------
  DESCRIPTION
    Builds a request table to validate attribute groups of an object

  NOTES
    (-) Only the attribute groups at the specified data level are added
        to the request object.
    (-) The object type EGO_ATTR_GROUP_REQUEST_OBJ is declared in
        EGOSEFD2.sql

----------------------------------------------------------------------------*/
PROCEDURE Build_Request_Table_For_Obj(
        p_object_name                   IN   VARCHAR2
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name               IN   EGO_DATA_LEVEL_VL.DATA_LEVEL_NAME%TYPE
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
                                                   -- the data level key values
       ,p_attr_group_type_table         IN   EGO_VARCHAR_TBL_TYPE
       ,x_attr_group_request_table      OUT NOCOPY EGO_ATTR_GROUP_REQUEST_TABLE
) IS

    l_api_name              VARCHAR2(30) := 'Build_Request_Table_For_Obj';
    l_attributes_row_table  EGO_USER_ATTR_ROW_TABLE;
    l_attributes_data_table EGO_USER_ATTR_DATA_TABLE;
    l_data_level_obj        EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_data_level_index      NUMBER;
    l_class_code_table      LOCAL_MEDIUM_VARCHAR_TABLE;
    l_attr_group_id         ego_obj_ag_assocs_b.attr_group_id%TYPE;
    l_data_level_1          VARCHAR2(150);
    l_data_level_2          VARCHAR2(150);
    l_data_level_3          VARCHAR2(150);

    CURSOR relevant_ag_w_data_level(
              p_data_level ego_obj_ag_assocs_b.data_level%TYPE
             ,p_class_code ego_obj_ag_assocs_b.classification_code%TYPE
             ,p_obj_name   fnd_objects.obj_name%TYPE
             ,p_ag_type    ego_fnd_dsc_flx_ctx_ext.descriptive_flexfield_name%TYPE)
    IS
     SELECT assoc.attr_group_id
       FROM ego_obj_ag_assocs_b assoc,
            fnd_objects object,
            ego_fnd_dsc_flx_ctx_ext ag
      WHERE assoc.classification_code     = p_class_code
        AND assoc.object_id               = object.object_id
        AND object.obj_name               = p_obj_name
        AND ag.descriptive_flexfield_name = p_ag_type
        AND ag.attr_group_id              = assoc.attr_group_id
        AND assoc.data_level              = p_data_level;

    CURSOR relevant_ag_wo_data_level(
              p_class_code ego_obj_ag_assocs_b.classification_code%TYPE
             ,p_obj_name   fnd_objects.obj_name%TYPE
             ,p_ag_type    ego_fnd_dsc_flx_ctx_ext.descriptive_flexfield_name%TYPE)
    IS
     SELECT assoc.attr_group_id
       FROM ego_obj_ag_assocs_b assoc,
            fnd_objects object,
            ego_fnd_dsc_flx_ctx_ext ag
      WHERE assoc.classification_code     = p_class_code
        AND assoc.object_id               = object.object_id
        AND object.obj_name               = p_obj_name
        AND ag.descriptive_flexfield_name = p_ag_type
        AND ag.attr_group_id              = assoc.attr_group_id;

  BEGIN

    Debug_Msg(l_api_name||' starting', 2);

    Debug_msg(l_api_name||' will request attribute group at ' ||
              p_data_level_name || ' for object ' || p_object_name ||
              ' to be validated');

    ---------------------------------------------------------
    -- Put the (class code name, value) pairs into a table --
    ---------------------------------------------------------

    Build_Class_Code_Table(
        p_class_code_name_value_pairs => p_class_code_name_value_pairs
       ,x_class_code_table            => l_class_code_table
    );

    Debug_Msg(l_api_name || ' finished building class code table', 2);

    --------------------------------------------------------------------
    -- Extract the values from the (column name, value) pairs in the  --
    -- data level pairs array                                         --
    --------------------------------------------------------------------

    Extract_Data_Level_Values(
        p_data_level_name               => p_data_level_name
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,x_data_level_1                  => l_data_level_1
       ,x_data_level_2                  => l_data_level_2
       ,x_data_level_3                  => l_data_level_3
    );

    Debug_Msg(l_api_name||' extracted data level values', 2);

    --------------------------
    -- Build Request Table  --
    --------------------------

    IF x_attr_group_request_table IS NULL THEN
       x_attr_group_request_table := EGO_ATTR_GROUP_REQUEST_TABLE();
    END IF;

    IF p_attr_group_type_table.COUNT = 0 THEN
Debug_Msg(l_api_name||' Attribute Group Type Table is empty', 2);
    END IF;

    IF l_class_code_table.COUNT = 0 THEN
Debug_Msg(l_api_name||' Class Code Table is empty', 2);
    END IF;

    <<ag_types_loop>>
    FOR i IN 1 .. p_attr_group_type_table.COUNT LOOP

Debug_Msg(l_api_name||' type table (' || i || ') = ' || p_attr_group_type_table(i), 2);

       <<class_code_loop>>
       FOR j IN 1 .. l_class_code_table.COUNT LOOP

Debug_Msg(l_api_name||' class code (' || j || ') = ' || l_class_code_table(j), 2);
Debug_Msg(l_api_name||' l_data_level_obj.NAME = ' || l_data_level_obj.NAME, 2);
Debug_Msg(l_api_name||' p_object_name = ' || p_object_name, 2);


          IF p_data_level_name IS NOT NULL AND
             LENGTH(p_data_level_name) > 0
          THEN
Debug_Msg(l_api_name||' p_data_level => ' || p_data_level_name , 3);
Debug_Msg(l_api_name||' p_ag_type    => ' || p_attr_group_type_table(i), 3);
             OPEN relevant_ag_w_data_level(
                    p_data_level => p_data_level_name
                   ,p_class_code => l_class_code_table(j)
                   ,p_obj_name   => p_object_name
                   ,p_ag_type    => p_attr_group_type_table(i));

          ELSE
Debug_Msg(l_api_name||' getting attribute groups not associated to any data level', 3);
             OPEN relevant_ag_wo_data_level(
                    p_class_code => l_class_code_table(j)
                   ,p_obj_name   => p_object_name
                   ,p_ag_type    => p_attr_group_type_table(i)
                   );

          END IF;

Debug_Msg(l_api_name||' i = ' || i || ', j = ' || j, 2);

          --------------------------------------------------------------------
          -- Create a request object for eatch attribute group which        --
          -- eixsts at the specified data level                             --
          --------------------------------------------------------------------

          <<attr_groups_loop>>
          LOOP


             ---------------------------------
             -- Get the attribute group ID  --
             ---------------------------------

             IF relevant_ag_w_data_level%ISOPEN THEN
Debug_Msg(l_api_name || ' fetching next AG ' || l_attr_group_id || ' with data level...', 2);
                FETCH relevant_ag_w_data_level INTO l_attr_group_id;
                EXIT WHEN relevant_ag_w_data_level%NOTFOUND;
             ELSE
                FETCH relevant_ag_wo_data_level INTO l_attr_group_id;
Debug_Msg(l_api_name || ' fetching next AG ' || l_attr_group_id || '  without data level...', 2);
                EXIT WHEN relevant_ag_wo_data_level%NOTFOUND;
             END IF;

             Debug_Msg(l_api_name||' attribute group ID is ' || l_attr_group_id, 2);

             ------------------------------------------------------
             -- Append a request object for this attribute group --
             ------------------------------------------------------

             x_attr_group_request_table.EXTEND();
             x_attr_group_request_table(x_attr_group_request_table.LAST) :=
              EGO_ATTR_GROUP_REQUEST_OBJ(
                  l_attr_group_id                              -- ATTR_GROUP_ID
                 ,NULL                                        -- APPLICATION_ID
                 ,NULL                                       -- ATTR_GROUP_TYPE
                 ,NULL                                       -- ATTR_GROUP_NAME
                 ,p_data_level_name                               -- DATA_LEVEL
                 ,l_data_level_1                                -- DATA_LEVEL_1
                 ,l_data_level_2                                -- DATA_LEVEL_2
                 ,l_data_level_3                                -- DATA_LEVEL_3
                 ,NULL                                          -- DATA_LEVEL_4
                 ,NULL                                          -- DATA_LEVEL_5
                 ,NULL                                        -- ATTR_NAME_LIST
              );
Debug_Msg(l_api_name || ' appended validation request for AG ' || l_attr_group_id, 2);

          END LOOP attr_groups_loop;
Debug_Msg(l_api_name || ' exited attr_groups_loop', 3);

          IF relevant_ag_w_data_level%ISOPEN THEN
             CLOSE relevant_ag_w_data_level;
          ELSE
             CLOSE relevant_ag_wo_data_level;
         END IF;

       END LOOP class_code_loop;
Debug_Msg(l_api_name || ' exited class_code_loop', 3);
    END LOOP ag_types_loop;

    Debug_Msg(l_api_name||' done', 2);

END Build_Request_Table_For_Obj;

----------------------------------------------------------------------

PROCEDURE Process_Req_Attr_Results(
        p_request_table          IN EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_attributes_row_table   IN EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table  IN EGO_USER_ATTR_DATA_TABLE
       ,px_attributes_req_table  IN OUT NOCOPY EGO_USER_ATTR_TABLE
) IS
    l_has_value BOOLEAN;
    l_ix        NUMBER;
    l_api_name   VARCHAR2(30) := 'Process_Req_Attr_Results';

    CURSOR fetch_required_attr(
             p_ag_id    IN ego_attr_groups_v.attr_group_id%TYPE)
    IS
     SELECT attr.attr_name,
            attr.attr_display_name,
            ag.attr_group_id,
            ag.attr_group_name,
            ag.attr_group_disp_name,
            ag.attr_group_type,
            ag.application_id
       FROM ego_attrs_v attr ,
            ego_attr_groups_v ag
      WHERE ag.application_id = attr.application_id
        AND ag.attr_group_type = attr.attr_group_type
        AND ag.attr_group_name = attr.attr_group_name
        AND ag.attr_group_id = p_ag_id
        AND attr.required_flag = 'Y'
        AND attr.enabled_flag = 'Y';

  BEGIN

Debug_Msg(l_api_name||' starting ', 2);

    IF p_request_table IS NULL THEN
Debug_Msg(l_api_name||' returning as request table is NULL ', 2);
       RETURN;
    END IF;

Debug_Msg(l_api_name||' request table size: ' || p_request_table.COUNT, 2);

    ------------------------------
    -- For each attribute group --
    ------------------------------
    FOR i IN 1 .. p_request_table.COUNT LOOP

       -------------------------------------
       -- Get all the required attributes --
       -------------------------------------
       FOR req_attr_rec IN fetch_required_attr(p_request_table(i).ATTR_GROUP_ID) LOOP

          l_has_value := FALSE;

          ------------------------------------------------
          -- Check to see if the attribute has any data --
          ------------------------------------------------

          IF p_attributes_row_table IS NOT NULL AND
             p_attributes_data_table IS NOT NULL
          THEN

Debug_Msg(l_api_name||' p_attributes_data_table size: ' || p_attributes_data_table.COUNT, 2);

             FOR j IN 1 .. p_attributes_data_table.COUNT LOOP

              -- find the corresponding row object index
              l_ix := -1;

              FOR k IN 1 .. p_attributes_row_table.COUNT LOOP
                 IF p_attributes_row_table(k).ROW_IDENTIFIER =
                    p_attributes_data_table(j).ROW_IDENTIFIER
                 THEN
                   l_ix := k;
                   exit;
                 END IF;
              END LOOP;

              IF l_ix = -1 THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

              IF p_attributes_data_table(j).ATTR_NAME        = req_attr_rec.attr_name
                 AND
                 (p_attributes_row_table(l_ix).ATTR_GROUP_ID     = req_attr_rec.attr_group_id
                   OR
                  (p_attributes_row_table(l_ix).ATTR_GROUP_APP_ID = req_attr_rec.application_id AND
                   p_attributes_row_table(l_ix).ATTR_GROUP_TYPE   = req_attr_rec.attr_group_type AND
                   p_attributes_row_table(l_ix).ATTR_GROUP_NAME   = req_attr_rec.attr_group_name)
                 )
                 AND
                 (p_attributes_data_table(j).ATTR_VALUE_STR IS NOT NULL OR
                  p_attributes_data_table(j).ATTR_VALUE_NUM IS NOT NULL OR
                  p_attributes_data_table(j).ATTR_VALUE_DATE IS NOT NULL OR
                  p_attributes_data_table(j).ATTR_DISP_VALUE IS NOT NULL)
               THEN
                  l_has_value := TRUE;
Debug_Msg(l_api_name|| p_attributes_data_table(j).ATTR_NAME || p_attributes_data_table(j).ATTR_VALUE_STR ||
          p_attributes_data_table(j).ATTR_VALUE_NUM || p_attributes_data_table(j).ATTR_VALUE_DATE || '(' ||
          p_attributes_data_table(j).ATTR_DISP_VALUE || ')', 2);

                  exit;
               END IF; -- if value exist for attr group
             END LOOP; -- p_attributes_data_table
          END IF; -- attr row and data NOT NULL

          --------------------------------------------------------------------
          -- If the attribute doesn't have a value, create an attribute     --
          -- descriptor object and add it to the results table, which       --
          -- contains the attribute descriptors of all required attributes  --
          -- that have violated the required property.                      --
          --------------------------------------------------------------------

          IF NOT l_has_value THEN

             IF px_attributes_req_table IS NULL THEN
                px_attributes_req_table := EGO_USER_ATTR_TABLE();
             END IF;

             px_attributes_req_table.EXTEND();
             px_attributes_req_table(px_attributes_req_table.LAST) :=
                EGO_USER_ATTR_OBJ(
                   req_attr_rec.application_id                -- APPLICATION_ID
                  ,req_attr_rec.attr_group_type              -- ATTR_GROUP_TYPE
                  ,req_attr_rec.attr_group_name              -- ATTR_GROUP_NAME
                  ,req_attr_rec.attr_group_disp_name    -- ATTR_GROUP_DISP_NAME
                  ,req_attr_rec.attr_name                          -- ATTR_NAME
                  ,req_attr_rec.attr_display_name             -- ATTR_DISP_NAME
                );

Debug_Msg(l_api_name|| req_attr_rec.attr_name || ' does not have a value', 2);
          ELSE
Debug_Msg(l_api_name|| req_attr_rec.attr_name || ' has a value', 2);
          END IF; -- NOT l_has_value
       END LOOP; --fetch_required_attr
    END LOOP; --p_request_table

Debug_Msg('Process_Req_Attr_Results, done', 2);

END Process_Req_Attr_Results;

----------------------------------------------------------------------

--
-- NOTES
--   (-) When an attribute that is required has no value, that attribute's
--       details gets added to the output collection 'x_attributes_req_table'.
--       The caller can read the entries in this table to find out which
--       attributes violate their madatory property.
--
PROCEDURE Validate_Required_Attrs (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name               IN   EGO_DATA_LEVEL_B.DATA_LEVEL_NAME%TYPE := NULL
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_group_type_table         IN   EGO_VARCHAR_TBL_TYPE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_attributes_req_table          OUT NOCOPY EGO_USER_ATTR_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
)IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Required_Attrs';
    l_batch_size            CONSTANT NUMBER := 5;
    l_attributes_row_table  EGO_USER_ATTR_ROW_TABLE;
    l_attributes_data_table EGO_USER_ATTR_DATA_TABLE;
    l_request_table         EGO_ATTR_GROUP_REQUEST_TABLE;
                        -- request table for ALL attribute groups of the object
    l_request_table_batch_iter    EGO_ATTR_GROUP_REQUEST_TABLE;
                             -- request table for one batch of attribute groups
    l_attributes_req_table  EGO_USER_ATTR_TABLE;
    l_token_table           ERROR_HANDLER.Token_Tbl_Type;

  BEGIN

    Debug_Msg(l_api_name ||' starting', 2);

    --------------------------------------------------------------------------
    -- Build a Request Table for all attribute groups of the object to be   --
    -- validated.                                                           --
    --------------------------------------------------------------------------

    Build_Request_Table_For_Obj(
        p_object_name                   => p_object_name
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level_name               => p_data_level_name
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_attr_group_type_table         => p_attr_group_type_table
       ,x_attr_group_request_table      => l_request_table
    );

    Debug_Msg(l_api_name||' Request Table for object has been built.', 2);

    IF l_request_table IS NULL THEN
       Debug_Msg(l_api_name||' Request Table for object is null so Returning.', 2);
       RETURN;
    END IF;

    --------------------------------------------------------------------------
    -- Build a Request Table which will contain the requests for just one   --
    -- batch of attribute groups per iteration                              --
    --------------------------------------------------------------------------

    l_request_table_batch_iter   := EGO_ATTR_GROUP_REQUEST_TABLE();

    IF l_request_table.COUNT = 0 THEN
       Debug_Msg(l_api_name||' Request Table for attribute group is empty so Returning', 2);
       RETURN;
    END IF;

    --------------------------------------------------------------------------
    -- Iterate through the request objects, and validate the attributes at  --
    -- the data level that particular request object specifies              --
    --------------------------------------------------------------------------

    FOR i IN 1 .. l_request_table.COUNT
    LOOP

       -----------------------------------------------------------------------
       -- Collect the request rows that belong to a single attribute group  --
       -----------------------------------------------------------------------

       l_request_table_batch_iter.EXTEND();

       IF mod(i, l_batch_size) = 0 THEN
          -- Start a new batch
          l_request_table_batch_iter(l_batch_size) := l_request_table(i);
       ELSE
          -- Append this request row to the current batch
          l_request_table_batch_iter(mod(i, l_batch_size)) := l_request_table(i);
       END IF;

       IF mod(i, l_batch_size) = 0 OR
          i = l_request_table.COUNT
       THEN

          --------------------------------------------------------------------
          -- Fetch the attribute values in this batch of attribute groups   --
          --------------------------------------------------------------------
          Get_User_Attrs_Data (
              p_api_version                   => p_api_version
             ,p_object_name                   => p_object_name
             ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
             ,p_attr_group_request_table      => l_request_table_batch_iter
             ,p_user_privileges_on_object     => NULL
             ,p_entity_id                     => p_entity_id
             ,p_entity_index                  => p_entity_index
             ,p_entity_code                   => p_entity_code
             ,p_debug_level                   => p_debug_level
             ,p_init_error_handler            => p_init_error_handler
             ,p_init_fnd_msg_list             => p_init_fnd_msg_list
             ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
             ,x_attributes_row_table          => l_attributes_row_table
             ,x_attributes_data_table         => l_attributes_data_table
             ,x_return_status                 => x_return_status
             ,x_errorcode                     => x_errorcode
             ,x_msg_count                     => x_msg_count
             ,x_msg_data                      => x_msg_data
          );

          IF l_attributes_data_table IS NULL THEN
Debug_Msg(l_api_name||' l_attributes_data_table = NULL', 3);
          ELSE
Debug_Msg(l_api_name||' l_attributes_data_table.COUNT = ' || l_attributes_data_table.COUNT, 3);
          END IF;

          -------------------------------------
          -- Populate result data structure  --
          -------------------------------------
          Process_Req_Attr_Results(
             p_request_table          => l_request_table_batch_iter
            ,p_attributes_row_table   => l_attributes_row_table
            ,p_attributes_data_table  => l_attributes_data_table
            ,px_attributes_req_table  => l_attributes_req_table
          );

          x_attributes_req_table := l_attributes_req_table;

          --reset transient variables
          l_request_table_batch_iter.DELETE;

          IF l_attributes_row_table IS NOT NULL THEN
             l_attributes_row_table.DELETE;
          END IF;

          IF l_attributes_data_table IS NOT NULL THEN
             l_attributes_data_table.DELETE;
          END IF;

       END IF;

    END LOOP;

    Debug_Msg(l_api_name||' done', 2);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_token_table.DELETE();
      l_token_table(1).TOKEN_NAME := 'PKG_NAME';
      l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
      l_token_table(2).TOKEN_NAME := 'API_NAME';
      l_token_table(2).TOKEN_VALUE := l_api_name;
      l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
      l_token_table(3).TOKEN_VALUE := SQLERRM;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name              => 'EGO_PLSQL_ERR'
       ,p_application_id            => 'EGO'
       ,p_token_tbl                 => l_token_table
       ,p_message_type              => FND_API.G_RET_STS_ERROR
       ,p_row_identifier            => G_USER_ROW_IDENTIFIER
       ,p_entity_id                 => p_entity_id
       ,p_entity_index              => p_entity_index
       ,p_entity_code               => p_entity_code
       ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
      );

END Validate_Required_Attrs;


-----------------------------------------------
-- Wrappers for Add_Bind and Init
-----------------------------------------------

PROCEDURE Add_Bind ( p_bind_identifier   IN VARCHAR2 DEFAULT NULL
                    ,p_value             IN VARCHAR2)
  IS
BEGIN
   G_BIND_INDEX := G_BIND_INDEX + 1;
   G_BIND_IDENTIFIER_TBL(G_BIND_INDEX) := p_bind_identifier;
   G_BIND_DATATYPE_TBL(G_BIND_INDEX) := 'C';
   G_BIND_TEXT_TBL(G_BIND_INDEX) := p_value;
   FND_DSQL.Add_Bind(p_value);
END Add_Bind; --VARCHAR2

----------------------------------------------------------------------

PROCEDURE Add_Bind ( p_bind_identifier   IN VARCHAR2 DEFAULT NULL
                    ,p_value             IN DATE)
  IS
BEGIN
   G_BIND_INDEX := G_BIND_INDEX + 1;
   G_BIND_IDENTIFIER_TBL(G_BIND_INDEX) := p_bind_identifier;
   G_BIND_DATATYPE_TBL(G_BIND_INDEX) := 'D';
   G_BIND_DATE_TBL(G_BIND_INDEX) := p_value;
   FND_DSQL.Add_Bind(p_value);
END Add_Bind; --DATE

----------------------------------------------------------------------

PROCEDURE Add_Bind ( p_bind_identifier   IN VARCHAR2 DEFAULT NULL
                    ,p_value             IN NUMBER)
  IS
BEGIN
   G_BIND_INDEX := G_BIND_INDEX + 1;
   G_BIND_IDENTIFIER_TBL(G_BIND_INDEX) := p_bind_identifier;
   G_BIND_DATATYPE_TBL(G_BIND_INDEX) := 'N';
   G_BIND_NUMBER_TBL(G_BIND_INDEX) := p_value;
   FND_DSQL.Add_Bind(p_value);
END Add_Bind; --NUMBER

----------------------------------------------------------------------

PROCEDURE Set_Binds_And_Dml (p_sql IN VARCHAR2
                            ,p_mode IN VARCHAR2)
 IS
BEGIN

 IF(p_mode = 'B') THEN
   G_B_TABLE_DML           := p_sql;
   G_B_BIND_INDEX          := G_BIND_INDEX;
   G_B_BIND_IDENTIFIER_TBL   := G_BIND_IDENTIFIER_TBL;
   G_B_BIND_DATATYPE_TBL   := G_BIND_DATATYPE_TBL;
   G_B_BIND_TEXT_TBL       := G_BIND_TEXT_TBL;
   G_B_BIND_DATE_TBL       := G_BIND_DATE_TBL;
   G_B_BIND_NUMBER_TBL     := G_BIND_NUMBER_TBL;
 ELSIF (p_mode='TL') THEN
   G_TL_TABLE_DML          := p_sql;
   G_TL_BIND_INDEX         := G_BIND_INDEX;
   G_TL_BIND_IDENTIFIER_TBL   := G_BIND_IDENTIFIER_TBL;
   G_TL_BIND_DATATYPE_TBL  := G_BIND_DATATYPE_TBL;
   G_TL_BIND_TEXT_TBL      := G_BIND_TEXT_TBL;
   G_TL_BIND_DATE_TBL      := G_BIND_DATE_TBL;
   G_TL_BIND_NUMBER_TBL    := G_BIND_NUMBER_TBL;
 END IF;

END Set_Binds_And_Dml;

----------------------------------------------------------------------

PROCEDURE Init
  IS
BEGIN
   G_BIND_INDEX   := 0;
   FND_DSQL.Init();

   FOR i IN 1 .. 100 LOOP

    G_BIND_IDENTIFIER_TBL(i) := NULL;
    G_BIND_DATATYPE_TBL(i) := NULL;
    G_BIND_TEXT_TBL(i) := NULL;
    G_BIND_DATE_TBL(i) := NULL;
    G_BIND_NUMBER_TBL(i) := NULL;

   END LOOP;

END init;

---------------------------------------------------------------

/*
 * Apply_Default_Vals_For_Entity
 * -----------------------------
 * Apply_Default_Vals_For_Entity : This API should be called after the entity creation
 * is successfuly done. This API would set the default values for attributes in the all
 * the single row attribute groups not having a required attribute for the given entity.
 */

PROCEDURE Apply_Default_Vals_For_Entity (
        p_object_name                   IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_groups_to_exclude        IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL
       ,p_data_level_values             IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_additional_class_Code_list    IN   VARCHAR2   DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       )
  IS
    l_api_name                    VARCHAR2(30) := 'Apply_Default_Vals_For_Entity';
    l_object_id                   NUMBER;
    l_ext_b_table_name            VARCHAR2(30);
    l_ext_vl_name                 VARCHAR2(30);
    l_ext_where_clause            VARCHAR2(600);
    l_ag_id_col_exists            BOOLEAN;
    l_dynamic_sql                 VARCHAR2(10000);
    l_related_class_Code_list     VARCHAR2(5000);
    l_excluded_ag_list            VARCHAR2(1000);
    l_previous_ag_id              NUMBER;
    l_counter1                    NUMBER;
    l_counter2                    NUMBER;
    l_dummy_number                NUMBER;
    l_ext_row_exists              BOOLEAN;
    l_base_data_level             VARCHAR2(30);
    l_data_level_1                VARCHAR2(150);
    l_data_level_2                VARCHAR2(150);
    l_data_level_3                VARCHAR2(150);
    l_data_level_4                VARCHAR2(150);
    l_data_level_5                VARCHAR2(150);
    l_number_val                  NUMBER;
    l_str_val                     VARCHAR2(4000);	-- Bug 8757354
    l_date_val                    DATE;
    l_attr_row_table              EGO_USER_ATTR_ROW_TABLE;
    l_attr_data_table             EGO_USER_ATTR_DATA_TABLE;
    l_transaction_type            VARCHAR2(10);
    l_temp_date_str               VARCHAR2(200);
    l_temp_attr_row_table         EGO_USER_ATTR_ROW_TABLE;
    l_temp_attr_data_table        EGO_USER_ATTR_DATA_TABLE;
    l_cc_name_value_pairs         EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_has_data_level_id           BOOLEAN;
    l_data_level_id               NUMBER;

    TYPE DYNAMIC_CUR              IS REF CURSOR;
    attr_rec_cursor               DYNAMIC_CUR;

    TYPE LOCAL_USER_ATTR_DATA_REC IS RECORD
    (
        ATTR_GROUP_ID             NUMBER
       ,ATTR_GROUP_NAME           VARCHAR2(30)
       ,ATTR_NAME                 VARCHAR2(30)
       ,REQUIRED_FLAG             VARCHAR2(1)
       ,DEFAULT_VALUE             VARCHAR2(4000)	-- Bug 8757354
       ,DATA_LEVEL                VARCHAR2(30)
       ,DATA_TYPE                 VARCHAR2(1)
    );

    l_attr_record                 LOCAL_USER_ATTR_DATA_REC;

  BEGIN

    Debug_Msg(l_api_name ||' Starting with params ',1);
    Debug_Msg(l_api_name ||' object_name: '||p_object_name||' application id: '||p_application_id);
    Debug_Msg(l_api_name ||' attr group type: '||p_attr_group_type||' attr grp to exclude '||p_attr_groups_to_exclude);
    IF p_pk_column_name_value_pairs IS NULL THEN
      Debug_Msg(l_api_name ||' p_pk_column_name_value_pairs is NULL ');
    ELSIF p_pk_column_name_value_pairs.COUNT = 0 THEN
      Debug_Msg(l_api_name ||' p_pk_column_name_value_pairs count is 0 ');
    ELSE
      FOR i IN 1 .. p_pk_column_name_value_pairs.COUNT LOOP
        debug_msg(l_api_name||' name('||i||'): '||p_pk_column_name_value_pairs(i).NAME ||' value('||i||'): '||p_pk_column_name_value_pairs(i).value);
      END LOOP;
    END IF;
    IF p_class_code_name_value_pairs IS NULL THEN
      Debug_Msg(l_api_name ||' p_class_code_name_value_pairs is NULL ');
    ELSIF p_class_code_name_value_pairs.COUNT = 0 THEN
      Debug_Msg(l_api_name ||' p_class_code_name_value_pairs count is 0 ');
    ELSE
      FOR i IN 1 .. p_class_code_name_value_pairs.COUNT LOOP
        debug_msg(l_api_name||' name('||i||'): '||p_class_code_name_value_pairs(i).NAME ||' value('||i||'): '||p_class_code_name_value_pairs(i).value);
      END LOOP;
    END IF;
    Debug_Msg(l_api_name ||' data level: '||p_data_level);
    IF p_data_level_values IS NULL THEN
      Debug_Msg(l_api_name ||' p_data_level_values is NULL ');
    ELSIF p_data_level_values.COUNT = 0 THEN
      Debug_Msg(l_api_name ||' p_data_level_values count is 0 ');
    ELSE
      FOR i IN 1 .. p_data_level_values.COUNT LOOP
        debug_msg(l_api_name||' name('||i||'): '||p_data_level_values(i).NAME ||' value('||i||'): '||p_data_level_values(i).value);
      END LOOP;
    END IF;
    Debug_Msg(l_api_name ||' addl class codes: '||p_additional_class_Code_list);
    Debug_Msg(l_api_name ||' entity id: '||p_entity_id||' entity index: '||p_entity_index);
    Debug_Msg(l_api_name ||' entity code: '||p_entity_code||' debug level: '||p_debug_level);
    Debug_Msg(l_api_name ||' init error handler: '||p_init_error_handler||' write conc log: '||p_write_to_concurrent_log);
    Debug_Msg(l_api_name ||' init msg list: '||p_init_fnd_msg_list||' log errors: '||p_log_errors);
    Debug_Msg(l_api_name ||' add error to stack: '||p_add_errors_to_fnd_stack||' commit flag: '||p_commit);

    SELECT FLEX.APPLICATION_TABLE_NAME        EXT_TABLE_NAME,
           FLEX_EXT.APPLICATION_VL_NAME       EXT_VL_NAME
      INTO l_ext_b_table_name,
           l_ext_vl_name
      FROM FND_DESCRIPTIVE_FLEXS              FLEX,
           EGO_FND_DESC_FLEXS_EXT             FLEX_EXT
     WHERE FLEX.APPLICATION_ID = FLEX_EXT.APPLICATION_ID(+)
       AND FLEX.DESCRIPTIVE_FLEXFIELD_NAME = FLEX_EXT.DESCRIPTIVE_FLEXFIELD_NAME(+)
       AND FLEX.APPLICATION_ID = p_application_id
       AND FLEX.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type;

    IF( l_ext_vl_name IS NULL ) THEN
      l_ext_vl_name := l_ext_b_table_name;
    END IF;
    Debug_Msg(l_api_name ||' b table: '||l_ext_b_table_name||' tl table: '||l_ext_vl_name);

    l_object_id := Get_Object_Id_From_Name(p_object_name);

    -------------------------------------------------------------
    -- Find out weather the ATTR_GROUP_ID column exists in the --
    -- table where attribute data is to be uploaded or not     --
    -------------------------------------------------------------
    l_ag_id_col_exists := FND_API.TO_BOOLEAN(EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(
                                    p_table_name  => l_ext_b_table_name
                                   ,p_column_name => 'ATTR_GROUP_ID')
                                             );

    l_has_data_level_id := FND_API.TO_BOOLEAN(EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(
                                    p_table_name  => l_ext_b_table_name
                                   ,p_column_name => 'DATA_LEVEL_ID')
                                             );

    IF l_has_data_level_id THEN
      SELECT data_level_id
        INTO l_data_level_id
        FROM ego_data_level_b
       WHERE application_id = p_application_id
         AND attr_group_type = p_attr_group_type
         AND data_level_name = p_data_level;
    END IF;

    l_ext_where_clause := p_class_code_name_value_pairs(1).NAME ||' = '||p_class_code_name_value_pairs(1).VALUE||' ';
    IF (l_ag_id_col_exists) THEN
      l_ext_where_clause := l_ext_where_clause || ' AND EXT.ATTR_GROUP_ID = :ag_id ';
    END IF;

    FOR i IN p_pk_column_name_value_pairs.FIRST .. p_pk_column_name_value_pairs.LAST
    LOOP
      l_ext_where_clause := l_ext_where_clause||' AND '||p_pk_column_name_value_pairs(i).NAME || ' = '||p_pk_column_name_value_pairs(i).VALUE ;
    END LOOP;

    IF l_has_data_level_id THEN
      l_ext_where_clause := l_ext_where_clause || ' AND data_level_id = '||l_data_level_id;
      IF p_data_level_values IS NOT NULL AND p_data_level_values.COUNT <> 0 THEN
        FOR i IN 1 .. p_data_level_values.COUNT LOOP
          l_ext_where_clause := l_ext_where_clause || ' AND '||p_data_level_values(i).name ||' = '||p_data_level_values(i).value;
        END LOOP;
      END IF;
    END IF;

    IF (p_additional_class_Code_list IS NULL) THEN
      l_related_class_Code_list := ' -2910 '; --any random negative number since cc wont be negative.
    ELSE
      l_related_class_Code_list := p_additional_class_Code_list;
    END IF;

    ----------------------
    -- Building the SQL --
    ----------------------
    --bug 8904892 change driving table to assoc_tbl;

    l_dynamic_sql := ' SELECT  /*+ LEADING( assoc_tbl) */ ATTR_GROUP_TBL.ATTR_GROUP_ID, ATTR_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE ATTR_GROUP_NAME,'||
                            ' ATTR_TBL.END_USER_COLUMN_NAME ATTR_NAME, REQUIRED_FLAG, DEFAULT_VALUE , ASSOC_TBL.DATA_LEVEL,'||
                            ' ATTR_EXT_TBL.DATA_TYPE'||
                       ' FROM FND_DESCR_FLEX_COLUMN_USAGES ATTR_TBL,'||
                            ' EGO_FND_DSC_FLX_CTX_EXT ATTR_GROUP_TBL,'||
                            ' EGO_OBJ_AG_ASSOCS_B ASSOC_TBL,'||
                            ' EGO_FND_DF_COL_USGS_EXT ATTR_EXT_TBL'||
                      ' WHERE ATTR_TBL.APPLICATION_ID = ATTR_GROUP_TBL.APPLICATION_ID ';

    IF (p_attr_groups_to_exclude IS NOT NULL) THEN
       l_dynamic_sql := l_dynamic_sql||
                        ' AND ATTR_GROUP_TBL.ATTR_GROUP_ID NOT IN ('||p_attr_groups_to_exclude||') ';
    END IF;

    l_dynamic_sql := l_dynamic_sql||
                        ' AND ATTR_TBL.DESCRIPTIVE_FLEXFIELD_NAME = ATTR_GROUP_TBL.DESCRIPTIVE_FLEXFIELD_NAME'||
                        ' AND ATTR_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE = ATTR_GROUP_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE '||
                        ' AND (ATTR_TBL.DEFAULT_VALUE IS NOT NULL OR ATTR_TBL.REQUIRED_FLAG = ''Y'')'||
                        ' AND ATTR_TBL.ENABLED_FLAG = ''Y'''||
                        ' AND ATTR_EXT_TBL.APPLICATION_ID = :app_id '||
                        ' AND ATTR_EXT_TBL.DESCRIPTIVE_FLEXFIELD_NAME = :attr_group_type '||
                        ' AND ATTR_EXT_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE = ATTR_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE'||
                        ' AND ATTR_EXT_TBL.APPLICATION_COLUMN_NAME = ATTR_TBL.APPLICATION_COLUMN_NAME'||
                        ' AND ATTR_GROUP_TBL.DESCRIPTIVE_FLEXFIELD_NAME = :attr_group_type '||
                        ' AND ATTR_GROUP_TBL.APPLICATION_ID = :app_id '||
                        ' AND ATTR_GROUP_TBL.ATTR_GROUP_ID = ASSOC_TBL.ATTR_GROUP_ID'||
                        ' AND ASSOC_TBL.OBJECT_ID = :object_id '||
                        ' AND ATTR_GROUP_TBL.MULTI_ROW = ''N'''||
                        ' AND (    ASSOC_TBL.CLASSIFICATION_CODE IN ('||l_related_class_Code_list||')'||
                        '       OR ASSOC_TBL.CLASSIFICATION_CODE = :class_Code  )';
    IF l_has_data_level_id THEN
      l_dynamic_sql := l_dynamic_sql||
                        ' AND ASSOC_TBL.data_level_id = '||l_data_level_id;
    END IF;
      l_dynamic_sql := l_dynamic_sql||
                        ' ORDER BY ATTR_GROUP_TBL.ATTR_GROUP_ID';

   IF l_has_data_level_id THEN
     l_base_data_level := p_data_level;
   ELSE
     -----------------------------------------------
     -- Getting the base data level for the entity
     -----------------------------------------------
     SELECT data_level_name
       INTO l_base_data_level
       FROM ( SELECT MIN(data_level_id) data_level_id
                FROM ego_data_level_b
               WHERE application_id = p_application_id
                 AND attr_group_type = p_attr_group_type
            ) min_dl, ego_data_level_b dl
      WHERE dl.data_level_id = min_dl.data_level_id;
   END IF;

   IF p_data_level_values IS NOT NULL THEN
     l_dummy_number := p_data_level_values.COUNT;
   ELSE
     l_dummy_number := 0;
   END IF;

   IF l_dummy_number > 4 THEN
     l_data_level_5 := p_data_level_values(5).VALUE;
   ELSE
     l_data_level_5 := NULL;
   END IF;

   IF l_dummy_number > 3 THEN
     l_data_level_4 := p_data_level_values(4).VALUE;
   ELSE
     l_data_level_4 := NULL;
   END IF;

   IF l_dummy_number > 2 THEN
     l_data_level_3 := p_data_level_values(3).VALUE;
   ELSE
     l_data_level_3 := NULL;
   END IF;

   IF l_dummy_number > 1 THEN
     l_data_level_2 := p_data_level_values(2).VALUE;
   ELSE
     l_data_level_2 := NULL;
   END IF;

   IF l_dummy_number > 0 THEN
     l_data_level_1 := p_data_level_values(1).VALUE;
   ELSE
     l_data_level_1 := NULL;
   END IF;

   -------------------------------------
   -- Looping through the attr records
   -- for building the attr data object
   -------------------------------------
    -- initializing all the variables...
    l_excluded_ag_list := ' ';
    l_previous_ag_id := -1;
    l_counter1 := 0;
    l_counter2 := 0;

    l_attr_row_table := EGO_USER_ATTR_ROW_TABLE();
    l_attr_data_table := EGO_USER_ATTR_DATA_TABLE();
    l_temp_attr_row_table := EGO_USER_ATTR_ROW_TABLE();
    l_temp_attr_data_table := EGO_USER_ATTR_DATA_TABLE();

    Debug_Msg(l_api_name ||' attr rec cursor: '||l_dynamic_sql);
    Debug_Msg(l_api_name ||' binds are 1: '|| p_application_id ||' 2: '|| p_attr_group_type||
              ' 3: '||p_attr_group_type ||' 4: '||p_application_id ||' 5: '||l_object_id ||
              ' 6: '||p_class_code_name_value_pairs(1).VALUE);

     OPEN attr_rec_cursor
      FOR  l_dynamic_sql
    USING  p_application_id,
           p_attr_group_type,
           p_attr_group_type,
           p_application_id,
           l_object_id,
           p_class_code_name_value_pairs(1).VALUE;

    ------------------------------------------------------------------------------------------
    --Looping through the cursor fetched records to get the attributes with default values  --
    --and no corresponding AG row in the ext data table.                                    --
    ------------------------------------------------------------------------------------------
    LOOP
    FETCH attr_rec_cursor INTO l_attr_record;
    EXIT WHEN attr_rec_cursor%NOTFOUND;

      IF(l_attr_record.DATA_TYPE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE)THEN
         l_number_val := TO_NUMBER(l_attr_record.DEFAULT_VALUE);
         l_str_val    := NULL;
         l_date_val   := NULL;
      ELSIF (l_attr_record.DATA_TYPE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE OR
             l_attr_record.DATA_TYPE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE) THEN
         l_number_val := NULL;
         l_str_val    := l_attr_record.DEFAULT_VALUE;
         l_date_val   := NULL;
      ELSIF(l_attr_record.DATA_TYPE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
             l_attr_record.DATA_TYPE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
         l_number_val := NULL;
         l_str_val    := NULL;
         IF(INSTR(UPPER(l_attr_record.DEFAULT_VALUE),'$SYSDATE$') <> 0) THEN
           l_temp_date_str := REPLACE(UPPER(l_attr_record.DEFAULT_VALUE),'$'); --bugfix:5228308
           EXECUTE IMMEDIATE 'SELECT '||l_temp_date_str||' FROM DUAL '
           INTO l_date_val;
         ELSE
           l_date_val := TO_DATE(l_attr_record.DEFAULT_VALUE,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
         END IF;
      END IF;

      IF (l_attr_record.REQUIRED_FLAG = 'Y' AND l_attr_record.DEFAULT_VALUE IS NULL) THEN
         l_excluded_ag_list := l_excluded_ag_list || '   '||l_attr_record.ATTR_GROUP_ID||'   ';
      END IF;

      IF (l_previous_ag_id = -1 OR l_previous_ag_id <> l_attr_record.ATTR_GROUP_ID) THEN

        l_temp_attr_row_table.EXTEND();
        l_counter1 := l_counter1+1;

        IF (l_ag_id_col_exists) THEN
           l_transaction_type := 'CREATE';
        ELSE
           l_transaction_type := 'SYNC';
        END IF;

        IF l_has_data_level_id THEN -- R12C code
          Debug_Msg(l_api_name ||' creating attr row object for R12C ');
          l_temp_attr_row_table(l_counter1) :=
                     EGO_USER_ATTR_ROW_OBJ( l_attr_record.ATTR_GROUP_ID,      --ROW_IDENTIFIER
                                            l_attr_record.ATTR_GROUP_ID,      --ATTR_GROUP_ID
                                            p_application_id,                 --ATTR_GROUP_APP_ID
                                            p_attr_group_type,                --ATTR_GROUP_TYPE
                                            l_attr_record.ATTR_GROUP_NAME,    --ATTR_GROUP_NAME
                                            p_data_level,                     --DATA_LEVEL
                                            l_data_level_1,                   --DATA_LEVEL_1
                                            l_data_level_2,                   --DATA_LEVEL_2
                                            l_data_level_3,                   --DATA_LEVEL_3
                                            l_data_level_4,                   --DATA_LEVEL_4
                                            l_data_level_5,                   --DATA_LEVEL_5
                                            l_transaction_type                --TRANSACTION_TYPE
                                           );
        ELSE -- R12 code
          IF(l_base_data_level = l_attr_record.DATA_LEVEL) THEN
            Debug_Msg(l_api_name ||' creating attr row object for R12 base data level ');
            l_temp_attr_row_table(l_counter1) :=
                     EGO_USER_ATTR_ROW_OBJ( l_attr_record.ATTR_GROUP_ID,      --ROW_IDENTIFIER
                                            l_attr_record.ATTR_GROUP_ID,      --ATTR_GROUP_ID
                                            p_application_id,                 --ATTR_GROUP_APP_ID
                                            p_attr_group_type,                --ATTR_GROUP_TYPE
                                            l_attr_record.ATTR_GROUP_NAME,    --ATTR_GROUP_NAME
                                            null,                             --DATA_LEVEL
                                            null,                             --DATA_LEVEL_1
                                            null,                             --DATA_LEVEL_2
                                            null,                             --DATA_LEVEL_3
                                            null,                             --DATA_LEVEL_4
                                            null,                             --DATA_LEVEL_5
                                            l_transaction_type                --TRANSACTION_TYPE
                                           );
          ELSE
            Debug_Msg(l_api_name ||' creating attr row object for R12 NON base data level ');
            l_temp_attr_row_table(l_counter1) :=
                     EGO_USER_ATTR_ROW_OBJ( l_attr_record.ATTR_GROUP_ID,      --ROW_IDENTIFIER
                                            l_attr_record.ATTR_GROUP_ID,      --ATTR_GROUP_ID
                                            p_application_id,                 --ATTR_GROUP_APP_ID
                                            p_attr_group_type,                --ATTR_GROUP_TYPE
                                            l_attr_record.ATTR_GROUP_NAME,    --ATTR_GROUP_NAME
                                            null,                             --DATA_LEVEL
                                            l_data_level_1,                   --DATA_LEVEL_1
                                            l_data_level_2,                   --DATA_LEVEL_2
                                            l_data_level_3,                   --DATA_LEVEL_3
                                            null,                             --DATA_LEVEL_4
                                            null,                             --DATA_LEVEL_5
                                            l_transaction_type                --TRANSACTION_TYPE
                                           );

          END IF;
        END IF;
        l_previous_ag_id := l_attr_record.ATTR_GROUP_ID;
      END IF;

      l_temp_attr_data_table.EXTEND();
      l_counter2 := l_counter2 + 1;
      l_temp_attr_data_table(l_counter2) :=
                 EGO_USER_ATTR_DATA_OBJ( l_attr_record.ATTR_GROUP_ID,   --ROW_IDENTIFIER
                                         l_attr_record.ATTR_NAME,       --ATTR_NAME
                                         l_str_val,                     --ATTR_VALUE_STR
                                         l_number_val,                  --ATTR_VALUE_NUM
                                         l_date_val,                    --ATTR_VALUE_DATE
                                         l_attr_record.DEFAULT_VALUE,   --ATTR_DISP_VALUE
                                         null,                          --ATTR_UNIT_OF_MEASURE
                                         null                           --USER_ROW_IDENTIFIER
                                        );
    END LOOP;
    Debug_Msg(l_api_name ||' completed data for AG cursor ');
    ------------------------------------------------------------------------------------
    --Here we clean up the attr group defination table to filter out the ag's with
    --required attributes or having a record in the ext data table.
    ------------------------------------------------------------------------------------

    l_dynamic_sql := 'SELECT 1 FROM '||l_ext_vl_name||' EXT WHERE '||l_ext_where_clause;
    Debug_Msg(l_api_name ||' dynamic sql for ext row check: '||l_dynamic_sql);

    IF(l_temp_attr_row_table.COUNT > 0 AND l_temp_attr_row_table.COUNT > 0) THEN

       FOR i in l_temp_attr_row_table.FIRST .. l_temp_attr_row_table.LAST
       LOOP

         IF ( INSTR(l_excluded_ag_list,l_temp_attr_row_table(i).ATTR_GROUP_ID) = 0 ) THEN

           l_ext_row_exists := TRUE;
           BEGIN
             IF (l_ag_id_col_exists) THEN
               Debug_Msg(l_api_name ||' exec dyn sql for '||l_temp_attr_row_table(i).ATTR_GROUP_ID);
               EXECUTE IMMEDIATE l_dynamic_sql
               INTO l_dummy_number
               USING l_temp_attr_row_table(i).ATTR_GROUP_ID;
             ELSE
               EXECUTE IMMEDIATE l_dynamic_sql
               INTO l_dummy_number;
             END IF;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               l_ext_row_exists:=FALSE;
           END;

           IF (NOT l_ext_row_exists ) THEN
             l_attr_row_table.EXTEND();
             l_attr_row_table(l_attr_row_table.LAST) :=
                  EGO_USER_ATTR_ROW_OBJ (  l_temp_attr_row_table(i).ROW_IDENTIFIER
                                          ,l_temp_attr_row_table(i).ATTR_GROUP_ID
                                          ,l_temp_attr_row_table(i).ATTR_GROUP_APP_ID
                                          ,l_temp_attr_row_table(i).ATTR_GROUP_TYPE
                                          ,l_temp_attr_row_table(i).ATTR_GROUP_NAME
                                          ,l_temp_attr_row_table(i).DATA_LEVEL
                                          ,l_temp_attr_row_table(i).DATA_LEVEL_1
                                          ,l_temp_attr_row_table(i).DATA_LEVEL_2
                                          ,l_temp_attr_row_table(i).DATA_LEVEL_3
                                          ,l_temp_attr_row_table(i).DATA_LEVEL_4
                                          ,l_temp_attr_row_table(i).DATA_LEVEL_5
                                          ,l_temp_attr_row_table(i).TRANSACTION_TYPE
                                         );
           ELSE
             l_excluded_ag_list := l_excluded_ag_list||'  '||l_temp_attr_row_table(i).ATTR_GROUP_ID||'   ';
           END IF;
         END IF;
       END LOOP;
       Debug_Msg(l_api_name ||' 1st level of filtering ');
       ----------------------------------------------------------------------------
       --Here we filter out the attributes belonging to attr groups which have
       --required attributes or have a row in the ext table for the given item.
       ----------------------------------------------------------------------------

       l_counter1 := 0;
       FOR i in l_temp_attr_data_table.FIRST .. l_temp_attr_data_table.LAST
       LOOP
         IF ( INSTR(l_excluded_ag_list,l_temp_attr_data_table(i).ROW_IDENTIFIER) = 0 ) THEN

           l_counter1 := l_counter1+1;
           l_attr_data_table.EXTEND();
           l_attr_data_table(l_counter1) :=
                EGO_USER_ATTR_DATA_OBJ (  l_temp_attr_data_table(i).ROW_IDENTIFIER
                                         ,l_temp_attr_data_table(i).ATTR_NAME
                                         ,l_temp_attr_data_table(i).ATTR_VALUE_STR
                                         ,l_temp_attr_data_table(i).ATTR_VALUE_NUM
                                         ,l_temp_attr_data_table(i).ATTR_VALUE_DATE
                                         ,l_temp_attr_data_table(i).ATTR_DISP_VALUE
                                         ,l_temp_attr_data_table(i).ATTR_UNIT_OF_MEASURE
                                         ,l_temp_attr_data_table(i).USER_ROW_IDENTIFIER
                                        );
         END IF;
       END LOOP;
       Debug_Msg(l_api_name ||' 2nd level of filtering ');

    END IF; --if the generated tables are not null
    ------------------------------------------------------------
    -- Now we call Process_user_attrs_data for processing the
    -- data we have extracted above ...
    ------------------------------------------------------------

    x_failed_row_id_list := NULL;
    x_return_status := 'S';
    x_errorcode := NULL;
    x_msg_count := 0;
    x_msg_data := NULL;


    IF(l_attr_data_table.COUNT > 0 AND l_attr_row_table.COUNT > 0 ) THEN

      l_cc_name_value_pairs := p_class_code_name_value_pairs;
      l_cc_name_value_pairs.EXTEND();
      l_cc_name_value_pairs(2) := EGO_COL_NAME_VALUE_PAIR_OBJ('RELATED_CLASS_CODE_LIST',l_related_class_Code_list);
      Debug_Msg(l_api_name ||' Calling Process_User_Attrs_Data ');
      Process_User_Attrs_Data(
          p_api_version                   => 1.0
         ,p_object_name                   => p_object_name
         ,p_attributes_row_table          => l_attr_row_table
         ,p_attributes_data_table         => l_attr_data_table
         ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
         ,p_class_code_name_value_pairs   => l_cc_name_value_pairs
         ,p_entity_id                     => p_entity_id
         ,p_entity_index                  => p_entity_index
         ,p_entity_code                   => p_entity_code
         ,p_debug_level                   => p_debug_level
         ,p_init_error_handler            => p_init_error_handler
         ,p_write_to_concurrent_log       => p_write_to_concurrent_log
         ,p_init_fnd_msg_list             => p_init_fnd_msg_list
         ,p_log_errors                    => p_log_errors
         ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
         ,p_commit                        => p_commit
         ,x_failed_row_id_list            => x_failed_row_id_list
         ,x_return_status                 => x_return_status
         ,x_errorcode                     => x_errorcode
         ,x_msg_count                     => x_msg_count
         ,x_msg_data                      => x_msg_data
       );
      Debug_Msg(l_api_name ||' returned Process_User_Attrs_Data with status: '||x_return_status);
      Debug_Msg(l_api_name ||' returned Process_User_Attrs_Data with msg: '||x_msg_data);
    END IF;
    Debug_Msg(l_api_name ||' Exit ');
EXCEPTION
  WHEN OTHERS THEN
    Debug_Msg(l_api_name ||' EXCEPTION: '||SQLERRM);
    x_return_status := G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    x_msg_data := SQLERRM;

END Apply_Default_Vals_For_Entity;

/*
*Bug:9277377
*Add the function to check column for both table and view oject
*/
FUNCTION HAS_COLUMN_IN_TABLE_VIEW (p_object_name  IN  VARCHAR2
                             ,p_column_name IN  VARCHAR2
                             )
RETURN VARCHAR2 IS
  l_dummy_number  NUMBER;
BEGIN
   -- Add owner to the all_tab_columns query for better performance.
   -- Also cache the owner and table names to try to avoid doing the
   -- same query over and over.

     IF (g_tab_name = p_object_name) THEN
       NULL;  -- A hit in the cache, no need to query.
     ELSE
       -- Execute the following either if g_tab_name
       -- is not equal to p_object_name or if it is
       -- NULL (i.e. the first usage).
       --
         SELECT owner
         INTO   g_owner
         FROM   sys.all_objects
         WHERE  object_type IN ('TABLE','VIEW')
         AND object_name = p_object_name;
      -- update cache
         g_tab_name := p_object_name;
     END IF;

  SELECT 1
  INTO l_dummy_number
  FROM SYS.all_tab_columns
  WHERE table_name = p_object_name
  AND column_name = p_column_name;
  RETURN FND_API.G_TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_API.G_FALSE;
END HAS_COLUMN_IN_TABLE_VIEW;



----------------------------
-- Package Initialization --
----------------------------
BEGIN

    G_BIND_DATATYPE_TBL := VARCHAR2_TBL_TYPE();
    G_BIND_TEXT_TBL := VARCHAR2_TBL_TYPE();
    G_BIND_DATE_TBL := DATE_TBL_TYPE();
    G_BIND_NUMBER_TBL := NUMBER_TBL_TYPE();
    G_BIND_IDENTIFIER_TBL := VARCHAR2_TBL_TYPE();


    G_B_BIND_DATATYPE_TBL := VARCHAR2_TBL_TYPE();
    G_B_BIND_TEXT_TBL := VARCHAR2_TBL_TYPE();
    G_B_BIND_DATE_TBL := DATE_TBL_TYPE();
    G_B_BIND_NUMBER_TBL := NUMBER_TBL_TYPE();
    G_B_BIND_IDENTIFIER_TBL := VARCHAR2_TBL_TYPE();


    G_TL_BIND_DATATYPE_TBL := VARCHAR2_TBL_TYPE();
    G_TL_BIND_TEXT_TBL := VARCHAR2_TBL_TYPE();
    G_TL_BIND_DATE_TBL := DATE_TBL_TYPE();
    G_TL_BIND_NUMBER_TBL := NUMBER_TBL_TYPE();
    G_TL_BIND_IDENTIFIER_TBL := VARCHAR2_TBL_TYPE();


    G_BIND_IDENTIFIER_TBL.EXTEND(100);
    G_BIND_DATATYPE_TBL.EXTEND(100);
    G_BIND_TEXT_TBL.EXTEND(100);
    G_BIND_DATE_TBL.EXTEND(100);
    G_BIND_NUMBER_TBL.EXTEND(100);

    G_B_BIND_IDENTIFIER_TBL.EXTEND(100);
    G_B_BIND_DATATYPE_TBL.EXTEND(100);
    G_B_BIND_TEXT_TBL.EXTEND(100);
    G_B_BIND_DATE_TBL.EXTEND(100);
    G_B_BIND_NUMBER_TBL.EXTEND(100);

    G_TL_BIND_IDENTIFIER_TBL.EXTEND(100);
    G_TL_BIND_DATATYPE_TBL.EXTEND(100);
    G_TL_BIND_TEXT_TBL.EXTEND(100);
    G_TL_BIND_DATE_TBL.EXTEND(100);
    G_TL_BIND_NUMBER_TBL.EXTEND(100);

END EGO_USER_ATTRS_DATA_PVT;

/
