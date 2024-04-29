--------------------------------------------------------
--  DDL for Package Body FND_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FUNCTION" as
/* $Header: AFSCFNSB.pls 120.8.12010000.5 2016/02/27 01:12:57 emiranda ship $ */

  C_PKG_NAME    CONSTANT VARCHAR2(30) := 'FND_FUNCTION';
  C_LOG_HEAD    CONSTANT VARCHAR2(30) := 'fnd.plsql.FND_FUNCTION.';

  /* These column values mark a menu as uncompiled. */
  /* These will be stored in the FUNCTION_ID and GRANT_FLAG to indicate */
  /* that a particular menu has been modified and needs to be recompiled */
  C_INVALID_MENU_VAL CONSTANT NUMBER := -99999;
  C_INVALID_GRANT_VAL CONSTANT VARCHAR2(1) := 'U'; /*U stands for Uncompiled */

  /* These column values mark a menu as blank (yielding no compilation). */
  /* These will be stored in the FUNCTION_ID and GRANT_FLAG to indicate */
  /* that the corresponding FND_MENU row doesn't produce any information */
  /* when compiled. */
  /* Some possible reasons: The menu isn't used by any menu entries, or */
  /* the menu doesn't contain any functions */
  C_BLANK_MENU_VAL CONSTANT NUMBER := -99990;
  C_BLANK_GRANT_VAL CONSTANT VARCHAR2(1) := 'B'; /* B stands for Blank */

  /*
  ** Lock ID for coordinating compilations (2004/10/22)
  */
  C_MENU_LOCK_ID  constant NUMBER := 20041022;

  TYPE NUMBER_TABLE_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;

  /* Bulk collects are a feature that will have the benefit of increasing */
  /* performance and hopefully reducing I/O reads on dev115 */
  /* But the problem is they cause random failures in 8.1.6.1 databases */
  /* so we can't use them before 8.1.7.1. (due to database bug 1688232).*/
  /* So we will detect the database version and set this flag to one of: */
  /* 'UNKNOWN'- Flag needs to be initialized by call to init routine */
  /* 'TRUE' - supported */
  /* 'FALSE'- unsupported */
  /* Once 8.1.7.1+ is required for all Apps customers then this hack */
  /* Can be gotten rid of, and this can be hardcoded to 'TRUE' */
  /* 2/03- TM- That time is now... we now require 8.1.7.1+.*/
  G_BULK_COLLECTS_SUPPORTED     VARCHAR2(30) := 'TRUE';

  /* This table stores marks while being called from row level db triggers,*/
  /* because those row level db triggers can't actually mark the menu */
  /* That involves reading the FND_MENU_ENTRIES table, which is considered */
  /* a mutating table.  So we store the marks here and then process them in*/
  /* the after statement trigger. */
  TBL_QUEUED_MENU_ID NUMBER_TABLE_TYPE;
  TBL_QUEUED_MENU_ID_MAX NUMBER := 0;


  /* This table stores the list of menus being visited as we */
  /* Compile menus down recursively.  */
  /* This is basically a list that has the parents of a particular menu */
  /* and it is maintained by pushing and popping items on it as we go down */
  /* and up the menu hierarchy.  If the current menu is also on its list */
  /* of parents, then we know we've found an infinite recursion. */
  TBL_RECURS_DETEC_MENU_ID NUMBER_TABLE_TYPE;
  TBL_RECURS_DETEC_MENU_ID_MAX NUMBER := 0;

  /* This constant is used for recursion detection in the fallback */
  /* runtime menu scan.  We keep track of how many items are on the menu,
  /* and assume if the number of entries on the current */
  /* menu is too high then it's caused by recursion. */
  C_MAX_MENU_ENTRIES CONSTANT pls_integer := 10000;

  /* This simple cache will avoid the need to find which menu is on */
  /* the current responsibility with SQL every time.  We just store */
  /* the menu around after we get it for the current resp. */
  P_LAST_RESP_ID NUMBER := -1;
  P_LAST_RESP_APPL_ID NUMBER := -1;
  P_LAST_MENU_ID NUMBER := -1;

  g_func_id_cache    NUMBER := NULL;
  -- modified for bug#5395351
  g_func_name_cache  fnd_form_functions.function_name%type := NULL;


/* AVAILABILITY - This function compares the MAINTENANCE_MODE_SUPPORT
**                of a particular function to the APPS_MAINTENANCE_MODE
**                profile value and determines whether the function is
**                available during that maintenance phase.
**
** in: MAINTENANCE_MODE_SUPPORT- the value from the database column
**
** out: 'Y'= available, 'N'= not available
*/
function AVAILABILITY(MAINTENANCE_MODE_SUPPORT in varchar2) return varchar2 is
  apps_maintenance_mode varchar2(255);
  retval  boolean;
  l_api_name CONSTANT VARCHAR2(30) := 'AVAILABILITY';
begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'MAINTENANCE_MODE_SUPPORT =>'|| MAINTENANCE_MODE_SUPPORT
          ||');');
  end if;

  apps_maintenance_mode := FND_PROFILE.VALUE('APPS_MAINTENANCE_MODE');

  if(fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
       c_log_head || l_api_name || '.got_mode',
       'profile APPS_MAINTENANCE_MODE is set to value:'
       || apps_maintenance_mode);
  end if;

  -- This following if statement is added to support the new function
  -- mantenance_mode_support 'OFFLINE'
  -- Note that we will always preventing function access if is OFFLINE.
  -- RSheh : I did not want to rewrite the whole thing below so I just
  --         added the following if statement to support OFFLINE
  if (MAINTENANCE_MODE_SUPPORT = 'OFFLINE') then
    retval := FALSE;
  else
  -- Original code before adding support for OFFLINE
  retval := TRUE;
  if (apps_maintenance_mode is NULL) then
    retval := TRUE; /* Feature not yet supported, so ignore. */
  elsif (apps_maintenance_mode = 'NORMAL') then
    retval := TRUE; /* In normal mode everything is supported */
  elsif (apps_maintenance_mode = 'DISABLED') then
    retval := FALSE; /* In normal mode nothing is supported */
  elsif (apps_maintenance_mode = 'MAINT') then
    if (    (MAINTENANCE_MODE_SUPPORT = 'MAINT')
         OR (MAINTENANCE_MODE_SUPPORT = 'QUERY')
         OR (MAINTENANCE_MODE_SUPPORT = 'FUZZY')) then
      retval := TRUE;
    elsif (MAINTENANCE_MODE_SUPPORT = 'NONE') then
      retval := FALSE;
    else
      retval := TRUE; /* Mode not supported so ignore */
    end if;
  elsif (apps_maintenance_mode = 'FUZZY') then
    if (MAINTENANCE_MODE_SUPPORT = 'FUZZY') then
      retval := TRUE;
    elsif (    (MAINTENANCE_MODE_SUPPORT = 'NONE')
         OR (MAINTENANCE_MODE_SUPPORT = 'QUERY')
         OR (MAINTENANCE_MODE_SUPPORT = 'MAINT')) then
      retval := FALSE;
    else
      retval := TRUE;
    end if;
  else
    /* Unrecognized value for APPS_MAINTENANCE_MODE profile... */
    /* assume the best and allow access. */
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
       c_log_head || l_api_name || '.unrecognized_mode',
       'Unrecognized value for profile APPS_MAINTENANCE_MODE:'
       || apps_maintenance_mode);
    end if;
    retval := TRUE;
  end if;
  end if; /* If statement for supporting OFFLINE */

  if (retval) then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
       c_log_head || l_api_name || '.end_true',
       'returning Y');
    end if;
    return 'Y';
  else
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
       c_log_head || l_api_name || '.end_false',
       'returning N');
    end if;
    return 'N';
  end if;

end;


-- BULK_COLLECTS_SUPPORTED
-- This temporary routine determines whether bulk collects are supported.
-- See comments around G_BULK_COLLECTS_SUPPORTED above
--
function BULK_COLLECTS_SUPPORTED return boolean is
  ver varchar2(255);
begin
  begin
    if (G_BULK_COLLECTS_SUPPORTED = 'TRUE') then
      return TRUE;
    elsif (G_BULK_COLLECTS_SUPPORTED = 'FALSE') then
      return FALSE;
    elsif (G_BULK_COLLECTS_SUPPORTED = 'UNKNOWN') then
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
    else
      return (FALSE); /* Should never happen */
    end if;
  exception
    when others then
      return FALSE; /* Should never happen */
  end;
end BULK_COLLECTS_SUPPORTED;


-- PROCESS_MENU_TREE_DOWN_FOR_MN
--   Plow through the menu tree, processing exclusions and figuring
--   out which functions are accessible.
-- IN
--   p_menu_id - menu_id
--   p_function_id- function to check for
--     Don't pass values for the following two params if you don't want
--     exclusions processed.
--   p_appl_id - application id of resp
--   p_resp_id - responsibility id of current user
--   p_ignore_exclusions - passing 'Y' will ignore the exclusions.
--
-- RETURNS
--  TRUE if function is accessible
--
function PROCESS_MENU_TREE_DOWN_FOR_MN(
  p_menu_id     in number,
  p_function_id in number,
  p_appl_id     in number,
  p_resp_id     in number) return boolean is

  l_api_name CONSTANT VARCHAR2(30) := 'PROCESS_MENU_TREE_DOWN_FOR_MN';

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
  cursor excl_c is
      SELECT RULE_TYPE, ACTION_ID from fnd_resp_functions
       where application_id = p_appl_id
         and responsibility_id = p_resp_id;

  /* Cursor to get menu entries on a particular menu.*/
  cursor get_mnes_c is
      SELECT MENU_ID, ENTRY_SEQUENCE, FUNCTION_ID, SUB_MENU_ID, GRANT_FLAG
        from fnd_menu_entries
       where MENU_ID  = l_sub_menu_id;

  menulist_cur pls_integer;
  menulist_size pls_integer;

  entry_excluded boolean;
  last_index pls_integer;
  i number;
  z number;

begin
  --
  -- This routine processes the menu hierarchy and exclusion rules in PL/SQL
  -- rather than in the database.
  -- The basic algorithm of this routine is:
  -- Populate the list of exclusions by selecting from FND_RESP_FUNCTIONS
  -- menulist(1) = p_menu_id
  -- while (elements on menulist)
  -- {
  --   Remove first element off menulist
  --   if this menu is not excluded with a menu exclusion rule
  --   {
  --     Query all menu entry children of current menu
  --     for (each child) loop
  --     {
  --        If it's excluded by a func exclusion rule, go on to the next one.
  --        If we've got the function we're looking for,
  --           and grant_flag = Y, we're done- return TRUE;
  --        If it's got a sub_menu_id, add it to the end of menulist
  --           to be processed
  --     }
  --     Move to next element on menulist
  --   }
  -- }
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_menu_id =>'|| to_char(p_menu_id) ||
          'p_function_id =>'|| to_char(p_function_id) ||
          'p_appl_id =>'|| to_char(p_appl_id) ||
          'p_resp_id =>'|| to_char(p_resp_id) ||');');
  end if;

  if(p_appl_id is not NULL) then
    /* Select the list of exclusion rules into our cache */
    for excl_rec in excl_c loop
       EXCLUSIONS(excl_rec.action_id) := excl_rec.rule_type;
    end loop;
  end if;


  -- Initialize menulist working list to parent menu
  menulist_cur := 0;
  menulist_size := 1;
  menulist(0) := p_menu_id;

  -- Continue processing until reach the end of list
  while (menulist_cur < menulist_size) loop
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.proc_menulist',
              'menulist_cur: ' || to_char(menulist_cur));
    end if;

    -- Check if recursion limit exceeded
    if (menulist_cur > C_MAX_MENU_ENTRIES) then
      fnd_message.set_name('FND', 'MENU-MENU LOOP');
      fnd_message.set_token('MENU_ID', p_menu_id);
      if (fnd_log.LEVEL_ERROR >= fnd_log.g_current_runtime_level) then
        fnd_log.message(FND_LOG.LEVEL_ERROR,
          c_log_head || l_api_name || '.recursion');
      end if;

      /* If the function were accessible from this menu, then we should */
      /* have found it before getting to this point, so we are confident */
      /* that the function is not on this menu. */
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_found_recur',
          'returning FALSE');
      end if;

      return FALSE;
    end if;

    l_sub_menu_id := menulist(menulist_cur);

    -- See whether the current menu is excluded or not.
    entry_excluded := FALSE;
    begin
      if(    (l_sub_menu_id is not NULL)
         and (exclusions(l_sub_menu_id) = 'M')) then
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.menu_excl',
               'l_sub_menu_id:' || l_sub_menu_id );
        end if;
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

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.not_excl',
               ' Following was not excluded: l_sub_menu_id: ' ||
               to_char(l_sub_menu_id));
      end if;

      if (BULK_COLLECTS_SUPPORTED) then
        open get_mnes_c;
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
        for rec in get_mnes_c loop
          z := z + 1;
          tbl_menu_id(z) := rec.MENU_ID;
          tbl_ent_seq(z) := rec.ENTRY_SEQUENCE;
          tbl_func_id(z) := rec.FUNCTION_ID;
          tbl_submnu_id (z):= rec.SUB_MENU_ID;
          tbl_gnt_flg(z) := rec.GRANT_FLAG;
        end loop;
        last_index := z;
      end if;


    end if; /* entry_excluded */

    -- Process each of the child entries fetched
    for i in 1 .. last_index loop
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.proc_child',
               'Processing child of current menu.  tbl_func_id(i):' ||
               tbl_func_id(i) || ' tbl_submenu_id(i):'||
               tbl_submnu_id(i));
      end if;

      -- Check if there is an exclusion rule for this entry
      entry_excluded := FALSE;
      begin
        if(    (tbl_func_id(i) is not NULL)
           and (exclusions(tbl_func_id(i)) = 'F')) then
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.func_excl',
               'tbl_func_id(i):' || tbl_func_id(i) );
          end if;
          entry_excluded := TRUE;
        end if;
      exception
        when no_data_found then
          null;
      end;

      -- Skip this entry if it's excluded
      if (not entry_excluded) then
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.not_excl',
               'Entry not excluded.  Checking function:'
               ||to_char(tbl_func_id(i))|| ' against p_function_id:'
               ||to_char(p_function_id)||' where grant_flag='||tbl_gnt_flg(i));
        end if;
        -- Check if this is a matching function.  If so, return success.
        if(    (tbl_func_id(i) = p_function_id)
           and (tbl_gnt_flg(i) = 'Y'))
        then
          if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             c_log_head || l_api_name || '.end_found',
             'returning TRUE');
          end if;
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
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
     c_log_head || l_api_name || '.end_not_found',
     'returning FALSE');
  end if;
  return FALSE;
end PROCESS_MENU_TREE_DOWN_FOR_MN;


-- PROCESS_MENU_TREE_DOWN
--   Plow through the menu tree, processing exclusions and figuring
--   out which functions are accessible.
-- IN
--   p_appl_id - application id of resp
--   p_resp_id - responsibility id of current user
--   p_function_id- function to check for
--
-- RETURNS
--  TRUE if function is accessible
--
function PROCESS_MENU_TREE_DOWN(
  p_appl_id in number,
  p_resp_id in number,
  p_function_id in number
      ) return boolean is
  l_menu_id NUMBER;
  l_api_name  CONSTANT VARCHAR2(30)     := 'PROCESS_MENU_TREE_DOWN';
begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_appl_id=>'|| to_char(p_appl_id) ||
          ', p_resp_id=>'|| p_resp_id ||
          ', p_function_id=>'|| p_function_id||
          ')');
  end if;

  if (    (P_LAST_RESP_ID = p_resp_id)
      and (P_LAST_RESP_APPL_ID = p_appl_id)) then
     /* If the cache is valid just use the cache */
     l_menu_id := P_LAST_MENU_ID;
  else
    /* Find the root menu for this responsibility */
    begin
      select menu_id
        into l_menu_id
        from fnd_responsibility
       where responsibility_id = p_resp_id
         and application_id    = p_appl_id;
      /* Store the new value in the cache */
      P_LAST_RESP_ID := p_resp_id;
      P_LAST_RESP_APPL_ID := p_appl_id;
      P_LAST_MENU_ID := l_menu_id;
    exception
      when no_data_found then
        /* No menu for this resp, so there can't be any functions */

        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end_no_menu_resp',
                  'returning FALSE');
        end if;
        return FALSE;
    end;
  end if;
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                  c_log_head || l_api_name || '.end',
                  'return call to PROCESS_MENU_TREE_DOWN_FOR_MN '||
                  ' l_menu_id = '||l_menu_id);
  end if;
  return PROCESS_MENU_TREE_DOWN_FOR_MN(l_menu_id, p_function_id,
               p_appl_id, p_resp_id);
end PROCESS_MENU_TREE_DOWN;


-- MARK_MENU
--   Plow through the menu tree upwards, marking menus as we go up, so that
--   all the menus that include this menu will be marked.  Stop when we reach
--   menus that have already been marked.
-- IN
--   menu_id     - menu to mark
-- RETURNS
--  TRUE if success
--
procedure MARK_MENU_I(p_menu_id in number) is
pragma autonomous_transaction;
/*
** Normally it would be bad to pragma this as autonomous since it gets called
** from db triggers in transactions that can get rolled back.  The author
** claims it's harmless for this routine to have marked rows even if the
** mark is for a rolled back change, but another problem with this scheme
** is that this code won't see the changes that the surrounding transaction
** is trying to commit.  The author claims that the pragma should help
** prevent deadlocks (change added for 3229888).
** ### Is this still needed now that locking code has been added?
** ### George thinks that it's best to have marks written and visible
** ### as quickly as possible for situations such as data loading, so
** ### for now the code is left as-is.  In theory, though, this pragma
** ### should be moved to MARK_MENU, the locking surround for this routine.
*/
  l_api_name  CONSTANT VARCHAR2(30)     := 'MARK_MENU';
  l_menu_id number;
  l_sub_menu_id number;
  mark_existed boolean;

  /* Menu Entry table record type */
  TYPE MNE_REC_TYPE IS RECORD
  (MENU_ID       NUMBER,
   ENTRY_SEQ     NUMBER,
   FUNCTION_ID   NUMBER,
   SUB_MENU_ID   NUMBER,
   GRANT_FLAG    VARCHAR2(1));

  /* Define the menu entry table type */
  TYPE MNE_TYPE is table of MNE_REC_TYPE INDEX BY BINARY_INTEGER;

  /* The actual menu entry tables */
  CUR_MNES  MNE_TYPE;
  CUR_MNES_SIZE BINARY_INTEGER := 0;



  /* Table to store the list of submenus that we are looking for */
  TYPE MENULIST_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  MENULIST  MENULIST_TYPE;

  TYPE NUMBER_TABLE_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  TYPE VARCHAR2_TABLE_TYPE is table of VARCHAR2(1) INDEX BY BINARY_INTEGER;

  /* Returns from the bulk collect (fetches) */
  TBL_MENU_ID NUMBER_TABLE_TYPE;
  TBL_ENT_SEQ NUMBER_TABLE_TYPE;
  TBL_FUNC_ID NUMBER_TABLE_TYPE;
  TBL_SUBMNU_ID NUMBER_TABLE_TYPE;
  TBL_GNT_FLG VARCHAR2_TABLE_TYPE;


  /* Cursor to get menu entries that have a submenu*/
  cursor get_mnes_w_sm_c is
      SELECT MENU_ID, ENTRY_SEQUENCE, FUNCTION_ID, SUB_MENU_ID, GRANT_FLAG
        from fnd_menu_entries
       where SUB_MENU_ID  = l_sub_menu_id;

  entry_excluded boolean;
  already_in_list boolean;
  i number;
  j number;
  k number;
  m number;
  p number;
  z number;
  last_index pls_integer;


begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name || '(' ||
          'p_menu_id=>'|| p_menu_id||');');
  end if;
  --
  -- This routine processes the menu hierarchy upwards, marking on the way.
  -- The basic algorithm of this routine is:
  -- cur_mne(1).menu_id = menu passed in
  -- loop
  -- {
  --   for each element of cur_mne
  --   {
  --      Mark this menu as uncompiled.
  --      If it was already marked, go on to another one.
  --      Select and add all the menu entries under its menu_id onto cur_mne
  --   }
  -- } until there are no more elements in cur_mne

  /* We are going to add all the menu entries that have this function */
  /* to the list, processing exclusion rules and checking them as we go. */
  CUR_MNES_SIZE := 0;

  CUR_MNES(CUR_MNES_SIZE).MENU_ID     := p_menu_id;
  CUR_MNES(CUR_MNES_SIZE).ENTRY_SEQ   := 0;
  CUR_MNES(CUR_MNES_SIZE).SUB_MENU_ID := 0;
  CUR_MNES(CUR_MNES_SIZE).FUNCTION_ID := 0;
  CUR_MNES(CUR_MNES_SIZE).GRANT_FLAG  := 0;
  CUR_MNES_SIZE := CUR_MNES_SIZE + 1;

  /* Keep processing until there are no more menu entries in the list */
  /* (or until we break out of this loop upon finding the menu) */
  while (CUR_MNES_SIZE > 0) loop /* For each level */
    i := 0;
    m := 0;

    /* Loop through all the menu entries on the current list */
    while (i < CUR_MNES_SIZE) loop /* For each entry at the level */
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
          c_log_head || l_api_name || '.proc_ent',
          'Processing entry.  i:' || to_char(i)||
          ' CUR_MNES(i).MENU_ID:'|| to_char(CUR_MNES(i).MENU_ID) ||
          ' CUR_MNES(i).ENTRY_SEQ:'|| to_char(CUR_MNES(i).ENTRY_SEQ) ||
          ' CUR_MNES(i).SUB_MENU_ID:'|| to_char(CUR_MNES(i).SUB_MENU_ID) ||
          ' CUR_MNES(i).FUNCTION_ID:'|| to_char(CUR_MNES(i).FUNCTION_ID) ||
          ' CUR_MNES(i).GRANT_FLAG:'|| CUR_MNES(i).GRANT_FLAG);
      end if;
      begin
        insert into fnd_compiled_menu_functions
          (menu_id, function_id, grant_flag)
          values
          (CUR_MNES(i).MENU_ID, C_INVALID_MENU_VAL, C_INVALID_GRANT_VAL);
        commit;
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            c_log_head || l_api_name || '.marked',
            'Mark inserted.');
        end if;
        mark_existed := FALSE;
      exception
        when dup_val_on_index then
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.marked_existed',
              'Mark was already there. ');
          end if;
          mark_existed := TRUE;
      end;

      if (not mark_existed) then
        /* Put this on the list of menus we will get */
        if(CUR_MNES(i).MENU_ID is not NULL) then
          MENULIST(m) := CUR_MNES(i).MENU_ID;
          m := m + 1;
        end if;
      end if;

      i := i + 1;
    end loop;

    CUR_MNES_SIZE := 0;

    /* Process the list of parent menuids */
    p := 0;
    while (p < m) loop
      /* Get the list of menu entries above a particular submenu */
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
           c_log_head || l_api_name || '.handle_menulist',
           'Handling Menulist.  p:' || to_char(p)||
           ' MENULIST(p):'|| to_char(MENULIST(p)));
      end if;
      l_sub_menu_id := MENULIST(p);

      if (BULK_COLLECTS_SUPPORTED) then
        open get_mnes_w_sm_c;
        fetch get_mnes_w_sm_c bulk collect into tbl_menu_id, tbl_ent_seq,
               tbl_func_id, tbl_submnu_id, tbl_gnt_flg;
        close get_mnes_w_sm_c;
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
        for rec in get_mnes_w_sm_c loop
          z := z + 1;
          tbl_menu_id(z) := rec.MENU_ID;
          tbl_ent_seq(z) := rec.ENTRY_SEQUENCE;
          tbl_func_id(z) := rec.FUNCTION_ID;
          tbl_submnu_id (z):= rec.SUB_MENU_ID;
          tbl_gnt_flg(z) := rec.GRANT_FLAG;
        end loop;
        last_index := z;
      end if;


      /* put those menu entries into the list for next time */
      for q in 1..last_index loop
        CUR_MNES(CUR_MNES_SIZE).MENU_ID     := tbl_menu_id(q);
        CUR_MNES(CUR_MNES_SIZE).ENTRY_SEQ   := tbl_ent_seq(q);
        CUR_MNES(CUR_MNES_SIZE).SUB_MENU_ID := tbl_submnu_id(q);
        CUR_MNES(CUR_MNES_SIZE).FUNCTION_ID := tbl_func_id(q);
        CUR_MNES(CUR_MNES_SIZE).GRANT_FLAG  := tbl_gnt_flg(q);
        CUR_MNES_SIZE := CUR_MNES_SIZE + 1;
      end loop; /* for q in...*/
      p := p + 1;
    end loop; /* while (j < EXCLUSIONS_SIZE) loop */

  end loop; /* while (i < CUR_MNES_SIZE) loop */

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'end');
  end if;
end MARK_MENU_I;


-- ADD_QUEUED_MARKS-
--  Calls MARK_MENUS for all menus that we called QUEUE_MARK on.
--
procedure ADD_QUEUED_MARKS
is
  l_api_name  CONSTANT VARCHAR2(30)     := 'ADD_QUEUED_MARKS';
  RSTATUS number;
begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name);
   end if;
   if (DBMS_LOCK.REQUEST(C_MENU_LOCK_ID, DBMS_LOCK.S_MODE) = 0) then
     begin
       for i in 1..TBL_QUEUED_MENU_ID_MAX loop
         MARK_MENU_I(TBL_QUEUED_MENU_ID(TBL_QUEUED_MENU_ID_MAX));
       end loop;
       -- Commit;
       TBL_QUEUED_MENU_ID_MAX := 0;
     exception when OTHERS then
       null;
     end;
     RSTATUS := DBMS_LOCK.RELEASE(C_MENU_LOCK_ID);
   end if;
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'return');
   end if;
end;



-- QUEUE_MARK- store up a mark so it can later be processed.  This is
--   normally only called from db triggers; other code can and should
--   just call mark_menu directly.
-- IN
--   p_menu_id     - menu to mark
--
procedure QUEUE_MARK(
   p_menu_id in number) is
  l_api_name  CONSTANT VARCHAR2(30)     := 'QUEUE_MARK';
begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name ||'(' ||
          'p_menu_id=>'|| p_menu_id||');');
   end if;
   if (TBL_QUEUED_MENU_ID_MAX <> 0)
       AND (TBL_QUEUED_MENU_ID(TBL_QUEUED_MENU_ID_MAX) = p_menu_id) then
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_dupfound',
          'return');
     end if;
     return; /* Dont make duplicate marks */
   end if;

   /* Store the mark away. */
   TBL_QUEUED_MENU_ID_MAX := TBL_QUEUED_MENU_ID_MAX + 1;
   TBL_QUEUED_MENU_ID(TBL_QUEUED_MENU_ID_MAX) := p_menu_id;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'mark stored as TBL_QUEUED_MENU_ID_MAX: '||TBL_QUEUED_MENU_ID_MAX);
   end if;
end;



-- MARK_MENU
--   Plow through the menu tree upwards, marking menus as we go up, so that
--   all the menus that include this menu will be marked.  Stop when we reach
--   menus that have already been marked.
-- IN
--   menu_id     - menu to mark
-- RETURNS
--  TRUE if success
--
procedure MARK_MENU(p_menu_id in number) is
  RSTATUS number;
begin
  if (DBMS_LOCK.REQUEST(C_MENU_LOCK_ID, DBMS_LOCK.S_MODE) = 0) then
    begin
      MARK_MENU_I(p_menu_id);
      -- Commit;
    exception when OTHERS then
      null;
    end;
    RSTATUS := DBMS_LOCK.RELEASE(C_MENU_LOCK_ID);
  end if;
end MARK_MENU;




-- TEST_ID_NO_GRANTS
--   Test if function id is accessible under current responsibility.
--   Looks only at the menus on current resp, not any grants.
-- IN
--   function_id - function id to test
--   MAINTENANCE_MODE_SUPPORT- the value from the column in fnd_form_functions
--   CONTEXT_DEPENDENCE-       the value from the column in fnd_form_functions
--   TEST_MAINT_AVAILABILTY-   'Y' (default) means check if available for
--                             current value of profile APPS_MAINTENANCE_MODE
--                             'N' means the caller is checking so it's
--                             unnecessary to check.
-- RETURNS
--  TRUE if function is accessible
--
function TEST_ID_NO_GRANTS(function_id in number,
                  MAINTENANCE_MODE_SUPPORT in varchar2,
                  CONTEXT_DEPENDENCE in varchar2,
                  TEST_MAINT_AVAILABILITY in varchar2)
                 return boolean
is
  l_api_name  CONSTANT VARCHAR2(30)     := 'TEST_ID_NO_GRANTS(4_ARGS)';
  l_function_id  number;
  l_menu_id      number;
  dummy          number;
  l_resp_id      number;
  l_resp_appl_id number;
  result         boolean;
  L_TEST_MAINT_AVAILABILITY boolean;
begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'function_id =>'|| function_id ||
          'MAINTENANCE_MODE_SUPPORT =>'|| MAINTENANCE_MODE_SUPPORT ||
          'CONTEXT_DEPENDENCE =>'|| CONTEXT_DEPENDENCE ||
          'TEST_MAINT_AVAILABILITY =>'|| TEST_MAINT_AVAILABILITY ||
          ');');
  end if;

  l_function_id := function_id;
  l_resp_id := Fnd_Global.Resp_Id;
  l_resp_appl_id := Fnd_Global.Resp_Appl_Id;

  if (   (TEST_MAINT_AVAILABILITY = 'Y')
      OR (TEST_MAINT_AVAILABILITY is NULL)) then
    L_TEST_MAINT_AVAILABILITY := TRUE;
  else
    L_TEST_MAINT_AVAILABILITY := FALSE;
  end if;

  begin
    /* See if there are any exclusions */
    select 1
      into dummy
      from fnd_resp_functions
     where responsibility_id = l_resp_id
       and application_id    = l_resp_appl_id
       and rownum = 1;

    /* If we got here then there are exclusions, so don't use compiled */
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
       c_log_head || l_api_name || '.end_excl',
       'Because of exclusions, falling back, calling process_menu_tree_down.');
    end if;

    result := process_menu_tree_down(Fnd_Global.Resp_Appl_Id,
                                     Fnd_Global.Resp_Id,
                                     l_function_id);
    if(result = FALSE) then
       return FALSE;
    else
       if(L_TEST_MAINT_AVAILABILITY) then
         if(AVAILABILITY(MAINTENANCE_MODE_SUPPORT) = 'Y') then
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
      /* If we got here, there are no exclusions. */
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.not_excl',
               'No exclusions, so finding menu');
      end if;
      if (    (P_LAST_RESP_ID = l_resp_id)
          and (P_LAST_RESP_APPL_ID = l_resp_appl_id)) then
         /* If the cache is valid just use the cache */
         l_menu_id := P_LAST_MENU_ID;
      else
        /* Find the root menu for this responsibility */
        begin
          select menu_id
            into l_menu_id
            from fnd_responsibility
           where responsibility_id = l_resp_id
             and application_id    = l_resp_appl_id;
          /* Store the new value in the cache */
          P_LAST_RESP_ID := l_resp_id;
          P_LAST_RESP_APPL_ID := l_resp_appl_id;
          P_LAST_MENU_ID := l_menu_id;
        exception
          when no_data_found then
            /* No menu for this resp, so there can't be any functions */
            if (fnd_log.LEVEL_PROCEDURE >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
               c_log_head || l_api_name || '.end_no_menu',
               'Couldnt find root menu for resp. returning FALSE ');
            end if;
            return FALSE;
        end;
      end if;
  end;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
     c_log_head || l_api_name || '.end',
     'Returning with call to is_function_on_menu; ');
  end if;

  /* This is that call to actually do the test */
  result := IS_FUNCTION_ON_MENU(l_menu_id, l_function_id, TRUE);

  if(result = FALSE) then
     return FALSE;
  else
     if(L_TEST_MAINT_AVAILABILITY) then
       if(AVAILABILITY(MAINTENANCE_MODE_SUPPORT) = 'Y') then
         return TRUE;
       else
         return FALSE;
       end if;
     else
       return TRUE;
     end if;
  end if;

end TEST_ID_NO_GRANTS;


/* TEST_ID_SLOW- used for testing the security system.  Note that this */
/*               code is no longer maintained and is actually out of date */
/*               because it doesn't consider MAINTENANCE_MODE_SUPPORT */
function TEST_ID_SLOW(function_id in number) return boolean
is
  l_api_name  CONSTANT VARCHAR2(30)     := 'TEST_ID';
  l_function_id number;
begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
     c_log_head || l_api_name || '.begin',
     'function_id: '||function_id);
  end if;

  l_function_id := function_id;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
     c_log_head || l_api_name || '.end',
     'Returning with call to process_menu_tree_down; ');
  end if;
  return process_menu_tree_down(Fnd_Global.Resp_Appl_Id,
                               Fnd_Global.Resp_Id,
                               l_function_id);
end TEST_ID_SLOW;


function IS_FUNCTION_ON_MENU(p_menu_id     IN NUMBER,
                             p_function_id IN NUMBER,
                             p_check_grant_flag IN BOOLEAN)
return boolean is
  l_api_name CONSTANT VARCHAR2(30) := 'IS_FUNCTION_ON_MENU';

  dummy number;
  marked_as_not_compiled boolean;
  some_compiled_menus boolean;
  p_chk_gnt_as_vc varchar2(1);
begin
  if (p_check_grant_flag) then
    p_chk_gnt_as_vc := 'Y';
  else
    p_chk_gnt_as_vc := 'N';
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_menu_id =>'|| to_char(p_menu_id) ||
          'p_check_grant_flag (as vc) =>'|| p_chk_gnt_as_vc || ');');
  end if;

  if (FND_FUNCTION.G_ALREADY_FAST_COMPILED <> 'T') then
    FND_FUNCTION.FAST_COMPILE;
  end if;

  -- Check first if there are any compiled rows at all for the menu
  some_compiled_menus := FALSE;
  begin
    select 1
    into dummy
    from fnd_compiled_menu_functions
    where menu_id = p_menu_id
      and rownum = 1;
    /* If we got here, there are compiled rows */
    some_compiled_menus := TRUE;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.compiled_rows',
              'There are compiled rows.');
    end if;
  exception
    when no_data_found then
      some_compiled_menus := FALSE;
  end;

  -- If any compiled menus at all, see if any of those are invalid
  marked_as_not_compiled := FALSE;
  if (some_compiled_menus) then
    begin
      select 1
        into dummy
      from fnd_compiled_menu_functions
      where menu_id = p_menu_id
        and grant_flag = C_INVALID_GRANT_VAL
        and rownum = 1;
      /* If we got here we know this is marked as not compiled. */
      marked_as_not_compiled := TRUE;
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.marked_as_not_comp',
              'Menu Marked as not compiled.');
    end if;
    exception
      when no_data_found then
        marked_as_not_compiled := FALSE;
    end;
  end if;

  -- If there are any rows, AND none of the rows are invalid, then
  -- assume the menu must be compiled.
  if (some_compiled_menus and (not marked_as_not_compiled)) then
    begin
      if (p_check_grant_flag) then
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.check_w_gflg',
              'Checking with grantflag for p_menu_id: '|| to_char(p_menu_id)
              ||' and p_function_id:'||to_char(p_function_id));
        end if;

        select 1
        into dummy
        from fnd_compiled_menu_functions
        where menu_id = p_menu_id
        and function_id = p_function_id
        and grant_flag = 'Y' ;
      else
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.check_wo_gflg',
              'Checking without grantflag for p_menu_id: '|| to_char(p_menu_id)
              ||' and p_function_id:'||to_char(p_function_id));
        end if;

        select 1
        into dummy
        from fnd_compiled_menu_functions
        where menu_id = p_menu_id
        and function_id = p_function_id;
      end if;

      /* If we got here that means we found the compiled row */
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_comp_found',
          'found compiled row. returning TRUE');
      end if;
      return TRUE;
    exception
      when no_data_found then
        /* Not in compilation, so this function is not in the menu */
        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            c_log_head || l_api_name || '.end_comp_nfound',
            'found no compiled row. returning FALSE');
        end if;
        return FALSE;
    end;
  else
    /* Submit a concurrent request to compile the marked menus. */
    begin
      FND_JOBS_PKG.SUBMIT_MENU_COMPILE;
    exception
       when others then /* Don't error out if we can't submit the request.*/
          if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
              c_log_head || l_api_name || '.req_submit_fail',
            'Could not submit concurrent request FNDSCMPI to recompile menus');
          end if;
    end;

    /* The menu is uncompiled so fall back to the full tree search */
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
            'uncompiled, fall back. return process_menu_tree_down_for_mn()');
    end if;
    return process_menu_tree_down_for_mn(p_menu_id, p_function_id,
                                         NULL, NULL);
  end if;
end IS_FUNCTION_ON_MENU;


function TEST_INSTANCE_ID_MAINTMODE(function_id in varchar2,
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
) return boolean is
   l_api_name  CONSTANT VARCHAR2(30)    := 'TEST_INSTANCE_ID_MAINTMODE';
   ret_val varchar2(1) := 'F';
   ret_bool boolean := FALSE;
   L_MAINTENANCE_MODE_SUPPORT varchar2(8) := NULL;
   L_CONTEXT_DEPENDENCE       varchar2(8) := NULL;
   -- modified for bug#5395351
   l_function_name            fnd_form_functions.function_name%type := NULL;
begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name || '(' ||
          'function_id=>'|| function_id||
          ', object_name=>'|| object_name||
          ', instance_pk1_value=>'|| instance_pk1_value||
          ', instance_pk2_value=>'|| instance_pk2_value||
          ', instance_pk3_value=>'|| instance_pk3_value||
          ', instance_pk4_value=>'|| instance_pk4_value||
          ', instance_pk5_value=>'|| instance_pk5_value||
          ', user_name=>'|| nvl(user_name, '[NULL]')||
          ');');
   end if;


   if (    (fnd_data_security.DISALLOW_DEPRECATED = 'Y')
               and (   (user_name <> SYS_CONTEXT('FND','USER_NAME'))
                    or (     (user_name is not null)
                         and (SYS_CONTEXT('FND','USER_NAME') is null)))) then
              /* In R12 we do not allow passing values other than */
              /* the current user name (which is the default), */
              /* so we raise a runtime exception if that deprecated */
              /* kind of call is made to this routine. */
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
                    'Invalid API call.  Parameter user_name: '||user_name||
                    ' was passed to API '||c_pkg_name || '.TEST_INSTANCE' ||
                    '.  object_name: '||object_name||'.  '||
                    ' In Release 12 and beyond the user_name parameter '||
                    'is unsupported, and any product team that passes it '||
                    'must correct their code because it does not work '||
                    'correctly.  Please see the deprecated API document at '||
                    'http://files.oraclecorp.com/content/AllPublic/'||
                    'SharedFolders/ATG%20Requirements-Public/R12/'||
                    'Requirements%20Definition%20Document/'||
                    'Application%20Object%20Library/DeprecatedApiRDD.doc '||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine, which is likely the owner of the object that '||
                    'was passed to this routine: '||
                    object_name);
              if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_depr_param',
                     FALSE);
              end if;
              fnd_message.raise_error;
   end if;


   -- Change function name to id
   begin
     select F.FUNCTION_NAME, F.MAINTENANCE_MODE_SUPPORT, F.CONTEXT_DEPENDENCE
     into l_function_name, L_MAINTENANCE_MODE_SUPPORT, L_CONTEXT_DEPENDENCE
     from FND_FORM_FUNCTIONS F
     where F.FUNCTION_ID = test_instance_id_maintmode.function_id;
   exception
     when no_data_found then
       -- Invalid function name
       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
           c_log_head || l_api_name || '.end_notfound',
           'returning FALSE');
       end if;
       return(FALSE);
   end;


   if (TEST_ID_NO_GRANTS(function_id,
                 L_MAINTENANCE_MODE_SUPPORT, L_CONTEXT_DEPENDENCE, 'N')) then
     ret_bool := TRUE;
     goto check_avail;
   end if;

   if (object_name is not NULL) then
     ret_val := FND_DATA_SECURITY.CHECK_FUNCTION(p_api_version => 1.0,
                                    p_function           => l_function_name,
                                    p_object_name        => object_name,
                                    p_instance_pk1_value => instance_pk1_value,
                                    p_instance_pk2_value => instance_pk2_value,
                                    p_instance_pk3_value => instance_pk3_value,
                                    p_instance_pk4_value => instance_pk4_value,
                                    p_instance_pk5_value => instance_pk5_value,
                                    p_user_name          => user_name);
     if (ret_val = 'T') then
       ret_bool := TRUE;
       goto check_avail;
     else
         if (ret_val = 'E') or (ret_val = 'U') then
             FND_MESSAGE.CLEAR;
         end if;
         ret_bool := FALSE;
     end if;
   end if;

   if (ret_bool = FALSE) then /* Check global object type grant */
       ret_val := FND_DATA_SECURITY.check_global_object_type_grant
                  (p_api_version => 1.0,
                   p_function           => l_function_name,
                   p_user_name          => user_name);
       if (ret_val = 'T') then
         ret_bool := TRUE;
         goto check_avail;
       else
         ret_bool := FALSE;
         goto all_done;
       end if;
   end if;


<<check_avail>>
   if (ret_bool = TRUE) then
     if(AVAILABILITY(L_MAINTENANCE_MODE_SUPPORT) = 'Y') then
       ret_bool := TRUE;
     else
       ret_bool := FALSE;
     end if;
   end if;

<<all_done>>

   if (ret_bool) then
       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
           c_log_head || l_api_name || '.end_available',
           'returning TRUE;');
       end if;
       return TRUE;
   else
       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
           c_log_head || l_api_name || '.end_false',
           'returning FALSE;');
       end if;
       return FALSE;
   end if;

end TEST_INSTANCE_ID_MAINTMODE;


function TEST_INSTANCE_ID(function_id in varchar2,
                       object_name          IN  VARCHAR2,
                       instance_pk1_value   IN  VARCHAR2,
                       instance_pk2_value   IN  VARCHAR2,
                       instance_pk3_value   IN  VARCHAR2,
                       instance_pk4_value   IN  VARCHAR2,
                       instance_pk5_value   IN  VARCHAR2,
                       user_name            IN  VARCHAR2
) return boolean is
   l_api_name  CONSTANT VARCHAR2(30)    := 'TEST_INSTANCE_ID';
   ret_val boolean := FALSE;
   L_MAINTENANCE_MODE_SUPPORT varchar2(8) := NULL;
   L_CONTEXT_DEPENDENCE       varchar2(8) := NULL;
begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'function_id =>'|| function_id ||
          ');');
  end if;

  -- Change function name to id
  begin
    -- Bug 5059644. Modified bind variable name from function_id to
    -- TEST_INSTANCE_ID.function_id. This change is to avoid FTS.
    select  F.MAINTENANCE_MODE_SUPPORT, F.CONTEXT_DEPENDENCE
    into L_MAINTENANCE_MODE_SUPPORT, L_CONTEXT_DEPENDENCE
    from FND_FORM_FUNCTIONS F
    where F.function_id = test_instance_id.function_id;
  exception
    when no_data_found then
      -- Invalid function name
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_notfound',
          'returning FALSE');
      end if;
      return(FALSE);
  end;

   ret_val := TEST_INSTANCE_ID_MAINTMODE(
               function_id,
               object_name,
               instance_pk1_value,
               instance_pk2_value,
               instance_pk3_value,
               instance_pk4_value,
               instance_pk5_value,
               user_name,
               L_MAINTENANCE_MODE_SUPPORT,
               L_CONTEXT_DEPENDENCE,
               'Y');

     if (ret_val) then
         if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             c_log_head || l_api_name || '.end_available',
             'returning TRUE;');
         end if;
         return TRUE;
     else
         if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             c_log_head || l_api_name || '.end_false',
             'returning FALSE;');
         end if;
         return FALSE;
     end if;

end TEST_INSTANCE_ID;


--
-- TEST_INSTANCE
--   Test if function is accessible under current resp and user, for
--   the object instance (database row) which is the current instance.
--   This actually checks both the function security
--   and data security system as described at the oracle internal link:
--       http://www-apps.us.oracle.com/atg/plans/r115x/datasec.txt
--   Note that this takes account of global object type grants (grants
--   that apply to all object types), as well as global object instance
--   grants (which apply to all instances of a particular object type).
--
--   Generally the user should pass the object_name and whichever
--   of the instance_pkX_values apply to that object.
--   If the user does not pass the object_name param, then only global
--     object type grants will get picked up from fnd_grants.
--   If the user does not pass the instance_pkXvalues, but does pass
--     object_name, only instance type grants will get picked up.
--
-- IN
--   function_name - function to test
--   object_name and pk values- object and primary key values of the current
--      object.
--   user_name- Normally the caller leaves this blank so it will test
--              with the current FND user.  But folks who populate their
--              grants with special "compound" usernames might need
--              to pass the grantee_key (user_name) of the current user.
-- RETURNS
--  TRUE if function is accessible
--  FALSE if function is not accessible or if there was an error.
--
function TEST_INSTANCE(function_name in varchar2,
                       object_name          IN  VARCHAR2,
                       instance_pk1_value   IN  VARCHAR2,
                       instance_pk2_value   IN  VARCHAR2,
                       instance_pk3_value   IN  VARCHAR2,
                       instance_pk4_value   IN  VARCHAR2,
                       instance_pk5_value   IN  VARCHAR2,
                       user_name            IN  VARCHAR2
) return boolean is
   l_api_name  CONSTANT VARCHAR2(30)    := 'TEST_INSTANCE';
   ret_val boolean := FALSE;
   function_id number;
   L_MAINTENANCE_MODE_SUPPORT varchar2(8);
   L_CONTEXT_DEPENDENCE       varchar2(8);
begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'function_name =>'|| function_name ||
          'object_name =>'|| object_name ||
          'instance_pk1_value =>'|| instance_pk1_value ||
          'instance_pk2_value =>'|| instance_pk2_value ||
          'instance_pk3_value =>'|| instance_pk3_value ||
          'instance_pk4_value =>'|| instance_pk4_value ||
          'instance_pk5_value =>'|| instance_pk5_value ||
          'user_name =>'|| user_name ||
          ');');
  end if;


  -- Change function name to id
  begin
    select F.FUNCTION_ID, F.MAINTENANCE_MODE_SUPPORT, F.CONTEXT_DEPENDENCE
    into function_id, L_MAINTENANCE_MODE_SUPPORT, L_CONTEXT_DEPENDENCE
    from FND_FORM_FUNCTIONS F
    where F.FUNCTION_NAME = test_instance.function_name;
  exception
    when no_data_found then
      -- Invalid function name
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_notfound',
          'returning FALSE');
      end if;
      return(FALSE);
  end;

   ret_val := TEST_INSTANCE_ID_MAINTMODE(
               function_id,
               object_name,
               instance_pk1_value,
               instance_pk2_value,
               instance_pk3_value,
               instance_pk4_value,
               instance_pk5_value,
               user_name,
               L_MAINTENANCE_MODE_SUPPORT,
               L_CONTEXT_DEPENDENCE,
               'Y');

     if (ret_val) then
         if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             c_log_head || l_api_name || '.end_available',
             'returning TRUE;');
         end if;
         return TRUE;
     else
         if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             c_log_head || l_api_name || '.end_false',
             'returning FALSE;');
         end if;
         return FALSE;
     end if;

end TEST_INSTANCE;


-- TEST_ID
--   Test if function id is accessible under current responsibility.
-- IN
--   function_id - function id to test
--   MAINTENANCE_MODE_SUPPORT- the value from the column in fnd_form_functions
--   CONTEXT_DEPENDENCE-       the value from the column in fnd_form_functions
--   TEST_MAINT_AVAILABILTY-   'Y' (default) means check if available for
--                             current value of profile APPS_MAINTENANCE_MODE
--                             'N' means the caller is checking so it's
--                             unnecessary to check.
-- RETURNS
--  TRUE if function is accessible
--
function TEST_ID(function_id in number,
                  MAINTENANCE_MODE_SUPPORT in varchar2,
                  CONTEXT_DEPENDENCE in varchar2,
                  TEST_MAINT_AVAILABILITY in varchar2)
                 return boolean
is
  l_api_name  CONSTANT VARCHAR2(30)     := 'TEST_ID(4_ARGS)';
  result         boolean;
begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'function_id =>'|| function_id ||
          'MAINTENANCE_MODE_SUPPORT =>'|| MAINTENANCE_MODE_SUPPORT ||
          'CONTEXT_DEPENDENCE =>'|| CONTEXT_DEPENDENCE ||
          'TEST_MAINT_AVAILABILITY =>'|| TEST_MAINT_AVAILABILITY ||
          ');');
  end if;

  result := TEST_INSTANCE_ID_MAINTMODE(
                         function_id => function_id,
                         object_name => NULL,
                         instance_pk1_value => NULL,
                         instance_pk2_value => NULL,
                         instance_pk3_value => NULL,
                         instance_pk4_value => NULL,
                         instance_pk5_value => NULL,
                         user_name => NULL,
                         MAINTENANCE_MODE_SUPPORT =>MAINTENANCE_MODE_SUPPORT,
                         CONTEXT_DEPENDENCE => CONTEXT_DEPENDENCE,
                         TEST_MAINT_AVAILABILITY => TEST_MAINT_AVAILABILITY);

  if (result) then
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_available',
          'returning TRUE;');
      end if;
      return TRUE;
  else
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_false',
          'returning FALSE;');
      end if;
      return FALSE;
  end if;

end TEST_ID;





-- TEST_ID
--   Test if function id is accessible under current responsibility.
-- IN
--   function_id - function id to test
-- RETURNS
--  TRUE if function is accessible
--
function TEST_ID(function_id in number) return boolean
is
  L_MAINTENANCE_MODE_SUPPORT varchar2(8);
  L_CONTEXT_DEPENDENCE varchar2(8);
  l_function_id        number;
  l_api_name  CONSTANT VARCHAR2(30)     := 'TEST_ID(1_ARG)';
begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'function_id =>'|| function_id || ');');
  end if;

  L_MAINTENANCE_MODE_SUPPORT := NULL;
  L_CONTEXT_DEPENDENCE := NULL;
  l_function_id := function_id;
  begin
    /* Get the extra columns */
    select MAINTENANCE_MODE_SUPPORT, CONTEXT_DEPENDENCE
      into L_MAINTENANCE_MODE_SUPPORT, L_CONTEXT_DEPENDENCE
      from fnd_form_functions
     where function_id = l_function_id;

  exception
    when no_data_found then
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_bad_fnid',
          'function_id passed to test_id cant be found in fnd_form_functions.');
      end if;
      return FALSE; /* Bad function id passed */
  end;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
      c_log_head || l_api_name || '.end_call_3_arg',
      'Passing MAINTENANCE_MODE_SUPPORT and CONTEXT_DEPENDENCE to test_id().');
  end if;

  return test_id(l_function_id,
                 L_MAINTENANCE_MODE_SUPPORT, L_CONTEXT_DEPENDENCE, 'Y');
end TEST_ID;



--
-- TEST
--   Test if function is accessible under current responsibility.
-- IN
--   function_name - function to test
--   TEST_MAINT_AVAILABILTY-   'Y' (default) means check if available for
--                             current value of profile APPS_MAINTENANCE_MODE
--                             'N' means the caller is checking so it's
--                             unnecessary to check.
-- RETURNS
--  TRUE if function is accessible
--
function TEST(function_name in varchar2,
              TEST_MAINT_AVAILABILITY in varchar2) return boolean
is
  l_api_name  CONSTANT VARCHAR2(30)     := 'TEST';
  function_id number;
  L_MAINTENANCE_MODE_SUPPORT varchar2(8);
  L_CONTEXT_DEPENDENCE       varchar2(8);
  l_rtn       boolean;
  l_continue  boolean;
begin
  l_rtn  := FALSE;
  l_continue  := TRUE;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'function_name =>'|| function_name || ');');
  end if;

  -- Change function name to id
  begin
    select F.FUNCTION_ID, F.MAINTENANCE_MODE_SUPPORT, F.CONTEXT_DEPENDENCE
    into function_id, L_MAINTENANCE_MODE_SUPPORT, L_CONTEXT_DEPENDENCE
    from FND_FORM_FUNCTIONS F
    where F.FUNCTION_NAME = test.function_name;

    l_continue  := TRUE;

  exception
    when no_data_found then
      -- Invalid function name
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_notfound',
          'returning FALSE');
      end if;
      l_continue  := FALSE;

  end;

  -- Call test_id to complete
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
        c_log_head || l_api_name || '.end',
        'returning call to test_id of function_id:'||function_id
        ||' L_MAINTENANCE_MODE_SUPPORT:'||L_MAINTENANCE_MODE_SUPPORT
        ||' L_CONTEXT_DEPENDENCE:'||L_CONTEXT_DEPENDENCE);
  end if;

  IF l_continue = TRUE THEN
    l_rtn := Test_Id(function_id,
                   L_MAINTENANCE_MODE_SUPPORT, L_CONTEXT_DEPENDENCE,
                   TEST_MAINT_AVAILABILITY);
  END IF;

  -- Clear the message stack since everything else is already reported
  -- and write by fnd_log.string if log is enable
  --
  fnd_message.clear;

  return l_rtn;

end TEST;

/* Note: The reason for having separate _I (internal) routines is so that*/
/* the non- _I routines will always be top level routines and will never */
/* call other top level routines.  That way those top level routines can */
/* be pragma autonomous_transaction. */
/* If we didn't have it this way, we would have the situation where */
/* COMPILE_ALL_FROM_SCRATCH calls COMPILE_ALL_MARKED, which calls */
/* COMPILE_MENU_MARKED, and all those routines are */
/* pragma autononous_transaction because they can be called independently.*/
/* That would yield three nested autononous transactions which would at */
/* minimum waste rollback segments and at maximum would cause weird behavior */

function COMPILE_MENU_MARKED_I(p_menu_id NUMBER,
                   p_force in varchar2) return NUMBER;
function COMPILE_ALL_FROM_SCRATCH_I return NUMBER;
function COMPILE_ALL_MARKED_I(compile_missing in VARCHAR2)
 return NUMBER;
procedure MARK_ALL_I;

/* COMPILE_I- This API is invoked by the concurrent program */
procedure COMPILE_I( errbuf out NOCOPY varchar2,
                              retcode  out NOCOPY varchar2,
                              everything in varchar2 /* 'Y'= from scratch*/) is
  l_api_name  CONSTANT VARCHAR2(30) := 'COMPILE';
  numrows NUMBER;
  msgbuf varchar2(2000);
begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name ||'(' ||
          'everything=>'|| everything||');');
   end if;

   if(everything = 'Y') then
      numrows := COMPILE_ALL_FROM_SCRATCH_I;
      fnd_message.set_name('FND', 'SECURITY_COMPILED_FROM_SCRATCH');
      msgbuf := fnd_message.get;
      FND_FILE.put_line(FND_FILE.log, msgbuf);
   else
      numrows := COMPILE_ALL_MARKED_I('Y');
      fnd_message.set_name('FND', 'SECURITY_COMPILED_MARKED_MENUS');
      msgbuf := fnd_message.get;
      FND_FILE.put_line(FND_FILE.log, msgbuf);
   end if;

   fnd_message.set_name('FND', 'GENERIC_ROWS_PROCESSED');
   fnd_message.set_token('ROWS', numrows);
   msgbuf := fnd_message.get;
   FND_FILE.put_line(FND_FILE.log, msgbuf);

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'returning from compile.  numrows='||numrows);
   end if;
exception
   when others then
     errbuf := sqlerrm;
     retcode := '2';
     FND_FILE.put_line(FND_FILE.log,errbuf);
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_exception',
          'returning from compile with exception.  numrows='||numrows);
     end if;
     raise;
end compile_I;

/* COMPILE- This API is invoked by the concurrent program */
procedure COMPILE( errbuf out NOCOPY varchar2,
                              retcode  out NOCOPY varchar2,
                              everything in varchar2 /* 'Y'= from scratch*/) is
pragma autonomous_transaction;
  RSTATUS number;
begin
  if (DBMS_LOCK.REQUEST(C_MENU_LOCK_ID, DBMS_LOCK.X_MODE) = 0) then
    begin
      COMPILE_I(errbuf,  retcode, everything);
    exception when OTHERS then
      null;
    end;
    RSTATUS := DBMS_LOCK.RELEASE(C_MENU_LOCK_ID);
  end if;
end;


/* COMPILE_CHANGES - This API is invoked by the DBMS_SCHEDULER */
procedure COMPILE_CHANGES is
pragma autonomous_transaction;
  l_api_name  CONSTANT VARCHAR2(30) := 'COMPILE_CHANGES';
  numrows     NUMBER;
  RSTATUS number;
begin
   FND_JOBS_PKG.APPS_INITIALIZE_SYSADMIN;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name ||';');
   end if;

   if (DBMS_LOCK.REQUEST(C_MENU_LOCK_ID, DBMS_LOCK.X_MODE) = 0) then
     begin
       numrows := COMPILE_ALL_MARKED_I('Y');
     exception when OTHERS then
       null;
     end;
     RSTATUS := DBMS_LOCK.RELEASE(C_MENU_LOCK_ID);
   end if;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'returning from compile.  numrows='||numrows);
   end if;

exception
   when others then
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_exception',
          'returning from compile with exception.  numrows='||numrows);
     end if;
     -- ### Should log return code = 2 and sqlerrm buffer
     raise;
end;


-- COMPILE_ALL_FROM_SCRATCH_I-
-- Recompiles everything from scratch.
function COMPILE_ALL_FROM_SCRATCH_I return NUMBER is
  l_api_name  CONSTANT VARCHAR2(30) := 'COMPILE_ALL_FROM_SCRATCH';
begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name );
  end if;
  MARK_ALL_I;
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'returning COMPILE_ALL_MARKED');
  end if;
  return COMPILE_ALL_MARKED_I('Y');
end compile_all_from_scratch_I;

-- COMPILE_ALL_FROM_SCRATCH-
-- Recompiles everything from scratch.
function COMPILE_ALL_FROM_SCRATCH return NUMBER is
pragma autonomous_transaction;
  RESULT_COUNT number;
  RSTATUS number;
begin
  if (DBMS_LOCK.REQUEST(C_MENU_LOCK_ID, DBMS_LOCK.X_MODE) = 0) then
    begin
      RESULT_COUNT := COMPILE_ALL_FROM_SCRATCH_I;
    exception when OTHERS then
      null;
    end;
    RSTATUS := DBMS_LOCK.RELEASE(C_MENU_LOCK_ID);
  end if;
  return RESULT_COUNT;
end;



-- MARK_MISSING-
--
-- Marks as uncompiled all the menus that don't have any rows
-- in the compiled table.
-- No locking needed because it's only called internally from
-- a procedure that already has a lock.
--
procedure MARK_MISSING is
  l_api_name  CONSTANT VARCHAR2(30) := 'MARK_MISSING';

  TYPE NUMBER_TABLE_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  TBL_MENU_ID NUMBER_TABLE_TYPE;

  last_index pls_integer;

  /* Bug 5196541. Added sql hints to improve the performance */
  cursor get_missing_menus_c is
    select /*+ INDEX_FFS(menus) */ menu_id from fnd_menus menus
     where not exists
      (select 'X'
         from fnd_compiled_menu_functions cmf
        where menus.menu_id = cmf.menu_id);
  z number;
begin
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name );
    end if;

    /* Mark as uncompiled any menus that don't have a representation */
    /* in the compiled table */

    if (BULK_COLLECTS_SUPPORTED) then
      open get_missing_menus_c;
      fetch get_missing_menus_c bulk collect into tbl_menu_id;
      close get_missing_menus_c;

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
      for rec in get_missing_menus_c loop
        z := z + 1;
        tbl_menu_id(z) := rec.MENU_ID;
      end loop;
      last_index := z;
    end if;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
          c_log_head || l_api_name || '.got_list',
          'Got list of menus.  Number of elements- last_index:' ||
          last_index);
    end if;

    /* mark that menu as uncompiled */
    for q in 1..last_index loop
      begin
        insert into fnd_compiled_menu_functions
          (menu_id, function_id, grant_flag)
            values
          (tbl_menu_id(q), C_INVALID_MENU_VAL, C_INVALID_GRANT_VAL);
        -- We commit the menu mark in order to keep the rollback segment
        -- from getting too big as we compile lots of menus.
        commit;
      exception
        when dup_val_on_index then
          if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
              c_log_head || l_api_name || '.exception',
              'Duplicate Value on index.  Should never happen.');
          end if;
          null;  /* Should never happen but better safe than sorry */
      end;
    end loop;
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'end');
    end if;
end MARK_MISSING;


-- COMPILE_ALL_MARKED_I-
--
-- recompiles all the marked menus.
--
--  for (each menu_id marked)
--    FND_FUNCTION.COMPILE_MENU_MARKED(menu_id)
--
--  Returns number of compiled rows changed.
--
function COMPILE_ALL_MARKED_I(compile_missing in VARCHAR2)
 return number is
  l_api_name  CONSTANT VARCHAR2(30) := 'COMPILE_ALL_MARKED';
  l_menu_id number;
  l_rows_processed number;

  TYPE NUMBER_TABLE_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  TBL_MENU_ID NUMBER_TABLE_TYPE;

begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name ||'(' ||
          'compile_missing=>'|| compile_missing||');');
  end if;

  /* Mark any menus that aren't in the compiled representation, */
  /* so they will get recompiled */
  if (compile_missing = 'Y') then
     mark_missing;
  end if;

  l_rows_processed := 0;
  while (TRUE) loop
    /* Find a menu that needs compilation */
    begin /* The hint below was suggested to avoid FTS in bug 2078561 */
      select
    /*+ INDEX (fnd_compiled_menu_functions fnd_compiled_menu_functions_n3) */
        menu_id
        into l_menu_id
        from fnd_compiled_menu_functions
       where grant_flag = C_INVALID_GRANT_VAL
         and rownum = 1;
    exception
      when no_data_found then
        /* We've gotten to all the marked rows, so we are done */
        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            c_log_head || l_api_name || '.end_none_marked',
            'returning l_rows_processed:' || l_rows_processed );
        end if;

        -- Set the alreadt fast compiled flag since we are done bug5184601

        fnd_function.g_already_fast_compiled := 'T';
        return l_rows_processed;
    end;

    /* Reset recursion detector and recompile that menu */
    TBL_RECURS_DETEC_MENU_ID_MAX  := 0;

    l_rows_processed := l_rows_processed +
                        COMPILE_MENU_MARKED_I(l_menu_id, 'N');

  end loop;

  fnd_function.g_already_fast_compiled := 'T';
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'returning l_rows_processed:' || l_rows_processed );
  end if;
  return l_rows_processed;

end compile_all_marked_I;


-- COMPILE_ALL_MARKED-
--
-- recompiles all the marked menus.
--
--  for (each menu_id marked)
--    FND_FUNCTION.COMPILE_MENU_MARKED(menu_id)
--
--  Returns number of compiled rows changed.
--
function COMPILE_ALL_MARKED(compile_missing in VARCHAR2)
 return number is
pragma autonomous_transaction;
  RESULT_COUNT number;
  RSTATUS number;
begin
  if (DBMS_LOCK.REQUEST(C_MENU_LOCK_ID, DBMS_LOCK.X_MODE) = 0) then
    begin
      RESULT_COUNT := COMPILE_ALL_MARKED_I(compile_missing);
    exception when OTHERS then
      null;
    end;
    RSTATUS := DBMS_LOCK.RELEASE(C_MENU_LOCK_ID);
  end if;
  return RESULT_COUNT;
end;



-- FAST_COMPILE-
--
-- Recompiles all the marked menus if and only if they haven't yet
-- been already compiled in this session.
--
-- Other packages that reference FND_COMPILED_MENU_FUNCTIONS should
-- call it like this in their package initialization block:
--
--   if (FND_FUNCTION.G_ALREADY_FAST_COMPILED <> 'T') then
--     FND_FUNCTION.FAST_COMPILE;
--   end if;
--
-- Administrators can also call it from SQL*Plus in order to compile
-- the FND_COMPILED_MENU_FUNCTIONS table, like this:
--
-- execute FND_FUNCTION.FAST_COMPILE;
--
procedure FAST_COMPILE is
pragma autonomous_transaction;
  RESULT_COUNT number;
  RSTATUS number;
  L_MENU_ID number;
begin
  if (G_ALREADY_FAST_COMPILED <> 'T') then
    -- Check if any menus need compilation bug5184601
    begin

      select
       /*+ INDEX (fnd_compiled_menu_functions fnd_compiled_menu_functions_n3) */
         MENU_ID into L_MENU_ID
      from FND_COMPILED_MENU_FUNCTIONS
      where GRANT_FLAG = C_INVALID_GRANT_VAL
      and ROWNUM = 1;
    exception
      when NO_DATA_FOUND then
        G_ALREADY_FAST_COMPILED:= 'T';
        return;
      when OTHERS then
        null;
    end;
    if (DBMS_LOCK.REQUEST(C_MENU_LOCK_ID, DBMS_LOCK.X_MODE) = 0) then
      begin
        RESULT_COUNT := COMPILE_ALL_MARKED_I('N');
      exception when OTHERS then
        null;
      end;
      RSTATUS := DBMS_LOCK.RELEASE(C_MENU_LOCK_ID);
    end if;
  end if;
end;


--
-- COMPILE_MENU_MARKED_I
--   if (not force mode) and (this menu is not marked)
--      return; we're done
--   Delete all rows from fnd_compiled_menu_functions for this menu_id
--   for each menu_entry on this menu
--      if this is a function
--         add it to the compiled table
--      if this is a menu
--         Call FND_FUNCTION.COMPILE_MENU_MARKED() to compile this submenu
--         Copy all the submenu elements from the compiled table
--   delete the marker row for this menu_id
--
--   IN:
--   p_menu_id- menu to compile.
--   p_force- 'Y' means compile even if already marked compiled.
--            'N' is default, meaning only compile if not marked as compiled.
--   RETURNS - a count of how many rows needed to be processed.
--
function COMPILE_MENU_MARKED_I(p_menu_id NUMBER,
                   p_force in varchar2)
 return NUMBER is

  l_api_name             CONSTANT VARCHAR2(30) := 'COMPILE_MENU_MARKED';
  result boolean;
  dummy  number;
  cursor get_mnes_down_c is
      SELECT MENU_ID, ENTRY_SEQUENCE, FUNCTION_ID, SUB_MENU_ID, GRANT_FLAG
        from fnd_menu_entries
       where MENU_ID  = p_menu_id;

  TYPE NUMBER_TABLE_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  TYPE VARCHAR2_TABLE_TYPE is table of VARCHAR2(1) INDEX BY BINARY_INTEGER;

  /* Returns from the bulk collect (fetches) */
  TBL_MENU_ID NUMBER_TABLE_TYPE;
  TBL_ENT_SEQ NUMBER_TABLE_TYPE;
  TBL_FUNC_ID NUMBER_TABLE_TYPE;
  TBL_SUBMNU_ID NUMBER_TABLE_TYPE;
  TBL_GNT_FLG VARCHAR2_TABLE_TYPE;

  l_submnu_id NUMBER;
  cursor get_compiled_menu_fns_c is
    select function_id, grant_flag
           from fnd_compiled_menu_functions
          where menu_id = l_submnu_id
            and grant_flag <> C_INVALID_GRANT_VAL
            and grant_flag <> C_BLANK_GRANT_VAL;
  TBL_COPY_FUNC_ID NUMBER_TABLE_TYPE;
  TBL_COPY_GNT_FLG VARCHAR2_TABLE_TYPE;

  l_rows_processed NUMBER;
  l_sub_rows_processed NUMBER;
  last_index pls_integer;
  comp_fail exception;
  i number;
  j number;
begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_menu_id =>'|| p_menu_id ||
          'p_force =>'|| p_force || ');');
  end if;

  l_rows_processed := 0;

  /* Check to see if this menu is marked and bail if not marked. */
  if((p_force is NULL) OR (p_force <> 'Y')) then
    begin
      select 1
        into dummy
        from fnd_compiled_menu_functions
       where menu_id = p_menu_id
         and grant_flag = C_INVALID_GRANT_VAL
         and rownum = 1;
    exception
      when no_data_found then
        return 0; /* If we got here that means this menu is not marked; bail*/
    end;
  end if;

  /* Check the recursion stack to make sure this menu isn't also a */
  /* parent of this menu. */
  for i in 1..TBL_RECURS_DETEC_MENU_ID_MAX loop
    if ( TBL_RECURS_DETEC_MENU_ID(i) = p_menu_id ) then
       if (fnd_log.LEVEL_ERROR >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_ERROR,
           c_log_head || l_api_name || '.recursion',
           'A looping menu has been detected in menu_id:'||to_char(p_menu_id));
       end if;

       /* Don't go into an infinite recursion; this menu is already */
       /* being compiled so we don't need to do it again. */
       return 0;
    end if;
  end loop;

  /* Push this menu_id onto the recursion detection stack */
  TBL_RECURS_DETEC_MENU_ID_MAX := TBL_RECURS_DETEC_MENU_ID_MAX + 1;
  TBL_RECURS_DETEC_MENU_ID(TBL_RECURS_DETEC_MENU_ID_MAX) := p_menu_id;

  /* If we havent already deleted the data for this menu, delete it now. */
  begin
    delete from fnd_compiled_menu_functions
     where menu_id = p_menu_id
       and grant_flag <> C_INVALID_GRANT_VAL;
  exception when no_data_found then
     null;
  end;

  /* Get the list of menu entries below this submenu. */
  if(BULK_COLLECTS_SUPPORTED) then
    open get_mnes_down_c;
    fetch get_mnes_down_c bulk collect into tbl_menu_id, tbl_ent_seq,
               tbl_func_id, tbl_submnu_id, tbl_gnt_flg;
    close get_mnes_down_c;

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
    i:= 0;
    for below in get_mnes_down_c loop
      i := i + 1;
      tbl_menu_id(i) := below.MENU_ID;
      tbl_ent_seq(i) := below.ENTRY_SEQUENCE;
      tbl_func_id(i) := below.FUNCTION_ID;
      tbl_submnu_id (i):= below.SUB_MENU_ID;
      tbl_gnt_flg(i) := below.GRANT_FLAG;
    end loop;
    last_index := i;
  end if;



  if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.got_mnulist',
              'Got list of mnes below p_menu_id '||
               to_char(p_menu_id)||'.  Number of elements- last_index:'
               ||to_char(last_index));
  end if;

  /* put those menu entries into the list for next time */
  for q in 1..last_index loop
    /* If this is a function, Put this function into the cache */
    if (tbl_func_id(q) is not NULL) then
      begin
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.insert1',
              'Inserting into compiled table menu_id: '|| to_char(p_menu_id)
               ||' func_id:'||to_char(tbl_func_id(q) )
               ||' gnt_flag:'||tbl_gnt_flg(q) );
        end if;
        l_rows_processed := l_rows_processed + 1;
        insert into fnd_compiled_menu_functions
          (MENU_ID, FUNCTION_ID, GRANT_FLAG)
             values
          (p_menu_id, tbl_func_id(q), tbl_gnt_flg(q));
      exception
        when dup_val_on_index then
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.dup_val_index',
              'Insert failed with dup val on index. No Problem.');
          end if;
          if (tbl_gnt_flg(q) <> 'N') then /* don't overwrite 'Y' with 'N'*/
            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                c_log_head || l_api_name || '.upd_gnt_flag',
                'About to update grant_flag.');
            end if;
            /* If the grant flag isn't right, update it. */
            update fnd_compiled_menu_functions
              set  grant_flag = tbl_gnt_flg(q)
            where  menu_id = p_menu_id
              and  function_id = tbl_func_id(q)
              and  grant_flag = 'N';
          end if;
      end;
    end if;

    /* Compile the sub menu, recursively, and then copy the compiled */
    /* rows from the submenu into this menu.  */
    if (tbl_submnu_id(q) is not NULL) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.call_recursive',
              'Calling recursively for tbl_submnu_id(q): '||
              tbl_submnu_id(q));
      end if;

      -- ### What if the submenu has never been compiled?
      l_sub_rows_processed :=
        COMPILE_MENU_MARKED_I(tbl_submnu_id(q), p_force);

      /* for all the entries in this just-compiled menu */
      l_submnu_id := tbl_submnu_id(q);

      if (BULK_COLLECTS_SUPPORTED) then
        open get_compiled_menu_fns_c;
        fetch get_compiled_menu_fns_c bulk collect
             into tbl_copy_func_id, tbl_copy_gnt_flg;
        close get_compiled_menu_fns_c;

        -- See if we found any rows. If not set last_index to zero.
        begin
          if(   (tbl_copy_func_id.FIRST is NULL)
             or (tbl_copy_func_id.FIRST <> 1)) then
            last_index := 0;
          else
            if (tbl_copy_func_id.FIRST is not NULL) then
              last_index := tbl_copy_func_id.LAST;
            else
              last_index := 0;
            end if;
          end if;
        exception
          when others then
            last_index := 0;
        end;
      else
        j:= 0;
        for rec in get_compiled_menu_fns_c loop
          j := j + 1;
          tbl_copy_func_id(j) := rec.FUNCTION_ID;
          tbl_copy_gnt_flg(j) := rec.GRANT_FLAG;
        end loop;
        last_index := j;
     end if;

      -- ### Use the correct count for sub-menus
      l_rows_processed := l_rows_processed + last_index;

      /* put those entries into the compilation for the menu worked on. */
      for z in 1..last_index loop
        begin

          if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.insert2',
              'Inserting into compiled table p_menu_id: '|| to_char(p_menu_id)
               ||' tbl_copy_func_id(z):'||tbl_copy_func_id(z)
               ||' tbl_copy_gnt_flg(ze):'||tbl_copy_gnt_flg(z) );
          end if;
          insert into fnd_compiled_menu_functions
            (menu_id, function_id, grant_flag)
              values
            (p_menu_id, tbl_copy_func_id(z), tbl_copy_gnt_flg(z));
        exception
          when dup_val_on_index then
            if (l_rows_processed > 1) then
              l_rows_processed := l_rows_processed - 1;
            end if;
            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                c_log_head || l_api_name || '.dup_val_index2',
                'Insert failed with dup val on index. No Problem.');
            end if;
            if (tbl_copy_gnt_flg(z) <> 'N') then/*don't overwrite 'Y' w/ 'N'*/
              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  c_log_head || l_api_name || '.upd_gnt_flag2',
                  'About to update grant_flag.');
              end if;
              /* If the grant flag isn't right, update it. */
              update fnd_compiled_menu_functions
                set  grant_flag = tbl_copy_gnt_flg(z)
              where  menu_id = p_menu_id
                and  function_id = tbl_copy_func_id(z)
                and  grant_flag = 'N';
            end if;
        end;
      end loop;
    end if;
  end loop;

  /* If there were no functions in this menu, then insert a "blank" mark */
  /* to indicate that we've compiled this menu but there are no fns. */
  if (l_rows_processed = 0) then
    begin
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            c_log_head || l_api_name || '.insert_blank',
            'Inserting blank row into compiled table p_menu_id: '||
            to_char(p_menu_id) );
      end if;
      insert into fnd_compiled_menu_functions
        (menu_id, function_id, grant_flag)
           values
        (p_menu_id, C_BLANK_MENU_VAL, C_BLANK_GRANT_VAL);
    exception
      when dup_val_on_index then
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            c_log_head || l_api_name || '.dup_val_index3',
            'Insert failed with dup val on index. No Problem.');
        end if;
        null;  /* Only put one copy of this row */
    end;
  end if;

  /* now that this menu has been compiled, remove the "uncompiled mark" */
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            c_log_head || l_api_name || '.del_mark',
            'Removing uncompiled mark from p_menu_id:'||p_menu_id);
  end if;
  begin
    delete from fnd_compiled_menu_functions
       where menu_id = p_menu_id
         and grant_flag = C_INVALID_GRANT_VAL;
  exception when no_data_found then
     null;  /* We should never get here, but dont bomb if we do */
  end;

  -- We commit the menu compilation in order to keep the rollback segment
  -- from getting too big as we compile lots of menus.
  commit;

  -- Pop the recursion detection stack
  if(TBL_RECURS_DETEC_MENU_ID_MAX <= 1) then
    TBL_RECURS_DETEC_MENU_ID_MAX := 0;
  else
    TBL_RECURS_DETEC_MENU_ID_MAX := TBL_RECURS_DETEC_MENU_ID_MAX - 1;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            c_log_head || l_api_name || '.end',
            'returning l_rows_processed:' || l_rows_processed );
  end if;
  return l_rows_processed;
end compile_menu_marked_I;



--
-- COMPILE_MENU_MARKED
--   if (not force mode) and (this menu is not marked)
--      return; we're done
--   Delete all rows from fnd_compiled_menu_functions for this menu_id
--   for each menu_entry on this menu
--      if this is a function
--         add it to the compiled table
--      if this is a menu
--         Call FND_FUNCTION.COMPILE_MENU_MARKED() to compile this submenu
--         Copy all the submenu elements from the compiled table
--   delete the marker row for this menu_id
--
--   RETURNS - a count of how many rows needed to be processed.
--
function COMPILE_MENU_MARKED(p_menu_id NUMBER,
                   p_force in varchar2) return NUMBER is
pragma autonomous_transaction;
  RESULT_COUNT number;
  RSTATUS number;
begin
  if (DBMS_LOCK.REQUEST(C_MENU_LOCK_ID, DBMS_LOCK.X_MODE) = 0) then
    begin
      RESULT_COUNT := COMPILE_MENU_MARKED_I(p_menu_id, p_force);
    exception when OTHERS then
      null;
    end;
    RSTATUS := DBMS_LOCK.RELEASE(C_MENU_LOCK_ID);
  end if;
  return RESULT_COUNT;
end;



-- MARK_ALL_I-
--
--    truncate compiled table.
--    for each menu_id in fnd_menus
--       Mark that menu_id in the compiled table
--
--
procedure MARK_ALL_I is
  l_api_name  CONSTANT VARCHAR2(30) := 'MARK_ALL';
  l_menu_id number;

  cursor get_all_menus_c is
    select menu_id from fnd_menus;

  last_index pls_integer;

  TYPE NUMBER_TABLE_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  TBL_MENU_ID NUMBER_TABLE_TYPE;
  more_to_delete boolean;

  z number;
begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name );
    end if;

    more_to_delete := TRUE;
    while (more_to_delete) loop
       begin
         more_to_delete := FALSE;
         -- Delete menus one menu at a time.
         delete from fnd_compiled_menu_functions
               where menu_id = (select menu_id
                                  from fnd_compiled_menu_functions
                                 where rownum = 1);
         -- Commit to keep the rollback small
         commit;
         if (sql%rowcount > 0) then
           more_to_delete := TRUE;
         end if;
       exception
         when no_data_found then
           more_to_delete := FALSE;
       end;
    end loop;

    /* Mark all menus as uncompiled */

    -- We commit the menu mark in order to keep the rollback segment
    -- from getting too big as we compile lots of menus.
    commit;
    if (BULK_COLLECTS_SUPPORTED) then
      open get_all_menus_c;
      fetch get_all_menus_c bulk collect into tbl_menu_id;
      close get_all_menus_c;
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
      for rec in get_all_menus_c loop
        z := z + 1;
        tbl_menu_id(z) := rec.MENU_ID;
      end loop;
      last_index := z;
    end if;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.got_mnulist',
              'Got list of menus.  Number of elements- last_index:'||
              last_index);
    end if;

    /* mark that menu as uncompiled */
    for q in 1..last_index loop
      begin
        insert into fnd_compiled_menu_functions
          (menu_id, function_id, grant_flag)
            values
          (tbl_menu_id(q), C_INVALID_MENU_VAL, C_INVALID_GRANT_VAL);
        -- We commit the menu mark in order to keep the rollback segment
        -- from getting too big as we compile lots of menus.
        commit;
      exception
        when dup_val_on_index then
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              c_log_head || l_api_name || '.dup_val_index',
              'Mark failed because of dup val on index. Shouldnt happen.');
          end if;
          null;  /* Should never happen but better safe than sorry */
      end;
    end loop;

    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'end');
    end if;
end mark_all_I;

-- MARK_ALL-
--
--    truncate compiled table.
--    for each menu_id in fnd_menus
--       Mark that menu_id in the compiled table
--
--
procedure MARK_ALL is
pragma autonomous_transaction;
  RSTATUS number;
begin
  if (DBMS_LOCK.REQUEST(C_MENU_LOCK_ID, DBMS_LOCK.S_MODE) = 0) then
    begin
      MARK_ALL_I;
    exception when OTHERS then
      null;
    end;
    RSTATUS := DBMS_LOCK.RELEASE(C_MENU_LOCK_ID);
  end if;
end;


---Function get_function_id
------------------------------
Function get_function_id(p_function_name in varchar2
                       ) return number is
v_function_id number;
l_api_name             CONSTANT VARCHAR2(30) := 'GET_FUNCTION_ID';
Begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_function_name =>'|| p_function_name ||');');
   end if;

   if (p_function_name = g_func_name_cache) then
      v_function_id := g_func_id_cache; /* If we have it cached, use value */
   else    /* not cached, hit db */
      select function_id
      into v_function_id
      from fnd_form_functions
      where function_name=p_function_name;

      /* Store in cache */
      g_func_id_cache := v_function_id;
      g_func_name_cache := p_function_name;
   end if;


   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
         c_log_head || l_api_name || '.end',
          'returning v_function_id:' || v_function_id);
   end if;
   return v_function_id;
exception
   when no_data_found then
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_null',
          'returning null');
     end if;
     return null;
end;

-- COMPILE_MENU
--
-- Called as a Concurrent Program to compile menu when entries are added
--
--
procedure COMPILE_MENU(errbuf out NOCOPY varchar2, retcode out NOCOPY number, p_menu_id in number, p_force in varchar2) is

  numrows number;
begin
 numrows := COMPILE_MENU_MARKED(p_menu_id, p_force);
 errbuf := ' Compile successful. ';
 retcode :=0;

exception
    when others then
        retcode := 2;
        errbuf := 'ERROR: '|| sqlerrm;
end;

end FND_FUNCTION;

/
