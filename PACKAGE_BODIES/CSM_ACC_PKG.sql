--------------------------------------------------------
--  DDL for Package Body CSM_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_ACC_PKG" AS
/* $Header: csmeaccb.pls 120.4 2008/04/22 11:45:05 trajasek ship $*/
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Provides generic procedures to manipulate ACC tables, and
-- mark dirty records for users, in process
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag      09/16/02 Created
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below
CURSOR c_asg_user (c_user_id NUMBER)
IS
  SELECT resource_id
  FROM   ASG_USER
  WHERE  user_id = c_user_id
  AND    Enabled ='Y';


FUNCTION Check_for_owner(p_user_id NUMBER)
RETURN NUMBER;

/***
  Procedure that checks if an ACC record exists for a given resource_id.
  If so, it returns the ACC record's access_id.
  If not, it returns -1.
***/
FUNCTION Get_Acc_Id
 (  p_acc_table_name     in VARCHAR2
  , p_user_id            in NUMBER
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
            ' WHERE USER_ID = :1' ||
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

  CSM_UTIL_PKG.LOG( l_stmt || fnd_global.local_chr(10) ||
      ':1 = ' || p_user_id || fnd_global.local_chr(10) || l_error_msg,
      'CSM_ACC_PKG.GET_ACC_ID',FND_LOG.LEVEL_PROCEDURE);


  IF p_pk2_name IS NULL THEN
    EXECUTE IMMEDIATE l_stmt INTO l_access_id USING p_user_id, l_pk1_value;
  ELSIF p_pk3_name IS NULL then
    EXECUTE IMMEDIATE l_stmt INTO l_access_id USING p_user_id, l_pk1_value, l_pk2_value;
  ELSE
    EXECUTE IMMEDIATE l_stmt INTO l_access_id USING p_user_id, l_pk1_value, l_pk2_value, l_pk3_value;
  END IF;
  /*** record exists -> return access code ***/
  RETURN l_access_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  CSM_UTIL_PKG.LOG( 'No Access_ID found for Statement:' || l_stmt || fnd_global.local_chr(10) ||
      ':1 = ' || p_user_id, 'CSM_ACC_PKG.GET_ACC_ID',FND_LOG.LEVEL_EXCEPTION);
    /*** Record doesn't exist ***/
    RETURN -1;
  WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG( 'Exception occurred in CSM_ACC_PKG.GET_ACC_ID' || sqlerrm, 'CSM_ACC_PKG.GET_ACC_ID',FND_LOG.LEVEL_EXCEPTION);
    /*** Raise any other error ***/
    RAISE;
END Get_Acc_Id;

/***
  Procedure that inserts a record into any ACC table.
***/
PROCEDURE INSERT_ACC
  ( p_publication_item_names in t_publication_item_list
  , p_acc_table_name         in VARCHAR2
  , p_seq_name               in VARCHAR2
  , p_user_id                in NUMBER
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
  l_resource_id    jtf_rs_resource_extns.resource_id%TYPE;
  l_owner_id       NUMBER;
  l_user_id        NUMBER;
BEGIN

  --Function replaces owner if data routed to owner is set
  l_user_id := Check_for_owner(p_user_id);

  /*** insert new ACC record for current resource ***/
  l_access_id := Get_Acc_Id
                 ( p_acc_table_name => p_acc_table_name
                 , p_user_id        => l_user_id
                 , p_pk1_name       => p_pk1_name
                 , p_pk1_num_value  => p_pk1_num_value
                 , p_pk1_char_value => p_pk1_char_value
                 , p_pk1_date_value => p_pk1_date_value
                 , p_pk2_name       => p_pk2_name
                 , p_pk2_num_value  => p_pk2_num_value
                 , p_pk2_char_value => p_pk2_char_value
   	             , p_pk2_date_value => p_pk2_date_value
                 , p_pk3_name       => p_pk3_name
                 , p_pk3_num_value  => p_pk3_num_value
                 , p_pk3_char_value => p_pk3_char_value
   	             , p_pk3_date_value => p_pk3_date_value);

  IF l_access_id <> -1 THEN
    /*Record already exists for this user, increasing the counter*/
    l_stmt := 'UPDATE '||p_acc_table_name||
              ' SET COUNTER = COUNTER + 1'||
	      ', LAST_UPDATE_DATE = SYSDATE '||
	      ', LAST_UPDATED_BY = 1 '||
          ', LAST_UPDATE_LOGIN = 1' ||
              ' WHERE ACCESS_ID = :1'; -- ||l_access_id;



    CSM_UTIL_PKG.LOG( l_stmt, 'CSM_ACC_PKG.INSERT_ACC',FND_LOG.LEVEL_PROCEDURE);

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
              ' CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, COUNTER, USER_ID, ' || p_pk1_name || ') ' ||
              'VALUES ('
              || p_seq_name || '.NEXTVAL, SYSDATE, 1, SYSDATE, 1, 1, 1, :1, ' || l_pk1_string ||
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
                ' CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, COUNTER, USER_ID, ' ||
	 p_pk1_name ||', '|| p_pk2_name || ') ' ||
                'VALUES ('
              || p_seq_name || '.NEXTVAL, SYSDATE, 1, SYSDATE, 1, 1, 1, :1, ' ||
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
                  ' CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, COUNTER, USER_ID, ' ||
                  p_pk1_name ||', '|| p_pk2_name ||', '|| p_pk3_name || ') ' ||
                  'VALUES ('
              || p_seq_name || '.NEXTVAL, SYSDATE, 1, SYSDATE, 1, 1, 1, :1, ' ||
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

     CSM_UTIL_PKG.LOG( 'executing:' || fnd_global.local_chr(10) ||
           l_stmt || fnd_global.local_chr(10) || ':1 = ' || l_user_id
           || fnd_global.local_chr(10) || l_error_msg, 'CSM_ACC_PKG.INSERT_ACC',FND_LOG.LEVEL_PROCEDURE);


    /*We have at least one PK so get the value*/
    IF l_pk2_value IS NULL THEN
      /* Only one PK available */
      EXECUTE IMMEDIATE l_stmt USING l_user_id, l_pk1_value  RETURNING INTO l_access_id;
    ELSIF l_pk3_value IS NULL THEN
      /*Two PK's */
      EXECUTE IMMEDIATE l_stmt USING l_user_id, l_pk1_value, l_pk2_value  RETURNING INTO l_access_id;
    ELSE
      /* Three PK's */
      EXECUTE IMMEDIATE l_stmt USING l_user_id, l_pk1_value, l_pk2_value, l_pk3_value
      RETURNING INTO l_access_id;
    END IF;
    -- insert record in outqueue ASG call here *****************************************
    --get the resource id
    OPEN  c_asg_user (l_user_id);
    FETCH c_asg_user  INTO l_resource_id;
    CLOSE c_asg_user;

    IF l_resource_id IS NOT NULL THEN --do mark diry only for valid MFS user
      FOR i IN 1 .. p_publication_item_names.LAST LOOP
        l_rc := asg_download.markDirty(p_publication_item_names(i), l_access_id, l_resource_id, 'I', sysdate );
      END LOOP;
    END IF;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG( 'Exception occurred in CSM_ACC_PKG.INSERT_ACC' || sqlerrm, 'CSM_ACC_PKG.INSERT_ACC',FND_LOG.LEVEL_EXCEPTION);
    /*** Raise any other error ***/
    RAISE;

END Insert_Acc;


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
  ,p_user_id                in NUMBER   DEFAULT NULL
  ,p_operator               in VARCHAR2 DEFAULT '='
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
  l_resource_id    jtf_rs_resource_extns.resource_id%TYPE;
  l_user_id            NUMBER;
BEGIN
  --Function replaces owner if data routed to owner is set
  l_user_id := Check_for_owner(p_user_id);

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
  l_stmt := 'SELECT USER_ID, ACCESS_ID FROM ' || p_acc_table_name ||
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

  /*** was user_id provided? ***/
  IF l_user_id IS NOT NULL THEN
    /*** yes -> add p_operator filter on mobile_user_id to WHERE clause ***/
    l_stmt := l_stmt || ' AND USER_ID ' || p_operator || ' :P4 ';
    dbms_sql.parse( l_cursor, l_stmt, dbms_sql.v7);
    dbms_sql.bind_variable( l_cursor, 'P4', l_user_id );
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


  CSM_UTIL_PKG.LOG( 'executing:' || l_stmt || fnd_global.local_chr(10) ||
      ':P1 = ' || l_pk1_value || fnd_global.local_chr(10) ||
      ':P2 = ' || l_pk2_value || fnd_global.local_chr(10) ||
      ':P3 = ' || l_pk3_value || fnd_global.local_chr(10) ||
      ':P4 = ' || l_user_id, 'CSM_ACC_PKG.DELETE_ACC',FND_LOG.LEVEL_PROCEDURE);


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
      --get the resource id
    OPEN  c_asg_user (l_tab_mobile_user_id(i));
    FETCH c_asg_user  INTO l_resource_id;
    CLOSE c_asg_user;

      IF l_resource_id IS NOT NULL THEN --do mark diry only for valid MFS user
        FOR j IN 1 .. p_publication_item_names.LAST LOOP
          l_rc := asg_download.markDirty( p_publication_item_names(j), l_tab_access_id(i)
                                      , l_resource_id, 'D', sysdate );
        END LOOP;
      END IF;
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
  IF l_user_id IS NOT NULL THEN
    l_stmt := l_stmt ||' AND USER_ID '||p_operator||' :P4';
  END IF;


  IF p_pk2_name IS NULL AND p_pk3_name IS NULL AND l_user_id IS NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value;
  ELSIF l_user_id IS NULL AND p_pk3_name IS NULL AND p_pk2_name IS NOT NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value;
  ELSIF l_user_id IS NULL AND p_pk3_name IS NOT NULL AND p_pk2_name IS NOT NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, l_pk3_value;
  ELSIF l_user_id IS NOT NULL AND p_pk2_name IS NULL AND p_pk3_name IS NULL THEN
   EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_user_id;
  ELSIF l_user_id IS NOT NULL AND p_pk2_name IS NOT NULL AND p_pk3_name IS NULL THEN
   EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, l_user_id;
  ELSE
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, l_pk3_value, l_user_id;
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
  IF l_user_id IS NOT NULL THEN
    l_stmt := l_stmt ||' AND USER_ID '|| p_operator ||' :P4';
  END IF;


  IF p_pk2_name IS NULL AND p_pk3_name IS NULL AND l_user_id IS NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value;
  ELSIF l_user_id IS NULL AND p_pk3_name IS NULL AND p_pk2_name IS NOT NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value;
  ELSIF l_user_id IS NULL AND p_pk3_name IS NOT NULL AND p_pk2_name IS NOT NULL THEN
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, l_pk3_value;
  ELSIF l_user_id IS NOT NULL AND p_pk2_name IS NULL AND p_pk3_name IS NULL THEN
   EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_user_id;
  ELSIF l_user_id IS NOT NULL AND p_pk2_name IS NOT NULL AND p_pk3_name IS NULL THEN
   EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, l_user_id;
  ELSE
    EXECUTE IMMEDIATE l_stmt USING l_pk1_value, l_pk2_value, l_pk3_value, l_user_id;
  END IF;

EXCEPTION WHEN OTHERS THEN
 IF l_cursor <> 0 THEN
   dbms_sql.close_cursor( l_cursor );
 END IF;
  CSM_UTIL_PKG.LOG( 'Exception occurred in CSM_ACC_PKG.DELETE_ACC' || sqlerrm, 'CSM_ACC_PKG.DELETE_ACC',FND_LOG.LEVEL_EXCEPTION);
 /*** Raise any other error ***/
 RAISE;
END Delete_Acc;

/*** Procedure that re-sends a record with given acc_id to the mobile ***/
PROCEDURE Update_Acc
 ( p_publication_item_names in t_publication_item_list
  ,p_acc_table_name         in VARCHAR2
  ,p_user_id            in NUMBER
  ,p_access_id              in NUMBER
 )
IS
 l_rc             BOOLEAN;
 l_resource_id    jtf_rs_resource_extns.resource_id%TYPE;
 l_user_id        NUMBER;
BEGIN
  --Function replaces owner if data routed to owner is set
  l_user_id := Check_for_owner(p_user_id);

 --get the resource id
    OPEN  c_asg_user (l_user_id);
    FETCH c_asg_user  INTO l_resource_id;
    CLOSE c_asg_user;

  IF l_resource_id IS NOT NULL THEN --do mark diry only for valid MFS user
     --call update outqueue ASG call *****************************************
    FOR i IN 1 .. p_publication_item_names.LAST LOOP
      l_rc := asg_download.markDirty(p_publication_item_names(i), p_access_id, l_resource_id, 'U', sysdate );
    END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG( 'Exception occurred in CSM_ACC_PKG.UPDATE_ACC' || sqlerrm, 'CSM_ACC_PKG.UPDATE_ACC',FND_LOG.LEVEL_EXCEPTION);
    /*** Raise any other error ***/
    RAISE;

END Update_Acc;

FUNCTION Check_for_owner(p_user_id NUMBER)
RETURN NUMBER
IS
l_user_id   NUMBER;
l_owner_id  NUMBER;

BEGIN

  /*checking if data has to be processed for the owner*/
  IF csm_profile_pkg.Get_Route_Data_To_Owner ='Y' THEN
    --get owner
    l_owner_id := csm_util_pkg.get_owner(p_user_id);
    IF l_owner_id > -1 THEN --If the owner is valid
      l_user_id := l_owner_id;
    ELSE  --if owner is invalid then use user_id
      l_user_id := p_user_id;
    END IF;
  ELSE --if the profile is not set then process for the user
    l_user_id := p_user_id;
  END IF;
  RETURN l_user_id;

END Check_for_owner;

END;

/
