--------------------------------------------------------
--  DDL for Package Body BISM_EXPORT_WRITER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BISM_EXPORT_WRITER" 
/* $Header: bibexpwb.pls 120.2 2006/04/03 05:23:02 akbansal noship $ */
AS
FUNCTION get_guid RETURN raw
IS
oid1 raw(16);
oid2 raw(16);
BEGIN

select sys_guid() into oid1 from dual;
select sys_guid() into oid2 from dual;
return oid1||oid2;

END;

FUNCTION insert_object(a_gname raw,a_guid raw, a_filename nvarchar2, a_data nclob,a_binary_data blob)
RETURN timestamp
IS
v_time timestamp;
v_clob BISM_EXPORT.text%TYPE;
v_blob  BISM_EXPORT.binarydata%TYPE;
BEGIN
IF a_data IS NULL AND a_binary_data IS NULL THEN
-- nothing to insert
RETURN NULL;
END IF;

v_time:= SYSDATE;

IF a_data IS NOT NULL THEN
BEGIN
SELECT text into v_clob FROM BISM_EXPORT WHERE
group_name=a_gname AND
group_id = a_guid AND
file_name = a_filename for update;
-- write piece wise
dbms_lob.write ( v_clob, dbms_lob.getlength(a_data), dbms_lob.getlength(v_clob)+1, a_data );
EXCEPTION WHEN
No_Data_Found then
-- data does not exist yet, create it
-- insert null for binary data (BLOB)
INSERT INTO BISM_EXPORT (GROUP_NAME, GROUP_ID, FILE_NAME, TIME_CREATED, TEXT, BINARYDATA) VALUES(a_gname,a_guid,a_filename,v_time,a_data,null);
END;
ELSIF a_binary_data IS NOT NULL THEN
BEGIN
SELECT binarydata into v_blob FROM BISM_EXPORT WHERE
group_name=a_gname AND
group_id = a_guid AND
file_name = a_filename for update;
-- write piece wise
dbms_lob.write ( v_blob, dbms_lob.getlength(a_binary_data), dbms_lob.getlength(v_blob)+1, a_binary_data );
EXCEPTION WHEN
No_Data_Found then
-- data does not exist yet, create it
-- insert null for text data (CLOB)
INSERT INTO BISM_EXPORT (GROUP_NAME, GROUP_ID, FILE_NAME, TIME_CREATED, TEXT, BINARYDATA) VALUES(a_gname,a_guid,a_filename,v_time,null,a_binary_data);
END;

END IF;

COMMIT;

RETURN v_time;
END;

PROCEDURE delete_object(a_gname raw,a_guid raw, a_filename nvarchar2)
IS
a_gname_is_not_null BOOLEAN := FALSE;
a_guid_is_not_null BOOLEAN := FALSE;
a_filename_is_not_null boolean := FALSE;
BEGIN
IF  a_gname IS NOT NULL THEN
a_gname_is_not_null := TRUE;
END IF;

IF a_guid IS NOT NULL THEN
a_guid_is_not_null := TRUE;
END IF;

IF a_filename IS NOT NULL THEN
a_filename_is_not_null := TRUE;
END IF;


IF  a_gname_is_not_null = TRUE AND a_guid_is_not_null = true AND a_filename_is_not_null = true THEN
DELETE FROM BISM_EXPORT WHERE
group_name= a_gname AND
group_id = a_guid AND
file_name=a_filename;
ELSIF a_gname_is_not_null = TRUE and a_filename_is_not_null = true THEN
DELETE FROM BISM_EXPORT WHERE
group_name= a_gname AND
file_name=a_filename;
ELSIF a_gname_is_not_null = TRUE THEN
DELETE FROM BISM_EXPORT WHERE
group_name= a_gname;
END IF;

COMMIT;
END;

PROCEDURE delete_objects(a_timeinsecs integer )
IS
v_secs INTEGER;
v_sec integer;
v_min integer;
v_hour integer;
v_num integer;
v_timestamp timestamp;
v_temp varchar2(30);
BEGIN


IF a_timeinsecs = 0 THEN
-- nothing to do
RETURN;
END IF;

-- time in secs since the beginning of the day
SELECT
TO_CHAR(systimestamp,'HH24') * 60*60+
+ TO_CHAR(systimestamp,'MI') * 60
+ TO_CHAR(systimestamp,'SS') into v_secs FROM dual;

v_secs := v_secs - a_timeinsecs;

-- reconstruct the time after substracting the time duration
v_sec := MOD (v_secs, 60);
v_min := MOD (trunc (v_secs/60), 60);
v_hour := MOD (trunc (v_secs/3600), 24);
-- stage it as character data
v_temp := to_char(sysdate,'DD-MON-YY') || ' '|| v_hour||'.'||v_min||'.'||v_sec;
-- create timestamp

SELECT to_timestamp(v_temp, 'DD-MON-YY HH24.MI.SS') into v_timestamp from dual;
-- delete the objects

delete from bism_export where to_char(time_created, 'DD-MON-YY HH24.MI.SS') < v_temp;
COMMIT;

END;


FUNCTION get_object(a_gname in raw,a_guid in out nocopy raw, a_filename in nvarchar2)
RETURN SchemaCurType
IS
 v_rc SchemaCurType;
 v_clob bism_export.text%TYPE;
 a_gname_is_not_null BOOLEAN := FALSE;
 a_guid_is_not_null BOOLEAN := FALSE;
 a_filename_is_not_null boolean := FALSE;
BEGIN

IF  a_gname IS NOT NULL THEN
a_gname_is_not_null := TRUE;
END IF;

IF a_guid IS NOT NULL THEN
a_guid_is_not_null := TRUE;
END IF;

IF a_filename IS NOT NULL THEN
a_filename_is_not_null := TRUE;
END IF;

IF  a_gname_is_not_null = TRUE AND a_guid_is_not_null = true AND a_filename_is_not_null = true THEN
-- no need to fetch groupd_id
OPEN v_rc FOR SELECT text,binarydata FROM BISM_EXPORT WHERE group_name = a_gname  and
group_id = a_guid and file_name = a_filename;
ELSIF a_gname_is_not_null = TRUE and a_filename_is_not_null = true THEN
SELECT group_id into a_guid FROM BISM_EXPORT WHERE group_name = a_gname and file_name = a_filename;
OPEN v_rc FOR SELECT text,binarydata FROM BISM_EXPORT WHERE group_name = a_gname and  file_name = a_filename;
ELSIF a_gname_is_not_null = TRUE THEN
SELECT group_id into a_guid FROM BISM_EXPORT WHERE group_name = a_gname;
OPEN v_rc FOR SELECT text,binarydata FROM BISM_EXPORT WHERE group_name = a_gname and file_name = a_filename;
END IF;
RETURN v_rc;
END;

END;

/
