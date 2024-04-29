--------------------------------------------------------
--  DDL for Package Body ECX_XSLT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_XSLT_UTILS" as
-- $Header: ECXXSLTB.pls 120.2.12010000.2 2008/08/22 20:04:39 cpeixoto ship $

LAST_UPDATED_BY		CONSTANT	pls_integer	:= 0;
CREATED_BY		CONSTANT	pls_integer	:= 0;
LAST_UPDATE_LOGIN	CONSTANT	pls_integer	:= 0;
FILE_TYPE		CONSTANT	varchar2(50)	:= 'XSLT';

procedure ins
        (
        i_filename      	in      varchar2,
        i_version		in	varchar2,
        i_application_code	in	varchar2,
        i_payload               in      clob,
        i_retcode               OUT     NOCOPY number,
        i_retmsg                OUT     NOCOPY varchar2
        )
is
   i_id			pls_integer;
   i_creation_date	date;
   i_new_version	number;
begin
   -- if version is null find out the max for the given details
   if (i_version is null)
   then
      begin
        select id, creation_date, version
         into   i_id, i_creation_date, i_new_version
         from   ecx_files
         where  application_code = i_application_code
          and   version = (select max(version)
                           from   ecx_files
                           where  application_code = i_application_code
			   and    name = i_filename
                           and    type = FILE_TYPE)
         and    name = i_filename
         and    type = FILE_TYPE;
	exception
         when no_data_found then
            -- since there is no max version present enter this in DB
            -- with default version = 0.0
            i_new_version := 0.0;
      end;
   else
      -- if the data already exists in the table get the creation date and the id
      -- and use this in the insert
      begin
	select id, creation_date
         into   i_id, i_creation_date
         from   ecx_files
         where  application_code = i_application_code
         and    version = i_version
         and    name = i_filename
         and    type = FILE_TYPE;

	exception
         when no_data_found then
            -- this is not present in the DB so insert it
            i_new_version := to_number(i_version);
            null;
      end;
   end if;

   if (i_id is not null AND i_creation_date is not null)
   then
      -- update the entry with the latest data
      update ecx_files
      set    last_update_date = sysdate,
             payload = i_payload
      where  id = i_id;
   else
      -- insert into ecx_files
      insert into ecx_files
           (
           id,
           type,
           name,
           version,
           application_code,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           payload
           )
      values
           (
           ecx_files_s.nextval,
           FILE_TYPE,
           i_filename,
           i_new_version,
           i_application_code,
           sysdate,
           LAST_UPDATED_BY,
           sysdate,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           i_payload
           );
   end if;
   i_retcode := 0;
   i_retmsg := ' XSLT name = ' || i_filename || ' application_code = ' || i_application_code ||
                ' version = ' || i_new_version || ' Successfully loaded';
exception
when others then
   i_retcode := 2;
   i_retmsg := SQLERRM || 'XSLT file cannot be loaded';
end ins;


procedure del
        (
        i_filename      	in      varchar2,
        i_version		in	varchar2,
        i_application_code	in	varchar2,
        i_retcode               OUT     NOCOPY number,
        i_retmsg                OUT     NOCOPY varchar2
        )
is

begin
   -- if version is null, delete the max version entry that matches the details
   if (i_version is null)
   then
      delete from ecx_files
      where  application_code = i_application_code
      and   version = (select max(version)
                        from   ecx_files
                        where   application_code = i_application_code
			and    name = i_filename
                        and    type = FILE_TYPE)
      and    name = i_filename
      and    type = FILE_TYPE;
  else
     delete  from ecx_files
      where   application_code = i_application_code
      and    (i_version is null or version = i_version)
      and     name = i_filename
      and     type = FILE_TYPE;
   end if;

   if(sql%rowcount = 0)
   then
      i_retcode := 2;
      i_retmsg := ' XSLT does not Exist';
   else
      i_retcode := 0;
      i_retmsg := ' XSLT Successfully Deleted';
   end if;
exception
when others then
   i_retcode := 2;
   i_retmsg := SQLERRM || '   XSLT cannot be deleted';
end del;

end ecx_xslt_utils;

/
