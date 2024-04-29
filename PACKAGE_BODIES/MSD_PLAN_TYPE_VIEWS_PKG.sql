--------------------------------------------------------
--  DDL for Package Body MSD_PLAN_TYPE_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_PLAN_TYPE_VIEWS_PKG" as
/* $Header: msdptvpb.pls 120.0 2005/05/25 18:42:07 appldev noship $ */

PROCEDURE LOAD_ROW(
          X_plan_type    varchar2,
          X_view_type  varchar2,
          X_view_name     varchar2,
          x_last_update_date in varchar2,
	  x_lob_flag in varchar2,
          x_owner in varchar2,
          x_custom_mode in varchar2) IS

        f_luby    number;  -- entity owner in file
        f_ludate  date;    -- entity update date in file
        db_luby   number;  -- entity owner in db
        db_ludate date;    -- entity update date in db
    begin
         -- Translate owner to file_last_updated_by
         if (x_owner = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from MSD_PLAN_TYPE_VIEWS
          where PLAN_TYPE = x_plan_type
            and VIEW_TYPE = x_view_type
            --and VIEW_NAME = x_view_name
            and nvl(LOB_FLAG,'-1') = nvl( x_lob_flag,'-1') ;

          -- Update record, honoring customization mode.
          -- Record should be updated only if:
          -- a. CUSTOM_MODE = FORCE, or
          -- b. file owner is CUSTOM, db owner is SEED
          -- c. owners are the same, and file_date > db_date
          if ((x_custom_mode = 'FORCE') or
              ((f_luby = 0) and (db_luby = 1)) or
              ((f_luby = db_luby) and (f_ludate > db_ludate)))
          then
            update MSD_PLAN_TYPE_VIEWS set
             PLAN_TYPE = x_plan_type,
             VIEW_TYPE = x_view_type,
             VIEW_NAME = x_view_name,
             LOB_FLAG = x_lob_flag,
             LAST_UPDATE_DATE = f_ludate,
             LAST_UPDATED_BY = f_luby,
             LAST_UPDATE_LOGIN = 0
            where PLAN_TYPE = x_plan_type
              and VIEW_TYPE = x_view_type
              --and VIEW_NAME = x_view_name
               and nvl(LOB_FLAG,-1) = nvl( x_lob_flag,-1) ;
          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into MSD_PLAN_TYPE_VIEWS (
              PLAN_TYPE,
              VIEW_TYPE,
              VIEW_NAME,
               LOB_FLAG,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN
            ) values (
              x_plan_type,
              x_view_type,
              x_view_name,
               x_lob_flag,
              f_ludate,
              f_luby,
              f_ludate,
              f_luby,
              0);
        end;
     end LOAD_ROW;


end MSD_PLAN_TYPE_VIEWS_PKG;

/
