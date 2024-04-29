--------------------------------------------------------
--  DDL for Package Body BISM_WEAKAGGREGATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BISM_WEAKAGGREGATES" as
/* $Header: bibasctb.pls 120.2 2006/04/03 05:19:39 akbansal noship $ */
procedure associate(fid raw, a_srcpath varchar2,a_tgtpath varchar2,name varchar2,value varchar2, myid raw)
is
a_srcname bism_objects.object_name%type;
a_srcid bism_objects.object_id%type;
a_srctypeid bism_objects.object_type_id%type;
a_tgtname bism_objects.object_name%type;
a_tgtid bism_objects.object_id%type;
a_tgttypeid bism_objects.object_type_id%type;
ret varchar2(1);
-- I need to map the following exceptions
invalid_folder_path EXCEPTION;
object_not_found EXCEPTION;
no_privileges EXCEPTION;
insufficient_provileges EXCEPTION;
folder_not_found EXCEPTION;

PRAGMA EXCEPTION_INIT(invalid_folder_path, -20706);
PRAGMA EXCEPTION_INIT(object_not_found,-20200);
PRAGMA EXCEPTION_INIT(no_privileges, -20404);
PRAGMA EXCEPTION_INIT(insufficient_provileges, -20400);
PRAGMA EXCEPTION_INIT(folder_not_found, -20300);

begin

if name is null or value is null then
raise_application_error(BISM_ERRORCODES.INVALID_ARGUMENTS,'Null value specified');
end if;

-- lookuphelper walks through the path checking privileges all the way down
-- the user only needs LIST access on the all but last folders making up
-- the path, he needs READ access on the (last) folder where the object resides
--check the source object first
begin
-- a_srcpath will be null if the user specified an empty string in call to
-- associate() method in Java, setString(n,"") turns out to be null in plsql
-- if it is null in plsql, assume that the user wanted to use fid as src object
-- if user called Java API with a null, an exception will be thrown
if a_srcpath is not null then
bism_core.lookuphelper(fid,a_srcpath,a_srcname,a_srcid,a_srctypeid,myid);
else
-- when null is supplied for srcname, it means that the user wanted
-- this folder to be src object
ret := bism_access_control.check_list_access(fid,myid);
-- check_list_access will throw an exception if not enough privs
a_srcid := fid;
a_srctypeid := 100;
end if;
exception

-- check for exceptions and map them as being related to the source object
-- so that the caller can distringuish

when object_not_found then
raise_application_error(BISM_ERRORCODES.SRC_OBJECT_NOT_FOUND,'Source object not found');
when no_privileges then
raise_application_error(BISM_ERRORCODES.NO_PRIV_SRC_FOLDER,'No privileges for source folder');
when insufficient_provileges then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_SRC_FOLDER,'Insufficient privileges for source folder');
when folder_not_found then
raise_application_error(BISM_ERRORCODES.SRC_FOLDER_NOT_FOUND,'Source folder not found');
when others then
raise;
end;

begin
-- a_tgtpath will be null if the user specified an empty string in call to
-- associate() method in Java, setString(n,"") turns out to be null in plsql
-- if it is null, assume that the user wanted to use fid as src object

if a_tgtpath is not null then
bism_core.lookuphelper(fid,a_tgtpath,a_tgtname,a_tgtid,a_tgttypeid,myid);
else
-- when null is supplied for srcname, it means that the user wanted
-- this folder to be src object
ret := bism_access_control.check_list_access(fid,myid);
a_tgtid := fid;
a_tgttypeid := 100;
end if;

exception

-- check for exceptions and map them as being related to the target object
-- so that the caller can distringuish

when object_not_found then
raise_application_error(BISM_ERRORCODES.TGT_OBJECT_NOT_FOUND,'Target object not found');
when no_privileges then
raise_application_error(BISM_ERRORCODES.NO_PRIV_TGT_FOLDER,'No privileges for target folder');
when insufficient_provileges then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_TGT_FOLDER,'Insufficient privileges for target folder');
when folder_not_found then
raise_application_error(BISM_ERRORCODES.TGT_FOLDER_NOT_FOUND,'Target folder not found');
when others then
raise;
end;

--if something went wrong, it would have thrown exception by now, so every thing
-- is a OK
insert into bism_associates (source_id,target_id,name,value) values (a_srcid,a_tgtid,name,value);
-- if there is any exceptions, let it bubble up

end;

procedure dissociate(fid raw, a_srcpath varchar2, a_name varchar2, a_value varchar2,myid raw)
is
ret varchar2(1);
a_srcname bism_objects.object_name%type;
a_srcid bism_objects.object_id%type;
a_srctypeid bism_objects.object_type_id%type;
rows_deleted integer:= 0;

invalid_folder_path EXCEPTION;
object_not_found EXCEPTION;
no_privileges EXCEPTION;
insufficient_provileges EXCEPTION;
folder_not_found EXCEPTION;

PRAGMA EXCEPTION_INIT(invalid_folder_path, -20706);
PRAGMA EXCEPTION_INIT(object_not_found,-20200);
PRAGMA EXCEPTION_INIT(no_privileges, -20404);
PRAGMA EXCEPTION_INIT(insufficient_provileges, -20400);
PRAGMA EXCEPTION_INIT(folder_not_found, -20300);

begin


-- lookuphelper walks through the path checking privileges all the way down
-- the caller only needs list access on the last but one folders making up
-- the path but he needs READ access on the folder where the object resides

begin

-- a_srcpath will be null if the user specified an empty string in call to
-- dissociate() method in Java, setString(n,"") turns out to be null in plsql
-- if it is null, assume that the user wanted to use fid as src object

if a_srcpath is not null then
bism_core.lookuphelper(fid,a_srcpath,a_srcname,a_srcid,a_srctypeid,myid);
else
ret := bism_access_control.check_list_access(fid,myid);
a_srcid := fid;
a_srctypeid := 100;
end if;
-- check for exceptions and map them as being related to the source object
-- so that the caller can distringuish
exception
when object_not_found then
raise_application_error(BISM_ERRORCODES.SRC_OBJECT_NOT_FOUND,'Source object not found');
when no_privileges then
raise_application_error(BISM_ERRORCODES.NO_PRIV_SRC_FOLDER,'No privileges for source folder');
when insufficient_provileges then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_SRC_FOLDER,'Insufficient privileges for source folder');
when folder_not_found then
raise_application_error(BISM_ERRORCODES.SRC_FOLDER_NOT_FOUND,'Source folder not found');
when others then
raise;
end;

-- we dont care about the target object, because the uniqueness lies
-- in source-name-value

--if something went wrong, it would have thrown exception by now, so every thing
-- is a OK

if a_srcid is not null and a_name is null then
delete from bism_associates where source_id = a_srcid;
elsif a_srcid is not null and a_name is not null and a_value is null then
delete from bism_associates where source_id = a_srcid and name = a_name;
else
delete from bism_associates where source_id = a_srcid and name = a_name and value = a_value;
end if;

rows_deleted := SQL%ROWCOUNT;
if rows_deleted = 0 then
raise_application_error(BISM_ERRORCODES.ASSOCIATION_NOT_FOUND, 'Association not found');
end if;
-- if there is any exceptions, let it bubble up

end;

function get_associate(fid raw,a_srcpath varchar2,a_attrname varchar2,a_attrvalue varchar2,myid raw)
return myrctype
is
rc myrctype;
ret varchar2(1);
a_srcname bism_objects.object_name%type;
a_srcid bism_objects.object_id%type;
a_srctypeid bism_objects.object_type_id%type;
b_tgtid bism_objects.object_id%type;
invalid_folder_path EXCEPTION;
object_not_found EXCEPTION;
no_privileges EXCEPTION;
insufficient_provileges EXCEPTION;
folder_not_found EXCEPTION;

PRAGMA EXCEPTION_INIT(invalid_folder_path, -20706);
PRAGMA EXCEPTION_INIT(object_not_found,-20200);
PRAGMA EXCEPTION_INIT(no_privileges, -20404);
PRAGMA EXCEPTION_INIT(insufficient_provileges, -20400);
PRAGMA EXCEPTION_INIT(folder_not_found, -20300);

begin

-- let the caller check the validity of the input arguments

begin

if a_srcpath is not null then
bism_core.lookuphelper(fid,a_srcpath,a_srcname,a_srcid,a_srctypeid,myid);
else
ret := bism_access_control.check_list_access(fid,myid);
a_srcid := fid;
end if;
-- check for exceptions and map them as being related to the source object
-- so that the caller can distringuish
exception
when object_not_found then
raise_application_error(BISM_ERRORCODES.SRC_OBJECT_NOT_FOUND,'Source object not found');
when no_privileges then
raise_application_error(BISM_ERRORCODES.NO_PRIV_SRC_FOLDER,'No privileges for source folder');
when insufficient_provileges then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_SRC_FOLDER,'Insufficient privileges for source folder');
when folder_not_found then
raise_application_error(BISM_ERRORCODES.SRC_FOLDER_NOT_FOUND,'Source folder not found');
when others then
raise;
end;

begin
select target_id into b_tgtid from bism_associates where source_id = a_srcid and name = a_attrname and value = a_attrvalue;
exception
when no_data_found then
raise_application_error(BISM_ERRORCODES.ASSOCIATION_NOT_FOUND,'Association not found');
when others then
raise;
end;

return object_load(b_tgtid);
end;

function object_load (objid raw) return myrctype
is
rc myrctype;
begin

begin
-- this method is not being used currently !!
-- the foll. sql stmt is m_fetchObjectsSQL2 inside SQLBuilder
open rc for SELECT T.USER_VISIBLE, T.OBJECT_TYPE_ID, T.VERSION, T.TIME_DATE_CREATED,
T.TIME_DATE_MODIFIED, T.OBJECT_ID,T.FOLDER_ID, T.CREATED_BY,
T.LAST_MODIFIED_BY, T.OBJECT_NAME, T.TITLE, T.APPLICATION, T.DATABASE, T.DESCRIPTION,
T.KEYWORDS, T.XML, T.APPLICATION_SUBTYPE1, T.COMP_SUBTYPE1, T.COMP_SUBTYPE2,T.COMP_SUBTYPE3,T.TIME_DATE_LAST_ACCESSED,
T.container_id,T.aggregate_info from
(
SELECT A.USER_VISIBLE, A.OBJECT_TYPE_ID, A.VERSION, A.TIME_DATE_CREATED,
A.TIME_DATE_MODIFIED, A.OBJECT_ID,A.FOLDER_ID, A.CREATED_BY,
A.LAST_MODIFIED_BY, A.OBJECT_NAME, A.TITLE, A.APPLICATION, A.DATABASE, A.DESCRIPTION,
A.KEYWORDS, A.XML, A.APPLICATION_SUBTYPE1, A.COMP_SUBTYPE1, A.COMP_SUBTYPE2,A.COMP_SUBTYPE3, A.TIME_DATE_LAST_ACCESSED,
T1.container_id,T1.aggregate_info
from bism_objects A,
(
select distinct containee_id,container_id,aggregate_info from bism_aggregates start with containee_id = objid and container_id='30' connect by container_id = prior containee_id
order siblings by containee_id
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

procedure get(fid raw,path varchar2,a_objname out nocopy varchar2,a_objid out nocopy raw,a_typeid out nocopy number,myid raw,startpos in out nocopy integer,folderid out nocopy raw)
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
newstr := bism_core.get_next_element(path,'/',startpos);
len := nvl(length(newstr),0);
if len <> 0 then
    begin
    select object_id,object_type_id,object_name,user_visible into oid,typeid,oname,visible from bism_objects where folder_id = fid and object_name = newstr and user_visible = 'Y';
    ret := bism_access_control.check_list_access(fid,myid);

    if ret = 'y' then
        -- when the given string does not contain the delimiter any more
        -- get_next_element function will set startpos to zero
        -- indicating end of path
        if startpos <> 0 then
        	get(oid,path,a_objname,a_objid,a_typeid,myid,startpos,folderid);
        else
            -- if no more path, set the obj name, id and type
            -- of the last object in the path
		folderid := fid;
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

function verify_source(fid raw,a_srcpath varchar2,myid raw,folderid out nocopy raw)
return raw
is
rc bism_weakaggregates.myrctype;
a_srcname bism_objects.object_name%type;
a_srcid bism_objects.object_id%type;
a_srctypeid bism_objects.object_type_id%type;

invalid_folder_path EXCEPTION;
object_not_found EXCEPTION;
no_privileges EXCEPTION;
insufficient_provileges EXCEPTION;
folder_not_found EXCEPTION;

PRAGMA EXCEPTION_INIT(invalid_folder_path, -20706);
PRAGMA EXCEPTION_INIT(object_not_found,-20200);
PRAGMA EXCEPTION_INIT(no_privileges, -20404);
PRAGMA EXCEPTION_INIT(insufficient_provileges, -20400);
PRAGMA EXCEPTION_INIT(folder_not_found, -20300);
a_objname bism_objects.object_name%type;
a_objid bism_objects.object_id%type;
a_typeid bism_objects.object_type_id%type;
startpos integer := 1;-- unparsed string, so start at 1
ret varchar2(1);

begin

-- let the caller check the validity of the input arguments

begin
if a_srcpath is not null then
get(fid ,a_srcpath ,a_srcname ,a_srcid ,a_srctypeid ,myid ,startpos,folderid);
return a_srcid;
else
-- when user supplies an empty string into Java listAssociates() API
-- that methods binds "" to the bind variable which turns out to be
-- a null in plsql.
ret := bism_access_control.check_list_access(fid,myid);
if ret = 'y' then
folderid := fid;
return fid;
end if;
end if;
exception
when object_not_found then
raise_application_error(BISM_ERRORCODES.SRC_OBJECT_NOT_FOUND,'Source object not found');
when no_privileges then
raise_application_error(BISM_ERRORCODES.NO_PRIV_SRC_FOLDER,'No privileges for source folder');
when insufficient_provileges then
raise_application_error(BISM_ERRORCODES.INSUFFICIENT_PRIV_SRC_FOLDER,'Insufficient privileges for source folder');
when folder_not_found then
raise_application_error(BISM_ERRORCODES.SRC_FOLDER_NOT_FOUND,'Source folder not found');
when others then
raise;
end;

end;

end;

/
