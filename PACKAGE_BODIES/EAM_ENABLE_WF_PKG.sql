--------------------------------------------------------
--  DDL for Package Body EAM_ENABLE_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ENABLE_WF_PKG" as
/* $Header: EAMVWFEB.pls 120.0 2005/10/17 00:43:34 cboppana noship $ */

procedure LOAD_SEED_ROW(
          x_upload_mode                         in      varchar2,
          x_custom_mode                         in      varchar2,
          x_maintenance_object_source	in	number,
	  x_enable_workflow			in	varchar2,
          x_owner                               in      varchar2,
          x_last_update_date                    in      varchar2) is
begin
   if (x_upload_mode = 'NLS') then
      return;
   else
      EAM_ENABLE_WF_PKG.LOAD_ROW(
         x_custom_mode,
          x_maintenance_object_source,
	  x_enable_workflow,
	 x_owner,
	 x_last_update_date);
   end if;
end LOAD_SEED_ROW;

procedure LOAD_ROW(
          x_custom_mode                         in      varchar2,
          x_maintenance_object_source	in	number,
	  x_enable_workflow			in	varchar2,
          x_owner                               in      varchar2,
          x_last_update_date                    in      varchar2) is
   user_id NUMBER := 0;
   f_ludate  date;    -- entity update date in file
   db_luby   number;  -- entity owner in db
   db_ludate date;    -- entity update date in db
begin
   user_id := fnd_load_util.owner_id(x_owner);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

   select LAST_UPDATED_BY, LAST_UPDATE_DATE
   into   db_luby, db_ludate
   from  EAM_ENABLE_WORKFLOW
   where  MAINTENANCE_OBJECT_SOURCE = x_maintenance_object_source;

   if (fnd_load_util.upload_test(user_id, f_ludate, db_luby,
                                 db_ludate, x_custom_mode)) then
      update EAM_ENABLE_WORKFLOW set
             MAINTENANCE_OBJECT_SOURCE =  x_maintenance_object_source,
             ENABLE_WORKFLOW =  x_enable_workflow,
             LAST_UPDATE_DATE = f_ludate,
             LAST_UPDATED_BY = user_id,
             LAST_UPDATE_LOGIN = 0
      where  MAINTENANCE_OBJECT_SOURCE  = x_maintenance_object_source;
   end if;

exception
   when no_data_found then
      -- Row doesn't exist yet.  Now this insert statement is placed here.
      insert into EAM_ENABLE_WORKFLOW (
                  MAINTENANCE_OBJECT_SOURCE,
                  ENABLE_WORKFLOW,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN )
           values (
                  x_maintenance_object_source,
                  x_enable_workflow,
                  f_ludate,
                  user_id,
                  f_ludate,
                  user_id,
                  0 );

end LOAD_ROW;


end EAM_ENABLE_WF_PKG;

/
