--------------------------------------------------------
--  DDL for Package Body EDW_SOURCE_INSTANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SOURCE_INSTANCES_PKG" AS
/* $Header: EDWSRCIB.pls 115.19 2003/11/19 09:19:36 smulye ship $ */



FUNCTION CHECK_REMOTE_ENTRY(p_dblink IN varchar2) return boolean
IS
dummy number:= 0;
l_dummy number;
cid     number;
l_bool boolean := true;

BEGIN

	  /* check if the source already has a row */
        /* if so, records may
           already collected with that instance_fk etc
	   so, throw a warning to the user  */


	/* return false if entry exists in remote db
	   return true if entry does not exist */

        begin
	edw_misc_util.globalNamesOff;
        cid := DBMS_SQL.open_cursor;
        DBMS_SQL.PARSE(cid, 'SELECT count(*) FROM edw_local_instance@'||P_DBLINK, dbms_sql.native);
        dbms_sql.define_column(cid, 1, dummy);
        l_dummy:=dbms_sql.execute(cid);
        if dbms_sql.fetch_rows(cid)<>0 then
                dbms_sql.column_value(cid, 1, dummy);
                if (dummy > 0) then /* throw error message */
                   /*fnd_message.set_name('BIS', 'EDW_SOURCE_ALREADY_PRESENT');
                   fnd_message.set_token('NAME',
                        X_WAREHOUSE_TO_INSTANCE_LINK, FALSE);
                   app_exception.raise_exception; */
		   l_bool := false;
		else
		   l_bool := true;
                end if;
        end if;

	return l_bool;

END ;

END CHECK_REMOTE_ENTRY;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INSTANCE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_WAREHOUSE_TO_INSTANCE_LINK in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
dummy number:= 0;
l_dummy number;
cid	number;
  cursor C is select ROWID from EDW_SOURCE_INSTANCES
    where INSTANCE_CODE = X_INSTANCE_CODE
    ;

begin
	begin

  insert into EDW_SOURCE_INSTANCES (
    INSTANCE_CODE,
    ENABLED_FLAG,
    WAREHOUSE_TO_INSTANCE_LINK,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_INSTANCE_CODE,
    X_ENABLED_FLAG,
    X_WAREHOUSE_TO_INSTANCE_LINK,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into EDW_SOURCE_INSTANCES_TL (
    INSTANCE_CODE,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_INSTANCE_CODE,
    X_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from EDW_SOURCE_INSTANCES_TL T
    where T.INSTANCE_CODE = X_INSTANCE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
Exception when others then
	x_rowid:=null;
	raise;
end;
end INSERT_ROW;

procedure LOCK_ROW (
  X_INSTANCE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_WAREHOUSE_TO_INSTANCE_LINK in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      WAREHOUSE_TO_INSTANCE_LINK,
      INSTANCE_CODE
    from EDW_SOURCE_INSTANCES
    where INSTANCE_CODE = X_INSTANCE_CODE
    for update of INSTANCE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from EDW_SOURCE_INSTANCES_TL
    where INSTANCE_CODE = X_INSTANCE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INSTANCE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    /*((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null)
           AND (X_ENABLED_FLAG is null)))
      AND*/ ((recinfo.WAREHOUSE_TO_INSTANCE_LINK = X_WAREHOUSE_TO_INSTANCE_LINK)
           OR ((recinfo.WAREHOUSE_TO_INSTANCE_LINK is null)
           AND (X_WAREHOUSE_TO_INSTANCE_LINK is null)))
      AND ((recinfo.INSTANCE_CODE = X_INSTANCE_CODE)
           OR ((recinfo.INSTANCE_CODE is null)
           AND (X_INSTANCE_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_INSTANCE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_WAREHOUSE_TO_INSTANCE_LINK in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update EDW_SOURCE_INSTANCES set
    ENABLED_FLAG = X_ENABLED_FLAG,
    WAREHOUSE_TO_INSTANCE_LINK = X_WAREHOUSE_TO_INSTANCE_LINK,
    INSTANCE_CODE = X_INSTANCE_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INSTANCE_CODE = X_INSTANCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update EDW_SOURCE_INSTANCES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INSTANCE_CODE = X_INSTANCE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INSTANCE_CODE in VARCHAR2
) is
begin
  delete from EDW_SOURCE_INSTANCES_TL
  where INSTANCE_CODE = X_INSTANCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from EDW_SOURCE_INSTANCES
  where INSTANCE_CODE = X_INSTANCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE is
 v_sql_stmt  VARCHAR2(1000);
 v_db_link   VARCHAR2(240);

 cursor db_links  IS
   select WAREHOUSE_TO_INSTANCE_LINK
   from   EDW_SOURCE_INSTANCES;

begin
  delete from EDW_SOURCE_INSTANCES_TL T
  where not exists
    (select NULL
    from EDW_SOURCE_INSTANCES B
    where B.INSTANCE_CODE = T.INSTANCE_CODE
    );

  update EDW_SOURCE_INSTANCES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from EDW_SOURCE_INSTANCES_TL B
    where B.INSTANCE_CODE = T.INSTANCE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INSTANCE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.INSTANCE_CODE,
      SUBT.LANGUAGE
    from EDW_SOURCE_INSTANCES_TL SUBB, EDW_SOURCE_INSTANCES_TL SUBT
    where SUBB.INSTANCE_CODE = SUBT.INSTANCE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into EDW_SOURCE_INSTANCES_TL (
    INSTANCE_CODE,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.INSTANCE_CODE,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from EDW_SOURCE_INSTANCES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EDW_SOURCE_INSTANCES_TL T
    where T.INSTANCE_CODE = B.INSTANCE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

---------------------------------------------------------------------
-- After this, copy records to EDW_LOCAL_INSTANCE_TL at each instance.
-- This is for the fix of bug 2125924
---------------------------------------------------------------------

  edw_misc_util.globalNamesOff;

  FOR db_link_to_local IN db_links LOOP
    v_db_link := db_link_to_local.WAREHOUSE_TO_INSTANCE_LINK;
    v_sql_stmt := 'delete from EDW_LOCAL_INSTANCE_TL@' || v_db_link;

    BEGIN
      EXECUTE IMMEDIATE v_sql_stmt;

      v_sql_stmt := 'insert into EDW_LOCAL_INSTANCE_TL@' || v_db_link ||
                ' select * from EDW_SOURCE_INSTANCES_TL '  ||
                ' where INSTANCE_CODE = ' ||
                  '(select distinct INSTANCE_CODE ' ||
                  ' from  EDW_SOURCE_INSTANCES '    ||
                  ' where WAREHOUSE_TO_INSTANCE_LINK = '''||v_db_link||''')';

      EXECUTE IMMEDIATE v_sql_stmt;
    EXCEPTION /* this should not happen */
      WHEN OTHERS THEN NULL;
    END;
  END LOOP;


  -- we also need to consider the case that no db_link pointing to warehouse itself,
  -- so we repeat the above for EDW_LOCAL_INSTANCE_TL in the warehouse.

    BEGIN
      delete from EDW_LOCAL_INSTANCE_TL;

      insert into EDW_LOCAL_INSTANCE_TL(
	    INSTANCE_CODE,
	    NAME,
	    DESCRIPTION,
	    CREATION_DATE,
	    CREATED_BY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATE_LOGIN,
	    LAST_UPDATED_BY,
	    LANGUAGE,
	    SOURCE_LANG)
        select
	    INSTANCE_CODE,
	    NAME,
	    DESCRIPTION,
	    CREATION_DATE,
	    CREATED_BY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATE_LOGIN,
	    LAST_UPDATED_BY,
	    LANGUAGE,
	    SOURCE_LANG
	 from EDW_SOURCE_INSTANCES_TL
         where INSTANCE_CODE =
               (select distinct INSTANCE_CODE from EDW_LOCAL_INSTANCE);

    EXCEPTION /* this should not happen */
      WHEN OTHERS THEN NULL;
    END;

-------------------------------------------------------------------------

end ADD_LANGUAGE;

procedure CHECK_UNIQUE (
  X_ROWID in VARCHAR2,
  X_INSTANCE_CODE in VARCHAR2
) IS
dummy NUMBER;
BEGIN
  SELECT COUNT(1) INTO dummy
  FROM EDW_SOURCE_INSTANCES_VL
  WHERE INSTANCE_CODE = X_INSTANCE_CODE
  AND ((X_ROWID IS NULL) OR (ROW_ID <> X_ROWID));

  IF (dummy >= 1) THEN
    fnd_message.set_name('BIS', 'EDW_DUPLICATE_INSTANCE');
    fnd_message.set_token('INSTANCE_CODE',
      x_instance_code, FALSE);
    app_exception.raise_exception;
  END IF;

END CHECK_UNIQUE;

procedure CHECK_REFERENCES (
  X_INSTANCE_CODE in VARCHAR2
) IS
dummy NUMBER;
BEGIN
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
  (SELECT 1 FROM edw_push_detail_log
   WHERE INSTANCE_CODE = X_INSTANCE_CODE);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('BIS', 'EDW_INSTANCE_IN_USE');
    app_exception.raise_exception;
END CHECK_REFERENCES;


procedure CHECK_UNIQUE_NAME (
  X_ROWID in VARCHAR2,
  X_INSTANCE_NAME in VARCHAR2
) IS
dummy NUMBER;
BEGIN
 /* will fail cos the rowid is for edw_source_instances and NOT tl */
 SELECT count(*) INTO dummy
  FROM EDW_SOURCE_INSTANCES_VL
  WHERE NAME = X_INSTANCE_NAME
  AND ((X_ROWID IS NULL) OR (ROW_ID <> X_ROWID));



  IF (dummy >= 1) THEN
    fnd_message.set_name('BIS', 'EDW_DUPLICATE_INSTANCE_NAME');
    fnd_message.set_token('INSTANCE_CODE', X_ROWID, FALSE);
      --x_instance_name, FALSE);
    app_exception.raise_exception;
  END IF;
END CHECK_UNIQUE_NAME;

procedure CHECK_UNIQUE_DBLINK (
  X_ROWID in VARCHAR2,
  X_DBLINK in VARCHAR2
) IS
dummy NUMBER;
BEGIN
  SELECT COUNT(1) INTO dummy
  FROM EDW_SOURCE_INSTANCES_VL
  WHERE WAREHOUSE_TO_INSTANCE_LINK = X_DBLINK
  AND ((X_ROWID IS NULL) OR (ROW_ID <> X_ROWID));

  IF (dummy >= 1) THEN
    fnd_message.set_name('BIS', 'EDW_DBLINK_ALREADY_USED');
    fnd_message.set_token('DBLINK',
      x_dblink, FALSE);
    app_exception.raise_exception;
  END IF;
END CHECK_UNIQUE_DBLINK;


procedure INSERT_ROW_REMOTE (
  X_INSTANCE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_WAREHOUSE_TO_INSTANCE_LINK in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) IS
v_cursor_id NUMBER;
v_ret_code NUMBER;
v_sql_stmt VARCHAR2(1000);
v_source_lang VARCHAR2(40);
cid NUMBER;
remote_date date;

BEGIN
	edw_misc_util.globalNamesOff;

	cid := DBMS_SQL.open_cursor;
        DBMS_SQL.PARSE(cid, 'SELECT sysdate FROM dual@'||X_WAREHOUSE_TO_INSTANCE_LINK, dbms_sql.native);
        dbms_sql.define_column(cid, 1, remote_date);
        v_ret_code:=dbms_sql.execute(cid);
        if dbms_sql.fetch_rows(cid)<>0 then
                dbms_sql.column_value(cid, 1, remote_date);
        end if;
	DBMS_SQL.close_cursor(cid);

	delete_row_remote(x_instance_code, X_WAREHOUSE_TO_INSTANCE_LINK);

  v_sql_stmt := 'INSERT INTO edw_local_instance@' ||
                x_warehouse_to_instance_link ||
    '(instance_code, enabled_flag, creation_date, created_by,
    last_update_date, last_updated_by, last_update_login,
    warehouse_to_instance_link)
    values (:x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8)';
  v_cursor_id := dbms_sql.open_cursor;
  dbms_sql.parse(v_cursor_id, v_sql_stmt, DBMS_SQL.V7);
  dbms_sql.bind_variable(v_cursor_id, ':x1', x_instance_code);
  dbms_sql.bind_variable(v_cursor_id, ':x2', x_enabled_flag);
  dbms_sql.bind_variable(v_cursor_id, ':x3', remote_date);
  dbms_sql.bind_variable(v_cursor_id, ':x4', x_created_by);
  dbms_sql.bind_variable(v_cursor_id, ':x5', remote_date);
  dbms_sql.bind_variable(v_cursor_id, ':x6', x_last_updated_by);
  dbms_sql.bind_variable(v_cursor_id, ':x7', x_last_update_login);
  dbms_sql.bind_variable(v_cursor_id, ':x8', x_warehouse_to_instance_link);
  v_ret_code := dbms_sql.execute(v_cursor_id);
  dbms_sql.close_cursor(v_cursor_id);

  SELECT userenv('LANG') INTO v_source_lang
  FROM dual;

  v_sql_stmt := 'insert into EDW_LOCAL_INSTANCE_TL@' ||
    x_warehouse_to_instance_link ||
    '(INSTANCE_CODE, NAME, DESCRIPTION, CREATION_DATE, CREATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN, LAST_UPDATED_BY, LANGUAGE,
    SOURCE_LANG) select :x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8,
    L.LANGUAGE_CODE, :x9 from FND_LANGUAGES@' ||
    x_warehouse_to_instance_link ||
  ' L where L.INSTALLED_FLAG in (''I'', ''B'')
  and not exists (select NULL from EDW_LOCAL_INSTANCE_TL@' ||
    x_warehouse_to_instance_link ||
    ' T where T.INSTANCE_CODE = :x1 and T.LANGUAGE = L.LANGUAGE_CODE)';

  v_cursor_id := dbms_sql.open_cursor;
  dbms_sql.parse(v_cursor_id, v_sql_stmt, DBMS_SQL.V7);
  dbms_sql.bind_variable(v_cursor_id, ':x1', x_instance_code);
  dbms_sql.bind_variable(v_cursor_id, ':x2', x_name);
  dbms_sql.bind_variable(v_cursor_id, ':x3', x_description);
  dbms_sql.bind_variable(v_cursor_id, ':x4', remote_date);
  dbms_sql.bind_variable(v_cursor_id, ':x5', x_created_by);
  dbms_sql.bind_variable(v_cursor_id, ':x6', remote_date);
  dbms_sql.bind_variable(v_cursor_id, ':x7', x_last_updated_by);
  dbms_sql.bind_variable(v_cursor_id, ':x8', x_last_update_login);
  dbms_sql.bind_variable(v_cursor_id, ':x9', v_source_lang);
  v_ret_code := dbms_sql.execute(v_cursor_id);
  dbms_sql.close_cursor(v_cursor_id);

EXCEPTION
  WHEN e_too_many_local_instances THEN
    fnd_message.set_name('BIS', 'EDW_TOO_MANY_LOCAL_INSTANCES');
    app_exception.raise_exception;
  WHEN others THEN
	IF (X_ENABLED_FLAG = 'N') THEN
		null;
	ELSE
		app_exception.raise_exception;
	END IF;
END INSERT_ROW_REMOTE;

procedure DELETE_ROW_REMOTE (
  X_INSTANCE_CODE in VARCHAR2,
  X_WAREHOUSE_TO_INSTANCE_LINK in VARCHAR2
) IS
v_cursor_id NUMBER;
v_ret_code NUMBER;
v_sql_stmt VARCHAR2(240);

BEGIN

	edw_misc_util.globalNamesOff;
  v_sql_stmt := 'delete from EDW_LOCAL_INSTANCE@' ||
  x_warehouse_to_instance_link;
  v_cursor_id := dbms_sql.open_cursor;
  dbms_sql.parse(v_cursor_id, v_sql_stmt, DBMS_SQL.V7);
  --dbms_sql.bind_variable(v_cursor_id, ':x1', x_instance_code);
  v_ret_code := dbms_sql.execute(v_cursor_id);
  dbms_sql.close_cursor(v_cursor_id);

  v_sql_stmt := 'delete from EDW_LOCAL_INSTANCE_TL@' ||
  x_warehouse_to_instance_link ;
  v_cursor_id := dbms_sql.open_cursor;
  dbms_sql.parse(v_cursor_id, v_sql_stmt, DBMS_SQL.V7);
  --dbms_sql.bind_variable(v_cursor_id, ':x1', x_instance_code);
  v_ret_code := dbms_sql.execute(v_cursor_id);
  dbms_sql.close_cursor(v_cursor_id);
END DELETE_ROW_REMOTE;

END EDW_SOURCE_INSTANCES_PKG;

/
