--------------------------------------------------------
--  DDL for Package Body BISM_ACCESS_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BISM_ACCESS_CONTROL" AS
/* $Header: bibaclb.pls 115.4 2004/02/13 00:34:33 gkellner noship $ */

function check_list_access(fid raw,myid raw)
return varchar2
is
priv number(2):=0;
name bism_objects.object_name%type;
begin

-- resolve folder path,getUserPrivilege,checkUserPrivilege calls this function
-- cheks to see if the specified user has at least
-- list access to the specified folder

select max(privilege) into priv from bism_permissions where
object_id = fid and subject_id in
(
select group_id from bism_groups where user_id = myid
);

if priv is null then
begin
select object_name into name from bism_objects where object_id = fid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for folder');
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.FOLDER_NOT_FOUND,'Folder not found');
end;
end if;

if priv >= 10 then
return 'y';
else
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Insufficient privileges');
end if;
exception
when no_data_found then
return 'n';
end;

function check_ins_access(fid raw,myid raw)
return varchar2
is
name bism_objects.object_name%type;
priv number(2):=0;
begin

-- always look at the folder id and see if the folder allows this
-- object to be inserted (this object can be either be a folder
-- or an object - it does not matter)
select max(privilege) into priv from bism_permissions where
object_id = fid and subject_id in
(
select group_id from bism_groups where user_id = myid
);

if priv is null then
begin
select object_name into name from bism_objects where object_id = fid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for folder');
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.FOLDER_NOT_FOUND,'Folder not found');
end;
end if;

if priv >= 30 then
return 'y';
else
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Insufficient privileges');
end if;
exception
when no_data_found then
return 'n';
end;


function check_upd_access(oid raw,fid raw,is_record_a_folder varchar2,curr_user_id raw)
return varchar2
is
priv number(2):=0;
thisid raw(16);
name bism_objects.object_name%type;
begin


if is_record_a_folder = 'Y' OR is_record_a_folder = 'y' then
thisid := oid;--if curr selection is a folder, fine lets look up access on folder
else
thisid := fid;-- if current record is an object, walk up to its parent folder
end if;

select max(privilege) into priv from bism_permissions where
object_id = thisid and subject_id in
(
select group_id from bism_groups where user_id = curr_user_id
);

if priv is null then
begin
select object_name into name from bism_objects where object_id = thisid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for folder');
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.FOLDER_NOT_FOUND,'Folder not found');
end;
end if;

if priv >= 40 then
return 'y';
else
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Insufficient privileges');
end if;

exception
when no_data_found then
dbms_output.put_line('Exception occurred - No Data Found');
return 'n';

end;


function check_read_access(oid raw,fid raw,current_selection_is_folder varchar2,curr_user_id raw)
return varchar2
is
priv number(2):=0;
tempid raw(16);
name bism_objects.object_name%type;
begin

if current_selection_is_folder = 'Y' OR current_selection_is_folder = 'y' then
tempid := oid;
else
tempid := fid;
end if;

select max(privilege) into priv from bism_permissions where
object_id = tempid and subject_id in
(
select group_id from bism_groups where user_id = curr_user_id
);

if priv is null then
begin
select object_name into name from bism_objects where object_id = tempid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for folder');
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.FOLDER_NOT_FOUND,'Folder not found');
end;
end if;

if priv >= 20 then
return 'y';
else
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Insufficient privileges');
end if;
exception
when no_data_found then
return 'n';

end;


function check_del_access(oid raw,fid raw,is_folder varchar2,name varchar2,curr_user_id raw)
return varchar2
is
c1 number;
c2 number;
priv number(2):=0;
tempid bism_objects.object_id%type;
fname bism_objects.object_name%type;
begin

if is_folder = 'N' OR is_folder = 'n' then
-- if the record is an object, check its folder privilege
-- unbind() enters this block
tempid := fid;
else
-- if the selected record is a folder, use its oid
tempid := oid;
end if;


select max(privilege) into priv from bism_permissions
where object_id = tempid and subject_id in
(
select group_id from bism_groups where user_id = curr_user_id
);


if priv is null then
begin
select object_name into fname from bism_objects where object_id = tempid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for folder');
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.FOLDER_NOT_FOUND,'Folder not found');
end;
end if;

if priv >=40  then
return 'y';
else
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Insufficient privileges');
end if;
exception
when no_data_found then
dbms_output.put_line('Exception occurred - No Data Found');
return 'n';

end;


function check_fullcontrol_access(oid raw,myid raw)
return varchar2
is
priv number(2):=0;
name bism_objects.object_name%type;
begin
-- this function mus be called only on a folder
select max(privilege) into priv from bism_permissions where
object_id = oid and subject_id in
(
select group_id from bism_groups where user_id = myid
);

if priv is null then
begin
select object_name into name from bism_objects where object_id = oid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for folder');
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.FOLDER_NOT_FOUND,'Folder not found');
end;
end if;

if priv >= 50 then
return 'y';
else
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Insufficient privileges');
end if;
exception
when no_data_found then
dbms_output.put_line('Exception occurred - No Data Found');
return 'n';

end;

function check_show_entries_access(oid raw,myid raw)
return varchar2
is
priv number(2):=0;
name bism_objects.object_name%type;
oname bism_objects.object_name%type;
begin

-- this function must be called only on a folder
-- for now entries() is the only method calling this

select max(privilege) into priv from bism_permissions where
object_id = oid and subject_id in
(
select group_id from bism_groups where user_id = myid
);

if priv is null then
begin
select object_name into name from bism_objects where object_id = oid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for folder');
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.FOLDER_NOT_FOUND,'Folder not found');
end;
end if;

-- to list the entries on a folder, the caller should have atleast the
-- LIST access. Originally I have coded it in such a way that the caller
-- needed to have FULLCONTROL (50) but then we found that NT allows the
-- user with LIST access to see the AclEntries on a folder, so Henry and I
-- decided to change the behavior here to be compliant with NT
--  now I only check for priv of 10
if priv >= 10 then
return 'y';
else
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES, 'Insufficient privileges to show entries');
end if;
exception
when no_data_found then
begin
select object_name into oname from bism_objects where object_id = oid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for folder');
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.FOLDER_NOT_FOUND,'Folder not found');
end;

return 'n';

end;


function dummy_op(oid raw,myid raw)
return varchar2
is
begin
return 'y';
end;

function dummy_op2(oid raw,fid raw,current_selection_is_folder varchar2,myid raw)
return varchar2
is
begin
return 'y';
end;

end bism_access_control;

/
