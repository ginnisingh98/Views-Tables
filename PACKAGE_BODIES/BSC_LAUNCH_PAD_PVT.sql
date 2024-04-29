--------------------------------------------------------
--  DDL for Package Body BSC_LAUNCH_PAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_LAUNCH_PAD_PVT" AS
/* $Header: BSCLPADB.pls 120.1 2005/10/24 23:59:51 kyadamak noship $ */


/* --------------------------APPS MENUS -------------------------*/

/*===========================================================================+
|
|   Name:          INSERT_APP_MENU_VB
|
|   Description:   it is a wrapper for FND_MENUS_PKG.INSERT_ROW function
|          This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:  x_menu_id - Menu id
|        x_menu_name  - Menu Name
|        x_user_menu_name - User Menu Name
|        x_menu_type      - Menu Type
|        x_description    - Description
|        x_user id    -User Id
|
|   Notes:
|
+============================================================================*/
PROCEDURE INSERT_APP_MENU_VB(X_MENU_ID in NUMBER,
      X_MENU_NAME in VARCHAR2,
      X_USER_MENU_NAME in VARCHAR2,
      X_MENU_TYPE    in VARCHAR2,
      X_DESCRIPTION in VARCHAR2,
      X_USER_ID in NUMBER
    ) IS
          row_id  VARCHAR2(30);
BEGIN
    DELETE FND_MENUS WHERE MENU_ID = X_MENU_ID;
    DELETE FND_MENUS_TL WHERE MENU_ID = X_MENU_ID;
    FND_MENUS_PKG.INSERT_ROW( X_ROWID => row_id,
           X_MENU_ID        => X_MENU_ID,
           X_MENU_NAME              => X_MENU_NAME,
           X_USER_MENU_NAME     => X_USER_MENU_NAME,
           X_MENU_TYPE      => X_MENU_TYPE,
           X_DESCRIPTION            => X_DESCRIPTION,
           X_CREATION_DATE          => sysdate,
           X_CREATED_BY             => x_user_id,
           X_LAST_UPDATE_DATE       => sysdate,
           X_LAST_UPDATED_BY        => x_user_id,
           X_LAST_UPDATE_LOGIN      => 0 );

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_LAUNCH_PAD_PVT.INSERT_APP_MENU_VB',
                        x_mode => 'I');

END INSERT_APP_MENU_VB;
/*===========================================================================+
|
|   Name:          UPDATE_APP_MENU_VB
|
|   Description:   it is a wrapper for FND_MENUS_PKG.UPDATE_ROW function
|          This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:  x_menu_id - Menu id
|        x_menu_name  - Menu Name
|        x_user_menu_name - User Menu Name
|        x_menu_type      - Menu Type
|        x_description    - Description
|        x_user id    -User Id
|
|   Notes:
|
+============================================================================*/
PROCEDURE UPDATE_APP_MENU_VB(X_MENU_ID in NUMBER,
      X_MENU_NAME in VARCHAR2,
      X_USER_MENU_NAME in VARCHAR2,
      X_MENU_TYPE    in VARCHAR2,
      X_DESCRIPTION in VARCHAR2,
      X_USER_ID in NUMBER
    ) IS
          row_id  VARCHAR2(30);
BEGIN
    FND_MENUS_PKG.UPDATE_ROW(X_MENU_ID          => X_MENU_ID,
           X_MENU_NAME              => X_MENU_NAME,
           X_USER_MENU_NAME     => X_USER_MENU_NAME,
           X_MENU_TYPE      => X_MENU_TYPE,
           X_DESCRIPTION            => X_DESCRIPTION,
           X_LAST_UPDATE_DATE       => sysdate,
           X_LAST_UPDATED_BY        => x_user_id,
           X_LAST_UPDATE_LOGIN      => 0 );

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_LAUNCH_PAD_PVT.UPDATE_APP_MENU_VB',
                        x_mode => 'I');
END UPDATE_APP_MENU_VB;
/*===========================================================================+
|
|   Name:          DELETE_APP_MENU_VB
|
|   Description:   it is a wrapper for FND_MENUS_PKG.DELETE_ROW function
|          This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:  x_menu_id - Menu id
|
|   Notes:
|
+============================================================================*/
PROCEDURE DELETE_APP_MENU_VB(X_MENU_ID in NUMBER
    ) IS
          row_id  VARCHAR2(30);
BEGIN
    FND_MENUS_PKG.DELETE_ROW(X_MENU_ID          => X_MENU_ID);

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_LAUNCH_PAD_PVT.DELETE_APP_MENU_VB',
                        x_mode => 'I');
END DELETE_APP_MENU_VB;
/*===========================================================================+
|
|   Name:          CHECK_MENU_NAMES
|
|   Description:   Check if the menu name and User name are unique to
|          insert as a new menu.
|   Return :       'N' : Name Invalid, The name alreday exist
|                  'U' : User Name Invalid, The user name alreday exist
|                  'T' : True , The names don't exist. It can be added
|   Parameters:    X_MENU_ID        Menu Id that will be inserted
|          X_MENU_NAME      Menu Name
|              X_USER_MENU_NAME     User Menu Name
+============================================================================*/
FUNCTION CHECK_MENU_NAMES(X_MENU_ID in NUMBER,
      X_MENU_NAME in VARCHAR2,
      X_USER_MENU_NAME in VARCHAR2
) RETURN VARCHAR2 IS

    h_count NUMBER;
    h_val VARCHAR2(1);

BEGIN
    -- Name
    SELECT count(*)
    INTO h_count
    FROM FND_MENUS_VL
    WHERE MENU_ID <> X_MENU_ID
    AND (MENU_NAME = X_MENU_NAME);
    IF h_count > 0 THEN
    h_val := 'N';
        RETURN h_val;
    END IF;
    -- User Name
    SELECT count(*)
    INTO h_count
    FROM FND_MENUS_VL
    WHERE MENU_ID <> X_MENU_ID
    AND (upper(USER_MENU_NAME) = X_USER_MENU_NAME);
    IF h_count > 0 THEN
    h_val := 'U';
        RETURN h_val;
    END IF;
    h_val := 'T';
    RETURN h_val;
END CHECK_MENU_NAMES;

/* --------------------------FORM FUNCTIONS -------------------------*/
/*===========================================================================+
|
|   Name:          INSERT_FORM_FUNCTION_VB
|
|   Description:   it is a wrapper for FND_FORM_FUNCTIONS_PKG.INSERT_ROW function
|          This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE INSERT_FORM_FUNCTION_VB(X_FUNCTION_ID in NUMBER,
      X_WEB_HOST_NAME in VARCHAR2,
      X_WEB_AGENT_NAME in VARCHAR2,
      X_WEB_HTML_CALL in VARCHAR2,
      X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
      X_WEB_SECURED in  VARCHAR2,
      X_WEB_ICON  in VARCHAR2,
      X_OBJECT_ID  in NUMBER,
      X_REGION_APPLICATION_ID in NUMBER,
      X_REGION_CODE  in VARCHAR2,
      X_FUNCTION_NAME in VARCHAR2,
      X_APPLICATION_ID in NUMBER,
      X_FORM_ID  in NUMBER,
      X_PARAMETERS in VARCHAR2,
      X_TYPE    in VARCHAR2,
      X_USER_FUNCTION_NAME in VARCHAR2,
      X_DESCRIPTION in VARCHAR2,
      X_USER_ID in NUMBER
    ) IS
          row_id  VARCHAR2(30);

BEGIN
    DELETE FND_FORM_FUNCTIONS WHERE FUNCTION_ID = X_FUNCTION_ID;
    DELETE FND_FORM_FUNCTIONS_TL WHERE FUNCTION_ID = X_FUNCTION_ID;
    fnd_form_functions_pkg.INSERT_ROW( X_ROWID => row_id,
           X_FUNCTION_ID        => X_FUNCTION_ID,
           X_WEB_HOST_NAME          => X_WEB_HOST_NAME,
           X_WEB_AGENT_NAME         => X_WEB_AGENT_NAME,
           X_WEB_HTML_CALL          => X_WEB_HTML_CALL,
           X_WEB_ENCRYPT_PARAMETERS => X_WEB_ENCRYPT_PARAMETERS,
           X_WEB_SECURED            => X_WEB_SECURED,
           X_WEB_ICON               => X_WEB_ICON,
           X_OBJECT_ID              => X_OBJECT_ID,
           X_REGION_APPLICATION_ID  => X_REGION_APPLICATION_ID,
           X_REGION_CODE            => X_REGION_CODE,
           X_FUNCTION_NAME          => X_FUNCTION_NAME,
           X_APPLICATION_ID         => X_APPLICATION_ID,
           X_FORM_ID                => X_FORM_ID,
           X_PARAMETERS             => X_PARAMETERS,
           X_TYPE                   => X_TYPE,
           X_USER_FUNCTION_NAME     => X_USER_FUNCTION_NAME,
           X_DESCRIPTION            => X_DESCRIPTION,
           X_CREATION_DATE          => sysdate,
           X_CREATED_BY             => x_user_id,
           X_LAST_UPDATE_DATE       => sysdate,
           X_LAST_UPDATED_BY        => x_user_id,
           X_LAST_UPDATE_LOGIN      => 0 );

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_LAUNCH_PAD_PVT.INSERT_FORM_FUNCTION_VB',
                        x_mode => 'I');

END INSERT_FORM_FUNCTION_VB;
/*===========================================================================+
|
|   Name:          UPDATE_FORM_FUNCTION_VB
|
|   Description:   it is a wrapper for FND_FORM_FUNCTIONS_PKG.UPDATE_ROW function
|          This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE UPDATE_FORM_FUNCTION_VB(X_FUNCTION_ID in NUMBER,
      X_WEB_HOST_NAME in VARCHAR2,
      X_WEB_AGENT_NAME in VARCHAR2,
      X_WEB_HTML_CALL in VARCHAR2,
      X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
      X_WEB_SECURED in  VARCHAR2,
      X_WEB_ICON  in VARCHAR2,
      X_OBJECT_ID  in NUMBER,
      X_REGION_APPLICATION_ID in NUMBER,
      X_REGION_CODE  in VARCHAR2,
      X_FUNCTION_NAME in VARCHAR2,
      X_APPLICATION_ID in NUMBER,
      X_FORM_ID  in NUMBER,
      X_PARAMETERS in VARCHAR2,
      X_TYPE    in VARCHAR2,
      X_USER_FUNCTION_NAME in VARCHAR2,
      X_DESCRIPTION in VARCHAR2,
      X_USER_ID in NUMBER
    ) IS
          row_id  VARCHAR2(30);
BEGIN
    fnd_form_functions_pkg.UPDATE_ROW(X_FUNCTION_ID => X_FUNCTION_ID,
           X_WEB_HOST_NAME          => X_WEB_HOST_NAME,
           X_WEB_AGENT_NAME         => X_WEB_AGENT_NAME,
           X_WEB_HTML_CALL          => X_WEB_HTML_CALL,
           X_WEB_ENCRYPT_PARAMETERS => X_WEB_ENCRYPT_PARAMETERS,
           X_WEB_SECURED            => X_WEB_SECURED,
           X_WEB_ICON               => X_WEB_ICON,
           X_OBJECT_ID              => X_OBJECT_ID,
           X_REGION_APPLICATION_ID  => X_REGION_APPLICATION_ID,
           X_REGION_CODE            => X_REGION_CODE,
           X_FUNCTION_NAME          => X_FUNCTION_NAME,
           X_APPLICATION_ID         => X_APPLICATION_ID,
           X_FORM_ID                => X_FORM_ID,
           X_PARAMETERS             => X_PARAMETERS,
           X_TYPE                   => X_TYPE,
           X_USER_FUNCTION_NAME     => X_USER_FUNCTION_NAME,
           X_DESCRIPTION            => X_DESCRIPTION,
           X_LAST_UPDATE_DATE       => sysdate,
           X_LAST_UPDATED_BY        => x_user_id,
           X_LAST_UPDATE_LOGIN      => 0 );

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_LAUNCH_PAD_PVT.UPDATE_FORM_FUNCTION_VB',
                        x_mode => 'I');

END UPDATE_FORM_FUNCTION_VB;
/*===========================================================================+
|
|   Name:          DELETE_FORM_FUNCTION_VB
|
|   Description:   it is a wrapper for FND_FORM_FUNCTIONS_PKG.DELETE_ROW function
|          This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE DELETE_FORM_FUNCTION_VB(X_FUNCTION_ID in NUMBER
    ) IS
          row_id  VARCHAR2(30);
BEGIN
    fnd_form_functions_pkg.DELETE_ROW(X_FUNCTION_ID         => X_FUNCTION_ID);

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_LAUNCH_PAD_PVT.DELETE_FORM_FUNCTION_VB',
                        x_mode => 'I');
END DELETE_FORM_FUNCTION_VB;
/*===========================================================================+
| FUNCTION CHECK_FUNCTION_NAMES
|
|   Name:          CHECK_FUNCTION_NAMES
|
|   Description:   Check if the fucntion name and User name are unique to
|          insert as a new function.
|   Return :       'N' : Name Invalid, The name alreday exist
|                  'U' : User Name Invalid, The user name alreday exist
|                  'T' : True , The names don't exist. It can be added
|   Parameters:    X_FUNCTION_ID        Menu Id that will be inserted
|          X_FUNCTION_NAME      Menu Name
|              X_USER_FUNCTION_NAME User Menu Name
+============================================================================*/

FUNCTION CHECK_FUNCTION_NAMES(X_FUNCTION_ID in NUMBER,
      X_FUNCTION_NAME in VARCHAR2,
      X_USER_FUNCTION_NAME in VARCHAR2
    ) RETURN VARCHAR2  IS

    h_count NUMBER;
    h_val VARCHAR2(1);

BEGIN
    -- Name
    SELECT count(*)
    INTO h_count
    FROM  FND_FORM_FUNCTIONS_VL
    WHERE FUNCTION_ID <> X_FUNCTION_ID
    AND (FUNCTION_NAME = X_FUNCTION_NAME);
    IF h_count > 0 THEN
    h_val := 'N';
        RETURN h_val;
    END IF;
    -- User Name
    SELECT count(*)
    INTO h_count
    FROM FND_FORM_FUNCTIONS_VL
    WHERE FUNCTION_ID <> X_FUNCTION_ID
    AND (USER_FUNCTION_NAME = X_USER_FUNCTION_NAME);
    IF h_count > 0 THEN
    h_val := 'U';
        RETURN h_val;
    END IF;
    h_val := 'T';
    RETURN h_val;
END CHECK_FUNCTION_NAMES;

/* --------------------------APPS MENU-ENTRIES -------------------------*/
/*===========================================================================+
|
|   Name:          INSERT_APP_MENU_ENTRIES_VB
|
|   Description:   it is a wrapper for FND_MENU_ENTRIES_PKG.INSERT_ROW  function
|          This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE INSERT_APP_MENU_ENTRIES_VB(X_MENU_ID in NUMBER,
      X_ENTRY_SEQUENCE in NUMBER,
      X_SUB_MENU_ID  in NUMBER,
      X_FUNCTION_ID in NUMBER,
      X_GRANT_FLAG  in VARCHAR2,
      X_PROMPT      in VARCHAR2,
      X_DESCRIPTION in VARCHAR2,
      X_USER_ID in NUMBER
    ) IS
          row_id  VARCHAR2(30);
BEGIN
    DELETE FND_MENU_ENTRIES WHERE MENU_ID = X_MENU_ID AND ENTRY_SEQUENCE = X_ENTRY_SEQUENCE;
    DELETE FND_MENU_ENTRIES_TL WHERE MENU_ID = X_MENU_ID AND ENTRY_SEQUENCE = X_ENTRY_SEQUENCE;

    FND_MENU_ENTRIES_PKG.INSERT_ROW ( X_ROWID => row_id,
        X_MENU_ID       => X_MENU_ID,
        X_ENTRY_SEQUENCE    => X_ENTRY_SEQUENCE,
        X_SUB_MENU_ID       => X_SUB_MENU_ID,
        X_FUNCTION_ID       => X_FUNCTION_ID,
        X_GRANT_FLAG        => X_GRANT_FLAG,
        X_PROMPT        => X_PROMPT,
            X_DESCRIPTION            => X_DESCRIPTION,
            X_CREATION_DATE          => sysdate,
            X_CREATED_BY             => x_user_id,
            X_LAST_UPDATE_DATE       => sysdate,
            X_LAST_UPDATED_BY        => x_user_id,
            X_LAST_UPDATE_LOGIN      => 0 );

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_LAUNCH_PAD_PVT.INSERT_APP_MENU_ENTRIES_VB',
                        x_mode => 'I');

END INSERT_APP_MENU_ENTRIES_VB;
/*===========================================================================+
|
|   Name:          UPDATE_APP_MENU_ENTRIES_VB
|
|   Description:   it is a wrapper for FND_MENU_ENTRIES_PKG.UPDATE_ROW  function
|          This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE UPDATE_APP_MENU_ENTRIES_VB(X_MENU_ID in NUMBER,
      X_ENTRY_SEQUENCE in NUMBER,
      X_SUB_MENU_ID  in NUMBER,
      X_FUNCTION_ID in NUMBER,
      X_GRANT_FLAG  in VARCHAR2,
      X_PROMPT      in VARCHAR2,
      X_DESCRIPTION in VARCHAR2,
      X_USER_ID in NUMBER
    ) IS
BEGIN
    FND_MENU_ENTRIES_PKG.UPDATE_ROW(X_MENU_ID       => X_MENU_ID,
        X_ENTRY_SEQUENCE    => X_ENTRY_SEQUENCE,
        X_SUB_MENU_ID       => X_SUB_MENU_ID,
        X_FUNCTION_ID       => X_FUNCTION_ID,
        X_GRANT_FLAG        => X_GRANT_FLAG,
        X_PROMPT        => X_PROMPT,
            X_DESCRIPTION            => X_DESCRIPTION,
            X_LAST_UPDATE_DATE       => sysdate,
            X_LAST_UPDATED_BY        => x_user_id,
            X_LAST_UPDATE_LOGIN      => 0 );

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_LAUNCH_PAD_PVT.UPDATE_APP_MENU_ENTRIES_VB',
                        x_mode => 'I');

END UPDATE_APP_MENU_ENTRIES_VB;
/*===========================================================================+
|
|   Name:          DELETE_APP_MENU_ENTRIES_VB
|
|   Description:   it is a wrapper for FND_MENU_ENTRIES_PKG.DELETE_ROW  function
|          This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE DELETE_APP_MENU_ENTRIES_VB(X_MENU_ID in NUMBER,
      X_ENTRY_SEQUENCE in NUMBER
    ) IS
BEGIN
    FND_MENU_ENTRIES_PKG.DELETE_ROW(X_MENU_ID       => X_MENU_ID,
        X_ENTRY_SEQUENCE    => X_ENTRY_SEQUENCE);

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_LAUNCH_PAD_PVT.DELETE_APP_MENU_ENTRIES_VB',
                        x_mode => 'I');
END DELETE_APP_MENU_ENTRIES_VB;


/*===========================================================================+
|
|   Name:          SECURITY_RULE_EXISTS_VB
|
|   Description:   it is a wrapper for FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS function
|          This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
FUNCTION SECURITY_RULE_EXISTS_VB(responsibility_key in varchar2,
      rule_type in varchar2 default 'F',  -- F = Function, M = Menu
      rule_name in varchar2
) RETURN VARCHAR2 IS

    h_val VARCHAR2(1);
BEGIN
    -- Name
    h_val := 'F';
    IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS(responsibility_key,rule_type,rule_name) = TRUE  THEN
    h_val := 'T';
    END IF;
    RETURN h_val;
END SECURITY_RULE_EXISTS_VB;
/*===========================================================================+
| FUNCTION SECURITY_ACCESS_MENU
|
|   Name:          SECURITY_ACCESS_MENU
|
|   Description:   It verifies if a Responsibility has acces to a menu or not
|   Return :       'T' : It has access
|                  'F' : It doesn't have access
|   Parameters:    X_RESPO      Responsibility
|          X_MENU_ID        Menu Id
+============================================================================*/

FUNCTION  SECURITY_ACCESS_MENU(X_RESPO in NUMBER,
      X_MENU_ID  in NUMBER
    ) RETURN VARCHAR2 IS

    h_val VARCHAR2(1);
    h_top_menu NUMBER;
    h_count NUMBER;
cursor c_RESPO is
    SELECT MENU_ID
    FROM FND_RESPONSIBILITY_VL
    WHERE RESPONSIBILITY_ID=X_RESPO;

BEGIN
    -- Name
    h_val := 'F';
    h_count := 0;
    -- Get The top Level Menu for the Responsbility
    OPEN c_RESPO;
    FETCH c_RESPO INTO h_top_menu;
    IF (c_RESPO%notfound) THEN
       h_top_menu := -1;
    END IF;
    CLOSE c_RESPO;
    IF  h_top_menu IS NOT NULL THEN
        -- Check if the menu is in the Menu entries - It looks 3 levels down
        SELECT COUNT(*) VAL
        INTO h_count
        FROM (
        select SUB_MENU_ID from FND_MENU_ENTRIES_VL
            WHERE  MENU_ID = h_top_menu
        UNION
        select SUB_MENU_ID from FND_MENU_ENTRIES_VL
            WHERE  MENU_ID IN (select SUB_MENU_ID from FND_MENU_ENTRIES_VL
            WHERE  MENU_ID = h_top_menu)
        UNION
        select SUB_MENU_ID from FND_MENU_ENTRIES_VL
            WHERE  MENU_ID IN (select SUB_MENU_ID from FND_MENU_ENTRIES_VL
            WHERE  MENU_ID IN (select SUB_MENU_ID from FND_MENU_ENTRIES_VL
            WHERE  MENU_ID = h_top_menu))
        ) MNS
         WHERE MNS.SUB_MENU_ID=X_MENU_ID;
    END IF;

    IF h_count > 0 THEN
    h_val := 'T';
    END IF;
    RETURN h_val;
END SECURITY_ACCESS_MENU;


/*===========================================================================+
| FUNCTION Migrate_Custom_Links
|
|   Description:   Migrate custom links from the source system.
|                  It creates the menu in the target system in case it does
|                  not exist and it is a BSC menu.
|                  It creates unexisting BSC functions inside the menus.
|                  It never update or delete an existing menu or function.
|
|                  Fixed Bug#2195153: Check user_menu_name/user_function_name
|                                     to see if the menu/function already
|                                     exist in the target system. This is after
|                                     checking menu_name/function_name.
|
|   Return :       TRUE : no errors
|                  FALSE : error
|
|   Parameters:    x_src_db_link    source db link.
+============================================================================*/
FUNCTION Migrate_Custom_Links(
    x_src_db_link IN VARCHAR2
    ) RETURN BOOLEAN IS

    h_sql       VARCHAR2(32000);
    h_ret       INTEGER;
    h_cursor        INTEGER;
    h_ret1      INTEGER;
    h_cursor1       INTEGER;
    h_ret2      INTEGER;
    h_cursor2       INTEGER;
    h_i         NUMBER;

    h_menu_name     VARCHAR2(30);
    h_user_menu_name    VARCHAR2(80);
    h_menu_id_src   NUMBER;

    CURSOR c_menu_id IS
    SELECT menu_id
        FROM fnd_menus
        WHERE menu_name = h_menu_name;

    CURSOR c_menu_id_u IS
    SELECT menu_id
        FROM fnd_menus_vl
        WHERE user_menu_name = h_user_menu_name;

    h_menu_id       NUMBER;
    h_row_id        VARCHAR2(30);
    h_user_id       NUMBER;
    h_menu_type     VARCHAR2(30);
    h_description   VARCHAR2(240);

    h_function_name     FND_FORM_FUNCTIONS.function_name%TYPE;
    h_user_function_name    VARCHAR2(80);
    h_function_id_src       NUMBER;

    CURSOR c_function_id IS
    SELECT function_id
        FROM fnd_form_functions
        WHERE function_name = h_function_name;

    CURSOR c_function_id_u IS
    SELECT function_id
        FROM fnd_form_functions_vl
        WHERE user_function_name = h_user_function_name;

    h_function_id       NUMBER;
    h_web_host_name     VARCHAR2(80);
    h_web_agent_name        VARCHAR2(80);
    h_web_html_call     VARCHAR2(240);
    h_web_encrypt_parameters    VARCHAR2(1);
    h_web_secured       VARCHAR2(1);
    h_web_icon          VARCHAR2(30);
    h_object_id         NUMBER;
    h_region_application_id NUMBER;
    h_region_code       VARCHAR2(30);
    h_application_id        NUMBER;
    h_form_id           NUMBER;
    h_parameters        VARCHAR2(2000);
    h_type          VARCHAR2(30);

    h_entry_sequence        NUMBER;
    h_sub_menu_id       NUMBER;
    h_grant_flag        VARCHAR2(1);
    h_prompt            VARCHAR(60);

BEGIN

    -- Get user id
    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    h_user_id := BSC_APPS.fnd_global_user_id;

    -- Migrate menus with functions
    h_sql := 'SELECT DISTINCT M.MENU_NAME, M.USER_MENU_NAME, T.LINK_ID'||
         ' FROM BSC_TAB_VIEW_LABELS_B T, FND_MENUS_VL@'||x_src_db_link||' M'||
             ' WHERE T.LABEL_TYPE = 2 AND NVL(T.LINK_ID, -1) <> -1 AND T.LINK_ID = M.MENU_ID';

    h_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(h_cursor, h_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(h_cursor, 1, h_menu_name, 30);
    DBMS_SQL.DEFINE_COLUMN(h_cursor, 2, h_user_menu_name, 80);
    DBMS_SQL.DEFINE_COLUMN(h_cursor, 3, h_menu_id_src);

    h_ret := DBMS_SQL.EXECUTE(h_cursor);

    WHILE DBMS_SQL.FETCH_ROWS(h_cursor) > 0 LOOP
        DBMS_SQL.COLUMN_VALUE(h_cursor, 1, h_menu_name);
        DBMS_SQL.COLUMN_VALUE(h_cursor, 2, h_user_menu_name);
        DBMS_SQL.COLUMN_VALUE(h_cursor, 3, h_menu_id_src);

        -- Get the menu id in the target
        OPEN c_menu_id;
    FETCH c_menu_id INTO h_menu_id;
        IF c_menu_id%NOTFOUND THEN
        h_menu_id := -1;
    END IF;
        CLOSE c_menu_id;

        IF h_menu_id = -1 THEN
            -- If the menu name does not exist,
            -- we need to check for the user_menu_name
            OPEN c_menu_id_u;
        FETCH c_menu_id_u INTO h_menu_id;
            IF c_menu_id_u%NOTFOUND THEN
            h_menu_id := -1;
        END IF;
            CLOSE c_menu_id_u;
        END IF;

        IF h_menu_id = -1 THEN
        -- menu does not exist in the target

            -- Create the menu only if the menu is for BSC
            IF UPPER(SUBSTR(h_menu_name,1,3)) = 'BSC' THEN
                -- Get the menu_id
                SELECT fnd_menus_s.nextval INTO h_menu_id FROM DUAL;

                -- Get all info about the menu in the source to create it in the target
                h_menu_type := NULL;
                h_description := NULL;

        h_sql := 'SELECT type, description'||
                         ' FROM fnd_menus_vl@'||x_src_db_link||
                         ' WHERE menu_name =:1';
                         /*  ' WHERE menu_name = '''||h_menu_name||'''';*/


                h_cursor1 := DBMS_SQL.OPEN_CURSOR;
                DBMS_SQL.PARSE(h_cursor1, h_sql, DBMS_SQL.NATIVE);
            DBMS_SQL.DEFINE_COLUMN(h_cursor1, 1, h_menu_type, 30);
            DBMS_SQL.DEFINE_COLUMN(h_cursor1, 2, h_description, 240);
            DBMS_SQL.BIND_VARIABLE(h_cursor1,':1',h_menu_name);
            --DBMS_OUTPUT.PUT_LINE('DYNAMIC SQL --------------> '|| h_cursor1);
            h_ret1 := DBMS_SQL.EXECUTE(h_cursor1);

                -- We know that the menu exists in the source
        IF DBMS_SQL.FETCH_ROWS(h_cursor1) > 0 THEN
                DBMS_SQL.COLUMN_VALUE(h_cursor1, 1, h_menu_type);
                DBMS_SQL.COLUMN_VALUE(h_cursor1, 2, h_description);
                END IF;
                DBMS_SQL.CLOSE_CURSOR(h_cursor1);

                -- call the api to create the menu
                FND_MENUS_PKG.INSERT_ROW(
            X_ROWID         => h_row_id,
                X_MENU_ID       => h_menu_id,
                X_MENU_NAME             => h_menu_name,
                X_USER_MENU_NAME    => h_user_menu_name,
                X_MENU_TYPE     => h_menu_type,
                X_DESCRIPTION           => h_description,
                X_CREATION_DATE         => sysdate,
                X_CREATED_BY            => h_user_id,
                X_LAST_UPDATE_DATE      => sysdate,
                X_LAST_UPDATED_BY       => h_user_id,
                X_LAST_UPDATE_LOGIN     => 0
            );
        END IF;

        END IF;

        -- Migrate functions only if the menu is for BSC
        IF h_menu_id <> -1 THEN
            IF UPPER(SUBSTR(h_menu_name,1,3)) = 'BSC' THEN
        -- Get the menu entries (functions) associated to this menu in the source system
                -- and are not associated with the same menu in the target system.
                -- We need to create those entries in the target menu.
                -- Only see BSC functions
                h_sql := 'SELECT SF.FUNCTION_NAME, SF.USER_FUNCTION_NAME, SF.FUNCTION_ID'||
             ' FROM FND_MENU_ENTRIES@'||x_src_db_link||' SE, FND_FORM_FUNCTIONS_VL@'||x_src_db_link||' SF'||
             ' WHERE SE.MENU_ID = :1 AND SE.FUNCTION_ID = SF.FUNCTION_ID AND'||
             ' SF.APPLICATION_ID = 271 AND SF.FUNCTION_NAME NOT IN ('||
             ' SELECT TF.FUNCTION_NAME FROM FND_MENU_ENTRIES TE, FND_FORM_FUNCTIONS TF'||
             ' WHERE TE.MENU_ID = :2 AND TE.FUNCTION_ID = TF.FUNCTION_ID AND TF.APPLICATION_ID = 271)';
             /*' WHERE TE.MENU_ID = '||h_menu_id||' AND TE.FUNCTION_ID = TF.FUNCTION_ID AND TF.APPLICATION_ID = 271)';*/

                h_cursor1 := DBMS_SQL.OPEN_CURSOR;
                DBMS_SQL.PARSE(h_cursor1, h_sql, DBMS_SQL.NATIVE);
                DBMS_SQL.DEFINE_COLUMN(h_cursor1, 1, h_function_name, 480);
                DBMS_SQL.DEFINE_COLUMN(h_cursor1, 2, h_user_function_name, 80);
                DBMS_SQL.DEFINE_COLUMN(h_cursor1, 3, h_function_id_src);
                DBMS_SQL.BIND_VARIABLE(h_cursor1, ':1', h_menu_id_src);
                DBMS_SQL.BIND_VARIABLE(h_cursor1, ':2', h_menu_id);
                h_ret1 := DBMS_SQL.EXECUTE(h_cursor1);

                WHILE DBMS_SQL.FETCH_ROWS(h_cursor1) > 0 LOOP
                    DBMS_SQL.COLUMN_VALUE(h_cursor1, 1, h_function_name);
            DBMS_SQL.COLUMN_VALUE(h_cursor1, 2, h_user_function_name);
            DBMS_SQL.COLUMN_VALUE(h_cursor1, 3, h_function_id_src);

                    -- Check if the function exists
                    OPEN c_function_id;
                FETCH c_function_id INTO h_function_id;
                    IF c_function_id%NOTFOUND THEN
                    h_function_id := -1;
                END IF;
                    CLOSE c_function_id;

                IF h_function_id = -1 THEN
                    -- If the function name does not exist,
                    -- we need to check for the user_function_name
                    OPEN c_function_id_u;
                FETCH c_function_id_u INTO h_function_id;
                    IF c_function_id_u%NOTFOUND THEN
                    h_function_id := -1;
                END IF;
                    CLOSE c_function_id_u;
                END IF;

                    -- Create the function if does not exist. We know that it is a BSC function.
                    IF h_function_id = -1 THEN
                        -- Get the function_id
                        SELECT fnd_form_functions_s.nextval INTO h_function_id FROM DUAL;

                        -- Get all info about the function in the source to create it in the target
            h_web_host_name :=  NULL;
            h_web_agent_name :=  NULL;
            h_web_html_call :=  NULL;
            h_web_encrypt_parameters :=  NULL;
            h_web_secured :=  NULL;
            h_web_icon :=  NULL;
            h_object_id :=  NULL;
            h_region_application_id :=  NULL;
            h_region_code :=  NULL;
            h_application_id :=  NULL;
            h_form_id :=  NULL;
            h_parameters :=  NULL;
            h_type :=  NULL;
            h_description :=  NULL;

                h_sql := 'SELECT web_host_name, web_agent_name, web_html_call,'||
                     ' web_encrypt_parameters, web_secured, web_icon, object_id,'||
                     ' region_application_id, region_code, application_id,'||
                     ' form_id, parameters, type, description'||
                     ' FROM fnd_form_functions_vl@'||x_src_db_link||
                     ' WHERE function_name = :1';
                     /*' WHERE function_name = '''||h_function_name||'''';*/

                        h_cursor2 := DBMS_SQL.OPEN_CURSOR;
                        DBMS_SQL.PARSE(h_cursor2, h_sql, DBMS_SQL.NATIVE);
                    DBMS_SQL.DEFINE_COLUMN(h_cursor2, 1, h_web_host_name, 80);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 2, h_web_agent_name, 80);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 3, h_web_html_call, 240);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 4, h_web_encrypt_parameters, 1);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 5, h_web_secured, 1);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 6, h_web_icon, 30);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 7, h_object_id);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 8, h_region_application_id);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 9, h_region_code, 30);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 10, h_application_id);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 11, h_form_id);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 12, h_parameters, 2000);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 13, h_type, 30);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 14, h_description, 240);
            DBMS_SQL.BIND_VARIABLE(h_cursor2, ':1', h_function_name);
                    h_ret2 := DBMS_SQL.EXECUTE(h_cursor2);

                        -- We know that the menu exists in the source
                IF DBMS_SQL.FETCH_ROWS(h_cursor2) > 0 THEN
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 1, h_web_host_name);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 2, h_web_agent_name);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 3, h_web_html_call);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 4, h_web_encrypt_parameters);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 5, h_web_secured);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 6, h_web_icon);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 7, h_object_id);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 8, h_region_application_id);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 9, h_region_code);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 10, h_application_id);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 11, h_form_id);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 12, h_parameters);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 13, h_type);
                DBMS_SQL.COLUMN_VALUE(h_cursor2, 14, h_description);
                        END IF;
                        DBMS_SQL.CLOSE_CURSOR(h_cursor2);

                        -- call the api to create the function
            FND_FORM_FUNCTIONS_PKG.INSERT_ROW(
                X_ROWID          => h_row_id,
                    X_FUNCTION_ID        => h_function_id,
                    X_WEB_HOST_NAME          => h_web_host_name,
                    X_WEB_AGENT_NAME         => h_web_agent_name,
                    X_WEB_HTML_CALL          => h_web_html_call,
                    X_WEB_ENCRYPT_PARAMETERS => h_web_encrypt_parameters,
                    X_WEB_SECURED            => h_web_secured,
                    X_WEB_ICON               => h_web_icon,
                    X_OBJECT_ID              => h_object_id,
                    X_REGION_APPLICATION_ID  => h_region_application_id,
                    X_REGION_CODE            => h_region_code,
                    X_FUNCTION_NAME          => h_function_name,
                    X_APPLICATION_ID         => h_application_id,
                    X_FORM_ID                => h_form_id,
                    X_PARAMETERS             => h_parameters,
                    X_TYPE                   => h_type,
                    X_USER_FUNCTION_NAME     => h_user_function_name,
                    X_DESCRIPTION            => h_description,
                    X_CREATION_DATE          => sysdate,
                    X_CREATED_BY             => h_user_id,
                    X_LAST_UPDATE_DATE       => sysdate,
                    X_LAST_UPDATED_BY        => h_user_id,
                    X_LAST_UPDATE_LOGIN      => 0
            );

                    END IF;


                    -- Create the menu entry in the target
                    -- Get the maximum entry sequence
            SELECT nvl(max(entry_sequence)+1, 1) INTO h_entry_sequence
            FROM fnd_menu_entries
                    WHERE menu_id = h_menu_id;

                    -- Get all info about the menu entry in the source to create it in the target
            h_sub_menu_id := NULL;
            h_grant_flag := NULL;
            h_prompt := NULL;
            h_description := NULL;

                    h_sql := 'SELECT sub_menu_id, grant_flag, prompt, description'||
                 ' FROM fnd_menu_entries_vl@'||x_src_db_link||
                 ' WHERE menu_id = :1 AND function_id = :2';
                 /*' WHERE menu_id = '||h_menu_id_src||' AND function_id = '||h_function_id_src;*/


                    h_cursor2 := DBMS_SQL.OPEN_CURSOR;
                    DBMS_SQL.PARSE(h_cursor2, h_sql, DBMS_SQL.NATIVE);
                DBMS_SQL.DEFINE_COLUMN(h_cursor2, 1, h_sub_menu_id);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 2, h_grant_flag, 1);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 3, h_prompt, 60);
            DBMS_SQL.DEFINE_COLUMN(h_cursor2, 4, h_description, 240);
            DBMS_SQL.BIND_VARIABLE(h_cursor2, ':1', h_menu_id_src);
            DBMS_SQL.BIND_VARIABLE(h_cursor2, ':2', h_function_id_src);
            h_ret2 := DBMS_SQL.EXECUTE(h_cursor2);

                    -- We know that the menu entry exists in the source
            IF DBMS_SQL.FETCH_ROWS(h_cursor2) > 0 THEN
            DBMS_SQL.COLUMN_VALUE(h_cursor2, 1, h_sub_menu_id);
            DBMS_SQL.COLUMN_VALUE(h_cursor2, 2, h_grant_flag);
            DBMS_SQL.COLUMN_VALUE(h_cursor2, 3, h_prompt);
            DBMS_SQL.COLUMN_VALUE(h_cursor2, 4, h_description);
                    END IF;
                    DBMS_SQL.CLOSE_CURSOR(h_cursor2);

                    -- Create the menu entry
            FND_MENU_ENTRIES_PKG.INSERT_ROW (
            X_ROWID         => h_row_id,
            X_MENU_ID       => h_menu_id,
            X_ENTRY_SEQUENCE    => h_entry_sequence,
            X_SUB_MENU_ID       => h_sub_menu_id,
            X_FUNCTION_ID       => h_function_id,
            X_GRANT_FLAG        => h_grant_flag,
            X_PROMPT        => h_prompt,
                X_DESCRIPTION           => h_description,
                X_CREATION_DATE         => sysdate,
                X_CREATED_BY            => h_user_id,
                X_LAST_UPDATE_DATE      => sysdate,
                X_LAST_UPDATED_BY       => h_user_id,
                X_LAST_UPDATE_LOGIN     => 0
                    );
            END LOOP;
                DBMS_SQL.CLOSE_CURSOR(h_cursor1);

            END IF;
        END IF;

    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(h_cursor);


    -- Now that all the menus have been migrated we can
    -- update the link_id in BSC_TAB_VIEW_LABLES_B with the menu_id in the target
    h_sql := 'UPDATE bsc_tab_view_labels_b l
              SET link_id = NVL((SELECT t.menu_id
                                 FROM fnd_menus t, fnd_menus@'||x_src_db_link||' s
                                 WHERE t.menu_name = s.menu_name AND
                                       l.link_id = s.menu_id),
                                NVL((SELECT t.menu_id
                                     FROM fnd_menus_vl t, fnd_menus_vl@'||x_src_db_link||' s
                                     WHERE t.user_menu_name = s.user_menu_name AND
                                           l.link_id = s.menu_id),
                                    -1))
              WHERE label_type = 2';
    BSC_APPS.Execute_Immediate(h_sql);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_LAUNCH_PAD_PVT.Migrate_Custom_Links');
        RETURN FALSE;
END Migrate_Custom_Links;


/*===========================================================================+
| FUNCTION Migrate_Custom_Links_Security
|
|   Description:   Assing the custom links (menus) to the target responsibility
|                  according to the source responsibility.
|                  Only add BSC menus to the target responsibility.
|
|   Return :       TRUE : no errors
|                  FALSE : error
|
+============================================================================*/
FUNCTION Migrate_Custom_Links_Security(
    x_trg_resp IN NUMBER,
    x_src_resp IN NUMBER,
    x_src_db_link IN VARCHAR2
    ) RETURN BOOLEAN IS

    e_no_migrate    EXCEPTION;

    h_sql       VARCHAR2(32000);
    h_ret       INTEGER;
    h_cursor        INTEGER;

    CURSOR c_top_menu_id IS
    SELECT menu_id
        FROM fnd_responsibility_vl
        WHERE responsibility_id = x_trg_resp;

    h_top_menu_id   NUMBER;
    h_top_menu_id_src   NUMBER;
    h_menu_id       NUMBER;
    h_description   VARCHAR2(240);
    h_entry_sequence    NUMBER;
    h_row_id        VARCHAR2(30) := NULL;
    h_function_id   NUMBER := NULL;
    h_grant_flag    VARCHAR2(1) := 'Y';
    h_prompt        VARCHAR(60) := NULL;
    h_user_id       NUMBER;

BEGIN
    -- Get user id
    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    h_user_id := BSC_APPS.fnd_global_user_id;

    -- Get the top menu id of the source responsibility
    h_sql := 'SELECT MENU_ID'||
             ' FROM FND_RESPONSIBILITY_VL@'||x_src_db_link||
             /*' WHERE RESPONSIBILITY_ID = '||x_src_resp;*/
             ' WHERE RESPONSIBILITY_ID = :1';

    h_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(h_cursor, h_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(h_cursor, 1, h_top_menu_id_src);
    DBMS_SQL.BIND_VARIABLE(h_cursor, ':1', x_src_resp);
    h_ret := DBMS_SQL.EXECUTE(h_cursor);

    IF DBMS_SQL.FETCH_ROWS(h_cursor) > 0 THEN
        DBMS_SQL.COLUMN_VALUE(h_cursor, 1, h_top_menu_id_src);
    ELSE
        -- The source responsibility does not have a top menu
        RAISE e_no_migrate;
    END IF;
    DBMS_SQL.CLOSE_CURSOR(h_cursor);


    -- Get the top menu id of the target responsibiity
    OPEN c_top_menu_id;
    FETCH c_top_menu_id INTO h_top_menu_id;
    IF c_top_menu_id%NOTFOUND THEN
        CLOSE c_top_menu_id;
        RAISE e_no_migrate;
    END IF;
    CLOSE c_top_menu_id;


    -- Get the information of the menus we need to assign to the top menu of the
    -- target responsibility.
    -- Those menus are the ones that the source responsibility has access to and
    -- are not already assigned to the top menu of the target responsibility and
    -- are BSC menus.
    h_sql := 'SELECT'||
         '    L.LINK_ID,'||
         '    M.DESCRIPTION'||
         ' FROM'||
         '    BSC_TAB_VIEW_LABELS_B L,'||
         '    BSC_TAB_VIEW_LABELS_B@'||x_src_db_link||' LS,'||
         '    FND_MENUS_VL M'||
             ' WHERE'||
             '    L.TAB_ID = LS.TAB_ID AND'||
         '    L.TAB_VIEW_ID = LS.TAB_VIEW_ID AND'||
             '    L.LABEL_ID = LS.LABEL_ID AND'||
         '    L.LABEL_TYPE = 2 AND'||
         '    NVL(L.LINK_ID, -1) <> -1 AND'||
         '    L.LINK_ID = M.MENU_ID AND'||
         '    UPPER(SUBSTR(MENU_NAME,1,3)) = ''BSC'' AND'||
         '    NOT (L.LINK_ID IN (SELECT SUB_MENU_ID'||
         '                       FROM FND_MENU_ENTRIES_VL'||
         '                       WHERE MENU_ID = :1 AND SUB_MENU_ID IS NOT NULL)) AND'||
       /*'                       WHERE MENU_ID = '||h_top_menu_id||' AND SUB_MENU_ID IS NOT NULL)) AND'||*/
             '    LS.LINK_ID IN (SELECT SUB_MENU_ID'||
         '                   FROM FND_MENU_ENTRIES_VL@'||x_src_db_link||
         '                   WHERE MENU_ID = :2 AND SUB_MENU_ID IS NOT NULL)';
      /* '                   WHERE MENU_ID = '||h_top_menu_id_src||' AND SUB_MENU_ID IS NOT NULL)';*/



    h_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(h_cursor, h_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(h_cursor, 1, h_menu_id);
    DBMS_SQL.DEFINE_COLUMN(h_cursor, 2, h_description, 240);
    DBMS_SQL.BIND_VARIABLE(h_cursor, ':1', h_top_menu_id);
    DBMS_SQL.BIND_VARIABLE(h_cursor, ':2', h_top_menu_id_src);
    h_ret := DBMS_SQL.EXECUTE(h_cursor);

    WHILE DBMS_SQL.FETCH_ROWS(h_cursor) > 0 LOOP
        DBMS_SQL.COLUMN_VALUE(h_cursor, 1, h_menu_id);
        DBMS_SQL.COLUMN_VALUE(h_cursor, 2, h_description);

        -- Get the maximum entry sequence
        SELECT nvl(max(entry_sequence)+1, 1) INTO h_entry_sequence
    FROM fnd_menu_entries
        WHERE menu_id = h_top_menu_id;

        -- Create the menu entry
        FND_MENU_ENTRIES_PKG.INSERT_ROW (
        X_ROWID         => h_row_id,
        X_MENU_ID       => h_top_menu_id,
        X_ENTRY_SEQUENCE    => h_entry_sequence,
        X_SUB_MENU_ID       => h_menu_id,
        X_FUNCTION_ID       => h_function_id,
        X_GRANT_FLAG        => h_grant_flag,
        X_PROMPT        => h_prompt,
        X_DESCRIPTION           => h_description,
        X_CREATION_DATE         => sysdate,
            X_CREATED_BY            => h_user_id,
            X_LAST_UPDATE_DATE      => sysdate,
            X_LAST_UPDATED_BY       => h_user_id,
            X_LAST_UPDATE_LOGIN     => 0
            );
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(h_cursor);

    RETURN TRUE;

EXCEPTION
    WHEN e_no_migrate THEN
        RETURN TRUE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_LAUNCH_PAD_PVT.Migrate_Custom_Links_Security');
        RETURN FALSE;
END Migrate_Custom_Links_Security;

/**********************************************************************
 Name :-  is_Launch_Pad_Attached
 Description : -This fucntion will validate if the launchad is attached
                to the root application module or not.
 OutPut :-  TRUE  : launchpad is attached.
            FALSE : not attached.
/*********************************************************************/

FUNCTION is_Launch_Pad_Attached
(
     p_Menu_Id          IN  FND_MENUS.menu_id%TYPE
   , p_Sub_Menu_Id      IN  FND_MENUS.menu_id%TYPE

) RETURN BOOLEAN
IS
l_count         NUMBER;
BEGIN

    SELECT  COUNT(0)
    INTO    l_count
    FROM    FND_MENU_ENTRIES
    WHERE   MENU_ID = p_Menu_Id
    AND     SUB_MENU_ID = p_Sub_Menu_Id;

    IF (l_count<>0) THEN
     RETURN TRUE;
    ELSE
     RETURN FALSE;
    END IF;
END  is_Launch_Pad_Attached;

/**********************************************************************
 Name :-  get_entry_sequence
 Description : -This fucntion returns the entry sequnce corresponding to
                to the root application menu and the launchpad menu id.
 /*********************************************************************/

FUNCTION get_entry_sequence
(
     p_Menu_Id        IN  FND_MENUS.menu_id%TYPE
   , p_Sub_Menu_Id    IN  FND_MENUS.menu_id%TYPE
) RETURN NUMBER
IS
  l_entry_sequence      FND_MENU_ENTRIES.entry_sequence%TYPE;

  CURSOR c_entry_sequnece IS
  SELECT ENTRY_SEQUENCE
  FROM   FND_MENU_ENTRIES
  WHERE  MENU_ID = p_Menu_Id
  AND    SUB_MENU_ID = p_Sub_Menu_Id;

BEGIN

  IF(c_entry_sequnece%ISOPEN) THEN
   CLOSE  c_entry_sequnece;
  END IF;

  OPEN c_entry_sequnece;
  FETCH c_entry_sequnece INTO l_entry_sequence;
  CLOSE c_entry_sequnece;

  RETURN l_entry_sequence;
END  get_entry_sequence;


END BSC_LAUNCH_PAD_PVT;

/
