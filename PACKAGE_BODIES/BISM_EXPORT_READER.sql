--------------------------------------------------------
--  DDL for Package Body BISM_EXPORT_READER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BISM_EXPORT_READER" AS
/* $Header: bibexpb.pls 120.2 2006/04/03 05:21:58 akbansal noship $ */
PROCEDURE delete_objects(a_timeinsecs integer)
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
-- delete objects from local cache
EXECUTE IMMEDIATE 'delete from bism_export_temp where to_char(time_created, ''DD-MON-YY HH24.MI.SS'') < :1' using v_temp;
-- we do not want to delete from actual table because an adversary having access (EXECUTE priv)
-- to BISM_EXPORT_READER package can potentially wipe out all objects
--
-- delete from bism_export where to_char(time_created, 'DD-MON-YY HH24.MI.SS') < v_temp;
COMMIT;

END;


PROCEDURE delete_object(a_gname raw,a_guid raw,a_filename nvarchar2)
IS
a_gname_is_not_null BOOLEAN := FALSE;
a_guid_is_not_null BOOLEAN := FALSE;
a_filename_is_not_null BOOLEAN := FALSE;
BEGIN
IF  a_gname IS NOT NULL THEN
a_gname_is_not_null := TRUE;
ELSE
-- GNAME MUST ALWAYS BE THERE, ELSE MAKE IT A NO-OP
return;
END IF;

IF a_guid IS NOT NULL THEN
a_guid_is_not_null := TRUE;
END IF;

IF a_filename IS NOT NULL THEN
a_filename_is_not_null := TRUE;
END IF;

-- NOTE : IT IS OK to delete objects from bism_export as long as the user provides
-- GNAME (really guid). Since this parameter is hard to guess, if user presents this
-- parameter, we trust him and delete the matching object (not all)  from bism_export

IF  a_gname_is_not_null = TRUE AND a_guid_is_not_null = true AND a_filename_is_not_null = TRUE THEN
DELETE FROM BISM_EXPORT WHERE group_name= a_gname AND group_id = a_guid AND file_name = a_filename;
EXECUTE IMMEDIATE 'DELETE FROM BISM_EXPORT_TEMP WHERE group_name= :1 AND group_id = :2 AND file_name = :3' using a_gname , a_guid, a_filename;
ELSIF  a_gname_is_not_null = TRUE AND   a_filename_is_not_null = true THEN
DELETE FROM BISM_EXPORT WHERE group_name= a_gname AND file_name = a_filename;
EXECUTE IMMEDIATE 'DELETE FROM BISM_EXPORT_TEMP WHERE group_name= :1 AND file_name = :2' using a_gname , a_filename;
ELSIF a_gname_is_not_null = TRUE THEN
DELETE FROM BISM_EXPORT WHERE group_name= a_gname;
EXECUTE IMMEDIATE 'DELETE FROM BISM_EXPORT_TEMP WHERE group_name= :1' using a_gname;
END IF;

COMMIT;
END;


FUNCTION get_object(a_gname in raw,a_guid in out nocopy raw, a_filename in nvarchar2)
RETURN SchemaCurType
IS
 v_rc SchemaCurType;
 v_clob bism_export.text%TYPE;
 v_temp_clob bism_export.text%TYPE;
 v_read_amount     integer;
 v_read_offset     integer;
 v_buffer          nvarchar2(32767);
 a_gname_is_not_null BOOLEAN := FALSE;
 a_guid_is_not_null BOOLEAN := FALSE;
 a_filename_is_not_null boolean := FALSE;
 v_publishdata VARCHAR2(512);
 v_query VARCHAR2(256);

BEGIN

IF  a_gname IS NOT NULL THEN
a_gname_is_not_null := TRUE;
ELSE
-- GNAME MUST ALWAYS BE THERE, MAKE IT A No-Op OTHERWISE
a_guid := null;
return v_rc;
END IF;

IF a_guid IS NOT NULL THEN
a_guid_is_not_null := TRUE;
END IF;

IF a_filename IS NOT NULL THEN
a_filename_is_not_null := TRUE;
END IF;

IF  a_gname_is_not_null = TRUE AND a_guid_is_not_null = true AND a_filename_is_not_null = true THEN

v_publishdata := 'INSERT into BISM_EXPORT_TEMP(GROUP_NAME, GROUP_ID, FILE_NAME, TIME_CREATED, TEXT, BINARYDATA) '||
                  'values (:1,:2,:3, '||
									'(SELECT time_created FROM bism_export WHERE '||
   										'group_name = :4 and '||
	 										'group_id = :5 AND ' ||
	 										'file_name = :6 ),'||
	  							'(SELECT text FROM bism_export WHERE '||
   										'group_name = :7 and '||
	 										'group_id = :8 AND ' ||
	 										'file_name = :9 ),'||
                  '(SELECT binarydata FROM bism_export WHERE '||
   										'group_name = :10 and '||
	 										'group_id = :11 AND ' ||
	 										'file_name = :12 ) )';


v_query := 'SELECT text,binarydata FROM BISM_EXPORT_TEMP WHERE '||
						'group_name = '||''''|| a_gname ||''''||' and '||
						'group_id = '|| '''' || a_guid || ''''||' and '||
						'file_name = '|| '''' || a_filename || '''';


begin

EXECUTE IMMEDIATE v_publishdata using a_gname, a_guid, a_filename, a_gname, a_guid, a_filename,a_gname, a_guid, a_filename,a_gname, a_guid, a_filename;
EXCEPTION
WHEN OTHERS THEN
IF SQLCODE = -00942 THEN
Raise_Application_Error(-20900,'Temporary Table does not not exist');
END IF;
END;


ELSIF a_gname_is_not_null = TRUE and a_filename_is_not_null = true THEN
v_publishdata := 'INSERT into BISM_EXPORT_TEMP(GROUP_NAME, GROUP_ID, FILE_NAME, TIME_CREATED, TEXT, BINARYDATA) '||
	 								'values (:1,null,:2, '||
	 								'(select time_created from bism_export WHERE '||
   								'group_name = :3 and file_name =  :4),'||
	  							'(SELECT text FROM bism_export WHERE '||
   								'group_name = :5 and '||
	 								'file_name =  :6),'||
                  '(SELECT binarydata FROM bism_export WHERE '||
   								'group_name = :7 and '||
	 								'file_name =  :8))';

v_query := 'SELECT text,binarydata FROM BISM_EXPORT_TEMP WHERE '||
						'group_name = '|| '''' || a_gname||''''||' and '||
						'file_name = '|| '''' || a_filename || '''';

SELECT group_id into a_guid FROM BISM_EXPORT WHERE group_name = a_gname and file_name = a_filename;


begin
EXECUTE IMMEDIATE v_publishdata using a_gname, a_filename,a_gname, a_filename, a_gname, a_filename,a_gname, a_filename;
EXCEPTION
WHEN OTHERS THEN
IF SQLCODE = -00942 THEN
Raise_Application_Error(-20900,'Temporary Table does not not exist');
END IF;
END;

ELSIF a_gname_is_not_null = TRUE THEN
-- THIS CASE SHOULD NEVER OCCUR, GNAME AND FILENAME ARE ALWAYS PRESENT
v_publishdata := 'INSERT into BISM_EXPORT_TEMP(GROUP_NAME, GROUP_ID, FILE_NAME, TIME_CREATED, TEXT, BINARYDATA) '||
	 								'values (:1,null,null, '||
	 								'(SELECT time_created FROM bism_export WHERE '||
   								'group_name = :2), '||
	  							'(SELECT text FROM bism_export WHERE '||
   								'group_name = :3), null)';

v_query := 'SELECT text FROM BISM_EXPORT_TEMP WHERE '||
						'group_name = '|| '''' || a_gname||'''';

SELECT group_id into a_guid FROM BISM_EXPORT WHERE group_name = a_gname ;

begin
EXECUTE IMMEDIATE v_publishdata using a_gname, a_gname,a_gname;
EXCEPTION
WHEN OTHERS THEN
IF SQLCODE = -00942 THEN
Raise_Application_Error(-20900,'Temporary Table does not not exist');
END IF;
END;

END IF;



OPEN v_rc FOR v_query;

RETURN v_rc;
END;

END;

/
