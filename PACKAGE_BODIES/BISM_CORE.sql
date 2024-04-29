--------------------------------------------------------
--  DDL for Package Body BISM_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BISM_CORE" as
/* $Header: bibcoreb.pls 120.3 2006/04/03 05:20:50 akbansal noship $ */

function get_next_element(str varchar2,delimiter varchar2,startpos in out nocopy integer)
return varchar2
is
len integer := 0;
newstr varchar2(32767) := '';
endpos integer := 0;
begin

-- caller must make sure that str is not null, we dont want to do that
-- check here because this could be called several times

endpos := instr(str,delimiter,startpos);
if endpos <> 0 then
len := endpos - startpos;
newstr := substr(str,startpos,len);
--dbms_output.put_line('getnextele new str= '||newstr || ' start pos = '||startpos || ' pos = '|| endpos);
startpos := endpos+length(delimiter);
return newstr;
else
if startpos = 1 then
startpos := 0; -- indicate that delimiter is not found
return str;
else
newstr := substr(str,startpos);
startpos := 0;
return newstr;
end if;
end if;
end;

function get_last_object_id(fid raw,path varchar2,startpos in out nocopy integer,myid raw)
return raw
is
oid bism_objects.object_id%type;
typeid bism_objects.object_type_id%type;
ret varchar2(1) := 'n';
newstr varchar2(2000) := '';
len integer:=0;
begin

if startpos = 0 then
    return fid; -- ends the recursion
else
    -- startpos gets updated during this call
    -- when a last name is retreived, get_next_element sets
    -- it to zero, indicating no more elements in the path
    newstr := get_next_element(path,'/',startpos);
end if;

-- len should not be 0 because Java validates the given path
-- and makes sure there are no nulls and empty names constituting the path
-- but if it happens to be zero, throw an exception
len := nvl(length(newstr),0);

if len <> 0 then
    begin
    select object_id,object_type_id into oid,typeid from bism_objects where folder_id = fid and object_name = newstr and user_visible = 'Y';
    ret := bism_core.check_lookup_access(oid,typeid,'Y',myid);
    if ret = 'y' then
        return get_last_object_id(oid,path,startpos,myid);
    end if;
    exception
    when no_data_found then
    raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
    end;
else
raise_application_error(BISM_ERRORCODES.INVALID_FOLDER_PATH,'Invalid atomic name');
end if;

end;


procedure delete_folder(fid raw,myid raw)
is
    ret varchar2(1);
begin
    -- modified by ccchow, check delete access for objects also
    for i in (select object_id,object_name from bism_objects where object_type_id = 100 and user_visible = 'Y' start with object_id = fid connect by folder_id = prior object_id)
	loop
        ret := check_del_access_for_folder(i.object_id,myid);
    end loop;

    delete from bism_objects where object_id = fid and object_type_id = 100 and user_visible = 'Y';
end delete_folder;

procedure delete_folder(fid raw,path varchar2,myid raw)
is
    ret varchar2(1);
    oid bism_objects.object_id%type;
    startpos integer := 1; --must be initd to one
begin
    oid := get_last_object_id(fid,path,startpos,myid);

    -- modified by ccchow, check delete access for objects also
    for i in (select object_id,object_name from bism_objects where object_type_id = 100 and user_visible = 'Y' start with object_id = oid connect by folder_id = prior object_id)
    loop
        ret := check_del_access_for_folder(i.object_id,myid);
    end loop;

    delete from bism_objects where object_id = oid and object_type_id = 100 and user_visible = 'Y';
end delete_folder;

-- new function added to check delete access of all objects within a folder
function check_del_access_for_folder(fid raw,myid raw)
return varchar2
is
    ret varchar2(1);
begin
    -- first check the folder itself
    ret := bism_access_control.check_del_access(fid,null,'Y',null,myid);

	-- now check its children
	for i in (select object_id from bism_objects where folder_id = fid and user_visible = 'Y')
	loop
	    ret := check_obj_del_access(i.object_id,fid,myid);
	end loop;

	return ret;
end check_del_access_for_folder;

-- common routine used by delete_object and check_del_access_for_folder
-- this function checks the access for deleting an object (ccchow)
function check_obj_del_access(oid raw,fid raw,myid raw)
return varchar2
is
    ret varchar2(1);
    have_del_access varchar2(1) := 'n';
    insufficient_privileges EXCEPTION;
    PRAGMA EXCEPTION_INIT(insufficient_privileges, -20400);
begin
    -- check WRITE privilege on object and READ privilege on parent folder
    -- or
    -- check READ privilege on object and FULL CONTROL privilege on parent folder
    begin
        ret := bism_access_control.check_del_access(null,oid,'n',null,myid);
        if ret = 'y' then
            have_del_access := 'y';
        end if;
    exception
    when insufficient_privileges then
        begin
            ret := bism_access_control.check_read_access(null,oid,'n',myid);
            if ret = 'y' then
                ret := bism_access_control.check_fullcontrol_access(fid,myid);
            end if;
        end;
    end;

    if have_del_access = 'y' then
        ret := bism_access_control.check_read_access(null,fid,'n',myid);
    end if;

	return ret;
end check_obj_del_access;

-- modified for object level security (ccchow)
procedure delete_object(fid raw,objname varchar2,myid raw)
is
    typeid  bism_objects.object_type_id%type;
    ret varchar2(1) := 'n';

    -- added for obj level security
	oid  bism_objects.object_id%type;
    have_del_access varchar2(1) := 'n';

    -- new exception used for obj access control (ccchow)
    insufficient_privileges EXCEPTION;
    PRAGMA EXCEPTION_INIT(insufficient_privileges, -20400);
begin
    begin
       -- make sure that the object being delete is not folder
        select object_type_id,object_id into typeid,oid from bism_objects where folder_id = fid and object_name = objname and user_visible='Y';
        if typeid is null then
            raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
        end if;

        if typeid = 100 then
            raise_application_error(BISM_ERRORCODES.CANNOT_UNBIND_FOLDER,'Cannot unbind folder');
        end if;

        -- modified for obj access control (ccchow)
		-- see comments on the new check_obj_del_access routine
        ret := check_obj_del_access(oid,fid,myid);
    exception
    when no_data_found then
        raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
    end;

    -- the following check if condition to be removed
    if ret = 'y' then
        delete from bism_objects where folder_id = fid and object_name = objname and user_visible= 'Y';
        if bism_core.v_auto_commit = TRUE then
          commit;
        end if;
    else
        raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Insufficient privilege');
    end if;
end delete_object;

procedure set_privilege(fid raw,grantor raw,grantee_name varchar2,priv number)
is
p number(2);
ret varchar2(1) := 'n';
sub_id raw(16);
begin

begin
select PRIVILEGE_ID into p from bism_privileges where PRIVILEGE_ID = priv;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.PRIVILEGE_NOT_UNDERSTOOD,'Privilege not understood');
end;

ret := bism_access_control.check_fullcontrol_access(fid,grantor);
if ret = 'y' then
select subject_id into sub_id from bism_subjects where subject_name = grantee_name;
insert into bism_permissions (subject_id,object_id,privilege) values(sub_id,fid,priv);
if bism_core.v_auto_commit = TRUE then
  commit;
end if;

end if;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.USER_NOT_FOUND,'Grantee not found in BISM_SUBJECTS table');
end set_privilege;



procedure delete_folder_wo_security(fid raw,myid raw)
is
begin
delete from bism_objects where object_id = fid and object_type_id = 100 and user_visible = 'Y';
end;

-- not used in 3.0, see new check_lookup_access method
function check_lookup_access(oid raw,fid raw,objtype number,visible varchar2,myid raw)
return varchar2
is
begin
if visible = 'N' then
return 'y';
end if;
-- if the object is a folder, then check for list access else look for
-- read access on the folder containing the object
-- Originally it was coded to check for READ access regardless of
-- object typebut then I am introducing this change in version 26
-- the reason for this change is because UI performs lookup operation
-- (and NOT list) to show folders and if folder only has LIST access
-- getObject/lookup on that folder will fail
-- Henry and I decided to change this behavior
if objtype = 100 then
return bism_access_control.check_list_access(oid,myid);
else
-- modified to check access of object instead of folder
return bism_access_control.check_read_access(null,fid,'n',myid);
end if;
end;

-- new check_lookup_access for object level security (ccchow)
function check_lookup_access(oid raw,objtype number,visible varchar2,myid raw)
return varchar2
is
begin
    if visible = 'N' then
        return 'y';
    end if;

    if objtype = 100 then
        return bism_access_control.check_list_access(oid,myid);
    else
        return bism_access_control.check_read_access(null,oid,'n',myid);
    end if;
end check_lookup_access;

function prepare_rebind(fid raw,oname varchar2,myid raw,ids out nocopy bism_object_ids, current_time out nocopy date,num number,status out nocopy integer)
return raw
is
typeid bism_objects.object_type_id%type;
oid bism_objects.object_id%type;
tempid bism_objects.object_id%type;
foldername  bism_objects.object_name%type;
ret varchar2(1) := 'n';
begin
ids := bism_object_ids();
-- make sure the folder exists and that the user has delete
-- privilege on it
begin

select object_id into oid from bism_objects where object_id = fid;
--OK, now check the privilege
ret := bism_access_control.check_del_access(null,fid,'n',null,myid);
exception
when no_data_found then
status := BISM_CONSTANTS.PARENT_FOLDER_NOT_FOUND;
return null;
end;

begin
if ret = 'y' then
-- this user has access to the folder, let's see if object exists
select object_id,object_type_id into oid,typeid from bism_objects where folder_id = fid and object_name = oname and user_visible='Y';
-- ok the object exists


if typeid <> 100 then

-- NOTE : we need to delete the relationships between this object and its
-- first level named objects
delete from bism_aggregates where container_id = oid;

-- delete if it is an object and return the top level object_id
--delete from bism_objects where folder_id = fid and user_visible= 'Y' and object_name = oname;
--leave the top level object alone but delete every anonymous object underneath it

-- because of cascade effect all the anonymous sub objects of the
-- top level object will be deleted
delete from bism_objects where container_id = oid;

--everything went well so fetch ids and return it
begin
for i in 1..num-1 loop
select sys_guid() into tempid from dual;
ids.extend();
ids(i) := tempid;
end loop;
select sysdate into current_time from dual;
end;
status :=BISM_CONSTANTS.IS_OBJECT;
return oid;
else -- type is 100 , i.e it's a folder !
-- dont delete if it is a folder and return its object_id
status :=BISM_CONSTANTS.IS_FOLDER;
return oid;
end if;
-- do commit from jdbc
else
select object_name into foldername from bism_objects where object_id = fid;
status := BISM_CONSTANTS.INSUFFICIENT_PRIVILEGES;
return null;
end if;
exception
when no_data_found then
status := BISM_CONSTANTS.DATA_NOT_FOUND;
-- object does not exist, but we need to populate ids so that rebind
-- can come back to bind the object


begin
for i in 1..num loop
select sys_guid() into tempid from dual;
ids.extend();
ids(i) := tempid;
end loop;
select sysdate into current_time from dual;
end;
return null;
end;

end;

function prepare_rebind_30(fid raw,oname varchar2,myid raw,ids out nocopy raw, current_time out nocopy date,num number,status out nocopy integer)
return raw
is
typeid bism_objects.object_type_id%type;
oid bism_objects.object_id%type;
tempid bism_objects.object_id%type;
foldername  bism_objects.object_name%type;
ret varchar2(1) := 'n';
begin
--ids := bism_object_ids();
-- the caller shouldn't ask for more than 2000 ids at a time
--select sysdate into current_time from dual;
--if num > 2000 then
--   return null;
-- make sure the folder exists and that the user has delete
-- privilege on it
begin

select object_id into oid from bism_objects where object_id = fid;
--OK, now check the privilege
ret := bism_access_control.check_del_access(null,fid,'n',null,myid);
exception
when no_data_found then
status := BISM_CONSTANTS.PARENT_FOLDER_NOT_FOUND;
return null;
end;

begin
if ret = 'y' then
-- this user has access to the folder, let's see if object exists
select object_id,object_type_id into oid,typeid from bism_objects where folder_id = fid and object_name = oname and user_visible='Y';
-- ok the object exists


if typeid <> 100 then

-- NOTE : we need to delete the relationships between this object and its
-- first level named objects
delete from bism_aggregates where container_id = oid;

-- delete if it is an object and return the top level object_id
--delete from bism_objects where folder_id = fid and user_visible= 'Y' and object_name = oname;
--leave the top level object alone but delete every anonymous object underneath it

-- because of cascade effect all the anonymous sub objects of the
-- top level object will be deleted
delete from bism_objects where container_id = oid;

--everything went well so fetch ids and return it
begin
for i in 1..num-1 loop
select sys_guid() into tempid from dual;
--ids.extend();
--ids(i) := tempid;
ids := ids || tempid;
end loop;
select sysdate into current_time from dual;
end;
status :=BISM_CONSTANTS.IS_OBJECT;
return oid;
else -- type is 100 , i.e it's a folder !
-- dont delete if it is a folder and return its object_id
status :=BISM_CONSTANTS.IS_FOLDER;
return oid;
end if;
-- do commit from jdbc
else
select object_name into foldername from bism_objects where object_id = fid;
status := BISM_CONSTANTS.INSUFFICIENT_PRIVILEGES;
return null;
end if;
exception
when no_data_found then
status := BISM_CONSTANTS.DATA_NOT_FOUND;
-- object does not exist, but we need to populate ids so that rebind
-- can come back to bind the object


begin
for i in 1..num loop
select sys_guid() into tempid from dual;
--ids.extend();
--ids(i) := tempid;
ids := ids || tempid;
end loop;
select sysdate into current_time from dual;
end;
return null;
end;

end;

procedure lookup_folder_wo_security(fid raw,path varchar2,a_objid out nocopy raw,myid raw,startpos in out nocopy integer)
is
    oid bism_objects.object_id%type;
    typeid bism_objects.object_type_id%type;
    ret varchar2(1) := 'n';
    newstr varchar2(2000) := '';
    len integer :=0;
begin
    -- using '\' as delimeter for now, this can be changed
    -- note : the delimeter can be longer than one char
    -- get_next_element will match the delimeter string
    newstr := get_next_element(path,'/',startpos);
    len := nvl(length(newstr),0);
    if len <> 0 then
        begin
            select object_id into oid from bism_objects where folder_id = fid and object_name = newstr and object_type_id = 100 and user_visible = 'Y';

            if startpos <> 0 then
                lookup_folder_wo_security(oid,path,a_objid,myid,startpos);
            else
                a_objid := oid;
            end if;
        exception
        when no_data_found then
            raise_application_error(BISM_ERRORCODES.FOLDER_NOT_FOUND,'Folder not found');
        end;
    else
        raise_application_error(BISM_ERRORCODES.INVALID_FOLDER_PATH,'Invalid atomic name');
    end if;
end lookup_folder_wo_security;


-- new prepare rebind method
function prepare_rebind(fid raw,folder_path varchar2,oname varchar2,myid raw,ids out nocopy bism_object_ids, current_time out nocopy date,num number,status out nocopy integer,parentid out nocopy raw)
return raw
is
    typeid bism_objects.object_type_id%type;
    oid bism_objects.object_id%type;
    tempid bism_objects.object_id%type;
    pos integer := 1;
begin
    ids := bism_object_ids();
    -- make sure the folder exists
    if folder_path is null then
	    parentid := fid;
	else
        begin
            lookup_folder_wo_security(fid,folder_path,parentid,myid,pos);
        exception
        when others then
            status := BISM_CONSTANTS.PARENT_FOLDER_NOT_FOUND;
            return null;
        end;
    end if;

    begin
        -- check if object exists
        select object_id,object_type_id into oid,typeid from bism_objects where folder_id = parentid and object_name = oname and user_visible='Y';

        -- ok the object exists
        if typeid <> 100 then

            -- NOTE : we need to delete the relationships between this object and its
            -- first level named objects
            delete from bism_aggregates where container_id = oid;

            -- delete if it is an object and return the top level object_id
            --delete from bism_objects where folder_id = fid and user_visible= 'Y' and object_name = oname;
            --leave the top level object alone but delete every anonymous object underneath it

            -- because of cascade effect all the anonymous sub objects of the
            -- top level object will be deleted
            delete from bism_objects where container_id = oid;

            --everything went well so fetch ids and return it
            for i in 1..num-1
            loop
                select sys_guid() into tempid from dual;
                ids.extend();
                ids(i) := tempid;
            end loop;
            select sysdate into current_time from dual;

	    	status :=BISM_CONSTANTS.IS_OBJECT;
		    return oid;
        else -- type is 100 , i.e it's a folder !
            -- dont delete if it is a folder and return its object_id
            status :=BISM_CONSTANTS.IS_FOLDER;
            return oid;
        end if;
    exception
        when no_data_found then
        status := BISM_CONSTANTS.DATA_NOT_FOUND;
        -- object does not exist, but we need to populate ids so that rebind
        -- can come back to bind the object

        begin
            for i in 1..num
            loop
                select sys_guid() into tempid from dual;
                ids.extend();
                ids(i) := tempid;
            end loop;
            select sysdate into current_time from dual;
        end;
        return null;
    end;
end prepare_rebind;

-- new prepare rebind method without ADTs
function prepare_rebind_30(fid raw,folder_path varchar2,oname varchar2,myid raw,ids out nocopy raw, current_time out nocopy date,num number,status out nocopy integer,parentid out nocopy raw)
return raw
is
    typeid bism_objects.object_type_id%type;
    oid bism_objects.object_id%type;
    tempid bism_objects.object_id%type;
    pos integer := 1;
begin
    --ids := bism_object_ids();
    -- make sure the folder exists
    if folder_path is null then
	    parentid := fid;
	else
        begin
            lookup_folder_wo_security(fid,folder_path,parentid,myid,pos);
        exception
        when others then
            status := BISM_CONSTANTS.PARENT_FOLDER_NOT_FOUND;
            return null;
        end;
    end if;

    begin
        -- check if object exists
        select object_id,object_type_id into oid,typeid from bism_objects where folder_id = parentid and object_name = oname and user_visible='Y';

        -- ok the object exists
        if typeid <> 100 then

            -- NOTE : we need to delete the relationships between this object and its
            -- first level named objects
            delete from bism_aggregates where container_id = oid;

            -- delete if it is an object and return the top level object_id
            --delete from bism_objects where folder_id = fid and user_visible= 'Y' and object_name = oname;
            --leave the top level object alone but delete every anonymous object underneath it

            -- because of cascade effect all the anonymous sub objects of the
            -- top level object will be deleted
            delete from bism_objects where container_id = oid;

            --everything went well so fetch ids and return it
            for i in 1..num-1
            loop
                select sys_guid() into tempid from dual;
                --ids.extend();
                --ids(i) := tempid;
                ids := ids || tempid;
            end loop;
            select sysdate into current_time from dual;

	    	status :=BISM_CONSTANTS.IS_OBJECT;
		    return oid;
        else -- type is 100 , i.e it's a folder !
            -- dont delete if it is a folder and return its object_id
            status :=BISM_CONSTANTS.IS_FOLDER;
            return oid;
        end if;
    exception
        when no_data_found then
        status := BISM_CONSTANTS.DATA_NOT_FOUND;
        -- object does not exist, but we need to populate ids so that rebind
        -- can come back to bind the object

        begin
            for i in 1..num
            loop
                select sys_guid() into tempid from dual;
                --ids.extend();
                --ids(i) := tempid;
                ids := ids || tempid;
            end loop;
            select sysdate into current_time from dual;
        end;
        return null;
    end;
end prepare_rebind_30;

-- modified for object level security
function check_modify_attrs_access(fid raw,objname varchar2,myid raw,status out nocopy number,callerid in number)
return varchar2
is
    ret varchar2(1) := 'n';
    oid bism_objects.object_id%type;
    type_id bism_objects.object_type_id%type;

    -- added for obj access control (ccchow)
    have_upd_access varchar2(1) := 'n';
    insufficient_privileges EXCEPTION;
    PRAGMA EXCEPTION_INIT(insufficient_privileges, -20400);
 begin
    -- I am not check for status any more
    status := BISM_CONSTANTS.OK;

    -- callerid = 0 represents rename java function
    -- callerid = 1 represents modiAttributes java function


    begin
        select object_type_id,object_id into type_id,oid from bism_objects where folder_id = fid and object_name = objname and user_visible = 'Y';

        if type_id = 100 then
            -- if the object being renamed is a folder, we have two scenarios:
            -- 1. if the parent folder has ADD_FOLDER (ADD and READ in NT) privilege
            -- and subfolder (being renamed) has WRITE privilege, then RENAME is allowed
            -- or --
            -- 2. if the parent folder has FULL CONTROL privilege and subfolder (being renamed)
            -- has at least LIST privilege, then RENAME is allowed

            if callerid = 0 then
                ret := 'n';
                -- check if user has at least ADD_FOLDER (Add and Read on NT) priv on
                -- parent folder
                -- note : ADD_FOLDER privilege is the minimum privilege required
                -- on parent folder for this operation to succeed, if this throws
                -- exception, let it bubble up
                ret := bism_access_control.check_ins_access(fid,myid);
                begin
                  -- OK, if user has ADD_FOLDER on parent, check to see if subfolder has
                  -- at least WRITE (scenario 1 described above)
                  -- if subfolder does not have WRITE, then test scenario 2
                  -- which is checking  parent folder for FULL CONTROL,
                  -- and sub folder for at least LIST privilege
                  -- scenario 2 handled in exception handler
                  if ret = 'y' then
                    have_upd_access := bism_access_control.check_upd_access(oid,null,'Y',myid) ;
                    return have_upd_access;
                  end if;
                exception
                when insufficient_privileges then
                    -- check if the user has full control on parent folder
                    ret := bism_access_control.check_fullcontrol_access(fid,myid) ;
                    -- if so, then as long as he has at least LIST privilege on subfolder,
                    -- he can rename the sub folder
                    if ret = 'y' then
                      return bism_access_control.check_list_access(oid,myid);
                    end if;
                end;
              end if;
            if callerid = 1 then
                -- if it is a folder, then user needs INSERT priv on that folder
                -- parent folder priv do not play a role
                return bism_access_control.check_ins_access(oid,myid) ;
            end if;
        else
		    if callerid = 0 then
       	        -- renaming of an object
                -- modified for obj access control (ccchow)
                -- check WRITE privilege on object and INSERT privilege on parent folder
			    -- or
                -- check READ privilege on object and FULL CONTROL privilege on parent folder
                begin
                    ret := bism_access_control.check_upd_access(null,oid,'n',myid);
                    if ret = 'y' then
                        have_upd_access := 'y';
                    end if;
                 exception
                    when insufficient_privileges then
                    begin
                        ret := bism_access_control.check_read_access(null,oid,'n',myid);
                        if ret = 'y' then
                            ret := bism_access_control.check_fullcontrol_access(fid,myid);
                        end if;
                    end;
                end;

                if have_upd_access = 'y' then
                    ret := bism_access_control.check_ins_access(fid,myid);
                end if;
            end if;

		    if callerid = 1 then
       	        -- modifying attributes of an object
                -- modified for obj access control (ccchow)
                -- check WRITE privilege on object and READ privilege on parent folder
			    -- or
                -- check READ privilege on object and FULL CONTROL privilege on parent folder
                begin
                    ret := bism_access_control.check_upd_access(null,oid,'n',myid);
                    if ret = 'y' then
                        have_upd_access := 'y';
                    end if;
                exception
                    when insufficient_privileges then
                    begin
                        ret := bism_access_control.check_read_access(null,oid,'n',myid);
                        if ret = 'y' then
                            ret := bism_access_control.check_fullcontrol_access(fid,myid);
                        end if;
                    end;
                end;

                if have_upd_access = 'y' then
                    ret := bism_access_control.check_read_access(null,fid,'n',myid);
                end if;
            end if;

			return ret;
        end if;
    exception
    when no_data_found then
        status := BISM_CONSTANTS.DATA_NOT_FOUND;
        raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
    end;
end check_modify_attrs_access;

function get_attributes(p_fid raw, p_objname varchar2, p_myid raw)
return myrctype
is
  v_rc myrctype;
begin
  open v_rc for
    select USER_VISIBLE,OBJECT_TYPE_ID,VERSION,TIME_DATE_CREATED,TIME_DATE_MODIFIED,OBJECT_ID,
		   CONTAINER_ID,FOLDER_ID,
           decode(CREATED_BY,CREATED_BY,(select subject_name from bism_subjects where subject_id = created_by and subject_type='u'),null),
		   decode(LAST_MODIFIED_BY,LAST_MODIFIED_BY,(select subject_name from bism_subjects where subject_id = LAST_MODIFIED_BY and subject_type='u'), null),
		   OBJECT_NAME,TITLE,APPLICATION,DATABASE,
		   DESCRIPTION,KEYWORDS,APPLICATION_SUBTYPE1,COMP_SUBTYPE1,COMP_SUBTYPE2,COMP_SUBTYPE3,TIME_DATE_LAST_ACCESSED
	from bism_objects
	where 'y' = bism_core.check_get_attrs_access(p_fid,p_objname,p_myid)
	and user_visible = 'Y'
	and folder_id = p_fid
	and object_name = p_objname;
  return v_rc;
end;

function check_get_attrs_access(fid raw,objname varchar2,myid raw)
return varchar2
is
type_id bism_objects.object_type_id%type;
begin

begin
-- determine the type of object the user is trying to do getAttributes on
-- if folder, do not do any security check
-- if it is an object, then the user MUST have atleast LIST priv on the
-- parent folder
select object_type_id into type_id from bism_objects where folder_id = fid and object_name = objname and user_visible = 'Y';
exception
when no_data_found then
-- we dont care whether th eobject is not found or folder is not found
raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
end;

-- if the object is not a folder, then
-- check to see if the user has atleast LIST access to the parent folder
-- (previously we used to check for read access on the folder
-- but then we decided to change it to list access only because
-- NT allows users with LIST access see the props of folder as well
-- as props of object within the folder)

if type_id <> 100 then
return bism_access_control.check_list_access(fid,myid) ;
else
-- this is an important change, according to NT, if the object is a folder
-- DO NOT CHECK for any privileges, every user is allowed to see the attribs
-- on a folder whether or not they have any prvbs on that folder
return 'y';
end if;

end;

--
-- check_user_privileges
--
function check_user_privileges(p_username varchar2, p_oid raw, p_myid raw)
return number
is
  v_subid bism_subjects.subject_id%type;
  v_priv bism_permissions.privilege%type;
begin
  begin
    select subject_id into v_subid from bism_subjects where subject_name = p_username and subject_type='u';
	exception
	when no_data_found then
	  raise_application_error(-20503,'User not found');
  end;
  begin
    -- could remove acl checking since it has been done when looking up the object id (ccchow)
    select nvl(max(privilege),0) into v_priv from bism_permissions where object_id = p_oid and subject_id in (select group_id from bism_groups where user_id = v_subid);
    exception
	when no_data_found then
	  v_priv := 0;
  end;
  return v_priv;
end;

--
-- entries --
--
function entries(p_oid in raw,p_myid in raw)
return myrctype
is
  v_rc myrctype;
begin
  open v_rc for
	select decode(t1.subject_id, t1.subject_id,
		     (select subject_name from bism_subjects where subject_id = t1.subject_id),
	        null),
	      t1.privilege,
	      t2.subject_type
	from bism_permissions t1,
	    bism_subjects t2
	where 'y' = bism_access_control.check_show_entries_access(p_oid,p_myid)
	and t1.object_id = p_oid
	and t2.subject_id = t1.subject_id;
  return v_rc;
end;

function add_entries(fid in raw,acllist in out nocopy  bism_acl_obj_t,myid in raw,cascade in varchar2,topfolder in varchar2)
return bism_acl_obj_t
is
begin
    return add_entries(fid,acllist,myid,cascade,'n',topfolder,'y');
end;

procedure add_entries_30(fid in raw,acllist in CLOB,myid in raw,cascade in varchar2,topfolder in varchar2, aclseparator in varchar2)
-- function add_entries(fid in raw,acllist in out nocopy  bism_acl_obj_t,myid in raw,cascade in varchar2,topfolder in varchar2)
-- return bism_acl_obj_t
is
begin
    add_entries_30(fid,acllist,myid,cascade,'N',topfolder,'Y',aclseparator);
end;

function remove_entries(fid in raw,acllist in out nocopy  bism_acl_obj_t,myid in raw,cascade in varchar2,topfolder in varchar2)
return bism_chararray_t
is
begin
    return remove_entries(fid,acllist,myid,cascade,'n',topfolder,'y');
end;

function remove_entries_30(fid in raw,acllist in out nocopy CLOB,myid in raw,cascade in varchar2,topfolder in varchar2, aclseparator in varchar2)
return varchar2
is
begin
    return remove_entries_30(fid,acllist,myid,cascade,'N',topfolder,'Y',aclseparator);
end;

function is_src_ancestor_of_target(srcfid raw,tgtfid raw)
return boolean
is
v_var varchar2(1) := 'n';

begin

begin
-- check to see if the target folder is in the path of the source folder
-- if so we cannot move src folder to target folder
-- ex : assume : folder foo contains folder goo
-- user attempts to move foo to goo which is illegal
-- so check to see if target (goo) is in the path of source (foo)
select 'y' into v_var from dual where tgtfid = any ( select object_id from bism_objects where object_type_id = 100  start with object_id = srcfid connect by folder_id = prior object_id);
exception
when no_data_found then
return false;
end;

return true;
end;

procedure move(srcfid raw,tgtfid raw,objname varchar2,myid raw)
is
objid bism_objects.object_id%type:= null;
objtypeid bism_objects.object_type_id%type := 0;
begin

if srcfid = tgtfid then
return;
end if;

begin
-- make sure target folder exists
select object_id,object_type_id into objid,objtypeid from bism_objects where object_id = tgtfid and user_visible = 'Y';
if objtypeid <> 100 then
raise_application_error(BISM_ERRORCODES.TGT_IS_NOT_FOLDER,'Illegal move : Target object is not a folder');
end if;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.TGT_FOLDER_NOT_FOUND,'Target folder not found');
end;

-- now make sure that the object exists and check its type

objtypeid := 0;
objid := null;

begin
select object_id,object_type_id into objid,objtypeid from bism_objects where folder_id = srcfid and object_name = objname and user_visible = 'Y';
if objtypeid = 100 then
move_folder(srcfid ,tgtfid ,objname ,objid, myid );
else
move_object(srcfid ,tgtfid ,objname ,objid, myid );
end if;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
end;

if bism_core.v_auto_commit = TRUE then
  commit;
end if;

end;

procedure move_folder(topfolderid raw,tgtfid raw,objname varchar2, srcfid raw,myid raw)
is
priv bism_permissions.privilege%type;
foldername bism_objects.object_name%type;
move_not_allowed boolean := true;
begin

move_not_allowed := is_src_ancestor_of_target(srcfid,tgtfid);
if move_not_allowed = true then
raise_application_error(BISM_ERRORCODES.ILLEGAL_MOVE,'Target folder is subfolder of source folder');
end if;

-- NT requires that the user posses List priv on Parent folder
-- and Change priv on the src folder (being moved) and Add priv
-- on the target folder

-- 1. lets check the parent folder access first
begin
priv := 0;
select max(privilege) into priv from bism_permissions where
object_id = topfolderid and subject_id in
(
select group_id from bism_groups where user_id = myid
);

-- if privilege does not exist on the folder, priv will be set to null
-- but it wont raise data not found exception
-- this can happen for 2 reasons
-- 1. if folder does not exist
-- 2. if user does not have privilege on folder
if priv is null then
begin
select object_name into foldername from bism_objects where object_id = srcfid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for parent folder');
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.PARENT_FOLDER_NOT_FOUND ,'Parent folder not found');
end;
end if;


if priv < 10 then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Insufficient privileges for parent folder');
end if;

end;

-- 2. lets check the source folder access

begin
priv := 0;
select max(privilege) into priv from bism_permissions where
object_id = srcfid and subject_id in
(
select group_id from bism_groups where user_id = myid
);


if priv is null then
begin
select object_name into foldername from bism_objects where object_id = srcfid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for source folder');
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.SRC_FOLDER_NOT_FOUND ,'Source folder not found');
end;
end if;


if priv < 40 then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_SRC_FOLDER,'Insufficient privileges for source folder');
end if;

end;


-- now test the target folder access
begin
priv:=0;
select max(privilege) into priv from bism_permissions where
object_id = tgtfid and subject_id in
(
select group_id from bism_groups where user_id = myid
);

-- if privilege does not exist on the folder, priv will be set to null
-- but it wont raise data not found exception
if priv is null then
begin
select object_name into foldername from bism_objects where object_id = tgtfid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for target folder '||foldername);
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.TGT_FOLDER_NOT_FOUND ,'Target folder not found');
end;
end if;

if priv < 30 then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_TGT_FOLDER,'Insufficient privileges for target folder');
end if;

end;


-- lastly check to make sure user atleast has LIST priv on all sub folders
-- of source folder (this is what NT does)
begin
for i in (select object_id from bism_objects where object_type_id=100 start with object_id = srcfid connect by folder_id = prior object_id) loop
priv := 0;
select max(privilege) into priv from bism_permissions where
object_id = i.object_id and subject_id in
(
select group_id from bism_groups where user_id = myid
);

if priv is null then
-- we know that the object exists because we got by doing a select above see for loop
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for a folder in the hierarchy');
end if;

if priv < 10 then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_HIER_FOLDER,'Insufficient privileges for a folder in folder hierarchy');
end if;

end loop;
end;

-- if we got this far means that the user has privileges on both the src
-- and target folder, now lets do the move operation
-- NT preserves the time stamps when folder is moved
update bism_objects set folder_id = tgtfid,last_modified_by = myid where object_id = srcfid;

end;

-- modified by ccchow, to support object level security
procedure move_object(srcfid raw,tgtfid raw,objname varchar2,objid raw,myid raw)
is
    priv bism_permissions.privilege%type;
    foldername bism_objects.object_name%type;
begin
    -- first test the object itself (added - ccchow)
	begin
	    priv := 0;
        select max(privilege) into priv from bism_permissions where object_id = objid and subject_id in (select group_id from bism_groups where user_id = myid);

        if priv is null then
            begin
                select object_name into foldername from bism_objects where object_id = objid;
                raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for object');
            exception
            when no_data_found then
                raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND ,'Object not found');
            end;
        end if;

		-- NT requires at least WRITE privilege on object
        if priv < 40 then
            raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Insufficient privileges');
        end if;
    end;

	-- now test the source folder
    begin
        priv := 0;
        select max(privilege) into priv from bism_permissions where object_id = srcfid and subject_id in (select group_id from bism_groups where user_id = myid);

        -- if privilege does not exist on the folder, priv will be set to null
        -- but it wont raise data not found exception
        -- this can happen for 2 reasons
        -- 1. if folder does not exist
        -- 2. if user does not have privilege on folder
        if priv is null then
            begin
                select object_name into foldername from bism_objects where object_id = srcfid;
                raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for source folder '||foldername);
            exception
            when no_data_found then
                raise_application_error(BISM_ERRORCODES.SRC_FOLDER_NOT_FOUND ,'Source folder not found');
            end;
        end if;

		-- deprecated since NT requires only LIST privilege on source folder for move
        --if priv < 40 then
        --raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_SRC_FOLDER,'Insufficient privileges for source folder');
        --end if;
    end;

    -- now test the target folder
    begin
        priv:=0;
        select max(privilege) into priv from bism_permissions where object_id = tgtfid and subject_id in (select group_id from bism_groups where user_id = myid);

        -- if privilege does not exist on the folder, priv will be set to null
        -- but it wont raise data not found exception
        if priv is null then
            begin
                select object_name into foldername from bism_objects where object_id = tgtfid;
                raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for target folder '||foldername);
            exception
            when no_data_found then
                raise_application_error(BISM_ERRORCODES.TGT_FOLDER_NOT_FOUND ,'Target folder not found');
            end;
        end if;

        if priv < 30 then
            raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_TGT_FOLDER,'Insufficient privileges for target folder');
        end if;
    end;

    -- if we got this far means that the user has privileges on both the src
    -- and target folder, now lets do the move operation
    --
    -- preserve the time stamps during move operation
    -- (ccchow) The ACL will also be preserved since we only updated the folder id etc.
    for i in (select object_id from bism_objects start with object_id = objid connect by container_id = prior object_id)
	loop
        update bism_objects set folder_id = tgtfid,last_modified_by = myid where bism_objects.object_id = i.object_id;
    end loop;

end move_object;

function can_copy_folder(srcfid raw,tgtfid raw,myid raw)
return boolean
is
foldername bism_objects.object_name%type;
priv bism_permissions.privilege%type := 0;
copy_not_allowed boolean := true;
begin
-- make sure that the destination folder is not a sub folder of src folder
copy_not_allowed := bism_core.is_src_ancestor_of_target(srcfid,tgtfid);
if copy_not_allowed = true then
raise_application_error(BISM_ERRORCODES.ILLEGAL_COPY,'Target folder is subfolder of source folder');
end if;
-- make sure user has atleast READ access on all sub folders
begin
for i in (select object_id from bism_objects where object_type_id=100 start with object_id = srcfid connect by folder_id = prior object_id) loop
priv := 0;
select max(privilege) into priv from bism_permissions where
object_id = i.object_id and subject_id in
(
select group_id from bism_groups where user_id = myid
);

if priv is null then
-- we know that the object exists because we got by doing a select above see for loop
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for a folder in the hierarchy');
end if;

if priv < 20 then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_HIER_FOLDER,'Insufficient privileges for folder hierarchy');
end if;

end loop;
end;

-- now test the target folder
begin
priv:=0;
select max(privilege) into priv from bism_permissions where
object_id = tgtfid and subject_id in
(
select group_id from bism_groups where user_id = myid
);

-- if privilege does not exist on the folder, priv will be set to null
-- but it wont raise data not found exception
if priv is null then
begin
select object_name into foldername from bism_objects where object_id = tgtfid;
raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for target folder '||foldername);
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.TGT_FOLDER_NOT_FOUND,'Target folder not found');
end;
end if;

if priv < 30 then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_TGT_FOLDER,'Insufficient privileges for target folder');
end if;

end;

return true;
end;

procedure copy_folder(srcfid raw,tgtfid raw,destobjname varchar2,myid raw,copytype integer,first_level boolean)
is
agginfo bism_aggregates.aggregate_info%type;
new_target_folder bism_objects.object_id%type;
newguid bism_objects.object_id%type:= null;
dummycounter integer := 0;
begin

-- NOTE : dummycounter is not used any more after fixing bug # 4639756
-- removing it from arguments would require signature change, so leaving it in..

-- note : srcfid is the id of the folder that needs to be copied to target location
-- copy the top level folder first
-- we allow user to specify name for the top folder being copied
newguid := bism_utils.get_guid;
if first_level = true then
insert into BISM_OBJECTS
(USER_VISIBLE, OBJECT_TYPE_ID, VERSION, TIME_DATE_CREATED,TIME_DATE_MODIFIED,OBJECT_ID,CONTAINER_ID,FOLDER_ID,CREATED_BY,LAST_MODIFIED_BY,
OBJECT_NAME, TITLE, APPLICATION, DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1, COMP_SUBTYPE2,COMP_SUBTYPE3,
EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED)
select USER_VISIBLE, OBJECT_TYPE_ID, VERSION, sysdate,sysdate,newguid,utl_raw.cast_to_raw('0'),tgtfid,myid,myid,destobjname, TITLE,
APPLICATION, DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1, COMP_SUBTYPE2,COMP_SUBTYPE3,EXTENSIBLE_ATTRIBUTES,
TIME_DATE_LAST_ACCESSED
from bism_objects
where object_id = srcfid;
else
insert into bism_objects
(USER_VISIBLE, OBJECT_TYPE_ID, VERSION, TIME_DATE_CREATED,TIME_DATE_MODIFIED,OBJECT_ID,CONTAINER_ID,FOLDER_ID,CREATED_BY,LAST_MODIFIED_BY,
OBJECT_NAME, TITLE, APPLICATION, DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1, COMP_SUBTYPE2,COMP_SUBTYPE3,
EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED)
select USER_VISIBLE, OBJECT_TYPE_ID, VERSION, sysdate,sysdate,newguid,utl_raw.cast_to_raw('0'),tgtfid,myid,myid,object_name, TITLE, APPLICATION,
DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1, COMP_SUBTYPE2,COMP_SUBTYPE3,EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED
from bism_objects
where object_id = srcfid ;
end if;

--above object_id becomes newTargetFolder for child objects
new_target_folder := newguid;
-- now start copying the contents of the source folder
for i in (select object_id,object_type_id,object_name from bism_objects where folder_id = srcfid and user_visible='Y') loop
if i.object_type_id = 100 then
copy_folder(i.object_id,new_target_folder,null,myid,copytype,false);
else
copy_object(srcfid, new_target_folder, i.object_name, i.object_name, myid, copytype);
end if;
end loop;

end;


procedure copy(srcfid raw,tgtfid raw,srcobjname varchar2,destobjname varchar2,myid raw,copytype integer)
is
objid bism_objects.object_id%type:= null;
objtypeid bism_objects.object_type_id%type := 0;
can_copy_folder_var boolean := false;
begin

if copytype not in (0,1) then
raise_application_error(BISM_ERRORCODES.INVALID_COPY_OPERATION,'Invalid copy type');
end if;

begin

-- make sure target exists
select object_id,object_type_id into objid,objtypeid from bism_objects where object_id = tgtfid;
if objtypeid <> 100 then
raise_application_error(BISM_ERRORCODES.TGT_IS_NOT_FOLDER,'Target object is not folder');
end if;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.TGT_FOLDER_NOT_FOUND,'Target folder not found');
end;

-- now make sure that the object exists, check its type and call approp. method

objtypeid := 0;
objid := null;

begin
-- note : srcfid here means the parent folder containing the folder/object that needs
-- to be copied
select object_id,object_type_id into objid,objtypeid from bism_objects where folder_id = srcfid and object_name = srcobjname and user_visible = 'Y';
if objtypeid = 100 then
--objid represents the folderid of the folder that needs to be copied
can_copy_folder_var := can_copy_folder(objid,tgtfid,myid);
-- if we cannot copy this folder, it will throw exception
-- hence no need to check for return value
copy_folder(objid ,tgtfid ,destobjname, myid,copytype,true);
else
copy_object(srcfid ,tgtfid ,srcobjname ,destobjname, myid,copytype );
end if;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
end;

if bism_core.v_auto_commit = TRUE then
  commit;
end if;

end;

-- modified by ccchow to support object level security
procedure copy_object(srcfid raw,tgtfid raw,srcobjname varchar2,destobjname varchar2,myid raw,copytype integer)
is
    priv bism_permissions.privilege%type;
    foldername bism_objects.object_name%type;
    newguid bism_objects.object_id%type;
    toplevelobjid bism_objects.object_id%type;
    agginfo bism_aggregates.aggregate_info%type;
    uv bism_objects.USER_VISIBLE%type;
    oti bism_objects.object_type_id%type;
    ver bism_objects.VERSION%type;
    ttl bism_objects.TITLE%type;
    app bism_objects.APPLICATION%type;
    db bism_objects.DATABASE%type;
    dsc bism_objects.DESCRIPTION%type;
    kwds bism_objects.KEYWORDS%type;
    xml bism_objects.XML%type;
    as1 bism_objects.APPLICATION_SUBTYPE1%type;
    cs1 bism_objects.COMP_SUBTYPE1%type;
    cs2 bism_objects.COMP_SUBTYPE2%type;
    cs3 bism_objects.COMP_SUBTYPE3%type;
    ext bism_objects.EXTENSIBLE_ATTRIBUTES%type;
    pass_copytype integer;
    dummycounter integer := 0;
begin

-- NOTE : dummycounter is not used any more after fixing bug # 4639756
-- removing it from arguments would require signature change, so leaving it in..


    -- make sure the object exists before we attempt to do anything!
    begin
        select object_id into toplevelobjid from bism_objects where folder_id = srcfid and object_name = srcobjname and user_visible = 'Y';
    exception
        when no_data_found then
        raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
    end;
    -- OK, top level object is found !!

	-- first check the privilege on the object (ccchow)
	begin
	    priv := 0;
        select max(privilege) into priv from bism_permissions where object_id = toplevelobjid and subject_id in (select group_id from bism_groups where user_id = myid);

        if priv is null then
            raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges on object');
        end if;

        -- NT requires READ priv on the object
        if priv < 20 then
            raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Insufficient privileges');
        end if;
	end;

    -- now check privileges on source and target folders
    begin
        priv := 0;
        select max(privilege) into priv from bism_permissions where object_id = srcfid and subject_id in (select group_id from bism_groups where user_id = myid);

        -- if privilege does not exist on the folder, priv will be set to null
        -- but it wont raise data not found exception
        -- this can happen for 2 reasons
        -- 1. if folder does not exist
        -- 2. if user does not have privilege on folder
        if priv is null then
            begin
                select object_name into foldername from bism_objects where object_id = srcfid;
                raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for source folder '||foldername);
            exception
            when no_data_found then
                raise_application_error(BISM_ERRORCODES.SRC_FOLDER_NOT_FOUND,'Source folder not found');
            end;
        end if;

        -- NT requires LIST priv on source folder only (NEW)
        -- (deprecated) NT only requires READ priv on source folder to be able to
        -- copy from source folder (OLD)
        -- if priv < 20 then
        -- raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_SRC_FOLDER,'Insufficient privileges for source folder');
        -- end if;
    end;

    -- now test the target folder
    begin
        priv:=0;
        select max(privilege) into priv from bism_permissions where object_id = tgtfid and subject_id in (select group_id from bism_groups where user_id = myid);

        -- if privilege does not exist on the folder, priv will be set to null
        -- but it wont raise data not found exception
        if priv is null then
            begin
                select object_name into foldername from bism_objects where object_id = tgtfid;
                raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privileges for target folder '||foldername);
            exception
            when no_data_found then
                raise_application_error(BISM_ERRORCODES.TGT_FOLDER_NOT_FOUND,'Target folder not found');
            end;
        end if;

        if priv < 30 then
            raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_TGT_FOLDER,'Insufficient privileges for target folder');
        end if;
    end;

    -- if we got this far means that the user has privileges on both the src
    -- and target folder, lets start the copy operation

    -- SHALLOW COPY
    -- if user wants a shallow copy, copy the top level object
    -- and all its anonymous objects to the target folder. dont copy
    -- named objects. leave them where they are and set up relationships
    -- between cloned anonymous and existing named objects by
    -- updating bism_aggregates accordingly
    -- copy_next_level will copy the rest of the hierarchy down

    -- DEEP COPY
    -- if user wants a deep copy, copy all objects in the hierarchy including
    -- the named objects. the cloned instances of named sub objects will now
    -- become anonymous
    -- and top level object is the only visible object
    -- all named sub objects get a system generated name and their user_visible
    -- flag will be set to 'N'
    -- all the objects (named and anon) will be copied to the target folder
    -- copy_next_level will copy the rest of the hierarchy down

	-- NOTE that privilege of the copied object will inherit from the new parent folder
	--      so here we don't need to do anything special (taken care of by the trigger) - ccchow

    -- Copy the top level object first
    newguid := bism_utils.get_guid;
    -- the new instance gets new time stamps (time_date_created and time_date_modified) as per NT
    select USER_VISIBLE, OBJECT_TYPE_ID, VERSION, TITLE, APPLICATION, DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1, COMP_SUBTYPE2,COMP_SUBTYPE3,EXTENSIBLE_ATTRIBUTES
    into uv, oti, ver, ttl, app, db, dsc, kwds, xml, as1, cs1, cs2, cs3, ext
    from bism_objects
    where object_id =toplevelobjid;
    insert into bism_objects (USER_VISIBLE, OBJECT_TYPE_ID, VERSION, TIME_DATE_CREATED,TIME_DATE_MODIFIED,OBJECT_ID,CONTAINER_ID,FOLDER_ID,CREATED_BY,LAST_MODIFIED_BY,
OBJECT_NAME, TITLE, APPLICATION, DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1, COMP_SUBTYPE2,COMP_SUBTYPE3,
EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED) values
	(uv, oti, ver, sysdate,sysdate,newguid,utl_raw.cast_to_raw('0'),tgtfid,myid,myid,destobjname, ttl, app, db, dsc, kwds, xml, as1, cs1, cs2, cs3, ext, sysdate);
    -- for shortcuts we always want to use shallow copy (only copy the shortcut, not the object that it points to)
    if oti = 200 then
       pass_copytype := 0;
    else
       pass_copytype := copytype;
    end if;
    select aggregate_info into agginfo from bism_aggregates where container_id = utl_raw.cast_to_raw('0') and containee_id = toplevelobjid;
    insert into bism_aggregates (CONTAINER_ID, CONTAINEE_ID, AGGREGATE_INFO) values (utl_raw.cast_to_raw('0'),newguid,agginfo);
    -- if we want to return the object id of the top level objec
    -- add select object_type_id to above select statement then concat
    -- rettypeid with retguid
    -- retguid := newguid;
    copy_next_level(toplevelobjid,newguid,tgtfid,myid,dummycounter,pass_copytype);

    --return rettype||':'||retguid;
end copy_object;

procedure copy_next_level(oldparentid raw,newparentid raw,tgtfid raw,myid raw,dummycounter in out nocopy integer,copytype integer)
is
anon_obj_name bism_objects.object_name%type;
user_visible_var bism_objects.user_visible%type;
newguid raw(16);
begin

-- NOTE : dummycounter is not used any more after fixing bug # 4639756
-- removing it from arguments would require signature change, so leaving it in..

-- NOTE : oldparentid is the object_id of the original object hierarchy.
-- walk the old hierarchy using oldparentid and its children
-- newparentid is the new instance object_id. use this to set up the graph
-- between newly created objects
for i in (select containee_id,aggregate_info from bism_aggregates where container_id = oldparentid) loop
   	select user_visible into user_visible_var from bism_objects where object_id = i.containee_id;
	if user_visible_var = 'Y' then
	    if copytype = 0 then
    	    -- this is a named object and if performing shallow copy, don't copy it,
    	    -- just set up relationshin between this and its parent
    	    -- and dont traverse its hierarchy
	        insert into bism_aggregates (CONTAINER_ID, CONTAINEE_ID, AGGREGATE_INFO) values (newparentid,i.containee_id,i.aggregate_info);
	    elsif copytype = 1 then
	        -- user wants deep copy, so clone the named object as well and make it
	        -- anonymous, give it a system generated name
            newguid := bism_utils.get_guid;
            anon_obj_name := 'SYS-'||newguid;
          -- the new instance gets new time stamps (time_date_created and time_date_modified) as per NT
            insert into bism_objects
			(USER_VISIBLE, OBJECT_TYPE_ID, VERSION, TIME_DATE_CREATED,TIME_DATE_MODIFIED,OBJECT_ID,CONTAINER_ID,FOLDER_ID,CREATED_BY,
                         LAST_MODIFIED_BY, OBJECT_NAME, TITLE, APPLICATION, DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1,
                         COMP_SUBTYPE2,COMP_SUBTYPE3,EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED)
			select 'N', OBJECT_TYPE_ID, VERSION, sysdate,sysdate,newguid,newparentid,tgtfid,myid,myid,anon_obj_name, TITLE, APPLICATION,
                               DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1, COMP_SUBTYPE2,COMP_SUBTYPE3,
                               EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED from bism_objects where object_id = i.containee_id ;
            insert into bism_aggregates (CONTAINER_ID, CONTAINEE_ID, AGGREGATE_INFO) values (newparentid,newguid,i.aggregate_info);
	      copy_next_level(i.containee_id,newguid,tgtfid,myid,dummycounter,copytype);
	    end if;
    elsif user_visible_var = 'N' then
        newguid := bism_utils.get_guid;
        anon_obj_name := 'SYS-'||newguid;
        if length(anon_obj_name) <= 64 then
            -- try to generate a new object name but there is no reason we cant use
            -- old anonymous name
            insert into bism_objects
			(USER_VISIBLE, OBJECT_TYPE_ID, VERSION, TIME_DATE_CREATED,TIME_DATE_MODIFIED,OBJECT_ID,CONTAINER_ID,FOLDER_ID,CREATED_BY,
                         LAST_MODIFIED_BY, OBJECT_NAME, TITLE, APPLICATION, DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1,
                         COMP_SUBTYPE1, COMP_SUBTYPE2,COMP_SUBTYPE3,EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED)
			select USER_VISIBLE, OBJECT_TYPE_ID, VERSION, sysdate,sysdate,newguid,newparentid,tgtfid,myid,myid,anon_obj_name, TITLE,
                               APPLICATION, DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1, COMP_SUBTYPE2,COMP_SUBTYPE3,
                               EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED from bism_objects where object_id = i.containee_id ;
            insert into bism_aggregates (CONTAINER_ID, CONTAINEE_ID, AGGREGATE_INFO) values (newparentid,newguid,i.aggregate_info);
        else
            -- if anon name length generated here exceeds 64, copy the existing name
            insert into bism_objects
			(USER_VISIBLE, OBJECT_TYPE_ID, VERSION, TIME_DATE_CREATED,TIME_DATE_MODIFIED,OBJECT_ID,CONTAINER_ID,FOLDER_ID,CREATED_BY,
                         LAST_MODIFIED_BY, OBJECT_NAME, TITLE, APPLICATION, DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1,
                         COMP_SUBTYPE2,COMP_SUBTYPE3,EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED)
			select USER_VISIBLE, OBJECT_TYPE_ID, VERSION, sysdate,sysdate,newguid,newparentid,tgtfid,myid,myid,OBJECT_NAME, TITLE,
                        APPLICATION, DATABASE, DESCRIPTION,KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1, COMP_SUBTYPE2,COMP_SUBTYPE3,
                        EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED from bism_objects where object_id = i.containee_id ;
            insert into bism_aggregates (CONTAINER_ID, CONTAINEE_ID, AGGREGATE_INFO) values (newparentid,newguid,i.aggregate_info);
        end if;
	    copy_next_level(i.containee_id,newguid,tgtfid,myid,dummycounter,copytype);
	end if;
end loop;
end;

procedure lookuphelper(fid raw,path in bism_lookup_info_in_50_a,lookup_output out nocopy bism_lookup_info_out_50_a,myid raw)
is
i integer := 1; -- the top level frame initializes it to one
begin
lookup_output := bism_lookup_info_out_50_a();
lookup(fid,path,lookup_output,i, myid);
----- COMMENTED CODE COMMENTED CODE COMMENTED CODE -------
-- the foll code has been commented because returning the object
-- from here as ref cursor is not performing well
--if lookup_output(lookup_output.LAST).typeid <> 100 then
---- object_load does not check privileges because lookup would
---- have done it already
--return object_load(lookup_output(lookup_output.LAST).objid,myid);
--else
--return v_cur; -- this is not initd, dont access it in Java
--end if;
--return v_cur;
end;

procedure lookuphelper(fid raw,path varchar2, objname out nocopy varchar2,objid out nocopy raw,typeid out nocopy number, myid raw)
is
startpos integer := 1;-- unparsed string, so start at 1
begin
lookup(fid,path,objname,objid,typeid,myid,startpos);
end;

procedure lookup(fid raw,path bism_lookup_info_in_50_a,lookup_output in out nocopy bism_lookup_info_out_50_a,idx in out nocopy integer,myid raw)
is
oid bism_objects.object_id%type;
typeid bism_objects.object_type_id%type;
oname bism_objects.object_name%type;
ret varchar2(1) := 'n';
visible bism_objects.user_visible%type;
begin

if path.exists(idx) then

    begin
    select object_id,object_type_id,object_name,user_visible into oid,typeid,oname,visible from bism_objects where folder_id = fid and object_name = path(idx).objname and user_visible = 'Y';
    ret := bism_core.check_lookup_access(oid,typeid,visible,myid);
    if ret = 'y' then
        lookup_output.extend();
        lookup_output(lookup_output.count) := bism_lookup_info_out(oname,oid,typeid);
        idx := idx + 1;
        lookup(oid,path,lookup_output,idx,myid);
    end if;
    exception
    when no_data_found then
    raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
    end;
end if; --end if path(idx) exists

end;

procedure lookup(fid raw,path varchar2,a_objname out nocopy varchar2,a_objid out nocopy raw,a_typeid out nocopy number,myid raw,startpos in out nocopy integer)
is
oid bism_objects.object_id%type;
typeid bism_objects.object_type_id%type;
oname bism_objects.object_name%type;
ret varchar2(1) := 'n';
visible bism_objects.user_visible%type;
newstr varchar2(2000) := '';
len integer :=0;
len1 integer :=0;
begin
-- using '\' as delimeter for now, this can be changed
-- note : the delimeter can be longer than one char
-- get_next_element will match the delimeter string
newstr := get_next_element(path,'/',startpos);
len := nvl(length(newstr),0);
if len <> 0 then
    begin
    select object_id,object_type_id,object_name,user_visible into oid,typeid,oname,visible from bism_objects where folder_id = fid and object_name = newstr and user_visible = 'Y';

	-- modified by ccchow, no need to check access of intermediate folders
    if startpos = 0 then
        ret := bism_core.check_lookup_access(oid,typeid,visible,myid);
	else
	    ret := 'y';
	end if;

    if ret = 'y' then
        -- when the given string does not contain the delimiter any more
        -- get_next_element function will set startpos to zero
        -- indicating end of path
        if startpos <> 0 then
            lookup(oid,path,a_objname,a_objid,a_typeid,myid,startpos);
        else
            -- if no more path, set the obj name, id and type
            -- of the last object in the path
            -- caller (Java) retreives this info
            a_objname := oname;
            a_objid := oid;
            a_typeid := typeid;
        end if;
    end if;
    exception
    when no_data_found then
    raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
    end;
else
raise_application_error(BISM_ERRORCODES.INVALID_FOLDER_PATH,'Invalid atomic name');
end if;

end;

function check_access_super_tree(startoid raw,stopoid raw,myid raw)
return varchar2
is
priv bism_permissions.privilege%type;

begin


if startoid = stopoid then
    select max(privilege) into priv from bism_permissions where object_id = startoid and subject_id in (select group_id from bism_groups where user_id = myid);
    if priv is null then
    -- user has no access to this folder
        return 'n';
    else
    -- user has insufficient privileges
        if priv < 10 then
            return 'n';
        end if;
    end if;
else

for i in( select object_id from bism_objects start with object_id = startoid connect by prior folder_id = object_id and object_id <> stopoid ) loop

    select max(privilege) into priv from bism_permissions where object_id = i.object_id and subject_id in (select group_id from bism_groups where user_id = myid);
    if priv is null then
    -- user has no access to this folder
        return 'n';
    else
    -- user has insufficient privileges
        if priv < 10 then
            return 'n';
        end if;
    end if;
end loop;

end if;

return 'y';


end;

function get_object_full_name(oid raw)
return varchar2
is
isfirst boolean := true;
objfullname varchar2(2000) := ' ';
begin

-- absolute path from the root not including it
-- if greater than 2000 chars put ...
for j in(select object_name from bism_objects start with object_id = oid connect by prior folder_id = object_id and object_id <> '31' order by level desc) loop
if length(j.object_name) + length(objfullname) <= 2000 then
if isfirst = true then
objfullname := j.object_name ;
isfirst := false;
else
objfullname := objfullname||'/'||j.object_name ;
end if;
else
objfullname := objfullname||'...';
goto exit_loop;
end if;
end loop;
<<exit_loop>>

return objfullname;
end;

function object_load (objid raw,myid raw) return myrctype
is
rc myrctype;
begin

begin
-- this method is not being used currently !!
-- the foll. sql stmt is m_fetchObjectsSQL2 inside SQLBuilder
open rc for SELECT /*+ NO_MERGE */ T.USER_VISIBLE, T.OBJECT_TYPE_ID, T.VERSION, T.TIME_DATE_CREATED,
T.TIME_DATE_MODIFIED, T.OBJECT_ID,T.FOLDER_ID, T.CREATED_BY,
T.LAST_MODIFIED_BY, T.OBJECT_NAME, T.TITLE, T.APPLICATION, T.DATABASE, T.DESCRIPTION,
T.KEYWORDS, T.XML, T.APPLICATION_SUBTYPE1, T.COMP_SUBTYPE1, T.COMP_SUBTYPE2,T.COMP_SUBTYPE3,TIME_DATE_LAST_ACCESSED,
T.container_id,T.aggregate_info from
(
SELECT /*+ NO_MERGE */ A.USER_VISIBLE, A.OBJECT_TYPE_ID, A.VERSION, A.TIME_DATE_CREATED,
A.TIME_DATE_MODIFIED, A.OBJECT_ID,A.FOLDER_ID, A.CREATED_BY,
A.LAST_MODIFIED_BY, A.OBJECT_NAME, A.TITLE, A.APPLICATION, A.DATABASE, A.DESCRIPTION,
A.KEYWORDS, A.XML, A.APPLICATION_SUBTYPE1, A.COMP_SUBTYPE1, A.COMP_SUBTYPE2,A.COMP_SUBTYPE3,TIME_DATE_LAST_ACCESSED,
T1.container_id,T1.aggregate_info
from bism_objects A,
(
select distinct containee_id,container_id,aggregate_info from bism_aggregates start with containee_id = objid and container_id='30' connect by container_id = prior containee_id
)
T1
where A.object_id=T1.containee_id
)
T ;
return rc;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
when others then
raise;
end;

end;

function get_folder(oid raw, myid raw)
return myrctype
is
rc myrctype;
begin
begin
open rc for
select USER_VISIBLE, OBJECT_TYPE_ID, VERSION, TIME_DATE_CREATED, TIME_DATE_MODIFIED,
	   OBJECT_ID, CONTAINER_ID, FOLDER_ID,
       decode(CREATED_BY, CREATED_BY,
			  (select subject_name from bism_subjects where subject_id = CREATED_BY and subject_type='u'),
			  null),
       decode(LAST_MODIFIED_BY, LAST_MODIFIED_BY,
			  (select subject_name from bism_subjects where subject_id = LAST_MODIFIED_BY and subject_type='u'),
			   null),
       OBJECT_NAME, TITLE, APPLICATION, DATABASE, DESCRIPTION, KEYWORDS, XML,
	   APPLICATION_SUBTYPE1, COMP_SUBTYPE1, COMP_SUBTYPE2, COMP_SUBTYPE3,
       decode(USER_VISIBLE,'Y',bism_core.get_object_full_name(object_id),'') FULLNAME
from bism_objects where
-- folder does not have aggregate info
       object_id = oid and
-- apply security check
-- technically speaking we dont need this because
-- user already had access that's how he could call getObject()
-- call check_lookup_access instead of check_read_access (done previously)
-- check_lookup_access now calls check_list_access if the obj type is 100
-- else calls check_read_access
-- Henry and Yekesa decided to put in this change to allow users with
-- LIST access on a folder to be able to see the folder attribs (i.e
-- LIST access should allow user to load the folder object)
        'y'=bism_core.check_lookup_access(oid,'100','y',myid);
return rc;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
when others then
raise;
end;

end get_folder;

function get_object(objid raw, myid raw, traceLastLoaded varchar2)
return myrctype
is
rc myrctype;
current_date date;
begin
begin
open rc for
select T1.USER_VISIBLE, T1.OBJECT_TYPE_ID, T1.VERSION, T1.TIME_DATE_CREATED, T1.TIME_DATE_MODIFIED,
              T1.OBJECT_ID, T1.CONTAINER_ID, T1.FOLDER_ID,
			  decode(T1.CREATED_BY, T1.CREATED_BY,
			         (select subject_name from bism_subjects where subject_id = T1.CREATED_BY and subject_type='u'),
					 null),
              decode(T1.LAST_MODIFIED_BY, T1.LAST_MODIFIED_BY,
			  (select subject_name from bism_subjects where subject_id = T1.LAST_MODIFIED_BY and subject_type='u'),
			  null),
              T1.OBJECT_NAME, T1.TITLE, T1.APPLICATION, T1.DATABASE, T1.DESCRIPTION, T1.KEYWORDS, T1.XML,
			  T1.APPLICATION_SUBTYPE1, T1.COMP_SUBTYPE1, T1.COMP_SUBTYPE2, T1.COMP_SUBTYPE3, T1.TIME_DATE_LAST_ACCESSED, T2.container_id,
			  T2.containee_id,T2.AGGREGATE_INFO,
			  decode(T1.USER_VISIBLE,'Y',bism_core.get_object_full_name(object_id),'') FULLNAME
from bism_objects T1, bism_aggregates T2
where
/* make sure it is a visible object*/
     1 = (select '1' from bism_objects where object_id = objid and user_visible = 'Y') and
/* fetch the entire hierachry looking up the aggregates table*/
     object_id in (
	               select  distinct containee_id
				   from bism_aggregates
				   		start with containee_id = objid
                        connect by container_id = prior containee_id
                  ) and T1.object_id = T2.containee_id
                    --apply security check
                    /* technically speaking we dont have to check the privilege any more
                       because th euser would have access to the OID only when could access that object*/
                    and 'y' = bism_core.check_lookup_access(T1.object_id,T1.object_type_id,T1.user_visible,myid);
        if traceLastLoaded = '1' then
           select sysdate into current_date from dual;
           update bism_objects set TIME_DATE_LAST_ACCESSED = current_date where object_id = objid;
        end if;

return rc;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
when others then
raise;
end;
end get_object;

function fetch_objectsSQL1(cid raw, objid raw, myid raw)
return myrctype
is
rc myrctype;
begin
begin
open rc for
SELECT /*+ NO_MERGE */ T1.USER_VISIBLE, T1.OBJECT_TYPE_ID, T1.VERSION, T1.TIME_DATE_CREATED,
	   T1.TIME_DATE_MODIFIED, T1.OBJECT_ID, T1.CONTAINER_ID, T1.FOLDER_ID,
	   decode(T1.CREATED_BY, T1.CREATED_BY,
	          (select subject_name from bism_subjects where subject_id = T1.CREATED_BY and subject_type='u'),
			  null),
	   decode(T1.LAST_MODIFIED_BY, T1.LAST_MODIFIED_BY,
	          (select subject_name from bism_subjects where subject_id = T1.LAST_MODIFIED_BY and subject_type='u'),
			  null),
       T1.OBJECT_NAME, T1.TITLE, T1.APPLICATION, T1.DATABASE, T1.DESCRIPTION,
       T1.KEYWORDS, T1.XML, T1.APPLICATION_SUBTYPE1, T1.COMP_SUBTYPE1, T1.COMP_SUBTYPE2,T1.COMP_SUBTYPE3, T1.TIME_DATE_LAST_ACCESSED,
       T2.container_id, T2.containee_id, T2.AGGREGATE_INFO
from (SELECT /*+ NO_MERGE */ USER_VISIBLE, OBJECT_TYPE_ID, VERSION, TIME_DATE_CREATED,
             TIME_DATE_MODIFIED, OBJECT_ID, CONTAINER_ID, FOLDER_ID, CREATED_BY,
             LAST_MODIFIED_BY, OBJECT_NAME, TITLE, APPLICATION, DATABASE, DESCRIPTION,
             KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1, COMP_SUBTYPE2, COMP_SUBTYPE3, TIME_DATE_LAST_ACCESSED
	  from bism_objects where object_id in
	       (select distinct containee_id
		    from bism_aggregates start with containee_id = cid
			                     connect by container_id = prior containee_id
           )
     ) T1,
       (select  distinct container_id,containee_id, aggregate_info
	    from bism_aggregates start with containee_id= cid
		                     connect by container_id = prior containee_id
       ) T2
      where
      /* now apply these rules : 1. top level object must be user_visible */
      1 = (select '1' from bism_objects where object_id= objid and user_visible = 'Y')
      and
      /* 2. fetch only the require object hierarchy*/
      T1.object_id = T2.containee_id
      /*
         3. now apply the privileges, we dont care whether it is anony or named because
            the privileges are set at the folder level
      */
      and
      'y' = bism_core.check_lookup_access(T1.object_id,T1.object_type_id,T1.user_visible,myid);
return rc;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
when others then
raise;
end;
end fetch_objectsSQL1;

function fetch_objectsSQL2(cid raw, myid raw, traceLastLoaded varchar2)
return myrctype
is
rc myrctype;
ids_array obj_ids := obj_ids();
uvs_array obj_uvs := obj_uvs();
otids_array obj_otids := obj_otids();
current_date date;
begin
begin
open rc for
SELECT /*+ NO_MERGE */ T.USER_VISIBLE, T.OBJECT_TYPE_ID, T.VERSION, T.TIME_DATE_CREATED,
    T.TIME_DATE_MODIFIED, T.OBJECT_ID,T.FOLDER_ID,
    decode(T.CREATED_BY,T.CREATED_BY,(select subject_name from bism_subjects where subject_id = T.CREATED_BY and subject_type='u'),null),
    decode(T.LAST_MODIFIED_BY,T.LAST_MODIFIED_BY,(select subject_name from bism_subjects where subject_id = T.LAST_MODIFIED_BY and subject_type='u'),null),
    T.OBJECT_NAME, T.TITLE, T.APPLICATION, T.DATABASE, T.DESCRIPTION,
    T.KEYWORDS, T.XML, T.APPLICATION_SUBTYPE1, T.COMP_SUBTYPE1, T.COMP_SUBTYPE2,T.COMP_SUBTYPE3, T.TIME_DATE_LAST_ACCESSED,
    /*1. containee_id is not fetched from bism_aggregates because it is pulling several extra rows
    when an object is shared by multiple containers, however containee_id is same as object_id
    from bism_objects */
    T.container_id,T.aggregate_info,
    decode(T.USER_VISIBLE,'Y',bism_core.get_object_full_name(T.OBJECT_ID),'') FULLNAME
    from
    (
    SELECT /*+ NO_MERGE */ A.USER_VISIBLE, A.OBJECT_TYPE_ID, A.VERSION, A.TIME_DATE_CREATED,
    /*2. do not fetch container_id from bism_objects use container_id from bism_aggreagtes instead*/
    A.TIME_DATE_MODIFIED, A.OBJECT_ID, /*A.CONTAINER_ID, */ A.FOLDER_ID, A.CREATED_BY,
    A.LAST_MODIFIED_BY, A.OBJECT_NAME, A.TITLE, A.APPLICATION, A.DATABASE, A.DESCRIPTION,
    A.KEYWORDS, A.XML, A.APPLICATION_SUBTYPE1, A.COMP_SUBTYPE1, A.COMP_SUBTYPE2,A.COMP_SUBTYPE3, A.TIME_DATE_LAST_ACCESSED,
    T1.container_id,T1.aggregate_info
    from bism_objects A,
    (
    /* 3. distinct is required because there may be diamond relationships in the hierarchy
    and if so, we only want to fetch it once */
    /* 4. container_id = '30' is important because an object may have multiple containers
    in which case we end up fetching those rows as well, which is useless
    */
    select distinct containee_id,container_id,aggregate_info from bism_aggregates start with containee_id = cid and container_id='30' connect by container_id = prior containee_id
    )
    T1
    /* 5. fetch only the required object hierarchy */
    where A.object_id=T1.containee_id
    )
    T
    /* 6. the foll. security check is not needed, because lookuphelper the function that was
    called before this stmt gets executed has indeed checked for lookup_access
    but dropping this check does not seem to improve perf. so I am leaving it in
    for now */
    where
    'y' = bism_core.check_lookup_access(T.object_id, T.object_type_id, T.user_visible, myid);

	/* now set lastLoaded attribute*/
    if traceLastLoaded = '1' then
      select sysdate into current_date from dual;
      --update bism_objects set TIME_DATE_LAST_ACCESSED = current_date where object_id = oid;
	  open obj_ids_cursor(cid,myid);
	  fetch obj_ids_cursor bulk collect into uvs_array, otids_array, ids_array;
	  if ids_array.COUNT > 0 then
      	 for i in ids_array.FIRST..ids_array.LAST
		 loop
       	   -- update last_loaded time for each
		   update bism_objects set TIME_DATE_LAST_ACCESSED = current_date where object_id=ids_array(i);
         end loop;
      end if;
	  close obj_ids_cursor;
    end if;
return rc;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
when others then
raise;
end;
end fetch_objectsSQL2;

function rename_object(fid raw, objname varchar2, myid raw, callerid number, newobjname varchar2)
return number
is
ret varchar2(1) := 'n';
status number;
begin
ret := bism_core.check_modify_attrs_access(fid, objname, myid, status, callerid);
if ret = 'y' then
   update bism_objects set object_name = newobjname ,
                           time_date_modified = sysdate ,
                           last_modified_by = myid
   where folder_id = fid and user_visible = 'Y' and object_name = objname ;
end if;

return status;

end rename_object;

function list
    (p_fid bism_objects.FOLDER_ID%type,
     p_subid bism_subjects.SUBJECT_ID%type)
return myrctype
is
rc myrctype;
begin
begin
open rc for
     select object_name,object_type_id
     from bism_objects
	 where folder_id = p_fid and
	 user_visible = 'Y' and
	 'y' = bism_access_control.check_list_access(p_fid,p_subid);
return rc;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
when others then
raise;
end;

end list;


-- begin refactoring code for init, bind, rebind, createSubcontext
function init(p_subname in bism_subjects.subject_name%type)
return bism_subjects.subject_id%type
is
    subid bism_subjects.subject_id%type;
    oid bism_objects.object_id%type := null;
	priv bism_permissions.privilege%type := 0;
begin
	/* make sure root folder exists */
    begin
        select object_id into oid from bism_objects where folder_id='30' and object_name= 'ROOT' and user_visible = 'Y';
	exception
        when no_data_found then
        raise_application_error(BISM_ERRORCODES.ROOT_NOT_FOUND,'Root folder not found');
    end;

    /* make sure user exists */
    begin
        select subject_id into subid from bism_subjects where subject_name = p_subname and subject_type= 'u';
    exception
        when no_data_found then
            raise_application_error (BISM_ERRORCODES.USER_NOT_IDENTIFIED,'User could not be identified');
    end;

    /* make sure user has enough prvileges */
    begin
        select nvl(max(privilege),0) into priv from bism_permissions where object_id = '31' and subject_id in (select group_id from bism_groups where user_id = subid );
    exception
        when no_data_found then
            raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User has no privilege for root folder');
    end;

    if priv < 10 then
        raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'User does not have enough privileges for root folder');
    end if;

    return subid;
end init;

function create_subcontext
    (p_tempTimeC bism_objects.time_date_created%type,
	 p_tempTimeM bism_objects.time_date_modified%type,
	 p_creator bism_subjects.subject_name%type,
	 p_modifier bism_subjects.subject_name%type,
	 p_fid bism_objects.folder_id%type,
	 p_subid bism_subjects.subject_id%type,
	 p_version bism_objects.VERSION%type,
	 p_object_name bism_objects.object_name%type,
	 p_title bism_objects.title%type,
	 p_application bism_objects.application%type,
	 p_database bism_objects.database%type,
	 p_desc bism_objects.description%type,
	 p_keywords bism_objects.keywords%type,
	 p_appsubtype1 bism_objects.application_subtype1%type,
	 p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
	 p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
	 p_compsubtype3 bism_objects.COMP_SUBTYPE3%type)
return bism_objects.object_id%type
is
    sub_id bism_subjects.subject_id%type;
    oid bism_objects.object_id%type;
    oname bism_objects.object_name%type;
    fid bism_objects.folder_id%type;
    created_subid bism_subjects.subject_id%type;
    modified_subid bism_subjects.subject_id%type;
    timeC bism_objects.time_date_created%type := sysdate;
    timeM bism_objects.time_date_modified%type := sysdate;
    tempTimeC bism_objects.time_date_created%type := null;
    tempTimeM bism_objects.time_date_modified%type := null;
    ret varchar2(1):='n';
begin
    begin
        tempTimeC := p_tempTimeC;
        tempTimeM := p_tempTimeM;
        select subject_id into created_subid from bism_subjects where subject_name = p_creator and subject_type = 'u';
		if p_creator <> p_modifier then
		   select subject_id into modified_subid from bism_subjects where subject_name = p_modifier and subject_type = 'u';
		else
		   modified_subid := created_subid;
		end if;
    exception
        when no_data_found then
        raise_application_error(-20503,'User not found');
	end;

    ret := bism_access_control.check_ins_access(p_fid, p_subid);
    if ret = 'y' then
	    if tempTimeC is not null then
		    timeC := tempTimeC;
		else
			timeC := sysdate;
	    end if;

	    if tempTimeM is not null then
	        timeM := tempTimeM;
        else
		    timeM := sysdate;
	    end if;

	    insert into BISM_OBJECTS
		(USER_VISIBLE, OBJECT_TYPE_ID,VERSION, TIME_DATE_CREATED, TIME_DATE_MODIFIED, OBJECT_ID, CONTAINER_ID, FOLDER_ID, CREATED_BY,
                 LAST_MODIFIED_BY, OBJECT_NAME, TITLE, APPLICATION, DATABASE, DESCRIPTION, KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1,
                 COMP_SUBTYPE2, COMP_SUBTYPE3, TIME_DATE_LAST_ACCESSED) values ('Y',0100,p_version,timeC,timeM,bism_utils.get_guid,null,
                 p_fid,created_subid,modified_subid,p_object_name,p_title,p_application,p_database,p_desc,p_keywords,null,p_appsubtype1,
                 p_compsubtype1,p_compsubtype2,p_compsubtype3, timeC) returning object_id into oid;
	else
		raise_application_error(-20104,'Unexpected return value');
	end if;

    return oid;
end create_subcontext;

function create_subcontext_30
    (p_tempTimeC bism_objects.time_date_created%type,
	 p_tempTimeM bism_objects.time_date_modified%type,
	 p_oid bism_objects.object_id%type,
	 p_creator bism_subjects.subject_name%type,
	 p_modifier bism_subjects.subject_name%type,
	 p_fid bism_objects.folder_id%type,
	 p_subid bism_subjects.subject_id%type,
	 p_version bism_objects.VERSION%type,
	 p_object_name bism_objects.object_name%type,
	 p_title bism_objects.title%type,
	 p_application bism_objects.application%type,
	 p_database bism_objects.database%type,
	 p_desc bism_objects.description%type,
	 p_keywords bism_objects.keywords%type,
	 p_appsubtype1 bism_objects.application_subtype1%type,
	 p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
	 p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
	 p_compsubtype3 bism_objects.COMP_SUBTYPE3%type,
     p_extAttrs_Clob CLOB)
     return bism_objects.object_id%type
is
    sub_id bism_subjects.subject_id%type;
    oid bism_objects.object_id%type;
    oname bism_objects.object_name%type;
    fid bism_objects.folder_id%type;
    created_subid bism_subjects.subject_id%type;
    modified_subid bism_subjects.subject_id%type;
    timeC bism_objects.time_date_created%type := sysdate;
    timeM bism_objects.time_date_modified%type := sysdate;
    tempTimeC bism_objects.time_date_created%type := null;
    tempTimeM bism_objects.time_date_modified%type := null;
    p_extAttrs bism_objects.extensible_attributes%type := null;

    ret varchar2(1):='n';
begin
    begin
        tempTimeC := p_tempTimeC;
        tempTimeM := p_tempTimeM;

        select subject_id into created_subid from bism_subjects where subject_name = p_creator and subject_type = 'u';
		if p_creator <> p_modifier then
		   select subject_id into modified_subid from bism_subjects where subject_name = p_modifier and subject_type = 'u';
		else
		   modified_subid := created_subid;
		end if;
    exception
        when no_data_found then
        raise_application_error(-20503,'User not found');
	end;

    ret := bism_access_control.check_ins_access(p_fid, p_subid);
     -- if caller provides id for this folderr, use it
     IF p_oid is not null then
     		oid := p_oid;
     ELSE
        oid := bism_utils.get_guid;
     END IF;

    if ret = 'y' then
	    if tempTimeC is not null then
		    timeC := tempTimeC;
		else
			timeC := sysdate;
	    end if;

	    if tempTimeM is not null then
	        timeM := tempTimeM;
        else
		    timeM := sysdate;
	    end if;
	    if p_extAttrs_Clob is not null then
            	    -- convert CLOB representation of extensible attributes into XMLType representation
                    p_extAttrs := sys.xmltype.createXML(p_extAttrs_Clob);
            end if;

	    insert into BISM_OBJECTS
		(USER_VISIBLE, OBJECT_TYPE_ID,VERSION, TIME_DATE_CREATED, TIME_DATE_MODIFIED, OBJECT_ID, CONTAINER_ID, FOLDER_ID, CREATED_BY,
                 LAST_MODIFIED_BY, OBJECT_NAME, TITLE, APPLICATION, DATABASE, DESCRIPTION, KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1,
                 COMP_SUBTYPE2, COMP_SUBTYPE3,EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED) values ('Y',0100,p_version,timeC,timeM,
                 oid,null,p_fid,created_subid,modified_subid,p_object_name,p_title,p_application,p_database,p_desc,p_keywords,
                 null,p_appsubtype1,p_compsubtype1,p_compsubtype2,p_compsubtype3,p_extAttrs,timeC) ;
	else
		raise_application_error(-20104,'Unexpected return value');
	end if;

    return oid;
end create_subcontext_30;

procedure bind
    (p_creator bism_subjects.SUBJECT_NAME%type,
	 p_modifier bism_subjects.SUBJECT_NAME%type,
	 p_subject_id bism_subjects.SUBJECT_ID%type,
	 p_visible bism_objects.USER_VISIBLE%type,
     p_obj_type_id bism_objects.OBJECT_TYPE_ID%type,
     p_version bism_objects.VERSION%type,
     p_time_created bism_objects.TIME_DATE_CREATED%type,
     p_time_modified bism_objects.TIME_DATE_MODIFIED%type,
     p_oid bism_objects.OBJECT_ID%type,
     p_container_id bism_objects.CONTAINER_ID%type,
     p_fid bism_objects.FOLDER_ID%type,
	 p_obj_name bism_objects.OBJECT_NAME%type,
	 p_title bism_objects.TITLE%type,
	 p_application bism_objects.APPLICATION%type,
	 p_database bism_objects.DATABASE%type,
	 p_desc bism_objects.DESCRIPTION%type,
	 p_keywords bism_objects.KEYWORDS%type,
	 p_xml bism_objects.XML%type,
	 p_appsubtype1 bism_objects.APPLICATION_SUBTYPE1%type,
	 p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
	 p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
	 p_compsubtype3	bism_objects.COMP_SUBTYPE3%type,
	 p_container_id2 bism_aggregates.CONTAINER_ID%type,
	 p_aggregate_info bism_aggregates.AGGREGATE_INFO%type,
	 p_ext_attrs_clob CLOB,
	 p_time_last_loaded bism_objects.TIME_DATE_LAST_ACCESSED%type
	 )
is
    ret varchar2(1);
    created_subid bism_subjects.subject_id%type;
    modified_subid bism_subjects.subject_id%type;
    p_ext_attrs bism_objects.extensible_attributes%type := null;
begin
    begin
        select subject_id into created_subid from bism_subjects where subject_name = p_creator and subject_type ='u';
		if p_creator <> p_modifier then
		   select subject_id into modified_subid from bism_subjects where subject_name = p_modifier and subject_type = 'u';
		else
		   modified_subid := created_subid;
		end if;
	exception
	    when no_data_found then
		raise_application_error(-20503,'User not found');
		/* let other exceptions bubble up */
	end;

	begin
	    ret := bism_access_control.check_ins_access(p_fid,p_subject_id);
	end;

	if ret = 'y' then
           if p_ext_attrs_clob is not null then
               -- convert CLOB representation of extensible attributes into XMLType representation
               p_ext_attrs := sys.xmltype.createXML(p_ext_attrs_clob);
           end if;

	    insert into BISM_OBJECTS (USER_VISIBLE,OBJECT_TYPE_ID,VERSION,TIME_DATE_CREATED,TIME_DATE_MODIFIED,OBJECT_ID,CONTAINER_ID,FOLDER_ID,
                                      CREATED_BY,LAST_MODIFIED_BY,OBJECT_NAME,TITLE,APPLICATION,DATABASE,DESCRIPTION,KEYWORDS,XML,
                                      APPLICATION_SUBTYPE1,COMP_SUBTYPE1,COMP_SUBTYPE2,COMP_SUBTYPE3,EXTENSIBLE_ATTRIBUTES,TIME_DATE_LAST_ACCESSED)
		values
		(p_visible,p_obj_type_id,p_version,p_time_created,p_time_modified,p_oid,p_container_id,p_fid,created_subid,modified_subid,p_obj_name,
                 p_title,p_application,p_database,p_desc,p_keywords,p_xml,p_appsubtype1,p_compsubtype1,p_compsubtype2,p_compsubtype3,p_ext_attrs,
                 p_time_last_loaded);
	else
		raise_application_error(-20104,'Unexpected return value');
	end if;

	/* need to use a different container id since bism_aggregate doesn't take null for container_id for top level object */
    bind_aggregate(p_container_id2,p_oid,p_aggregate_info);
end bind;


procedure bind
    (p_creator bism_subjects.SUBJECT_NAME%type,
	 p_modifier bism_subjects.SUBJECT_NAME%type,
	 p_subject_id bism_subjects.SUBJECT_ID%type,
	 p_visible bism_objects.USER_VISIBLE%type,
     p_obj_type_id bism_objects.OBJECT_TYPE_ID%type,
     p_version bism_objects.VERSION%type,
     p_time_created bism_objects.TIME_DATE_CREATED%type,
     p_time_modified bism_objects.TIME_DATE_MODIFIED%type,
     p_oid bism_objects.OBJECT_ID%type,
     p_container_id bism_objects.CONTAINER_ID%type,
     p_fid bism_objects.FOLDER_ID%type,
	 p_obj_name bism_objects.OBJECT_NAME%type,
	 p_title bism_objects.TITLE%type,
	 p_application bism_objects.APPLICATION%type,
	 p_database bism_objects.DATABASE%type,
	 p_desc bism_objects.DESCRIPTION%type,
	 p_keywords bism_objects.KEYWORDS%type,
	 p_xml bism_objects.XML%type,
	 p_appsubtype1 bism_objects.APPLICATION_SUBTYPE1%type,
	 p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
	 p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
	 p_compsubtype3	bism_objects.COMP_SUBTYPE3%type,
	 p_container_id2 bism_aggregates.CONTAINER_ID%type,
	 p_aggregate_info bism_aggregates.AGGREGATE_INFO%type
	 )
is
    ret varchar2(1);
    created_subid bism_subjects.subject_id%type;
    modified_subid bism_subjects.subject_id%type;
begin
    begin
        select subject_id into created_subid from bism_subjects where subject_name = p_creator and subject_type ='u';
		if p_creator <> p_modifier then
		   select subject_id into modified_subid from bism_subjects where subject_name = p_modifier and subject_type = 'u';
		else
		   modified_subid := created_subid;
		end if;
	exception
	    when no_data_found then
		raise_application_error(-20503,'User not found');
		/* let other exceptions bubble up */
	end;

	begin
	    ret := bism_access_control.check_ins_access(p_fid,p_subject_id);
	end;

	if ret = 'y' then
	    insert into BISM_OBJECTS (USER_VISIBLE,OBJECT_TYPE_ID,VERSION,TIME_DATE_CREATED,TIME_DATE_MODIFIED,OBJECT_ID,CONTAINER_ID,FOLDER_ID,
                                      CREATED_BY,LAST_MODIFIED_BY,OBJECT_NAME,TITLE,APPLICATION,DATABASE,DESCRIPTION,KEYWORDS,XML,
                                      APPLICATION_SUBTYPE1,COMP_SUBTYPE1,COMP_SUBTYPE2,COMP_SUBTYPE3) values (p_visible,p_obj_type_id,p_version,
                                      p_time_created,p_time_modified,p_oid,p_container_id,p_fid,created_subid,modified_subid,p_obj_name,p_title,
                                      p_application,p_database,p_desc,p_keywords,p_xml,p_appsubtype1,p_compsubtype1,p_compsubtype2,p_compsubtype3);
	else
		raise_application_error(-20104,'Unexpected return value');
	end if;

	/* need to use a different container id since bism_aggregate doesn't take null for container_id for top level object */
    bind_aggregate(p_container_id2,p_oid,p_aggregate_info);
end bind;

procedure bind_aggregate
    (p_container_id bism_aggregates.CONTAINER_ID%type,
	 p_containee_id bism_aggregates.CONTAINEE_ID%type,
	 p_aggregate_info bism_aggregates.AGGREGATE_INFO%type)
is
begin
    insert into bism_aggregates (container_id, containee_id, aggregate_info) values (p_container_id,p_containee_id,p_aggregate_info);
end bind_aggregate;

function list_bindings
    (p_fid bism_objects.FOLDER_ID%type,
	 p_subid bism_subjects.SUBJECT_ID%type)
return myrctype
is
rc myrctype;
begin
    open rc for select object_name,object_type_id,object_id from bism_objects where folder_id = p_fid and user_visible = 'Y' and 'y' = bism_access_control.check_list_access(p_fid,p_subid);
    return rc;
end list_bindings;

procedure rebind
    (p_creator bism_subjects.SUBJECT_NAME%type,
	 p_modifier bism_subjects.SUBJECT_NAME%type,
	 p_subject_id bism_subjects.SUBJECT_ID%type,
	 p_visible bism_objects.USER_VISIBLE%type,
     p_obj_type_id bism_objects.OBJECT_TYPE_ID%type,
     p_version bism_objects.VERSION%type,
     p_time_created bism_objects.TIME_DATE_CREATED%type,
     p_time_modified bism_objects.TIME_DATE_MODIFIED%type,
     p_oid bism_objects.OBJECT_ID%type,
     p_container_id bism_objects.CONTAINER_ID%type,
     p_fid bism_objects.FOLDER_ID%type,
	 p_obj_name bism_objects.OBJECT_NAME%type,
	 p_title bism_objects.TITLE%type,
	 p_application bism_objects.APPLICATION%type,
	 p_database bism_objects.DATABASE%type,
	 p_desc bism_objects.DESCRIPTION%type,
	 p_keywords bism_objects.KEYWORDS%type,
	 p_xml bism_objects.XML%type,
	 p_appsubtype1 bism_objects.APPLICATION_SUBTYPE1%type,
	 p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
	 p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
	 p_compsubtype3	bism_objects.COMP_SUBTYPE3%type,
	 p_ext_attrs_clob CLOB,
	 p_time_last_loaded bism_objects.TIME_DATE_LAST_ACCESSED%type,
   p_aggregate_info bism_aggregates.AGGREGATE_INFO%type,
   p_obj_is_top_level varchar2)
is
    ret varchar2(1);
    created_subid bism_subjects.subject_id%type;
    modified_subid bism_subjects.subject_id%type;
    p_ext_attrs bism_objects.extensible_attributes%type := null;
begin
    begin
        select subject_id into created_subid from bism_subjects where subject_name = p_creator and subject_type ='u';
        select subject_id into modified_subid from bism_subjects where subject_name = p_modifier and subject_type ='u';
    exception
        when no_data_found then
        raise_application_error(-20503,'User not found');
        /* let other exceptions bubble up */
    end;

    -- if the object is top level, we update the row, otherwise, we insert
    if p_obj_is_top_level = 'Y' then
	-- object level security, rebind requires WRITE privilege on the object ONLY
	-- nothing to do with parent folder
    ret := bism_access_control.check_upd_access(null,p_oid,'n',p_subject_id);
    if ret = 'y' then
       if p_ext_attrs_clob is not null then
          -- convert CLOB representation of extensible attributes into XMLType representation
          p_ext_attrs := sys.xmltype.createXML(p_ext_attrs_clob);
       end if;

        update bism_objects
		set USER_VISIBLE=p_visible,
		OBJECT_TYPE_ID=p_obj_type_id,
		VERSION=p_version,
		TIME_DATE_CREATED=p_time_created,
		TIME_DATE_MODIFIED=p_time_modified,
		OBJECT_ID=p_oid,
		CONTAINER_ID=p_container_id,
		FOLDER_ID=p_fid,
		CREATED_BY=created_subid,
		LAST_MODIFIED_BY=modified_subid,
		OBJECT_NAME=p_obj_name,
		TITLE=p_title,
		APPLICATION=p_application,
		DATABASE=p_database,
		DESCRIPTION=p_desc,
		KEYWORDS=p_keywords,
		XML=p_xml,
		APPLICATION_SUBTYPE1=p_appsubtype1,
		COMP_SUBTYPE1=p_compsubtype1,
		COMP_SUBTYPE2=p_compsubtype2,
		COMP_SUBTYPE3=p_compsubtype3,
		EXTENSIBLE_ATTRIBUTES=p_ext_attrs,
		TIME_DATE_LAST_ACCESSED=p_time_last_loaded
		where user_visible = 'Y' and object_id = p_oid;
	end if;

  else
    -- if rebind is called to insert an aggregate object, dont check privs
    if p_ext_attrs_clob is not null then
          -- convert CLOB representation of extensible attributes into XMLType representation
          p_ext_attrs := sys.xmltype.createXML(p_ext_attrs_clob);
    end if;

    insert into bism_objects (USER_VISIBLE, OBJECT_TYPE_ID,VERSION, TIME_DATE_CREATED, TIME_DATE_MODIFIED, OBJECT_ID, CONTAINER_ID, FOLDER_ID, CREATED_BY,
                 LAST_MODIFIED_BY, OBJECT_NAME, TITLE, APPLICATION, DATABASE, DESCRIPTION, KEYWORDS, XML, APPLICATION_SUBTYPE1, COMP_SUBTYPE1,
                 COMP_SUBTYPE2, COMP_SUBTYPE3, EXTENSIBLE_ATTRIBUTES, TIME_DATE_LAST_ACCESSED)
      values
      (
        p_visible,p_obj_type_id,p_version,p_time_created,p_time_modified,p_oid,
        p_container_id,p_fid,created_subid,modified_subid,p_obj_name,p_title,p_application,
        p_database,p_desc,p_keywords,p_xml,p_appsubtype1,p_compsubtype1,p_compsubtype2,p_compsubtype3,
        p_ext_attrs,p_time_last_loaded
      );
    bind_aggregate(p_container_id,p_oid,p_aggregate_info);
    end if;
end rebind;


procedure rebind
    (p_creator bism_subjects.SUBJECT_NAME%type,
	 p_modifier bism_subjects.SUBJECT_NAME%type,
	 p_subject_id bism_subjects.SUBJECT_ID%type,
	 p_visible bism_objects.USER_VISIBLE%type,
     p_obj_type_id bism_objects.OBJECT_TYPE_ID%type,
     p_version bism_objects.VERSION%type,
     p_time_created bism_objects.TIME_DATE_CREATED%type,
     p_time_modified bism_objects.TIME_DATE_MODIFIED%type,
     p_oid bism_objects.OBJECT_ID%type,
     p_container_id bism_objects.CONTAINER_ID%type,
     p_fid bism_objects.FOLDER_ID%type,
	 p_obj_name bism_objects.OBJECT_NAME%type,
	 p_title bism_objects.TITLE%type,
	 p_application bism_objects.APPLICATION%type,
	 p_database bism_objects.DATABASE%type,
	 p_desc bism_objects.DESCRIPTION%type,
	 p_keywords bism_objects.KEYWORDS%type,
	 p_xml bism_objects.XML%type,
	 p_appsubtype1 bism_objects.APPLICATION_SUBTYPE1%type,
	 p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
	 p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
	 p_compsubtype3	bism_objects.COMP_SUBTYPE3%type)
is
    ret varchar2(1);
    created_subid bism_subjects.subject_id%type;
    modified_subid bism_subjects.subject_id%type;
begin
    begin
        select subject_id into created_subid from bism_subjects where subject_name = p_creator and subject_type ='u';
        select subject_id into modified_subid from bism_subjects where subject_name = p_modifier and subject_type ='u';
    exception
        when no_data_found then
        raise_application_error(-20503,'User not found');
        /* let other exceptions bubble up */
    end;

	-- object level security, rebind requires WRITE privilege on the object ONLY
	-- nothing to do with parent folder
    ret := bism_access_control.check_upd_access(null,p_oid,'n',p_subject_id);
    if ret = 'y' then
        update bism_objects set USER_VISIBLE=p_visible,OBJECT_TYPE_ID=p_obj_type_id,VERSION=p_version,TIME_DATE_CREATED=p_time_created,
                                TIME_DATE_MODIFIED=p_time_modified,OBJECT_ID=p_oid,CONTAINER_ID=p_container_id,FOLDER_ID=p_fid,
                                CREATED_BY=created_subid,LAST_MODIFIED_BY=modified_subid,OBJECT_NAME=p_obj_name,TITLE=p_title,
                                APPLICATION=p_application,DATABASE=p_database,DESCRIPTION=p_desc,KEYWORDS=p_keywords,XML=p_xml,
                                APPLICATION_SUBTYPE1=p_appsubtype1,COMP_SUBTYPE1=p_compsubtype1,COMP_SUBTYPE2=p_compsubtype2,
                                COMP_SUBTYPE3=p_compsubtype3 where user_visible = 'Y' and object_id = p_oid;
    end if;
end rebind;
-- end refactoring code for init, bind, rebind, createSubcontext


-- new methods for object level security feature
function add_entries(oid in raw,acllist in out nocopy bism_acl_obj_t,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2)
return bism_acl_obj_t
is
    newguid bism_objects.object_id%type:= null;
    username bism_subjects.subject_name%type;
    objname bism_objects.object_name%type;
    priv number(2);
    grantorpriv number(2);
    newusers bism_acl_obj_t := bism_acl_obj_t();
    dummy bism_acl_obj_t := bism_acl_obj_t();
    sid raw(16);
begin
    if acllist.count = 0 then
        return null;
    end if;

    select max(privilege) into grantorpriv from bism_permissions where object_id = oid and subject_id in (select group_id from bism_groups where user_id = myid);

    if grantorpriv is null then
        begin
            -- see if object exists
            select object_name into objname from bism_objects where object_id = oid;
            raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'Grantor has no privileges for folder');
        exception
            when no_data_found then
                raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
        end;
    end if;

    if grantorpriv < 50 then
        raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Grantor has insufficient privileges');
    end if;

    if topfolder = 'y' or topfolder = 'Y' then
        for i in 1..acllist.count
		loop
            begin
                select subject_id into sid from bism_subjects where subject_name = acllist(i).subjname;
                acllist(i).subjid := sid;
            exception
            when no_data_found then
                --generate a new id for the new user
                newguid := bism_utils.get_guid;
                -- dont throw exception, instead return the acl object of the new user to
                -- the caller so that the JdbcAdapter can cache the name to Id mapping
                newusers.extend();
                newusers(newusers.count) :=  bism_acl_obj(acllist(i).subjname,acllist(i).privilege, newguid);
                insert into bism_subjects (SUBJECT_ID, SUBJECT_NAME, SUBJECT_TYPE) values (newguid,acllist(i).subjname,'u');
                insert into bism_groups (USER_ID, GROUP_ID) values(newguid,newguid);
                acllist(i).subjid := newguid;
            end;
        end loop;
    end if;

    -- ok the grantor has enough privilege, proceed with adding entries
    for i in 1..acllist.count
	loop
        if acllist(i).subjid is not null then
            delete from bism_permissions where object_id = oid and subject_id = acllist(i).subjid;
        end if;
    end loop;

    for i in 1..acllist.count
	loop
        if acllist(i).subjid is not null then
            insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(acllist(i).subjid,oid,acllist(i).privilege);
        end if;
    end loop;

    -- do it for folder only
    if isfolder = 'y' or isfolder = 'Y' then
        -- new functionality (ccchow)
        -- cascading acl to all existing objects within the folder
        if cascade_to_objs = 'y' or cascade_to_objs = 'Y' then
            -- first find all the objects within the folder
			for i in (select object_id, object_type_id from bism_objects where folder_id = oid and user_visible = 'Y')
            loop
                -- remove all existing entries
                for j in 1..acllist.count
			    loop
                    if acllist(j).subjid is not null then
                        delete from bism_permissions where object_id = i.object_id and subject_id = acllist(j).subjid;
                    end if;
                end loop;

                -- add the new entries
                for j in 1..acllist.count loop
                    if acllist(j).subjid is not null then
                        -- for non-folder, need to map ADDFOLDER to LIST and LIST to nothing
                        if i.object_type_id = 100 then
                            insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(acllist(j).subjid,i.object_id,acllist(j).privilege);
                        else
                            if acllist(j).privilege > 10 then
                                if acllist(j).privilege = 30 then
                                    insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(acllist(j).subjid,i.object_id,20);
                                else
                                    insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(acllist(j).subjid,i.object_id,acllist(j).privilege);
                                end if;
                            end if;
                        end if;
                    end if;
                end loop;
            end loop;
        end if;

        if cascade_to_subfolders = 'y' or cascade_to_subfolders = 'Y' then
            for i in (select object_id from bism_objects where folder_id = oid and object_type_id = 100 and user_visible='Y' )
			loop
                -- ignore the return value dummy because it should be null
                -- we only create new user in first level frame
                -- (ccchow) always cascade to existing objects in subfolders as well, as in NT
                dummy := add_entries(i.object_id,acllist,myid,cascade_to_subfolders,'y','n','y');
            end loop;
        end if;
    end if;
    return newusers;
end add_entries;

procedure add_entries_30(oid in raw,acllist in CLOB,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2, aclseparator in varchar2)
-- return bism_acl_obj_t
is
    newguid bism_objects.object_id%type:= null;
    username bism_subjects.subject_name%type;
    objname bism_objects.object_name%type;
    priv number(2);
    grantorpriv number(2);
    sid bism_subjects.SUBJECT_ID%TYPE;
    startpos INTEGER := 1;
    usrnm BISM_SUBJECTS.SUBJECT_NAME%TYPE;
    usrpriv BISM_PERMISSIONS.PRIVILEGE%TYPE;
    usrtype BISM_SUBJECTS.SUBJECT_TYPE%TYPE;
begin
    if (acllist is null) or (DBMS_LOB.getlength(acllist) = 0) then
        return;
    end if;

    select max(privilege) into grantorpriv from bism_permissions where object_id = oid and subject_id in (select group_id from bism_groups where user_id = myid);

    if grantorpriv is null then
        begin
            -- see if object exists
            select object_name into objname from bism_objects where object_id = oid;
            raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'Grantor has no privileges for folder');
        exception
            when no_data_found then
                raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
        end;
    end if;

    if grantorpriv < 50 then
        raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Grantor has insufficient privileges');
    end if;

    loop
    if startpos <> 0 then
        begin
	    -- parse acllist to get user name and privilege
            usrnm := get_next_element(acllist,aclseparator,startpos);
            usrpriv := get_next_element(acllist,aclseparator,startpos);
            usrtype := get_next_element(acllist,aclseparator,startpos);
	    -- always do this for the top level objects: first time around
      if topfolder = 'Y' or topfolder = 'y' then
      begin
      select subject_id into sid from bism_subjects where subject_name = usrnm;
                 exception
                 when no_data_found then
                   --generate a new id for the new user
                   newguid := bism_utils.get_guid;
                   insert into bism_subjects (SUBJECT_ID, SUBJECT_NAME, SUBJECT_TYPE) values (newguid,usrnm,usrtype);
                   insert into bism_groups (USER_ID, GROUP_ID) values(newguid,newguid);
	           sid := newguid;
     		end;
            else
		-- same as in topfolder but there won't be an exception
                -- because we already inserted the user if he wasn't present
	        select subject_id into sid from bism_subjects where subject_name = usrnm;
	    end if;

        -- ok the grantor has enough privilege, proceed with adding entries
        if sid is not null then
            delete from bism_permissions where object_id = oid and subject_id = sid;
            insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(sid,oid,usrpriv);
        end if;

    -- do it for folder only
    if isfolder = 'Y' or isfolder = 'y' then
        -- new functionality (ccchow)
        -- cascading acl to all existing objects within the folder
        if cascade_to_objs = 'Y' or cascade_to_objs = 'y' then
            -- first find all the objects within the folder
            for i in (select object_id, object_type_id from bism_objects where folder_id = oid and user_visible = 'Y')
            loop
                -- remove all existing entries
                    if sid is not null then
                        delete from bism_permissions where object_id = i.object_id and subject_id = sid;
                -- add the new entries
                        -- for non-folder, need to map ADDFOLDER to LIST and LIST to nothing
                        if i.object_type_id = 100 then
                            insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(sid,i.object_id,usrpriv);
                        else
                            if usrpriv > 10 then
                                if usrpriv = 30 then
                                    insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(sid,i.object_id,20);
                                else
                                    insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(sid,i.object_id,usrpriv);
                                end if;
                            end if;
                        end if;
                    end if;
            end loop;
        end if;

    end if; -- end of if folders only

        end; -- inside acllist loop
    else
	goto exit_loop;
    end if;
    end loop;
    <<exit_loop>>

    -- do it for folder only
        if (isfolder = 'Y' or isfolder = 'y') and (cascade_to_subfolders = 'Y' or cascade_to_subfolders = 'y') then
            for i in (select object_id from bism_objects where folder_id = oid and object_type_id = 100 and user_visible='Y' )
			loop
                add_entries_30(i.object_id,acllist,myid,cascade_to_subfolders,'Y','N','Y',aclseparator);
            end loop;
        end if;
--    return newusers;
end add_entries_30;

function remove_entries(oid in raw,acllist in out nocopy  bism_acl_obj_t,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2)
return bism_chararray_t
is
    username bism_subjects.subject_name%type;
    objname bism_objects.object_name%type;
    priv number(2);
    grantorpriv number(2);
    errormsgs bism_chararray_t := bism_chararray_t();
    childerrormsgs bism_chararray_t := bism_chararray_t();
    errors_occured boolean;
    sid raw(16);

    -- used for cascading acl to objects
    type oid_t is table of bism_objects.object_id%type;
    oid_var oid_t := oid_t();
begin
    if acllist is null then
        return null;
    end if;

    select max(privilege) into grantorpriv from bism_permissions where object_id = oid and subject_id in (select group_id from bism_groups where user_id = myid);

    if grantorpriv is null then
        begin
            -- see if object exists
            select object_name into objname from bism_objects where object_id = oid;
            raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'Grantor has no privileges for folder');
        exception
		    when no_data_found then
                raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
        end;
    end if;

    if grantorpriv < 50 then
        raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Grantor has insufficient privileges');
    end if;

    if topfolder = 'Y' or topfolder = 'y' then
        for i in 1..acllist.count
		loop
            begin
                select subject_id into sid from bism_subjects where subject_name = acllist(i).subjname;
                acllist(i).subjid := sid;
            exception
            when no_data_found then
                errors_occured := true;
                errormsgs.extend();
                errormsgs(errormsgs.count) := 'User '|| acllist(i).subjname || ' not found';
                acllist(i).subjid := null;
                acllist(i).subjname := null;
                acllist(i).privilege := 0;
            end;
        end loop;
    end if;

    -- ok the user has enough privilege, proceed with removing entries
    for i in 1..acllist.count
	loop
        if acllist(i).subjid is not null then
            delete from bism_permissions where object_id = oid and subject_id = acllist(i).subjid;
        end if;
    end loop;

    -- do it for folder only
    if isfolder = 'Y' or isfolder = 'y' then
        -- new functionality (ccchow)
        -- cascading acl to all existing objects within the folder
        if cascade_to_objs = 'Y' or cascade_to_objs = 'y' then
            -- first find all the objects within the folder
            select object_id bulk collect into oid_var from bism_objects where folder_id = oid and user_visible = 'Y';

            if oid_var.COUNT > 0 then
                for i in oid_var.FIRST..oid_var.LAST
		    	loop
                    -- remove the specified entries
                    for j in 1..acllist.count
   				    loop
                        if acllist(j).subjid is not null then
                            delete from bism_permissions where object_id = oid_var(i) and subject_id = acllist(j).subjid;
                        end if;
                    end loop;
                end loop;
            end if;
        end if;

        if cascade_to_subfolders = 'Y' or cascade_to_subfolders = 'y' then
            for i in (select object_id from bism_objects where folder_id = oid and object_type_id = 100 and user_visible='Y')
			loop
                -- ignore the return value childerrormsgs because it should be null
                -- we check for errors only when it is a top level folder and that means
                -- errormsgs in the top level frame should capture any errors
                childerrormsgs := remove_entries(i.object_id,acllist,myid,cascade_to_subfolders,'Y','N','Y');
            end loop;
        end if;
    end if;

    return errormsgs;
end remove_entries;

function remove_entries_30(oid in raw,acllist in out nocopy CLOB,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2, aclseparator in varchar2)
--return bism_chararray_t
return varchar2
is
    username bism_subjects.subject_name%type;
    objname bism_objects.object_name%type;
    priv number(2);
    grantorpriv number(2);
    errormsgs varchar2(32767) := '';
    childerrormsgs varchar2(32767) := '';
--    errormsgs bism_chararray_t := bism_chararray_t();
--    childerrormsgs bism_chararray_t := bism_chararray_t();
    errors_occured boolean;
    sid bism_subjects.SUBJECT_ID%TYPE;
    startpos INTEGER := 1;
    usrnm BISM_SUBJECTS.SUBJECT_NAME%TYPE;
    usrpriv BISM_PERMISSIONS.PRIVILEGE%TYPE;

    -- used for cascading acl to objects
    type oid_t is table of bism_objects.object_id%type;
    oid_var oid_t := oid_t();
begin
    if (acllist is null) or (DBMS_LOB.getlength(acllist) = 0) then
        return null;
    end if;

    select max(privilege) into grantorpriv from bism_permissions where object_id = oid and subject_id in (select group_id from bism_groups where user_id = myid);

    if grantorpriv is null then
        begin
            -- see if object exists
            select object_name into objname from bism_objects where object_id = oid;
            raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'Grantor has no privileges for folder');
        exception
		    when no_data_found then
                raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
        end;
    end if;

    if grantorpriv < 50 then
        raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Grantor has insufficient privileges');
    end if;

    loop
    if startpos <> 0 then
        begin
	    -- parse acllist to get user name and privilege
            usrnm := get_next_element(acllist,aclseparator,startpos);
            usrpriv := get_next_element(acllist,aclseparator,startpos);
	    -- always do this for the top level objects: first time around
            begin
                select subject_id into sid from bism_subjects where subject_name = usrnm;
            exception
            when no_data_found then
                errors_occured := true;
                errormsgs := errormsgs || ' ' || usrnm;
                sid := null;
                usrnm := null;
                usrpriv := 0;
            end;
--    end if;

    -- ok the user has enough privilege, proceed with removing entries
        if sid is not null then
            delete from bism_permissions where object_id = oid and subject_id = sid;
        end if;

    -- do it for folder only
    if isfolder = 'Y' or isfolder = 'y' then
        -- new functionality (ccchow)
        -- cascading acl to all existing objects within the folder
        if cascade_to_objs = 'Y' or cascade_to_objs = 'y' then
            -- first find all the objects within the folder
            select object_id bulk collect into oid_var from bism_objects where folder_id = oid and user_visible = 'Y';

            if oid_var.COUNT > 0 then
                for i in oid_var.FIRST..oid_var.LAST
		    	loop
                    -- remove the specified entries
                        if sid is not null then
                            delete from bism_permissions where object_id = oid_var(i) and subject_id = sid;
                        end if;
                end loop;
            end if;
        end if;

    end if; -- end of if folders only

        end; -- inside acllist loop
    else
	goto exit_loop;
    end if;
    end loop;
    <<exit_loop>>

    -- do it for folder only
    if (isfolder = 'Y' or isfolder = 'y') and (cascade_to_subfolders = 'Y' or cascade_to_subfolders = 'y') then
            for i in (select object_id from bism_objects where folder_id = oid and object_type_id = 100 and user_visible='Y')
			loop
                -- ignore the return value childerrormsgs because it should be null
                -- we check for errors only when it is a top level folder and that means
                -- errormsgs in the top level frame should capture any errors
                childerrormsgs := remove_entries_30(i.object_id,acllist,myid,cascade_to_subfolders,'Y','N','Y',aclseparator);
            end loop;
    end if;


    return errormsgs;
end remove_entries_30;

-- new function (ccchow)
-- basically, same as add_entires except replaces every acl
function set_entries(oid in raw,acllist in out nocopy  bism_acl_obj_t,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2)
return bism_acl_obj_t
is
    newguid bism_objects.object_id%type:= null;
    objname bism_objects.object_name%type;
    username bism_subjects.subject_name%type;
    priv number(2);
    grantorpriv number(2);
    newusers bism_acl_obj_t := bism_acl_obj_t();
    dummy bism_acl_obj_t := bism_acl_obj_t();
    sid raw(16);
begin
    -- make sure grantor has privilege and enough privilege
    select max(privilege) into grantorpriv from bism_permissions where object_id = oid and subject_id in (select group_id from bism_groups where user_id = myid);

    if grantorpriv is null then
        begin
            -- see if object exists
            select object_name into objname from bism_objects where object_id = oid;
            raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'Grantor has no privileges for folder');
        exception
            when no_data_found then
                raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
        end;
	end if;

    if grantorpriv < 50 then
        raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Grantor has insufficient privileges');
    end if;

    if topfolder = 'Y' or topfolder = 'y' then
        for i in 1..acllist.count
		loop
            begin
                select subject_id into sid from bism_subjects where subject_name = acllist(i).subjname;
                acllist(i).subjid := sid;
            exception
            when no_data_found then
                --generate a new id for the new user
                newguid := bism_utils.get_guid;
                -- dont throw exception, instead return the acl object of the new user to
                -- the caller so that the JdbcAdapter can cache the name to Id mapping
                newusers.extend();
                newusers(newusers.count) :=  bism_acl_obj(acllist(i).subjname,acllist(i).privilege, newguid);
                insert into bism_subjects (SUBJECT_ID, SUBJECT_NAME, SUBJECT_TYPE) values (newguid,acllist(i).subjname,'u');
                insert into bism_groups (USER_ID, GROUP_ID) values(newguid,newguid);
                acllist(i).subjid := newguid;
            end;
        end loop;
    end if;

    -- ok the grantor has enough privilege, proceed with setting entries

	-- first remove all previous entries
    delete from bism_permissions where object_id = oid and subject_id <> myid;

    -- insert entries for this object
    for i in 1..acllist.count loop
        if acllist(i).subjid is not null then
            insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(acllist(i).subjid,oid,acllist(i).privilege);
        end if;
    end loop;

    -- do it for folder only
    if isfolder = 'Y' or isfolder = 'y' then
        -- new functionality (ccchow)
        -- cascading acl to all existing objects within the folder
        if cascade_to_objs = 'Y' or cascade_to_objs = 'y' then
            -- first find all the objects within the folder
            for i in (select object_id, object_type_id from bism_objects where folder_id = oid and user_visible = 'Y')
			loop
                -- remove all existing entries
                delete from bism_permissions where object_id = i.object_id and subject_id <> myid;

                -- add the new entries
                for j in 1..acllist.count
				loop
                    if acllist(j).subjid is not null then
                        -- for non-folder, need to map ADDFOLDER to LIST and LIST to nothing
                        if i.object_type_id = 100 then
                            insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(acllist(j).subjid,i.object_id,acllist(j).privilege);
                        else
                            if acllist(j).privilege > 10 then
                                if acllist(j).privilege = 30 then
                                    insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(acllist(j).subjid,i.object_id,20);
                                else
                                    insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(acllist(j).subjid,i.object_id,acllist(j).privilege);
                                end if;
                            end if;
                        end if;
                    end if;
                end loop;
            end loop;
        end if;

        if cascade_to_subfolders = 'Y' or cascade_to_subfolders = 'y' then
            for i in (select object_id from bism_objects where folder_id = oid and object_type_id = 100 and user_visible='Y' )
			loop
                -- ignore the return value dummy because it should be null
                -- we only create new user in first level frame
                -- (ccchow) always cascade to existing objects in subfolders as well, as in NT
                dummy := set_entries(i.object_id,acllist,myid,cascade_to_subfolders,'Y','N','Y');
            end loop;
        end if;
    end if;

    return newusers;
end set_entries;

-- new function (ccchow)
-- basically, same as add_entires except replaces every acl
procedure set_entries_30(oid in raw,acllist in out nocopy CLOB,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2, aclseparator in varchar2)
is
    newguid bism_objects.object_id%type:= null;
    objname bism_objects.object_name%type;
    username bism_subjects.subject_name%type;
    priv number(2);
    grantorpriv number(2);
    sid bism_subjects.SUBJECT_ID%TYPE;
    startpos INTEGER := 1;
    usrnm BISM_SUBJECTS.SUBJECT_NAME%TYPE;
    usrpriv BISM_PERMISSIONS.PRIVILEGE%TYPE;
    usrtype BISM_SUBJECTS.SUBJECT_TYPE%TYPE;
    firstTime boolean := true;
begin

    if (acllist is null) or (DBMS_LOB.getlength(acllist) = 0) then
        return;
    end if;

    -- make sure grantor has privilege and enough privilege
    select max(privilege) into grantorpriv from bism_permissions where object_id = oid and subject_id in (select group_id from bism_groups where user_id = myid);

    if grantorpriv is null then
        begin
            -- see if object exists
            select object_name into objname from bism_objects where object_id = oid;
            raise_application_error(BISM_ERRORCODES.NO_PRIVILEGES,'Grantor has no privileges for folder');
        exception
            when no_data_found then
                raise_application_error(BISM_ERRORCODES.OBJECT_NOT_FOUND,'Object not found');
        end;
    end if;

    if grantorpriv < 50 then
        raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIVILEGES,'Grantor has insufficient privileges');
    end if;

    loop
    if startpos <> 0 then
        begin
	    -- parse acllist to get user name and privilege
            usrnm := get_next_element(acllist,aclseparator,startpos);
            usrpriv := get_next_element(acllist,aclseparator,startpos);
            usrtype := get_next_element(acllist,aclseparator,startpos);
	    -- always do this for the top level objects: first time around
    if topfolder = 'Y' or topfolder = 'y' then
            begin
                select subject_id into sid from bism_subjects where subject_name = usrnm;
            exception
            when no_data_found then
                --generate a new id for the new user
                newguid := bism_utils.get_guid;
                -- dont throw exception, instead return the acl object of the new user to
                -- the caller so that the JdbcAdapter can cache the name to Id mapping
                insert into bism_subjects (SUBJECT_ID, SUBJECT_NAME, SUBJECT_TYPE) values (newguid,usrnm,usrtype);
                insert into bism_groups (USER_ID, GROUP_ID) values(newguid,newguid);
                sid := newguid;
            end;
            else
		-- same as in topfolder but there won't be an exception
                -- because we already inserted the user if he wasn't present
	        select subject_id into sid from bism_subjects where subject_name = usrnm;
	    end if;

    -- ok the grantor has enough privilege, proceed with setting entries

	-- first remove all previous entries
        if firstTime = true then
            delete from bism_permissions where object_id = oid and subject_id <> myid;
        end if;

    -- insert entries for this object
        if sid is not null then
            insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(sid,oid,usrpriv);
        end if;

    -- do it for folder only
    if isfolder = 'Y' or isfolder = 'y' then
        -- new functionality (ccchow)
        -- cascading acl to all existing objects within the folder
        if cascade_to_objs = 'Y' or cascade_to_objs = 'y' then
            -- first find all the objects within the folder
            for i in (select object_id, object_type_id from bism_objects where folder_id = oid and user_visible = 'Y')
			loop
                -- remove all existing entries
                if firstTime = true then
                   delete from bism_permissions where object_id = i.object_id and subject_id <> myid;
                end if;

                -- add the new entries
                    if sid is not null then
                        -- for non-folder, need to map ADDFOLDER to LIST and LIST to nothing
                        if i.object_type_id = 100 then
                            insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(sid,i.object_id,usrpriv);
                        else
                            if usrpriv > 10 then
                                if usrpriv = 30 then
                                    insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(sid,i.object_id,20);
                                else
                                    insert into bism_permissions (SUBJECT_ID, OBJECT_ID, PRIVILEGE) values(sid,i.object_id,usrpriv);
                                end if;
                            end if;
                        end if;
                    end if;
            end loop;
        end if;
    end if; -- end of if folders only
    firstTime := false;

        end; -- inside acllist loop
    else
	goto exit_loop;
    end if;
    end loop;
    <<exit_loop>>

    -- do it for folder only
        if (isfolder = 'Y' or isfolder = 'y') and (cascade_to_subfolders = 'Y' or cascade_to_subfolders = 'y') then
            for i in (select object_id from bism_objects where folder_id = oid and object_type_id = 100 and user_visible='Y' )
			loop
                set_entries_30(i.object_id,acllist,myid,cascade_to_subfolders,cascade_to_objs,'N','Y',aclseparator);
--                set_entries_30(i.object_id,acllist,myid,cascade_to_subfolders,'Y','N','Y',aclseparator);
            end loop;
        end if;

end set_entries_30;

function get_privilege(oid raw, myid raw) return number
is
    priv bism_permissions.privilege%type;
begin
    select nvl(max(privilege),0) into priv from bism_permissions where object_id = oid and subject_id in (select group_id from bism_groups where user_id = myid);
    return priv;
end get_privilege;

function list_dependents(p_fid bism_objects.FOLDER_ID%type, p_objname varchar2, p_myid raw)
return myrctype
is
  v_rc myrctype;
begin
  open v_rc for
  with
  visible_table as
  ( -- find all objects that contain the object we are interested in.
  select /*+ INDEX(BISM_OBJECTS) */ object_name as object_name, object_id as object_id, object_type_id as object_type_id, user_visible as user_visible
  from bism_objects
  where object_id in
  (
  select /*+ INDEX(BISM_AGGREGATES) */ container_id from bism_aggregates
  where containee_id in
  (
  select /*+ INDEX(BISM_OBJECTS) */ object_id from bism_objects
  where
  folder_id = p_fid
  and
  object_name = p_objname
  and 'y' = bism_access_control.check_read_access(object_id, p_fid,'n', p_myid)
  )
  and container_id <> '30'
  )
  )
  select /*+ INDEX(BISM_OBJECTS) */ bism_core.get_object_full_name(object_id), object_type_id
  from bism_objects
  where
  object_id in (  select object_id from visible_table where user_visible = 'Y' )
  union
  select /*+ INDEX(BISM_OBJECTS) */ bism_core.get_object_full_name(object_id), object_type_id
  from bism_objects
  where object_id
  in
  (
  select distinct object_id from bism_objects c
  start with object_id
  in ( select object_id from visible_table where user_visible = 'N' )
  connect by  prior container_id =   object_id
  )
  and user_visible ='Y';
  return v_rc;
end list_dependents;

procedure update_attribute(a_fid raw,a_obj_name varchar2,a_attr_name varchar2, a_attr_val varchar2, a_sub_id raw)
is
ret varchar2(1) := 'n';
status number;
v_uv bism_objects.user_visible%type := 'Y';
created_subid raw(16) := null;
modified_subid raw(16) := null;
begin

if a_sub_id is null or length(a_sub_id) = 0 then
raise_application_error(-20503,'User not found');
end if;

ret := bism_core.check_modify_attrs_access(a_fid, a_obj_name,a_sub_id , status, 1);

if ret = 'y' then
-- if created by and modified by were specified, look them up, we need them later
if a_attr_name = 'created_by' or a_attr_name = 'CREATED_BY' then
if a_attr_val is not null then
begin
select subject_id into created_subid from bism_subjects
where
subject_name = a_attr_val and subject_type ='u';
EXECUTE IMMEDIATE 'update bism_objects set created_by = :1 where folder_id = :2  and user_visible = :3 and object_name = :4 '
   using created_subid,a_fid, v_uv , a_obj_name;
exception
when no_data_found then
raise_application_error(-20503,'User not found');
end;
end if;
elsif a_attr_name = 'last_modified_by' or a_attr_name = 'LAST_MODIFIED_BY' then
if a_attr_val is not null then
begin
select subject_id into modified_subid from bism_subjects
where
subject_name = a_attr_val and subject_type ='u';
EXECUTE IMMEDIATE 'update bism_objects set last_modified_by = :1
   where folder_id = :2 and user_visible = :3 and object_name = :4'
   using modified_subid, a_fid, v_uv, a_obj_name;
exception
when no_data_found then
raise_application_error(-20503,'User not found');
end;
else
-- use current user id
EXECUTE IMMEDIATE 'update bism_objects set last_modified_by  =  :1
   where folder_id = :2 and user_visible = :3 and object_name = :4 '
   using a_sub_id,a_fid,v_uv,a_obj_name;
end if;

else

-- if it is not created_by or last_modified_by, issue the update command
   EXECUTE IMMEDIATE 'update bism_objects set '|| a_attr_name||' = :1
   where folder_id = :2 and user_visible = :3 and object_name = :4 '
   using a_attr_val,a_fid,v_uv,a_obj_name;
end if;
end if;

end update_attribute;

procedure update_date_attribute(a_fid raw,a_obj_name varchar2,a_attr_name varchar2, a_attr_val date, a_sub_id raw)
is
ret varchar2(1) := 'n';
status number;
b_var char(1);
v_uv bism_objects.user_visible%type:='Y';
created_subid raw(16) := null;
modified_subid raw(16) := null;
begin

if a_sub_id is null or length(a_sub_id) = 0 then
raise_application_error(-20503,'User not found');
end if;

ret := bism_core.check_modify_attrs_access(a_fid, a_obj_name,a_sub_id , status, 1);
if ret = 'y' then
begin
  if a_attr_val is not null then
    if a_attr_name = 'time_date_created' then
     EXECUTE IMMEDIATE 'update bism_objects set time_date_created = :1
     where folder_id = :2 and user_visible = :3 and object_name = :4 '
     using a_attr_val,a_fid,v_uv,a_obj_name;
    elsif a_attr_name = 'time_date_modified' then
     EXECUTE IMMEDIATE 'update bism_objects set time_date_modified = :1
     where folder_id = :2 and user_visible = :3 and object_name = :4 '
     using a_attr_val,a_fid,v_uv,a_obj_name;
    elsif a_attr_name = 'time_date_last_accessed' then
     EXECUTE IMMEDIATE 'update bism_objects set time_date_last_accessed = :1
     where folder_id = :2 and user_visible = :3 and object_name = :4 '
     using a_attr_val,a_fid,v_uv,a_obj_name;
    end if;
  else
    if a_attr_name = 'time_date_created' then
      EXECUTE IMMEDIATE 'update bism_objects set time_date_created = :1
      where folder_id = :2 and user_visible = :3 and object_name = :4 '
      using sysdate, a_fid, v_uv,a_obj_name;
    elsif a_attr_name = 'time_date_modified' then
      EXECUTE IMMEDIATE 'update bism_objects set time_date_modified = :1
      where folder_id = :2 and user_visible = :3 and object_name = :4 '
      using sysdate, a_fid, v_uv,a_obj_name;
    elsif a_attr_name = 'time_date_last_accessed' then
      EXECUTE IMMEDIATE 'update bism_objects set time_date_last_accessed = :1
      where folder_id = :2 and user_visible = :3 and object_name = :4 '
      using sysdate, a_fid, v_uv,a_obj_name;
    end if;
  end if;
end;

end if;

end update_date_attribute;

procedure update_attribute(a_fid raw,a_obj_name varchar2,a_ext_attr_xml varchar2, a_sub_id raw)
is
ret varchar2(1) := 'n';
status number;
b_var char(1);
created_subid raw(16) := null;
modified_subid raw(16) := null;
v_attrs_xml varchar2(4000);
v_uv bism_objects.user_visible%type:='Y';

begin

if a_ext_attr_xml is null or length(a_ext_attr_xml) = 0 then
return;
end if;

if a_sub_id is null or length(a_sub_id) = 0 then
raise_application_error(-20503,'User not found');
end if;

ret := bism_core.check_modify_attrs_access(a_fid, a_obj_name,a_sub_id , status, 1);
if ret = 'y' then
begin
-- there should be three bind variables in the incoming update statement
-- from modifyATtributes API
-- this is on purpose to prevent users from updating objects that they dont have access to
EXECUTE IMMEDIATE a_ext_attr_xml using a_fid, v_uv,a_obj_name;

end;
end if;

end update_attribute;

procedure set_auto_commit(p_val varchar2)
is
begin
if p_val = 'Y' or p_val = 'y' then
v_auto_commit := TRUE;
else
v_auto_commit := FALSE;
end if;
end;
end  bism_core;

/
