--------------------------------------------------------
--  DDL for Package Body FII_EUL4I_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EUL4I_UTILS" AS
/* $Header: FIIEL41B.pls 120.2 2004/01/14 06:57:10 sgautam noship $ */

 g_debug_flag		VARCHAR2(1) := NVL(FND_PROFILE.value('EDW_DEBUG'), 'N');

 g_errbuf		VARCHAR2(2000) := NULL;
 g_retcode		VARCHAR2(200)  := NULL;
 g_eulOwner             VARCHAR2(30)   := NULL;
 g_fiiSchema            VARCHAR2(30)   := 'FII';
 g_Mode                 VARCHAR2(30)   := NULL;
 g_processName          VARCHAR2(50)   := NULL;

 G_EUL_OWNER_DOES_NOT_EXIST          EXCEPTION;
 PRAGMA EXCEPTION_INIT(G_EUL_OWNER_DOES_NOT_EXIST, -942);

 G_BUSINESS_AREA_DOES_NOT_EXIST      EXCEPTION;
 PRAGMA EXCEPTION_INIT(G_BUSINESS_AREA_DOES_NOT_EXIST, 100);


 /* FII Business Area Names */
 G_BusArea_1            VARCHAR2(100) := 'Revenue Intelligence Business Area';
 G_BusArea_2            VARCHAR2(100) := 'Payables Intelligence Business Area';
 G_BusArea_3            VARCHAR2(100) := 'Project Intelligence Business Area';

/* list of table to modify even if they are shared by other groups - due to
    standard attributes not being hidden i.e. creation date */
 G_TableList            VARCHAR2(1000) := '('''')';

  TYPE eulBusAreaRecType IS RECORD (
    BA_ID                          NUMBER(10),
    BA_NAME                        VARCHAR2(100),
    BA_DEVELOPER_KEY               VARCHAR2(100),
    BA_RECORDS_EVALUATED           NUMBER(10),
    BA_RECORDS_HIDDEN              NUMBER(10));
  TYPE eulBusAreaTabType IS TABLE OF eulBusAreaRecType
    INDEX BY BINARY_INTEGER;
  eulBusAreaTab eulBusAreaTabType;


  TYPE eulTableRecType IS RECORD (
    BA_ID                          NUMBER(10),
    BA_DEVELOPER_KEY               VARCHAR2(100),
    FOLDER_ID                      NUMBER(10),
    FOLDER_NAME                    VARCHAR2(100),
    NEW_FOLDER_NAME                VARCHAR2(100),
    TABLE_NAME                     VARCHAR2(64),
    VIEW_NAME                      VARCHAR2(64),
    TABLE_DEVELOPER_KEY            VARCHAR2(100),
    TABLE_TYPE                     VARCHAR2(1),
    HIDDEN_ITEM_FLAG               VARCHAR2(1),
    FOLDER_HIDDEN                  NUMBER(1),
    FOLDER_SB_HIDDEN               NUMBER(1));
  eulTablesRec eulTableRecType;
  TYPE eulTablesTabType IS TABLE OF eulTableRecType
    INDEX BY BINARY_INTEGER;
  eulTablesTab eulTablesTabType;


  TYPE eulColumnsRecType IS RECORD (
    BA_ID                          NUMBER(10),
    BA_DEVELOPER_KEY               VARCHAR2(100),
    FOLDER_ID                      NUMBER(10),
    ITEM_ID                        NUMBER(10),
    ITEM_DATA_TYPE                 NUMBER(2),
    ITEM_HEADING                   VARCHAR2(240),
    ITEM_FORMAT_MASK               VARCHAR2(100),
    ITEM_NAME                      VARCHAR2(100),
    NEW_ITEM_NAME                  VARCHAR2(100),
    COLUMN_NAME                    VARCHAR2(64),
    COLUMN_DEVELOPER_KEY           VARCHAR2(100),
    ITEM_HIDDEN                    NUMBER(1),
    ITEM_SB_HIDDEN                 NUMBER(1),
    TABLE_TYPE                     VARCHAR2(1));
  eulColumnsRec eulColumnsRecType;
  TYPE eulColumnsTabType IS TABLE OF eulColumnsRecType
    INDEX BY BINARY_INTEGER;
  eulColumnsTab eulColumnsTabType;


  TYPE dimTabRec IS RECORD (
    table_name           VARCHAR2(30),
    view_name            VARCHAR2(30),
    rowcnt               NUMBER,
    table_status         VARCHAR2(30),
    hier1_status         VARCHAR2(30),
    hier2_status         VARCHAR2(30),
    hier3_status         VARCHAR2(30),
    hier4_status         VARCHAR2(30),
    eul_tab_status       VARCHAR2(30),
    eul_hier1_status     VARCHAR2(30),
    eul_hier2_status     VARCHAR2(30),
    eul_hier3_status     VARCHAR2(30),
    eul_hier4_status     VARCHAR2(30));
  TYPE dimTabType IS TABLE OF dimTabRec
     INDEX BY BINARY_INTEGER;
  dimTab dimTabType;

/* ---------------------------------
   PRIVATE PROCEDURES AND FUNCTIONS
   ---------------------------------*/

/******************************************************************************
 PROCEDURE CHILD_SETUP
******************************************************************************/

PROCEDURE CHILD_SETUP(p_object_name VARCHAR2) IS
  l_dir 	VARCHAR2(400);
BEGIN
 /* IF (fnd_profile.value('EDW_TRACE')='Y') THEN
     dbms_session.set_sql_trace(TRUE);
  ELSE
     dbms_session.set_sql_trace(FALSE);
  END IF; */ --Commented for bug 3304365

  IF (fnd_profile.value('EDW_DEBUG') = 'Y') THEN
     edw_log.g_debug := TRUE;
  END IF;

  l_dir:=fnd_profile.value('EDW_LOGFILE_DIR');

  if l_dir is null then
    l_dir:='/sqlcom/log';
  end if;

  if g_debug_flag = 'Y' then
  	edw_log.put_names(p_object_name||'.log',p_object_name||'.out',l_dir);
  end if;

  EXCEPTION
  WHEN OTHERS THEN
    g_errbuf:=sqlerrm;
    g_retcode:=sqlcode;

    raise;

END;



/******************************************************************************
 Function ItemsToHide
******************************************************************************/
   FUNCTION  ItemsToHide(pBusAreaNameIn VARCHAR2,
                         pTableNameIn   VARCHAR2,
                         pColumnNameIn  VARCHAR2,
                         pItemNameIn    VARCHAR2)
   RETURN INTEGER
   IS
      RETURN_VALUE INTEGER := 0;
      --
   BEGIN

     g_processName := 'itemsToHide';
      --

            --  Assuming all key item names end in 'ID','_PK' or 'KEY'
         IF ((SUBSTRB(PColumnNameIn,-3,3) IN ('_ID' , '_PK' , 'KEY','_FK') OR
              SUBSTRB(PColumnNameIn,-2,2) IN ('ID' , 'PK')) AND
              pColumnNameIn NOT LIKE '%TAX%ID' /* Tax Payer IDs */) OR

            --  User attribute and measures
            (NVL(INSTR(pColumnNameIn,'USER_ATTRIBUTE'),0) > 0 AND
              (NVL(INSTR(UPPER(REPLACE(pItemNameIn,'_',' ')),'USER ATTRIBUTE'),0) > 0 OR
               UPPER(pItemNameIn) LIKE 'USER%ATTRIBUTE%'))
             OR
            (NVL(INSTR(pColumnNameIn,'USER_MEASURE'),0) > 0 AND
              (NVL(INSTR(UPPER(REPLACE(pItemNameIn,'_',' ')),'USER MEASURE'),0) > 0 OR
               UPPER(pItemNameIn) LIKE 'USER%MEASURE%')) OR

            --  Instance is not a user attribute
            (NVL(INSTR(PColumnNameIn,'INSTANCE'),0) > 0 AND
            /* (
              NOT
             (pBusAreaNameIn = G_BusArea_3 -- Projects wants instance attribute
              AND
              pTableNameIn LIKE '%_M' AND
              pTableNameIn NOT IN ('EDW_TIME_M') ))
              OR */
              (pColumnNameIn NOT IN ('TPRT_INSTANCE' ,
                                     'ASGN_INSTANCE' ,
                                     'ITEM_INSTANCE_CODE' ,
                                     'ORGA_INSTANCE',
                                     'PRJ_INSTANCE') )
              ) OR

            --  Hide Time Span Columns
            SUBSTRB(PColumnNameIn,-8,8) = 'TIMESPAN' OR

            -- Hide creation and last update dates
            PColumnNameIn LIKE  '%CREATION_DATE' OR
            (PColumnNameIn LIKE  '%LAST_UPDATE_DATE' AND
             /* POA Request for DUNS lud */
             pColumnNameIn NOT IN ('DNMR_DNB_LAST_UPDATE_DATE')) OR

            -- Hide reservered columns, inactive,start and end dates for dimensions
            (PTableNameIn LIKE '%_M' AND
             (PColumnNameIn LIKE '%_INACTIVE_DATE' OR
              pColumnNameIn LIKE '%_LEVEL_NAME' OR
              NVL(INSTR(pColumnNameIn,'_ID_'),0) > 0 OR
               ((PColumnNameIn LIKE '%_START_DATE%' OR
                 PColumnNameIn LIKE '%_STRT_DATE%'  OR
                 PColumnNameIn LIKE '%_END_DATE%') AND
                 SUBSTRB(pColumnNameIn,1,4) NOT IN ('CYR_','CPER','CQTR' /* EDW_TIME_M */,
                                                   'TASK','TTSK' /* EDW_PROJECT_M */,
                                                   'ASGN','PERS' /* EDW_HR_PERSON_M */)) OR
              PColumnNameIn LIKE '%_DP')) OR

              (pTableNameIn = 'EDW_ORGANIZATION_M' AND
               NVL(INSTR(pColumnNameIn,'_CAT_'),0) > 0 ) OR

               FII_EUL4I_UTILS_2.ItemsToHide(pBusAreaNameIn,
                                           pTableNameIn,
                                           pColumnNameIn,
                                           pItemNameIn) = 1
            --

            THEN RETURN_VALUE := 1;

          END IF;
      --
      /* Reset other groups table and change them only
      for columns specified in FII_EUL4I_utils_2*/
      IF INSTR(g_TableList,pTableNameIn) > 0 THEN

         RETURN_VALUE := -1;

         RETURN_VALUE := FII_EUL4I_UTILS_2.ItemsToHide(pBusAreaNameIn,
                                                     pTableNameIn,
                                                     pColumnNameIn,
                                                     pItemNameIn);

      END IF;

      RETURN RETURN_VALUE;

   EXCEPTION
   WHEN OTHERS THEN
     if g_debug_flag = 'Y' then
        edw_log.put_line('');
        edw_log.put_line('Error in '||g_processName);
        edw_log.put_line('pBusAreaNamein = '||pBusAreaNamein);
        edw_log.put_line('pTableName = '||pTableNamein);
        edw_log.put_line('pColumnNameIn ='||pColumnNameIn);
        edw_log.put_line('pItemNameIn ='||pItemNameIn);
    end if;

        g_errbuf:=sqlerrm;
        g_retcode:=sqlcode;

        raise;

   END ItemsToHide;

/******************************************************************************
 Procedure hideFolderItems
******************************************************************************/
   PROCEDURE hideFolderItems(pItemID      IN NUMBER,
                             pHideDisplay IN NUMBER DEFAULT 1)
   IS

   l_stmt   VARCHAR2(1000) := NULL;

   BEGIN

      g_processName := 'hideFolderItems';

      l_stmt := 'UPDATE '||g_EulOwner||'.eul4_expressions exp '||
                'SET    exp.it_hidden = '||pHideDisplay||' '||
                'WHERE  exp.exp_id = '||pItemId;

      /* Update tables record to indicate that items were hidden for that table */
      eulTablesTab(eulColumnsTab(pItemID).folder_id).hidden_item_flag := 'Y';

      IF g_Mode <> 'TEST' THEN

        EXECUTE IMMEDIATE l_stmt;

      END IF;

      if g_debug_flag = 'Y' then
   		edw_log.debug_line('Procedure hideFolderItems');
   		edw_log.debug_line('Going to execute statement:');
   		edw_log.debug_line(l_stmt);
      end if;


      EXCEPTION
      WHEN OTHERS THEN

        g_errbuf:=sqlerrm;
        g_retcode:=sqlcode;

        raise;

   END hideFolderItems;

/******************************************************************************
 Procedure hideFolderItems
******************************************************************************/
PROCEDURE hideFolderItems(pBusAreaID IN NUMBER,
                          pTableName IN VARCHAR2,
                          pViewName  IN VARCHAR2,
                          pColumn    IN VARCHAR2,
                          pHideDisplay IN NUMBER DEFAULT 1)
IS

  l_stmt    VARCHAR2(1000);
  l_itemId  NUMBER(10):= 0;

   /* Cursor variable to hold item id */
  TYPE eulItemCurType IS REF CURSOR;
  eulItem_cv  eulItemCurType;

BEGIN

   g_processName := 'hideFolderItems';

   l_stmt := 'SELECT exp.exp_id '||
             'FROM  '||g_EulOwner||'.eul4_expressions exp , '||
             '      '||g_EulOwner||'.eul4_objs obj, '||
             '      '||g_EulOwner||'.eul4_ba_obj_links bol '||
             'WHERE  bol.bol_ba_id   = '||pBusAreaID||' '||
             'AND    obj.obj_id      = bol.bol_obj_id '||
             'AND    obj.obj_hidden  = 0 '||
             'AND    obj.sobj_ext_table IN ('''||pTableName||''' ,'''||pViewName||''') '||
             'AND    exp.it_obj_id  = obj.obj_id '||
             'AND    exp.it_ext_column LIKE '''||pColumn||'''';

	if g_debug_flag = 'Y' then
   		edw_log.debug_line('Procedure hideFolderItems');
   		edw_log.debug_line('Going to execute statement:');
   		edw_log.debug_line(l_stmt);
   	end if;

--   EXECUTE IMMEDIATE l_stmt INTO l_itemID ;

   OPEN eulItem_cv FOR l_stmt;
   LOOP

     FETCH eulItem_cv INTO l_itemID;
     EXIT WHEN eulItem_cv%NOTFOUND;

       IF eulColumnsTab.exists(l_itemID) THEN

         eulColumnsTab(l_itemID).item_sb_hidden := pHideDisplay;
      /* Update tables record to indicate that items were hidden for that table */
         eulTablesTab(eulColumnsTab(l_ItemID).folder_id).hidden_item_flag := 'Y';

       END IF;

       IF pHideDisplay = 0 THEN

         hideFolderItems(l_itemID,0);

       END IF;


   END LOOP;

   CLOSE eulItem_cv;

    EXCEPTION
    WHEN OTHERS THEN
    if g_debug_flag = 'Y' then
        edw_log.put_line('');
        edw_log.put_line('Error in hideFolderItems');
        edw_log.put_line('pBusAreaID = '||pBusAreaID);
        edw_log.put_line('pTableName = '||pTableName);
        edw_log.put_line('pViewName  = '||pViewName);
        edw_log.put_line('pColumn    LIKE '||pColumn);
        edw_log.put_line('l_stmt '||l_stmt);
     end if ;

        g_errbuf:=sqlerrm;
        g_retcode:=sqlcode;

        raise;

--    hideFolderItems(l_itemID);

END hideFolderItems;


/******************************************************************************
 Procedure InitBusAreas
******************************************************************************/

   PROCEDURE InitBusAreas(pBusAreaName     IN      VARCHAR2,
                          pAction          IN      VARCHAR2 DEFAULT 'ADD') IS

       ctr                  PLS_INTEGER    := 0;
       l_stmt               VARCHAR2(1000) := NULL;
       lEulBA_ID            NUMBER(10);
       lEulBA_NAME          VARCHAR2(100);
       lEulBA_DEVELOPER_KEY VARCHAR2(100);

      BEGIN

        g_processName := 'initBusAreas';

        IF pAction = 'RESET' THEN

          eulBusAreaTab.delete;

        ELSE

          l_stmt := 'SELECT ba.ba_id,  '||
                    '       ba.ba_name,'||
                    '       ba.ba_name ba_developer_key '||
                    'FROM  '||g_EulOwner||'.eul4_bas ba '||
                    'WHERE  ba.ba_name = '''||pBusAreaName||'''';

	if g_debug_flag = 'Y' then
          edw_log.debug_line('Procedure initBusAreas');
          edw_log.debug_line('Going to execute statement:');
          edw_log.debug_line(l_stmt);
        end if;


          EXECUTE IMMEDIATE l_stmt INTO lEulBA_ID, lEulBA_Name, lEulBA_DEVELOPER_KEY;

            eulBusAreaTab(lEulBA_id).ba_id   := lEulBA_ID;
            eulBusAreaTab(lEulBA_id).ba_name := lEulBA_Name;
            eulBusAreaTab(lEulBA_id).ba_developer_key := lEulBA_DEVELOPER_KEY;
            eulBusAreaTab(lEulBA_id).ba_records_evaluated  := 0;
            eulBusAreaTab(lEulBA_id).ba_records_hidden     := 0;

        END IF;

      EXCEPTION
      WHEN OTHERS THEN
        g_errbuf:=sqlerrm;
        g_retcode:=sqlcode;

        raise;
   END InitBusAreas;

/******************************************************************************
 Procedure InitColumns
******************************************************************************/
   PROCEDURE InitColumns(pBusAreaName IN VARCHAR2,
                         pFolderID   IN NUMBER,
                         pTableName  IN VARCHAR2,
                         pTableType  IN VARCHAR2) IS

    ctr                  PLS_INTEGER    := 0;
    l_stmt               VARCHAR2(2000) := NULL;

    /* Cursor variable to hold table names */
    TYPE eulColCurType IS REF CURSOR;
    eulCol_cv  eulColCurType;

   BEGIN

     g_processName := 'initColumns';

     l_stmt := 'SELECT NULL                             BA_ID       , '||
               '       NULL                             BA_DEVELOPER_KEY ,'||
               '      '||pFolderID||'                   folder_id , '||
               '       folder_items.EXP_ID              Item_ID , '||
               '       folder_items.exp_data_type       item_data_type , '||
               '       folder_items.it_heading          item_heading , '||
               '       folder_items.it_format_mask      item_format_mask , '||
               '       folder_items.exp_name            Item_Name , '||
               '       NULL                             new_item_name , '||
               '       folder_items.IT_EXT_COLUMN       column_Name , '||
               '       folder_items.exp_developer_Key   column_developer_key , '||
               '       folder_items.IT_HIDDEN           Item_Hidden , '||
               '       FII_EUL4I_utils.ItemsToHide('''||pBusAreaName||''','''||pTableName||''', folder_items.IT_EXT_COLUMN,folder_items.exp_name) item_sb_hidden , '||
               '   '''||pTableType||'''           table_type '||
               'FROM  '||g_EulOwner||'.eul4_EXPRESSIONS folder_items '||
               'WHERE  folder_items.it_obj_id = '||pFolderId||' '||
               'ORDER BY folder_items.IT_EXT_COLUMN, '||
               '        folder_items.exp_id';

	if g_debug_flag = 'Y' then
          edw_log.debug_line('Procedure initColumns');
          edw_log.debug_line('Going to execute statement:');
          edw_log.debug_line(l_stmt);
        end if;

       OPEN eulCol_cv FOR l_stmt;
       LOOP

         FETCH eulCol_cv INTO eulColumnsRec;
         EXIT WHEN eulCol_cv%NOTFOUND;

         eulColumnsTab(eulColumnsRec.item_id) := eulColumnsRec;

--          /* Delete row if hidden and should be hidden are the same */
--         IF eulColumnsTab(eulColumnsRec.item_id).item_hidden = eulColumnsTab(eulColumnsRec.item_id).item_sb_hidden THEN

--            eulColumnsTab.delete(eulColumnsRec.item_id);

--         END IF;

       END LOOP;

       CLOSE eulCol_cv;

    EXCEPTION
    WHEN OTHERS THEN
    	if g_debug_flag = 'Y' then
        edw_log.put_line('');
        edw_log.put_line('Error in initColumns');
        edw_log.put_line('pBusAreaName = '||pBusAreaName);
        edw_log.put_line('pTableName = '||pTableName);
        edw_log.put_line('l_stmt '||l_stmt);
        end if;

        g_errbuf:=sqlerrm;
        g_retcode:=sqlcode;

        raise;

   END InitColumns;


/******************************************************************************
 Procedure InitTables
******************************************************************************/
   PROCEDURE InitTables(pBusAreaName IN VARCHAR2,
                        pAction      IN VARCHAR2 DEFAULT 'NULL')
   IS

    ctr                  PLS_INTEGER    := 0;
    l_stmt               VARCHAR2(3000) := NULL;

    /* Cursor variable to hold table names */
    TYPE eulTabCurType IS REF CURSOR;
    eulTab_cv  eulTabCurType;

   BEGIN

     g_processName := 'initTables';

     l_stmt := 'SELECT BUSINESS_AREAS.BA_ID                           BA_ID       , '||
               '       BUSINESS_AREAS.BA_DEVELOPER_KEY                BA_DEVELOPER_KEY ,'||
               '       folders.OBJ_ID                                 Folder_ID , '||
               '       folders.obj_name                               Folder_Name , '||
               '       NULL                                           new_folder_name , '||
               '       folders.SOBJ_EXT_TABLE                         Table_Name , '||
               '''MIS_''||RTRIM(folders.sobj_ext_table,''M'')||''V''  view_name, '||
               '       folders.OBJ_DEVELOPER_KEY                      OBJ_DEVELOPER_KEY , '||
               '       SUBSTRB(folders.SOBJ_EXT_TABLE,-1,1)            table_type , '||
               '       NULL                                           hidden_item_flag , ' ||
               '       folders.obj_hidden                             folder_hidden , '||
               '       folders.obj_hidden                             folder_sb_hidden '||
               'FROM  '||g_EulOwner||'.eul4_OBJS                      folders , '||
               '      '||g_EulOwner||'.eul4_BA_OBJ_LINKS              BA_Folders , '||
               '      '||g_EulOwner||'.eul4_bas                       BUSINESS_AREAS '||
               'WHERE  business_areas.ba_name = '''||pBusAreaName||''' '||
               'AND    BA_Folders.BOL_OBJ_ID=folders.OBJ_ID '||
               'AND    BA_Folders.BOL_BA_ID=BUSINESS_AREAS.BA_ID '||
               'AND    folders.obj_hidden = 0 '||
               'AND   (NOT EXISTS (SELECT 1 '||
                                  'FROM   '||g_EulOwner||'.eul4_BA_OBJ_LINKS BA_Folders2 , '||
                                  '       '||g_EulOwner||'.eul4_bas          BUSINESS_AREAS2 '||
                                  'WHERE  BA_Folders2.BOL_BA_ID   = BUSINESS_AREAS2.BA_ID '||
                                  'AND    ba_folders2.bol_obj_id = ba_folders.bol_obj_id '||
                                  'AND    BUSINESS_AREAS2.BA_name NOT IN  '||
                                  '          ('''||g_BusArea_1||''', '||
                                  '           '''||g_BusArea_2||''', '||
                                  '           '''||g_BusArea_3||''')) OR '||
               '       folders.sobj_ext_table IN ('||g_TableList||') OR '||
               '       folders.sobj_ext_table LIKE ''EDW_GL_ACCT%'' OR  '||
               '       folders.sobj_ext_table LIKE ''MIS_EDW_GL_ACCT%'' ) ' ||
               'ORDER BY folders.SOBJ_EXT_TABLE, '||
               '        folders.OBJ_ID ';


	if g_debug_flag = 'Y' then
      		edw_log.debug_line('Procedure initTables');
      		edw_log.debug_line('Going to execute statement:');
      		edw_log.debug_line(l_stmt);
        end if;


--      eulTablesTab.delete;
--      eulColumnsTab.delete;

       OPEN eulTab_cv FOR l_stmt;
       LOOP

         FETCH eulTab_cv INTO eulTablesRec;
         EXIT WHEN eulTab_cv%NOTFOUND;

         eulTablesTab(eulTablesRec.folder_id) := eulTablesRec;

       InitColumns(pBusAreaName, eulTablesRec.folder_id,eulTablesRec.table_name,eulTablesRec.table_type);

       END LOOP;

       CLOSE eulTab_cv;

    EXCEPTION
    WHEN OTHERS THEN
    	if g_debug_flag = 'Y' then
        edw_log.put_line('');
        edw_log.put_line('Error in initTables');
        edw_log.put_line('pBusAreaName = '||pBusAreaName);
        edw_log.put_line('l_stmt '||l_stmt);
        end if;

        g_errbuf:=sqlerrm;
        g_retcode:=sqlcode;

      raise;

   END InitTables;

/******************************************************************************
 Procedure hideFolders
******************************************************************************/
   PROCEDURE hideFolders(pFolderID IN NUMBER)
   IS

   ctr PLS_INTEGER := 0;
   l_stmt VARCHAR2(1000);

   BEGIN

     g_processName := 'hideFolders';

     l_stmt :=
        'UPDATE '||g_EulOwner||'.eul4_objs obj '||
        'SET    obj.obj_hidden = 1 '||
        'WHERE  obj.obj_id = '||pFolderId||'';

     IF g_Mode <> 'TEST' THEN

       if g_debug_flag = 'Y' then
        edw_log.debug_line('Procedure hideFolders');
        edw_log.debug_line('Going to execute statement:');
        edw_log.debug_line(l_stmt);
       end if;

        EXECUTE IMMEDIATE l_stmt;

     END IF;

    EXCEPTION
    WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:=sqlcode;

      raise;

   END hideFolders;

/******************************************************************************
 Procedure hideFolders
******************************************************************************/
PROCEDURE hideFolders(pBusAreaID IN NUMBER,
                      pTableName IN VARCHAR2,
                      pViewName  IN VARCHAR2)

IS

  l_stmt      VARCHAR2(1000);
  l_folderId  NUMBER(10):= 0;

  TYPE eulFolderCurType IS REF CURSOR;
  eulFolder_cv  eulFolderCurType;


BEGIN
  g_processName := 'hideFolders';

   l_stmt := 'SELECT obj.obj_id folder_id '||
             'FROM  '||g_EulOwner||'.eul4_objs obj, '||
             '      '||g_EulOwner||'.eul4_ba_obj_links bol '||
             'WHERE  bol.bol_ba_id   = '||pBusAreaID||' '||
             'AND    obj.obj_id      = bol.bol_obj_id '||
             'AND    oBj.sobj_ext_table IN ('''||pTableName||''' ,'''||pViewName||''') ';

	if g_debug_flag = 'Y' then
   		edw_log.debug_line('Procedure hideFolders');
   		edw_log.debug_line('Going to execute statement:');
   		edw_log.debug_line(l_stmt);
   	end if;


   OPEN eulFolder_cv FOR l_Stmt;
   LOOP

     FETCH eulFolder_cv INTO l_FolderID;
     EXIT WHEN eulFolder_cv%NOTFOUND;

     eulTablesTab(l_FolderID).folder_sb_hidden := 1;
     hideFolders(l_FolderID);

   END LOOP;

   CLOSE eulFolder_cv;

   EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;

     raise;

END hideFolders;


/******************************************************************************
 Procedure hideEulDimLevels
******************************************************************************/
PROCEDURE hideEulDimLevels(pBusAreaID    IN NUMBER,
                           pdimTableName IN VARCHAR2,
                           pdimViewName  IN VARCHAR2,
                           pLevelName    IN VARCHAR2)

IS

  levelTab DBMS_UTILITY.uncl_array;

  levelStr VARCHAR2(2000) := NULL;
  rowCtr   BINARY_INTEGER;

  l_stmt   VARCHAR2(4000);

  GL_FLEX_DIM_TAB_NF EXCEPTION;
  PRAGMA EXCEPTION_INIT(GL_FLEX_DIM_TAB_NF, -942);

BEGIN
  g_processName := 'hideEulDimLevels';

  /* Display all name columns in this hier */
  hideFolderItems(pBusAreaID , pDimTableName, pdimViewName  , pLevelName||'%'||'NAME' , 0);

  /* Display all description columns in this hier */
  hideFolderItems(pBusAreaID , pDimTableName, pdimViewName  , pLevelName||'%'||'DESCRIPTION' , 0);

  l_stmt :=
  'SELECT DISTINCT '||
  '       LTRIM( '||
  '       DECODE(MAX(DECODE(H102_NAME , H103_NAME , 0, 1)),0, ''H102'',NULL)|| '||
  '       DECODE(MAX(DECODE(H103_NAME , H104_NAME , 0, 1)),0,'',H103'',NULL)|| '||
  '       DECODE(MAX(DECODE(H104_NAME , H105_NAME , 0, 1)),0,'',H104'',NULL)|| '||
  '       DECODE(MAX(DECODE(H105_NAME , H106_NAME , 0, 1)),0,'',H105'',NULL)|| '||
  '       DECODE(MAX(DECODE(H106_NAME , H107_NAME , 0, 1)),0,'',H106'',NULL)|| '||
  '       DECODE(MAX(DECODE(H107_NAME , H108_NAME , 0, 1)),0,'',H107'',NULL)|| '||
  '       DECODE(MAX(DECODE(H108_NAME , H109_NAME , 0, 1)),0,'',H108'',NULL)|| '||
  '       DECODE(MAX(DECODE(H109_NAME , H110_NAME , 0, 1)),0,'',H109'',NULL)|| '||
  '       DECODE(MAX(DECODE(H110_NAME , H111_NAME , 0, 1)),0,'',H110'',NULL)|| '||
  '       DECODE(MAX(DECODE(H111_NAME , H112_NAME , 0, 1)),0,'',H111'',NULL)|| '||
  '       DECODE(MAX(DECODE(H112_NAME , H113_NAME , 0, 1)),0,'',H112'',NULL)|| '||
  '       DECODE(MAX(DECODE(H113_NAME , H114_NAME , 0, 1)),0,'',H113'',NULL)|| '||
  '       DECODE(MAX(DECODE(H114_NAME , H115_NAME , 0, 1)),0,'',H114'',NULL)|| '||
  '       DECODE(MAX(DECODE(H202_NAME , H203_NAME , 0, 1)),0,'',H202'',NULL)|| '||
  '       DECODE(MAX(DECODE(H203_NAME , H204_NAME , 0, 1)),0,'',H203'',NULL)|| '||
  '       DECODE(MAX(DECODE(H204_NAME , H205_NAME , 0, 1)),0,'',H204'',NULL)|| '||
  '       DECODE(MAX(DECODE(H205_NAME , H206_NAME , 0, 1)),0,'',H205'',NULL)|| '||
  '       DECODE(MAX(DECODE(H206_NAME , H207_NAME , 0, 1)),0,'',H206'',NULL)|| '||
  '       DECODE(MAX(DECODE(H207_NAME , H208_NAME , 0, 1)),0,'',H207'',NULL)|| '||
  '       DECODE(MAX(DECODE(H208_NAME , H209_NAME , 0, 1)),0,'',H208'',NULL)|| '||
  '       DECODE(MAX(DECODE(H209_NAME , H210_NAME , 0, 1)),0,'',H209'',NULL)|| '||
  '       DECODE(MAX(DECODE(H210_NAME , H211_NAME , 0, 1)),0,'',H210'',NULL)|| '||
  '       DECODE(MAX(DECODE(H211_NAME , H212_NAME , 0, 1)),0,'',H211'',NULL)|| '||
  '       DECODE(MAX(DECODE(H212_NAME , H213_NAME , 0, 1)),0,'',H212'',NULL)|| '||
  '       DECODE(MAX(DECODE(H213_NAME , H214_NAME , 0, 1)),0,'',H213'',NULL)|| '||
  '       DECODE(MAX(DECODE(H214_NAME , H215_NAME , 0, 1)),0,'',H214'',NULL)|| '||
  '       DECODE(MAX(DECODE(H302_NAME , H303_NAME , 0, 1)),0,'',H302'',NULL)|| '||
  '       DECODE(MAX(DECODE(H303_NAME , H304_NAME , 0, 1)),0,'',H303'',NULL)|| '||
  '       DECODE(MAX(DECODE(H304_NAME , H305_NAME , 0, 1)),0,'',H304'',NULL)|| '||
  '       DECODE(MAX(DECODE(H305_NAME , H306_NAME , 0, 1)),0,'',H305'',NULL)|| '||
  '       DECODE(MAX(DECODE(H306_NAME , H307_NAME , 0, 1)),0,'',H306'',NULL)|| '||
  '       DECODE(MAX(DECODE(H307_NAME , H308_NAME , 0, 1)),0,'',H307'',NULL)|| '||
  '       DECODE(MAX(DECODE(H308_NAME , H309_NAME , 0, 1)),0,'',H308'',NULL)|| '||
  '       DECODE(MAX(DECODE(H309_NAME , H310_NAME , 0, 1)),0,'',H309'',NULL)|| '||
  '       DECODE(MAX(DECODE(H310_NAME , H311_NAME , 0, 1)),0,'',H310'',NULL)|| '||
  '       DECODE(MAX(DECODE(H311_NAME , H312_NAME , 0, 1)),0,'',H311'',NULL)|| '||
  '       DECODE(MAX(DECODE(H312_NAME , H313_NAME , 0, 1)),0,'',H312'',NULL)|| '||
  '       DECODE(MAX(DECODE(H313_NAME , H314_NAME , 0, 1)),0,'',H313'',NULL)|| '||
  '       DECODE(MAX(DECODE(H314_NAME , H315_NAME , 0, 1)),0,'',H314'',NULL)|| '||
  '       DECODE(MAX(DECODE(H402_NAME , H403_NAME , 0, 1)),0,'',H402'',NULL)|| '||
  '       DECODE(MAX(DECODE(H403_NAME , H404_NAME , 0, 1)),0,'',H403'',NULL)|| '||
  '       DECODE(MAX(DECODE(H404_NAME , H405_NAME , 0, 1)),0,'',H404'',NULL)|| '||
  '       DECODE(MAX(DECODE(H405_NAME , H406_NAME , 0, 1)),0,'',H405'',NULL)|| '||
  '       DECODE(MAX(DECODE(H406_NAME , H407_NAME , 0, 1)),0,'',H406'',NULL)|| '||
  '       DECODE(MAX(DECODE(H407_NAME , H408_NAME , 0, 1)),0,'',H407'',NULL)|| '||
  '       DECODE(MAX(DECODE(H408_NAME , H409_NAME , 0, 1)),0,'',H408'',NULL)|| '||
  '       DECODE(MAX(DECODE(H409_NAME , H410_NAME , 0, 1)),0,'',H409'',NULL)|| '||
  '       DECODE(MAX(DECODE(H410_NAME , H411_NAME , 0, 1)),0,'',H410'',NULL)|| '||
  '       DECODE(MAX(DECODE(H411_NAME , H412_NAME , 0, 1)),0,'',H411'',NULL)|| '||
  '       DECODE(MAX(DECODE(H412_NAME , H413_NAME , 0, 1)),0,'',H412'',NULL)|| '||
  '       DECODE(MAX(DECODE(H413_NAME , H414_NAME , 0, 1)),0,'',H413'',NULL)|| '||
  '       DECODE(MAX(DECODE(H414_NAME , H415_NAME , 0, 1)),0,'',H414'',NULL),'','') '||
  'FROM   '||pDimTableName;

	if g_debug_flag = 'Y' then
          edw_log.debug_line('Procedure hideEulDimLevels');
          edw_log.debug_line('Going to execute statement:');
          edw_log.debug_line(l_stmt);
       end if;

  EXECUTE IMMEDIATE l_stmt INTO levelStr;

  DBMS_UTILITY.COMMA_TO_TABLE(levelStr,rowCtr,levelTab);

  FOR ctr IN 1..levelTab.count LOOP

    IF levelTab(ctr) IS NOT NULL AND levelTab(ctr) LIKE pLevelName THEN

      hideFolderItems(pBusAreaID , pDimTableName, pdimViewName  , levelTab(ctr)||'%');

    END IF;

  END LOOP;

  EXCEPTION
  WHEN GL_FLEX_DIM_TAB_NF
  THEN
	if g_debug_flag = 'Y' then
     		edw_log.put_line('GL Flex Dimension Tables not found in '||g_fiischema||' schema');
        end if;

  WHEN OTHERS THEN

     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;

     raise;

END hideEulDimLevels;


/******************************************************************************
 Procedure eulGLFlexDimMaint
******************************************************************************/
PROCEDURE eulGLFlexDimMaint
IS

  ctr      PLS_INTEGER := 0;
  ba_ctr   PLS_INTEGER := 0;
  l_stmt   VARCHAR2(2000) := NULL;

  GL_FLEX_DIM_TAB_NF EXCEPTION;
  PRAGMA EXCEPTION_INIT(GL_FLEX_DIM_TAB_NF, -942);

BEGIN
  g_processName := 'eulGLFlexDimMaint';


   /* Load GL Flex dimension table names into array */
   dimTab(1).table_name  := 'EDW_GL_ACCT1_M';
   dimTab(2).table_name  := 'EDW_GL_ACCT2_M';
   dimTab(3).table_name  := 'EDW_GL_ACCT3_M';
   dimTab(4).table_name  := 'EDW_GL_ACCT4_M';
   dimTab(5).table_name  := 'EDW_GL_ACCT5_M';
   dimTab(6).table_name  := 'EDW_GL_ACCT6_M';
   dimTab(7).table_name  := 'EDW_GL_ACCT7_M';
   dimTab(8).table_name  := 'EDW_GL_ACCT8_M';
   dimTab(9).table_name  := 'EDW_GL_ACCT9_M';
   dimTab(10).table_name := 'EDW_GL_ACCT10_M';

   /* Load GL Flex dimension table and hierarchy status into array */
  FOR ctr IN 1..dimTab.count LOOP

    dimTab(ctr).view_name := 'MIS_'||RTRIM(dimTab(ctr).table_name,'M')||'V';

    l_stmt := 'SELECT COUNT(*), '||
              'DECODE(LEAST(COUNT(DISTINCT DECODE(  L1_NAME , ''NA_EDW'' , NULL , ''NA_ERR'' , NULL ,   L1_NAME)),1),1,''Used'',''Not Used'') L1_NAME, '||
              'DECODE(LEAST(COUNT(DISTINCT DECODE(H115_NAME , ''NA_EDW'' , NULL , ''NA_ERR'' , NULL , H115_NAME)),1),1,''Used'',''Not Used'') H115_NAME, '||
              'DECODE(LEAST(COUNT(DISTINCT DECODE(H215_NAME , ''NA_EDW'' , NULL , ''NA_ERR'' , NULL , H215_NAME)),1),1,''Used'',''Not Used'') H215_NAME, '||
              'DECODE(LEAST(COUNT(DISTINCT DECODE(H315_NAME , ''NA_EDW'' , NULL , ''NA_ERR'' , NULL , H315_NAME)),1),1,''Used'',''Not Used'') H315_NAME, '||
              'DECODE(LEAST(COUNT(DISTINCT DECODE(H415_NAME , ''NA_EDW'' , NULL , ''NA_ERR'' , NULL , H415_NAME)),1),1,''Used'',''Not Used'') H415_NAME  '||
              'FROM '||dimTab(ctr).table_name;

	if g_debug_flag = 'Y' then
    		edw_log.debug_line('Procedure eulGLFlexDimMaint');
    		edw_log.debug_line('Going to execute statement:');
    		edw_log.debug_line(l_stmt);
        end if;


    EXECUTE IMMEDIATE l_stmt INTO dimTab(ctr).rowcnt , dimTab(ctr).table_status , dimTab(ctr).hier1_status , dimTab(ctr).hier2_status , dimTab(ctr).hier3_status , dimTab(ctr).hier4_status;

	if g_debug_flag = 'Y' then
    		edw_log.put_line('Table :'||dimTab(ctr).table_name);
--    		edw_log.put_line('   View :'||dimTab(ctr).view_name);
    		edw_log.put_line('   Rows :'||dimTab(ctr).rowcnt);
    		edw_log.put_line('   Table  Status :'||dimTab(ctr).table_status);
    		edw_log.put_line('   Hier 1 Status :'||dimTab(ctr).hier1_status);
    		edw_log.put_line('   Hier 2 Status :'||dimTab(ctr).hier2_status);
    		edw_log.put_line('   Hier 3 Status :'||dimTab(ctr).hier3_status);
    		edw_log.put_line('   Hier 4 Status :'||dimTab(ctr).hier4_status);
    		edw_log.put_line('');
       end if;


    -- Hide Unused dimensions and hier
    --
       ba_ctr := eulBusAreaTab.first;

       FOR ctr1 IN 1..eulBusAreaTab.count LOOP
       --

         IF dimTab(ctr).table_status = 'Not Used' THEN
         --
         hideFolders(eulBusAreaTab(ba_ctr).ba_id , dimTab(ctr).table_name ,dimTab(ctr).view_name);

         ELSE

           -- Hide columns for hierarchy 1
           IF dimTab(ctr).hier1_status = 'Not Used' THEN

            hideFolderItems(eulBusAreaTab(ba_ctr).ba_id , dimTab(ctr).table_name,
                            dimTab(ctr).view_name , 'H1%');
           ELSE
           -- Hide unused columns within used hierachies
            hideEulDimLevels(eulBusAreaTab(ba_ctr).ba_id , dimTab(ctr).table_name,
                             dimTab(ctr).view_name , 'H1%');
           END IF;

           -- Hide columns for hierarchy 2
           IF dimTab(ctr).hier2_status = 'Not Used' THEN

            hideFolderItems(eulBusAreaTab(ba_ctr).ba_id , dimTab(ctr).table_name,
                            dimTab(ctr).view_name , 'H2%');
           ELSE
           -- Hide unused columns within used hierachies
            hideEulDimLevels(eulBusAreaTab(ba_ctr).ba_id , dimTab(ctr).table_name,
                             dimTab(ctr).view_name , 'H2%');
           END IF;


           -- Hide columns for hierarchy 3
           IF dimTab(ctr).hier3_status = 'Not Used' THEN

            hideFolderItems(eulBusAreaTab(ba_ctr).ba_id , dimTab(ctr).table_name,
                            dimTab(ctr).view_name , 'H3%');
           ELSE
           -- Hide unused columns within used hierachies
            hideEulDimLevels(eulBusAreaTab(ba_ctr).ba_id , dimTab(ctr).table_name,
                             dimTab(ctr).view_name , 'H3%');
           END IF;


           -- Hide columns for hierarchy 4
           IF dimTab(ctr).hier4_status = 'Not Used' THEN

            hideFolderItems(eulBusAreaTab(ba_ctr).ba_id , dimTab(ctr).table_name,
                            dimTab(ctr).view_name , 'H4%');
           ELSE
           -- Hide unused columns within used hierachies
            hideEulDimLevels(eulBusAreaTab(ba_ctr).ba_id , dimTab(ctr).table_name,
                             dimTab(ctr).view_name , 'H4%');
           END IF;
           --
         END IF;
         --
       ba_ctr := eulBusAreaTab.next(ba_ctr);

       END LOOP;
    --
  END LOOP;

    EXCEPTION
    WHEN GL_FLEX_DIM_TAB_NF
    THEN
	if g_debug_flag = 'Y' then
      		edw_log.put_line('GL Flex Dimension Tables not found in '||g_fiischema||' schema');
	end if;

    WHEN OTHERS THEN
        edw_log.put_line('');
        edw_log.put_line('Error in eulGLFlexDimMaint '||eulBusAreaTab(ba_ctr).ba_name);
        edw_log.put_line('dimTab(ctr).table_status = '||dimTab(ctr).table_status);
        edw_log.put_line('ctr = '||ctr);
    edw_log.put_line('Table :'||dimTab(ctr).table_name);
--    edw_log.put_line('   View :'||dimTab(ctr).view_name);
    edw_log.put_line('   Rows :'||dimTab(ctr).rowcnt);
    edw_log.put_line('   Table  Status :'||dimTab(ctr).table_status);
    edw_log.put_line('   Hier 1 Status :'||dimTab(ctr).hier1_status);
    edw_log.put_line('   Hier 2 Status :'||dimTab(ctr).hier2_status);
    edw_log.put_line('   Hier 3 Status :'||dimTab(ctr).hier3_status);
    edw_log.put_line('   Hier 4 Status :'||dimTab(ctr).hier4_status);
    edw_log.put_line('');

    g_errbuf:=sqlerrm;
    g_retcode:=sqlcode;

    raise;

END eulGLFlexDimMaint;

/******************************************************************************
 Procedure eulHierDelete
******************************************************************************/
Procedure eulHierDelete
IS
-- Hierarchies
--   445 Week
--   Enterprise Calendar
--   GL Period
--   Gregorian Calendar
--   Project Period

  /* 'Project Intelligence Business Area' */
  project_hier1   VARCHAR2(5) := 'P445%';
  project_hier2   VARCHAR2(5) := 'zzz';
  project_hier3   VARCHAR2(5) := 'zzz';
  project_hier4   VARCHAR2(5) := 'zzz';

  /* 'Payables Intelligence Business Area' */
  payables_hier1  VARCHAR2(5) := 'P445%';
  payables_hier2  VARCHAR2(5) := 'PPER%';
  payables_hier3  VARCHAR2(5) := 'EC%';
  payables_hier4  VARCHAR2(5) := 'YEAR%';

  /* 'Revenue Intelligence Business Area' */
  revenue_hier1   VARCHAR2(5) := 'P445%';
  revenue_hier2   VARCHAR2(5) := 'EC%%';
  revenue_hier3   VARCHAR2(5) := 'YEAR%';
  revenue_hier4   VARCHAR2(5) := 'zzz';


  l_stmt      VARCHAR2(4000);
  l_hierId    NUMBER(10):= 0;

  TYPE eulHierCurType IS REF CURSOR;
  eulHier_cv  eulHierCurType;

BEGIN

l_stmt := 'SELECT DISTINCT hi_id '||
          'FROM   '||g_EulOwner||'.eul4_OBJS           folders , '||
          '       '||g_EulOwner||'.eul4_BA_OBJ_LINKS   ba_folders , '||
          '       '||g_EulOwner||'.eul4_BAS            business_areas , '||
          '       '||g_EulOwner||'.eul4_EXPRESSIONS    folder_items , '||
          '       '||g_EulOwner||'.eul4_IG_EXP_LINKS   item_to_hier , '||
          '       '||g_EulOwner||'.eul4_HI_NODES       hier_nodes , '||
          '       '||g_EulOwner||'.eul4_HI_SEGMENTS    hier_segments, '||
          '       '||g_EulOwner||'.eul4_HIERARCHIES    hier '||
          'WHERE  ( '||
          '         /*PROJECTS */ '||
          '        (business_areas.ba_name = '''||G_BusArea_3||''' AND '||
          '         (folder_items.it_ext_column LIKE '''||project_hier1||''' OR '||
          '          folder_items.it_ext_column LIKE '''||project_hier2||''' OR '||
          '          folder_items.it_ext_column LIKE '''||project_hier3||''' OR '||
          '          folder_items.it_ext_column LIKE '''||project_hier4||''')) '||
          '        OR '||
          '        /* Payables */ '||
          '        (business_areas.ba_name = '''||G_BusArea_2||''' AND '||
          '         (folder_items.it_ext_column LIKE '''||payables_hier1||''' OR '||
          '          folder_items.it_ext_column LIKE '''||payables_hier2||''' OR '||
          '          folder_items.it_ext_column LIKE '''||payables_hier3||''' OR '||
          '          folder_items.it_ext_column LIKE '''||payables_hier4||''')) '||
          '        OR '||
          '        /* Revenue */ '||
          '        (business_areas.ba_name = '''||G_BusArea_1||''' AND '||
          '         (folder_items.it_ext_column LIKE '''||revenue_hier1||''' OR '||
          '          folder_items.it_ext_column LIKE '''||revenue_hier2||''' OR '||
          '          folder_items.it_ext_column LIKE '''||revenue_hier3||''' OR '||
          '          folder_items.it_ext_column LIKE '''||revenue_hier4||''')) '||
          '       ) '||
          'AND    ba_folders.bol_ba_id          = business_areas.ba_id '||
          'AND    ba_folders.bol_obj_id         = folders.obj_id '||
          'AND    folders.sobj_ext_table        = ''EDW_TIME_M'' '||
          'AND    folder_items.it_obj_id        = folders.obj_id '||
          'AND    folder_items.exp_id           = item_to_hier.hil_exp_id '||
          'AND    item_to_hier.hil_hn_id        = hier_nodes.hn_iD '||
          'AND    hier_segments.ihs_hi_id       = hier_nodes.hn_hi_id '||
          'AND    hier_segments.ihs_hn_id_child = hier_nodes.hn_id '||
          'AND    hier_nodes.hn_hi_id           = hier.hi_id';

	if g_debug_flag = 'Y' then
    		edw_log.debug_line('Procedure eulHierDelete');
    		edw_log.debug_line('Going to execute statement:');
    		edw_log.debug_line(l_stmt);
    	end if;

 IF g_mode <> 'TEST' THEN

   OPEN eulHier_cv FOR l_Stmt;
   LOOP

     FETCH eulHier_cv INTO l_HierID;
     EXIT WHEN eulHier_cv%NOTFOUND;

       -- Delete parent-child relationships
       EXECUTE IMMEDIATE 'DELETE '||
                         'FROM   '||g_EulOwner||'.eul4_HI_SEGMENTS hier_segments '||
                         'WHERE  hier_segments.ihs_hi_id = :1' USING l_HierId;

       -- Delete links from hier nodes to folder.items
       EXECUTE IMMEDIATE 'DELETE '||
                         'FROM   '||g_EulOwner||'.eul4_IG_EXP_LINKS item_to_hier '||
                         'WHERE  hil_hn_id IN '||
                         '(SELECT hn_id '||
                         ' FROM   '||g_EulOwner||'.eul4_HI_NODES '||
                         ' WHERE  hn_hi_id = :1)' USING l_HierId;

       -- Delete hier nodes
       EXECUTE IMMEDIATE 'DELETE '||
                         'FROM   '||g_EulOwner||'.eul4_HI_NODES '||
                         'WHERE  hn_hi_id = :1' USING l_HierId;

       -- Delete hier
       EXECUTE IMMEDIATE 'DELETE '||
                         'FROM   '||g_EulOwner||'.eul4_HIERARCHIES hier '||
                         'WHERE  hier.hi_id = :1' USING l_HierId;

   END LOOP;

   CLOSE eulHier_cv;

	if g_debug_flag = 'Y' then
     		edw_log.put_line('');
     		edw_log.put_line('Deleted Unused time hierarchies from FII Business Areas.');
     		edw_log.put_line('');
        end if;

 END IF;

END eulHierDelete;


/******************************************************************************
 Procedure EULMaint
******************************************************************************/

   PROCEDURE EULMaint(Errbuf           IN OUT  NOCOPY VARCHAR2,
                      Retcode          IN OUT  NOCOPY VARCHAR2,
                      pEulOwnerName    IN      VARCHAR2,
                      pMode            IN      VARCHAR2,
                      pBusAreaName     IN      VARCHAR2,
                      pAction          IN      VARCHAR2)
   IS

     l_exception_msg  VARCHAR2(2400):=Null;
     ctr              PLS_INTEGER := 0;
     lFactChangeCtr   PLS_INTEGER := 0;
     lDimChangeCtr    PLS_INTEGER := 0;
     ba_ctr           PLS_INTEGER := 0;
     tab_ctr          PLS_INTEGER := 0;
     col_ctr          PLS_INTEGER := 0;
     l_stmt           VARCHAR2(2000) := NULL;

   BEGIN

     CHILD_SETUP(pEulOwnerName||'_'||pBusAreaName||'_'||pMode);

     g_EulOwner := UPPER(pEulOwnerName);
     g_Mode     := UPPER(pMode);


     /* Set Business Area Nanes */
     IF pBusAreaName IS NULL THEN

       /* Set FII Bus Areas */
       InitBusAreas(G_BusArea_1,pAction);
       InitBusAreas(G_BusArea_2,pAction);
       InitBusAreas(G_BusArea_3,pAction);

       /* Set Bus Area Tables */
       InitTables(G_BusArea_1);
       InitTables(G_BusArea_2);
       InitTables(G_BusArea_3);

     ELSE

       /* Set Bus Area */
       InitBusAreas(pBusAreaName,pAction);

       /* Set Bus Area Tables */
       InitTables(pBusAreaName);

     END IF;

--     hideFolders(eulTablesTab);

     /* Remove unused time hierarchies for FII bus areas */
     eulHierDelete;

     /* Test usage of GL Acct FlexDimensions
        Hide duplicate levels and unused hierarchies and dimensions
     */
     eulGLFlexDimMaint;



    /* Hide folder items */
    ctr := eulColumnsTab.first;

    FOR col IN 1..eulColumnsTab.count LOOP

        eulColumnsTab(ctr).BA_ID       := eulTablesTab(eulColumnsTab(ctr).folder_id).BA_ID      ;

        ba_ctr := eulColumnsTab(ctr).BA_ID      ;

        eulBusAreaTab(ba_ctr).ba_records_evaluated := eulBusAreaTab(ba_ctr).ba_records_evaluated + 1;

        /* test for number columns to reformat */
      IF eulColumnsTab(ctr).item_data_type = 2 AND
         eulColumnsTab(ctr).table_type = 'F' THEN

         /*
         edw_log.put_line('Item Name '||eulColumnsTab(ctr).item_name);
         edw_log.put_line('Item Heading '||eulColumnsTab(ctr).item_heading);
         edw_log.put_line('Item Format '||eulColumnsTab(ctr).item_format_mask);
         */
         l_stmt := 'UPDATE '||g_EulOwner||'.eul4_expressions '||
                           'SET it_heading = NVL(it_heading,exp_name) , '||
                           '    it_format_mask = NVL(it_format_mask , ''999G999G999G999'') '||
                           'WHERE exp_id = :1';

         EXECUTE IMMEDIATE l_stmt USING eulColumnsTab(ctr).item_id;

         COMMIT;

      END IF;

         /* Test for columns to Hide */
      IF eulColumnsTab(ctr).item_sb_hidden = 1 AND
         eulColumnsTab(ctr).item_hidden = 0 THEN

         hideFolderItems(eulColumnsTab(ctr).item_id);
         /* Update Business Area Ctr for hidden items */
         eulBusAreaTab(ba_ctr).ba_records_hidden := eulBusAreaTab(ba_ctr).ba_records_hidden + 1;

          IF eulColumnsTab(ctr).table_type = 'M' THEN

            lDimChangeCtr := lDimChangeCtr + 1;

          ELSIF eulColumnsTab(ctr).table_type = 'F' THEN

            lFactChangeCtr := lFactChangeCtr + 1;

          ELSE

             NULL;

          END IF;

      ELSIF /*Display instance and other columns for Projects */
            eulColumnsTab(ctr).item_sb_hidden = 0 AND
            eulColumnsTab(ctr).item_hidden = 1 AND
            NVL(INSTR(eulColumnsTab(ctr).column_name,'INSTANCE'),0) > 0 AND
            eulBusAreaTab(ba_ctr).ba_name = G_BusArea_3 THEN
/* in progress */
--         hideFolderItems(eulColumnsTab(ctr).item_id,0);
       NULL;

       ELSE

          NULL;

       END IF;

       ctr := eulColumnsTab.next(ctr);

     END LOOP;

     /* Report on results */
     ba_ctr  := eulBusAreaTab.first;

     FOR ba IN 1..eulBusAreaTab.count LOOP

	if g_debug_flag = 'Y' then
        	edw_log.put_line('');
        	edw_log.put_line(eulBusAreaTab(ba_ctr).ba_name);
        	edw_log.put_line('');
        	edw_log.put_line('  '||RPAD('Table Name',30,' ')||'  '||'Folder Name');
        	edw_log.put_line('  '||RPAD('-',30,'-')||'  '||RPAD('-',30,'-'));
         end if;

        tab_ctr := eulTablesTab.first;

       FOR tab IN 1..eulTablesTab.count LOOP

        IF   eulTablesTab(tab_ctr).BA_ID       = eulBusAreaTab(ba_ctr).ba_id THEN
          if g_debug_flag = 'Y' then
          	edw_log.PUT_LINE('  '||RPAD(eulTablesTab(tab_ctr).table_name,30,' ')||'  '||eulTablesTab(tab_ctr).folder_name);
	  end if;
          IF eulTablesTab(tab_ctr).hidden_item_flag = 'Y' AND eulTablesTab(tab_ctr).folder_sb_hidden = 0 THEN

		if g_debug_flag = 'Y' then
            		edw_log.put_line('     '||RPAD('Column Name',30,' ')||'  '||'Change '||'   '||'Item Name');
            		edw_log.put_line('     '||RPAD('-',30,'-')||'  '||RPAD('-',30,'-'));
                end if;

            col_ctr := eulColumnsTab.first;

            FOR col IN 1..eulColumnsTab.count LOOP

              IF eulColumnsTab(col_ctr).folder_id = eulTablesTab(tab_ctr).folder_Id THEN

                IF eulColumnsTab(col_ctr).item_sb_hidden = 1 AND
                   eulColumnsTab(col_ctr).item_hidden = 0 THEN

                   if g_debug_flag = 'Y' then
                   	edw_log.put_line('     '||RPAD(eulColumnsTab(col_ctr).column_name,30,' ')||'  '||'Hide   '||'   '||eulColumnsTab(col_ctr).item_name);
		   end if;

                ELSIF eulColumnsTab(col_ctr).item_sb_hidden = 0 AND
                      eulColumnsTab(col_ctr).item_hidden = 1 THEN

			if g_debug_flag = 'Y' then
                   		edw_log.put_line('     '||RPAD(eulColumnsTab(col_ctr).column_name,30,' ')||'  '||'Display'||'   '||eulColumnsTab(col_ctr).item_name);
		        end if;
                ELSE

                   NULL;

                END IF;

              END IF;

            col_ctr := eulColumnsTab.next(col_ctr);

            END LOOP;
		if g_debug_flag = 'Y' then
            		edw_log.put_line('    ');
                end if;

          END IF;

        END IF;

      tab_ctr := eulTablesTab.next(tab_ctr);

      END LOOP;
	if g_debug_flag = 'Y' then
    		edw_log.put_line('  ');
    	end if;
    ba_ctr := eulBusAreaTab.next(ba_ctr);

    END LOOP;

     ba_ctr  := eulBusAreaTab.first;

     FOR ba IN 1..eulBusAreaTab.count LOOP

	if g_debug_flag = 'Y' then
       		edw_log.put_line('');
       		edw_log.put_line(eulBusAreaTab(ba_ctr).ba_name||' - ');
       		edw_log.put_line('Items Evaluated:'||eulBusAreaTab(ba_ctr).ba_records_evaluated);
       		edw_log.put_line('Items Hidden:'||eulBusAreaTab(ba_ctr).ba_records_hidden);
	end if;
     ba_ctr := eulBusAreaTab.next(ba_ctr);

     END LOOP;
	if g_debug_flag = 'Y' then
    		edw_log.put_line(eulColumnsTab.count||' Items Evaluated');
    		edw_log.put_line(lFactChangeCtr||' Fact Items Hidden');
    		edw_log.put_line(lDimChangeCtr||' Dimension Items Hidden');

  	end if;

   COMMIT;

   EXCEPTION

   WHEN G_BUSINESS_AREA_DOES_NOT_EXIST THEN
      Errbuf  := g_errbuf;
      Retcode := g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      	if g_debug_flag = 'Y' then
      		edw_log.put_line('Business Area Name not found');
      		edw_log.put_line('Process : '||g_processName);
        end if;
      raise;

   WHEN G_EUL_OWNER_DOES_NOT_EXIST THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      	if g_debug_flag = 'Y' then
      		edw_log.put_line('End User Layer (EUL) Owner not found');
      		edw_log.put_line('Process : '||g_processName);
      	end if;
      raise;

   WHEN OTHERS THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      	if g_debug_flag = 'Y' then
      		edw_log.put_line(l_exception_msg);
      		edw_log.put_line('pAction'||pAction);
      		edw_log.put_line('pEulOwnerName'||g_EulOwner);
      		edw_log.put_line('pBusAreaName'||pBusAreaName);
      		edw_log.put_line('pMode'||g_mode);
      		edw_log.put_line('Process : '||g_processName);
      		edw_log.put_line('l_stmt : '||l_stmt);
     	end if;
      raise;

   END EulMaint;

END FII_EUL4I_UTILS;

/
