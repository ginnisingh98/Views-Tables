--------------------------------------------------------
--  DDL for Package Body PER_DRT_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DRT_UPLOAD_PKG" as
/* $Header: perdrtup.pkb 120.0.12010000.9 2019/10/23 07:20:30 hardeeps noship $ */

FUNCTION get_owner
  (table_name IN varchar2) RETURN varchar2 IS
  l_owner varchar2(128);
  p_table_name varchar2(128);
  l_schema varchar2(30);
BEGIN
  p_table_name := table_name;

  SELECT  oracle_username
  INTO    l_schema
  FROM    system.fnd_oracle_userid
  WHERE   read_only_flag = 'U';

  SELECT  table_owner
  INTO    l_owner
  FROM    dba_synonyms
  WHERE   owner = l_schema
  AND     synonym_name = p_table_name
  AND     table_name IN (p_table_name,p_table_name
                                      || '#');

  RETURN l_owner;
EXCEPTION
  WHEN others THEN
    RETURN NULL;
END get_owner;

procedure LOAD_ROW_DRTT (
  X_PRODUCT_CODE in VARCHAR2,
	X_SCHEMA in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_TABLE_PHASE in VARCHAR2,
  X_RECORD_IDENTIFIER in VARCHAR2,
  X_ENTITY_TYPE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2 default to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')) is

	l_count number(15) := 0;
	l_owner varchar2(50);
	l_schema varchar2(128);

	f_luby number;  -- entity owner in file
	f_ludate date;  -- entity update date in file
	db_luby number; -- entity owner in db
	db_ludate date; -- entity update date in db

	data_migrator_mode varchar2(1);

	cursor c_check_table(p_schema varchar2, p_table_name varchar2) is
				select count(*) from all_objects where owner = p_schema and object_name = p_table_name;

	cursor c_table_exists(p_table_name varchar2) is
				select count(*) from all_objects where owner <> (select oracle_username from system.fnd_oracle_userid where read_only_flag ='U')
				and object_name = p_table_name and object_type = 'TABLE';

 begin

			l_schema := X_SCHEMA;
			open c_check_table(X_SCHEMA,X_TABLE_NAME);
			fetch c_check_table into l_count;
			close c_check_table;

			if l_count = 0 then

					open c_table_exists(X_TABLE_NAME);
					fetch c_table_exists into l_count;
					close c_table_exists;

					if l_count = 0 then
						return;
					else
						l_owner := get_owner(X_TABLE_NAME);
						if l_owner is not null then
						 		l_schema := l_owner;
						else
								return;
						end if;
					end if;
			end if;

      f_luby := fnd_load_util.owner_id(X_OWNER);
      f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD HH24:MI:SS'), sysdate);

	data_migrator_mode := hr_general.g_data_migrator_mode;
	hr_general.g_data_migrator_mode  := 'Y';


	SELECT  last_update_date, last_updated_by
	INTO    db_ludate, db_luby
	FROM    per_drt_tables
	WHERE   table_name = x_table_name
	AND     table_phase = x_table_phase
	AND     record_identifier = x_record_identifier
	AND     product_code = x_product_code
	AND     schema = l_schema
	AND     entity_type = x_entity_type;

	if f_ludate >= db_ludate and db_luby <> -1 then

		 	update PER_DRT_TABLES
		 		set PRODUCT_CODE = X_PRODUCT_CODE,
					SCHEMA = l_schema,
		 			TABLE_NAME = X_TABLE_NAME,
		 			TABLE_PHASE = X_TABLE_PHASE,
		 			RECORD_IDENTIFIER = X_RECORD_IDENTIFIER,
		 			ENTITY_TYPE = X_ENTITY_TYPE,
		 			LAST_UPDATED_BY   = f_luby,
		 			LAST_UPDATE_DATE  = f_ludate,
		 			LAST_UPDATE_LOGIN = 0
		 		where TABLE_NAME = X_TABLE_NAME and TABLE_PHASE = X_TABLE_PHASE
				AND RECORD_IDENTIFIER = X_RECORD_IDENTIFIER;

		 if (sql%notfound) then
		    raise no_data_found;
		 end if;

	end if;

	hr_general.g_data_migrator_mode  := data_migrator_mode;

 exception
   when no_data_found then
   insert into PER_DRT_TABLES(
   TABLE_ID,
   PRODUCT_CODE,
	 SCHEMA,
   TABLE_NAME,
   TABLE_PHASE,
   RECORD_IDENTIFIER,
   ENTITY_TYPE,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN)
   		values (
      PER_DRT_TABLES_S.nextval,
   		X_PRODUCT_CODE,
			l_schema,
   		X_TABLE_NAME,
   		X_TABLE_PHASE,
   		X_RECORD_IDENTIFIER,
   		X_ENTITY_TYPE,
   		f_ludate,
   		f_luby,
   		f_ludate,
   		f_luby,
   		0);

	hr_general.g_data_migrator_mode  := data_migrator_mode;

 end LOAD_ROW_DRTT;

procedure LOAD_ROW_DRTC (
  X_TABLE_NAME in VARCHAR2,
  X_TABLE_PHASE in VARCHAR2,
  X_RECORD_IDENTIFIER in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_PHASE in VARCHAR2,
  X_ATTRIBUTE in VARCHAR2,
  X_FF_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_PARAMETER_1 in VARCHAR2,
  X_PARAMETER_2 in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE_C in VARCHAR2 default to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')) is

  l_table_id number(20);
  l_schema varchar2(240);
  l_count number(15) := 0;


	f_luby number;  -- entity owner in file
	f_ludate date;  -- entity update date in file
	db_luby number; -- entity owner in db
	db_ludate date; -- entity update date in db

	data_migrator_mode varchar2(1);

	cursor c_get_table_id is select table_id,SCHEMA from PER_DRT_TABLES where table_name = X_TABLE_NAME and table_phase = X_TABLE_PHASE
		and record_identifier = X_RECORD_IDENTIFIER;

	cursor c_check_column(p_table_name varchar2, p_column_name varchar2,p_schema varchar2) is
				select count(*) from all_tab_columns where table_name = p_table_name and column_name = p_column_name and owner = p_schema;

begin

	open c_get_table_id;
	fetch c_get_table_id into l_table_id,l_schema;
	close c_get_table_id;

	if l_table_id is null then
		return;
	end if;

			open c_check_column(X_TABLE_NAME,X_COLUMN_NAME,l_schema);
			fetch c_check_column into l_count;
			close c_check_column;

			if l_count = 0 then
				return;
			end if;

      f_luby := fnd_load_util.owner_id(X_OWNER);
      f_ludate := nvl(to_date(X_LAST_UPDATE_DATE_C, 'YYYY/MM/DD HH24:MI:SS'), sysdate);

	data_migrator_mode := hr_general.g_data_migrator_mode;
	hr_general.g_data_migrator_mode  := 'Y';

	SELECT  last_update_date, last_updated_by
	INTO    db_ludate, db_luby
	FROM    PER_DRT_COLUMNS
	WHERE   TABLE_ID = l_table_id
	AND     COLUMN_NAME = X_COLUMN_NAME;

	if f_ludate >= db_ludate and db_luby <> -1 then


		 	update PER_DRT_COLUMNS
		 		set TABLE_ID = l_table_id,
		 			COLUMN_NAME = X_COLUMN_NAME,
		 			COLUMN_PHASE = X_COLUMN_PHASE,
		 			ATTRIBUTE = X_ATTRIBUTE,
		 			FF_TYPE = X_FF_TYPE,
		 			RULE_TYPE = X_RULE_TYPE,
		 			PARAMETER_1 = X_PARAMETER_1,
		 			PARAMETER_2 = X_PARAMETER_2,
		 			COMMENTS = X_COMMENTS,
		 			LAST_UPDATED_BY   = f_luby,
		 			LAST_UPDATE_DATE  = f_ludate,
		 			LAST_UPDATE_LOGIN = 0
		 		where TABLE_ID = l_table_id and COLUMN_NAME = X_COLUMN_NAME;

		 if (sql%notfound) then
		    raise no_data_found;
		 end if;

  end if;

	hr_general.g_data_migrator_mode  := data_migrator_mode;

 exception
   when no_data_found then
   insert into PER_DRT_COLUMNS(
   COLUMN_ID,
   TABLE_ID,
   COLUMN_NAME,
   COLUMN_PHASE,
   ATTRIBUTE,
   FF_TYPE,
   RULE_TYPE,
   PARAMETER_1,
   PARAMETER_2,
   COMMENTS,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN)
   		values (
   		PER_DRT_COLUMNS_S.nextval,
   		l_table_id,
   		X_COLUMN_NAME,
   		X_COLUMN_PHASE,
   		X_ATTRIBUTE,
   		X_FF_TYPE,
   		X_RULE_TYPE,
   		X_PARAMETER_1,
   		X_PARAMETER_2,
   		X_COMMENTS,
   		f_ludate,
   		f_luby,
   		f_ludate,
   		f_luby,
   		0);

	hr_general.g_data_migrator_mode  := data_migrator_mode;

end LOAD_ROW_DRTC;

procedure LOAD_ROW_DRTCC (
  X_TABLE_NAME in VARCHAR2,
  X_TABLE_PHASE in VARCHAR2,
  X_RECORD_IDENTIFIER in VARCHAR2,
  X_COLUMN_NAME_C in VARCHAR2,
  X_FF_NAME in VARCHAR2,
  X_CONTEXT_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_PHASE in VARCHAR2,
  X_ATTRIBUTE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_PARAMETER_1 in VARCHAR2,
  X_PARAMETER_2 in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE_F in VARCHAR2 default to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')) is

  l_table_id number(20);
  l_column_id number(20);
  l_ff_type varchar2(240);
  l_count number(15) := 0;

	f_luby number;  -- entity owner in file
	f_ludate date;  -- entity update date in file
	db_luby number; -- entity owner in db
	db_ludate date; -- entity update date in db

	data_migrator_mode varchar2(1);

	cursor c_get_table_id is select table_id from PER_DRT_TABLES where table_name = X_TABLE_NAME and table_phase = X_TABLE_PHASE
		and record_identifier = X_RECORD_IDENTIFIER;

	cursor c_get_column_id(table_id number) is select column_id,FF_TYPE from PER_DRT_COLUMNS where table_id = l_table_id and COLUMN_NAME = X_COLUMN_NAME_C;


	cursor c_get_ddf_context(p_FLEXFIELD_NAME varchar2, p_CONTEXT_CODE varchar2, p_COLUMN_NAME varchar2) is
					select count(*) from per_drt_dffs where FLEXFIELD_NAME = p_FLEXFIELD_NAME and CONTEXT_CODE = p_CONTEXT_CODE and APPLICATION_COLUMN_NAME = p_COLUMN_NAME;

	cursor c_get_kff_context(p_FLEXFIELD_NAME varchar2, p_CONTEXT_CODE varchar2, p_COLUMN_NAME varchar2) is
					select count(*) from per_drt_kffs where FLEXFIELD_NAME = p_FLEXFIELD_NAME and CONTEXT_CODE = p_CONTEXT_CODE and APPLICATION_COLUMN_NAME = p_COLUMN_NAME;

begin

	open c_get_table_id;
	fetch c_get_table_id into l_table_id;
	close c_get_table_id;

	if l_table_id is null then
		return;
	end if;

	open c_get_column_id(l_table_id);
	fetch c_get_column_id into l_column_id,l_ff_type;
	close c_get_column_id;

	if l_column_id is null then
		return;
	end if;

	if l_ff_type = 'DDF' then

			open c_get_ddf_context(X_FF_NAME,X_CONTEXT_NAME,X_COLUMN_NAME);
			fetch c_get_ddf_context into l_count;
			close c_get_ddf_context;

			if l_count = 0 then
				return;
			end if;

	elsif l_ff_type = 'KFF' then

			open c_get_kff_context(X_FF_NAME,X_CONTEXT_NAME,X_COLUMN_NAME);
			fetch c_get_kff_context into l_count;
			close c_get_kff_context;

			if l_count = 0 then
				return;
			end if;

	end if;

      f_luby := fnd_load_util.owner_id(X_OWNER);
      f_ludate := nvl(to_date(X_LAST_UPDATE_DATE_F, 'YYYY/MM/DD HH24:MI:SS'), sysdate);

	data_migrator_mode := hr_general.g_data_migrator_mode;
	hr_general.g_data_migrator_mode  := 'Y';

	SELECT  last_update_date, last_updated_by
	INTO    db_ludate, db_luby
	FROM    PER_DRT_COL_CONTEXTS
	WHERE   COLUMN_ID = l_column_id
	AND     FF_NAME = X_FF_NAME
  AND     CONTEXT_NAME = X_CONTEXT_NAME;

	if f_ludate >= db_ludate and db_luby <> -1 then


			  update PER_DRT_COL_CONTEXTS
			    set COLUMN_ID = l_column_id,
			      FF_NAME = X_FF_NAME,
			      CONTEXT_NAME = X_CONTEXT_NAME,
			      COLUMN_NAME = X_COLUMN_NAME,
			      COLUMN_PHASE = X_COLUMN_PHASE,
			      ATTRIBUTE = X_ATTRIBUTE,
			      RULE_TYPE = X_RULE_TYPE,
			      PARAMETER_1 = X_PARAMETER_1,
			      PARAMETER_2 = X_PARAMETER_2,
			      COMMENTS = X_COMMENTS,
			      LAST_UPDATED_BY   = f_luby,
			      LAST_UPDATE_DATE  = f_ludate,
			      LAST_UPDATE_LOGIN = 0
			    where COLUMN_ID = l_column_id and FF_NAME = X_FF_NAME and CONTEXT_NAME = X_CONTEXT_NAME;

			 if (sql%notfound) then
			    raise no_data_found;
			 end if;

  end if;

	hr_general.g_data_migrator_mode  := data_migrator_mode;

 exception
   when no_data_found then
   insert into PER_DRT_COL_CONTEXTS(
   FF_COLUMN_ID,
	 COLUMN_ID,
   FF_NAME,
   CONTEXT_NAME,
   COLUMN_NAME,
   COLUMN_PHASE,
   ATTRIBUTE,
   RULE_TYPE,
   PARAMETER_1,
   PARAMETER_2,
   COMMENTS,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN)
      values (
      PER_DRT_COL_CONTEXTS_S.nextval,
			l_column_id,
      X_FF_NAME,
      X_CONTEXT_NAME,
      X_COLUMN_NAME,
      X_COLUMN_PHASE,
      X_ATTRIBUTE,
      X_RULE_TYPE,
      X_PARAMETER_1,
      X_PARAMETER_2,
      X_COMMENTS,
   		f_ludate,
   		f_luby,
   		f_ludate,
   		f_luby,
   		0);

	hr_general.g_data_migrator_mode  := data_migrator_mode;

end LOAD_ROW_DRTCC;


end per_drt_upload_pkg;

/
