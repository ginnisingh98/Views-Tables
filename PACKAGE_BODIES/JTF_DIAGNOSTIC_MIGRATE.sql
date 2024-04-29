--------------------------------------------------------
--  DDL for Package Body JTF_DIAGNOSTIC_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DIAGNOSTIC_MIGRATE" AS
/* $Header: jtfdiagmigrate_b.pls 115.1 2003/01/04 00:54:27 skhemani noship $ */

  ------------------------------------------------------------
  -- Begin procedure INSERT_PLACEHOLDER_DATE
  ------------------------------------------------------------

  procedure INSERT_PLACEHOLDER_DATE is

    v_number	number := 0;
    v_date	date   := add_months(sysdate, -480);

    BEGIN
    	select count(*) into v_number from jtf_diagnostic_prereq where
    	sourceappid = 'migrate_date_flag' and sourceid = 'migrate_date_flag'
    	and prereqid = 'migrate_date_flag';

    	if v_number = 0 then
		insert into jtf_diagnostic_prereq
		(SEQUENCE, SOURCEID, PREREQID,
		SOURCEAPPID, TYPE, OBJECT_VERSION_NUMBER,
		CREATED_BY, LAST_UPDATE_DATE,
		LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATION_DATE)
		values
		(JTF_DIAGNOSTIC_PREREQ_S.NEXTVAL, 'migrate_date_flag',
		'migrate_date_flag', 'migrate_date_flag', -1,
		-1, -1,v_date , -1,
		NULL, v_date);
    	end if;


    END INSERT_PLACEHOLDER_DATE;

  ------------------------------------------------------------
  -- Begin procedure UPDATE_MIGRATION_DATE
  ------------------------------------------------------------

  procedure UPDATE_MIGRATION_DATE is

    BEGIN
    	update jtf_diagnostic_prereq
    	set last_update_date = SYSDATE
    	where sourceid='migrate_date_flag' and
    	prereqid='migrate_date_flag' and
    	sourceappid='migrate_date_flag';
    END UPDATE_MIGRATION_DATE;

  ------------------------------------------------------------
  -- Begin procedure LOCK_MIGRATION_DATE
  ------------------------------------------------------------

  procedure LOCK_MIGRATION_DATE is

    v_last_update_date 	date;

    BEGIN
	select last_update_date into v_last_update_date
	from jtf_diagnostic_prereq
    	where sourceid='migrate_date_flag' and
    	prereqid='migrate_date_flag' and
    	sourceappid='migrate_date_flag' for update of last_update_date;
    END LOCK_MIGRATION_DATE;


  ------------------------------------------------------------
  -- Begin procedure MIGRATE_DB_DIAGNOSTIC_DATA
  ------------------------------------------------------------

  PROCEDURE MIGRATE_DB_DIAGNOSTIC_DATA IS

  BEGIN
  	MIGRATE_APPS;
  END MIGRATE_DB_DIAGNOSTIC_DATA;


  ------------------------------------------------------------
  -- Begin procedure MIGRATE_APPS
  ------------------------------------------------------------

  PROCEDURE MIGRATE_APPS IS

    v_last_migrate_date	date 	:= SYSDATE;
    v_count		number	:= 0;

    CURSOR applist IS
	select distinct c.application_id, c.application_short_name,
	a.created_by, a.last_updated_by, a.last_update_date,
	a.object_version_number from jtf_perz_data a,
	jtf_perz_profile b,  fnd_application c where a.profile_id = b.profile_id
	and b.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
	and a.perz_data_type = 'JTF' and a.perz_data_name
	like 'TESTHARNESS%GRPCOUNT' and a.application_id = c.application_id;

  BEGIN

  	select last_update_date into v_last_migrate_date from
  	jtf_diagnostic_prereq where sourceid = 'migrate_date_flag'
  	and sourceappid = 'migrate_date_flag'
  	and prereqid = 'migrate_date_flag';

  	for x in applist
  		loop
  			-- check if this already exists.
  			-- if not insert, else update
  			select count(*) into v_count from jtf_diagnostic_app
  			where appid = x.application_short_name;

			if v_last_migrate_date < x.last_update_date or v_count = 0 then

				if v_count = 0 then

  						insert into jtf_diagnostic_app(
  						sequence, appID, OBJECT_VERSION_NUMBER, CREATED_BY,
  						LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
	  					CREATION_DATE) values(
  						JTF_DIAGNOSTIC_APP_S.nextval,
  						x.application_short_name, x.object_version_number,
  						x.CREATED_BY, x.LAST_UPDATE_DATE, x.created_by,
  						null, x.LAST_UPDATE_DATE);

	  			else
	  					update jtf_diagnostic_app set
  						last_update_date = x.last_update_date,
  						LAST_UPDATED_BY = x.LAST_UPDATED_BY,
  						OBJECT_VERSION_NUMBER = x.OBJECT_VERSION_NUMBER
  						where appid = x.application_short_name;

  				end if;

  			end if;


  			-- insert or update prereqs
  			MIGRATE_APP_PREREQS(x.application_short_name,
  							x.application_id);

			-- Insert or update groups
			MIGRATE_APP_GROUPS(x.application_short_name,
  							x.application_id);


  		end loop;
  END MIGRATE_APPS;


  ------------------------------------------------------------
  -- Begin procedure MIGRATE_APP_PREREQS
  ------------------------------------------------------------

  PROCEDURE MIGRATE_APP_PREREQS(P_ASN IN VARCHAR2, P_APP_ID IN NUMBER) IS

    v_last_migrate_date		date 	:= SYSDATE;
    v_count			NUMBER 	:= 0;

    CURSOR PREREQLIST IS
    	select b.attribute_value, b.created_by,
	b.last_updated_by, b.last_update_date, a.object_version_number
	from jtf_perz_data a , jtf_perz_data_attrib b, jtf_perz_profile c
	where a.perz_data_id = b.perz_data_id
	and  a.profile_id = c.profile_id
	and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
	and  a.application_id= P_APP_ID
	and  a.perz_data_name = 'TESTHARNESS.' || P_ASN || '.PREREQ';

  BEGIN
  	select last_update_date into v_last_migrate_date from
  	jtf_diagnostic_prereq where sourceid = 'migrate_date_flag'
  	and sourceappid = 'migrate_date_flag'
  	and prereqid = 'migrate_date_flag';

  	FOR X IN PREREQLIST LOOP

		-- check if this PREREQ already exists.
  		-- if not insert, else update
  		select count(*) into v_count from jtf_diagnostic_prereq
  		where sourceid = p_asn and sourceappid = p_asn
  		and prereqid = x.attribute_value;

		if v_last_migrate_date < x.last_update_date or v_count = 0 then

			if v_count = 0 then

				-- insert the prereq

				insert into jtf_diagnostic_prereq(
				SEQUENCE, SOURCEID, PREREQID,
				SOURCEAPPID, TYPE, OBJECT_VERSION_NUMBER,
				CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN, CREATION_DATE)
				values(
				JTF_DIAGNOSTIC_PREREQ_S.nextval, p_asn, x.attribute_value,
				p_asn, 1, x.object_version_number,
				x.created_by, x.last_update_date, x.created_by,
				NULL, x.LAST_UPDATE_DATE);

			else
				-- update the prereq

				update jtf_diagnostic_prereq set
				last_update_date = x.last_update_date,
				LAST_UPDATED_BY = x.LAST_UPDATED_BY,
				OBJECT_VERSION_NUMBER = x.OBJECT_VERSION_NUMBER
				where sourceappid = p_asn and
				prereqid = x.attribute_value
				and sourceid = p_asn;

			end if;

		end if;

  	END LOOP;

  END MIGRATE_APP_PREREQS;


  ------------------------------------------------------------
  -- Begin procedure MIGRATE_APP_GROUPS
  ------------------------------------------------------------

  PROCEDURE MIGRATE_APP_GROUPS(P_ASN IN VARCHAR2, P_APP_ID IN NUMBER) IS

    v_count			number  := 0;
    v_group_count		number	:= 0;

  BEGIN

       	select distinct to_number(b.attribute_value) into v_group_count
       	from jtf_perz_data a , jtf_perz_data_attrib b, jtf_perz_profile c
	where a.perz_data_id = b.perz_data_id
	and  a.profile_id = c.profile_id
	and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
	and  a.application_id= P_APP_ID
	and  a.perz_data_name = 'TESTHARNESS.' || P_ASN || '.GRPCOUNT';

	if v_group_count > 0 then
		for v_count in 1..v_group_count loop
			MIGRATE_APP_GROUPS(P_ASN, P_APP_ID, v_count);
		end loop;
	end if;

	EXCEPTION
		-- basically do nothing when no data found or any
		-- other error for getting group count for an application

		WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
			v_group_count := 0;
		WHEN OTHERS THEN
			v_group_count := 0;

  END MIGRATE_APP_GROUPS;


  ------------------------------------------------------------
  -- Begin procedure MIGRATE_APP_GROUPS
  ------------------------------------------------------------

  PROCEDURE MIGRATE_APP_GROUPS(
  				P_ASN IN VARCHAR2,
  				P_APP_ID IN NUMBER,
  				P_GRPCOUNT IN NUMBER) IS

  v_last_migrate_date		date 	:= SYSDATE;
  v_count			NUMBER 	:= 0;
  v_temp			NUMBER 	:= 0;


  cursor grplist is
    	select b.attribute_value, b.created_by,
	b.last_updated_by, b.last_update_date, a.object_version_number
	from jtf_perz_data a , jtf_perz_data_attrib b, jtf_perz_profile c
	where a.perz_data_id = b.perz_data_id
	and  a.profile_id = c.profile_id
	and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
	and  a.application_id = P_APP_ID
	and  a.perz_data_name like 'TESTHARNESS.' || P_ASN || '.GROUP.'|| p_grpcount ||'.NAME';
  BEGIN

    	IF P_GRPCOUNT > 0 THEN

	  	select last_update_date into v_last_migrate_date from
  		jtf_diagnostic_prereq where sourceid = 'migrate_date_flag'
  		and sourceappid = 'migrate_date_flag'
  		and prereqid = 'migrate_date_flag';

		FOR X IN grplist LOOP

			-- check if this already exists.
  			-- if not insert, else update
  			select count(*) into v_count from jtf_diagnostic_group
  			where appid = P_ASN
  			and groupname = x.attribute_value;

  			if v_last_migrate_date < x.last_update_date or v_count = 0 then

				-- v_temp := grplist%ROWCOUNT;

			  	select MAX(ordernumber) into v_temp
  				from jtf_diagnostic_group where appid = p_asn;

  				if sql%notfound or v_temp = 0 then
  					v_temp := 1;
  				else v_temp := v_temp + 1;
  				end if;

  				if v_count = 0 then

  					-- making sure that the rowcount is not
  					-- already in use in which case use the max
  					-- number there

  					-- insert the record

  					insert into jtf_diagnostic_group(SEQUENCE, GROUPNAME,
  					APPID, ORDERNUMBER, OBJECT_VERSION_NUMBER,
  					CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
  					LAST_UPDATE_LOGIN, CREATION_DATE, SENSITIVITY) values (
  					JTF_DIAGNOSTIC_GROUP_S.NEXTVAL, x.attribute_value,
  					P_ASN, DECODE(v_temp,null,1,v_temp),
  					x.OBJECT_VERSION_NUMBER, x.CREATED_BY,
  					x.LAST_UPDATE_DATE, x.created_by, NULL,
  					x.LAST_UPDATE_DATE, 1);

  				else
  					-- update the record

  					update jtf_diagnostic_group set
  					OBJECT_VERSION_NUMBER = x.OBJECT_VERSION_NUMBER,
  					LAST_UPDATE_DATE = x.LAST_UPDATE_DATE,
  					LAST_UPDATED_BY = x.LAST_UPDATED_BY
		  			where appid = P_ASN
  					and groupname = x.attribute_value;

  				end if;

  			end if;

			--insert or update group prereqs
			MIGRATE_GROUP_PREREQS(P_ASN,
  						x.attribute_value, P_APP_ID);


  			v_temp := 0;
		 	select count(*) into v_temp
		 	from jtf_perz_data a , jtf_perz_data_attrib b, jtf_perz_profile c
			where a.perz_data_id = b.perz_data_id
			and  a.profile_id = c.profile_id
			and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
			and  a.application_id = P_APP_ID
			and  a.perz_data_name = 'TESTHARNESS.' || p_asn || '.'
					|| x.attribute_value ||'.TCOUNT';


			if v_temp = 1 then

	 			select distinct to_number(b.attribute_value) into v_temp
			 	from jtf_perz_data a , jtf_perz_data_attrib b, jtf_perz_profile c
				where a.perz_data_id = b.perz_data_id
				and  a.profile_id = c.profile_id
				and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
				and  a.application_id = P_APP_ID
				and  a.perz_data_name = 'TESTHARNESS.' || p_asn || '.'
					|| x.attribute_value ||'.TCOUNT';


  				for v_count in 1..v_temp loop
					--insert or update test information
					MIGRATE_GROUP_TESTS(P_ASN, x.attribute_value,
								P_APP_ID, v_count);
				end loop;

			end if;

		END LOOP;

  	END IF;

  END MIGRATE_APP_GROUPS;

  ------------------------------------------------------------
  -- Begin procedure MIGRATE_GROUP_PREREQS
  ------------------------------------------------------------

  PROCEDURE MIGRATE_GROUP_PREREQS(
  				P_ASN IN VARCHAR2,
  				P_GRPNAME IN VARCHAR2,
  				P_APP_ID IN NUMBER) IS

  v_last_migrate_date		date 	:= SYSDATE;
  v_count			NUMBER 	:= 0;
  v_temp			NUMBER 	:= 0;


  cursor prereqlist is
    	select b.attribute_value, b.created_by,
	b.last_updated_by, b.last_update_date, a.object_version_number
	from jtf_perz_data a , jtf_perz_data_attrib b, jtf_perz_profile c
	where a.perz_data_id = b.perz_data_id
	and  a.profile_id = c.profile_id
	and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
	and  a.application_id = P_APP_ID
	and  a.perz_data_name like 'TESTHARNESS.' || P_ASN || '.' || P_GRPNAME ||'.DEP';
  BEGIN

  	select last_update_date into v_last_migrate_date from
	jtf_diagnostic_prereq where sourceid = 'migrate_date_flag'
	and sourceappid = 'migrate_date_flag'
	and prereqid = 'migrate_date_flag';

	FOR X IN prereqlist LOOP

		-- check if this already exists.
		-- if not insert, else update
		select count(*) into v_count from jtf_diagnostic_prereq
		where sourceappid = P_ASN
		and prereqid = x.attribute_value
  			and sourceid = p_grpname;

		if v_last_migrate_date < x.last_update_date or v_count = 0 then

			if v_count = 0 then
			-- insert the group prereq

				insert into jtf_diagnostic_prereq(
				SEQUENCE, SOURCEID, PREREQID,
				SOURCEAPPID, TYPE, OBJECT_VERSION_NUMBER,
				CREATED_BY, LAST_UPDATE_DATE,
				LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATION_DATE)
				values(
				JTF_DIAGNOSTIC_PREREQ_S.NEXTVAL,
				p_grpname, x.attribute_value, p_asn,
				2, x.object_version_number, x.created_by,
				x.last_update_date, x.created_by,
				NULL, x.last_update_date);


			else
			-- just update the group prereq
				update jtf_diagnostic_prereq set
				OBJECT_VERSION_NUMBER = x.OBJECT_VERSION_NUMBER,
				LAST_UPDATE_DATE = x.LAST_UPDATE_DATE,
				LAST_UPDATED_BY = x.LAST_UPDATED_BY;

			end if;

		end if;

	END LOOP;

  END MIGRATE_GROUP_PREREQS;

  ------------------------------------------------------------
  -- Begin procedure MIGRATE_GROUP_TESTS
  ------------------------------------------------------------

  PROCEDURE MIGRATE_GROUP_TESTS(
  				P_ASN IN VARCHAR2,
  				P_GRPNAME IN VARCHAR2,
  				P_APP_ID IN NUMBER,
  				p_testnum in number) IS

  v_last_migrate_date		date 		:= SYSDATE;
  v_count			NUMBER 		:= 0;
  v_temp_ordnum			number		:= 0;
  v_temp_argrows		number		:= 0;
  v_prev_data_name		jtf_perz_data.perz_data_name%type := 'blank';
  v_prev_attrib_value		jtf_perz_data_attrib.attribute_value%type := 'blank';

  cursor testlist is
   	select distinct a.perz_data_name, b.attribute_value, b.created_by,
	b.last_updated_by, b.last_update_date, a.object_version_number
	from jtf_perz_data a , jtf_perz_data_attrib b, jtf_perz_profile c
	where a.perz_data_id = b.perz_data_id
	and  a.profile_id = c.profile_id
	and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
	and  a.application_id = P_APP_ID
	and  a.perz_data_name = 'TESTHARNESS.' || P_ASN || '.' || P_GRPNAME ||'.TEST'
	||'.' || p_testnum order by a.perz_data_name, b.attribute_value;

  BEGIN

  	select last_update_date into v_last_migrate_date from
	jtf_diagnostic_prereq where sourceid = 'migrate_date_flag'
	and sourceappid = 'migrate_date_flag'
	and prereqid = 'migrate_date_flag';

	FOR X IN testlist LOOP

		-- insertion happens for every 2nd row from the cursor
		-- since the first one is the test type that we have to convert
		-- to the desired format as required by daniel's new standard
		-- after pl/sql enabling

		if mod(testlist%rowcount, 2) = 0 and  v_prev_data_name = x.perz_data_name then


			-- check if this already exists.
			-- if not insert, else update

			select count(*) into v_count from jtf_diagnostic_test
			where appid = P_ASN and groupname = P_GRPNAME and
			testclassname = x.attribute_value;

			if v_last_migrate_date < x.last_update_date or v_count = 0 then

				if v_count = 0 then

					-- insert the testcase after getting
					-- all the right parameters



					-- ordernumber (max there in the database + 1)

					select MAX(ordernumber) into v_temp_ordnum
					from jtf_diagnostic_test
					where appid = p_asn
					and groupname = p_grpname;
					-- and testclassname = x.attribute_value;

					if sql%notfound or v_temp_ordnum = 0 then
						v_temp_ordnum := 1;
					else v_temp_ordnum := v_temp_ordnum + 1;
					end if;




					-- testtype should be properly formatted
					-- according to the new standard

					if v_prev_attrib_value = '1' then
						v_prev_attrib_value := '{1,5}';
					elsif v_prev_attrib_value = '2' then
						v_prev_attrib_value := '{2,5}';
					elsif v_prev_attrib_value = '3' then
						v_prev_attrib_value := '{1,2,5}';
					else v_prev_attrib_value := '{1,5}';
					end if;



					-- total argument rows (key is okay)
					-- v_temp_argrows

					select count(*) into v_temp_argrows
					from jtf_perz_data a , jtf_perz_data_attrib b,
					jtf_perz_profile c
					where a.perz_data_id = b.perz_data_id
					and  a.profile_id = c.profile_id
					and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
					and  a.application_id = p_app_id
					and  a.perz_data_name = 'TESTHARNESS.' || p_asn || '.'
					|| p_grpname ||'.'
					|| x.attribute_value ||'.SETCOUNT';


					if v_temp_argrows = 1 then

					select distinct TO_NUMBER(b.attribute_value)
					into v_temp_argrows
					from jtf_perz_data a , jtf_perz_data_attrib b,
					jtf_perz_profile c
					where a.perz_data_id = b.perz_data_id
					and  a.profile_id = c.profile_id
					and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
					and  a.application_id = p_app_id
					and  a.perz_data_name = 'TESTHARNESS.' || p_asn || '.'
					|| p_grpname ||'.'
					|| x.attribute_value ||'.SETCOUNT';

					end if;


					insert into jtf_diagnostic_test(
					SEQUENCE, GROUPNAME, APPID,
					ORDERNUMBER, TESTTYPE, TESTCLASSNAME,
					TOTALARGUMENTROWS, OBJECT_VERSION_NUMBER,
					CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN, CREATION_DATE)
					values(
					jtf_diagnostic_test_s.nextval, p_grpname, p_asn,
					DECODE(v_temp_ordnum,null,1,v_temp_ordnum),
					v_prev_attrib_value,
					x.attribute_value,
					v_temp_argrows, X.OBJECT_VERSION_NUMBER, X.created_by,
					x.last_update_date, X.created_by,
					NULL, x.last_update_date);

				else

					-- just update the testcase
					update jtf_diagnostic_test set
					OBJECT_VERSION_NUMBER = x.OBJECT_VERSION_NUMBER,
					LAST_UPDATE_DATE = x.LAST_UPDATE_DATE,
					LAST_UPDATED_BY = x.LAST_UPDATED_BY
					where appid = p_asn and groupname = p_grpname
					and testclassname = x.attribute_value;

				end if;
			end if;


			-- Migrate test arguments here
			-- figure out what the bare min parameters required
			-- to get arguments from the property manager tables

			migrate_test_arguments(p_asn, p_grpname, p_app_id, x.attribute_value);

	    	end if;

		v_prev_data_name := x.perz_data_name;
		v_prev_attrib_value := x.attribute_value;

	END LOOP;

  END MIGRATE_GROUP_TESTS;

  ------------------------------------------------------------
  -- Begin procedure migrate_test_arguments
  ------------------------------------------------------------

  procedure migrate_test_arguments(
  				p_asn in varchar2,
  				p_grpname in varchar2,
  				p_app_id in number,
  				p_classname in varchar2) is

  v_count		number		:= 0;
  v_counter		binary_integer	:= 1;
  v_argument_names	JTF_VARCHAR2_TABLE_4000;

  cursor argnamelist is

	select a.perz_data_name, b.attribute_value, b.created_by,
	b.last_updated_by, b.last_update_date, a.object_version_number
	from jtf_perz_data a , jtf_perz_data_attrib b, jtf_perz_profile c
	where a.perz_data_id = b.perz_data_id and  a.profile_id = c.profile_id
	and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
	and  a.application_id = p_app_id and  a.perz_data_name like
	'TESTHARNESS.' || p_asn || '.' || p_grpname ||'.'
	|| p_classname ||'.ArgName';

  begin

  v_argument_names := JTF_VARCHAR2_TABLE_4000();

		-- total argument rows (key is okay)
		-- v_temp_argrows

		select count(*) into v_count
		from jtf_perz_data a , jtf_perz_data_attrib b,
		jtf_perz_profile c
		where a.perz_data_id = b.perz_data_id
		and  a.profile_id = c.profile_id
		and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
		and  a.application_id = p_app_id
		and  a.perz_data_name = 'TESTHARNESS.' || p_asn || '.'
		|| p_grpname ||'.'
		|| p_classname ||'.SETCOUNT';


		if v_count = 1 then

			-- this means that one row was returned
			-- and there is a char (numeric) value in the result
			-- set that we should convert to a number
			-- and search for arguments

			select distinct TO_NUMBER(b.attribute_value)
			into v_count
			from jtf_perz_data a , jtf_perz_data_attrib b,
			jtf_perz_profile c
			where a.perz_data_id = b.perz_data_id
			and  a.profile_id = c.profile_id
			and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
			and  a.application_id = p_app_id
			and  a.perz_data_name = 'TESTHARNESS.' || p_asn || '.'
			|| p_grpname ||'.'
			|| p_classname ||'.SETCOUNT';


			-- only if there are more than 0
			-- 0 argument rows in the perz data
			-- tables should we even bother to
			-- carry out the following process
			-- for performance purposes

			if v_count > 0 then

				-- now get the argument names in the array
				-- jtf_varchar_table_4000

				for x in argnamelist loop
					v_argument_names.extend;
					v_argument_names(argnamelist%rowcount)
						:= x.attribute_value;
				end loop;

				-- send all this information to the next plsql procedure
				-- that loops thru and makes the argument row migration to the
				-- database table jtf_diagnostic_arg

				for v_counter in 1..v_count loop
					migrate_test_arg_row(v_argument_names,
							p_asn, p_grpname,
							p_classname, p_app_id,
							to_char(v_counter));
				end loop;

			end if;

		end if;

  end migrate_test_arguments;


  -------------------------------------------------
  -- Begin procedure migrate_test_arg_row
  -------------------------------------------------

  procedure migrate_test_arg_row(
  				v_argument_names IN JTF_VARCHAR2_TABLE_4000,
 				p_asn in varchar2,
 				p_grpname in varchar2,
 				p_classname in varchar2,
 				p_app_id in number,
 				p_rownum in varchar2) is

 	v_count				number	:= 0;
 	v_rowcounter			number;
  	v_last_migrate_date		date 	:= SYSDATE;
  	v_arg_values			jtf_varchar2_table_4000;

 	cursor argvallist is

		select a.perz_data_name, b.attribute_value, b.created_by,
		b.last_updated_by, b.last_update_date, a.object_version_number
		from jtf_perz_data a , jtf_perz_data_attrib b, jtf_perz_profile c
		where a.perz_data_id = b.perz_data_id and  a.profile_id = c.profile_id
		and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
		and  a.application_id = p_app_id
		and  a.perz_data_name like
		'TESTHARNESS.' || p_asn || '.' || p_grpname ||'.'
		|| p_classname ||'.SET.' || p_rownum;

 begin

	-- make sure that the number of rows received from the
	-- query is equal to the number of arguments in the array
	-- if not dont do anything, potentiall dangerous situation

	select count(*) into v_count
	from jtf_perz_data a , jtf_perz_data_attrib b, jtf_perz_profile c
	where a.perz_data_id = b.perz_data_id and  a.profile_id = c.profile_id
	and  c.profile_name = 'JTF_PROPERTY_MANAGER_DEFAULT_1'
	and  a.application_id = p_app_id
	and  a.perz_data_name like
	'TESTHARNESS.' || p_asn || '.' || p_grpname ||'.'
	|| p_classname ||'.SET.' || p_rownum;


	if v_count = v_argument_names.count then

		select last_update_date into v_last_migrate_date from
		jtf_diagnostic_prereq where sourceid = 'migrate_date_flag'
		and sourceappid = 'migrate_date_flag'
		and prereqid = 'migrate_date_flag';

		for x in argvallist loop

			-- check if this exists or not.
			-- if not we will insert it anyway
			-- irrespective of last_migrate date

			v_rowcounter := argvallist%rowcount;

			select count(*) into v_count from jtf_diagnostic_arg
			where testclassname = p_classname and
			groupname = p_grpname and
			appid = p_asn and
			argname = v_argument_names(v_rowcounter) and
			rownumber = p_rownum;

			if v_last_migrate_date < x.last_update_date or v_count = 0 then

				if v_count = 0 then

					insert into jtf_diagnostic_arg(
					SEQUENCE, TESTCLASSNAME, GROUPNAME,
					APPID, ARGNAME, ARGVALUE,
					ROWNUMBER,  VALUESETNUMBER,
					OBJECT_VERSION_NUMBER, CREATED_BY,
					LAST_UPDATE_DATE, LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN, CREATION_DATE)
					values(
					jtf_diagnostic_arg_s.nextval,
					p_classname, p_grpname,
					p_asn,
					v_argument_names(v_rowcounter),
					x.attribute_value, p_rownum, 1,
					x.object_version_number, x.created_by,
					x.last_update_date, x.created_by,
					null, x.last_update_date);

	  			else
					update jtf_diagnostic_arg set
					argvalue =  x.attribute_value,
					last_updated_by = x.last_updated_by,
					object_version_number = x.object_version_number,
					last_update_date = x.last_update_date
					where testclassname = p_classname and
					groupname = p_grpname and
					appid = p_asn and
					argname = v_argument_names(v_rowcounter) and
					rownumber = p_rownum;

				end if;

			end if;

		end loop;

	end if;

 end migrate_test_arg_row;


END JTF_DIAGNOSTIC_MIGRATE;


/
