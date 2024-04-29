--------------------------------------------------------
--  DDL for Package Body JTM_HOOK_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_HOOK_UTIL_PKG" AS
/* $Header: jtmhutlb.pls 120.3 2006/01/13 03:21:17 trajasek noship $ */

/*** Globals ***/
g_resource_id    NUMBER;  -- variable used for caching current resource_id
g_debug_level    NUMBER;  -- variable containing debug level

/*** For return of profile values ***/
G_SITE_LEVEL_ID    CONSTANT NUMBER := 10001;
G_APPL_LEVEL_ID    CONSTANT NUMBER := 10002;
G_RESP_LEVEL_ID    CONSTANT NUMBER := 10003;
G_USER_LEVEL_ID    CONSTANT NUMBER := 10004;

/***
  Function that returns debug level.
  0 = No debug
  1 = Log errors
  2 = Log errors and functional messages
  3 = Log errors, functional messages and SQL statements
  4 = Full Debug
***/
FUNCTION Get_Debug_Level
RETURN NUMBER
IS
BEGIN
  /*** has debug mode already been retrieved ***/
  IF g_debug_level IS NULL THEN
    /*** no -> get it from profile ***/
    g_debug_level := FND_PROFILE.VALUE( 'JTM_DEBUG_LEVEL');
  END IF;
  RETURN g_debug_level;
END Get_Debug_Level;

/*** Function to check if this resource is a Mobile Field Service/Laptop user ***/
FUNCTION isMobileFSresource
  ( p_resource_id in NUMBER
  )
RETURN BOOLEAN
IS
 /*** cursor to check if user is mobile user resource ***/
 /* A user is a mobile FS user when:
    - Exists in ASG_USER
    - Has a responsibility that is mapped to the publication 'SERVICEL'
 */
 --Bug 4924543
 CURSOR c_asg_user( b_resource_id NUMBER ) IS
 SELECT null
    FROM  asg_user               au
    ,     asg_user_pub_resps     aupr
    WHERE au.user_name   = aupr.user_name
    AND   aupr.pub_name  = 'SERVICEL'
    AND   au.enabled 	 = 'Y'
    AND   au.resource_id = b_resource_id;

 r_asg_user c_asg_user%ROWTYPE;

BEGIN
  OPEN c_asg_user( p_resource_id );
  FETCH c_asg_user INTO r_asg_user;
  IF c_asg_user%NOTFOUND THEN
    /*** resource is not a mobile user -> exit ***/
    CLOSE c_asg_user;
    RETURN FALSE;
  END IF;
  CLOSE c_asg_user;
  RETURN TRUE;
END isMobileFSresource;

/***
Procedure that returns resource_id for a given client_name.
***/
FUNCTION Get_Resource_Id( p_client_name IN VARCHAR2
	           )
RETURN NUMBER IS
  CURSOR c_resource ( b_client_name VARCHAR2) IS
    SELECT resource_id
    FROM   jtf_rs_resource_extns rre
    ,      fnd_user              usr
    WHERE  usr.user_id = rre.user_id
    AND    usr.user_name = b_client_name;
  r_resource c_resource%ROWTYPE;
BEGIN
  OPEN c_resource( p_client_name );
  FETCH c_resource INTO r_resource;
  CLOSE c_resource;
  RETURN r_resource.resource_id;
END Get_Resource_Id;

FUNCTION Get_User_Id( p_client_name IN VARCHAR2
	           )
RETURN NUMBER
IS
 CURSOR c_user( b_client_name VARCHAR2 ) IS
  SELECT user_id
  FROM fnd_user
  WHERE user_name = b_client_name;
 r_user c_user%ROWTYPE;
BEGIN
 OPEN c_user( p_client_name );
 FETCH c_user INTO r_user;
 CLOSE c_user;
 RETURN r_user.user_id;
END Get_User_Id;

/***
  Procedure that checks if an ACC record exists for a given resource_id.
  If so, it returns the ACC record's access_id.
  If not, it returns -1.
***/
FUNCTION Get_Acc_Id
 (  p_acc_table_name     in VARCHAR2
  , p_resource_id        in NUMBER
  , p_pk1_name           in VARCHAR2
  , p_pk1_num_value      in NUMBER   DEFAULT NULL
  , p_pk1_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk1_date_value     in DATE     DEFAULT NULL
  , p_pk2_name           in VARCHAR2 DEFAULT NULL
  , p_pk2_num_value      in NUMBER   DEFAULT NULL
  , p_pk2_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk2_date_value     in DATE     DEFAULT NULL
  , p_pk3_name           in VARCHAR2 DEFAULT NULL
  , p_pk3_num_value      in NUMBER   DEFAULT NULL
  , p_pk3_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk3_date_value     in DATE     DEFAULT NULL
 )
RETURN NUMBER
IS
  l_stmt           VARCHAR2(2000);
  l_access_id      NUMBER;
  l_error_msg      VARCHAR2(4000);
  l_merged_pk      VARCHAR2(4000);
  l_pk1_value      VARCHAR2(4000);
  l_pk2_value      VARCHAR2(4000) := NULL;
  l_pk3_value      VARCHAR2(4000) := NULL;
  l_pk1_string     VARCHAR2(4000);
  l_pk2_string     VARCHAR2(4000);
  l_pk3_string     VARCHAR2(4000);
BEGIN

  IF p_pk1_date_value IS null THEN
    l_pk1_value := NVL( TO_CHAR(p_pk1_num_value ), p_pk1_char_value );
    l_pk1_string:= ':2';
  ELSE
    l_pk1_value := to_char((p_pk1_date_value),'j');
    l_pk1_string:= 'to_date(:2,''j'')';
  END IF;
  /* Create Execute statement and log strings */
  l_stmt := 'SELECT ACCESS_ID FROM ' || p_acc_table_name ||
            ' WHERE RESOURCE_ID = :1' ||
            ' AND ' || p_pk1_name || ' = ' || l_pk1_string;
    l_error_msg := ' :2 = ' || l_pk1_value;
    l_merged_pk := l_pk1_value;
    IF p_pk2_name IS NOT NULL THEN
      IF p_pk2_date_VALUE IS null THEN
        l_pk2_value := NVL( TO_CHAR(p_pk2_num_value ), p_pk2_char_value );
        l_pk2_string:= ':4';
      ELSE
        l_pk2_value := to_char((p_pk2_date_value),'j');
        l_pk2_string:= 'to_date(:4,''j'')';
      END IF;
      /* Create Execute statement and log strings */
      l_stmt := l_stmt || ' AND ' || p_pk2_name || ' = ' || l_pk2_string;
      if ( Length(l_error_msg || fnd_global.local_chr(10)
           || ' :4 = ' || l_pk2_value) < 4000) then
          l_error_msg := l_error_msg || fnd_global.local_chr(10)
                         || ' :4 = ' || l_pk2_value;
      elsif (Length(l_error_msg || ' ...') < 4000) then
          l_error_msg := l_error_msg || ' ...';
      end if;

      if ( Length(l_merged_pk || ' , ' || l_pk2_value) < 4000 ) then
          l_merged_pk := l_merged_pk || ' , ' || l_pk2_value;
      elsif ( Length(l_merged_pk || ' ...') < 4000 ) then
          l_merged_pk := l_merged_pk || ' ...';
      end if;
      IF p_pk3_name IS NOT null THEN
        /* There are three PK's */
        IF p_pk3_date_value IS null THEN
          l_pk3_value := NVL( TO_CHAR(p_pk3_num_value ), p_pk3_char_value );
          l_pk3_string:= ':5';
        ELSE
          l_pk3_value := to_char((p_pk3_date_value),'j');
          l_pk3_string:= 'to_date(:5,''j'')';
        END IF;
        /* Create Execute statement and log strings */
        l_stmt := l_stmt || ' AND ' || p_pk3_name || ' = ' || l_pk3_string;
        if ( Length(l_error_msg || fnd_global.local_chr(10)
             || ' :5 = ' || l_pk3_value) < 4000) then
            l_error_msg := l_error_msg || fnd_global.local_chr(10)
                           || ' :5 = ' || l_pk3_value;
        elsif (Length(l_error_msg || ' ...') < 4000) then
            l_error_msg := l_error_msg || ' ...';
        end if;
        if ( Length(l_merged_pk || ' , ' || l_pk3_value) < 4000 ) then
            l_merged_pk := l_merged_pk || ' , ' || l_pk3_value;
        elsif ( Length(l_merged_pk || ' ...') < 4000 ) then
            l_merged_pk := l_merged_pk || ' ...';
        end if;
      END IF;
    END IF;

  IF Get_Debug_Level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_merged_pk
    , p_acc_table_name
    , 'JTM_HOOK_UTIL_PKG.Get_Acc_Id executing:' || fnd_global.local_chr(10) ||
      l_stmt || fnd_global.local_chr(10) ||
      ':1 = ' || p_resource_id || fnd_global.local_chr(10) || l_error_msg
    , JTM_HOOK_UTIL_PKG.g_debug_level_full
    , 'jtm_message_log_pkg');
  END IF;

  IF p_pk2_name IS NULL THEN
    EXECUTE IMMEDIATE l_stmt INTO l_access_id USING p_resource_id, l_pk1_value;
  ELSIF p_pk3_name IS NULL then
    EXECUTE IMMEDIATE l_stmt INTO l_access_id USING p_resource_id, l_pk1_value, l_pk2_value;
  ELSE
    EXECUTE IMMEDIATE l_stmt INTO l_access_id USING p_resource_id, l_pk1_value, l_pk2_value, l_pk3_value;
  END IF;
  /*** record exists -> return access code ***/
  RETURN l_access_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    RETURN -1;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
    RAISE;
END Get_Acc_Id;

/***
  Procedure that returns all RESOURCE_ID, ACCESS_ID combinations present in ACC for a given
  table_name, primary key name and primary key value
***/
PROCEDURE Get_Resource_Acc_List
 (  p_acc_table_name     in  VARCHAR2
  , p_pk1_name           in VARCHAR2
  , p_pk1_num_value      in NUMBER   DEFAULT NULL
  , p_pk1_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk1_date_value     in DATE     DEFAULT NULL
  , p_pk2_name           in VARCHAR2 DEFAULT NULL
  , p_pk2_num_value      in NUMBER   DEFAULT NULL
  , p_pk2_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk2_date_value     in DATE     DEFAULT NULL
  , p_pk3_name           in VARCHAR2 DEFAULT NULL
  , p_pk3_num_value      in NUMBER   DEFAULT NULL
  , p_pk3_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk3_date_value     in DATE     DEFAULT NULL
  , l_tab_resource_id    out NOCOPY dbms_sql.Number_Table
  , l_tab_access_id      out NOCOPY dbms_sql.Number_Table
 )
IS
  l_stmt               VARCHAR2(2000);
  l_cursor             INTEGER;
  l_count              INTEGER;
  l_index              NUMBER;
  l_error_msg          VARCHAR2(4000);
  l_merged_pk          VARCHAR2(4000);
  l_pk1_value          VARCHAR2(4000);
  l_pk2_value          VARCHAR2(4000) := NULL;
  l_pk3_value          VARCHAR2(4000) := NULL;
  l_pk1_string         VARCHAR2(4000);
  l_pk2_string         VARCHAR2(4000);
  l_pk3_string         VARCHAR2(4000);
BEGIN
  IF p_pk1_date_value IS null THEN
    l_pk1_value := NVL( TO_CHAR(p_pk1_num_value ), p_pk1_char_value );
    l_pk1_string:= ':P1';
  ELSE
    l_pk1_value := to_char((p_pk1_date_value),'j');
    l_pk1_string:= 'to_date(:P1,''j'')';
  END IF;
  /* Create Execute statement and log strings */
  l_stmt := 'SELECT RESOURCE_ID, ACCESS_ID FROM ' || p_acc_table_name ||
            ' WHERE ' || p_pk1_name || ' = ' || l_pk1_string;
  l_error_msg := ' :P1 = ' || l_pk1_value;
  l_merged_pk := l_pk1_value;
    IF p_pk2_name IS NOT NULL THEN
      IF p_pk2_date_VALUE IS null THEN
        l_pk2_value := NVL( TO_CHAR(p_pk2_num_value ), p_pk2_char_value );
        l_pk2_string:= ':P2';
      ELSE
        l_pk2_value := to_char((p_pk2_date_value),'j');
        l_pk2_string:= 'to_date(:P2,''j'')';
      END IF;
      /* Create Execute statement and log strings */
      l_stmt := l_stmt || ' AND ' || p_pk2_name || ' = ' || l_pk2_string;
      if ( Length(l_error_msg || fnd_global.local_chr(10)
           || ' :P2 = ' || l_pk2_value) < 4000) then
          l_error_msg := l_error_msg || fnd_global.local_chr(10)
                         || ' :P2 = ' || l_pk2_value;
      elsif (Length(l_error_msg || ' ...') < 4000) then
          l_error_msg := l_error_msg || ' ...';
      end if;

      if ( Length(l_merged_pk || ' , ' || l_pk2_value) < 4000 ) then
          l_merged_pk := l_merged_pk || ' , ' || l_pk2_value;
      elsif ( Length(l_merged_pk || ' ...') < 4000 ) then
          l_merged_pk := l_merged_pk || ' ...';
      end if;
      IF p_pk3_name IS NOT null THEN
        /* There are three PK's */
        IF p_pk3_date_value IS null THEN
          l_pk3_value := NVL( TO_CHAR(p_pk3_num_value ), p_pk3_char_value );
          l_pk3_string:= ':P3';
        ELSE
          l_pk3_value := to_char((p_pk3_date_value),'j');
          l_pk3_string:= 'to_date(:P3,''j'')';
        END IF;
        /* Create Execute statement and log strings */
        l_stmt := l_stmt || ' AND ' || p_pk3_name || ' = ' || l_pk3_string;
        if ( Length(l_error_msg || fnd_global.local_chr(10)
             || ' :P3 = ' || l_pk3_value) < 4000) then
            l_error_msg := l_error_msg || fnd_global.local_chr(10)
                         || ' :P3 = ' || l_pk3_value;
        elsif (Length(l_error_msg || ' ...') < 4000) then
            l_error_msg := l_error_msg || ' ...';
        end if;
        if ( Length(l_merged_pk || ' , ' || l_pk3_value) < 4000 ) then
            l_merged_pk := l_merged_pk || ' , ' || l_pk3_value;
        elsif ( Length(l_merged_pk || ' ...') < 4000 ) then
            l_merged_pk := l_merged_pk || ' ...';
        end if;
      END IF;
    END IF;

  IF Get_Debug_Level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_merged_pk
    , p_acc_table_name
    , 'JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List executing:' || fnd_global.local_chr(10) ||
      l_stmt || fnd_global.local_chr(10) || l_error_msg
    , JTM_HOOK_UTIL_PKG.g_debug_level_full
    , 'jtm_message_log_pkg');
  END IF;

  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse( l_cursor, l_stmt, dbms_sql.v7);
  dbms_sql.bind_variable( l_cursor, 'P1', l_pk1_value);
  IF p_pk2_name IS NOT NULL THEN
    dbms_sql.bind_variable( l_cursor, 'P2', l_pk2_value );
    IF p_pk3_name IS NOT NULL THEN
      dbms_sql.bind_variable( l_cursor, 'P3', l_pk3_value );
    END IF;
  END IF;
  l_index := 1;
  dbms_sql.define_array( l_cursor, 1, l_tab_resource_id, 10, l_index);
  dbms_sql.define_array( l_cursor, 2, l_tab_access_id, 10, l_index);
  l_count := dbms_sql.execute( l_cursor );
  LOOP
    l_count := dbms_sql.fetch_rows(l_cursor);

    dbms_sql.column_value( l_cursor, '1', l_tab_resource_id);
    dbms_sql.column_value( l_cursor, '2', l_tab_access_id);

    EXIT WHEN l_count <> 10;
  END LOOP;
  dbms_sql.close_cursor( l_cursor );
END Get_Resource_Acc_List;

/***
  Procedure that inserts a record into any ACC table
***/
PROCEDURE INSERT_ACC
  ( p_publication_item_names in t_publication_item_list
  , p_acc_table_name         in VARCHAR2
  , p_resource_id            in NUMBER
  , p_pk1_name               in VARCHAR2
  , p_pk1_num_value          in NUMBER   DEFAULT NULL
  , p_pk1_char_value         in VARCHAR2 DEFAULT NULL
  , p_pk1_date_value         in DATE     DEFAULT NULL
  , p_pk2_name               in VARCHAR2 DEFAULT NULL
  , p_pk2_num_value          in NUMBER   DEFAULT NULL
  , p_pk2_char_value         in VARCHAR2 DEFAULT NULL
  , p_pk2_date_value         in DATE     DEFAULT NULL
  , p_pk3_name               in VARCHAR2 DEFAULT NULL
  , p_pk3_num_value          in NUMBER   DEFAULT NULL
  , p_pk3_char_value         in VARCHAR2 DEFAULT NULL
  , p_pk3_date_value         in DATE     DEFAULT NULL
 )
IS
  l_stmt           VARCHAR2(2000);
  l_access_id      NUMBER;
  l_error_msg      VARCHAR2(4000);
  l_merged_pk      VARCHAR2(4000);
  l_pk1_value      VARCHAR2(4000);
  l_pk2_value      VARCHAR2(4000) := NULL;
  l_pk3_value      VARCHAR2(4000) := NULL;
  l_pk1_string     VARCHAR2(4000);
  l_pk2_string     VARCHAR2(4000);
  l_pk3_string     VARCHAR2(4000);
  l_rc             BOOLEAN;
BEGIN
  /*** insert new ACC record for current resource ***/
  l_access_id := Get_Acc_Id
                 ( p_acc_table_name => p_acc_table_name
                 , p_resource_id    => p_resource_id
                 , p_pk1_name       => p_pk1_name
                 , p_pk1_num_value  => p_pk1_num_value
                 , p_pk1_char_value => p_pk1_char_value
                 , p_pk1_date_value => p_pk1_date_value
                 , p_pk2_name       => p_pk2_name
                 , p_pk2_num_value  => p_pk2_num_value
                 , p_pk2_char_value => p_pk2_char_value
	             , p_pk2_date_value => p_pk2_date_value
                 , p_pk3_name       => p_pk2_name
                 , p_pk3_num_value  => p_pk2_num_value
                 , p_pk3_char_value => p_pk2_char_value
 	             , p_pk3_date_value => p_pk2_date_value);

  IF l_access_id <> -1 THEN
    /*Record already exists for this user, increasing the counter*/
    l_stmt := 'UPDATE '||p_acc_table_name||
              ' SET COUNTER = COUNTER + 1'||
	      ', LAST_UPDATE_DATE = SYSDATE '||
	      ', LAST_UPDATED_BY = 1 '||
              ' WHERE ACCESS_ID = :1 ';

    IF Get_Debug_Level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
       jtm_message_log_pkg.Log_Msg
         ( l_access_id
         , p_acc_table_name
         , 'JTM_HOOK_UTIL_PKG.Insert_Acc executing:' || fnd_global.local_chr(10) || l_stmt
         , JTM_HOOK_UTIL_PKG.g_debug_level_full
         , 'jtm_message_log_pkg');
    END IF;
    EXECUTE IMMEDIATE l_stmt using l_access_id;

  ELSE
  /*Record does not exists so do the insert*/
  /* Check how many PK there are and transfer values */
    IF p_pk1_date_value IS null THEN
      l_pk1_value := NVL( TO_CHAR(p_pk1_num_value ), p_pk1_char_value );
      l_pk1_string:= ':2';
    ELSE
      l_pk1_value := to_char((p_pk1_date_value),'j');
      l_pk1_string:= 'to_date(:2,''j'')';
    END IF;
    /* Create Execute statement and log strings */
    l_stmt := 'INSERT INTO ' || p_acc_table_name || ' (ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,'||
              ' CREATION_DATE, CREATED_BY, COUNTER, RESOURCE_ID, ' || p_pk1_name || ') ' ||
              'VALUES (JTM_ACC_TABLE_S.NEXTVAL, SYSDATE, 1, SYSDATE, 1, 1, :1, ' || l_pk1_string ||
              ') RETURNING ACCESS_ID INTO :3';
    l_error_msg := ' :2 = ' || l_pk1_value;
    l_merged_pk := l_pk1_value;
    IF p_pk2_name IS NOT NULL THEN
      IF p_pk2_date_VALUE IS null THEN
        l_pk2_value := NVL( TO_CHAR(p_pk2_num_value ), p_pk2_char_value );
        l_pk2_string:= ':4';
      ELSE
        l_pk2_value := to_char((p_pk2_date_value),'j');
        l_pk2_string:= 'to_date(:4,''j'')';
      END IF;
      /* Create Execute statement and log strings */
      l_stmt := 'INSERT INTO ' || p_acc_table_name || ' (ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,'||
                ' CREATION_DATE, CREATED_BY, COUNTER, RESOURCE_ID, ' ||
	 p_pk1_name ||', '|| p_pk2_name || ') ' ||
                'VALUES (JTM_ACC_TABLE_S.NEXTVAL, SYSDATE, 1, SYSDATE, 1, 1, :1, ' ||
	 l_pk1_string || ', ' || l_pk2_string || ' ) RETURNING '||  'ACCESS_ID INTO :3';
      if ( Length(l_error_msg || fnd_global.local_chr(10)
           || ' :4 = ' || l_pk2_value) < 4000) then
          l_error_msg := l_error_msg || fnd_global.local_chr(10)
                         || ' :4 = ' || l_pk2_value;
      elsif (Length(l_error_msg || ' ...') < 4000) then
          l_error_msg := l_error_msg || ' ...';
      end if;
      if ( Length(l_merged_pk || ' , ' || l_pk2_value) < 4000 ) then
          l_merged_pk := l_merged_pk || ' , ' || l_pk2_value;
      elsif ( Length(l_merged_pk || ' ...') < 4000 ) then
          l_merged_pk := l_merged_pk || ' ...';
      end if;
      IF p_pk3_name IS NOT null THEN
        /* There are three PK's */
        IF p_pk3_date_value IS null THEN
          l_pk3_value := NVL( TO_CHAR(p_pk3_num_value ), p_pk3_char_value );
          l_pk3_string:= ':5';
        ELSE
          l_pk3_value := to_char((p_pk3_date_value),'j');
          l_pk3_string:= 'to_date(:5,''j'')';
        END IF;
        /* Create Execute statement and log strings */
        l_stmt := 'INSERT INTO ' || p_acc_table_name || ' (ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,'||
                  ' CREATION_DATE, CREATED_BY, COUNTER, RESOURCE_ID, ' ||
                  p_pk1_name ||', '|| p_pk2_name ||', '|| p_pk3_name || ') ' ||
                  'VALUES (JTM_ACC_TABLE_S.NEXTVAL, SYSDATE, 1, SYSDATE, 1, 1, :1, ' ||
	 l_pk1_string || ', ' || l_pk2_string || ', ' || l_pk3_string || ' ) RETURNING '||
                  'ACCESS_ID INTO :3';
        if ( Length(l_error_msg || fnd_global.local_chr(10)
             || ' :5 = ' || l_pk3_value) < 4000) then
            l_error_msg := l_error_msg || fnd_global.local_chr(10)
                           || ' :5 = ' || l_pk3_value;
        elsif (Length(l_error_msg || ' ...') < 4000) then
            l_error_msg := l_error_msg || ' ...';
        end if;

        if ( Length(l_merged_pk || ' , ' || l_pk3_value) < 4000 ) then
            l_merged_pk := l_merged_pk || ' , ' || l_pk3_value;
        elsif ( Length(l_merged_pk || ' ...') < 4000 ) then
            l_merged_pk := l_merged_pk || ' ...';
        end if;
      END IF;
    END IF;

    IF Get_Debug_Level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
       jtm_message_log_pkg.Log_Msg
         ( l_merged_pk
         , p_acc_table_name
         , 'JTM_HOOK_UTIL_PKG.Insert_Acc executing:' || fnd_global.local_chr(10) ||
           l_stmt || fnd_global.local_chr(10) || ':1 = ' || p_resource_id
           || fnd_global.local_chr(10) || l_error_msg
         , JTM_HOOK_UTIL_PKG.g_debug_level_full
         , 'jtm_message_log_pkg');
    END IF;

    /*We have at least one PK so get the value*/
    IF l_pk2_value IS NULL THEN
      /* Only one PK available */
      EXECUTE IMMEDIATE l_stmt USING p_resource_id, l_pk1_value  RETURNING INTO l_access_id;
    ELSIF l_pk3_value IS NULL THEN
      /*Two PK's */
      EXECUTE IMMEDIATE l_stmt USING p_resource_id, l_pk1_value, l_pk2_value  RETURNING INTO l_access_id;
    ELSE
      /* Three PK's */
      EXECUTE IMMEDIATE l_stmt USING p_resource_id, l_pk1_value, l_pk2_value, l_pk3_value
      RETURNING INTO l_access_id;
    END IF;
    -- insert record in outqueue ASG call here *****************************************
    FOR i IN 1 .. p_publication_item_names.LAST LOOP
      l_rc := asg_download.markDirty(p_publication_item_names(i), l_access_id, p_resource_id, 'I', sysdate );
    END LOOP;
  END IF;
END Insert_Acc;

/*** Procedure that re-sends a record with given acc_id to the mobile ***/
PROCEDURE Update_Acc
 ( p_publication_item_names in t_publication_item_list
  ,p_acc_table_name         in VARCHAR2
  ,p_resource_id            in NUMBER
  ,p_access_id              in NUMBER
 )
IS
 l_rc BOOLEAN;
BEGIN
 --call update outqueue ASG call *****************************************
  FOR i IN 1 .. p_publication_item_names.LAST LOOP
    l_rc := asg_download.markDirty(p_publication_item_names(i), p_access_id, p_resource_id, 'U', sysdate );
  END LOOP;
END Update_Acc;

/***
 Procedure that deletes record(s) from any ACC table
 If p_resource_id is NULL, all ACC records that match the PK values are deleted.
 If p_resource_id is specified and p_operator='=' the ACC record is only deleted for that specific resource.
 If p_resource_id is specified and p_operator='<>' all ACC records with resource_id<>p_resource_id are deleted
***/
PROCEDURE Delete_Acc
 ( p_publication_item_names in t_publication_item_list
  ,p_acc_table_name         in VARCHAR2
  ,p_pk1_name               in VARCHAR2
  ,p_pk1_num_value          in NUMBER   DEFAULT NULL
  ,p_pk1_char_value         in VARCHAR2 DEFAULT NULL
  , p_pk1_date_value        in DATE     DEFAULT NULL
  , p_pk2_name              in VARCHAR2 DEFAULT NULL
  , p_pk2_num_value         in NUMBER   DEFAULT NULL
  , p_pk2_char_value        in VARCHAR2 DEFAULT NULL
  , p_pk2_date_value        in DATE     DEFAULT NULL
  , p_pk3_name              in VARCHAR2 DEFAULT NULL
  , p_pk3_num_value         in NUMBER   DEFAULT NULL
  , p_pk3_char_value        in VARCHAR2 DEFAULT NULL
  , p_pk3_date_value        in DATE     DEFAULT NULL
  ,p_resource_id            in NUMBER   DEFAULT NULL
  ,p_operator               in VARCHAR2 DEFAULT NULL
)
IS
  l_stmt               VARCHAR2(4000);
  l_cursor             INTEGER;
  l_count              INTEGER;
  l_tab_mobile_user_id dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
  l_pk1_value          VARCHAR2(4000);
  l_pk2_value          VARCHAR2(4000);
  l_pk3_value          VARCHAR2(4000);
  l_pk1_string         VARCHAR2(4000);
  l_pk2_string         VARCHAR2(4000);
  l_pk3_string         VARCHAR2(4000);
  l_pk_err_msg_txt     VARCHAR2(4000);
  l_count_value        NUMBER;
  l_rc                 BOOLEAN;
  l_index              NUMBER;
  l_operator           VARCHAR2(20);
BEGIN
  IF p_operator is null THEN
     l_operator := '=';
  ELSE
     l_operator := p_operator;
  END IF;

  IF p_pk1_date_value IS null THEN
    l_pk1_value := NVL( TO_CHAR(p_pk1_num_value ), p_pk1_char_value );
    l_pk1_string:= ':P1';
  ELSE
    l_pk1_value := to_char((p_pk1_date_value),'j');
    l_pk1_string:= 'to_date(:P1,''j'')';
  END IF;
  IF p_pk2_name IS NOT NULL THEN
    IF p_pk2_date_value IS null THEN
      l_pk2_value := NVL( TO_CHAR(p_pk2_num_value ), p_pk2_char_value );
        l_pk2_string:= ':P2';
      ELSE
        l_pk2_value := to_char((p_pk2_date_value),'j');
        l_pk2_string:= 'to_date(:P2,''j'')';
    END IF;
    IF p_pk3_name IS NOT NULL THEN
      /* There are three PK's */
      IF p_pk3_date_value IS null THEN
        l_pk3_value := NVL( TO_CHAR(p_pk3_num_value ), p_pk3_char_value );
        l_pk3_string:= ':P3';
      ELSE
        l_pk3_value := to_char((p_pk3_date_value),'j');
        l_pk3_string:= 'to_date(:P3,''j'')';
      END IF;
    END IF;
  END IF;

  /*** At least 1 PK ***/
  l_stmt := 'SELECT RESOURCE_ID, ACCESS_ID FROM ' || p_acc_table_name ||
            ' WHERE COUNTER = 1 AND ' || p_pk1_name || ' = ' || l_pk1_string;
  IF p_pk2_name IS NOT NULL THEN
    /*** 2 PK's available ***/
    l_stmt := l_stmt ||' AND ' || p_pk2_name || ' = ' || l_pk2_string;
    IF p_pk3_name IS NOT NULL THEN
      /*** 3 PK's available ***/
      l_stmt := l_stmt ||' AND ' || p_pk3_name || ' = ' || l_pk3_string;
    END IF;
  END IF;

  l_cursor := dbms_sql.open_cursor;

  /*** was resource_id provided? ***/
  IF p_resource_id IS NOT NULL THEN
    /*** yes -> add p_operator filter on mobile_user_id to WHERE clause ***/
    l_stmt := l_stmt || ' AND RESOURCE_ID ' || l_operator || ' :P4 ';
    dbms_sql.parse( l_cursor, l_stmt, dbms_sql.v7);
    dbms_sql.bind_variable( l_cursor, 'P4', p_resource_id );
  ELSE
    /*** no -> delete all ACC records ***/
    dbms_sql.parse( l_cursor, l_stmt, dbms_sql.v7);
  END IF;

  dbms_sql.bind_variable( l_cursor, 'P1', l_pk1_value );
  IF p_pk2_name IS NOT NULL THEN
    dbms_sql.bind_variable( l_cursor, 'P2', l_pk2_value );
    IF p_pk3_name IS NOT NULL THEN
      dbms_sql.bind_variable( l_cursor, 'P3', l_pk3_value );
    END IF;
  END IF;

  l_index := 1;
  dbms_sql.define_array( l_cursor, 1, l_tab_mobile_user_id, 10, l_index);
  dbms_sql.define_array( l_cursor, 2, l_tab_access_id, 10, l_index);


  IF Get_Debug_Level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
    jtm_message_log_pkg.Log_Msg
     ( l_pk1_value||','||l_pk2_value||','||l_pk3_value
     , p_acc_table_name
     , 'JTM_HOOK_UTIL_PKG.Delete_Acc executing:' || fnd_global.local_chr(10) ||
      l_stmt || fnd_global.local_chr(10) ||
      ':P1 = ' || l_pk1_value || fnd_global.local_chr(10) ||
      ':P2 = ' || l_pk2_value || fnd_global.local_chr(10) ||
      ':P3 = ' || l_pk3_value || fnd_global.local_chr(10) ||
      ':P4 = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.g_debug_level_full
    , 'jtm_message_log_pkg');
  END IF;

  l_count := dbms_sql.execute( l_cursor );
  LOOP
    l_count := dbms_sql.fetch_rows(l_cursor);

    dbms_sql.column_value( l_cursor, '1', l_tab_mobile_user_id);
    dbms_sql.column_value( l_cursor, '2', l_tab_access_id);

    EXIT WHEN l_count <> 10;
  END LOOP;
  dbms_sql.close_cursor( l_cursor );

  /*** were any records deleted? ***/
  IF l_tab_mobile_user_id.COUNT > 0 THEN
    /*** yes -> loop over arrays containing mobile_user_id and access_id and notify oLite ***/
    FOR i IN l_tab_mobile_user_id.FIRST .. l_tab_mobile_user_id.LAST LOOP
      -- notify oLite of deletion ***
      FOR j IN 1 .. p_publication_item_names.LAST LOOP
        l_rc := asg_download.markDirty( p_publication_item_names(j), l_tab_access_id(i)
                                      , l_tab_mobile_user_id(i), 'D', sysdate );
      END LOOP;
    END LOOP;
  END IF;

  /*Perform the actual delete*/
  l_stmt := 'DELETE '||p_acc_table_name||
            ' WHERE COUNTER = 1'||
	    ' AND '||p_pk1_name||' = ' || l_pk1_string;
  IF p_pk2_name IS NOT NULL THEN
    l_stmt := l_stmt ||' AND '||p_pk2_name|| ' = ' || l_pk2_string;
    IF p_pk3_name IS NOT NULL THEN
      l_stmt := l_stmt ||' AND '||p_pk3_name|| ' = ' || l_pk3_string;
    END IF;
  END IF;
  IF p_resource_id IS NOT NULL THEN
    l_stmt := l_stmt ||' AND RESOURCE_ID '||l_operator||' :P4';
  END IF;

  IF Get_Debug_Level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
    jtm_message_log_pkg.Log_Msg
     ( l_pk1_value||','||l_pk2_value||','||l_pk3_value
     , p_acc_table_name
     , 'JTM_HOOK_UTIL_PKG.Delete_Acc executing :' || fnd_global.local_chr(10) ||
      l_stmt || fnd_global.local_chr(10) ||
      ':P1 = ' || l_pk1_value || fnd_global.local_chr(10) ||
      ':P2 = ' || l_pk2_value || fnd_global.local_chr(10) ||
      ':P3 = ' || l_pk3_value || fnd_global.local_chr(10) ||
      ':P4 = ' || p_resource_id
     , JTM_HOOK_UTIL_PKG.g_debug_level_full
     , 'jtm_message_log_pkg');
  END IF;

  IF p_pk2_name IS NULL AND p_pk3_name IS NULL AND p_resource_id IS NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value;
  ELSIF p_resource_id IS NULL AND p_pk3_name IS NULL AND p_pk2_name IS NOT NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value;
  ELSIF p_resource_id IS NULL AND p_pk3_name IS NOT NULL AND p_pk2_name IS NOT NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, l_pk3_value;
  ELSIF p_resource_id IS NOT NULL AND p_pk2_name IS NULL AND p_pk3_name IS NULL THEN
   EXECUTE IMMEDIATE l_stmt USING l_pk1_value, p_resource_id;
  ELSIF p_resource_id IS NOT NULL AND p_pk2_name IS NOT NULL AND p_pk3_name IS NULL THEN
   EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, p_resource_id;
  ELSE
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, l_pk3_value, p_resource_id;
  END IF;

  /* Now we have deleted all records we have to decrease the counter of the remaining records*/
  l_stmt := 'UPDATE '||p_acc_table_name||
            ' SET COUNTER = COUNTER - 1'||
	    ', LAST_UPDATE_DATE = SYSDATE'||
	    ', LAST_UPDATED_BY = 1'||
            ' WHERE COUNTER >= 2 AND '||p_pk1_name||' = ' || l_pk1_string;
  IF p_pk2_name IS NOT NULL THEN
    l_stmt := l_stmt ||' AND '||p_pk2_name|| ' = ' || l_pk2_string;
    IF p_pk3_name IS NOT NULL THEN
      l_stmt := l_stmt ||' AND '||p_pk3_name|| ' = ' || l_pk3_string;
    END IF;
  END IF;
  IF p_resource_id IS NOT NULL THEN
    l_stmt := l_stmt ||' AND RESOURCE_ID '|| l_operator ||' :P4';
  END IF;

  IF Get_Debug_Level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_pk1_value
    , p_acc_table_name
    , 'JTM_HOOK_UTIL_PKG.Delete_Acc executing:' || fnd_global.local_chr(10) || l_stmt
    , JTM_HOOK_UTIL_PKG.g_debug_level_full
    , 'jtm_message_log_pkg');
  END IF;

  IF p_pk2_name IS NULL AND p_pk3_name IS NULL AND p_resource_id IS NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value;
  ELSIF p_resource_id IS NULL AND p_pk3_name IS NULL AND p_pk2_name IS NOT NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value;
  ELSIF p_resource_id IS NULL AND p_pk3_name IS NOT NULL AND p_pk2_name IS NOT NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, l_pk3_value;
  ELSIF p_resource_id IS NOT NULL AND p_pk2_name IS NULL AND p_pk3_name IS NULL THEN
   EXECUTE IMMEDIATE l_stmt USING l_pk1_value, p_resource_id;
  ELSIF p_resource_id IS NOT NULL AND p_pk2_name IS NOT NULL AND p_pk3_name IS NULL THEN
   EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, p_resource_id;
  ELSE
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, l_pk3_value, p_resource_id;
  END IF;

EXCEPTION WHEN OTHERS THEN
 IF l_cursor <> 0 THEN
   dbms_sql.close_cursor( l_cursor );
 END IF;
 RAISE;
END Delete_Acc;

/**/
PROCEDURE DELETE_ACC_FOR_RESOURCE
( p_acc_table_name IN VARCHAR2
, p_resource_id IN NUMBER
) IS
 l_stmt    VARCHAR2(1000);
BEGIN
  l_stmt := 'DELETE ' || p_acc_table_name ||' WHERE RESOURCE_ID = :P1';

  IF Get_Debug_Level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , p_acc_table_name
    , 'JTM_HOOK_UTIL_PKG.Delete_Acc_4Res executing:' || fnd_global.local_chr(10) ||
      l_stmt || fnd_global.local_chr(10)||'P1 = '||p_resource_id
    , JTM_HOOK_UTIL_PKG.g_debug_level_full
    , 'jtm_message_log_pkg');
  END IF;

  EXECUTE IMMEDIATE l_stmt USING p_resource_id;

END;

/*** Better it would be to use th Get specific funtion of fnd_profile ***/
FUNCTION Get_Profile_Value( p_name        IN VARCHAR2
                          , p_site_id     IN NUMBER  DEFAULT NULL
	                  , p_appl_id     IN NUMBER  DEFAULT NULL
                          , p_user_id     IN NUMBER  DEFAULT NULL
                          , p_resp_id     IN NUMBER  DEFAULT NULL
	           )
RETURN VARCHAR2
IS

CURSOR c_profile_option_value ( b_profile_option_name VARCHAR2,
                                b_site_level_value    NUMBER,
                                b_appl_level_value    NUMBER,
                                b_resp_level_value    NUMBER,
                                b_user_level_value    NUMBER
                              ) IS
  SELECT val.profile_option_value
    FROM fnd_profile_options       opt,
         fnd_profile_option_values val
   WHERE NVL(opt.start_date_active, SYSDATE) <= SYSDATE
     AND NVL(opt.end_date_active,   SYSDATE) >= SYSDATE
     AND opt.profile_option_name = b_profile_option_name
     AND opt.application_id      = val.application_id
     AND opt.profile_option_id   = val.profile_option_id
     AND ( ( val.level_id    = G_SITE_LEVEL_ID    AND
             val.level_value = b_site_level_value
           ) OR
           ( val.level_id    = G_APPL_LEVEL_ID    AND
             val.level_value = b_appl_level_value
           ) OR
           ( val.level_id    = G_RESP_LEVEL_ID    AND
             val.level_value = b_resp_level_value
           ) OR
           ( val.level_id    = G_USER_LEVEL_ID    AND
             val.level_value = b_user_level_value
           )
         )
         ORDER BY val.level_id DESC;


  r_profile_option_value c_profile_option_value%ROWTYPE;

BEGIN

  OPEN c_profile_option_value ( p_name,
                                p_site_id,
                                p_appl_id,
                                p_resp_id,
                                p_user_id
                              );
  FETCH c_profile_option_value INTO r_profile_option_value;
  CLOSE c_profile_option_value;

  RETURN r_profile_option_value.profile_option_value;

END Get_Profile_Value;

END JTM_HOOK_UTIL_PKG;

/
