--------------------------------------------------------
--  DDL for Package Body EDW_SEC_REF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SEC_REF" as
/* $Header: EDWSREFB.pls 115.2 2002/12/06 02:55:22 tiwang noship $*/

-- This procedure disables security for a reference

PROCEDURE disable_security
(application_short_name varchar2, responsibility_key varchar2,
           fact_physical_name varchar2, fk_column_physical_name varchar2)
IS

  x_object_name			varchar2(30) := 'EDW_SEC_REF.DISABLE_SECURITY';
  x_object_type			varchar2(30) := 'Disable Security Procedure';

  v_Errorcode			number;
  v_ErrorText			varchar2(200);

  x_message			varchar2(2000);


  x_appl_id             number;
  x_resp_id             number;
  x_fact_id 		number;
  x_dim_id             number;

  x_rec_count		number;

  x_app_name		varchar2(50);
  x_resp_key		varchar2(30);

  x_dim_name		varchar2(255);


BEGIN

x_app_name := application_short_name;
x_resp_key :=responsibility_key;


select application_id into x_appl_id from fnd_application_vl
where application_short_name =  x_app_name;

select responsibility_id into x_resp_id from fnd_responsibility_vl
where responsibility_key = x_resp_key
and application_id = x_appl_id;

select distinct fact_id into x_fact_id from edw_sec_fact_info_t
where fact_name = fact_physical_name;

select dim_id into x_dim_id from edw_sec_fact_info_t
where fact_name = fact_physical_name
and fk_col_name = fk_column_physical_name;

select dim_name into x_dim_name from edw_sec_dim_info_t
where dim_id = x_dim_id;


-- Check if row already exists

select count(*) into x_rec_count from edw_sec_ref_info_t
where appl_id = x_appl_id
and resp_id = x_resp_id
and fact_id = x_fact_id
and fk_col_name = fk_column_physical_name;


IF (x_rec_count = 0) THEN

-- Insert Row

Insert into edw_sec_ref_info_t
	(appl_id,
	resp_id,
	fact_id,
	fact_name,
	dim_id,
	dim_name,
	fk_col_name)
values
	(x_appl_id,
	x_resp_id,
	x_fact_id,
	fact_physical_name,
	x_dim_id,
	x_dim_name,
	fk_column_physical_name);

commit;

END IF;


EXCEPTION

  WHEN OTHERS THEN
	RAISE;
/*
	v_ErrorCode := SQLCODE;
	v_ErrorText := SUBSTR(SQLERRM, 1, 200);


--	Log error message into edw_error_log table

        x_message :=   'Oracle error occured.
			Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;

        edw_sec_util.log_error(x_object_name, x_object_type, null, null, x_message);

	commit;
*/


END disable_security;







-- This procedure enables security for a reference

PROCEDURE enable_security
(application_short_name varchar2, responsibility_key varchar2,
           fact_physical_name varchar2, fk_column_physical_name varchar2)
IS

  x_object_name			varchar2(30) := 'EDW_SEC_REF.ENABLE_SECURITY';
  x_object_type			varchar2(30) := 'Enable Security Procedure';

  v_Errorcode			number;
  v_ErrorText			varchar2(200);

  x_message			varchar2(2000);


  x_appl_id             number;
  x_resp_id             number;
  x_fact_id 		number;
  x_dim_id             number;

  x_rec_count		number;

  x_app_name		varchar2(50);
  x_resp_key		varchar2(30);

BEGIN

x_app_name := application_short_name;
x_resp_key :=responsibility_key;


select application_id into x_appl_id from fnd_application_vl
where application_short_name =  x_app_name;

select responsibility_id into x_resp_id from fnd_responsibility_vl
where responsibility_key = x_resp_key
and application_id = x_appl_id;

select distinct fact_id into x_fact_id from edw_sec_fact_info_t
where fact_name = fact_physical_name;

select dim_id into x_dim_id from edw_sec_fact_info_t
where fact_name = fact_physical_name
and fk_col_name = fk_column_physical_name;

-- Delete Row

Delete from edw_sec_ref_info_t
where appl_id = x_appl_id
and resp_id = x_resp_id
and fact_id = x_fact_id
and fk_col_name = fk_column_physical_name;

commit;


EXCEPTION

  WHEN OTHERS THEN
	RAISE;
/*
	v_ErrorCode := SQLCODE;
	v_ErrorText := SUBSTR(SQLERRM, 1, 200);


--	Log error message into edw_error_log table

        x_message :=   'Oracle error occured.
			Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;

        edw_sec_util.log_error(x_object_name, x_object_type, null, null, x_message);

	commit;
*/


END enable_security;



END edw_sec_ref;

/
