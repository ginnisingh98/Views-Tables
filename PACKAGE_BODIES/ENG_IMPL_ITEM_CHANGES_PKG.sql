--------------------------------------------------------
--  DDL for Package Body ENG_IMPL_ITEM_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_IMPL_ITEM_CHANGES_PKG" AS
/* $Header: ENGITMIB.pls 120.41.12010000.6 2010/09/07 23:16:16 mshirkol ship $ */


   ----------------------------------------------------------------------------
   --  Debug Profile option used to write Error_Handler.Write_Debug          --
   --  Profile option name = INV_DEBUG_TRACE ;                               --
   --  User Profile Option Name = INV: Debug Trace                           --
   --  Values: 1 (True) ; 0 (False)                                          --
   --  NOTE: This better than MRP_DEBUG which is used at many places.        --
   ----------------------------------------------------------------------------
   G_DEBUG CONSTANT VARCHAR2(10) := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   -----------------------------------------------------------------------
   -- These are the Constants to generate a New Line Character.         --
   -----------------------------------------------------------------------
   G_CARRIAGE_RETURN VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(13);
   G_LINE_FEED       VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(10);
   -- Following prints ^M characters in the log file.
   G_NEWLINE         VARCHAR2(2) :=  G_LINE_FEED;


   ---------------------------------------------------------------
   -- API Return Status       .                                 --
   ---------------------------------------------------------------
   G_RET_STS_SUCCESS       CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_SUCCESS;
   G_RET_STS_WARNING       CONSTANT    VARCHAR2(1) :=  'W';
   G_RET_STS_ERROR         CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_ERROR;
   G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_UNEXP_ERROR;

   ---------------------------------------------------------------
   -- Used for Error Reporting.                                 --
   ---------------------------------------------------------------
   G_ERROR_TABLE_NAME      VARCHAR2(30) ;
   G_ERROR_ENTITY_CODE     VARCHAR2(30) := 'EGO_ITEM';
   G_OUTPUT_DIR            VARCHAR2(512) ;
   G_ERROR_FILE_NAME       VARCHAR2(400) ;
   G_BO_IDENTIFIER         VARCHAR2(30) := 'ENG_CHANGE_IMPL';


   ---------------------------------------------------------------
   -- Introduced for 11.5.10, so that Java Conc Program can     --
   -- continue writing to the same Error Log File.              --
   ---------------------------------------------------------------
   G_ERRFILE_PATH_AND_NAME VARCHAR2(10000);



   ---------------------------------------------------------------
   -- Message Type Text       .                                 --
   ---------------------------------------------------------------
   G_FND_MSG_TYPE_CONFIRMATION       VARCHAR2(100) ;
   G_FND_MSG_TYPE_ERROR              VARCHAR2(100) ;
   G_FND_MSG_TYPE_WARNING            VARCHAR2(100) ;
   G_FND_MSG_TYPE_INFORMATION        VARCHAR2(100) ;

   ---------------------------------------------------------------
   -- Message Type Text       .                                 --
   ---------------------------------------------------------------
   G_ENG_MSG_TYPE_ERROR              CONSTANT VARCHAR2(1)     :=  Error_Handler.G_STATUS_ERROR ;
   G_ENG_MSG_TYPE_WARNING            CONSTANT VARCHAR2(1)     :=  Error_Handler.G_STATUS_WARNING ;
   G_ENG_MSG_TYPE_UNEXPECTED         CONSTANT VARCHAR2(1)     :=  Error_Handler.G_STATUS_UNEXPECTED ;
   G_ENG_MSG_TYPE_FATAL              CONSTANT VARCHAR2(1)     :=  Error_Handler.G_STATUS_FATAL  ;
   G_ENG_MSG_TYPE_CONFIRMATION       CONSTANT VARCHAR2(1)     :=  'C';
   G_ENG_MSG_TYPE_INFORMATION        CONSTANT VARCHAR2(1)     :=  'I' ;




   ---------------------------------------------------------------
   -- Private Global Variables    .                             --
   ---------------------------------------------------------------
    TYPE LOCAL_VARCHAR_TABLE IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

   G_OBJECT_NAME_TO_ID_CACHE                LOCAL_VARCHAR_TABLE;


   G_EGO_ITEM                     CONSTANT VARCHAR2(30)  := 'EGO_ITEM';
   G_EGO_APPL_ID                  CONSTANT NUMBER        := 431 ;
   G_ITEM_APPL_ID                 CONSTANT NUMBER        := 401 ;
   G_EGO_MASTER_ITEMS             CONSTANT VARCHAR2(30)  := 'EGO_MASTER_ITEMS' ;
   G_EGO_ITEMMGMT_GROUP           CONSTANT VARCHAR2(30)  := 'EGO_ITEMMGMT_GROUP' ;
   G_EGO_ITEM_GTIN_ATTRS          CONSTANT VARCHAR2(30)  := 'EGO_ITEM_GTIN_ATTRS' ;
   G_EGO_ITEM_GTIN_MULTI_ATTRS    CONSTANT VARCHAR2(30)  := 'EGO_ITEM_GTIN_MULTI_ATTRS' ;


  ---------------------------------------------------------------
  -- Change Management ACD TYpe                                --
  ---------------------------------------------------------------
  G_ADD_ACD_TYPE       CONSTANT VARCHAR2(10) := 'ADD';
  G_CHANGE_ACD_TYPE    CONSTANT VARCHAR2(10) := 'CHANGE';
  G_DELETE_ACD_TYPE    CONSTANT VARCHAR2(10) := 'DELETE';
  G_HISTORY_ACD_TYPE   CONSTANT VARCHAR2(10) := 'HISTORY';

  ---------------------------------------------------------------
  -- Change Management Tx TYpe                                --
  ---------------------------------------------------------------
  G_CREATE_TX_TYPE                         CONSTANT VARCHAR2(10) := 'CREATE'; --4th
  G_UPDATE_TX_TYPE                         CONSTANT VARCHAR2(10) := 'UPDATE'; --2nd
  G_DELETE_TX_TYPE                         CONSTANT VARCHAR2(10) := 'DELETE'; --1st
  G_SYNC_TX_TYPE                           CONSTANT VARCHAR2(10) := 'SYNC';   --3rd

  ---------------------------------------------------------------
  -- Seesion Lang Info --
  ---------------------------------------------------------------

  -- Cached NLS values
  -- 64 is drawned from v$nls_valid_values view.
  G_NLS_LANGUAGE  VARCHAR2(64);
  G_NLS_TERRITORY VARCHAR2(64);
  G_NLS_CHARSET   VARCHAR2(64);


  -----------------------------------------------------
  -- This is a private additional mode for use in    --
  -- calls to Process_Row from Implement_Change_Line --
  -----------------------------------------------------
  G_IMPLEMENT_CREATE_MODE                  CONSTANT VARCHAR2(10) := 'IMP_CREATE';


  ------------------------
  -- Private Data Types --
  ------------------------
  TYPE LOCAL_COL_NV_PAIR_TABLE IS TABLE OF EGO_COL_NAME_VALUE_PAIR_OBJ
      INDEX BY BINARY_INTEGER;



 ----------------------------------------------------------
 -- Write to Concurrent Log                              --
 ----------------------------------------------------------

PROCEDURE Developer_Debug (p_msg  IN  VARCHAR2) IS
 l_err_msg VARCHAR2(240);
BEGIN

  FND_FILE.put_line(FND_FILE.LOG, p_msg);

  EXCEPTION
   WHEN OTHERS THEN
    l_err_msg := SUBSTRB(SQLERRM, 1,240);
    FND_FILE.put_line(FND_FILE.LOG, 'LOGGING SQL ERROR => '||l_err_msg);
END;


-----------------------------------------------------------------
 -- Write Debug statements to Log using Error Handler procedure --
 -----------------------------------------------------------------
PROCEDURE Write_Debug (p_msg  IN  VARCHAR2)
IS
BEGIN

  -- NOTE: No need to check for profile now, as Error_Handler checks
  --       for Error_Handler.Get_Debug = 'Y' before writing to Debug Log.
  -- If Profile set to TRUE --
  -- IF (G_DEBUG = 1) THEN
  -- Error_Handler.Write_Debug('['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_msg);
  -- END IF;

  Error_Handler.Write_Debug('['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_msg);

  -- For Concurrent Request Log
  Developer_Debug('['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_msg);


  /*
  -- For OA/FND Log
  BEGIN

    -- FND Standard Log
    -- FND_LOG.LEVEL_UNEXPECTED;
    -- FND_LOG.LEVEL_ERROR;
    -- FND_LOG.LEVEL_EXCEPTION;
    -- FND_LOG.LEVEL_EVENT;
    -- FND_LOG.LEVEL_PROCEDURE;
    -- FND_LOG.LEVEL_STATEMENT;
    --  G_DEBUG_LOG_HEAD         := 'fnd.plsql.'||G_PKG_NAME||'.';


    IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(log_level => p_log_level
                    ,module    => G_DEBUG_LOG_HEAD||p_module
                    ,message   => p_message
                    );
    END IF;
  NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END log_now;
  */



END;


 ----------------------------------------------------------
 -- Internal procedure to open Debug Session.            --
 ----------------------------------------------------------
PROCEDURE open_debug_session_internal IS

  CURSOR c_get_utl_file_dir IS
     SELECT VALUE
      FROM V$PARAMETER
      WHERE NAME = 'utl_file_dir';

  --local variables
  l_log_output_dir       VARCHAR2(512);
  l_log_return_status    VARCHAR2(99);
  l_errbuff              VARCHAR2(999);
BEGIN

  Error_Handler.initialize();
  Error_Handler.set_bo_identifier(G_BO_IDENTIFIER);

  ---------------------------------------------------------------------------------
  -- Commented on 12/17/2003 (PPEDDAMA). Open_Debug_Session should set the value
  -- appropriately, so that when the Debug Session is successfully opened :
  -- will return Error_Handler.Get_Debug = 'Y', else Error_Handler.Get_Debug = 'N'
  ---------------------------------------------------------------------------------
  -- Error_Handler.Set_Debug('Y');

  OPEN c_get_utl_file_dir;
  FETCH c_get_utl_file_dir INTO l_log_output_dir;
  --developer_debug('UTL_FILE_DIR : '||l_log_output_dir);
  IF c_get_utl_file_dir%FOUND THEN
    ------------------------------------------------------
    -- Trim to get only the first directory in the list --
    ------------------------------------------------------
    IF INSTR(l_log_output_dir,',') <> 0 THEN
      l_log_output_dir := SUBSTR(l_log_output_dir, 1, INSTR(l_log_output_dir, ',') - 1);
      --developer_debug('Log Output Dir : '||l_log_output_dir);
    END IF;


    IF G_OUTPUT_DIR IS NOT NULL
    THEN
       l_log_output_dir := G_OUTPUT_DIR ;
    END IF ;



    IF G_ERROR_FILE_NAME IS NULL
    THEN
        G_ERROR_FILE_NAME := G_BO_IDENTIFIER ||'_'||
                             to_char(sysdate, 'DDMONYYYY_HH24MISS')||'.err';
    END IF ;

    --developer_debug('Trying to open the Error File => '||G_ERROR_FILE_NAME);

    -----------------------------------------------------------------------
    -- To open the Debug Session to write the Debug Log.                 --
    -- This sets Debug value so that Error_Handler.Get_Debug returns 'Y' --
    -----------------------------------------------------------------------
    Error_Handler.Open_Debug_Session(
      p_debug_filename   => G_ERROR_FILE_NAME
     ,p_output_dir       => l_log_output_dir
     ,x_return_status    => l_log_return_status
     ,x_error_mesg       => l_errbuff
     );

    ---------------------------------------------------------------
    -- Introduced for 11.5.10, so that Java Conc Program can     --
    -- continue writing to the same Error Log File.              --
    ---------------------------------------------------------------
    G_ERRFILE_PATH_AND_NAME := l_log_output_dir||'/'||G_ERROR_FILE_NAME;

    developer_debug(' Log file location --> '||l_log_output_dir||'/'||G_ERROR_FILE_NAME ||' created with status '|| l_log_return_status);

    IF (l_log_return_status <> G_RET_STS_SUCCESS) THEN
       developer_debug('Unable to open error log file. Error => '||l_errbuff);
    END IF;

  END IF;--IF c_get_utl_file_dir%FOUND THEN
  -- Bug : 4099546
  CLOSE c_get_utl_file_dir;
END open_debug_session_internal;


 -----------------------------------------------------------
 -- Open the Debug Session, conditionally if the profile: --
 -- INV Debug Trace is set to TRUE                        --
 -----------------------------------------------------------
PROCEDURE Open_Debug_Session
(  p_debug IN VARCHAR2 := NULL
,  p_output_dir IN VARCHAR2 := NULL
,  p_file_name  IN VARCHAR2 := NULL
)
IS

BEGIN
  ----------------------------------------------------------------
  -- Open the Debug Log Session, only if Profile is set to TRUE --
  ----------------------------------------------------------------
  IF (G_DEBUG = 1 OR FND_API.to_Boolean(p_debug)) THEN


     G_OUTPUT_DIR := p_output_dir ;
     G_ERROR_FILE_NAME := p_file_name ;
     ----------------------------------------------------------------------------------
     -- Opens Error_Handler debug session, only if Debug session is not already open.
     -- Suggested by RFAROOK, so that multiple debug sessions are not open PER
     -- Concurrent Request.
     ----------------------------------------------------------------------------------
     IF (Error_Handler.Get_Debug <> 'Y') THEN
       Open_Debug_Session_Internal;
     END IF;

  END IF;

END Open_Debug_Session;

 -----------------------------------------------------------------
 -- Close the Debug Session, only if Debug is already Turned ON --
 -----------------------------------------------------------------
PROCEDURE Close_Debug_Session IS

BEGIN
   -----------------------------------------------------------------------------
   -- Close Error_Handler debug session, only if Debug session is already open.
   -----------------------------------------------------------------------------
   IF (Error_Handler.Get_Debug = 'Y') THEN
     Error_Handler.Close_Debug_Session;
   END IF;

END Close_Debug_Session;


procedure GetNLSLanguage(language  out nocopy varchar2,
                         territory out nocopy varchar2,
                         charset   out nocopy varchar2)
is
  tmpbuf  varchar2(240);
  pos1    number;        -- position for '_'
  pos2    number;        -- position for '.'
begin
  if (G_NLS_LANGUAGE is null) then
    tmpbuf := userenv('LANGUAGE');
    pos1 := instr(tmpbuf, '_');
    pos2 := instr(tmpbuf, '.');

    G_NLS_LANGUAGE  := substr(tmpbuf, 1, pos1-1);
    G_NLS_TERRITORY := substr(tmpbuf, pos1+1, pos2-pos1-1);
    G_NLS_CHARSET   := substr(tmpbuf, pos2+1);
  end if;

  GetNLSLanguage.language  := G_NLS_LANGUAGE;
  GetNLSLanguage.territory := G_NLS_TERRITORY;
  GetNLSLanguage.charset   := G_NLS_CHARSET;
end GetNLSLanguage;


--
-- GetSessionLanguage (PRIVATE)
--   Try to return the cached session language value.
--   If it is not cached yet, call the real query function.
--
function GetSessionLanguage
return varchar2
is
  l_lang  varchar2(64);
  l_terr  varchar2(64);
  l_chrs  varchar2(64);
begin
  if (G_NLS_LANGUAGE is not null) then
    return G_NLS_LANGUAGE;
  end if;

  GetNLSLanguage(l_lang, l_terr, l_chrs);
  return l_lang;

end GetSessionLanguage;


--
-- SetNLSLanguage (PRIVATE)
--   Set the NLS Lanugage setting of current session
--
procedure SetNLSLanguage(p_language  in varchar2,
                         p_territory in varchar2)
is
   l_language varchar2(30);
   l_territory varchar2(30);
begin
  if (p_language = G_NLS_LANGUAGE) then
     return;
  end if;

  l_language := ''''||p_language||'''';
  l_territory := ''''||p_territory||'''';

  DBMS_SESSION.SET_NLS('NLS_LANGUAGE', l_language);
  DBMS_SESSION.SET_NLS('NLS_TERRITORY', l_territory);

  -- update cache
  G_NLS_LANGUAGE := p_language;
  G_NLS_TERRITORY := p_territory;
end SetNLSLanguage;


 -----------------------------------------------------------------
 -- Get Change Id                                               --
 -----------------------------------------------------------------
FUNCTION GetChangeId (p_change_line_id     IN  NUMBER)
RETURN NUMBER
IS

  l_change_id NUMBER;

  CURSOR C (c_change_line_id IN NUMBER)
  IS
    SELECT change_id
    FROM  ENG_REVISED_ITEMS
    WHERE revised_item_sequence_id = c_change_line_id ;



BEGIN


  open c (p_change_line_id);
  fetch c into l_change_id;
  close c;


  IF l_change_id IS NULL
  THEN

    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'GetChangeId:'|| 'no change Id');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

  END IF ;

  RETURN l_change_id ;

END GetChangeId;


 -----------------------------------------------------------------
 -- Get Item Number                                             --
 -----------------------------------------------------------------
FUNCTION GetItemNumber
(  p_inventory_item_id       IN  NUMBER
,  p_organization_id         IN  NUMBER
) RETURN VARCHAR2
IS

    CURSOR c_item_info (c_inventory_item_id         NUMBER ,
                        c_organization_id           NUMBER )
    IS
          SELECT item.concatenated_segments item_name
          FROM   MTL_SYSTEM_ITEMS_KFV item
          WHERE item.organization_id  = c_organization_id
          AND   item.inventory_item_id = c_inventory_item_id ;


    l_item_name   MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;


BEGIN


    FOR item_rec IN c_item_info ( c_inventory_item_id  => p_inventory_item_id
                                , c_organization_id => p_organization_id)
    LOOP

         l_item_name :=  item_rec.item_name ;

    END LOOP ;

    return l_item_name ;

END GetItemNumber ;


 -----------------------------------------------------------------
 -- Get_Object_Id_From_Name                                     --
 -----------------------------------------------------------------

FUNCTION Get_Object_Id_From_Name (
        p_object_name                   IN   VARCHAR2
)
RETURN NUMBER
IS
    l_object_name_table_index NUMBER;
    l_object_id              NUMBER;

BEGIN

Write_Debug('In Get_Object_Id_From_Name, starting for p_object_name '||p_object_name);

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

      SELECT OBJECT_ID INTO l_object_id
        FROM FND_OBJECTS
       WHERE OBJ_NAME = p_object_name;

      G_OBJECT_NAME_TO_ID_CACHE(l_object_id) := p_object_name;

    END IF;

Write_Debug('In Get_Object_Id_From_Name, done: returning l_object_id as '||l_object_id);

    RETURN l_object_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Object_Id_From_Name;

 -----------------------------------------------------------------
 -- Get_Table_Columns_List                                     --
 -----------------------------------------------------------------
-- Copied from EGO_USER_ATTRS_DATA_PVT
-- Need to ask Ext Team to make this global

 	 -- As a part of the Bug 8939021, Removed the hint BYPASS_UJVC.
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
       ,p_exclude_dff                   IN   BOOLEAN    DEFAULT FALSE
)
RETURN VARCHAR2
IS

    l_dynamic_sql            VARCHAR2(20000);
    l_table_column_names_list VARCHAR2(32767);
    l_in_update_mode         BOOLEAN;
    l_update_expression      VARCHAR2(32767);
    l_column_name            VARCHAR2(30);
    l_column_type            VARCHAR2(1);
    l_exclude_table_name    VARCHAR(30);

    TYPE DYNAMIC_CUR IS REF CURSOR;
    l_dynamic_cursor         DYNAMIC_CUR;
    l_skip_common_b_tl_cols  VARCHAR2(32767);

  BEGIN
    -------------------------------------------------------------------
    -- Build a query to fetch names of all columns we want to append --
    -------------------------------------------------------------------
    l_skip_common_b_tl_cols := '''INVENTORY_ITEM_ID'', ''ORGANIZATION_ID'', ''REVISION_ID'', ''LAST_UPDATED_BY'', ''CREATED_BY'' , ''CREATION_DATE'', ''LAST_UPDATE_LOGIN'' , ''LAST_UPDATE_DATE'' ,''ITEM_CATALOG_GROUP_ID'', ''ATTR_GROUP_ID''';
    l_dynamic_sql := ' SELECT C.COLUMN_NAME, C.COLUMN_TYPE' ||
                       ' FROM FND_COLUMNS C, FND_TABLES T' ||
                      ' WHERE T.TABLE_NAME = :1'||
                        ' AND T.APPLICATION_ID = :2'||
                        ' AND C.APPLICATION_ID = T.APPLICATION_ID'||
                        ' AND C.TABLE_ID = T.TABLE_ID';

    IF (p_from_cols_to_exclude_list IS NOT NULL) THEN
      l_dynamic_sql := l_dynamic_sql||' AND C.COLUMN_NAME NOT IN ('||
                       p_from_cols_to_exclude_list||')';

    END IF;

    IF (SUBSTR(p_from_table_name,LENGTH(p_from_table_name)-1)='_B') THEN
      l_exclude_table_name := SUBSTR(p_from_table_name,0,LENGTH(p_from_table_name)-1)||'TL';

      l_dynamic_sql := l_dynamic_sql||' AND C.COLUMN_NAME NOT IN ('||
                                  ' SELECT C_TL.COLUMN_NAME ' ||
                       ' FROM FND_COLUMNS C_TL, FND_TABLES T_TL' ||
                      ' WHERE T_TL.TABLE_NAME = '''|| l_exclude_table_name ||''''||
                        ' AND C_TL.APPLICATION_ID = T_TL.APPLICATION_ID'||
                        ' AND T_TL.APPLICATION_ID = T.APPLICATION_ID ' ||
                        ' AND C_TL.TABLE_ID = T_TL.TABLE_ID' ||
                        ' AND C_TL.COLUMN_NAME NOT IN ('||l_skip_common_b_tl_cols || '))';

    END IF;

    IF (p_exclude_dff) THEN
      l_dynamic_sql := l_dynamic_sql||' AND C.COLUMN_NAME NOT LIKE ''ATTRIBUTE%'' ';
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
    OPEN l_dynamic_cursor FOR l_dynamic_sql USING p_from_table_name, p_application_id;
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

    /*Added below for bug 8939021. Commented the below update statement*/

    --IF (l_in_update_mode) THEN
     -- l_table_column_names_list := 'UPDATE /*+ BYPASS_UJVC */ (SELECT '||l_table_column_names_list||
      --                             ' FROM '||p_from_table_name||' '||p_from_table_alias_prefix||
       --                            ','||p_to_table_name||' '||p_to_table_alias_prefix||' '||
        --                           p_in_line_view_where_clause||') SET '||l_update_expression;
   -- END IF;
    RETURN l_table_column_names_list;

END Get_Table_Columns_List;



PROCEDURE Build_Attr_Metadata_Table
(  p_application_id               IN NUMBER
,  p_attr_group_type              IN VARCHAR2
,  p_attr_group_name              IN VARCHAR2 DEFAULT NULL
,  x_attr_metadata_table          OUT NOCOPY EGO_ATTR_METADATA_TABLE
) IS

    l_attr_metadata_table    EGO_ATTR_METADATA_TABLE := EGO_ATTR_METADATA_TABLE();
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;
    l_sql_query              LONG;

    CURSOR attrs_cursor (
        cp_application_id               IN   NUMBER
       ,cp_attr_group_type              IN   VARCHAR2
       ,cp_attr_group_name              IN   VARCHAR2
    ) IS
    SELECT EXT.ATTR_ID,
           FLX_EXT.ATTR_GROUP_ID,
           FLX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE ATTR_GROUP_NAME,
           A.END_USER_COLUMN_NAME,
           TL.FORM_LEFT_PROMPT,
           EXT.DATA_TYPE,
           FC.MEANING                   DATA_TYPE_MEANING,
           A.COLUMN_SEQ_NUM,
           EXT.UNIQUE_KEY_FLAG,
           A.DEFAULT_VALUE,
           EXT.INFO_1,
           VS.MAXIMUM_SIZE,
           A.REQUIRED_FLAG,
           A.APPLICATION_COLUMN_NAME,
           VS.FLEX_VALUE_SET_ID,
           VS.VALIDATION_TYPE,
           VS.MINIMUM_VALUE,
           VS.MAXIMUM_VALUE,
           EXT.UOM_CLASS,
           UOM.UOM_CODE,
           EXT.VIEW_IN_HIERARCHY_CODE,
           EXT.EDIT_IN_HIERARCHY_CODE
      FROM EGO_FND_DSC_FLX_CTX_EXT      FLX_EXT,
           FND_DESCR_FLEX_COLUMN_USAGES A,
           FND_DESCR_FLEX_COL_USAGE_TL  TL,
           EGO_FND_DF_COL_USGS_EXT      EXT,
           EGO_VS_FORMAT_CODES_V        FC,
           FND_FLEX_VALUE_SETS          VS,
           MTL_UNITS_OF_MEASURE         UOM
     WHERE FLX_EXT.APPLICATION_ID = cp_application_id
       AND FLX_EXT.DESCRIPTIVE_FLEXFIELD_NAME = cp_attr_group_type
       AND ( FLX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = cp_attr_group_name
             OR cp_attr_group_name IS NULL )
       AND A.APPLICATION_ID = cp_application_id
       AND A.DESCRIPTIVE_FLEXFIELD_NAME = cp_attr_group_type
       AND ( A.DESCRIPTIVE_FLEX_CONTEXT_CODE = cp_attr_group_name
             OR cp_attr_group_name IS NULL )
       AND TL.APPLICATION_ID = cp_application_id
       AND TL.DESCRIPTIVE_FLEXFIELD_NAME = cp_attr_group_type
       AND ( TL.DESCRIPTIVE_FLEX_CONTEXT_CODE = cp_attr_group_name
             OR cp_attr_group_name IS NULL )
       AND EXT.APPLICATION_ID = cp_application_id
       AND EXT.DESCRIPTIVE_FLEXFIELD_NAME = cp_attr_group_type
       AND ( EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE  = cp_attr_group_name
             OR cp_attr_group_name IS NULL )
       AND FC.LOOKUP_CODE(+) = EXT.DATA_TYPE
       AND A.ENABLED_FLAG = 'Y'
       AND TL.APPLICATION_COLUMN_NAME = A.APPLICATION_COLUMN_NAME
       AND TL.LANGUAGE = USERENV('LANG')
       AND EXT.APPLICATION_COLUMN_NAME = A.APPLICATION_COLUMN_NAME
       AND A.FLEX_VALUE_SET_ID = VS.FLEX_VALUE_SET_ID (+)
       AND UOM.UOM_CLASS(+) = EXT.UOM_CLASS
       AND UOM.BASE_UOM_FLAG(+) = 'Y'
       ORDER BY A.COLUMN_SEQ_NUM;

  BEGIN


Write_Debug('Build_Attr_Metadata_Table . ..  '  );
Write_Debug('-----------------------------------' );
Write_Debug('p_application_id: '  || to_char(p_application_id));
Write_Debug('p_attr_group_type:'  || p_attr_group_type);
Write_Debug('p_attr_group_name:'  || p_attr_group_name);
Write_Debug('-----------------------------------' );

    ----------------------------------------------------------------------------
    -- The SORT_ATTR_VALUES_FLAG flag records whether any Attributes in this  --
    -- collection have a Value Set of type "Table"; if so, we will need to    --
    -- sort the Attr values when we process a row in order to ensure that any --
    -- bind values needed by the Value Set are converted before the Value Set --
    -- is processed                                                           --
    ----------------------------------------------------------------------------

    -------------------------------------------------------
    -- The UNIQUE_KEY_ATTRS_COUNT records how many Attrs --
    -- in this Attribute Group are part of a Unique Key  --
    -------------------------------------------------------

    --------------------------------------------------------------------
    -- The TRANS_ATTRS_COUNT records how many translatable Attributes --
    -- this Attribute Group has; it will be used in Update_Row        --
    --------------------------------------------------------------------

    FOR attrs_rec IN attrs_cursor(p_application_id
                                 ,p_attr_group_type
                                 ,p_attr_group_name)
    LOOP
      l_attr_metadata_obj := EGO_ATTR_METADATA_OBJ(
                               attrs_rec.ATTR_ID
                              ,attrs_rec.ATTR_GROUP_ID
                              ,attrs_rec.ATTR_GROUP_NAME
                              ,attrs_rec.END_USER_COLUMN_NAME
                              ,attrs_rec.FORM_LEFT_PROMPT
                              ,attrs_rec.DATA_TYPE
                              ,attrs_rec.DATA_TYPE_MEANING
                              ,attrs_rec.COLUMN_SEQ_NUM
                              ,attrs_rec.UNIQUE_KEY_FLAG
                              ,attrs_rec.DEFAULT_VALUE
                              ,attrs_rec.INFO_1
                              ,attrs_rec.MAXIMUM_SIZE
                              ,attrs_rec.REQUIRED_FLAG
                              ,attrs_rec.APPLICATION_COLUMN_NAME
                              ,attrs_rec.FLEX_VALUE_SET_ID
                              ,attrs_rec.VALIDATION_TYPE
                              ,attrs_rec.MINIMUM_VALUE
                              ,attrs_rec.MAXIMUM_VALUE
                              ,attrs_rec.UOM_CLASS
                              ,attrs_rec.UOM_CODE
                              ,null -- DISP_TO_INT_VAL_QUERY
                              ,null -- INT_TO_DISP_VAL_QUERY
                              ,'N'
                              ,attrs_rec.VIEW_IN_HIERARCHY_CODE
                              ,attrs_rec.EDIT_IN_HIERARCHY_CODE
                              );

      /*
      IF (attrs_rec.UNIQUE_KEY_FLAG = 'Y') THEN

        px_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT :=
          px_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT + 1;

      END IF;

      IF (attrs_rec.DATA_TYPE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

          px_attr_group_metadata_obj.TRANS_ATTRS_COUNT :=
          px_attr_group_metadata_obj.TRANS_ATTRS_COUNT + 1;

      END IF;


      IF (attrs_rec.VALIDATION_TYPE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE OR
          attrs_rec.VALIDATION_TYPE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE) THEN

        -----------------------------------------------------------------
        -- If this Attribute has a Value Set with Internal and Display --
        -- Values, we build SQL to transform one into the other (and   --
        -- if the Value Set is of type "Table", we set the sort flag   --
        -- in our Attribute Group metadata object to 'Y')              --
        -----------------------------------------------------------------

        Build_Sql_Queries_For_Value(attrs_rec.FLEX_VALUE_SET_ID
                                   ,attrs_rec.VALIDATION_TYPE
                                   ,px_attr_group_metadata_obj
                                   ,l_attr_metadata_obj);
      END IF;

      ------------------------------------------------------------------
      -- For hierarchy security, we need to keep track of whether any --
      -- of the attributes requires propagation (EIH code of LP/AP)   --
            -- for leaf/all propagation                                     --
      ------------------------------------------------------------------
      IF (attrs_rec.EDIT_IN_HIERARCHY_CODE = 'LP' OR
                attrs_rec.EDIT_IN_HIERARCHY_CODE = 'AP') THEN

        px_attr_group_metadata_obj.HIERARCHY_PROPAGATE_FLAG := 'Y';
        EGO_USER_ATTRS_DATA_PVT.
        -- DEBUG_MSG('In Build_Attr_Metadata_Table, found LP/AP: '||px_attr_group_metadata_obj.ATTR_GROUP_NAME||' '||attrs_rec.ATTR_ID, 2);

      END IF;
      */

      l_attr_metadata_table.EXTEND();
      l_attr_metadata_table(l_attr_metadata_table.LAST) := l_attr_metadata_obj;

    END LOOP;

    x_attr_metadata_table := l_attr_metadata_table ;

END Build_Attr_Metadata_Table;


 -----------------------------------------------------------------
 -- Check if Item Attr Change exists                           --
 -----------------------------------------------------------------
FUNCTION CheckItemAttrChange (p_change_line_id     IN  NUMBER)
RETURN BOOLEAN
IS

  l_change_line_id NUMBER;

  CURSOR C IS
    SELECT change_line_id
    FROM  EGO_MTL_SY_ITEMS_CHG_VL
    WHERE change_line_id = p_change_line_id
    AND   implementation_date IS NULL
    AND   acd_type <> 'HISTORY'
    AND   rownum = 1;

BEGIN

  open c;
  fetch c into l_change_line_id;
  if (c%notfound) then
    close c;
    RETURN FALSE;
  end if;
  close c;
  RETURN TRUE ;

END CheckItemAttrChange ;



 -----------------------------------------------------------------
 -- Check if Item User Attr Change exists                       --
 -----------------------------------------------------------------
FUNCTION CheckItemUserAttrChange (p_change_line_id     IN  NUMBER)
RETURN BOOLEAN
IS

  l_change_line_id NUMBER;

  CURSOR C IS
    SELECT change_line_id
    FROM  EGO_ITEMS_ATTRS_CHANGES_VL
    WHERE change_line_id = p_change_line_id
    AND   implementation_date IS NULL
    AND   acd_type <> 'HISTORY'
    AND   rownum = 1;

BEGIN

  open c;
  fetch c into l_change_line_id;
  if (c%notfound) then
    close c;
    RETURN FALSE;
  end if;
  close c;
  RETURN TRUE ;

END CheckItemUserAttrChange ;



 -----------------------------------------------------------------
 -- Check if Item GDSN Attr Change exists                       --
 -----------------------------------------------------------------
FUNCTION CheckItemGDSNAttrChange (p_change_line_id       IN  NUMBER
                                 ,p_gdsn_attr_group_type IN VARCHAR2 := NULL
                                 )
RETURN BOOLEAN
IS

  l_change_line_id NUMBER;

  CURSOR C IS
    SELECT change_line_id
    FROM  EGO_GTN_ATTR_CHG_VL
    WHERE change_line_id = p_change_line_id
    AND   implementation_date IS NULL
    AND   acd_type <> 'HISTORY'
    AND   rownum = 1;


  CURSOR C2 IS
    SELECT change_line_id
    FROM  EGO_GTN_MUL_ATTR_CHG_VL
    WHERE change_line_id = p_change_line_id
    AND   implementation_date IS NULL
    AND   acd_type <> 'HISTORY'
    AND   rownum = 1;


BEGIN

  IF ( p_gdsn_attr_group_type IS NULL OR
       p_gdsn_attr_group_type = G_EGO_ITEM_GTIN_ATTRS )
  THEN
        -- Check Single Row GDSN Attr Change
        open c;
        fetch c into l_change_line_id;
        if (c%found) then
          close c;
          RETURN TRUE ;
        end if;
        close c;

  END IF ;

  IF ( p_gdsn_attr_group_type IS NULL OR
       p_gdsn_attr_group_type = G_EGO_ITEM_GTIN_MULTI_ATTRS )
  THEN

      -- Check Multi Row GDSN Attr Change
      open c2;
      fetch c2 into l_change_line_id;
      if (c2%found) then
        close c2;
        RETURN TRUE ;
      end if;
      close c2;

  END IF ;


  RETURN FALSE ;

END CheckItemGDSNAttrChange ;


 -----------------------------------------------------------------
 -- Check if Item Mfg Part Num Change exists                    --
 -----------------------------------------------------------------
FUNCTION CheckItemMfgPartNumChange (p_change_line_id     IN  NUMBER)
RETURN BOOLEAN
IS

  l_change_line_id NUMBER;

  CURSOR C IS
    SELECT change_line_id
    FROM   EGO_MFG_PART_NUM_CHGS
    WHERE change_line_id = p_change_line_id
    AND   implmentation_date IS NULL  -- Spell Miss implementation
    AND   acd_type <> 'HISTORY'
    AND   rownum = 1;

BEGIN

  open c;
  fetch c into l_change_line_id;
  if (c%notfound) then
    close c;
    RETURN FALSE;
  end if;
  close c;
  RETURN TRUE ;

END CheckItemMfgPartNumChange ;


 -----------------------------------------------------------------
 -- Get Ext Id for Item GDSN Attr Production                    --
 -----------------------------------------------------------------
FUNCTION Get_Ext_Id_For_GDSN_Single_Row ( p_inventory_item_id  IN  NUMBER
                                        , p_organization_id    IN  NUMBER )
RETURN NUMBER
IS

  l_ext_id NUMBER ;

  CURSOR C IS
    SELECT extension_id
    FROM  EGO_ITEM_GTN_ATTRS_B
    WHERE inventory_item_id = p_inventory_item_id
    AND   organization_id =  p_organization_id
    AND   revision_id IS NULL ;

BEGIN

  open c;
  fetch c into l_ext_id;
  close c;
  RETURN l_ext_id ;

END Get_Ext_Id_For_GDSN_Single_Row ;



PROCEDURE impl_item_changes
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER
)
IS
    l_api_name      CONSTANT VARCHAR2(30) := 'IMPL_ITEM_CHANGES';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list        VARCHAR2(1) ;
    l_validation_level     NUMBER ;
    l_commit               VARCHAR2(1) ;
    l_write_msg_to_intftbl VARCHAR2(1) ;


    l_msg_data       VARCHAR2(4000);
    l_msg_count      NUMBER;
    l_return_status  VARCHAR2(1);
    l_error_msg      VARCHAR2(2000) ;

    l_change_id         NUMBER ;
    l_change_line_id    NUMBER ;

    l_found          BOOLEAN ;

    CURSOR getChangeLines (c_change_id      NUMBER
                          ,c_change_line_id NUMBER)
    IS
        SELECT revised_item_sequence_id
        FROM eng_revised_items
        WHERE  change_id = c_change_id
        AND   ( revised_item_sequence_id = c_change_line_id
                OR c_change_line_id IS NULL )
        AND implementation_date IS NULL
        ORDER BY scheduled_date ;


BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;


    IF FND_API.To_Boolean( l_commit ) THEN
       SAVEPOINT IMPL_ITEM_CHANGES;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_change_id: '  || to_char(p_change_id));
Write_Debug('p_change_line_id: '  || to_char(p_change_line_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;
    l_change_id := p_change_id ;
    l_change_line_id := p_change_line_id ;

    -- API body
    -- Logic Here
    -- Init Local Vars

    IF ( l_change_id IS NULL OR l_change_id <= 0 ) AND
       ( l_change_line_id IS NULL OR  l_change_line_id <= 0 )
    THEN
        return ;
    END IF ;


    IF ( l_change_id IS NULL OR  l_change_id <= 0 )
    THEN
        l_change_id := GetChangeId(p_change_line_id => l_change_line_id) ;

Write_Debug('Got Change Id: '  || to_char(l_change_id));

    END IF ;



    FOR revised_line_rec IN getChangeLines(l_change_id, l_change_line_id)
    LOOP
        l_change_line_id := revised_line_rec.revised_item_sequence_id;


Write_Debug('Calling impl_rev_item_user_attr_chgs for Rev Item: '  || to_char(l_change_line_id));

        impl_rev_item_user_attr_chgs
        (
          p_api_version            => 1.0
         ,p_commit                 => FND_API.G_FALSE
         ,x_return_status          => l_return_status
         ,x_msg_count              => l_msg_count
         ,x_msg_data               => l_msg_data
         ,p_change_id              => l_change_id
         ,p_change_line_id         => l_change_line_id
        ) ;


Write_Debug('After Calling impl_rev_item_user_attr_chgs, Return Status: '  || l_return_status);


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN

            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_user_attr_chgs');
            FND_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;

        END IF;



Write_Debug('Calling impl_rev_item_attr_changes for Rev Item: '  || to_char(l_change_line_id));


        impl_rev_item_attr_changes
        (
          p_api_version            => 1.0
         ,p_commit                 => FND_API.G_FALSE
         ,x_return_status          => l_return_status
         ,x_msg_count              => l_msg_count
         ,x_msg_data               => l_msg_data
         ,p_change_id              => l_change_id
         ,p_change_line_id         => l_change_line_id
        ) ;


Write_Debug('After Calling impl_rev_item_attr_changes, Return Status: '  || l_return_status);



        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN

            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            RAISE FND_API.G_EXC_ERROR;

        END IF;

        impl_rev_item_gdsn_attr_chgs
        (
          p_api_version            => 1.0
         ,p_commit                 => FND_API.G_FALSE
         ,x_return_status          => l_return_status
         ,x_msg_count              => l_msg_count
         ,x_msg_data               => l_msg_data
         ,p_change_id              => l_change_id
         ,p_change_line_id         => l_change_line_id
        ) ;


Write_Debug('After Calling impl_rev_item_gdsn_attr_chgs, Return Status: '  || l_return_status);


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN

            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_gdsn_attr_chgs');
            FND_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;

        END IF;



Write_Debug('Calling impl_rev_item_aml_changes for Rev Item: '  || to_char(l_change_line_id));

        impl_rev_item_aml_changes
        (
          p_api_version            => 1.0
         ,p_commit                 => FND_API.G_FALSE
         ,x_return_status          => l_return_status
         ,x_msg_count              => l_msg_count
         ,x_msg_data               => l_msg_data
         ,p_change_id              => l_change_id
         ,p_change_line_id         => l_change_line_id
        ) ;


Write_Debug('After calling impl_rev_item_aml_changes, Return Status: '  || l_return_status);


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN

            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;

            FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_aml_changes');
            FND_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;

        END IF;


    END LOOP ; -- revised_line_rec LOOP

    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( l_commit ) THEN

Write_Debug('Commit impl_item_changes. . . ' );

       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP

Write_Debug('Dumping Message number : '|| I );
Write_Debug('DATA = '||replace(substr(FND_MSG_PUB.Get(I), 1, 200), chr(0), ' '));

    END LOOP;


Write_Debug('End of impl_item_changes . . . ' );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
Write_Debug('When G_EXC_ERROR Exception in impl_item_changes');

    x_return_status := G_RET_STS_ERROR ;


    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK Impl Item Changes to IMPL_ITEM_CHANGES. . ');
       ROLLBACK TO IMPL_ITEM_CHANGES;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );




    FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP

Write_Debug('Dumping Message number : '|| I );
Write_Debug('DATA = '||replace(substr(FND_MSG_PUB.Get(I), 1, 200), chr(0), ' '));

    END LOOP;


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

Write_Debug('When G_EXC_UNEXPECTED_ERROR Exception in impl_item_changes');
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK Impl Item Changes to IMPL_ITEM_CHANGES. . ');
       ROLLBACK TO IMPL_ITEM_CHANGES;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP

Write_Debug('Dumping Message number : '|| I );
Write_Debug('DATA = '||replace(substr(FND_MSG_PUB.Get(I), 1, 200), chr(0), ' '));

    END LOOP;

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN OTHERS THEN
Write_Debug('When OTHERS Exception in impl_item_changes');
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK Impl Item Changes to IMPL_ITEM_CHANGES. . ');
       ROLLBACK TO IMPL_ITEM_CHANGES;
    END IF;

Write_Debug('When Others Exception ' || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));

    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_item_changes for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;


    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP

Write_Debug('Dumping Message number : '|| I );
Write_Debug('DATA = '||replace(substr(FND_MSG_PUB.Get(I), 1, 200), chr(0), ' '));

    END LOOP;


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

END impl_item_changes;


FUNCTION Get_Process_Item_Param(p_db_col_name IN VARCHAR2)
RETURN VARCHAR2
IS
    l_param_name VARCHAR2(31) ;

BEGIN

    IF (p_db_col_name = 'ENFORCE_SHIP_TO_LOCATION_CODE' )
    THEN

      l_param_name := 'P_' || SUBSTR(p_db_col_name, 1, 26)  ;

    ELSIF (p_db_col_name = 'PROCESS_EXECUTION_ENABLED_FLAG' )
    THEN

      l_param_name := 'P_' || SUBSTR(p_db_col_name, 1, 28)  ;

    --added this for bug 5177385
    ELSIF (p_db_col_name = 'RESTRICT_SUBINVENTORIES_CODE'  OR  p_db_col_name = 'SERVICE_DURATION_PERIOD_CODE' )
    THEN

      l_param_name := 'P_' || SUBSTR(p_db_col_name, 1, 27)  ;

    ELSIF (LENGTH(p_db_col_name) >= 29)
    THEN

      l_param_name := 'P_' || SUBSTR(p_db_col_name, 1, 27)  ;

    ELSE
      l_param_name := 'P_' || p_db_col_name ;

    END IF ;


    RETURN l_param_name ;

END Get_Process_Item_Param ;


PROCEDURE impl_rev_item_attr_changes
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER
)
IS

    l_api_name      CONSTANT VARCHAR2(30) := 'IMPL_REV_ITEM_ATTR_CHGS';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;

    l_msg_data         VARCHAR2(4000);
    l_msg_count        NUMBER;
    l_return_status    VARCHAR2(1);
    l_message_list     Error_Handler.Error_Tbl_Type ;
    l_msg_index        NUMBER ;

    l_found            BOOLEAN ;

    l_change_id        NUMBER;
    l_change_line_id   NUMBER;

    l_dummy_c          NUMBER;
    l_dummy_r          NUMBER;
    l_object_id              NUMBER;


    l_production_b_table_name      VARCHAR2(30);
    l_production_tl_table_name     VARCHAR2(30);
    l_production_vl_name           VARCHAR2(30);
    l_change_b_table_name          VARCHAR2(30);
    l_change_tl_table_name         VARCHAR2(30);

    l_cols_to_exclude_list         VARCHAR2(2000);
    l_chg_col_names_list          VARCHAR2(32767);
    l_b_chg_cols_list             VARCHAR2(32767);
    l_tl_chg_cols_list            VARCHAR2(10000);
    l_history_b_chg_cols_list     VARCHAR2(32767);
    l_history_tl_chg_cols_list    VARCHAR2(10000);
    l_history_b_prod_cols_list     VARCHAR2(32767);
    l_history_tl_prod_cols_list    VARCHAR2(10000);

    l_dynamic_sql            VARCHAR2(32767); --the largest a VARCHAR2 can be
    l_utility_dynamic_sql    VARCHAR2(32767); --the largest a VARCHAR2 can be
    l_cursor_id              NUMBER;
    l_column_count           NUMBER;
    l_dummy                  NUMBER;
    l_desc_table             DBMS_SQL.Desc_Tab;
    l_retrieved_value        VARCHAR2(1000);
    l_current_column_index   NUMBER;

    l_inventory_item_id      NUMBER ;
    l_organization_id        NUMBER ;
    l_item_number            MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
    l_item_desc              MTL_SYSTEM_ITEMS_KFV.DESCRIPTION%TYPE;
    l_out_inventory_item_id  NUMBER ;
    l_out_organization_id    NUMBER ;
    l_process_control        VARCHAR2(30) ;
    l_process_item           NUMBER ;

    -- l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_attr_name_value_pairs  EGO_USER_ATTR_DATA_TABLE := EGO_USER_ATTR_DATA_TABLE();
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;

    l_mode_for_current_row    VARCHAR2(10);
    l_current_acd_type        VARCHAR2(30);
    l_current_row_language    VARCHAR2(30);
    l_current_row_source_lang VARCHAR2(30);
    l_current_column_name     VARCHAR2(30);
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_attr_metadata_table     EGO_ATTR_METADATA_TABLE  := EGO_ATTR_METADATA_TABLE() ;

    l_num_value               NUMBER ;
    l_char_value              VARCHAR2(1000) ;
    l_date_value              DATE ;
    l_date_value_char         VARCHAR2(30) ;


    -- l_uom_column_nv_pairs    LOCAL_COL_NV_PAIR_TABLE;
    -- l_uom_nv_pairs_index     NUMBER := 0;
    -- l_data_level_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    -- l_current_dl_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    -- l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    -- l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    -- l_dummy_err_msg_name     VARCHAR2(30);
    -- l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    -- l_current_uom_col_nv_obj EGO_COL_NAME_VALUE_PAIR_OBJ;
    -- l_attr_col_name_for_uom_col VARCHAR2(30);

BEGIN

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;

    IF FND_API.To_Boolean( l_commit ) THEN
       -- Standard Start of API savepoint
       SAVEPOINT IMPL_REV_ITEM_ATTR_CHGS;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_change_id: '  || to_char(p_change_id));
Write_Debug('p_change_line_id: '  || to_char(p_change_line_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    -- API body
    -- Logic Here
    -- Init Local Vars


    l_change_id := p_change_id;
    l_change_line_id := p_change_line_id;

    IF ( l_change_id IS NULL OR l_change_id <= 0 )
    THEN
        l_change_id := GetChangeId(p_change_line_id => l_change_line_id) ;

Write_Debug('Got Change Id: '  || to_char(l_change_id));

    END IF ;


Write_Debug('Check Item Attr Change exists for Rev Item: '  || to_char(l_change_line_id));

    l_found :=  CheckItemAttrChange(p_change_line_id => l_change_line_id) ;
    IF NOT l_found THEN

Write_Debug('Item Attr Change not found for '  || to_char(l_change_line_id));
       RETURN ;

    END IF ;

    -----------------------------------------------
    -- First, we get the Object ID for our calls --
    -----------------------------------------------
    l_object_id := Get_Object_Id_From_Name(G_EGO_ITEM);



    -- So far TL and VL are not registerd.
    -- We will use this in future
    -----------------------------------------------
    --We get the meta data for Object ID for our calls --
    -----------------------------------------------
     SELECT EXT_TABLE_NAME, EXT_TL_TABLE_NAME, EXT_VL_NAME
       INTO l_production_b_table_name, l_production_tl_table_name, l_production_vl_name
       FROM EGO_ATTR_GROUP_TYPES_V
      WHERE APPLICATION_ID =  G_EGO_APPL_ID
        AND ATTR_GROUP_TYPE = G_EGO_MASTER_ITEMS ;



    -- MK Need to get from Change Context
    l_change_b_table_name          := 'EGO_MTL_SY_ITEMS_CHG_B' ;
    l_change_tl_table_name         := 'EGO_MTL_SY_ITEMS_CHG_TL' ;
    -- l_production_b_table_name      := 'MTL_SYSTEM_ITEMS_B' ;
    l_production_tl_table_name     := 'MTL_SYSTEM_ITEMS_TL' ;

    ---------------------------------------------------------------
    -- Next, we add to the lists the rest of the columns that we --
    -- either want to get explicitly or don't want to get at all --
    ---------------------------------------------------------------
    l_chg_col_names_list := 'B.INVENTORY_ITEM_ID,B.ORGANIZATION_ID,B.ACD_TYPE,B.ITEM_NUMBER,B.DESCRIPTION';

    l_cols_to_exclude_list := '''INVENTORY_ITEM_ID'',''ORGANIZATION_ID'','||
                              '''ACD_TYPE'',''ATTR_GROUP_ID'',''EXTENSION_ID'','||
                              '''CHANGE_ID'',''CHANGE_LINE_ID'',''IMPLEMENTATION_DATE'','||
                              '''CREATED_BY'',''CREATION_DATE'',''LAST_UPDATED_BY'','||
                              '''LAST_UPDATE_DATE'',''LAST_UPDATE_LOGIN'','||
                              '''PROGRAM_ID'',''PROGRAM_UPDATE_DATE'',''REQUEST_ID'' ,'||
                              '''PROGRAM_APPLICATION_ID'',''EGO_MASTER_ITEMS_DFF_CTX'', '||
                              '''STYLE_ITEM_FLAG'',''STYLE_ITEM_ID'',''GDSN_OUTBOUND_ENABLED_FLAG'','||
                              '''ITEM_NUMBER'',''DESCRIPTION'',''LAST_SUBMITTED_NIR_ID'',''DEFAULT_MATERIAL_STATUS_ID'',''SERIAL_TAGGING_FLAG''' ;
			        /*Added for bug 6764240 the column LAST_SUBMITTED_NIR_ID*/
        			/*Added for bug 7257989 the column DEFAULT_MATERIAL_STATUS_ID*/
                                /* Added for bug#10091510 the column Serial_Tagging_Flag */
    ----------------------------------------------------------
    -- Get lists of columns for the B and TL pending tables --
    -- (i.e., all Attr cols and the language cols from TL)  --
    ----------------------------------------------------------

Write_Debug('Get lists of columns for the Pending Change B '  || l_change_b_table_name );

    l_b_chg_cols_list := Get_Table_Columns_List(
                           -- p_application_id            => G_EGO_APPL_ID
                              p_application_id            => G_ITEM_APPL_ID
                           -- ,p_from_table_name           => l_change_b_table_name
                           -- Need to chagne this later
                           ,p_from_table_name           => l_production_b_table_name
                           ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                           ,p_from_table_alias_prefix   => 'B'
                           ,p_cast_date_cols_to_char    => TRUE
                           ,p_exclude_dff               => TRUE
                          );


Write_Debug('Get lists of columns for the Pending Change TL '  || l_change_tl_table_name );

    l_tl_chg_cols_list := Get_Table_Columns_List(
                           -- p_application_id            => G_EGO_APPL_ID
                              p_application_id            => G_ITEM_APPL_ID
                            -- ,p_from_table_name           => l_change_tl_table_name
                            ,p_from_table_name           => 'MTL_SYSTEM_ITEMS_TL'
                            ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                           ,p_from_table_alias_prefix   => 'TL'
                            ,p_cast_date_cols_to_char    => TRUE
                           );

    --------------------------------------------------------
    -- While we're getting lists of columns, we also get  --
    -- lists for later use in copying old production rows --
    -- into the pending tables as HISTORY rows            --
    --------------------------------------------------------

Write_Debug('Get lists of columns for the Pending Change History B '  || l_change_b_table_name );

    l_history_b_chg_cols_list := Get_Table_Columns_List(
                                   -- p_application_id            => G_EGO_APPL_ID
                                    p_application_id            => G_ITEM_APPL_ID
                                    -- ,p_from_table_name           => l_change_b_table_name
                                    -- Need to chagne this later
                                   ,p_from_table_name           => l_production_b_table_name
                                   ,p_from_table_alias_prefix   => 'CT'
                                   ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                   -- For Now
                                   ,p_exclude_dff               => TRUE
                                  );

Write_Debug('Get lists of columns for the Pending Change History TL '  || l_change_b_table_name );

    l_history_tl_chg_cols_list := Get_Table_Columns_List(
                                   -- p_application_id            => G_EGO_APPL_ID
                                    p_application_id            => G_ITEM_APPL_ID
                                     -- ,p_from_table_name           => l_change_tl_table_name
                                    ,p_from_table_name           => 'MTL_SYSTEM_ITEMS_TL'
                                    ,p_from_table_alias_prefix   => 'CT'
                                    ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                   );


Write_Debug('Get lists of columns for the Production History B '  || l_change_b_table_name );

    l_history_b_prod_cols_list := Get_Table_Columns_List(
                                    p_application_id            => G_ITEM_APPL_ID
                                   ,p_from_table_name           => l_production_b_table_name
                                   ,p_from_table_alias_prefix   => 'PT'
                                   ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                   -- For Now
                                   ,p_exclude_dff               => TRUE
                                  );

Write_Debug('Get lists of columns for the Production History TL '  || l_change_b_table_name );


    l_history_tl_prod_cols_list := Get_Table_Columns_List(
                                         p_application_id            => G_ITEM_APPL_ID
                                        ,p_from_table_name           => l_production_tl_table_name
                                        ,p_from_table_alias_prefix   => 'PT'
                                        ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                       );



Write_Debug('Get Attribute Meta for All Master Item AG . ..  '  );

    -------------------------------------------------
    -- Get Attribute Meta for All Master Item AG --
    -------------------------------------------------
    Build_Attr_Metadata_Table
    (
          p_application_id   => G_EGO_APPL_ID
       ,  p_attr_group_type  => G_EGO_MASTER_ITEMS
       ,  p_attr_group_name  => NULL
       ,  x_attr_metadata_table => l_attr_metadata_table
    ) ;

Write_Debug('After getting Attribute Meta for All Master Item AG . . .  '  );



    -------------------------------------------------
    -- Now we build the SQL for our dynamic cursor --
    -------------------------------------------------

Write_Debug('Now we build the SQL for our dynamic cursor . . .  '  );

    l_dynamic_sql := 'SELECT '||l_chg_col_names_list||','||
                                l_b_chg_cols_list||','||
                                l_tl_chg_cols_list||
                      ' FROM '||l_change_b_table_name ||' B,'||
                                l_change_tl_table_name ||' TL'||
                     ' WHERE B.ACD_TYPE <> ''HISTORY'' AND B.IMPLEMENTATION_DATE IS NULL'||
                       ' AND B.ACD_TYPE = TL.ACD_TYPE'||
                       ' AND B.CHANGE_LINE_ID = TL.CHANGE_LINE_ID'||
                       ' AND TL.LANGUAGE = userenv(''LANG'')'||
                       ' AND B.CHANGE_LINE_ID = :1';



Write_Debug('SQL:' || l_dynamic_sql );


    l_cursor_id := DBMS_SQL.Open_Cursor;
    DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.Native);
    DBMS_SQL.Bind_Variable(l_cursor_id, ':1', l_change_line_id);
    DBMS_SQL.Describe_Columns(l_cursor_id, l_column_count, l_desc_table);


    FOR i IN 1 .. l_column_count
    LOOP

      --
      -- NOTE: ASSUMPTION: no PKs will ever be DATE objects
      --
      -------------------------------------------------------------
      -- We define all columns as VARCHAR2(1000) for convenience --
      -------------------------------------------------------------
      DBMS_SQL.Define_Column(l_cursor_id, i, l_retrieved_value, 1000);
    END LOOP;


Write_Debug('Execute our dynamic query . . .' );


    ----------------------------------
    -- Execute our dynamic query... --
    ----------------------------------
    l_dummy := DBMS_SQL.Execute(l_cursor_id);


Write_Debug('After Executing our dynamic query . . .' );

    ----------------------------------------------------
    -- ...then loop through the result set, gathering
    -- the column values
    ----------------------------------------------------
    WHILE (DBMS_SQL.Fetch_Rows(l_cursor_id) > 0)
    LOOP


Write_Debug('loop through the result set, gathering the column values  . . .' );

      l_current_column_index := 1;
      l_attr_name_value_pairs.DELETE();

      ------------------------------------
      -- Get the PK values for this row --
      ------------------------------------
      --   Item Id
      DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
      l_current_column_index := l_current_column_index + 1;
      -- l_pk_column_name_value_pairs(1).VALUE := SUBSTRB(l_retrieved_value, 1, 150);
      l_inventory_item_id := TO_NUMBER(l_retrieved_value) ;



Write_Debug('Got Item Id ' || to_char(l_inventory_item_id));

      --   Org Id
      DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
      l_current_column_index := l_current_column_index + 1;
      -- l_pk_column_name_value_pairs(2).VALUE := SUBSTRB(l_retrieved_value, 1, 150);
      l_organization_id := TO_NUMBER(l_retrieved_value) ;


Write_Debug('Got Org Id ' || to_char(l_organization_id));

      ----------------------------
      -- Determine the ACD Type --
      ----------------------------
      DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
      l_current_column_index := l_current_column_index + 1;
      l_current_acd_type := l_retrieved_value;

Write_Debug('Got Acd Id ' || l_current_acd_type);

  ----------------------------
      -- Determine the generated Item Number
      ----------------------------
      DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
      l_current_column_index := l_current_column_index + 1;
      l_item_number := l_retrieved_value;

Write_Debug('Got Item Number ' || l_item_number);

      ----------------------------
      -- Determine the generated Item Number
      ----------------------------
      DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
      l_current_column_index := l_current_column_index + 1;
      l_item_desc := l_retrieved_value;

Write_Debug('Got Item desc ' || l_item_desc);



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
                                 p_attr_metadata_table => l_attr_metadata_table
                                ,p_db_column_name      => l_current_column_name
                               );


        ------------------------------------------------
        -- If the current column is an Attr column... --
        ------------------------------------------------
        IF (l_attr_metadata_obj IS NOT NULL AND
            l_attr_metadata_obj.ATTR_NAME IS NOT NULL AND
            l_current_column_index IS NOT NULL )
        THEN

          -----------------------------------------------------
          -- ...then we add its value to our Attr data table
          -- Note: set column name as  ATTR_NAME to use it for Proces_Item param
          -----------------------------------------------------
          l_attr_name_value_pairs.EXTEND();
          l_attr_name_value_pairs(l_attr_name_value_pairs.LAST) :=
            EGO_USER_ATTR_DATA_OBJ(
              1
             ,l_current_column_name -- ,l_attr_metadata_obj.ATTR_NAME
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

    -------------------------------------------------------------------------
    --  No need to process UOM for Item Master AG Type
    --  ELSIF (INSTR(l_current_column_name, 'UOM_') = 1) THEN
    --
      --------------------------------------------
      -- Store the UOM column's name and value  --
      -- in a PL/SQL table for assignment below --
      --------------------------------------------
    --   l_uom_nv_pairs_index := l_uom_nv_pairs_index + 1;
    --   l_uom_column_nv_pairs(l_uom_nv_pairs_index) :=
    --     EGO_COL_NAME_VALUE_PAIR_OBJ(l_current_column_name, l_retrieved_value);
    --
    -------------------------------------------------------------------------

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
      END LOOP; -- l_current_column_index



      -- NO need to process UOM
      ---------------------------------------------------------
      -- If we gathered any UOM data, we assign all gathered --
      -- UOM values to the appropriate Attr data object      --
      ---------------------------------------------------------
      -- IF (l_uom_nv_pairs_index > 0) THEN
      --
      --   FOR i IN 1 .. l_uom_nv_pairs_index
      --   LOOP
      --
      --
      --    l_current_uom_col_nv_obj := l_uom_column_nv_pairs(i);
      --
          ----------------------------------------------
          -- We derive the Attr's DB column name from --
          -- the UOM column name in one of two ways   --
          ----------------------------------------------
      --    IF (INSTR(l_current_uom_col_nv_obj.NAME, 'UOM_EXT_ATTR') = 1) THEN
      --      l_attr_col_name_for_uom_col := 'N_'||SUBSTR(l_current_uom_col_nv_obj.NAME, 5);
      --    ELSE
      --      l_attr_col_name_for_uom_col := SUBSTR(l_current_uom_col_nv_obj.NAME, 5);
      --    END IF;
      --
          -------------------------------------------------------------
          -- Now we find the Attr from the column name we've derived --
          -- and set its Attr data object's UOM field with our value --
          -------------------------------------------------------------
      --    IF (l_attr_name_value_pairs IS NOT NULL AND
      --        l_attr_name_value_pairs.COUNT > 0) THEN
      --
      --      l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
      --                               p_attr_metadata_table => l_attr_group_metadata_obj.attr_metadata_table
      --                              ,p_db_column_name      => l_attr_col_name_for_uom_col
      --                             );
      --
            ------------------------------------------------------------------
            -- If we found the metadata object, we look for the data object --
            ------------------------------------------------------------------
      --      IF (l_attr_metadata_obj IS NOT NULL AND
      --          l_attr_metadata_obj.ATTR_NAME IS NOT NULL) THEN
      --
      --        FOR j IN l_attr_name_value_pairs.FIRST .. l_attr_name_value_pairs.LAST
      --        LOOP
      --          IF (l_attr_name_value_pairs(j).ATTR_NAME =
      --              l_attr_metadata_obj.ATTR_NAME) THEN
      --
                  -----------------------------------------------------------
                  -- When we find the data object, we set its UOM and exit --
                  -----------------------------------------------------------
      --            l_attr_name_value_pairs(j).ATTR_UNIT_OF_MEASURE :=
      --              l_current_uom_col_nv_obj.VALUE;
      --            EXIT;

      --          END IF;
      --        END LOOP;
      --      END IF;
      --    END IF;
      --  END LOOP;
      -- END IF; -- End of UOM Data
      --


      -------------------------------------------------------------------
      -- Now that we've got all necessary data and metadata, we try to --
      -- find a corresponding production row for this pending row; we  --
      -- use the new data level values if we have them, because we are --
      -- trying to see whether or not the row we're about to move into --
      -- the production table already exists there                     --
      -------------------------------------------------------------------
      IF (l_current_acd_type = G_CHANGE_ACD_TYPE)
      THEN

Write_Debug('Item Attr Change Imple is processing rec with ACD Type: '  || l_current_acd_type);

          -----------------------------------------------------
          -- If ACD Type is CHANGE and there's
          -- a production row, we change it
          -- In case of Item Op Attr Change, we can assume this
          -----------------------------------------------------
          l_mode_for_current_row := G_UPDATE_TX_TYPE;


      ELSE
          -- Acd Type maybe ADD or DELETE or Invalid one
Write_Debug('Item Attr Change Imple does not support ACD Type: '  || l_current_acd_type);

          -- We don't support this in R12
          FND_MESSAGE.Set_Name('ENG','ENG_IMPL_INVALID_ACD_TYPE');
          FND_MESSAGE.Set_Token('ACD_TYPE', l_current_acd_type);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

      END IF;


      IF (l_mode_for_current_row <> 'SKIP')
      THEN

        ---------------------------------------------------------------------
        -- Now at last we're ready to call Process_Row on this pending row --
        ---------------------------------------------------------------------
        l_dynamic_sql :=
         ' BEGIN '                                                ||
         ' EGO_ITEM_PUB.Process_Item '                            ||
         ' ( '                                                    ||
           ' p_api_version =>  1'                               ||
          ' ,p_init_msg_list => FND_API.G_FALSE '                 ||
          ' ,p_commit  => FND_API.G_FALSE '                       ||
          ' ,p_transaction_type => :l_mode_for_current_row '      ||
          -- ' ,p_Language_Code => :l_current_row_language '      ||
          ' ,p_inventory_item_id => :l_inventory_item_id '        ||
          ' ,p_item_number => :l_item_number '                    ||
          ' ,p_organization_id => :l_organization_id '            ||
         -- ' ,p_process_control => ''PLM_UI:Y'''                 ||  Bug 4723028
         ' ,p_process_control => ''PLM_UI:N$ENG_CALL:Y'''         ||
          --' ,p_process_item => :l_process_item '                ||
          -- ' ,p_object_version_number => null '                 ||
          ' ,x_inventory_item_id=> :l_out_inventory_item_id '     ||
          ' ,x_organization_id => :l_out_organization_id '        ;
	   if l_item_desc is not null
          then
              l_dynamic_sql := l_dynamic_sql || ' ,P_DESCRIPTION => :l_item_desc ' ;
          end if;
	   l_dynamic_sql := l_dynamic_sql || ' ,x_return_status => :l_return_status ' ||
          ' ,x_msg_count => :l_msg_count '                        ||
          ' ,x_msg_data => :l_msg_data ' ;


          FOR j IN l_attr_name_value_pairs.FIRST .. l_attr_name_value_pairs.LAST
          LOOP

              ---------------------------------------------------------------------
              -- Assumption. EGO_ITEM_PUB.Process_Item's param for attribute data
              -- is P_ + DB Column Name
              ---------------------------------------------------------------------

              -----------------------------
              -- Got Data                --
              -----------------------------
              l_num_value  := l_attr_name_value_pairs(j).ATTR_VALUE_NUM ;
              l_char_value := l_attr_name_value_pairs(j).ATTR_VALUE_STR ;
              l_date_value := l_attr_name_value_pairs(j).ATTR_VALUE_DATE ;
              l_date_value_char := TO_CHAR(l_attr_name_value_pairs(j).ATTR_VALUE_DATE, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT)  ;


              -- ATTR_NAME is set as DB Column Name
              IF l_num_value IS NOT NULL
              THEN
                  IF l_num_value = ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_NUM
                  THEN
                      l_num_value := EGO_ITEM_PUB.G_INTF_NULL_NUM;
                  END IF;

                  l_dynamic_sql := l_dynamic_sql ||
                  ' , ' || Get_Process_Item_Param(l_attr_name_value_pairs(j).ATTR_NAME) || ' => '  ||  TO_CHAR(l_num_value) ;

              ELSIF l_char_value IS NOT NULL
              THEN
                  IF l_char_value = ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_CHAR
                  THEN
                      l_char_value := EGO_ITEM_PUB.G_INTF_NULL_CHAR;
                  END IF;

                  l_dynamic_sql := l_dynamic_sql ||
                  ' , ' || Get_Process_Item_Param(l_attr_name_value_pairs(j).ATTR_NAME) || ' => '  || '''' || l_char_value || '''' ;

              ELSIF l_date_value IS NOT NULL
              THEN
                  IF l_date_value = ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_DATE
                  THEN
                      l_date_value := EGO_ITEM_PUB.G_INTF_NULL_DATE;
                  END IF;

                 l_dynamic_sql := l_dynamic_sql ||
                 ' , ' || Get_Process_Item_Param(l_attr_name_value_pairs(j).ATTR_NAME) || ' => ' || ' TO_DATE( ''' || l_date_value_char || ''', ''' || EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT || ''')  ';

                  -- l_dynamic_sql := l_dynamic_sql || ''' || l_date_value || '''' ;

              END IF ;

          END LOOP;

          l_dynamic_sql := l_dynamic_sql || '  ); END; '  ;


          if l_item_number is null
          then
          l_item_number := GetItemNumber(p_inventory_item_id => l_inventory_item_id
                                        , p_organization_id => l_organization_id) ;
          end if;

Write_Debug('EGO_ITEM_PUB.Process_Item call: '  || l_dynamic_sql);
Write_Debug('---------------------------------- ' );
Write_Debug('l_mode_for_current_row: '  || l_mode_for_current_row);
Write_Debug('l_inventory_item_id: '  || to_char(l_inventory_item_id));
Write_Debug('l_organization_id: '  || to_char(l_organization_id));
Write_Debug('l_item_number: '  || l_item_number);
Write_Debug('---------------------------------- ' );


          BEGIN

              l_dummy_c := DBMS_SQL.OPEN_CURSOR;
              DBMS_SQL.PARSE(l_dummy_c, l_dynamic_sql, 2);
              DBMS_SQL.BIND_VARIABLE (l_dummy_c, 'l_mode_for_current_row', l_mode_for_current_row);
              DBMS_SQL.BIND_VARIABLE (l_dummy_c, 'l_inventory_item_id', l_inventory_item_id);
              DBMS_SQL.BIND_VARIABLE (l_dummy_c, 'l_item_number', l_item_number);
              DBMS_SQL.BIND_VARIABLE (l_dummy_c, 'l_organization_id', l_organization_id);
              DBMS_SQL.BIND_VARIABLE (l_dummy_c, 'l_out_inventory_item_id', l_out_inventory_item_id);
              DBMS_SQL.BIND_VARIABLE (l_dummy_c, 'l_out_organization_id', l_out_organization_id);
	      if l_item_desc is not null
              then
                DBMS_SQL.BIND_VARIABLE(l_dummy_c, 'l_item_desc', l_item_desc);
              end if;
              DBMS_SQL.BIND_VARIABLE (l_dummy_c, 'l_return_status', l_return_status, 1);
              DBMS_SQL.BIND_VARIABLE (l_dummy_c, 'l_msg_count', l_msg_count);
              DBMS_SQL.BIND_VARIABLE (l_dummy_c, 'l_msg_data', l_msg_data, 2000);
	      l_dummy_r := DBMS_SQL.EXECUTE(l_dummy_c);
              DBMS_SQL.VARIABLE_VALUE(l_dummy_c, 'l_return_status', l_return_status);
              DBMS_SQL.VARIABLE_VALUE(l_dummy_c, 'l_msg_count', l_msg_count);
              DBMS_SQL.VARIABLE_VALUE(l_dummy_c, 'l_msg_data', l_msg_data);


Write_Debug('After calling EGO_ITEM_PUB.Process_Item' );
Write_Debug('---------------------------------- ' );
Write_Debug('l_return_status: '  || l_return_status);
Write_Debug('l_msg_count: '  || to_char(l_msg_count));
Write_Debug('l_msg_data: '  || l_msg_data);
Write_Debug('l_out_inventory_item_id: '  || to_char(l_out_inventory_item_id));
Write_Debug('l_out_organization_id: '  || to_char(l_out_organization_id));
Write_Debug('---------------------------------- ' );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSE
             -- Bug 6157001 Moved here - if l_return_status = 'S' Add history record only if process_item returns S
             -- History record was getting saved somehow even when the process_item is returning E and rollback is being executed.
             -----------------------------------------------------------
             -- If we're altering a production row, we first copy the --
             -- row into the pending tables with the ACD Type HISTORY --
             -----------------------------------------------------------
             IF (l_mode_for_current_row = G_DELETE_TX_TYPE OR
                 l_mode_for_current_row = G_UPDATE_TX_TYPE) THEN


     Write_Debug('Copy the row into the pending tables with the ACD Type HISTORY');


               -----------------------------------------------------------
               -- Process_Row will only process our pending B table row --
               -- in the loop when LANGUAGE is NULL or when LANGUAGE =  --
               -- SOURCE_LANG, so we insert a History row in that loop  --
               -----------------------------------------------------------
               IF (l_current_row_language IS NULL OR
                   l_current_row_language = l_current_row_source_lang)
               THEN


     Write_Debug('Inserting History Row with the ACD Type HISTORY for B table');

                 l_utility_dynamic_sql := ' INSERT INTO '||l_change_b_table_name||' CT ('||
                                          l_history_b_chg_cols_list||
                                          ', CT.CREATED_BY,CT.CREATION_DATE,CT.LAST_UPDATED_BY'||
                                          ', CT.LAST_UPDATE_DATE, CT.LAST_UPDATE_LOGIN'||
                                          ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, CT.ACD_TYPE'||
                                          ', CT.INVENTORY_ITEM_ID, CT.ORGANIZATION_ID ' ||
                                          ' )  SELECT ' || l_history_b_prod_cols_list||
                                          ', PT.CREATED_BY,PT.CREATION_DATE,PT.LAST_UPDATED_BY'||
                                          ', PT.LAST_UPDATE_DATE, PT.LAST_UPDATE_LOGIN'||
                                          ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'''||
                                          ', PT.INVENTORY_ITEM_ID, PT.ORGANIZATION_ID FROM ' ||
                                          l_production_b_table_name ||' PT, '||
                                          l_change_b_table_name || ' CT ' ||
                                        ' WHERE PT.INVENTORY_ITEM_ID = :1'||
                                        ' AND PT.ORGANIZATION_ID = :2'||
                                        ' AND CT.INVENTORY_ITEM_ID = :3'||
                                        ' AND CT.ORGANIZATION_ID = :4'||
                                        ' AND CT.CHANGE_LINE_ID = :5'||
                                        ' AND CT.ACD_TYPE = :6' ;



                 EXECUTE IMMEDIATE l_utility_dynamic_sql
                 USING l_inventory_item_id, l_organization_id,
                       l_inventory_item_id, l_organization_id,
                       l_change_line_id, l_current_acd_type ;


     Write_Debug('After Inserting History Row with the ACD Type HISTORY for B table');

               END IF;


               ------------------------------------------------------------
               -- Process_Row will only process the pending TL table row --
               -- whose language matches LANGUAGE, so we only insert a   --
               -- History row for that row                               --
               ------------------------------------------------------------

     Write_Debug('Inserting History Row with the ACD Type HISTORY for TL table');


               l_utility_dynamic_sql := ' INSERT INTO '||l_change_tl_table_name||' CT ('||
                                        l_history_tl_chg_cols_list||
                                        ', CT.CREATED_BY,CT.CREATION_DATE,CT.LAST_UPDATED_BY'||
                                        ', CT.LAST_UPDATE_DATE, CT.LAST_UPDATE_LOGIN'||
                                        ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, CT.ACD_TYPE'||
                                        ', CT.INVENTORY_ITEM_ID, CT.ORGANIZATION_ID '||
                                          ' )  SELECT ' || l_history_tl_prod_cols_list||
                                        ', PT.CREATED_BY,PT.CREATION_DATE,PT.LAST_UPDATED_BY'||
                                        ', PT.LAST_UPDATE_DATE, PT.LAST_UPDATE_LOGIN'||
                                        ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'''||
                                        ', PT.INVENTORY_ITEM_ID, PT.ORGANIZATION_ID FROM '||
                                        l_production_tl_table_name||' PT, '||
                                        l_change_tl_table_name||' CT ' ||
                                        ' WHERE PT.INVENTORY_ITEM_ID = :1'||
                                        ' AND PT.ORGANIZATION_ID = :2'||
                                        ' AND CT.INVENTORY_ITEM_ID = :3'||
                                        ' AND CT.ORGANIZATION_ID = :4'||
                                        ' AND CT.CHANGE_LINE_ID = :5'||
                                        ' AND CT.ACD_TYPE = :6'||
                                        ' AND CT.LANGUAGE = PT.LANGUAGE AND CT.LANGUAGE = :7';

                 EXECUTE IMMEDIATE l_utility_dynamic_sql
                 USING l_inventory_item_id, l_organization_id,
                       l_inventory_item_id, l_organization_id,
                       l_change_line_id, l_current_acd_type,
                       l_current_row_language;

     Write_Debug('After Inserting History Row with the ACD Type HISTORY for TL table');

             END IF; -- Check l_mode_for_current_row

        END IF;

          EXCEPTION

             WHEN FND_API.G_EXC_ERROR THEN
                   x_return_status := l_return_status ;
                   RAISE FND_API.G_EXC_ERROR;

             WHEN OTHERS THEN

                   FND_MSG_PUB.Add_Exc_Msg
                   ( p_pkg_name            => 'EGO_ITEM_PUB' ,
                     p_procedure_name      => 'Process_Item',
                     p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
                   );


                  FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
                  FND_MESSAGE.Set_Token('OBJECT_NAME', 'EGO_ITEM_PUB.Process_Item');
                  FND_MSG_PUB.Add;

Write_Debug('When Others Exception while calling EGO_ITEM_PUB.Process_Item' || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          END ;


          IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS)
          THEN

              -- Get message list from Error_Hanlder
              Error_Handler.Get_Message_List(x_Message_List => l_message_list ) ;
              l_msg_index := l_message_list.FIRST ;

              WHILE l_msg_index IS NOT NULL
              LOOP
                   FND_MSG_PUB.Add_Exc_Msg
                   ( p_pkg_name            => null ,
                     p_procedure_name      => null ,
                     p_error_text          => l_message_list(l_msg_index).message_text
                   );

                  l_msg_index := l_message_list.NEXT(l_msg_index);

              END LOOP;

              FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP

                  -- FND_MSG_PUB.dump_Msg(I);
Write_Debug('Dumping Message number : '|| I );
Write_Debug('DATA = '||replace(substr(FND_MSG_PUB.Get(I), 1, 200), chr(0), ' '));

              END LOOP;


              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;

Write_Debug('EGO_ITEM_PUB.Process_Item failed . ..  ' );
Write_Debug('Output - Return Stattus: '  || l_return_status);
Write_Debug('Output - Return Stattus: '  || to_char(l_msg_count));
Write_Debug('Output - Return Stattus: '  || substr(l_msg_data,1,200));

              FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
              FND_MESSAGE.Set_Token('OBJECT_NAME', 'EGO_ITEM_PUB.Process_Item');
              FND_MSG_PUB.Add;

              RAISE FND_API.G_EXC_ERROR ;

          END IF;

      END IF; -- l_mode_for_current_row <> 'SKIP'


    END LOOP; -- DBMS_SQL.Fetch_Rows Loop
    DBMS_SQL.Close_Cursor(l_cursor_id);


    ---------------------------------------------------------------------------
    -- Finally, set the IMPLEMENTATION_DATE for all rows we just implemented --
    ---------------------------------------------------------------------------
    -- If the record is queried
    IF l_current_column_index IS NOT NULL
    THEN

Write_Debug('set the IMPLEMENTATION_DATE for all rows we just implemented');


        EXECUTE IMMEDIATE ' UPDATE '||l_change_b_table_name||
                             ' SET IMPLEMENTATION_DATE = :1'||
                           ' WHERE CHANGE_LINE_ID = :2'
        USING SYSDATE, p_change_line_id;
        EXECUTE IMMEDIATE ' UPDATE '||l_change_tl_table_name||
                             ' SET IMPLEMENTATION_DATE = :1'||
                           ' WHERE CHANGE_LINE_ID = :2'
        USING SYSDATE, p_change_line_id;


    END IF ;
Write_Debug('In Implement Item Attribute Change, Done');

    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( l_commit ) THEN

Write_Debug('Commit Item Attribute Change Implementation ');

       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
Write_Debug('When G_EXC_ERROR Exception in impl_rev_item_attr_changes');

    x_return_status := G_RET_STS_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('Rollback to IMPL_REV_ITEM_ATTR_CHGS Item Attribute Change Implementation ');
       ROLLBACK TO IMPL_REV_ITEM_ATTR_CHGS;
    END IF;

    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_attr_changes for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;


    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
Write_Debug('When G_EXC_UNEXPECTED_ERROR Exception in impl_rev_item_attr_changes');

    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('Rollback to IMPL_REV_ITEM_ATTR_CHGS Item Attribute Change Implementation ');
       ROLLBACK TO IMPL_REV_ITEM_ATTR_CHGS;
    END IF;


    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_attr_changes for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;

  WHEN OTHERS THEN
Write_Debug('When G_EXC_ERROR Exception in impl_rev_item_attr_changes');

    x_return_status := G_RET_STS_UNEXP_ERROR ;

Write_Debug('Rollback to IMPL_REV_ITEM_ATTR_CHGS Item Attribute Change Implementation ');

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('Rollback to IMPL_REV_ITEM_ATTR_CHGS Item Attribute Change Implementation ');
       ROLLBACK TO IMPL_REV_ITEM_ATTR_CHGS;
    END IF;


Write_Debug('When Others Exception ' || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));


    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_attr_changes for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;


    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;


END impl_rev_item_attr_changes;




PROCEDURE impl_rev_item_aml_changes
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER
)
IS

    l_api_name      CONSTANT VARCHAR2(30) := 'IMPL_REV_ITEM_AML_CHANGES';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;


    l_msg_data       VARCHAR2(4000);
    l_msg_count      NUMBER;
    l_return_status  VARCHAR2(1);
    l_errorcode      NUMBER;

    l_found          BOOLEAN ;

    l_change_id NUMBER;
    l_change_line_id NUMBER;

    l_check_aml_changes NUMBER := 2;
    plsql_block VARCHAR2(5000);

BEGIN


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;

    IF FND_API.To_Boolean( l_commit ) THEN
       -- Standard Start of API savepoint
       SAVEPOINT IMPL_REV_ITEM_AML_CHANGES;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_change_id: '  || to_char(p_change_id));
Write_Debug('p_change_line_id: '  || to_char(p_change_line_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    -- API body
    -- Logic Here
    -- Init Local Vars


    l_change_id := p_change_id;
    l_change_line_id := p_change_line_id;

    IF ( l_change_id IS NULL OR l_change_id <= 0 )
    THEN
        l_change_id := GetChangeId(p_change_line_id => l_change_line_id) ;

Write_Debug('Got Change Id: '  || to_char(l_change_id));

    END IF ;


Write_Debug('Check Item AML Change exists for Rev Item: '  || to_char(l_change_line_id));

    l_found :=  CheckItemMfgPartNumChange(p_change_line_id => l_change_line_id) ;
    IF NOT l_found THEN

Write_Debug('Item AML Change not found for '  || to_char(l_change_line_id));
       RETURN ;

    END IF ;


    --
    --  Call implement aml changes api
    --

Write_Debug('calling EGO_ITEM_AML_PUB.Implement_AML_Changes for Rev Item: '  || to_char(l_change_line_id));
    BEGIN
        plsql_block := 'BEGIN
        EGO_ITEM_AML_PUB.Implement_AML_Changes(
        :a,
        :b,
        :c,
        :d,
        :e,
        :f,
        :g,
        :h);
        END;';

        EXECUTE IMMEDIATE plsql_block USING
                        '1',
                        '',
                        FND_API.G_FALSE,
                        p_change_id,
                        p_change_line_id,
                        OUT l_return_status,
                        OUT l_msg_count,
                        OUT l_msg_data;

Write_Debug('After calling EGO_ITEM_AML_PUB.Implement_AML_Changes for Return Status: '  || l_return_status);
        IF l_msg_count > 1 THEN
                for i in 1..l_msg_count loop
Write_Debug(' msg no '||i ||': '|| fnd_msg_pub.Get(p_msg_index =>  i,p_encoded => 'F'));
                end loop;
           else
Write_Debug('Implement_AML_Changes Error message : '  || l_msg_data);
        END IF;


   EXCEPTION
       WHEN OTHERS THEN

            FND_MSG_PUB.Add_Exc_Msg
             ( p_pkg_name            => 'EGO_ITEM_AML_PUB' ,
               p_procedure_name      => 'Implement_AML_Changes',
               p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
            );


            FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            FND_MESSAGE.Set_Token('OBJECT_NAME', 'EGO_ITEM_AML_PUB.Implement_AML_Changes');
            FND_MSG_PUB.Add;

Write_Debug('When Others Exception while calling EGO_ITEM_AML_PUB.Implement_AML_Changes:' || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END ;

    IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS)
    THEN
        x_return_status := l_return_status;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;

Write_Debug('EGO_ITEM_AML_PUB.Implement_AML_Changes failed . ..  ' );
Write_Debug('Output - Return Stattus: '  || l_return_status);
Write_Debug('Output - Return Stattus: '  || to_char(l_msg_count));
Write_Debug('Output - Return Stattus: '  || substr(l_msg_data,1,200));


        FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
        FND_MESSAGE.Set_Token('OBJECT_NAME', 'EGO_ITEM_AML_PUB.Implement_AML_Changes');
        FND_MSG_PUB.Add;

        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
Write_Debug('COMMIT Item AML Changes implementation');

       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
Write_Debug('When G_EXC_ERROR Exception in impl_rev_item_aml_changes');

    x_return_status := G_RET_STS_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK Item AML Changes implementation to IMPL_REV_ITEM_AML_CHANGES');
       ROLLBACK TO IMPL_REV_ITEM_AML_CHANGES;
    END IF;

    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_aml_changes for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;


    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
Write_Debug('When G_EXC_UNEXPECTED_ERROR Exception in impl_rev_item_aml_changes');

    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK Item AML Changes implementation to IMPL_REV_ITEM_AML_CHANGES');
       ROLLBACK TO IMPL_REV_ITEM_AML_CHANGES;
    END IF;


    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_aml_changes for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;

  WHEN OTHERS THEN
Write_Debug('When OTHERS Exception in impl_rev_item_aml_changes');

    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK Item AML Changes implementation to IMPL_REV_ITEM_AML_CHANGES');
       ROLLBACK TO IMPL_REV_ITEM_AML_CHANGES;
    END IF;


Write_Debug('When Others Exception ' || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));

    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_aml_changes for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;


    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;

END impl_rev_item_aml_changes ;




PROCEDURE impl_rev_item_gdsn_attr_chgs
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER
)
IS


    l_api_name      CONSTANT VARCHAR2(30) := 'IMPL_REV_ITEM_GDSN_ATTR_CHGS';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;


    l_msg_data       VARCHAR2(4000);
    l_msg_count      NUMBER;
    l_return_status  VARCHAR2(1);
    l_errorcode      NUMBER;

    l_single_row_change_found          BOOLEAN ;
    l_multi_row_change_found           BOOLEAN ;

    l_change_id              NUMBER;
    l_change_line_id         NUMBER;
    l_inventory_item_id      NUMBER ;
    l_organization_id        NUMBER ;
    l_attr_group_id          NUMBER ;

    l_cols_to_exclude_list    VARCHAR2(2000);
    l_chg_col_names_list      VARCHAR2(32767);
    l_mul_chg_col_names_list  VARCHAR2(32767);


    l_mode_for_current_row    VARCHAR2(10);
    l_current_acd_type        VARCHAR2(30);
    l_current_row_language    VARCHAR2(30);
    l_current_row_source_lang VARCHAR2(30);
    l_current_column_name     VARCHAR2(30);
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_attr_metadata_table     EGO_ATTR_METADATA_TABLE ;
    l_current_pending_ext_id    NUMBER;
    l_current_production_ext_id NUMBER;
    l_ext_id_for_current_row    NUMBER;


    l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_attr_name_value_pairs      EGO_USER_ATTR_DATA_TABLE := EGO_USER_ATTR_DATA_TABLE();
    l_attr_metadata_obj          EGO_ATTR_METADATA_OBJ;

    l_num_value               NUMBER ;
    l_char_value              VARCHAR2(1000) ;
    l_date_value              DATE ;
    l_date_value_char         VARCHAR2(30) ;


    l_utility_dynamic_sql    VARCHAR2(32767); --the largest a VARCHAR2 can be
    l_cursor_id              NUMBER;
    l_column_count           NUMBER;
    l_dummy                  NUMBER;
    l_desc_table             DBMS_SQL.Desc_Tab;
    l_retrieved_value        VARCHAR2(1000);
    l_current_column_index   NUMBER;

    l_prod_b_table_name      CONSTANT VARCHAR2(30) := 'EGO_ITEM_GTN_ATTRS_B' ;
    l_prod_tl_table_name     CONSTANT VARCHAR2(30) := 'EGO_ITEM_GTN_ATTRS_TL' ;
    l_chg_b_table_name       CONSTANT VARCHAR2(30) := 'EGO_GTN_ATTR_CHG_B' ;
    l_chg_tl_table_name      CONSTANT VARCHAR2(30) := 'EGO_GTN_ATTR_CHG_TL' ;
    l_mul_prod_b_table_name  CONSTANT VARCHAR2(30) := 'EGO_ITM_GTN_MUL_ATTRS_B' ;
    l_mul_prod_tl_table_name CONSTANT VARCHAR2(30) := 'EGO_ITM_GTN_MUL_ATTRS_TL' ;
    l_mul_chg_b_table_name   CONSTANT VARCHAR2(30) := 'EGO_GTN_MUL_ATTR_CHG_B' ;
    l_mul_chg_tl_table_name  CONSTANT VARCHAR2(30) := 'EGO_GTN_MUL_ATTR_CHG_TL' ;

    l_b_chg_cols_list        VARCHAR2(32767);
    l_tl_chg_cols_list       VARCHAR2(10000);
    l_hist_b_chg_cols_list   VARCHAR2(32767);
    l_hist_tl_chg_cols_list  VARCHAR2(10000);
    l_hist_b_prod_cols_list  VARCHAR2(32767);
    l_hist_tl_prod_cols_list VARCHAR2(10000);

    l_mul_b_chg_cols_list        VARCHAR2(32767);
    l_mul_tl_chg_cols_list       VARCHAR2(10000);
    l_mul_hist_b_chg_cols_list   VARCHAR2(32767);
    l_mul_hist_tl_chg_cols_list  VARCHAR2(10000);
    l_mul_hist_b_prod_cols_list  VARCHAR2(32767);
    l_mul_hist_tl_prod_cols_list VARCHAR2(10000);


    l_dynamic_sql            VARCHAR2(32767); --the largest a VARCHAR2 can be
    l_mul_dynamic_sql        VARCHAR2(32767); --the largest a VARCHAR2 can be

    l_single_row_attrs_rec   EGO_ITEM_PUB.UCCNET_ATTRS_SINGL_ROW_REC_TYP ;
    l_multi_row_attrs_tbl    EGO_ITEM_PUB.UCCNET_ATTRS_MULTI_ROW_TBL_TYP;
    l_extra_attrs_rec        EGO_ITEM_PUB.UCCNET_EXTRA_ATTRS_REC_TYP;

    l_installed_flag         VARCHAR2(1) ;
    l_lang_code              VARCHAR2(4);
    l_nls_lang               VARCHAR2(64);
    l_territory              VARCHAR2(64);

    l_orig_nls_lang          VARCHAR2(64);
    l_orig_territory         VARCHAR2(64);
    l_orig_chrs              VARCHAR2(64);

    ind NUMBER;
    -- l_current_dl_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    -- l_object_id                  NUMBER;
    -- l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;


    CURSOR c_lang
    IS
      SELECT L.LANGUAGE_CODE, L.INSTALLED_FLAG, L.NLS_LANGUAGE, L.NLS_TERRITORY
      FROM FND_LANGUAGES  L
      WHERE  L.INSTALLED_FLAG IN ('B', 'I') ;


BEGIN

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;


    IF FND_API.To_Boolean( l_commit ) THEN
      -- Standard Start of API savepoint
      SAVEPOINT IMPL_REV_ITEM_GDSN_ATTR_CHGS;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_change_id: '  || to_char(p_change_id));
Write_Debug('p_change_line_id: '  || to_char(p_change_line_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    -- API body
    -- Logic Here
    -- Init Local Vars


    l_change_id := p_change_id;
    l_change_line_id := p_change_line_id;

    IF ( l_change_id IS NULL OR l_change_id <= 0 )
    THEN
        l_change_id := GetChangeId(p_change_line_id => l_change_line_id) ;

Write_Debug('Got Change Id: '  || to_char(l_change_id));

    END IF ;


Write_Debug('Check Item GDSN Attr Change exists for Rev Item: '  || to_char(l_change_line_id));

    l_single_row_change_found :=  CheckItemGDSNAttrChange(p_change_line_id => l_change_line_id
                                             , p_gdsn_attr_group_type => G_EGO_ITEM_GTIN_ATTRS
                                              ) ;


    l_multi_row_change_found :=  CheckItemGDSNAttrChange(p_change_line_id => l_change_line_id
                                             , p_gdsn_attr_group_type => G_EGO_ITEM_GTIN_MULTI_ATTRS
                                              ) ;

    IF NOT l_single_row_change_found AND
       NOT l_multi_row_change_found
    THEN

Write_Debug('Item GDSN Attr Change not found for '  || to_char(l_change_line_id));
       RETURN ;

    END IF ;


    -----------------------------------------------
    --We get the meta data for Object ID for our calls --
    -----------------------------------------------
    -- In R12, we will do hardcoding, anyway we need to put chg table name by hardcoding
    --
    -- SELECT EXT_TABLE_NAME, EXT_TL_TABLE_NAME, EXT_VL_NAME
    --   INTO l_b_table_name, l_tl_table_name, l_vl_name
    --   FROM EGO_ATTR_GROUP_TYPES_V
    --  WHERE APPLICATION_ID =  G_EGO_APPL_ID
    --    AND ATTR_GROUP_TYPE = G_EGO_ITEM_GTIN_ATTRS ;
    --
    --
    -- SELECT EXT_TABLE_NAME, EXT_TL_TABLE_NAME, EXT_VL_NAME
    --   INTO l_mul_b_table_name, l_mul_tl_table_name, l_mul_vl_name
    --   FROM EGO_ATTR_GROUP_TYPES_V
    --  WHERE APPLICATION_ID =  G_EGO_APPL_ID
    --    AND ATTR_GROUP_TYPE = G_EGO_ITEM_GTIN_MULTI_ATTRS ;
    --


    ---------------------------------------------------------------
    -- Next, we add to the lists the rest of the columns that we --
    -- either want to get explicitly or don't want to get at all --
    ---------------------------------------------------------------
    l_mul_chg_col_names_list:= 'B.INVENTORY_ITEM_ID,B.ORGANIZATION_ID,B.ACD_TYPE,B.EXTENSION_ID,B.ATTR_GROUP_ID';
    l_chg_col_names_list    := 'B.INVENTORY_ITEM_ID,B.ORGANIZATION_ID,B.ACD_TYPE,B.EXTENSION_ID';


    l_cols_to_exclude_list := '''INVENTORY_ITEM_ID'',''ORGANIZATION_ID'','||
                              '''ACD_TYPE'',''ATTR_GROUP_ID'',''EXTENSION_ID'','||
                              '''CHANGE_ID'',''CHANGE_LINE_ID'','||
                              '''IMPLEMENTATION_DATE'',''CREATED_BY'','||
                              '''CREATION_DATE'',''LAST_UPDATED_BY'','||
                              '''LAST_UPDATE_DATE'',''LAST_UPDATE_LOGIN'','||
                              '''PROGRAM_ID'',''PROGRAM_UPDATE_DATE'',''REQUEST_ID'' ,''PROGRAM_APPLICATION_ID''';


    ----------------------------------------------------------
    -- Get lists of columns for the B and TL pending tables --
    -- (i.e., all Attr cols and the language cols from TL)  --
    ----------------------------------------------------------
    l_b_chg_cols_list := Get_Table_Columns_List(
                            p_application_id            => G_EGO_APPL_ID
                           -- ,p_from_table_name           => l_chg_b_table_name
                           ,p_from_table_name           => l_prod_b_table_name
                           ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                           ,p_from_table_alias_prefix   => 'B'
                           ,p_cast_date_cols_to_char    => TRUE
                          );
    l_tl_chg_cols_list := Get_Table_Columns_List(
                             p_application_id            => G_EGO_APPL_ID
                            -- ,p_from_table_name           => l_chg_tl_table_name
                            ,p_from_table_name           => l_prod_tl_table_name
                            ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                            ,p_from_table_alias_prefix   => 'TL'
                            ,p_cast_date_cols_to_char    => TRUE
                           );

    l_mul_b_chg_cols_list := Get_Table_Columns_List(
                            p_application_id            => G_EGO_APPL_ID
                           -- ,p_from_table_name           => l_mul_chg_b_table_name
                           ,p_from_table_name           => l_mul_prod_b_table_name
                           ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                            ,p_from_table_alias_prefix   => 'B'
                           ,p_cast_date_cols_to_char    => TRUE
                          );
    l_mul_tl_chg_cols_list := Get_Table_Columns_List(
                             p_application_id            => G_EGO_APPL_ID
                            -- ,p_from_table_name           => l_mul_chg_tl_table_name
                            ,p_from_table_name           => l_mul_prod_tl_table_name
                            ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                            ,p_from_table_alias_prefix   => 'TL'
                            ,p_cast_date_cols_to_char    => TRUE
                           );


    --------------------------------------------------------
    -- While we're getting lists of columns, we also get  --
    -- lists for later use in copying old prod rows --
    -- into the pending tables as HISTORY rows            --
    --------------------------------------------------------


    l_hist_b_chg_cols_list := Get_Table_Columns_List(
                                    p_application_id            => G_EGO_APPL_ID
                                   -- MK
                                   --,p_from_table_name           => l_chg_b_table_name
                                   ,p_from_table_name           => l_prod_b_table_name
                                   ,p_from_table_alias_prefix   => 'CT'
                                   ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                  );

    l_hist_tl_chg_cols_list := Get_Table_Columns_List(
                                     p_application_id            => G_EGO_APPL_ID
                                    -- ,p_from_table_name           => l_chg_tl_table_name
                                    ,p_from_table_name           => l_prod_tl_table_name
                                    ,p_from_table_alias_prefix   => 'CT'
                                    ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                   );

    l_hist_b_prod_cols_list := Get_Table_Columns_List(
                                    p_application_id            => G_EGO_APPL_ID
                                   ,p_from_table_name           => l_prod_b_table_name
                                   ,p_from_table_alias_prefix   => 'PT'
                                   ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                  );

    l_hist_tl_prod_cols_list := Get_Table_Columns_List(
                                     p_application_id            => G_EGO_APPL_ID
                                    ,p_from_table_name           => l_prod_tl_table_name
                                    ,p_from_table_alias_prefix   => 'PT'
                                    ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                   );


    l_mul_hist_b_chg_cols_list := Get_Table_Columns_List(
                                    p_application_id            => G_EGO_APPL_ID
                                   -- ,p_from_table_name           => l_mul_chg_b_table_name
                                   ,p_from_table_name           => l_mul_prod_b_table_name
                                   ,p_from_table_alias_prefix   => 'CT'
                                   ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                  );

    l_mul_hist_tl_chg_cols_list := Get_Table_Columns_List(
                                     p_application_id            => G_EGO_APPL_ID
                                    -- MK
                                    -- ,p_from_table_name           => l_mul_chg_tl_table_name
                                    ,p_from_table_name           => l_mul_prod_tl_table_name
                                    ,p_from_table_alias_prefix   => 'CT'
                                    ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                   );

    l_mul_hist_b_prod_cols_list := Get_Table_Columns_List(
                                    p_application_id            => G_EGO_APPL_ID
                                   ,p_from_table_name           => l_mul_prod_b_table_name
                                   ,p_from_table_alias_prefix   => 'PT'
                                   ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                  );

    l_mul_hist_tl_prod_cols_list := Get_Table_Columns_List(
                                     p_application_id            => G_EGO_APPL_ID
                                    ,p_from_table_name           => l_mul_prod_tl_table_name
                                    ,p_from_table_alias_prefix   => 'PT'
                                    ,p_from_cols_to_exclude_list => l_cols_to_exclude_list
                                   );




    IF l_single_row_change_found  THEN

Write_Debug('Processing Item GDSN Single Change . . . ' );

        -----------------------------------------------------------------
        -- Now we build the SQL for our dynamic cursor for Single Row --
        -----------------------------------------------------------------
        l_dynamic_sql := 'SELECT '||l_chg_col_names_list||','||
                                    l_b_chg_cols_list||','||
                                    l_tl_chg_cols_list||
                          ' FROM '||l_chg_b_table_name ||' B,'||
                                    l_chg_tl_table_name ||' TL'||
                         ' WHERE B.ACD_TYPE <> ''HISTORY'' AND B.IMPLEMENTATION_DATE IS NULL'||
                           ' AND B.ACD_TYPE = TL.ACD_TYPE'||
                           ' AND B.EXTENSION_ID = TL.EXTENSION_ID' ||
                           ' AND B.CHANGE_LINE_ID = TL.CHANGE_LINE_ID'||
                           ' AND B.CHANGE_LINE_ID = :1';


Write_Debug('Item GDSN Single Change Query:' || l_dynamic_sql  );

        l_cursor_id := DBMS_SQL.Open_Cursor;
        DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.Native);
        DBMS_SQL.Bind_Variable(l_cursor_id, ':1', l_change_line_id);
        DBMS_SQL.Describe_Columns(l_cursor_id, l_column_count, l_desc_table);

        FOR i IN 1 .. l_column_count
        LOOP
          --
          -- NOTE: ASSUMPTION: no PKs will ever be DATE objects
          --
          -------------------------------------------------------------
          -- We define all columns as VARCHAR2(1000) for convenience --
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
          --   Item Id
          DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
          l_current_column_index := l_current_column_index + 1;
          -- l_pk_column_name_value_pairs(1).VALUE := SUBSTRB(l_retrieved_value, 1, 150);
          l_inventory_item_id := TO_NUMBER(l_retrieved_value) ;

Write_Debug('Item GDSN Single Change Item Id: ' || to_char(l_inventory_item_id));

          --   Org Id
          DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
          l_current_column_index := l_current_column_index + 1;
          -- l_pk_column_name_value_pairs(2).VALUE := SUBSTRB(l_retrieved_value, 1, 150);
          l_organization_id := TO_NUMBER(l_retrieved_value) ;
Write_Debug('Item GDSN Single Change Org Id: ' || to_char(l_organization_id));

          ----------------------------
          -- Determine the ACD Type --
          ----------------------------
          DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
          l_current_column_index := l_current_column_index + 1;
          l_current_acd_type := l_retrieved_value;

Write_Debug('Item GDSN Single Change ACD Type: ' || l_current_acd_type);
          --------------------------
          -- Get the extension ID --
          --------------------------
          DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
          l_current_column_index := l_current_column_index + 1;
          l_current_pending_ext_id := TO_NUMBER(l_retrieved_value);

Write_Debug('Item GDSN Single Change Extension Id: ' || to_char(l_current_pending_ext_id));


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
            -- l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
            --                          p_attr_metadata_table => l_attr_metadata_table
            --                         ,p_db_column_name      => l_current_column_name
            --                        );
            --
            ------------------------------------------------
            -- If the current column is an Attr column... --
            ------------------------------------------------
            IF (l_current_column_name = 'LANGUAGE') THEN

              -------------------------------------------------------
              -- Determine the Language for passing to Process_Row --
              -------------------------------------------------------
              l_current_row_language := l_retrieved_value;

Write_Debug('Current Lang: ' || l_current_row_language );

            ELSIF (l_current_column_name = 'SOURCE_LANG') THEN

              ------------------------------------------------
              -- Determine the Source Lang for knowing when --
              -- to insert a History row into the B table   --
              ------------------------------------------------
              l_current_row_source_lang := l_retrieved_value;

Write_Debug('Current Row Source Lang: ' || l_current_row_source_lang);

            --
            -- WE CAN NOT CONSTRUCT following PL/SQL Object dynamically
            -- using dynamic SQL
            -- So NO NEED TO Constuct this
            -- l_single_row_attrs_rec   EGO_ITEM_PUB.UCCNET_ATTRS_SINGL_ROW_REC_TYP ;
            -- l_multi_row_attrs_tbl    EGO_ITEM_PUB.UCCNET_ATTRS_MULTI_ROW_TBL_TYP;
            --
            -- ELSIF (l_attr_metadata_obj IS NOT NULL AND
            --     l_attr_metadata_obj.ATTR_NAME IS NOT NULL AND
            --     l_current_column_index IS NOT NULL )
            -- THEN
            --
              -----------------------------------------------------
              -- ...then we add its value to our Attr data table --
              -----------------------------------------------------
            --   l_attr_name_value_pairs.EXTEND();
            --   l_attr_name_value_pairs(l_attr_name_value_pairs.LAST) :=
            --     EGO_USER_ATTR_DATA_OBJ(
            --       1
            --      ,l_current_column_name -- ,l_attr_metadata_obj.ATTR_NAME
            --      ,null -- ATTR_VALUE_STR
            --      ,null -- ATTR_VALUE_NUM
            --      ,null -- ATTR_VALUE_DATE
            --      ,null -- ATTR_DISP_VALUE
            --      ,null -- ATTR_UNIT_OF_MEASURE (will be set below if necessary)
            --      ,-1
            --     );

              --------------------------------------------------------
              -- We assign l_retrieved_value according to data type --
              --------------------------------------------------------
            --   IF (l_attr_metadata_obj.DATA_TYPE_CODE = 'N') THEN
                -----------------------------
                -- We deal with UOMs below --
                -----------------------------
            --     l_attr_name_value_pairs(l_attr_name_value_pairs.LAST).ATTR_VALUE_NUM :=
            --       TO_NUMBER(l_retrieved_value);
            --   ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = 'X') THEN
            --     l_attr_name_value_pairs(l_attr_name_value_pairs.LAST).ATTR_VALUE_DATE :=
            --       TRUNC(TO_DATE(l_retrieved_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));
            --   ELSIF (l_attr_metadata_obj.DATA_TYPE_CODE = 'Y') THEN
            --     l_attr_name_value_pairs(l_attr_name_value_pairs.LAST).ATTR_VALUE_DATE :=
            --       TO_DATE(l_retrieved_value, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
            --   ELSE
            --     l_attr_name_value_pairs(l_attr_name_value_pairs.LAST).ATTR_VALUE_STR :=
            --       l_retrieved_value;
            --   END IF;

        -------------------------------------------------------------------------
        --  No need to process UOM for Item Master AG Type
        --  ELSIF (INSTR(l_current_column_name, 'UOM_') = 1) THEN
        --
          --------------------------------------------
          -- Store the UOM column's name and value  --
          -- in a PL/SQL table for assignment below --
          --------------------------------------------
        --   l_uom_nv_pairs_index := l_uom_nv_pairs_index + 1;
        --   l_uom_column_nv_pairs(l_uom_nv_pairs_index) :=
        --     EGO_COL_NAME_VALUE_PAIR_OBJ(l_current_column_name, l_retrieved_value);
        --
        -------------------------------------------------------------------------

            END IF;
          END LOOP; -- l_current_column_index


           -------------------------------------------------------------------
           -- Now that we've got all necessary data and metadata, we try to --
           -- find a corresponding production row for this pending row; we  --
           -- use the new data level values if we have them, because we are --
           -- trying to see whether or not the row we're about to move into --
           -- the production table already exists there                     --
           -------------------------------------------------------------------

           l_current_production_ext_id :=
              Get_Ext_Id_For_GDSN_Single_Row(
                p_inventory_item_id     => l_inventory_item_id
               ,p_organization_id       => l_organization_id
              );

Write_Debug('Item GDSN Single Production Extension Id: ' || to_char(l_current_production_ext_id));

           ---------------------------------------------------------------------
           -- The mode and extension ID we pass to Process_Row are determined --
           -- by the existence of a production row, the ACD Type, and in some --
           -- cases by whether the Attr Group is single-row or multi-row      --
           ---------------------------------------------------------------------
           IF (l_current_acd_type = G_ADD_ACD_TYPE) THEN

             IF (l_current_production_ext_id IS NULL) THEN
               ---------------------------------------
               -- If ACD Type is CREATE and there's --
               -- no production row, we create one  --
               ---------------------------------------
               l_mode_for_current_row := G_CREATE_TX_TYPE ;
               l_ext_id_for_current_row := l_current_pending_ext_id;
             ELSE
                 ------------------------------------------------------
                 -- If ACD Type is CREATE, there's a production row, --
                 -- and it's a single-row Attr Group, then someone   --
                 -- created the row after this change was proposed,  --
                 -- so we'll update the production row; we'll also   --
                 -- copy the production Ext ID into the pending row  --
                 -- to record the fact that this pending row updated --
                 -- this production row                              --
                 ------------------------------------------------------
                 l_mode_for_current_row := G_UPDATE_TX_TYPE;
                 l_ext_id_for_current_row := l_current_production_ext_id;

                 ------------------------------------------------------------
                 -- Process_Row will only process our pending B table row  --
                 -- in the loop when LANGUAGE is NULL or when LANGUAGE =   --
                 -- SOURCE_LANG, so we change the pending row in that loop --
                 ------------------------------------------------------------
                 IF (l_current_row_language IS NULL OR
                     l_current_row_language = l_current_row_source_lang) THEN

Write_Debug('Updating Pending Extenstion Id for Pending B table ...' );

                   l_utility_dynamic_sql := 'UPDATE '||l_chg_b_table_name||
                                              ' SET EXTENSION_ID = :1'||
                                            ' WHERE EXTENSION_ID = :2'||
                                              ' AND ACD_TYPE = ''ADD'''||
                                              ' AND CHANGE_LINE_ID = :3';
                   EXECUTE IMMEDIATE l_utility_dynamic_sql
                   USING l_current_production_ext_id
                        ,l_current_pending_ext_id
                        ,p_change_line_id;

                 END IF;

Write_Debug('Updating Pending Extenstion Id for Pending TL table ...' );

                 l_utility_dynamic_sql := 'UPDATE '||l_chg_tl_table_name||
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

             END IF;  -- l_current_production_ext_id IS NULL)

           ELSIF (l_current_acd_type = G_CHANGE_ACD_TYPE) THEN

             IF (l_current_production_ext_id IS NULL) THEN
               -------------------------------------------------------------
               -- In every case below, we'll use the pending extension ID --
               -------------------------------------------------------------
               l_ext_id_for_current_row := l_current_pending_ext_id;

                 -------------------------------------------------------
                 -- If ACD Type is CHANGE, there's no production row, --
                 -- and it's a single-row Attr Group, that means that --
                 -- the row was somehow deleted since this change was --
                 -- proposed, so we'll need to re-insert the row.     --
                 -------------------------------------------------------
                 l_mode_for_current_row := G_CREATE_TX_TYPE;
             ELSE
               ---------------------------------------
               -- If ACD Type is CHANGE and there's --
               -- a production row, we change it    --
               ---------------------------------------
               l_mode_for_current_row := G_UPDATE_TX_TYPE;
               l_ext_id_for_current_row := l_current_production_ext_id;
             END IF;

           ELSIF (l_current_acd_type = G_DELETE_ACD_TYPE) THEN
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
               l_mode_for_current_row := G_DELETE_TX_TYPE;
               l_ext_id_for_current_row := l_current_production_ext_id;
             END IF;


          ELSE
Write_Debug('Item Attr Change Imple does not support ACD Type: '  || l_current_acd_type);

              -- We don't support this in R12
              FND_MESSAGE.Set_Name('ENG','ENG_IMPL_INVALID_ACD_TYPE');
              FND_MESSAGE.Set_Token('ACD_TYPE', l_current_acd_type);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;


          END IF;

Write_Debug('Mode for Current Row operation: '  || l_mode_for_current_row);

          IF (l_mode_for_current_row <> 'SKIP')
          THEN

            -----------------------------------------------------------
            -- If we're altering a production row, we first copy the --
            -- row into the pending tables with the ACD Type HISTORY --
            -----------------------------------------------------------
            IF (l_mode_for_current_row = G_DELETE_TX_TYPE OR
                l_mode_for_current_row = G_UPDATE_TX_TYPE) THEN

              -----------------------------------------------------------
              -- Process_Row will only process our pending B table row --
              -- in the loop when LANGUAGE is NULL or when LANGUAGE =  --
              -- SOURCE_LANG, so we insert a History row in that loop  --
              -----------------------------------------------------------
              IF (l_current_row_language IS NULL OR
                  l_current_row_language = l_current_row_source_lang)
              THEN

Write_Debug('Inserting History Record with ACD Type HISTORY into Pending B Table... '  );

                l_utility_dynamic_sql := ' INSERT INTO '||l_chg_b_table_name||' CT ('||
                                         l_hist_b_chg_cols_list||
                                         ', CT.CREATED_BY,CT.CREATION_DATE,CT.LAST_UPDATED_BY'||
                                         ', CT.LAST_UPDATE_DATE, CT.LAST_UPDATE_LOGIN'||
                                         ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, CT.ACD_TYPE'||
                                         ', CT.INVENTORY_ITEM_ID, CT.ORGANIZATION_ID, CT.EXTENSION_ID) SELECT '||
                                         l_hist_b_prod_cols_list||
                                         ', PT.CREATED_BY,PT.CREATION_DATE,PT.LAST_UPDATED_BY'||
                                         ', PT.LAST_UPDATE_DATE, PT.LAST_UPDATE_LOGIN'||
                                         ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'''||
                                         ', PT.INVENTORY_ITEM_ID, PT.ORGANIZATION_ID, PT.EXTENSION_ID FROM '||
                                           l_prod_b_table_name||' PT, '||
                                           l_chg_b_table_name || ' CT ' ||
                                         ' WHERE PT.INVENTORY_ITEM_ID = :1'||
                                         ' AND PT.ORGANIZATION_ID = :2'||
                                         ' AND CT.INVENTORY_ITEM_ID = :3'||
                                         ' AND CT.ORGANIZATION_ID = :4'||
                                         ' AND CT.CHANGE_LINE_ID = :5'||
                                         ' AND CT.ACD_TYPE = :6' ||
                                         ' AND PT.EXTENSION_ID = :7'||
                                         ' AND CT.EXTENSION_ID = :8' ;

                EXECUTE IMMEDIATE l_utility_dynamic_sql
                USING l_inventory_item_id, l_organization_id,
                      l_inventory_item_id, l_organization_id,
                      l_change_line_id, l_current_acd_type,
                      l_ext_id_for_current_row, l_current_pending_ext_id ;

              END IF;


              ------------------------------------------------------------
              -- Process_Row will only process the pending TL table row --
              -- whose language matches LANGUAGE, so we only insert a   --
              -- History row for that row                               --
              ------------------------------------------------------------
Write_Debug('Inserting History Record with ACD Type HISTORY into Pending TL Table... '  );

              l_utility_dynamic_sql := ' INSERT INTO '||l_chg_tl_table_name||' CT ('||
                                       l_hist_tl_chg_cols_list||
                                       ', CT.CREATED_BY,CT.CREATION_DATE,CT.LAST_UPDATED_BY'||
                                       ', CT.LAST_UPDATE_DATE, CT.LAST_UPDATE_LOGIN'||
                                       ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, CT.ACD_TYPE'||
                                       ', CT.INVENTORY_ITEM_ID, CT.ORGANIZATION_ID, CT.EXTENSION_ID) ' ||
                                       ' SELECT '||
                                       l_hist_tl_prod_cols_list||
                                       ', PT.CREATED_BY,PT.CREATION_DATE,PT.LAST_UPDATED_BY'||
                                       ', PT.LAST_UPDATE_DATE, PT.LAST_UPDATE_LOGIN'||
                                       ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'''||
                                       ', PT.INVENTORY_ITEM_ID, PT.ORGANIZATION_ID, PT.EXTENSION_ID FROM '||
                                       l_prod_tl_table_name||' PT, '||
                                       l_chg_tl_table_name||' CT ' ||
                                       ' WHERE PT.INVENTORY_ITEM_ID = :1'||
                                       ' AND PT.ORGANIZATION_ID = :2'||
                                       ' AND CT.INVENTORY_ITEM_ID = :3'||
                                       ' AND CT.ORGANIZATION_ID = :4'||
                                       ' AND CT.CHANGE_LINE_ID = :5'||
                                       ' AND CT.ACD_TYPE = :6'||
                                       ' AND PT.EXTENSION_ID = :7'||
                                       ' AND CT.EXTENSION_ID = :8' ||
                                       ' AND CT.LANGUAGE = PT.LANGUAGE AND CT.LANGUAGE = :9';

                EXECUTE IMMEDIATE l_utility_dynamic_sql
                USING l_inventory_item_id, l_organization_id,
                      l_inventory_item_id, l_organization_id,
                      l_change_line_id, l_current_acd_type,
                      l_ext_id_for_current_row, l_current_pending_ext_id ,
                      l_current_row_language;


            END IF; -- Check l_mode_for_current_row


          END IF; -- l_mode_for_current_row <> 'SKIP'


        END LOOP; -- DBMS_SQL.Fetch_Rows Loop
        DBMS_SQL.Close_Cursor(l_cursor_id);


Write_Debug('After Processing Item GDSN Single Change . . . ' );

    END IF ; -- l_single_row_change_found


    IF l_multi_row_change_found THEN

Write_Debug('Processing Item GDSN Mult-Row Change . . . ' );


        -----------------------------------------------------------------
        -- Now we build the SQL for our dynamic cursor for Multi Row --
        -----------------------------------------------------------------
        l_mul_dynamic_sql := 'SELECT '||l_mul_chg_col_names_list||','||
                                    l_mul_b_chg_cols_list||','||
                                    l_mul_tl_chg_cols_list||
                          ' FROM '||l_mul_chg_b_table_name ||' B,'||
                                    l_mul_chg_tl_table_name ||' TL'||
                         ' WHERE B.ACD_TYPE <> ''HISTORY'' AND B.IMPLEMENTATION_DATE IS NULL'||
                           ' AND B.ACD_TYPE = TL.ACD_TYPE'||
                           ' AND B.EXTENSION_ID = TL.EXTENSION_ID' ||
                           ' AND B.CHANGE_LINE_ID = TL.CHANGE_LINE_ID'||
                           ' AND B.CHANGE_LINE_ID = :1 ORDER BY B.ATTR_GROUP_ID';


-- Write_Debug('Item GDSN Multi-Row Change Query:' || l_mul_dynamic_sql );

        l_cursor_id := DBMS_SQL.Open_Cursor;
        DBMS_SQL.Parse(l_cursor_id, l_mul_dynamic_sql, DBMS_SQL.Native);
        DBMS_SQL.Bind_Variable(l_cursor_id, ':1', l_change_line_id);
        DBMS_SQL.Describe_Columns(l_cursor_id, l_column_count, l_desc_table);

        FOR i IN 1 .. l_column_count
        LOOP
          --
          -- NOTE: ASSUMPTION: no PKs will ever be DATE objects
          --
          -------------------------------------------------------------
          -- We define all columns as VARCHAR2(1000) for convenience --
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

        l_pk_column_name_value_pairs :=
        EGO_COL_NAME_VALUE_PAIR_ARRAY(
          EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', NULL)
         ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', NULL)
        );


        -- l_object_id := Get_Object_Id_From_Name(G_EGO_ITEM);
        -- l_ext_table_metadata_obj
        --   := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(l_object_id);


        WHILE (DBMS_SQL.Fetch_Rows(l_cursor_id) > 0)
        LOOP

Write_Debug('----------- Fetch Mutl-Row Attr Change Rercord ---------- ' );

          l_current_column_index := 1;
          l_attr_name_value_pairs.DELETE();
          ------------------------------------
          -- Get the PK values for this row --
          ------------------------------------
          --   Item Id
          DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
          l_current_column_index := l_current_column_index + 1;
          l_pk_column_name_value_pairs(1).VALUE := SUBSTRB(l_retrieved_value, 1, 150);
          l_inventory_item_id := TO_NUMBER(l_retrieved_value) ;

Write_Debug('Item GDSN Multi-Row Change Item Id: ' || to_char(l_inventory_item_id));


          --   Org Id
          DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
          l_current_column_index := l_current_column_index + 1;
          l_pk_column_name_value_pairs(2).VALUE := SUBSTRB(l_retrieved_value, 1, 150);
          l_organization_id := TO_NUMBER(l_retrieved_value) ;


Write_Debug('Item GDSN Multi-Row Change Org Id: ' || to_char(l_organization_id));


          ----------------------------
          -- Determine the ACD Type --
          ----------------------------
          DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
          l_current_column_index := l_current_column_index + 1;
          l_current_acd_type := l_retrieved_value;

Write_Debug('Item GDSN Multi-Row Change ACD Type: ' || l_current_acd_type);

          --------------------------
          -- Get the extension ID --
          --------------------------
          DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
          l_current_column_index := l_current_column_index + 1;
          l_current_pending_ext_id := TO_NUMBER(l_retrieved_value);


Write_Debug('Item GDSN Multi-Row Change Extension Id: ' || to_char(l_current_pending_ext_id));

          ---------------------------------------------------------
          -- Find the Attr Group metadata from the Attr Group ID --
          ---------------------------------------------------------

          DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
          l_current_column_index := l_current_column_index + 1;
          l_attr_group_id := TO_NUMBER(l_retrieved_value) ;

Write_Debug('EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata for ' || to_char(l_attr_group_id));

          l_attr_group_metadata_obj :=
            EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
              p_attr_group_id => l_attr_group_id
            );

Write_Debug('After EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata ') ;

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
             l_attr_metadata_table := l_attr_group_metadata_obj.ATTR_METADATA_TABLE;
             l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                     p_attr_metadata_table => l_attr_metadata_table
                                    ,p_db_column_name      => l_current_column_name
                                   );

            ------------------------------------------------
            -- If the current column is an Attr column... --
            ------------------------------------------------
            IF (l_current_column_name = 'LANGUAGE') THEN

              -------------------------------------------------------
              -- Determine the Language for passing to Process_Row --
              -------------------------------------------------------
              l_current_row_language := l_retrieved_value;

Write_Debug('Current Lang: ' || l_current_row_language );


            ELSIF (l_current_column_name = 'SOURCE_LANG') THEN

              ------------------------------------------------
              -- Determine the Source Lang for knowing when --
              -- to insert a History row into the B table   --
              ------------------------------------------------
              l_current_row_source_lang := l_retrieved_value;
            END IF;

Write_Debug('Current Row Source Lang: ' || l_current_row_source_lang);

            --
            -- WE CAN NOT CONSTRUCT following PL/SQL Object dynamically
            -- using dynamic SQL
            -- So NO NEED TO Constuct this
            -- l_single_row_attrs_rec   EGO_ITEM_PUB.UCCNET_ATTRS_SINGL_ROW_REC_TYP ;
            -- l_multi_row_attrs_tbl    EGO_ITEM_PUB.UCCNET_ATTRS_MULTI_ROW_TBL_TYP;
            --
/************************************************************/
            IF (l_attr_metadata_obj IS NOT NULL AND
                 l_attr_metadata_obj.ATTR_NAME IS NOT NULL AND
                 l_current_column_index IS NOT NULL )
            THEN

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

        -------------------------------------------------------------------------
        --  No need to process UOM for Item Master AG Type
        --  ELSIF (INSTR(l_current_column_name, 'UOM_') = 1) THEN
        --
          --------------------------------------------
          -- Store the UOM column's name and value  --
          -- in a PL/SQL table for assignment below --
          --------------------------------------------
        --   l_uom_nv_pairs_index := l_uom_nv_pairs_index + 1;
        --   l_uom_column_nv_pairs(l_uom_nv_pairs_index) :=
        --     EGO_COL_NAME_VALUE_PAIR_OBJ(l_current_column_name, l_retrieved_value);
        --
        -------------------------------------------------------------------------
/***********************************************/

            END IF;
          END LOOP; -- l_current_column_index

          -------------------------------------------------------------------
          -- Now that we've got all necessary data and metadata, we try to --
          -- find a corresponding production row for this pending row; we  --
          -- use the new data level values if we have them, because we are --
          -- trying to see whether or not the row we're about to move into --
          -- the production table already exists there                     --
          -------------------------------------------------------------------

Write_Debug('calling EGO_USER_ATTRS_DATA_PVT.Get_Extension_Id. . .  ');

            l_current_production_ext_id
             := EGO_USER_ATTRS_DATA_PVT.Get_Extension_Id (
               p_object_name                      => G_EGO_ITEM
              ,p_attr_group_id                    => l_attr_group_id
              ,p_application_id                   => G_EGO_APPL_ID
              ,p_attr_group_type                  => G_EGO_ITEM_GTIN_MULTI_ATTRS
              ,p_pk_column_name_value_pairs       => l_pk_column_name_value_pairs
              ,p_data_level_name_value_pairs      => null
              ,p_attr_name_value_pairs            => l_attr_name_value_pairs
              ) ;
Write_Debug('After calling EGO_USER_ATTRS_DATA_PVT.Get_Extension_Id. Current Prod Ext Id: ' || to_char(l_current_production_ext_id));

          ---------------------------------------------------------------------
           -- The mode and extension ID we pass to Process_Row are determined --
           -- by the existence of a production row, the ACD Type, and in some --
           -- cases by whether the Attr Group is single-row or multi-row      --
           ---------------------------------------------------------------------
           IF (l_current_acd_type = G_ADD_ACD_TYPE) THEN

             IF (l_current_production_ext_id IS NULL) THEN
               ---------------------------------------
               -- If ACD Type is CREATE and there's --
               -- no production row, we create one  --
               ---------------------------------------
               l_mode_for_current_row := G_CREATE_TX_TYPE ;
               l_ext_id_for_current_row := l_current_pending_ext_id;
             ELSE
               ---------------------------------------------------------------
               -- We let the ADD + multi-row + existing production row case --
               -- through so Get_Extension_Id_And_Mode can throw the error  --
               ---------------------------------------------------------------
               l_mode_for_current_row := G_CREATE_TX_TYPE;
               l_ext_id_for_current_row := l_current_pending_ext_id;

             END IF;  -- l_current_production_ext_id IS NULL)

           ELSIF (l_current_acd_type = G_CHANGE_ACD_TYPE) THEN

             IF (l_current_production_ext_id IS NULL) THEN
                -------------------------------------------------------------
                -- In every case below, we'll use the pending extension ID --
                -------------------------------------------------------------
                l_ext_id_for_current_row := l_current_pending_ext_id;

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
                EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM '||l_mul_chg_b_table_name||
                                  ' WHERE EXTENSION_ID = :1'
                INTO l_dummy
                USING l_current_pending_ext_id;

                IF (l_dummy > 0) THEN
                  l_mode_for_current_row := G_UPDATE_TX_TYPE;

                ELSE
                  l_mode_for_current_row := G_CREATE_TX_TYPE;
                END IF;

             ELSE
               ---------------------------------------
               -- If ACD Type is CHANGE and there's --
               -- a production row, we change it    --
               ---------------------------------------
               l_mode_for_current_row := G_UPDATE_TX_TYPE;
               l_ext_id_for_current_row := l_current_production_ext_id;
             END IF;

           ELSIF (l_current_acd_type = G_DELETE_ACD_TYPE) THEN
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
               l_mode_for_current_row := G_DELETE_TX_TYPE;
               l_ext_id_for_current_row := l_current_production_ext_id;
             END IF;


          ELSE
              -- Invalid Case
Write_Debug('Item Attr Change Imple does not support ACD Type: '  || l_current_acd_type);

              -- We don't support this in R12
              FND_MESSAGE.Set_Name('ENG','ENG_IMPL_INVALID_ACD_TYPE');
              FND_MESSAGE.Set_Token('ACD_TYPE', l_current_acd_type);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;

          END IF;


          IF (l_mode_for_current_row <> 'SKIP')
          THEN

            -----------------------------------------------------------
            -- If we're altering a production row, we first copy the --
            -- row into the pending tables with the ACD Type HISTORY --
            -----------------------------------------------------------
            IF (l_mode_for_current_row = G_DELETE_TX_TYPE OR
                l_mode_for_current_row = G_UPDATE_TX_TYPE) THEN

              -----------------------------------------------------------
              -- Process_Row will only process our pending B table row --
              -- in the loop when LANGUAGE is NULL or when LANGUAGE =  --
              -- SOURCE_LANG, so we insert a History row in that loop  --
              -----------------------------------------------------------
              IF (l_current_row_language IS NULL OR
                  l_current_row_language = l_current_row_source_lang)
              THEN

Write_Debug('Inserting History Row with the ACD Type HISTORY for Multi-Row B table');

                l_utility_dynamic_sql := ' INSERT INTO '||l_mul_chg_b_table_name||' CT ('||
                                         l_mul_hist_b_chg_cols_list||
                                         ', CT.CREATED_BY,CT.CREATION_DATE,CT.LAST_UPDATED_BY'||
                                         ', CT.LAST_UPDATE_DATE, CT.LAST_UPDATE_LOGIN'||
                                         ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, CT.ACD_TYPE'||
                                         ', CT.INVENTORY_ITEM_ID, CT.ORGANIZATION_ID, CT.EXTENSION_ID, CT.ATTR_GROUP_ID) ' ||
                                         ' SELECT '||
                                         l_mul_hist_b_prod_cols_list||
                                         ', PT.CREATED_BY,PT.CREATION_DATE,PT.LAST_UPDATED_BY'||
                                         ', PT.LAST_UPDATE_DATE, PT.LAST_UPDATE_LOGIN'||
                                       ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'' '||
                                       ', PT.INVENTORY_ITEM_ID, PT.ORGANIZATION_ID, PT.EXTENSION_ID, PT.ATTR_GROUP_ID FROM '||
                                         l_mul_prod_b_table_name||' PT, '||
                                         l_mul_chg_b_table_name || ' CT ' ||
                                       ' WHERE PT.INVENTORY_ITEM_ID = :1'||
                                       ' AND PT.ORGANIZATION_ID = :2'||
                                       ' AND CT.INVENTORY_ITEM_ID = :3'||
                                       ' AND CT.ORGANIZATION_ID = :4'||
                                       ' AND CT.CHANGE_LINE_ID = :5'||
                                       ' AND CT.ACD_TYPE = :6' ||
                                       ' AND PT.EXTENSION_ID = :7'||
                                       ' AND CT.EXTENSION_ID = :8' ;



-- Write_Debug('Insert Stme:' || l_utility_dynamic_sql);
-- Write_Debug('l_ext_id_for_current_row:' || to_char(l_ext_id_for_current_row));
-- Write_Debug('l_current_pending_ext_id:' || to_char(l_current_pending_ext_id));


                EXECUTE IMMEDIATE l_utility_dynamic_sql
                USING l_inventory_item_id, l_organization_id,
                      l_inventory_item_id, l_organization_id,
                      l_change_line_id, l_current_acd_type,
                      l_ext_id_for_current_row, l_current_pending_ext_id ;


              END IF;


              ------------------------------------------------------------
              -- Process_Row will only process the pending TL table row --
              -- whose language matches LANGUAGE, so we only insert a   --
              -- History row for that row                               --
              ------------------------------------------------------------

Write_Debug('Inserting History Row with the ACD Type HISTORY for Multi-Row TL table');

              l_utility_dynamic_sql := ' INSERT INTO '||l_mul_chg_tl_table_name||' CT ('||
                                       l_mul_hist_tl_chg_cols_list||
                                       ', CT.CREATED_BY,CT.CREATION_DATE,CT.LAST_UPDATED_BY'||
                                       ', CT.LAST_UPDATE_DATE, CT.LAST_UPDATE_LOGIN'||
                                       ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, CT.ACD_TYPE '||
                                       ', CT.INVENTORY_ITEM_ID, CT.ORGANIZATION_ID,  CT.EXTENSION_ID, CT.ATTR_GROUP_ID ) ' ||
                                       ' SELECT '||
                                       l_mul_hist_tl_prod_cols_list||
                                       ', PT.CREATED_BY,PT.CREATION_DATE,PT.LAST_UPDATED_BY'||
                                       ', PT.LAST_UPDATE_DATE, PT.LAST_UPDATE_LOGIN'||
                                       ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'''||
                                       ', PT.INVENTORY_ITEM_ID, PT.ORGANIZATION_ID, PT.EXTENSION_ID, PT.ATTR_GROUP_ID FROM '||
                                       l_mul_prod_tl_table_name||' PT, '||
                                       l_mul_chg_tl_table_name||' CT ' ||
                                       ' WHERE PT.INVENTORY_ITEM_ID = :1'||
                                       ' AND PT.ORGANIZATION_ID = :2'||
                                       ' AND CT.INVENTORY_ITEM_ID = :3'||
                                       ' AND CT.ORGANIZATION_ID = :4'||
                                       ' AND CT.CHANGE_LINE_ID = :5'||
                                       ' AND CT.ACD_TYPE = :6'||
                                       ' AND PT.EXTENSION_ID = :7'||
                                       ' AND CT.EXTENSION_ID = :8' ||
                                       ' AND CT.LANGUAGE = PT.LANGUAGE AND CT.LANGUAGE = :9';

                EXECUTE IMMEDIATE l_utility_dynamic_sql
                USING l_inventory_item_id, l_organization_id,
                      l_inventory_item_id, l_organization_id,
                      l_change_line_id, l_current_acd_type,
                      l_ext_id_for_current_row, l_current_pending_ext_id ,
                      l_current_row_language;

            END IF; -- Check l_mode_for_current_row


          END IF; -- l_mode_for_current_row <> 'SKIP'


        END LOOP; -- DBMS_SQL.Fetch_Rows Loop
        DBMS_SQL.Close_Cursor(l_cursor_id);

Write_Debug('--------------------------------------------------' );
Write_Debug('After Processing Item GDSN Mult-Row Changes . . . ' );

    END IF ;  -- l_multi_row_change_found



    GetNLSLanguage(l_orig_nls_lang,l_orig_territory,l_orig_chrs);



    FOR l_rec IN c_lang
    LOOP
        l_installed_flag := l_rec.INSTALLED_FLAG ;
        l_lang_code := l_rec.LANGUAGE_CODE;
        l_nls_lang  := l_rec.NLS_LANGUAGE;
        l_territory := l_rec.NLS_TERRITORY ;

        -- Set NLS Lang so that the row for lang is processed correctly
        SetNLSLanguage(l_nls_lang ,l_territory);

Write_Debug('Constructing GDSN Attribute Rows PL/SQL Objects . .. '  ) ;
Write_Debug('for Lang Code: ' || l_lang_code || ' - Installed Flag: ' || l_installed_flag  );
Write_Debug('NLS Lang : ' || l_nls_lang || ' - NLS Territory: ' || l_territory );
Write_Debug('Calling ENG_CHANGE_IMPORT_UTIL.MERGE_GDSN_PENDING_CHG_ROWS. . . ' );

        l_multi_row_attrs_tbl.DELETE;
        ENG_CHANGE_IMPORT_UTIL.MERGE_GDSN_PENDING_CHG_ROWS
        ( p_inventory_item_id    => l_inventory_item_id
         ,p_organization_id      => l_organization_id
         ,p_change_id            => l_change_id
         ,p_change_line_id       => l_change_line_id
         ,p_acd_type             => NULL
         ,x_single_row_attrs_rec => l_single_row_attrs_rec
         ,x_multi_row_attrs_tbl  => l_multi_row_attrs_tbl
         ,x_extra_attrs_rec      => l_extra_attrs_rec
        ) ;

Write_Debug('After ENG_CHANGE_IMPORT_UTIL.MERGE_GDSN_PENDING_CHG_ROWS. . . ' );



        BEGIN
Write_Debug('Calling EGO_GTIN_ATTRS_PVT.Process_UCCnet_Attrs_For_Item . . . ' );

            EGO_GTIN_ATTRS_PVT.Process_UCCnet_Attrs_For_Item(
              p_api_version                   => p_api_version
             ,p_check_policy                  => FND_API.G_FALSE
             ,p_inventory_item_id             => l_inventory_item_id
             ,p_organization_id               => l_organization_id
             ,p_single_row_attrs_rec          => l_single_row_attrs_rec
             ,p_multi_row_attrs_table         => l_multi_row_attrs_tbl
             ,p_entity_id                     => null
             ,p_entity_index                  => null
             ,p_entity_code                   => G_BO_IDENTIFIER
             ,p_init_error_handler            => FND_API.G_FALSE
             ,p_commit                        => FND_API.G_FALSE
             ,x_return_status                 => l_return_status
             ,x_errorcode                     => l_errorcode
             ,x_msg_count                     => l_msg_count
             ,x_msg_data                      => l_msg_data);


        EXCEPTION
           WHEN OTHERS THEN

                FND_MSG_PUB.Add_Exc_Msg
                ( p_pkg_name            => 'EGO_GTIN_ATTRS_PVT' ,
                  p_procedure_name      => 'Process_UCCnet_Attrs_For_Item',
                  p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
                );

                FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
                FND_MESSAGE.Set_Token('OBJECT_NAME', 'EGO_GTIN_ATTRS_PVT.Process_UCCnet_Attrs_For_Item');
                FND_MSG_PUB.Add;

Write_Debug('When Others Exception while calling EGO_GTIN_ATTRS_PVT.Process_UCCnet_Attrs_For_Item' || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


        END ;


Write_Debug('After Calling EGO_GTIN_ATTRS_PVT.Process_UCCnet_Attrs_For_Item. Return Status: ' || l_return_status );

        IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS)
        THEN

          Write_Debug('EGO_GTIN_ATTRS_PVT.Process_UCCnet_Attrs_For_Item failed . ..  ' );
          Write_Debug('Output - Return Stattus: '  || l_return_status);
          Write_Debug('Output - Return Stattus: '  || to_char(l_msg_count));
--          Write_Debug('Output - Return Stattus: '  || substr(l_msg_data,1,200));
          FOR cnt IN 1..l_msg_count LOOP
            Write_Debug('Error msg - '||cnt ||': '|| FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F'));
          END LOOP;



            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            FND_MESSAGE.Set_Token('OBJECT_NAME', 'EGO_GTIN_ATTRS_PVT.Process_UCCnet_Attrs_For_Item');
            FND_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR ;

        END IF;


    END LOOP ;  -- installed lang loop

    -- reset the existing session language
    WF_Notification.SetNLSLanguage(l_orig_nls_lang,l_orig_territory);



    ---------------------------------------------------------------------------
    -- Finally, set the IMPLEMENTATION_DATE for all rows we just implemented --
    ---------------------------------------------------------------------------
    IF l_single_row_change_found
    THEN

        EXECUTE IMMEDIATE ' UPDATE '||l_chg_b_table_name||
                             ' SET IMPLEMENTATION_DATE = :1'||
                           ' WHERE CHANGE_LINE_ID = :2'
        USING SYSDATE, p_change_line_id;

        EXECUTE IMMEDIATE ' UPDATE '||l_chg_tl_table_name||
                             ' SET IMPLEMENTATION_DATE = :1'||
                           ' WHERE CHANGE_LINE_ID = :2'
        USING SYSDATE, p_change_line_id;


    END IF ;

    IF l_multi_row_change_found
    THEN

Write_Debug('set the IMPLEMENTATION_DATE for all rows we just implemented');

        EXECUTE IMMEDIATE ' UPDATE '||l_mul_chg_b_table_name||
                             ' SET IMPLEMENTATION_DATE = :1'||
                           ' WHERE CHANGE_LINE_ID = :2'
        USING SYSDATE, p_change_line_id;

        EXECUTE IMMEDIATE ' UPDATE '||l_mul_chg_tl_table_name||
                             ' SET IMPLEMENTATION_DATE = :1'||
                           ' WHERE CHANGE_LINE_ID = :2'
        USING SYSDATE, p_change_line_id;


    END IF ;
Write_Debug('In Implement Item GDSN Attribute Change, Done');
    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('COMMIT Item GDSN Attribute Change Implementation');
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
Write_Debug('When G_EXC_ERROR Exception in impl_rev_item_gdsn_attr_chgs');

    x_return_status := G_RET_STS_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK  Item GDSN Attribute Change Implementation TO IMPL_REV_ITEM_GDSN_ATTR_CHGS');
      ROLLBACK TO IMPL_REV_ITEM_GDSN_ATTR_CHGS;
    END IF;

    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_gdsn_attr_chgs for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;


    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
Write_Debug('When G_EXC_UNEXPECTED_ERROR Exception in impl_rev_item_gdsn_attr_chgs');

    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK  Item GDSN Attribute Change Implementation TO IMPL_REV_ITEM_GDSN_ATTR_CHGS');
      ROLLBACK TO IMPL_REV_ITEM_GDSN_ATTR_CHGS;
    END IF;


    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_gdsn_attr_chgs for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;

  WHEN OTHERS THEN

Write_Debug('When Others Exception in impl_rev_item_gdsn_attr_chgs');

    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK  Item GDSN Attribute Change Implementation TO IMPL_REV_ITEM_GDSN_ATTR_CHGS');
      ROLLBACK TO IMPL_REV_ITEM_GDSN_ATTR_CHGS;
    END IF;


Write_Debug('When Others Exception ' || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));

    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_gdsn_attr_chgs for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;


    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;

END  impl_rev_item_gdsn_attr_chgs ;


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
    l_data_level_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY ;
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
    l_impl_attr_name_value_pairs    EGO_USER_ATTR_DATA_TABLE := EGO_USER_ATTR_DATA_TABLE();
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
    L_ATTR_GROUP_ID          NUMBER;
    L_PREV_EXT_ID     NUMBER:=-1;
    L_DATA_LEVEL_ID          NUMBER;
    L_DATA_LEVEL_NAME       VARCHAR2(80);
    L_DATA_LEVEL_META_DATA   EGO_DATA_LEVEL_METADATA_OBJ;

  BEGIN

    IF FND_API.To_Boolean( p_commit ) THEN
      -- Standard start of API savepoint
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

-----------------------------------

Write_Debug('In Implement_Change_Line, starting');

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


Write_Debug('After PKs data. . .');

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


    ---------------------------------------------------------------
    -- Next, we add to the lists the rest of the columns that we --
    -- either want to get explicitly or don't want to get at all --
    ---------------------------------------------------------------
    l_chng_col_names_list := l_chng_col_names_list||
                                ',B.ACD_TYPE,B.ATTR_GROUP_ID,B.EXTENSION_ID' ||
                                ',B.DATA_LEVEL_ID' ||
	                              ',B.REVISION_ID,B.PK1_VALUE'||
	                              ',B.PK2_VALUE,B.PK3_VALUE'||
	                              ',B.PK4_VALUE,B.PK5_VALUE';

    l_cols_to_exclude_list := l_cols_to_exclude_list||
                                ',''DATA_LEVEL_ID''' ||
	                              ',''REVISION_ID'',''PK1_VALUE'''||
	                              ',''PK2_VALUE'',''PK3_VALUE'''||
	                              ',''PK4_VALUE'',''PK5_VALUE'''||
                                ',''ACD_TYPE'',''ATTR_GROUP_ID'',''EXTENSION_ID'''||
                                ',''CHANGE_ID'',''CHANGE_LINE_ID'''||
                                ',''IMPLEMENTATION_DATE'',''CREATED_BY'''||
                                ',''CREATION_DATE'',''LAST_UPDATED_BY'''||
                                ',''LAST_UPDATE_DATE'',''LAST_UPDATE_LOGIN''';

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
    l_cols_to_exclude_list := '''CHANGE_ID'', ''CHANGE_LINE_ID'', ''ACD_TYPE'', ''IMPLEMENTATION_DATE'''||
			      ', ''EXTENSION_ID'' ,''DATA_LEVEL_ID'',''PK1_VALUE'',''PK2_VALUE'',''PK3_VALUE'''||
			      ',''PK4_VALUE'', ''PK5_VALUE'',''PROGRAM_ID'', ''PROGRAM_UPDATE_DATE'' , ''REQUEST_ID'' ,''PROGRAM_APPLICATION_ID'' ';
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


Write_Debug('After get meta data for user def attr production and table meta data. . .');

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
                       ' AND B.CHANGE_LINE_ID = :1 ' ||
                       ' ORDER BY B.EXTENSION_ID';

    l_cursor_id := DBMS_SQL.Open_Cursor;
    DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.Native);
    DBMS_SQL.Bind_Variable(l_cursor_id, ':1', p_change_line_id);
    DBMS_SQL.Describe_Columns(l_cursor_id, l_column_count, l_desc_table);
    write_debug('Sql formed for the attr changes : ' || l_dynamic_sql);
    FOR i IN 1 .. l_column_count
    LOOP

--
-- ASSUMPTION: no PKs will ever be DATE objects
--
      -------------------------------------------------------------
      -- We define all columns as VARCHAR2(1000) for convenience --
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

	Write_Debug('Current Item catalog category id in : ' || TO_CHAR(l_class_code_name_value_pairs(1).VALUE));
        EXECUTE IMMEDIATE 'BEGIN '||p_related_class_code_function||'(:1, :2); END;'
        USING IN  l_class_code_name_value_pairs(1).VALUE,
              OUT l_class_code_name_value_pairs(2).VALUE;
	if l_class_code_name_value_pairs(2).VALUE is not null
	then
		Write_Debug('Current p_related_class_code in : ' || TO_CHAR(l_class_code_name_value_pairs(2).VALUE));
	end if;
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
      L_ATTR_GROUP_ID := TO_NUMBER(l_retrieved_value);
      l_attr_group_metadata_obj :=
        EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
          p_attr_group_id => L_ATTR_GROUP_ID
        );

      --------------------------
      -- Get the extension ID --
      --------------------------
      DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
      l_current_column_index := l_current_column_index + 1;
      l_current_pending_ext_id := TO_NUMBER(l_retrieved_value);

      Write_Debug('Current Pending Ext Id : ' || TO_CHAR(l_current_pending_ext_id));


      ---------------------------------------------------------
      -- Find the Attr Data Level and Data Level Pks
      ---------------------------------------------------------
 		    DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
	      l_current_column_index := l_current_column_index + 1;
	      L_DATA_LEVEL_ID := TO_NUMBER(l_retrieved_value);
        Write_Debug('Current data level Id : ' || TO_CHAR(L_DATA_LEVEL_ID));
        if L_DATA_LEVEL_ID is not NULL
        then
          L_DATA_LEVEL_META_DATA := EGO_USER_ATTRS_COMMON_PVT.Get_Data_Level_Metadata(L_DATA_LEVEL_ID);
          L_DATA_LEVEL_NAME := L_DATA_LEVEL_META_DATA.DATA_LEVEL_NAME;
        Write_Debug('Current data level name  : ' || TO_CHAR(L_DATA_LEVEL_NAME));

	      IF L_DATA_LEVEL_NAME='ITEM_REVISION_LEVEL'
	        THEN
	            DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
	            l_current_column_index := l_current_column_index + 5;
	            l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ(
	                                                  L_DATA_LEVEL_META_DATA.PK_COLUMN_NAME1,
	                                                  l_retrieved_value));


	        ELSE
		          l_data_level_name_value_pairs :=   EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ(
	                                              						 null,
	                                                 					 null));
	            l_current_column_index := l_current_column_index + 1;
              if  L_DATA_LEVEL_META_DATA.PK_COLUMN_NAME1 IS NOT NULL
              THEN
                      DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);

                      --l_current_column_index := l_current_column_index + 1;
                      l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ(
                                                        L_DATA_LEVEL_META_DATA.PK_COLUMN_NAME1,
                                                         l_retrieved_value));
            --  ELSE
                  --  l_current_column_index := l_current_column_index + 1;

              END IF;
              l_current_column_index := l_current_column_index + 1;
	            if  L_DATA_LEVEL_META_DATA.PK_COLUMN_NAME2 IS NOT NULL
	            THEN

	                DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
	                --l_current_column_index := l_current_column_index + 1;
	                l_data_level_name_value_pairs.EXTEND;
	                l_data_level_name_value_pairs(l_data_level_name_value_pairs.LAST):= EGO_COL_NAME_VALUE_PAIR_OBJ(
	                                                 L_DATA_LEVEL_META_DATA.PK_COLUMN_NAME2,
	                                                 l_retrieved_value);
	            -- else
	                --l_current_column_index := l_current_column_index + 1;

	             END IF;
               l_current_column_index := l_current_column_index + 1;
	            if  L_DATA_LEVEL_META_DATA.PK_COLUMN_NAME3 IS NOT NULL
	            THEN

	                DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
	              --  l_current_column_index := l_current_column_index + 1;
	               l_data_level_name_value_pairs.EXTEND;
	                l_data_level_name_value_pairs(l_data_level_name_value_pairs.LAST):= EGO_COL_NAME_VALUE_PAIR_OBJ(
	                                                 L_DATA_LEVEL_META_DATA.PK_COLUMN_NAME3,
	                                                 l_retrieved_value);
	            -- else
	               -- l_current_column_index := l_current_column_index + 1;

               END IF;
	             l_current_column_index := l_current_column_index + 1;
	            if  L_DATA_LEVEL_META_DATA.PK_COLUMN_NAME4 IS NOT NULL
	            THEN

	                DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
	                --l_current_column_index := l_current_column_index + 1;
	               l_data_level_name_value_pairs.EXTEND;
	                l_data_level_name_value_pairs(l_data_level_name_value_pairs.LAST):= EGO_COL_NAME_VALUE_PAIR_OBJ(
	                                                 L_DATA_LEVEL_META_DATA.PK_COLUMN_NAME4,
	                                                 l_retrieved_value);
	             --else
	                --l_current_column_index := l_current_column_index + 1;

               END IF;
               l_current_column_index := l_current_column_index + 1;
	            if  L_DATA_LEVEL_META_DATA.PK_COLUMN_NAME5 IS NOT NULL
	            THEN

	               DBMS_SQL.Column_Value(l_cursor_id, l_current_column_index, l_retrieved_value);
	               --l_current_column_index := l_current_column_index + 1;
	               l_data_level_name_value_pairs.EXTEND;
	               l_data_level_name_value_pairs(l_data_level_name_value_pairs.LAST):= EGO_COL_NAME_VALUE_PAIR_OBJ(
	                                                 L_DATA_LEVEL_META_DATA.PK_COLUMN_NAME5,
	                                                 l_retrieved_value);
	             --else
	               -- l_current_column_index := l_current_column_index + 1;
	            END IF;
              l_current_column_index := l_current_column_index + 1;
	      END IF;
      END if ;

      ---------------------------------------------------------------
      -- Determine whether this Attr Group needs Data Level values --
      ---------------------------------------------------------------


      IF (EGO_USER_ATTRS_DATA_PVT.Is_Data_Level_Correct(l_object_id
                               ,l_attr_group_metadata_obj.ATTR_GROUP_ID
                               ,l_ext_table_metadata_obj
                               ,l_class_code_name_value_pairs
                               ,l_data_level_name
                               ,l_data_level_name_value_pairs
                               ,l_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME
                               ,l_dummy_err_msg_name
                               ,l_token_table)) THEN
        l_current_dl_name_value_pairs := l_data_level_name_value_pairs;
      ELSE
        --------------------------------------------------------------------
        -- If the passed-in Data Levels are incorrect (e.g., they include --
        -- Revision ID for an Attr Group associated at the Item level),   --
        -- we will try to pass NULL and hope it works.  NOTE: this is an  --
        -- imperfect fix; it'll work for Items, but maybe not in general  --
        --------------------------------------------------------------------

--
-- TO DO: make this logic more robust; right now it assumes that either
-- we use all the passed-in Data Levels or none of them, but what about
-- someday if there's a multi-DL implementation (i.e., one in which there's
-- more than a binary situation of "passing DL" or "not passing DL"--e.g.,
-- "passing some but not all DL")?
--
        l_token_table.DELETE();
        l_current_dl_name_value_pairs := NULL;
      END IF;


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
      --  write_debug(l_current_column_name||' : ' || l_retrieved_value);
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
              l_current_pending_ext_id -- Current Pending Ext Id
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
       IF (l_current_acd_type = 'CHANGE')
       THEN
       Write_Debug('Calling ENG_CHANGE_ATTR_UTIL.SETUP_IMPL_ATTR_DATA_ROW. . .');




        ENG_CHANGE_ATTR_UTIL.SETUP_IMPL_ATTR_DATA_ROW
        (
         p_api_version                  =>  p_api_version
        ,p_object_name                  =>  p_object_name
        ,p_attr_group_id                =>  l_attr_group_metadata_obj.ATTR_GROUP_ID
        ,p_application_id               =>  l_attr_group_metadata_obj.APPLICATION_ID
        ,p_attr_group_type              =>  l_attr_group_metadata_obj.ATTR_GROUP_TYPE
        ,p_attr_group_name              =>  l_attr_group_metadata_obj.ATTR_GROUP_NAME
        ,p_pk_column_name_value_pairs   =>  l_pk_column_name_value_pairs
        ,p_class_code_name_value_pairs  =>  l_class_code_name_value_pairs
        ,p_data_level_name              =>  L_DATA_LEVEL_NAME
        ,p_data_level_name_value_pairs  =>  l_current_dl_name_value_pairs
        ,p_attr_name_value_pairs        =>  l_attr_name_value_pairs
        ,x_setup_attr_data              =>  l_impl_attr_name_value_pairs
        ,x_return_status                =>  x_return_status
        ,x_errorcode                    =>  x_errorcode
        ,x_msg_count                    =>  x_msg_count
        ,x_msg_data                     =>  x_msg_data
        );

        ELSIF (l_current_acd_type = 'ADD' OR l_current_acd_type = 'DELETE'  )
        THEN
          l_impl_attr_name_value_pairs := l_attr_name_value_pairs;
        END IF;

      l_current_production_ext_id :=
        EGO_USER_ATTRS_DATA_PVT.Get_Extension_Id_For_Row(
          p_attr_group_metadata_obj     => l_attr_group_metadata_obj
         ,p_ext_table_metadata_obj      => l_ext_table_metadata_obj
         ,p_pk_column_name_value_pairs  => l_pk_column_name_value_pairs
         ,p_data_level                  => l_data_level_name
         ,p_data_level_name_value_pairs => l_current_dl_name_value_pairs
         ,p_attr_name_value_pairs       => l_impl_attr_name_value_pairs
        );


Write_Debug('Current Production Ext Id : ' || TO_CHAR(l_current_production_ext_id));


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
Write_Debug('Current Acd Type : ADD  and there is no production row with pk same values ');

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
Write_Debug('Current Acd Type : ADD  and there is a  production row with pk same values ');
Write_Debug('IN case of single-row Attr Group, we will update the value');


            l_mode_for_current_row := G_UPDATE_TX_TYPE;
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

Write_Debug('Current Acd Type : ADD  and there is a  production row with pk same values ');
Write_Debug('IN case of multi-row Attr Group, we will let it trough and get exception later');

            ---------------------------------------------------------------
            -- We let the ADD + multi-row + existing production row case --
            -- through so Get_Extension_Id_And_Mode can throw the error  --
            ---------------------------------------------------------------
            l_mode_for_current_row := G_IMPLEMENT_CREATE_MODE;
            l_ext_id_for_current_row := l_current_pending_ext_id;
          END IF;
        END IF;
      ELSIF (l_current_acd_type = 'CHANGE') THEN
        IF (l_current_production_ext_id IS NULL ) THEN
          -------------------------------------------------------------
          -- In every case below, we'll use the pending extension ID --
          -------------------------------------------------------------
          l_ext_id_for_current_row := l_current_pending_ext_id;
--
-- TO DO: check if pendingExtID is in prod; if so, error
--

          IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'N') THEN

Write_Debug('Current Acd Type : CHANGE  and there is a  production row with pk same values ');
Write_Debug('IN case of multi-row Attr Group, we will let it trough and get exception later');
            -------------------------------------------------------
            -- If ACD Type is CHANGE, there's no production row, --
            -- and it's a single-row Attr Group, that means that --
            -- the row was somehow deleted since this change was --
            -- proposed, so we'll need to re-insert the row.     --
            -------------------------------------------------------
            l_mode_for_current_row := G_IMPLEMENT_CREATE_MODE;
          ELSE

Write_Debug('Current Acd Type CHANGE:  and there is NO  production row with pk same values ');
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
Write_Debug('Set Update mode to this row');
              l_mode_for_current_row := G_UPDATE_TX_TYPE;
            ELSE
Write_Debug('Set Create mode to this row');
              l_mode_for_current_row := G_IMPLEMENT_CREATE_MODE;
            END IF;
          END IF;
        ELSE
          ---------------------------------------
          -- If ACD Type is CHANGE and there's --
          -- a production row, we change it    --
          ---------------------------------------
          l_mode_for_current_row := G_UPDATE_TX_TYPE;
          l_ext_id_for_current_row := l_current_production_ext_id;
        END IF;
      ELSIF (l_current_acd_type = 'DELETE') THEN

Write_Debug('Current Acd Type DELETE: check the pending ext id row exits in prod table');

        -- R12, we don't store no-change attr in pending table
        -- l_current_production_ext_id is always null
        -- So we check if a record with pend ext id does exist in prod table
        -- If yes, delete the prod record

        -- IF (l_current_production_ext_id IS NULL) THEN
          ---------------------------------------
          -- If ACD Type is DELETE and there's --
          -- no production row, we do nothing  --
          ---------------------------------------
            EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM '|| p_production_b_table_name ||
                              ' WHERE EXTENSION_ID = :1'
            INTO l_dummy
            USING l_current_pending_ext_id;

            IF (l_dummy > 0) THEN

Write_Debug('Set Delete mode to this row');

              l_mode_for_current_row := G_DELETE_TX_TYPE ;
              l_current_production_ext_id := l_current_pending_ext_id ;
              l_ext_id_for_current_row := l_current_pending_ext_id ;

            ELSE

Write_Debug('Set Skip  mode to this row ');
              l_mode_for_current_row := 'SKIP';
            END IF;

        -- ELSE
          ---------------------------------------
          -- If ACD Type is DELETE and there's --
          -- a production row, we delete it    --
          ---------------------------------------
        -- l_mode_for_current_row := G_DELETE_TX_TYPE;
        -- l_ext_id_for_current_row := l_current_production_ext_id;
        -- END IF;
      END IF;

      IF (l_mode_for_current_row <> 'SKIP') THEN

        -----------------------------------------------------------
        -- If we're altering a production row, we first copy the --
        -- row into the pending tables with the ACD Type HISTORY --
        -----------------------------------------------------------
        IF (l_mode_for_current_row = G_DELETE_TX_TYPE OR
            l_mode_for_current_row = G_UPDATE_TX_TYPE) THEN
          -----------------------------------------------------------
          -- Process_Row will only process our pending B table row --
          -- in the loop when LANGUAGE is NULL or when LANGUAGE =  --
          -- SOURCE_LANG, so we insert a History row in that loop  --
          -----------------------------------------------------------
          /* BUG 5388684  As the source lang may not be the first record to get processed.
             in case its add case for Single row then if the other language record goes first
             which is used to insert history record which is wrong.
          */
          /*IF (l_current_row_language IS NULL OR
              l_current_row_language = l_current_row_source_lang) THEN*/
          IF L_PREV_EXT_ID <> l_ext_id_for_current_row THEN
            l_utility_dynamic_sql := ' INSERT INTO '||p_change_b_table_name||' CT ('||
                                     l_history_b_chng_cols_list||
                                     ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, CT.ACD_TYPE'||
                                     ', CT.EXTENSION_ID,CT.DATA_LEVEL_ID '||
				     ', CT.PK1_VALUE, CT.PK2_VALUE, CT.PK3_VALUE '||
				     ', CT.PK4_VALUE, CT.PK5_VALUE )SELECT '||
                                     l_history_b_prod_cols_list||
                                     ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'''||
                                     ', PT.EXTENSION_ID, CT.DATA_LEVEL_ID '||
				     ', CT.PK1_VALUE, CT.PK2_VALUE, CT.PK3_VALUE '||
				     ', CT.PK4_VALUE, CT.PK5_VALUE FROM '||
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
                                   ', CT.EXTENSION_ID,CT.DATA_LEVEL_ID '||
				     ', CT.PK1_VALUE, CT.PK2_VALUE, CT.PK3_VALUE '||
				     ', CT.PK4_VALUE, CT.PK5_VALUE ) SELECT '||
                                   l_history_tl_prod_cols_list||
                                   ', CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'''||
                                   ', PT.EXTENSION_ID, CT.DATA_LEVEL_ID '||
				     ', CT.PK1_VALUE, CT.PK2_VALUE, CT.PK3_VALUE '||
				     ', CT.PK4_VALUE, CT.PK5_VALUE FROM '||
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

        ELSIF (l_mode_for_current_row = G_IMPLEMENT_CREATE_MODE) THEN -- BUG 5340167
             IF L_PREV_EXT_ID <> l_ext_id_for_current_row THEN
                l_utility_dynamic_sql := ' INSERT INTO '||p_change_b_table_name||' CT ('||
                                         ' CT.CHANGE_ID, CT.CHANGE_LINE_ID, CT.ACD_TYPE'||
                                         ', CT.EXTENSION_ID,CT.ATTR_GROUP_ID '||
                                         ', CT.ORGANIZATION_ID ,CT.INVENTORY_ITEM_ID '||
                                         ', CT.ITEM_CATALOG_GROUP_ID, CT.REVISION_ID, CT.CREATED_BY '||
                                         ', CT.CREATION_DATE , CT.LAST_UPDATE_DATE ' ||
                                         ', CT.LAST_UPDATE_LOGIN, CT.LAST_UPDATED_BY, CT.DATA_LEVEL_ID '||
					 ', CT.PK1_VALUE, CT.PK2_VALUE, CT.PK3_VALUE '||
					 ', CT.PK4_VALUE, CT.PK5_VALUE '||
                                         '  ) SELECT '||
                                         '  CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'''||
                                         ', CT.EXTENSION_ID ,CT.ATTR_GROUP_ID '||
                                         ', CT.ORGANIZATION_ID , CT.INVENTORY_ITEM_ID '||
                                         ', CT.ITEM_CATALOG_GROUP_ID,CT.REVISION_ID, CT.CREATED_BY '||
                                         ', CT.CREATION_DATE , CT.LAST_UPDATE_DATE ' ||
                                         ', CT.LAST_UPDATE_LOGIN, CT.LAST_UPDATED_BY, CT.DATA_LEVEL_ID '||
					 ', CT.PK1_VALUE, CT.PK2_VALUE, CT.PK3_VALUE '||
					 ', CT.PK4_VALUE, CT.PK5_VALUE '||
					 ' FROM '||
                                          p_change_b_table_name || ' CT '||
                                         ' WHERE CT.EXTENSION_ID = :1'||
                                         ' AND CT.CHANGE_LINE_ID = :2'||
                                         ' AND CT.ACD_TYPE = :3';

                EXECUTE IMMEDIATE l_utility_dynamic_sql
                USING l_current_pending_ext_id,
                      p_change_line_id, l_current_acd_type;

            END IF;

             l_utility_dynamic_sql := ' INSERT INTO '|| p_change_tl_table_name||' CT ('||
                                         ' CT.CHANGE_ID, CT.CHANGE_LINE_ID, CT.ACD_TYPE'||
                                         ', CT.EXTENSION_ID, CT.ATTR_GROUP_ID '||
                                         ', CT.ORGANIZATION_ID ,CT.INVENTORY_ITEM_ID '||
                                         ', CT.ITEM_CATALOG_GROUP_ID,  CT.REVISION_ID, CT.CREATED_BY '||
                                         ', CT.CREATION_DATE , CT.LAST_UPDATE_DATE ' ||
                                         ', CT.LAST_UPDATE_LOGIN, CT.LAST_UPDATED_BY '||
                                         ', CT.SOURCE_LANG,CT.LANGUAGE,CT.DATA_LEVEL_ID '||
					 ', CT.PK1_VALUE, CT.PK2_VALUE, CT.PK3_VALUE '||
					 ', CT.PK4_VALUE, CT.PK5_VALUE ) SELECT '||
                                         '  CT.CHANGE_ID, CT.CHANGE_LINE_ID, ''HISTORY'''||
                                         ', CT.EXTENSION_ID, CT.ATTR_GROUP_ID '||
                                         ', CT.ORGANIZATION_ID , CT.INVENTORY_ITEM_ID '||
                                         ', CT.ITEM_CATALOG_GROUP_ID, CT.REVISION_ID, CT.CREATED_BY '||
                                         ', CT.CREATION_DATE , CT.LAST_UPDATE_DATE ' ||
                                         ', CT.LAST_UPDATE_LOGIN, CT.LAST_UPDATED_BY '||
                                         ', CT.SOURCE_LANG , CT.LANGUAGE , CT.DATA_LEVEL_ID '||
					 ', CT.PK1_VALUE, CT.PK2_VALUE, CT.PK3_VALUE '||
					 ', CT.PK4_VALUE, CT.PK5_VALUE '||
					 ' FROM '||
                                          p_change_tl_table_name || ' CT '||
                                         ' WHERE CT.EXTENSION_ID = :1'||
                                         ' AND CT.CHANGE_LINE_ID = :2'||
                                         ' AND CT.ACD_TYPE = :3'||
                                         ' AND CT.LANGUAGE = :4';

          EXECUTE IMMEDIATE l_utility_dynamic_sql
          USING l_ext_id_for_current_row, p_change_line_id, l_current_acd_type, l_current_row_language;
          -- BUG 5340167
        END IF;

Write_Debug('After Calling ENG_CHANGE_ATTR_UTIL.SETUP_IMPL_ATTR_DATA_ROW: Return Status: ' || x_return_status );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN

Write_Debug('Raising error after ENG_CHANGE_ATTR_UTIL '  );

             RAISE FND_API.G_EXC_ERROR;
        END IF;


Write_Debug('Calling EGO_USER_ATTRS_DATA_PVT.Process_Row '  );
        if l_mode_for_current_row = G_IMPLEMENT_CREATE_MODE  AND L_PREV_EXT_ID = l_ext_id_for_current_row
        THEN
              l_mode_for_current_row  := G_UPDATE_TX_TYPE;
        END IF;
Write_Debug('ATTR_GROUP_ID  '  || to_char( l_attr_group_metadata_obj.ATTR_GROUP_ID));
Write_Debug('ATTR_GROUP_TYPE ' ||  l_attr_group_metadata_obj.ATTR_GROUP_TYPE );
Write_Debug('ATTR_GROUP_NAME ' ||  l_attr_group_metadata_obj.ATTR_GROUP_NAME );
Write_Debug('l_data_level_name '|| l_data_level_name );
Write_Debug('Transaction Mode '|| l_mode_for_current_row );
Write_Debug('Extension ID  '|| to_char(l_ext_id_for_current_row ));

        ---------------------------------------------------------------------
        -- Now at last we're ready to call Process_Row on this pending row --
        ---------------------------------------------------------------------
for i in l_impl_attr_name_value_pairs.first .. l_impl_attr_name_value_pairs.last
loop
	Write_Debug('Name  '  || to_char( l_impl_attr_name_value_pairs(i).ATTR_NAME));
	Write_Debug('value  '  || to_char( l_impl_attr_name_value_pairs(i).ATTR_VALUE_STR));
end loop;
        EGO_USER_ATTRS_DATA_PVT.Process_Row(
          p_api_version                   => 1.0
         ,p_object_name                   => p_object_name
         ,p_attr_group_id                 => l_attr_group_metadata_obj.ATTR_GROUP_ID
         ,p_application_id                => l_attr_group_metadata_obj.APPLICATION_ID
         ,p_attr_group_type               => l_attr_group_metadata_obj.ATTR_GROUP_TYPE
         ,p_attr_group_name               => l_attr_group_metadata_obj.ATTR_GROUP_NAME
         ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
         ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
         ,p_data_level                    => l_data_level_name
         ,p_data_level_name_value_pairs   => l_current_dl_name_value_pairs
         ,p_extension_id                  => l_ext_id_for_current_row
         ,p_attr_name_value_pairs         => l_impl_attr_name_value_pairs
         ,p_language_to_process           => l_current_row_language
         ,p_mode                          => l_mode_for_current_row
         ,p_add_errors_to_fnd_stack       => FND_API.G_TRUE
         ,x_return_status                 => x_return_status
         ,x_errorcode                     => x_errorcode
         ,x_msg_count                     => x_msg_count
         ,x_msg_data                      => x_msg_data
        );

Write_Debug('After Calling EGO_USER_ATTRS_DATA_PVT.Process_Row: Return Status: ' || x_return_status );
        L_PREV_EXT_ID := l_ext_id_for_current_row;

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

    -- Developer: CHECHAND - Bug# 9742219 - Begin
    -- Description: Implementation of ECO doesnot refelect regenerated item description at master org, in all organization item entries.
    -- Synching description of all org items to the description of the master item.
    BEGIN
    FOR rec IN (SELECT inventory_item_id, description , LANGUAGE FROM mtl_system_items_tl WHERE
    inventory_item_id = (SELECT DISTINCT INVENTORY_ITEM_ID FROM EGO_ITEMS_ATTRS_CHANGES_B WHERE change_line_id = p_change_line_id)
    AND ORGANIZATION_ID = (SELECT DISTINCT ORGANIZATION_ID FROM EGO_ITEMS_ATTRS_CHANGES_B WHERE change_line_id = p_change_line_id))
    LOOP
      Write_Debug('Synching Item description at all organization levels for item: ' || rec.inventory_item_id  );
      Write_Debug('New Description: ' || rec.description  );
      UPDATE mtl_system_items_tl
      SET description = rec.description
      WHERE inventory_item_id =  rec.inventory_item_id
      AND LANGUAGE = rec.LANGUAGE;

      IF rec.LANGUAGE = 'US' THEN
        UPDATE mtl_system_items_b
        SET description = rec.description
        WHERE
        inventory_item_id = rec.inventory_item_id ;
      END IF;
    END LOOP;

    Write_Debug('Done synching item descriptions.');
    END;
    -- Developer: CHECHAND - Bug# 9742219 - End


Write_Debug('In Implement_Change_Line, done');

-----------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
Write_Debug('COMMIT Implement_Change_Line');
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

Write_Debug('When G_EXC_ERROR Exception in Implement_Change_Line');

      x_return_status := FND_API.G_RET_STS_ERROR;

      IF FND_API.To_Boolean( p_commit ) THEN
Write_Debug('ROLLBACK TO Implement_Change_Line');
        ROLLBACK TO Implement_Change_Line_PUB;
      END IF;

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

Write_Debug('In Implement_Change_Line, got expected error: x_msg_data is '||x_msg_data);

    WHEN OTHERS THEN
Write_Debug('When G_RET_STS_UNEXP_ERROR Exception in Implement_Change_Line');

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_API.To_Boolean( p_commit ) THEN
Write_Debug('ROLLBACK TO Implement_Change_Line');
        ROLLBACK TO Implement_Change_Line_PUB;
      END IF;


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

Write_Debug('In Implement_Change_Line, got unexpected error: x_msg_data is '||x_msg_data);

END Implement_Change_Line;


PROCEDURE impl_rev_item_user_attr_chgs
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER
)
IS
    l_api_name      CONSTANT VARCHAR2(30) := 'IMPL_REV_ITEM_USER_ATTR_CHGS';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;

    l_msg_data       VARCHAR2(4000);
    l_msg_count      NUMBER;
    l_return_status  VARCHAR2(1);
    l_error_msg      VARCHAR2(2000) ;

    l_found          BOOLEAN ;


    l_check_item_attr_change  NUMBER := 2;
    l_new_revision_id NUMBER;
    l_old_revision_id NUMBER;

    l_errorcode NUMBER;
    l_change_id NUMBER;
    l_change_line_id NUMBER;

    plsql_block VARCHAR2(5000);


    l_old_data_level_nv_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_new_data_level_nv_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;

BEGIN


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( l_commit ) THEN
      -- Standard Start of API savepoint
      SAVEPOINT IMPL_REV_ITEM_USER_ATTR_CHGS;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_change_id: '  || to_char(p_change_id));
Write_Debug('p_change_line_id: '  || to_char(p_change_line_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    -- API body
    -- Logic Here
    -- Init Local Vars
    l_change_id := p_change_id;
    l_change_line_id := p_change_line_id;

    IF ( l_change_id IS NULL OR l_change_id <= 0 )
    THEN
        l_change_id := GetChangeId(p_change_line_id => l_change_line_id) ;

Write_Debug('Got Change Id: '  || to_char(l_change_id));

    END IF ;


Write_Debug('Check Item User Attr Change exists for Rev Item: '  || to_char(l_change_line_id));
    l_found :=  CheckItemUserAttrChange(p_change_line_id => l_change_line_id) ;
    IF NOT l_found THEN
Write_Debug('Item User Attr Change not found for '  || to_char(l_change_line_id));
       RETURN ;
    END IF ;


    IF (l_found ) THEN
        BEGIN
            --
            -- if new revision is created for this revised Item
            --
            select new_item_revision_id, current_item_revision_id
            into   l_new_revision_id, l_old_revision_id
            from eng_revised_items
            where revised_item_sequence_id = p_change_line_id;

        EXCEPTION WHEN others THEN
            null;
        END;
    END IF;


    --
    -- Call item user attribute changes implement  API
    --


    --  we should pass revised_item_sequence_id as line_id and l_revision_id  as
    --  the new revision_id

     l_change_id := p_change_id;
     l_change_line_id := p_change_line_id;


Write_Debug('Before calling EGO_USER_ATTRS_DATA_PUB.Implement_Change_Line for '  || to_char(l_change_line_id));




    ---------------------------------------------------------------------
    -- Build data structures to pass in Data Level info, if applicable --
    ---------------------------------------------------------------------
    IF (l_old_revision_id IS NOT NULL) THEN
      l_old_data_level_nv_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                     EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID',
                                     l_old_revision_id)
                                   );
    END IF;

    IF (l_new_revision_id IS NOT NULL) THEN
      l_new_data_level_nv_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                     EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID',
                                     l_new_revision_id)
                                   );
    END IF;


    BEGIN

        -- In R12, moved EGO_USER_ATTRS_DATA_PVT.Implement_Change_Line to
        -- this package
        -------------------------------------------------------------------------
        -- Now we invoke the UserAttrs procedure, passing Item-specific params --
        -------------------------------------------------------------------------
        Implement_Change_Line(
              p_api_version                   => 1.0
             ,p_object_name                   => 'EGO_ITEM'
             ,p_production_b_table_name       => 'EGO_MTL_SY_ITEMS_EXT_B'
             ,p_production_tl_table_name      => 'EGO_MTL_SY_ITEMS_EXT_TL'
             ,p_change_b_table_name           => 'EGO_ITEMS_ATTRS_CHANGES_B'
             ,p_change_tl_table_name          => 'EGO_ITEMS_ATTRS_CHANGES_TL'
             ,p_tables_application_id         => 431
             ,p_change_line_id                => l_change_line_id
             ,p_old_data_level_nv_pairs       => l_old_data_level_nv_pairs
             ,p_new_data_level_nv_pairs       => l_new_data_level_nv_pairs
             ,p_related_class_code_function   => 'EGO_ITEM_USER_ATTRS_CP_PUB.Get_Related_Class_Codes'
             ,p_init_msg_list                 => FND_API.G_FALSE
             ,p_commit                        => FND_API.G_FALSE
             ,x_return_status                 => l_return_status
             ,x_errorcode                     => l_errorcode
             ,x_msg_count                     => l_msg_count
             ,x_msg_data                      => l_msg_data
             ) ;

    EXCEPTION
       WHEN OTHERS THEN

            FND_MSG_PUB.Add_Exc_Msg
             ( p_pkg_name            => 'EGO_USER_ATTRS_DATA_PVT' ,
               p_procedure_name      => 'Implement_Change_Line',
               p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
            );


            FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            FND_MESSAGE.Set_Token('OBJECT_NAME', 'EGO_USER_ATTRS_DATA_PVT.Implement_Change_Line');
            FND_MSG_PUB.Add;

Write_Debug('When Others Exception while calling EGO_USER_ATTRS_DATA_PVT.Implement_Change_Line:' || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END ;

    IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS)
    THEN

Write_Debug('Implement_Change_Line failed . ..  ' );
Write_Debug('Output - Return Stattus: '  || l_return_status);
Write_Debug('Output - Return Stattus: '  || to_char(l_msg_count));
Write_Debug('Output - Return Stattus: '  || substr(l_msg_data,1,200));


        x_return_status := l_return_status;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
        FND_MESSAGE.Set_Token('OBJECT_NAME', 'EGO_USER_ATTRS_DATA_PVT.Implement_Change_Line');
        FND_MSG_PUB.Add;

        RAISE FND_API.G_EXC_ERROR ;
    END IF;


    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( l_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
Write_Debug('When G_EXC_ERROR Exception in impl_rev_item_user_attr_chgs');
    x_return_status := G_RET_STS_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK  Item User Attribute Change Implementation TO IMPL_REV_ITEM_USER_ATTR_CHGS');
      ROLLBACK TO IMPL_REV_ITEM_USER_ATTR_CHGS;
    END IF;

    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'impl_rev_item_attr_changes'|| 'error code '||l_errorcode);
    FND_MSG_PUB.Add;


    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

Write_Debug('When G_EXC_UNEXPECTED_ERROR Exception in impl_rev_item_user_attr_chgs');
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK  Item User Attribute Change Implementation TO IMPL_REV_ITEM_USER_ATTR_CHGS');
      ROLLBACK TO IMPL_REV_ITEM_USER_ATTR_CHGS;
    END IF;


    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_attr_changes for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;


    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;

  WHEN OTHERS THEN

Write_Debug('When Others Exception in impl_rev_item_user_attr_chgs');
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF FND_API.To_Boolean( l_commit ) THEN
Write_Debug('ROLLBACK  Item User Attribute Change Implementation TO IMPL_REV_ITEM_USER_ATTR_CHGS');
      ROLLBACK TO IMPL_REV_ITEM_USER_ATTR_CHGS;
    END IF;



Write_Debug('When Others Exception ' || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));

    FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
    FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_IMPL_ITEM_CHANGES_PKG.impl_rev_item_attr_changes for ChangeId: '||l_change_id || '- ChangeLineId: '||l_change_line_id);
    FND_MSG_PUB.Add;


    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    -- Close debug session only explicitly open the debug session for
    -- this API.
    IF FND_API.to_Boolean(p_debug)
    THEN
        Close_Debug_Session;
    END IF ;

END impl_rev_item_user_attr_chgs ;



END ENG_IMPL_ITEM_CHANGES_PKG;

/
