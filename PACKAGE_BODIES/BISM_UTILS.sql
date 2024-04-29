--------------------------------------------------------
--  DDL for Package Body BISM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BISM_UTILS" AS
/* $Header: bibutilb.pls 120.2 2006/04/03 05:24:05 akbansal noship $ */
function get_guid
return raw
is
oid raw(16);
begin
select sys_guid() into oid from dual;
return oid;
end;

function get_database_user return varchar2
is
user varchar2(64);
begin
select sys_context('userenv','session_user') into user from dual;
return user;
end;

function get_current_user_id return raw
is
id raw(16);
begin
-- select sys_context('bism_session','current_user_id') into id from dual;
return id;
end;

function init_user(user varchar2) return raw
is
sub_id raw(16);
oid raw(16);
priv bism_permissions.privilege%type;
begin

--make sure there is a root folder
begin
select object_id into oid from bism_objects where folder_id = '30' and object_name = 'ROOT' and user_visible = 'Y';
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.ROOT_NOT_FOUND,'Root folder not found');
end;

-- make sure that the user is internally identified (we need SUBJECT_ID)
begin
select subject_id into sub_id from bism_subjects where subject_name = user ;
-- bism_context.set_user(sub_id);
-- select sys_context('bism_session','current_user_id') into sub_id from dual;
exception
when no_data_found then
-- renumber the error messages later..
raise_application_error(BISM_ERRORCODES.USER_NOT_IDENTIFIED,'User could not be identified',true);
when too_many_rows then
raise_application_error(BISM_ERRORCODES.USER_EXISTS_MULTIPLE_TIMES,'User exists more than once',true);

end;

--lastly make sure that the user has atleat list privilege on the root
begin
select privilege into priv from bism_permissions where subject_id=sub_id and object_id='31';
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for root folder');
end;

if priv < 10 then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'User does not have enough privileges for root folder');
else
return sub_id;
end if;

end;


function get_object_ids_and_time(num number,current_time out nocopy date)
return bism_object_ids
is
oid raw(16);
ids bism_object_ids := bism_object_ids();
begin
for i in 1..num loop
select sys_guid() into oid from dual;
ids.extend();
ids(i) := oid;
end loop;
select sysdate into current_time from dual;
return ids;
end;

function get_object_ids_and_time_30(num number,current_time out nocopy date)
return RAW
is
oid raw(16);
ids raw(32000);
begin
-- the caller shouldn't ask for more than 2000 ids at a time
select sysdate into current_time from dual;
if num > 2000 then
   return null;
end if;
for i in 1..num loop
select sys_guid() into oid from dual;
ids := ids || oid;
end loop;
return ids;
end;

function get_time_in_hundredth_sec
return varchar2
is
begin
return to_char(dbms_utility.get_time());
end;

end bism_utils;

/
