--------------------------------------------------------
--  DDL for Package Body AMW_CONSTRAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_CONSTRAINT_PVT" AS
/* $Header: amwvcstb.pls 120.32.12010000.1 2008/07/28 08:35:45 appldev ship $ */

-- ===============================================================
-- Package name
--          AMW_CONSTRAINT_PVT
-- Purpose
--
-- History
-- 		  	11/12/2003    tsho     Creates
--          12/12/2003    tsho     use static sql for database 8.1.7.4.0 with AMW.B
--          04/30/2003    tsho     enable dynamic sql in AMW.C with framework 5.10
--          05/05/2004    tsho     add Get_Functions and related getters
--          01/06/2005    tsho     consider Responsibility, User waivers in AMW.D
--          05/13/2005    tsho     introduce Cocurrent Program, Incomapatible Sets, Revalidation, (Role, GLOBAL Grant/USER Grant) in AMW.E
--          12/01/2005    tsho     add Purge_Violation_Before_Date (for bug 4673154)
--          12/01/2005    psomanat For Perfomance Fix :
--                                 1. Modified procedures Check_For_Func_Cst_ALL
--                                 Check_For_Func_Cst_ME,Check_For_Func_Cst_SET
--                                 Check_For_Resp_Cst_ALL,Check_For_Resp_Cst_ME
--                                 Check_For_Resp_Cst_SET,Populate_Ptnl_Access_List
--                                 Populate_Ptnl_Resps_For_Cst,Write_Func_To_Table_For_User
--                                 Write_Resp_To_Table_For_User,Write_Resp_Violat_to_table
--                                 Write_Resp_Violat_to_table_rvl
--
--                                 2. Added Procedures Populate_User_Vio_For_Cst,
--                                 Populate_User_Vio_For_Vlt,PROCESS_MENU_TREE_DOWN_FOR_CST
-- ===============================================================


-- copy from FND_FUNCTION.G_BULK_COLLECTS_SUPPORTED (AFSCFNSB.pls 115.51 2003/08/01)
-- Bulk collects are a feature that will have the benefit of increasing
-- performance and hopefully reducing I/O reads on dev115
-- But the problem is they cause random failures in 8.1.6.1 databases
-- so we can't use them before 8.1.7.1. (due to database bug 1688232).
-- So we will detect the database version and set this flag to one of:
-- 'UNKNOWN'- Flag needs to be initialized by call to init routine
-- 'TRUE' - supported
-- 'FALSE'- unsupported
-- Once 8.1.7.1+ is required for all Apps customers then this hack
-- Can be gotten rid of, and this can be hardcoded to 'TRUE'
-- 2/03- TM- That time is now... we now require 8.1.7.1+.
G_BULK_COLLECTS_SUPPORTED 	VARCHAR2(30) := 'TRUE';


-- copy from FND_FUNCTION.C_MAX_MENU_ENTRIES (AFSCFNSB.pls 115.51 2003/08/01)
-- This constant is used for recursion detection in the fallback
-- runtime menu scan.  We keep track of how many items are on the menu,
-- and assume if the number of entries on the current
-- menu is too high then it's caused by recursion.
C_MAX_MENU_ENTRIES CONSTANT pls_integer := 10000;


-- copy from FND_FUNCTION.P_LAST_RESP_ID (AFSCFNSB.pls 115.51 2003/08/01)
-- copy from FND_FUNCTION.P_LAST_RESP_APPL_ID (AFSCFNSB.pls 115.51 2003/08/01)
-- copy from FND_FUNCTION.P_LAST_MENU_ID (AFSCFNSB.pls 115.51 2003/08/01)
-- This simple cache will avoid the need to find which menu is on
-- the current responsibility with SQL every time.  We just store
-- the menu around after we get it for the current resp.
P_LAST_RESP_ID NUMBER := -1;
P_LAST_RESP_APPL_ID NUMBER := -1;
P_LAST_MENU_ID NUMBER := -1;


-- store potential violation info (valid for one user against one constraint)
TYPE G_NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE G_DATE_TABLE   IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE G_VARCHAR2_TABLE   IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE G_VARCHAR2_CODE_TABLE   IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE G_VARCHAR2_LONG_TABLE is table of VARCHAR2(320) INDEX BY BINARY_INTEGER;

TYPE G_VARCHAR2_TABLE_TYPE  IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
TYPE G_NUMBER_TABLE_TYPE IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
TYPE G_RESPVIO_RECORD IS RECORD(
     Responsibility_id  NUMBER(15),
     application_id     NUMBER(15),
     Role_Name          VARCHAR2(320),
     Menu_id            NUMBER,
     Function_Id        NUMBER,
     Access_Given_Date  DATE,
     Access_Given_By_Id NUMBER(15),
     Object_Type        VARCHAR2(80),
     group_code         VARCHAR2(80),
     prog_appl_id       NUMBER(15)
);

TYPE G_RESPVIO_ENTRIES_TABLE IS TABLE OF G_RESPVIO_RECORD INDEX BY BINARY_INTEGER;
TYPE G_FUNC_TABLE IS TABLE OF G_RESPVIO_ENTRIES_TABLE INDEX BY BINARY_INTEGER;
TYPE G_RESPVIO_TABLE IS TABLE OF G_FUNC_TABLE INDEX BY VARCHAR2(30);

TYPE G_USERVIO_RECORD IS RECORD(
     User_id            NUMBER(15),
     Role_Name          VARCHAR2(320),
     application_id     NUMBER(15),
     Responsibility_id  NUMBER(15),
     Menu_id            NUMBER,
     Function_Id        NUMBER,
     prog_appl_id       NUMBER(15),
     Access_Given_Date  DATE,
     Access_Given_By_Id NUMBER(15),
     Object_Type        VARCHAR2(80),
     Waived             VARCHAR2(1),
     group_code         VARCHAR2(80)
);

TYPE G_USERVIO_ENTRIES_TABLE IS TABLE OF G_USERVIO_RECORD INDEX BY BINARY_INTEGER;
TYPE G_FUNCS_TABLE IS TABLE OF G_USERVIO_ENTRIES_TABLE INDEX BY BINARY_INTEGER;
TYPE G_USERVIO_TABLE IS TABLE OF G_FUNCS_TABLE INDEX BY BINARY_INTEGER;

TYPE G_RESPS_TABLE IS TABLE OF G_USERVIO_ENTRIES_TABLE INDEX BY VARCHAR2(30);
TYPE G_USERESPVIO_TABLE IS TABLE OF G_RESPS_TABLE INDEX BY BINARY_INTEGER;
G_PV_COUNT                  NUMBER;
G_PV_FUNCTION_ID_LIST            G_NUMBER_TABLE;     -- Stores the FUNC or CP id
G_PV_MENU_ID_LIST                G_NUMBER_TABLE;
G_PV_RESPONSIBILITY_ID_LIST      G_NUMBER_TABLE;
G_PV_APPLICATION_ID_LIST         G_NUMBER_TABLE;
G_PV_ACCESS_GIVEN_DATE_LIST      G_DATE_TABLE;
G_PV_ACCESS_GIVEN_BY_LIST        G_NUMBER_TABLE;
G_PV_GROUP_CODE_LIST             G_VARCHAR2_CODE_TABLE;
-- 05.25.2006 : psomanat : Fix for bug 5214858
G_PV_PROGRAM_APPL_ID_LIST        G_NUMBER_TABLE;     -- Stores CP application Id
G_PV_OBJECT_TYPE_LIST            G_VARCHAR2_CODE_TABLE;     -- Stores Object Type
G_RESP_VIOLATIONS_LIST           G_RESPVIO_TABLE;
G_UNEXCL_FUNC_ID_LIST            G_NUMBER_TABLE_TYPE;
G_UNEXCL_GRP_CODE_LIST           G_VARCHAR2_TABLE_TYPE;

G_PV_FUNCTION_ID            NUMBER := NULL;
G_PV_MENU_ID                NUMBER := NULL;
G_PV_RESPONSIBILITY_ID      NUMBER := NULL;
G_PV_APPLICATION_ID         NUMBER := NULL;
G_PV_ACCESS_GIVEN_DATE      DATE   := NULL;
G_PV_ACCESS_GIVEN_BY        NUMBER := NULL;
G_PV_GROUP_CODE             VARCHAR2(30) := NULL;

-- store the potential responsibilities(and corresponding application_id , menu_id) by specified constraint_rev_id
G_PNTL_RESP_ID_LIST     G_NUMBER_TABLE;
G_PNTL_APPL_ID_LIST     G_NUMBER_TABLE;
G_PNTL_MENU_ID_LIST     G_NUMBER_TABLE;
G_PNTL_FUNCTION_ID_LIST G_NUMBER_TABLE;
G_PNTL_GRP_CODE_LIST    G_NUMBER_TABLE;
G_PNTL_RESP_VIO_LIST    G_RESPVIO_TABLE;

-- store the potential user id for one constraint
G_CST_USER_ID_LIST   G_NUMBER_TABLE;
--05.17.2005 tsho: starting from AMW.E, store user_name in addition to user_id for use in G_AMW_USER_ROLES
G_CST_USER_NAME_LIST G_VARCHAR2_LONG_TABLE;

-- store the user potential violation
G_UPV_COUNT                       NUMBER;
G_UPV_FUNCTION_ID_LIST            G_NUMBER_TABLE;
G_UPV_MENU_ID_LIST                G_NUMBER_TABLE;
G_UPV_RESPONSIBILITY_ID_LIST      G_NUMBER_TABLE;
G_UPV_APPLICATION_ID_LIST         G_NUMBER_TABLE;
G_UPV_PROGRAM_APPL_ID_LIST        G_NUMBER_TABLE;
G_UPV_ACCESS_GIVEN_DATE_LIST      G_DATE_TABLE;
G_UPV_ACCESS_GIVEN_BY_LIST        G_NUMBER_TABLE;
G_UPV_ROLE_NAME_LIST              G_VARCHAR2_LONG_TABLE;
G_UPV_GROUP_CODE_LIST             G_VARCHAR2_CODE_TABLE;
G_UPV_ENTRY_OBJECT_TYPE_LIST      G_VARCHAR2_CODE_TABLE;
--psomanat : Fix for 5236356
G_USER_VIOLATIONS_LIST            G_USERVIO_TABLE;
G_USER_RESP_VIO_LIST              G_USERESPVIO_TABLE;
G_User_Waiver_List                G_NUMBER_TABLE;
G_User_Violation_Id_list          G_NUMBER_TABLE;

-- ===============================================================
-- Private Function name
--          BULK_COLLECTS_SUPPORTED
--
-- Purpose
--          This temporary routine determines whether bulk collects are supported.
--          See comments around G_BULK_COLLECTS_SUPPORTED above
--
-- Return
--          True    := BULK COLLECTS SUPPORTED
--          False   := BULK COLLECTS NOT SUPPORTED
--
-- Notes
--          copy from FND_FUNCTION.BULK_COLLECTS_SUPPORTED (AFSCFNSB.pls 115.51 2003/08/01)
--          since it's private function in FND_FUNCTION
--
-- ===============================================================
FUNCTION BULK_COLLECTS_SUPPORTED
RETURN boolean
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'BULK_COLLECTS_SUPPORTED';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

ver varchar2(255);

begin
  --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

  begin
    if (G_BULK_COLLECTS_SUPPORTED = 'TRUE') then
      return TRUE;
    elsif (G_BULK_COLLECTS_SUPPORTED = 'FALSE') then
      return FALSE;
    elsif (G_BULK_COLLECTS_SUPPORTED = 'UNKNOWN') then
      -- 11.17.2003 tsho: return false if unknown
      /*
      select version
        into ver
        from v$instance
       where rownum = 1;

      if(ver >= '8.1.7.1.0') then
         G_BULK_COLLECTS_SUPPORTED := 'TRUE';
         return (TRUE);
      else
         G_BULK_COLLECTS_SUPPORTED := 'FALSE';
         return (FALSE);
      end if;
      */
      return (FALSE);
    else
      return (FALSE); /* Should never happen */
    end if;
  exception
    when others then
      return FALSE; /* Should never happen */
  end;
end BULK_COLLECTS_SUPPORTED;

-- ===============================================================
-- Private Function name
--          PROCESS_MENU_TREE_DOWN_FOR_CST
--
-- Purpose
--          Plow through the menu tree, processing exclusions and figuring
--          out which functions are accessible.
--
--
-- Params
--          p_menu_id           := menu_id
--          p_function_id       := function to check for
--
--          Don't pass values for the following two params if you don't want
--          exclusions processed.
--          p_appl_id           := application id of resp
--          p_resp_id           := responsibility id
--
--          p_access_given_date := start_date of user resp  (added for AMW)
--          p_access_given_by   := created_by of user resp  (added for AMW)
--
-- Return
--          True    := function accessible
--          False   := function not accessible
--
-- Notes
--          copy from FND_FUNCTION.PROCESS_MENU_TREE_DOWN_FOR_MN (AFSCFNSB.pls 115.51 2003/08/01)
--          and modify for AMW to use dynamic sql
--
--          12.21.2004 tsho: set default NULL for p_access_given_date, p_access_given_by
--          12.21.2004 tsho: fix for performance bug 4036679
-- History
--          05.24.2005 tsho: AMW.E Incompatible Sets,
--          need to pass in amw_constraint_entries.group_code for each item
-- ===============================================================
FUNCTION PROCESS_MENU_TREE_DOWN_FOR_CST(
  p_constraint_rev_id in number,
  p_menu_id     in number,
  p_appl_id     in number,
  p_resp_id     in number
) RETURN boolean
IS

  L_API_NAME                  CONSTANT VARCHAR2(30) := 'PROCESS_MENU_TREE_DOWN_FOR_MN';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;
  l_sub_menu_id number;

  /* Table to store the list of submenus that we are looking for */
  MENULIST  G_NUMBER_TABLE;

  /* The table of exclusions.  The index in is the action_id, and the */
  /* value stored in each element is the rule_type.*/
  EXCLUSIONS G_VARCHAR2_TABLE;

  /* Returns from the bulk collect (fetches) */
  TBL_MENU_ID G_NUMBER_TABLE;
  TBL_ENT_SEQ G_NUMBER_TABLE;
  TBL_FUNC_ID G_NUMBER_TABLE;
  TBL_SUBMNU_ID G_NUMBER_TABLE;
  TBL_GNT_FLG G_VARCHAR2_TABLE;
  TBL_ACCESS_GIVEN_DATE G_DATE_TABLE;         --05.25-2006 :psomanat : Fix for bug 5214858
  TBL_ACCESS_GIVEN_BY   G_NUMBER_TABLE;    --05.25-2006 :psomanat : Fix for bug 5214858

  TYPE exclCurTyp IS REF CURSOR;
  excl_c exclCurTyp;
  l_excl_rule_list     G_VARCHAR2_CODE_TABLE;
  l_excl_act_id_list     G_NUMBER_TABLE;

  l_excl_dynamic_sql   VARCHAR2(200)  :=
        'SELECT RULE_TYPE, ACTION_ID '
      ||'  FROM '||G_AMW_RESP_FUNCTIONS
      ||' WHERE application_id = :1 '
      ||'   AND responsibility_id = :2 ';


  TYPE mnesCurTyp IS REF CURSOR;
  get_mnes_c mnesCurTyp;
  l_mnes_dynamic_sql   VARCHAR2(200)  :=
        'SELECT MENU_ID, ENTRY_SEQUENCE, FUNCTION_ID, SUB_MENU_ID, GRANT_FLAG,CREATION_DATE,CREATED_BY '
      ||'  FROM '||G_AMW_MENU_ENTRIES
      ||' WHERE menu_id  = :1 ';

  menulist_cur pls_integer;
  menulist_size pls_integer;

  entry_excluded boolean;
  last_index pls_integer;
  i number;
  z number;

  -- psomanat : 06:09:2006 : fix for bug 5256720
  L_RESPVIO_ENTRIES  G_RESPVIO_ENTRIES_TABLE;
  L_FUNC_ID_LIST G_FUNC_TABLE;
  counts number;
  is_duplicate boolean;
  listkey VARCHAR2(30) := NULL;
  entry_unexcluded boolean;
  unexclkey VARCHAR2(30) := NULL;
  l_searched_func_id_list G_NUMBER_TABLE_TYPE;
  l_group_code VARCHAR2(1):=null;


BEGIN

    OPEN excl_c FOR l_excl_dynamic_sql USING
        p_appl_id,
        p_resp_id;
    FETCH excl_c BULK COLLECT INTO l_excl_rule_list,l_excl_act_id_list;
    CLOSE excl_c;

    IF (l_excl_rule_list IS NOT NULL) AND (l_excl_rule_list.FIRST IS NOT NULL) THEN
        FOR i in l_excl_rule_list.FIRST .. l_excl_rule_list.LAST
        LOOP
            EXCLUSIONS(l_excl_act_id_list(i)) := l_excl_rule_list(i);
        END LOOP;
    END IF;

    -- releasing the memory
    l_excl_rule_list.delete();
    l_excl_act_id_list.delete();

    -- Initialize menulist working list to parent menu
    menulist_cur := 0;
    menulist_size := 1;
    menulist(0) := p_menu_id;

    -- Continue processing until reach the end of list
    WHILE (menulist_cur < menulist_size)
    LOOP
        -- Check if recursion limit exceeded
        IF (menulist_cur > C_MAX_MENU_ENTRIES) THEN
            /* If the function were accessible from this menu, then we should */
            /* have found it before getting to this point, so we are confident */
            /* that the function is not on this menu. */
            RETURN FALSE;
        END IF;

        l_sub_menu_id := menulist(menulist_cur);

        -- See whether the current menu is excluded or not.
        entry_excluded := FALSE;
        BEGIN
            IF ((l_sub_menu_id IS NOT NULL) AND (exclusions(l_sub_menu_id) = 'M')) THEN
                entry_excluded := TRUE;
            END IF;
        EXCEPTION
            WHEN no_data_found THEN
                null;
        END;

        IF (entry_excluded) THEN
            last_index := 0; /* Indicate that no rows were returned */
        ELSE
            OPEN get_mnes_c FOR l_mnes_dynamic_sql USING l_sub_menu_id;
            FETCH get_mnes_c
            BULK COLLECT INTO tbl_menu_id,
                              tbl_ent_seq,
                              tbl_func_id,
                              tbl_submnu_id,
                              tbl_gnt_flg,
                              tbl_access_given_date,
                              tbl_access_given_by;
            CLOSE get_mnes_c;

            IF ((tbl_menu_id.FIRST is NULL) or (tbl_menu_id.FIRST IS NULL)) THEN
                last_index := 0;
            ELSE
                last_index := tbl_menu_id.LAST;
            END IF;
        END IF;
        -- Process each of the child entries fetched
        FOR i in 1 .. last_index LOOP
            entry_excluded := FALSE;
            begin
                if( (tbl_func_id(i) is not NULL)
                    and (exclusions(tbl_func_id(i)) = 'F')) then
                    entry_excluded := TRUE;

                    -- We store the excluded function_id in l_searched_func_id_list
                    -- we use this list to check if we have validated alll the
                    -- unexcluded incompatible funtions for a given responsibility
                    listkey :=tbl_func_id(i)||'@'||1;
                    IF G_UNEXCL_FUNC_ID_LIST.EXISTS(listkey) THEN
                        IF NOT l_searched_func_id_list.EXISTS(listkey) THEN
                            l_searched_func_id_list(listkey) :=tbl_func_id(i);
                        END IF;
                    END IF;
                    listkey :=tbl_func_id(i)||'@'||2;
                    IF G_UNEXCL_FUNC_ID_LIST.EXISTS(listkey) THEN
                        IF NOT l_searched_func_id_list.EXISTS(listkey) THEN
                            l_searched_func_id_list(listkey) :=tbl_func_id(i);
                        END IF;
                    END IF;
                end if;
            exception
                when no_data_found then
                null;
            end;

            if (not entry_excluded ) then
                IF tbl_func_id(i) is not NULL THEN
                    entry_unexcluded := FALSE;
                    -- Check if this is a matching function.  If so, return success.
                    listkey :=tbl_func_id(i)||'@'||1;
                    IF G_UNEXCL_FUNC_ID_LIST.EXISTS(listkey) THEN
                        entry_unexcluded := TRUE;
                        unexclkey :=listkey;
                        l_group_code:='1';
                    END IF;
                    listkey :=tbl_func_id(i)||'@'||2;
                    IF G_UNEXCL_FUNC_ID_LIST.EXISTS(listkey) THEN
                        entry_unexcluded := TRUE;
                        unexclkey :=listkey;
                        l_group_code:='2';
                    END IF;

                    IF (entry_unexcluded AND (tbl_gnt_flg(i) = 'Y')) THEN

                        -- We store the processed function_id in l_searched_func_id_list
                        -- we use this list to check if we have validated alll the
                        -- unexcluded incompatible funtions for a given responsibility
                        IF NOT l_searched_func_id_list.EXISTS(unexclkey) THEN
                            l_searched_func_id_list(unexclkey) :=tbl_func_id(i);
                        END IF;

                        L_FUNC_ID_LIST.delete();
                        L_RESPVIO_ENTRIES.delete();

                        -- To identify a responsibility we need application id and responsibility.
                        -- So the key is like application_id@responsibility_id
                        listkey := p_appl_id||'@'||p_resp_id;

                        -- Here we check if the responsibility allready exists in G_RESP_VIOLATIONS_LIST.
                        -- If Yes, we get the function list
                        --    check if the function list contains the FUNCTION ID  refered by
                        --    tbl_func_id(i)
                        --    If yes, we get the responsibility violation plsql record and
                        --       add a new record to the existing records
                        -- End
                        -- Note : when any of the check fails, the corresponding NestedTable entry
                        --        or plsql entry is newly created and added to the main G_RESP_VIOLATIONS_LIST
                        IF (G_RESP_VIOLATIONS_LIST.EXISTS(listkey)) THEN
                            L_FUNC_ID_LIST := G_RESP_VIOLATIONS_LIST(listkey);
                            IF L_FUNC_ID_LIST.EXISTS(tbl_func_id(i)) THEN
                                L_RESPVIO_ENTRIES := L_FUNC_ID_LIST(tbl_func_id(i));
                            END IF;
                        END IF;

                        -- before adding a record to responsibility violation plsql record
                        -- we check if the current function tbl_func_id(i) detail is
                        -- available in the responsibility violation plsql records
                        is_duplicate := FALSE;
                        IF ((L_RESPVIO_ENTRIES IS NOT NULL) and (L_RESPVIO_ENTRIES.FIRST IS NOT NULL)) THEN
                            FOR j IN  L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                            LOOP
                                IF L_RESPVIO_ENTRIES(j).Menu_id = tbl_menu_id(i) THEN
                                    is_duplicate := TRUE;
                                    EXIT;
                                END IF;
                            END LOOP;
                        END IF;

                        IF NOT is_duplicate THEN
                            counts := L_RESPVIO_ENTRIES.COUNT+1;
                            L_RESPVIO_ENTRIES(counts).application_id     := p_appl_id;
                            L_RESPVIO_ENTRIES(counts).Responsibility_id  := p_resp_id;
                            L_RESPVIO_ENTRIES(counts).Menu_id            := tbl_menu_id(i);
                            L_RESPVIO_ENTRIES(counts).Function_Id        := tbl_func_id(i);
                            L_RESPVIO_ENTRIES(counts).Access_Given_Date  := TBL_ACCESS_GIVEN_DATE(i);
                            L_RESPVIO_ENTRIES(counts).Access_Given_By_Id := TBL_ACCESS_GIVEN_BY(i);
                            L_RESPVIO_ENTRIES(counts).Object_Type        := 'FUNC';
                            L_RESPVIO_ENTRIES(counts).group_code         := l_group_code;
                            L_RESPVIO_ENTRIES(counts).prog_appl_id       := NULL;
                            L_RESPVIO_ENTRIES(counts).Role_Name          := NULL;
                            L_FUNC_ID_LIST(tbl_func_id(i))               := L_RESPVIO_ENTRIES;
                            G_RESP_VIOLATIONS_LIST(listkey)            := L_FUNC_ID_LIST;
                        END IF;

                        /*FND_FILE.put_line(fnd_file.log,'*****************');
                        FND_FILE.put_line(fnd_file.log,'Responsibility_id  '||p_resp_id);
                        FND_FILE.put_line(fnd_file.log,'p_appl_id          '||p_appl_id);
                        FND_FILE.put_line(fnd_file.log,'tbl_menu_id        '||tbl_menu_id(i));
                        FND_FILE.put_line(fnd_file.log,'p_function_id      '||tbl_func_id(i));
                        FND_FILE.put_line(fnd_file.log,'p_group_code       '||l_group_code);
                        FND_FILE.put_line(fnd_file.log,'*****************');
                        FND_FILE.put_line(fnd_file.log,'tbl_func_id(i) '||tbl_func_id(i));
                        FND_FILE.put_line(fnd_file.log,'G_UNEXCL_FUNC_ID_LIST.COUNT'||G_UNEXCL_FUNC_ID_LIST.COUNT);
                        FND_FILE.put_line(fnd_file.log,'l_searched_func_id_list.COUNT'||l_searched_func_id_list.COUNT); */

                        -- When the unexcluded function count equals searched function count,
                        -- we have processed all the unexcluded function. So we need to stop
                        -- digging into the responsibility menu hierarchy
                        IF l_searched_func_id_list.COUNT = G_UNEXCL_FUNC_ID_LIST.COUNT THEN
                            RETURN TRUE;
                        END IF;
                    END IF;
                END IF;
                -- If this is a submenu, then add it to the end of the
                -- working list for processing.
                IF (tbl_submnu_id(i) IS NOT NULL) THEN
                    menulist(menulist_size) := tbl_submnu_id(i);
                    menulist_size := menulist_size + 1;
                END IF;
            END IF; -- End if not excluded
        END LOOP;  -- For loop processing child entries
        -- Advance to next menu on working list
        menulist_cur := menulist_cur + 1;
    END LOOP;

    -- We couldn't find the function anywhere, so it's not available
    return FALSE;
END PROCESS_MENU_TREE_DOWN_FOR_CST;


-- ===============================================================
-- Private Function name
--          PROCESS_MENU_TREE_DOWN_FOR_MN
--
-- Purpose
--          Plow through the menu tree, processing exclusions and figuring
--          out which functions are accessible.
--
--          This routine processes the menu hierarchy and exclusion rules in PL/SQL
--          rather than in the database.
--          The basic algorithm of this routine is:
--          Populate the list of exclusions by selecting from FND_RESP_FUNCTIONS
--          menulist(1) = p_menu_id
--          while (elements on menulist)
--          {
--              Remove first element off menulist
--              if this menu is not excluded with a menu exclusion rule
--              {
--                  Query all menu entry children of current menu
--                  for (each child) loop
--                  {
--                      If it's excluded by a func exclusion rule, go on to the next one.
--                      If we've got the function we're looking for,
--                        and grant_flag = Y, we're done- return TRUE;
--                      If it's got a sub_menu_id, add it to the end of menulist
--                        to be processed
--                  }
--                  Move to next element on menulist
--              }
--          }
--
-- Params
--          p_menu_id           := menu_id
--          p_function_id       := function to check for
--
--          Don't pass values for the following two params if you don't want
--          exclusions processed.
--          p_appl_id           := application id of resp
--          p_resp_id           := responsibility id
--
--          p_access_given_date := start_date of user resp  (added for AMW)
--          p_access_given_by   := created_by of user resp  (added for AMW)
--
-- Return
--          True    := function accessible
--          False   := function not accessible
--
-- Notes
--          copy from FND_FUNCTION.PROCESS_MENU_TREE_DOWN_FOR_MN (AFSCFNSB.pls 115.51 2003/08/01)
--          and modify for AMW to use dynamic sql
--
--          12.21.2004 tsho: set default NULL for p_access_given_date, p_access_given_by
--          12.21.2004 tsho: fix for performance bug 4036679
-- History
--          05.24.2005 tsho: AMW.E Incompatible Sets,
--          need to pass in amw_constraint_entries.group_code for each item
-- ===============================================================
FUNCTION PROCESS_MENU_TREE_DOWN_FOR_MN(
  p_menu_id     in number,
  p_function_id in number,
  p_appl_id     in number,
  p_resp_id     in number,
  p_access_given_date   in date := NULL,
  p_access_given_by     in number := NULL,
  p_group_code          in varchar2 := NULL
) RETURN boolean
IS

  L_API_NAME                  CONSTANT VARCHAR2(30) := 'PROCESS_MENU_TREE_DOWN_FOR_MN';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

  l_sub_menu_id number;

  /* Table to store the list of submenus that we are looking for */
  TYPE MENULIST_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  MENULIST  MENULIST_TYPE;

  TYPE NUMBER_TABLE_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  TYPE VARCHAR2_TABLE_TYPE is table of VARCHAR2(1) INDEX BY BINARY_INTEGER;

  /* The table of exclusions.  The index in is the action_id, and the */
  /* value stored in each element is the rule_type.*/
  EXCLUSIONS VARCHAR2_TABLE_TYPE;

  /* Returns from the bulk collect (fetches) */
  TBL_MENU_ID NUMBER_TABLE_TYPE;
  TBL_ENT_SEQ NUMBER_TABLE_TYPE;
  TBL_FUNC_ID NUMBER_TABLE_TYPE;
  TBL_SUBMNU_ID NUMBER_TABLE_TYPE;
  TBL_GNT_FLG VARCHAR2_TABLE_TYPE;
  TBL_ACCESS_GIVEN_DATE G_DATE_TABLE;         --05.25-2006 :psomanat : Fix for bug 5214858
  TBL_ACCESS_GIVEN_BY   NUMBER_TABLE_TYPE;    --05.25-2006 :psomanat : Fix for bug 5214858

  /* Cursor to get exclusions */
  -- 11.12.2003 tsho: use dynamic sql for AMW
  /*
  cursor excl_c is
      SELECT RULE_TYPE, ACTION_ID from fnd_resp_functions
       where application_id = p_appl_id
         and responsibility_id = p_resp_id;
  */
  -- 12.12.2003 tsho: use static sql for AMW for the time being
  -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
  TYPE exclCurTyp IS REF CURSOR;
  excl_c exclCurTyp;
  l_excl_rule_type     VARCHAR2(30);
  l_excl_action_id     NUMBER;
  l_excl_dynamic_sql   VARCHAR2(200)  :=
        'SELECT RULE_TYPE, ACTION_ID '
      ||'  FROM '||G_AMW_RESP_FUNCTIONS
      ||' WHERE application_id = :1 '
      ||'   AND responsibility_id = :2 ';


  /* Cursor to get menu entries on a particular menu.*/
  -- 11.12.2003 tsho: use dynamic sql for AMW
  /*
  cursor get_mnes_c is
      SELECT MENU_ID, ENTRY_SEQUENCE, FUNCTION_ID, SUB_MENU_ID, GRANT_FLAG
        from fnd_menu_entries
       where MENU_ID  = l_sub_menu_id;
  */
  -- 12.12.2003 tsho: use static sql for AMW for the time being
  -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
  TYPE mnesCurTyp IS REF CURSOR;
  get_mnes_c mnesCurTyp;
  l_mnes_menu_id        NUMBER;
  l_mnes_entry_sequence NUMBER;
  l_mnes_function_id    NUMBER;
  l_mnes_sub_menu_id    NUMBER;
  l_mnes_grant_flag     VARCHAR2(1);
-- 05.25.2006 : psomanat : Fix for bug 5214858
  l_access_given_date   DATE;
  l_access_given_by     NUMBER;
  l_mnes_dynamic_sql   VARCHAR2(200)  :=
        'SELECT MENU_ID, ENTRY_SEQUENCE, FUNCTION_ID, SUB_MENU_ID, GRANT_FLAG,CREATION_DATE,CREATED_BY '
      ||'  FROM '||G_AMW_MENU_ENTRIES
      ||' WHERE menu_id  = :1 ';

  menulist_cur pls_integer;
  menulist_size pls_integer;

  entry_excluded boolean;
  last_index pls_integer;
  i number;
  z number;

BEGIN
  --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

  if(p_appl_id is not NULL) then
    /* Select the list of exclusion rules into our cache */
    -- 11.12.2003 tsho: use dynamic sql for AMW
    /*
    for excl_rec in excl_c loop
       EXCLUSIONS(excl_rec.action_id) := excl_rec.rule_type;
    end loop;
    */
    -- 12.12.2003 tsho: use static sql for AMW for the time being
    -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
    OPEN excl_c FOR l_excl_dynamic_sql USING
        p_appl_id,
        p_resp_id;
    LOOP
        FETCH excl_c INTO l_excl_rule_type, l_excl_action_id;
        EXIT WHEN excl_c%NOTFOUND;
        EXCLUSIONS(l_excl_action_id) := l_excl_rule_type;
    END LOOP;
    CLOSE excl_c;

  end if;


  -- Initialize menulist working list to parent menu
  menulist_cur := 0;
  menulist_size := 1;
  menulist(0) := p_menu_id;

  -- Continue processing until reach the end of list
  while (menulist_cur < menulist_size) loop
    -- Check if recursion limit exceeded
    if (menulist_cur > C_MAX_MENU_ENTRIES) then
      /* If the function were accessible from this menu, then we should */
      /* have found it before getting to this point, so we are confident */
      /* that the function is not on this menu. */
      return FALSE;
    end if;

    l_sub_menu_id := menulist(menulist_cur);

    -- See whether the current menu is excluded or not.
    entry_excluded := FALSE;
    begin
      if(    (l_sub_menu_id is not NULL)
         and (exclusions(l_sub_menu_id) = 'M')) then
        entry_excluded := TRUE;
      end if;
    exception
      when no_data_found then
        null;
    end;

    if (entry_excluded) then
      last_index := 0; /* Indicate that no rows were returned */
    else
      /* This menu isn't excluded, so find out whats entries are on it. */
      if (BULK_COLLECTS_SUPPORTED) then
        -- 11.12.2003 tsho: use dynamic sql for AMW
        /*
        open get_mnes_c;
        */
        -- 12.12.2003 tsho: use static sql for AMW for the time being
        -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
        open get_mnes_c for l_mnes_dynamic_sql USING
            l_sub_menu_id;

        fetch get_mnes_c bulk collect into tbl_menu_id, tbl_ent_seq,
             tbl_func_id, tbl_submnu_id, tbl_gnt_flg,TBL_ACCESS_GIVEN_DATE,TBL_ACCESS_GIVEN_BY;
        close get_mnes_c;

        -- See if we found any rows. If not set last_index to zero.
        begin
          if((tbl_menu_id.FIRST is NULL) or (tbl_menu_id.FIRST <> 1)) then
            last_index := 0;
          else
            if (tbl_menu_id.FIRST is not NULL) then
              last_index := tbl_menu_id.LAST;
            else
              last_index := 0;
            end if;
          end if;
        exception
          when others then
            last_index := 0;
        end;
      else
        z:= 0;

        -- 11.12.2003 tsho: use dynamic sql for AMW
        /*
        for rec in get_mnes_c loop
          z := z + 1;
          tbl_menu_id(z) := rec.MENU_ID;
          tbl_ent_seq(z) := rec.ENTRY_SEQUENCE;
          tbl_func_id(z) := rec.FUNCTION_ID;
          tbl_submnu_id (z):= rec.SUB_MENU_ID;
          tbl_gnt_flg(z) := rec.GRANT_FLAG;
        end loop;
        */
        -- 12.12.2003 tsho: use static sql for AMW for the time being
        -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
        OPEN get_mnes_c FOR l_mnes_dynamic_sql USING
            l_sub_menu_id;
        LOOP
            FETCH get_mnes_c INTO l_mnes_menu_id,
                                  l_mnes_entry_sequence,
                                  l_mnes_function_id,
                                  l_mnes_sub_menu_id,
                                  l_mnes_grant_flag,
                                  l_access_given_date,
                                  l_access_given_by;
            EXIT WHEN get_mnes_c%NOTFOUND;
            tbl_menu_id(z) := l_mnes_menu_id;
            tbl_ent_seq(z) := l_mnes_entry_sequence;
            tbl_func_id(z) := l_mnes_function_id;
            tbl_submnu_id (z):= l_mnes_sub_menu_id;
            tbl_gnt_flg(z) := l_mnes_grant_flag;
        END LOOP;
        CLOSE get_mnes_c;

        last_index := z;
      end if;


    end if; /* entry_excluded */

    -- Process each of the child entries fetched
    for i in 1 .. last_index loop
      -- Check if there is an exclusion rule for this entry
      entry_excluded := FALSE;
      begin
        if(    (tbl_func_id(i) is not NULL)
           and (exclusions(tbl_func_id(i)) = 'F')) then
          entry_excluded := TRUE;
        end if;
      exception
        when no_data_found then
          null;
      end;

      -- Skip this entry if it's excluded
      if (not entry_excluded) then
        -- Check if this is a matching function.  If so, return success.
        if(    (tbl_func_id(i) = p_function_id)
           and (tbl_gnt_flg(i) = 'Y'))
        then
          -- 12.21.2004 tsho: fix for performance bug 4036679, store in the global list directly
          -- 11.14.2003 tsho: populate the global potential violation info
          /*
          G_PV_MENU_ID                  := tbl_menu_id(i);
          G_PV_FUNCTION_ID              := p_function_id;
          G_PV_RESPONSIBILITY_ID        := p_resp_id;
          G_PV_ACCESS_GIVEN_DATE        := p_access_given_date;
          G_PV_ACCESS_GIVEN_BY          := p_access_given_by;
          FND_FILE.put_line(fnd_file.log,'inside '||L_API_NAME || ': ');
          FND_FILE.put_line(fnd_file.log,'G_PV_RESPONSIBILITY_ID: '||G_PV_RESPONSIBILITY_ID);
          FND_FILE.put_line(fnd_file.log,'G_PV_MENU_ID: '||G_PV_MENU_ID);
          FND_FILE.put_line(fnd_file.log,'G_PV_FUNCTION_ID: '||G_PV_FUNCTION_ID);
          */
          G_PV_MENU_ID_LIST(G_PV_COUNT)             := tbl_menu_id(i);
          G_PV_FUNCTION_ID_LIST(G_PV_COUNT)         := p_function_id;
          G_PV_RESPONSIBILITY_ID_LIST(G_PV_COUNT)   := p_resp_id;
          G_PV_APPLICATION_ID_LIST(G_PV_COUNT)      := p_appl_id;
          G_PV_ACCESS_GIVEN_DATE_LIST(G_PV_COUNT)   := TBL_ACCESS_GIVEN_DATE(i);
          G_PV_ACCESS_GIVEN_BY_LIST(G_PV_COUNT)     := TBL_ACCESS_GIVEN_BY(i);
          G_PV_GROUP_CODE_LIST(G_PV_COUNT)          := p_group_code; -- 05.24.2005 tsho: AMW.E Incompatible Sets
          --05.25.06 : psomanat : Fix for bug 5214858
          G_PV_PROGRAM_APPL_ID_LIST(G_PV_COUNT)     := NULL;
          G_PV_OBJECT_TYPE_LIST(G_PV_COUNT)         := 'FUNC';
          G_PV_COUNT := G_PV_COUNT +1;
          return TRUE;
        end if;

        -- If this is a submenu, then add it to the end of the
        -- working list for processing.
        if (tbl_submnu_id(i) is not NULL) then
          menulist(menulist_size) := tbl_submnu_id(i);
          menulist_size := menulist_size + 1;
        end if;
      end if; -- End if not excluded
    end loop;  -- For loop processing child entries

    -- Advance to next menu on working list
    menulist_cur := menulist_cur + 1;
  end loop;

  -- We couldn't find the function anywhere, so it's not available
  return FALSE;

END PROCESS_MENU_TREE_DOWN_FOR_MN;





-- ===============================================================
-- Private Function name
--          PROCESS_MENU_TREE_DOWN
--
-- Purpose
--          Plow through the menu tree, processing exclusions and figuring
--          out which functions are accessible.
--
-- Params
--          p_appl_id           := application id of resp
--          p_resp_id           := responsibility id of current user
--          p_function_id       := function to check for
--          p_access_given_date := start_date of user resp  (added for AMW)
--          p_access_given_by   := created_by of user resp  (added for AMW)
--
-- Return
--          True    := function accessible
--          False   := function not accessible
--
-- Notes
--          copy from FND_FUNCTION.PROCESS_MENU_TREE_DOWN (AFSCFNSB.pls 115.51 2003/08/01)
--          and modify for AMW to use dynamic sql
--
--           12.21.2004 tsho: set default NULL for p_access_given_date, p_access_given_by
-- ===============================================================
FUNCTION PROCESS_MENU_TREE_DOWN (
  p_appl_id in number,
  p_resp_id in number,
  p_function_id in number,
  p_access_given_date in date := NULL,
  p_access_given_by in number := NULL
) RETURN boolean
IS
  l_menu_id NUMBER;

  L_API_NAME                  CONSTANT VARCHAR2(30) := 'PROCESS_MENU_TREE_DOWN';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

  -- 11.13.2003 tsho: use dynamic sql for AMW
  -- 12.12.2003 tsho: use static sql for AMW for the time being
  -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
  TYPE respCurTyp IS REF CURSOR;
  resp_c respCurTyp;
  l_resp_dynamic_sql   VARCHAR2(200)  :=
        'SELECT menu_id '
      ||'  FROM '||G_AMW_RESPONSIBILITY
      ||' WHERE responsibility_id = :1 '
      ||'   AND application_id = :2 ';

BEGIN
  --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

  if (    (P_LAST_RESP_ID = p_resp_id)
      and (P_LAST_RESP_APPL_ID = p_appl_id)) then
     /* If the cache is valid just use the cache */
     l_menu_id := P_LAST_MENU_ID;
  else
    /* Find the root menu for this responsibility */
    begin

      -- 11.13.2003 tsho: use dynamic sql for AMW
      /*
      select menu_id
        into l_menu_id
        from fnd_responsibility
       where responsibility_id = p_resp_id
         and application_id    = p_appl_id;
      */
      -- 12.12.2003 tsho: use static sql for AMW for the time being
      -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
      OPEN resp_c FOR l_resp_dynamic_sql USING
        p_resp_id,
        p_appl_id;
      FETCH resp_c INTO l_menu_id;
      CLOSE resp_c;


      /* Store the new value in the cache */
      P_LAST_RESP_ID := p_resp_id;
      P_LAST_RESP_APPL_ID := p_appl_id;
      P_LAST_MENU_ID := l_menu_id;
    exception
      when no_data_found then
        /* No menu for this resp, so there can't be any functions */
        return FALSE;
    end;
  end if;
  return PROCESS_MENU_TREE_DOWN_FOR_MN(l_menu_id,
                                       p_function_id,
                                       p_appl_id,
                                       p_resp_id,
                                       p_access_given_date,
                                       p_access_given_by);
END PROCESS_MENU_TREE_DOWN;





-- ===============================================================
-- Private Function name
--          TEST_ID_NO_GRANTS
--
-- Purpose
--          Test if function id is accessible under current responsibility.
--          Looks only at the menus on current resp, not any grants.
--
-- Params
--          function_id              := function id to test
--          p_appl_id                := application id of resp  (added for AMW)
--          p_resp_id                := responsibility id   (added for AMW)
--          p_access_given_date      := start_date of user resp  (added for AMW)
--          p_access_given_by        := created_by of user resp  (added for AMW)
--          MAINTENANCE_MODE_SUPPORT := the value from the column in g_amw_form_functions
--          CONTEXT_DEPENDENCE       := the value from the column in g_amw_form_functions
--          TEST_MAINT_AVAILABILTY   := 'Y' (default) means check if available for
--                                      current value of profile APPS_MAINTENANCE_MODE
--                                      'N' means the caller is checking so it's
--                                      unnecessary to check.
--
-- Return
--          True    := function accessible
--          False   := function not accessible
--
-- Notes
--          copy from FND_FUNCTION.TEST_ID_NO_GRANTS (AFSCFNSB.pls 115.51 2003/08/01)
--          and modify for AMW to use dynamic sql.
--
--          FND_FUNCTION.TEST_ID_NO_GRANTS calls FND_FUNCTION.IS_FUNCTION_ON_MENU,
--          since FND_FUNCTION.IS_FUNCTION_ON_MENU will use table FND_COMPILED_MENU_FUNCTIONS,
--          we won't have this compiled table for AMW, so we just use the uncompiled one
--          (aka, call PROCESS_MENU_TREE_DOWN no matter what we have exclusions or not).
--
--          use FND_FUNCTION.AVAILABILITY(maintenance_mode_support) directly,
--          since it's public function of FND_FUNCTION package and no need to modify for AMW.
--
-- ===============================================================
FUNCTION TEST_ID_NO_GRANTS (
    function_id in number,
    p_appl_id     in number,
    p_resp_id     in number,
    p_access_given_date in date,
    p_access_given_by   in number,
    MAINTENANCE_MODE_SUPPORT in varchar2,
    CONTEXT_DEPENDENCE in varchar2,
    TEST_MAINT_AVAILABILITY in varchar2
) RETURN boolean
IS

  L_API_NAME                  CONSTANT VARCHAR2(30) := 'TEST_ID_NO_GRANTS';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

  l_function_id  number;
  l_menu_id      number;
  l_resp_id      number;
  l_resp_appl_id number;
  result         boolean;
  L_TEST_MAINT_AVAILABILITY boolean;

BEGIN
  --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

  l_function_id := function_id;
  l_resp_id := p_resp_id; -- 11.13.2003 thso: use passed-in
  l_resp_appl_id := p_appl_id; -- 11.13.2003 thso: use passed-in

  if (   (TEST_MAINT_AVAILABILITY = 'Y')
      OR (TEST_MAINT_AVAILABILITY is NULL)) then
    L_TEST_MAINT_AVAILABILITY := TRUE;
  else
    L_TEST_MAINT_AVAILABILITY := FALSE;
  end if;

  begin
    /* If we got here then there are exclusions, so don't use compiled */
    result := process_menu_tree_down(l_resp_appl_id,
                                     l_resp_id,
                                     l_function_id,
                                     p_access_given_date,
                                     p_access_given_by);
    if(result = FALSE) then
       return FALSE;
    else
       if(L_TEST_MAINT_AVAILABILITY) then
         if(FND_FUNCTION.AVAILABILITY(MAINTENANCE_MODE_SUPPORT) = 'Y') then
           return TRUE;
         else
           return FALSE;
         end if;
       else
         return TRUE;
       end if;
    end if;

  exception
    when no_data_found then
      null;
  end;

END TEST_ID_NO_GRANTS;




-- ===============================================================
-- Private Function name
--          TEST_INSTANCE_ID_MAINTMODE
--
-- Purpose
--          Test if function id is accessible under current responsibility.
--          Looks only at the menus on current resp, not any grants.
--
-- Params
--          function_id              := function id to test
--          p_appl_id                := application id of resp  (added for AMW)
--          p_resp_id                := responsibility id   (added for AMW)
--          p_access_given_date      := start_date of user resp  (added for AMW)
--          p_access_given_by        := created_by of user resp  (added for AMW)
--          object_name              := NULL
--          instance_pk1_value       := NULL
--          instance_pk2_value       := NULL
--          instance_pk3_value       := NULL
--          instance_pk4_value       := NULL
--          instance_pk5_value       := NULL
--          user_name                := NULL
--          MAINTENANCE_MODE_SUPPORT := the value from the column in g_amw_form_functions
--          CONTEXT_DEPENDENCE       := the value from the column in g_amw_form_functions
--          TEST_MAINT_AVAILABILTY   := 'Y' (default) means check if available for
--                                      current value of profile APPS_MAINTENANCE_MODE
--                                      'N' means the caller is checking so it's
--                                      unnecessary to check.
--
-- Return
--          True    := function accessible
--          False   := function not accessible
--
-- Notes
--          copy from FND_FUNCTION.TEST_INSTANCE_ID_MAINTMODE (AFSCFNSB.pls 115.51 2003/08/01)
--          and modify for AMW to use dynamic sql.
--
--          since AMW constraint doesn't support data security (row base),
--          but supports static function security (function base).
--          Unlike in FND_FUNCTION.TEST_INSTANCE_ID_MAINTMODE,
--          here the passed-in object_name should always be NULL
--          and we won't check data security
--
--          use FND_FUNCTION.AVAILABILITY(maintenance_mode_support) directly,
--          since it's public function of FND_FUNCTION package and no need to modify for AMW.
--
-- ===============================================================
FUNCTION TEST_INSTANCE_ID_MAINTMODE (
    function_id IN NUMBER,
    p_appl_id   IN NUMBER,
    p_resp_id   IN NUMBER,
    p_access_given_date  IN  DATE,
    p_access_given_by    IN  NUMBER,
    object_name          IN  VARCHAR2,
    instance_pk1_value   IN  VARCHAR2,
    instance_pk2_value   IN  VARCHAR2,
    instance_pk3_value   IN  VARCHAR2,
    instance_pk4_value   IN  VARCHAR2,
    instance_pk5_value   IN  VARCHAR2,
    user_name            IN  VARCHAR2,
    MAINTENANCE_MODE_SUPPORT in varchar2,
    CONTEXT_DEPENDENCE in varchar2,
    TEST_MAINT_AVAILABILITY in varchar2
) RETURN boolean
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'TEST_INSTANCE_ID_MAINTMODE';
   L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

   ret_val varchar2(1) := 'F';
   ret_bool boolean := FALSE;
   L_MAINTENANCE_MODE_SUPPORT varchar2(8) := MAINTENANCE_MODE_SUPPORT;
   L_CONTEXT_DEPENDENCE       varchar2(8) := CONTEXT_DEPENDENCE;

BEGIN
   --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

   if (TEST_ID_NO_GRANTS(function_id,
                         p_appl_id,
                         p_resp_id,
                         p_access_given_date,
                         p_access_given_by,
                         L_MAINTENANCE_MODE_SUPPORT,
                         L_CONTEXT_DEPENDENCE,
                         'N')) then
     ret_bool := TRUE;
     goto check_avail;
   end if;

   if (object_name is not NULL) then
     -- 11.13.2003 tsho: ignore object_name, since AMW constraint doesn't support data security
     null;
   end if;

<<check_avail>>
   if (ret_bool = TRUE) then
     if(FND_FUNCTION.AVAILABILITY(L_MAINTENANCE_MODE_SUPPORT) = 'Y') then
       ret_bool := TRUE;
     else
       ret_bool := FALSE;
     end if;
   end if;

<<all_done>>

   if (ret_bool) then
       return TRUE;
   else
       return FALSE;
   end if;

END TEST_INSTANCE_ID_MAINTMODE;





-- ===============================================================
-- Private Function name
--          TEST_ID
--
-- Purpose
--          Test if function id is accessible under current responsibility.
--
-- Params
--          function_id              := function id to test
--          p_appl_id                := application id of resp  (added for AMW)
--          p_resp_id                := responsibility id   (added for AMW)
--          p_access_given_date      := start_date of user resp  (added for AMW)
--          p_access_given_by        := created_by of user resp  (added for AMW)
--
-- Return
--          True    := function accessible
--          False   := function not accessible
--
-- Notes
--          copy from FND_FUNCTION.TEST_ID (AFSCFNSB.pls 115.51 2003/08/01)
--
-- ===============================================================
function TEST_ID(
    function_id IN NUMBER,
    p_appl_id   IN NUMBER,
    p_resp_id   IN NUMBER,
    p_access_given_date IN DATE,
    p_access_given_by   IN NUMBER
) RETURN boolean
IS

  L_API_NAME                  CONSTANT VARCHAR2(30) := 'TEST_ID';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

  L_MAINTENANCE_MODE_SUPPORT varchar2(8);
  L_CONTEXT_DEPENDENCE varchar2(8);
  TEST_MAINT_AVAILABILITY varchar2(1) := 'Y';
  L_FUNCTION_ID NUMBER;

  -- 11.13.2003 tsho: use dynamic sql for AMW
  -- 12.12.2003 tsho: use static sql for AMW for the time being
  -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
  TYPE funcCurTyp IS REF CURSOR;
  func_c funcCurTyp;
  l_func_dynamic_sql   VARCHAR2(200)  :=
        'SELECT MAINTENANCE_MODE_SUPPORT, CONTEXT_DEPENDENCE '
      ||'  FROM '||G_AMW_FORM_FUNCTIONS_VL
      ||' WHERE FUNCTION_ID = :1 ';

BEGIN
  --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);
  L_MAINTENANCE_MODE_SUPPORT := NULL;
  L_CONTEXT_DEPENDENCE := NULL;
  L_FUNCTION_ID := function_id;


  begin
    -- 12.12.2003 tsho: use static sql for AMW for the time being
    -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
    OPEN func_c FOR l_func_dynamic_sql USING
      function_id;
    FETCH func_c INTO L_MAINTENANCE_MODE_SUPPORT,
                      L_CONTEXT_DEPENDENCE;
    CLOSE func_c;
    /*
    SELECT MAINTENANCE_MODE_SUPPORT, CONTEXT_DEPENDENCE
      INTO L_MAINTENANCE_MODE_SUPPORT, L_CONTEXT_DEPENDENCE
      FROM FND_FORM_FUNCTIONS
     WHERE FUNCTION_ID = l_function_id;
    */

  exception
    when no_data_found then
      return FALSE; /* Bad function id passed */
    when others then
      --FND_FILE.put_line(fnd_file.log,'other exception '||SQLERRM);
      raise;
  end;

  return TEST_INSTANCE_ID_MAINTMODE(
                         function_id => function_id,
                         p_appl_id   => p_appl_id,
                         p_resp_id   => p_resp_id,
                         p_access_given_date => p_access_given_date,
                         p_access_given_by   => p_access_given_by,
                         object_name => NULL,
                         instance_pk1_value => NULL,
                         instance_pk2_value => NULL,
                         instance_pk3_value => NULL,
                         instance_pk4_value => NULL,
                         instance_pk5_value => NULL,
                         user_name => NULL,
                         MAINTENANCE_MODE_SUPPORT => L_MAINTENANCE_MODE_SUPPORT,
                         CONTEXT_DEPENDENCE => L_CONTEXT_DEPENDENCE,
                         TEST_MAINT_AVAILABILITY => TEST_MAINT_AVAILABILITY);

END TEST_ID;



-- ===============================================================
-- Function name
--          Get_Party_Id
--
-- Purpose
--          get the party_id by specified user_id
--
-- Params
--          p_user_id   := specified user_id
--
-- ===============================================================
Function Get_Party_Id (
    p_user_id   IN  NUMBER
)
Return  NUMBER
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Party_Id';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

l_party_id NUMBER;

-- find all employees having corresponding user_id in g_amw_user
-- 12.12.2003 tsho: use static sql for AMW for the time being
-- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
TYPE userCurTyp IS REF CURSOR;
c_user_dynamic_sql userCurTyp;
l_user_dynamic_sql   VARCHAR2(200)  :=
        'SELECT person_party_id '
      ||'  FROM '||G_AMW_USER ||' u '
      ||' WHERE u.user_id = :1 ';

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);
    -- 12.12.2003 tsho: use static sql for AMW for the time being
    -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
    OPEN c_user_dynamic_sql FOR l_user_dynamic_sql USING
        p_user_id;
    FETCH c_user_dynamic_sql INTO l_party_id;
    CLOSE c_user_dynamic_sql;
    /*
    SELECT person_party_id
      INTO l_party_id
      FROM FND_USER u
     WHERE u.user_id = p_user_id;
    */

    RETURN l_party_id;

END Get_Party_Id;


-- ===============================================================
-- Procedure name
--          Populate_User_Id_List
--
-- Purpose
--          populate the global user id list
--
-- Notes
--          01.10.2005 tsho: Deprecated, use Populate_User_Id_List_For_Cst instead
-- ===============================================================
Procedure Populate_User_Id_List
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Populate_User_Id_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

i NUMBER;
l_user_id NUMBER;

-- find all employees having corresponding user_id in g_amw_user
-- 12.12.2003 tsho: use static sql for AMW for the time being
-- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
TYPE userCurTyp IS REF CURSOR;
c_user_dynamic_sql userCurTyp;
l_user_dynamic_sql   VARCHAR2(200)  :=
        'SELECT user_id '
      ||'  FROM amw_employees_current_v emp, '
      ||        G_AMW_USER ||' u '
      ||' WHERE emp.party_id = u.person_party_id  ';
/*
cursor get_user_c is
    SELECT user_id
      FROM amw_employees_current_v emp,
           fnd_user u
     WHERE emp.party_id = u.person_party_id;
*/

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    -- find all employees having corresponding user_id in g_amw_user
    IF (BULK_COLLECTS_SUPPORTED) THEN
        -- 12.12.2003 tsho: use static sql for AMW for the time being
        -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
        OPEN c_user_dynamic_sql FOR l_user_dynamic_sql;
        FETCH c_user_dynamic_sql BULK COLLECT INTO G_USER_ID_LIST;
        CLOSE c_user_dynamic_sql;
        /*
        OPEN get_user_c;
        FETCH get_user_c BULK COLLECT INTO G_USER_ID_LIST;
        CLOSE get_user_c;
        */

    ELSE
        -- no BULK_COLLECTS_SUPPORTED
        i := 0;
        -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
        OPEN c_user_dynamic_sql FOR l_user_dynamic_sql;
        LOOP
            FETCH c_user_dynamic_sql INTO l_user_id;
            EXIT WHEN c_user_dynamic_sql%NOTFOUND;
            i := i+1;
            G_USER_ID_LIST(i) := l_user_id;
        END LOOP;
        CLOSE c_user_dynamic_sql;
        /*
        FOR rec in get_user_c LOOP
          i := i + 1;
          G_USER_ID_LIST(i) := rec.user_id;
        END LOOP;
        */

    END IF; -- end of if: BULK_COLLECTS_SUPPORTED

END Populate_User_Id_List;

-- ===============================================================
-- Procedure name
--          Populate_User_Vio_For_Cst
-- Purpose
--          populate the global user id with the incompatible functions
--          accessible by him for one constraint
-- Params
--          p_constraint_rev_id   := specified constraint_rev_id
--          p_type_code           := specified constraint type code (default is NULL)
-- History
--          06.30.2006 psomanat: created the procedure
-- ===============================================================
Procedure Populate_User_Vio_For_Cst(
    p_constraint_rev_id      IN  NUMBER,
    p_type_code              IN  VARCHAR2   := NULL
)
IS

    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Populate_User_Vio_For_Cst';
    L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.1;

    -- 01.06.2005 tsho: store the constraint type for this constraint
    l_type_code     VARCHAR2(30)    := p_type_code;
    -- 01.06.2005 tsho: find the constraint by specified constraint_rev_id
    CURSOR c_constraint (l_constraint_rev_id IN NUMBER) IS
      SELECT type_code
        FROM amw_constraints_b
	   WHERE constraint_rev_id=l_constraint_rev_id;

    TYPE userVioCurTyp IS REF CURSOR;
    c_user_vio_dynamic_sql userVioCurTyp;

    -- Identify the roles, user/global grants accessible to a user
    -- which makes him a violating user
    l_user_role_dynamic_sql   VARCHAR2(4000)  :=
      ' SELECT gra.grantee_key role_name, '
    ||'        gra.menu_id, '
    ||'        ce.function_id, '
    ||'        min(urasgn.start_date), '
    ||'        ( SELECT asgn.created_by '
    ||'          FROM '||G_AMW_USER_ROLE_ASSIGNMENTS||'  asgn '
    ||'          WHERE asgn.user_name = usr.user_name '
    ||'          AND asgn.role_name = role_name '
    ||'          AND asgn.start_date = start_date '
    ||'          AND rownum=1 '
    ||'        ) created_by, '
    ||'        ''FUNC'' entry_object_type, '
    ||'        usr.user_id, '
    ||'        ce.group_code '
    ||' FROM '||G_AMW_GRANTS||' gra, '
    ||'      '||G_AMW_COMPILED_MENU_FUNCTIONS||'  cmf, '
    ||'      AMW_CONSTRAINT_ENTRIES ce, '
    ||'      '||G_AMW_USER_ROLE_ASSIGNMENTS||'  urasgn, '
    ||'      '||G_AMW_USER||' usr '
    ||' WHERE urasgn.user_name = usr.user_name '
    ||' AND (gra.grantee_orig_system = ''UMX'' OR gra.grantee_orig_system = ''FND_RESP'') '
    ||' AND urasgn.role_name = gra.GRANTEE_KEY '
    ||' AND gra.menu_id = cmf.menu_id '
    ||' AND cmf.function_id = ce.function_id '
    ||' AND (ce.object_type is null OR ce.object_type = ''FUNC'') '
    ||' AND ce.CONSTRAINT_REV_ID = :1 '
    ||' AND gra.INSTANCE_TYPE = ''GLOBAL'' '
    ||' AND gra.OBJECT_ID = -1 '
    ||' AND gra.GRANTEE_TYPE = ''GROUP'' '
    ||' AND gra.start_date <= sysdate '
    ||' AND (gra.end_date >= sysdate or gra.end_date is null) '
    ||' AND urasgn.start_date <= sysdate '
    ||' AND (urasgn.end_date >= sysdate or urasgn.end_date is null) '
    ||' AND usr.start_date <= sysdate '
    ||' AND (usr.end_date >= sysdate or usr.end_date is null) '
    ||' GROUP BY gra.grantee_key, gra.menu_id,ce.function_id,usr.user_name,usr.user_id,ce.group_code'
    ||' UNION ALL '
    ||' SELECT to_char(null) role_name, '
    ||'        gra.menu_id, '
    ||'        ce.function_id, '
    ||'        gra.start_date, '
    ||'        gra.created_by, '
    ||'        ''FUNC'' entry_object_type, '
    ||'        usr.user_id, '
    ||'        ce.group_code '
    ||' FROM '||G_AMW_GRANTS||' gra, '
    ||'      '||G_AMW_COMPILED_MENU_FUNCTIONS||' cmf, '
    ||'      AMW_CONSTRAINT_ENTRIES ce, '
    ||'      '||G_AMW_USER||' usr '
    ||' WHERE (( gra.GRANTEE_KEY = usr.user_name AND gra.GRANTEE_TYPE = ''USER'') '
    ||'          OR (gra.GRANTEE_KEY = ''GLOBAL'' AND gra.GRANTEE_TYPE = ''GLOBAL'')) '
    ||' AND gra.menu_id = cmf.menu_id '
    ||' AND cmf.function_id = ce.function_id '
    ||' AND (ce.object_type is null OR ce.object_type = ''FUNC'') '
    ||' AND ce.CONSTRAINT_REV_ID = :2 '
    ||' AND gra.INSTANCE_TYPE = ''GLOBAL'' '
    ||' AND gra.OBJECT_ID  = -1 '
    ||' AND gra.start_date <= sysdate '
    ||' AND (gra.end_date  >= sysdate or gra.end_date is null) '
    ||' AND usr.start_date <= sysdate '
    ||' AND (usr.end_date  >= sysdate or usr.end_date is null) ';

    -- Identify the responsibilities accessible to a user
    -- which makes him a violating user
    l_user_func_cst_dynamic_sql   VARCHAR2(9000)  :=
      ' SELECT  usr.user_id, '
    ||'         appl.application_id, '
    ||'         ur.role_orig_system_id, '
    ||'         min(urasgn.start_date) start_date, '
    ||'        ( select asgn.created_by '
    ||'          from  '||G_AMW_USER_ROLE_ASSIGNMENTS||'  asgn '
    ||'          where asgn.user_name = ur.user_name '
    ||'          and asgn.role_name = ur.role_name '
    ||'          and asgn.start_date = start_date '
    ||'          and rownum=1 '
    ||'        ) created_by, '
    ||'        DECODE((select count(*) '
    ||'                from amw_constraint_waivers_b '
    ||'                where constraint_rev_id= :1 '
    ||'                and object_type=''RESP'' '
    ||'                and pk1 = ur.role_orig_system_id '
    ||'                and pk2 = appl.application_id '
    ||'                and start_date <= sysdate '
    ||'                AND (end_date  >= sysdate or end_date is null)),0,''N'',''Y'') waived_flag '
    ||' FROM WF_USER_ROLES  ur, '
    ||'      '||G_AMW_USER_ROLE_ASSIGNMENTS||'  urasgn, '
    ||'      '||G_AMW_USER||' usr, '
    ||'      WF_LOCAL_ROLES rol, '
    ||'      FND_APPLICATION_VL appl, '
    ||'      '||G_AMW_RESPONSIBILITY||' resp, '
    ||'      '||G_AMW_COMPILED_MENU_FUNCTIONS||' cmf, '
    ||'      AMW_CONSTRAINT_ENTRIES ce '
    ||' WHERE ce.CONSTRAINT_REV_ID =  :2 '
    ||' AND (ce.object_type is null OR ce.object_type = ''FUNC'') '
    ||' AND cmf.menu_id = resp.menu_id '
    ||' AND cmf.grant_flag = ''Y'' '
    ||' AND cmf.function_id = ce.function_id '
    ||' AND resp.start_date <= sysdate '
    ||' AND (resp.end_date >= sysdate or resp.end_date is null) '
    ||' AND ur.role_orig_system_id = resp.responsibility_id '
    ||' AND ur.role_orig_system = ''FND_RESP'' '
    ||' AND ur.role_name = rol.name '
    ||' AND ur.role_orig_system = rol.orig_system '
    ||' AND ur.role_orig_system_id = rol.orig_system_id '
    ||' AND ur.partition_id = rol.partition_id '
    ||' AND rol.start_date<= sysdate '
    ||' AND (rol.expiration_date IS NULL OR rol.expiration_date>=sysdate) '
    ||' AND rol.owner_tag=appl.application_short_name '
    ||' AND resp.application_id=appl.application_id '
    ||' AND ur.user_name = urasgn.user_name '
    ||' AND ur.role_name = urasgn.role_name '
    ||' AND urasgn.start_date <= sysdate '
    ||' AND (urasgn.end_date >= sysdate or urasgn.end_date is null) '
    ||' AND ur.user_name=usr.user_name '
    ||' AND (ur.user_orig_system = ''FND_USR'' OR ur.user_orig_system = ''PER'') '
    ||' AND usr.start_date <= sysdate '
    ||' AND (usr.end_date >= sysdate or usr.end_date is null) '
    ||' GROUP BY usr.user_id,ur.user_name,appl.application_id,ur.role_orig_system_id, ur.role_name '
    ||' UNION '
    ||' SELECT  usr.user_id, '
    ||'        appl.application_id, '
    ||'        ur.role_orig_system_id, '
    ||'        min(urasgn.start_date) start_date, '
    ||'        ( select asgn.created_by '
    ||'          from  '||G_AMW_USER_ROLE_ASSIGNMENTS||'  asgn '
    ||'          where asgn.user_name = ur.user_name '
    ||'          and asgn.role_name = ur.role_name '
    ||'          and asgn.start_date = start_date '
    ||'          and rownum=1 '
    ||'        ) created_by, '
    ||'        DECODE((select count(*) '
    ||'                from amw_constraint_waivers_b '
    ||'                where constraint_rev_id= :3 '
    ||'                and object_type=''RESP'' '
    ||'                and pk1 = ur.role_orig_system_id '
    ||'                and pk2 = appl.application_id '
    ||'                and start_date <= sysdate '
    ||'                AND (end_date  >= sysdate or end_date is null)),0,''N'',''Y'') waived_flag '
    ||' FROM WF_USER_ROLES  ur, '
    ||'      '||G_AMW_USER_ROLE_ASSIGNMENTS||'  urasgn, '
    ||'      '||G_AMW_USER||' usr, '
    ||'      WF_LOCAL_ROLES rol, '
    ||'      FND_APPLICATION_VL appl, '
    ||'      '||G_AMW_RESPONSIBILITY||' RESP, '
    ||'      '||G_AMW_REQUEST_GROUP_UNITS||' RGU, '
    ||'      AMW_CONSTRAINT_ENTRIES ACE '
    ||' WHERE ACE.CONSTRAINT_REV_ID=:4 '
    ||' AND ACE.OBJECT_TYPE=''CP'' '
    ||' AND RESP.GROUP_APPLICATION_ID IS NOT NULL '
    ||' AND RESP.REQUEST_GROUP_ID IS NOT NULL '
    ||' AND RGU.APPLICATION_ID=RESP.GROUP_APPLICATION_ID '
    ||' AND RGU.REQUEST_GROUP_ID=RESP.REQUEST_GROUP_ID '
    ||' AND RGU.REQUEST_UNIT_TYPE = ''P'' '
    ||' AND RGU.UNIT_APPLICATION_ID=ACE.APPLICATION_ID '
    ||' AND RGU.REQUEST_UNIT_ID=ACE.FUNCTION_ID '
    ||' AND RESP.START_DATE<=SYSDATE '
    ||' AND (RESP.END_DATE>= SYSDATE or RESP.END_DATE IS NULL) '
    ||' AND ur.role_orig_system_id = resp.responsibility_id '
    ||' AND ur.role_orig_system = ''FND_RESP'' '
    ||' AND ur.role_name = rol.name '
    ||' AND ur.role_orig_system = rol.orig_system '
    ||' AND ur.role_orig_system_id = rol.orig_system_id '
    ||' AND ur.partition_id = rol.partition_id '
    ||' AND rol.start_date<= sysdate '
    ||' AND (rol.expiration_date IS NULL OR rol.expiration_date>=sysdate) '
    ||' AND rol.owner_tag = appl.application_short_name '
    ||' AND resp.application_id = appl.application_id '
    ||' AND ur.user_name = urasgn.user_name '
    ||' AND ur.role_name = urasgn.role_name '
    ||' AND urasgn.start_date <= sysdate '
    ||' AND (urasgn.end_date >= sysdate or urasgn.end_date is null) '
    ||' AND ur.user_name=usr.user_name '
    ||' AND (ur.user_orig_system = ''FND_USR'' OR ur.user_orig_system = ''PER'') '
    ||' AND usr.start_date <= sysdate '
    ||' AND (usr.end_date >= sysdate or usr.end_date is null) '
    ||' GROUP BY usr.user_id,ur.user_name,appl.application_id,ur.role_orig_system_id, ur.role_name ';

    -- Identify the responsibilities accessible to a user
    -- which makes him a violating user
    l_user_resp_dynamic_sql VARCHAR2(4000)  :=
      ' SELECT usr.user_id,   '
    ||'        appl.application_id, '
    ||'        ur.role_orig_system_id, '
    ||'        min(urasgn.start_date) start_date, '
    ||'        ( select asgn.created_by '
    ||'          from '||G_AMW_USER_ROLE_ASSIGNMENTS||'  asgn '
    ||'          where asgn.user_name = ur.user_name '
    ||'          and asgn.role_name   = ur.role_name '
    ||'          and asgn.start_date  = start_date '
    ||'          and rownum=1 '
    ||'        ) created_by ,'
    ||'        ce.group_code '
    ||' FROM WF_USER_ROLES  ur, '
    ||'      '||G_AMW_USER_ROLE_ASSIGNMENTS||'  urasgn, '
    ||'      '||G_AMW_USER||' usr, '
    ||'      WF_LOCAL_ROLES rol, '
    ||'      FND_APPLICATION_VL appl, '
    ||'      '||G_AMW_RESPONSIBILITY||' resp, '
    ||'      AMW_CONSTRAINT_ENTRIES ce '
    ||' WHERE ce.CONSTRAINT_REV_ID =  :1 '
    ||' AND ce.object_type     = ''RESP'' '
    ||' AND ce.function_id     = resp.responsibility_id '
    ||' AND ce.application_id  = resp.application_id '
    ||' AND ur.role_orig_system_id = resp.responsibility_id '
    ||'  AND ur.role_orig_system = ''FND_RESP'' '
    ||' AND ur.role_name        = rol.name '
    ||' AND ur.role_orig_system = rol.orig_system '
    ||' AND ur.role_orig_system_id = rol.orig_system_id '
    ||' AND ur.partition_id     = rol.partition_id '
    ||' AND rol.owner_tag       = appl.application_short_name '
    ||' AND resp.application_id = appl.application_id '
    ||' AND ur.user_name        = urasgn.user_name '
    ||' AND ur.role_name        = urasgn.role_name '
    ||' AND ur.user_name        = usr.user_name '
    ||' AND rol.start_date      <= sysdate '
    ||' AND (rol.expiration_date IS NULL OR rol.expiration_date>=sysdate) '
    ||' AND resp.start_date    <= sysdate '
    ||' AND (resp.end_date     >= sysdate OR resp.end_date IS NULL) '
    ||' AND urasgn.start_date  <= sysdate '
    ||' AND (urasgn.end_date   >= sysdate OR urasgn.end_date IS NULL) '
    ||' AND usr.start_date     <= sysdate '
    ||' AND (usr.end_date      >= sysdate OR usr.end_date IS NULL) '
    ||' GROUP BY usr.user_id,ur.user_name,appl.application_id,ur.role_orig_system_id, ur.role_name,ce.group_code  ';

    -- psomanat : 06:09:2006 : fix for bug 5256720
    L_USERVIO_ENTRIES G_USERVIO_ENTRIES_TABLE;
    L_FUNC_ID_LIST    G_FUNCS_TABLE;
    L_RESP_ID_LIST    G_RESPS_TABLE;
    counts            Number;
    listkey           NUMBER(15);
    l_user_access_waived_resp_list G_VARCHAR2_TABLE;

    L_RESPVIO_ENTRIES   G_RESPVIO_ENTRIES_TABLE;
    L_RESP_FUNC_ID_LIST G_FUNC_TABLE;
    rListkey            VARCHAR2(30) := NULL;
    flag                boolean:=true;
BEGIN
    -- FND_FILE.put_line(fnd_file.log,'Populate_User_Vio_For_Cst Began '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));

    IF (p_type_code IS NULL) THEN
        OPEN c_constraint(p_constraint_rev_id);
        FETCH c_constraint INTO l_type_code;
        CLOSE c_constraint;
    END IF; -- end of if: _type_code IS NULL

    G_USER_VIOLATIONS_LIST.delete();
    G_USER_RESP_VIO_LIST.delete();

    IF (substr(l_type_code,1,4) = 'RESP') THEN

        -- Clearing the list
        G_CST_USER_ID_LIST.DELETE();
        G_UPV_APPLICATION_ID_LIST.DELETE();
        G_UPV_RESPONSIBILITY_ID_LIST.DELETE();
        G_UPV_ACCESS_GIVEN_DATE_LIST.DELETE();
        G_UPV_ACCESS_GIVEN_BY_LIST.DELETE();
        G_UPV_GROUP_CODE_LIST.DELETE();

        -- For responsibility violation, we identify the responsibilities
        -- accessible to the user in the G_UPV_XXXXXX_LIST
        OPEN c_user_vio_dynamic_sql FOR l_user_resp_dynamic_sql USING
            p_constraint_rev_id;
        FETCH c_user_vio_dynamic_sql
        BULK COLLECT INTO G_CST_USER_ID_LIST,
                          G_UPV_APPLICATION_ID_LIST,
                          G_UPV_RESPONSIBILITY_ID_LIST,
                          G_UPV_ACCESS_GIVEN_DATE_LIST,
                          G_UPV_ACCESS_GIVEN_BY_LIST,
                          G_UPV_GROUP_CODE_LIST;
        CLOSE c_user_vio_dynamic_sql;

        -- A user can have n number of responsibilities associated to him
        -- We need to iterate over the G_UPV_XXXXXX_LIST to get the responsibilities
        -- assigned to the user.
        -- This will cause a performace issue
        -- So we store the G_UPV_XXXXXX_LIST nested tables data into a plsql data
        -- structure. The structure is like this
        --   User_id
        --        |______Responsibility_id
        --        |______Responsibility_id
        --        |______Responsibility_id
        --

        IF (G_CST_USER_ID_LIST IS NOT NULL) AND (G_CST_USER_ID_LIST.FIRST IS NOT NULL) THEN
            FOR i in 1 .. G_CST_USER_ID_LIST.COUNT
            LOOP
                flag:=TRUE;
                listkey :=G_CST_USER_ID_LIST(i);
                rListkey :=G_UPV_APPLICATION_ID_LIST(i)||'@'||G_UPV_RESPONSIBILITY_ID_LIST(i);

                L_RESP_ID_LIST.delete();
                L_USERVIO_ENTRIES.delete();

                IF (G_USER_RESP_VIO_LIST.EXISTS(listkey)) THEN
                    L_RESP_ID_LIST := G_USER_RESP_VIO_LIST(listkey);
                    IF L_RESP_ID_LIST.EXISTS(rListkey) THEN
                        L_USERVIO_ENTRIES := L_RESP_ID_LIST(rListkey);
                        FOR l IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
                        LOOP
                            IF ( L_USERVIO_ENTRIES(l).application_id    = G_UPV_APPLICATION_ID_LIST(i) AND
                                 L_USERVIO_ENTRIES(l).Responsibility_id = G_UPV_RESPONSIBILITY_ID_LIST(i)) THEN
                                    flag:=FALSE;
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
                IF (flag) THEN
                counts := L_USERVIO_ENTRIES.COUNT+1;
                L_USERVIO_ENTRIES(counts).User_id            := G_CST_USER_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).Access_Given_Date  := G_UPV_ACCESS_GIVEN_DATE_LIST(i);
                L_USERVIO_ENTRIES(counts).Access_Given_By_Id := G_UPV_ACCESS_GIVEN_BY_LIST(i);
                L_USERVIO_ENTRIES(counts).application_id     := G_UPV_APPLICATION_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).Responsibility_id  := G_UPV_RESPONSIBILITY_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).group_code         := G_UPV_GROUP_CODE_LIST(i);
                L_USERVIO_ENTRIES(counts).Waived             := NUll;
                L_USERVIO_ENTRIES(counts).Role_Name          := NUll;
                L_USERVIO_ENTRIES(counts).Menu_id            := NUll;
                L_USERVIO_ENTRIES(counts).Function_Id        := NUll;
                L_USERVIO_ENTRIES(counts).Object_Type        := NUll;
                L_USERVIO_ENTRIES(counts).prog_appl_id       := NUll;
                L_RESP_ID_LIST(rListkey)                     := L_USERVIO_ENTRIES;
                G_USER_RESP_VIO_LIST(listkey)                := L_RESP_ID_LIST;
                END IF;
            END LOOP;
        END IF;

        -- Clearing the list
        G_CST_USER_ID_LIST.DELETE();
        G_UPV_APPLICATION_ID_LIST.DELETE();
        G_UPV_RESPONSIBILITY_ID_LIST.DELETE();
        G_UPV_ACCESS_GIVEN_DATE_LIST.DELETE();
        G_UPV_ACCESS_GIVEN_BY_LIST.DELETE();
        G_UPV_GROUP_CODE_LIST.DELETE();
    ELSE
        -- clear the list
        G_UPV_ROLE_NAME_LIST.delete();
        G_UPV_MENU_ID_LIST.delete();
        G_UPV_FUNCTION_ID_LIST.delete();
        G_UPV_ACCESS_GIVEN_DATE_LIST.delete();
        G_UPV_ACCESS_GIVEN_BY_LIST.delete();
        G_UPV_ENTRY_OBJECT_TYPE_LIST.delete();
        G_CST_USER_ID_LIST.delete();
        G_UPV_GROUP_CODE_LIST.delete();

        -- A user can have n number of responsibilities associated to him
        -- We need to iterate over the G_UPV_XXXXXX_LIST to get the responsibilities
        -- assigned to the user. Then from the responsibility we need to
        -- get the incompatible functions accessible to the user.
        -- This will cause a performace issue
        -- So we store the G_UPV_XXXXXX_LIST nested tables and G_RESP_VIOLATIONS_LIST
        -- data into a plsql data  structure.
        -- The structure is like this
        --   User_id
        --        |______Function_Id
        --                      |______Function Detils group1
        --                      |______Function Detils group2
        --        |______Function_Id
        --                      |______Function Detils group1
        --                      |______Function Detils group2
        --        |______Function_Id
        --                      |______Function Detils group1
        --                      |______Function Detils group2
        --  A function can be avilable in group 1 and group 2
        --  so we store both groups under function_id

        -- First we get the user - roles,user - grants, global grants  and
        -- populate the plsql data structure
        OPEN c_user_vio_dynamic_sql FOR l_user_role_dynamic_sql USING
                p_constraint_rev_id,
                p_constraint_rev_id;
        FETCH c_user_vio_dynamic_sql
        BULK COLLECT INTO G_UPV_ROLE_NAME_LIST,
                          G_UPV_MENU_ID_LIST,
                          G_UPV_FUNCTION_ID_LIST,
                          G_UPV_ACCESS_GIVEN_DATE_LIST,
                          G_UPV_ACCESS_GIVEN_BY_LIST,
                          G_UPV_ENTRY_OBJECT_TYPE_LIST,
                          G_CST_USER_ID_LIST,
                          G_UPV_GROUP_CODE_LIST;
        CLOSE c_user_vio_dynamic_sql;

        IF (G_CST_USER_ID_LIST IS NOT NULL) AND (G_CST_USER_ID_LIST.FIRST IS NOT NULL) THEN
            FOR i in 1 .. G_CST_USER_ID_LIST.COUNT
            LOOP
                flag:=TRUE;
                L_FUNC_ID_LIST.delete();
                L_USERVIO_ENTRIES.delete();

                listkey :=G_CST_USER_ID_LIST(i);
                IF (G_USER_VIOLATIONS_LIST.EXISTS(listkey)) THEN
                    L_FUNC_ID_LIST := G_USER_VIOLATIONS_LIST(listkey);
                    IF L_FUNC_ID_LIST.EXISTS(G_UPV_FUNCTION_ID_LIST(i)) THEN
                        L_USERVIO_ENTRIES := L_FUNC_ID_LIST(G_UPV_FUNCTION_ID_LIST(i));
                       FOR l IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
                       LOOP
                            IF ( L_USERVIO_ENTRIES(l).Role_Name   = G_UPV_ROLE_NAME_LIST(i) AND
                                 L_USERVIO_ENTRIES(l).Menu_id     = G_UPV_MENU_ID_LIST(i) AND
                                 L_USERVIO_ENTRIES(l).Function_Id = G_UPV_FUNCTION_ID_LIST(i)) THEN
                                    flag:=FALSE;
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
                IF (flag) THEN
                counts := L_USERVIO_ENTRIES.COUNT+1;
                L_USERVIO_ENTRIES(counts).User_id            := G_CST_USER_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).Role_Name          := G_UPV_ROLE_NAME_LIST(i);
                L_USERVIO_ENTRIES(counts).Menu_id            := G_UPV_MENU_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).Function_Id        := G_UPV_FUNCTION_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).Access_Given_Date  := G_UPV_ACCESS_GIVEN_DATE_LIST(i);
                L_USERVIO_ENTRIES(counts).Access_Given_By_Id := G_UPV_ACCESS_GIVEN_BY_LIST(i);
                L_USERVIO_ENTRIES(counts).Object_Type        := 'FUNC';
                L_USERVIO_ENTRIES(counts).Waived             := 'N';
                L_USERVIO_ENTRIES(counts).group_code         := G_UPV_GROUP_CODE_LIST(i);
                L_USERVIO_ENTRIES(counts).prog_appl_id       := NULL;
                L_USERVIO_ENTRIES(counts).application_id     := NULL;
                L_USERVIO_ENTRIES(counts).Responsibility_id  := NULL;
                L_FUNC_ID_LIST(G_UPV_FUNCTION_ID_LIST(i))    := L_USERVIO_ENTRIES;
                G_USER_VIOLATIONS_LIST(listkey)              := L_FUNC_ID_LIST;
                END IF;
            END lOOP;
        END IF;

        -- clear the list
        G_UPV_ROLE_NAME_LIST.delete();
        G_UPV_MENU_ID_LIST.delete();
        G_UPV_FUNCTION_ID_LIST.delete();
        G_UPV_ENTRY_OBJECT_TYPE_LIST.delete();
        G_UPV_GROUP_CODE_LIST.delete();
        G_CST_USER_ID_LIST.delete();
        G_UPV_APPLICATION_ID_LIST.delete();
        G_UPV_RESPONSIBILITY_ID_LIST.delete();
        G_UPV_ACCESS_GIVEN_DATE_LIST.delete();
        G_UPV_ACCESS_GIVEN_BY_LIST.delete();
        l_user_access_waived_resp_list.delete();

        --Second User - responsbilities and populate the plsql data structure
        OPEN c_user_vio_dynamic_sql FOR l_user_func_cst_dynamic_sql USING
            p_constraint_rev_id,
            p_constraint_rev_id,
            p_constraint_rev_id,
            p_constraint_rev_id;
        FETCH c_user_vio_dynamic_sql
        BULK COLLECT INTO G_CST_USER_ID_LIST,
                      G_UPV_APPLICATION_ID_LIST,
                      G_UPV_RESPONSIBILITY_ID_LIST,
                      G_UPV_ACCESS_GIVEN_DATE_LIST,
                      G_UPV_ACCESS_GIVEN_BY_LIST,
                      l_user_access_waived_resp_list;
        CLOSE c_user_vio_dynamic_sql;

        IF (G_CST_USER_ID_LIST IS NOT NULL) AND (G_CST_USER_ID_LIST.FIRST IS NOT NULL) THEN
            FOR i in 1 .. G_CST_USER_ID_LIST.COUNT
            LOOP
                listkey :=G_CST_USER_ID_LIST(i);
                rListkey :=G_UPV_APPLICATION_ID_LIST(i)||'@'||G_UPV_RESPONSIBILITY_ID_LIST(i);

                IF (G_RESP_VIOLATIONS_LIST.EXISTS(rListkey)) THEN
                    L_RESP_FUNC_ID_LIST.delete();
                    L_RESP_FUNC_ID_LIST := G_RESP_VIOLATIONS_LIST(rListkey);
                    FOR j IN L_RESP_FUNC_ID_LIST.FIRST .. L_RESP_FUNC_ID_LIST.LAST
                    LOOP
                        IF L_RESP_FUNC_ID_LIST.EXISTS(j) THEN
                            L_RESPVIO_ENTRIES.delete();
                            L_RESPVIO_ENTRIES:=L_RESP_FUNC_ID_LIST(j);
                            FOR k IN L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                            LOOP
                                flag:=TRUE;
                                L_FUNC_ID_LIST.delete();
                                L_USERVIO_ENTRIES.delete();
                                IF (G_USER_VIOLATIONS_LIST.EXISTS(listkey)) THEN
                                    L_FUNC_ID_LIST := G_USER_VIOLATIONS_LIST(listkey);
                                    IF L_FUNC_ID_LIST.EXISTS(L_RESPVIO_ENTRIES(k).Function_Id) THEN
                                        L_USERVIO_ENTRIES := L_FUNC_ID_LIST(L_RESPVIO_ENTRIES(k).Function_Id);
                                        FOR l IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
                                        LOOP
                                            IF (L_USERVIO_ENTRIES(l).Object_Type = 'FUNC' AND
                                               L_RESPVIO_ENTRIES(k).Object_Type = 'FUNC' AND
                                               L_USERVIO_ENTRIES(l).application_id = L_RESPVIO_ENTRIES(k).application_id AND
                                               L_USERVIO_ENTRIES(l).Responsibility_id = L_RESPVIO_ENTRIES(k).Responsibility_id AND
                                               L_USERVIO_ENTRIES(l).Menu_id = L_RESPVIO_ENTRIES(k).Menu_id ) THEN
                                                flag:=FALSE;
                                            END IF;

                                            IF (L_USERVIO_ENTRIES(l).Object_Type = 'CP' AND
                                               L_RESPVIO_ENTRIES(k).Object_Type = 'CP' AND
                                               L_USERVIO_ENTRIES(l).application_id = L_RESPVIO_ENTRIES(k).application_id AND
                                               L_USERVIO_ENTRIES(l).Responsibility_id = L_RESPVIO_ENTRIES(k).Responsibility_id AND
                                               L_USERVIO_ENTRIES(l).Menu_id = L_RESPVIO_ENTRIES(k).Menu_id AND
                                               L_USERVIO_ENTRIES(l).prog_appl_id = L_RESPVIO_ENTRIES(k).prog_appl_id ) THEN
                                                flag:=FALSE;
                                            END IF;
                                        END LOOP;
                                    END IF;
                                END IF;
                                IF (flag)THEN
                                counts := L_USERVIO_ENTRIES.COUNT+1;
                                L_USERVIO_ENTRIES(counts).User_id               := G_CST_USER_ID_LIST(i);
                                L_USERVIO_ENTRIES(counts).Role_Name             := NUll;
                                L_USERVIO_ENTRIES(counts).Menu_id               := L_RESPVIO_ENTRIES(k).Menu_id;
                                L_USERVIO_ENTRIES(counts).Function_Id           := L_RESPVIO_ENTRIES(k).Function_Id;
                                L_USERVIO_ENTRIES(counts).Access_Given_Date     := G_UPV_ACCESS_GIVEN_DATE_LIST(i);
                                L_USERVIO_ENTRIES(counts).Access_Given_By_Id    := G_UPV_ACCESS_GIVEN_BY_LIST(i);
                                L_USERVIO_ENTRIES(counts).Object_Type           := L_RESPVIO_ENTRIES(k).Object_Type;
                                L_USERVIO_ENTRIES(counts).prog_appl_id          := L_RESPVIO_ENTRIES(k).prog_appl_id;
                                L_USERVIO_ENTRIES(counts).application_id        := L_RESPVIO_ENTRIES(k).application_id;
                                L_USERVIO_ENTRIES(counts).Responsibility_id     := L_RESPVIO_ENTRIES(k).Responsibility_id;
                                L_USERVIO_ENTRIES(counts).group_code            := L_RESPVIO_ENTRIES(k).group_code;
                                L_USERVIO_ENTRIES(counts).Waived                := l_user_access_waived_resp_list(i);
                                L_FUNC_ID_LIST(L_RESPVIO_ENTRIES(k).Function_Id):= L_USERVIO_ENTRIES;
                                G_USER_VIOLATIONS_LIST(listkey)                 := L_FUNC_ID_LIST;
                                END IF;
                            END LOOP;
                        END IF;
                    END LOOP;
                END IF;
            END lOOP;
        END IF;

        -- Clear the list
        G_CST_USER_ID_LIST.delete();
        G_UPV_APPLICATION_ID_LIST.delete();
        G_UPV_RESPONSIBILITY_ID_LIST.delete();
        G_UPV_ACCESS_GIVEN_DATE_LIST.delete();
        G_UPV_ACCESS_GIVEN_BY_LIST.delete();
        l_user_access_waived_resp_list.delete();
    END IF;
    -- FND_FILE.put_line(fnd_file.log,'Populate_User_Vio_For_Cst END '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));
END;

-- ===============================================================
-- Procedure name
--          Populate_User_Id_List_For_Cst
-- Purpose
--          populate the global user id list for one constraint (G_CST_USER_ID_LIST)
-- Params
--          p_constraint_rev_id   := specified constraint_rev_id
--          p_type_code           := specified constraint type code (default is NULL)
-- Notes
--          p_type_code is introduced in AMW.D
--          if p_type_code is null, then check the type_code of p_constraint_rev_id
-- History
--          12.21.2004 tsho: fix for performance bug 4036679
--          01.06.2005 tsho: starting from AMW.D,
--                           consider Incompatible Responsibilities.
--                           consider Responsibility waivers, User waivers.
--                           not only check for employees, check for all users in G_AMW_USER
--          05.17.2005 tsho: starting from AMW.E,
--                           consider Role, GLOBAL Grant/USER Grant
--          05.25.2005 tsho: consider Concurrent Programs as constraint entries
--          06.30.2006 psomanat: Method Depricated. Use Populate_User_Vio_For_Cst
-- ===============================================================
Procedure Populate_User_Id_List_For_Cst(
    p_constraint_rev_id      IN  NUMBER,
    p_type_code              IN  VARCHAR2   := NULL
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Populate_User_Id_List_For_Cst';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.1;

-- 01.06.2005 tsho: store the constraint type for this constraint
l_type_code     VARCHAR2(30)    := p_type_code;

-- 01.06.2005 tsho: find the constraint by specified constraint_rev_id
CURSOR c_constraint (l_constraint_rev_id IN NUMBER) IS
      SELECT type_code
        FROM amw_constraints_b
	   WHERE constraint_rev_id=l_constraint_rev_id;

i NUMBER;
l_user_id NUMBER;
l_user_name VARCHAR2(320);

-- enable dynamic sql in AMW.C with 5.10
-- should only get user_id who has potential responsibilities
TYPE userCurTyp IS REF CURSOR;
c_user_dynamic_sql userCurTyp;
-- 05.17.2005 tsho: starting from AMW.E, consider Role, GLOBAL Grant/USER Grant
/*
l_user_func_cst_dynamic_sql   VARCHAR2(2000)  :=
        'SELECT distinct ur.user_id '
      ||'  FROM '||G_AMW_USER_RESP_GROUPS||' ur '
      ||'      ,'||G_AMW_USER||' u '
      ||' WHERE ur.user_id = u.user_id '
      ||'   AND ur.start_date <= sysdate AND (ur.end_date >= sysdate or ur.end_date is null) '
      ||'   AND u.start_date <= sysdate AND (u.end_date >= sysdate or u.end_date is null) '
      ||'   AND ur.responsibility_id in ( '
      ||'       SELECT responsibility_id '
      ||'         FROM '||G_AMW_RESPONSIBILITY
      ||'        WHERE start_date <= sysdate AND (end_date >= sysdate or end_date is null) '
      ||'          AND menu_id in ( '
      ||'              SELECT menu_id '
      ||'                FROM '||G_AMW_COMPILED_MENU_FUNCTIONS
      ||'               WHERE grant_flag = ''Y'' '
      ||'                 AND function_id in ( '
      ||'                     SELECT constraintEntry.FUNCTION_ID '
      ||'                       FROM AMW_CONSTRAINT_ENTRIES constraintEntry '
      ||'                      WHERE constraintEntry.CONSTRAINT_REV_ID = :1 '
      ||'                 ) '
      ||'          ) '
      ||'   ) ';
*/
l_user_func_cst_dynamic_sql   VARCHAR2(4000)  :=
        'SELECT u.user_id, u.user_name '
      ||'  FROM '||G_AMW_USER||' u '
      ||' WHERE u.start_date <= sysdate AND (u.end_date >= sysdate or u.end_date is null) '
      ||'   AND u.user_name in ( '
      ||'     SELECT ur.user_name '
      ||'       FROM '||G_AMW_USER_ROLES||' ur '
      ||'           ,'||G_AMW_RESPONSIBILITY||' resp '
      ||'           ,'||G_AMW_COMPILED_MENU_FUNCTIONS||' cmf '
      ||'           ,AMW_CONSTRAINT_ENTRIES ce '
      ||'      WHERE ur.role_orig_system = ''FND_RESP'' '
      ||'        AND ur.role_orig_system_id = resp.responsibility_id '
      ||'        AND resp.menu_id = cmf.menu_id '
      ||'        AND cmf.function_id = ce.function_id AND (ce.object_type is null OR ce.object_type = ''FUNC'') '
      ||'        AND cmf.grant_flag = ''Y'' '
      ||'        AND ce.CONSTRAINT_REV_ID = :1 '
      ||'        AND resp.start_date <= sysdate AND (resp.end_date >= sysdate or resp.end_date is null) '
      ||'     UNION ALL '
      ||'     SELECT ur.user_name '
      ||'       FROM '||G_AMW_USER_ROLES||' ur '
      ||'           ,'||G_AMW_RESPONSIBILITY||' resp '
      ||'           ,'||G_AMW_REQUEST_GROUP_UNITS||' rgu '
      ||'           ,AMW_CONSTRAINT_ENTRIES ce '
      ||'      WHERE ur.role_orig_system = ''FND_RESP'' '
      ||'        AND ur.role_orig_system_id = resp.responsibility_id '
      ||'        AND resp.request_group_id = rgu.request_group_id '
      ||'        AND rgu.request_unit_type = ''P'' '
      ||'        AND rgu.request_unit_id = ce.function_id AND ce.object_type = ''CP'' '
      ||'        AND ce.CONSTRAINT_REV_ID = :2 '
      ||'        AND resp.start_date <= sysdate AND (resp.end_date >= sysdate or resp.end_date is null) '
      ||'     UNION ALL '
      ||'     SELECT ur.user_name '
      ||'       FROM '||G_AMW_USER_ROLES||' ur '
      ||'           ,'||G_AMW_GRANTS||' gra '
      ||'           ,'||G_AMW_COMPILED_MENU_FUNCTIONS||' cmf '
      ||'           ,AMW_CONSTRAINT_ENTRIES ce '
      ||'      WHERE (ur.role_orig_system = ''UMX'' OR ur.role_orig_system = ''FND_RESP'') '
      ||'        AND ur.ROLE_NAME = gra.GRANTEE_KEY '
      ||'        AND gra.INSTANCE_TYPE = ''GLOBAL'' '
      ||'        AND gra.OBJECT_ID = -1 '
      ||'        AND gra.GRANTEE_TYPE = ''GROUP'' '
      ||'        AND gra.menu_id = cmf.menu_id '
      ||'        AND cmf.function_id = ce.function_id '
      ||'        AND ce.CONSTRAINT_REV_ID = :3 '
      ||'        AND gra.start_date <= sysdate AND (gra.end_date >= sysdate or gra.end_date is null) '
      ||'     UNION ALL '
      ||'     SELECT ur.user_name '
      ||'       FROM '||G_AMW_USER_ROLES||' ur '
      ||'           ,'||G_AMW_GRANTS||' gra '
      ||'           ,'||G_AMW_COMPILED_MENU_FUNCTIONS||' cmf '
      ||'           ,AMW_CONSTRAINT_ENTRIES ce '
      ||'      WHERE ur.user_name = gra.GRANTEE_KEY '
      ||'        AND gra.INSTANCE_TYPE = ''GLOBAL'' '
      ||'        AND gra.OBJECT_ID = -1 '
      ||'        AND gra.GRANTEE_TYPE = ''USER'' '
      ||'        AND gra.menu_id = cmf.menu_id '
      ||'        AND cmf.function_id = ce.function_id '
      ||'        AND ce.CONSTRAINT_REV_ID = :4 '
      ||'        AND gra.start_date <= sysdate AND (gra.end_date >= sysdate or gra.end_date is null) '
      ||'   ) ';

l_user_resp_cst_dynamic_sql   VARCHAR2(2000)  :=
        'SELECT distinct ur.user_id, to_char(null) user_name '
      ||'  FROM '||G_AMW_USER_RESP_GROUPS||' ur'
      ||'      ,'||G_AMW_USER||' u'
      ||' WHERE ur.user_id = u.user_id '
      ||'   AND ur.start_date <= sysdate AND (ur.end_date >= sysdate or ur.end_date is null) '
      ||'   AND u.start_date <= sysdate AND (u.end_date >= sysdate or u.end_date is null) '
      ||'   AND ur.responsibility_id in ( '
      ||'       SELECT constraintEntry.FUNCTION_ID '
      ||'         FROM AMW_CONSTRAINT_ENTRIES constraintEntry '
      ||'        WHERE constraintEntry.CONSTRAINT_REV_ID = :1 '
      ||'   ) ';



BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    -- 12.21.2004 tsho: fix for performance bug 4036679, G_USER_ID_LIST is valid for one constraint
    G_CST_USER_ID_LIST.DELETE();

    --05.17.2005 tsho: starting from AMW.E, store user_name in addition to user_id for use in G_AMW_USER_ROLES
    G_CST_USER_NAME_LIST.DELETE();

    -- 01.06.2005 tsho: if p_type_code is null, then check the type_code of p_constraint_rev_id
    IF (p_type_code IS NULL) THEN
        OPEN c_constraint(p_constraint_rev_id);
        FETCH c_constraint INTO l_type_code;
        CLOSE c_constraint;
    END IF; -- end of if: _type_code IS NULL

    IF (substr(l_type_code,1,4) = 'RESP') THEN
      --FND_FILE.put_line(fnd_file.log,'ID List for RESP '||L_API_NAME);
      -- for constriant type : Responsibility
      IF (BULK_COLLECTS_SUPPORTED) THEN
        -- enable dynamic sql in AMW.C with 5.10
        OPEN c_user_dynamic_sql FOR l_user_resp_cst_dynamic_sql USING
            p_constraint_rev_id;
        FETCH c_user_dynamic_sql BULK COLLECT INTO G_CST_USER_ID_LIST, G_CST_USER_NAME_LIST;
        CLOSE c_user_dynamic_sql;
      ELSE
        -- no BULK_COLLECTS_SUPPORTED
        i := 0;
        -- enable dynamic sql in AMW.C with 5.10
        OPEN c_user_dynamic_sql FOR l_user_resp_cst_dynamic_sql USING
            p_constraint_rev_id;
        LOOP
            FETCH c_user_dynamic_sql INTO l_user_id, l_user_name;
            EXIT WHEN c_user_dynamic_sql%NOTFOUND;
            i := i+1;
            G_CST_USER_ID_LIST(i) := l_user_id;
            G_CST_USER_NAME_LIST(i) := l_user_name;
        END LOOP;
        CLOSE c_user_dynamic_sql;
      END IF; -- end of if: BULK_COLLECTS_SUPPORTED

    ELSE
      --FND_FILE.put_line(fnd_file.log,'ID List for FUNC '||L_API_NAME);
      -- for constriant type : Function
      IF (BULK_COLLECTS_SUPPORTED) THEN
        OPEN c_user_dynamic_sql FOR l_user_func_cst_dynamic_sql USING
            p_constraint_rev_id, p_constraint_rev_id, p_constraint_rev_id, p_constraint_rev_id;
        FETCH c_user_dynamic_sql BULK COLLECT INTO G_CST_USER_ID_LIST, G_CST_USER_NAME_LIST;
        CLOSE c_user_dynamic_sql;
      ELSE
        -- no BULK_COLLECTS_SUPPORTED
        i := 0;
        -- enable dynamic sql in AMW.C with 5.10
        OPEN c_user_dynamic_sql FOR l_user_func_cst_dynamic_sql USING
            p_constraint_rev_id, p_constraint_rev_id, p_constraint_rev_id, p_constraint_rev_id;
        LOOP
            FETCH c_user_dynamic_sql INTO l_user_id, l_user_name;
            EXIT WHEN c_user_dynamic_sql%NOTFOUND;
            i := i+1;
            G_CST_USER_ID_LIST(i) := l_user_id;
            G_CST_USER_NAME_LIST(i) := l_user_name;
        END LOOP;
        CLOSE c_user_dynamic_sql;
      END IF; -- end of if: BULK_COLLECTS_SUPPORTED

    END IF; --end of if: substr(l_type_code,1,4) = 'RESP'
    --FND_FILE.put_line(fnd_file.log,'Came out '||L_API_NAME);

END Populate_User_Id_List_For_Cst;


-- ===============================================================
-- Procedure name
--          Populate_User_Vio_For_Vlt
-- Purpose
--          populate the global user id list for one violation (G_CST_USER_ID_LIST)
-- Params
--          p_violation_id        := specified violation_id
--          p_constraint_rev_id   := specified constraint_rev_id
--          p_type_code           := Specified Object_Type

-- Notes
--          Revalidation only check violations for existing violators for
--          specified violation_id
--
-- History
--          05.20.2005 tsho: create for AMW.E Revalidation
-- ===============================================================
Procedure Populate_User_Vio_For_Vlt(
    p_violation_id           IN  NUMBER,
    p_constraint_rev_id      IN  NUMBER := NULL,
    p_type_code              IN  VARCHAR2   := NULL
)
IS
    -- 01.06.2005 tsho: store the constraint type for this constraint
    l_type_code     VARCHAR2(30)    := p_type_code;

    -- 01.06.2005 tsho: find the constraint by specified constraint_rev_id
    CURSOR c_constraint (l_constraint_rev_id IN NUMBER) IS
        SELECT  type_code
        FROM    amw_constraints_b
        WHERE   constraint_rev_id=l_constraint_rev_id;

    TYPE userVioCurTyp IS REF CURSOR;
    c_user_vio_dynamic_sql userVioCurTyp;

    -- get the roles,user/global grants accessible by existing violators
    l_user_role_dynamic_sql   VARCHAR2(4000)  :=
      ' SELECT gra.grantee_key role_name, '
    ||'        gra.menu_id, '
    ||'        ce.function_id, '
    ||'        min(urasgn.start_date), '
    ||'        ( SELECT asgn.created_by '
    ||'          FROM '||G_AMW_USER_ROLE_ASSIGNMENTS||'  asgn '
    ||'          WHERE asgn.user_name = usr.user_name '
    ||'          AND asgn.role_name = role_name '
    ||'          AND asgn.start_date = start_date '
    ||'          AND rownum=1 '
    ||'        ) created_by, '
    ||'        ''FUNC'' entry_object_type, '
    ||'        usr.user_id ,'
    ||'        ce.group_code '
    ||' FROM '||G_AMW_GRANTS||' gra, '
    ||'      '||G_AMW_COMPILED_MENU_FUNCTIONS||'  cmf, '
    ||'      AMW_CONSTRAINT_ENTRIES ce, '
    ||'      '||G_AMW_USER_ROLE_ASSIGNMENTS||'  urasgn, '
    ||'      '||G_AMW_USER||' usr, '
    ||'      AMW_VIOLATION_USERS vu '
    ||' WHERE urasgn.user_name = usr.user_name '
    ||' AND (gra.grantee_orig_system = ''UMX'' OR gra.grantee_orig_system = ''FND_RESP'') '
    ||' AND urasgn.role_name = gra.GRANTEE_KEY '
    ||' AND gra.menu_id = cmf.menu_id '
    ||' AND cmf.function_id = ce.function_id '
    ||' AND (ce.object_type is null OR ce.object_type = ''FUNC'') '
    ||' AND ce.CONSTRAINT_REV_ID = :1 '
    ||' AND gra.INSTANCE_TYPE = ''GLOBAL'' '
    ||' AND gra.OBJECT_ID = -1 '
    ||' AND gra.GRANTEE_TYPE = ''GROUP'' '
    ||' AND gra.start_date <= sysdate '
    ||' AND (gra.end_date >= sysdate or gra.end_date is null) '
    ||' AND urasgn.start_date <= sysdate '
    ||' AND (urasgn.end_date >= sysdate or urasgn.end_date is null) '
    ||' AND usr.start_date <= sysdate '
    ||' AND (usr.end_date >= sysdate or usr.end_date is null) '
    ||' AND  vu.violation_id =:2 '
    ||' AND  vu.violated_by_id = usr.user_id '
    ||' GROUP BY gra.grantee_key, gra.menu_id,ce.function_id,usr.user_name,usr.user_id, ce.group_code '
    ||' UNION ALL '
    ||' SELECT to_char(null) role_name, '
    ||'        gra.menu_id, '
    ||'        ce.function_id, '
    ||'        gra.start_date, '
    ||'        gra.created_by, '
    ||'        ''FUNC'' entry_object_type, '
    ||'        usr.user_id ,'
    ||'        ce.group_code '
    ||' FROM '||G_AMW_GRANTS||' gra, '
    ||'      '||G_AMW_COMPILED_MENU_FUNCTIONS||' cmf, '
    ||'      AMW_CONSTRAINT_ENTRIES ce, '
    ||'      '||G_AMW_USER||' usr , '
    ||'      AMW_VIOLATION_USERS vu '
    ||' WHERE (( gra.GRANTEE_KEY = usr.user_name AND gra.GRANTEE_TYPE = ''USER'') '
    ||'          OR (gra.GRANTEE_KEY = ''GLOBAL'' AND gra.GRANTEE_TYPE = ''GLOBAL'')) '
    ||' AND gra.menu_id = cmf.menu_id '
    ||' AND cmf.function_id = ce.function_id '
    ||' AND (ce.object_type is null OR ce.object_type = ''FUNC'') '
    ||' AND ce.CONSTRAINT_REV_ID = :3 '
    ||' AND gra.INSTANCE_TYPE = ''GLOBAL'' '
    ||' AND gra.OBJECT_ID  = -1 '
    ||' AND gra.start_date <= sysdate '
    ||' AND (gra.end_date  >= sysdate or gra.end_date is null) '
    ||' AND usr.start_date <= sysdate '
    ||' AND (usr.end_date  >= sysdate or usr.end_date is null) '
    ||' AND  vu.violation_id =:4 '
    ||' AND  vu.violated_by_id = usr.user_id ';

    -- Identify the responsibilities accessible by existing violators
    l_user_func_cst_dynamic_sql   VARCHAR2(9000)  :=
      ' SELECT  usr.user_id, '
    ||'         appl.application_id, '
    ||'         ur.role_orig_system_id, '
    ||'         min(urasgn.start_date) start_date, '
    ||'        ( select asgn.created_by '
    ||'          from WF_USER_ROLE_ASSIGNMENTS  asgn '
    ||'          where asgn.user_name = ur.user_name '
    ||'          and asgn.role_name = ur.role_name '
    ||'          and asgn.start_date = start_date '
    ||'          and rownum=1 '
    ||'        ) created_by, '
    ||'        DECODE((select count(*) '
    ||'                from amw_constraint_waivers_b '
    ||'                where constraint_rev_id= :1 '
    ||'                and object_type=''RESP'' '
    ||'                and pk1 = ur.role_orig_system_id '
    ||'                and pk2 = appl.application_id '
    ||'                and start_date <= sysdate '
    ||'                AND (end_date  >= sysdate or end_date is null)),0,''N'',''Y'') waived_flag '
    ||' FROM WF_USER_ROLES  ur, '
    ||'      WF_USER_ROLE_ASSIGNMENTS  urasgn, '
    ||'      FND_USER usr, '
    ||'      WF_LOCAL_ROLES rol, '
    ||'      FND_APPLICATION_VL appl, '
    ||'      FND_RESPONSIBILITY resp, '
    ||'      FND_COMPILED_MENU_FUNCTIONS cmf, '
    ||'      AMW_CONSTRAINT_ENTRIES ce , '
    ||'      AMW_VIOLATION_USERS vu '
    ||' WHERE ce.CONSTRAINT_REV_ID =  :2 '
    ||' AND (ce.object_type is null OR ce.object_type = ''FUNC'') '
    ||' AND cmf.menu_id = resp.menu_id '
    ||' AND cmf.grant_flag = ''Y'' '
    ||' AND cmf.function_id = ce.function_id '
    ||' AND resp.start_date <= sysdate '
    ||' AND (resp.end_date >= sysdate or resp.end_date is null) '
    ||' AND ur.role_orig_system_id = resp.responsibility_id '
    ||' AND ur.role_orig_system = ''FND_RESP'' '
    ||' AND ur.role_name = rol.name '
    ||' AND ur.role_orig_system = rol.orig_system '
    ||' AND ur.role_orig_system_id = rol.orig_system_id '
    ||' AND ur.partition_id = rol.partition_id '
    ||' AND rol.start_date<= sysdate '
    ||' AND (rol.expiration_date IS NULL OR rol.expiration_date>=sysdate) '
    ||' AND rol.owner_tag=appl.application_short_name '
    ||' AND resp.application_id=appl.application_id '
    ||' AND ur.user_name = urasgn.user_name '
    ||' AND ur.role_name = urasgn.role_name '
    ||' AND (ur.user_orig_system = ''FND_USR'' OR ur.user_orig_system = ''PER'') '
    ||' AND urasgn.start_date <= sysdate '
    ||' AND (urasgn.end_date >= sysdate or urasgn.end_date is null) '
    ||' AND ur.user_name=usr.user_name '
    ||' AND usr.start_date <= sysdate '
    ||' AND (usr.end_date >= sysdate or usr.end_date is null) '
    ||' AND  vu.violation_id =:3 '
    ||' AND  vu.violated_by_id = usr.user_id '
    ||' GROUP BY usr.user_id,ur.user_name,appl.application_id,ur.role_orig_system_id, ur.role_name '
    ||' UNION '
    ||' SELECT  usr.user_id, '
    ||'        appl.application_id, '
    ||'        ur.role_orig_system_id, '
    ||'        min(urasgn.start_date) start_date, '
    ||'        ( select asgn.created_by '
    ||'          from WF_USER_ROLE_ASSIGNMENTS  asgn '
    ||'          where asgn.user_name = ur.user_name '
    ||'          and asgn.role_name = ur.role_name '
    ||'          and asgn.start_date = start_date '
    ||'          and rownum=1 '
    ||'        ) created_by, '
    ||'        DECODE((select count(*) '
    ||'                from amw_constraint_waivers_b '
    ||'                where constraint_rev_id= :4 '
    ||'                and object_type=''RESP'' '
    ||'                and pk1 = ur.role_orig_system_id '
    ||'                and pk2 = appl.application_id '
    ||'                and start_date <= sysdate '
    ||'                AND (end_date  >= sysdate or end_date is null)),0,''N'',''Y'') waived_flag '
    ||' FROM WF_USER_ROLES  ur, '
    ||'     WF_USER_ROLE_ASSIGNMENTS  urasgn, '
    ||'     FND_USER usr, '
    ||'     WF_LOCAL_ROLES rol, '
    ||'     FND_APPLICATION_VL appl, '
    ||'     FND_RESPONSIBILITY RESP, '
    ||'     FND_REQUEST_GROUP_UNITS RGU, '
    ||'     AMW_CONSTRAINT_ENTRIES ACE , '
    ||'     AMW_VIOLATION_USERS vu '
    ||' WHERE ACE.CONSTRAINT_REV_ID=:5 '
    ||' AND ACE.OBJECT_TYPE=''CP'' '
    ||' AND RESP.GROUP_APPLICATION_ID IS NOT NULL '
    ||' AND RESP.REQUEST_GROUP_ID IS NOT NULL '
    ||' AND RGU.APPLICATION_ID=RESP.GROUP_APPLICATION_ID '
    ||' AND RGU.REQUEST_GROUP_ID=RESP.REQUEST_GROUP_ID '
    ||' AND RGU.REQUEST_UNIT_TYPE = ''P'' '
    ||' AND RGU.UNIT_APPLICATION_ID=ACE.APPLICATION_ID '
    ||' AND RGU.REQUEST_UNIT_ID=ACE.FUNCTION_ID '
    ||' AND RESP.START_DATE<=SYSDATE '
    ||' AND (RESP.END_DATE>= SYSDATE or RESP.END_DATE IS NULL) '
    ||' AND ur.role_orig_system_id = resp.responsibility_id '
    ||' AND ur.role_orig_system = ''FND_RESP'' '
    ||' AND ur.role_name = rol.name '
    ||' AND ur.role_orig_system = rol.orig_system '
    ||' AND ur.role_orig_system_id = rol.orig_system_id '
    ||' AND ur.partition_id = rol.partition_id '
    ||' AND rol.start_date<= sysdate '
    ||' AND (rol.expiration_date IS NULL OR rol.expiration_date>=sysdate) '
    ||' AND rol.owner_tag = appl.application_short_name '
    ||' AND resp.application_id = appl.application_id '
    ||' AND ur.user_name = urasgn.user_name '
    ||' AND ur.role_name = urasgn.role_name '
    ||' AND urasgn.start_date <= sysdate '
    ||' AND (urasgn.end_date >= sysdate or urasgn.end_date is null) '
    ||' AND ur.user_name=usr.user_name '
    ||' AND usr.start_date <= sysdate '
    ||' AND (usr.end_date >= sysdate or usr.end_date is null) '
    ||' AND  vu.violation_id =:6 '
    ||' AND  vu.violated_by_id = usr.user_id '
    ||' GROUP BY usr.user_id,ur.user_name,appl.application_id,ur.role_orig_system_id, ur.role_name ';

    -- Identify the responsibilities accessible by existing violators
    l_user_resp_dynamic_sql VARCHAR2(4000)  :=
      ' SELECT usr.user_id,   '
    ||'        appl.application_id, '
    ||'        ur.role_orig_system_id, '
    ||'        min(urasgn.start_date) start_date, '
    ||'        ( select asgn.created_by '
    ||'          from '||G_AMW_USER_ROLE_ASSIGNMENTS||'  asgn '
    ||'          where asgn.user_name = ur.user_name '
    ||'          and asgn.role_name   = ur.role_name '
    ||'          and asgn.start_date  = start_date '
    ||'          and rownum=1 '
    ||'        ) created_by ,'
    ||'       ce.group_code '
    ||' FROM WF_USER_ROLES  ur, '
    ||'      '||G_AMW_USER_ROLE_ASSIGNMENTS||'  urasgn, '
    ||'      '||G_AMW_USER||' usr, '
    ||'      WF_LOCAL_ROLES rol, '
    ||'      FND_APPLICATION_VL appl, '
    ||'      '||G_AMW_RESPONSIBILITY||' resp, '
    ||'      AMW_CONSTRAINT_ENTRIES ce , '
    ||'      AMW_VIOLATION_USERS vu '
    ||' WHERE ce.CONSTRAINT_REV_ID =  :1 '
    ||' AND ce.object_type     = ''RESP'' '
    ||' AND ce.function_id     = resp.responsibility_id '
    ||' AND ce.application_id  = resp.application_id '
    ||' AND ur.role_orig_system_id = resp.responsibility_id '
    ||'  AND ur.role_orig_system = ''FND_RESP'' '
    ||' AND ur.role_name        = rol.name '
    ||' AND ur.role_orig_system = rol.orig_system '
    ||' AND ur.role_orig_system_id = rol.orig_system_id '
    ||' AND ur.partition_id     = rol.partition_id '
    ||' AND rol.owner_tag       = appl.application_short_name '
    ||' AND resp.application_id = appl.application_id '
    ||' AND ur.user_name        = urasgn.user_name '
    ||' AND ur.role_name        = urasgn.role_name '
    ||' AND ur.user_name        = usr.user_name '
    ||' AND (ur.user_orig_system = ''FND_USR'' OR ur.user_orig_system = ''PER'') '
    ||' AND rol.start_date      <= sysdate '
    ||' AND (rol.expiration_date IS NULL OR rol.expiration_date>=sysdate) '
    ||' AND  vu.violation_id =:2 '
    ||' AND  vu.violated_by_id = usr.user_id '
    ||' AND resp.start_date    <= sysdate '
    ||' AND (resp.end_date     >= sysdate OR resp.end_date IS NULL) '
    ||' AND urasgn.start_date  <= sysdate '
    ||' AND (urasgn.end_date   >= sysdate OR urasgn.end_date IS NULL) '
    ||' AND usr.start_date     <= sysdate '
    ||' AND (usr.end_date      >= sysdate OR usr.end_date IS NULL) '
    ||' GROUP BY usr.user_id,ur.user_name,appl.application_id,ur.role_orig_system_id, ur.role_name,ce.group_code  ';

    -- psomanat : 06:09:2006 : fix for bug 5256720
    L_USERVIO_ENTRIES G_USERVIO_ENTRIES_TABLE;
    L_FUNC_ID_LIST    G_FUNCS_TABLE;
    L_RESP_ID_LIST    G_RESPS_TABLE;

    counts            Number;
    listkey           NUMBER(15);
    l_user_access_waived_resp_list G_VARCHAR2_TABLE;

    L_RESPVIO_ENTRIES   G_RESPVIO_ENTRIES_TABLE;
    L_RESP_FUNC_ID_LIST G_FUNC_TABLE;
    rListkey            VARCHAR2(30) := NULL;
    flag                BOOLEAN := TRUE;
BEGIN

    -- FND_FILE.put_line(fnd_file.log,'Populate_User_Vio_For_Vlt Began '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));

    IF (p_violation_id IS NULL) THEN
        RETURN;
    END IF;

    IF (p_type_code IS NULL) THEN
        OPEN c_constraint(p_constraint_rev_id);
        FETCH c_constraint INTO l_type_code;
        CLOSE c_constraint;
    END IF; -- end of if: _type_code IS NULL

    G_USER_VIOLATIONS_LIST.delete();
    G_USER_RESP_VIO_LIST.delete();

    IF (substr(l_type_code,1,4) = 'RESP') THEN

        -- Clearing the List
        G_CST_USER_ID_LIST.Delete();
        G_UPV_APPLICATION_ID_LIST.Delete();
        G_UPV_RESPONSIBILITY_ID_LIST.Delete();
        G_UPV_ACCESS_GIVEN_DATE_LIST.Delete();
        G_UPV_ACCESS_GIVEN_BY_LIST.Delete();
        G_UPV_GROUP_CODE_LIST.Delete();

        OPEN c_user_vio_dynamic_sql FOR l_user_resp_dynamic_sql USING
            p_constraint_rev_id,p_violation_id;
        FETCH c_user_vio_dynamic_sql
        BULK COLLECT INTO G_CST_USER_ID_LIST,
                      G_UPV_APPLICATION_ID_LIST,
                      G_UPV_RESPONSIBILITY_ID_LIST,
                      G_UPV_ACCESS_GIVEN_DATE_LIST,
                      G_UPV_ACCESS_GIVEN_BY_LIST,
                      G_UPV_GROUP_CODE_LIST;
        CLOSE c_user_vio_dynamic_sql;

        -- A user can have n number of responsibilities associated to him
        -- We need to iterate over the G_UPV_XXXXXX_LIST to get the responsibilities
        -- assigned to the user.
        -- This will cause a performace issue
        -- So we store the G_UPV_XXXXXX_LIST nested tables data into a plsql data
        -- structure. The structure is like this
        --   User_id
        --        |______Responsibility_id
        --        |______Responsibility_id
        --        |______Responsibility_id
        --

        IF (G_CST_USER_ID_LIST IS NOT NULL) AND (G_CST_USER_ID_LIST.FIRST IS NOT NULL) THEN
            FOR i in 1 .. G_CST_USER_ID_LIST.COUNT
            LOOP
                flag := TRUE;
                listkey :=G_CST_USER_ID_LIST(i);
                rListkey :=G_UPV_APPLICATION_ID_LIST(i)||'@'||G_UPV_RESPONSIBILITY_ID_LIST(i);

                L_RESP_ID_LIST.delete();
                L_USERVIO_ENTRIES.delete();

                IF (G_USER_RESP_VIO_LIST.EXISTS(listkey)) THEN
                    L_RESP_ID_LIST := G_USER_RESP_VIO_LIST(listkey);
                    IF L_RESP_ID_LIST.EXISTS(rListkey) THEN
                        L_USERVIO_ENTRIES := L_RESP_ID_LIST(rListkey);
                        FOR l IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
                        LOOP
                            IF ( L_USERVIO_ENTRIES(l).application_id    = G_UPV_APPLICATION_ID_LIST(i) AND
                                 L_USERVIO_ENTRIES(l).Responsibility_id = G_UPV_RESPONSIBILITY_ID_LIST(i)) THEN
                                    flag:=FALSE;
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
                IF (flag) THEN
                counts := L_USERVIO_ENTRIES.COUNT+1;
                L_USERVIO_ENTRIES(counts).User_id            := G_CST_USER_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).Access_Given_Date  := G_UPV_ACCESS_GIVEN_DATE_LIST(i);
                L_USERVIO_ENTRIES(counts).Access_Given_By_Id := G_UPV_ACCESS_GIVEN_BY_LIST(i);
                L_USERVIO_ENTRIES(counts).application_id     := G_UPV_APPLICATION_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).Responsibility_id  := G_UPV_RESPONSIBILITY_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).group_code         := G_UPV_GROUP_CODE_LIST(i);
                L_USERVIO_ENTRIES(counts).Waived             := NUll;
                L_USERVIO_ENTRIES(counts).Role_Name          := NUll;
                L_USERVIO_ENTRIES(counts).Menu_id            := NUll;
                L_USERVIO_ENTRIES(counts).Function_Id        := NUll;
                L_USERVIO_ENTRIES(counts).Object_Type        := NUll;
                L_USERVIO_ENTRIES(counts).prog_appl_id       := NUll;
                L_RESP_ID_LIST(rListkey)                     := L_USERVIO_ENTRIES;
                G_USER_RESP_VIO_LIST(listkey)                := L_RESP_ID_LIST;
                END IF;
            END LOOP;
        END IF;
        -- Clearing the List
        G_CST_USER_ID_LIST.Delete();
        G_UPV_APPLICATION_ID_LIST.Delete();
        G_UPV_RESPONSIBILITY_ID_LIST.Delete();
        G_UPV_ACCESS_GIVEN_DATE_LIST.Delete();
        G_UPV_ACCESS_GIVEN_BY_LIST.Delete();
        G_UPV_GROUP_CODE_LIST.Delete();
    ELSE
        -- Clearing the list
        G_UPV_ROLE_NAME_LIST.delete();
        G_UPV_MENU_ID_LIST.delete();
        G_UPV_FUNCTION_ID_LIST.delete();
        G_UPV_ACCESS_GIVEN_DATE_LIST.delete();
        G_UPV_ACCESS_GIVEN_BY_LIST.delete();
        G_UPV_ENTRY_OBJECT_TYPE_LIST.delete();
        G_CST_USER_ID_LIST.delete();
        G_UPV_GROUP_CODE_LIST.delete();

        -- A user can have n number of responsibilities associated to him
        -- We need to iterate over the G_UPV_XXXXXX_LIST to get the responsibilities
        -- assigned to the user. Then from the responsibility we need to
        -- get the incompatible functions accessible to the user.
        -- This will cause a performace issue
        -- So we store the G_UPV_XXXXXX_LIST nested tables and G_RESP_VIOLATIONS_LIST
        -- data into a plsql data  structure.
        -- The structure is like this
        --   User_id
        --        |______Function_Id
        --                      |______Function Detils group1
        --                      |______Function Detils group2
        --        |______Function_Id
        --                      |______Function Detils group1
        --                      |______Function Detils group2
        --        |______Function_Id
        --                      |______Function Detils group1
        --                      |______Function Detils group2
        --  A function can be avilable in group 1 and group 2
        --  so we store both groups under function_id

        -- First we get the user - roles,user - grants, global grants  and
        -- populate the plsql data structure
        OPEN c_user_vio_dynamic_sql FOR l_user_role_dynamic_sql USING
                p_constraint_rev_id,
                p_violation_id,
                p_constraint_rev_id,
                p_violation_id;
        FETCH c_user_vio_dynamic_sql
        BULK COLLECT INTO G_UPV_ROLE_NAME_LIST,
                          G_UPV_MENU_ID_LIST,
                          G_UPV_FUNCTION_ID_LIST,
                          G_UPV_ACCESS_GIVEN_DATE_LIST,
                          G_UPV_ACCESS_GIVEN_BY_LIST,
                          G_UPV_ENTRY_OBJECT_TYPE_LIST,
                          G_CST_USER_ID_LIST,
                          G_UPV_GROUP_CODE_LIST;
        CLOSE c_user_vio_dynamic_sql;

        IF (G_CST_USER_ID_LIST IS NOT NULL) AND (G_CST_USER_ID_LIST.FIRST IS NOT NULL) THEN
        FOR i in 1 .. G_CST_USER_ID_LIST.COUNT
            LOOP
                flag := TRUE;
                L_FUNC_ID_LIST.delete();
                L_USERVIO_ENTRIES.delete();

                listkey :=G_CST_USER_ID_LIST(i);
                IF (G_USER_VIOLATIONS_LIST.EXISTS(listkey)) THEN
                    L_FUNC_ID_LIST := G_USER_VIOLATIONS_LIST(listkey);
                    IF L_FUNC_ID_LIST.EXISTS(G_UPV_FUNCTION_ID_LIST(i)) THEN
                        L_USERVIO_ENTRIES := L_FUNC_ID_LIST(G_UPV_FUNCTION_ID_LIST(i));
                       FOR l IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
                       LOOP
                            IF ( L_USERVIO_ENTRIES(l).Role_Name   = G_UPV_ROLE_NAME_LIST(i) AND
                                 L_USERVIO_ENTRIES(l).Menu_id     = G_UPV_MENU_ID_LIST(i) AND
                                 L_USERVIO_ENTRIES(l).Function_Id = G_UPV_FUNCTION_ID_LIST(i)) THEN
                                    flag:=FALSE;
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
                IF (flag) THEN
                counts := L_USERVIO_ENTRIES.COUNT+1;
                L_USERVIO_ENTRIES(counts).User_id            := G_CST_USER_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).Role_Name          := G_UPV_ROLE_NAME_LIST(i);
                L_USERVIO_ENTRIES(counts).Menu_id            := G_UPV_MENU_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).Function_Id        := G_UPV_FUNCTION_ID_LIST(i);
                L_USERVIO_ENTRIES(counts).Access_Given_Date  := G_UPV_ACCESS_GIVEN_DATE_LIST(i);
                L_USERVIO_ENTRIES(counts).Access_Given_By_Id := G_UPV_ACCESS_GIVEN_BY_LIST(i);
                L_USERVIO_ENTRIES(counts).Object_Type        := 'FUNC';
                L_USERVIO_ENTRIES(counts).Waived             := 'N';
                L_USERVIO_ENTRIES(counts).group_code         := G_UPV_GROUP_CODE_LIST(i);
                L_USERVIO_ENTRIES(counts).prog_appl_id       := NULL;
                L_USERVIO_ENTRIES(counts).application_id     := NULL;
                L_USERVIO_ENTRIES(counts).Responsibility_id  := NULL;
                L_FUNC_ID_LIST(G_UPV_FUNCTION_ID_LIST(i))    := L_USERVIO_ENTRIES;
                G_USER_VIOLATIONS_LIST(listkey)              := L_FUNC_ID_LIST;
                END IF;
            END lOOP;
        END IF;
        -- Clearing the list
        G_UPV_ROLE_NAME_LIST.delete();
        G_UPV_MENU_ID_LIST.delete();
        G_UPV_FUNCTION_ID_LIST.delete();
        G_UPV_ENTRY_OBJECT_TYPE_LIST.delete();
        G_CST_USER_ID_LIST.delete();
        G_UPV_APPLICATION_ID_LIST.delete();
        G_UPV_RESPONSIBILITY_ID_LIST.delete();
        G_UPV_ACCESS_GIVEN_DATE_LIST.delete();
        G_UPV_ACCESS_GIVEN_BY_LIST.delete();
        l_user_access_waived_resp_list.delete();
        G_UPV_GROUP_CODE_LIST.delete();

        --Second User - responsbilities and populate the plsql data structure
        OPEN c_user_vio_dynamic_sql FOR l_user_func_cst_dynamic_sql USING
            p_constraint_rev_id,
            p_constraint_rev_id,
            p_violation_id,
            p_constraint_rev_id,
            p_constraint_rev_id,
            p_violation_id;
        FETCH c_user_vio_dynamic_sql
        BULK COLLECT INTO G_CST_USER_ID_LIST,
                      G_UPV_APPLICATION_ID_LIST,
                      G_UPV_RESPONSIBILITY_ID_LIST,
                      G_UPV_ACCESS_GIVEN_DATE_LIST,
                      G_UPV_ACCESS_GIVEN_BY_LIST,
                      l_user_access_waived_resp_list;
        CLOSE c_user_vio_dynamic_sql;

        IF (G_CST_USER_ID_LIST IS NOT NULL) AND (G_CST_USER_ID_LIST.FIRST IS NOT NULL) THEN
            FOR i in 1 .. G_CST_USER_ID_LIST.COUNT
            LOOP
                listkey :=G_CST_USER_ID_LIST(i);
                rListkey :=G_UPV_APPLICATION_ID_LIST(i)||'@'||G_UPV_RESPONSIBILITY_ID_LIST(i);

                IF (G_RESP_VIOLATIONS_LIST.EXISTS(rListkey)) THEN
                    L_RESP_FUNC_ID_LIST.delete();
                    L_RESP_FUNC_ID_LIST := G_RESP_VIOLATIONS_LIST(rListkey);
                    FOR j IN L_RESP_FUNC_ID_LIST.FIRST .. L_RESP_FUNC_ID_LIST.LAST
                    LOOP
                        IF L_RESP_FUNC_ID_LIST.EXISTS(j) THEN
                            L_RESPVIO_ENTRIES.delete();
                            L_RESPVIO_ENTRIES:=L_RESP_FUNC_ID_LIST(j);
                            FOR k IN L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                            LOOP
                                flag := TRUE;
                                L_FUNC_ID_LIST.delete();
                                L_USERVIO_ENTRIES.delete();
                                IF (G_USER_VIOLATIONS_LIST.EXISTS(listkey)) THEN
                                    L_FUNC_ID_LIST := G_USER_VIOLATIONS_LIST(listkey);
                                    IF L_FUNC_ID_LIST.EXISTS(L_RESPVIO_ENTRIES(k).Function_Id) THEN
                                        L_USERVIO_ENTRIES := L_FUNC_ID_LIST(L_RESPVIO_ENTRIES(k).Function_Id);
                                        FOR l IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
                                        LOOP
                                            IF (L_USERVIO_ENTRIES(l).Object_Type = 'FUNC' AND
                                               L_RESPVIO_ENTRIES(k).Object_Type = 'FUNC' AND
                                               L_USERVIO_ENTRIES(l).application_id = L_RESPVIO_ENTRIES(k).application_id AND
                                               L_USERVIO_ENTRIES(l).Responsibility_id = L_RESPVIO_ENTRIES(k).Responsibility_id AND
                                               L_USERVIO_ENTRIES(l).Menu_id = L_RESPVIO_ENTRIES(k).Menu_id ) THEN
                                                flag:=FALSE;
                                            END IF;

                                            IF (L_USERVIO_ENTRIES(l).Object_Type = 'CP' AND
                                               L_RESPVIO_ENTRIES(k).Object_Type = 'CP' AND
                                               L_USERVIO_ENTRIES(l).application_id = L_RESPVIO_ENTRIES(k).application_id AND
                                               L_USERVIO_ENTRIES(l).Responsibility_id = L_RESPVIO_ENTRIES(k).Responsibility_id AND
                                               L_USERVIO_ENTRIES(l).Menu_id = L_RESPVIO_ENTRIES(k).Menu_id AND
                                               L_USERVIO_ENTRIES(l).prog_appl_id = L_RESPVIO_ENTRIES(k).prog_appl_id ) THEN
                                                flag:=FALSE;
                                            END IF;
                                        END LOOP;
                                    END IF;
                                END IF;
                                IF (flag) THEN
                                counts := L_USERVIO_ENTRIES.COUNT+1;
                                L_USERVIO_ENTRIES(counts).User_id               := G_CST_USER_ID_LIST(i);
                                L_USERVIO_ENTRIES(counts).Role_Name             := NUll;
                                L_USERVIO_ENTRIES(counts).Menu_id               := L_RESPVIO_ENTRIES(k).Menu_id;
                                L_USERVIO_ENTRIES(counts).Function_Id           := L_RESPVIO_ENTRIES(k).Function_Id;
                                L_USERVIO_ENTRIES(counts).Access_Given_Date     := G_UPV_ACCESS_GIVEN_DATE_LIST(i);
                                L_USERVIO_ENTRIES(counts).Access_Given_By_Id    := G_UPV_ACCESS_GIVEN_BY_LIST(i);
                                L_USERVIO_ENTRIES(counts).Object_Type           := L_RESPVIO_ENTRIES(k).Object_Type;
                                L_USERVIO_ENTRIES(counts).prog_appl_id          := L_RESPVIO_ENTRIES(k).prog_appl_id;
                                L_USERVIO_ENTRIES(counts).application_id        := L_RESPVIO_ENTRIES(k).application_id;
                                L_USERVIO_ENTRIES(counts).Responsibility_id     := L_RESPVIO_ENTRIES(k).Responsibility_id;
                                L_USERVIO_ENTRIES(counts).group_code            := L_RESPVIO_ENTRIES(k).group_code;
                                L_USERVIO_ENTRIES(counts).Waived                := l_user_access_waived_resp_list(i);
                                L_FUNC_ID_LIST(L_RESPVIO_ENTRIES(k).Function_Id):= L_USERVIO_ENTRIES;
                                G_USER_VIOLATIONS_LIST(listkey)                 := L_FUNC_ID_LIST;
                                END IF;
                            END LOOP;
                        END IF;
                    END LOOP;
                END IF;
            END lOOP;
        END IF;
    END IF;
    -- FND_FILE.put_line(fnd_file.log,'Populate_User_Vio_For_Vlt End '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));
END;


-- ===============================================================
-- Procedure name
--          Populate_User_Id_List_For_Vlt
-- Purpose
--          populate the global user id list for one violation (G_CST_USER_ID_LIST)
-- Params
--          p_violation_id        := specified violation_id
--          p_constraint_rev_id   := specified constraint_rev_id
-- Notes
--          Revalidation only check violations for existing violators for specified violation_id
--
-- History
--          05.20.2005 tsho: create for AMW.E Revalidation
--          06.30.2006 psomanat: Method Depricated. Use Populate_User_Vio_For_Vlt
-- ===============================================================
Procedure Populate_User_Id_List_For_Vlt(
    p_violation_id           IN  NUMBER,
    p_constraint_rev_id      IN  NUMBER := NULL
)
IS

i NUMBER;
l_user_id NUMBER;
l_user_name VARCHAR2(320);

TYPE userCurTyp IS REF CURSOR;
c_user_dynamic_sql userCurTyp;

l_user_reval_dynamic_sql   VARCHAR2(200)  :=
        'SELECT u.user_id, u.user_name '
      ||'  FROM AMW_VIOLATION_USERS vu '
      ||'      ,'||G_AMW_USER||' u '
      ||' WHERE vu.violation_id = :1 '
      ||'   AND vu.violated_by_id = u.user_id ';

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    -- fix for performance bug 4036679, G_USER_ID_LIST is valid for one constraint
    G_CST_USER_ID_LIST.DELETE();

    --05.17.2005 tsho: starting from AMW.E, store user_name in addition to user_id for use in G_AMW_USER_ROLES
    G_CST_USER_NAME_LIST.DELETE();

    IF (p_violation_id IS NOT NULL) THEN
      IF (BULK_COLLECTS_SUPPORTED) THEN
        OPEN c_user_dynamic_sql FOR l_user_reval_dynamic_sql USING
            p_violation_id;
        FETCH c_user_dynamic_sql BULK COLLECT INTO G_CST_USER_ID_LIST, G_CST_USER_NAME_LIST;
        CLOSE c_user_dynamic_sql;
      ELSE
        -- no BULK_COLLECTS_SUPPORTED
        i := 0;
        -- enable dynamic sql in AMW.C with 5.10
        OPEN c_user_dynamic_sql FOR l_user_reval_dynamic_sql USING
            p_violation_id;
        LOOP
            FETCH c_user_dynamic_sql INTO l_user_id, l_user_name;
            EXIT WHEN c_user_dynamic_sql%NOTFOUND;
            i := i+1;
            G_CST_USER_ID_LIST(i) := l_user_id;
            G_CST_USER_NAME_LIST(i) := l_user_name;
        END LOOP;
        CLOSE c_user_dynamic_sql;
      END IF; -- end of if: BULK_COLLECTS_SUPPORTED
    END IF; -- end of if: p_violation_id IS NOT NULL

END Populate_User_Id_List_For_Vlt;



-- ===============================================================
-- Private Function name
--          Create_Violation
--
-- Purpose
--          create violation in AMW_VIOLATIONS
--          against specified constraint
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--
-- Notes
--
-- ===============================================================
FUNCTION Create_Violation (
    p_constraint_rev_id IN NUMBER
) RETURN NUMBER
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Violation';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- store the violation_id getting from AMW_VIOLATION_S
l_violation_id NUMBER   := NULL;
l_row_id       VARCHAR2(32767); -- 11.17.2003 tsho: need to check out

-- store the request_id getting from FND_GLOBAL
l_request_id   NUMBER   := FND_GLOBAL.CONC_REQUEST_ID;

-- get violation_id from AMW_VIOLATION_S
CURSOR c_violation_id IS
      SELECT AMW_VIOLATION_S.NEXTVAL
      FROM dual;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    -- get violation_id from AMW_VIOLATION_S
    OPEN c_violation_id;
    FETCH c_violation_id INTO l_violation_id;
    CLOSE c_violation_id;

    AMW_VIOLATIONS_PKG.insert_row(x_rowid              =>  l_row_id,
                                  x_violation_id       =>  l_violation_id,
                                  x_constraint_rev_id  =>  p_constraint_rev_id,
                                  x_request_id         =>  l_request_id,
                                  x_request_date       =>  SYSDATE,
                                  x_requested_by_id    =>  G_PARTY_ID,
                                  x_violator_num       =>  NULL,
                                  x_status_code        =>  'NA',
                                  x_last_updated_by    =>  G_USER_ID,
                                  x_last_update_date   =>  SYSDATE,
                                  x_created_by         =>  G_USER_ID,
                                  x_creation_date      =>  SYSDATE,
                                  x_last_update_login  =>  G_LOGIN_ID,
                                  x_security_group_id  =>  G_SECURITY_GROUP_ID,
                                  x_object_version_number => 1);

    --FND_FILE.put_line(fnd_file.log,'AMW_VIOLATIONS_PKG.insert_row: l_violation_id= '||l_violation_id);

    RETURN l_violation_id;
END Create_Violation;



-- ===============================================================
-- Private Procedure name
--          Update_Violation
--
-- Purpose
--          update violation in AMW_VIOLATIONS
--          against specified violation_id and its constraint_rev_id
--
-- Params
--          p_violation_id := specified violation_id
--          p_constraint_rev_id := specified constraint_rev_id
--
-- Notes
--          this is to update the violator_num, status_code in AMW_VIOLATIONS
--          based on the conclusion from AMW_VIOLATION_USERS
--
-- History
--          01.06.2005 tsho: starting from AMW.D, consider Waivers
--          05.20.2005 tsho: starting from AMW.E, consider Revalidation
-- ===============================================================
PROCEDURE Update_Violation (
    p_violation_id      IN NUMBER,
    p_constraint_rev_id IN NUMBER,
    p_revalidate_flag   IN   VARCHAR2  := NULL
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Violation';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- store the violator_num
l_violator_num              NUMBER  := NULL;
l_violator_num_aft_reval    NUMBER  := NULL;
l_resp_violation_num        NUMBER  := NULL;

-- store the violation status (status_code), default is 'NA' (Not Applicable)
l_violation_status  VARCHAR2(30) := 'NA';
l_reval_request_id  NUMBER := NULL;
l_reval_request_date  DATE := NULL;
l_reval_requested_by_id  NUMBER := NULL;



-- 05.20.2005 tsho: store the request_id getting from FND_GLOBAL
l_request_id   NUMBER   := FND_GLOBAL.CONC_REQUEST_ID;

-- get violator_num from AMW_VIOLATION_USERS
-- 01.06.2005 tsho: starting from AMW.D, consider waivers
CURSOR c_violator_num (l_violation_id IN NUMBER) IS
    SELECT count(*)
      FROM amw_violation_users
     WHERE violation_id = l_violation_id
       AND (waived_flag is NULL OR waived_flag <> 'Y');

-- 05.20.2005 tsho: get the num of violators after revalidating this violation
CURSOR c_violator_num_aft_reval (l_violation_id IN NUMBER) IS
    SELECT count(*)
      FROM amw_violation_users
     WHERE violation_id = l_violation_id
       AND (waived_flag is NULL OR waived_flag <> 'Y')
       AND (corrected_flag is NULL OR corrected_flag <> 'Y');

CURSOR c_resp_violation_num (l_violation_id IN NUMBER) IS
    SELECT count(*)
      FROM amw_violation_resp
     WHERE violation_id = l_violation_id
       AND waived_flag = 'N'
       AND corrected_flag = 'N';

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    OPEN c_violator_num(p_violation_id);
    FETCH c_violator_num INTO l_violator_num;
    CLOSE c_violator_num;

    --05.20.2005 tsho: get the num of violators after revalidation
    OPEN c_violator_num_aft_reval(p_violation_id);
    FETCH c_violator_num_aft_reval INTO l_violator_num_aft_reval;
    CLOSE c_violator_num_aft_reval;

    OPEN c_resp_violation_num(p_violation_id);
    FETCH c_resp_violation_num INTO l_resp_violation_num;
    CLOSE c_resp_violation_num;
    -- decide violation status based on violator_num
    -- if no violator, status_code is 'C' (Closed),
    -- if has violators when first running the check, status_code is 'O' (Open)
    -- if has violators when revalidating the violation, status_code is 'R' (Revalidated)
    IF (l_violator_num = 0 OR l_violator_num_aft_reval = 0) AND l_resp_violation_num = 0  THEN
        l_violation_status := 'C';
    ELSIF ( p_revalidate_flag IS NOT NULL
          AND p_revalidate_flag = 'Y'
          AND (l_violator_num_aft_reval > 0 or l_resp_violation_num > 0) ) THEN
        l_violation_status := 'R';
    ELSE
        l_violation_status := 'O';
    END IF;

    -- 06.27.2005 tsho: only update reval columns if revalidate_flag is 'Y'
    IF (p_revalidate_flag = 'Y') THEN
        l_reval_request_id := l_request_id;
        l_reval_request_date := SYSDATE;
        l_reval_requested_by_id := G_PARTY_ID;
    END IF;

    AMW_VIOLATIONS_PKG.update_row(x_violation_id       =>  p_violation_id,
                                  x_constraint_rev_id  =>  p_constraint_rev_id,
                                  x_violator_num       =>  l_violator_num,
                                  x_status_code        =>  l_violation_status,
                                  x_last_updated_by    =>  G_USER_ID,
                                  x_last_update_date   =>  SYSDATE,
                                  x_last_update_login  =>  G_LOGIN_ID,
                                  x_security_group_id  =>  G_SECURITY_GROUP_ID,
                                  x_object_version_number => 1,
                                  x_reval_request_id      => l_reval_request_id, -- 05.20.2005 tsho: AMW.E revalidation
                                  x_reval_request_date    => l_reval_request_date,      -- 05.20.2005 tsho: AMW.E revalidation
                                  x_reval_requested_by_id => l_reval_requested_by_id    -- 05.20.2005 tsho: AMW.E revalidation
                                  );

END Update_Violation;


-- ===============================================================
-- Private Procedure name
--          Update_Violation_User
--
-- Purpose
--          update user in AMW_VIOLATION_USERS
--          against specified violation_id and violated_by_id
--
-- Params
--          p_user_violation_id := specified user_violation_id
--          p_violation_id := specified violation_id
--          p_violated_by_id := specified violated_by_id
--          p_corrected_flag := specified corrected_flag
--
-- Notes
--          this is to update the corrected_flag in AMW_VIOLATION_USERS
--
-- History
--          05.23.2005 tsho: create for AMW.E Revalidation
-- ===============================================================
PROCEDURE Update_Violation_User (
    p_user_violation_id      IN NUMBER      := NULL,
    p_violation_id           IN NUMBER,
    p_violated_by_id         IN NUMBER,
    p_corrected_flag         IN   VARCHAR2  := NULL
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Violation_User';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- store the user_violation_id
l_user_violation_id      NUMBER   := NULL;

-- get user_violation_id from AMW_VIOLATION_USERS
CURSOR c_user_violation_id (l_violation_id IN NUMBER, l_violated_by_id IN NUMBER) IS
    SELECT user_violation_id
      FROM amw_violation_users
     WHERE violation_id = l_violation_id
       AND violated_by_id = l_violated_by_id;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    IF (p_user_violation_id IS NULL) THEN
        BEGIN
            -- get user_violation_id from AMW_VIOLATION_USERS if not specified
            OPEN c_user_violation_id(p_violation_id, p_violated_by_id);
            FETCH c_user_violation_id INTO l_user_violation_id;
            CLOSE c_user_violation_id;

        EXCEPTION
            WHEN no_data_found THEN
                IF c_user_violation_id%ISOPEN THEN
                    CLOSE c_user_violation_id;
                END IF;
                --FND_FILE.put_line(fnd_file.log,'Error in cursor c_user_violation_id'||substr(SQLERRM, 1, 200));
                return;
        END;
    END IF;

    AMW_VIOLATION_USERS_PKG.UPDATE_ROW (
          x_user_violation_id   => l_user_violation_id,
          x_violation_id        => p_violation_id,
          x_violated_by_id      => p_violated_by_id,
          x_last_updated_by     => G_USER_ID,
          x_last_update_date    => SYSDATE,
          x_last_update_login   => G_USER_ID,
          x_security_group_id   => G_SECURITY_GROUP_ID,
          x_waived_flag         => null,
          x_corrected_flag      => p_corrected_flag);
    DELETE FROM AMW_VIOLAT_USER_ENTRIES
    WHERE USER_VIOLATION_ID=l_user_violation_id;

    --FND_FILE.put_line(fnd_file.log,'Came out'||L_API_NAME);
END Update_Violation_User;


-- ===============================================================
-- Private Procedure name
--          Write_To_Table
--
-- Purpose
--          Write global potential violation of specified user
--          against specified constraint
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--          p_user_id := specified user_id
--
-- Notes
--          when calling this procedure means it's gaurantee
--          the specified user has violated the specified constraint
--
--          01.10.2005 tsho: Deprecated,
--          use Write_Func_To_Table_For_User or Write_Resp_To_Table_For_User instead
-- History
--          05.17.2005 tsho: starting from AMW.E, add column: ROLE_NAME to AMW_VIOLAT_USER_ENTRIES
-- ===============================================================
Procedure Write_To_Table (
    p_violation_id      IN  NUMBER,
    p_constraint_rev_id IN  NUMBER,
    p_user_id           IN  NUMBER
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Write_To_Table';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

i   NUMBER;
l_party_id NUMBER;

-- store the user_violation_id getting from AMW_USER_VIOLATION_S
l_user_violation_id NUMBER;
l_row_id    VARCHAR2(32767); -- 11.17.2003 tsho: need to check out

-- get user_violation_id from AMW_USER_VIOLATION_S
CURSOR c_user_violation_id IS
    SELECT AMW_USER_VIOLATION_S.NEXTVAL
    FROM dual;



-- find party_id with specified user_id
-- 12.12.2003 tsho: use static sql for AMW for the time being
-- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10, but due to bug 3348191, still comment this out
/*
TYPE userCurTyp IS REF CURSOR;
c_user_dynamic_sql userCurTyp;
l_user_dynamic_sql   VARCHAR2(200)  :=
        'SELECT person_party_id '
      ||'  FROM '||G_AMW_USER
      ||' WHERE user_id = :1 ';
*/

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    -- find party_id with specified user_id
    BEGIN
        -- 12.12.2003 tsho: use static sql for AMW for the time being
        -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10, but due to bug 3348191, still comment this out
        /*
        OPEN c_user_dynamic_sql FOR l_user_dynamic_sql USING
            p_user_id;
        FETCH c_user_dynamic_sql INTO l_party_id;
        CLOSE c_user_dynamic_sql;
        */
        -- 01.02.2003 tsho: bug 3348191 - duplicated user shown
        -- because same party_id(person) maps to multiple user_id(login acct),
        -- thus store user_id directly rather party_id in AMW_VIOLATION_USERS
        /*
        SELECT person_party_id
          INTO l_party_id
          FROM FND_USER
         WHERE user_id = p_user_id;
        */
        l_party_id := p_user_id;

    EXCEPTION
        WHEN no_data_found THEN
            null;
    END;

    IF ((G_PV_FUNCTION_ID_LIST IS NULL) OR (G_PV_FUNCTION_ID_LIST.FIRST IS NULL)) THEN
        -- no potential violation for this user against this constraint
        -- don't create a record in AMW_VIOLATION_USERS
        RETURN;
    END IF;

    -- get user_violation_id from AMW_USER_VIOLATION_S
    OPEN c_user_violation_id;
    FETCH c_user_violation_id INTO l_user_violation_id;
    CLOSE c_user_violation_id;

    AMW_VIOLATION_USERS_PKG.insert_row(x_rowid              =>  l_row_id,
                                       x_user_violation_id  =>  l_user_violation_id,
                                       x_violation_id       =>  p_violation_id,
                                       x_violated_by_id     =>  l_party_id,
                                       x_last_updated_by    =>  G_USER_ID,
                                       x_last_update_date   =>  SYSDATE,
                                       x_created_by         =>  G_USER_ID,
                                       x_creation_date      =>  SYSDATE,
                                       x_last_update_login  =>  G_LOGIN_ID,
                                       x_security_group_id  =>  NULL);

    --FND_FILE.put_line(fnd_file.log,'AMW_VIOLATION_USERS_PKG.insert_row: l_user_violation_id= '|| l_user_violation_id);

    -- bulk insert to AMW_VIOLAT_USER_ENTRIES
    FORALL i IN 1 .. G_PV_FUNCTION_ID_LIST.COUNT
        INSERT INTO AMW_VIOLAT_USER_ENTRIES VALUES (
                                        SYSDATE,                        -- last_update_date
                                        G_USER_ID,                      -- last_updated_by
                                        G_LOGIN_ID,                     -- last_update_login
                                        SYSDATE,                        -- creation_date
                                        G_USER_ID,                      -- created_by
                                        NULL,                           -- security_group_id
                                        l_user_violation_id,            -- user_violation_id
                                        G_PV_RESPONSIBILITY_ID_LIST(i), -- responsibility_id
                                        G_PV_MENU_ID_LIST(i),           -- menu_id
                                        G_PV_FUNCTION_ID_LIST(i),       -- function_id
                                        G_PV_ACCESS_GIVEN_DATE_LIST(i), -- access_given_date
                                        G_PV_ACCESS_GIVEN_BY_LIST(i),   -- access_given_by_id
                                        NULL,                           -- role_name
                                        NULL,                           -- object_type
                                        G_PV_APPLICATION_ID_LIST(i),    -- application_id
                                        null);


END Write_To_Table;



-- ===============================================================
-- Private Procedure name
--          Clear_Potential_Value_List
--
-- Purpose
--          to clear the global potential value list:
--              G_PV_FUNCTION_ID_LIST
--              G_PV_MENU_ID_LIST
--              G_PV_RESPONSIBILITY_ID_LIST
--              G_PV_ACCESS_GIVEN_DATE_LIST
--              G_PV_ACCESS_GIVEN_BY_LIST
--
-- ===============================================================
PROCEDURE Clear_Potential_Value_List
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Clear_Potential_Value_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);
    G_PV_COUNT  := 1;
    G_PV_FUNCTION_ID_LIST.DELETE();
    G_PV_MENU_ID_LIST.DELETE();
    G_PV_RESPONSIBILITY_ID_LIST.DELETE();
    G_PV_APPLICATION_ID_LIST.DELETE();
    G_PV_ACCESS_GIVEN_DATE_LIST.DELETE();
    G_PV_ACCESS_GIVEN_BY_LIST.DELETE();
    G_PV_GROUP_CODE_LIST.DELETE();
    G_PV_PROGRAM_APPL_ID_LIST.DELETE();
    G_PV_OBJECT_TYPE_LIST.DELETE();

END Clear_Potential_Value_List;


-- ===============================================================
-- Private Procedure name
--          Clear_User_Potential_Value_List
--
-- Purpose
--          to clear the global potential value list:
--              G_UPV_FUNCTION_ID_LIST
--              G_UPV_MENU_ID_LIST
--              G_UPV_RESPONSIBILITY_ID_LIST
--              G_UPV_ACCESS_GIVEN_DATE_LIST
--              G_UPV_ACCESS_GIVEN_BY_LIST
--              G_UPV_ROLE_NAME_LIST
--              G_UPV_GROUP_CODE_LIST
--              G_UPV_ENTRY_OBJECT_TYPE_LIST
--
-- History
--          05.17.2005 tsho: starting from AMW.E, add handle for G_UPV_ROLE_NAME_LIST, G_UPV_GROUP_CODE_LIST
--          05.25.2005 tsho: add handle for G_UPV_ENTRY_OBJECT_TYPE_LIST (consider Concurrent Programs as constraint entries)
-- ===============================================================
PROCEDURE Clear_Usr_Potential_Value_List
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Clear_Usr_Potential_Value_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    G_UPV_COUNT  := 1;
    G_UPV_FUNCTION_ID_LIST.DELETE();
    G_UPV_MENU_ID_LIST.DELETE();
    G_UPV_RESPONSIBILITY_ID_LIST.DELETE();
    G_UPV_APPLICATION_ID_LIST.DELETE();
    G_UPV_PROGRAM_APPL_ID_LIST.delete();
    G_UPV_ACCESS_GIVEN_DATE_LIST.DELETE();
    G_UPV_ACCESS_GIVEN_BY_LIST.DELETE();
    G_UPV_ROLE_NAME_LIST.DELETE();
    G_UPV_GROUP_CODE_LIST.DELETE();
    G_UPV_ENTRY_OBJECT_TYPE_LIST.DELETE();

END Clear_Usr_Potential_Value_List;



-- ===============================================================
-- Private Procedure name
--          Check_For_Constraint_ALL
--
-- Purpose
--          for constraint type = 'ALL or None' (type_code = 'ALL')
--          check violation for specified constraint
--          this is private procedure,
--          should not call this procedure directly
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--
-- Notes
--          01.10.2005 tsho: Deprecated, use Check_For_Func_Cst_ALL instead
-- ===============================================================
PROCEDURE Check_For_Constraint_ALL (
    p_constraint_rev_id          IN   NUMBER,
    p_violation_id               IN   NUMBER
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Check_For_Constraint_ALL';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;


-- store the tmp count for g_user_id_list
i NUMBER;

-- store the tmp count for l_functions
j NUMBER;

-- store the tmp count for l_functions
k NUMBER;

-- store the tmp count for l_user_resp_id_list
m NUMBER;

-- store the test_id result
l_test_id_result    BOOLEAN;

-- store the access right
l_accessible    BOOLEAN;

-- store how many incompatible functions he can access so far
l_access_function_count    NUMBER;


TYPE NumberTable IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE DateTable  IS TABLE OF DATE INDEX BY BINARY_INTEGER;

-- find the constraint entries(incompatible functions) by specified constraint_rev_id
l_function_id_list NumberTable;
l_constraint_function_id NUMBER;
CURSOR c_constraint_entries (l_constraint_rev_id IN NUMBER) IS
      SELECT function_id
        FROM amw_constraint_entries
	   WHERE constraint_rev_id=l_constraint_rev_id;


-- find the responsibilities by specified user_id
l_user_resp_id_list NumberTable;
l_user_resp_id NUMBER;

-- find the responsibility app ids by specified user_id
l_user_resp_app_id_list NumberTable;
l_user_resp_app_id NUMBER;

-- find the access_given_dates (start_date from G_AMW_USER_RESP_GROUPS) by specified user_id
l_user_resp_start_date_list DateTable;
l_user_resp_start_date DATE;

-- find the access_given_by ids (created_by from G_AMW_USER_RESP_GROUPS) by specified user_id
l_user_resp_created_by_list NumberTable;
l_user_resp_created_by NUMBER;

-- 12.12.2003 tsho: use static sql for AMW for the time being
-- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
TYPE respCurTyp IS REF CURSOR;
user_resp_c respCurTyp;
-- 04.07.2005 tsho: bug 4145922, cosider hierarchical role assignment
/*
l_user_resp_dynamic_sql   VARCHAR2(200)  :=
        'SELECT responsibility_id, responsibility_application_id, start_date, created_by '
      ||'  FROM '||G_AMW_USER_RESP_GROUPS
      ||' WHERE user_id = :1 and (end_date >= sysdate or end_date is null)';
*/
l_user_resp_dynamic_sql   VARCHAR2(2000)  :=
        'SELECT outer.responsibility_id, outer.responsibility_application_id, outer.start_date, outer.created_by '
      ||'  FROM '||G_AMW_USER_RESP_GROUPS ||' outer '
      ||' WHERE outer.start_date = ('
      ||'         SELECT min(innter.start_date) '
      ||'           FROM '||G_AMW_USER_RESP_GROUPS ||' inner '
      ||'          WHERE inner.user_id = :1 '
      ||'            AND inner.responsibility_id = outer.responsibility_id '
      ||'            AND inner.responsibility_application_id = outer.responsibility_application_id '
      ||'            AND inner.start_date <= sysdate AND (inner.end_date >= sysdate or inner.end_date is null) '
      ||'       )';
/*
cursor get_user_resp_c(l_user_id IN NUMBER) is
    SELECT responsibility_id,
           responsibility_application_id,
           start_date,
           created_by
      from FND_USER_RESP_GROUPS
     where user_id = l_user_id
       and (end_date >= sysdate or end_date is null);
*/

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    -- if no users in g_user_id_list, then no need to go further to check constraint
    IF ((G_USER_ID_LIST IS NULL) OR (G_USER_ID_LIST.FIRST IS NULL)) THEN
        RETURN;
    END IF;


    IF (p_constraint_rev_id IS NOT NULL) THEN
        -- find the constraint entries(incompatible functions) by specified constraint_rev_id
        IF (BULK_COLLECTS_SUPPORTED) THEN
            OPEN c_constraint_entries (p_constraint_rev_id);
            FETCH c_constraint_entries BULK COLLECT INTO l_function_id_list;
            CLOSE c_constraint_entries;
        ELSE
            -- no BULK_COLLECTS_SUPPORTED
            j := 0;
            OPEN c_constraint_entries (p_constraint_rev_id);
            LOOP
                FETCH c_constraint_entries INTO l_constraint_function_id;
                EXIT WHEN c_constraint_entries%NOTFOUND;
                j := j+1;
                l_function_id_list(j) := l_constraint_function_id;
            END LOOP;
            CLOSE c_constraint_entries;
        END IF; -- end of if: BULK_COLLECTS_SUPPORTED


        -- passed-in p_constraint_rev_id doesn't have at least 2 incompatible functions defined
        IF (l_function_id_list.COUNT < 2) THEN
            RETURN;
        END IF;


        -- constraint type is 'All or None'
        BEGIN
            -- for each user
            FOR i IN 1 .. G_USER_ID_LIST.COUNT
            LOOP
                --FND_FILE.put_line(fnd_file.log,'******* G_USER_ID_LIST('||i||') '||G_USER_ID_LIST(i)||' ******');
                -- clear potential violation info (valid for one user against one constraint)
                Clear_Potential_Value_List ();

                -- get user(usre i)'s responsibilities
                IF (BULK_COLLECTS_SUPPORTED) THEN
                    -- 12.12.2003 tsho: use static sql for AMW for the time being
                    -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
                    OPEN user_resp_c FOR l_user_resp_dynamic_sql USING
                        G_USER_ID_LIST(i);
                    FETCH user_resp_c BULK COLLECT INTO l_user_resp_id_list,
                                                        l_user_resp_app_id_list,
                                                        l_user_resp_start_date_list,
                                                        l_user_resp_created_by_list;
                    CLOSE user_resp_c;
                    /*
                    SELECT responsibility_id,
                           responsibility_application_id,
                           start_date,
                           created_by
                    BULK COLLECT INTO l_user_resp_id_list,
                                      l_user_resp_app_id_list,
                                      l_user_resp_start_date_list,
                                      l_user_resp_created_by_list
                    FROM FND_USER_RESP_GROUPS
                    WHERE user_id = G_USER_ID_LIST(i)
                      AND (end_date >= sysdate or end_date is null);
                    */

                ELSE
                    -- no BULK_COLLECTS_SUPPORTED
                    j := 0;
                    -- 12.12.2003 tsho: use static sql for AMW for the time being
                    -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
                    OPEN user_resp_c FOR l_user_resp_dynamic_sql USING
                        G_USER_ID_LIST(i);
                    LOOP
                        FETCH user_resp_c INTO l_user_resp_id,
                                               l_user_resp_app_id,
                                               l_user_resp_start_date,
                                               l_user_resp_created_by;
                        EXIT WHEN user_resp_c%NOTFOUND;
                        j := j+1;
                        l_user_resp_id_list(j) := l_user_resp_id;
                        l_user_resp_app_id_list(j) := l_user_resp_app_id;
                        l_user_resp_start_date_list(j) := l_user_resp_start_date;
                        l_user_resp_created_by_list(j) := l_user_resp_created_by;
                    END LOOP;
                    CLOSE user_resp_c;
                    /*
                    for rec in get_user_resp_c(G_USER_ID_LIST(i)) loop
                        j := j + 1;
                        l_user_resp_id_list(j) := rec.responsibility_id;
                        l_user_resp_app_id_list(j) := rec.responsibility_application_id;
                        l_user_resp_start_date_list(j) := rec.start_date;
                        l_user_resp_created_by_list(j) := rec.created_by;
                    end loop;
                    */
                END IF; -- end of if: BULK_COLLECTS_SUPPORTED


                -- check if he(user i) has access to function k
                l_access_function_count := 0;
                -- 05.07.2004 tsho, bug 3616058, only one function shown under user as violation, move l_accessible := FALSE to be inside of funciton Loop
                --l_accessible := FALSE;
                FOR k IN 1 .. l_function_id_list.COUNT
                LOOP
                    -- 05.07.2004 tsho, bug 3616058, only one function shown under user as violation, move l_accessible := FALSE to be inside of funciton Loop
                    l_accessible := FALSE;

                    --FND_FILE.put_line(fnd_file.log,'----------- l_function_id_list('||k||') '||l_function_id_list(k)||' --------');
                    -- test function id under user(user i)'s all responsibilities
                    -- l_accessible will become TRUE as long as at least one of his responsibility can access this function
                    FOR m IN 1 .. l_user_resp_id_list.COUNT
                    LOOP
                        --FND_FILE.put_line(fnd_file.log,'............. l_user_resp_id_list('||m||') '||l_user_resp_id_list(m)||' .........');
                        l_test_id_result := TEST_ID(function_id => l_function_id_list(k),
                                                    p_appl_id   => l_user_resp_app_id_list(m),
                                                    p_resp_id   => l_user_resp_id_list(m),
                                                    p_access_given_date => l_user_resp_start_date_list(m),
                                                    p_access_given_by   => l_user_resp_created_by_list(m));
                        l_accessible := l_accessible OR l_test_id_result;
                        IF (l_test_id_result) THEN
                            --FND_FILE.put_line(fnd_file.log,'............. l_test_id_result = TRUE ');
                            -- if TEST_ID result(final decision) has access right to function k under responsibility m,
                            --FND_FILE.put_line(fnd_file.log,'............. G_PV_COUNT = '||G_PV_COUNT);
                            G_PV_FUNCTION_ID_LIST(G_PV_COUNT) := G_PV_FUNCTION_ID;
                            G_PV_MENU_ID_LIST(G_PV_COUNT) := G_PV_MENU_ID;
                            G_PV_RESPONSIBILITY_ID_LIST(G_PV_COUNT) := G_PV_RESPONSIBILITY_ID;
                            G_PV_ACCESS_GIVEN_DATE_LIST(G_PV_COUNT) := G_PV_ACCESS_GIVEN_DATE;
                            G_PV_ACCESS_GIVEN_BY_LIST(G_PV_COUNT) := G_PV_ACCESS_GIVEN_BY;
                            --FND_FILE.put_line(fnd_file.log,'............. G_PV_FUNCTION_ID_LIST(G_PV_FUNCTION_ID_LIST.COUNT) = '||G_PV_FUNCTION_ID_LIST(G_PV_FUNCTION_ID_LIST.COUNT));
                            G_PV_COUNT := G_PV_COUNT +1;
                        END IF;
                    END LOOP; -- end of loop: l_user_resp_id_list

                    IF (NOT l_accessible) THEN
                        -- in 'ALL' constraint type,
                        -- if he(user i) doesn't have access(after check for all his responsibilities) to one function,
                        -- then he doesn't violat this constraint. exit to check for next user(user i+1)
                        --FND_FILE.put_line(fnd_file.log,'............. l_accessible = FALSE ');
                        EXIT;
                    ELSE
                        --FND_FILE.put_line(fnd_file.log,'............. l_accessible = TRUE ');
                        l_access_function_count := l_access_function_count+1;
                    END IF;

                END LOOP; -- end of loop: l_function_id_list

                IF (l_access_function_count < l_function_id_list.COUNT) THEN
                    -- user(user i) doesn't have access rights to all the incompatible functions defined in this constraint,
                    -- it's garuanteed he doesn't violate this constraint
                    --FND_FILE.put_line(fnd_file.log,'............. l_access_function_count < '||l_function_id_list.COUNT);
                    null;
                ELSE
                    -- write potential violation info to table
                    --FND_FILE.put_line(fnd_file.log,'............. l_access_function_count >= '||l_function_id_list.COUNT);
                    Write_To_Table(p_violation_id, p_constraint_rev_id, G_USER_ID_LIST(i));
                END IF;

            END LOOP; -- end of loop: G_USER_ID_LIST

        EXCEPTION
            WHEN others THEN
                --FND_FILE.put_line(fnd_file.log,'............. exception ...........');
                RAISE;
        END;

    END IF; -- end of if: p_constraint_rev_id IS NOT NULL

END Check_For_Constraint_ALL;





-- ===============================================================
-- Private Procedure name
--          Check_For_Constraint_ME
--
-- Purpose
--          for constraint type = 'Mutual Exclusive' (type_code = 'ME')
--          check violation for specified constraint
--          this is private procedure,
--          should not call this procedure directly
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--
-- Notes
--          01.10.2005 tsho: Deprecated, use Check_For_Func_Cst_ME instead
-- ===============================================================
PROCEDURE Check_For_Constraint_ME (
    p_constraint_rev_id          IN   NUMBER,
    p_violation_id               IN   NUMBER
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Check_For_Constraint_ME';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- store the tmp count for g_user_id_list
i NUMBER;

-- store the tmp count for l_functions
j NUMBER;

-- store the tmp count for l_functions
k NUMBER;

-- store the tmp count for l_user_resp_id_list
m NUMBER;

-- store the test_id result
l_test_id_result    BOOLEAN;

-- store the access right
l_accessible    BOOLEAN;

-- store how many incompatible functions he can access so far
l_access_function_count    NUMBER;


TYPE NumberTable IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE DateTable  IS TABLE OF DATE INDEX BY BINARY_INTEGER;

-- find the constraint entries(incompatible functions) by specified constraint_rev_id
l_function_id_list NumberTable;
l_constraint_function_id NUMBER;
CURSOR c_constraint_entries (l_constraint_rev_id IN NUMBER) IS
      SELECT function_id
        FROM amw_constraint_entries
	   WHERE constraint_rev_id=l_constraint_rev_id;


-- find the responsibilities by specified user_id
l_user_resp_id_list NumberTable;
l_user_resp_id NUMBER;

-- find the responsibility app ids by specified user_id
l_user_resp_app_id_list NumberTable;
l_user_resp_app_id NUMBER;

-- find the access_given_dates (start_date from G_AMW_USER_RESP_GROUPS) by specified user_id
l_user_resp_start_date_list DateTable;
l_user_resp_start_date DATE;

-- find the access_given_by ids (created_by from G_AMW_USER_RESP_GROUPS) by specified user_id
l_user_resp_created_by_list NumberTable;
l_user_resp_created_by NUMBER;

-- 12.12.2003 tsho: use static sql for AMW for the time being
-- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
TYPE respCurTyp IS REF CURSOR;
user_resp_c respCurTyp;
-- 04.07.2005 tsho: bug 4145922, cosider hierarchical role assignment
/*
l_user_resp_dynamic_sql   VARCHAR2(200)  :=
        'SELECT responsibility_id, responsibility_application_id, start_date, created_by '
      ||'  FROM '||G_AMW_USER_RESP_GROUPS
      ||' WHERE user_id = :1 and (end_date >= sysdate or end_date is null)';
*/
l_user_resp_dynamic_sql   VARCHAR2(2000)  :=
        'SELECT outer.responsibility_id, outer.responsibility_application_id, outer.start_date, outer.created_by '
      ||'  FROM '||G_AMW_USER_RESP_GROUPS ||' outer '
      ||' WHERE outer.start_date = ('
      ||'         SELECT min(innter.start_date) '
      ||'           FROM '||G_AMW_USER_RESP_GROUPS ||' inner '
      ||'          WHERE inner.user_id = :1 '
      ||'            AND inner.responsibility_id = outer.responsibility_id '
      ||'            AND inner.responsibility_application_id = outer.responsibility_application_id '
      ||'            AND inner.start_date <= sysdate AND (inner.end_date >= sysdate or inner.end_date is null) '
      ||'       )';
/*
cursor get_user_resp_c(l_user_id IN NUMBER) is
    SELECT responsibility_id,
           responsibility_application_id,
           start_date,
           created_by
      from FND_USER_RESP_GROUPS
     where user_id = l_user_id
       and (end_date >= sysdate or end_date is null);
*/

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    -- if no users in g_user_id_list, then no need to go further to check constraint
    IF ((G_USER_ID_LIST IS NULL) OR (G_USER_ID_LIST.FIRST IS NULL)) THEN
        RETURN;
    END IF;


    IF (p_constraint_rev_id IS NOT NULL) THEN
        -- find the constraint entries(incompatible functions) by specified constraint_rev_id
        IF (BULK_COLLECTS_SUPPORTED) THEN
            OPEN c_constraint_entries (p_constraint_rev_id);
            FETCH c_constraint_entries BULK COLLECT INTO l_function_id_list;
            CLOSE c_constraint_entries;
        ELSE
            -- no BULK_COLLECTS_SUPPORTED
            j := 0;
            OPEN c_constraint_entries (p_constraint_rev_id);
            LOOP
                FETCH c_constraint_entries INTO l_constraint_function_id;
                EXIT WHEN c_constraint_entries%NOTFOUND;
                j := j+1;
                l_function_id_list(j) := l_constraint_function_id;
            END LOOP;
            CLOSE c_constraint_entries;
        END IF; -- end of if: BULK_COLLECTS_SUPPORTED


        -- passed-in p_constraint_rev_id doesn't have at least 2 incompatible functions defined
        IF (l_function_id_list.COUNT < 2) THEN
            RETURN;
        END IF;


        -- constraint type is 'All or None'
        BEGIN
            -- for each user
            FOR i IN 1 .. G_USER_ID_LIST.COUNT
            LOOP
                -- clear potential violation info (valid for one user against one constraint)
                Clear_Potential_Value_List ();

                -- get user(usre i)'s responsibilities
                IF (BULK_COLLECTS_SUPPORTED) THEN
                    -- 12.12.2003 tsho: use static sql for AMW for the time being
                    -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
                    OPEN user_resp_c FOR l_user_resp_dynamic_sql USING
                        G_USER_ID_LIST(i);
                    FETCH user_resp_c BULK COLLECT INTO l_user_resp_id_list,
                                                        l_user_resp_app_id_list,
                                                        l_user_resp_start_date_list,
                                                        l_user_resp_created_by_list;
                    CLOSE user_resp_c;
                    /*
                    SELECT responsibility_id,
                           responsibility_application_id,
                           start_date,
                           created_by
                    BULK COLLECT INTO l_user_resp_id_list,
                                      l_user_resp_app_id_list,
                                      l_user_resp_start_date_list,
                                      l_user_resp_created_by_list
                    FROM FND_USER_RESP_GROUPS
                    WHERE user_id = G_USER_ID_LIST(i)
                      AND (end_date >= sysdate or end_date is null);
                    */

                ELSE
                    -- no BULK_COLLECTS_SUPPORTED
                    j := 0;
                    -- 12.12.2003 tsho: use static sql for AMW for the time being
                    -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
                    OPEN user_resp_c FOR l_user_resp_dynamic_sql USING
                        G_USER_ID_LIST(i);
                    LOOP
                        FETCH user_resp_c INTO l_user_resp_id,
                                               l_user_resp_app_id,
                                               l_user_resp_start_date,
                                               l_user_resp_created_by;
                        EXIT WHEN user_resp_c%NOTFOUND;
                        j := j+1;
                        l_user_resp_id_list(j) := l_user_resp_id;
                        l_user_resp_app_id_list(j) := l_user_resp_app_id;
                        l_user_resp_start_date_list(j) := l_user_resp_start_date;
                        l_user_resp_created_by_list(j) := l_user_resp_created_by;
                    END LOOP;
                    CLOSE user_resp_c;
                    /*
                    for rec in get_user_resp_c(G_USER_ID_LIST(i)) loop
                        j := j + 1;
                        l_user_resp_id_list(j) := rec.responsibility_id;
                        l_user_resp_app_id_list(j) := rec.responsibility_application_id;
                        l_user_resp_start_date_list(j) := rec.start_date;
                        l_user_resp_created_by_list(j) := rec.created_by;
                    end loop;
                    */

                END IF; -- end of if: BULK_COLLECTS_SUPPORTED


                -- check if he(user i) has access to function k
                l_access_function_count := 0;
                -- 05.07.2004 tsho, bug 3616058, only one function shown under user as violation, move l_accessible := FALSE to be inside of funciton Loop
                --l_accessible := FALSE;
                FOR k IN 1 .. l_function_id_list.COUNT
                LOOP
                    -- 05.07.2004 tsho, bug 3616058, only one function shown under user as violation, move l_accessible := FALSE to be inside of funciton Loop
                    l_accessible := FALSE;

                    -- test function id under user(user i)'s all responsibilities
                    -- l_accessible will become TRUE as long as at least one of his responsibility can access this function
                    FOR m IN 1 .. l_user_resp_id_list.COUNT
                    LOOP
                        l_test_id_result := TEST_ID(function_id => l_function_id_list(k),
                                                    p_appl_id   => l_user_resp_app_id_list(m),
                                                    p_resp_id   => l_user_resp_id_list(m),
                                                    p_access_given_date => l_user_resp_start_date_list(m),
                                                    p_access_given_by   => l_user_resp_created_by_list(m));
                        l_accessible := l_accessible OR l_test_id_result;

                        IF (l_test_id_result) THEN
                            -- if TEST_ID result(final decision) has access right to function k under responsibility m,
                            G_PV_FUNCTION_ID_LIST(G_PV_COUNT) := G_PV_FUNCTION_ID;
                            G_PV_MENU_ID_LIST(G_PV_COUNT) := G_PV_MENU_ID;
                            G_PV_RESPONSIBILITY_ID_LIST(G_PV_COUNT) := G_PV_RESPONSIBILITY_ID;
                            G_PV_ACCESS_GIVEN_DATE_LIST(G_PV_COUNT) := G_PV_ACCESS_GIVEN_DATE;
                            G_PV_ACCESS_GIVEN_BY_LIST(G_PV_COUNT) := G_PV_ACCESS_GIVEN_BY;
                            --FND_FILE.put_line(fnd_file.log,'............. G_PV_FUNCTION_ID_LIST(G_PV_FUNCTION_ID_LIST.COUNT) = '||G_PV_FUNCTION_ID_LIST(G_PV_FUNCTION_ID_LIST.COUNT));
                            G_PV_COUNT := G_PV_COUNT +1;
                        END IF;

                    END LOOP; -- end of loop: l_user_resp_id_list

                    IF (l_accessible) THEN
                        -- in 'ME' constraint type,
                        -- for each function(function k), after check for all his(user i) responsibilities,
                        -- if l_accessible=TRUE, add 1 to l_access_function_count
                        -- the user(user i) violates this constraint if l_access_function_count >= 2
                        l_access_function_count := l_access_function_count+1;
                    END IF;

                END LOOP; -- end of loop: l_function_id_list

                IF (l_access_function_count >= 2) THEN
                    -- now it's gauranteed user i has violated this constraint
                    -- write potential violation info to table
                    Write_To_Table(p_violation_id, p_constraint_rev_id, G_USER_ID_LIST(i));
                ELSE
                    null; -- now it's gauranteed user i doesn't violate this constraint
                END IF;

            END LOOP; -- end of loop: G_USER_ID_LIST

        EXCEPTION
            WHEN others THEN
                NULL;
        END;

    END IF; -- end of if: p_constraint_rev_id IS NOT NULL

END Check_For_Constraint_ME;


-- ===============================================================
-- Function name
--          Populate_Ptnl_Resps_For_Cst
-- Purpose
--          populate the global potential responsibility id list by specified constraint_rev_id,
--          populate the global corresponding application id list
-- Params
--          p_constraint_rev_id   := specified constraint_rev_id
--
-- Notes
--          12.21.2004 tsho: fix for performance bug 4036679
--          the returned potential responsibility id list includes the responsibility
--          which contains those functions excluded from it.
--          (ie, exclusion is not considered here)
-- History
--          05.25.2005 tsho: starting from AMW.E,consider Concurrent Programs as constraint entries
-- ===============================================================
Procedure Populate_Ptnl_Resps_For_Cst (
    p_constraint_rev_id   IN  NUMBER
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Populate_Ptnl_Resps_For_Cst';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

l_resp_id NUMBER;
l_appl_id NUMBER;
l_menu_id NUMBER;

-- store the tmp count for l_resp_id_list
j NUMBER;

-- enable dynamic sql in AMW.C with 5.10
TYPE respCurTyp IS REF CURSOR;
resp_c respCurTyp;

-- This query fetches the reponsibilities that have access to the incompatible functions only.
l_resp_dynamic_sql   VARCHAR2(2000)  :=
    'SELECT  DISTINCT resp.responsibility_id, '
    ||'        resp.application_id, '
    ||'        resp.menu_id, '
    ||'        ce.function_id, '
    ||'        ce.group_code '
    ||' FROM    AMW_CONSTRAINT_ENTRIES ce, '
    ||'        '||G_AMW_COMPILED_MENU_FUNCTIONS||' cmf, '
    ||'        '||G_AMW_RESPONSIBILITY||' resp '
    ||' WHERE   ce.CONSTRAINT_REV_ID = :1 '
    ||' AND     (ce.OBJECT_TYPE is null OR ce.OBJECT_TYPE = ''FUNC'') '
    ||' AND     cmf.function_id=ce.FUNCTION_ID '
    ||' AND     cmf.grant_flag = ''Y'' '
    ||' AND     resp.menu_id = cmf.menu_id '
    ||' AND     resp.start_date <= sysdate '
    ||' AND    (resp.end_date >= sysdate or resp.end_date is null) ';

    listkey VARCHAR2(30):=NULL;
    L_FUNC_ID_LIST G_FUNC_TABLE;
    L_RESPVIO_ENTRIES G_RESPVIO_ENTRIES_TABLE;
    counts NUMBER;


BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    -- clear global potential responsiblity id list and corresponding applicaiton id, menu id list (valid for one constraint)
    G_PNTL_RESP_ID_LIST.DELETE();
    G_PNTL_APPL_ID_LIST.DELETE();
    G_PNTL_MENU_ID_LIST.DELETE();
    G_PNTL_FUNCTION_ID_LIST.DELETE();
    G_PNTL_GRP_CODE_LIST.DELETE();
    G_PNTL_RESP_VIO_LIST.DELETE();

    OPEN resp_c FOR l_resp_dynamic_sql USING
         p_constraint_rev_id;
    FETCH resp_c
    BULK COLLECT INTO G_PNTL_RESP_ID_LIST,
                      G_PNTL_APPL_ID_LIST,
                      G_PNTL_MENU_ID_LIST,
                      G_PNTL_FUNCTION_ID_LIST,
                      G_PNTL_GRP_CODE_LIST;
    CLOSE resp_c;

    -- psomanat : 06:09:2006 : fix for bug 5256720
    -- The resultset of the above query is fetched into individual List.
    -- A responsibility can have more than one incompatible function.
    -- We need to verify if the incompatible function is excluded by function exclusion
    -- or menu exclusion.
    -- The Populate_Ptnl_Access_List,PROCESS_MENU_TREE_DOWN_FOR_MN proceedures of
    -- amwvcstb.pls 120.23 version takes each incompatible function individaully
    -- and checks if the function is excluded via function or menu exclusion.This
    -- makes the process very slow.
    -- To make the process fast, we collect the incompatible functions accessable
    -- via a responsibility in a plsql data structure and collectively check
    -- if the incompatible functions are excluded via function or menu exclusion
    -- from the responsibility.
    -- The PLSQL Data Structure is like this
    --           Responsibility
    --                   |______Function_Id
    --                   |              |________Function Details Record
    --                   |              |________Function Details Record
    --                   |
    --                   |______Function_Id
    --                   |              |________Function Details Record
    --                   |              |________Function Details Record
    --                   |______Function_Id
    --                   |              |________Function Details Record
    --                   |              |________Function Details Record
    --
    --
    -- So a responsibility can have n number of function ids.
    -- A responsibility is identified by application_id and responsibility_id
    -- So we use application_id@responsibility_id as key for the Responsibility
    -- Nested table.
    -- A function can be from set 1 and set 2. The each incompatible function
    -- detail is stored as a plsql record under the function id.
    IF ((G_PNTL_RESP_ID_LIST IS NOT NULL) AND (G_PNTL_RESP_ID_LIST.FIRST IS NOT NULL)) THEN
        FOR i in G_PNTL_RESP_ID_LIST.FIRST .. G_PNTL_RESP_ID_LIST.LAST
        LOOP
            L_FUNC_ID_LIST.DELETE();
            L_RESPVIO_ENTRIES.DELETE();

            listkey := G_PNTL_APPL_ID_LIST(i)||'@'||G_PNTL_RESP_ID_LIST(i);
            IF G_PNTL_RESP_VIO_LIST.EXISTS(listkey) THEN
                L_FUNC_ID_LIST := G_PNTL_RESP_VIO_LIST(listkey);
                IF L_FUNC_ID_LIST.EXISTS(G_PNTL_FUNCTION_ID_LIST(i)) THEN
                    L_RESPVIO_ENTRIES := L_FUNC_ID_LIST(G_PNTL_FUNCTION_ID_LIST(i));
                END IF;
            END IF;

            counts := L_RESPVIO_ENTRIES.COUNT+1;
            L_RESPVIO_ENTRIES(counts).application_id     := G_PNTL_APPL_ID_LIST(i);
            L_RESPVIO_ENTRIES(counts).Responsibility_id  := G_PNTL_RESP_ID_LIST(i);
            L_RESPVIO_ENTRIES(counts).Function_Id        := G_PNTL_FUNCTION_ID_LIST(i);
            L_RESPVIO_ENTRIES(counts).group_code         := G_PNTL_GRP_CODE_LIST(i);
            L_RESPVIO_ENTRIES(counts).Menu_id            := G_PNTL_MENU_ID_LIST(i);
            L_RESPVIO_ENTRIES(counts).Access_Given_Date  := NULL;
            L_RESPVIO_ENTRIES(counts).Access_Given_By_Id := NULL;
            L_RESPVIO_ENTRIES(counts).Object_Type        := NULL;
            L_RESPVIO_ENTRIES(counts).prog_appl_id       := NULL;
            L_RESPVIO_ENTRIES(counts).Role_Name          := NULL;
            L_FUNC_ID_LIST(G_PNTL_FUNCTION_ID_LIST(i))   := L_RESPVIO_ENTRIES;
            G_PNTL_RESP_VIO_LIST(listkey) := L_FUNC_ID_LIST;
        END LOOP;
    END IF;

    -- Clearing the List
    G_PNTL_RESP_ID_LIST.DELETE();
    G_PNTL_APPL_ID_LIST.DELETE();
    G_PNTL_MENU_ID_LIST.DELETE();
    G_PNTL_FUNCTION_ID_LIST.DELETE();
    G_PNTL_GRP_CODE_LIST.DELETE();
END Populate_Ptnl_Resps_For_Cst;



-- ===============================================================
-- Procedure name
--          Populate_Ptnl_Access_List
--
-- Purpose
--          populate the global potential responsibility id list
--          populate the global potential menu id list
--          populate the global potential function id list
--
-- Notes
--          12.21.2004 tsho: fix for performance bug 4036679
-- History
--          05.24.2005 tsho: AMW.E Incompatible Sets,
--          need to record amw_constraint_entries.group_code for each item
--          05.25.2005 tsho: consider Concurrent Programs as constraint entries
-- ===============================================================
Procedure Populate_Ptnl_Access_List (
    p_constraint_rev_id          IN   NUMBER
)
IS

    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Populate_Ptnl_Access_List';
    L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

    -- store the access right
    l_accessible    BOOLEAN;

TYPE cpRespCurTyp IS REF CURSOR;
cp_resp_c cpRespCurTyp;

-- This query identifies the responsibilities having access to the concurrent program
-- defined as incompatible function in a constraint
l_cp_resp_dynamic_sql   VARCHAR2(2000)  :=
      ' SELECT  RESP.APPLICATION_ID, '
    ||'         RESP.RESPONSIBILITY_ID, '
    ||'         RESP.REQUEST_GROUP_ID MENU_ID, '
    ||'         ACE.FUNCTION_ID, '
    ||'         ACE.OBJECT_TYPE, '
    ||'         ACE.APPLICATION_ID, '
    ||'         ACE.GROUP_CODE, '
    ||'         RGU.CREATION_DATE ACCESS_GIVEN_DATE, '
    ||'         RGU.CREATED_BY ACCESS_GIVEN_BY '
    ||' FROM    '||G_AMW_RESPONSIBILITY||' RESP, '
    ||'         '||G_AMW_REQUEST_GROUP_UNITS||' RGU, '
    ||'         AMW_CONSTRAINT_ENTRIES ACE '
    ||' WHERE   RESP.GROUP_APPLICATION_ID IS NOT NULL '
    ||' AND     RESP.REQUEST_GROUP_ID IS NOT NULL '
    ||' AND     RGU.REQUEST_UNIT_TYPE = ''P'' '
    ||' AND     ACE.OBJECT_TYPE=''CP'' '
    ||' AND     ACE.CONSTRAINT_REV_ID=:1 '
    ||' AND     RESP.GROUP_APPLICATION_ID=RGU.APPLICATION_ID '
    ||' AND     RESP.REQUEST_GROUP_ID=RGU.REQUEST_GROUP_ID '
    ||' AND     RGU.UNIT_APPLICATION_ID=ACE.APPLICATION_ID '
    ||' AND     RGU.REQUEST_UNIT_ID=ACE.FUNCTION_ID '
    ||' AND     RESP.START_DATE<=SYSDATE AND (RESP.END_DATE>= SYSDATE or RESP.END_DATE IS NULL) '
    ||' UNION ALL '
    ||' SELECT   RESP.APPLICATION_ID, '
    ||'          RESP.RESPONSIBILITY_ID, '
    ||'          RESP.REQUEST_GROUP_ID MENU_ID, '
    ||'          ACE.FUNCTION_ID, '
    ||'          ACE.OBJECT_TYPE, '
    ||'          ACE.APPLICATION_ID, '
    ||'          ACE.GROUP_CODE, '
    ||'          RGU.CREATION_DATE ACCESS_GIVEN_DATE, '
    ||'          RGU.CREATED_BY ACCESS_GIVEN_BY '
    ||'  FROM    '||G_AMW_RESPONSIBILITY||' RESP , '
    ||'          '||G_AMW_REQUEST_GROUP_UNITS||' RGU, '
    ||'          AMW_CONSTRAINT_ENTRIES ACE, '
    ||'          '||G_AMW_CONCURRENT_PROGRAMS_VL||' CON '
    ||'  WHERE   RESP.GROUP_APPLICATION_ID IS NOT NULL '
    ||'  AND     RESP.REQUEST_GROUP_ID IS NOT NULL '
    ||'  AND     RGU.REQUEST_UNIT_TYPE = ''A'' '
    ||'  AND     ACE.OBJECT_TYPE=''CP'' '
    ||'  AND     ACE.CONSTRAINT_REV_ID=:2 '
    ||'  AND     RESP.GROUP_APPLICATION_ID=RGU.APPLICATION_ID '
    ||'  AND     RESP.REQUEST_GROUP_ID=RGU.REQUEST_GROUP_ID '
    ||'  AND     RGU.UNIT_APPLICATION_ID=ACE.APPLICATION_ID '
    ||'  AND     RGU.REQUEST_UNIT_ID=ACE.APPLICATION_ID '
    ||'  AND     RGU.UNIT_APPLICATION_ID=CON.APPLICATION_ID '
    ||'  AND     CON.CONCURRENT_PROGRAM_ID = ACE.FUNCTION_ID '
    ||'  AND     RESP.START_DATE<=SYSDATE AND (RESP.END_DATE>= SYSDATE or RESP.END_DATE IS NULL)' ;

-- enable dynamic sql in AMW.C with 5.10
TYPE exclFuncCurTyp IS REF CURSOR;
excl_func_c exclFuncCurTyp;
-- This Query gets all the function exclusions for a given responsibility.
l_excl_func_dynamic_sql   VARCHAR2(1000)  :=
      'SELECT action_id '
    ||'  FROM '||G_AMW_RESP_FUNCTIONS
    ||' WHERE application_id = :1 '
    ||'   AND responsibility_id = :2 '
    ||'   AND rule_type = ''F'' ';

  -- psomanat : 06:09:2006 : fix for bug 5256720
  L_RESPVIO_ENTRIES G_RESPVIO_ENTRIES_TABLE;
  L_FUNC_ID_LIST    G_FUNC_TABLE;
  counts             Number;
  lkey VARCHAR2(30) := NULL;
  listkey VARCHAR2(30) := NULL;
  l_excl_func_id_list G_NUMBER_TABLE;
  l_excl_func_list G_NUMBER_TABLE;
  l_resp_id NUMBER;
  l_appl_id NUMBER;
  l_menu_id NUMBER;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);
    --FND_FILE.put_line(fnd_file.log,'Populate_Ptnl_Access_List Began '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));

    -- psomanat : 06:09:2006 : fix for bug 5256720
    G_RESP_VIOLATIONS_LIST.delete();
    l_accessible := FALSE;

    -- psomanat : 06:09:2006 : fix for bug 5256720
    IF (p_constraint_rev_id IS NULL) THEN
        Return;
    END IF;

    -- populate global potential responsibility id and corresponding application id list for this constraint_rev_id
    Populate_Ptnl_Resps_For_Cst(p_constraint_rev_id => p_constraint_rev_id);

    -- clear potential violation info (valid for one constraint)
    Clear_Potential_Value_List();

    -- FND_FILE.put_line(fnd_file.log,'cp_resp_c Began '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));
    -- Identify the Responsibilities having access to the concurrent
    -- program specified as incompatible function in the constraint.
    OPEN cp_resp_c FOR l_cp_resp_dynamic_sql USING p_constraint_rev_id,p_constraint_rev_id;
    FETCH cp_resp_c
    BULK COLLECT INTO   G_PV_APPLICATION_ID_LIST,
                        G_PV_RESPONSIBILITY_ID_LIST,
                        G_PV_MENU_ID_LIST,
                        G_PV_FUNCTION_ID_LIST,
                        G_PV_OBJECT_TYPE_LIST,
                        G_PV_PROGRAM_APPL_ID_LIST,
                        G_PV_GROUP_CODE_LIST,
                        G_PV_ACCESS_GIVEN_DATE_LIST,
                        G_PV_ACCESS_GIVEN_BY_LIST;
    CLOSE cp_resp_c;

    -- psomanat : 06:09:2006 : fix for bug 5256720
    -- The resultset of the above query is fetched into individual Nested Table.
    -- A responsibility can have access to more than one incompatible function.
    -- The Check_For_Func_Cst_XXXXX proceedures of amwvcstb.pls 120.23 version
    -- uses these individual nested table to identify the functions accessible
    -- by a responsibility. To do this it iterate over the G_PV_RESPONSIBILITY_ID_LIST
    -- to check if the responsibility exist and if it exists , it checks the
    -- G_PV_FUNCTION_ID_LIST to get the incompatible function.
    -- This process consumes lot of time.
    --
    -- So in order to avoide this unneccessary looping we store the date from
    -- the individual list into a PLSQL Data Structure is like this
    --           Responsibility
    --                   |______Function_Id
    --                   |              |________Function Details Record
    --                   |              |________Function Details Record
    --                   |
    --                   |______Function_Id
    --                   |              |________Function Details Record
    --                   |              |________Function Details Record
    --                   |______Function_Id
    --                   |              |________Function Details Record
    --                   |              |________Function Details Record
    --
    --
    -- So a responsibility can have n number of function ids.
    -- A responsibility is identified by application_id and responsibility_id
    -- So we use application_id@responsibility_id as key for the Responsibility
    -- Nested table.
    -- The each incompatible function detail is stored as a plsql record under
    -- the function id.
    -- The advantages of plsql data structure are
    --     1. Now the responsibility id + application id acts as an index to
    --        get all the incompatible functions
    --     2. The unneccesary looping is avoided
    --     3. The same data structure is used in mutiple proceedures, so we
    --        reduce the time take to get the required data by just passing the
    --        required keys.
    IF (G_PV_RESPONSIBILITY_ID_LIST IS NOT NULL) AND (G_PV_RESPONSIBILITY_ID_LIST.FIRST IS NOT NULL) THEN
        FOR i in 1 .. G_PV_RESPONSIBILITY_ID_LIST.COUNT
        LOOP
            L_FUNC_ID_LIST.delete();
            L_RESPVIO_ENTRIES.delete();

            -- To identify a responsibility we need application id and responsibility.
            -- So the key is like application_id@responsibility_id
            listkey :=G_PV_APPLICATION_ID_LIST(i)||'@'||G_PV_RESPONSIBILITY_ID_LIST(i);

            -- Here we check if the responsibility allready exists in G_RESP_VIOLATIONS_LIST.
            -- If Yes, we get the function list
            --    check if the function list contains the concurrent program id refered by
            --    G_PV_FUNCTION_ID_LIST(i)
            --    If yes, we get the responsibility violation plsql record and
            --       add a new record to the existing records
            -- End
            -- Note : when any of the check fails, the corresponding NestedTable entry
            --        or plsql entry is newly created and added to the main G_RESP_VIOLATIONS_LIST
            IF (G_RESP_VIOLATIONS_LIST.EXISTS(listkey)) THEN
                L_FUNC_ID_LIST := G_RESP_VIOLATIONS_LIST(listkey);
                IF L_FUNC_ID_LIST.EXISTS(G_PV_FUNCTION_ID_LIST(i)) THEN
                    L_RESPVIO_ENTRIES := L_FUNC_ID_LIST(G_PV_FUNCTION_ID_LIST(i));
                END IF;
            END IF;

            counts := L_RESPVIO_ENTRIES.COUNT+1;
            L_RESPVIO_ENTRIES(counts).application_id     := G_PV_APPLICATION_ID_LIST(i);
            L_RESPVIO_ENTRIES(counts).Responsibility_id  := G_PV_RESPONSIBILITY_ID_LIST(i);
            L_RESPVIO_ENTRIES(counts).Menu_id            := G_PV_MENU_ID_LIST(i);
            L_RESPVIO_ENTRIES(counts).Function_Id        := G_PV_FUNCTION_ID_LIST(i);
            L_RESPVIO_ENTRIES(counts).Access_Given_Date  := G_PV_ACCESS_GIVEN_DATE_LIST(i);
            L_RESPVIO_ENTRIES(counts).Access_Given_By_Id := G_PV_ACCESS_GIVEN_BY_LIST(i);
            L_RESPVIO_ENTRIES(counts).Object_Type        := 'CP';
            L_RESPVIO_ENTRIES(counts).group_code         := G_PV_GROUP_CODE_LIST(i);
            L_RESPVIO_ENTRIES(counts).prog_appl_id       := G_PV_PROGRAM_APPL_ID_LIST(i);
            L_RESPVIO_ENTRIES(counts).Role_Name          := NULL;
            L_FUNC_ID_LIST(G_PV_FUNCTION_ID_LIST(i))     := L_RESPVIO_ENTRIES;
            G_RESP_VIOLATIONS_LIST(listkey) := L_FUNC_ID_LIST;
        END lOOP; -- End of FOR i in 1 .. G_PV_RESPONSIBILITY_ID_LIST.COUNT
    END IF;
    --FND_FILE.put_line(fnd_file.log,'cp_resp_c End '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));

    -- Releasing the used memory
    Clear_Potential_Value_List();

    --FND_FILE.put_line(fnd_file.log,'Potential Reposnibility  Start '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));


    -- psomanat : 06:09:2006 : fix for bug 5256720
    -- In amwvcstb.pls 120.23 version, we use the following logic
    --   for each incomptible function ...
    --      for each responsibility ...
    --          Check if the current function is excluded via function or menu
    --          exclusion
    --      end
    --  end
    --
    -- So for each incompatible function we dig into the responsibility menu
    -- hierarchy once to see if the function is exclude via menu exclusion.
    --
    -- When the incompatible function is not accessible by the responsibility,
    -- we are unnecessaryly digging into the entire responsibility menu hierarchy.
    --
    -- Even if a responsibility is having access to more than incompatible function,
    -- we dig into the entire responsibility menu hierarchy once for each incompatible
    -- function. So we are doing the same operation once for each function
    --
    -- So i have modified the logic as follows
    -- When we identify the responsibilities having access to the incompatible functions,
    -- we seggregate the responsibility in a data structure like
    --           Responsibility
    --                   |______Function_Id
    --                   |              |________Function Details Record
    --                   |              |________Function Details Record
    --                   |
    --                   |______Function_Id
    --                   |              |________Function Details Record
    --                   |              |________Function Details Record
    --                   |______Function_Id
    --                   |              |________Function Details Record
    --                   |              |________Function Details Record
    --
    --
    --
    -- So now i know the functions a responsibility have access to.
    -- So i iterate over the responsibility menu hierarchy once and in this
    -- iteration itself i check if the incompatible functions accessible
    -- to the responsibility is excluded via menu exclusion.I check only
    -- functions accessible to the responsibility (Not all) and when iam done
    -- verifing these function, i come out of the PROCESS_MENU_TREE_DOWN_FOR_CST
    -- procedure
    -- The process completes quicker than the earlier
    listkey :=G_PNTL_RESP_VIO_LIST.FIRST;
    WHILE listkey IS NOT NULL
    LOOP
        -- Clearing the list
        G_UNEXCL_FUNC_ID_LIST.delete();
        G_UNEXCL_GRP_CODE_LIST.delete();
        l_excl_func_list.delete();
        l_excl_func_id_list.delete();
        L_FUNC_ID_LIST.delete();
        L_RESPVIO_ENTRIES.delete();

        L_FUNC_ID_LIST := G_PNTL_RESP_VIO_LIST(listkey);
        L_RESPVIO_ENTRIES := L_FUNC_ID_LIST(L_FUNC_ID_LIST.FIRST);
        l_appl_id := L_RESPVIO_ENTRIES(1).application_id;
        l_resp_id := L_RESPVIO_ENTRIES(1).Responsibility_id;
        l_menu_id := L_RESPVIO_ENTRIES(1).Menu_id;

        /*FND_FILE.put_line(fnd_file.log,'l_appl_id '||l_appl_id);
        FND_FILE.put_line(fnd_file.log,'l_resp_id '||l_resp_id);
        FND_FILE.put_line(fnd_file.log,'l_menu_id '||l_menu_id); */

        OPEN excl_func_c FOR l_excl_func_dynamic_sql USING
            l_appl_id, l_resp_id;
        FETCH excl_func_c BULK COLLECT INTO l_excl_func_id_list;
        CLOSE excl_func_c;

        IF ((l_excl_func_id_list IS NOT NULL) and (l_excl_func_id_list.FIRST IS NOT NULL)) THEN

            -- l_excl_func_id_list holds the excluded function list.
            -- To check if a incompatible function is excluded i need to loop
            -- through l_excl_func_id_list .
            -- But looping once for each incompatible function will be time consuming
            -- So i put the l_excl_func_id_list data in a associative array and then
            -- fetch the data using function id as index from l_excl_func_list
            FOR j IN l_excl_func_id_list.FIRST .. l_excl_func_id_list.LAST
            LOOP
                l_excl_func_list(l_excl_func_id_list(j)):=l_excl_func_id_list(j);
            END LOOP;

            -- We populate the unexcluded incompatible function details in G_UNEXCL_FUNC_ID_LIST
            -- G_UNEXCL_GRP_CODE_LIST
            -- L_FUNC_ID_LIST contains all the incompatible functions accessible
            -- by a responsibility
            -- we check if the function is excluded via function exclusion
            -- if no, then we put the function in unexcluded list G_UNEXCL_XXXXX
            -- A function can be from Set 1 or set 2, So we use Function_id@set
            -- as key for G_UNEXCL_XXXXX
            FOR j IN L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
            LOOP
                IF L_FUNC_ID_LIST.EXISTS(j) THEN
                    IF (NOT l_excl_func_list.exists(j)) THEN
                        L_RESPVIO_ENTRIES := L_FUNC_ID_LIST(j);
                        FOR k in L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                        LOOP
                            lkey := L_RESPVIO_ENTRIES(k).Function_Id||'@'||L_RESPVIO_ENTRIES(k).group_code;
                            G_UNEXCL_FUNC_ID_LIST(lkey) := L_RESPVIO_ENTRIES(k).Function_Id;
                            G_UNEXCL_GRP_CODE_LIST(lkey):= L_RESPVIO_ENTRIES(k).group_code;
                        END LOOP;
                    END IF;
                END IF;
            END LOOP;
        ELSE
            -- None of the incompatible functions are excluded

            -- We populate the unexcluded incompatible function details in G_UNEXCL_FUNC_ID_LIST
            -- G_UNEXCL_GRP_CODE_LIST
            -- L_FUNC_ID_LIST contains all the incompatible functions accessible
            -- by a responsibility
            -- A function can be from Set 1 or set 2, So we use Function_id@set
            -- as key for G_UNEXCL_XXXXX
            FOR j IN L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
            LOOP
                IF L_FUNC_ID_LIST.EXISTS(j) THEN
                    L_RESPVIO_ENTRIES := L_FUNC_ID_LIST(j);
                    FOR k in L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                    LOOP
                        lkey := L_RESPVIO_ENTRIES(k).Function_Id||'@'||L_RESPVIO_ENTRIES(k).group_code;
                        G_UNEXCL_FUNC_ID_LIST(lkey) := L_RESPVIO_ENTRIES(k).Function_Id;
                        G_UNEXCL_GRP_CODE_LIST(lkey):= L_RESPVIO_ENTRIES(k).group_code;
                    END LOOP;
                END IF;
            END LOOP;
        END IF;

        /*FND_FILE.put_line(fnd_file.log,'*************************');
        lkey :=G_UNEXCL_FUNC_ID_LIST.FIRST;
        WHILE lkey IS NOT NULL
        LOOP
            FND_FILE.put_line(fnd_file.log,G_UNEXCL_FUNC_ID_LIST(lkey));
            lkey:=G_UNEXCL_FUNC_ID_LIST.NEXT(lkey);
        end loop;
        FND_FILE.put_line(fnd_file.log,'*************************');*/

        -- we need to dig into the responsibility menu hierarchy when we have
        -- atleast one unexcluded incompatible function
        IF G_UNEXCL_FUNC_ID_LIST.FIRST IS NOT NULL THEN
            l_accessible := PROCESS_MENU_TREE_DOWN_FOR_CST(
                                p_constraint_rev_id => p_constraint_rev_id,
                                p_menu_id           => l_menu_id,
                                p_appl_id           => l_appl_id,
                                p_resp_id           => l_resp_id);
        END IF;
        listkey:=G_PNTL_RESP_VIO_LIST.NEXT(listkey);
    END LOOP; -- end of loop: l_ptnl_resps_id_list

    -- Deleteing the G_PNTL_RESP_VIO_LIST as we don't require it any more
    G_PNTL_RESP_VIO_LIST.delete();
    G_UNEXCL_FUNC_ID_LIST.delete();
    G_UNEXCL_GRP_CODE_LIST.delete();

    --FND_FILE.put_line(fnd_file.log,'Potential Reposnibility  End '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));

    /*
        -- Display the responsibility
        listkey :=G_RESP_VIOLATIONS_LIST.FIRST;
        WHILE listkey IS NOT NULL
        LOOP
                FND_FILE.put_line(fnd_file.log,'*********************************************************');
                FND_FILE.put_line(fnd_file.log,'  Responsibility_id '||listkey);
                L_FUNC_ID_LIST:=G_RESP_VIOLATIONS_LIST(listkey);
                FOR j IN L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
                LOOP
                    IF L_FUNC_ID_LIST.EXISTS(j) THEN
                        L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(j);
                        FOR k IN L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                        LOOP
                          --  FND_FILE.put_line(fnd_file.log,'Responsibility_id '||L_RESPVIO_ENTRIES(k).Responsibility_id);
                          --  FND_FILE.put_line(fnd_file.log,'application_id    '||L_RESPVIO_ENTRIES(k).application_id);
                          FND_FILE.put_line(fnd_file.log,'   Menu_id           '||L_RESPVIO_ENTRIES(k).Menu_id);
                          FND_FILE.put_line(fnd_file.log,'   Function_Id       '||L_RESPVIO_ENTRIES(k).Function_Id);
                          FND_FILE.put_line(fnd_file.log,'   Object_Type       '||L_RESPVIO_ENTRIES(k).Object_Type);
                          FND_FILE.put_line(fnd_file.log,'   group_code        '||L_RESPVIO_ENTRIES(k).group_code);
                          FND_FILE.put_line(fnd_file.log,'                     ');
                        END LOOP;
                    END IF;
                END LOOP;
                FND_FILE.put_line(fnd_file.log,'*********************************************************');
            listkey:=G_RESP_VIOLATIONS_LIST.NEXT(listkey);
        END LOOP;
    */
    --FND_FILE.put_line(fnd_file.log,'Comming out of '||L_API_NAME);
    -- FND_FILE.put_line(fnd_file.log,'Populate_Ptnl_Access_List End '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));
END Populate_Ptnl_Access_List;

-- ===============================================================
-- Private Procedure name
--          Write_Func_To_Table_For_User
--
-- Purpose
--          Write global potential violation of specified user
--          against specified constraint
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--          p_user_id := specified user_id
--
-- Notes
--          when calling this procedure means it's gaurantee
--          the specified user has violated the specified constraint
--
-- History
--          05.17.2005 tsho: starting from AMW.E, consider Role, GLOBAL Grant/USER Grant
--          05.23.2005 tsho: starting from AMW.E, Revalidation
-- ===============================================================
Procedure Write_Func_To_Table_For_User (
    p_violation_id          IN  NUMBER,
    p_constraint_rev_id     IN  NUMBER,
    p_user_id               IN  NUMBER,
    p_is_user_wavied        IN  VARCHAR2,
    p_revalidate_flag       IN   VARCHAR2  := NULL
)
IS
    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Write_Func_To_Table_For_User';
    L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

    -- ptulasi : 18/02/2008
    -- bug : 	6722113 : Added below cursor to get waived of responsibilities in
    -- this constraint
    CURSOR c_resp_waived (l_constraint_rev_id IN NUMBER) IS
        SELECT PK1,PK2
        FROM amw_constraint_waivers_b
        WHERE constraint_rev_id = l_constraint_rev_id
        AND   object_type = 'RESP'
        AND start_date <= sysdate AND (end_date >= sysdate or end_date is null);

    i   NUMBER;
    idx NUMBER;
    l_party_id NUMBER;

    -- store the user_violation_id getting from AMW_USER_VIOLATION_S
    l_user_violation_id NUMBER;
    l_row_id    ROWID;

    -- ptulasi : 18/02/2008
    -- bug : 	6722113 : Added below plsql tables to store waived of responsibilities
    l_waiv_resp_id_list         G_NUMBER_TABLE;
    l_waiv_resp_appl_id_list    G_NUMBER_TABLE;
    l_waived_resp_appl_list     G_NUMBER_TABLE_TYPE;
    listkey VARCHAR2(250);

    -- get user_violation_id from AMW_USER_VIOLATION_S
    CURSOR c_user_violation_id IS
        SELECT AMW_USER_VIOLATION_S.NEXTVAL
        FROM dual;

    l_is_user_waived    VARCHAR2(1);
    L_USERVIO_ENTRIES G_USERVIO_ENTRIES_TABLE;
    L_FUNC_ID_LIST    G_FUNCS_TABLE;
BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);
    l_is_user_waived := p_is_user_wavied;

    -- find party_id with specified user_id
    BEGIN
        -- 01.02.2003 tsho: bug 3348191 - duplicated user shown
        -- because same party_id(person) maps to multiple user_id(login acct),
        -- thus store user_id directly rather party_id in AMW_VIOLATION_USERS
        l_party_id := p_user_id;

    EXCEPTION
        WHEN no_data_found THEN
            null;
    END;

    -- ptulasi : 18/02/2008
    -- bug : 	6722113 : Added below code to not to display waived of responsibilities in
    -- the violation report
    -- Get the responsibilities marked as waiver for the current constraint in individual
    -- nested table.
    OPEN  c_resp_waived (p_constraint_rev_id);
    FETCH c_resp_waived BULK COLLECT INTO l_waiv_resp_id_list,l_waiv_resp_appl_id_list;
    CLOSE c_resp_waived;
    IF (l_waiv_resp_id_list IS NOT NULL) AND (l_waiv_resp_id_list.FIRST IS NOT NULL) THEN
        FOR i IN l_waiv_resp_id_list.FIRST ..l_waiv_resp_id_list.LAST
        LOOP
            listkey:=l_waiv_resp_appl_id_list(i)||'@'||l_waiv_resp_id_list(i);
            l_waived_resp_appl_list(listkey):=l_waiv_resp_id_list(i);
        END LOOP;
    END IF;

    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
        IF (G_User_Violation_Id_list.exists(p_user_id)) THEN
            l_user_violation_id :=G_User_Violation_Id_list(p_user_id);
            DELETE FROM AMW_VIOLAT_USER_ENTRIES
            WHERE USER_VIOLATION_ID =l_user_violation_id;

        -- ptulasi : 18-02-2008
        -- bug : 	6689589 : If a responsibility violating the constraint is end dated, the staus for the
        -- user having this responsibility only should be shown as closed. But this is not happening. This is
        -- because the corrected_flag for the user is not set to yes. The query used to fetch the user and his
        -- responsibilities will not fetch the end dated responsibilities. So no action is taken against the
        -- user having responsibilities which violate the constraint.
        -- Updated the corrected_flag of all the violating users to yes. For the violating users,
        -- the corrected_flag will be set to no.
            UPDATE AMW_VIOLATION_USERS SET CORRECTED_FLAG = 'N'
            WHERE USER_VIOLATION_ID = l_user_violation_id;
            -- ptulasi : 18/02/2008
            -- bug : 	6722113 : Added below condition to not to display waived of responsibilities in
            -- the violation report users tab
	   IF l_is_user_waived = 'Y' THEN
            UPDATE AMW_VIOLATION_USERS SET WAIVED_FLAG = 'Y'
            WHERE USER_VIOLATION_ID = l_user_violation_id;
        END IF;
        END IF;
    ELSE

        IF (G_User_Waiver_List.exists(p_user_id))THEN
            l_is_user_waived := 'Y';
        END IF;

        -- get user_violation_id from AMW_USER_VIOLATION_S
        OPEN c_user_violation_id;
        FETCH c_user_violation_id INTO l_user_violation_id;
        CLOSE c_user_violation_id;

        AMW_VIOLATION_USERS_PKG.insert_row(x_rowid          =>  l_row_id,
                                       x_user_violation_id  =>  l_user_violation_id,
                                       x_violation_id       =>  p_violation_id,
                                       x_violated_by_id     =>  l_party_id,
                                       x_last_updated_by    =>  G_USER_ID,
                                       x_last_update_date   =>  SYSDATE,
                                       x_created_by         =>  G_USER_ID,
                                       x_creation_date      =>  SYSDATE,
                                       x_last_update_login  =>  G_LOGIN_ID,
                                       x_security_group_id  =>  NULL,
                                       x_waived_flag        =>  l_is_user_waived);

    END IF; -- end of if: p_revalidate_flag IS NOT NULL

    L_FUNC_ID_LIST:=G_USER_VIOLATIONS_LIST(p_user_id);
    FOR j IN L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
    LOOP
        IF L_FUNC_ID_LIST.EXISTS(j) THEN
            L_USERVIO_ENTRIES:=L_FUNC_ID_LIST(j);
            FOR k IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
            LOOP
            -- ptulasi : 18/02/2008
            -- bug : 	6722113 : Added below condition to not to display waived of responsibilities in
            -- the violation report
            listkey := L_USERVIO_ENTRIES(k).application_id||'@'||L_USERVIO_ENTRIES(k).Responsibility_id;
            IF (((l_is_user_waived IS NULL OR l_is_user_waived <> 'Y')
             AND (NOT l_waived_resp_appl_list.exists(listkey))) OR (l_is_user_waived = 'Y')) THEN
                INSERT INTO AMW_VIOLAT_USER_ENTRIES(
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_LOGIN,
                       CREATION_DATE,
                       CREATED_BY,
                       SECURITY_GROUP_ID,
                       USER_VIOLATION_ID,
                       RESPONSIBILITY_ID,
                       MENU_ID,
                       FUNCTION_ID,
                       ACCESS_GIVEN_DATE,
                       ACCESS_GIVEN_BY_ID,
                       ROLE_NAME,
                       OBJECT_TYPE,
                       APPLICATION_ID,
                       PROGRAM_APPLICATION_ID)
                VALUES (
                                        SYSDATE,                                -- last_update_date
                                        G_USER_ID,                              -- last_updated_by
                                        G_LOGIN_ID,                             -- last_update_login
                                        SYSDATE,                                -- creation_date
                                        G_USER_ID,                              -- created_by
                                        NULL,                                   -- security_group_id
                                        l_user_violation_id,                    -- user_violation_id
                                        L_USERVIO_ENTRIES(k).Responsibility_id ,-- responsibility_id
                                        L_USERVIO_ENTRIES(k).Menu_id,           -- menu_id
                                        L_USERVIO_ENTRIES(k).Function_Id ,      -- function_id
                                        L_USERVIO_ENTRIES(k).Access_Given_Date, -- access_given_date
                                        L_USERVIO_ENTRIES(k).Access_Given_By_Id,-- access_given_by_id
                                        L_USERVIO_ENTRIES(k).Role_Name,         -- role_name
                                        L_USERVIO_ENTRIES(k).Object_Type,       -- object_type
                                        L_USERVIO_ENTRIES(k).application_id ,   -- application_id
                                        L_USERVIO_ENTRIES(k).prog_appl_id );    -- program application id
            END IF;
            END LOOP;
        END IF;
    END LOOP;
END Write_Func_To_Table_For_User;


-- ===============================================================
-- Private Procedure name
--          Write_Resp_To_Table_For_User
--
-- Purpose
--          Write global potential violation of specified user
--          against specified constraint
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--          p_user_id := specified user_id
--
-- Notes
--          when calling this procedure means it's gaurantee
--          the specified user has violated the specified constraint
--
-- History
--          05.17.2005 tsho: starting from AMW.E, add column: ROLE_NAME to AMW_VIOLAT_USER_ENTRIES
--          05.23.2005 tsho: starting from AMW.E, Revalidation
-- ===============================================================
Procedure Write_Resp_To_Table_For_User (
    p_violation_id          IN  NUMBER,
    p_constraint_rev_id     IN  NUMBER,
    p_user_id               IN  NUMBER,
    p_revalidate_flag       IN   VARCHAR2  := NULL
)
IS
    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Write_Resp_To_Table_For_User';
    L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

    i   NUMBER;
    idx NUMBER;
    l_party_id NUMBER;

    -- store the user_violation_id getting from AMW_USER_VIOLATION_S
    l_user_violation_id NUMBER;
    l_row_id    ROWID;

    l_is_user_waived    VARCHAR2(1);
    L_USERVIO_ENTRIES G_USERVIO_ENTRIES_TABLE;
    L_RESP_ID_LIST    G_RESPS_TABLE;
    listkey VARCHAR2(30) := NULL;

    -- get user_violation_id from AMW_USER_VIOLATION_S
    CURSOR c_user_violation_id IS
        SELECT AMW_USER_VIOLATION_S.NEXTVAL
        FROM dual;
BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);
    l_is_user_waived := NULL;

    -- find party_id with specified user_id
    BEGIN
        -- 01.02.2003 tsho: bug 3348191 - duplicated user shown
        -- because same party_id(person) maps to multiple user_id(login acct),
        -- thus store user_id directly rather party_id in AMW_VIOLATION_USERS
        l_party_id := p_user_id;

    EXCEPTION
        WHEN no_data_found THEN
            null;
    END;

    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
        IF (G_User_Violation_Id_list.exists(p_user_id)) THEN
            l_user_violation_id :=G_User_Violation_Id_list(p_user_id);
            DELETE FROM AMW_VIOLAT_USER_ENTRIES
            WHERE USER_VIOLATION_ID = l_user_violation_id;

        -- ptulasi : 18-02-2008
        -- bug : 	6689589 : If a responsibility violating the constraint is end dated, the staus for the
        -- user having this responsibility only should be shown as closed. But this is not happening. This is
        -- because the corrected_flag for the user is not set to yes. The query used to fetch the user and his
        -- responsibilities will not fetch the end dated responsibilities. So no action is taken against the
        -- user having responsibilities which violate the constraint.
        -- Updated the corrected_flag of all the violating users to yes. For the violating users,
        -- the corrected_flag will be set to no.
            UPDATE AMW_VIOLATION_USERS SET CORRECTED_FLAG = 'N'
            WHERE USER_VIOLATION_ID = l_user_violation_id;

        END IF;

    ELSE
        IF (G_User_Waiver_List.exists(p_user_id))THEN
            l_is_user_waived := 'Y';
        END IF;

        -- get user_violation_id from AMW_USER_VIOLATION_S
        OPEN c_user_violation_id;
        FETCH c_user_violation_id INTO l_user_violation_id;
        CLOSE c_user_violation_id;

        AMW_VIOLATION_USERS_PKG.insert_row(x_rowid          =>  l_row_id,
                                       x_user_violation_id  =>  l_user_violation_id,
                                       x_violation_id       =>  p_violation_id,
                                       x_violated_by_id     =>  l_party_id,
                                       x_last_updated_by    =>  G_USER_ID,
                                       x_last_update_date   =>  SYSDATE,
                                       x_created_by         =>  G_USER_ID,
                                       x_creation_date      =>  SYSDATE,
                                       x_last_update_login  =>  G_LOGIN_ID,
                                       x_security_group_id  =>  NULL,
                                       x_waived_flag        =>  l_is_user_waived);
    END IF; -- end of if: p_revalidate_flag IS NOT NULL

    L_RESP_ID_LIST:=G_USER_RESP_VIO_LIST(p_user_id);

    listkey :=L_RESP_ID_LIST.FIRST;
    WHILE listkey IS NOT NULL
    LOOP
        L_USERVIO_ENTRIES:=L_RESP_ID_LIST(listkey);
        FOR k IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
        LOOP
            INSERT INTO AMW_VIOLAT_USER_ENTRIES(
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_LOGIN,
                       CREATION_DATE,
                       CREATED_BY,
                       SECURITY_GROUP_ID,
                       USER_VIOLATION_ID,
                       RESPONSIBILITY_ID,
                       MENU_ID,
                       FUNCTION_ID,
                       ACCESS_GIVEN_DATE,
                       ACCESS_GIVEN_BY_ID,
                       ROLE_NAME,
                       OBJECT_TYPE,
                       APPLICATION_ID,
                       PROGRAM_APPLICATION_ID)
                  VALUES (
                                        SYSDATE,                                -- last_update_date
                                        G_USER_ID,                              -- last_updated_by
                                        G_LOGIN_ID,                             -- last_update_login
                                        SYSDATE,                                -- creation_date
                                        G_USER_ID,                              -- created_by
                                        NULL,                                   -- security_group_id
                                        l_user_violation_id,                    -- user_violation_id
                                        L_USERVIO_ENTRIES(k).Responsibility_id ,-- responsibility_id
                                        NULL,                                   -- menu_id
                                        NULL,                                   -- function_id
                                        L_USERVIO_ENTRIES(k).Access_Given_Date, -- access_given_date
                                        L_USERVIO_ENTRIES(k).Access_Given_By_Id,-- access_given_by_id
                                        NULL,                                   -- role_name
                                        'RESP',                                 -- object_type
                                        L_USERVIO_ENTRIES(k).application_id,    -- application_id
                                        NULL);                                  -- program application id
        END LOOP;
        listkey:=L_RESP_ID_LIST.NEXT(listkey);
    END LOOP;
END Write_Resp_To_Table_For_User;

-- ===============================================================
-- Private Procedure name
--          Wtite_Resp_Violat_to_table
--
-- Purpose
--          Write the violating responsibility to the Table
--          AMW_Violation_RESP,AMW_VIOLAT_RESP_ENTRIES
--
-- Params
--          p_violation_id      := specified violation id
--          p_constraint_rev_id := specified constraint_rev_id
--          p_type_code         := specified constraint object type
-- Notes
--
-- History
-- ===============================================================

Procedure Write_Resp_Violat_to_table (
    p_violation_id          IN  NUMBER,
    p_constraint_rev_id     IN   NUMBER,
    p_type_code             IN   VARCHAR2
)
IS

    CURSOR c_constraint_entries (l_constraint_rev_id IN NUMBER) IS
        SELECT function_id,object_type,group_code
        FROM amw_constraint_entries
        WHERE constraint_rev_id=l_constraint_rev_id;

    CURSOR c_resp_violation_id IS
        SELECT AMW_VIOLATION_RESP_S.NEXTVAL
        FROM dual;

    CURSOR c_resp_waived (l_constraint_rev_id IN NUMBER) IS
        SELECT PK1,PK2
        FROM amw_constraint_waivers_b
        WHERE constraint_rev_id = l_constraint_rev_id
        AND object_type = 'RESP'
        AND start_date <= sysdate AND (end_date >= sysdate or end_date is null);

    TYPE NumberTable IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    l_constraint_function_id NUMBER;
    l_resp_violation_id      NUMBER;
    l_is_resp_waived         VARCHAR2(1);
    l_is_resp_waived_count   NUMBER;
    l_function_id_list          G_NUMBER_TABLE;
    l_waiv_resp_id_list         G_NUMBER_TABLE;
    l_waiv_resp_appl_id_list    G_NUMBER_TABLE;
    l_waived_resp_appl_list     G_NUMBER_TABLE_TYPE;

    L_OBJECT_TYPE_LIST           G_VARCHAR2_CODE_TABLE;
    L_GROUP_CODE_LIST            G_VARCHAR2_CODE_TABLE;
    L_AVAILABLE_GROUP_CODE_LIST  G_VARCHAR2_CODE_TABLE;
    L_RESPVIO_ENTRIES            G_RESPVIO_ENTRIES_TABLE;

    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Wtite_Resp_Violat_to_table';
    L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

    -- psomanat : 06:09:2006 : fix for bug 5256720
    L_FUNC_ID_LIST    G_FUNC_TABLE;
    counts            Number;
    listkey           VARCHAR2(30) := NULL;
BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);
    --FND_FILE.put_line(fnd_file.log,'Wtite_Resp_Violat_to_table start '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));

    IF (G_RESP_VIOLATIONS_LIST.COUNT = 0) THEN
        RETURN;
    END IF;

    -- Collect all the constraint entries details
    OPEN c_constraint_entries (p_constraint_rev_id);
    FETCH c_constraint_entries BULK COLLECT INTO l_function_id_list,L_OBJECT_TYPE_LIST,L_GROUP_CODE_LIST;
    CLOSE c_constraint_entries;

    -- Get the responsibilities marked as waiver for the current constraint in individual
    -- nested table.
    -- To identify a responsibility in the nested table we need to iterate over it.
    -- This will be time consuming
    -- So we store the details in an associative array with application_id@responsbility_id
    -- as key. Now given a responsibility and application id we can easily find out if
    -- the responsibility is waived or not .
    OPEN  c_resp_waived (p_constraint_rev_id);
    FETCH c_resp_waived BULK COLLECT INTO l_waiv_resp_id_list,l_waiv_resp_appl_id_list;
    CLOSE c_resp_waived;

    IF (l_waiv_resp_id_list IS NOT NULL) AND (l_waiv_resp_id_list.FIRST IS NOT NULL) THEN
        FOR i IN l_waiv_resp_id_list.FIRST ..l_waiv_resp_id_list.LAST
        LOOP
            listkey:=l_waiv_resp_appl_id_list(i)||'@'||l_waiv_resp_id_list(i);
            l_waived_resp_appl_list(listkey):=l_waiv_resp_id_list(i);
        END LOOP;
    END IF;

    -- Logic :
    -- G_RESP_VIOLATIONS_LIST holds the responsibilities and the incompatible functions
    -- accessible from it
    -- Here we identify if the responsibility violates a constraint. The check
    -- is based on the object type
    -- If the object type = ALL , we check if the responsibility have access to all
    --         incompatible function
    -- If the Object type = ME,  we check if the responsibility have access to atleast
    --         2 incompatible function
    -- If the Object type = Set,  we check if the responsibility have access to atleast
    --         1 incompatible function from each group
    -- During this process we populate 2 tables AMW_VIOLATION_RESP,AMW_VIOLAT_RESP_ENTRIES
    -- We put responibility specific details in AMW_VIOLATION_RESP and
    -- the functions accessible to a responsibility in AMW_VIOLAT_RESP_ENTRIES
    listkey :=G_RESP_VIOLATIONS_LIST.FIRST;
    WHILE listkey IS NOT NULL
    LOOP
        L_RESPVIO_ENTRIES.DELETE();
        L_FUNC_ID_LIST.DELETE();

        L_FUNC_ID_LIST :=G_RESP_VIOLATIONS_LIST(listkey);

        IF p_type_code = 'ALL' AND  L_FUNC_ID_LIST.COUNT = l_function_id_list.COUNT THEN

            OPEN c_resp_violation_id;
            FETCH c_resp_violation_id INTO l_resp_violation_id;
            CLOSE c_resp_violation_id;

            l_is_resp_waived :='N';
            l_is_resp_waived_count := 0;

            L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(L_FUNC_ID_LIST.FIRST);
            IF (NOT l_waived_resp_appl_list.exists(listkey)) THEN

                /*FND_FILE.put_line(fnd_file.log,'***************Responsibility Violation All************* ');
                FND_FILE.put_line(fnd_file.log,' RESP_VIOLATION_ID :'||l_resp_violation_id);
                FND_FILE.put_line(fnd_file.log,' VIOLATION_ID      :'||P_VIOLATION_ID);
                FND_FILE.put_line(fnd_file.log,' RESPONSIBILITY_ID :'||L_RESPVIO_ENTRIES(1).Responsibility_id);
                FND_FILE.put_line(fnd_file.log,' APPLICATION_ID    :'||L_RESPVIO_ENTRIES(1).application_id);
                FND_FILE.put_line(fnd_file.log,' WAIVED_FLAG       :'||l_is_resp_waived);
                FND_FILE.put_line(fnd_file.log,' CORRECTED_FLAG    :'||'N');*/
                INSERT INTO AMW_VIOLATION_RESP(
                RESP_VIOLATION_ID,
                VIOLATION_ID,
                RESPONSIBILITY_ID,
                APPLICATION_ID,
                ROLE_NAME,
                WAIVED_FLAG,
                CORRECTED_FLAG,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                CREATION_DATE,
                CREATED_BY,
                SECURITY_GROUP_ID
                )
                VALUES(
                l_resp_violation_id,
                P_VIOLATION_ID,
                L_RESPVIO_ENTRIES(1).Responsibility_id,
                L_RESPVIO_ENTRIES(1).application_id,
                null,
                l_is_resp_waived,
                'N',
                sysdate,
                G_USER_ID,
                G_LOGIN_ID,
                sysdate,
                G_USER_ID,
                null
                );

                FOR j IN  L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
                LOOP
                    IF L_FUNC_ID_LIST.EXISTS(j) then
                    L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(j);

                        --FND_FILE.put_line(fnd_file.log,'---------------- Responsibility Violation Entries -----------');
                        FOR k IN  L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                        LOOP
                          /* FND_FILE.put_line(fnd_file.log,' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
                            FND_FILE.put_line(fnd_file.log,' RESP_VIOLATION_ID  :'||l_resp_violation_id);
                            FND_FILE.put_line(fnd_file.log,' MENU_ID            :'||L_RESPVIO_ENTRIES(k).Menu_Id);
                            FND_FILE.put_line(fnd_file.log,' FUNCTION_ID        :'||L_RESPVIO_ENTRIES(k).Function_id);
                            FND_FILE.put_line(fnd_file.log,' ACCESS_GIVEN_DATE  :'||L_RESPVIO_ENTRIES(k).Access_Given_Date);
                            FND_FILE.put_line(fnd_file.log,' ACCESS_GIVEN_BY_ID :'||L_RESPVIO_ENTRIES(k).Access_Given_By_Id);
                            FND_FILE.put_line(fnd_file.log,' OBJECT_TYPE        :'||L_RESPVIO_ENTRIES(k).Object_type);
                            FND_FILE.put_line(fnd_file.log,' APPLICATION_ID     :'||L_RESPVIO_ENTRIES(k).prog_appl_id);
                            FND_FILE.put_line(fnd_file.log,' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'); */

                             INSERT INTO AMW_VIOLAT_RESP_ENTRIES(
                                VIOLAT_RESP_ENTRY_ID,
                                RESP_VIOLATION_ID,
                                MENU_ID,
                                FUNCTION_ID,
                                ACCESS_GIVEN_DATE,
                                ACCESS_GIVEN_BY_ID,
                                OBJECT_TYPE,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_LOGIN,
                                CREATION_DATE,
                                CREATED_BY,
                                SECURITY_GROUP_ID,
                                APPLICATION_ID
                            )
                            VALUES(
                                AMW_VIOLAT_RESP_ENTRIES_S.NEXTVAL,
                                l_resp_violation_id,
                                L_RESPVIO_ENTRIES(k).Menu_Id,
                                L_RESPVIO_ENTRIES(k).Function_id,
                                L_RESPVIO_ENTRIES(k).Access_Given_Date,
                                L_RESPVIO_ENTRIES(k).Access_Given_By_Id,
                                L_RESPVIO_ENTRIES(k).Object_type,
                                sysdate,
                                G_USER_ID,
                                G_LOGIN_ID,
                                sysdate,
                                G_USER_ID,
                                NULL,
                                L_RESPVIO_ENTRIES(k).prog_appl_id
                            );
                        END LOOP;
                    END IF;
                END LOOP;
            END IF;
        ELSIF p_type_code = 'ME' AND  L_FUNC_ID_LIST.COUNT >= 2 THEN


            --dbms_output.put_line('In ME');
            OPEN c_resp_violation_id;
            FETCH c_resp_violation_id INTO l_resp_violation_id;
            CLOSE c_resp_violation_id;

            L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(L_FUNC_ID_LIST.FIRST);

            l_is_resp_waived :='N';
            l_is_resp_waived_count:= 0;


            IF (NOT l_waived_resp_appl_list.exists(listkey)) THEN
                /*FND_FILE.put_line(fnd_file.log,'***************Responsibility Violation ME************* ');
                FND_FILE.put_line(fnd_file.log,' RESP_VIOLATION_ID :'||l_resp_violation_id);
                FND_FILE.put_line(fnd_file.log,' VIOLATION_ID      :'||P_VIOLATION_ID);
                FND_FILE.put_line(fnd_file.log,' RESPONSIBILITY_ID :'||L_RESPVIO_ENTRIES(1).Responsibility_id);
                FND_FILE.put_line(fnd_file.log,' APPLICATION_ID    :'||L_RESPVIO_ENTRIES(1).application_id);
                FND_FILE.put_line(fnd_file.log,' WAIVED_FLAG       :'||l_is_resp_waived);
                FND_FILE.put_line(fnd_file.log,' CORRECTED_FLAG    :'||'N');   */

                INSERT INTO AMW_VIOLATION_RESP(
                    RESP_VIOLATION_ID,
                    VIOLATION_ID,
                    RESPONSIBILITY_ID,
                    APPLICATION_ID,
                    ROLE_NAME,
                    WAIVED_FLAG,
                    CORRECTED_FLAG,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    CREATION_DATE,
                    CREATED_BY,
                    SECURITY_GROUP_ID
                )
                VALUES(
                    l_resp_violation_id,
                    P_VIOLATION_ID,
                    L_RESPVIO_ENTRIES(1).Responsibility_id,
                    L_RESPVIO_ENTRIES(1).application_id,
                    null,
                    l_is_resp_waived,
                    'N',
                    sysdate,
                    G_USER_ID,
                    G_LOGIN_ID,
                    sysdate,
                    G_USER_ID,
                    null
                );

                FOR j IN  L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
                LOOP
                    IF L_FUNC_ID_LIST.EXISTS(j) then
                        L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(j);
                        --FND_FILE.put_line(fnd_file.log,'---------------- Responsibility Violation Entries -----------');
                        FOR k IN  L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                        LOOP
                            /*FND_FILE.put_line(fnd_file.log,' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
                            FND_FILE.put_line(fnd_file.log,' RESP_VIOLATION_ID  :'||l_resp_violation_id);
                            FND_FILE.put_line(fnd_file.log,' MENU_ID            :'||L_RESPVIO_ENTRIES(k).Menu_Id);
                            FND_FILE.put_line(fnd_file.log,' FUNCTION_ID        :'||L_RESPVIO_ENTRIES(k).Function_id);
                            FND_FILE.put_line(fnd_file.log,' ACCESS_GIVEN_DATE  :'||L_RESPVIO_ENTRIES(k).Access_Given_Date);
                            FND_FILE.put_line(fnd_file.log,' ACCESS_GIVEN_BY_ID :'||L_RESPVIO_ENTRIES(k).Access_Given_By_Id);
                            FND_FILE.put_line(fnd_file.log,' OBJECT_TYPE        :'||L_RESPVIO_ENTRIES(k).Object_type);
                            FND_FILE.put_line(fnd_file.log,' APPLICATION_ID     :'||L_RESPVIO_ENTRIES(k).prog_appl_id);
                            FND_FILE.put_line(fnd_file.log,' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');  */

                             INSERT INTO AMW_VIOLAT_RESP_ENTRIES(
                                VIOLAT_RESP_ENTRY_ID,
                                resp_violation_id,
                                MENU_ID,
                                FUNCTION_ID,
                                ACCESS_GIVEN_DATE,
                                ACCESS_GIVEN_BY_ID,
                                OBJECT_TYPE,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_LOGIN,
                                CREATION_DATE,
                                CREATED_BY,
                                SECURITY_GROUP_ID,
                                APPLICATION_ID
                            )
                            VALUES(
                                AMW_VIOLAT_RESP_ENTRIES_S.NEXTVAL,
                                l_resp_violation_id,
                                L_RESPVIO_ENTRIES(k).Menu_Id,
                                L_RESPVIO_ENTRIES(k).Function_id,
                                L_RESPVIO_ENTRIES(k).Access_Given_Date,
                                L_RESPVIO_ENTRIES(k).Access_Given_By_Id,
                                L_RESPVIO_ENTRIES(k).Object_type,
                                sysdate,
                                G_USER_ID,
                                G_LOGIN_ID,
                                sysdate,
                                G_USER_ID,
                                NULL,
                                L_RESPVIO_ENTRIES(k).prog_appl_id );
                        END LOOP;
                    END IF;
                END LOOP;
            END IF;
        ELSIF p_type_code = 'SET' THEN

            L_AVAILABLE_GROUP_CODE_LIST.delete();

            FOR j IN  L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
            LOOP
                IF L_FUNC_ID_LIST.EXISTS(j) then
                   L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(j);
                    FOR k IN  L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                    LOOP
                        L_AVAILABLE_GROUP_CODE_LIST(L_RESPVIO_ENTRIES(k).group_code):= L_RESPVIO_ENTRIES(k).group_code;
                        IF L_AVAILABLE_GROUP_CODE_LIST.COUNT >=2 THEN
                            EXIT;
                        END IF;
                    END LOOP;
                END IF;
            END LOOP;

            IF (L_AVAILABLE_GROUP_CODE_LIST.COUNT)>=2 THEN

                OPEN c_resp_violation_id;
                FETCH c_resp_violation_id INTO l_resp_violation_id;
                CLOSE c_resp_violation_id;

                L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(L_FUNC_ID_LIST.FIRST);

                l_is_resp_waived := 'N';
                l_is_resp_waived_count:= 0;

                IF (NOT l_waived_resp_appl_list.exists(listkey)) THEN
                   /* FND_FILE.put_line(fnd_file.log,'***************Responsibility Violation SET************* ');
                    FND_FILE.put_line(fnd_file.log,' RESP_VIOLATION_ID :'||l_resp_violation_id);
                    FND_FILE.put_line(fnd_file.log,' VIOLATION_ID      :'||P_VIOLATION_ID);
                    FND_FILE.put_line(fnd_file.log,' RESPONSIBILITY_ID :'||L_RESPVIO_ENTRIES(1).Responsibility_id);
                    FND_FILE.put_line(fnd_file.log,' APPLICATION_ID    :'||L_RESPVIO_ENTRIES(1).application_id);
                    FND_FILE.put_line(fnd_file.log,' WAIVED_FLAG       :'||l_is_resp_waived);
                    FND_FILE.put_line(fnd_file.log,' CORRECTED_FLAG    :'||'N');*/

                        INSERT INTO AMW_VIOLATION_RESP(
                        RESP_VIOLATION_ID,
                        VIOLATION_ID,
                        RESPONSIBILITY_ID,
                        APPLICATION_ID,
                        ROLE_NAME,
                        WAIVED_FLAG,
                        CORRECTED_FLAG,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN,
                        CREATION_DATE,
                        CREATED_BY,
                        SECURITY_GROUP_ID
                    )
                    VALUES(
                        l_resp_violation_id,
                        P_VIOLATION_ID,
                        L_RESPVIO_ENTRIES(1).Responsibility_id,
                        L_RESPVIO_ENTRIES(1).application_id,
                        null,
                        l_is_resp_waived,
                        'N',
                        sysdate,
                        G_USER_ID,
                        G_LOGIN_ID,
                        sysdate,
                        G_USER_ID,
                        null
                    );

                    FOR j IN  L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
                    LOOP
                        IF L_FUNC_ID_LIST.EXISTS(j) then
                            L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(j);
                            --FND_FILE.put_line(fnd_file.log,'---------------- Responsibility Violation Entries -----------');

                            FOR k IN  L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                            LOOP
                               /* FND_FILE.put_line(fnd_file.log,' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
                                FND_FILE.put_line(fnd_file.log,' RESP_VIOLATION_ID  :'||l_resp_violation_id);
                                FND_FILE.put_line(fnd_file.log,' MENU_ID            :'||L_RESPVIO_ENTRIES(k).Menu_Id);
                                FND_FILE.put_line(fnd_file.log,' FUNCTION_ID        :'||L_RESPVIO_ENTRIES(k).Function_id);
                                FND_FILE.put_line(fnd_file.log,' ACCESS_GIVEN_DATE  :'||L_RESPVIO_ENTRIES(k).Access_Given_Date);
                                FND_FILE.put_line(fnd_file.log,' ACCESS_GIVEN_BY_ID :'||L_RESPVIO_ENTRIES(k).Access_Given_By_Id);
                                FND_FILE.put_line(fnd_file.log,' OBJECT_TYPE        :'||L_RESPVIO_ENTRIES(k).Object_type);
                                FND_FILE.put_line(fnd_file.log,' APPLICATION_ID     :'||L_RESPVIO_ENTRIES(k).prog_appl_id);
                                FND_FILE.put_line(fnd_file.log,' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');*/

                                INSERT INTO AMW_VIOLAT_RESP_ENTRIES(
                                    VIOLAT_RESP_ENTRY_ID,
                                    RESP_VIOLATION_ID,
                                    MENU_ID,
                                    FUNCTION_ID,
                                    ACCESS_GIVEN_DATE,
                                    ACCESS_GIVEN_BY_ID,
                                    OBJECT_TYPE,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_LOGIN,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    SECURITY_GROUP_ID,
                                    APPLICATION_ID
                                )
                                VALUES(
                                    AMW_VIOLAT_RESP_ENTRIES_S.NEXTVAL,
                                    l_resp_violation_id,
                                    L_RESPVIO_ENTRIES(k).Menu_Id,
                                    L_RESPVIO_ENTRIES(k).Function_id,
                                    L_RESPVIO_ENTRIES(k).Access_Given_Date,
                                    L_RESPVIO_ENTRIES(k).Access_Given_By_Id,
                                    L_RESPVIO_ENTRIES(k).Object_type,
                                    sysdate,
                                    G_USER_ID,
                                    G_LOGIN_ID,
                                    sysdate,
                                    G_USER_ID,
                                    NULL,
                                    L_RESPVIO_ENTRIES(k).prog_appl_id
                                );
                            END LOOP;
                        END IF;
                    END LOOP;
                END IF;
            END IF;
        END IF;
        listkey:=G_RESP_VIOLATIONS_LIST.NEXT(listkey);
    END LOOP;
    --FND_FILE.put_line(fnd_file.log,'Came out '||L_API_NAME);
    --FND_FILE.put_line(fnd_file.log,'Wtite_Resp_Violat_to_table end '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));
END;

-- ===============================================================
-- Private Procedure name
--          Wtite_Resp_Violat_to_table_rvl
--
-- Purpose
--          revalidates the violating responsibility to the Table
--          AMW_Violation_RESP,AMW_VIOLAT_RESP_ENTRIES
--
-- Params
--          p_violation_id      := specified violation id
--          p_constraint_rev_id := specified constraint_rev_id
--          p_type_code         := specified constraint object type
--
-- Notes
--
-- History
-- ===============================================================

Procedure Write_Resp_Violat_to_table_rvl (
    p_violation_id          IN  NUMBER,
    p_constraint_rev_id     IN   NUMBER,
    p_type_code             IN   VARCHAR2
)
IS

    CURSOR c_constraint_entries (l_constraint_rev_id IN NUMBER) IS
        SELECT function_id,object_type,group_code
        FROM amw_constraint_entries
        WHERE constraint_rev_id=l_constraint_rev_id;

    CURSOR c_resp_violation_id IS
        SELECT AMW_VIOLATION_RESP_S.NEXTVAL
        FROM dual;

    CURSOR c_resp_waived (l_constraint_rev_id IN NUMBER) IS
        SELECT PK1,PK2
        FROM amw_constraint_waivers_b
        WHERE constraint_rev_id = l_constraint_rev_id
        AND object_type = 'RESP'
        AND start_date <= sysdate AND (end_date >= sysdate or end_date is null);

    CURSOR c_existing_resp_violation (l_violation_id IN NUMBER) IS
        SELECT  APPLICATION_ID,RESPONSIBILITY_ID,RESP_VIOLATION_ID
        FROM    AMW_VIOLATION_RESP
        WHERE   violation_id=l_violation_id;


    l_constraint_function_id NUMBER;
    l_resp_violation_id      NUMBER;
    l_is_resp_waived         VARCHAR2(1);
    l_is_resp_waived_count   NUMBER;

    l_waiv_resp_id_list         G_NUMBER_TABLE;
    l_waiv_resp_appl_id_list    G_NUMBER_TABLE;
    l_waived_resp_appl_list     G_NUMBER_TABLE_TYPE;
    L_FUNCTION_ID_LIST          G_NUMBER_TABLE;
    L_EXISTING_RESP_ID_LIST     G_NUMBER_TABLE;
    L_EXISTING_APPL_ID_LIST     G_NUMBER_TABLE;
    L_EXISTING_RESP_VIO_ID_LIST G_NUMBER_TABLE;

    L_OBJECT_TYPE_LIST           G_VARCHAR2_CODE_TABLE;
    L_GROUP_CODE_LIST            G_VARCHAR2_CODE_TABLE;
    L_AVAILABLE_GROUP_CODE_LIST  G_VARCHAR2_CODE_TABLE;
    L_RESPVIO_ENTRIES            G_RESPVIO_ENTRIES_TABLE;

    -- psomanat : 06:09:2006 : fix for bug 5256720
    L_FUNC_ID_LIST    G_FUNC_TABLE;
    counts            Number;
    listkey VARCHAR2(30) := NULL;
BEGIN
    --FND_FILE.put_line(fnd_file.log,'Wtite_Resp_Violat_to_table_rvl start '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));

    -- Logic :
    -- Check if the G_RESP_VIOLATIONS_LIST count is equal to 0
    -- If yes ,
    --       Then all the rsponsibility violations have been resolved.So we
    --       set the CORRECTED_FLAG= 'Y' for all responsibility violation
    -- If No,
    --      Get the existing responsibility violation
    --      For each exisitng responsibility violation
    --         Check if the responsibility is present in G_RESP_VIOLATIONS_LIST
    --         If Yes,
    --            Check if this responsibility is waived
    --            If yes,
    --               Set the CORRECTED_FLAG= 'Y' for the responsibility
    --            If No,
    --               Check if the responsibility still violates the constraint
    --               If No,
    --                  Set the CORRECTED_FLAG= 'Y' for the responsibility
    --               If Yes,
    --                  Populate the incompatible functions accessible to
    --                  responsibilities in AMW_VIOLAT_RESP_ENTRIES
    --         If No,
    --            Set the CORRECTED_FLAG= 'Y' for the responsibility
    IF (G_RESP_VIOLATIONS_LIST.COUNT = 0) THEN

        UPDATE AMW_VIOLATION_RESP
        SET CORRECTED_FLAG ='Y'
        WHERE VIOLATION_ID=p_violation_id;

        DELETE FROM AMW_VIOLAT_RESP_ENTRIES
        WHERE RESP_VIOLATION_ID IN (SELECT RESP_VIOLATION_ID FROM AMW_VIOLATION_RESP WHERE VIOLATION_ID=p_violation_id);

        RETURN;
    ELSE

        OPEN c_existing_resp_violation (p_violation_id);
        FETCH c_existing_resp_violation
        BULK COLLECT INTO L_EXISTING_APPL_ID_LIST,
                          L_EXISTING_RESP_ID_LIST,
                          L_EXISTING_RESP_VIO_ID_LIST;
        CLOSE c_existing_resp_violation;

        IF L_EXISTING_RESP_ID_LIST.COUNT = 0 THEN
            RETURN;
        END IF;

        OPEN c_constraint_entries (p_constraint_rev_id);
        FETCH c_constraint_entries BULK COLLECT INTO L_FUNCTION_ID_LIST,L_OBJECT_TYPE_LIST,L_GROUP_CODE_LIST;
        CLOSE c_constraint_entries;

        OPEN  c_resp_waived (p_constraint_rev_id);
        FETCH c_resp_waived BULK COLLECT INTO l_waiv_resp_id_list,l_waiv_resp_appl_id_list;
        CLOSE c_resp_waived;

        -- Put the waived responsibility in a associative array with
        -- application_id@responsibility_id as the key
        -- This will help us to identify the resposnibility waiver quickly as
        -- we need not iterate over the nested tables l_waiv_resp_id_list and
        -- l_waiv_resp_appl_id_list to check if the responsbility waiver exist or not
        IF (l_waiv_resp_id_list IS NOT NULL) AND (l_waiv_resp_id_list.FIRST IS NOT NULL) THEN
            FOR i IN l_waiv_resp_id_list.FIRST ..l_waiv_resp_id_list.LAST
            LOOP
                listkey:=l_waiv_resp_appl_id_list(i)||'@'||l_waiv_resp_id_list(i);
                l_waived_resp_appl_list(listkey):=l_waiv_resp_id_list(i);
            END LOOP;
        END IF;

        FOR i in L_EXISTING_RESP_ID_LIST.first .. L_EXISTING_RESP_ID_LIST.last
        LOOP
            listkey:=L_EXISTING_APPL_ID_LIST(i)||'@'||L_EXISTING_RESP_ID_LIST(i);
            IF G_RESP_VIOLATIONS_LIST.EXISTS(listkey) THEN

                DELETE FROM AMW_VIOLAT_RESP_ENTRIES
                WHERE RESP_VIOLATION_ID =L_EXISTING_RESP_VIO_ID_LIST(i);

                IF (l_waived_resp_appl_list.exists(listkey)) THEN
                    UPDATE AMW_VIOLATION_RESP
                    SET CORRECTED_FLAG ='Y'
                    WHERE VIOLATION_ID = p_violation_id
                    AND RESPONSIBILITY_ID = l_existing_resp_id_list(i)
                    AND APPLICATION_ID    = l_existing_appl_id_list(i);
                ELSE
                    L_RESPVIO_ENTRIES.DELETE();
                    L_FUNC_ID_LIST.DELETE();

                    L_FUNC_ID_LIST := G_RESP_VIOLATIONS_LIST(listkey);

                    IF (p_type_code = 'ALL' AND  L_FUNC_ID_LIST.COUNT = l_function_id_list.COUNT) THEN
                        FOR j IN  L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
                        LOOP
                            IF L_FUNC_ID_LIST.EXISTS(j) THEN
                                L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(j);
                                FOR k IN  L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                                LOOP
                                    INSERT INTO AMW_VIOLAT_RESP_ENTRIES(
                                        VIOLAT_RESP_ENTRY_ID,
                                        RESP_VIOLATION_ID,
                                        MENU_ID,
                                        FUNCTION_ID,
                                        ACCESS_GIVEN_DATE,
                                        ACCESS_GIVEN_BY_ID,
                                        OBJECT_TYPE,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_LOGIN,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        SECURITY_GROUP_ID,
                                        APPLICATION_ID
                                    )
                                    VALUES(
                                        AMW_VIOLAT_RESP_ENTRIES_S.NEXTVAL,
                                        L_EXISTING_RESP_VIO_ID_LIST(i),
                                        L_RESPVIO_ENTRIES(k).Menu_Id,
                                        L_RESPVIO_ENTRIES(k).Function_id,
                                        L_RESPVIO_ENTRIES(k).Access_Given_Date,
                                        L_RESPVIO_ENTRIES(k).Access_Given_By_Id,
                                        L_RESPVIO_ENTRIES(k).Object_type,
                                        sysdate,
                                        G_USER_ID,
                                        G_LOGIN_ID,
                                        sysdate,
                                        G_USER_ID,
                                        NULL,
                                        L_RESPVIO_ENTRIES(k).prog_appl_id
                                    );
                                END LOOP;
                            END IF;
                        END LOOP;
                    ELSIF p_type_code = 'ME' AND  L_FUNC_ID_LIST.COUNT >= 2 THEN
                        FOR j IN  L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
                        LOOP
                            IF L_FUNC_ID_LIST.EXISTS(j) then
                                L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(j);
                                FOR k IN  L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                                LOOP

                                    INSERT INTO AMW_VIOLAT_RESP_ENTRIES(
                                    VIOLAT_RESP_ENTRY_ID,
                                    resp_violation_id,
                                    MENU_ID,
                                    FUNCTION_ID,
                                    ACCESS_GIVEN_DATE,
                                    ACCESS_GIVEN_BY_ID,
                                    OBJECT_TYPE,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_LOGIN,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    SECURITY_GROUP_ID,
                                    APPLICATION_ID
                                    )
                                    VALUES(
                                        AMW_VIOLAT_RESP_ENTRIES_S.NEXTVAL,
                                        L_EXISTING_RESP_VIO_ID_LIST(i),
                                        L_RESPVIO_ENTRIES(k).Menu_Id,
                                        L_RESPVIO_ENTRIES(k).Function_id,
                                        L_RESPVIO_ENTRIES(k).Access_Given_Date,
                                        L_RESPVIO_ENTRIES(k).Access_Given_By_Id,
                                        L_RESPVIO_ENTRIES(k).Object_type,
                                        sysdate,
                                        G_USER_ID,
                                        G_LOGIN_ID,
                                        sysdate,
                                        G_USER_ID,
                                        NULL,
                                        L_RESPVIO_ENTRIES(k).prog_appl_id
                                    );
                                END LOOP;
                            END IF;
                        END LOOP;
                    ELSIF p_type_code = 'SET' THEN
                        L_AVAILABLE_GROUP_CODE_LIST.delete();

                        FOR j IN  L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
                        LOOP
                            IF L_FUNC_ID_LIST.EXISTS(j) then
                                L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(j);
                                FOR k IN  L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                                LOOP
                                    L_AVAILABLE_GROUP_CODE_LIST(L_RESPVIO_ENTRIES(k).group_code):= L_RESPVIO_ENTRIES(k).group_code;
                                    IF L_AVAILABLE_GROUP_CODE_LIST.COUNT >=2 THEN
                                        EXIT;
                                    END IF;
                                END LOOP;
                            END IF;
                        END LOOP;


                        IF (L_AVAILABLE_GROUP_CODE_LIST.COUNT)>=2 THEN

                            FOR j IN  L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
                            LOOP
                                IF L_FUNC_ID_LIST.EXISTS(j) then
                                    L_RESPVIO_ENTRIES:=L_FUNC_ID_LIST(j);
                                    FOR k IN  L_RESPVIO_ENTRIES.FIRST .. L_RESPVIO_ENTRIES.LAST
                                    LOOP
                                        INSERT INTO AMW_VIOLAT_RESP_ENTRIES(
                                            VIOLAT_RESP_ENTRY_ID,
                                            RESP_VIOLATION_ID,
                                            MENU_ID,
                                            FUNCTION_ID,
                                            ACCESS_GIVEN_DATE,
                                            ACCESS_GIVEN_BY_ID,
                                            OBJECT_TYPE,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            LAST_UPDATE_LOGIN,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            SECURITY_GROUP_ID,
                                            APPLICATION_ID
                                        )
                                        VALUES(
                                            AMW_VIOLAT_RESP_ENTRIES_S.NEXTVAL,
                                            L_EXISTING_RESP_VIO_ID_LIST(i),
                                            L_RESPVIO_ENTRIES(k).Menu_Id,
                                            L_RESPVIO_ENTRIES(k).Function_id,
                                            L_RESPVIO_ENTRIES(k).Access_Given_Date,
                                            L_RESPVIO_ENTRIES(k).Access_Given_By_Id,
                                            L_RESPVIO_ENTRIES(k).Object_type,
                                            sysdate,
                                                G_USER_ID,
                                            G_LOGIN_ID,
                                            sysdate,
                                            G_USER_ID,
                                            NULL,
                                            L_RESPVIO_ENTRIES(k).prog_appl_id
                                        );
                                    END LOOP;
                                END IF;
                            END LOOP;
                        ELSE
                            -- The responsbility does not have atleast one incompatible
                            -- functions from both the group
                            -- So it does not violates the constraint
                            UPDATE AMW_VIOLATION_RESP
                            SET CORRECTED_FLAG    = 'Y'
                            WHERE VIOLATION_ID    = p_violation_id
                            AND RESPONSIBILITY_ID = l_existing_resp_id_list(i)
                            AND APPLICATION_ID    = l_existing_appl_id_list(i);
                        END IF;
                    END IF;
                    -- we check if the responsibility still violates the constraint
                    -- we check this for object_type = ALL or ME
                    IF (p_type_code = 'ALL' AND  L_FUNC_ID_LIST.COUNT <> l_function_id_list.COUNT) OR
                       (p_type_code = 'ME' AND  L_FUNC_ID_LIST.COUNT <= 1) THEN
                            UPDATE AMW_VIOLATION_RESP
                            SET CORRECTED_FLAG ='Y'
                            WHERE VIOLATION_ID = p_violation_id
                            AND RESPONSIBILITY_ID = l_existing_resp_id_list(i)
                            AND APPLICATION_ID    = l_existing_appl_id_list(i);
                    END IF;
                END IF;
            ELSE
                UPDATE  AMW_VIOLATION_RESP
                SET     CORRECTED_FLAG = 'Y'
                WHERE   VIOLATION_ID = p_violation_id
                AND     RESPONSIBILITY_ID = l_existing_resp_id_list(i)
                AND     APPLICATION_ID    = l_existing_appl_id_list(i);
            END IF;
        END LOOP;
    END IF;
    --FND_FILE.put_line(fnd_file.log,'Wtite_Resp_Violat_to_table_rvl end '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));
END;

-- ===============================================================
-- Private Procedure name
--          Check_For_Func_Cst_ALL
--
-- Purpose
--          for constraint type = 'Function: ALL or None' (type_code = 'ALL')
--          check violation for specified constraint
--          this is private procedure,
--          should not call this procedure directly
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--
-- Notes
--
-- History
--          01.06.2005 tsho: starting from AMW.D, params changed for Populate_User_Id_List_For_Cst
--          05.17.2005 tsho: starting from AMW.E, consider Role, GLOBAL Grant/USER Grant
--          05.25.2005 tsho: consider Concurrent Programs as constraint entries
-- ===============================================================
PROCEDURE Check_For_Func_Cst_ALL (
    p_constraint_rev_id          IN   NUMBER,
    p_violation_id               IN   NUMBER,
    p_type_code                  IN   VARCHAR2,
    p_revalidate_flag            IN   VARCHAR2  := NULL
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Check_For_Func_Cst_ALL';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;


-- find the number of constraint entries(incompatible functions) by specified constraint_rev_id
l_constraint_function_count NUMBER;
CURSOR c_constraint_entries_count (l_constraint_rev_id IN NUMBER) IS
      SELECT count(*)
        FROM amw_constraint_entries
	   WHERE constraint_rev_id=l_constraint_rev_id;

    CURSOR c_valid_user_waivers (l_constraint_rev_id IN NUMBER) IS
        SELECT  PK1
        FROM    amw_constraint_waivers_b
        WHERE   constraint_rev_id = l_constraint_rev_id
        AND     object_type = 'USER'
        AND     start_date <= sysdate AND (end_date >= sysdate or end_date is null);

    CURSOR c_original_user_violation_id (l_violation_id IN NUMBER) IS
        SELECT  violated_by_id,user_violation_id
        FROM    amw_violation_users
        WHERE   violation_id = l_violation_id;

    l_user_access_func_list         G_NUMBER_TABLE;
    l_user_access_func_nowaiv_list  G_NUMBER_TABLE;
    l_waive_user_id NUMBER;
    l_user_violation_id NUMBER;
    l_user_id NUMBER;

    L_USERVIO_ENTRIES G_USERVIO_ENTRIES_TABLE;
    L_FUNC_ID_LIST    G_FUNCS_TABLE;

BEGIN

    IF ((p_constraint_rev_id IS NULL) AND (p_type_code IS NULL)) THEN
        Return;
    END IF;

    -- find the number of constraint entries(incompatible functions) by specified constraint_rev_id
    OPEN c_constraint_entries_count (p_constraint_rev_id);
    FETCH c_constraint_entries_count INTO l_constraint_function_count;
    CLOSE c_constraint_entries_count;

   -- Identify the Responsibilities having access to atleast one incompatible function
   -- The incompatible function should not be excluded via function or menu exclusion
    Populate_Ptnl_Access_List(p_constraint_rev_id  => p_constraint_rev_id);

   -- Identify the Responsibilities having access to the incompatible functions
   -- as per the constraint object type.
    IF p_revalidate_flag IS NULL THEN
        Write_Resp_Violat_to_table(p_violation_id,p_constraint_rev_id,p_type_code);
    ELSE
        Write_Resp_Violat_to_table_rvl(p_violation_id,p_constraint_rev_id,p_type_code);
    END IF;

    -- Identify the users having access to the incompatible functions.
    -- We identify the Responsibilities,Roles,Grants assigned to a user
    -- making him a violating user
    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
        Populate_User_Vio_For_Vlt(p_violation_id       => p_violation_id,
                                  p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    ELSE
        Populate_User_Vio_For_Cst(p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    END IF;

    --FND_FILE.put_line(fnd_file.log,'Populate user violation Began '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));

    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN

        -- When we revalidate a Constraint violation, we identify the existing
        -- violating users and store their corresponding user violation id
        -- in a associative array for performance.
        -- Now we can get the User violation id for a user by using the user id
        -- as key on G_User_Violation_Id_list
        G_User_Violation_Id_list.DELETE();
        OPEN c_original_user_violation_id(p_violation_id);
        LOOP
            FETCH c_original_user_violation_id INTO l_user_id,l_user_violation_id;
            EXIT WHEN c_original_user_violation_id%NOTFOUND;
            G_User_Violation_Id_list(l_user_id):=l_user_violation_id;
        END LOOP;
        CLOSE c_original_user_violation_id;
    ELSE

        -- We store the users marked as user waiver for the current constraint
        -- in a associative array for performamce.
        -- Now we can identify if a user is waived or not by checking if
        -- the user is in the G_User_Waiver_List associative array. we use the
        -- user id as index key
        G_User_Waiver_List.DELETE();
        OPEN c_valid_user_waivers(p_constraint_rev_id);
        LOOP
            FETCH c_valid_user_waivers INTO l_waive_user_id;
            EXIT WHEN c_valid_user_waivers%NOTFOUND;
            G_User_Waiver_List(l_waive_user_id):=l_waive_user_id;
        END LOOP;
        CLOSE c_valid_user_waivers;
    END IF;

    -- Logic :
    -- G_USER_VIOLATIONS_LIST contains the user having access to atleast one
    -- of the incompatible function via responsibilities,role or grants
    -- assigned to him.
    -- We check if the users has accesss to all the incompatible functions,
    -- if yes we mark him as violating user.
    IF (G_USER_VIOLATIONS_LIST IS NOT NULL) AND (G_USER_VIOLATIONS_LIST.FIRST IS NOT NULL) THEN
        FOR i in G_USER_VIOLATIONS_LIST.FIRST .. G_USER_VIOLATIONS_LIST.LAST
        LOOP
            IF G_USER_VIOLATIONS_LIST.EXISTS(i) THEN
                l_user_access_func_list.DELETE();
                l_user_access_func_nowaiv_list.DELETE();
                L_FUNC_ID_LIST:=G_USER_VIOLATIONS_LIST(i);
                FOR j IN L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
                LOOP
                    IF L_FUNC_ID_LIST.EXISTS(j) THEN
                        L_USERVIO_ENTRIES:=L_FUNC_ID_LIST(j);
                        FOR k IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
                        LOOP
                            l_user_access_func_list(L_USERVIO_ENTRIES(k).Function_Id):=L_USERVIO_ENTRIES(k).Function_Id;
                            IF L_USERVIO_ENTRIES(k).Waived = 'N' THEN
                                l_user_access_func_nowaiv_list(L_USERVIO_ENTRIES(k).Function_Id):=L_USERVIO_ENTRIES(k).Function_Id;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
                IF (l_user_access_func_list.COUNT = l_constraint_function_count) THEN
                    IF (l_user_access_func_nowaiv_list.COUNT = l_constraint_function_count) THEN
                        Write_Func_To_Table_For_User(p_violation_id, p_constraint_rev_id,i, NULL, p_revalidate_flag);
                    ELSE
                         Write_Func_To_Table_For_User(p_violation_id, p_constraint_rev_id,i,'Y', p_revalidate_flag);
                    END IF;
                ELSE
                    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
                        Update_Violation_User (
                            p_user_violation_id => NULL,
                            p_violation_id      => p_violation_id,
                            p_violated_by_id    => i,
                            p_corrected_flag    => 'Y');
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END IF;
    --FND_FILE.put_line(fnd_file.log,'comming out of api '||L_API_NAME);
END Check_For_Func_Cst_ALL;


-- ===============================================================
-- Private Procedure name
--          Check_For_Func_Cst_ME
--
-- Purpose
--          for constraint type = 'Function: Mutuallly Exclusive' (type_code = 'ME')
--          check violation for specified constraint
--          this is private procedure,
--          should not call this procedure directly
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--
-- Notes
--
-- History
--          01.06.2005 tsho: starting from AMW.D, params changed for Populate_User_Id_List_For_Cst
--          05.17.2005 tsho: starting from AMW.E, consider Role, GLOBAL Grant/USER Grant
--          05.25.2005 tsho: consider Concurrent Programs as constraint entries
-- ===============================================================
PROCEDURE Check_For_Func_Cst_ME (
    p_constraint_rev_id          IN   NUMBER,
    p_violation_id               IN   NUMBER,
    p_type_code                  IN   VARCHAR2,
    p_revalidate_flag            IN   VARCHAR2  := NULL
)
IS
    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Check_For_Func_Cst_ME';
    L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

    CURSOR c_valid_user_waivers (l_constraint_rev_id IN NUMBER) IS
        SELECT  PK1
        FROM    amw_constraint_waivers_b
        WHERE   constraint_rev_id = l_constraint_rev_id
        AND     object_type = 'USER'
        AND     start_date <= sysdate AND (end_date >= sysdate or end_date is null);

    CURSOR c_original_user_violation_id (l_violation_id IN NUMBER) IS
        SELECT  violated_by_id,user_violation_id
        FROM    amw_violation_users
        WHERE   violation_id = l_violation_id;

    l_user_access_func_list         G_NUMBER_TABLE;
    l_user_access_func_nowaiv_list  G_NUMBER_TABLE;
    l_waive_user_id NUMBER;
    l_user_violation_id NUMBER;
    l_user_id NUMBER;

    L_USERVIO_ENTRIES G_USERVIO_ENTRIES_TABLE;
    L_FUNC_ID_LIST    G_FUNCS_TABLE;
BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    IF ((p_constraint_rev_id IS NULL) AND (p_type_code IS NULL)) THEN
        Return;
    END IF;

   -- Identify the Responsibilities having access to atleast one incompatible function
   -- The incompatible function should not be excluded via function or menu exclusion
   Populate_Ptnl_Access_List(p_constraint_rev_id  => p_constraint_rev_id);

   -- Identify the Responsibilities having access to the incompatible functions
   -- as per the constraint object type.
   IF p_revalidate_flag IS NULL THEN
        Write_Resp_Violat_to_table(p_violation_id,p_constraint_rev_id,p_type_code);
    ELSE
        Write_Resp_Violat_to_table_rvl(p_violation_id,p_constraint_rev_id,p_type_code);
    END IF;

    -- Identify the users having access to the incompatible functions.
    -- We identify the Responsibilities,Roles,Grants assigned to a user
    -- making him a violating user
    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
        Populate_User_Vio_For_Vlt(p_violation_id       => p_violation_id,
                                  p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    ELSE
        Populate_User_Vio_For_Cst(p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    END IF;

    --FND_FILE.put_line(fnd_file.log,'Populate user violation Began '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));

    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN

        -- When we revalidate a Constraint violation, we identify the existing
        -- violating users and store their corresponding user violation id
        -- in a associative array for performance.
        -- Now we can get the User violation id for a user by using the user id
        -- as key on G_User_Violation_Id_list
        G_User_Violation_Id_list.DELETE();
        OPEN c_original_user_violation_id(p_violation_id);
        LOOP
            FETCH c_original_user_violation_id INTO l_user_id,l_user_violation_id;
            EXIT WHEN c_original_user_violation_id%NOTFOUND;
            G_User_Violation_Id_list(l_user_id):=l_user_violation_id;
        END LOOP;
        CLOSE c_original_user_violation_id;
    ELSE

        -- We store the users marked as user waiver for the current constraint
        -- in a associative array for performamce.
        -- Now we can identify if a user is waived or not by checking if
        -- the user is in the G_User_Waiver_List associative array. we use the
        -- user id as index key
        G_User_Waiver_List.DELETE();
        OPEN c_valid_user_waivers(p_constraint_rev_id);
        LOOP
            FETCH c_valid_user_waivers INTO l_waive_user_id;
            EXIT WHEN c_valid_user_waivers%NOTFOUND;
            G_User_Waiver_List(l_waive_user_id):=l_waive_user_id;
        END LOOP;
        CLOSE c_valid_user_waivers;
    END IF;

    -- Logic :
    -- G_USER_VIOLATIONS_LIST contains the user having access to atleast one
    -- of the incompatible function via responsibilities,role or grants
    -- assigned to him.
    -- We check if the users has access to atleast 2 incompatible functions,
    -- if yes we mark him as violating user.
    IF (G_USER_VIOLATIONS_LIST IS NOT NULL) AND (G_USER_VIOLATIONS_LIST.FIRST IS NOT NULL) THEN
        FOR i in G_USER_VIOLATIONS_LIST.FIRST .. G_USER_VIOLATIONS_LIST.LAST
        LOOP
            IF G_USER_VIOLATIONS_LIST.EXISTS(i) THEN
                l_user_access_func_list.DELETE();
                l_user_access_func_nowaiv_list.DELETE();
                L_FUNC_ID_LIST:=G_USER_VIOLATIONS_LIST(i);
                FOR j IN L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
                LOOP
                    IF L_FUNC_ID_LIST.EXISTS(j) THEN
                        L_USERVIO_ENTRIES:=L_FUNC_ID_LIST(j);
                        FOR k IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
                        LOOP
                            l_user_access_func_list(L_USERVIO_ENTRIES(k).Function_Id):=L_USERVIO_ENTRIES(k).Function_Id;
                            IF L_USERVIO_ENTRIES(k).Waived = 'N' THEN
                                l_user_access_func_nowaiv_list(L_USERVIO_ENTRIES(k).Function_Id):=L_USERVIO_ENTRIES(k).Function_Id;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
                IF (l_user_access_func_list.COUNT >= 2) THEN
                    IF (l_user_access_func_nowaiv_list.COUNT >= 2) THEN
                        Write_Func_To_Table_For_User(p_violation_id, p_constraint_rev_id,i, NULL, p_revalidate_flag);
                    ELSE
                         Write_Func_To_Table_For_User(p_violation_id, p_constraint_rev_id,i,'Y', p_revalidate_flag);
                    END IF;
                ELSE
                    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
                        Update_Violation_User (
                            p_user_violation_id => NULL,
                            p_violation_id      => p_violation_id,
                            p_violated_by_id    => i,
                            p_corrected_flag    => 'Y');
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END IF;

    --FND_FILE.put_line(fnd_file.log,'Populate user violation End '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));
END Check_For_Func_Cst_ME;


-- ===============================================================
-- Private Procedure name
--          Check_For_Func_Cst_SET
--
-- Purpose
--          for constraint type = 'Function: Incompatible Sets' (type_code = 'SET')
--          check violation for specified constraint
--          this is private procedure,
--          should not call this procedure directly
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--
-- Notes
--
-- History
--          05.13.2005 tsho: create for AMW.E
--          05.25.2005 tsho: consider Concurrent Programs as constraint entries
-- ===============================================================
PROCEDURE Check_For_Func_Cst_SET (
    p_constraint_rev_id          IN   NUMBER,
    p_violation_id               IN   NUMBER,
    p_type_code                  IN   VARCHAR2,
    p_revalidate_flag            IN   VARCHAR2  := NULL
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Check_For_Func_Cst_SET';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

    CURSOR c_valid_user_waivers (l_constraint_rev_id IN NUMBER) IS
        SELECT  PK1
        FROM    amw_constraint_waivers_b
        WHERE   constraint_rev_id = l_constraint_rev_id
        AND     object_type = 'USER'
        AND     start_date <= sysdate AND (end_date >= sysdate or end_date is null);

    CURSOR c_original_user_violation_id (l_violation_id IN NUMBER) IS
        SELECT  violated_by_id,user_violation_id
        FROM    amw_violation_users
        WHERE   violation_id = l_violation_id;

    l_user_access_func_list         G_NUMBER_TABLE;
    l_user_access_func_nowaiv_list  G_NUMBER_TABLE;
    l_waive_user_id NUMBER;
    l_user_violation_id NUMBER;
    l_user_id NUMBER;

    -- 05.24.2005 tsho: store those group_code of accessible functions by an user
    l_user_access_grp_list G_VARCHAR2_CODE_TABLE;
    l_user_access_grp_nowaiv_list G_VARCHAR2_CODE_TABLE;

    L_USERVIO_ENTRIES G_USERVIO_ENTRIES_TABLE;
    L_FUNC_ID_LIST    G_FUNCS_TABLE;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    IF ((p_constraint_rev_id IS NULL) AND (p_type_code IS NULL)) THEN
        Return;
    END IF;

   -- Identify the Responsibilities having access to atleast one incompatible function
   -- The incompatible function should not be excluded via function or menu exclusion
    Populate_Ptnl_Access_List(p_constraint_rev_id  => p_constraint_rev_id);

   -- Identify the Responsibilities having access to the incompatible functions
   -- as per the constraint object type.
    IF p_revalidate_flag IS NULL THEN
        Write_Resp_Violat_to_table(p_violation_id,p_constraint_rev_id,p_type_code);
    ELSE
        Write_Resp_Violat_to_table_rvl(p_violation_id,p_constraint_rev_id,p_type_code);
    END IF;

    -- Identify the users having access to the incompatible functions.
    -- We identify the Responsibilities,Roles,Grants assigned to a user
    -- making him a violating user
    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
        Populate_User_Vio_For_Vlt(p_violation_id       => p_violation_id,
                                  p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    ELSE
        Populate_User_Vio_For_Cst(p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    END IF;

    --FND_FILE.put_line(fnd_file.log,'Populate user violation Began '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));

    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN

        -- When we revalidate a Constraint violation, we identify the existing
        -- violating users and store their corresponding user violation id
        -- in a associative array for performance.
        -- Now we can get the User violation id for a user by using the user id
        -- as key on G_User_Violation_Id_list
        G_User_Violation_Id_list.DELETE();
        OPEN c_original_user_violation_id(p_violation_id);
        LOOP
            FETCH c_original_user_violation_id INTO l_user_id,l_user_violation_id;
            EXIT WHEN c_original_user_violation_id%NOTFOUND;
            G_User_Violation_Id_list(l_user_id):=l_user_violation_id;
        END LOOP;
        CLOSE c_original_user_violation_id;
    ELSE

        -- We store the users marked as user waiver for the current constraint
        -- in a associative array for performamce.
        -- Now we can identify if a user is waived or not by checking if
        -- the user is in the G_User_Waiver_List associative array. we use the
        -- user id as index key
        G_User_Waiver_List.DELETE();
        OPEN c_valid_user_waivers(p_constraint_rev_id);
        LOOP
            FETCH c_valid_user_waivers INTO l_waive_user_id;
            EXIT WHEN c_valid_user_waivers%NOTFOUND;
            G_User_Waiver_List(l_waive_user_id):=l_waive_user_id;
        END LOOP;
        CLOSE c_valid_user_waivers;
    END IF;

    -- Logic :
    -- G_USER_VIOLATIONS_LIST contains the user having access to atleast one
    -- of the incompatible function via responsibilities,role or grants
    -- assigned to him.
    -- We check if the users has access to atleast one incompatible functions
    -- from each group, if yes we mark him as violating user.
    IF (G_USER_VIOLATIONS_LIST IS NOT NULL) AND (G_USER_VIOLATIONS_LIST.FIRST IS NOT NULL) THEN
        FOR i in G_USER_VIOLATIONS_LIST.FIRST .. G_USER_VIOLATIONS_LIST.LAST
        LOOP
            IF G_USER_VIOLATIONS_LIST.EXISTS(i) THEN
                l_user_access_grp_list.DELETE();
                l_user_access_grp_nowaiv_list.DELETE();
                L_FUNC_ID_LIST:=G_USER_VIOLATIONS_LIST(i);
                FOR j IN L_FUNC_ID_LIST.FIRST .. L_FUNC_ID_LIST.LAST
                LOOP
                    IF L_FUNC_ID_LIST.EXISTS(j) THEN
                        L_USERVIO_ENTRIES:=L_FUNC_ID_LIST(j);
                        FOR k IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
                        LOOP
                            l_user_access_grp_list(L_USERVIO_ENTRIES(k).group_code):=L_USERVIO_ENTRIES(k).group_code;
                            IF L_USERVIO_ENTRIES(k).Waived = 'N' THEN
                                l_user_access_grp_nowaiv_list(L_USERVIO_ENTRIES(k).group_code):=L_USERVIO_ENTRIES(k).group_code;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
                IF (l_user_access_grp_list.COUNT >= 2) THEN
                    IF (l_user_access_grp_nowaiv_list.COUNT >= 2) THEN
                        Write_Func_To_Table_For_User(p_violation_id, p_constraint_rev_id,i, NULL, p_revalidate_flag);
                    ELSE
                         Write_Func_To_Table_For_User(p_violation_id, p_constraint_rev_id,i,'Y', p_revalidate_flag);
                    END IF;
                ELSE
                    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
                        Update_Violation_User (
                            p_user_violation_id => NULL,
                            p_violation_id      => p_violation_id,
                            p_violated_by_id    => i,
                            p_corrected_flag    => 'Y');
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END IF;
    --FND_FILE.put_line(fnd_file.log,'Populate user violation End '||to_char(sysdate,'DD-MON-RRRR:HH24:MI:SS'));
    --FND_FILE.put_line(fnd_file.log,'Commit Out '||L_API_NAME);
END Check_For_Func_Cst_SET;


-- ===============================================================
-- Private Procedure name
--          Check_For_Resp_Cst_ALL
--
-- Purpose
--          for constraint type = 'Responsibility: ALL or None' (type_code = 'RESPALL')
--          check violation for specified constraint
--          this is private procedure,
--          should not call this procedure directly
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--
-- Notes
--
-- History
--          01.06.2005 tsho: starting from AMW.D,
--                           consider Incompatible Responsibilities.
-- ===============================================================
PROCEDURE Check_For_Resp_Cst_ALL (
    p_constraint_rev_id          IN   NUMBER,
    p_violation_id               IN   NUMBER,
    p_type_code                  IN   VARCHAR2,
    p_revalidate_flag            IN   VARCHAR2  := NULL
)
IS

    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Check_For_Resp_Cst_ALL';
    L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

    -- store how many incompatible responsibilities he can access so far
    l_access_resp_count    NUMBER;
    -- find the number of constraint entries(incompatible responsibilities) by specified constraint_rev_id
    l_constraint_resp_count NUMBER;
    CURSOR c_constraint_entries_count (l_constraint_rev_id IN NUMBER) IS
      SELECT count(*)
        FROM amw_constraint_entries
	   WHERE constraint_rev_id=l_constraint_rev_id;

    CURSOR c_valid_user_waivers (l_constraint_rev_id IN NUMBER) IS
        SELECT  PK1
        FROM    amw_constraint_waivers_b
        WHERE   constraint_rev_id = l_constraint_rev_id
        AND     object_type = 'USER'
        AND     start_date <= sysdate AND (end_date >= sysdate or end_date is null);

    CURSOR c_original_user_violation_id (l_violation_id IN NUMBER) IS
        SELECT  violated_by_id,user_violation_id
        FROM    amw_violation_users
        WHERE   violation_id = l_violation_id;

    L_RESP_ID_LIST    G_RESPS_TABLE;
    l_waive_user_id NUMBER;
    l_user_violation_id NUMBER;
    l_user_id NUMBER;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    IF ((p_constraint_rev_id IS NULL) AND (p_type_code IS NULL)) THEN
        Return;
    END IF;

    OPEN c_constraint_entries_count (p_constraint_rev_id);
    FETCH c_constraint_entries_count INTO l_constraint_resp_count;
    CLOSE c_constraint_entries_count;

    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
        Populate_User_Vio_For_Vlt(p_violation_id       => p_violation_id,
                                  p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    ELSE
        Populate_User_Vio_For_Cst(p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    END IF;

    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN

        -- When we revalidate a Constraint violation, we identify the existing
        -- violating users and store their corresponding user violation id
        -- in a associative array for performance.
        -- Now we can get the User violation id for a user by using the user id
        -- as key on G_User_Violation_Id_list
        G_User_Violation_Id_list.DELETE();
        OPEN c_original_user_violation_id(p_violation_id);
        LOOP
            FETCH c_original_user_violation_id INTO l_user_id,l_user_violation_id;
            EXIT WHEN c_original_user_violation_id%NOTFOUND;
            G_User_Violation_Id_list(l_user_id):=l_user_violation_id;
        END LOOP;
        CLOSE c_original_user_violation_id;
    ELSE

        -- We store the users marked as user waiver for the current constraint
        -- in a associative array for performamce.
        -- Now we can identify if a user is waived or not by checking if
        -- the user is in the G_User_Waiver_List associative array. we use the
        -- user id as index key
        G_User_Waiver_List.DELETE();
        OPEN c_valid_user_waivers(p_constraint_rev_id);
        LOOP
            FETCH c_valid_user_waivers INTO l_waive_user_id;
            EXIT WHEN c_valid_user_waivers%NOTFOUND;
            G_User_Waiver_List(l_waive_user_id):=l_waive_user_id;
        END LOOP;
        CLOSE c_valid_user_waivers;
    END IF;

    -- Logic :
    -- G_USER_RESP_VIO_LIST contains incompatible responsibilities
    -- accessible to Users
    -- We check if the users has access all incompatible responsibilities
    -- if yes we mark him as violating user.
    IF (G_USER_RESP_VIO_LIST IS NOT NULL) AND (G_USER_RESP_VIO_LIST.FIRST IS NOT NULL) THEN
        FOR i in G_USER_RESP_VIO_LIST.FIRST .. G_USER_RESP_VIO_LIST.LAST
        LOOP
            IF G_USER_RESP_VIO_LIST.EXISTS(i) THEN
                L_RESP_ID_LIST:=G_USER_RESP_VIO_LIST(i);

                IF (L_RESP_ID_LIST.COUNT = l_constraint_resp_count) THEN
                        Write_Resp_To_Table_For_User(p_violation_id, p_constraint_rev_id, i, p_revalidate_flag);
                ELSE
                        -- 05.23.2005 tsho: user doesn't violate this constraint
                        -- if this check is for revalidation (ie, p_revalidate_flag = 'Y'), update the corrected_flag to 'Y' for this user
                    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
                            Update_Violation_User (
                                p_user_violation_id => NULL,
                                p_violation_id      => p_violation_id,
                                p_violated_by_id    => i,
                                p_corrected_flag    => 'Y');
                    END IF; -- end of if: p_revalidate_flag
                END IF; -- end of if: G_UPV_RESPONSIBILITY_ID_LIST.COUNT >= 2
            END IF;
        END LOOP;
    END IF;
    --FND_FILE.put_line(fnd_file.log,'out  '||L_API_NAME);
END Check_For_Resp_Cst_ALL;


-- ===============================================================
-- Private Procedure name
--          Check_For_Resp_Cst_ME
--
-- Purpose
--          for constraint type = 'Responsibility: Mutuallly Exclusive' (type_code = 'RESPME')
--          check violation for specified constraint
--          this is private procedure,
--          should not call this procedure directly
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--
-- Notes
--
-- History
--          01.06.2005 tsho: starting from AMW.D,
--                           consider Incompatible Responsibilities.
-- ===============================================================
PROCEDURE Check_For_Resp_Cst_ME (
    p_constraint_rev_id          IN   NUMBER,
    p_violation_id               IN   NUMBER,
    p_type_code                  IN   VARCHAR2,
    p_revalidate_flag            IN   VARCHAR2  := NULL
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Check_For_Resp_Cst_ME';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

    CURSOR c_valid_user_waivers (l_constraint_rev_id IN NUMBER) IS
        SELECT  PK1
        FROM    amw_constraint_waivers_b
        WHERE   constraint_rev_id = l_constraint_rev_id
        AND     object_type = 'USER'
        AND     start_date <= sysdate AND (end_date >= sysdate or end_date is null);

    CURSOR c_original_user_violation_id (l_violation_id IN NUMBER) IS
        SELECT  violated_by_id,user_violation_id
        FROM    amw_violation_users
        WHERE   violation_id = l_violation_id;

    L_RESP_ID_LIST    G_RESPS_TABLE;
    l_waive_user_id NUMBER;
    l_user_violation_id NUMBER;
    l_user_id NUMBER;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    IF ((p_constraint_rev_id IS NULL) AND (p_type_code IS NULL)) THEN
        Return;
    END IF;

    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
        Populate_User_Vio_For_Vlt(p_violation_id       => p_violation_id,
                                  p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    ELSE
        Populate_User_Vio_For_Cst(p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    END IF;

    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN

        -- When we revalidate a Constraint violation, we identify the existing
        -- violating users and store their corresponding user violation id
        -- in a associative array for performance.
        -- Now we can get the User violation id for a user by using the user id
        -- as key on G_User_Violation_Id_list
        G_User_Violation_Id_list.DELETE();
        OPEN c_original_user_violation_id(p_violation_id);
        LOOP
            FETCH c_original_user_violation_id INTO l_user_id,l_user_violation_id;
            EXIT WHEN c_original_user_violation_id%NOTFOUND;
            G_User_Violation_Id_list(l_user_id):=l_user_violation_id;
        END LOOP;
        CLOSE c_original_user_violation_id;
    ELSE

        -- We store the users marked as user waiver for the current constraint
        -- in a associative array for performamce.
        -- Now we can identify if a user is waived or not by checking if
        -- the user is in the G_User_Waiver_List associative array. we use the
        -- user id as index key
        G_User_Waiver_List.DELETE();
        OPEN c_valid_user_waivers(p_constraint_rev_id);
        LOOP
            FETCH c_valid_user_waivers INTO l_waive_user_id;
            EXIT WHEN c_valid_user_waivers%NOTFOUND;
            G_User_Waiver_List(l_waive_user_id):=l_waive_user_id;
        END LOOP;
        CLOSE c_valid_user_waivers;
    END IF;

    -- Logic :
    -- G_USER_RESP_VIO_LIST contains incompatible responsibilities
    -- accessible to Users
    -- We check if the users has access to atleast one incompatible responsibilities
    -- if yes we mark him as violating user.
    IF (G_USER_RESP_VIO_LIST IS NOT NULL) AND (G_USER_RESP_VIO_LIST.FIRST IS NOT NULL) THEN
        FOR i in G_USER_RESP_VIO_LIST.FIRST .. G_USER_RESP_VIO_LIST.LAST
        LOOP
            IF G_USER_RESP_VIO_LIST.EXISTS(i) THEN
                L_RESP_ID_LIST:=G_USER_RESP_VIO_LIST(i);
                IF (L_RESP_ID_LIST.COUNT >= 2) THEN
                        Write_Resp_To_Table_For_User(p_violation_id, p_constraint_rev_id, i, p_revalidate_flag);
                ELSE
                        -- 05.23.2005 tsho: user doesn't violate this constraint
                        -- if this check is for revalidation (ie, p_revalidate_flag = 'Y'), update the corrected_flag to 'Y' for this user
                    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
                            Update_Violation_User (
                                p_user_violation_id => NULL,
                                p_violation_id      => p_violation_id,
                                p_violated_by_id    => i,
                                p_corrected_flag    => 'Y');
                    END IF; -- end of if: p_revalidate_flag
                END IF; -- end of if: G_UPV_RESPONSIBILITY_ID_LIST.COUNT >= 2
            END IF;
        END LOOP;
    END IF;
END Check_For_Resp_Cst_ME;


-- ===============================================================
-- Private Procedure name
--          Check_For_Resp_Cst_SET
--
-- Purpose
--          for constraint type = 'Responsibility: Incompatible Sets' (type_code = 'RESPSET')
--          check violation for specified constraint
--          this is private procedure,
--          should not call this procedure directly
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--
-- Notes
--
-- History
--          05.13.2005 tsho: create for AMW.E
-- ===============================================================
PROCEDURE Check_For_Resp_Cst_SET (
    p_constraint_rev_id          IN   NUMBER,
    p_violation_id               IN   NUMBER,
    p_type_code                  IN   VARCHAR2,
    p_revalidate_flag            IN   VARCHAR2  := NULL
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Check_For_Resp_Cst_SET';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;
-- store how many incompatible responsibilities he can access so far
l_access_resp_count    NUMBER;

-- 05.24.2005 tsho: store those group_code of accessible functions by an user
l_user_access_grp_list G_VARCHAR2_CODE_TABLE;


    L_USERVIO_ENTRIES G_USERVIO_ENTRIES_TABLE;
    L_RESP_ID_LIST    G_RESPS_TABLE;
    l_waive_user_id NUMBER;
    l_user_violation_id NUMBER;
    l_user_id NUMBER;
    listkey VARCHAR2(30) := NULL;

    CURSOR c_valid_user_waivers (l_constraint_rev_id IN NUMBER) IS
        SELECT  PK1
        FROM    amw_constraint_waivers_b
        WHERE   constraint_rev_id = l_constraint_rev_id
        AND     object_type = 'USER'
        AND     start_date <= sysdate AND (end_date >= sysdate or end_date is null);

    CURSOR c_original_user_violation_id (l_violation_id IN NUMBER) IS
        SELECT  violated_by_id,user_violation_id
        FROM    amw_violation_users
        WHERE   violation_id = l_violation_id;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    IF ((p_constraint_rev_id IS NULL) AND (p_type_code IS NULL)) THEN
        Return;
    END IF;

    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
        Populate_User_Vio_For_Vlt(p_violation_id       => p_violation_id,
                                  p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    ELSE
        Populate_User_Vio_For_Cst(p_constraint_rev_id  => p_constraint_rev_id,
                                  p_type_code          => p_type_code);
    END IF;

    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN

        -- When we revalidate a Constraint violation, we identify the existing
        -- violating users and store their corresponding user violation id
        -- in a associative array for performance.
        -- Now we can get the User violation id for a user by using the user id
        -- as key on G_User_Violation_Id_list
        G_User_Violation_Id_list.DELETE();
        OPEN c_original_user_violation_id(p_violation_id);
        LOOP
            FETCH c_original_user_violation_id INTO l_user_id,l_user_violation_id;
            EXIT WHEN c_original_user_violation_id%NOTFOUND;
            G_User_Violation_Id_list(l_user_id):=l_user_violation_id;
        END LOOP;
        CLOSE c_original_user_violation_id;
    ELSE

        -- We store the users marked as user waiver for the current constraint
        -- in a associative array for performamce.
        -- Now we can identify if a user is waived or not by checking if
        -- the user is in the G_User_Waiver_List associative array. we use the
        -- user id as index key
        G_User_Waiver_List.DELETE();
        OPEN c_valid_user_waivers(p_constraint_rev_id);
        LOOP
            FETCH c_valid_user_waivers INTO l_waive_user_id;
            EXIT WHEN c_valid_user_waivers%NOTFOUND;
            G_User_Waiver_List(l_waive_user_id):=l_waive_user_id;
        END LOOP;
        CLOSE c_valid_user_waivers;
    END IF;

    -- Logic :
    -- G_USER_RESP_VIO_LIST contains incompatible responsibilities
    -- accessible to Users
    -- We check if the users has access to atleast one incompatible responsibilities
    -- from each group
    -- if yes we mark him as violating user.
    IF (G_USER_RESP_VIO_LIST IS NOT NULL) AND (G_USER_RESP_VIO_LIST.FIRST IS NOT NULL) THEN
        FOR i in G_USER_RESP_VIO_LIST.FIRST .. G_USER_RESP_VIO_LIST.LAST
        LOOP
            IF G_USER_RESP_VIO_LIST.EXISTS(i) THEN
                l_user_access_grp_list.DELETE();
                L_RESP_ID_LIST:=G_USER_RESP_VIO_LIST(i);
                listkey :=L_RESP_ID_LIST.FIRST;
                WHILE listkey IS NOT NULL
                LOOP
                    L_USERVIO_ENTRIES:=L_RESP_ID_LIST(listkey);
                    FOR k IN L_USERVIO_ENTRIES.FIRST .. L_USERVIO_ENTRIES.LAST
                    LOOP
                        l_user_access_grp_list(L_USERVIO_ENTRIES(k).group_code):=L_USERVIO_ENTRIES(k).group_code;
                    END LOOP;
                    listkey:=L_RESP_ID_LIST.NEXT(listkey);
                END LOOP;
                IF (l_user_access_grp_list.COUNT >= 2) THEN
                        Write_Resp_To_Table_For_User(p_violation_id, p_constraint_rev_id, i, p_revalidate_flag);
                ELSE
                    -- 05.23.2005 tsho: user doesn't violate this constraint
                    -- if this check is for revalidation (ie, p_revalidate_flag = 'Y'), update the corrected_flag to 'Y' for this user
                    IF (p_revalidate_flag IS NOT NULL AND p_revalidate_flag = 'Y') THEN
                            Update_Violation_User (
                                p_user_violation_id => NULL,
                                p_violation_id      => p_violation_id,
                                p_violated_by_id    => i,
                                p_corrected_flag    => 'Y');
                    END IF; -- end of if: p_revalidate_flag
                END IF; -- end of if: G_UPV_RESPONSIBILITY_ID_LIST.COUNT >= 2
            END IF;
        END LOOP;
    END IF;
    --FND_FILE.put_line(fnd_file.log,'Comming Out'||L_API_NAME);
END Check_For_Resp_Cst_SET;


-- ===============================================================
-- Private Procedure name
--          Check_Violation_For_Constraint
--
-- Purpose
--          check violation for specified constraint
--          this is private procedure,
--          should not call this procedure directly
--
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--          p_type_code         := the type_code(constraint type) of specified constraint_rev_id
--
-- Notes
--          if at calling time, already know the type_code(constraint type),
--          then don't need to search for type_code against AMW_CONSTRAINTS_B again.
--
--          what if the specified constraint is not a valid constraint?
--
--          12.21.2004 tsho: fix for performance bug 4036679
-- ===============================================================
PROCEDURE Check_Violation_For_Constraint (
    p_constraint_rev_id          IN   NUMBER,
    p_type_code                  IN   VARCHAR2      := NULL
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Check_Violation_For_Constraint';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.1;

-- store the violation_id getting from Create_Violation
l_violation_id NUMBER   := NULL;

-- store the constraint type for this constraint
l_type_code     VARCHAR2(30)    := p_type_code;

-- find the constraint by specified constraint_rev_id
CURSOR c_constraint (l_constraint_rev_id IN NUMBER) IS
      SELECT constraint_rev_id,
			 start_date,
             end_date,
             type_code
        FROM amw_constraints_b
	   WHERE constraint_rev_id=l_constraint_rev_id;
l_constraint c_constraint%ROWTYPE;


BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    -- create vilation record for specified constriant in AMW_VIOLATIONS
    l_violation_id := Create_Violation(p_constraint_rev_id);
    IF (l_violation_id IS NULL) THEN
        -- create violation in AMW_VIOLATIONS is not successful
        RETURN;
    END IF;

    --FND_FILE.put_line(fnd_file.log,'Violation Id '||l_violation_id);

    -- 12.21.2004 tsho: fix for performance bug 4036679
    /*
    -- if no users in g_user_id_list, then no need to go further to check constraint
    IF ((G_USER_ID_LIST IS NULL) OR (G_USER_ID_LIST.FIRST IS NULL)) THEN
        RETURN;
    END IF;
    */

    IF (p_constraint_rev_id IS NOT NULL) THEN
        -- no passed-in type_code, need to search for constraint type
        IF (l_type_code IS NULL) THEN
            BEGIN
                OPEN c_constraint(p_constraint_rev_id);
                FETCH c_constraint INTO l_constraint;
                CLOSE c_constraint;
                l_type_code := l_constraint.type_code;
            EXCEPTION
                -- passed-in p_constraint_rev_id not found
                WHEN no_data_found THEN
                    IF c_constraint%ISOPEN THEN
                        CLOSE c_constraint;
                    END IF;
                    --FND_FILE.put_line(fnd_file.log,'passed-in p_constraint_rev_id not found');
                    RETURN;
            END;
        END IF; -- end of if: l_type_code IS NULL

        -- check violation depends on different constraint type
        IF (l_type_code = 'ALL') THEN
            -- Check_For_Constraint_ALL(p_constraint_rev_id, l_violation_id);
            Check_For_Func_Cst_ALL(p_constraint_rev_id, l_violation_id, l_type_code);
        ELSIF (l_type_code = 'ME') THEN
            -- Check_For_Constraint_ME(p_constraint_rev_id, l_violation_id);
            Check_For_Func_Cst_ME(p_constraint_rev_id, l_violation_id, l_type_code);
        ELSIF (l_type_code = 'SET') THEN
            Check_For_Func_Cst_SET(p_constraint_rev_id, l_violation_id, l_type_code);
        ELSIF (l_type_code = 'RESPALL') THEN
            Check_For_Resp_Cst_ALL(p_constraint_rev_id, l_violation_id, l_type_code);
        ELSIF (l_type_code = 'RESPME') THEN
            Check_For_Resp_Cst_ME(p_constraint_rev_id, l_violation_id, l_type_code);
        ELSIF (l_type_code = 'RESPSET') THEN
            Check_For_Resp_Cst_SET(p_constraint_rev_id, l_violation_id, l_type_code);
        END IF; -- end of if: l_type_code = 'ALL'



    END IF; -- end of if: p_constraint_rev_id IS NOT NULL

    -- update violation(violator_num, status) for this constriant by specified l_violation_id
    Update_Violation(p_violation_id         => l_violation_id,
                     p_constraint_rev_id    => p_constraint_rev_id);

    -- commit for each constraint, in order to prevent the rollback segment too big
    COMMIT;
    --FND_FILE.put_line(fnd_file.log,'Came Out '||L_API_NAME);
END Check_Violation_For_Constraint;


-- ===============================================================
-- Procedure name
--     Check_Violation_By_Name
--
-- Purpose
--     This Concurrent Program Executable checks the constraint
--     violation for Constraint Name Starting with p_constraint_name%.
--
-- Params
--     p_constraint_name  : Constraint Name Starting With
--
--
-- Notes
--     18.05.2006 psomanat: created
-- ===============================================================
PROCEDURE Check_Violation_By_Name(
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_constraint_name            IN   VARCHAR2:= NULL
)
IS
CURSOR c_all_valid_constraints IS
    SELECT  CONSTRAINT_REV_ID,
            TYPE_CODE
    FROM    AMW_CONSTRAINTS_VL
    WHERE   START_DATE <= SYSDATE AND (END_DATE IS NULL OR END_DATE>=SYSDATE )
    AND     LOWER(CONSTRAINT_NAME) LIKE LOWER(p_constraint_name||'%');

    l_all_valid_constraints c_all_valid_constraints%ROWTYPE;

BEGIN
    -- get party_id for G_USER_ID
    G_PARTY_ID := Get_Party_Id(G_USER_ID);

    --FND_FILE.put_line(fnd_file.log,'inside api Check_Violation_By_Name');
    OPEN c_all_valid_constraints;
    LOOP
        FETCH c_all_valid_constraints INTO l_all_valid_constraints;
        EXIT WHEN c_all_valid_constraints%NOTFOUND;
        --FND_FILE.put_line(fnd_file.log,'Violation Check For  : '||l_all_valid_constraints.constraint_rev_id);
        --FND_FILE.put_line(fnd_file.log,'Violation Check For  : '||l_all_valid_constraints.type_code);
        Check_Violation_For_Constraint (p_constraint_rev_id => l_all_valid_constraints.constraint_rev_id,
                                        p_type_code         => l_all_valid_constraints.type_code);
    END LOOP;
    CLOSE c_all_valid_constraints;
END;

-- ===============================================================
-- Procedure name
--          Check_Violation
--
-- Purpose
--          to check violations for constraint
--
-- Params
--          p_check_all_constraint_flag := 'Y' or 'N' (default to 'N')
--          p_constraint_set
--          p_constraint_rev_id1
--          p_constraint_rev_id2
--          p_constraint_rev_id3
--          p_constraint_rev_id4
--
-- Notes
--          If 'Y' is passed-in as p_check_all_constraint_flag,
--          will run violation check for
--          every valid constraint
--          (valid means the current time is between constraint's START_DATE and END_DATE)
--          and ignore the passed-in p_constraint_rev_id.
--
--
--          If 'N' is passed-in as p_check_all_constraint_flag,
--          then check the passed-in p_constraint_rev_id
--          currently only support up to four specified constraints
--          p_constraint_rev_id1....p_constraint_rev_id4
--
--          12.21.2004 tsho: fix for performance bug 4036679
-- ===============================================================
PROCEDURE Check_Violation(
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_check_all_constraint_flag  IN   VARCHAR2      := 'N',
    p_constraint_set		 IN   VARCHAR2      := NULL,
    p_constraint_rev_id1         IN   NUMBER        := NULL,
    p_constraint_rev_id2         IN   NUMBER        := NULL,
    p_constraint_rev_id3         IN   NUMBER        := NULL,
    p_constraint_rev_id4         IN   NUMBER        := NULL
)
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Check_Violation';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;


l_stmt_str                  VARCHAR2(200)         := 'SELECT USER_NAME FROM '||G_AMW_USER;
l_name                      VARCHAR2(240);
TYPE EmpCurTyp IS REF CURSOR;
cur EmpCurTyp;


-- find all valid constraints
CURSOR c_all_valid_constraints IS
      SELECT constraint_rev_id,
             type_code
        FROM amw_constraints_b
       WHERE start_date <= sysdate AND (end_date IS NULL OR end_date >= sysdate);
l_all_valid_constraints c_all_valid_constraints%ROWTYPE;

CURSOR c_constraint_set_details IS
     SELECT a.constraint_rev_id,
            a.type_code
       FROM amw_constraints_b a,
            amw_constraint_set_details cs
      WHERE cs.constraint_set_code = p_constraint_set
        AND cs.constraint_id = a.constraint_id;
l_constraint_set_details c_constraint_set_details%ROWTYPE;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    -- 12.21.2004 tsho: fix for performance bug 4036679
    /*
    -- populate global G_USER_ID_LIST, this should be one time work.
    IF (G_USER_ID_LIST IS NULL) THEN
        Populate_User_Id_List;
    END IF;
    */

    -- get party_id for G_USER_ID
    G_PARTY_ID := Get_Party_Id(G_USER_ID);


    IF p_check_all_constraint_flag = 'Y' THEN
        -- check all constraints
        --FND_FILE.put_line(fnd_file.log,'Check Violation for all constraint');
        OPEN c_all_valid_constraints;
        LOOP
            FETCH c_all_valid_constraints INTO l_all_valid_constraints;
            EXIT WHEN c_all_valid_constraints%NOTFOUND;
            --FND_FILE.put_line(fnd_file.log,'Start Violation Check for Constraint Rev Id :'||l_all_valid_constraints.constraint_rev_id);
            --FND_FILE.put_line(fnd_file.log,'Type Code :'|| l_all_valid_constraints.type_code);
            Check_Violation_For_Constraint (p_constraint_rev_id => l_all_valid_constraints.constraint_rev_id,
                                            p_type_code         => l_all_valid_constraints.type_code);
            --FND_FILE.put_line(fnd_file.log,'Completed Violation Check for Constraint Rev Id :'||l_all_valid_constraints.constraint_rev_id);
        END LOOP;
        CLOSE c_all_valid_constraints;

    ELSE
       IF (p_constraint_set IS NOT NULL) THEN
        --FND_FILE.put_line(fnd_file.log,'Start Violation Check for Constraint Set');
        OPEN c_constraint_set_details;
        LOOP
          FETCH c_constraint_set_details INTO l_constraint_set_details;
          EXIT WHEN c_constraint_set_details%NOTFOUND;

          if (l_constraint_set_details.constraint_rev_id not in
                (nvl(p_constraint_rev_id1,-1),
                 nvl(p_constraint_rev_id2,-1),
                 nvl(p_constraint_rev_id3,-1),
                 nvl(p_constraint_rev_id4,-1)
             )) then

            --FND_FILE.put_line(fnd_file.log,'Start Violation Check for Constraint Rev Id :'||l_constraint_set_details.constraint_rev_id);
            --FND_FILE.put_line(fnd_file.log,'Type Code :'|| l_constraint_set_details.type_code);
            Check_Violation_For_Constraint (p_constraint_rev_id => l_constraint_set_details.constraint_rev_id,
                                          p_type_code => l_constraint_set_details.type_code);
            --FND_FILE.put_line(fnd_file.log,'Completed Violation Check for Constraint Rev Id :'||l_constraint_set_details.constraint_rev_id);
          end if;
        END LOOP;
        CLOSE c_constraint_set_details;
       END IF;

        -- check specified constraint
        IF p_constraint_rev_id1 IS NOT NULL THEN
            --FND_FILE.put_line(fnd_file.log,'Start Violation Check for Constraint Rev Id :'||p_constraint_rev_id1);
            Check_Violation_For_Constraint(p_constraint_rev_id => p_constraint_rev_id1);
            --FND_FILE.put_line(fnd_file.log,'Completed Violation Check for Constraint Rev Id :'||p_constraint_rev_id1);
        END IF;
        IF p_constraint_rev_id2 IS NOT NULL THEN
            --FND_FILE.put_line(fnd_file.log,'Start Violation Check for Constraint Rev Id :'||p_constraint_rev_id2);
            Check_Violation_For_Constraint(p_constraint_rev_id => p_constraint_rev_id2);
            --FND_FILE.put_line(fnd_file.log,'Completed Violation Check for Constraint Rev Id :'||p_constraint_rev_id2);
        END IF;
        IF p_constraint_rev_id3 IS NOT NULL THEN
            --FND_FILE.put_line(fnd_file.log,'Start Violation Check for Constraint Rev Id :'||p_constraint_rev_id3);
            Check_Violation_For_Constraint(p_constraint_rev_id => p_constraint_rev_id3);
            --FND_FILE.put_line(fnd_file.log,'Completed Violation Check for Constraint Rev Id :'||p_constraint_rev_id3);
        END IF;
        IF p_constraint_rev_id4 IS NOT NULL THEN
            --FND_FILE.put_line(fnd_file.log,'Start Violation Check for Constraint Rev Id :'||p_constraint_rev_id4);
            Check_Violation_For_Constraint(p_constraint_rev_id => p_constraint_rev_id4);
            --FND_FILE.put_line(fnd_file.log,'Completed Violation Check for Constraint Rev Id :'||p_constraint_rev_id4);
        END IF;

    END IF;

End Check_Violation;



-- ===============================================================
-- Procedure name
--          Revalidate_Violation
-- Purpose
--          to revalidate existing violators of specified violation report
--
-- Params
--          p_violation_id
--
-- Notes
--          this only checks violations for existing violators (against this constraint),
--          don't consider if any other users violate this constraint or not.
-- History
--          05.20.2005 tsho: create for AMW.E
-- ===============================================================
PROCEDURE Revalidate_Violation(
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_violation_id               IN   NUMBER            := NULL
    )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Revalidate_Violation';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- find the constraint related to this violation
CURSOR c_constraint(l_violation_id IN NUMBER) IS
      SELECT cst.constraint_rev_id
            ,cst.type_code
        FROM amw_constraints_b cst
            ,amw_violations v
       WHERE v.violation_id = l_violation_id
         AND v.constraint_rev_id = cst.constraint_rev_id;
l_constraint c_constraint%ROWTYPE;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    -- get party_id for G_USER_ID
    G_PARTY_ID := Get_Party_Id(G_USER_ID);

    IF p_violation_id IS NOT NULL THEN
        OPEN c_constraint (p_violation_id);
        FETCH c_constraint INTO l_constraint;
        CLOSE c_constraint;

        -- ptulasi : 18-02-2008
        -- bug : 	6689589 : If a responsibility violating the constraint is end dated, the staus for the
        -- user having this responsibility only should be shown as closed. But this is not happening. This is
        -- because the corrected_flag for the user is not set to yes. The query used to fetch the user and his
        -- responsibilities will not fetch the end dated responsibilities. So no action is taken against the
        -- user having responsibilities which violate the constraint.
        -- Updated the corrected_flag of all the violating users to yes. For the violating users,
        -- the corrected_flag will be set to no.
        UPDATE AMW_VIOLATION_USERS
        SET CORRECTED_FLAG = 'Y'
        WHERE VIOLATION_ID = p_violation_id;

        IF (l_constraint.constraint_rev_id IS NOT NULL AND l_constraint.type_code IS NOT NULL) THEN
            -- revalidate violation depends on different constraint type
            IF (l_constraint.type_code = 'ALL') THEN
                Check_For_Func_Cst_ALL(l_constraint.constraint_rev_id, p_violation_id, l_constraint.type_code, 'Y');
            ELSIF (l_constraint.type_code = 'ME') THEN
                Check_For_Func_Cst_ME(l_constraint.constraint_rev_id, p_violation_id, l_constraint.type_code, 'Y');
            ELSIF (l_constraint.type_code = 'SET') THEN
                Check_For_Func_Cst_SET(l_constraint.constraint_rev_id, p_violation_id, l_constraint.type_code, 'Y');
            ELSIF (l_constraint.type_code = 'RESPALL') THEN
                Check_For_Resp_Cst_ALL(l_constraint.constraint_rev_id, p_violation_id, l_constraint.type_code, 'Y');
            ELSIF (l_constraint.type_code = 'RESPME') THEN
                Check_For_Resp_Cst_ME(l_constraint.constraint_rev_id, p_violation_id, l_constraint.type_code, 'Y');
            ELSIF (l_constraint.type_code = 'RESPSET') THEN
                Check_For_Resp_Cst_SET(l_constraint.constraint_rev_id, p_violation_id, l_constraint.type_code, 'Y');
            END IF; -- end of if: l_type_code = 'ALL'

        END IF; -- end of if: l_constraint.constraint_rev_id IS NOT NULL
    END IF; -- end of if: p_violation_id IS NOT NULL

    -- update violation(violator_num, status) for this constriant by specified l_violation_id
    Update_Violation(p_violation_id         => p_violation_id,
                     p_constraint_rev_id    => l_constraint.constraint_rev_id,
                     p_revalidate_flag      => 'Y');

    -- commit for each constraint, in order to prevent the rollback segment too big
    COMMIT;

End Revalidate_Violation;


-- ===============================================================
-- Function name
--          Get_Resps_By_Appl
--
-- Purpose
--          get the responsibility by specified applicaiton_id,
-- Params
--          p_appl_id   := specified application_id
--
-- ===============================================================
Procedure Get_Resps_By_Appl (
    p_appl_id               IN  NUMBER,
    x_resp_list             OUT NOCOPY VARCHAR2,
    x_menu_list             OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Resps_By_Appl';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- find the responsibilities by specified app_id
l_resp_id_list G_NUMBER_TABLE;
l_resp_id NUMBER;

-- find the responsibility menu ids by specified app_id
l_menu_id_list G_NUMBER_TABLE;
l_menu_id NUMBER;

-- store the tmp count for l_resp_id_list
j NUMBER;

-- store the tmp count for l_resp_id_list
k NUMBER;

-- 12.12.2003 tsho: use static sql for AMW for the time being
-- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
TYPE respCurTyp IS REF CURSOR;
resp_c respCurTyp;
l_resp_dynamic_sql   VARCHAR2(200)  :=
        'SELECT responsibility_id, menu_id '
      ||'  FROM '||G_AMW_RESPONSIBILITY
      ||' WHERE application_id = :1 ';
/*
cursor get_resp_c(l_appl_id IN NUMBER) is
    SELECT responsibility_id,
           menu_id
      from FND_RESPONSIBILITY
     where application_id = l_appl_id;
*/

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    IF (p_appl_id IS NOT NULL) THEN
      -- get user(usre i)'s responsibilities
      IF (BULK_COLLECTS_SUPPORTED) THEN
        -- 12.12.2003 tsho: use static sql for AMW for the time being
        -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
        OPEN resp_c FOR l_resp_dynamic_sql USING
          p_appl_id;
        FETCH resp_c BULK COLLECT INTO l_resp_id_list,
                                       l_menu_id_list;
        CLOSE resp_c;
        /*
        SELECT responsibility_id,
               menu_id
        BULK COLLECT INTO l_resp_id_list,
                          l_menu_id_list
          FROM FND_RESPONSIBILITY
         WHERE application_id = p_appl_id;
        */

      ELSE
        -- no BULK_COLLECTS_SUPPORTED
        j := 0;
        -- 12.12.2003 tsho: use static sql for AMW for the time being
        -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
        OPEN resp_c FOR l_resp_dynamic_sql USING
          p_appl_id;
        LOOP
          FETCH resp_c INTO l_resp_id,
                            l_menu_id;
          EXIT WHEN resp_c%NOTFOUND;
          j := j+1;
          l_resp_id_list(j) := l_resp_id;
          l_menu_id_list(j) := l_menu_id;
        END LOOP;
        CLOSE resp_c;
        /*
        for rec in get_resp_c(p_appl_id) loop
        j := j + 1;
        l_resp_id_list(j) := rec.responsibility_id;
        l_menu_id_list(j) := rec.menu_id;
        end loop;
        */
      END IF; -- end of if: BULK_COLLECTS_SUPPORTED

    END IF; -- end of if: p_appl_id is not NULL

    FOR K IN 1 .. l_resp_id_list.count
    LOOP
        x_resp_list := x_resp_list || ',' || l_resp_id_list(K);
        x_menu_list := x_menu_list || ',' || l_menu_id_list(K);
    END LOOP;

    x_resp_list := rtrim(ltrim(x_resp_list,','),',');
    x_menu_list := rtrim(ltrim(x_menu_list,','),',');

END Get_Resps_By_Appl;



-- ===============================================================
-- Function name
--          Get_Functions_By_Appl
-- Purpose
--          get the available functions by specified applicaiton_id,
-- Params
--          p_appl_id   := specified application_id
--
-- ===============================================================
Function Get_Functions_By_Appl (
    p_appl_id   IN  NUMBER
)
Return  VARCHAR2
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Functions_By_Appl';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

L_FUNCTION_ID_LIST            G_NUMBER_TABLE;

-- 05.10 2004 tsho: store available function id
l_available_function_list   VARCHAR2(32767) := '';

-- 05.10 2004 tsho: store available function id under specific responsibility
l_resp_function_list        VARCHAR2(32767) := '';

-- find the responsibilities by specified app_id
l_resp_id_list G_NUMBER_TABLE;
l_resp_id NUMBER;

-- find the responsibility menu ids by specified app_id
l_menu_id_list G_NUMBER_TABLE;
l_menu_id NUMBER;

-- store the tmp count for l_resp_id_list
j NUMBER;

-- store the tmp count for l_resp_id_list
k NUMBER;

-- 12.12.2003 tsho: use static sql for AMW for the time being
-- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
TYPE respCurTyp IS REF CURSOR;
resp_c respCurTyp;
l_resp_dynamic_sql   VARCHAR2(200)  :=
        'SELECT responsibility_id, menu_id '
      ||'  FROM '||G_AMW_RESPONSIBILITY
      ||' WHERE application_id = :1 ';
/*
cursor get_resp_c(l_appl_id IN NUMBER) is
    SELECT responsibility_id,
           menu_id
      from FND_RESPONSIBILITY
     where application_id = l_appl_id;
*/

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    IF (p_appl_id IS NOT NULL) THEN
      -- get user(usre i)'s responsibilities
      IF (BULK_COLLECTS_SUPPORTED) THEN
        -- 12.12.2003 tsho: use static sql for AMW for the time being
        -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
        OPEN resp_c FOR l_resp_dynamic_sql USING
          p_appl_id;
        FETCH resp_c BULK COLLECT INTO l_resp_id_list,
                                       l_menu_id_list;
        CLOSE resp_c;
        /*
        SELECT responsibility_id,
               menu_id
        BULK COLLECT INTO l_resp_id_list,
                          l_menu_id_list
          FROM FND_RESPONSIBILITY
         WHERE application_id = p_appl_id;
        */

      ELSE
        -- no BULK_COLLECTS_SUPPORTED
        j := 0;
        -- 12.12.2003 tsho: use static sql for AMW for the time being
        -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
        OPEN resp_c FOR l_resp_dynamic_sql USING
          p_appl_id;
        LOOP
          FETCH resp_c INTO l_resp_id,
                            l_menu_id;
          EXIT WHEN resp_c%NOTFOUND;
          j := j+1;
          l_resp_id_list(j) := l_resp_id;
          l_menu_id_list(j) := l_menu_id;
        END LOOP;
        CLOSE resp_c;
        /*
        for rec in get_resp_c(p_appl_id) loop
        j := j + 1;
        l_resp_id_list(j) := rec.responsibility_id;
        l_menu_id_list(j) := rec.menu_id;
        end loop;
        */
      END IF; -- end of if: BULK_COLLECTS_SUPPORTED

    END IF; -- end of if: p_appl_id is not NULL


    FOR K IN 1 .. l_resp_id_list.count
    LOOP
        l_resp_function_list := Get_Functions_By_Resp(p_appl_id   => p_appl_id,
                                                      p_resp_id   => l_resp_id_list(K),
                                                      p_menu_id   => l_menu_id_list(K));
        l_available_function_list := l_available_function_list||','||l_resp_function_list;
    END LOOP;

    RETURN l_available_function_list;

END Get_Functions_By_Appl;




-- ===============================================================
-- Function name
--          Get_Functions_By_Resp
--
-- Purpose
--          get the available functions by specified resp_id,
-- Params
--          p_appl_id   := specified application_id
--          p_resp_id   := specified responsibility_id
--          p_menu_id   := specified menu_id
-- Notes
--          this Function is modified from PROCESS_MENU_TREE_DOWN_MN,
--          Instead of checking specific function_id, check all the
--          available functions under specific responsibility_id
--
-- ===============================================================
Function Get_Functions_By_Resp (
    p_appl_id   IN NUMBER,
    p_resp_id   IN NUMBER,
    p_menu_id   IN NUMBER
)
Return  VARCHAR2
IS

  L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Functions_By_Resp';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

  -- 05.10 2004 tsho: store available function id
  l_available_function_list   VARCHAR2(32767) := '';

  l_sub_menu_id number;

  /* Table to store the list of submenus that we are looking for */
  TYPE MENULIST_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  MENULIST  MENULIST_TYPE;

  TYPE NUMBER_TABLE_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  TYPE VARCHAR2_TABLE_TYPE is table of VARCHAR2(1) INDEX BY BINARY_INTEGER;

  /* The table of exclusions.  The index in is the action_id, and the */
  /* value stored in each element is the rule_type.*/
  EXCLUSIONS VARCHAR2_TABLE_TYPE;

  /* Returns from the bulk collect (fetches) */
  TBL_MENU_ID NUMBER_TABLE_TYPE;
  TBL_ENT_SEQ NUMBER_TABLE_TYPE;
  TBL_FUNC_ID NUMBER_TABLE_TYPE;
  TBL_SUBMNU_ID NUMBER_TABLE_TYPE;
  TBL_GNT_FLG VARCHAR2_TABLE_TYPE;


  /* Cursor to get exclusions */
  -- 11.12.2003 tsho: use dynamic sql for AMW
  /*
  cursor excl_c is
      SELECT RULE_TYPE, ACTION_ID from fnd_resp_functions
       where application_id = p_appl_id
         and responsibility_id = p_resp_id;
  */
  -- 12.12.2003 tsho: use static sql for AMW for the time being
  -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
  TYPE exclCurTyp IS REF CURSOR;
  excl_c exclCurTyp;
  l_excl_rule_type     VARCHAR2(30);
  l_excl_action_id     NUMBER;
  l_excl_dynamic_sql   VARCHAR2(200)  :=
        'SELECT RULE_TYPE, ACTION_ID '
      ||'  FROM '||G_AMW_RESP_FUNCTIONS
      ||' WHERE application_id = :1 '
      ||'   AND responsibility_id = :2 ';


  /* Cursor to get menu entries on a particular menu.*/
  -- 11.12.2003 tsho: use dynamic sql for AMW
  /*
  cursor get_mnes_c is
      SELECT MENU_ID, ENTRY_SEQUENCE, FUNCTION_ID, SUB_MENU_ID, GRANT_FLAG
        from fnd_menu_entries
       where MENU_ID  = l_sub_menu_id;
  */
  -- 12.12.2003 tsho: use static sql for AMW for the time being
  -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
  TYPE mnesCurTyp IS REF CURSOR;
  get_mnes_c mnesCurTyp;
  l_mnes_menu_id        NUMBER;
  l_mnes_entry_sequence NUMBER;
  l_mnes_function_id    NUMBER;
  l_mnes_sub_menu_id    NUMBER;
  l_mnes_grant_flag     VARCHAR2(1);
  l_mnes_dynamic_sql   VARCHAR2(200)  :=
        'SELECT MENU_ID, ENTRY_SEQUENCE, FUNCTION_ID, SUB_MENU_ID, GRANT_FLAG '
      ||'  FROM '||G_AMW_MENU_ENTRIES
      ||' WHERE menu_id  = :1 ';

  menulist_cur pls_integer;
  menulist_size pls_integer;

  entry_excluded boolean;
  last_index pls_integer;
  i number;
  z number;

BEGIN
  --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

  if(p_appl_id is not NULL) then
    /* Select the list of exclusion rules into our cache */
    -- 11.12.2003 tsho: use dynamic sql for AMW
    /*
    for excl_rec in excl_c loop
       EXCLUSIONS(excl_rec.action_id) := excl_rec.rule_type;
    end loop;
    */
    -- 12.12.2003 tsho: use static sql for AMW for the time being
    -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
    OPEN excl_c FOR l_excl_dynamic_sql USING
        p_appl_id,
        p_resp_id;
    LOOP
        FETCH excl_c INTO l_excl_rule_type, l_excl_action_id;
        EXIT WHEN excl_c%NOTFOUND;
        EXCLUSIONS(l_excl_action_id) := l_excl_rule_type;
    END LOOP;
    CLOSE excl_c;

  end if;


  -- Initialize menulist working list to parent menu
  menulist_cur := 0;
  menulist_size := 1;
  menulist(0) := p_menu_id;

  -- Continue processing until reach the end of list
  while (menulist_cur < menulist_size) loop
    -- Check if recursion limit exceeded
    if (menulist_cur > C_MAX_MENU_ENTRIES) then
      /* If the function were accessible from this menu, then we should */
      /* have found it before getting to this point, so we are confident */
      /* that the function is not on this menu. */
      return l_available_function_list;
    end if;

    l_sub_menu_id := menulist(menulist_cur);

    -- See whether the current menu is excluded or not.
    entry_excluded := FALSE;
    begin
      if(    (l_sub_menu_id is not NULL)
         and (exclusions(l_sub_menu_id) = 'M')) then
        entry_excluded := TRUE;
      end if;
    exception
      when no_data_found then
        null;
    end;

    if (entry_excluded) then
      last_index := 0; /* Indicate that no rows were returned */
    else
      /* This menu isn't excluded, so find out whats entries are on it. */
      if (BULK_COLLECTS_SUPPORTED) then
        -- 11.12.2003 tsho: use dynamic sql for AMW
        /*
        open get_mnes_c;
        */
        -- 12.12.2003 tsho: use static sql for AMW for the time being
        -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
        open get_mnes_c for l_mnes_dynamic_sql USING
            l_sub_menu_id;

        fetch get_mnes_c bulk collect into tbl_menu_id, tbl_ent_seq,
             tbl_func_id, tbl_submnu_id, tbl_gnt_flg;
        close get_mnes_c;

        -- See if we found any rows. If not set last_index to zero.
        begin
          if((tbl_menu_id.FIRST is NULL) or (tbl_menu_id.FIRST <> 1)) then
            last_index := 0;
          else
            if (tbl_menu_id.FIRST is not NULL) then
              last_index := tbl_menu_id.LAST;
            else
              last_index := 0;
            end if;
          end if;
        exception
          when others then
            last_index := 0;
        end;
      else
        z:= 0;

        -- 11.12.2003 tsho: use dynamic sql for AMW
        /*
        for rec in get_mnes_c loop
          z := z + 1;
          tbl_menu_id(z) := rec.MENU_ID;
          tbl_ent_seq(z) := rec.ENTRY_SEQUENCE;
          tbl_func_id(z) := rec.FUNCTION_ID;
          tbl_submnu_id (z):= rec.SUB_MENU_ID;
          tbl_gnt_flg(z) := rec.GRANT_FLAG;
        end loop;
        */
        -- 12.12.2003 tsho: use static sql for AMW for the time being
        -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
        OPEN get_mnes_c FOR l_mnes_dynamic_sql USING
            l_sub_menu_id;
        LOOP
            FETCH get_mnes_c INTO l_mnes_menu_id,
                                  l_mnes_entry_sequence,
                                  l_mnes_function_id,
                                  l_mnes_sub_menu_id,
                                  l_mnes_grant_flag;
            EXIT WHEN get_mnes_c%NOTFOUND;
            tbl_menu_id(z) := l_mnes_menu_id;
            tbl_ent_seq(z) := l_mnes_entry_sequence;
            tbl_func_id(z) := l_mnes_function_id;
            tbl_submnu_id (z):= l_mnes_sub_menu_id;
            tbl_gnt_flg(z) := l_mnes_grant_flag;
        END LOOP;
        CLOSE get_mnes_c;

        last_index := z;
      end if;


    end if; /* entry_excluded */

    -- Process each of the child entries fetched
    for i in 1 .. last_index loop
      -- Check if there is an exclusion rule for this entry
      entry_excluded := FALSE;
      begin
        if(    (tbl_func_id(i) is not NULL)
           and (exclusions(tbl_func_id(i)) = 'F')) then
          entry_excluded := TRUE;
        end if;
      exception
        when no_data_found then
          null;
      end;

      -- Skip this entry if it's excluded
      if (not entry_excluded) then
        if((tbl_gnt_flg(i) = 'Y') AND (tbl_func_id(i) is not NULL) ) then
          l_available_function_list := l_available_function_list || ',' || tbl_func_id(i);
        end if;

        -- If this is a submenu, then add it to the end of the
        -- working list for processing.
        if (tbl_submnu_id(i) is not NULL) then
          menulist(menulist_size) := tbl_submnu_id(i);
          menulist_size := menulist_size + 1;
        end if;
      end if; -- End if not excluded
    end loop;  -- For loop processing child entries

    -- Advance to next menu on working list
    menulist_cur := menulist_cur + 1;
  end loop;

  -- We couldn't find the function anywhere, so it's not available
  return rtrim(ltrim(l_available_function_list,','),',');

END Get_Functions_By_Resp;



-- ===============================================================
-- Procedure name
--          Purge_Violation_Before_Date
-- Purpose
--          to clear violation history before the specified date
-- Params
--          p_delopt
--          p_date
-- Notes
--          p_delopt can have one of the two values
--              ALLCSTVIO - All Constraint Violations
--              INVALCSTVIO - Invalid Constraint Violations
--          p_date will have passed-in date
--
--          With "ALL Constraint Violations", we will delete all the constraint
--          violations created before the specified date.
--          With "Invalid Constraint violations", we will delete all the invalid
--          constraint violations created before the specified date. deleted.
--
-- History
--          12.01.2005 tsho     create (related to customer requirement: bug 4673154)
--          12.14.2006 psomanat Added delete statements for amw_violation_resp and amw_violat_resp_entries
--          03.14.2007 psomanat Added parameter p_delopt
-- ===============================================================
PROCEDURE Purge_Violation_Before_Date (
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_delopt                     IN   VARCHAR2 := NULL,
    p_date                       IN   VARCHAR2 := NULL
) IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Purge_Violation_Before_Date';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;
l_date  DATE;
BEGIN
    FND_FILE.put_line(fnd_file.log,'Passed-in Delete Option is: '||p_delopt);
    FND_FILE.put_line(fnd_file.log,'Passed-in date is: '||p_date);

    IF p_date IS NOT NULL THEN
        l_date := trunc(to_date(p_date,'YYYY/MM/DD HH24:MI:SS')) + 1;
    ELSE
        l_date := trunc(sysdate) + 1;
    END IF;
    FND_FILE.put_line(fnd_file.log,'will delete violation history prior(<) to : '||l_date);

    FND_FILE.put_line(fnd_file.log,'Delete Constraint Violation Start');
    IF p_delopt = 'ALLCSTVIO' THEN
        DELETE FROM amw_violat_resp_entries
        WHERE creation_date < l_date;

        DELETE FROM amw_violation_resp
        WHERE creation_date < l_date;

        DELETE FROM amw_violat_user_entries
        WHERE creation_date < l_date;

        DELETE FROM amw_violation_users
        WHERE creation_date < l_date;

        DELETE FROM amw_violations
        WHERE creation_date < l_date;

    ELSE

        DELETE FROM amw_violat_resp_entries
        WHERE resp_violation_id IN (
            SELECT resp_violation_id
            FROM amw_violation_resp
            WHERE violation_id IN (
                SELECT violation_id
                FROM amw_violations
                WHERE status_code = 'NA'
                AND creation_date < l_date));


        DELETE FROM amw_violation_resp
        WHERE violation_id IN (
            SELECT violation_id
            FROM amw_violations
            WHERE status_code = 'NA'
            AND creation_date < l_date);

        DELETE FROM amw_violat_user_entries
        WHERE user_violation_id IN (
            SELECT  user_violation_id
            FROM amw_violation_users
            WHERE violation_id IN (
                SELECT violation_id
                FROM amw_violations
                WHERE status_code = 'NA'
                AND creation_date < l_date ));

        DELETE FROM amw_violation_users
        WHERE violation_id IN (
            SELECT violation_id
            FROM amw_violations
            WHERE status_code = 'NA'
            AND creation_date < l_date );

        DELETE FROM amw_violations
        WHERE status_code = 'NA'
        AND creation_date < l_date ;

    END IF;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,'Delete Constraint Violation END');

END Purge_Violation_Before_Date;

-- ----------------------------------------------------------------------

END AMW_CONSTRAINT_PVT;

/
