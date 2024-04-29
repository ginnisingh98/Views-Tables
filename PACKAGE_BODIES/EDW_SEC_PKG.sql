--------------------------------------------------------
--  DDL for Package Body EDW_SEC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SEC_PKG" as
/* $Header: EDWSPKGB.pls 120.2 2005/09/20 00:07:19 amitgupt noship $*/

-- This procedure sets the EDW context attributes

PROCEDURE set_context IS

--  PRAGMA AUTONOMOUS_TRANSACTION;

  cursor dim_access_cursor is
  select distinct dim_id from edw_sec_dim_access
  where resp_id = ses_resp_id;

  current_dim_id        edw_sec_dim_info_t.dim_id%TYPE;
  current_level_id	edw_sec_lvl_info_t.level_id%TYPE;

  cursor access_value_cursor is
  select distinct level_id
  from edw_sec_dim_access
  where resp_id = ses_resp_id
  and dim_id = current_dim_id;

  x_db_version          varchar2(30);
  x_compatible          varchar2(30);
  version_number        number;
  max_context_length    number;

  dim_access_rec	dim_access_cursor%ROWTYPE;
  access_value_rec	access_value_cursor%ROWTYPE;

  x_context_value		varchar2(4000) := NULL;
  temp_context_value		varchar2(4000) := NULL;
  x_context_name		edw_sec_dim_info_t.context_name%TYPE := NULL;
  x_table_name			edw_sec_dim_info_t.table_name%TYPE;
  x_lowest_level_col_name  	edw_sec_dim_info_t.lowest_level_col_name%TYPE;
  x_star_user_col_name		edw_sec_lvl_info_t.star_level_name_col_name%TYPE;
  x_access_value		number;

  x_object_name			varchar2(30) := 'EDW_SEC_PKG.SET_CONTEXT';
  x_object_type			varchar2(30) := 'Security Procedure';

  v_Errorcode			number;
  v_ErrorText			varchar2(200);

  LARGE_CONTEXT_LENGTH		EXCEPTION;

  x_default_sec			varchar2(30) := NULL;

  x_message			varchar2(2000);

BEGIN

--Reset context values
  dbms_session.set_context('edw_context', 'resp_context',null);
  dbms_session.set_context('edw_context', 'error_context',null);
  dbms_session.set_context('edw_context', 'db_version_context',null);


--Get responsibility_id

  ses_resp_id := FND_PROFILE.VALUE('RESP_ID');

--Get database version

  DBMS_UTILITY.DB_VERSION(x_db_version, x_compatible);
  --code change for bug 4498820
  -- logic changed to take care of 10 G databases
  --version_number := to_number(substr(x_db_version, 0, 1)||substr(x_db_version, 3, 1)||substr(x_db_version, 5, 1));
  version_number := replace(substr(x_db_version,1,instr(x_db_version,'.',1,2)+1),'.');
  dbms_session.set_context('edw_context', 'db_version_context', to_char(version_number));


-- Set maximum allowable context length

  If version_number < 816 then
	max_context_length := 256;
  else
	max_context_length := 4000;
  end if;

-- Process the dimensions for which security is defined for current responsibility

  FOR dim_access_rec IN dim_access_cursor LOOP

	select context_name, table_name, lowest_level_col_name
	into x_context_name, x_table_name, x_lowest_level_col_name
	from edw_sec_dim_info_t
	where dim_id = dim_access_rec.dim_id;

	current_dim_id := dim_access_rec.dim_id;

        x_context_value :=      ' select ' ||
                                x_lowest_level_col_name ||
                                ' from '||
                                x_table_name ||
                                ' where ';




--      Following 'FOR' loop takes care of multiple access_values for a dimension

        FOR access_value_rec IN access_value_cursor LOOP

                select  star_level_name_col_name
                into  x_star_user_col_name
                from edw_sec_lvl_info_t
                where dim_id = current_dim_id
                and level_id = access_value_rec.level_id;


  current_level_id := access_value_rec.level_id;

                If temp_context_value is null then
                        temp_context_value :=   x_star_user_col_name ||
                                                ' in ( select access_value from edw_sec_dim_access where resp_id = ' || ses_resp_id || ' and dim_id = ' || current_dim_id || ' and level_id = ' || current_level_id ||' )';

                else
                        temp_context_value :=   temp_context_value ||
                                                ' OR ' ||
                                                 x_star_user_col_name ||
                                                ' in ( select access_value from edw_sec_dim_access where resp_id = ' || ses_resp_id || ' and dim_id = ' || current_dim_id || ' and level_id = ' || current_level_id ||' )';
                end if;

        END LOOP;

        x_context_value := x_context_value || temp_context_value;

        temp_context_value := NULL;

        x_context_name := '' || x_context_name || '';


-- 	Check the context length

	If length(x_context_value) > max_context_length then
		RAISE LARGE_CONTEXT_LENGTH;
	end if;


-- 	Set the context attribute for the dimension

	dbms_session.set_context('edw_context', x_context_name, x_context_value);

  END LOOP;

  dbms_session.set_context('edw_context', 'resp_context', ses_resp_id);

  commit;


--Get edw_default_security_profile

  x_default_sec := FND_PROFILE.VALUE('EDW_DEFAULT_SECURITY');
  x_default_sec := UPPER(x_default_sec);

  dbms_session.set_context('edw_context', 'DEF_SEC_ENABLE', x_default_sec);

IF x_default_sec = 'Y' THEN  /*	Need to implement default security */

	edw_sec_pkg.link_aol_user;
	edw_sec_pkg.set_default_context;

END IF;


EXCEPTION

  WHEN NO_DATA_FOUND THEN NULL;

  WHEN LARGE_CONTEXT_LENGTH THEN

--      Log error message into edw_error_log table

	x_message :=  'Context length exceeds maximum allowable limit.
			 Please try by reducing the number of dimensions or levels on which security is defined.';
	edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);


--      Set the error_context to make security function aware of the error occured in initialization function

        dbms_session.set_context('edw_context', 'error_context', 'TRUE');
	commit;

  WHEN OTHERS THEN
	v_ErrorCode := SQLCODE;
	v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--      Set the error_context to make security function aware of the error occured in initialization function
-- 	This is moved before logging error so that if error logging fails, still we set the error_context

        dbms_session.set_context('edw_context', 'error_context', 'TRUE');


--	Log error message into edw_error_log table

        x_message :=   'Oracle error occured.
			Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);

	commit;



END set_context;




PROCEDURE set_default_context IS

-- This procedure populates two context attributes.
-- 1. DEFAULT_PERSON - This is set with proper subquery
-- 2. DEF_DIM_ID - This is populated with dim_id of Person dimension

--  PRAGMA AUTONOMOUS_TRANSACTION;

  x_db_version          varchar2(30);
  version_number        number;
  max_context_length    number;

  x_context_value		varchar2(4000) := NULL;
  x_context_name		varchar2(30); 	-- edw_sec_dim_info_t.context_name%TYPE := NULL;

  x_object_name			varchar2(40) := 'EDW_SEC_PKG.SET_DEFAULT_CONTEXT';
  x_object_type			varchar2(30) := 'Security Procedure';

  v_Errorcode			number;
  v_ErrorText			varchar2(200);

  LARGE_CONTEXT_LENGTH		EXCEPTION;

  error_flag			varchar2(30) := NULL;
  x_def_dim_id			edw_sec_dim_info_t.dim_id%TYPE;

  LINK_AOL_USER_ERROR			EXCEPTION;

  x_message                     varchar2(2000);


BEGIN


-- ASSUMPTION : link_aol_user populates two context attributes : def_access_column and def_access_id
--      1. def_access_column - populated with pk_key column name for the highest level at which person exists
--      For example if person exists at level 3 then def_access_column = S03_SPRVSR_LVL1_PK_KEY and so on.
--      2. def_access_id - populated with pk_key at that level i.e. the value of S03_SPRVSR_LVL1_PK_KEY column


  x_context_name := 'DEFAULT_PERSON';
  x_context_name := '' || x_context_name || '';


--Reset context values
  dbms_session.set_context('edw_context', x_context_name ,null);


-- Check for error flag to make sure successfull execution of link_aol_user
  error_flag := SYS_CONTEXT( 'edw_context', 'error_context');

  If error_flag = 'TRUE' then
        RAISE LINK_AOL_USER_ERROR;
  end if;


-- Get database version
-- ASSUMPTION: It is already captured in advance in set_context (i.e. set_default_context is called after that..)

  version_number :=  to_number(SYS_CONTEXT( 'edw_context', 'db_version_context'));


-- Set maximum allowable context length

  If version_number < 816 then
	max_context_length := 256;
  else
	max_context_length := 4000;
  end if;


	x_context_value := 'select ASGN_ASSIGNMENT_PK_KEY from EDW_HR_PERSON_M where '
				|| SYS_CONTEXT('edw_context','def_access_column')
				|| ' = '
				|| SYS_CONTEXT('edw_context','def_access_id');


-- 	Check the context length

	If length(x_context_value) > max_context_length then
		RAISE LARGE_CONTEXT_LENGTH;
	end if;


-- 	Set the context attribute for the dimension

	dbms_session.set_context('edw_context', x_context_name, x_context_value);


<< last >>

  commit;

-- Set attribute def_dim_id
  select dim_id into x_def_dim_id from edw_sec_dim_info_t
	where dim_name = 'EDW_HR_PERSON_M';
  dbms_session.set_context('edw_context', 'DEF_DIM_ID', to_char(x_def_dim_id));


EXCEPTION

  WHEN LINK_AOL_USER_ERROR THEN

-- Do nothing as error flag is already set by link_aol_user
  NULL;

  WHEN LARGE_CONTEXT_LENGTH THEN

--      Log error message into edw_error_log table

        x_message :=    'Default Context length exceeds maximum allowable limit.';

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);


--      Set the error_context to make security function aware of the error occured in initialization function

        dbms_session.set_context('edw_context', 'error_context', 'TRUE');
	commit;

  WHEN OTHERS THEN
	v_ErrorCode := SQLCODE;
	v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--      Set the error_context to make security function aware of the error occured in initialization function
--      This is moved before logging error so that if error logging fails, still we set the error_context

        dbms_session.set_context('edw_context', 'error_context', 'TRUE');


--	Log error message into edw_error_log table

        x_message :=   'Oracle error occured.
                        Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);

        commit;

END set_default_context;




PROCEDURE Link_aol_user IS

--  PRAGMA AUTONOMOUS_TRANSACTION;

  x_object_name			varchar2(40) := 'EDW_SEC_PKG.LINK_AOL_USER';
  x_object_type			varchar2(30) := 'Security Procedure';

  v_Errorcode			number;
  v_ErrorText			varchar2(200);

  x_user_count			number;
  x_user_name			fnd_user.user_name%type;
  x_db_link_name		edw_source_instances.warehouse_to_instance_link%type;
  x_person_id			number;
  x_instance_code		edw_system_parameters.instance_code%type;
  x_pk_fixed_string		varchar2(30) := '-EMPLOYEE-PERS';
  x_pk                  	edw_hr_person_m.asgn_assignment_pk%type;
  x_pk_key			edw_hr_person_m.asgn_assignment_pk_key%type;
  x_name                      	varchar2(2000); 	-- edw_hr_person_m.s01_name%type;
  x_asgn_name			edw_hr_person_m.asgn_name%type;
  x_number			number;
  x_char                       	varchar2(30);
  x_double_char			varchar2(30);
  x_access_id			edw_hr_person_m.asgn_assignment_pk_key%type;
  x_access_column		varchar2(30);
  sql_stmt			varchar2(4000);

  USER_NOT_EXIST		EXCEPTION;
  USER_NOT_LINKED		EXCEPTION;

  x_current_person_id		number;

  TYPE PersonIdTable IS TABLE OF NUMBER;

  x_table                       PersonIdTable := PersonIdTable(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
  i				number;

  x_message                     varchar2(2000);


BEGIN


-- 	The API link_aol_user populates two context attributes : def_access_column and def_access_id
--      1. def_access_column - populated with pk_key column name for the highest level at which person exists
--      For example if person exists at level 3 then def_access_column = S03_SPRVSR_LVL1_PK_KEY and so on.
--      2. def_access_id - populated with pk_key at that level i.e. the value of S03_SPRVSR_LVL1_PK_KEY column


--Reset context values
  dbms_session.set_context('edw_context', 'def_access_column',null);
  dbms_session.set_context('edw_context', 'def_access_id',null);


-- Capture apps user and  get person_id by going across db_link to fnd_user on master source instance.

-- Find application user

  x_user_name := FND_PROFILE.VALUE('USERNAME');


-- Find master source instance

  select instance_code into x_instance_code from edw_system_parameters;


-- Find database link to master source instance

  select warehouse_to_instance_link into x_db_link_name from edw_source_instances
 	 where instance_code = x_instance_code;


-- Check if application user exists on source instance


  sql_stmt := 'select count(*) from fnd_user@' || x_db_link_name ||
                ' where user_name = ''' ||x_user_name || '''';
          EXECUTE IMMEDIATE sql_stmt INTO x_user_count;

/*
sql_stmt := 'select count(*) from fnd_user' ||
			' where user_name = ''' ||x_user_name || '''';
		EXECUTE IMMEDIATE sql_stmt INTO x_user_count;
*/


  IF x_user_count = 0 THEN /* Application user doesn't exists on source. */
	RAISE USER_NOT_EXIST;
  END IF;


-- Get person_id by refering to FND_USER on master source instance

  sql_stmt := 'select nvl(employee_id, -1) from fnd_user@' || x_db_link_name ||
		' where user_name = ''' ||x_user_name || '''';
	  EXECUTE IMMEDIATE sql_stmt INTO x_person_id;

/*
  sql_stmt := 'select nvl(employee_id, -1) from fnd_user' ||
		    ' where user_name = ''' ||x_user_name || '''';
		EXECUTE IMMEDIATE sql_stmt INTO x_person_id;
*/



  IF x_person_id = -1 THEN /* Application user not linked with any employee. */
	RAISE USER_NOT_LINKED;
  END IF;

  x_pk := x_person_id || '-' || x_instance_code || x_pk_fixed_string;

  select asgn_assignment_pk_key into x_pk_key
  from edw_hr_person_m
  where asgn_assignment_pk = x_pk;



-----------------------------------------------------------
--
-- Start of new code based on Person_id
--
------------------------------------------------------------

-- Using dynamic SQL to make code independent of person dimension changes

  sql_stmt := ' select
        s01_person_id,
        s02_person_id,
        s03_person_id,
        s04_person_id,
        s05_person_id,
        s06_person_id,
        s07_person_id,
        s08_person_id,
        s09_person_id,
        s10_person_id,
        s11_person_id,
        s12_person_id,
        s13_person_id,
        s14_person_id,
        s15_person_id
  from
        edw_hr_person_m
  where
        asgn_assignment_pk_key = '|| x_pk_key;


  EXECUTE IMMEDIATE sql_stmt INTO
        x_table(1),
        x_table(2),
        x_table(3),
        x_table(4),
        x_table(5),
        x_table(6),
        x_table(7),
        x_table(8),
        x_table(9),
        x_table(10),
        x_table(11),
        x_table(12),
        x_table(13),
        x_table(14),
        x_table(15);


-- Check if Supervisor is null or Person at last level


IF ((x_table(1) IS NULL) OR (x_person_id <> x_table(1))) THEN

        x_access_column := 'ASGN_ASSIGNMENT_PK_KEY';
        x_access_id := x_pk_key;

        dbms_session.set_context('edw_context', 'def_access_column',x_access_column);
        dbms_session.set_context('edw_context', 'def_access_id',to_char(x_access_id));

	goto last;

END IF;


-- Find the level

i := 2;

WHILE (x_person_id = x_table(i)) LOOP
        IF i=15 THEN   /* Person at highest level */
                i:=16;
                EXIT;
        END IF;
        i := i+1;
END LOOP;

i := i-1;
x_char := i;


------------------------------------------------------------------
--
-- End of new code
--
----------------------------------------------------------------

-- Transformation logic to form PK_KEY columns name
-- They are named as : S01_SPRVSR_LVL1_PK_KEY, S02_SPRVSR_LVL2_PK_KEY.....S15_SPRVSR_LVL15_PK_KEY

  IF length(x_char) = 1 THEN
	x_double_char := '0'||x_char;
  ELSE
	x_double_char := x_char;
  END IF;

  x_access_column := 'S' || x_double_char || '_SPRVSR_LVL' || x_char  || '_PK_KEY';


-- Need to use dynamic SQL as x_access_column not known in advance

  sql_stmt := 'select ' || x_access_column || ' from edw_hr_person_m where asgn_assignment_pk_key = ' || x_pk_key;

  EXECUTE IMMEDIATE sql_stmt INTO x_access_id;



  dbms_session.set_context('edw_context', 'def_access_column',x_access_column);
  dbms_session.set_context('edw_context', 'def_access_id',to_char(x_access_id));


<< last >>

  commit;


EXCEPTION

  WHEN USER_NOT_EXIST THEN

--      Log error message into edw_error_log table

	x_message := 'Application user '|| x_user_name || ' does not exist on master source instance.';

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);

--      Set the error_context to make security function aware of the error occured in initialization function

        dbms_session.set_context('edw_context', 'error_context', 'TRUE');
        commit;


  WHEN USER_NOT_LINKED THEN

--      Log error message into edw_error_log table

        x_message := 'Application user '|| x_user_name || ' is not linked with any employee.';

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);

--      Set the error_context to make security function aware of the error occured in initialization function

        dbms_session.set_context('edw_context', 'error_context', 'TRUE');
        commit;


  WHEN OTHERS THEN
	v_ErrorCode := SQLCODE;
	v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--      Set the error_context to make security function aware of the error occured in initialization function
--      This is moved before logging error so that if error logging fails, still we set the error_context

        dbms_session.set_context('edw_context', 'error_context', 'TRUE');


--	Log error message into edw_error_log table

        x_message :=   'Oracle error occured.
                        Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);


        commit;

END link_aol_user;

---------------------------------------------------------
--Added for bug 4577390
--This will set the global names to false.
--this code was in BIS_INIT.INITALIZE and has been
--moved here. This function will be called from set_context
---------------------------------------------------------
PROCEDURE set_global_names_for_source IS
  sorc_records                  number := 0;
  v_Errorcode                   number;
  v_ErrorText                   varchar2(200);
  x_step			varchar2(50);
  sql_stmt                      varchar2(1000);
BEGIN
  -- Check if source
  select count(*) into sorc_records from dba_tables
  where owner = EDW_OWB_COLLECTION_UTIL.get_db_user('BIS')
  and table_name = 'EDW_LOCAL_INSTANCE';

  IF sorc_records > 0 THEN
    sql_stmt := 'select count(*) from edw_local_instance';
    EXECUTE IMMEDIATE sql_stmt into sorc_records;
  END IF;

  x_step := 'set_global_names_false';

  IF sorc_records > 0 THEN
    -- Set Global_names to false
    sql_stmt := ' ALTER SESSION SET global_names = false';
    EXECUTE IMMEDIATE sql_stmt;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
	v_ErrorCode := SQLCODE;
	v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--	Log error message into edw_error_log table

        insert into edw_error_log
        (object_name, object_type, resp_id, message,
        last_update_date, last_updated_by, creation_date, created_by, last_update_login)
        values
        ('EDW_SEC_PKG.set_global_names_for_source', 'EDW Security Package', NULL,
	'Oracle error occured in EDW_SEC_PKG.set_global_names_for_source procedure at step : '|| x_step
         || '. Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText,
        sysdate, 0, sysdate, 0, 0);
        commit;
END set_global_names_for_source;

-- This is a generic EDW security function which generates predicates based on context attributes

function dim_sec
(obj_schema varchar2,
obj_name varchar2)
return varchar2
is

  PRAGMA AUTONOMOUS_TRANSACTION;

  d_predicate 	varchar2(4000) := null;
  x_fact_id	number;
  x_fk_col_name	edw_sec_fact_info_t.fk_col_name%TYPE;
  x_context_name  edw_sec_dim_info_t.context_name%TYPE;


  cursor sec_cursor is select distinct t1.dim_id
  from edw_sec_dim_access t1, edw_sec_fact_info_t t2
  where resp_id = ses_resp_id
  and t1.dim_id = t2.dim_id
  and t2.fact_id = x_fact_id;

  sec_rec			sec_cursor%ROWTYPE;

---------------------------------------------------------------

  x_def_dim_id	edw_sec_dim_access.dim_id%TYPE;

  cursor sec_def_cursor is select distinct t1.dim_id
  from edw_sec_dim_access t1, edw_sec_fact_info_t t2
  where resp_id = ses_resp_id
  and t1.dim_id = t2.dim_id
  and t2.fact_id = x_fact_id
  and t1.dim_id <> x_def_dim_id;

  sec_def_rec                       sec_def_cursor%ROWTYPE;

  x_item_set_name	varchar2(30) := 'EDW_DEF_SEC_PERM';
  x_number		number :=0;
  x_default_sec		varchar2(30);
---------------------------------------------------------------------
  current_dim_id		edw_sec_fact_info_t.dim_id%TYPE;



-- Cursor changed to eliminate disabled references - 3/6/2002

  cursor fk_cursor is select fk_col_name
  from edw_sec_fact_info_t
  where fact_id = x_fact_id
  and dim_id = current_dim_id
  and fk_col_name not in
	( select fk_col_name
	from edw_sec_ref_info_t
	where resp_id = ses_resp_id
	and fact_id = x_fact_id
	and dim_id = current_dim_id);



  fk_rec 			fk_cursor%ROWTYPE;

  error_flag 			varchar2(30) := NULL;
  version_number        	number;
  max_predicate_length    	number;
  temp_predicate		varchar2(4000);

  x_object_name                 varchar2(30) := 'EDW_SEC_PKG.DIM_SEC';
  x_object_type                 varchar2(30) := 'Security Procedure';

  v_Errorcode                   number;
  v_ErrorText                   varchar2(200);


  LARGE_PREDICATE_LENGTH        EXCEPTION;
  INIT_ERROR			EXCEPTION;
  DEF_DIM_ID_IS_NULL		EXCEPTION;

  x_message                     varchar2(2000);


BEGIN
  --added for bug 4577390, need to global names to false
  edw_sec_pkg.set_global_names_for_source;

  --- Set edw context Added for bug 4577390
  edw_sec_pkg.set_context;

--Get responsibility_id

--ses_resp_id := FND_PROFILE.VALUE('RESP_ID');
  ses_resp_id := SYS_CONTEXT( 'edw_context', 'resp_context');

  select distinct fact_id into x_fact_id
  from edw_sec_fact_info_t
  where fact_name = obj_name;


-- Check for error flag to make sure successfull execution of initialization function

  error_flag := SYS_CONTEXT( 'edw_context', 'error_context');

  If error_flag = 'TRUE' then
	RAISE INIT_ERROR;
  end if;

-- Get database version and set maximum predicate length

  version_number :=  to_number(SYS_CONTEXT( 'edw_context', 'db_version_context'));

  If version_number < 817 then
	max_predicate_length := 2000;
  else
	max_predicate_length := 4000;
  end if;



-- Check if default Security is enabled

  x_default_sec := SYS_CONTEXT( 'edw_context', 'DEF_SEC_ENABLE');

  If x_default_sec = 'Y' then 	/* Default Security is enabled	*/

-- Check if default security needs to be implemented for this fact

	select count(*) into x_number
	from edw_sec_itemset_info_t
	where fact_id = x_fact_id;

  If x_number > 0 then	/* Default security needs to be implemented for this fact  */

-- Find out the dimension on which default security needs to be implemented
-- ASSUMPTION : The context attribute DEF_DIM_ID is already populated by set_default_context

-- Make sure def_dim_id is not null

  If SYS_CONTEXT('edw_context', 'DEF_DIM_ID') is null THEN
	RAISE DEF_DIM_ID_IS_NULL;
  End if;

  x_def_dim_id := SYS_CONTEXT('edw_context', 'DEF_DIM_ID');


-- Process the dimensions which are applicable to fact and for which security is defined for current responsibility
-- Except the dimension on which default security needs to be implemented (that will be taken care of by default_sec)

  FOR sec_def_rec in sec_def_cursor LOOP
	current_dim_id := sec_def_rec.dim_id;

--      Following 'FOR' loop takes care of multiple references to same dimension by a fact cube

	FOR fk_rec in fk_cursor LOOP
		x_fk_col_name := fk_rec.fk_col_name;

		select context_name into x_context_name
		from edw_sec_dim_info_t
		where dim_id = sec_def_rec.dim_id;

		x_context_name := '' || x_context_name || '';

--		This is to prevent erroring out if context not initialized.

		If SYS_CONTEXT('edw_context', x_context_name) IS NULL then
			goto last2;
		end if;
--
--		This is to take care of pl/sql bug with sys_context
                select SYS_CONTEXT('edw_context', x_context_name, 4000) into temp_predicate from dual;

		If d_predicate is null then
			d_predicate :=  x_fk_col_name ||
                	' in ('||
               		temp_predicate ||
			')';
		else
			d_predicate :=  d_predicate ||
                	' and ' ||
                	x_fk_col_name ||
                	' in (' ||
               		temp_predicate ||
			')';
		end if;

		x_context_name := NULL;

	END LOOP;

  << last2 >>
  null;

  END LOOP;

  end if;

  goto final;

 end if;

-- Following will get executed if default security not enabled

-- Process the dimensions which are applicable to fact and for which security is defined for current responsibility

  FOR sec_rec in sec_cursor LOOP
	current_dim_id := sec_rec.dim_id;

--      Following 'FOR' loop takes care of multiple references to same dimension by a fact cube

	FOR fk_rec in fk_cursor LOOP
		x_fk_col_name := fk_rec.fk_col_name;

		select context_name into x_context_name
		from edw_sec_dim_info_t
		where dim_id = sec_rec.dim_id;

		x_context_name := '' || x_context_name || '';

--		This is to prevent erroring out if context not initialized.

		If SYS_CONTEXT('edw_context', x_context_name) IS NULL then
			goto last;
		end if;
--
--		This is to take care of pl/sql bug with sys_context
                select SYS_CONTEXT('edw_context', x_context_name, 4000) into temp_predicate from dual;

		If d_predicate is null then
			d_predicate :=  x_fk_col_name ||
                	' in ('||
               		temp_predicate ||
			')';
		else
			d_predicate :=  d_predicate ||
                	' and ' ||
                	x_fk_col_name ||
                	' in (' ||
               		temp_predicate ||
		')';
		end if;

		x_context_name := NULL;

	END LOOP;

  << last >>
  null;

  END LOOP;


  << final >>

-- Check the predicate length

        If length(d_predicate) > max_predicate_length then
                RAISE LARGE_PREDICATE_LENGTH;
        end if;

  commit;

  return d_predicate;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
	d_predicate := NULL;
	commit;
	return d_predicate;

  WHEN INIT_ERROR THEN

--      Log error message into edw_error_log table

        x_message :=   'Error in initialization function.';

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);


--      Make security function fail
        RAISE;

  WHEN DEF_DIM_ID_IS_NULL THEN

--      Log error message into edw_error_log table

        x_message :=   'Def_dim_id is null.';

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);

--      Make security function fail
        RAISE;

  WHEN LARGE_PREDICATE_LENGTH THEN

--      Log error message into edw_error_log table

        x_message :=   'Predicate length exceeds maximum allowable limit.
        		Please try by reducing the number of dimensions or levels on which security is defined.';

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);


--	Make security function fail
	RAISE;

  WHEN OTHERS THEN
        v_ErrorCode := SQLCODE;
        v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--      Log error message into edw_sec_error table

        x_message :=   'Oracle error occured.
                        Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);


--      Make security function fail
        RAISE;

END dim_sec;




function Default_sec
(obj_schema varchar2,
obj_name varchar2)
return varchar2
is

  PRAGMA AUTONOMOUS_TRANSACTION;

  d_predicate 	varchar2(4000) := null;
  x_fk_col_name	varchar2(30); 		-- edw_sec_fact_info_t.fk_col_name%TYPE;
  x_context_name  varchar2(30); 	--edw_sec_dim_info_t.context_name%TYPE;


  error_flag 			varchar2(30) := NULL;
  version_number        	number;
  max_predicate_length    	number;
  temp_predicate		varchar2(4000);

  x_object_name                 varchar2(30) := 'EDW_SEC_PKG.DEFAULT_SEC';
  x_object_type                 varchar2(30) := 'Security Procedure';

  v_Errorcode                   number;
  v_ErrorText                   varchar2(200);

  x_fact_id			number;
  x_item_set_name       	varchar2(30) := 'EDW_DEF_SEC_PERM';

  LARGE_PREDICATE_LENGTH        EXCEPTION;
  INIT_ERROR			EXCEPTION;

  x_message                     varchar2(2000);


BEGIN
  --added for bug 4577390, need to global names to false
  edw_sec_pkg.set_global_names_for_source;

  --- Set edw context Added for bug 4577390
  edw_sec_pkg.set_context;

-- Check for error flag to make sure successfull execution of initialization function

  error_flag := SYS_CONTEXT( 'edw_context', 'error_context');

  If error_flag = 'TRUE' then
        RAISE INIT_ERROR;
  end if;


-- Check if default Security is enabled

  If SYS_CONTEXT('edw_context', 'DEF_SEC_ENABLED') <> 'Y' then
	d_predicate := NULL;
	goto last;
  end if;


--If default security context is not initialized then return NULL predicate.
-- This should not occur in any condition
-- We can make security function fail in this case if desired.

-- ASSUMPTION : Context name is DEFAULT_PERSON

                x_context_name := 'DEFAULT_PERSON';

                x_context_name := '' || x_context_name || '';


                If SYS_CONTEXT('edw_context', x_context_name) IS NULL then
                        d_predicate := NULL;
                        goto last;
                end if;


-- Find the fact against which security function is being executed

  select distinct fact_id into x_fact_id
  from edw_sec_fact_info_t
  where fact_name = obj_name;


-- Get database version and set maximum predicate length

  version_number :=  to_number(SYS_CONTEXT( 'edw_context', 'db_version_context'));

  If version_number < 817 then
	max_predicate_length := 2000;
  else
	max_predicate_length := 4000;
  end if;


-- Get FK column name in fact table which needs to be secured by default security

  select fk_col_name into x_fk_col_name
  from edw_sec_itemset_info_t
  where itemset_name = x_item_set_name
  and fact_id = x_fact_id;

-- ASSUMPTION : Context name is DEFAULT_PERSON

		x_context_name := 'DEFAULT_PERSON';

		x_context_name := '' || x_context_name || '';

--If default security context is not initialized then return NULL predicate.
-- This should not occur in any condition
-- We can make security function fail in this case if desired.

		If SYS_CONTEXT('edw_context', x_context_name) IS NULL then
			d_predicate := NULL;
			goto last;
		end if;
--
--		This is to take care of pl/sql bug with sys_context
                select SYS_CONTEXT('edw_context', x_context_name, 4000) into temp_predicate from dual;

-- ASSUMPTION : Only one reference (person_fk_key) needs to be secured.

--		If d_predicate is null then

			d_predicate :=  x_fk_col_name ||
                	' in ('||
               		temp_predicate ||
			')';

<< last >>
  null;


-- Check the predicate length

        If length(d_predicate) > max_predicate_length then
                RAISE LARGE_PREDICATE_LENGTH;
        end if;


  commit;
  return d_predicate;


EXCEPTION

  WHEN INIT_ERROR THEN

--      Log error message into edw_error_log table

        x_message :=   'Error in initialization function';

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);

--      Make security function fail
        RAISE;

  WHEN LARGE_PREDICATE_LENGTH THEN

--      Log error message into edw_error_log table

        x_message :=    'Predicate length exceeds maximum allowable limit.';

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);

--	Make security function fail
	RAISE;

  WHEN OTHERS THEN
        v_ErrorCode := SQLCODE;
        v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--      Log error message into edw_sec_error table

        x_message :=   'Oracle error occured.
                        Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;

        edw_sec_util.log_error(x_object_name, x_object_type, ses_resp_id, null, x_message);

--      Make security function fail
        RAISE;

END default_sec;




END edw_sec_pkg;

/
